CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOMAPCUSTOMERPRODUCT(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertomapcustomerproduct depends on:
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.clienttoproduct
--- base.clientproducttoentity
--- base.entitytype
--- base.phonetype 
--- base.phone
--- base.office
--- base.providertooffice
--- base.officetophone
--- base.officetoaddress
--- base.address
--- base.citystatepostalcode
--- base.clientproductentitytophone
--- base.product
--- base.client

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the insert
    insert_statement_1 string; 
    insert_statement_2 string;
    merge_statement_1 string; 
    merge_statement_2 string;
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertomapcustomerproduct');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ with CTE_ProviderCustomerProduct as (
    select distinct
        p.providerid,
        cp.clienttoproductid,
        -- ProviderReltioEntityId
        json.providercode,
        SUBSTRING(json.customerproduct_CUSTOMERPRODUCTCODE, 1,  POSITION('-' IN json.customerproduct_CUSTOMERPRODUCTCODE) - 1 ) as ClientCode,
        SUBSTR(json.customerproduct_CUSTOMERPRODUCTCODE, POSITION('-' IN json.customerproduct_CUSTOMERPRODUCTCODE) + 1, LENGTH(json.customerproduct_CUSTOMERPRODUCTCODE)) as ProductCode,
        json.customerproduct_CUSTOMERPRODUCTCODE as ClientToProductCode,
        row_number() over(partition by p.providerid, json.customerproduct_CUSTOMERPRODUCTCODE order by CREATE_DATE desc) as RowRank
    from raw.vw_PROVIDER_PROFILE as JSON
        left join base.provider as P on p.providercode = json.providercode
        inner join base.clienttoproduct as CP on cp.clienttoproductcode = json.customerproduct_CUSTOMERPRODUCTCODE
    where PROVIDER_PROFILE is not null
          and json.customerproduct_CUSTOMERPRODUCTCODE is not null),

CTE_ProviderOfficeCustomerProduct as (
    select distinct
        p.providerid,
        -- ProviderReltioEntityId
        json.providercode,
        SUBSTRING(json.customerproduct_CUSTOMERPRODUCTCODE, 1,  POSITION('-' IN json.customerproduct_CUSTOMERPRODUCTCODE) - 1 ) as ClientCode,
        SUBSTR(json.customerproduct_CUSTOMERPRODUCTCODE, POSITION('-' IN json.customerproduct_CUSTOMERPRODUCTCODE) + 1, LENGTH(json.customerproduct_CUSTOMERPRODUCTCODE)) as ProductCode,
        json.customerproduct_CUSTOMERPRODUCTCODE as ClientToProductCode,
        json.office_OFFICECODE as OfficeCode,
        -- OfficeReltioEntityID
        -- TrackingNumber
        json.office_PHONENUMBER as DisplayPhoneNumber,
        json.office_OFFICERANK as ProviderOfficeRank,
        -- DisplayPartnerCode
        -- RingToNumber
        -- RingToNumberType
        row_number() over(partition by ProviderID, OFFICE_OFFICECODE order by CREATE_DATE desc) as RowRank
    from raw.vw_PROVIDER_PROFILE as JSON
        left join base.provider as P on p.providercode = json.providercode
        inner join base.clienttoproduct as CP on cp.clienttoproductcode = json.customerproduct_CUSTOMERPRODUCTCODE
    where PROVIDER_PROFILE is not null
          and json.customerproduct_CUSTOMERPRODUCTCODE is not null
),
CTE_ClientLevelPhones as (
    select distinct 
        cpe.clientproducttoentityid, 
        cp.clienttoproductid, 
        cp.clienttoproductcode, 
        pt.phonetypecode, 
        p.phonenumber
    from base.clientproductentitytophone as CPEP
    	inner join	base.clientproducttoentity as CPE on cpe.clientproducttoentityid = cpep.clientproducttoentityid
    	inner join	base.entitytype as ET on et.entitytypeid = cpe.entitytypeid
    	inner join	base.clienttoproduct as CP on cp.clienttoproductid = cpe.clienttoproductid
    	inner join	base.phonetype as PT on pt.phonetypeid = cpep.phonetypeid
    	inner join	base.phone as P on p.phoneid = cpep.phoneid
    	inner join	CTE_ProviderCustomerProduct as cte on cte.clienttoproductcode = cp.clienttoproductcode
	where et.entitytypecode = 'CLPROD'
),

CTE_Phone1 as (
    select 
        pocp.providerid,
        pocp.displayphonenumber as ph, 
        'PTODS' as phTyp
    from CTE_ProviderOfficeCustomerProduct as pocp 
    union all
    select 
        pcp.providerid,
        clp.phonenumber as ph, 
        clp.phonetypecode as phTyp
    from CTE_ClientLevelPhones as CLP 
    left join CTE_ProviderCustomerProduct as pcp on pcp.clienttoproductid = clp.clienttoproductid
    where clp.clienttoproductcode = pcp.clienttoproductcode
),

