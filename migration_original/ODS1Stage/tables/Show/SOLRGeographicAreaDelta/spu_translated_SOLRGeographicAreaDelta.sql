CREATE OR REPLACE PROCEDURE ODS1_STAGE.SHOW.SP_LOAD_SOLRGEOGRAPHICAREADELTA() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  

DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Show.SOLRGeographicAreaDelta depends on: 
--- Mid.GeographicArea
--- Show.SOLRGeographicAreaDelta

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
                            ga.GeographicAreaID,
                            1 AS SolrDeltaTypeCode,
                            1 AS MidDeltaProcessComplete
                        FROM 
                            Mid.GeographicArea ga
                            LEFT JOIN Show.SOLRGeographicAreaDelta gad on ga.GeographicAreaID = gad.GeographicAreaID
                        WHERE
                            gad.GeographicAreaID is NULL';


--- Insert Statement
insert_statement := ' INSERT (
                        GeographicAreaID, 
                        SolrDeltaTypeCode, 
                        MidDeltaProcessComplete)
                      VALUES (
                        source.GeographicAreaID, 
                        source.SolrDeltaTypeCode, 
                        source.MidDeltaProcessComplete);';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Show.SOLRGeographicAreaDelta as target USING 
                   ('||select_statement||') as source 
                   ON target.GeographicAreaID = source.GeographicAreaID 
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