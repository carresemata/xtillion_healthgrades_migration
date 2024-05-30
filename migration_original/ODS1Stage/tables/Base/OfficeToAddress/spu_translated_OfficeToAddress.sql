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
--- mdm_team.mst.office_profile_processing (raw.vw_office_profile)
--- base.office
--- base.addresstype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
merge_statement string;
status string;
    procedure_name varchar(50) default('sp_load_officetoaddress');
    execution_start datetime default getdate();



begin


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

    -- select Statement
    select_statement := $$  select distinct
                                    at.addresstypeid,
                                    o.officeid,
                                    -- addressId
                                    json.address_SOURCECODE as SourceCode,
                                    -- isderived
                                    json.address_LASTUPDATEDATE as LastUpdateDate
                            from
                                raw.vw_OFFICE_PROFILE as JSON 
                                left join base.addresstype as AT on at.addresstypecode = json.address_ADDRESSTYPECODE
                                left join base.office as O on o.officecode = json.officecode
                                
                            where
                                    json.office_PROFILE is not null  
                                    and OfficeId is not null 
                                    and nullif(json.address_CITY,'') is not null 
                                    and nullif(json.address_STATE,'') is not null 
                                    and nullif(json.address_POSTALCODE,'') is not null
                                    and LENGTH(trim(upper(json.address_AddressLine1)) || ifnull(trim(upper(json.address_AddressLine2)),'') || ifnull(trim(upper(json.address_Suite)),'')) > 0
                            qualify row_number() over(partition by OfficeID, json.address_ADDRESSLINE1, json.address_ADDRESSLINE2, json.address_SUITE, json.address_CITY, json.address_STATE, json.address_POSTALCODE order by CREATE_DATE desc) = 1$$;


    -- insert Statement
insert_statement := ' insert  
                            (OfficeToAddressID,
                            AddressTypeID,
                            OfficeID,
                            --AddressID,
                            SourceCode,
                            --IsDerived,
                            LastUpdateDate)
                    values 
                          (uuid_string(),
                            source.addresstypeid,
                            source.officeid,
                            --AddressID,
                            source.sourcecode,
                            --IsDerived,
                            source.lastupdatedate)';



---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------

merge_statement := ' merge into base.officetoaddress as target 
using ('||select_statement||') as source
on source.officeid = target.officeid and source.addresstypeid = target.addresstypeid
WHEN MATCHED then delete 
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