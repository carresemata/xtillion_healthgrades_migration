CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTOLANGUAGE()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
DECLARE
--------------------------------------------------------
--------------- 0. Table dependencies -------------------
--------------------------------------------------------

-- Base.ProviderToLanguage depends on:
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.Language

--------------------------------------------------------
--------------- 1. Declaring variables ------------------
--------------------------------------------------------

select_statement STRING; -- CTE and Select statement for the Merge
insert_statement STRING; -- Insert statement for the Merge
merge_statement STRING; -- Merge statement to final table
status STRING; -- Status monitoring

--------------------------------------------------------
--------------- 2.Conditionals if any -------------------
--------------------------------------------------------

BEGIN
    -- no conditionals

--------------------------------------------------------
----------------- 3. SQL Statements ---------------------
--------------------------------------------------------

--- Select Statement
select_statement := $$ 
SELECT DISTINCT
    P.ProviderId,
    L.LanguageId,
    IFNULL(JSON.Language_SourceCode, 'Profisee') AS SourceCode,
    IFNULL(JSON.Language_LastUpdateDate, CURRENT_TIMESTAMP()) AS LastUpdateDate 

FROM Raw.VW_PROVIDER_PROFILE AS JSON
    LEFT JOIN Base.Provider P ON JSON.ProviderCode = P.ProviderCode
    LEFT JOIN Base.Language L ON JSON.Language_LanguageCode = L.LanguageCode
    
WHERE JSON.PROVIDER_PROFILE IS NOT NULL
  AND JSON.Language_LanguageCode IS NOT NULL
  AND ProviderID IS NOT NULL
  AND LanguageID IS NOT NULL
  AND JSON.Language_LanguageCode != 'LN0000C3A1' -- Discard English
QUALIFY ROW_NUMBER() OVER (PARTITION BY ProviderId, JSON.Language_LanguageCode ORDER BY CREATE_DATE DESC) = 1
$$;

--- Insert Statement
insert_statement := $$  INSERT 
                            (ProviderToLanguageId, 
                            ProviderId, 
                            LanguageId, 
                            SourceCode, 
                            LastUpdateDate)
                        VALUES 
                            (UUID_STRING(), 
                            source.ProviderId, 
                            source.LanguageId, 
                            source.SourceCode, 
                            source.LastUpdateDate)
                        $$;

--------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
--------------------------------------------------------

merge_statement := $$ MERGE INTO Base.ProviderToLanguage AS target
                        USING ($$||select_statement||$$) AS source
                        ON source.ProviderId = target.ProviderId 
                        WHEN MATCHED THEN DELETE
                        WHEN NOT MATCHED THEN $$||insert_statement;

--------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------

EXECUTE IMMEDIATE merge_statement;

--------------------------------------------------------
--------------- 6. Status monitoring --------------------
--------------------------------------------------------

status := 'Completed successfully';
RETURN status;

EXCEPTION
    WHEN OTHER THEN
        status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
        
        RETURN status;
END;