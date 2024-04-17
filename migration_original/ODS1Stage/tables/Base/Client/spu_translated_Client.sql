CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_CLIENT() -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
--- BASE.SWIMLANE_BASE_CLIENT
--- RAW.CUSTOMER_PRODUCT_PROFILE_PROCESSING
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
select_statement := $$SELECT
        DISTINCT swimlane.ClientCode,
        c.ClientID,
        case
            when swimlane.CustomerName is null
            and c.ClientName is null then swimlane.ClientCode
            when swimlane.CustomerName is null
            and c.ClientName is not null then c.ClientName
            else swimlane.CustomerName
        end as ClientName,
        ifnull(swimlane.LastUpdateDate, current_timestamp()) as LastUpdateDate,
        ifnull(swimlane.SourceCode, 'Profisee') as SourceCode
    FROM
        base.swimlane_base_client AS swimlane
        INNER JOIN ODS1_Stage.Base.Client AS c ON c.ClientCode = swimlane.ClientCode QUALIFY dense_rank() over(
            partition by swimlane.CustomerProductCode
            order by
                swimlane.created_datetime desc
        ) = 1$$;

--- Update Statement
update_statement := '
UPDATE
SET
    ClientName = source.ClientName,
    LastUpdateDate = source.LastUpdateDate';

--- Insert Statement
insert_statement := ' insert
    (
        ClientID,
        ClientCode,
        ClientName,
        SourceCode,
        LastUpdateDate
    )
VALUES
    (
        source.ClientID,
        source.ClientCode,
        source.ClientName,
        source.SourceCode,
        source.LastUpdateDate
    )';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO BASE.CLIENT as target USING 
                   ('||select_statement||') as source 
                   ON source.clientid = target.clientid
                   WHEN MATCHED THEN '||update_statement||'
                   WHEN NOT MATCHED AND source.clientid IS NOT NULL
                    AND source.clientcode IS NOT NULL THEN'||insert_statement;
                   
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

CALL BASE.SP_LOAD_CLIENT();


