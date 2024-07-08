CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOSUBSTATUS(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertosubstatus depends on: 
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.substatus

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertosubstatus');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$
                    with cte_providerstatus as (
                        select
                            p.ref_provider_code as providercode,
                            to_varchar(json.value:PROVIDER_STATUS_CODE) as providerstatus_ProviderStatusCode,
                            to_varchar(json.value:PROVIDER_STATUS_RANK) as providerstatus_ProviderStatusRank,
                            to_varchar(json.value:DATA_SOURCE_CODE) as providerstatus_SourceCode,
                            to_timestamp_ntz(json.value:UPDATED_DATETIME) as providerstatus_LastUpdateDate
                        from $$||mdm_db||$$.mst.provider_profile_processing as p,
                        lateral flatten(input => p.PROVIDER_PROFILE:PROVIDER_STATUS) as json
                    )
                    
                    select distinct
                        p.providerid,
                        s.substatusid,
                        ifnull(json.providerstatus_ProviderStatusRank, 2147483647) as HierarchyRank,
                        json.providerstatus_SourceCode as SourceCode,
                        json.providerstatus_LastUpdateDate as LastUpdateDate
                    from cte_providerstatus as json
                        join base.provider as p on p.providercode = json.providercode
                        join base.substatus as s on s.substatuscode = json.providerstatus_ProviderStatusCode
                    qualify row_number() over(partition by p.providerid, s.substatusid order by providerstatus_LastUpdateDate desc ) = 1 $$;


--- insert Statement
insert_statement := ' insert  
                        (ProviderToSubStatusID,
                        ProviderID,
                        SubStatusID,
                        HierarchyRank,
                        SourceCode,
                        LastUpdateDate)
                      values 
                        (utils.generate_uuid(source.providerid || source.substatusid), -- done
                        source.providerid,
                        source.substatusid,
                        source.hierarchyrank,
                        source.sourcecode,
                        source.lastupdatedate)';


 update_statement := ' update
                        set
                            target.HierarchyRank = source.hierarchyrank,
                            target.SourceCode = source.sourcecode,
                            target.LastUpdateDate = source.lastupdatedate
                    ';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providertosubstatus as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid and source.substatusid = target.substatusid
                   when matched then ' || update_statement || '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToSubStatus;
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