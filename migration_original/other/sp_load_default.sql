CREATE OR REPLACE PROCEDURE SP_LOAD_TABLE_NAME(ParameterName ParameterType) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  

DECLARE 

---------------------------------------------------------
--------------- 1. Table dependencies -------------------
---------------------------------------------------------
    
-- #TABLE NAME# depends on: 
--- #Table Dependency 1#
--- #Table Dependency 2#
--- #Table Dependency 3#

---------------------------------------------------------
--------------- 2. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
   

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
-- If no conditionals:
select_statement := 'WITH CTE_1 AS (SELECT ...), 
                     CTE_FINAL AS (SELECT ...)
                     
                     SELECT * FROM CTE_FINAL';

-- If conditionals:
select_statement := select_statement || 
                    'CTE_1 AS (SELECT ...), 
                     CTE_FINAL AS (SELECT ...)
                     
                     SELECT * FROM CTE_FINAL';

--- Update Statement
update_statement := ' UPDATE 
                     SET (columns to update)';

--- Insert Statement
insert_statement := ' INSERT  (columns to insert)
                      VALUES (columns values)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO #FinalTable# as target USING 
                   ('||select_statement||') as source 
                   ON source.id = target.id
                   WHEN MATCHED THEN '||update_statement|| '
                   WHEN NOT MATCHED THEN '||insert_statement||;
                   
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




