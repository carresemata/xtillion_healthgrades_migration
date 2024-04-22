CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTOCLINICALFOCUS()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderToClinicalFocus depends on:
--- Raw.PROVIDER_PROFILE_PROCESSING  
--- Base.Provider
--- Base.ClinicalFocus

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
select_statement := $$ 
SELECT DISTINCT 
    P.ProviderId,
    CF.ClinicalFocusId,
    JSON.ClinicalFocus_ClinicalFocusDCPCount AS ClinicalFocusDCPCount,
    JSON.ClinicalFocus_ClinicalFocusMinBucketsCalculated AS ClinicalFocusMinBucketsCalculated,
    JSON.ClinicalFocus_ProviderDCPCount AS ProviderDCPCount,
    JSON.ClinicalFocus_AverageBPercentile AS AverageBPercentile,
    JSON.ClinicalFocus_ProviderDCPFillPercent AS ProviderDCPFillPercent,
    JSON.ClinicalFocus_IsProviderDCPCountOverLowThreshold AS IsProviderDCPCountOverLowThreshold,
    JSON.ClinicalFocus_ClinicalFocusScore AS ClinicalFocusScore,
    JSON.ClinicalFocus_ProviderClinicalFocusRank AS ProviderClinicalFocusRank,
    IFNULL(JSON.ClinicalFocus_SourceCode, 'Profisee') AS SourceCode,
    IFNULL(JSON.ClinicalFocus_LastUpdateDate, CURRENT_TIMESTAMP()) AS LastUpdateDate

FROM Raw.VW_PROVIDER_PROFILE AS JSON
    JOIN Base.Provider AS P ON JSON.ProviderCode = P.ProviderCode
    JOIN Base.ClinicalFocus AS CF ON JSON.ClinicalFocus_ClinicalFocusCode = CF.ClinicalFocusCode

WHERE JSON.PROVIDER_PROFILE IS NOT NULL
  AND JSON.ClinicalFocus_ClinicalFocusCode IS NOT NULL
QUALIFY ROW_NUMBER() OVER(PARTITION BY P.ProviderCode, ClinicalFocus_ClinicalFocusCode ORDER BY ProviderId DESC) = 1
$$
;

--- Insert Statement
insert_statement := $$ 
INSERT 
(
    ProviderToClinicalFocusId,
    ProviderId,
    ClinicalFocusId,
    ClinicalFocusDCPCount,
    ClinicalFocusMinBucketsCalculated,
    ProviderDCPCount,
    AverageBPercentile,
    ProviderDCPFillPercent,
    IsProviderDCPCountOverLowThreshold,
    ClinicalFocusScore,
    ProviderClinicalFocusRank,
    SourceCode,
    InsertedOn
)
VALUES (
    UUID_STRING(),
    source.ProviderId,
    source.ClinicalFocusId,
    source.ClinicalFocusDCPCount,
    source.ClinicalFocusMinBucketsCalculated,
    source.ProviderDCPCount,
    source.AverageBPercentile,
    source.ProviderDCPFillPercent,
    source.IsProviderDCPCountOverLowThreshold,
    source.ClinicalFocusScore,
    source.ProviderClinicalFocusRank,
    source.SourceCode,
    source.LastUpdateDate
)
$$
;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := $$
                MERGE INTO Base.ProviderToClinicalFocus AS target
                USING ($$||select_statement||$$) AS source
                ON source.ProviderId = target.ProviderId AND source.ClinicalFocusId = target.ClinicalFocusId
                WHEN MATCHED THEN DELETE
                WHEN NOT MATCHED  THEN $$||insert_statement
                ;

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