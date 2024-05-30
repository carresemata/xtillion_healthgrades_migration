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
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.clinicalfocus

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertoclinicalfocus');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ 
select distinct 
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

from raw.vw_PROVIDER_PROFILE as JSON
    join base.provider as P on json.providercode = p.providercode
    join base.clinicalfocus as CF on json.clinicalfocus_ClinicalFocusCode = cf.clinicalfocuscode

where json.provider_PROFILE is not null
  and json.clinicalfocus_ClinicalFocusCode is not null
qualify row_number() over(partition by p.providercode, ClinicalFocus_ClinicalFocusCode order by ProviderId desc) = 1
$$
;

--- insert Statement
insert_statement := $$ 
insert 
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
    uuid_string(),
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
$$
;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := $$
                merge into base.providertoclinicalfocus as target
                using ($$||select_statement||$$) as source
                on source.providerid = target.providerid and source.clinicalfocusid = target.clinicalfocusid
                WHEN MATCHED then delete
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