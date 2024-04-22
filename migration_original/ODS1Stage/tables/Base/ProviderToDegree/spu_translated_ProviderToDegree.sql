CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTODEGREE()
RETURNS STRING
LANGUAGE SQL EXECUTE
AS CALLER
AS DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- Base.ProviderToDegree depends on:
-- Raw.VW_Provider_Profile
-- Base.Provider

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
select_statement STRING;
insert_statement STRING;
merge_statement STRING;
status STRING;

---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   

BEGIN
-- no conditionals

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

select_statement := $$                 
                    SELECT 
                        UUID_STRING() AS ProviderToDegreeID,
                        p.ProviderId,
                        JSON.Degree_DegreeCode AS DegreeID,
                        JSON.Degree_DegreeRank AS DegreePriority,
                        IFNULL(JSON.Degree_SourceCode, 'Profisee') AS SourceCode,
                        IFNULL(JSON.Degree_LastUpdateDate, SYSDATE()) AS LastUpdateDate
                    FROM Raw.VW_PROVIDER_PROFILE AS JSON
                    LEFT JOIN Base.Provider p ON p.ProviderCode = JSON.ProviderCode
                    LEFT JOIN Base.Degree d ON d.DegreeAbbreviation = JSON.Degree_DegreeCode
                    WHERE JSON.PROVIDER_PROFILE IS NOT NULL 
                    QUALIFY ROW_NUMBER() OVER (PARTITION BY ProviderId, JSON.Degree_DegreeCode ORDER BY JSON.Create_Date DESC) = 1
                    $$;


insert_statement := $$ 
                     INSERT  
                       (   
                        ProviderToDegreeID,
                        ProviderId,
                        DegreeId, 
                        DegreePriority,
                        SourceCode,
                        LastUpdateDate
                        )
                      VALUES 
                        (   
                        source.ProviderToDegreeID,
                        source.ProviderId,
                        source.DegreeId,
                        source.DegreePriority,
                        source.SourceCode,
                        source.LastUpdateDate
                        )
                     $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := $$ MERGE INTO Base.ProviderToDegree as target 
                    USING ($$||select_statement||$$) as source 
                   ON source.ProviderId = target.ProviderId
                   WHEN NOT MATCHED THEN $$ ||insert_statement;

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