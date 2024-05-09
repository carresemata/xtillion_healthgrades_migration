CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_LINEOFSERVICE() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Mid.LineOfService depends on:
--- Base.LineOfService
--- Base.LineOfServiceType
--- Base.SpecialtyGroup

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_LineOfService');
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
select_statement := $$ 
                    WITH CTE_LineofService AS (
                    SELECT
                        BaseLine.LineOfServiceID,
                        BaseLine.LineOfServiceCode,
                        BaseType.LineOfServiceTypeCode,
                        BaseLine.LineOfServiceDescription,
                        BaseSpec.LegacyKey,
                        BaseSpec.SpecialtyGroupDescription AS LegacyKeyName,
                        0 AS ActionCode
                    FROM
                        Base.LineOfService BaseLine
                        JOIN Base.LineOfServiceType BaseType ON BaseLine.LineOfServiceTypeID = BaseType.LineOfServiceTypeID
                        JOIN Base.SpecialtyGroup BaseSpec ON BaseLine.LineOfServiceCode = BaseSpec.SpecialtyGroupCode
                ),
                --- Insert Action
                CTE_Action_1 AS (
                    SELECT
                        CTE_LineOfService.LineOfServiceID,
                        1 AS ActionCode
                    FROM
                        CTE_LineOfService
                        LEFT JOIN Mid.LineOfService MidLine ON MidLine.LineOfServiceID = CTE_LineOfService.LineOfServiceID
                        AND MidLine.LineOfServiceCode = CTE_LineOfService.LineOfServiceCode
                        AND MidLine.LineOfServiceTypeCode = CTE_LineOfService.LineOfServiceTypeCode
                    WHERE
                        CTE_LineOfService.LineOfServiceID IS NULL
                ),
                -- Update Action
                CTE_Action_2 AS (
                    SELECT
                        CTE_LineOfService.LineOfServiceID,
                        2 AS ActionCode
                    FROM
                        CTE_LineOfService
                        JOIN Mid.LineOfService MidLine ON MidLine.LineOfServiceID = CTE_LineOfService.LineOfServiceID
                        AND MidLine.LineOfServiceCode = CTE_LineOfService.LineOfServiceCode
                        AND MidLine.LineOfServiceTypeCode = CTE_LineOfService.LineOfServiceTypeCode
                    WHERE
                        MD5(
                            IFNULL(
                                CTE_LineOfService.LineOfServiceDescription::VARCHAR,
                                ''''''''
                            )
                        ) <> MD5(
                            IFNULL(
                                CTE_LineOfService.LineOfServiceDescription::VARCHAR,
                                ''''''''
                            )
                        )
                        OR MD5(
                            IFNULL(CTE_LineOfService.LegacyKey::VARCHAR, '''''''')
                        ) <> MD5(
                            IFNULL(CTE_LineOfService.LegacyKey::VARCHAR, '''''''')
                        )
                        OR MD5(
                            IFNULL(
                                CTE_LineOfService.LegacyKeyName::VARCHAR,
                                ''''''''
                            )
                        ) <> MD5(
                            IFNULL(
                                CTE_LineOfService.LegacyKeyName::VARCHAR,
                                ''''''''
                            )
                        )
                )
                SELECT
                    A0.LineOfServiceID,
                    A0.LineOfServiceCode,
                    A0.LineOfServiceTypeCode,
                    A0.LineOfServiceDescription,
                    A0.LegacyKey,
                    A0.LegacyKeyName,
                    IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) AS ActionCode
                FROM
                    CTE_LineOfService A0
                    LEFT JOIN CTE_ACTION_1 A1 ON A0.LineOfServiceID = A1.LineOfServiceID
                    LEFT JOIN CTE_ACTION_2 A2 ON A0.LineOfServiceID = A2.LineOfServiceID
                WHERE
                    IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) <> 0
                    $$;


--- Update Statement
update_statement := 'UPDATE 
                     SET 
                        LINEOFSERVICEID = source.LINEOFSERVICEID, 
                        LINEOFSERVICECODE = source.LINEOFSERVICECODE, 
                        LINEOFSERVICETYPECODE = source.LINEOFSERVICETYPECODE, 
                        LINEOFSERVICEDESCRIPTION = source.LINEOFSERVICEDESCRIPTION, 
                        LEGACYKEY = source.LEGACYKEY, 
                        LEGACYKEYNAME = source.LEGACYKEYNAME';

--- Insert Statement
insert_statement := ' INSERT  
                        (LINEOFSERVICEID,
                        LINEOFSERVICECODE, 
                        LINEOFSERVICETYPECODE, 
                        LINEOFSERVICEDESCRIPTION, 
                        LEGACYKEY, 
                        LEGACYKEYNAME)
                      VALUES 
                        (source.LINEOFSERVICEID,
                        source.LINEOFSERVICECODE, 
                        source.LINEOFSERVICETYPECODE, 
                        source.LINEOFSERVICEDESCRIPTION, 
                        source.LEGACYKEY, 
                        source.LEGACYKEYNAME)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Mid.LineOfService as target USING 
                   ('||select_statement||') as source 
                   ON source.LINEOFSERVICEID = target.LINEOFSERVICEID
                   WHEN MATCHED AND ActionCode = 2 THEN '||update_statement|| '
                   WHEN NOT MATCHED AND ActionCode = 1 THEN '||insert_statement;
                   
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