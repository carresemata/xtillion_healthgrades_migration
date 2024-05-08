CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_CLIENTTOPRODUCT()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
--- Base.ClientToProduct depends on:
-- Base.swimlane_base_client
-- Base.Client
-- Base.Product

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

select_statement STRING;
insert_statement STRING; 
merge_statement STRING;
status STRING; -- Status monitoring

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
                    FROM Base.swimlane_base_client s
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
    RETURN status;



EXCEPTION
    WHEN OTHER THEN
          status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
          RETURN status;


END;