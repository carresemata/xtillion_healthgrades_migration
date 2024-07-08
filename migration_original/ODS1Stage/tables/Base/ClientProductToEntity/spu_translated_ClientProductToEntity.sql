CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_ClientProductToEntity(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL EXECUTE
    as CALLER
    as declare 
    ---------------------------------------------------------
    --------------- 1. table dependencies -------------------
    ---------------------------------------------------------
    
    --- base.clientproducttoentity depends on:
    --- mdm_team.mst.customer_product_profile_processing 
    --- mdm_team.mst.provider_profile_processing 
    --- mdm_team.mst.facility_profile_processing 
    --- mdm_team.mst.practice_profile_processing 
    --- base.entitytype
    --- base.clienttoproduct
    --- base.facility
    --- base.office
    --- base.provider
    --- base.relationshiptype
    --- base.product
    --- base.practice

    ---------------------------------------------------------
    --------------- 2. declaring variables ------------------
    ---------------------------------------------------------
    
    select_statement_1 string;
    select_statement_2 string;
    select_statement_3 string;
    select_statement_4 string;
    update_statement string;
    insert_statement string;
    merge_statement_1 string;
    merge_statement_2 string;
    merge_statement_3 string;
    merge_statement_4 string;
    prefix string;
    suffix string;
    status string;
    procedure_name varchar(50) default('sp_load_clientproducttoentity');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

    begin 
    
    ---------------------------------------------------------
    ----------------- 3. SQL Statements ---------------------
    ---------------------------------------------------------
    --- select Statement

    --------------------------------–------spuMergeCustomerProduct--------------------------------–------
    select_statement_1 := $$  
    select 
        cp.clienttoproductid,
        b.entitytypeid,
        cp.clienttoproductid as EntityID,
        s.SourceCode,
        ifnull(s.lastupdatedate, sysdate()) as LastUpdateDate
    from
        base.vw_swimlane_base_client s
        join base.clienttoproduct as cp on s.customerproductcode = cp.clienttoproductcode
        join base.entitytype b on b.entitytypecode = 'CLPROD'
    qualify row_number() over(partition by clienttoproductid, entitytypeid, EntityID order by s.lastupdatedate desc ) = 1
 $$;
    --------------------------------–------spuMergeFacilityCustomerProduct--------------------------------–------
    select_statement_2 := $$ 
    with cte_facility_profile_processing as (
    SELECT 
        fpp.ref_facility_code AS FacilityCode,
        fpp.created_datetime as CREATE_DATE,
        fpp.facility_profile,
        TO_VARCHAR(JSON.VALUE:CUSTOMER_PRODUCT_CODE) AS ClientToProductCode,
        TO_VARCHAR(JSON.VALUE:DATA_SOURCE_CODE) AS SourceCode,
        TO_VARCHAR(JSON.VALUE:UPDATED_DATETIME) AS LastUpdateDate
    FROM $$||mdm_db||$$.mst.facility_profile_processing fpp,
    LATERAL FLATTEN(input => fpp.FACILITY_PROFILE:CUSTOMER_PRODUCT) JSON
    WHERE ClientToProductCode IS NOT NULL
),
cte_swimlane as (
    select
        facilityid as FacilityID,
        cp.clienttoproductid,
        fpp.SourceCode,
        fpp.LastUpdateDate,
    from
        cte_facility_profile_processing as fpp
        join base.facility as f on fpp.facilitycode = f.facilitycode
        join base.clienttoproduct as cp on cp.clienttoproductcode = fpp.clienttoproductcode
)
select 
    s.clienttoproductid,
    b.entitytypeid,
    s.facilityid as EntityID,
    s.sourcecode,
    s.lastupdatedate
from
    cte_swimlane s
    join base.entitytype b on b.entitytypecode = 'FAC'
qualify row_number() over(partition by clienttoproductid, entitytypeid, EntityID order by s.lastupdatedate desc ) = 1
    $$;
    --------------------------------–------spuMergeProviderCustomerProduct--------------------------------–------
            select_statement_3 := $$        
             with Cte_customer_product as (
    SELECT
        p.ref_provider_code as providercode,
        p.created_datetime as CREATE_DATE,
        to_varchar(json.value:CUSTOMER_PRODUCT_CODE) as CustomerProduct_CustomerProductCode,
        to_boolean(json.value:IS_EMPLOYED) as CustomerProduct_IsEmployed,
        to_varchar(json.value:DATA_SOURCE_CODE) as CustomerProduct_SourceCode,
        to_timestamp_ntz(json.value:UPDATED_DATETIME) as CustomerProduct_LastUpdateDate,
    FROM $$||mdm_db||$$.mst.provider_profile_processing as p
    , lateral flatten(input => p.PROVIDER_PROFILE:CUSTOMER_PRODUCT) as json
    WHERE p.PROVIDER_PROFILE:CUSTOMER_PRODUCT IS NOT NULL
),
cte_swimlane as (
select
        p.providerid,
        cp.clienttoproductid,
        vw.CustomerProduct_LastUpdateDate as LastUpdateDate,
        vw.create_date,
        vw.CustomerProduct_SourceCode as SourceCode,
        vw.CustomerProduct_IsEmployed as IsEmployed,
        row_number() over(
            partition by p.providerid,vw.customerproduct_customerproductcode
            order by
                vw.create_date desc,
                case
                    when ifnull(IsEmployed, 'false') in ('true', 'Y', 'Yes', '1','TRUE') then 1
                    else 0
                end desc
        ) as RowRank,
    from
        Cte_customer_product as vw
        join base.provider as p on vw.providercode = p.providercode
        join base.clienttoproduct as cp on vw.customerproduct_customerproductcode = cp.clienttoproductcode
    where
        vw.customerproduct_customerproductcode is not null
)
select 
    s.clienttoproductid,
    b.entitytypeid,
    s.providerid as EntityID,
    IsEmployed as IsEntityEmployed,
    ifnull(s.sourcecode, 'Profisee') as SourceCode,
    ifnull(s.lastupdatedate, current_timestamp()) as LastUpdateDate
from
    cte_swimlane as s
    join base.entitytype b on b.entitytypecode = 'PROV'
where
    s.rowrank = 1

            $$;
    --------------------------------–------spuMergeProviderOfficeCustomerProduct--------------------------------–------
    select_statement_4 := $$         
with Cte_office as (
    SELECT
        p.ref_provider_code as providercode,
        p.created_datetime as create_date,
        to_varchar(p.PROVIDER_PROFILE:CUSTOMER_PRODUCT[0]:CUSTOMER_PRODUCT_CODE) as CustomerProduct_CustomerProductCode,
        to_varchar(json.value:OFFICE_CODE) as Office_OfficeCode,
        to_varchar(json.value:DATA_SOURCE_CODE) as Office_SourceCode,
        to_timestamp_ntz(json.value:UPDATED_DATETIME) as Office_LastUpdateDate,
        to_varchar(json.value:OFFICE_RANK) as Office_OfficeRank,
    FROM $$||mdm_db||$$.mst.provider_profile_processing as p
    , lateral flatten(input => p.PROVIDER_PROFILE:OFFICE) as json
    WHERE p.PROVIDER_PROFILE:OFFICE IS NOT NULL
),
cte_swimlane as (
        select
            pid.providerid,
            o.officeid,
            x.office_officecode,
            x.providercode,
            x.Office_LastUpdateDate,
            x.office_SourceCode,
            x.customerproduct_customerproductcode as ClientToProductCode,
            rt.relationshiptypeid,
            cp.clienttoproductid,
            row_number() over(
                partition by cp.clienttoproductid,
                o.officeid
                order by
                    x.Office_LastUpdateDate desc
            ) as RowRank
        from
            Cte_office as x
            join base.provider as pID on pid.providercode = x.providercode
            join base.office as O on o.officecode = x.office_officecode
            join base.relationshiptype rt on rt.relationshiptypecode = 'PROVTOOFF'
            join base.clienttoproduct as cp on cp.clienttoproductcode = x.customerproduct_customerproductcode
        where
            x.office_officecode is not null
    )
select 
    cp.clienttoproductid,
    et.entitytypeid,
    t.officeid as EntityID,
    t.office_SourceCode as SourceCode,
    ifnull(t.Office_LastUpdateDate,current_timestamp()) as LastUpdateDate
from
    cte_swimlane T
    join base.entitytype et on et.entitytypecode = 'OFFICE'
    join base.clienttoproduct cp on t.clienttoproductid = cp.clienttoproductid
    join base.office o on o.officeid = t.officeid
    join base.product PR on pr.productid = cp.productid
where rowrank = 1
    $$;

    --- insert Statement
    insert_statement := ' 
        insert
            (
                ClientProductToEntityID,
                ClientToProductID,
                EntityTypeID,
                EntityID,
                SourceCode,
                LastUpdateDate
            )
        values(
                utils.generate_uuid(source.clienttoproductid || source.entitytypeid || source.entityid), -- done
                source.clienttoproductid,
                source.entitytypeid,
                source.entityid,
                source.SourceCode,
                source.lastupdatedate
            )';

     --- update statement
     update_statement := ' update
                            set
                                target.SourceCode = source.SourceCode,
                                target.LastUpdateDate = source.lastupdatedate';

    ---------------------------------------------------------
    --------- 4. actions (inserts and updates) --------------
    ---------------------------------------------------------
    
    prefix := 'merge into base.clientproducttoentity as target using (';
    
    suffix := ') as source on source.clienttoproductid = target.clienttoproductid and source.entitytypeid = target.entitytypeid and source.entityid = target.entityid
                when matched then ' || update_statement || '
                when not matched then' || insert_statement;
                    
    merge_statement_1 := prefix || select_statement_1 || suffix;
    merge_statement_2:= prefix || select_statement_2 || suffix;
    merge_statement_3:= prefix || select_statement_3 || suffix;
    merge_statement_4:= prefix || select_statement_4 || suffix;

    ---------------------------------------------------------
    ------------------- 5. execution ------------------------
    ---------------------------------------------------------

    if (is_full) then
        truncate table base.clientproducttoentity;
    end if; 
    execute immediate merge_statement_1;
    execute immediate merge_statement_2;
    execute immediate merge_statement_3;
    execute immediate merge_statement_4;
    
    ---------------------------------------------------------
    --------------- 6. status monitoring --------------------
    ---------------------------------------------------------
    status:= 'completed successfully';
return status;
exception
    when other then status:= 'failed during execution. ' || 'sql error: ' || sqlerrm || ' error code: ' || sqlcode || '. sql state: ' || sqlstate;
return status;
end;
