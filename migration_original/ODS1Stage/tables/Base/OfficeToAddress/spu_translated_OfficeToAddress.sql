CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_OFFICETOADDRESS(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  

declare 

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.officetoaddress depends on:
--- mdm_team.mst.office_profile_processing
--- base.office
--- base.addresstype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
update_statement string;
merge_statement string;
status string;
procedure_name varchar(50) default('sp_load_officetoaddress');
execution_start datetime default getdate();
mdm_db string default('mdm_team');

begin


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

    -- select Statement
    select_statement := $$ with cte_address as (
select
    o.ref_office_code as officecode,
    o.created_datetime as create_date,
    o.office_profile,
    to_varchar(json.value:ADDRESS_LINE_1) as address_addressline1,
    to_varchar(json.value:ADDRESS_LINE_2) as address_addressline2,
    to_varchar(json.value:ADDRESS_TYPE_CODE) as address_ADDRESSTYPECODE,
    to_varchar(json.value:CITY) as address_city,
    to_varchar(json.value:DATA_SOURCE_CODE) as address_SOURCECODE,
    to_varchar(json.value:LATITUDE),
    to_varchar(json.value:LONGITUDE),
    to_varchar(json.value:STATE) as address_state,
    to_varchar(json.value:SUITE) as address_suite,
    to_varchar(json.value:TIME_ZONE),
    to_varchar(json.value:UPDATED_DATETIME) as address_LASTUPDATEDATE,
    to_varchar(json.value:ZIP)as address_postalcode,
from $$||mdm_db||$$.mst.office_profile_processing o,
lateral flatten(input => o.office_profile:ADDRESS) json
where nullif(address_CITY,'') is not null 
        and nullif(address_STATE,'') is not null 
        and nullif(address_POSTALCODE,'') is not null
        and LENGTH(trim(upper(address_AddressLine1)) || ifnull(trim(upper(address_AddressLine2)),'') || ifnull(trim(upper(address_Suite)),'')) > 0
)
select 
        at.addresstypeid,
        o.officeid,
        a.addressId,
        json.address_SOURCECODE as SourceCode,
        json.address_LASTUPDATEDATE as LastUpdateDate
from
    cte_address as JSON 
    join base.office as O on o.officecode = json.officecode
    left join base.addresstype as AT on at.addresstypecode = json.address_ADDRESSTYPECODE
    left join base.citystatepostalcode as cspc on 
        ifnull(cspc.state,'') = ifnull(json.address_state,'') and 
        ifnull(cspc.city,'') = ifnull(json.address_city,'') and 
        ifnull(cspc.postalcode,'') = ifnull(json.address_postalcode,'')
    left join base.address as a on 
        a.citystatepostalcodeid = cspc.citystatepostalcodeid and 
        ifnull(a.addressline1,'') = ifnull(json.address_addressline1,'') and 
        ifnull(a.addressline2,'') = ifnull(json.address_addressline2,'') and 
        ifnull(a.suite,'') = ifnull(json.address_suite,'')
    qualify row_number() over(partition by at.addresstypeid, o.officeid, a.addressId order by json.address_LASTUPDATEDATE desc) = 1
$$;


    -- insert Statement
insert_statement := ' insert  
                            (OfficeToAddressID,
                            AddressTypeID,
                            OfficeID,
                            AddressID,
                            SourceCode,
                            LastUpdateDate)
                    values 
                          (utils.generate_uuid(source.addresstypeid || source.officeid || source.addressID), -- done
                            source.addresstypeid,
                            source.officeid,
                            source.addressID,
                            source.sourcecode,
                            source.lastupdatedate)';
                            
update_statement := ' update set 
                        target.SourceCode = source.sourcecode,
                        target.LastUpdateDate = source.lastupdatedate';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------

merge_statement := ' merge into base.officetoaddress as target 
                    using ('||select_statement||') as source
                    on source.officeid = target.officeid and source.addresstypeid = target.addresstypeid and source.addressid = target.addressid
                    when matched then'|| update_statement ||' 
                    when not matched then'||insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.OfficeToAddress;
end if; 
execute immediate merge_statement;

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