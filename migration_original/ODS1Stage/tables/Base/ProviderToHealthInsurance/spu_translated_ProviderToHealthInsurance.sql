CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTOHEALTHINSURANCE()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
DECLARE
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.ProviderToHealthInsurance depends on:
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.HealthInsurancePlanToPlanType

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
        PTP.HealthInsurancePlanToPlanTypeId,
        IFNULL(JSON.HealthInsurance_SourceCode, 'Profisee') AS SourceCode,
        IFNULL(JSON.HealthInsurance_LastUpdateDate, CURRENT_TIMESTAMP()) AS LastUpdateDate
        
FROM Raw.VW_PROVIDER_PROFILE AS JSON
    LEFT JOIN Base.Provider P ON P.ProviderCode = JSON.ProviderCode
    LEFT JOIN Base.HealthInsurancePlanToPlanType AS PTP ON PTP.InsuranceProductCode = JSON.HealthInsurance_HealthInsuranceProductCode

WHERE JSON.PROVIDER_PROFILE IS NOT NULL
        AND JSON.HealthInsurance_HealthInsuranceProductCode IS NOT NULL
        
QUALIFY ROW_NUMBER() OVER (PARTITION BY ProviderId, JSON.HealthInsurance_HealthInsuranceProductCode ORDER BY CREATE_DATE DESC) = 1
$$;

--- Insert Statement
insert_statement := ' INSERT 
                        (ProviderToHealthInsuranceId, 
                        ProviderId, 
                        HealthInsurancePlanToPlanTypeId, 
                        SourceCode, 
                        LastUpdateDate)
                      VALUES 
                        (UUID_STRING(), 
                        source.ProviderId, 
                        source.HealthInsurancePlanToPlanTypeId, 
                        source.SourceCode, 
                        source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------

merge_statement := 'MERGE INTO Base.ProviderToHealthInsurance AS target
                    USING ('||select_statement||') AS source
                    ON source.ProviderId = target.ProviderId
                    WHEN MATCHED THEN DELETE
                    WHEN NOT MATCHED THEN '||insert_statement;

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