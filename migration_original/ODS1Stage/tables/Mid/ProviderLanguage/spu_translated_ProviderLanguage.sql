CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.Mid.SP_LOAD_PROVIDERLANGUAGE(IsProviderDeltaProcessing BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 

DECLARE
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.Provider
-- Base.ProviderToLanguage 
-- Base.Language 
-- raw.ProviderDeltaProcessing 

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

source_table STRING;
select_statement STRING; 
insert_statement STRING;
merge_statement STRING; 
status STRING;
    procedure_name varchar(50) default('sp_load_ProviderLanguage');
    execution_start DATETIME default getdate();


---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------  
BEGIN

    IF (IsProviderDeltaProcessing) THEN
        source_table := $$ raw.ProviderDeltaProcessing $$;
    ELSE
        source_table := $$ Base.Provider $$;
END IF;

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------  

    select_statement := $$
                       (WITH CTE_ProviderBatch AS (
                                SELECT p.ProviderID
                                FROM $$ ||source_table|| $$  p
                                ORDER BY p.ProviderID
                        ),
                    
                        CTE_ProviderLanguage AS (
                        SELECT ptl.ProviderID, l.LanguageName,
                               CASE WHEN mpl.ProviderID IS NULL THEN 1 ELSE 0 END AS ActionCode
                        FROM CTE_ProviderBatch pb
                        JOIN Base.ProviderToLanguage AS ptl ON ptl.ProviderID = pb.ProviderID
                        JOIN Base.Language AS l ON l.LanguageID = ptl.LanguageID
                        LEFT JOIN Mid.ProviderLanguage mpl ON ptl.ProviderID = mpl.ProviderID AND l.LanguageName = mpl.LanguageName
                        )
                        
                        SELECT 
                            pl.ProviderID,
                            pl.LanguageName,
                            pl.ActionCode
                        FROM CTE_ProviderLanguage pl)
                        $$;
      

      ---------------------------------------------------------
      --------- 4. Actions (Inserts and Updates) --------------
      ---------------------------------------------------------
      insert_statement := $$
                         INSERT
                          ( 
                          ProviderID,
                          LanguageName
                          )
                         VALUES 
                          (
                          source.ProviderID,
                          source.LanguageName
                          )
                          $$;


     merge_statement := $$
                        MERGE INTO Mid.PROVIDERLANGUAGE as target
                        USING $$ || select_statement || $$ AS source
                        ON source.ProviderID = target.ProviderID
                        WHEN MATCHED AND source.ProviderID = target.ProviderID 
                                     AND source.LanguageName = target.LanguageName
                                     AND source.ProviderID IS NULL THEN DELETE
                        WHEN NOT MATCHED AND source.ActionCode = 1 THEN $$ || insert_statement;
        

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