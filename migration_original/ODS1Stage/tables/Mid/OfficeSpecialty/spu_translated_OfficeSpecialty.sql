CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_OFFICESPECIALTY(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
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
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_officespecialty');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin
--- select Statement
select_statement := $$ 
                    with CTE_OfficeBatch as (
                        select distinct pto.officeid
                        from $$ || mdm_db || $$.mst.Provider_Profile_Processing as pdp 
                        join base.provider as P on p.providercode = pdp.ref_provider_code
                        join base.providertooffice as pto on pto.providerid = p.providerid
                        order by pto.officeid
                    )
                    
                    select 
                        etmt.entitytomedicaltermid as OfficeToSpecialtyID, 
                        etmt.entityid as OfficeID, 
                        mt.medicaltermcode as SpecialtyCode, 
                        mt.medicaltermdescription1 as Specialty, 
                        mt.medicaltermdescription2 as Specialist, 
                        mt.medicaltermdescription3 as Specialists, 
                        mt.legacykey as LegacyKey
                    from CTE_OfficeBatch as cte
                        join base.entitytomedicalterm etmt on etmt.entityid = cte.officeid
                        join base.medicalterm mt on etmt.medicaltermid = mt.medicaltermid
                        join base.medicaltermtype mtt on mt.medicaltermtypeid = mtt.medicaltermtypeid and mtt.medicaltermtypecode = 'Specialty'
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
                   when matched then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.OfficeSpecialty;
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

            return status;
end;