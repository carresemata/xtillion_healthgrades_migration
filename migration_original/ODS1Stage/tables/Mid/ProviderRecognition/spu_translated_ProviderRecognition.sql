CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDERRECOGNITION(IsProviderDeltaProcessing BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------

    -- mid.providerrecognition depends on:
    -- mdm_team.mst.provider_profile_processing
    -- base.provider
    -- base.award
    --- Base.ProviderSanction (base.vwuproviderrecognition)
    --- Base.SanctionAction (base.vwuproviderrecognition)
    --- Base.ProviderMalpractice (base.vwuproviderrecognition)
    --- Base.ProviderToCertificationSpecialty (base.vwuproviderrecognition)
    --- Base.CertificationStatus (base.vwuproviderrecognition)

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providerrecognition');
    execution_start datetime default getdate();

   
---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------   
   
begin
    if (IsProviderDeltaProcessing) then
       select_statement := $$
       with CTE_ProviderBatch as (
             select
                    p.providerid
                from
                    mdm_team.mst.Provider_Profile_Processing as ppp
                    join base.provider as P on p.providercode = ppp.ref_provider_code),$$;
    else
       select_statement := $$
       with CTE_ProviderBatch as (
            select p.providerid
            from base.provider as p
            order by p.providerid),$$;
    end if;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

select_statement := select_statement || 
                    $$
                    CTE_ProviderRecognition as (
                        select distinct
                        vwpr.providerid, 
                        a.awardcode as RecognitionCode, 
                        a.awarddisplayname as RecognitionDisplayName, 
                        null as ServiceLine, 
                        null as FacilityCode, 
                        null as FacilityName,
                        0 as ActionCode
                    from CTE_ProviderBatch as pb  
                    inner join base.vwuproviderrecognition vwpr on vwpr.providerid = pb.providerid
                    inner join base.award a on (vwpr.awardid = a.awardid)
                    ),

                    -- insert Action
                    CTE_Action_1 as (
                        select 
                            cte.providerid,
                            cte.recognitioncode,
                            cte.serviceline,
                            cte.facilitycode,
                            1 as ActionCode
                    from CTE_ProviderRecognition as cte
                    left join mid.providerrecognition as mid 
                    on (cte.providerid = mid.providerid and cte.recognitioncode = mid.recognitioncode 
                        and cte.serviceline = mid.serviceline and cte.facilitycode = mid.facilitycode)
                    where mid.providerid is null),

                    
                    -- update Action
                    CTE_Action_2 as (
                        select 
                            cte.providerid,
                            2 as ActionCode
                        from CTE_ProviderRecognition as cte
                        join mid.providerrecognition as mid 
                        on (cte.providerid = mid.providerid and cte.recognitioncode = mid.recognitioncode 
                            and cte.serviceline = mid.serviceline and cte.facilitycode = mid.facilitycode)
                        where 
                            MD5(ifnull(cte.providerid::varchar,'''')) <> MD5(ifnull(mid.providerid::varchar,'''')) or 
                            MD5(ifnull(cte.recognitioncode::varchar,'''')) <> MD5(ifnull(mid.recognitioncode::varchar,'''')) or 
                            MD5(ifnull(cte.serviceline::varchar,'''')) <> MD5(ifnull(mid.serviceline::varchar,'''')) or 
                            MD5(ifnull(cte.facilitycode::varchar,'''')) <> MD5(ifnull(mid.facilitycode::varchar,'''')) or
                            MD5(ifnull(cte.facilityname::varchar,'''')) <> MD5(ifnull(mid.facilityname::varchar,''''))
                     )
                     
                    select distinct
                        A0.ProviderID, 
                        A0.RecognitionCode, 
                        A0.RecognitionDisplayName, 
                        A0.ServiceLine,
                        A0.FacilityCode, 
                        A0.FacilityName, 
                        ifnull(A1.ActionCode,ifnull(A2.ActionCode, A0.ActionCode)) as ActionCode 
                    from CTE_ProviderRecognition as A0 
                    left join CTE_Action_1 as A1 on A0.ProviderID = A1.ProviderID
                    left join CTE_Action_2 as A2 on A0.ProviderID = A2.ProviderID
                    where ifnull(A1.ActionCode,ifnull(A2.ActionCode, A0.ActionCode)) <> 0 
                    $$;
                        


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------

update_statement := $$
                     update SET 
                        target.providerid = source.providerid,
                        target.recognitioncode = source.recognitioncode,
                        target.recognitiondisplayname = source.recognitiondisplayname,
                        target.serviceline = source.serviceline,
                        target.facilitycode = source.facilitycode,
                        target.facilityname = source.facilityname
                      $$;


--- insert Statement
insert_statement :=   $$
                      insert  (
                               ProviderID,
                               RecognitionCode,
                               RecognitionDisplayName,
                               ServiceLine,
                               FacilityCode,
                               FacilityName
                               )
                      values  (
                               source.providerid,
                               source.recognitioncode,
                               source.recognitiondisplayname,
                               source.serviceline,
                               source.facilitycode,
                               source.facilityname
                               )
                       $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := $$
                   merge into mid.providerrecognition as target using ($$|| select_statement ||$$) as source 
                   on source.providerid = target.providerid
                   WHEN MATCHED and source.actioncode = 2 then $$|| update_statement ||$$
                   WHEN MATCHED and target.providerid = source.providerid 
                        and target.recognitioncode = source.recognitioncode 
                        and ifnull(target.serviceline, '''') = ifnull(source.serviceline, '''') 
                        and ifnull(target.facilitycode, '''') = ifnull(source.facilitycode, '''') 
                        and source.providerid is null then delete
                   when not matched and source.actioncode = 1 then $$ || insert_statement;

                
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 
                    
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