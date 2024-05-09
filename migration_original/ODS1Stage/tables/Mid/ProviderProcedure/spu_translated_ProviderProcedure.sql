CREATE OR REPLACE PROCEDURE ODS1_STAGE.Mid.SP_LOAD_PROVIDERPROCEDURE(IsProviderDeltaProcessing BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 

DECLARE
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

--- Mid.ProviderProcedure depends on:
-- MDM_TEAM.MST.Provider_Profile_Processing
-- Base.Provider
-- Base.EntityToMedicalTerm
-- Base.MedicalTerm
-- Base.EntityType
-- Base.MedicalTermSet
-- Base.MedicalTermType

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------


source_table STRING; 
select_statement STRING; 
insert_statement STRING;
update_statement STRING;
merge_statement STRING; 
status STRING;

---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------  
BEGIN

    IF (IsProviderDeltaProcessing) THEN
        source_table := $$ MDM_TEAM.MST.Provider_Profile_Processing as ppp
                            JOIN Base.Provider as p on ppp.ref_provider_code = p.providercode $$;
    ELSE
        source_table := $$ Base.Provider $$;
END IF;

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------  

    select_statement := $$
                        (WITH CTE_ProviderBatch AS (
                        SELECT p.ProviderID
                        FROM $$ ||source_table|| $$
                        ORDER BY p.ProviderID
                        ),
                    
                        CTE_ProviderProcedure AS (
                            SELECT
                                etmt.EntityToMedicalTermID AS ProviderToProcedureID,
                                etmt.EntityID AS ProviderID,
                                mt.MedicalTermCode AS ProcedureCode,
                                mt.MedicalTermDescription1 AS ProcedureDescription,
                                mt.MedicalTermDescription2 AS ProcedureGroupDescription,
                                mt.LegacyKey,
                                CASE
                                    WHEN mpp.ProviderToProcedureID IS NULL THEN 1
                                    ELSE 0
                                END AS ActionCode
                            FROM CTE_ProviderBatch AS pb
                            INNER JOIN Base.EntityToMedicalTerm AS etmt ON etmt.EntityID = pb.ProviderID
                            INNER JOIN Base.MedicalTerm AS mt ON mt.MedicalTermID = etmt.MedicalTermID
                            INNER JOIN Base.EntityType AS et ON et.EntityTypeID = etmt.EntityTypeID
                            INNER JOIN Base.MedicalTermSet AS mts ON mts.MedicalTermSetID = mt.MedicalTermSetID
                            INNER JOIN Base.MedicalTermType AS mtt ON mtt.MedicalTermTypeID = mt.MedicalTermTypeID
                            LEFT JOIN Mid.ProviderProcedure AS mpp ON etmt.EntityToMedicalTermID = mpp.ProviderToProcedureID
                        )
                        
                        SELECT
                            pp.ProviderToProcedureID,
                            pp.ProviderID,
                            pp.ProcedureCode,
                            pp.ProcedureDescription,
                            pp.ProcedureGroupDescription,
                            pp.LegacyKey,
                            pp.ActionCode
                        FROM CTE_ProviderProcedure pp)
                        $$;
      

      ---------------------------------------------------------
      --------- 4. Actions (Inserts and Updates) --------------
      ---------------------------------------------------------

      update_statement := $$
                         UPDATE SET 
                            target.LegacyKey = source.LegacyKey,
                            target.ProcedureCode = source.ProcedureCode,
                            target.ProcedureDescription = source.ProcedureDescription,
                            target.ProcedureGroupDescription = source.ProcedureGroupDescription,
                            target.ProviderID = source.ProviderID
                          $$;

      
      insert_statement := $$
                         INSERT
                         ( 
                         LegacyKey,
                         ProcedureCode,
                         ProcedureDescription,
                         ProcedureGroupDescription,
                         ProviderID,
                         ProviderToProcedureID
                         )
                         VALUES 
                         (
                         source.LegacyKey,
                         source.ProcedureCode,
                         source.ProcedureDescription,
                         source.ProcedureGroupDescription,
                         source.ProviderID,
                         source.ProviderToProcedureID
                         )
                         $$;


     merge_statement := $$
                        MERGE INTO Mid.ProviderProcedure as target
                        USING $$ || select_statement || $$ AS source
                        ON source.ProviderToProcedureID = target.ProviderToProcedureID
                        WHEN MATCHED AND MD5(IFNULL(CAST(target.LegacyKey AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.LegacyKey AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.ProcedureCode AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.ProcedureCode AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.ProcedureDescription AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.ProcedureDescription AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.ProcedureGroupDescription AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.ProcedureGroupDescription AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.ProviderID AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.ProviderID AS VARCHAR), '')) 
                                        THEN $$ || update_statement || $$
                        WHEN MATCHED AND source.ProviderToProcedureID = target.ProviderToProcedureID AND target.ProviderToProcedureID IS NULL THEN DELETE
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