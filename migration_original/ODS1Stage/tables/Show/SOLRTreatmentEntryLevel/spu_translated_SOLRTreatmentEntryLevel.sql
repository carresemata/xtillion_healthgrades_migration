
-- 1. spuSOLRTreatmentEntryLevel (validated in snowflake)
CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRTREATMENTENTRYLEVEL() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  

declare

---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
    
-- show.solrtreatmententrylevel depends on :
--- base.specialtytocondition
--- base.treatmentlevel
--- base.specialtytoproceduremedical
--- base.specialty
--- base.medicalterm
    

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte statement
    insert_statement string; -- insert statement to final table
    merge_statement string; -- merge statement
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrtreatmententrylevel');
    execution_start datetime default getdate();

   
---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------   

begin
-- No conditionals


---------------------------------------------------------
--------------- 3. select statements --------------------
---------------------------------------------------------     

-- select Statement
select_statement:= 'with cte_treatment_spec as (
                        select
                            speccond.specialtyid,
                            speccond.conditionid as MedicalTermID,
                            treatlev.treatmentleveldescription,
                            treatlev.ismarketview
                        from
                            base.specialtytocondition as SpecCond
                            join base.treatmentlevel as TreatLev on treatlev.treatmentlevelid = speccond.treatmentlevelid
                        union
                        select
                            specproc.specialtyid,
                            specproc.proceduremedicalid as MedicalTermID,
                            treatlev.treatmentleveldescription,
                            treatlev.ismarketview
                        from
                            base.specialtytoproceduremedical as SpecProc
                            join base.treatmentlevel as TreatLev on treatlev.treatmentlevelid = specproc.treatmentlevelid
                    )
                    
                        select distinct
                            med.refmedicaltermcode as DCPCode,
                            ctetreat.treatmentleveldescription,
                            spec.specialtycode,
                            spec.specialtydescription,
                            ctetreat.ismarketview as ForMarketViewLoad
                        from
                            cte_treatment_spec cteTreat
                            join base.specialty Spec on spec.specialtyid = ctetreat.specialtyid
                            join base.medicalterm Med on med.medicaltermid = ctetreat.medicaltermid';

--- insert Statement
insert_statement := ' insert  (
                        DCPCode,
                        TreatmentLevelDescription,
                        SpecialtyCode,
                        SpecialtyDescription,
                        ForMarketViewLoad)
                      values (
                        source.dcpcode,
                        source.treatmentleveldescription,
                        source.specialtycode,
                        source.specialtydescription,
                        source.formarketviewload);';

                     
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := ' merge into show.solrtreatmententrylevel as target 
                        using (' ||select_statement|| ') as source 
                        on target.dcpcode = source.dcpcode and target.specialtycode = source.specialtycode
                        when not matched then '
                            || insert_statement ;

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