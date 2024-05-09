CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDEREDUCATION(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
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
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providereducation');
    execution_start datetime default getdate();

   
---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------   
   
begin
    if (IsProviderDeltaProcessing) then
           select_statement := '
           with CTE_ProviderBatch as (
                select
                    p.providerid
                from
                    MDM_team.mst.Provider_Profile_Processing as ppp
                    join base.provider as P on p.providercode = ppp.ref_provider_code),';
    else
           select_statement := '
           with CTE_ProviderBatch as (
                select
                    p.providerid
                from
                    base.provider as P
                order by
                    p.providerid),';
    end if;

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement

select_statement := select_statement || 
                    $$
                    CTE_ProviderEducation as (
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
                        n.nationname,
                        0 as ActionCode
                    from CTE_ProviderBatch as pb 
                    join base.providertoeducationinstitution ptei on ptei.providerid = pb.providerid
                    join base.educationinstitution ei on ei.educationinstitutionid = ptei.educationinstitutionid
                    join base.educationinstitutiontype eit on eit.educationinstitutiontypeid = ptei.educationinstitutiontypeid
                    left join base.address a on a.addressid = ei.addressid
                    left join base.citystatepostalcode csp on a.citystatepostalcodeid = csp.citystatepostalcodeid
                    left join base.nation n on csp.nationid = n.nationid
                    left join base.degree d on d.degreeid = ptei.degreeid
                    ),
                    -- insert Action
                    CTE_Action_1 as (
                            select 
                                cte.providertoeducationinstitutionid,
                                1 as ActionCode
                            from CTE_ProviderEducation as cte
                            left join mid.providereducation as mid 
                                on cte.providertoeducationinstitutionid = mid.providertoeducationinstitutionid 
                            where mid.providertoeducationinstitutionid is null),
                            
                     -- update Action
                     CTE_Action_2 as (
                            select 
                                cte.providertoeducationinstitutionid,
                                2 as ActionCode
                            from CTE_ProviderEducation as cte
                            join mid.providereducation as mid 
                                on cte.providertoeducationinstitutionid = mid.providertoeducationinstitutionid 
                            where 
                                
                                MD5(ifnull(cte.providerid::varchar,'''')) <> MD5(ifnull(mid.providerid::varchar,'''')) or 
                                MD5(ifnull(cte.educationinstitutionname::varchar,'''')) <> MD5(ifnull(mid.educationinstitutionname::varchar,'''')) or 
                                MD5(ifnull(cte.educationinstitutiontypecode::varchar,'''')) <> MD5(ifnull(mid.educationinstitutiontypecode::varchar,'''')) or 
                                MD5(ifnull(cte.educationinstitutiontypedescription::varchar,'''')) <> MD5(ifnull(mid.educationinstitutiontypedescription::varchar,'''')) or 
                                MD5(ifnull(cte.graduationyear::varchar,'''')) <> MD5(ifnull(mid.graduationyear::varchar,'''')) or 
                                MD5(ifnull(cte.positionheld::varchar,'''')) <> MD5(ifnull(mid.positionheld::varchar,'''')) or 
                                MD5(ifnull(cte.degreeabbreviation::varchar,'''')) <> MD5(ifnull(mid.degreeabbreviation::varchar,'''')) or 
                                MD5(ifnull(cte.city::varchar,'''')) <> MD5(ifnull(mid.city::varchar,'''')) or 
                                MD5(ifnull(cte.state::varchar,'''')) <> MD5(ifnull(mid.state::varchar,'''')) or 
                                MD5(ifnull(cte.nationname::varchar,'''')) <> MD5(ifnull(mid.nationname::varchar,'''')) 
                     )
        
                    select distinct
                        A0.ProviderToEducationInstitutionID, 
                        A0.ProviderID, 
                        A0.EducationInstitutionName, 
                        A0.EducationInstitutionTypeCode, 
                        A0.EducationInstitutionTypeDescription,
                        A0.GraduationYear, 
                        A0.PositionHeld, 
                        A0.DegreeAbbreviation, 
                        A0.City, 
                        A0.State, 
                        A0.NationName,
                        ifnull(A1.ActionCode,ifnull(A2.ActionCode, A0.ActionCode)) as ActionCode 
                    from CTE_ProviderEducation as A0 
                                        left join CTE_Action_1 as A1 on A0.ProviderToEducationInstitutionID = A1.ProviderToEducationInstitutionID
                                        left join CTE_Action_2 as A2 on A0.ProviderToEducationInstitutionID = A2.ProviderToEducationInstitutionID
                                        where ifnull(A1.ActionCode,ifnull(A2.ActionCode, A0.ActionCode)) <> 0 
                                        $$;

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
                   WHEN MATCHED and source.actioncode = 2 then '||update_statement|| '
                   when not matched and source.actioncode = 1 then '||insert_statement;
                   
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