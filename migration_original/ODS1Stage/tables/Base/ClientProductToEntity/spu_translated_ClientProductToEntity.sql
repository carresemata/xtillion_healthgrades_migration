CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_ClientProductToEntity() -- Parameters
    RETURNS STRING
    LANGUAGE SQL EXECUTE
    AS CALLER
    AS DECLARE 
    ---------------------------------------------------------
    --------------- 0. Table dependencies -------------------
    ---------------------------------------------------------
    
    --- Base.ClientProductToEntity depends on:
    --- MDM_TEAM.MST.CUSTOMER_PRODUCT_PROFILE_PROCESSING (Base.vw_swimlane_base_client)
    --- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
    --- MDM_TEAM.MST.FACILITY_PROFILE_PROCESSING (RAW.VW_FACILITY_PROFILE)
    --- MDM_TEAM.MST.PRACTICE_PROFILE_PROCESSING (RAW.VW_PRACTICE_PROFILE)
    --- BASE.ENTITYTYPE
    --- BASE.CLIENTTOPRODUCT
    --- BASE.FACILITY
    --- BASE.OFFICE
    --- BASE.PROVIDER
    --- BASE.RELATIONSHIPTYPE
    --- BASE.PRODUCT
    --- BASE.PRACTICE

    ---------------------------------------------------------
    --------------- 1. Declaring variables ------------------
    ---------------------------------------------------------
    select_statement_1 STRING;
    select_statement_2 STRING;
    select_statement_3 STRING;
    select_statement_4 STRING;
    select_statement_5 STRING;
    update_statement STRING;
    insert_statement STRING;
    merge_statement_1 STRING;
    merge_statement_2 STRING;
    merge_statement_3 STRING;
    merge_statement_4 STRING;
    merge_statement_5 STRING;
    prefix STRING;
    suffix STRING;
    status STRING;
    ---------------------------------------------------------
    --------------- 2.Conditionals if any -------------------
    ---------------------------------------------------------
    BEGIN 
    ---------------------------------------------------------
    ----------------- 3. SQL Statements ---------------------
    ---------------------------------------------------------
    --- Select Statement
    -- If no conditionals
    --------------------------------–------spuMergeCustomerProduct--------------------------------–------
    select_statement_1 := $$  
    SELECT
        distinct 
        cp.ClientToProductID,
        b.EntityTypeID,
        cp.ClientToProductID as EntityID,
        ifnull(s.LastUpdateDate, sysdate()) as LastUpdateDate
    FROM
        base.vw_swimlane_base_client s
        join base.clienttoproduct as cp on s.CUSTOMERPRODUCTCODE = cp.clienttoproductcode
        JOIN Base.EntityType b on b.EntityTypeCode = 'CLPROD'
    where
        (
            cp.ClientToProductID is not null
            and s.CLIENTCODE is not null
            and s.PRODUCTCODE is not null
        ) $$;
    --------------------------------–------spuMergeFacilityCustomerProduct--------------------------------–------
    select_statement_2 := $$ with cte_swimlane as (
            SELECT
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
            FROM
                raw.vw_facility_profile as vfp
                JOIN base.facility as f on vfp.facilitycode = f.facilitycode
                JOIN base.clienttoproduct as cp on cp.clienttoproductcode = vfp.customerproduct_customerproductcode
            WHERE
                customerproduct_customerproductcode is not null
        )
        SELECT
            distinct s.ClientToProductID,
            b.EntityTypeID,
            s.FacilityID as EntityID,
            s.SourceCode,
            s.LastUpdateDate
        FROM
            cte_swimlane s
            INNER JOIN Base.EntityType b ON b.EntityTypeCode = 'FAC'
            INNER JOIN Base.ClientToProduct cp ON s.ClientToProductID = cp.ClientToProductID
            INNER JOIN Base.Facility o ON s.FacilityID = o.FacilityID
            LEFT JOIN Base.ClientProductToEntity T ON T.ClientToProductID = s.ClientToProductID
            AND T.EntityID = o.FacilityID
            AND T.entitytypeid = b.entitytypeid
        WHERE
            s.RowRank = 1
            AND (
                s.ClientToProductID is not null
                and s.FacilityID is not null
            )
            AND T.ClientProductToEntityId IS NULL
            AND S.ClientToProductCode IS NOT NULL $$;
    --------------------------------–------spuMergeProviderCustomerProduct--------------------------------–------
            select_statement_3 := $$        with cte_swimlane as (
            SELECT
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
                provider_profile:FACILITY [0] :CUSTOMER_PRODUCT:IS_EMPLOYED AS IsEmployed,
                row_number() over(
                    partition by p.ProviderID,
                    vw.customerproduct_customerproductcode
                    order by
                        vw.create_date desc,
                        case
                            when IFNULL(IsEmployed, 'false') in ('true', 'Y', 'Yes', '1') then 1
                            else 0
                        end desc
                ) as RowRank,
                row_number() over(
                    partition by p.ProviderID,
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
                            when iFnull(IsEmployed, 'false') in ('true', 'Y', 'Yes', '1') then 1
                            else 0
                        end desc
                ) as RowRank1
            FROM
                raw.vw_provider_profile as vw
                JOIN base.provider as p on vw.providercode = p.providercode
                JOIN base.ClientToProduct as cp on vw.customerproduct_customerproductcode = cp.clienttoproductcode
            where
                vw.customerproduct_customerproductcode is not null
        )
        SELECT
            distinct 
            s.ClientToProductID,
            b.EntityTypeID,
            s.ProviderID as EntityID,
            IsEmployed as IsEntityEmployed,
            ifnull(s.SourceCode, 'Profisee') as SourceCode,
            ifnull(s.LastUpdateDate, sysdate()) as LastUpdateDate
        FROM
            cte_swimlane as s
            JOIN Base.EntityType b on b.EntityTypeCode = 'PROV'
            JOIN base.ClientToProduct as cp on s.ClientTOProductID = cp.ClientToProductID
            JOIN base.Provider as p on s.ProviderID = p.ProviderID
        where
            s.RowRank = 1
            and (s.ClientToProductID is not null)$$;
    --------------------------------–------spuMergeProviderOfficeCustomerProduct--------------------------------–------
    select_statement_4 := $$         with cte_swimlane as (
        SELECT
            DISTINCT 
            pID.ProviderID,
            O.OfficeID,
            x.office_officecode,
            x.ProviderCode,
            X.OFFICE_LastUpdateDate,
            x.office_SourceCode,
            x.customerproduct_customerproductcode as ClientToProductCode,
            rt.RelationshipTypeID,
            cp.ClientToProductID,
            row_number() over(
                partition by pID.ProviderID,
                OfficeCode
                order by
                    x.CREATE_DATE desc
            ) as RowRank
        FROM
            raw.vw_provider_profile AS x
            JOIN Base.Provider AS pID ON pID.ProviderCode = x.ProviderCode
            JOIN Base.Office as O on O.OFFICECODE = x.office_officecode
            JOIN Base.RelationshipType rt on rt.RelationshipTypeCode = 'PROVTOOFF'
            JOIN Base.ClientToProduct as cp on cp.ClientToProductCode = x.customerproduct_customerproductcode
        where
            x.office_officecode is not null
    )
