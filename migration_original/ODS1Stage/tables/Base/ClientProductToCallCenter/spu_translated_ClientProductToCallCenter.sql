CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CLIENTPRODUCTTOCALLCENTER() -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

--- Base.ClientProductToCallCenter depends on:
--- BASE.CLIENTTOPRODUCT
--- BASE.CALLCENTER
--- BASE.PRODUCT
--- BASE.CLIENT

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_ClientProductToCallCenter');
    execution_start DATETIME default getdate();

   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   

BEGIN

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
-- If no conditionals:
select_statement := $$WITH cte_product_id_pdchsp AS (
        SELECT
            CPCC.ClientToProductID
        FROM
            Base.ClientProductToCallCenter AS CPCC
            JOIN Base.ClientToProduct AS CTP ON CPCC.ClientToProductID = CTP.ClientToProductID
            JOIN Base.CallCenter AS CC ON CPCC.CallCenterID = CC.CallCenterID
            JOIN Base.Product AS P ON CTP.ProductID = P.ProductID
        WHERE
            P.ProductCode IN ('MAP', 'PDCHSP')
    )
    SELECT
        CP.ClientToProductID,
        '36334343-0000-0000-0000-000000000000' AS CallCenterID,
        1 AS ActiveFlag,
        CP.SourceCode,
        GETDATE() AS LastUpdateDate
    FROM
        Base.ClientToProduct AS CP
        JOIN Base.Product AS P ON CP.ProductID = P.ProductID
        JOIN Base.Client AS c ON c.ClientID = CP.ClientID
        LEFT JOIN cte_product_id_pdchsp AS CTE ON CP.ClientToProductID = CTE.ClientToProductID
    WHERE
    (
        P.ProductCode IN ('PDCHSP')
        OR (
            P.ProductCode IN ('MAP')
            AND ClientCode IN ('COMO', 'PAGE1SLN')
        )
    )
$$;

--- Insert Statement
insert_statement := ' INSERT (ClientProductToCallCenterID,ClientToProductID, CallCenterID, ActiveFlag, SourceCode, LastUpdateDate)
    VALUES (UUID_String(),Source.ClientToProductID, Source.CallCenterID, Source.ActiveFlag, Source.SourceCode, Source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO BASE.CLIENTPRODUCTTOCALLCENTER as target USING 
                   ('||select_statement||') as source 
                   ON source.ClientToProductID = target.ClientToProductID
                   AND source.CallCenterID = target.CallCenterID
                   WHEN NOT MATCHED THEN'||insert_statement;
                   
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