CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRGEOGRAPHICAREADELTA() 
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

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_SOLRGeographicAreaDelta');
    execution_start DATETIME default getdate();

   
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