SELECT
    distinct 
    cp.ClientToProductID,
    et.EntityTypeID,
    T.OfficeID AS EntityID,
    'Profisee' as SourceCode,
    SYSDATE() as LastUpdateDate
FROM
    cte_swimlane T
    JOIN Base.EntityType et on et.EntityTypeCode = 'OFFICE'
    JOIN Base.ClientToProduct cp on T.ClientToProductID = cp.ClientToProductID
    JOIN Base.Office o on o.OfficeID = T.OfficeID
    JOIN Base.Product PR on PR.ProductID = cp.ProductID
where
    ProductTypeCode = 'Practice' $$;
    --------------------------------–------spuMergePracticeCustomerProduct--------------------------------–------
    select_statement_5 := $$ cte_swimlane as (
 select 
    p.PracticeID as EntityID,
    x.PracticeCode,
    x.CustomerProduct_CustomerProductCode as ClientToProductCode,
    cp.ClientToProductID,
    b.EntityTypeID
    sysdate() as LastUpdateDate,
    row_number() over(partition by x.PracticeID order by x.CREATE_DATE desc) as RowRank
from
    raw.vw_practice_profile as x
    join base.practice as p on x.practicecode = p.practicecode
    join base.clienttoproduct as cp on cp.clienttoproductcode = x.customerproduct_customerproductcode
    join Base.EntityType b on b.EntityTypeCode='PRAC'
    )
    select
        ClientToProductID,
        EntityTypeID,
        EntityID,
        LastUpdateDate
        RowRank
    FROM 
        cte_swimlane
    Where rowrank = 1 $$;

    --- Insert Statement
    insert_statement := ' 
        INSERT
            (
                ClientProductToEntityID,
                ClientToProductID,
                EntityTypeID,
                EntityID,
                LastUpdateDate
            )
        VALUES(
                UUID_STRING(),
                source.ClientToProductID,
                source.EntityTypeID,
                source.EntityID,
                source.LastUpdateDate
            )';
    ---------------------------------------------------------
    --------- 4. Actions (Inserts and Updates) --------------
    ---------------------------------------------------------
    prefix := 'MERGE INTO BASE.ClientProductToEntity as target USING (';
    suffix := ') as source on source.ClientToProductID = target.ClientToProductID
                    and source.EntityTypeID = target.EntityTypeID
                    and source.EntityID = target.EntityID
                    WHEN NOT MATCHED THEN' || insert_statement;
                    
    merge_statement_1 := prefix || select_statement_1 || suffix;
    merge_statement_2:= prefix || select_statement_2 || suffix;
    merge_statement_3:= prefix || select_statement_3 || suffix;
    merge_statement_4:= prefix || select_statement_4 || suffix;
    merge_statement_5:= prefix || select_statement_5 || suffix;

    ---------------------------------------------------------
    ------------------- 5. Execution ------------------------
    -------------------------------------------------------
    -- return merge_statement_1;
    EXECUTE IMMEDIATE merge_statement_1;
    EXECUTE IMMEDIATE merge_statement_2;
    EXECUTE IMMEDIATE merge_statement_3;
    EXECUTE IMMEDIATE merge_statement_4;
    --Deprecated
    -- EXECUTE IMMEDIATE merge_statement_5;
    ---------------------------------------------------------
    --------------- 6. Status monitoring --------------------
    ---------------------------------------------------------
    status:= 'Completed successfully';
RETURN status;
EXCEPTION
    WHEN OTHER THEN status:= 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
RETURN status;
END;