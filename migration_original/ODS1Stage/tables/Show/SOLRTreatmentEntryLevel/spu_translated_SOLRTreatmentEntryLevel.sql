
-- 1. spuSOLRTreatmentEntryLevel (validated in snowflake)
CREATE OR REPLACE PROCEDURE ODS1_STAGE.SHOW.SP_LOAD_SOLRTREATMENTENTRYLEVEL() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  

DECLARE

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- SOLRTreatmentEntryLevel depends on :
--- Show.SOLRTreatmentEntryLevel
--- Base.SpecialtyToCondition
--- Base.TreatmentLevel
--- Base.SpecialtyToProcedureMedical
--- Base.Specialty
--- Base.MedicalTerm
    

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE statement
    insert_statement STRING; -- Insert statement to final table
    merge_statement STRING; -- Merge statement
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   

BEGIN
-- No conditionals


---------------------------------------------------------
--------------- 3. Select statements --------------------
---------------------------------------------------------     

-- Select Statement
select_statement:= 'WITH cte_treatment_spec AS (
                        SELECT
                            SpecCond.SpecialtyID,
                            SpecCond.ConditionID AS MedicalTermID,
                            TreatLev.TreatmentLevelDescription,
                            TreatLev.IsMarketView
                        FROM
                            Base.SpecialtyToCondition AS SpecCond
                            JOIN Base.TreatmentLevel AS TreatLev ON TreatLev.TreatmentLevelID = SpecCond.TreatmentLevelID
                        UNION
                        SELECT
                            SpecProc.SpecialtyID,
                            SpecProc.ProcedureMedicalID AS MedicalTermID,
                            TreatLev.TreatmentLevelDescription,
                            TreatLev.IsMarketView
                        FROM
                            Base.SpecialtyToProcedureMedical AS SpecProc
                            JOIN Base.TreatmentLevel AS TreatLev ON TreatLev.TreatmentLevelID = SpecProc.TreatmentLevelID
                    )
                    
                        SELECT DISTINCT
                            Med.RefMedicalTermCode AS DCPCode,
                            cteTreat.TreatmentLevelDescription,
                            Spec.SpecialtyCode,
                            Spec.SpecialtyDescription,
                            cteTreat.IsMarketView AS ForMarketViewLoad
                        FROM
                            cte_treatment_spec cteTreat
                            JOIN Base.Specialty Spec ON Spec.SpecialtyID = cteTreat.SpecialtyID
                            JOIN Base.MedicalTerm Med ON Med.MedicalTermID = cteTreat.MedicalTermID';

--- Insert Statement
insert_statement := ' INSERT  (
                        DCPCode,
                        TreatmentLevelDescription,
                        SpecialtyCode,
                        SpecialtyDescription,
                        ForMarketViewLoad)
                      VALUES (
                        source.DCPCode,
                        source.TreatmentLevelDescription,
                        source.SpecialtyCode,
                        source.SpecialtyDescription,
                        source.ForMarketViewLoad);';

                     
---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := ' MERGE INTO Show.SOLRTreatmentEntryLevel as target 
                        USING (' ||select_statement|| ') as source 
                        ON target.DCPCode = source.DCPCode AND target.SpecialtyCode = source.SpecialtyCode
                        WHEN NOT MATCHED THEN '
                            || insert_statement ;

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