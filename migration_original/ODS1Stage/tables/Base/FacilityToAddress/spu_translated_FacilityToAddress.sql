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
--- mdm_team.mst.facility_profile_processing (raw.vw_facility_profile)
--- base.facility
--- base.citystatepostalcode
--- base.address

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_facilitytoaddress');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$  select distinct
                                facility.facilityid,
                                address.addressid,
                                json.address_SourceCode as SourceCode
                            from
                                raw.vw_FACILITY_PROFILE as JSON 
                                join base.facility as Facility on json.facilitycode = facility.facilitycode
                                join base.citystatepostalcode as CSPC on json.address_City = cspc.city and json.address_State = cspc.state and json.address_PostalCode = cspc.postalcode 
                                join base.address as Address on address.addressline1 = json.address_AddressLine1 and cspc.citystatepostalcodeid = address.citystatepostalcodeid 
                            where
                                json.facility_PROFILE is not null and 
                                nullif(Address_City,'') is not null 
                                and nullif(Address_State,'') is not null 
                                and nullif(Address_PostalCode,'') is not null
                            qualify row_number() over(
                                partition by facility.facilityid
                                order by
                                    address.addressid desc
                            ) = 1 $$;


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
                            '4946464F-4543-0000-0000-000000000000',
                            source.sourcecode, 
                            current_timestamp())
                    $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.facilitytoaddress as target using 
                   ('||select_statement||') as source 
                   on source.facilityid = target.facilityid
                   WHEN MATCHED then delete
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