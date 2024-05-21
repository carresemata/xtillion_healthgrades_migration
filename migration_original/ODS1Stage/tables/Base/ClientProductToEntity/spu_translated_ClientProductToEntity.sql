CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_ClientProductToEntity() -- Parameters
    RETURNS STRING
    LANGUAGE SQL EXECUTE
    as CALLER
    as declare 
    ---------------------------------------------------------
    --------------- 1. table dependencies -------------------
    ---------------------------------------------------------
    
    --- base.clientproducttoentity depends on:
    --- mdm_team.mst.customer_product_profile_processing (base.vw_swimlane_base_client)
    --- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
    --- mdm_team.mst.facility_profile_processing (raw.vw_facility_profile)
    --- mdm_team.mst.practice_profile_processing (raw.vw_practice_profile)
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
    select_statement_5 string;
    update_statement string;
    insert_statement string;
    merge_statement_1 string;
    merge_statement_2 string;
    merge_statement_3 string;
    merge_statement_4 string;
    merge_statement_5 string;
    prefix string;
    suffix string;
    status string;
    procedure_name varchar(50) default('sp_load_clientproducttoentity');
    execution_start datetime default getdate();

    begin 
    ---------------------------------------------------------
    ----------------- 3. SQL Statements ---------------------
    ---------------------------------------------------------
    --- select Statement
    -- if no conditionals
    --------------------------------–------spuMergeCustomerProduct--------------------------------–------
    select_statement_1 := $$  
    select
        distinct 
        cp.clienttoproductid,
        b.entitytypeid,
        cp.clienttoproductid as EntityID,
        ifnull(s.lastupdatedate, sysdate()) as LastUpdateDate
    from
        base.vw_swimlane_base_client s
        join base.clienttoproduct as cp on s.customerproductcode = cp.clienttoproductcode
        join base.entitytype b on b.entitytypecode = 'CLPROD'
    where
        (
            cp.clienttoproductid is not null
            and s.clientcode is not null
            and s.productcode is not null
        ) $$;
    --------------------------------–------spuMergeFacilityCustomerProduct--------------------------------–------
    select_statement_2 := $$ with cte_swimlane as (
            select
                facilityid as FacilityID,
                vfp.facilitycode as FacilityCode,
                cp.clienttoproductid,
                customerproduct_customerproductcode as ClientToProductCode,
                parse_json(customerproduct_displaypartner) as DisplayPartner,
                customerproduct_featurefcclurl,
                customerproduct_featurefcflogo,
                customerproduct_featurefcfurl,
                row_number() over(
                    partition by FacilityID
                    order by
                        CREATE_DATE desc
                ) as RowRank,
                'Reltio' as SourceCode,
                sysdate() as LastUpdateDate
            from
                raw.vw_facility_profile as vfp
                join base.facility as f on vfp.facilitycode = f.facilitycode
                join base.clienttoproduct as cp on cp.clienttoproductcode = vfp.customerproduct_customerproductcode
            where
                customerproduct_customerproductcode is not null
        )
        select
            distinct s.clienttoproductid,
            b.entitytypeid,
            s.facilityid as EntityID,
            s.sourcecode,
            s.lastupdatedate
        from
            cte_swimlane s
            inner join base.entitytype b on b.entitytypecode = 'FAC'
            inner join base.clienttoproduct cp on s.clienttoproductid = cp.clienttoproductid
            inner join base.facility o on s.facilityid = o.facilityid
            left join base.clientproducttoentity T on t.clienttoproductid = s.clienttoproductid
            and t.entityid = o.facilityid
            and t.entitytypeid = b.entitytypeid
        where
            s.rowrank = 1
            and (
                s.clienttoproductid is not null
                and s.facilityid is not null
            )
            and t.clientproducttoentityid is null
            and s.clienttoproductcode is not null $$;
    --------------------------------–------spuMergeProviderCustomerProduct--------------------------------–------
            select_statement_3 := $$        with cte_swimlane as (
            select
                p.providerid,
                vw.providercode,
                left(
                    vw.customerproduct_customerproductcode,
                    charindex('-', vw.customerproduct_customerproductcode) -1
                ) as ClientCode,
                substring(
                    vw.customerproduct_customerproductcode,(
                        charindex('-', vw.customerproduct_customerproductcode) + 1
                    ),
                    len(vw.customerproduct_customerproductcode)
                ) as ProductCode,
                vw.customerproduct_customerproductcode as ClientToProductCode,
                cp.clienttoproductid,
                vw.facility_lastupdatedate as LastUpdateDate,
                vw.create_date,
                vw.facility_sourcecode as SourceCode,
                provider_profile:FACILITY [0] :CUSTOMER_PRODUCT:IS_EMPLOYED as IsEmployed,
                row_number() over(
                    partition by p.providerid,
                    vw.customerproduct_customerproductcode
                    order by
                        vw.create_date desc,
                        case
                            when ifnull(IsEmployed, 'false') in ('true', 'Y', 'Yes', '1') then 1
                            else 0
                        end desc
                ) as RowRank,
                row_number() over(
                    partition by p.providerid,
                    REPLACE(
                        substring(
                            vw.customerproduct_customerproductcode,(
                                charindex('-', vw.customerproduct_customerproductcode) + 1
                            ),
                            len(vw.customerproduct_customerproductcode)
                        ),
                        'T2',
                        ''
                    )
                    order by
                        vw.create_date desc,
                        case
                            when ifnull(IsEmployed, 'false') in ('true', 'Y', 'Yes', '1') then 1
                            else 0
                        end desc
                ) as RowRank1
            from
                raw.vw_provider_profile as vw
                join base.provider as p on vw.providercode = p.providercode
                join base.clienttoproduct as cp on vw.customerproduct_customerproductcode = cp.clienttoproductcode
            where
                vw.customerproduct_customerproductcode is not null
        )
        select
            distinct 
            s.clienttoproductid,
            b.entitytypeid,
            s.providerid as EntityID,
            IsEmployed as IsEntityEmployed,
            ifnull(s.sourcecode, 'Profisee') as SourceCode,
            ifnull(s.lastupdatedate, sysdate()) as LastUpdateDate
        from
            cte_swimlane as s
            join base.entitytype b on b.entitytypecode = 'PROV'
            join base.clienttoproduct as cp on s.clienttoproductid = cp.clienttoproductid
            join base.provider as p on s.providerid = p.providerid
        where
            s.rowrank = 1
            and (s.clienttoproductid is not null)$$;
    --------------------------------–------spuMergeProviderOfficeCustomerProduct--------------------------------–------
    select_statement_4 := $$         with cte_swimlane as (
        select
            distinct 
            pid.providerid,
            o.officeid,
            x.office_officecode,
            x.providercode,
            x.office_LastUpdateDate,
            x.office_SourceCode,
            x.customerproduct_customerproductcode as ClientToProductCode,
            rt.relationshiptypeid,
            cp.clienttoproductid,
            row_number() over(
                partition by pid.providerid,
                OfficeCode
                order by
                    x.create_DATE desc
            ) as RowRank
        from
            raw.vw_provider_profile as x
            join base.provider as pID on pid.providercode = x.providercode
            join base.office as O on o.officecode = x.office_officecode
            join base.relationshiptype rt on rt.relationshiptypecode = 'PROVTOOFF'
            join base.clienttoproduct as cp on cp.clienttoproductcode = x.customerproduct_customerproductcode
        where
            x.office_officecode is not null
    )
