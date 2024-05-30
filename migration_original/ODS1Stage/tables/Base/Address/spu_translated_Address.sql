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
--- mdm_team.mst.office_profile_processing (raw.vw_office_profile)
--- mdm_team.mst.facility_profile_processing (raw.vw_facility_profile)
--- base.facility
--- base.citystatepostalcode

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
    procedure_name varchar(50) default('sp_load_address');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement_1 := $$ select distinct
                                json.address_AddressLine1 as AddressLine1,
                                json.address_Latitude as Latitude,
                                json.address_Longitude as Longitude,
                                cspc.citystatepostalcodeid 
                                
                            from
                                raw.vw_FACILITY_PROFILE as JSON 
                                join base.facility as Facility on json.facilitycode = facility.facilitycode
                                join base.citystatepostalcode as CSPC on json.address_City = cspc.city and json.address_State = cspc.state and json.address_PostalCode = cspc.postalcode 
                            where
                                json.facility_PROFILE is not null and 
                                nullif(Address_City,'') is not null 
                                and nullif(Address_State,'') is not null 
                                and nullif(Address_PostalCode,'') is not null $$;



--- insert Statement
insert_statement_1 := $$ insert (
                                AddressId, 
                                NationId, 
                                AddressLine1, 
                                Latitude, 
                                Longitude, 
                                TimeZone, 
                                CityStatePostalCodeId
                        )
                        values (
                                uuid_string(),
                                '00415355-0000-0000-0000-000000000000',
                                source.addressline1, 
                                source.latitude, 
                                source.longitude, 
                                null, 
                                source.citystatepostalcodeid
                        )$$;

select_statement_2 := $$ select distinct
                                    cspc.citystatepostalcodeid, 
                                    cspc.nationid, 
                                    json.address_AddressLine1 as AddressLine1, 
                                    json.address_AddressLine2 as AddressLine2, 
                                    json.address_Latitude as Latitude, 
                                    json.address_Longitude as Longitude, 
                                    json.address_TimeZone as TimeZone, 
                                    json.address_Suite as Suite
                            from
                                raw.vw_OFFICE_PROFILE as JSON 
                                join base.citystatepostalcode as CSPC on json.address_PostalCode = cspc.postalcode and json.address_City = cspc.city and json.address_State = cspc.state
                                
                            where
                                json.office_PROFILE is not null and 
                                    nullif(Address_City,'') is not null 
                                    and nullif(Address_State,'') is not null 
                                    and nullif(Address_PostalCode,'') is not null
                                    and LENGTH(trim(upper(Address_AddressLine1)) || ifnull(trim(upper(Address_AddressLine2)),'') || ifnull(trim(upper(Address_Suite)),'')) > 0
                                    and cspc.citystatepostalcodeid is not null
                            qualify row_number() over(partition by json.address_AddressLine1, json.address_AddressLine2, json.address_Suite, cspc.city, json.address_State, json.address_PostalCode order by CREATE_DATE desc) = 1  $$;

insert_statement_2 := $$insert (
                           AddressID, 
                           CityStatePostalCodeID, 
                           NationID, 
                           AddressLine1, 
                           AddressLine2, 
                           Latitude, 
                           Longitude, 
                           TimeZone, 
                           Suite, 
                           LastUpdateDate 
                        )
                        values 
                        (   uuid_string(),
                            source.citystatepostalcodeid, 
                            source.nationid, 
                            source.addressline1, 
                            source.addressline2, 
                            source.latitude, 
                            source.longitude, 
                            source.timezone, 
                            source.suite, 
                            current_timestamp()
                           
                        );$$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement_1 := ' merge into base.address as target using 
                   ('||select_statement_1||') as source 
                   on source.addressline1 = target.addressline1 and source.citystatepostalcodeid = target.citystatepostalcodeid 
                   when not matched then '||insert_statement_1;

merge_statement_2 := $$ merge into base.address as target using 
                   ($$||select_statement_2||$$) as source 
                   on iff(trim(upper(source.addressline1)) is null, '', trim(upper(source.addressline1))) = iff(trim(upper(target.addressline1)) is null, '', trim(upper(target.addressline1)))
                   and iff(trim(upper(source.addressline2)) is null, '', trim(upper(source.addressline2))) = iff(trim(upper(target.addressline2)) is null, '', trim(upper(target.addressline2)))
                   and iff(trim(upper(source.suite)) is null, '', trim(upper(source.suite))) = iff(trim(upper(target.suite)) is null, '', trim(upper(target.suite)))
                   and source.citystatepostalcodeid = target.citystatepostalcodeid
                   when not matched then $$||insert_statement_2;
                   
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