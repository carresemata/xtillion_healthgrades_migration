CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_TELEHEALTHMETHOD()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.TeleHealthMethod depends on:
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.TeleHealthMethodType

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_TelehealthMethod');
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
select_statement := $$ SELECT DISTINCT
                            TMT.TelehealthMethodTypeId,
                            JSON.TELEHEALTH_TELEHEALTHMETHODCODE AS TeleHealthMethod,
                            JSON.TELEHEALTH_TELEHEALTHVENDORNAME AS ServiceName,
                            IFNULL(JSON.Telehealth_SourceCode, 'Profisee') AS SourceCode,
                            CASE WHEN IFNULL(JSON.TeleHealth_HasTelehealth, 'N') IN ('yes', 'true', '1', 'Y', 'T') THEN 'TRUE' ELSE 'FALSE' END AS HasTeleHealth,
                            JSON.Telehealth_LastUpdateDate AS LastUpdatedDate
                        FROM
                            RAW.VW_PROVIDER_PROFILE AS JSON
                            LEFT JOIN Base.TelehealthMethodType AS TMT ON TMT.MethodTypeCode = JSON.Telehealth_TelehealthMethodCode
                        WHERE
                            PROVIDER_PROFILE IS NOT NULL AND
                            HasTeleHealth = 'TRUE' AND
                            TelehealthMethod IS NOT NULL$$;




--- Insert Statement
insert_statement := ' INSERT  
                            (TelehealthMethodId,
                            TelehealthMethodTypeId, 
                            TelehealthMethod, 
                            ServiceName, 
                            SourceCode, 
                            LastUpdatedDate)
                      VALUES 
                            (UUID_STRING(),
                            source.TelehealthMethodTypeId, 
                            source.TelehealthMethod, 
                            source.ServiceName, 
                            source.SourceCode, 
                            source.LastUpdatedDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.Telehealthmethod as target USING 
                   ('||select_statement||') as source 
                   ON source.TelehealthMethodTypeId = target.TelehealthMethodTypeId
                   WHEN NOT MATCHED THEN '||insert_statement;
                   
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