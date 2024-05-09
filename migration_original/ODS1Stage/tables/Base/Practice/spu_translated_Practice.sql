CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PRACTICE() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.Practice depends on: 
--- MDMM_TEAM.MST.PRACTICE_PROFILE_PROCESSING (RAW.VW_PRACTICE_PROFILE)

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_Practice');
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
                            IFNULL(JSON.Demographics_LastUpdateDate, CURRENT_TIMESTAMP()) AS LastUpdateDate,
                            JSON.Demographics_NPI AS NPI,
                            JSON.PracticeCode,
                            CASE WHEN JSON.Demographics_Logo = 'None' THEN NULL ELSE JSON.Demographics_Logo END AS PracticeLogo,
                            CASE WHEN JSON.Demographics_MedicalDirector = 'None' THEN NULL ELSE JSON.Demographics_MedicalDirector END AS PracticeMedicalDirector,
                            CASE WHEN JSON.Demographics_PracticeName LIKE '%&amp;%' THEN REPLACE(JSON.Demographics_PracticeName, '&amp;', '&') ELSE IFNULL(JSON.Demographics_PracticeName, '' ) END AS PracticeName,
                            IFNULL(JSON.Demographics_SourceCode, 'Profisee') AS SourceCode,
                            JSON.Demographics_YearPracticeEstablished AS YearPracticeEstablished
                        FROM Raw.VW_PRACTICE_PROFILE AS JSON
                        WHERE 
                            PRACTICE_PROFILE IS NOT NULL AND
                            PracticeCode IS NOT NULL AND
                            PracticeName IS NOT NULL AND
                            LENGTH(PracticeCode) <= 10
                        QUALIFY ROW_NUMBER() OVER(PARTITION BY PracticeCode ORDER BY CREATE_DATE DESC) = 1$$;

--- Update Statement
update_statement := ' UPDATE
                        SET
                            LastUpdateDate = source.LastUpdateDate,
                            NPI = source.NPI,
                            PracticeCode = source.PracticeCode,
                            PracticeLogo = source.PracticeLogo,
                            PracticeMedicalDirector = source.PracticeMedicalDirector,
                            PracticeName = source.PracticeName,
                            SourceCode = source.SourceCode,
                            YearPracticeEstablished = source.YearPracticeEstablished';

--- Insert Statement
insert_statement := ' INSERT 
                            (
                            PracticeID,
                            LastUpdateDate,
                            NPI,
                            PracticeCode,
                            PracticeLogo,
                            PracticeMedicalDirector,
                            PracticeName,
                            SourceCode,
                            YearPracticeEstablished
                            )
                        VALUES
                            (
                            UUID_STRING(),
                            source.LastUpdateDate,
                            source.NPI,
                            source.PracticeCode,
                            source.PracticeLogo,
                            source.PracticeMedicalDirector,
                            source.PracticeName,
                            source.SourceCode,
                            source.YearPracticeEstablished
                            )';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.Practice as target USING 
                   ('||select_statement||') as source 
                   ON source.PracticeCode = target.PracticeCode
                   WHEN MATCHED THEN '||update_statement|| '
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