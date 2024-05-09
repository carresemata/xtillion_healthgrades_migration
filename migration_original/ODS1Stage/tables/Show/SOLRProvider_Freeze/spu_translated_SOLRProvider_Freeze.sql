-- hack_spuMAPFreeze
CREATE OR REPLACE PROCEDURE ODS1_STAGE.SHOW.SP_LOAD_SOLRPROVIDER_FREEZE() 
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
    RETURN status;


        
EXCEPTION
    WHEN OTHER THEN
          status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
          RETURN status;

    
END;
