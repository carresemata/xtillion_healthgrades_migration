CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOHEALTHINSURANCE(is_full BOOLEAN)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS declare
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

-- base.providertohealthinsurance depends on:
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.healthinsuranceplantoplantype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

select_statement string; -- cte and select statement for the merge
update_statement string; -- update
insert_statement string; -- insert statement for the merge
merge_statement string; -- merge statement to final table
status string; -- status monitoring
procedure_name varchar(50) default('sp_load_providertohealthinsurance');
execution_start datetime default getdate();
mdm_db string default('mdm_team');

begin
    

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

--- select Statement
select_statement := $$ 
with cte_health_insurance as (
    SELECT
        p.ref_provider_code as providercode,
        to_varchar(json.value:HEALTH_INSURANCE_PRODUCT_CODE) as HealthInsurance_HealthInsuranceProductCode,
        to_varchar(json.value:DATA_SOURCE_CODE) as HealthInsurance_SourceCode,
        to_timestamp_ntz(json.value:UPDATED_DATETIME) as HealthInsurance_LastUpdateDate
    FROM $$|| mdm_db ||$$.mst.provider_profile_processing as p
    , lateral flatten(input => p.PROVIDER_PROFILE:HEALTH_INSURANCE) as json
)
select 
    p.providerid,
    ptp.healthinsuranceplantoplantypeid,
    ft.HealthInsurance_SourceCode as SourceCode,
    ft.HealthInsurance_LastUpdateDate as LastUpdateDate
 from cte_health_insurance as ft
    inner join base.provider P on p.providercode = ft.providercode
    inner join base.healthinsuranceplantoplantype as PTP on ptp.insuranceproductcode = ft.HealthInsurance_HealthInsuranceProductCode
qualify row_number() over(partition by providerid, healthinsuranceplantoplantypeid order by HealthInsurance_LastUpdateDate desc ) = 1
$$;

--- insert Statement
insert_statement := ' insert 
                        (ProviderToHealthInsuranceId, 
                        ProviderId, 
                        HealthInsurancePlanToPlanTypeId, 
                        SourceCode, 
                        LastUpdateDate)
                      values 
                        (utils.generate_uuid(source.providerid || source.healthinsuranceplantoplantypeid), -- done
                        source.providerid, 
                        source.healthinsuranceplantoplantypeid, 
                        source.sourcecode, 
                        source.lastupdatedate)';

--- update statement
update_statement := ' update
                        set
                            target.SourceCode = source.sourcecode,
                            target.LastUpdateDate = source.lastupdatedate ';
                        
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------

merge_statement := 'merge into base.providertohealthinsurance as target
                    using ('||select_statement||') as source
                    on source.providerid = target.providerid and target.HealthInsurancePlanToPlanTypeId = source.healthinsuranceplantoplantypeid
                    when matched then ' || update_statement || '
                    when not matched then '||insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToHealthInsurance;
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