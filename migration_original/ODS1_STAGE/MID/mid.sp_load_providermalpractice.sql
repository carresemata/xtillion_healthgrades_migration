CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDERMALPRACTICE(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- mid.providermalpractice depends on: 
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.providermalpractice
--- base.malpracticeclaimtype
--- base.malpracticestate
--- base.state

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providermalpractice');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin

--- select Statement

select_statement := $$ with CTE_ProviderBatch as (
                        select
                            p.providerid
                        from
                            $$ || mdm_db || $$.mst.Provider_Profile_Processing as ppp
                            join base.provider as P on p.providercode = ppp.ref_provider_code)
                        select
                            distinct pm.providermalpracticeid,
                            pm.providerid,
                            mct.malpracticeclaimtypecode,
                            mct.malpracticeclaimtypedescription,
                            pm.claimnumber,
                            pm.claimdate,
                            pm.claimyear,
                            CASE
                                WHEN pm.claimamount is not null then CAST(pm.claimamount as varchar(50))
                                else pm.malpracticeclaimrange
                            END as ClaimAmount,
                            pm.complaint,
                            pm.incidentdate,
                            pm.closeddate,
                            pm.claimstate,
                            st.statename as ClaimStateFull,
                            pm.licensenumber,
                            pm.reportdate
                        from
                            CTE_ProviderBatch as pb
                            join base.providermalpractice as pm on pm.providerid = pb.providerid
                            join base.malpracticeclaimtype as mct on pm.malpracticeclaimtypeid = mct.malpracticeclaimtypeid
                            join base.malpracticestate as ms on pm.claimstate = ms.state
                            and ifnull(ms.active, 1) = 1
                            left join base.state as st on pm.claimstate = st.state $$;

--- update Statement
update_statement := ' update 
                     SET 
                        ProviderMalpracticeID = source.providermalpracticeid,
                        ProviderID = source.providerid,
                        MalpracticeClaimTypeCode = source.malpracticeclaimtypecode,
                        MalpracticeClaimTypeDescription = source.malpracticeclaimtypedescription,
                        ClaimNumber = source.claimnumber,
                        ClaimDate = source.claimdate,
                        ClaimYear = source.claimyear,
                        ClaimAmount = source.claimamount,
                        Complaint = source.complaint,
                        IncidentDate = source.incidentdate,
                        ClosedDate = source.closeddate,
                        ClaimState = source.claimstate,
                        ClaimStateFull = source.claimstatefull,
                        LicenseNumber = source.licensenumber,
                        ReportDate = source.reportdate';

--- insert Statement
insert_statement := ' insert  (
                        ProviderMalpracticeID,
                        ProviderID,
                        MalpracticeClaimTypeCode,
                        MalpracticeClaimTypeDescription,
                        ClaimNumber,
                        ClaimDate,
                        ClaimYear,
                        ClaimAmount,
                        Complaint,
                        IncidentDate,
                        ClosedDate,
                        ClaimState,
                        ClaimStateFull,
                        LicenseNumber,
                        ReportDate)
                      values (
                        source.providermalpracticeid,
                        source.providerid,
                        source.malpracticeclaimtypecode,
                        source.malpracticeclaimtypedescription,
                        source.claimnumber,
                        source.claimdate,
                        source.claimyear,
                        source.claimamount,
                        source.complaint,
                        source.incidentdate,
                        source.closeddate,
                        source.claimstate,
                        source.claimstatefull,
                        source.licensenumber,
                        source.reportdate)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.providermalpractice as target using 
                   ('||select_statement||') as source 
                   on source.providermalpracticeid = target.providermalpracticeid
                   when matched then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.ProviderMalpractice;
end if; 
execute immediate merge_statement ;

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

            raise;
end;