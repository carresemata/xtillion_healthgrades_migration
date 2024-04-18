CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTRAINING()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderTraining depends on: 
--- Raw.PROVIDER_PROFILE_PROCESSING
--- Base.Provider
--- Base.Training

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    -- no conditionals


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
  -- Select Statement
  select_statement := $$
      SELECT DISTINCT
        P.ProviderId,
        T.TrainingId,
        JSON.Training_TrainingLink AS TrainingLink,
        IFNULL(JSON.Training_SourceCode, 'Profisee') AS SourceCode,
        IFNULL(JSON.Training_LastUpdateDate, CURRENT_TIMESTAMP()) AS LastUpdateDate
      FROM Raw.VW_PROVIDER_PROFILE AS JSON
      LEFT JOIN Base.Provider P ON JSON.ProviderCode = P.ProviderCode
      LEFT JOIN Base.Training T ON JSON.Training_TrainingCode = T.TrainingCode
      WHERE 
        JSON.PROVIDER_PROFILE IS NOT NULL AND
        ProviderId IS NOT NULL AND
        TrainingId IS NOT NULL
        QUALIFY ROW_NUMBER() OVER (PARTITION BY ProviderId, Training_TrainingCode ORDER BY CREATE_DATE DESC) = 1
  $$;




--- Insert Statement
insert_statement := ' INSERT 
                        (ProviderTrainingId,
                          ProviderId, 
                          TrainingId,
                          TrainingLink,
                          SourceCode,
                          LastUpdateDate
                        )
                        VALUES (
                          UUID_STRING(),
                          source.ProviderId,
                          source.TrainingId,
                          source.TrainingLink,
                          source.SourceCode,
                          source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.ProviderTraining as target USING 
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
    RETURN status;


        
EXCEPTION
    WHEN OTHER THEN
          status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
          RETURN status;


    
END;