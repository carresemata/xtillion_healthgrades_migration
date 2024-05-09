CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTODEGREE()
RETURNS STRING
LANGUAGE SQL EXECUTE
AS CALLER
AS DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- Base.ProviderToDegree depends on:
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.Degree

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
select_statement STRING;
insert_statement STRING;
merge_statement STRING;
status STRING;
    procedure_name varchar(50) default('sp_load_ProviderToDegree');
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
                    SELECT 
                        UUID_STRING() AS ProviderToDegreeID,
                        p.ProviderId,
                        JSON.Degree_DegreeCode AS DegreeID,
                        JSON.Degree_DegreeRank AS DegreePriority,
                        IFNULL(JSON.Degree_SourceCode, 'Profisee') AS SourceCode,
                        IFNULL(JSON.Degree_LastUpdateDate, SYSDATE()) AS LastUpdateDate
                    FROM Raw.VW_PROVIDER_PROFILE AS JSON
                    LEFT JOIN Base.Provider p ON p.ProviderCode = JSON.ProviderCode
                    LEFT JOIN Base.Degree d ON d.DegreeAbbreviation = JSON.Degree_DegreeCode
                    WHERE JSON.PROVIDER_PROFILE IS NOT NULL 
                    QUALIFY ROW_NUMBER() OVER (PARTITION BY ProviderId, JSON.Degree_DegreeCode ORDER BY JSON.Create_Date DESC) = 1
                    $$;


insert_statement := $$ 
                     INSERT  
                       (   
                        ProviderToDegreeID,
                        ProviderId,
                        DegreeId, 
                        DegreePriority,
                        SourceCode,
                        LastUpdateDate
                        )
                      VALUES 
                        (   
                        source.ProviderToDegreeID,
                        source.ProviderId,
                        source.DegreeId,
                        source.DegreePriority,
                        source.SourceCode,
                        source.LastUpdateDate
                        )
                     $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := $$ MERGE INTO Base.ProviderToDegree as target 
                    USING ($$||select_statement||$$) as source 
                   ON source.ProviderId = target.ProviderId
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