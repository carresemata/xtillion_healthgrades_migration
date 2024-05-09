CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERLICENSE()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderLicense depends on: 
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.ProviderMalpractice
--- Base.State

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    delete_statement STRING; -- Delete statement 
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_ProviderLicense');
    execution_start DATETIME default getdate();

   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    -- no conditionals


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
select_statement := $$ SELECT DISTINCT
                            P.ProviderID,
                            S.StateID, 
                            JSON.License_LicenseNumber AS LicenseNumber,
                            JSON.License_LicenseTerminationDate AS LicenseTerminationDate,
                            IFNULL(JSON.License_SourceCode, 'Profisee') AS SourceCode,
                            IFNULL(JSON.License_LastUpdateDate, CURRENT_TIMESTAMP()) AS LastUpdateDate,
                            JSON.License_LicenseTypeCode AS LicenseType
                        FROM
                            Raw.VW_PROVIDER_PROFILE AS JSON
                            LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                            LEFT JOIN Base.State AS S ON JSON.License_State = S.State
                        WHERE   
                            PROVIDER_PROFILE IS NOT NULL AND
                            IFNULL(LicenseTerminationDate, CURRENT_TIMESTAMP()) >= DATEADD('DAY', -90, CURRENT_TIMESTAMP())
                        	OR NOT (JSON.License_LicenseStatusCode != 'A' AND LicenseTerminationDate IS NULL) AND
                            ProviderID IS NOT NULL AND
                            LicenseNumber IS NOT NULL AND
                            StateID IS NOT NULL
                        QUALIFY ROW_NUMBER() OVER(PARTITION BY ProviderID, StateID, LicenseNumber, LicenseType  ORDER BY CREATE_DATE DESC) = 1 $$;


--- Delete Statement
delete_statement := 'DELETE FROM Base.ProviderLicense
                        WHERE ProviderLicenseID IN (
                            SELECT pc.ProviderLicenseID
                            FROM raw.VW_PROVIDER_PROFILE as p
                            INNER JOIN Base.Provider as pID ON pID.ProviderCode = p.ProviderCode
                            INNER JOIN Base.ProviderLicense as pc ON pc.ProviderID = pID.ProviderID
                            LEFT JOIN Base.ProviderMalpractice M ON M.ProviderId = PC.ProviderId -- before it was ON M.ProviderLicenseID = PC.ProviderLicenseID
                            WHERE M.ProviderMalpracticeID IS NULL
                        );';

--- Insert Statement
insert_statement := ' INSERT  
                        (ProviderLicenseID,
                        ProviderID,
                        StateID,
                        LicenseNumber,
                        LicenseTerminationDate,
                        SourceCode,
                        LastUpdateDate,
                        LicenseType)
                      VALUES 
                        (UUID_STRING(),
                        source.ProviderID,
                        source.StateID,
                        source.LicenseNumber,
                        source.LicenseTerminationDate,
                        source.SourceCode,
                        source.LastUpdateDate,
                        source.LicenseType)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.ProviderLicense as target USING 
                   ('||select_statement||') as source 
                   ON source.Providerid = target.Providerid
                   WHEN NOT MATCHED THEN '||insert_statement;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE delete_statement ;
EXECUTE IMMEDIATE merge_statement ;

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