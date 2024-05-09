CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CLIENTTOPRODUCT()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
--- Base.ClientToProduct depends on:
-- MDM_TEAM.MST.CUSTOMER_PRODUCT_PROFILE_PROCESSING (Base.vw_swimlane_base_client)
-- Base.Client
-- Base.Product

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

select_statement STRING;
insert_statement STRING; 
merge_statement STRING;
status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_ClientToProduct');
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
                    SELECT
                        UUID_STRING() AS ClientToProductID,
                        c.ClientID,
                        p.ProductID,
                        IFNULL(s.ActiveFlag, true) AS ActiveFlag,
                        IFNULL(s.SourceCode, 'Profisee') AS SourceCode,
                        IFNULL(s.LastUpdateDate, SYSDATE()) AS LastUpdateDate,
                        s.QueueSize,
                        -- s.ReltioEntityID
                    FROM Base.vw_swimlane_base_client s
                    INNER JOIN Base.Client c ON c.ClientCode = s.ClientCode 
                    INNER JOIN Base.Product p on p.ProductCode = s.ProductCode
                    WHERE
                        s.ClientCode IS NOT NULL
                        AND s.ProductCode IS NOT NULL
                    QUALIFY DENSE_RANK() OVER( PARTITION BY s.CustomerProductCode ORDER BY s.created_datetime DESC) = 1
                    $$;


insert_statement := $$ 
                    INSERT  
                        (ClientToProductID,
                         ClientID, 
                         ProductID, 
                         ActiveFlag, 
                         SourceCode, 
                         LastUpdateDate, 
                         QueueSize
                         )
                    VALUES 
                        (source.ClientToProductID,
                        source.ClientID,
                        source.ProductID,
                        source.ActiveFlag,
                        source.SourceCode,
                        source.LastUpdateDate,
                        source.QueueSize
                        )
                    $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := $$ MERGE INTO Base.ClientToProduct as target USING 
                   ($$||select_statement||$$) as source 
                   ON source.ClientID = target.ClientID AND source.ProductID = target.ProductID AND source.SourceCode = target.SourceCode AND source.QueueSize = target.QueueSize
                   WHEN NOT MATCHED THEN $$||insert_statement;

    
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