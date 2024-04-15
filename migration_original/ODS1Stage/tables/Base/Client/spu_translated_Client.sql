CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_BASE_CLIENT(IsProviderDeltaProcessing BOOLEAN) -- Parameters
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
        DISTINCT x.ClientCode,
        c.ClientID,
        case
            when x.CustomerName is null
            and c.ClientName is null then x.ClientCode
            when x.CustomerName is null
            and c.ClientName is not null then c.ClientName
            else x.CustomerName
        end as ClientName,
        ifnull(x.LastUpdateDate, current_timestamp()) as LastUpdateDate,
        ifnull(x.SourceCode, 'Profisee') as SourceCode
    FROM
        base.swimlane_base_client AS x
        INNER JOIN ODS1_Stage.Base.Client AS c ON c.ClientCode = x.ClientCode QUALIFY dense_rank() over(
            partition by x.CustomerProductCode
            order by
                x.created_datetime desc
        ) = 1$$;

--- Update Statement
update_statement := '
update
    Base.Client
set
    ClientName = s.ClientName,
    LastUpdateDate = s.LastUpdateDate
from
    (' || select_statement || ') as s
    inner join Base.Client as p on p.ClientID = s.ClientID';;

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
                   WHEN NOT MATCHED AND source.clientid IS NOT NULL
                    AND source.clientcode IS NOT NULL THEN'||insert_statement;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE update_statement;                    
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