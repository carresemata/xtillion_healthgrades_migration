CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOOFFICE()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
DECLARE

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- BASE.ProviderToOffice depends on:
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.Office

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

select_statement STRING; -- CTE and Select statement for the Merge
insert_statement STRING; -- Insert statement for the Merge
merge_statement STRING; -- Merge statement to final table
status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_ProviderToOffice');
    execution_start DATETIME default getdate();


---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------

BEGIN
-- no conditionals

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- Select Statement
select_statement := $$ SELECT DISTINCT
                            P.ProviderId,
                            O.OfficeId, 
                            JSON.Office_OfficeName AS OfficeName,
                            JSON.Office_PracticeName AS PracticeName, 
                            -- IsPrimaryOffice
                            JSON.Office_OfficeRank AS ProviderOfficeRank,
                            IFNULL(JSON.Office_SourceCode, 'Profisee') AS SourceCode,
                            -- ProviderOfficeRankInferenceCode
                            -- SourceAddressCount
                            IFNULL(JSON.Office_LastUpdateDate, SYSDATE()) AS LastUpdateDate
                        
                        FROM RAW.VW_PROVIDER_PROFILE AS JSON
                            LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                            JOIN Base.Office AS O ON O.OfficeCode = JSON.Office_OfficeCode
                        WHERE
                            PROVIDER_PROFILE IS NOT NULL AND
                            ProviderID IS NOT NULL AND
                            OfficeID IS NOT NULL AND
                            JSON.Office_OfficeCode IS NOT NULL
                        QUALIFY row_number() over(partition by ProviderId, JSON.Office_OfficeCode order by CREATE_DATE desc)= 1 $$;

-- Insert Statement
insert_statement := $$
    INSERT (
        ProviderToOfficeID,
        ProviderID,
        OfficeID,
        OfficeName,
        PracticeName,
        --IsPrimaryOffice,
        ProviderOfficeRank,
        SourceCode,
        --ProviderOfficeRankInferenceCode,
        --SourceAddressCount,
        LastUpdateDate
    )
    VALUES
        (UUID_STRING(),
        source.ProviderID,
        source.OfficeID,
        source.OfficeName,
        source.PracticeName,
        --source.IsPrimaryOffice,
        source.ProviderOfficeRank,
        source.SourceCode,
        --source.ProviderOfficeRankInferenceCode,
        --source.SourceAddressCount,
        source.LastUpdateDate) $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------

merge_statement := ' MERGE INTO Base.ProviderToOffice AS TARGET
                    USING (' || select_statement || ') AS SOURCE
                    ON TARGET.ProviderID = SOURCE.ProviderID AND TARGET.OfficeID = SOURCE.OfficeID
                    WHEN MATCHED THEN DELETE
                    WHEN NOT MATCHED THEN' || insert_statement;

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