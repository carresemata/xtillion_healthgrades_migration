CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTOPROVIDERSUBTYPE()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderToProviderSubType depends on: 
--- Raw.VW_PROVIDER_PROFILE
--- Base.Provider
--- Base.ProviderSubType

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
select_statement := $$ SELECT DISTINCT
                            P.ProviderId,
                            PST.ProviderSubTypeID,
                            IFNULL(JSON.ProviderSubType_SourceCode, 'Profisee') AS SourceCode,
                            JSON.ProviderSubType_ProviderSubTypeRank AS ProviderSubTypeRank,
                            2147483647 AS ProviderSubTypeRankCalculated,
                            IFNULL(JSON.ProviderSubType_LastUpdateDate, CURRENT_TIMESTAMP()) AS LastUpdateDate
                        FROM Raw.VW_PROVIDER_PROFILE AS JSON
                            LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                            JOIN Base.ProviderSubType AS PST ON PST.ProviderSubTypeCode = JSON.ProviderSubType_ProviderSubTypeCode
                        WHERE
                            PROVIDER_PROFILE IS NOT NULL
                            AND ProviderSubType_ProviderSubTypeCode IS NOT NULL
                            AND ProviderID IS NOT NULL 
                        QUALIFY ROW_NUMBER() OVER( PARTITION BY ProviderID, IFNULL(ProviderSubType_ProviderSubTypeCode, 'ALT') ORDER BY CREATE_DATE DESC) = 1 $$;



--- Insert Statement
insert_statement := ' INSERT  
                        (ProviderToProviderSubTypeID,
                        ProviderID,
                        ProviderSubTypeID,
                        SourceCode,
                        ProviderSubTypeRank,
                        ProviderSubTypeRankCalculated,
                        LastUpdateDate)
                      VALUES 
                        (UUID_STRING(),
                        source.ProviderID,
                        source.ProviderSubTypeID,
                        source.SourceCode,
                        source.ProviderSubTypeRank,
                        source.ProviderSubTypeRankCalculated,
                        source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.ProviderToProviderSubType as target USING 
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