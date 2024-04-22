CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTOABOUTME()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderToAboutMe depends on: 
--- Raw.PROVIDER_PROFILE_PROCESSING
--- Base.Provider
--- Base.AboutMe

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
                        IFNULL(JSON.AboutMe_Sourcecode, 'Profisee') AS SourceCode,
                        A.AboutMeId,
                        JSON.AboutMe_AboutMeText AS ProviderAboutMeText,
                        A.DisplayOrder AS CustomDisplayOrder,
                        IFNULL(JSON.AboutMe_LastUpdateDate, CURRENT_TIMESTAMP()) AS LastUpdateDate
                    FROM Raw.VW_PROVIDER_PROFILE AS JSON
                          LEFT JOIN Base.Provider P ON JSON.ProviderCode = P.ProviderCode
                          LEFT JOIN Base.AboutMe A ON JSON.AboutMe_AboutMeCode = A.AboutMeCode
                    WHERE 
                        JSON.PROVIDER_PROFILE IS NOT NULL AND
                        ProviderId IS NOT NULL AND
                        AboutMeId IS NOT NULL AND
                        AboutMe_AboutMeText IS NOT NULL
                    QUALIFY ROW_NUMBER() OVER (PARTITION BY ProviderId, AboutMe_AboutMeCode ORDER BY CREATE_DATE DESC) = 1 $$ ;



--- Insert Statement
insert_statement := ' INSERT  
                        (ProviderToAboutMeID,
                        ProviderID,
                        SourceCode,
                        AboutMeID,
                        ProviderAboutMeText,
                        CustomDisplayOrder,
                        LastUpdatedDate)
                      VALUES 
                        (UUID_STRING(),
                        source.ProviderID,
                        source.SourceCode,
                        source.AboutMeID,
                        source.ProviderAboutMeText,
                        source.CustomDisplayOrder,
                        source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.ProviderToAboutMe as target USING 
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