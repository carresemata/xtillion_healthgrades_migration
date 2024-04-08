CREATE OR REPLACE PROCEDURE ODS1_STAGE.MID.SP_LOAD_PROVIDERRECOGNITION(IsProviderDeltaProcessing BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.Provider
-- Base.vwuProviderRecognition
-- Base.Award
-- Mid.ProviderRecognition
-- Raw.ProviderDeltaProcessing  

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

select_statement STRING; -- CTE and Select statement for the Merge
update_statement STRING; -- Update statement for the Merge
insert_statement STRING; -- Insert statement for the Merge
merge_statement STRING; -- Merge statement to final table
status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    IF (IsProviderDeltaProcessing) THEN
       select_statement := $$
       WITH CTE_ProviderBatch AS (
            SELECT pdp.ProviderID
            FROM Raw.ProviderDeltaProcessing as pdp),$$;
    ELSE
       select_statement := $$
       WITH CTE_ProviderBatch AS (
            SELECT p.ProviderID
            FROM Base.Provider as p
            ORDER BY p.ProviderID),$$;
    END IF;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

select_statement := select_statement || 
                    $$
                    CTE_ProviderRecognition AS (
                        SELECT DISTINCT
                        vwpr.ProviderID, 
                        a.AwardCode AS RecognitionCode, 
                        a.AwardDisplayName AS RecognitionDisplayName, 
                        NULL AS ServiceLine, 
                        NULL AS FacilityCode, 
                        NULL AS FacilityName,
                        0 AS ActionCode
                    FROM CTE_ProviderBatch AS pb  
                    INNER JOIN Base.vwuProviderRecognition vwpr ON vwpr.ProviderID = pb.ProviderID
                    INNER JOIN Base.Award a ON (vwpr.AwardID = a.AwardID)
                    ),

                    -- Insert Action
                    CTE_Action_1 AS (
                        SELECT 
                            cte.ProviderID,
                            cte.RecognitionCode,
                            cte.ServiceLine,
                            cte.FacilityCode,
                            1 AS ActionCode
                    FROM CTE_ProviderRecognition AS cte
                    LEFT JOIN Mid.ProviderRecognition AS mid 
                    ON (cte.ProviderID = mid.ProviderID AND cte.RecognitionCode = mid.RecognitionCode 
                        AND cte.ServiceLine = mid.ServiceLine AND cte.FacilityCode = mid.FacilityCode)
                    WHERE mid.ProviderID IS NULL),

                    
                    -- Update Action
                    CTE_Action_2 AS (
                        SELECT 
                            cte.ProviderID,
                            2 AS ActionCode
                        FROM CTE_ProviderRecognition AS cte
                        LEFT JOIN Mid.ProviderRecognition AS mid 
                        ON (cte.ProviderID = mid.ProviderID AND cte.RecognitionCode = mid.RecognitionCode 
                            AND cte.ServiceLine = mid.ServiceLine AND cte.FacilityCode = mid.FacilityCode)
                        WHERE 
                            MD5(IFNULL(cte.ProviderID::VARCHAR,'''')) <> MD5(IFNULL(mid.ProviderID::VARCHAR,'''')) OR 
                            MD5(IFNULL(cte.RecognitionCode::VARCHAR,'''')) <> MD5(IFNULL(mid.RecognitionCode::VARCHAR,'''')) OR 
                            MD5(IFNULL(cte.ServiceLine::VARCHAR,'''')) <> MD5(IFNULL(mid.ServiceLine::VARCHAR,'''')) OR 
                            MD5(IFNULL(cte.FacilityCode::VARCHAR,'''')) <> MD5(IFNULL(mid.FacilityCode::VARCHAR,'''')) OR
                            MD5(IFNULL(cte.FacilityName::VARCHAR,'''')) <> MD5(IFNULL(mid.FacilityName::VARCHAR,''''))
                     )
                     
                    SELECT DISTINCT
                        A0.ProviderID, 
                        A0.RecognitionCode, 
                        A0.RecognitionDisplayName, 
                        A0.ServiceLine,
                        A0.FacilityCode, 
                        A0.FacilityName, 
                        IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) AS ActionCode 
                    FROM CTE_ProviderRecognition AS A0 
                    LEFT JOIN CTE_Action_1 AS A1 ON A0.ProviderID = A1.ProviderID
                    LEFT JOIN CTE_Action_2 AS A2 ON A0.ProviderID = A2.ProviderID
                    WHERE IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) <> 0 
                    $$;
                        


---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------

update_statement := $$
                     UPDATE SET 
                        target.ProviderID = source.ProviderID,
                        target.RecognitionCode = source.RecognitionCode,
                        target.RecognitionDisplayName = source.RecognitionDisplayName,
                        target.ServiceLine = source.ServiceLine,
                        target.FacilityCode = source.FacilityCode,
                        target.FacilityName = source.FacilityName
                      $$;


--- Insert Statement
insert_statement :=   $$
                      INSERT  (
                               ProviderID,
                               RecognitionCode,
                               RecognitionDisplayName,
                               ServiceLine,
                               FacilityCode,
                               FacilityName
                               )
                      VALUES  (
                               source.ProviderID,
                               source.RecognitionCode,
                               source.RecognitionDisplayName,
                               source.ServiceLine,
                               source.FacilityCode,
                               source.FacilityName
                               )
                       $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := $$
                   MERGE INTO Mid.ProviderRecognition as target USING ($$|| select_statement ||$$) as source 
                   ON source.ProviderID = target.ProviderID
                   WHEN MATCHED AND source.ActionCode = 2 THEN $$|| update_statement ||$$
                   WHEN MATCHED AND target.ProviderID = source.ProviderID 
                        AND target.RecognitionCode = source.RecognitionCode 
                        AND IFNULL(target.ServiceLine, '''') = IFNULL(source.ServiceLine, '''') 
                        AND IFNULL(target.FacilityCode, '''') = IFNULL(source.FacilityCode, '''') 
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