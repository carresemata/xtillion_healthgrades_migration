CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_DEGREE()
RETURNS STRING
LANGUAGE SQL EXECUTE
AS CALLER
AS DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- Base.Degree depends on:
-- Raw.Provider_Profile_JSON
-- Base.Degree

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
                    WITH CTE_degrees AS (
                        SELECT DISTINCT JSON.Degree_DegreeCode AS DegreeCode
                        FROM RAW.VW_PROVIDER_PROFILE AS JSON
                        WHERE NOT EXISTS (
                            SELECT d.DegreeAbbreviation
                            FROM Base.Degree AS d
                            WHERE d.DegreeAbbreviation = JSON.Degree_DegreeCode
                        ) AND DegreeCode IS NOT NULL
                    )
                    
                    SELECT 
                        UUID_STRING() AS DegreeID,
                        cte_d.DegreeCode AS DegreeAbbreviation,
                        cte_d.DegreeCode AS DegreeDescription, -- weird but what the original proc does
                        (SELECT MAX(refRank) FROM Base.Degree) + ROW_NUMBER() OVER (ORDER BY cte_d.DegreeCode) AS refRank
                    FROM CTE_degrees AS cte_d
                    ORDER BY cte_d.DegreeCode
                    $$;


insert_statement := $$ 
                     INSERT  
                       (   
                        DegreeID,
                        DegreeAbbreviation,
                        DegreeDescription,
                        refRank
                        )
                      VALUES 
                        (   
                        source.DegreeID,
                        source.DegreeAbbreviation,
                        source.DegreeDescription,
                        source.refRank
                        )
                     $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := $$ MERGE INTO Base.Degree as target 
                    USING ($$||select_statement||$$) as source 
                   ON source.DegreeId = target.DegreeId
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