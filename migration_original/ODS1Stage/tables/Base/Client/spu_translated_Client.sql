CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CLIENT() -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

--- BASE.CLIENT depends on:   
--- MDM_TEAM.MST.CUSTOMER_PRODUCT_PROFILE_PROCESSING (BASE.vw_SWIMLANE_BASE_CLIENT)

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_Client');
    execution_start DATETIME default getdate();

   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   

BEGIN

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
select_statement := $$ SELECT
         DISTINCT
        swimlane.ClientCode,
        UUID_STRING() AS clientid,
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
        LEFT JOIN Base.Client AS c ON c.ClientCode = swimlane.ClientCode QUALIFY dense_rank() over(
            partition by swimlane.CLIENTCODE
            order by
                swimlane.LastUpdateDate desc
        ) = 1 $$;

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

-- EXECUTE IMMEDIATE update_statement;                    
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