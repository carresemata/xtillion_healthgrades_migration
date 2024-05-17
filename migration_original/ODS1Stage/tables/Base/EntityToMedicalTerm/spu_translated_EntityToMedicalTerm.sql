CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_ENTITYTOMEDICALTERM() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    

-- base.entitytomedicalterm depends on:
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
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
    procedure_name varchar(50) default('sp_load_entitytomedicalterm');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement

select_statement_1 := $$ with CTE_Swimlane as (
    select
        p.providerid,
        json.providercode,
        p.providerid as EntityId,
        mt.medicaltermid,
        -- ConditionCode
        -- DecileRank
        -- IsPreview
        json.medicalprocedure_LASTUPDATEDATE as LastUpdateDate,
        -- MedicalTermRank
        json.medicalprocedure_NATIONALRANKINGA as NationalRankingA,
        json.medicalprocedure_NATIONALRANKINGB as NationalRankingB,
        json.medicalprocedure_PATIENTCOUNT as PatientCount,
        json.medicalprocedure_PATIENTCOUNTISFEW as PatientCountIsFew,
        -- Searchable
        json.medicalprocedure_SOURCECODE as SourceCode
        -- SourceSearch
    from
        raw.vw_PROVIDER_PROFILE as JSON
        left join base.provider as P on p.providercode = json.providercode
        left join base.entitytomedicalterm as ETMT on etmt.entityid = p.providerid
        inner join base.medicalterm as MT on mt.medicaltermid = etmt.medicaltermid
        inner join base.medicaltermtype as MTT on mtt.medicaltermtypeid = mt.medicaltermtypeid and mtt.medicaltermtypecode = 'Condition'
    where 
        PROVIDER_PROFILE is not null 
    qualify row_number() over(partition by ProviderId order by CREATE_DATE desc) = 1
),

CTE_DeleteAll as (
    select distinct
        EntityToMedicalTermId
    from raw.vw_PROVIDER_PROFILE as Process 
        inner join base.provider as P on p.providercode = process.providercode
        inner join base.entitytomedicalterm as ETMT on etmt.entityid = p.providerid
        inner join base.medicalterm as MT on mt.medicaltermid = etmt.medicaltermid and mt.medicaltermtypeid = (select MedicalTermTypeId from base.medicaltermtype where MedicalTermTypeCode = 'Condition' )
),

CTE_DeleteSome as (
    select distinct
        EntityToMedicalTermId
    from raw.vw_PROVIDER_PROFILE as Process
        inner join base.provider as P on p.providercode = process.providercode
        inner join base.entitytomedicalterm as ETMT on etmt.entityid = p.providerid
        inner join base.medicalterm as MT on mt.medicaltermid = etmt.medicaltermid and mt.medicaltermtypeid = (select MedicalTermTypeId from base.medicaltermtype where MedicalTermTypeCode = 'Condition' )
        left join CTE_swimlane as S on s.providerid = etmt.entityid and s.medicaltermid = mt.medicaltermid
    where s.providerid is null
),
CTE_Tmp2 as (
    select
        s.entityid, 
        s.medicaltermid, 
        (select EntityTypeID from base.entitytype where EntityTypeCode = 'PROV') as EntityTypeID,  
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


select_statement_2 := $$ with CTE_Swimlane as (
    select
        p.providerid,
        json.providercode,
        p.providerid as EntityId,
        mt.medicaltermid,
        json.medicalprocedure_MEDICALPROCEDURECODE as ProcedureCode,
        -- DecileRank
        -- IsPreview
        ifnull(json.medicalprocedure_LASTUPDATEDATE, sysdate()) as LastUpdateDate,
        -- MedicalTermRank
        json.medicalprocedure_NATIONALRANKINGA as NationalRankingA,
        json.medicalprocedure_NATIONALRANKINGB as NationalRankingB,
        json.medicalprocedure_PATIENTCOUNT as PatientCount,
        json.medicalprocedure_PATIENTCOUNTISFEW as PatientCountIsFew,
        -- Searchable
        ifnull(json.medicalprocedure_SOURCECODE, 'Profisee') as SourceCode
        -- SourceSearch
    from
        raw.vw_PROVIDER_PROFILE as JSON
        left join base.provider as P on p.providercode = json.providercode
        left join base.entitytomedicalterm as ETMT on etmt.entityid = p.providerid
        inner join base.medicalterm as MT on mt.medicaltermid = etmt.medicaltermid
        inner join base.medicaltermtype as MTT on mtt.medicaltermtypeid = mt.medicaltermtypeid and mtt.medicaltermtypecode = 'Procedure'
    where 
        PROVIDER_PROFILE is not null 
        and json.medicalprocedure_MEDICALPROCEDURECODE is not null
    qualify row_number() over(partition by ProviderId, json.medicalprocedure_MEDICALPROCEDURECODE order by CREATE_DATE desc) = 1
),
CTE_Tmp2 as (
    select
        s.entityid, 
        s.medicaltermid, 
        (select EntityTypeID from base.entitytype where EntityTypeCode = 'PROV') as EntityTypeID,  
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

delete_statement_1 := 'delete from base.entitytomedicalterm 
            where EntityToMedicalTermID IN 
                (' || select_statement_1 || 'select EntityToMedicalTermID from CTE_DeleteAll)
            or EntityToMedicalTermID IN 
                (' || select_statement_1 || 'select EntityToMedicalTermID from CTE_DeleteSome)';


merge_statement_1 := ' merge into base.entitytomedicalterm as target using 
                   ('||select_statement_1 ||' select * from CTE_swimlane ) as source 
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
                                target.sourcecode = source.sourcecode';

merge_statement_2 := ' merge into base.entitytomedicalterm as target using 
                   ('||select_statement_1 ||' select * from CTE_Tmp2) as source 
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
                            source.nationalrankingb)';
                                


merge_statement_3 := ' merge into base.entitytomedicalterm as target using 
                   ('||select_statement_2 ||' select * from CTE_swimlane )   as source 
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
                            target.sourcecode = source.sourcecode';

merge_statement_4 := ' merge into base.entitytomedicalterm as target using 
                   ('||select_statement_2 ||' select * from CTE_Tmp2) as source 
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
                            source.nationalrankingb)';
                            
                 
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 

execute immediate delete_statement_1 ;
execute immediate merge_statement_1 ;
execute immediate merge_statement_2 ;
execute immediate merge_statement_3 ;
execute immediate merge_statement_4 ;

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