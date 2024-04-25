CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTODISPLAYSPECIALTY(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderToDisplaySpecialty depends on:
--- Raw.VW_PROVIDER_PROFILE
--- Base.Provider
--- Base.ProviderToSpecialty
--- Base.DisplaySpecialtyRule
--- Base.DisplaySpecialtyRuleToSpecialty
--- Base.ProviderToCertificationSpecialty
--- Base.DisplaySpecialtyRuleToCertificationSpecialty
--- Base.ProviderToClinicalFocus
--- Base.DisplaySpecialtyRuleToClinicalFocus

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    delete_statement STRING;
    truncate_statement STRING;
    select_statement STRING; -- CTE and Select statement for the insert
    insert_statement STRING; -- Insert statement 
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    IF (IsProviderDeltaProcessing) THEN
           delete_statement := 'DELETE FROM Base.ProviderToDisplaySpecialty 
                                    WHERE ProviderID IN 
                                        (SELECT ProviderID 
                                         FROM Raw.ProviderDeltaProcessing)';

           select_statement := '
           WITH CTE_ProviderBatch AS (
                SELECT ProviderId
                FROM Raw.ProviderDeltaProcessing
            ),';
    ELSE
           truncate_statement := 'TRUNCATE TABLE Base.ProviderToDisplaySpecialty';
           
           select_statement := '
           WITH CTE_ProviderBatch AS (
                SELECT ProviderId
                FROM Base.Provider),';
    END IF;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement

-- If conditionals:
select_statement := select_statement || 
                    $$ CTE_ProviderBatch AS (
                                SELECT ProviderId
                                FROM Base.Provider),
                                
                            CTE_NotExists AS (
                              SELECT 1
                              FROM Base.ProviderToSpecialty pts
                              LEFT JOIN Base.DisplaySpecialtyRule AS dsr ON pts.specialtyid = dsr.specialtyid
                              LEFT JOIN Base.Provider AS P ON p.providerid = pts.providerid
                              LEFT JOIN Base.DisplaySpecialtyRuleToSpecialty dsrs
                                ON dsrs.DisplaySpecialtyRuleID = dsr.DisplaySpecialtyRuleID
                                AND dsrs.SpecialtyID = pts.SpecialtyID
                              WHERE pts.ProviderID = p.ProviderID
                                AND pts.IsSearchableCalculated = 1
                                AND dsrs.SpecialtyID IS NULL
                            ),
                            CTE_ProviderDisplay AS (
                              SELECT DISTINCT c.DisplaySpecialtyRuleID, a.ProviderID
                              FROM Base.ProviderToSpecialty a
                              JOIN CTE_ProviderBatch b ON b.ProviderID = a.ProviderID
                              JOIN Base.DisplaySpecialtyRule c ON c.SpecialtyID = a.SpecialtyID
                              WHERE a.IsSearchableCalculated = 1 AND
                                    NOT EXISTS (SELECT * FROM CTE_NotExists)
                            ),
                            CTE_ProviderCerts AS (
                                SELECT DISTINCT
                                    Cert.ProviderId,
                                    Dis.DisplaySpecialtyRuleID
                                FROM Base.ProviderToCertificationSpecialty AS Cert
                                JOIN CTE_ProviderDisplay AS CTE ON Cert.ProviderId = CTE.ProviderId
                                JOIN Base.DisplaySpecialtyRuleToCertificationSpecialty AS Dis ON Dis.DisplaySpecialtyRuleID = CTE.DisplaySpecialtyRuleID
                            ),
                            CTE_ProviderCF AS (
                                SELECT DISTINCT
                                    CF.ProviderId,
                                    DisCF.DisplaySpecialtyRuleID
                                FROM Base.ProviderToClinicalFocus AS CF
                                JOIN CTE_ProviderDisplay AS CTE ON CTE.ProviderId = CF.ProviderId
                                JOIN Base.DisplaySpecialtyRuleToClinicalFocus AS DisCF ON DisCF.DisplaySpecialtyRuleID = CTE.DisplaySpecialtyRuleID
                            ),
                            CTE_ProviderPrimarySpec AS (
                                SELECT
                                    ProvSpec.ProviderID,
                                    SpecRule.DisplayspecialtyRuleId
                                FROM Base.ProviderToSpecialty AS ProvSpec
                                JOIN CTE_ProviderDisplay AS CTE ON CTE.ProviderId = ProvSpec.ProviderId
                                JOIN Base.DisplaySpecialtyRule AS SpecRule ON SpecRule.DisplaySpecialtyRuleID = CTE.DisplaySpecialtyRuleID
                            )
                            SELECT DISTINCT
                                ProvDS.ProviderID,
                                SpecRule.SpecialtyId
                            FROM CTE_ProviderDisplay AS ProvDS
                                JOIN Base.DisplaySpecialtyRule AS SpecRule ON SpecRule.DisplaySpecialtyRuleID = ProvDS.ProviderId
                                LEFT JOIN CTE_ProviderCerts AS ProvCert ON ProvCert.ProviderId = ProvDS.ProviderId AND ProvCert.DisplaySpecialtyRuleID = SpecRule.DisplaySpecialtyRuleID
                                LEFT JOIN CTE_ProviderCF AS ProvCF ON ProvCF.ProviderID = ProvDS.ProviderID AND ProvCF.DisplaySpecialtyRuleID = SpecRule.DisplaySpecialtyRuleID
                                LEFT JOIN CTE_ProviderPrimarySpec AS ProvPrimSpec ON ProvPrimSpec.ProviderId = ProvDS.ProviderID AND ProvPrimSpec.DisplaySpecialtyRuleID = SpecRule.DisplaySpecialtyRuleID 
                            
                            WHERE (((((SpecRule.IsCertificationSpecialtyRequired = 1 and ProvCert.ProviderID is not null) or (SpecRule.IsCertificationSpecialtyRequired = 0))
                            			or ((SpecRule.IsClinicalFocuRequired = 1 and ProvCF.ProviderID is not null) or (SpecRule.IsClinicalFocuRequired = 0)))) 
                            			and SpecRule.DisplaySpecialtyRuleCondition = 'AND')
                            			OR (((((SpecRule.IsCertificationSpecialtyRequired = 1 and ProvCert.ProviderID is not null) or (SpecRule.IsCertificationSpecialtyRequired = 0))
                            			or ((SpecRule.IsClinicalFocuRequired = 1 and ProvCF.ProviderID is not null) or (SpecRule.IsClinicalFocuRequired = 0)))) 
                            			and SpecRule.DisplaySpecialtyRuleCondition = 'OR')  
                             QUALIFY row_number() over (partition by ProvDS.ProviderID order by SpecRule.DisplaySpecialtyRuleRank, case when SpecRule.IsPrimaryRequired = 1 and ProvPrimSpec.ProviderID is not null then 1 else 2 end, SpecRule.DisplaySpecialtyRuleTieBreaker) = 1    $$;



---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

insert_statement := ' INSERT INTO Base.ProviderToDisplaySpecialty 
                        (ProviderID,
                        SpecialtyId) ' ||select_statement;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

IF (IsProviderDeltaProcessing) THEN
    EXECUTE IMMEDIATE delete_statement;
ELSE
    EXECUTE IMMEDIATE truncate_statement;
END IF;
    
EXECUTE IMMEDIATE insert_statement ;

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