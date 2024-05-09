CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CITYSTATEPOSTALCODE() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
    
-- base.citystatepostalcode depends on: 
--- mdm_team.mst.office_profile_processing (raw.vw_office_profile)
--- mdm_team.mst.facility_profile_processing (raw.vw_facility_profile)
--- base.facility


---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    select_statement_1 string; -- cte and select statement for the merge
    insert_statement_1 string; -- insert statement for the merge
    merge_statement_1 string; -- merge statement to final table
    select_statement_2 string; -- cte and select statement for the merge
    insert_statement_2 string; -- insert statement for the merge
    merge_statement_2 string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_citystatepostalcode');
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
select_statement_1 := $$ select distinct
                                CASE WHEN trim(Address_City) LIKE '%,' then LEFT(trim(Address_City), LENGTH(Address_City)-1) else Address_City END as City,
                                Address_State as State,
                                Address_PostalCode as PostalCode
                            from
                                raw.vw_OFFICE_PROFILE
                            where
                                OFFICE_PROFILE is not null and
                                    nullif(Address_City,'') is not null 
                                    and nullif(Address_State,'') is not null 
                                    and nullif(Address_PostalCode,'') is not null
                                    and LENGTH(trim(upper(Address_AddressLine1)) || ifnull(trim(upper(Address_AddressLine2)),'') || ifnull(trim(upper(Address_Suite)),'')) > 0
                                         $$;



--- insert Statement
insert_statement_1 := ' insert (
                                CityStatePostalCodeId,
                                City,
                                State,
                                PostalCode,
                                LastUpdateDate
                        )
                        values (
                                uuid_string(),
                                source.city,
                                source.state,
                                source.postalcode,
                                current_timestamp()
                        )';

select_statement_2 := $$ select distinct
                                    Address_City as City,
                                    Address_State as State,
                                    Address_PostalCode as PostalCode,
                                    Address_Latitude as Latitude,
                                    Address_Longitude as Longitude
                                from
                                    raw.vw_FACILITY_PROFILE as JSON 
                                    join base.facility as Facility on json.facilitycode = facility.facilitycode
                                where
                                    json.facility_PROFILE is not null and
                                    nullif(City,'') is not null 
                                    and nullif(State,'') is not null 
                                    and nullif(PostalCode,'') is not null $$;

insert_statement_2 := $$insert (
                            CityStatePostalCodeId, 
                            City, 
                            State, 
                            PostalCode, 
                            CentroidLatitude, 
                            CentroidLongitude, 
                            NationId, 
                            LastUpdateDate
                        )
                        values 
                        (   uuid_string(), 
                            source.city, 
                            source.state, 
                            source.postalcode, 
                            source.latitude, 
                            source.longitude, 
                            '00415355-0000-0000-0000-000000000000', 
                            current_timestamp()
                        );$$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement_1 := ' merge into base.citystatepostalcode as target using 
                   ('||select_statement_1||') as source 
                   on source.city = target.city and source.state = target.state and source.postalcode = target.postalcode
                   when not matched then '||insert_statement_1;

merge_statement_2 := ' merge into base.citystatepostalcode as target using 
                   ('||select_statement_2||') as source 
                   on source.city = target.city and source.state = target.state and source.postalcode = target.postalcode
                   when not matched then '||insert_statement_2;
                   
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 
                    
execute immediate merge_statement_1 ;
execute immediate merge_statement_2 ;

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