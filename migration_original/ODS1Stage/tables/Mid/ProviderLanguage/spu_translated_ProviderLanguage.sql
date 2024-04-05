CREATE OR REPLACE PROCEDURE ODS1_STAGE.Mid.SP_LOAD_PROVIDERLANGUAGE(IsProviderDeltaProcessing BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 

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

DECLARE

source_table STRING;
select_statement STRING; 
insert_statement STRING;
merge_statement STRING; 
status STRING;

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
        RETURN status;
    
    
    EXCEPTION
        WHEN OTHER THEN
              status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
              RETURN status;
                    
END;