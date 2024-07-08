CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_FACILITYTOFACILITYTYPE(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.facilitytofacilitytype depends on: 
--- mdm_team.mst.facility_profile_processing 
--- base.facility
--- base.facilitytype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_facilitytofacilitytype');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
begin
    

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ with Cte_facility_type as (
                            SELECT
                                p.ref_facility_code as facilitycode,
                                to_varchar(json.value:FACILITY_TYPE_CODE) as Facility_Type_Code,
                                to_varchar(json.value:DATA_SOURCE_CODE) as Facility_Type_SourceCode,
                                to_timestamp_ntz(json.value:UPDATED_DATETIME) as Facility_Type_LastUpdateDate
                            FROM $$ || mdm_db || $$.mst.facility_profile_processing as p
                            , lateral flatten(input => p.FACILITY_PROFILE:FACILITY_TYPE) as json
                        )
                        
                        select distinct
                            facility.facilityid,
                            type.facilitytypeid,
                            ifnull(json.facility_Type_SourceCode, 'Profisee') as SourceCode,
                            ifnull(json.facility_Type_LastUpdateDate, current_timestamp()) as LastUpdateDate
                        from
                            cte_facility_type as JSON
                            join base.facility as Facility on json.facilitycode = facility.facilitycode
                            join base.facilitytype as Type on type.facilitytypecode = json.facility_Type_Code 
                        qualify row_number() over(partition by facilityid, facilitytypeid order by facility_Type_LastUpdateDate desc) = 1 $$;



--- insert Statement
insert_statement := ' insert  
                            (FacilityToFacilityTypeID,
                            FacilityID,
                            FacilityTypeID,
                            SourceCode,
                            LastUpdateDate)
                      values 
                            (utils.generate_uuid(source.facilityid || source.facilitytypeid),
                            source.facilityid,
                            source.facilitytypeid,
                            source.sourcecode,
                            source.lastupdatedate)';

--- update statement 
update_statement := $$ update
                        set
                            target.SourceCode = source.sourcecode,
                            target.LastUpdateDate = source.lastupdatedate
                    $$;
                    
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.facilitytofacilitytype as target using 
                   ('||select_statement||') as source 
                   on source.facilityid = target.facilityid and source.facilitytypeid = target.facilitytypeid
                   when matched then ' || update_statement || '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.FacilityToFacilityType;
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