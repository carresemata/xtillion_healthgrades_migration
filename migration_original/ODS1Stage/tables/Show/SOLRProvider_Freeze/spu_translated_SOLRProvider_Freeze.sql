-- hack_spuMAPFreeze
CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRPROVIDER_FREEZE() 
    RETURNS STRING
    LANGUAGE SQL
    AS  

DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Show.SOLRProvider_Freeze depends on: 
--- Show.WebFreeze


---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------


    cleanup_1 STRING; -- Cleanup for Show.SOLRProvider_Freeze
    cleanup_2 STRING; -- Cleanup for Show.WebFreeze
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_SOLRProvider_Freeze');
    execution_start DATETIME default getdate();


   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    -- no conditionals


---------------------------------------------------------
--------------- 3. Select statements --------------------
---------------------------------------------------------     



---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

cleanup_1 := 'DELETE FROM
                Show.SOLRProvider_Freeze
            WHERE
                SponsorCode NOT IN (
                    SELECT
                        ClientCode
                    FROM
                        Show.WebFreeze);';

            

cleanup_2 := 'DELETE FROM
                Show.WebFreeze
            WHERE
                CURRENT_TIMESTAMP > FreezeEndDate;';


         

                   


---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE cleanup_1;
EXECUTE IMMEDIATE cleanup_2;  
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
