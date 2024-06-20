CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PARTNERTOENTITY(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.partnertoentity depends on:
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.partner
--- base.providertooffice
--- base.entitytype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the insert
    update_statement string; -- update statement
    insert_statement string; -- insert statement
    merge_statement string; 
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_partnertoentity');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$
with Cte_oas as (
    SELECT
        p.ref_provider_code as providercode,
        p.created_datetime as create_date,
        to_varchar(json.value:CUSTOMER_PRODUCT_CODE) as OAS_CustomerProductCode,
        to_varchar(json.value:DATA_SOURCE_CODE) as OAS_SourceCode,
        to_varchar(json.value:URL) as OAS_URL
    FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
    , lateral flatten(input => p.PROVIDER_PROFILE:OAS) as json
    where to_varchar(json.value:CUSTOMER_PRODUCT_CODE) is not null
),

CTE_SwimlaneURL as (
    select distinct
        p.providerid,
        json.providercode,
        LEFT(json.oas_CUSTOMERPRODUCTCODE, POSITION('-' IN json.oas_CUSTOMERPRODUCTCODE) - 1) as PartnerCode,
        json.oas_CUSTOMERPRODUCTCODE as OASCustomerProductCode,
        json.oas_URL as OasURL,
        json.oas_sourcecode as sourcecode,
        row_number() over(partition by json.providercode, json.oas_CUSTOMERPRODUCTCODE order by CREATE_DATE desc) as RowRank
    from cte_oas as JSON
        inner join base.provider as P on p.providercode = json.providercode
)
    select 
        distinct
        par.partnerid,
        prov.providerid as PrimaryEntityId,
        (select entitytypeid from base.entitytype where entitytypecode = 'PROV') as PrimaryEntityTypeId,
        provoff.officeid as SecondaryEntityID,
        (select entitytypeid from base.entitytype where entitytypecode = 'OFFICE') as SecondaryEntityTypeID,
        provoff.officeid as PartnerSecondaryEntityId,
        cte.oasurl,
        cte.sourcecode,
        current_timestamp() as LastUpdateDate
    from CTE_swimlaneUrl as cte
    inner join base.partner as Par on par.partnercode = cte.partnercode
    inner join base.provider as Prov on prov.providercode = cte.providercode
    inner join base.providertooffice as ProvOff on provoff.providerid = cte.providerid
    where RowRank = 1 
$$;


-- update statement
update_statement := ' update 
                        set
                            target.oasurl = source.oasurl,
                            target.lastupdatedate = source.lastupdatedate';

-- insert statement
insert_statement := ' insert (PartnerToEntityId,
                            PartnerID, 
                            PrimaryEntityID, 
                            PrimaryEntityTypeID, 
                            SecondaryEntityID, 
                            SecondaryEntityTypeID, 
                            PartnerSecondaryEntityId,
                            OASURL, 
                            LastUpdateDate)
                    values (uuid_string(),
                            source.partnerid, 
                            source.primaryentityid, 
                            source.primaryentitytypeid, 
                            source.secondaryentityid, 
                            source.secondaryentitytypeid, 
                            source.partnersecondaryentityid,
                            source.oasurl, 
                            source.lastupdatedate)';


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := ' merge into base.partnertoentity as target using 
                   ('||select_statement ||') as source 
                   on target.partnerid = source.partnerid and target.primaryentityid = source.primaryentityid and target.primaryentitytypeid = source.primaryentitytypeid and target.secondaryentityid = source.secondaryentityid and target.secondaryentitytypeid = source.secondaryentitytypeid and target.partnersecondaryentityid = source.partnersecondaryentityid
                   when matched then '|| update_statement || '
                   when not matched then ' || insert_statement;
                    
 
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.PartnerToEntity;
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