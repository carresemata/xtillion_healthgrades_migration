CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.UTILS.SP_ARCHIVE_PROCESSING()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'DECLARE 
---------------------------------------------------------
--------------- 1. Table dependencies -------------------
---------------------------------------------------------
    


---------------------------------------------------------
--------------- 2. Declaring variables ------------------
---------------------------------------------------------

    customer_product_insert STRING;
    facility_insert STRING;
    office_insert STRING;
    practice_insert STRING;
    provider_insert STRING;
    status STRING; -- Status monitoring
    customer_product_delete STRING;
    facility_delete STRING;
    office_delete STRING;
    practice_delete STRING;
    provider_delete STRING;
    customer_product_truncate STRING;
    facility_truncate STRING;
    office_truncate STRING;
    practice_truncate STRING;
    provider_truncate STRING;
   
   
BEGIN


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

                     
---------------------------------------------------------
------- 4. Actions (Inserts, Updates and Deletes) -------
---------------------------------------------------------  

customer_product_insert := $$ INSERT INTO UTILS.CUSTOMER_PRODUCT_PROFILE_PROCESSED 
                                SELECT *, current_timestamp() as InsertedOn  FROM MDM_TEAM.MST.CUSTOMER_PRODUCT_PROFILE_PROCESSING $$;

facility_insert := $$ INSERT INTO UTILS.FACILITY_PROFILE_PROCESSED 
                     SELECT *, current_timestamp() as InsertedOn  FROM MDM_TEAM.MST.FACILITY_PROFILE_PROCESSING $$;

office_insert := $$ INSERT INTO UTILS.OFFICE_PROFILE_PROCESSED 
                   SELECT *, current_timestamp() as InsertedOn  FROM MDM_TEAM.MST.OFFICE_PROFILE_PROCESSING $$;

practice_insert := $$ INSERT INTO UTILS.PRACTICE_PROFILE_PROCESSED 
                     SELECT *, current_timestamp() as InsertedOn  FROM MDM_TEAM.MST.PRACTICE_PROFILE_PROCESSING $$;

provider_insert := $$ INSERT INTO UTILS.PROVIDER_PROFILE_PROCESSED 
                     SELECT *, current_timestamp() as InsertedOn  FROM MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING $$;

customer_product_delete := $$DELETE FROM UTILS.CUSTOMER_PRODUCT_PROFILE_PROCESSED WHERE InsertedOn < DATEADD(day, -7, CURRENT_DATE)$$;


facility_delete := $$DELETE FROM UTILS.FACILITY_PROFILE_PROCESSED WHERE InsertedOn < DATEADD(day, -7, CURRENT_DATE)$$;


office_delete := $$DELETE FROM UTILS.OFFICE_PROFILE_PROCESSED WHERE InsertedOn < DATEADD(day, -7, CURRENT_DATE)$$;


practice_delete := $$DELETE FROM UTILS.PRACTICE_PROFILE_PROCESSED WHERE InsertedOn < DATEADD(day, -7, CURRENT_DATE)$$;


provider_delete := $$DELETE FROM UTILS.PROVIDER_PROFILE_PROCESSED WHERE InsertedOn < DATEADD(day, -7, CURRENT_DATE)$$;

customer_product_truncate := $$ TRUNCATE TABLE MDM_TEAM.MST.CUSTOMER_PRODUCT_PROFILE_PROCESSING $$;

facility_truncate := $$ TRUNCATE TABLE MDM_TEAM.MST.FACILITY_PROFILE_PROCESSING $$;

office_truncate := $$ TRUNCATE TABLE MDM_TEAM.MST.OFFICE_PROFILE_PROCESSING $$;

practice_truncate := $$ TRUNCATE TABLE MDM_TEAM.MST.PRACTICE_PROFILE_PROCESSING $$;

provider_truncate := $$ TRUNCATE TABLE MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING $$;

                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
EXECUTE IMMEDIATE customer_product_insert ;
EXECUTE IMMEDIATE facility_insert;
EXECUTE IMMEDIATE office_insert;
EXECUTE IMMEDIATE practice_insert;
EXECUTE IMMEDIATE provider_insert;
EXECUTE IMMEDIATE customer_product_delete;
EXECUTE IMMEDIATE facility_delete;
EXECUTE IMMEDIATE office_delete;
EXECUTE IMMEDIATE practice_delete;
EXECUTE IMMEDIATE provider_delete;
EXECUTE IMMEDIATE customer_product_truncate;
EXECUTE IMMEDIATE facility_truncate;
EXECUTE IMMEDIATE office_truncate;
EXECUTE IMMEDIATE practice_truncate;
EXECUTE IMMEDIATE provider_truncate;

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
--------------------------------------------------------- 

status := ''Completed successfully'';
    RETURN status;


        
EXCEPTION
    WHEN OTHER THEN
          status := ''Failed during execution. '' || ''SQL Error: '' || SQLERRM || '' Error code: '' || SQLCODE || ''. SQL State: '' || SQLSTATE;
          RETURN status;

    
END';