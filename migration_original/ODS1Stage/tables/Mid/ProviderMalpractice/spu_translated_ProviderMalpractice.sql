CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDERMALPRACTICE(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
    
-- mid.providermalpractice depends on: 
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.providermalpractice
--- base.malpracticeclaimtype
--- base.malpracticestate
--- base.state

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providermalpractice');
    execution_start datetime default getdate();

   
---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------   
   
begin
    if (IsProviderDeltaProcessing) then
           select_statement := '
          with CTE_ProviderBatch as (
                select
                    p.providerid
                from
                    MDM_team.mst.Provider_Profile_Processing as ppp
                    join base.provider as P on p.providercode = ppp.ref_provider_code),';
    else
           select_statement := '
           with CTE_ProviderBatch as (
                select
                    p.providerid
                from
                    base.provider as p
                order by
                    p.providerid),';
            
    end if;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement

-- if conditionals:
select_statement := select_statement || 
                    $$ CTE_ProviderMalpractice as (
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
                                pm.reportdate,
                                0 as ActionCode
                            from
                                CTE_ProviderBatch as pb
                                join base.providermalpractice as pm on pm.providerid = pb.providerid
                                join base.malpracticeclaimtype as mct on pm.malpracticeclaimtypeid = mct.malpracticeclaimtypeid
                                join base.malpracticestate as ms on pm.claimstate = ms.state
                                and ifnull(ms.active, 1) = 1
                                left join base.state as st on pm.claimstate = st.state
                        ),
                        -- insert Action
                        CTE_Action_1 as (
                            select
                                cte.providermalpracticeid,
                                1 as ActionCode
                            from
                                CTE_ProviderMalpractice as cte
                                left join mid.providermalpractice as mid on cte.providermalpracticeid = mid.providermalpracticeid
                            where
                                mid.providermalpracticeid is null
                        ),
                        -- update Action
                        CTE_Action_2 as (
                            select
                                cte.providermalpracticeid,
                                2 as ActionCode
                            from
                                CTE_ProviderMalpractice as cte
                                join mid.providermalpractice as mid on cte.providermalpracticeid = mid.providermalpracticeid
                            where
                                MD5(ifnull(cte.providerid::varchar, '')) <> MD5(ifnull(mid.providerid::varchar, ''))
                                or MD5(ifnull(cte.malpracticeclaimtypecode::varchar, '')) <> MD5(ifnull(mid.malpracticeclaimtypecode::varchar, ''))
                                or MD5(ifnull(cte.malpracticeclaimtypedescription::varchar, '')) <> MD5(ifnull(mid.malpracticeclaimtypedescription::varchar, ''))
                                or MD5(ifnull(cte.claimnumber::varchar, '')) <> MD5(ifnull(mid.claimnumber::varchar, ''))
                                or MD5(ifnull(cte.claimdate::varchar, '')) <> MD5(ifnull(mid.claimdate::varchar, ''))
                                or MD5(ifnull(cte.claimyear::varchar, '')) <> MD5(ifnull(mid.claimyear::varchar, ''))
                                or MD5(ifnull(cte.claimamount::varchar, '')) <> MD5(ifnull(mid.claimamount::varchar, ''))
                                or MD5(ifnull(cte.complaint::varchar, '')) <> MD5(ifnull(mid.complaint::varchar, ''))
                                or MD5(ifnull(cte.incidentdate::varchar, '')) <> MD5(ifnull(mid.incidentdate::varchar, ''))
                                or MD5(ifnull(cte.closeddate::varchar, '')) <> MD5(ifnull(mid.closeddate::varchar, ''))
                                or MD5(ifnull(cte.claimstate::varchar, '')) <> MD5(ifnull(mid.claimstate::varchar, ''))
                                or MD5(ifnull(cte.claimstatefull::varchar, '')) <> MD5(ifnull(mid.claimstatefull::varchar, ''))
                                or MD5(ifnull(cte.licensenumber::varchar, '')) <> MD5(ifnull(mid.licensenumber::varchar, ''))
                                or MD5(ifnull(cte.reportdate::varchar, '')) <> MD5(ifnull(mid.reportdate::varchar, ''))
                        )
                        select
                            distinct A0.ProviderMalpracticeID,
                            A0.ProviderID,
                            A0.MalpracticeClaimTypeCode,
                            A0.MalpracticeClaimTypeDescription,
                            A0.ClaimNumber,
                            A0.ClaimDate,
                            A0.ClaimYear,
                            A0.ClaimAmount,
                            A0.Complaint,
                            A0.IncidentDate,
                            A0.ClosedDate,
                            A0.ClaimState,
                            A0.ClaimStateFull,
                            A0.LicenseNumber,
                            A0.ReportDate,
                            ifnull(
                                A1.ActionCode,
                                ifnull(A2.ActionCode, A0.ActionCode)
                            ) as ActionCode
                        from
                            CTE_ProviderMalpractice as A0
                            left join CTE_Action_1 as A1 on A0.ProviderMalpracticeID = A1.ProviderMalpracticeID
                            left join CTE_Action_2 as A2 on A0.ProviderMalpracticeID = A2.ProviderMalpracticeID
                        where
                            ifnull(
                                A1.ActionCode,
                                ifnull(A2.ActionCode, A0.ActionCode)
                            ) <> 0 $$;

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
                   WHEN MATCHED and source.actioncode = 2 then '||update_statement|| '
                   when not matched and source.actioncode = 1 then '||insert_statement;
                   
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 
                    
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

            return status;
end;