CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_OFFICESPECIALTY(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
    
-- mid.officespecialty depends on: 
--- mdm_team.mst.provider_profile_processing
--- base.providertooffice
--- base.office
--- base.entitytomedicalterm 
--- base.medicalterm
--- base.medicaltermtype
--- base.provider

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_officespecialty');
    execution_start datetime default getdate();

   
---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------   
   
begin
    if (IsProviderDeltaProcessing) then
           select_statement := '
            with CTE_OfficeBatch as (select distinct pto.officeid
            from MDM_team.mst.Provider_Profile_Processing as pdp 
            join base.provider as P on p.providercode = pdp.ref_provider_code
            join base.providertooffice as pto on pto.providerid = p.providerid
            order by pto.officeid),
           ';
    else
           select_statement := '
           with CTE_OfficeBatch as (
           select distinct o.officeid 
           from base.office as o 
           order by o.officeid),
          ';
    end if;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := select_statement || 
                    $$ 
                    CTE_OfficeSpecialty as (
                        select 
                            etmt.entitytomedicaltermid as OfficeToSpecialtyID, 
                            etmt.entityid as OfficeID, 
                            mt.medicaltermcode as SpecialtyCode, 
                            mt.medicaltermdescription1 as Specialty, 
                            mt.medicaltermdescription2 as Specialist, 
                            mt.medicaltermdescription3 as Specialists, 
                            mt.legacykey as LegacyKey,
                            0 as ActionCode
                    		
                        from CTE_OfficeBatch as cte
                            join base.entitytomedicalterm etmt on etmt.entityid = cte.officeid
                            join base.medicalterm mt on etmt.medicaltermid = mt.medicaltermid
                    		join base.medicaltermtype mtt on mt.medicaltermtypeid = mtt.medicaltermtypeid and mtt.medicaltermtypecode = 'Specialty'
                    
                    ),
                    -- insert Action
                    CTE_Action_1 as (
                        select 
                            cte.officetospecialtyid,
                            1 as ActionCode
                        from CTE_OfficeSpecialty as cte
                        join mid.officespecialty as mid on cte.officetospecialtyid = mid.officetospecialtyid 
                        where cte.officetospecialtyid is null
                    ),
                    -- update Action
                    CTE_Action_2 as (
                        select
                            cte.officetospecialtyid,
                            2 as ActionCode
                        from CTE_OfficeSpecialty as cte
                        join mid.officespecialty as mid on cte.officetospecialtyid = mid.officetospecialtyid 
                        where
                            MD5(ifnull(cte.officeid::varchar,''))<>           MD5(ifnull(mid.officeid::varchar,'')) or
                            MD5(ifnull(cte.specialtycode::varchar,''))<>      MD5(ifnull(mid.specialtycode::varchar,'')) or
                            MD5(ifnull(cte.specialty::varchar,''))<>          MD5(ifnull(mid.specialty::varchar,'')) or
                            MD5(ifnull(cte.specialist::varchar,''))<>         MD5(ifnull(mid.specialist::varchar,'')) or
                            MD5(ifnull(cte.specialists::varchar,''))<>        MD5(ifnull(mid.specialists::varchar,'')) or
                            MD5(ifnull(cte.legacykey::varchar,''))<>          MD5(ifnull(mid.legacykey::varchar,'')) 
                    )
                    select distinct
                        A0.OfficeToSpecialtyId,
                        A0.OfficeId,
                        A0.SpecialtyCode,
                        A0.Specialty,
                        A0.Specialist,
                        A0.Specialists,
                        A0.LegacyKey,
                        ifnull(A1.ActionCode,ifnull(A2.ActionCode, A0.ActionCode)) as ActionCode
                    from CTE_OfficeSpecialty as A0
                    left join CTE_Action_1 as A1 on A0.OfficeToSpecialtyId = A1.OfficeToSpecialtyId
                    left join CTE_Action_2 as A2 on A0.OfficeToSpecialtyId = A2.OfficeToSpecialtyId
                    where ifnull(A1.ActionCode,ifnull(A2.ActionCode, A0.ActionCode)) <> 0
                    $$;

--- update Statement
update_statement := ' update 
                     SET 
                        OfficeToSpecialtyId = source.officetospecialtyid,
                        OfficeId = source.officeid,
                        SpecialtyCode = source.specialtycode,
                        Specialty = source.specialty,
                        Specialist = source.specialist,
                        Specialists = source.specialists,
                        LegacyKey = source.legacykey';

--- insert Statement
insert_statement := ' insert  
                        (OfficeToSpecialtyId,
                        OfficeId,
                        SpecialtyCode,
                        Specialty,
                        Specialist,
                        Specialists,
                        LegacyKey)
                      values 
                        (source.officetospecialtyid,
                        source.officeid,
                        source.specialtycode,
                        source.specialty,
                        source.specialist,
                        source.specialists,
                        source.legacykey)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.officespecialty as target using 
                   ('||select_statement||') as source 
                   on target.officetospecialtyid = source.officetospecialtyid 
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