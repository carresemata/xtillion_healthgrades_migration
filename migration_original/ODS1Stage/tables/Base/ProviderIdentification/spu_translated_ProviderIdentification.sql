CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERIDENTIFICATION() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderIdentification depends on: 
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.IdentificationType

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_ProviderIdentification');
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
                            I.IdentificationTypeID,
                            JSON.Identification_Identifier AS IdentificationValue,
                            JSON.Identification_ExpirationDate AS ExpirationDate,
                            JSON.Identification_SourceCode AS SourceCode,
                            JSON.Identification_LastUpdateDate AS LastUpdateDate
                        FROM
                            Raw.VW_PROVIDER_PROFILE AS JSON
                            JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                            JOIN Base.IdentificationType AS I ON I.IdentificationTypeCode = JSON.Identification_IdentificationTypeCode
                        FROM
                            Raw.VW_PROVIDER_PROFILE AS JSON
                            JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                        WHERE
                            PROVIDER_PROFILE IS NOT NULL AND
                            ProviderId IS NOT NULL AND
                            IdentificationTypeID IS NOT NULL
                            QUALIFY ROW_NUMBER() OVER(PARTITION BY ProviderID ORDER BY CREATE_DATE DESC) = 1$$;

--- Insert Statement
insert_statement := ' INSERT  
                        (ProviderIdentificationID,
                        ProviderID,
                        IdentificationTypeID,
                        IdentificationValue,
                        ExpirationDate,
                        SourceCode,
                        LastUpdateDate)
                      VALUES 
                        (UUID_STRING(),
                        source.ProviderID,
                        source.IdentificationTypeID,
                        source.IdentificationValue,
                        source.ExpirationDate,
                        source.SourceCode,
                        source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.ProviderIdentification as target USING 
                   ('||select_statement||') as source 
                   ON source.Providerid = target.Providerid
                   WHEN MATCHED THEN DELETE
                   WHEN NOT MATCHED THEN '||insert_statement;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
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