CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOCLINICALFOCUS(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertoclinicalfocus depends on:
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.clinicalfocus

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertoclinicalfocus');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ 
with cte_clinicalfocus as (
    select
        p.ref_provider_code as providercode,
        to_varchar(json.value:CLINICAL_FOCUS_CODE) as clinicalfocus_ClinicalFocusCode,
        to_varchar(json.value:CLINICAL_FOCUS_DCP_COUNT) as clinicalfocus_ClinicalFocusDCPCount,
        to_varchar(json.value:CLINICAL_FOCUS_MIN_BUCKETS_CALCULATED) as clinicalfocus_ClinicalFocusMinBucketsCalculated,
        to_varchar(json.value:PROVIDER_DCP_COUNT) as clinicalfocus_ProviderDCPCount,
        to_varchar(json.value:AVERAGE_B_PERCENTILE) as clinicalfocus_AverageBPercentile,
        to_varchar(json.value:PROVIDER_DCP_FILL_PERCENT) as clinicalfocus_ProviderDCPFillPercent,
        to_boolean(json.value:IS_PROVIDER_DCP_COUNT_OVER_LOW_THRESHOLD) as clinicalfocus_IsProviderDCPCountOverLowThreshold,
        to_varchar(json.value:CLINICAL_FOCUS_SCORE) as clinicalfocus_ClinicalFocusScore,
        to_varchar(json.value:PROVIDER_CLINICAL_FOCUS_RANK) as clinicalfocus_ProviderClinicalFocusRank,
        to_varchar(json.value:DATA_SOURCE_CODE) as clinicalfocus_SourceCode,
        to_timestamp_ntz(json.value:UPDATED_DATETIME) as clinicalfocus_LastUpdateDate
    from $$||mdm_db||$$.mst.provider_profile_processing as p,
    lateral flatten(input => p.PROVIDER_PROFILE:CLINICAL_FOCUS) as json
    where to_varchar(json.value:CLINICAL_FOCUS_CODE) is not null
)

select 
    p.providerid,
    cf.clinicalfocusid,
    json.clinicalfocus_ClinicalFocusDCPCount as ClinicalFocusDCPCount,
    json.clinicalfocus_ClinicalFocusMinBucketsCalculated as ClinicalFocusMinBucketsCalculated,
    json.clinicalfocus_ProviderDCPCount as ProviderDCPCount,
    json.clinicalfocus_AverageBPercentile as AverageBPercentile,
    json.clinicalfocus_ProviderDCPFillPercent as ProviderDCPFillPercent,
    json.clinicalfocus_IsProviderDCPCountOverLowThreshold as IsProviderDCPCountOverLowThreshold,
    json.clinicalfocus_ClinicalFocusScore as ClinicalFocusScore,
    json.clinicalfocus_ProviderClinicalFocusRank as ProviderClinicalFocusRank,
    ifnull(json.clinicalfocus_SourceCode, 'Profisee') as SourceCode,
    ifnull(json.clinicalfocus_LastUpdateDate, current_timestamp()) as LastUpdateDate
from cte_clinicalfocus as json
    join base.provider as p on json.providercode = p.providercode
    join base.clinicalfocus as cf on json.clinicalfocus_ClinicalFocusCode = cf.clinicalfocuscode
qualify row_number() over(partition by p.providerid, clinicalfocusid order by clinicalfocus_LastUpdateDate desc) = 1
$$
;

--- insert Statement
insert_statement := $$ insert 
                        (
                            ProviderToClinicalFocusId,
                            ProviderId,
                            ClinicalFocusId,
                            ClinicalFocusDCPCount,
                            ClinicalFocusMinBucketsCalculated,
                            ProviderDCPCount,
                            AverageBPercentile,
                            ProviderDCPFillPercent,
                            IsProviderDCPCountOverLowThreshold,
                            ClinicalFocusScore,
                            ProviderClinicalFocusRank,
                            SourceCode,
                            InsertedOn
                        )
                        values (
                            utils.generate_uuid(source.providerid || source.clinicalfocusid), 
                            source.providerid,
                            source.clinicalfocusid,
                            source.clinicalfocusdcpcount,
                            source.clinicalfocusminbucketscalculated,
                            source.providerdcpcount,
                            source.averagebpercentile,
                            source.providerdcpfillpercent,
                            source.isproviderdcpcountoverlowthreshold,
                            source.clinicalfocusscore,
                            source.providerclinicalfocusrank,
                            source.sourcecode,
                            source.lastupdatedate
                        )
                        $$;


--- update statement
update_statement := $$ update
                        set
                            target.ClinicalFocusDCPCount = source.clinicalfocusdcpcount,
                            target.ClinicalFocusMinBucketsCalculated = source.clinicalfocusminbucketscalculated,
                            target.ProviderDCPCount = source.providerdcpcount,
                            target.AverageBPercentile = source.averagebpercentile,
                            target.ProviderDCPFillPercent = source.providerdcpfillpercent,
                            target.IsProviderDCPCountOverLowThreshold = source.isproviderdcpcountoverlowthreshold,
                            target.ClinicalFocusScore = source.clinicalfocusscore,
                            target.ProviderClinicalFocusRank = source.providerclinicalfocusrank,
                            target.SourceCode = source.sourcecode,
                            target.InsertedOn = source.lastupdatedate $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := $$
                merge into base.providertoclinicalfocus as target
                using ($$||select_statement||$$) as source
                on source.providerid = target.providerid and source.clinicalfocusid = target.clinicalfocusid
                when matched then $$ || update_statement || $$
                when not matched  then $$||insert_statement
                ;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToClinicalFocus;
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
