CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDERSPECIALTYFACILITYSERVICELINERATING(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

-- mid.providerspecialtyfacilityservicelinerating depends on:
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.providertofacility
--- base.facility
--- base.providertospecialty
--- base.specialtygrouptospecialty
--- base.specialtygroup
--- base.tempspecialtytoservicelineghetto
--- ermart1.facility_facilitytoservicelinerating (external dependency)
--- ermart1.facility_serviceline (external dependency)
--- ermart1.facility_facilitytoprocedurerating (external dependency)
--- ermart1.facility_proceduretoserviceline (external dependency)

---------------------------------------------------------
--------------- 2. Declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providerspecialtyfacilityservicelinerating');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement

begin
select_statement := $$ with CTE_ProviderBatch as (
                select
                    p.providerid
                from
                    $$ || mdm_db || $$.mst.Provider_Profile_Processing as ppp
                    join base.provider as P on p.providercode = ppp.ref_provider_code),
                cte_union as (
                select
                    fsl.facilityid,
                    fsl.servicelineid,
                    sl.servicelinedescription,
                    fsl.survivalstar as servicelinestar
                from
                    ermart1.facility_facilitytoservicelinerating as fsl
                    join ermart1.facility_serviceline as sl on fsl.servicelineid = sl.servicelineid
                where
                    fsl.ismaxyear = 1
                union all
                select
                    fpr.facilityid,
                    sl.servicelineid,
                    sl.servicelinedescription,
                    fpr.overallsurvivalstar as servicelinestar
                from
                    ermart1.facility_facilitytoprocedurerating as fpr
                    join ermart1.facility_proceduretoserviceline as psl on fpr.procedureid = psl.procedureid
                    join ermart1.facility_serviceline as sl on psl.servicelineid = sl.servicelineid
                where
                    fpr.ismaxyear = 1
                    and fpr.procedureid = 'ob1')
                select distinct 
                    pb.providerid, 
                    tstslg.servicelinecode, 
                    e.servicelinestar, 
                    e.servicelinedescription, 
                    sg.legacykey, 
                    tstslg.specialtyid, 
                    tstslg.specialtycode
                from cte_providerbatch as pb
                    inner join base.providertofacility as pf on pf.providerid = pb.providerid
                    join base.facility as b on pf.facilityid = b.facilityid
                    join base.providertospecialty as ps on pf.providerid = ps.providerid
                    join base.specialtygrouptospecialty as sgs on sgs.specialtyid = ps.specialtyid
                    join base.specialtygroup as sg on sg.specialtygroupid = sgs.specialtygroupid
                    join base.tempspecialtytoservicelineghetto as tstslg on sg.specialtygroupcode = tstslg.specialtycode
                    join cte_union as e on b.legacykey = e.facilityid and tstslg.servicelinecode = 'SL' || e.servicelineid
                order by pb.providerid
                 $$;

--- Update Statement
update_statement := ' update 
                     set
                        target.servicelinedescription = source.servicelinedescription,
                        target.legacykey = source.legacykey,
                        target.specialtyid = source.specialtyid';

--- Insert Statement
insert_statement := ' insert  (
                        providerid, 
                        servicelinecode, 
                        servicelinestar, 
                        servicelinedescription, 
                        legacykey, 
                        specialtyid, 
                        specialtycode)
                      values (
                        source.providerid,
                        source.servicelinecode,
                        source.servicelinestar,
                        source.servicelinedescription,
                        source.legacykey,
                        source.specialtyid,
                        source.specialtycode)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.providerspecialtyfacilityservicelinerating as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid 
                    and source.specialtycode = target.specialtycode 
                    and source.servicelinecode = target.servicelinecode 
                    and source.servicelinestar = target.servicelinestar
                   when matched then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
        
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.ProviderSpecialtyFacilityServiceLineRating;
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

            raise;
end;