CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOPROVIDERSUBTYPE(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertoprovidersubtype depends on: 
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.providersubtype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertoprovidersubtype');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement :=     $$ 
                        with cte_providersubtype as (
                            select
                                p.ref_provider_code as providercode,
                                to_varchar(json.value:PROVIDER_SUB_TYPE_CODE) as providersubtype_ProviderSubTypeCode,
                                to_varchar(json.value:PROVIDER_SUB_TYPE_RANK) as providersubtype_ProviderSubTypeRank,
                                to_varchar(json.value:DATA_SOURCE_CODE) as providersubtype_SourceCode,
                                to_timestamp_ntz(json.value:UPDATED_DATETIME) as providersubtype_LastUpdateDate
                            from $$||mdm_db||$$.mst.provider_profile_processing as p,
                            lateral flatten(input => p.PROVIDER_PROFILE:PROVIDER_SUB_TYPE) as json
                        )
                        
                        select distinct
                            p.providerid,
                            pst.providersubtypeid,
                            ifnull(json.providersubtype_SourceCode, 'Profisee') as SourceCode,
                            json.providersubtype_ProviderSubTypeRank as ProviderSubTypeRank,
                            2147483647 as ProviderSubTypeRankCalculated,
                            ifnull(json.providersubtype_LastUpdateDate, current_timestamp()) as LastUpdateDate
                        from cte_providersubtype as json
                        join base.provider as p on p.providercode = json.providercode
                        join base.providersubtype as pst on pst.providersubtypecode = json.providersubtype_ProviderSubTypeCode
                        qualify row_number() over(partition by providerid, ifnull(providersubtype_ProviderSubTypeCode, 'ALT') order by providersubtype_LastUpdateDate desc) = 1
                        $$;



--- insert Statement
insert_statement := ' insert  
                        (ProviderToProviderSubTypeID,
                        ProviderID,
                        ProviderSubTypeID,
                        SourceCode,
                        ProviderSubTypeRank,
                        ProviderSubTypeRankCalculated,
                        LastUpdateDate)
                      values 
                        (utils.generate_uuid(source.providerid || source.providersubtypeid), 
                        source.providerid,
                        source.providersubtypeid,
                        source.sourcecode,
                        source.providersubtyperank,
                        source.providersubtyperankcalculated,
                        source.lastupdatedate)';


update_statement := ' update set
                        target.SourceCode = source.SourceCode,
                        target.providersubtyperank = source.providersubtyperank,
                        target.providersubtyperankcalculated = source.providersubtyperankcalculated,
                        target.LastUpdateDate = source.LastUpdateDate';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providertoprovidersubtype as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid
                      and source.providersubtypeid = target.providersubtypeid
                   when matched then '||update_statement||'
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToProviderSubType;
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