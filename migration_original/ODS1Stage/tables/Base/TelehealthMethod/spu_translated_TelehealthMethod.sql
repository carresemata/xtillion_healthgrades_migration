CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_TELEHEALTHMETHOD(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.telehealthmethod depends on:
--- mdm_team.mst.provider_profile_processing 
--- base.telehealthmethodtype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_telehealthmethod');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ 
                    with cte_telehealth as (
                        select 
                            case 
                                when to_varchar(json.value:TELEHEALTH_URL) is not null then to_varchar(json.value:TELEHEALTH_URL)
                                when to_varchar(json.value:TELEHEALTH_PHONE) is not null then to_varchar(json.value:TELEHEALTH_PHONE)
                                else 'NA'
                            end as telehealth_TelehealthMethod,
                            case 
                                when to_varchar(json.value:TELEHEALTH_URL) is not null then 'URL'
                                when to_varchar(json.value:TELEHEALTH_PHONE) is not null then 'PHONE'
                                else 'NA'
                            end as telehealth_TelehealthMethodCode,
                            to_varchar(json.value:TELEHEALTH_VENDOR_NAME) as telehealth_TelehealthVendorName,
                            to_boolean(json.value:HAS_TELEHEALTH) as telehealth_HasTelehealth,
                            to_varchar(json.value:DATA_SOURCE_CODE) as telehealth_SourceCode,
                            to_timestamp_ntz(json.value:UPDATED_DATETIME) as telehealth_LastUpdateDate
                        from $$||mdm_db||$$.mst.provider_profile_processing,
                            lateral flatten(input => PROVIDER_PROFILE:TELEHEALTH) as json
                        where telehealth_TelehealthMethodCode is not null
                              and to_boolean(json.value:HAS_TELEHEALTH) = 'TRUE'
                    )
                    
                    select distinct
                        tmt.telehealthmethodtypeid,
                        json.telehealth_TelehealthMethod as TeleHealthMethod,
                        json.telehealth_TelehealthVendorName as ServiceName,
                        ifnull(json.telehealth_SourceCode, 'Profisee') as SourceCode,
                        json.telehealth_HasTelehealth as HasTeleHealth,
                        json.telehealth_LastUpdateDate as LastUpdatedDate
                    from cte_telehealth as json
                        join base.telehealthmethodtype as tmt on tmt.methodtypecode = json.telehealth_TelehealthMethodCode
                    qualify row_number() over(partition by telehealthmethodtypeid, telehealth_TelehealthMethod order by telehealth_LastUpdateDate desc) = 1
                    $$;


--- insert Statement
insert_statement := ' insert  
                            (TelehealthMethodId,
                            TelehealthMethodTypeId, 
                            TelehealthMethod, 
                            ServiceName, 
                            SourceCode, 
                            LastUpdatedDate)
                      values 
                            (uuid_string(),
                            source.telehealthmethodtypeid, 
                            source.telehealthmethod, 
                            source.servicename, 
                            source.sourcecode, 
                            source.lastupdateddate)';

update_statement := 'update set
                        target.ServiceName = source.ServiceName,
                        target.SourceCode = source.SourceCode,
                        target.LastUpdatedDate = source.LastUpdatedDate';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.telehealthmethod as target using 
                   ('||select_statement||') as source 
                   on source.telehealthmethodtypeid = target.telehealthmethodtypeid and source.telehealthmethod = target.telehealthmethod
                   when matched then '||update_statement||'
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.TelehealthMethod;
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