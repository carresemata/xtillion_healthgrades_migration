CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_ENTITYTOMEDICALTERM("IS_FULL" BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    

-- base.entitytomedicalterm depends on:
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.medicalterm
--- base.entitytype
--- base.medicaltermtype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement_1 string;
    delete_statement_1 string;
    merge_statement_1 string;
    merge_statement_2 string;
    select_statement_2 string;
    merge_statement_3 string;
    merge_statement_4 string;
    status string; -- status monitoring
    procedure_name varchar(50) default(''sp_load_entitytomedicalterm'');
    execution_start datetime default getdate();
    mdm_db string default(''mdm_team'');
   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement

select_statement_1 := $$ with Cte_condition as (
    SELECT
        p.ref_provider_code as providercode,
        to_varchar(json.value:CONDITION_CODE) as Condition_ConditionCode,
        to_varchar(json.value:CONDITION_RANK) as Condition_ConditionRank,
        to_varchar(json.value:NATIONAL_RANKING_A) as Condition_NationalRankingA,
        to_varchar(json.value:NATIONAL_RANKING_B) as Condition_NationalRankingB,
        to_boolean(json.value:PATIENT_COUNT_IS_FEW) as Condition_PatientCountIsFew,
        to_varchar(json.value:PATIENT_COUNT) as Condition_PatientCount,
        to_varchar(json.value:TREATMENT_LEVEL_CODE) as Condition_TreatmentLevelCode,
        to_boolean(json.value:IS_SCREENING_DEFAULT_CALCULATION) as Condition_IsScreeningDefaultCalculation,
        to_varchar(json.value:DATA_SOURCE_CODE) as Condition_SourceCode,
        to_timestamp_ntz(json.value:UPDATED_DATETIME) as Condition_LastUpdateDate
    FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
    , lateral flatten(input => p.PROVIDER_PROFILE:CONDITION) as json
),
CTE_Swimlane as (
    select
        p.providerid,
        cte.providercode,
        p.providerid as EntityId,
        mt.medicaltermid,
        cte.condition_ConditionCode,
        -- DecileRank
        -- IsPreview
        cte.Condition_LASTUPDATEDATE as LastUpdateDate,
        cte.Condition_ConditionRank as MedicalTermRank,
        cte.Condition_NATIONALRANKINGA as NationalRankingA,
        cte.Condition_NATIONALRANKINGB as NationalRankingB,
        cte.Condition_PATIENTCOUNT as PatientCount,
        cte.condition_PATIENTCOUNTISFEW as PatientCountIsFew,
        -- Searchable
        cte.condition_SOURCECODE as SourceCode
        -- SourceSearch
    from
        cte_condition as cte
        inner join base.provider as P on p.providercode = cte.providercode
        inner join base.medicalterm as MT on mt.refmedicaltermcode = cte.condition_conditioncode
        inner join base.medicaltermtype as MTT on mtt.medicaltermtypeid = mt.medicaltermtypeid and mtt.medicaltermtypecode = ''Condition''
),

CTE_DeleteAll as (
    select distinct
        EntityToMedicalTermId
    from $$ || mdm_db || $$.mst.provider_profile_processing as Process 
        inner join base.provider as P on p.providercode = process.ref_provider_code
        inner join base.entitytomedicalterm as ETMT on etmt.entityid = p.providerid
        inner join base.medicalterm as MT on mt.medicaltermid = etmt.medicaltermid and mt.medicaltermtypeid = (select MedicalTermTypeId from base.medicaltermtype where MedicalTermTypeCode = ''Condition'' )
),

CTE_DeleteSome as (
    select distinct
        EntityToMedicalTermId
    from $$ || mdm_db || $$.mst.provider_profile_processing as Process
        inner join base.provider as P on p.providercode = process.ref_provider_code
        inner join base.entitytomedicalterm as ETMT on etmt.entityid = p.providerid
        inner join base.medicalterm as MT on mt.medicaltermid = etmt.medicaltermid and mt.medicaltermtypeid = (select MedicalTermTypeId from base.medicaltermtype where MedicalTermTypeCode = ''Condition'' )
        left join CTE_swimlane as S on s.providerid = etmt.entityid and s.medicaltermid = mt.medicaltermid
    where s.providerid is null
),
CTE_Tmp2 as (
    select
        s.entityid, 
        s.medicaltermid, 
        (select EntityTypeID from base.entitytype where EntityTypeCode = ''PROV'') as EntityTypeID,  
	    s.sourcecode, 
        s.lastupdatedate, 
        s.patientcount, 
        s.patientcountisfew, 
        s.nationalrankinga, 
        s.nationalrankingb
    from CTE_Swimlane as S 
    where not exists (
        select 1 
        from base.entitytomedicalterm as ETMT 
            left join CTE_Swimlane as S on s.entityid = etmt.entityid
        where etmt.entityid=s.providerid and
              etmt.medicaltermid=s.medicaltermid) ) $$;


select_statement_2 := $$ with Cte_medical_procedure as (
    SELECT
        p.ref_provider_code as providercode,
        to_varchar(json.value:MEDICAL_PROCEDURE_CODE) as MedicalProcedure_MedicalProcedureCode,
        to_varchar(json.value:NATIONAL_RANKING_A) as MedicalProcedure_NationalRankingA,
        to_varchar(json.value:NATIONAL_RANKING_B) as MedicalProcedure_NationalRankingB,
        to_boolean(json.value:PATIENT_COUNT_IS_FEW) as MedicalProcedure_PatientCountIsFew,
        to_varchar(json.value:PATIENT_COUNT) as MedicalProcedure_PatientCount,
        to_varchar(json.value:TREATMENT_LEVEL_CODE) as MedicalProcedure_TreatmentLevelCode,
        to_boolean(json.value:IS_SCREENING_DEFAULT_CALCULATION) as MedicalProcedure_IsScreeningDefaultCalculation,
        to_varchar(json.value:DATA_SOURCE_CODE) as MedicalProcedure_SourceCode,
        to_timestamp_ntz(json.value:UPDATED_DATETIME) as MedicalProcedure_LastUpdateDate
    FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
    , lateral flatten(input => p.PROVIDER_PROFILE:MEDICAL_PROCEDURE) as json
),

CTE_Swimlane as (
    select
        p.providerid,
        cte.providercode,
        p.providerid as EntityId,
        mt.medicaltermid,
        cte.medicalprocedure_MEDICALPROCEDURECODE as ProcedureCode,
        -- DecileRank
        -- IsPreview
        ifnull(cte.medicalprocedure_LASTUPDATEDATE, sysdate()) as LastUpdateDate,
        -- MedicalTermRank
        cte.medicalprocedure_NATIONALRANKINGA as NationalRankingA,
        cte.medicalprocedure_NATIONALRANKINGB as NationalRankingB,
        cte.medicalprocedure_PATIENTCOUNT as PatientCount,
        cte.medicalprocedure_PATIENTCOUNTISFEW as PatientCountIsFew,
        -- Searchable
        ifnull(cte.medicalprocedure_SOURCECODE, ''Profisee'') as SourceCode
        -- SourceSearch
    from
        cte_medical_procedure as cte
        inner join base.provider as P on p.providercode = cte.providercode
        inner join base.medicalterm as MT on mt.refmedicaltermcode = cte.medicalprocedure_MEDICALPROCEDURECODE
        inner join base.medicaltermtype as MTT on mtt.medicaltermtypeid = mt.medicaltermtypeid and mtt.medicaltermtypecode = ''Procedure''
),

CTE_Tmp2 as (
    select
        s.entityid, 
        s.medicaltermid, 
        (select EntityTypeID from base.entitytype where EntityTypeCode = ''PROV'') as EntityTypeID,  
	    s.sourcecode, 
        s.lastupdatedate, 
        s.patientcount, 
        s.patientcountisfew, 
        s.nationalrankinga, 
        s.nationalrankingb
    from CTE_Swimlane as S 
    where not exists (
        select 1 
        from base.entitytomedicalterm as ETMT 
            left join CTE_Swimlane as S on s.entityid = etmt.entityid
        where etmt.entityid=s.providerid and
              etmt.medicaltermid=s.medicaltermid)) $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

delete_statement_1 := ''delete from base.entitytomedicalterm 
            where EntityToMedicalTermID IN 
                ('' || select_statement_1 || ''select EntityToMedicalTermID from CTE_DeleteAll)
            or EntityToMedicalTermID IN 
                ('' || select_statement_1 || ''select EntityToMedicalTermID from CTE_DeleteSome)'';


merge_statement_1 := '' merge into base.entitytomedicalterm as target using 
                   (''||select_statement_1 ||'' select * from CTE_swimlane ) as source 
                   on target.entityid = source.entityid and target.medicaltermid = source.medicaltermid
                   WHEN MATCHED and 
                                    ifnull(target.patientcountisfew,0) <> ifnull(source.patientcountisfew,0) 
                                    or ifnull(target.nationalrankinga,0) <> ifnull(source.nationalrankinga,0) 
                                    or ifnull(target.patientcount,0) <> ifnull(source.patientcount,0) 
                                    or ifnull(target.nationalrankingb,0) <> ifnull(source.nationalrankingb,0)
                   then 
                    update 
                            SET 
                                target.patientcountisfew = source.patientcountisfew, 
                                target.lastupdatedate = source.lastupdatedate, 
                                target.nationalrankinga = source.nationalrankinga, 
                                target.patientcount = source.patientcount, 
                                target.nationalrankingb = source.nationalrankingb, 
                                target.sourcecode = source.sourcecode'';

merge_statement_2 := '' merge into base.entitytomedicalterm as target using 
                   (''||select_statement_1 ||'' select * from CTE_Tmp2) as source 
                   on target.entityid = source.entityid and target.medicaltermid = source.medicaltermid
                   when not matched then 
                    insert (EntityID, 
                            MedicalTermID, 
                            EntityTypeID, 
                            SourceCode, 
                            LastUpdateDate, 
                            PatientCount, 
                            PatientCountIsFew,
                            NationalRankingA, 
                            NationalRankingB)
                    values (source.entityid, 
                            source.medicaltermid, 
                            source.entitytypeid,  
                            source.sourcecode,
                            source.lastupdatedate, 
                            source.patientcount,
                            source.patientcountisfew,  
                            source.nationalrankinga, 
                            source.nationalrankingb)'';
                                


merge_statement_3 := '' merge into base.entitytomedicalterm as target using 
                   (''||select_statement_2 ||'' select * from CTE_swimlane )   as source 
                   on target.entityid = source.entityid and target.medicaltermid = source.medicaltermid
                   WHEN MATCHED and 
                                    ifnull(target.patientcountisfew,0) <> ifnull(source.patientcountisfew,0) 
    or ifnull(target.nationalrankinga,0) <> ifnull(source.nationalrankinga,0)
    or ifnull(target.patientcount,0) <> ifnull(source.patientcount,0)
    or ifnull(target.nationalrankingb,0) <> ifnull(source.nationalrankingb,0)
                   then update SET 
                            target.patientcountisfew = source.patientcountisfew,
                            target.lastupdatedate = source.lastupdatedate,
                            target.nationalrankinga = source.nationalrankinga,
                            target.patientcount = source.patientcount,
                            target.nationalrankingb = source.nationalrankingb,
                            target.sourcecode = source.sourcecode'';

merge_statement_4 := '' merge into base.entitytomedicalterm as target using 
                   (''||select_statement_2 ||'' select * from CTE_Tmp2) as source 
                   on target.entityid = source.entityid and target.medicaltermid = source.medicaltermid
                   when not matched then 
                    insert (EntityID, 
                            MedicalTermID, 
                            EntityTypeID,  
                            SourceCode,
                            LastUpdateDate, 
                            PatientCount,
                            PatientCountIsFew,  
                            NationalRankingA, 
                            NationalRankingB)
                    values (source.entityid, 
                            source.medicaltermid, 
                            source.entitytypeid,  
                            source.sourcecode,
                            source.lastupdatedate, 
                            source.patientcount,
                            source.patientcountisfew,  
                            source.nationalrankinga, 
                            source.nationalrankingb)'';
                            
                 
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.EntityToMedicalTerm;
end if; 
execute immediate delete_statement_1 ;
execute immediate merge_statement_1 ;
execute immediate merge_statement_2 ;
execute immediate merge_statement_3 ;
execute immediate merge_statement_4 ;

---------------------------------------------------------
--------------- 6. status monitoring --------------------
--------------------------------------------------------- 

status := ''completed successfully'';
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        return status;

        exception
        when other then
            status := ''failed during execution. '' || ''sql error: '' || sqlerrm || '' error code: '' || sqlcode || ''. sql state: '' || sqlstate;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, split_part(regexp_substr(:status, ''error code: ([0-9]+)''), '':'', 2)::integer, trim(split_part(split_part(:status, ''sql error:'', 2), ''error code:'', 1)), split_part(regexp_substr(:status, ''sql state: ([0-9]+)''), '':'', 2)::integer; 

            raise;
end';