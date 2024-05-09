CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERREDIRECT()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 

DECLARE
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- Base.ProviderRedirect depends on:
--- Mid.Provider 

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
select_statement STRING;
update_statement STRING;
merge_statement STRING;
status STRING;
    procedure_name varchar(50) default('sp_load_ProviderRedirect');
    execution_start DATETIME default getdate();


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
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        RETURN status;

        EXCEPTION
        WHEN OTHER THEN
            status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, SPLIT_PART(REGEXP_SUBSTR(:status, 'Error code: ([0-9]+)'), ':', 2)::INTEGER, TRIM(SPLIT_PART(SPLIT_PART(:status, 'SQL Error:', 2), 'Error code:', 1)), SPLIT_PART(REGEXP_SUBSTR(:status, 'SQL State: ([0-9]+)'), ':', 2)::INTEGER; 

            RETURN status;
END;