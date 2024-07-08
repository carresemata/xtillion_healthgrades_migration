CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_ADDRESS(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.address depends on: 
--- mdm_team.mst.office_profile_processing 
--- mdm_team.mst.facility_profile_processing 
--- base.facility
--- base.citystatepostalcode

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement_1 string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update
    merge_statement_1 string; -- merge statement to final table
    select_statement_2 string; -- cte and select statement for the merge
    merge_statement_2 string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_address');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');   
   
begin
    

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement_1 := $$ with cte_address as (
                            select
                                p.ref_facility_code as facilitycode,
                                to_varchar(json.value:ADDRESS_LINE_1) AS Address_AddressLine1,
                                to_varchar(json.value:ADDRESS_LINE_2) AS Address_AddressLine2,
                                to_varchar(json.value:LATITUDE) AS Address_Latitude,
                                to_varchar(json.value:LONGITUDE) AS Address_Longitude,
                                to_varchar(json.value:CITY) AS Address_City,
                                to_varchar(json.value:STATE) AS Address_State, 
                                to_varchar(json.value:ZIP) AS Address_PostalCode ,
                                to_varchar(json.value:UPDATED_DATETIME) as address_LastUpdateDate,
                                ifnull(to_varchar(json.value:TIME_ZONE), 'None') as address_Timezone,
                                to_varchar(json.value:SUITE) as address_Suite
                            from  
                                $$ || mdm_db || $$.mst.facility_profile_processing as p
                                , lateral flatten(input => p.FACILITY_PROFILE:ADDRESS) as json
                            where
                                nullif(Address_City,'') is not null 
                                and nullif(Address_State,'') is not null 
                                and nullif(Address_PostalCode,'') is not null
                                and Address_AddressLine1 != ''
                            )

                            select distinct
                                json.address_AddressLine1 as AddressLine1,
                                json.address_addressline2 as addressline2,
                                json.address_Latitude as Latitude,
                                json.address_Longitude as Longitude,
                                cspc.citystatepostalcodeid,
                                cspc.nationid,
                                json.address_suite as suite,
                                json.address_timezone as timezone,
                                ifnull(json.address_lastupdatedate, current_timestamp()) as lastupdatedate
                            from
                                cte_address as JSON 
                                join base.facility as Facility on json.facilitycode = facility.facilitycode
                                join base.citystatepostalcode as CSPC on json.address_City = cspc.city and json.address_State = cspc.state and json.address_PostalCode = cspc.postalcode  
                            qualify row_number() over(partition by json.address_AddressLine1, json.address_Suite, json.address_State, cspc.city, json.address_PostalCode order by address_lastupdatedate desc) = 1  $$;



select_statement_2 := $$  with cte_address as (
                            select
                                p.ref_office_code as officecode,
                                p.CREATED_DATETIME AS CREATE_DATE,
                                to_varchar(json.value:ADDRESS_LINE_1) AS Address_AddressLine1,
                                to_varchar(json.value:ADDRESS_LINE_2) AS Address_AddressLine2,
                                to_varchar(json.value:LATITUDE) AS Address_Latitude,
                                to_varchar(json.value:LONGITUDE) AS Address_Longitude,
                                to_varchar(json.value:CITY) AS Address_City,
                                to_varchar(json.value:STATE) AS Address_State, 
                                to_varchar(json.value:ZIP) AS Address_PostalCode,
                                ifnull(to_varchar(json.value:TIME_ZONE), 'None') AS Address_TimeZone,
                                to_varchar(json.value:SUITE) AS Address_Suite,
                                to_varchar(json.value:UPDATED_DATETIME) as address_LastUpdateDate
                            from  
                                $$ || mdm_db || $$.mst.office_profile_processing as p
                                , lateral flatten(input => p.OFFICE_PROFILE:ADDRESS) as json
                            where
                                nullif(Address_City,'') is not null 
                                and nullif(Address_State,'') is not null 
                                and nullif(Address_PostalCode,'') is not null
                                and LENGTH(trim(upper(Address_AddressLine1)) || ifnull(trim(upper(Address_AddressLine2)),'') || ifnull(trim(upper(Address_Suite)),'')) > 0
                                and Address_AddressLine1 != ''
                            )

                            select distinct
                                    cspc.citystatepostalcodeid, 
                                    cspc.nationid, 
                                    json.address_AddressLine1 as AddressLine1, 
                                    json.address_AddressLine2 as AddressLine2, 
                                    json.address_Latitude as Latitude, 
                                    json.address_Longitude as Longitude, 
                                    json.address_TimeZone as TimeZone, 
                                    json.address_Suite as Suite,
                                    ifnull(json.address_lastupdatedate, current_timestamp()) as lastupdatedate
                            from
                                cte_address as JSON 
                                join base.citystatepostalcode as CSPC on json.address_PostalCode = cspc.postalcode and json.address_City = cspc.city and json.address_State = cspc.state 
                            qualify row_number() over(partition by json.address_AddressLine1, json.address_AddressLine2, json.address_Suite, json.address_State, cspc.city, json.address_PostalCode order by address_lastupdatedate desc) = 1 $$;


--- insert Statement
insert_statement := $$ insert (
                                AddressId, 
                                NationId, 
                                AddressLine1, 
                                AddressLine2,
                                Latitude, 
                                Longitude, 
                                TimeZone, 
                                CityStatePostalCodeId,
                                suite,
                                lastupdatedate
                        )
                        values (
                                utils.generate_uuid(source.addressline1 || source.addressline2 || source.suite || source.citystatepostalcodeid), 
                                source.nationid,
                                source.addressline1, 
                                source.addressline2,
                                source.latitude, 
                                source.longitude, 
                                source.timezone, 
                                source.citystatepostalcodeid,
                                source.suite,
                                source.lastupdatedate
                        )$$;

--- update statement
update_statement := $$ 
    update
    set
        target.NationId = source.nationid,
        target.AddressLine1 = source.addressline1,
        target.AddressLine2 = source.addressline2,
        target.Latitude = source.latitude,
        target.Longitude = source.longitude,
        target.TimeZone = source.timezone,
        target.suite = source.suite,
        target.lastupdatedate = source.lastupdatedate
$$;


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement_1 := ' merge into base.address as target using 
                   ('||select_statement_1||') as source 
                   on source.addressline1 = target.addressline1 and source.addressline2 = target.addressline2 and source.suite = target.suite and source.citystatepostalcodeid = target.citystatepostalcodeid
                   when matched then ' || update_statement || '
                   when not matched then '||insert_statement;

merge_statement_2 := $$ merge into base.address as target using 
                   ($$||select_statement_2||$$) as source 
                   on source.addressline1 = target.addressline1 and source.addressline2 = target.addressline2 and source.suite = target.suite and source.citystatepostalcodeid = target.citystatepostalcodeid
                   when matched then $$ || update_statement || $$
                   when not matched then $$||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.Address;
end if; 
execute immediate merge_statement_2 ;
execute immediate merge_statement_1 ;

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
