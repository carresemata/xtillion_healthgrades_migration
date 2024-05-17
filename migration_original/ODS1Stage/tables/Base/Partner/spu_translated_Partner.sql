CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PARTNER()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.partner depends on: 
--- mdm_team.mst.customer_product_profile_processing  (base.vw_swimlane_base_client)
--- base.client
--- base.partnertype
--- base.product

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    update_clause string; -- where condition for update
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_partner');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$  with cte_swimlane as (
    select
        *
    from
        base.vw_swimlane_base_client qualify dense_rank() over(
            partition by customerproductcode
            order by
                LastUpdateDate
        ) = 1
),
CTE_FeatureFCBRL as (
    select
        *,
        CASE
            WHEN LEFT(FeatureFCBRL, 2) != 'FV' then 'FV' || upper(
                REPLACE(
                    REPLACE(
                        REPLACE(FeatureFCBRL, 'CLIENT', 'CLT'),
                        'CUSTOMER',
                        'CLT'
                    ),
                    'FACILITY',
                    'FAC'
                )
            )
            else FeatureFCBRL
        END as FeatureFCBRLNew
    from
        CTE_swimlane
),
CTE_OASPartnerTypeCode as (
    select
        *,
        CASE
            WHEN PRODUCTCODE IN ('CDOAS', 'IOAS')
            and OASPartnerTypeCode is null then 'URL'
            else OASPartnerTypeCode
        END as OASPartnerTypeCodeNew
    from
        CTE_FeatureFCBRL
),
CTE_CustomerName as (
    select
        cte.*,
        CASE
            WHEN cte.customername is null
            and c.clientname is null then cte.clientcode
            WHEN cte.customername is null
            and c.clientname is not null then c.clientname
            else cte.customername
        END as CustomerNameNew
    from
        CTE_OASPartnerTypeCode as cte
        left join base.client as C on c.clientcode = cte.clientcode
),
CTE_FinalSwimlane as (
    select
        CREATED_DATETIME,
        CUSTOMERPRODUCTCODE,
        CLIENTCODE,
        PRODUCTCODE,
        CUSTOMERPRODUCTJSON,
        CUSTOMERNAMENEW as CustomerName,
        QUEUESIZE,
        LASTUPDATEDATE,
        SOURCECODE,
        ACTIVEFLAG,
        OASURLPATH,
        OASPARTNERTYPECODENEW as OASPartnerTypeCode,
        FEATUREFCBFN,
        FEATUREFCBRLNEW as FeatureFCBRL,
        FEATUREFCCCP_FVCLT,
        FEATUREFCCCP_FVFAC,
        FEATUREFCCCP_FVOFFICE,
        FEATUREFCCLLOGO,
        FEATUREFCCWALL,
        FEATUREFCCLURL,
        FEATUREFCDISLOC,
        FEATUREFCDOA,
        FEATUREFCDOS_FVFAX,
        FEATUREFCDOS_FVMMPEML,
        FEATUREFCDTP,
        FEATUREFCEOARD,
        FEATUREFCEPR,
        FEATUREFCOOACP,
        FEATUREFCLOT,
        FEATUREFCMAR,
        FEATUREFCMWC,
        FEATUREFCNPA,
        FEATUREFCOAS,
        FEATUREFCOASURL,
        FEATUREFCOASVT,
        FEATUREFCOBT,
        FEATUREFCODC_FVDFC,
        FEATUREFCODC_FVDPR,
        FEATUREFCODC_FVMT,
        FEATUREFCODC_FVPSR,
        FEATUREFCPNI,
        FEATUREFCPQM,
        FEATUREFCREL_FVCPOFFICE,
        FEATUREFCREL_FVCPTOCC,
        FEATUREFCREL_FVCPTOFAC,
        FEATUREFCREL_FVCPTOPRAC,
        FEATUREFCREL_FVCPTOPROV,
        FEATUREFCREL_FVPRACOFF,
        FEATUREFCREL_FVPROVFAC,
        FEATUREFCREL_FVPROVOFF,
        FEATUREFCSPC,
        FEATUREFCOOPSR,
        FEATUREFCOOMT
    from
        CTE_CustomerName
)
select distinct
    c.clientid as PartnerID,
    cte.clientcode as PartnerCode,
    cte.customername as PartnerDescription,
    pt.partnertypeid,
    cte.productcode as PartnerProductCode,
    p.productdescription as PartnerProductDescription,
    cte.oasurlpath as URLPath 
from CTE_FinalSwimlane as cte
    inner join base.partnertype as PT on pt.partnertypecode = cte.oaspartnertypecode
    inner join base.client as C on c.clientcode = cte.clientcode
    inner join base.product as P on p.productcode = cte.productcode  $$;



--- update Statement
update_statement := ' update 
                     SET  
                        target.partnertypeid = source.partnertypeid, 
                        target.partnerproductcode = source.partnerproductcode, 
                        target.urlpath = source.urlpath,
                        target.partnerdescription = source.partnerdescription,
                        target.partnerproductdescription = source.partnerproductdescription';
                            
-- update Clause
update_clause := $$ ifnull(target.partnertypeid,'00000000-0000-0000-0000-000000000000') != ifnull(source.partnertypeid,'00000000-0000-0000-0000-000000000000') 
                    or ifnull(target.partnerproductcode,'') != ifnull(source.partnerproductcode,'') 
                    or ifnull(target.urlpath,'') != ifnull(source.urlpath,'')
                    or ifnull(target.partnerdescription,'') != ifnull(source.partnerdescription,'') 
                    or ifnull(target.partnerproductdescription,'') != ifnull(source.partnerproductdescription,'')
                    
                    $$;                        
        
--- insert Statement
insert_statement := ' insert  
                            (PartnerID,
                            PartnerCode,
                            PartnerDescription,
                            PartnerTypeID,
                            PartnerProductCode,
                            PartnerProductDescription,
                            URLPath )
                      values 
                            (source.partnerid,
                            source.partnercode,
                            source.partnerdescription,
                            source.partnertypeid,
                            source.partnerproductcode,
                            source.partnerproductdescription,
                            source.urlpath
                            )';


    
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := ' merge into base.partner as target using 
                   ('||select_statement||') as source 
                   on source.partnerid = target.partnerid and source.partnertypeid = target.partnertypeid
                   WHEN MATCHED and' || update_clause || 'then '||update_statement|| '
                   when not matched and 
                   not exists (select 1 from base.partner as p where p.partnercode = p.partnercode) then'||insert_statement;
                   
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 
                    
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