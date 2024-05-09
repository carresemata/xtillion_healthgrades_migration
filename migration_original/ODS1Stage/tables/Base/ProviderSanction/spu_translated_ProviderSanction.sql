CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERSANCTION()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS

DECLARE
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- Base.ProviderSanction procedure depends on:
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.StateReportingAgency
--- Base.SanctionType
--- Base.SanctionCategory
--- Base.SanctionAction

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

select_statement STRING; -- CTE and Select statement for the Merge
insert_statement STRING; -- Insert statement for the Merge
merge_statement STRING; -- Merge statement to final table
status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_ProviderSanction');
    execution_start DATETIME default getdate();


---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------

BEGIN
-- No conditionals

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- Select Statement
select_statement := $$ SELECT
                        P.ProviderId,
                        JSON.SANCTION_SANCTIONLICENSE AS SanctionLicense,
                        SRA.StateReportingAgencyID,
                        ST.SanctionTypeID,
                        SC.SanctionCategoryID,
                        SA.SanctionActionID,
                        JSON.SANCTION_SANCTIONDESCRIPTION AS SanctionDescription,
                        JSON.SANCTION_SANCTIONDATE AS SanctionDate,
                        JSON.SANCTION_SANCTIONREINSTATEMENTDATE AS SanctionReinstatementDate,
                        -- SanctionAccuracyDate
                        IFNULL(JSON.SANCTION_SOURCECODE, 'Profisee') AS SourceCode,
                        IFNULL(JSON.SANCTION_LASTUPDATEDATE, CURRENT_TIMESTAMP()) AS LastUpdateDate
                    FROM RAW.VW_PROVIDER_PROFILE AS JSON
                        LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                        LEFT JOIN Base.StateReportingAgency AS SRA ON SRA.STATEREPORTINGAGENCYCODE = JSON.SANCTION_STATEREPORTINGAGENCYCODE
                        LEFT JOIN Base.SanctionType AS ST ON ST.SANCTIONTYPECODE = JSON.SANCTION_SANCTIONTYPECODE
                        LEFT JOIN Base.SanctionCategory AS SC ON SC.SANCTIONCATEGORYCODE = JSON.SANCTION_SANCTIONCATEGORYCODE
                        LEFT JOIN Base.SanctionAction AS SA ON SA.SANCTIONACTIONCODE = JSON.SANCTION_SANCTIONACTIONCODE
                        
                    WHERE
                        PROVIDER_PROFILE IS NOT NULL AND
                        PROVIDERID IS NOT NULL AND
                        JSON.SANCTION_SANCTIONDATE IS NOT NULL AND
                        SanctionCategoryID IS NOT NULL AND
                        StateReportingAgencyID IS NOT NULL 
                    QUALIFY row_number() over(partition by ProviderId, JSON.SANCTION_SANCTIONDATE, JSON.SANCTION_SANCTIONACTIONCODE, JSON.SANCTION_SANCTIONCATEGORYCODE, JSON.SANCTION_SANCTIONTYPECODE, JSON.SANCTION_STATEREPORTINGAGENCYCODE order by CREATE_DATE desc) = 1 $$;

-- Insert Statement
insert_statement := ' INSERT (
                            ProviderSanctionID,
                            ProviderID,
                            SanctionLicense,
                            StateReportingAgencyID,
                            SanctionTypeID,
                            SanctionCategoryID,
                            SanctionActionID,
                            SanctionDescription,
                            SanctionDate,
                            SanctionReinstatementDate,
                            --SanctionAccuracyDate,
                            SourceCode,
                            LastUpdateDate
                        )
                        VALUES (
                            UUID_STRING(),
                            source.ProviderID,
                            source.SanctionLicense,
                            source.StateReportingAgencyID,
                            source.SanctionTypeID,
                            source.SanctionCategoryID,
                            source.SanctionActionID,
                            source.SanctionDescription,
                            source.SanctionDate,
                            source.SanctionReinstatementDate,
                            --source.SanctionAccuracyDate,
                            source.SourceCode,
                            source.LastUpdateDate
                        )';

                        

-- Merge Statement
merge_statement := ' MERGE INTO Base.ProviderSanction AS TARGET
USING ( ' || select_statement || ') AS SOURCE
ON TARGET.ProviderID = SOURCE.ProviderID
    AND TARGET.StateReportingAgencyID = SOURCE.StateReportingAgencyID
    AND TARGET.SanctionTypeID = SOURCE.SanctionTypeID
    AND TARGET.SanctionCategoryID = SOURCE.SanctionCategoryID
    AND TARGET.SanctionActionID = SOURCE.SanctionActionID
WHEN MATCHED THEN DELETE
WHEN NOT MATCHED THEN' || insert_statement;

---------------------------------------------------------
------------------- 4. Execution ------------------------
---------------------------------------------------------

EXECUTE IMMEDIATE merge_statement;

---------------------------------------------------------
--------------- 5. Status monitoring --------------------
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