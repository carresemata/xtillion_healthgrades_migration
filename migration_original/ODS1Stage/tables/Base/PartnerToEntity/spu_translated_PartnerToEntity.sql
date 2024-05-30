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
--- base.office
--- base.providertooffice
--- base.entitytype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement_1 string; -- cte and select statement for the insert
    select_statement_2 string;
    insert_statement_1 string; -- insert statement 
    insert_statement_2 string;
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_partnertoentity');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement_1 := $$
with CTE_SwimlaneURL as (
    select distinct
        p.providerid,
        json.providercode,
        LEFT(json.oas_CUSTOMERPRODUCTCODE, POSITION('-' IN json.oas_CUSTOMERPRODUCTCODE) - 1) as PartnerCode,
        json.oas_CUSTOMERPRODUCTCODE as OASCustomerProductCode,
        json.oas_URL as OasURL,
        row_number() over(partition by json.providercode, json.oas_CUSTOMERPRODUCTCODE order by CREATE_DATE desc) as RowRank
    from raw.vw_PROVIDER_PROFILE as JSON
    inner join base.provider as P on p.providercode = json.providercode
    where PROVIDER_PROFILE is not null and
        OAS_CUSTOMERPRODUCTCODE is not null
),
CTE_SwimlaneAPI as (
    select 
        json.providercode,
        p.providerid,
        o.officeid,
        json.office_OFFICECODE as OfficeCode,
        SUBSTRING(
        json.oas_CUSTOMERPRODUCTCODE, 
        1, POSITION('-' IN json.oas_CUSTOMERPRODUCTCODE) - 1) as PartnerCode ,
        json.oas_CUSTOMERPRODUCTCODE as OasCustomerProductCode,
        row_number() over(partition by json.providercode, json.office_OFFICECODE order by CREATE_DATE desc) as RowRank
    from raw.vw_PROVIDER_PROFILE as JSON
    inner join base.provider as P on p.providercode = json.providercode
    inner join base.office as O on o.officecode = json.office_OFFICECODE
),
CTE_SwimlaneAPIUpdated as (
    select * 
    from cte_swimlaneapi as api1
    where exists (select * from cte_swimlaneapi as api2 join cte_swimlaneapi as api1 on api1.Providercode = api2.ProviderCode and api2.OASCustomerProductCode is not null)
), 
CTE_SwimlaneURL2 as (
    select
        uuid_string() as PartnerToEntityId,
        par.partnerid,
        prov.providerid as PrimaryEntityId,
        (select entitytypeid from base.entitytype where entitytypecode = 'PROV') as PrimaryEntityTypeId,
        provoff.officeid as SecondaryEntityID,
        (select entitytypeid from base.entitytype where entitytypecode = 'OFFICE') as SecondaryEntityTypeID,
        provoff.officeid as PartnerSecondaryEntityId,
        cte.oasurl,
        sysdate() as LastUpdateDate
    from CTE_swimlaneUrl as cte
    inner join base.partner as Par on par.partnercode = cte.partnercode
    inner join base.provider as Prov on prov.providercode = cte.providercode
    inner join base.providertooffice as ProvOff on provoff.providerid = cte.providerid
    where RowRank = 1 
)$$;


select_statement_2 := select_statement_1 || 
$$, CTE_SwimlaneAPI2 as (
    select
        uuid_string() as PartnerToEntityId,
        par.partnerid,
        prov.providerid as PrimaryEntityId,
        (select entitytypeid from base.entitytype where entitytypecode = 'PROV') as PrimaryEntityTypeId,
        cte.officeid as SecondaryEntityID,
        (select entitytypeid from base.entitytype where entitytypecode = 'OFFICE') as SecondaryEntityTypeID,
        off.practiceid as TertiaryEntityId,
        (select entitytypeid from base.entitytype where entitytypecode = 'PRAC') as TertiaryEntityTypeID,
        sysdate() as LastUpdateDate
    from CTE_SwimlaneAPIUpdated as cte
    inner join base.partner as Par on par.partnercode = cte.partnercode
    inner join base.provider as Prov on prov.providercode = cte.providercode
    inner join base.office as Off on off.officeid = cte.officeid
    where RowRank = 1
)
select * from cte_swimlaneapi2$$;



---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

insert_statement_1 := ' merge into base.partnertoentity as target using 
                   ('||select_statement_1 ||' select * from CTE_swimlaneURL2) as source 
                   on target.partnertoentityid = source.partnertoentityid and target.partnerid = source.partnerid
                   when not matched then 
                    insert (PartnerToEntityId,
                            PartnerID, 
                            PrimaryEntityID, 
                            PrimaryEntityTypeID, 
                            SecondaryEntityID, 
                            SecondaryEntityTypeID, 
                            PartnerSecondaryEntityId,
                            OASURL, 
                            LastUpdateDate)
                    values (source.partnertoentityid,
                            source.partnerid, 
                            source.primaryentityid, 
                            source.primaryentitytypeid, 
                            source.secondaryentityid, 
                            source.secondaryentitytypeid, 
                            source.partnersecondaryentityid,
                            source.oasurl, 
                            source.lastupdatedate)';

                    
insert_statement_2 := ' merge into base.partnertoentity as target using 
                   ('||select_statement_2 ||') as source 
                   on target.partnertoentityid = source.partnertoentityid and target.partnerid = source.partnerid
                   when not matched then 
                    insert (PartnerToEntityId,
                            PartnerID, 
                            PrimaryEntityID, 
                            PrimaryEntityTypeID, 
                            SecondaryEntityID, 
                            SecondaryEntityTypeID,  
                            TertiaryEntityID, 
                            TertiaryEntityTypeID, 
                            LastUpdateDate)
                    values (source.partnertoentityid,
                            source.partnerid, 
                            source.primaryentityid, 
                            source.primaryentitytypeid, 
                            source.secondaryentityid, 
                            source.secondaryentitytypeid, 
                            source.tertiaryentityid,
                            source.tertiaryentitytypeid, 
                            source.lastupdatedate)';
                    
 
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.PartnerToEntity;
end if; 
execute immediate insert_statement_1 ;
execute immediate insert_statement_2 ;

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
