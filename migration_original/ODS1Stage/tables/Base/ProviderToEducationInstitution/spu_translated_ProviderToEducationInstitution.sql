CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOEDUCATIONINSTITUTION()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertoeducationinstitution depends on: 
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.educationinstitution
--- base.educationinstitutiontype

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertoeducationinstitution');
    execution_start datetime default getdate();

   
---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------   
   
begin
    -- no conditionals


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ select 
                            p.providerid,
                            ei.educationinstitutionid,
                            eit.educationinstitutiontypeid,
                            json.educationinstitution_GraduationYear as GraduationYear,
                            ifnull(json.educationinstitution_SourceCode, 'Profisee') as SourceCode,
                            ifnull(json.educationinstitution_LastUpdateDate, sysdate()) as LastUpdateDate,
                        from raw.vw_PROVIDER_PROFILE as JSON
                            left join base.provider as P on p.providercode = json.providercode
                            left join base.educationinstitution as EI on ei.educationinstitutioncode = json.educationinstitution_EDUCATIONINSTITUTIONCODE
                            left join base.educationinstitutiontype as EIT on eit.educationinstitutiontypecode = json.educationinstitution_EDUCATIONINSTITUTIONTYPECODE
                        where 
                            PROVIDER_PROFILE is not null and
                            ProviderID is not null and
                            EducationInstitutionID is not null and
                            EducationInstitutionTypeID is not null
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
                   WHEN MATCHED then delete
                   when not matched then '||insert_statement;
                   
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