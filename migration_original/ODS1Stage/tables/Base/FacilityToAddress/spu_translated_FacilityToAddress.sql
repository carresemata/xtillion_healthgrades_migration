CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_FACILITYTOADDRESS(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.facilitytoaddress depends on: 
--- mdm_team.mst.facility_profile_processing 
--- base.facility
--- base.citystatepostalcode
--- base.address
--- base.addresstype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_facilitytoaddress');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
begin
    
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$  with Cte_address as (
                                SELECT
                                    p.ref_facility_code as facilitycode,
                                    to_varchar(json.value:ADDRESS_TYPE_CODE) as Address_AddressTypeCode,
                                    to_varchar(json.value:ADDRESS_LINE_1) as Address_AddressLine1,
                                    to_varchar(json.value:CITY) as Address_City,
                                    to_varchar(json.value:STATE) as Address_State,
                                    to_varchar(json.value:ZIP) as Address_PostalCode,
                                    to_varchar(json.value:DATA_SOURCE_CODE) as Address_SourceCode,
                                    to_timestamp_ntz(json.value:UPDATED_DATETIME) as Address_LastUpdateDate
                                FROM $$ || mdm_db || $$.mst.facility_profile_processing as p
                                , lateral flatten(input => p.FACILITY_PROFILE:ADDRESS) as json
                                where
                                    nullif(Address_City,'') is not null 
                                    and nullif(Address_State,'') is not null 
                                    and nullif(Address_PostalCode,'') is not null
                            )

                            select distinct
                                facility.facilityid,
                                address.addressid,
                                type.addresstypeid,
                                json.address_SourceCode as SourceCode,
                                ifnull(json.address_lastupdatedate, current_timestamp()) as lastupdatedate
                            from
                                cte_address as JSON 
                                join base.facility as Facility on json.facilitycode = facility.facilitycode
                                join base.citystatepostalcode as CSPC on json.address_City = cspc.city and json.address_State = cspc.state and json.address_PostalCode = cspc.postalcode 
                                join base.address as Address on address.addressline1 = json.address_AddressLine1 and cspc.citystatepostalcodeid = address.citystatepostalcodeid 
                                join base.addresstype as type on type.addresstypecode = json.address_addresstypecode
                            qualify row_number() over(partition by facility.facilityid order by json.address_lastupdatedate desc ) = 1 $$;


--- insert Statement
insert_statement := $$ insert (
                            FacilityToAddressId, 
                            FacilityId, 
                            AddressId, 
                            AddressTypeId, 
                            SourceCode, 
                            LastUpdateDate)
                       values (
                            uuid_string(), 
                            source.facilityid, 
                            source.addressid, 
                            source.addresstypeid,
                            source.sourcecode, 
                            source.lastupdatedate)
                    $$;

--- update statement 
update_statement := $$ update
                        set
                            target.SourceCode = source.sourcecode,
                            target.LastUpdateDate = source.lastupdatedate
                    $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.facilitytoaddress as target using 
                   ('||select_statement||') as source 
                   on source.facilityid = target.facilityid and source.addressid = target.addressid and source.addresstypeid = target.addresstypeid
                   when matched then ' || update_statement || '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.FacilityToAddress;
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