CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_FACILITYTOFACILITYTYPE()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.facilitytofacilitytype depends on: 
--- mdm_team.mst.facility_profile_processing (raw.vw_facility_profile)
--- base.facility
--- base.facilitytype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_facilitytofacilitytype');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ select distinct
                            facility.facilityid,
                            type.facilitytypeid,
                            ifnull(json.facility_Type_SourceCode, 'Profisee') as SourceCode,
                            ifnull(json.facility_Type_LastUpdateDate, current_timestamp()) as LastUpdateDate
                            
                        from
                            raw.vw_FACILITY_PROFILE as JSON
                            join base.facility as Facility on json.facilitycode = facility.facilitycode
                            join base.facilitytype as Type on type.facilitytypecode = json.facility_Type_Code
                        where
                            FACILITY_PROFILE is not null
                            and FacilityID is not null$$;



--- insert Statement
insert_statement := ' insert  
                            (FacilityToFacilityTypeID,
                            FacilityID,
                            FacilityTypeID,
                            SourceCode,
                            LastUpdateDate)
                      values 
                            (uuid_string(),
                            source.facilityid,
                            source.facilitytypeid,
                            source.sourcecode,
                            source.lastupdatedate)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.facilitytofacilitytype as target using 
                   ('||select_statement||') as source 
                   on source.facilityid = target.facilityid
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