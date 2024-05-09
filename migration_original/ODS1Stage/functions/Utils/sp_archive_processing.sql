CREATE OR REPLACE PROCEDURE ODS1_STAGE.UTILS.SP_ARCHIVE_PROCESSING() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    


---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    customer_product_insert STRING;
    facility_insert STRING;
    office_insert STRING;
    practice_insert STRING;
    provider_insert STRING;
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_archive_processing');
    execution_start DATETIME default getdate();
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

                     
---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

customer_product_insert := $$ INSERT INTO RAW.CUSTOMER_PRODUCT_PROFILE_PROCESSED 
                                SELECT *, current_timestamp() as InsertedOn  FROM Raw.CUSTOMER_PRODUCT_PROFILE_PROCESSING $$;

facility_insert := $$ INSERT INTO RAW.FACILITY_PROFILE_PROCESSED 
                     SELECT *, current_timestamp() as InsertedOn  FROM Raw.FACILITY_PROFILE_PROCESSING $$;

office_insert := $$ INSERT INTO RAW.OFFICE_PROFILE_PROCESSED 
                   SELECT *, current_timestamp() as InsertedOn  FROM Raw.OFFICE_PROFILE_PROCESSING $$;

practice_insert := $$ INSERT INTO RAW.PRACTICE_PROFILE_PROCESSED 
                     SELECT *, current_timestamp() as InsertedOn  FROM Raw.PRACTICE_PROFILE_PROCESSING $$;

provider_insert := $$ INSERT INTO RAW.PROVIDER_PROFILE_PROCESSED 
                     SELECT *, current_timestamp() as InsertedOn  FROM Raw.PROVIDER_PROFILE_PROCESSING $$;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
EXECUTE IMMEDIATE customer_product_insert ;
EXECUTE IMMEDIATE facility_insert;
EXECUTE IMMEDIATE office_insert;
EXECUTE IMMEDIATE practice_insert;
EXECUTE IMMEDIATE provider_insert;

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


