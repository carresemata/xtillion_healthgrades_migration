CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOPROVIDERTYPE()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderToProviderType depends on: 
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.ProviderType

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_ProviderToProviderType');
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
                            P.ProviderId,
                            PT.ProviderTypeID,
                            IFNULL(JSON.ProviderType_SourceCode, 'Profisee') AS SourceCode,
                            IFNULL(JSON.ProviderType_ProviderTypeRankCalculated, 1) AS ProviderTypeRank,
                            2147483647 AS ProviderTypeRankCalculated,
                            IFNULL(JSON.ProviderType_LastUpdateDate, CURRENT_TIMESTAMP()) AS LastUpdateDate    
                        FROM Raw.VW_PROVIDER_PROFILE AS JSON
                        LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                        LEFT JOIN Base.ProviderType AS PT ON PT.ProviderTypeCode = IFNULL(JSON.ProviderType_ProviderTypeCode, 'ALT')
                        WHERE
                            PROVIDER_PROFILE IS NOT NULL
                            AND ProviderType_ProviderTypeCode IS NOT NULL
                            AND ProviderID IS NOT NULL 
                        QUALIFY ROW_NUMBER() OVER( PARTITION BY ProviderID, IFNULL(ProviderType_ProviderTypeCode, 'ALT') ORDER BY CREATE_DATE DESC) = 1$$;



--- Insert Statement
insert_statement := ' INSERT  
                        (ProviderToProviderTypeID,
                        ProviderID,
                        ProviderTypeID,
                        SourceCode,
                        ProviderTypeRank,
                        ProviderTypeRankCalculated,
                        LastUpdateDate)
                      VALUES 
                        (UUID_STRING(),
                        source.ProviderID,
                        source.ProviderTypeID,
                        source.SourceCode,
                        source.ProviderTypeRank,
                        source.ProviderTypeRankCalculated,
                        source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.ProviderToProviderType as target USING 
                   ('||select_statement||') as source 
                   ON source.Providerid = target.Providerid
                   WHEN MATCHED THEN DELETE
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