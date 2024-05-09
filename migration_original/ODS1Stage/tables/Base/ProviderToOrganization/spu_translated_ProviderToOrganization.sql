CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOORGANIZATION()
RETURNS STRING
LANGUAGE SQL EXECUTE
AS CALLER
AS DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- Base.ProviderToOrganization depends on:
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
select_statement STRING;
insert_statement STRING;
merge_statement STRING;
status STRING;
    procedure_name varchar(50) default('sp_load_ProviderToOrganization');
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
                        IFNULL(JSON.Organization_SourceCode, 'Profisee') AS SourceCode,
                        UUID_STRING() AS ProviderToOrganizationID,
                        p.ProviderID AS ProviderID,
                        -- OrganizationID,
                        -- PositionID,
                        -- PositionStartDate,
                        -- PositionEndDate,
                        JSON.Organization_PositionRank AS PositionRank,
                        SYSDATE() AS LastUpdateDate,
                        CURRENT_USER() AS InsertedBy
                    FROM Raw.VW_PROVIDER_PROFILE AS JSON
                    LEFT JOIN Base.Provider AS p ON p.ProviderCode = JSON.ProviderCode
                    WHERE p.ProviderID IS NOT NULL
                    $$;


insert_statement := $$ 
                     INSERT  
                       (   
                        SourceCode,
                        ProviderToOrganizationID,
                        ProviderID,
                        -- OrganizationID,
                        -- PositionID,
                        -- PositionStartDate,
                        -- PositionEndDate,
                        PositionRank,
                        LastUpdateDate,
                        InsertedBy
                        )
                      VALUES 
                        (   
                        source.SourceCode,
                        source.ProviderToOrganizationID,
                        source.ProviderID,
                        -- source.OrganizationID,
                        -- source.PositionID,
                        -- source.PositionStartDate,
                        -- source.PositionEndDate,
                        source.PositionRank,
                        source.LastUpdateDate,
                        source.InsertedBy
                        )
                     $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := $$ MERGE INTO Base.ProviderToOrganization as target 
                    USING ($$||select_statement||$$) as source 
                   ON source.ProviderId = target.ProviderId
                   WHEN MATCHED THEN DELETE
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