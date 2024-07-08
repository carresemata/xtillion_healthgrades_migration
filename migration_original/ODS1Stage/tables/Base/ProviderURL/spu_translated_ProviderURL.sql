CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERURL(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providerurl depends on: 
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
    procedure_name varchar(50) default('sp_load_providerurl');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
   
begin
    

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ with Cte_provider_type as (
                            SELECT
                                p.ref_provider_code as providercode,
                                to_varchar(json.value:PROVIDER_TYPE_CODE) as ProviderType_ProviderTypeCode,
                                to_varchar(json.value:PROVIDER_TYPE_RANK) as ProviderType_ProviderTypeRank,
                                to_varchar(json.value:PROVIDER_TYPE_RANK_CALCULATED) as ProviderType_ProviderTypeRankCalculated,
                                to_varchar(json.value:DATA_SOURCE_CODE) as ProviderType_SourceCode,
                                to_timestamp_ntz(json.value:UPDATED_DATETIME) as ProviderType_LastUpdateDate
                            FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
                            , lateral flatten(input => p.PROVIDER_PROFILE:PROVIDER_TYPE) as json
                        )
                        select
                            json.providercode,
                            p.providerid,
                            replace(
                                replace(
                                    '/' || case
                                        when pt.providertypecode = 'DOC' then 'physician/dr-'
                                        when pt.providertypecode = 'DENT' then 'dentist/dr-'
                                        else 'providers/'
                                    end || lower(p.firstname) || '-' || lower(p.lastname) || '-' || lower(p.providercode),
                                    '''',
                                    ''
                                ),
                                ' ',
                                '-'
                            ) as URL,
                            ifnull(json.providertype_SourceCode, 'Profisee') as SourceCode,
                            ifnull(json.providertype_LastUpdateDate, sysdate()) as LastUpdateDate
                        from
                            cte_provider_type as JSON
                            join base.provider as P on p.providercode = json.providercode
                            join base.providertype as PT on pt.providertypecode = json.providertype_ProviderTypeCode
                        qualify row_number() over(partition by ProviderID order by ifnull(json.providertype_ProviderTypeRankCalculated,1), ProviderType_LastUpdateDate desc) = 1
$$;



--- update statement
update_statement := ' update
                        set
                            target.url = source.url,
                            target.sourcecode = source.sourcecode,
                            target.lastupdatedate = source.lastupdatedate';

--- insert Statement
insert_statement := ' insert  
                        (ProviderURLID,
                        ProviderID,
                        providercode,
                        URL,
                        SourceCode,
                        LastUpdateDate)
                      values 
                        (utils.generate_uuid(source.providercode), -- done
                        source.providerid,
                        source.providercode,
                        source.url,
                        source.sourcecode,
                        source.lastupdatedate)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providerurl as target using 
                   ('||select_statement||') as source 
                   on source.providercode = target.providercode
                   when matched then ' || update_statement || '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution -----------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderURL;
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

            return status;
end;