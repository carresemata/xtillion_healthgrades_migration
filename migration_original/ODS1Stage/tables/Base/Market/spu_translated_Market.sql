CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_MARKET()
RETURNS STRING
LANGUAGE SQL EXECUTE
AS CALLER
AS DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
--- Base.Market depends on:
-- Base.GeographicArea
-- Base.MarketMaster (empty in SQL Server?)
-- Base.Source
-- dbo.RequestedMarketLocationsMissingFromODS2 (external schema)

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
select_statement STRING;
insert_statement STRING;
merge_statement STRING;
status STRING;
    procedure_name varchar(50) default('sp_load_Market');
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
                    SELECT DISTINCT
                        mkm.MarketGUID AS MarketID,
                        mkm.GeographicAreaGUID AS GeographicAreaID,
                        mkm.LineOfServiceGUID AS LineOfServiceID,
                        mkm.MarketCode,
                        mkm.LegacyClientMarketID AS LegacyKey,
                        'ClientMarketID' AS LegacyKeyName,
                        s.SourceCode,
                        mkm.LastUpdateDate
                    FROM Base.MarketMaster AS mkm
                        INNER JOIN Base.GeographicArea ga ON mkm.GeographicAreaGUID = ga.GeographicAreaID
                        INNER JOIN dbo.RequestedMarketLocationsMissingFromODS2 missing ON ga.GeographicAreaValue1 = missing.GeographicAreaValue1
                            AND IFNULL(ga.GeographicAreaValue2,'') = IFNULL(missing.GeographicAreaValue2, '')
                        LEFT JOIN Base.Market bm ON mkm.MarketGUID = bm.MarketID
                        LEFT JOIN Base.Source s ON mkm.SYSTEM_SRC_GUID = s.SourceID
                    WHERE mkm.EndDate > DATEADD(day, -180, CURRENT_DATE()) OR mkm.EndDate IS NULL
                        AND bm.MarketID IS NULL
                    $$;


insert_statement := $$ 
                    INSERT
                        (
                        MarketID, 
                        GeographicAreaID, 
                        LineOfServiceID, 
                        MarketCode, 
                        LegacyKey, 
                        LegacyKeyName, 
                        SourceCode,
                        LastUpdateDate
                        )
                     VALUES 
                        (
                        source.MarketID, 
                        source.GeographicAreaID, 
                        source.LineOfServiceID, 
                        source.MarketCode, 
                        source.LegacyKey, 
                        source.LegacyKeyName, 
                        source.SourceCode,
                        source.LastUpdateDate
                        )
                     $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := $$ MERGE INTO Base.Market as target 
                    USING ($$||select_statement||$$) as source 
                   ON source.MarketId = target.MarketId
                   WHEN NOT MATCHED THEN $$ ||insert_statement;

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