CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERMALPRACTICE(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  

declare 

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.providermalpractice depends on:
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.malpracticeclaimtype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
merge_statement string;
status string;
procedure_name varchar(50) default('sp_load_providermalpractice');
execution_start datetime default getdate();
mdm_db string default('mdm_team');



begin


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- select Statement
select_statement := $$  with Cte_malpractice as (
    SELECT
        p.ref_provider_code as providercode,
        p.created_datetime as CREATE_DATE,
        to_varchar(json.value:MALPRACTICE_CLAIM_TYPE_CODE) as Malpractice_MalpracticeClaimTypeCode,
        to_varchar(json.value:CLAIM_NUMBER) as Malpractice_ClaimNumber,
        to_varchar(json.value:CLAIM_DATE) as Malpractice_ClaimDate,
        to_varchar(json.value:CLAIM_YEAR) as Malpractice_ClaimYear,
        to_varchar(json.value:CLAIM_AMOUNT) as Malpractice_ClaimAmount,
        to_varchar(json.value:CLAIM_STATE) as Malpractice_ClaimState,
        to_varchar(json.value:MALPRACTICE_CLAIM_RANGE) as Malpractice_MalpracticeClaimRange,
        to_varchar(json.value:COMPLAINT) as Malpractice_Complaint,
        to_varchar(json.value:INCIDENT_DATE) as Malpractice_IncidentDate,
        to_varchar(json.value:CLOSED_DATE) as Malpractice_ClosedDate,
        to_varchar(json.value:REPORT_DATE) as Malpractice_ReportDate,
        to_varchar(json.value:LICENSE_NUMBER) as Malpractice_LicenseNumber,
        to_varchar(json.value:DATA_SOURCE_CODE) as Malpractice_SourceCode,
        to_timestamp_ntz(json.value:UPDATED_DATETIME) as Malpractice_LastUpdateDate
    FROM $$||mdm_db||$$.mst.provider_profile_processing as p
    , lateral flatten(input => p.PROVIDER_PROFILE:MALPRACTICE) as json
),
CTE_Swimlane as (select
    p.providerid,
    -- pl.providerlicenseid,
    m.malpracticeclaimtypeid,
    json.providercode,
    json.malpractice_MALPRACTICECLAIMTYPECODE as MalpracticeClaimTypeCode,
    json.malpractice_CLAIMNUMBER as ClaimNumber,
    json.malpractice_CLAIMDATE as ClaimDate,
    json.malpractice_CLAIMYEAR as ClaimYear,
    TO_NUMBER(json.malpractice_CLAIMAMOUNT) as ClaimAmount,
    json.malpractice_CLAIMSTATE as ClaimState,
    json.malpractice_MALPRACTICECLAIMRANGE as MalpracticeClaimRange,
    json.malpractice_COMPLAINT as Complaint,
    json.malpractice_INCIDENTDATE as IncidentDate,
    json.malpractice_CLOSEDDATE as ClosedDate,
    json.malpractice_REPORTDATE as ReportDate,
    json.malpractice_SOURCECODE as SourceCode,
    json.malpractice_LICENSENUMBER as LicenseNumber,
    json.malpractice_LASTUPDATEDATE as LastUpdateDate,
    row_number() over(partition by p.providerid, json.malpractice_MALPRACTICECLAIMTYPECODE, json.malpractice_CLAIMDATE, json.malpractice_CLAIMYEAR, json.malpractice_CLAIMSTATE, json.malpractice_LICENSENUMBER, json.malpractice_MALPRACTICECLAIMRANGE order by CREATE_DATE desc, TO_NUMBER(json.malpractice_CLAIMAMOUNT) desc) as RowRank, 
	row_number()over(order by p.providerid) as RN1
from
    Cte_malpractice as JSON
    left join base.provider as P on json.providercode = p.providercode
    -- left join base.providerlicense as PL on pl.providerid = p.providerid and pl.licensenumber = json.malpractice_LICENSENUMBER
    left join base.malpracticeclaimtype as M on m.malpracticeclaimtypecode = json.malpractice_MALPRACTICECLAIMTYPECODE
where json.malpractice_CLAIMAMOUNT is not null
    ),
    
CTE_BadMalpracticeClaimTypeCode as (
    select distinct 
        p.providercode, 
        'Bad Malpractice Claim Type Code value of ' || COALESCE(s.malpracticeclaimtypecode,'null') as ProblemType, 
        RN1
    from CTE_swimlane S
    join base.provider P on p.providerid = s.providerid
    left join base.malpracticeclaimtype MCT on mct.malpracticeclaimtypecode = s.malpracticeclaimtypecode
    where mct.malpracticeclaimtypeid is null
    
            union all
    
    select distinct 
        p.providercode, 
        'Bad Malpractice Claim Type Code value of ' || COALESCE(s.malpracticeclaimtypecode,'null') as ProblemType, 
        RN1
    from CTE_swimlane S
    join base.provider P on p.providerid = s.providerid
    left join base.malpracticeclaimtype MCT on mct.malpracticeclaimtypeid = s.malpracticeclaimtypeid
    where mct.malpracticeclaimtypeid is null	
    
            union all
    
    select 
        s.providercode, 
        'Bad IncidentDate value: ' || to_varchar(IncidentDate), 
        RN1
    from CTE_swimlane S
    where TRY_CAST(IncidentDate as DATE) is null and IncidentDate is not null
    
            union all
    
    select 
        s.providercode, 
        'Bad ReportDate value: ' || to_varchar(ReportDate), 
        RN1
    from CTE_swimlane S
    where TRY_CAST(ReportDate as DATE) is null and ReportDate is not null
    
            union all
    
    select 
        s.providercode, 
        'Bad ClaimDate value: ' || to_varchar(ClaimDate), 
        RN1
    from CTE_swimlane S
    where TRY_CAST(ClaimDate as DATE) is null and ClaimDate is not null
    
            union all
    
    select 
        s.providercode, 
        'Bad ClosedDate value: ' || to_varchar(ClosedDate), 
        RN1
    from CTE_swimlane S
    where TRY_CAST(ClosedDate as DATE) is null and ClosedDate is not null
    
            union all
    
    select 
        s.providercode, 
        'Bad ClaimYear value: ' || to_varchar(ClaimYear),
        RN1
    from CTE_swimlane S
    where TRY_CAST(ClaimYear as INT) is null and ClaimYear is not null
),
CTE_KEEP as (
    select 
        s.providerid,
        --s.providerlicenseid,
        s.malpracticeclaimtypeid,
        s.providercode,
        s.malpracticeclaimtypecode,
        s.claimnumber,
        s.claimdate,
        s.claimyear,
        s.claimamount,
        s.claimstate,
        s.malpracticeclaimrange,
        s.complaint,
        s.incidentdate,
        s.closeddate,
        s.reportdate,
        s.sourcecode,
        s.licensenumber,
        s.lastupdatedate,
        s.rowrank, 
        s.rn1
    from CTE_swimlane as S
    where (
        (
            COALESCE(TRY_CAST(s.incidentdate as DATE), '1900-01-01'::DATE) > DATEADD('YEAR', -5, CURRENT_DATE()) or 
            COALESCE(TRY_CAST(s.reportdate as DATE), '1900-01-01'::DATE) > DATEADD('YEAR', -5, CURRENT_DATE()) or 
            COALESCE(TRY_CAST(s.claimdate as DATE), '1900-01-01'::DATE) > DATEADD('YEAR', -5, CURRENT_DATE()) or 
            COALESCE(TRY_CAST(s.closeddate as DATE), '1900-01-01'::DATE) > DATEADD('YEAR', -5, CURRENT_DATE())
        )
        or (
            s.incidentdate is null and 
            s.reportdate is null and 
            s.claimdate is null and 
            s.closeddate is null and 
            s.claimyear is not null and 
            TRY_CAST(s.claimyear as INT) > EXTRACT(YEAR from DATEADD('YEAR', -5, CURRENT_DATE()))))), 
CTE_Delete1 as (
    select 
        ProviderId,
        --ProviderLicenseId,
        MalpracticeClaimTypeID,
        ProviderCode,
        MalpracticeClaimTypeCode,
        ClaimNumber,
        ClaimDate,
        ClaimYear,
        ClaimAmount,
        ClaimState,
        MalpracticeClaimRange,
        Complaint,
        IncidentDate,
        ClosedDate,
        ReportDate,
        SourceCode,
        LicenseNumber,
        LastUpdateDate,
        RowRank,
        RN1
    from CTE_Swimlane
    where RN1 IN (select RN1 from CTE_KEEP))
select 
    ProviderId,
    --ProviderLicenseId,
    MalpracticeClaimTypeID,
    ProviderCode,
    MalpracticeClaimTypeCode,
    ClaimNumber,
    ClaimDate,
    ClaimYear,
    ClaimAmount,
    ClaimState,
    MalpracticeClaimRange,
    Complaint,
    IncidentDate,
    ClosedDate,
    ReportDate,
    SourceCode,
    LicenseNumber,
    LastUpdateDate,
    RowRank,
    RN1
from CTE_Delete1 as D
 $$;


    -- insert Statement
insert_statement := ' insert  
                            (ProviderMalpracticeID,
                            ProviderID,
                            --ProviderLicenseID,
                            MalpracticeClaimTypeID,
                            ClaimNumber,
                            ClaimDate,
                            ClaimYear,
                            ClaimAmount,
                            ClaimState,
                            MalpracticeClaimRange,
                            Complaint,
                            IncidentDate,
                            ClosedDate,
                            ReportDate,
                            SourceCode,
                            LicenseNumber,
                            LastUpdateDate)
                    values 
                          ( uuid_string(),
                            source.providerid,
                            --source.providerlicenseid,
                            source.malpracticeclaimtypeid,
                            source.claimnumber,
                            source.claimdate,
                            source.claimyear,
                            source.claimamount,
                            source.claimstate,
                            source.malpracticeclaimrange,
                            source.complaint,
                            source.incidentdate,
                            source.closeddate,
                            source.reportdate,
                            source.sourcecode,
                            source.licensenumber,
                            source.lastupdatedate)';



---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------

merge_statement := ' merge into base.providermalpractice as target 
using ('||select_statement||') as source
on source.providerid = target.providerid and source.malpracticeclaimtypeid = target.malpracticeclaimtypeid --and source.providerlicenseid = target.providerlicenseid
WHEN MATCHED then delete 
when not matched then'||insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderMalpractice;
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
