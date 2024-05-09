CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTOSUBSTATUS()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderToSubStatus depends on: 
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.SubStatus

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
select_statement := 'SELECT DISTINCT
                        P.ProviderId,
                        S.SubStatusId,
                        IFNULL(JSON.ProviderStatus_ProviderStatusRank, 2147483647) AS HierarchyRank,
                        JSON.ProviderStatus_SourceCode AS SourceCode,
                        JSON.ProviderStatus_LastUpdateDate As LastUpdateDate
                    FROM Raw.VW_PROVIDER_PROFILE AS JSON
                        LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                        LEFT JOIN Base.SubStatus AS S ON S.SubStatusCode = JSON.ProviderStatus_ProviderStatusCode
                    WHERE 
                        PROVIDER_PROFILE IS NOT NULL AND
                        ProviderId IS NOT NULL AND
                        ProviderStatus_ProviderStatusCode IS NOT NULL
                    QUALIFY ROW_NUMBER() OVER( PARTITION BY ProviderID, ProviderStatus_ProviderStatusCode ORDER BY CREATE_DATE DESC) = 1';


--- Insert Statement
insert_statement := ' INSERT  
                        (ProviderToSubStatusID,
                        ProviderID,
                        SubStatusID,
                        HierarchyRank,
                        SourceCode,
                        LastUpdateDate)
                      VALUES 
                        (UUID_STRING(),
                        source.ProviderID,
                        source.SubStatusID,
                        source.HierarchyRank,
                        source.SourceCode,
                        source.LastUpdateDate)';
---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.ProviderToSubStatus as target USING 
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