CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_FACILITYHOURS(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.facilityhours depends on: 
--- mdm_team.mst.facility_profile_processing 
--- base.facility
--- base.daysofweek

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_facilityhours');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
begin
    

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
-- if no conditionals:
select_statement := $$ with Cte_hours as (
                                select
                                    p.ref_facility_code as facilitycode,
                                    to_varchar(json.value:DAYS_OF_WEEK_CODE) as Hours_DaysOfWeek,
                                    to_varchar(json.value:OPENING_TIME) as Hours_OpeningTime,
                                    to_varchar(json.value:CLOSING_TIME) as Hours_ClosingTime,
                                    to_boolean(json.value:IS_CLOSED) as Hours_IsClosed,
                                    to_boolean(json.value:IS_OPEN_24_HOURS) as Hours_IsOpen24Hours,
                                    to_varchar(json.value:DATA_SOURCE_CODE) as Hours_SourceCode,
                                    to_timestamp_ntz(json.value:UPDATED_DATETIME) as Hours_LastUpdateDate
                                from $$ || mdm_db || $$.mst.facility_profile_processing as p
                                , lateral flatten(input => p.FACILITY_PROFILE:HOURS) as json
                                where Hours_SourceCode = 'HG INST'
                            )

                    select distinct
                        facility.facilityid,
                        ifnull(json.hours_SourceCode, 'Profisee') as SourceCode,
                        days.daysofweekid,
                        json.hours_OpeningTime as FacilityHoursOpeningTime,
                        json.hours_ClosingTime as FacilityHoursClosingTime,
                        json.hours_IsClosed as FacilityIsClosed,
                        json.hours_IsOpen24Hours as FacilityIsOpen24Hours,
                        ifnull(json.hours_LastUpdateDate, current_timestamp()) as LastUpdateDate
                    from
                        cte_hours as json
                        join base.facility as Facility on json.facilitycode = facility.facilitycode
                        join base.daysofweek as Days on days.daysofweekcode = json.hours_DaysOfWeek $$;


--- insert Statement
insert_statement := ' insert  
                        (FacilityHoursID, 
                         FacilityId, 
                         SourceCode, 
                         DaysOfWeekID, 
                         FacilityHoursOpeningTime, 
                         FacilityHoursClosingTime, 
                         FacilityIsClosed, 
                         FacilityIsOpen24Hours, 
                         LastUpdateDate)
                      values 
                        (utils.generate_uuid(source.facilityid || source.daysofweekid), 
                         source.facilityid, 
                         source.sourcecode, 
                         source.daysofweekid, 
                         source.facilityhoursopeningtime, 
                         source.facilityhoursclosingtime, 
                         source.facilityisclosed, 
                         source.facilityisopen24Hours, 
                         source.lastupdatedate)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := $$ merge into base.facilityhours as target using 
                   ($$ ||select_statement|| $$) as source 
                   on source.facilityid = target.facilityid and source.daysofweekid = target.daysofweekid
                   when not matched then $$ ||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.FacilityHours;
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