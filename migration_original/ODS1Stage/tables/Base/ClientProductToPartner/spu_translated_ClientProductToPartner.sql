CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CLIENTPRODUCTTOPARTNER(is_full BOOLEAN)
RETURNS STRING
LANGUAGE SQL
EXECUTE as CALLER
as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

--- base.clientproducttopartner depends on: 
-- mdm_team.mst.customer_product_profile_processing (base.vw_swimlane_base_client)
-- base.client
-- base.clienttoproduct
-- base.partner


---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

cte_sl string; -- bulk of swim lane
select_statement_1 string; 
select_statement_2 string; 
insert_statement string; 
update_statement string;
merge_statement_1 string; 
merge_statement_2 string;
status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_clientproducttopartner');
    execution_start datetime default getdate();



begin
    
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

cte_sl := $$
           with cte_swimlane as (
                select *
                from base.vw_swimlane_base_client 
                qualify DENSE_RANK() over(partition by customerproductcode order by LastUpdateDate) = 1
            ),
            
CTE_FeatureFCBRL as (
    select *,
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
    from CTE_swimlane
)
-- select * from CTE_FeatureFCBRL;
,
CTE_OASPartnerTypeCode as (
    select *,
    CASE
        WHEN PRODUCTCODE IN ('CDOAS', 'IOAS') and OASPartnerTypeCode is null then 'URL'
        else OASPartnerTypeCode
    END as OASPartnerTypeCodeNew
    from CTE_FeatureFCBRL
)
-- select * from CTE_OASPartnerTypeCode;
,

CTE_CustomerName as (
    select cte.*,
    CASE
        WHEN cte.customername is null and c.clientname is null then cte.clientcode
        WHEN cte.customername is null and c.clientname is not null then c.clientname
        else cte.customername
    END as CustomerNameNew
    from CTE_OASPartnerTypeCode as cte
    left join base.client as c on c.clientcode = cte.clientcode
)
-- select * from CTE_CustomerName;
,
            
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
    from CTE_CustomerName
)
          $$;

select_statement_1 := cte_sl || $$
                                select
                                   ctp.clienttoproductid, 
                                   c.clientid as PartnerID,
                                   cte.SourceCode, 
                                   cte.LastUpdateDate, 
                                   CURRENT_USER() as LastUpdateUser, 
                                from CTE_FinalSwimlane as cte
                                    inner join base.client c on c.clientcode = LEFT(cte.clientcode, LEN(cte.clientcode) - 3)
                                    inner join base.clienttoproduct ctp on ctp.clientid = c.clientid
                                qualify row_number() over(partition by clienttoproductid, c.clientid order by cte.lastupdatedate desc) = 1
                                $$;


select_statement_2 := cte_sl || $$
                                select distinct
                                   ctp.clienttoproductid, 
                                   (select PartnerId from base.partner where PartnerCode = 'MHD') as PartnerID,
                                   cte.sourcecode as SourceCode, 
                                   cte.LastUpdateDate,
                                   CURRENT_USER() as LastUpdateUser, 
                                from CTE_FinalSwimlane as cte
                                inner join base.client c on c.clientcode = LEFT(cte.clientcode, LEN(cte.clientcode) - 3)
                                inner join base.clienttoproduct ctp on ctp.clientid = c.clientid
                                where
                                LEFT(ctp.clienttoproductid, POSITION('-', ctp.clienttoproductid) - 1) IN ('STDAVD','HCASAM','HCASM','HCAPASO','HCAWNV','HCAGC','HCAHL1','HCACKS','HCALEW','HCACARES','HCACVA','HCAFRFT','HCATRI','HCASATL','HCANFD','HCAMW','HCAWFD','HCAMT','HCANTD','HCACVA','HCAMT','HCAMW','HCACKS','HCAEFD','HCAGC','HCAHL1','HCALEW','HCANFD','HCAPASO','HCASAM','HCASATL','HCATRI','HCAWFD','HCAWNV','HCAFRFT','HCARES','STDAVD')
                                $$;
update_statement := $$
                    update set 
                        target.LastUpdateDate = source.LastUpdateDate, 
                        target.LastUpdateUser = source.LastUpdateUser,
                        target.sourcecode = source.SourceCode
                    $$;
                                
insert_statement := $$ 
                    insert  
                        (
                         ClientProductToPartnerID, 
                         ClientToProductID, 
                         PartnerID, 
                         SourceCode, 
                         LastUpdateDate, 
                         LastUpdateUser 
                         )
                    values 
                        (
                        uuid_string(),                        
                        source.clienttoproductid,
                        source.partnerid,
                        source.sourcecode,
                        source.lastupdatedate,
                        source.lastupdateuser
                        )
                    $$;


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement_1 := $$ merge into base.clientproducttopartner as target using 
                   ($$||select_statement_1||$$) as source 
                   on source.clienttoproductid = target.clienttoproductid 
                   and  source.partnerid = target.partnerid
                   when not matched then $$||insert_statement;

merge_statement_2 := $$ merge into base.clientproducttopartner as target using 
                   ($$||select_statement_2||$$) as source 
                   on source.clienttoproductid = target.clienttoproductid 
                   and  source.partnerid = target.partnerid                   
                   when not matched then $$||insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ClientProductToPartner;
end if; 
execute immediate merge_statement_1;
execute immediate merge_statement_2;

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
