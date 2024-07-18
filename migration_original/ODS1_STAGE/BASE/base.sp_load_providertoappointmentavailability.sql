CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOAPPOINTMENTAVAILABILITY(is_full BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS declare
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.providertoappointmentavailability depends on:
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.appointmentavailability

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
update_statement string;
merge_statement string;
status string;
procedure_name varchar(50) default('sp_load_providertoappointmentavailability');
execution_start datetime default getdate();
mdm_db string default('mdm_team');

begin
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------
-- select Statement
select_statement :=  $$ with Cte_appointment_availability as (
                            SELECT
                                p.ref_provider_code as providercode,
                                to_varchar(json.value:APPOINTMENT_AVAILABILITY_CODE ) as  AppointmentAvailability_AppointmentAvailabilityCode,
                                to_varchar(json.value:DATA_SOURCE_CODE ) as  AppointmentAvailability_SourceCode,
                                to_varchar(json.value:UPDATED_DATETIME ) as  AppointmentAvailability_LastUpdateDate,
                            FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
                                , lateral flatten (input => p.PROVIDER_PROFILE:APPOINTMENT_AVAILABILITY ) as json
                        )
                        select
                            p.providerid,
                            aa.appointmentavailabilityid,
                            ifnull(AppointmentAvailability_SourceCode, 'Profisee') as SourceCode,
                            ifnull(AppointmentAvailability_LastUpdateDate, sysdate()) as LastUpdatedDate
                        from cte_appointment_availability as json
                            inner join base.provider as P on p.providercode = json.providercode
                            inner join base.appointmentavailability as AA on aa.appointmentavailabilitycode = AppointmentAvailability_AppointmentAvailabilityCode
                        qualify row_number() over(partition by providerid, appointmentavailabilityid order by AppointmentAvailability_LastUpdateDate desc) = 1 $$;

-- insert Statement
insert_statement := ' insert 
                        (ProviderToAppointmentAvailabilityID, 
                        ProviderID, 
                        AppointmentAvailabilityID, 
                        SourceCode, 
                        LastUpdatedDate)
                      values (
                        utils.generate_uuid(source.providerid || source.appointmentavailabilityid), 
                        source.providerid, 
                        source.appointmentavailabilityid, 
                        source.sourcecode, 
                        source.lastupdateddate)
                        ';

--- update statement
update_statement := ' update
                        set
                            target.SourceCode = source.sourcecode,
                            target.LastUpdatedDate = source.lastupdateddate ';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := 'merge into base.providertoappointmentavailability as target
                    using (' || select_statement || ') as source
                    on target.providerid = source.providerid and target.appointmentavailabilityid = source.appointmentavailabilityid
                    when matched then ' || update_statement || '
                    when not matched then ' || insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToAppointmentAvailability;
end if; 
execute immediate merge_statement;

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