CTE_PhoneXML1 as (
    select
        providerId,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phTyp is not null,'<phTyp>' || phTyp || '</phTyp>','')  || '</phone>','') as phoneXML
    from CTE_Phone1
    group by ProviderId
        
),

CTE_insert_1 as (
    select 
        pcp.providerid, 
        o.officeid, 
        cp.clienttoproductid, 
        TO_VARIANT(xml.phonexml) as PhoneXML,
        -- RingToNumberType,
        -- DisplayPartnerCode,
        -- InsertedBy,
        pocp.displayphonenumber, 
        -- RingToNumber,
        -- TrackingNumber
    from CTE_ProviderCustomerProduct as pcp 
        inner join CTE_ProviderOfficeCustomerProduct as pocp on pocp.providerid = pcp.providerid and pocp.clienttoproductcode = pcp.clienttoproductcode 
        inner join base.office as o on o.officecode = pocp.officecode
        inner join base.clienttoproduct as cp on cp.clienttoproductcode = pcp.clienttoproductcode
        inner join CTE_PhoneXML1 as XML on xml.providerid = pocp.providerid
    where 
        pcp.rowrank = 1 
        and pocp.rowrank = 1
        and pcp.productcode = 'MAP'
        and LENGTH(xml.phonexml) >= LENGTH('<phone><phTyp>PTODS</phTyp></phone>')
),
CTE_Phone2 as (
    select 
        oph.officeid,
        ph.phonenumber as ph, 
        'PTODS' as phTyp
    from base.phone as PH
        left join base.officetophone as OPH on ph.phoneid = oph.phoneid
),

CTE_PhoneXML2 as (
        select
        OfficeId,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phTyp is not null,'<phTyp>' || phTyp || '</phTyp>','')  || '</phone>','') as phoneXML
    from CTE_Phone2
    group by OfficeId
),

CTE_Insert_2 as (
    select 
        p.providerid, 
        o.officeid, 
        lcp.clienttoproductid,
		TO_VARIANT(xml.phonexml) as PhoneXML,
		'HG' as DisplayPartnerCode
	    from	base.provider P
    	    inner join	base.providertooffice PO on po.providerid = p.providerid
    	    inner join	base.officetophone OPH on oph.officeid = po.officeid 
    	    inner join	base.phone PH on ph.phoneid = oph.phoneid
    	    inner join  base.phonetype PT on pt.phonetypeid = oph.phonetypeid and pt.phonetypecode = 'SERVICE'
    	    inner join	base.office O on o.officeid = po.officeid
    	    inner join	base.officetoaddress OA on oa.officeid = o.officeid
    	    inner join	base.address A on a.addressid = oa.addressid
    	    inner join	base.citystatepostalcode CSPC on cspc.citystatepostalcodeid = a.citystatepostalcodeid
    	    inner join	base.clientproducttoentity lCPE on lcpe.entityid = p.providerid
    	    inner join	base.entitytype dE on de.entitytypeid = lcpe.entitytypeid
    	    inner join	base.clienttoproduct lCP on lcp.clienttoproductid = lcpe.clienttoproductid
    	    inner join	base.client dC on lcp.clientid = dc.clientid
    	    inner join	base.product dP on dp.productid = lcp.productid
            inner join CTE_PhoneXML2 as XML on xml.officeid = p.providerid
	    where		dp.productcode = 'MAP'
                    and LENGTH(xml.phonexml) >= LENGTH('<phone><phTyp>PTODS</phTyp></phone>')
) $$;


insert_statement_1 := 'insert (ProviderToMapCustomerProductId,
                            ProviderID, 
                            OfficeID, 
                            ClientToProductID, 
                            PhoneXML, 
                            DisplayPhoneNumber)
                    values (utils.generate_uuid(source.providerid || source.officeid), 
                            source.providerid, 
                            source.officeid, 
                            source.clienttoproductid, 
                            source.phonexml, 
                            source.displayphonenumber)';
                
insert_statement_2 := 'insert (ProviderToMapCustomerProductId,
                            ProviderID, 
                            OfficeID, 
                            ClientToProductID, 
                            PhoneXML, 
                            DisplayPartnerCode)
                    values (utils.generate_uuid(source.providerid || source.officeid), 
                            source.providerid, 
                            source.officeid, 
                            source.clienttoproductid, 
                            source.phonexml, 
                            source.displaypartnercode)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement_1 := ' merge into base.providertomapcustomerproduct as target using 
                   ('||select_statement ||' select * from CTE_insert_1) as source 
                   on target.providerid = source.providerid and target.officeid = source.officeid
                   when not matched then ' || insert_statement_1;

                    
merge_statement_2 := ' merge into base.providertomapcustomerproduct as target using 
                   ('||select_statement || ' select * from CTE_insert_2) as source 
                   on target.providerid = source.providerid and target.officeid = source.officeid
                   when not matched then ' || insert_statement_2;
                    
 
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToMAPCustomerProduct;
end if; 
execute immediate merge_statement_1 ;
execute immediate merge_statement_2 ;

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