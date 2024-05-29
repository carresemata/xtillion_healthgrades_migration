CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOCERTIFICATIONSPECIALTY(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertocertificationspecialty depends on: 
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.certificationboard
--- base.certificationspecialty
--- base.certificationagency
--- base.certificationstatus
--- base.moclevel
--- base.mocpathway

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertocertificationspecialty');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- select Statement
select_statement := $$  select distinct
                            p.providerid,
                            cs.certificationspecialtyid,
                            ifnull(json.certificationspecialty_SOURCECODE, 'Profisee') as SourceCode,
                            ifnull(json.certificationspecialty_LASTUPDATEDATE, sysdate()) as LastUpdateDate,
                            cb.certificationboardid, 
                            ca.certificationagencyid,
                            --CertificationSpecialtyRank
                            cst.certificationstatusid,
                            -- CertificationStatusDate, 
                            json.certificationspecialty_CERTIFICATIONEFFECTIVEDATE as CertificationEffectiveDate, 
                            json.certificationspecialty_CERTIFICATIONEXPIRATIONDATE as CertificationExpirationDate, 
                            -- IsSearchable, 
                            -- CertificationAgencyVerified, 
                            mp.mocpathwayid, 
                            ml.moclevelid
                        from raw.vw_PROVIDER_PROFILE as JSON
                            inner join base.provider as P on p.providercode = json.providercode
                            inner join base.certificationspecialty as CS on cs.certificationspecialtycode = json.certificationspecialty_CERTIFICATIONSPECIALTYCODE
                            inner join base.certificationboard as CB on cb.certificationboardcode = json.certificationspecialty_CERTIFICATIONBOARDCODE
                            inner join base.certificationagency as CA on ca.certificationagencycode = json.certificationspecialty_CERTIFICATIONAGENCYCODE
                            inner join base.certificationstatus as CST on cst.certificationstatuscode = json.certificationspecialty_CERTIFICATIONSTATUSCODE
                            inner join base.mocpathway as MP on mp.mocpathwaycode = json.certificationspecialty_MOCPATHWAYCODE
                            inner join base.moclevel as ML on ml.moclevelcode = json.certificationspecialty_MOCLEVELCODE
                        where
                            PROVIDER_PROFILE is not null and
                            PROVIDERID is not null and
                            CERTIFICATIONSPECIALTYID is not null and
                            CERTIFICATIONBOARDID is not null and
                            CERTIFICATIONAGENCYID is not null 
                        qualify row_number() over(partition by PROVIDERID, json.certificationspecialty_CERTIFICATIONAGENCYCODE, json.certificationspecialty_CERTIFICATIONBOARDCODE, json.certificationspecialty_CERTIFICATIONSPECIALTYCODE order by json.certificationspecialty_CERTIFICATIONEFFECTIVEDATE desc, json.certificationspecialty_CERTIFICATIONEXPIRATIONDATE desc, case when json.certificationspecialty_CERTIFICATIONSTATUSCODE = 'C' then 1 else 9 end, CREATE_DATE desc) = 1 $$;

-- insert Statement
insert_statement := ' insert (
                        ProviderToCertificationSpecialtyID, 
                        ProviderID, 
                        CertificationSpecialtyID, 
                        SourceCode, 
                        LastUpdateDate, 
                        CertificationBoardID, 
                        CertificationAgencyID, 
                        --CertificationSpecialtyRank, 
                        CertificationStatusID, 
                        --CertificationStatusDate, 
                        CertificationEffectiveDate, 
                        CertificationExpirationDate, 
                        --IsSearchable, 
                        --CertificationAgencyVerified, 
                        MOCPathwayID, 
                        MOCLevelID)
                     values (
                       uuid_string(),
                       source.providerid, 
                       source.certificationspecialtyid, 
                       source.sourcecode, 
                       source.lastupdatedate, 
                       source.certificationboardid, 
                       source.certificationagencyid, 
                       --source.certificationspecialtyrank, 
                       source.certificationstatusid, 
                       --source.certificationstatusdate, 
                       source.certificationeffectivedate, 
                       source.certificationexpirationdate, 
                       --source.issearchable, 
                       --source.certificationagencyverified, 
                       source.mocpathwayid, 
                       source.moclevelid )';


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := 'merge into base.providertocertificationspecialty as target
using ('||select_statement||') as source
on  source.providerid = target.providerid and
    source.certificationspecialtyid = target.certificationspecialtyid and
    source.certificationboardid = target.certificationboardid and
    source.certificationagencyid = target.certificationagencyid and
    source.certificationstatusid = target.certificationstatusid
WHEN MATCHED then delete
when not matched then' || insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToCertificationSpecialty;
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