select
    distinct 
    cp.clienttoproductid,
    et.entitytypeid,
    t.officeid as EntityID,
    'Profisee' as SourceCode,
    sysdate() as LastUpdateDate
from
    cte_swimlane T
    join base.entitytype et on et.entitytypecode = 'OFFICE'
    join base.clienttoproduct cp on t.clienttoproductid = cp.clienttoproductid
    join base.office o on o.officeid = t.officeid
    join base.product PR on pr.productid = cp.productid
where
    ProductTypeCode = 'Practice' $$;
    --------------------------------–------spuMergePracticeCustomerProduct--------------------------------–------
    select_statement_5 := $$ cte_swimlane as (
 select 
    p.practiceid as EntityID,
    x.practicecode,
    x.customerproduct_CustomerProductCode as ClientToProductCode,
    cp.clienttoproductid,
    b.entitytypeid
    sysdate() as LastUpdateDate,
    row_number() over(partition by x.practiceid order by x.create_DATE desc) as RowRank
from
    raw.vw_practice_profile as x
    join base.practice as p on x.practicecode = p.practicecode
    join base.clienttoproduct as cp on cp.clienttoproductcode = x.customerproduct_customerproductcode
    join base.entitytype b on b.entitytypecode='PRAC'
    )
    select
        ClientToProductID,
        EntityTypeID,
        EntityID,
        LastUpdateDate
        RowRank
    from 
        cte_swimlane
    where rowrank = 1 $$;

    --- insert Statement
    insert_statement := ' 
        insert
            (
                ClientProductToEntityID,
                ClientToProductID,
                EntityTypeID,
                EntityID,
                LastUpdateDate
            )
        values(
                uuid_string(),
                source.clienttoproductid,
                source.entitytypeid,
                source.entityid,
                source.lastupdatedate
            )';
    ---------------------------------------------------------
    --------- 4. actions (inserts and updates) --------------
    ---------------------------------------------------------
    prefix := 'merge into base.clientproducttoentity as target using (';
    suffix := ') as source on source.clienttoproductid = target.clienttoproductid
                    and source.entitytypeid = target.entitytypeid
                    and source.entityid = target.entityid
                    when not matched then' || insert_statement;
                    
    merge_statement_1 := prefix || select_statement_1 || suffix;
    merge_statement_2:= prefix || select_statement_2 || suffix;
    merge_statement_3:= prefix || select_statement_3 || suffix;
    merge_statement_4:= prefix || select_statement_4 || suffix;
    merge_statement_5:= prefix || select_statement_5 || suffix;

    ---------------------------------------------------------
    ------------------- 5. execution ------------------------
    -------------------------------------------------------
    -- return merge_statement_1;
    execute immediate merge_statement_1;
    execute immediate merge_statement_2;
    execute immediate merge_statement_3;
    execute immediate merge_statement_4;
    --deprecated
    -- execute immediate merge_statement_5;
    ---------------------------------------------------------
    --------------- 6. status monitoring --------------------
    ---------------------------------------------------------
    status:= 'completed successfully';
return status;
exception
    when other then status:= 'failed during execution. ' || 'sql error: ' || sqlerrm || ' error code: ' || sqlcode || '. sql state: ' || sqlstate;
return status;
end;