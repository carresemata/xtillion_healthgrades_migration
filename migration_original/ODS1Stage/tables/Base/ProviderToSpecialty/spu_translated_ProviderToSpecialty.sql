CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTOSPECIALTY()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderToSpecialty depends on: 
--- Raw.PROVIDER_PROFILE_PROCESSING
--- Base.Provider

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
select_statement := $$ SELECT
                            P.ProviderId,
                            JSON.Specialty_SpecialtyCode AS SpecialtyID,
                            IFNULL(JSON.Specialty_SourceCode, 'Profisee') AS SourceCode,
                            IFNULL(JSON.Specialty_LastUpdatedate, CURRENT_TIMESTAMP()) AS LastUpdateDate,
                            JSON.Specialty_SpecialtyRank AS SpecialtyRank,
                            IFNULL(JSON.Specialty_SpecialtyRankCalculated, 2147483647) AS SpecialtyRankCalculated,
                            JSON.Specialty_IsSearchable AS IsSearchable,
                            IFNULL(JSON.Specialty_IsSearchableCalculated, 1) AS IsSearchableCalculated,
                            IFNULL(JSON.Specialty_IsSpecialtyRedundant, 0) AS SpecialtyIsRedundant,
                            JSON.Specialty_SpecialtyDCPCount AS SpecialtyDCPCount,
                            JSON.Specialty_SpecialtyDCPMinFillThreshold AS SpecialtyDCPMinFillThreshold,
                            JSON.Specialty_ProviderSpecialtyDCPCount AS ProviderSpecialtyDCPCount,
                            JSON.Specialty_ProviderSpecialtyAveragePercentile AS ProviderSpecialtyAveragePercentile,
                            JSON.Specialty_IsMeetsLowThreshold AS MeetsLowThreshold,
                            JSON.Specialty_ProviderRawSpecialtyScore AS ProviderRawSpecialtyScore,
                            JSON.Specialty_ScaledSpecialtyBoost AS ScaledSpecialtyBoost,
                        FROM Raw.PROVIDER_PROFILE_JSON AS JSON
                             LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                        WHERE
                             PROVIDER_PROFILE IS NOT NULL
                             AND Specialty_SpecialtyCode IS NOT NULL
                             AND ProviderID IS NOT NULL 
                        QUALIFY ROW_NUMBER() OVER( PARTITION BY ProviderID, Specialty_SpecialtyCode ORDER BY Specialty_SpecialtyRankCalculated, CREATE_DATE DESC) = 1$$;



--- Insert Statement
insert_statement := ' INSERT  
                        (ProviderToSpecialtyID,
                        ProviderID,
                        SpecialtyID,
                        SourceCode,
                        LastUpdateDate,
                        SpecialtyRank,
                        SpecialtyRankCalculated,
                        IsSearchable,
                        IsSearchableCalculated,
                        SpecialtyIsRedundant,
                        SpecialtyDCPCount,
                        SpecialtyDCPMinFillThreshold,
                        ProviderSpecialtyDCPCount,
                        ProviderSpecialtyAveragePercentile,
                        MeetsLowThreshold,
                        ProviderRawSpecialtyScore,
                        ScaledSpecialtyBoost)
                      VALUES 
                        (UUID_STRING(),
                        source.ProviderID,
                        source.SpecialtyID,
                        source.SourceCode,
                        source.LastUpdateDate,
                        source.SpecialtyRank,
                        source.SpecialtyRankCalculated,
                        source.IsSearchable,
                        source.IsSearchableCalculated,
                        source.SpecialtyIsRedundant,
                        source.SpecialtyDCPCount,
                        source.SpecialtyDCPMinFillThreshold,
                        source.ProviderSpecialtyDCPCount,
                        source.ProviderSpecialtyAveragePercentile,
                        source.MeetsLowThreshold,
                        source.ProviderRawSpecialtyScore,
                        source.ScaledSpecialtyBoost)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.ProviderToSpecialty as target USING 
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