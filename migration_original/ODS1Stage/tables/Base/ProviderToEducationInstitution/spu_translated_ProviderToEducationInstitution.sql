CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOEDUCATIONINSTITUTION(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertoeducationinstitution depends on: 
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.educationinstitution
--- base.educationinstitutiontype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertoeducationinstitution');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ with cte_educationinstitution as (
                            select
                                p.ref_provider_code as providercode,
                                to_varchar(json.value:EDUCATION_INSTITUTION_CODE) as educationinstitution_EducationInstitutionCode,
                                to_varchar(json.value:EDUCATION_INSTITUTION_TYPE_CODE) as educationinstitution_EducationInstitutionTypeCode,
                                to_varchar(json.value:GRADUATION_YEAR) as educationinstitution_GraduationYear,
                                to_varchar(json.value:DATA_SOURCE_CODE) as educationinstitution_SourceCode,
                                to_timestamp_ntz(json.value:UPDATED_DATETIME) as educationinstitution_LastUpdateDate
                            from $$||mdm_db||$$.mst.provider_profile_processing as p
                            , lateral flatten(input => p.PROVIDER_PROFILE:EDUCATION_INSTITUTION) as json
                        )
                        
                        select
                            p.providerid,
                            ei.educationinstitutionid,
                            eit.educationinstitutiontypeid,
                            json.educationinstitution_GraduationYear as GraduationYear,
                            ifnull(json.educationinstitution_SourceCode, 'Profisee') as SourceCode,
                            ifnull(json.educationinstitution_LastUpdateDate, current_timestamp()) as LastUpdateDate
                        from cte_educationinstitution as json
                        join base.provider as p on p.providercode = json.providercode
                        join base.educationinstitution as ei on ei.educationinstitutioncode = json.educationinstitution_EducationInstitutionCode
                        join base.educationinstitutiontype as eit on eit.educationinstitutiontypecode = json.educationinstitution_EducationInstitutionTypeCode
                        where educationinstitutionid is not null
                          and educationinstitutiontypeid is not null
                        $$;



--- insert Statement
insert_statement := ' insert  
                            (ProviderToEducationInstitutionID,
                            ProviderID,
                            EducationInstitutionID,
                            EducationInstitutionTypeID,
                            GraduationYear,
                            SourceCode,
                            LastUpdateDate)
                      values 
                            (uuid_string(),
                            source.providerid,
                            source.educationinstitutionid,
                            source.educationinstitutiontypeid,
                            source.graduationyear,
                            source.sourcecode,
                            source.lastupdatedate)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providertoeducationinstitution as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToEducationInstitution;
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
