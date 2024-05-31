CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOAPPOINTMENTAVAILABILITY("IS_FULL" BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'declare
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.providertoappointmentavailability depends on:
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.appointmentavailability

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
merge_statement string;
status string;
    procedure_name varchar(50) default(''sp_load_providertoappointmentavailability'');
    execution_start datetime default getdate();

begin
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------
-- select Statement
select_statement :=  $$ select
                            p.providerid,
                            aa.appointmentavailabilityid,
                            ifnull(appav.value:DATA_SOURCE_CODE, ''Profisee'') as SourceCode,
                            ifnull(appav.value:UPDATED_DATETIME, sysdate()) as LastUpdatedDate
                        from raw.vw_PROVIDER_PROFILE as JSON
                            inner join base.provider as P on p.providercode = json.providercode,
                            lateral flatten (input => json.appointmentavailability) appav
                            inner join base.appointmentavailability as AA on aa.appointmentavailabilitycode = to_varchar(appav.value:APPOINTMENT_AVAILABILITY_CODE)
                        where
                            PROVIDER_PROFILE is not null $$;

-- insert Statement
insert_statement := '' insert 
                        (ProviderToAppointmentAvailabilityID, 
                        ProviderID, 
                        AppointmentAvailabilityID, 
                        SourceCode, 
                        LastUpdatedDate)
                      values (
                        uuid_string(),
                        source.providerid, 
                        source.appointmentavailabilityid, 
                        source.sourcecode, 
                        source.lastupdateddate)
                        '';


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := ''merge into base.providertoappointmentavailability as target
using ('' || select_statement || '') as source
on target.providerid = source.providerid
and target.appointmentavailabilityid = source.appointmentavailabilityid
WHEN MATCHED then delete
when not matched then '' || insert_statement;

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
status := ''completed successfully'';
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        return status;

        exception
        when other then
            status := ''failed during execution. '' || ''sql error: '' || sqlerrm || '' error code: '' || sqlcode || ''. sql state: '' || sqlstate;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, split_part(regexp_substr(:status, ''error code: ([0-9]+)''), '':'', 2)::integer, trim(split_part(split_part(:status, ''sql error:'', 2), ''error code:'', 1)), split_part(regexp_substr(:status, ''sql state: ([0-9]+)''), '':'', 2)::integer; 

            return status;
end';