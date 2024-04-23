CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERREDIRECT()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 

DECLARE
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
--- Base.ProviderRedirect depends on:
-- Mid.Provider (yes, this is not a typo...)
-- Base.ProviderRedirect

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
select_statement STRING;
update_statement STRING;
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
                    SELECT p.ProviderCode, p.ProviderURL
                    FROM Mid.Provider p
                    INNER JOIN Base.ProviderRedirect pr ON p.ProviderCode = pr.ProviderCodeNew
                    WHERE pr.ProviderURLNew IS NOT NULL
                        AND p.ProviderURL != pr.ProviderURLNew
                        AND pr.DeactivationReason NOT IN ('Deactivated', 'HomePageRedirect')
                    $$;

update_statement := $$ 
                    UPDATE SET ProviderURLNew = source.ProviderURL
                    $$;


---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := $$ MERGE INTO Base.ProviderRedirect as target 
                    USING ($$||select_statement||$$) as source 
                    ON source.ProviderCode = target.ProviderCodeNew
                    WHEN MATCHED THEN $$ ||update_statement
                    $$;


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