CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_OFFICE(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.office depends on: 
--- mdm_team.mst.office_profile_processing (raw.vw_office_profile)
--- base.practice

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    update_clause string; -- where condition for update
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_office');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$  select 
                                -- ReltioEntityID,
                                uuid_string() as OfficeID,
                                CASE WHEN LENGTH(json.officecode)>10 then null else json.officecode END as OfficeCode, 
                                p.practiceid, 
                                -- HasBillingStaff
                                -- HasHandicapAccess
                                -- HasLabServicesOnSite
                                -- HasPharmacyOnSite
                                -- HasXrayOnSite
                                -- IsSurgeryCenter
                                -- HasSurgeryOnSite
                                -- AverageDailyPatientVolume
                                -- PhysicianCount
                                -- OfficeCoordinatorName
                                json.demographics_PARKINGINFORMATION as ParkingInformation,
                                -- PaymentPolicy
                                json.demographics_OFFICENAME as OfficeName,
                                ifnull(json.demographics_SOURCECODE, 'Profisee') as Sourcecode,
                                -- OfficeRank
                                -- is Derived
                                -- NPI
                                ifnull(json.demographics_LASTUPDATEDATE, sysdate() ) as LastUpdateDate
                                -- OfficeDescription
                                -- HasChildPlayground
                                -- OfficeWebsite
                                -- OfficeEmail
                            from raw.vw_OFFICE_PROFILE as JSON
                                left join base.practice as P on p.practicecode = json.practice_PRACTICECODE
                            where
                                OFFICE_PROFILE is not null
                                and OFFICECODE is not null
                            qualify row_number() over(partition by OfficeID order by CREATE_DATE desc) = 1 $$;



--- update Statement
update_statement := ' update 
                     SET  target.officecode = source.officecode, 
                            target.practiceid = source.practiceid, 
                            target.parkinginformation = source.parkinginformation, 
                            target.officename = source.officename, 
                            target.sourcecode = source.sourcecode, 
                            target.lastupdatedate = source.lastupdatedate';
                            
-- update Clause
update_clause := $$  ifnull(target.officecode, '') != ifnull(source.officecode, '') 
                    or ifnull(target.officename, '') != ifnull(source.officename, '') 
                    or ifnull(target.sourcecode, '') != ifnull(source.sourcecode, '') 
                    or ifnull(target.parkinginformation, '') != ifnull(source.parkinginformation, '') 
                    $$;                        
        
--- insert Statement
insert_statement := ' insert  
                            (OfficeID,
                            OfficeCode,
                            PracticeID,
                            ParkingInformation,
                            OfficeName,
                            SourceCode,
                            LastUpdateDate)
                      values 
                            (source.officeid,
                            source.officecode,
                            source.practiceid,
                            source.parkinginformation,
                            source.officename,
                            source.sourcecode,
                            source.lastupdatedate )';


    
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := ' merge into base.office as target using 
                   ('||select_statement||') as source 
                   on source.officeid = target.officeid
                   WHEN MATCHED and' || update_clause || 'then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.Office;
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