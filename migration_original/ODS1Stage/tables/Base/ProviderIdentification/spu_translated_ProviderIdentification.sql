CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERIDENTIFICATION() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderIdentification depends on: 
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
select_statement := $$ SELECT DISTINCT
                            P.ProviderID,
                            JSON.Identification_IdentificationTypeCode AS IdentificationTypeID,
                            JSON.Identification_Identifier AS IdentificationValue,
                            JSON.Identification_ExpirationDate AS ExpirationDate,
                            JSON.Identification_SourceCode AS SourceCode,
                            JSON.Identification_LastUpdateDate AS LastUpdateDate
                        FROM
                            Raw.VW_PROVIDER_PROFILE AS JSON
                            JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                        WHERE
                            PROVIDER_PROFILE IS NOT NULL AND
                            ProviderId IS NOT NULL AND
                            IdentificationTypeID IS NOT NULL
                            QUALIFY ROW_NUMBER() OVER(PARTITION BY ProviderID ORDER BY CREATE_DATE DESC) = 1$$;

--- Insert Statement
insert_statement := ' INSERT  
                        (ProviderIdentificationID,
                        ProviderID,
                        IdentificationTypeID,
                        IdentificationValue,
                        ExpirationDate,
                        SourceCode,
                        LastUpdateDate)
                      VALUES 
                        (UUID_STRING(),
                        source.ProviderID,
                        source.IdentificationTypeID,
                        source.IdentificationValue,
                        source.ExpirationDate,
                        source.SourceCode,
                        source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.ProviderIdentification as target USING 
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