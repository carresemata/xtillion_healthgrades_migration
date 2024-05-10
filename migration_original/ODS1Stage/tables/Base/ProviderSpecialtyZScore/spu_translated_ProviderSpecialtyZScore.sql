CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERSPECIALTYZSCORE()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
    
-- base.providerspecialtyzscore depends on:
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.providertospecialty
--- base.specialty
--- base.specialtytocondition
--- base.treatmentlevel
--- base.specialtytoproceduremedical
--- base.medicalterm
--- base.cohorttocondition
--- base.cohortprocedure
--- base.providertofacilitytomedicalterm
--- ermart1.facility_procedure
--- show.solrfacility

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and Select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    delete_statement string; 
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providerspecialtyzscore');
    execution_start datetime default getdate();
   
---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    -- no conditionals


---------------------------------------------------------
----------------- 3. sql statements ---------------------
---------------------------------------------------------     

--- Select Statement
select_statement := $$ with cte_providerzscore as (
    select
        distinct providerid
    from
        mdm_team.mst.provider_profile_processing as ppp 
        join base.provider as p on ppp.ref_provider_code = p.providercode 
),
cte_union as (
    select
        stc.specialtyid,
        stc.conditionid as medicaltermid,
        stc.treatmentlevelid
    from
        base.specialtytocondition stc
        join base.treatmentlevel tl on tl.treatmentlevelid = stc.treatmentlevelid
    where
        tl.ismarketview = 1
    union all
    select
        stp.specialtyid,
        stp.proceduremedicalid as medicaltermid,
        stp.treatmentlevelid
    from
        base.specialtytoproceduremedical stp
        join base.treatmentlevel tl on tl.treatmentlevelid = stp.treatmentlevelid
    where
        tl.ismarketview = 1),
        
cte_specialtydcp as (
    select
        cte.specialtyid,
        mt.refmedicaltermcode as dcpcode
    from cte_union as cte
    join base.medicalterm as mt on mt.medicaltermid = cte.medicaltermid
    join base.treatmentlevel as tl on tl.treatmentlevelid = cte.treatmentlevelid
    where mt.isclaimsbased = 1
),
cte_providerzscorespecialtytoeligbledcp as (
    select
        pts.providerid,
        pts.specialtyid,
        mt.medicaltermid,
        ctesp.dcpcode
    from
        cte_providerzscore as cteprov
        inner join base.providertospecialty as pts on pts.providerid = cteprov.providerid
        inner join base.specialty as s on s.specialtyid = pts.specialtyid
        inner join cte_specialtydcp as ctesp on ctesp.specialtyid = pts.specialtyid
        inner join base.medicalterm as mt on mt.refmedicaltermcode = ctesp.dcpcode
    where ifnull(mt.isscreening, 0) = 0
),
cte_ratinglist as (
    select distinct
        mt.refmedicaltermcode as dcpcode,
        ifnull(ifnull(cond.cohortcode, proc.cohortcode), 'N/A') as ratingcode,
        ifnull(ermartcond.procedureid, ermartproc.procedureid) as procedureid
    from base.medicalterm as mt
    left join base.cohorttocondition as cond on cond.conditionid = mt.medicaltermid
    left join base.cohorttoprocedure as proc on proc.proceduremedicalid = mt.medicaltermid
    left join ermart1.facility_procedure as ermartcond on ermartcond.procedureid = cond.cohortcode
    left join ermart1.facility_procedure as ermartproc on ermartproc.procedureid = proc.cohortcode
    where ifnull(ifnull(cond.cohortcode, proc.cohortcode), 'N/A') != 'N/A'
),
cte_facaward as (
    select distinct 
    sf.facilityid,
    xmlget(xmlget(x.value, 'proc'), 'pCd'):"$"::string as procedureid, -- ProcedureCode
    xmlget(xmlget(x.value, 'proc'), 'pNm'):"$"::string as proceduredescription, -- ProcedureName
    xmlget(xmlget(x.value, 'proc'), 'zScr'):"$"::float as procedurezscore,
    xmlget(xmlget(x.value, 'proc'), 'rStr'):"$"::int as overallsurvivalstar
from show.solrfacility sf,
     lateral flatten(input => parse_xml(sf.servicelinexml), path => 'svcLnL.svcLn') as z,
     lateral flatten(input => xmlget(z.value, 'procL'), path => 'proc') as x
where xmlget(xmlget(x.value, 'proc'), 'pCd'):"$"::string in (select distinct procedureid from cte_ratinglist)
),
cte_dcpfacilities as (
    select distinct 
        pfm.providerid,
        pfm.facilityid,
        mt.refmedicaltermcode as dcpcode,
        r.procedureid,
        r.ratingcode,
        fa.overallsurvivalstar,
        fa.procedurezscore,
        pfm.patientcount,
        pfm.patientcountisfew,
        pfm.patientcount * fa.procedurezscore as weightedzscore
    from base.providertofacilitytomedicalterm pfm
        inner join cte_providerzscore pz on pz.providerid = pfm.providerid
        inner join base.medicalterm mt on mt.medicaltermid = pfm.medicaltermid
        inner join cte_ratinglist r on r.dcpcode = mt.refmedicaltermcode
        inner join cte_facaward fa on fa.facilityid = pfm.facilityid and fa.procedureid = r.procedureid
    where pfm.patientcountisfew = 0
),
cte_providerzscorespecialtydcpratings as (
    select 
        dcp.providerid,
        pst.specialtyid,
        sum(dcp.weightedzscore) / sum(dcp.patientcount) as avgweightedzscore
    from cte_dcpfacilities dcp
        inner join cte_providerzscorespecialtytoeligbledcp pst on pst.providerid = dcp.providerid and pst.dcpcode = dcp.dcpcode
    where dcp.patientcountisfew = 0
    group by 
        dcp.providerid,
        pst.specialtyid
) $$;



--- Update Statement
update_statement := ' update 
                     set 
                        target.avgweightedzscore = source.avgweightedzscore';

--- Insert Statement
insert_statement := ' insert  (
                            providerspecialtyzscoreid,
                            providerid,
                            specialtyid,
                            avgweightedzscore)
                      values (
                            uuid_string(),
                            source.providerid,
                            source.specialtyid,
                            source.avgweightedzscore
                      )';

--- Delete Statement 
delete_statement := 'delete from base.providerspecialtyzscore
                        where providerid in (
                            select t.providerid
                            from base.providerspecialtyzscore as t
                            inner join ('|| select_statement || 'select * from cte_providerzscore ) as p on p.providerid = t.providerid
                            left join (' || select_statement || 'select * from cte_providerzscorespecialtydcpratings ) as s on s.providerid = t.providerid and s.specialtyid = t.specialtyid
                            where s.providerid is null
                        );';
                        
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providerspecialtyzscore  as target using 
                   ('||select_statement|| ' select * from cte_providerzscorespecialtydcpratings) as source 
                   on source.providerid = target.providerid and source.specialtyid = target.specialtyid
                   when matched and cast(source.avgweightedzscore as numeric(10,5)) != target.avgweightedzscore then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 

execute immediate delete_statement ;                     
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