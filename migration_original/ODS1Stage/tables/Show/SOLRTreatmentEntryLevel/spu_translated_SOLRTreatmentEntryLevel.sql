
-- 1. spuSOLRTreatmentEntryLevel (validated in snowflake)
CREATE OR REPLACE PROCEDURE DEV.SP_LOAD_SOLRTREATMENTENTRYLEVEL() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  

DECLARE

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- SOLRTreatmentEntryLevel depends on : Show.SOLRTreatmentEntryLevel, Base.SpecialtyToCondition, Base.TreatmentLevel, Base.SpecialtyToProcedureMedical, Base.Specialty, and Base.MedicalTerm
    

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE statement
    load_statement STRING; -- Insert statement to final table
    final_execution STRING; -- Execution of the load and select
    status STRING; -- Status monitoring

   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   

BEGIN
-- No conditionals


---------------------------------------------------------
--------------- 3. Select statements --------------------
---------------------------------------------------------     


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
                    
                        SELECT
                            Med.RefMedicalTermCode AS DCPCode,
                            cteTreat.TreatmentLevelDescription,
                            Spec.SpecialtyCode,
                            Spec.SpecialtyDescription,
                            cteTreat.IsMarketView AS ForMarketViewLoad
                        FROM
                            cte_treatment_spec cteTreat
                            JOIN Base.Specialty Spec ON Spec.SpecialtyID = cteTreat.SpecialtyID
                            JOIN Base.MedicalTerm Med ON Med.MedicalTermID = cteTreat.MedicalTermID
                        GROUP BY
                            DCPCode,
                            cteTreat.TreatmentLevelDescription,
                            Spec.SpecialtyCode,
                            Spec.SpecialtyDescription,
                            ForMarketViewLoad';

                     
---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


load_statement:= 'INSERT INTO Dev.SOLRTreatmentEntryLevel 
                    (DCPCode,
                    TreatmentLevelDescription,
                    SpecialtyCode,
                    SpecialtyDescription,
                    ForMarketViewLoad)' ;

---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
final_execution:= load_statement || select_statement ;
EXECUTE IMMEDIATE final_execution ;



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
