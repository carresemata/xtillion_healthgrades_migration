CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERURL()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderURL depends on: 
--- Base.Provider
--- Base.ProviderType

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
                            replace(
                                replace(
                                    '/' || case
                                        when PT.ProviderTypeCode = 'DOC' then 'physician/dr-'
                                        when PT.ProviderTypeCode = 'DENT' then 'dentist/dr-'
                                        else 'providers/'
                                    end || lower(P.FirstName) || '-' || lower(P.LastName) || '-' || lower(P.ProviderCode),
                                    '''',
                                    ''
                                ),
                                ' ',
                                '-'
                            ) AS URL,
                            IFNULL(JSON.ProviderType_SourceCode, 'Profisee') AS SourceCode,
                            IFNULL(JSON.ProviderType_LastUpdateDate, SYSDATE()) AS LastUpdateDate
                        FROM
                            RAW.VW_PROVIDER_PROFILE AS JSON
                            LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                            LEFT JOIN Base.ProviderType AS PT ON PT.ProviderTypeCode = JSON.ProviderType_ProviderTypeCode
                        WHERE 
                            PROVIDER_PROFILE IS NOT NULL AND
                            ProviderTypeCode IS NOT NULL AND 
                            ProviderID IS NOT NULL
                        QUALIFY ROW_NUMBER() OVER(PARTITION BY ProviderID ORDER BY IFNULL(JSON.ProviderType_ProviderTypeRankCalculated,1), CREATE_DATE DESC) = 1
$$;




--- Insert Statement
insert_statement := ' INSERT  
                        (ProviderURLID,
                        ProviderID,
                        URL,
                        SourceCode,
                        LastUpdateDate)
                      VALUES 
                        (UUID_STRING(),
                        source.ProviderID,
                        source.URL,
                        source.SourceCode,
                        source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.ProviderURL as target USING 
                   ('||select_statement||') as source 
                   ON source.Providerid = target.Providerid
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