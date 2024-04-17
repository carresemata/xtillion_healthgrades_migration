CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTOPROVIDERTYPE()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderToProviderType depends on: 
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
                            JSON.ProviderCode AS ProviderId,
                            IFNULL(JSON.ProviderType_ProviderTypeCode, 'ALT') AS ProviderTypeID,
                            IFNULL(JSON.ProviderType_SourceCode, 'Profisee') AS SourceCode,
                            IFNULL(JSON.ProviderType_ProviderTypeRankCalculated, 1) AS ProviderTypeRank,
                            2147483647 AS ProviderTypeRankCalculated,
                            IFNULL(JSON.ProviderType_LastUpdateDate, CURRENT_TIMESTAMP()) AS LastUpdateDate    
                        FROM Raw.PROVIDER_PROFILE_JSON AS JSON
                        WHERE
                            PROVIDER_PROFILE IS NOT NULL
                            AND ProviderType_ProviderTypeCode IS NOT NULL
                            AND ProviderID IS NOT NULL 
                        QUALIFY ROW_NUMBER() OVER( PARTITION BY ProviderID, IFNULL(ProviderType_ProviderTypeCode, 'ALT') ORDER BY CREATE_DATE DESC) = 1$$;



--- Insert Statement
insert_statement := ' INSERT  
                        (ProviderToProviderTypeID,
                        ProviderID,
                        ProviderTypeID,
                        SourceCode,
                        ProviderTypeRank,
                        ProviderTypeRankCalculated,
                        LastUpdateDate)
                      VALUES 
                        (UUID_STRING(),
                        source.ProviderID,
                        source.ProviderTypeID,
                        source.SourceCode,
                        source.ProviderTypeRank,
                        source.ProviderTypeRankCalculated,
                        source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.ProviderToProviderType as target USING 
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