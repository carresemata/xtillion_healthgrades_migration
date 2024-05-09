CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOAPPOINTMENTAVAILABILITY()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
DECLARE
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- BASE.ProviderToAppointmentAvailability depends on:
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.AppointmentAvailability

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
select_statement STRING;
insert_statement STRING;
merge_statement STRING;
status STRING;
    procedure_name varchar(50) default('sp_load_ProviderToAppointmentAvailability');
    execution_start DATETIME default getdate();

---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------
-- Select Statement
select_statement :=  $$ SELECT
                            P.ProviderId,
                            AA.AppointmentAvailabilityID,
                            IFNULL(JSON.APPOINTMENTAVAILABILITY_SOURCECODE, 'Profisee') AS SourceCode,
                            IFNULL(JSON.APPOINTMENTAVAILABILITY_LASTUPDATEDATE, SYSDATE()) AS LastUpdatedDate
                        FROM RAW.VW_PROVIDER_PROFILE AS JSON
                            LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                            LEFT JOIN Base.AppointmentAvailability AS AA ON AA.APPOINTMENTAVAILABILITYCODE = JSON.APPOINTMENTAVAILABILITY_APPOINTMENTAVAILABILITYCODE
                        WHERE
                            PROVIDER_PROFILE IS NOT NULL AND
                            PROVIDERID IS NOT NULL AND
                            AppointmentAvailabilityID IS NOT NULL AND
                            JSON.APPOINTMENTAVAILABILITY_APPOINTMENTAVAILABILITYCODE IS NOT NULL
                        QUALIFY row_number() over(partition by PROVIDERID, JSON.APPOINTMENTAVAILABILITY_APPOINTMENTAVAILABILITYCODE order by CREATE_DATE desc) = 1$$;

-- Insert Statement
insert_statement := ' INSERT 
                        (ProviderToAppointmentAvailabilityID, 
                        ProviderID, 
                        AppointmentAvailabilityID, 
                        SourceCode, 
                        LastUpdatedDate)
                      VALUES (
                        UUID_STRING(),
                        source.ProviderID, 
                        source.AppointmentAvailabilityID, 
                        source.SourceCode, 
                        source.LastUpdatedDate)
                        ';


---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := 'MERGE INTO Base.ProviderToAppointmentAvailability AS target
USING (' || select_statement || ') AS source
ON target.ProviderID = source.ProviderID
AND target.AppointmentAvailabilityID = source.AppointmentAvailabilityID
WHEN MATCHED THEN DELETE
WHEN NOT MATCHED THEN ' || insert_statement;

---------------------------------------------------------
------------------- 5. Execution ------------------------
---------------------------------------------------------
EXECUTE IMMEDIATE merge_statement;

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
---------------------------------------------------------
status := 'Completed successfully';
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        RETURN status;

        EXCEPTION
        WHEN OTHER THEN
            status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, SPLIT_PART(REGEXP_SUBSTR(:status, 'Error code: ([0-9]+)'), ':', 2)::INTEGER, TRIM(SPLIT_PART(SPLIT_PART(:status, 'SQL Error:', 2), 'Error code:', 1)), SPLIT_PART(REGEXP_SUBSTR(:status, 'SQL State: ([0-9]+)'), ':', 2)::INTEGER; 

            RETURN status;
END;