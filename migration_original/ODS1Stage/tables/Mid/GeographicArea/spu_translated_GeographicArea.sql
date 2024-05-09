CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_GEOGRAPHICAREA() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  

DECLARE
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Mid.GeographicArea depends on: 
--- Base.GeographicArea
--- Base.GeographicAreaType


---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
 
    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_GeographicArea');
    execution_start DATETIME default getdate();

   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    -- no conditionals


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
select_statement := $$WITH CTE_geoArea AS (
                    SELECT
                        GEOGRAPHICAREAID,
                        GEOGRAPHICAREACODE,
                        GEOGRAPHICAREATYPECODE,
                        CASE
                            WHEN GeoAreaType.GeographicAreaTypeCode = 'CITYST' THEN CONCAT(
                                GeoArea.GeographicAreaValue1,
                                ',',
                                GeoArea.GeographicAreaValue2
                            )
                            ELSE GeoArea.GeographicAreaValue1
                        END AS GeographicAreaValue,
                        0 AS ActionCode -- Create a new column ActionCode and set it to 0 (default value: no change)
                    FROM
                        Base.GeographicArea GeoArea
                        JOIN Base.GeographicAreaType GeoAreaType ON GeoArea.GEOGRAPHICAREATYPEID = GeoAreaType.GEOGRAPHICAREATYPEID
                    ),
                    -- Insert Action
                    CTE_Action_1 AS (
                        SELECT
                            CTE_geoArea.GeographicAreaID,
                            1 AS ActionCode
                        FROM
                            CTE_geoArea
                            LEFT JOIN Mid.GeographicArea GeoArea ON CTE_geoArea.GeographicAreaID = GeoArea.GeographicAreaID
                            AND CTE_geoArea.GeographicAreaCode = GeoArea.GeographicAreaCode
                            AND CTE_geoArea.GEOGRAPHICAREATYPECODE = GeoArea.GEOGRAPHICAREATYPECODE
                            AND CTE_geoArea.GeographicAreaValue = GeoArea.GeographicAreaValue
                        WHERE
                            GeoArea.GeographicAreaID IS NULL
                    ),
                    -- Update Action
                    CTE_Action_2 AS (
                        SELECT
                            CTE_geoArea.GeographicAreaID,
                            2 AS ActionCode
                        FROM
                            CTE_geoArea
                            JOIN Mid.GeographicArea GeoArea ON CTE_geoArea.GeographicAreaID = GeoArea.GeographicAreaID
                            AND CTE_geoArea.GeographicAreaCode = GeoArea.GeographicAreaCode
                        WHERE
                            MD5(
                                IFNULL(CTE_geoArea.GEOGRAPHICAREACODE::VARCHAR, '''')
                            ) <> MD5(
                                IFNULL(CTE_geoArea.GEOGRAPHICAREACODE::VARCHAR, '''')
                            )
                            OR MD5(
                                IFNULL(CTE_geoArea.GeographicAreaValue::VARCHAR, '''')
                            ) <> MD5(
                                IFNULL(CTE_geoArea.GeographicAreaValue::VARCHAR, '''')
                            )
                    )
                    SELECT
                        A0.GEOGRAPHICAREAID,
                        A0.GEOGRAPHICAREACODE,
                        A0.GEOGRAPHICAREATYPECODE,
                        A0.GeographicAreaValue,
                        IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) AS ActionCode
                    FROM
                        CTE_geoArea A0
                        LEFT JOIN CTE_ACTION_1 A1 ON A0.GeographicAreaID = A1.GeographicAreaID
                        LEFT JOIN CTE_ACTION_2 A2 ON A0.GeographicAreaID = A2.GeographicAreaID
                    WHERE 
                        IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) <> 0
                    $$;

--- Update Statement
update_statement := ' UPDATE 
                        SET
                            GEOGRAPHICAREAID = source.GEOGRAPHICAREAID , 
                            GEOGRAPHICAREACODE = source.GEOGRAPHICAREACODE , 
                            GEOGRAPHICAREATYPECODE = source.GEOGRAPHICAREATYPECODE , 
                            GEOGRAPHICAREAVALUE = source.GEOGRAPHICAREAVALUE ';

--- Insert Statement
insert_statement := ' INSERT
                            (   GEOGRAPHICAREAID,
                                GEOGRAPHICAREACODE,
                                GEOGRAPHICAREATYPECODE,
                                GEOGRAPHICAREAVALUE)
                       VALUES
                            (   source.GEOGRAPHICAREAID,
                                source.GEOGRAPHICAREACODE,
                                source.GEOGRAPHICAREATYPECODE,
                                source.GEOGRAPHICAREAVALUE);';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Mid.GeographicArea as target USING 
                   ('||select_statement||') as source 
                   ON source.GEOGRAPHICAREAID = target.GEOGRAPHICAREAID AND source.GEOGRAPHICAREACODE = target.GEOGRAPHICAREACODE
                   WHEN MATCHED AND source.ActionCode = 2 THEN '||update_statement|| '
                   WHEN NOT MATCHED AND source.ActionCode = 1 THEN '||insert_statement;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
EXECUTE IMMEDIATE merge_statement ;

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
