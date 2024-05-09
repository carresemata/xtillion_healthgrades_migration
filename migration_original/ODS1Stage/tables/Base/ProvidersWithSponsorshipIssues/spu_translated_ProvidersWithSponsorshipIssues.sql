CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERLSWITHSPONSORSHIPISSUES()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 

DECLARE
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
--- Base.ProvidersWithSponsorshipIssues depends on:
-- Mid.ProviderSponsorship
-- Mid.Provider

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
select_statement STRING;
insert_statement STRING;
update_statement STRING;
merge_statement STRING;
status STRING;
    procedure_name varchar(50) default('sp_load_ProvidersWithSponsorshipIssues');
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
                    WITH CTE_ProviderWithMultipleSponsorships AS (
                        SELECT ProviderCode
                        FROM Mid.ProviderSponsorship
                        WHERE ProductCode <> 'LID'
                        GROUP BY ProviderCode
                        HAVING COUNT(DISTINCT ClientCode) > 1
                    ),
                    
                    CTE_ProviderWithNullOfficeCode AS (
                        SELECT DISTINCT ProviderCode
                        FROM Mid.ProviderSponsorship
                        WHERE ProductCode = 'PDCPRAC' AND OfficeCode IS NULL
                    ),
                    
                    CTE_ProviderWithNullPhoneXML AS (
                        SELECT DISTINCT ps.ProviderCode
                        FROM Mid.ProviderSponsorship ps
                        JOIN Mid.Provider p ON p.ProviderCode = ps.ProviderCode
                        WHERE ps.ProductCode IN ('PDCHSP', 'PDCPRAC') AND ps.PhoneXML IS NULL
                    ),
                    
                    CTE_ProviderWithNullFacilityCode AS (
                        SELECT DISTINCT ps.ProviderCode
                        FROM Mid.ProviderSponsorship ps
                        JOIN Mid.Provider p ON p.ProviderCode = ps.ProviderCode
                        WHERE ps.ProductCode = 'PDCHSP' AND ps.FacilityCode IS NULL
                    ),
                    
                    CTE_AllIssues AS (
                        SELECT ProviderCode, 'Non-LID Provider has more than one sponsorship record in ODS1Stage.Mid.ProviderSponsorship' AS IssueDescription
                        FROM CTE_ProviderWithMultipleSponsorships
                        UNION ALL
                        SELECT ProviderCode, 'PDCPRAC Provider has a null OfficeCode in ODS1Stage.Mid.ProviderSponsorship'
                        FROM CTE_ProviderWithNullOfficeCode 
                        UNION ALL
                        SELECT ProviderCode, 'PDCHSP/PDCPRAC Provider has a null PhoneXML in ODS1Stage.Mid.ProviderSponsorship'
                        FROM CTE_ProviderWithNullPhoneXML
                        UNION ALL
                        SELECT ProviderCode, 'PDCHSP Provider has a null FacilityCode in ODS1Stage.Mid.ProviderSponsorship'
                        FROM CTE_ProviderWithNullFacilityCode
                    )
                    
                    SELECT ProviderCode, IssueDescription
                    FROM CTE_AllIssues
                    $$;

insert_statement := $$ 
                    INSERT
                        (
                        ProviderCode, 
                        IssueDescription
                        )
                     VALUES 
                        (
                        source.ProviderCode,
                        source.IssueDescription
                        )
                     $$;

update_statement := $$
                    UPDATE SET target.IssueDescription= source.IssueDescription
                    $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := $$ MERGE INTO Base.ProvidersWithSponsorshipIssues as target 
                    USING ($$||select_statement||$$) as source 
                    ON source.ProviderCode = target.ProviderCode
                    WHEN MATCHED THEN $$||update_statement||$$
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