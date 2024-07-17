CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOTELEHEALTHMETHOD(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertotelehealthmethod depends on: 
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.telehealthmethod
--- base.telehealthmethodtype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertotelehealthmethod');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
   
begin


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ with Cte_telehealth as (
                            SELECT distinct
                                p.ref_provider_code as providercode,
                                to_boolean(json.value:HAS_TELEHEALTH) as Telehealth_HasTelehealth,
                                ifnull(to_varchar(json.value:TELEHEALTH_METHOD_CODE), 'NA') as Telehealth_TelehealthMethodCode,
                                ifnull(ifnull(to_varchar(json.value:TELEHEALTH_URL), to_varchar(json.value:TELEHEALTH_PHONE)), to_varchar(json.value:TELEHEALTH_VENDOR_NAME)) as Telehealth_Telehealthmethod,
                                to_varchar(json.value:DATA_SOURCE_CODE) as Telehealth_SourceCode,
                                to_timestamp_ntz(json.value:UPDATED_DATETIME) as Telehealth_LastUpdateDate
                            FROM $$ || mdm_db || $$ .mst.provider_profile_processing as p
                            , lateral flatten(input => p.PROVIDER_PROFILE:TELEHEALTH) as json
                            where to_varchar(json.value:HAS_TELEHEALTH) = TRUE
                        )
                        select distinct
                            p.providerid,
                            tm.telehealthmethodid, 
                            tmt.methodtypecode,
                            ifnull(json.telehealth_SourceCode, 'Profisee') as SourceCode,
                            json.Telehealth_HasTelehealth as HasTeleHealth,
                            ifnull(json.telehealth_LastUpdateDate, current_timestamp()) as LastUpdatedDate
                        from
                            cte_telehealth as JSON
                            join base.provider as P on p.providercode = json.providercode
                            join base.telehealthmethodtype as TMT on tmt.methodtypecode = json.telehealth_TelehealthMethodCode
                            join base.telehealthmethod as TM on tm.telehealthmethodtypeid = tmt.telehealthmethodtypeid or json.telehealth_telehealthmethod = tm.telehealthmethod 
                        qualify row_number() over(partition by providerid order by telehealth_LastUpdateDate desc) = 1$$;


--- update statement
update_statement := ' update
                        set
                            target.sourcecode = source.sourcecode,
                            target.lastupdateddate = source.lastupdateddate';

--- insert Statement
insert_statement := ' insert  
                            (ProviderToTelehealthMethodId,
                            ProviderId,
                            TelehealthMethodId,
                            SourceCode,
                            LastUpdatedDate)
                      values 
                            (utils.generate_uuid(source.providerid || source.telehealthmethodid), 
                            source.providerid,
                            source.telehealthmethodid,
                            source.sourcecode,
                            source.lastupdateddate)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providertotelehealthmethod as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid and source.telehealthmethodid = target.telehealthmethodid
                   when matched then ' || update_statement || '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToTelehealthMethod;
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