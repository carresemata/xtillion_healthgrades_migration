CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDERRECOGNITION(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
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
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providerrecognition');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin

select_statement := $$ with CTE_ProviderBatch as (
                        select
                            p.providerid
                        from
                            $$ || mdm_db || $$.mst.Provider_Profile_Processing as ppp
                            join base.provider as P on p.providercode = ppp.ref_provider_code)
                        select distinct
                            vwpr.providerid, 
                            a.awardcode as RecognitionCode, 
                            a.awarddisplayname as RecognitionDisplayName, 
                            null as ServiceLine, 
                            null as FacilityCode, 
                            null as FacilityName
                        from CTE_ProviderBatch as pb  
                            inner join base.vwuproviderrecognition vwpr on vwpr.providerid = pb.providerid
                            inner join base.award a on vwpr.awardid = a.awardid
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
                   merge into mid.providerrecognition as target using 
                   ($$|| select_statement ||$$) as source on source.providerid = target.providerid
                   when matched then $$|| update_statement ||$$
                   when not matched then $$ || insert_statement;

                
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.ProviderRecognition;
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