CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDEREDUCATION(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- mid.providereducation depends on:
--- mdm_team.mst.provider_profile_processing
--- base.providertoeducationinstitution
--- base.educationinstitution
--- base.educationinstitutiontype
--- base.address
--- base.citystatepostalcode
--- base.nation
--- base.degree
--- base.provider

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providereducation');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
begin
select_statement := $$
                    with CTE_ProviderBatch as (
                    select
                        p.providerid
                    from
                        $$ || mdm_db || $$.mst.Provider_Profile_Processing as ppp
                        join base.provider as P on p.providercode = ppp.ref_provider_code)
                    select distinct 
                        ptei.providertoeducationinstitutionid, 
                        ptei.providerid, 
                        ei.educationinstitutionname, 
                        eit.educationinstitutiontypecode, 
                        eit.educationinstitutiontypedescription,
                        ptei.graduationyear, 
                        ptei.positionheld, 
                        d.degreeabbreviation, 
                        csp.city, 
                        csp.state, 
                        n.nationname
                    from CTE_ProviderBatch as pb 
                        join base.providertoeducationinstitution ptei on ptei.providerid = pb.providerid
                        join base.educationinstitution ei on ei.educationinstitutionid = ptei.educationinstitutionid
                        join base.educationinstitutiontype eit on eit.educationinstitutiontypeid = ptei.educationinstitutiontypeid
                        left join base.address a on a.addressid = ei.addressid
                        left join base.citystatepostalcode csp on a.citystatepostalcodeid = csp.citystatepostalcodeid
                        left join base.nation n on csp.nationid = n.nationid
                        left join base.degree d on d.degreeid = ptei.degreeid $$;

--- update Statement
update_statement := ' update 
                     SET 
                        ProviderToEducationInstitutionID = source.providertoeducationinstitutionid, 
                        ProviderID = source.providerid, 
                        EducationInstitutionName = source.educationinstitutionname, 
                        EducationInstitutionTypeCode = source.educationinstitutiontypecode, 
                        EducationInstitutionTypeDescription = source.educationinstitutiontypedescription,
                        GraduationYear = source.graduationyear, 
                        PositionHeld = source.positionheld, 
                        DegreeAbbreviation = source.degreeabbreviation, 
                        City = source.city, 
                        State = source.state, 
                        NationName = source.nationname';

--- insert Statement
insert_statement := ' insert  
                        (ProviderToEducationInstitutionID,
                        ProviderID,
                        EducationInstitutionName,
                        EducationInstitutionTypeCode,
                        EducationInstitutionTypeDescription,
                        GraduationYear,
                        PositionHeld,
                        DegreeAbbreviation,
                        City,
                        State,
                        NationName)
                      values 
                        (source.providertoeducationinstitutionid,
                        source.providerid,
                        source.educationinstitutionname,
                        source.educationinstitutiontypecode,
                        source.educationinstitutiontypedescription,
                        source.graduationyear,
                        source.positionheld,
                        source.degreeabbreviation,
                        source.city,
                        source.state,
                        source.nationname)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.providereducation as target using 
                   ('||select_statement||') as source 
                   on source.providertoeducationinstitutionid = target.providertoeducationinstitutionid
                   when matched then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.ProviderEducation;
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

            raise;
end;