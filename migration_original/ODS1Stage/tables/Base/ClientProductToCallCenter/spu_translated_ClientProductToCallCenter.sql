CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_CLIENTPRODUCTTOCALLCENTER() -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
--- BASE.CLIENTPRODUCTTOCALLCENTER
--- BASE.CLIENTTOPRODUCT
--- BASE.CALLCENTER
--- BASE.PRODUCT
--- BASE.CLIENT

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
   
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
            z.ClientToProductID
        FROM
            Base.ClientProductToCallCenter AS z
            JOIN Base.ClientToProduct AS y ON z.ClientToProductID = y.ClientToProductID
            JOIN Base.CallCenter AS x ON z.CallCenterID = x.CallCenterID
            JOIN Base.Product AS w ON y.ProductID = w.ProductID
        WHERE
            w.ProductCode IN ('MAP', 'PDCHSP')
    )
    SELECT
        a.ClientToProductID,
        '36334343-0000-0000-0000-000000000000' AS CallCenterID,
        1 AS ActiveFlag,
        a.SourceCode,
        GETDATE() AS LastUpdateDate
    FROM
        Base.ClientToProduct AS a
        JOIN Base.Product AS b ON a.ProductID = b.ProductID
        JOIN Base.Client AS c ON c.ClientID = a.ClientID
        LEFT JOIN cte_product_id_pdchsp AS z ON a.ClientToProductID = z.ClientToProductID
    WHERE
    (
        b.ProductCode IN ('PDCHSP')
        OR (
            b.ProductCode IN ('MAP')
            AND ClientCode IN ('COMO', 'PAGE1SLN')
        )
    )
$$;

--- Insert Statement
insert_statement := ' INSERT (ClientToProductID, CallCenterID, ActiveFlag, SourceCode, LastUpdateDate)
    VALUES (Source.ClientToProductID, Source.CallCenterID, Source.ActiveFlag, Source.SourceCode, Source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO BASE.CLIENTPRODUCTTOCALLCENTER as target USING 
                   ('||select_statement||') as source 
                   ON source.ClientToProductID = target.ClientToProductID
                   WHEN NOT MATCHED THEN'||insert_statement;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

-- EXECUTE IMMEDIATE update_statement;                    
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