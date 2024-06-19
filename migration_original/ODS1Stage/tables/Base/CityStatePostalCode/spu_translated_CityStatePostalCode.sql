CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CITYSTATEPOSTALCODE("IS_FULL" BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.citystatepostalcode depends on: 
--- mdm_team.mst.office_profile_processing 
--- mdm_team.mst.facility_profile_processing 
--- base.facility


---------------------------------------------------------
--------------- 2. declaring variables ------------------
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
    mdm_db string default('mdm_team');
   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement_1 := $$ select distinct
                                CASE WHEN trim(TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].CITY)) LIKE '%,' then LEFT(trim(TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].CITY)), LENGTH(TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].CITY))-1) else TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].CITY) END as City,
                                TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].STATE) as State,
                                TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].ZIP) as PostalCode
                            from
                                $$ || mdm_db || $$.mst.office_profile_processing as process
                            where
                                    nullif(City,'') is not null 
                                    and nullif(State,'') is not null 
                                    and nullif(Postalcode,'') is not null
                                    and LENGTH(trim(upper(TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].ADDRESS_LINE_1))) || ifnull(trim(upper(TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].ADDRESS_LINE_2))),'') || ifnull(trim(upper(TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].SUITE))),'')) > 0
                                         $$;



--- insert Statement
insert_statement_1 := $$ insert (
                                CityStatePostalCodeId,
                                City,
                                State,
                                PostalCode,
                                LastUpdateDate,
                                nationid
                        )
                        values (
                                uuid_string(),
                                source.city,
                                source.state,
                                source.postalcode,
                                current_timestamp(),
                                '00415355-0000-0000-0000-000000000000'
                        )$$;

select_statement_2 := $$ select distinct
                                    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].CITY) as City,
                                    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].STATE) as State,
                                    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].ZIP) as PostalCode,
                                    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].LATITUDE) as Latitude,
                                    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].LONGITUDE) as Longitude
                                from
                                    $$ || mdm_db || $$.mst.facility_profile_processing as process 
                                    join base.facility as Facility on process.ref_facility_code = facility.facilitycode
                                where
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
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.CityStatePostalCode;
end if; 
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
