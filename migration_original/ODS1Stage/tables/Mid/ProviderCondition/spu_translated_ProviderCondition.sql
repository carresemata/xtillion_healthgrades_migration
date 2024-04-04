CREATE OR REPLACE PROCEDURE ODS1_STAGE.Mid.SP_LOAD_PROVIDERCONDITION(IsProviderDeltaProcessing BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.Provider
-- Base.EntityToMedicalTerm
-- Base.MedicalTerm
-- Base.EntityType
-- Base.MedicalTermSet
-- Base.MedicalTermType
-- raw.ProviderDeltaProcessing
-- Mid.ProviderCondition (*)

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

DECLARE

select_statement STRING; 
insert_statement STRING;
merge_statement STRING; 
status STRING;

---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------  

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------  

-- The conditional statements are included in this block since 
-- the conditional itself directly determines the select

BEGIN

      IF (IsProviderDeltaProcessing) THEN
        select_statement := $$
                            (WITH CTE_ProviderBatch AS (
                                SELECT pdp.ProviderID
                                FROM raw.ProviderDeltaProcessing AS pdp
                                ORDER BY pdp.ProviderID
                            ),
                            
                            CTE_ProviderCondition AS (
                                SELECT
                                    etmt.EntityToMedicalTermID AS ProviderToConditionID,
                                    etmt.EntityID AS ProviderID,
                                    mt.MedicalTermCode AS ConditionCode,
                                    mt.MedicalTermDescription1 AS ConditionDescription,
                                    mt.MedicalTermDescription2 AS ConditionGroupDescription,
                                    mt.LegacyKey
                                FROM CTE_ProviderBatch AS pb
                                INNER JOIN Base.EntityToMedicalTerm AS etmt ON etmt.EntityID = pb.ProviderID 
                                INNER JOIN Base.MedicalTerm AS mt ON mt.MedicalTermID = etmt.MedicalTermID
                                INNER JOIN Base.EntityType AS et ON et.EntityTypeID = etmt.EntityTypeID
                                INNER JOIN Base.MedicalTermSet AS mts ON mts.MedicalTermSetID = mt.MedicalTermSetID
                                INNER JOIN Base.MedicalTermType AS mtt ON mtt.MedicalTermTypeID = mt.MedicalTermTypeID
                                INNER JOIN Mid.ProviderCondition AS mpc ON etmt.EntityToMedicalTermID = mpc.ProviderToConditionID
                                WHERE mts.MedicalTermSetCode = 'HGProvider' AND mtt.MedicalTermTypeCode = 'Condition'
                                 AND (MD5(IFNULL(CAST(mt.MedicalTermCode AS VARCHAR), '')) <> MD5(IFNULL(CAST(mpc.ConditionCode AS VARCHAR), '')) OR 
                                      MD5(IFNULL(CAST(mt.MedicalTermDescription1 AS VARCHAR), '')) <> MD5(IFNULL(CAST(mpc.ConditionDescription AS VARCHAR), '')) OR 
                                      MD5(IFNULL(CAST(mt.MedicalTermDescription2 AS VARCHAR), '')) <> MD5(IFNULL(CAST(mpc.ConditionGroupDescription AS VARCHAR), '')) OR 
                                      MD5(IFNULL(CAST(mt.LegacyKey AS VARCHAR), '')) <> MD5(IFNULL(CAST(mpc.LegacyKey AS VARCHAR), '')) OR 
                                      MD5(IFNULL(CAST(etmt.EntityID AS VARCHAR), '')) <> MD5(IFNULL(CAST(mpc.ProviderID AS VARCHAR), '')))
                             ) 
                             
                             SELECT
                              pc.ConditionCode,
                              pc.ConditionDescription,
                              pc.ConditionGroupDescription,
                              pc.LegacyKey,
                              pc.ProviderID,
                              pc.ProviderToConditionID
                             FROM CTE_ProviderCondition pc)
                            $$;
                            
      ELSE
        select_statement := $$
                            (WITH CTE_ProviderBatch AS (
                              SELECT p.ProviderID
                              FROM Base.Provider AS p
                              ORDER BY p.ProviderID
                            ),
                            
                            CTE_ProviderCondition AS (
                              SELECT
                                etmt.EntityToMedicalTermID AS ProviderToConditionID,
                                etmt.EntityID AS ProviderID,
                                mt.MedicalTermCode AS ConditionCode,
                                mt.MedicalTermDescription1 AS ConditionDescription,
                                mt.MedicalTermDescription2 AS ConditionGroupDescription,
                                mt.LegacyKey
                              FROM CTE_ProviderBatch AS pb
                              INNER JOIN Base.EntityToMedicalTerm AS etmt ON etmt.EntityID = pb.ProviderID 
                              INNER JOIN Base.MedicalTerm AS mt ON mt.MedicalTermID = etmt.MedicalTermID
                              INNER JOIN Base.EntityType AS et ON et.EntityTypeID = etmt.EntityTypeID
                              INNER JOIN Base.MedicalTermSet AS mts ON mts.MedicalTermSetID = mt.MedicalTermSetID
                              INNER JOIN Base.MedicalTermType AS mtt ON mtt.MedicalTermTypeID = mt.MedicalTermTypeID
                              WHERE mts.MedicalTermSetCode = 'HGProvider' AND mtt.MedicalTermTypeCode = 'Condition'
                            )
                            
                            SELECT
                              pc.ConditionCode,
                              pc.ConditionDescription,
                              pc.ConditionGroupDescription,
                              pc.LegacyKey,
                              pc.ProviderID,
                              pc.ProviderToConditionID
                            FROM CTE_ProviderCondition pc)
                            $$;
      END IF;
      

      ---------------------------------------------------------
      --------- 4. Actions (Inserts and Updates) --------------
      ---------------------------------------------------------
      insert_statement := $$
                         INSERT 
                          ( 
                          ConditionCode,
                          ConditionDescription,
                          ConditionGroupDescription,
                          LegacyKey,
                          ProviderID,
                          ProviderToConditionID
                          )
                         VALUES 
                          (
                          source.ConditionCode,
                          source.ConditionDescription,
                          source.ConditionGroupDescription,
                          source.LegacyKey,
                          source.ProviderID,
                          source.ProviderToConditionID
                          )
                          $$;


      merge_statement := $$
                        MERGE INTO Mid.ProviderCondition AS target 
                        USING $$ || select_statement || $$ AS source	
                        ON source.ProviderToConditionID = target.ProviderToConditionID
                        WHEN MATCHED AND target.ProviderToConditionID = source.ProviderToConditionID
                                     AND source.ProviderID = target.ProviderID 
                                     AND source.ProviderToConditionID IS NULL THEN DELETE
                        WHEN NOT MATCHED THEN $$ || insert_statement;

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