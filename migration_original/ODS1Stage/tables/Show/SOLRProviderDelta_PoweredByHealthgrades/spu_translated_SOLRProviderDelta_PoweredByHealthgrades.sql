CREATE OR REPLACE PROCEDURE ODS1_STAGE.SHOW.SP_LOAD_SOLRProviderDelta_PoweredByHealthgrades()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 
DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Show.SOLRProvider
-- Base.ProviderCertification (formerly scdghcorp.ProviderCertification in SQL Server)

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

select_statement STRING;
insert_statement STRING; -- Insert statement for the Merge
merge_statement STRING; -- Merge statement to final table
status STRING; -- Status monitoring
BEGIN

---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------  

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------  
select_statement :=  $$ 
                     (WITH CTE_ClientProviders AS (
                        SELECT DISTINCT s.ProviderCode, s.providerId, s.SOLRProviderID, pc.SourceCode
                        FROM Show.SOLRProvider AS s
                        JOIN Base.ProviderCertification AS pc ON pc.ProviderCode = s.ProviderCode
                     ) 
                     SELECT DISTINCT
                        cp.ProviderID, 
                        '1' AS SolrDeltaTypeCode,
                        CURRENT_DATE() AS StartDeltaProcessDate,
                        '1' AS MidDeltaProcessComplete
                     FROM CTE_ClientProviders AS cp
                     ORDER BY cp.ProviderID)
                     $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------

insert_statement := $$
                    INSERT 
                      ( 
                      ProviderID,
                      SolrDeltaTypeCode,
                      StartDeltaProcessDate,
                      MidDeltaProcessComplete
                      )
                    VALUES 
                      (
                      source.ProviderID,
                      source.SolrDeltaTypeCode,
                      source.StartDeltaProcessDate,
                      source.MidDeltaProcessComplete
                      )
                    $$;

merge_statement := $$
                   MERGE INTO Show.SOLRProviderDelta_PoweredByHealthgrades as target 
                   USING $$|| select_statement ||$$ as source	
                   ON source.ProviderID = target.ProviderID
                   WHEN NOT MATCHED THEN $$|| insert_statement ||$$;
                   $$;

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