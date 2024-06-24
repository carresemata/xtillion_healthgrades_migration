CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CITYSTATEPOSTALCODE(is_full BOOLEAN)
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
    merge_statement_1 string; -- merge statement to final table
    select_statement_2 string; -- cte and select statement for the merge
    merge_statement_2 string; -- merge statement to final table
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update for the merge
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_citystatepostalcode');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
   
begin


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement_1 := $$ with CTE_Address AS (
                                SELECT
                                    p.ref_office_code AS officecode,
                                    TO_VARCHAR(json.value: ADDRESS_LINE_1) AS Address_AddressLine1,
                                    TO_VARCHAR(json.value: ADDRESS_LINE_2) AS Address_AddressLine2,
                                    TO_VARCHAR(json.value: SUITE) AS Address_Suite,
                                    TO_VARCHAR(json.value: CITY) AS Address_City,
                                    TO_VARCHAR(json.value: STATE) AS Address_State,
                                    TO_VARCHAR(json.value: ZIP) AS Address_PostalCode,
                                    TO_VARCHAR(json.value: LATITUDE) AS Address_Latitude,
                                    TO_VARCHAR(json.value: LONGITUDE) AS Address_Longitude,
                                    TO_TIMESTAMP_NTZ(json.value: UPDATED_DATETIME) AS Address_LastUpdateDate
                                FROM $$ || mdm_db || $$.mst.office_profile_processing AS p,
                                     LATERAL FLATTEN(input => p.OFFICE_PROFILE:ADDRESS) AS json
                            )
                            
                            select 
                                address_city as City,
                                address_state as State,
                                address_postalcode as PostalCode,
                                address_latitude as centroidlatitude,
                                address_longitude as centroidlongitude,
                                address_lastupdatedate as lastupdatedate
                            from
                                cte_address
                            where
                                    nullif(City,'') is not null 
                                    and nullif(State,'') is not null 
                                    and nullif(Postalcode,'') is not null
                                    and LENGTH( trim(upper(address_addressline1)) || ifnull(trim(upper(address_addressline2)),'') || ifnull(trim(upper(address_suite)),'')) > 0
                            qualify row_number() over(partition by city, state, postalcode order by lastupdatedate desc) = 1
                                         $$;


select_statement_2 := $$ with CTE_Address AS (
                                SELECT
                                    p.ref_facility_code AS facilitycode,
                                    TO_VARCHAR(json.value: CITY) AS Address_City,
                                    TO_VARCHAR(json.value: STATE) AS Address_State,
                                    TO_VARCHAR(json.value: ZIP) AS Address_PostalCode,
                                    TO_VARCHAR(json.value: LATITUDE) AS Address_Latitude,
                                    TO_VARCHAR(json.value: LONGITUDE) AS Address_Longitude,
                                    TO_TIMESTAMP_NTZ(json.value: UPDATED_DATETIME) AS Address_LastUpdateDate
                                FROM $$ || mdm_db || $$.mst.facility_profile_processing AS p,
                                     LATERAL FLATTEN(input => p.FACILITY_PROFILE:ADDRESS) AS json
                            )
                            select 
                                
                                    address_city as City,
                                    address_state as State,
                                    address_postalcode as PostalCode,
                                    address_latitude as centroidlatitude,
                                    address_longitude as centroidlongitude,
                                    address_lastupdatedate as lastupdatedate
                                from
                                    cte_address as process 
                                    join base.facility as Facility on process.facilitycode = facility.facilitycode
                                where
                                    nullif(City,'') is not null 
                                    and nullif(State,'') is not null 
                                    and nullif(PostalCode,'') is not null
                                qualify row_number() over(partition by city, state, postalcode order by lastupdatedate desc) = 1 $$;

--- insert Statement
insert_statement := $$ insert (
                                CityStatePostalCodeId,
                                City,
                                State,
                                PostalCode,
                                LastUpdateDate,
                                CentroidLatitude,
                                CentroidLongitude,
                                nationid
                        )
                        values (
                                uuid_string(),
                                source.city,
                                source.state,
                                source.postalcode,
                                source.lastupdatedate,
                                source.centroidlatitude,
                                source.centroidlongitude,
                                '00415355-0000-0000-0000-000000000000'
                        )$$;

--- update statement
update_statement := $$ update 
                        set
                            target.lastupdatedate = source.lastupdatedate,
                            target.centroidlatitude = source.centroidlatitude,
                            target.centroidlongitude = source.centroidlongitude $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement_1 := ' merge into base.citystatepostalcode as target using 
                   ('||select_statement_1||') as source 
                   on source.city = target.city and source.state = target.state and source.postalcode = target.postalcode
                   when matched then ' || update_statement || '
                   when not matched then '||insert_statement;

merge_statement_2 := ' merge into base.citystatepostalcode as target using 
                   ('||select_statement_2||') as source 
                   on source.city = target.city and source.state = target.state and source.postalcode = target.postalcode
                   when matched then ' || update_statement || '
                   when not matched then '||insert_statement;
                   
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
