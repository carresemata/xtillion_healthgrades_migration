CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERSANCTION(is_full BOOLEAN)
RETURNS STRING
LANGUAGE SQL
EXECUTE as CALLER
as

declare
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.providersanction procedure depends on:
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.statereportingagency
--- base.sanctiontype
--- base.sanctioncategory
--- base.sanctionaction

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

select_statement string; -- cte and select statement for the merge
insert_statement string; -- insert statement for the merge
update_statement string; -- update
merge_statement string; -- merge statement to final table
status string; -- status monitoring
procedure_name varchar(50) default('sp_load_providersanction');
execution_start datetime default getdate();
mdm_db string default('mdm_team');


begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- select Statement
select_statement := $$ with Cte_sanction as (
                        SELECT
                            p.ref_provider_code as providercode,
                            to_varchar(json.value:SANCTION_LICENSE) as Sanction_SanctionLicense,
                            to_varchar(json.value:SANCTION_TYPE_CODE) as Sanction_SanctionTypeCode,
                            to_varchar(json.value:SANCTION_CATEGORY_CODE) as Sanction_SanctionCategoryCode,
                            to_varchar(json.value:SANCTION_ACTION_CODE) as Sanction_SanctionActionCode,
                            to_varchar(json.value:SANCTION_DESCRIPTION) as Sanction_SanctionDescription,
                            to_varchar(json.value:SANCTION_DATE) as Sanction_SanctionDate,
                            to_varchar(json.value:SANCTION_REINSTATEMENT_DATE) as Sanction_SanctionReinstatementDate,
                            to_varchar(json.value:DATA_SOURCE_CODE) as Sanction_SourceCode,
                            to_timestamp_ntz(json.value:UPDATED_DATETIME) as Sanction_LastUpdateDate,
                            to_varchar(json.value:STATE_REPORTING_AGENCY_CODE) as Sanction_StateReportingAgencyCode
                        FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
                        , lateral flatten(input => p.PROVIDER_PROFILE:SANCTION) as json
                        where
                            sanction_SANCTIONDATE is not null
                    )

                    select distinct
                        p.providerid,
                        json.sanction_SANCTIONLICENSE as SanctionLicense,
                        sra.statereportingagencyid,
                        st.sanctiontypeid,
                        sc.sanctioncategoryid,
                        sa.sanctionactionid,
                        json.sanction_SANCTIONDESCRIPTION as SanctionDescription,
                        json.sanction_SANCTIONDATE as SanctionDate,
                        json.sanction_SANCTIONREINSTATEMENTDATE as SanctionReinstatementDate,
                        -- SanctionAccuracyDate
                        ifnull(json.sanction_SOURCECODE, 'Profisee') as SourceCode,
                        ifnull(json.sanction_LASTUPDATEDATE, current_timestamp()) as LastUpdateDate
                    from cte_sanction as JSON
                        join base.provider as P on p.providercode = json.providercode
                        join base.statereportingagency as SRA on sra.statereportingagencycode = json.sanction_STATEREPORTINGAGENCYCODE
                        left join base.sanctiontype as ST on st.sanctiontypecode = json.sanction_SANCTIONTYPECODE
                        join base.sanctioncategory as SC on sc.sanctioncategorycode = json.sanction_SANCTIONCATEGORYCODE
                        left join base.sanctionaction as SA on sa.sanctionactioncode = json.sanction_SANCTIONACTIONCODE
                    qualify row_number() over(partition by ProviderId, json.sanction_SANCTIONDATE, json.sanction_SANCTIONACTIONCODE, json.sanction_SANCTIONCATEGORYCODE, json.sanction_SANCTIONTYPECODE, json.sanction_STATEREPORTINGAGENCYCODE order by json.sanction_LASTUPDATEDATE desc) = 1  $$;

-- insert Statement
insert_statement := ' insert (
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
                            SourceCode,
                            LastUpdateDate
                        )
                        values (
                            utils.generate_uuid(source.providerid || source.statereportingagencyid || source.sanctiontypeid || source.sanctioncategoryid || source.sanctionactionid || source.sanctiondate ), 
                            source.providerid,
                            source.sanctionlicense,
                            source.statereportingagencyid,
                            source.sanctiontypeid,
                            source.sanctioncategoryid,
                            source.sanctionactionid,
                            source.sanctiondescription,
                            source.sanctiondate,
                            source.sanctionreinstatementdate,
                            source.sourcecode,
                            source.lastupdatedate
                        )';

--- update statement                        
update_statement := ' 
    update
    set
        target.SanctionLicense = source.sanctionlicense,
        target.SanctionDescription = source.sanctiondescription,
        target.SanctionDate = source.sanctiondate,
        target.SanctionReinstatementDate = source.sanctionreinstatementdate,
        target.SourceCode = source.sourcecode,
        target.LastUpdateDate = source.lastupdatedate
';     

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

-- Merge Statement
merge_statement := ' merge into base.providersanction as TARGET
using ( ' || select_statement || ') as SOURCE
    on target.providerid = source.providerid
    and target.statereportingagencyid = source.statereportingagencyid
    and target.sanctiontypeid = source.sanctiontypeid
    and target.sanctioncategoryid = source.sanctioncategoryid
    and target.sanctionactionid = source.sanctionactionid
    and target.sanctiondate = source.sanctiondate
when matched then ' || update_statement || '
when not matched then' || insert_statement;

---------------------------------------------------------
------------------- 5. Execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table base.providersanction;
end if; 
execute immediate merge_statement;

---------------------------------------------------------
--------------- 6. status monitoring --------------------
---------------------------------------------------------

status := 'completed successfully';
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        return status;

        exception
        when other then
            status := 'failed during execution. ' || 'sql error: ' || sqlerrm || ' error code: ' || sqlcode || '. sql state: ' || sqlstate;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, split_part(regexp_substr(:status, 'error code: ([0-9]+)'), ':', 2)::integer, trim(split_part(split_part(:status, 'sql error:', 2), 'error code:', 1)), split_part(regexp_substr(:status, 'sql state: ([0-9]+)'), ':', 2)::integer; 

            return status;
end;