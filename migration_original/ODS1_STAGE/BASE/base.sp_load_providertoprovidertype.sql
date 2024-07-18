CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOPROVIDERTYPE(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertoprovidertype depends on: 
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.providertype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertoprovidertype');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
begin
    
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement :=     $$ 
                        with cte_providertype as (
                            select
                                p.ref_provider_code as providercode,
                                to_varchar(json.value:PROVIDER_TYPE_CODE) as providertype_ProviderTypeCode,
                                to_varchar(json.value:PROVIDER_TYPE_RANK_CALCULATED) as providertype_ProviderTypeRankCalculated,
                                to_varchar(json.value:DATA_SOURCE_CODE) as providertype_SourceCode,
                                to_timestamp_ntz(json.value:UPDATED_DATETIME) as providertype_LastUpdateDate
                            from $$||mdm_db||$$.mst.provider_profile_processing as p,
                            lateral flatten(input => p.PROVIDER_PROFILE:PROVIDER_TYPE) as json
                        )
                        
                        select distinct
                            p.providerid,
                            pt.providertypeid,
                            ifnull(json.providertype_SourceCode, 'Profisee') as SourceCode,
                            ifnull(json.providertype_ProviderTypeRankCalculated, 1) as ProviderTypeRank,
                            2147483647 as ProviderTypeRankCalculated,
                            ifnull(json.providertype_LastUpdateDate, current_timestamp()) as LastUpdateDate
                        from cte_providertype as json
                            join base.provider as p on p.providercode = json.providercode
                            join base.providertype as pt on pt.providertypecode = ifnull(json.providertype_ProviderTypeCode, 'ALT')
                        qualify row_number() over(partition by providerid, pt.providertypeid order by providertype_LastUpdateDate desc) = 1
                        $$;



--- insert Statement
insert_statement := ' insert  
                        (ProviderToProviderTypeID,
                        ProviderID,
                        ProviderTypeID,
                        SourceCode,
                        ProviderTypeRank,
                        ProviderTypeRankCalculated,
                        LastUpdateDate)
                      values 
                        (utils.generate_uuid(source.providerid || source.providertypeid), 
                        source.providerid,
                        source.providertypeid,
                        source.sourcecode,
                        source.providertyperank,
                        source.providertyperankcalculated,
                        source.lastupdatedate)';

--- update statement
update_statement := ' update
                        set
                            target.SourceCode = source.sourcecode,
                            target.ProviderTypeRank = source.providertyperank,
                            target.ProviderTypeRankCalculated = source.providertyperankcalculated,
                            target.LastUpdateDate = source.lastupdatedate';
                        

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providertoprovidertype as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid and target.ProviderTypeID = source.providertypeid
                   when matched then ' || update_statement || '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToProviderType;
end if; 
execute immediate merge_statement ;

---------------------------------------------------------
--------------- 6. status monitoring --------------------
--------------------------------------------------------- 

status := 'completed successfully';
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        return status;

        exception
        when other then
            status := 'failed during execution. ' || 'sql error: ' || sqlerrm || ' error code: ' || sqlcode || '. sql state: ' || sqlstate;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, split_part(regexp_substr(:status, 'error code: ([0-9]+)'), ':', 2)::integer, trim(split_part(split_part(:status, 'sql error:', 2), 'error code:', 1)), split_part(regexp_substr(:status, 'sql state: ([0-9]+)'), ':', 2)::integer; 

            raise;
end;