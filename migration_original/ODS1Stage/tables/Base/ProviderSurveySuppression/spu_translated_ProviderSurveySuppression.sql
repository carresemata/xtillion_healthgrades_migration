CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERSURVEYSUPPRESSION()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
DECLARE

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- BASE.ProviderSurveySuppression depends on:
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.SurveySuppressionReason

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
select_statement STRING;
insert_statement STRING;
merge_statement STRING;
status STRING;
    procedure_name varchar(50) default('sp_load_ProviderSurveySuppression');
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
select_statement := $$ SELECT
                            P.ProviderId,
                            SSR.SurveySuppressionReasonID,
                            IFNULL(JSON.DEMOGRAPHICS_SOURCECODE, 'Profisee') AS SourceCode
                        FROM RAW.VW_PROVIDER_PROFILE AS JSON
                            LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                            LEFT JOIN Base.SurveySuppressionReason AS SSR ON SSR.SuppressionCode = JSON.DEMOGRAPHICS_SURVEYSUPPRESSIONREASONCODE
                        WHERE
                            JSON.PROVIDER_PROFILE IS NOT NULL AND
                            P.ProviderId IS NOT NULL AND
                            SurveySuppressionReasonID IS NOT NULL AND
                            JSON.DEMOGRAPHICS_SURVEYSUPPRESSIONREASONCODE IS NOT NULL
                        QUALIFY dense_rank() OVER (PARTITION BY ProviderId ORDER BY CREATE_DATE DESC)= 1 $$;

--- Insert Statement
insert_statement := ' INSERT 
                        (ProviderSurveySuppressionID, 
                        ProviderID, 
                        SurveySuppressionReasonID, 
                        SourceCode)
                      VALUES 
                        (UUID_STRING(), 
                        source.providerid, 
                        source.surveysuppressionreasonid, 
                        source.sourcecode)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------

merge_statement := ' MERGE INTO Base.ProviderSurveySuppression AS target 
USING ('||select_statement||') AS source
ON source.ProviderId = target.ProviderId AND source.SurveySuppressionReasonID = target.SurveySuppressionReasonID
WHEN MATCHED THEN DELETE 
WHEN NOT MATCHED THEN'||insert_statement;

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