CREATE OR REPLACE PROCEDURE ODS1_STAGE.SHOW.SP_LOAD_SOLRLINEOFSERVICEDELTA() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  

DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Show.SOLRLineOfServiceDelta depends on: 
--- Mid.LineOfService
--- Show.LineOfServiceDelta

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
select_statement := '   SELECT DISTINCT
                            ls.LineOfServiceID,
                            1 AS SolrDeltaTypeCode,
                            1 AS MidDeltaProcessComplete
                        FROM 
                            Mid.LineOfService ls
                            LEFT JOIN Show.SOLRLineOfServiceDelta lsd on ls.LineOfServiceID = lsd.LineOfServiceID
                        WHERE
                            lsd.LineOfServiceID is NULL';


--- Insert Statement
insert_statement := ' INSERT (
                        LineOfServiceID, 
                        SolrDeltaTypeCode, 
                        MidDeltaProcessComplete)
                      VALUES (
                        source.LineOfServiceID, 
                        source.SolrDeltaTypeCode, 
                        source.MidDeltaProcessComplete);';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Show.SOLRLineOfServiceDelta as target USING 
                   ('||select_statement||') as source 
                   ON target.LineOfServiceID = source.LineOfServiceID 
                   WHEN NOT MATCHED THEN ' ||insert_statement ;
                   
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
