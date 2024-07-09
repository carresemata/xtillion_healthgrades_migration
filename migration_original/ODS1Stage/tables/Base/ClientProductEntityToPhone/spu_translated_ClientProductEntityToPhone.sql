CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CLIENTPRODUCTENTITYTOPHONE(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL EXECUTE
    as CALLER
    as declare 
    ---------------------------------------------------------
    --------------- 1. table dependencies -------------------
    ---------------------------------------------------------
    
    --- base.clientproductentitytophone depends on:
    --- mdm_team.mst.provider_profile_processing 
    --- mdm_team.mst.facility_profile_processing 
    --- base.entitytype
    --- base.clienttoproduct
    --- base.facility
    --- base.clientproducttoentity
    --- base.phone
    --- base.phonetype
    --- base.syndicationpartner
    --- base.office
    --- base.officetophone

    
    ---------------------------------------------------------
    --------------- 2. declaring variables ------------------
    ---------------------------------------------------------
    
    select_statement_1 string;
    select_statement_2 string;
    select_statement_3 string;
    update_statement string;
    insert_statement string;
    merge_statement_1 string;
    merge_statement_2 string;
    merge_statement_3 string;
    status string;
    procedure_name varchar(50) default('sp_load_clientproductentitytophone');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

    begin 
    
    ---------------------------------------------------------
    ----------------- 3. SQL Statements ---------------------
    ---------------------------------------------------------
    --- select Statement
    select_statement_1 := $$ WITH CTE_Customer_Product AS (
    SELECT
        p.ref_facility_code AS facilitycode,
        created_datetime as create_date,
        TO_VARCHAR(json.value: CUSTOMER_PRODUCT_CODE) AS CustomerProduct_CustomerProductCode,
        TO_VARCHAR(json.value: FEATURE_FCCLLOGO) AS CustomerProduct_FeatureFcclLogo,
        TO_VARCHAR(json.value: FEATURE_FCCLURL) AS CustomerProduct_FeatureFcclUrl,
        TO_TIMESTAMP_NTZ(json.value: DESIGNATED_DATETIME) AS CustomerProduct_DesignatedDatetime,
        TO_VARCHAR(json.value: FEATURE_FCFLOGO) AS CustomerProduct_FeatureFcfLogo,
        TO_VARCHAR(json.value: FEATURE_FCFURL) AS CustomerProduct_FeatureFcfUrl,
        TO_VARCHAR(json.value: OPT_OUT) AS CustomerProduct_OptOut,
        TO_VARCHAR(json.value: DATA_SOURCE_CODE) AS CustomerProduct_SourceCode,
        TO_VARCHAR(json.value: DISPLAY_PARTNER) AS CustomerProduct_DisplayPartner,
        TO_TIMESTAMP_NTZ(json.value: UPDATED_DATETIME) AS CustomerProduct_LastUpdateDate
    FROM $$ || mdm_db || $$.mst.facility_profile_processing  AS p,
         LATERAL FLATTEN(input => p.FACILITY_PROFILE:CUSTOMER_PRODUCT) AS json
    where
        customerproduct_customerproductcode is not null
),
cte_swimlane as (
        select
            facilityid as FacilityID,
            vfp.facilitycode as FacilityCode,
            cp.clienttoproductid,
            customerproduct_customerproductcode as ClientToProductCode,
            parse_json(customerproduct_displaypartner) as DisplayPartnerjson,
            customerproduct_featurefcclurl,
            customerproduct_featurefcflogo,
            customerproduct_featurefcfurl,
            row_number() over(
                partition by FacilityID
                order by
                    CREATE_DATE desc
            ) as RowRank,
            ifnull (CustomerProduct_SourceCode, 'Reltio') as SourceCode,
            ifnull( CustomerProduct_LastUpdateDate, sysdate()) as LastUpdateDate
        from
            cte_customer_product as vfp
            join base.facility as f on vfp.facilitycode = f.facilitycode
            join base.clienttoproduct as cp on cp.clienttoproductcode = vfp.customerproduct_customerproductcode
        
    ),
    cte_display_partner as 
        (SELECT
            s.facilitycode,
            s.clienttoproductcode,
            s.lastupdatedate,
            s.sourcecode,
            s.rowrank,
            to_varchar(json.value:DISPLAY_PARTNER_CODE) as DisplayPartnerCode,
            to_varchar(json.value:PHONE_PTFDS) as PhonePTFDS,
            to_varchar(json.value:PHONE_PTFDSM) as PhonePTFDSM,
            to_varchar(json.value:PHONE_PTFDST) as PhonePTFDST,
            to_varchar(json.value:PHONE_PTFMC) as PhonePTFMC,
            to_varchar(json.value:PHONE_PTFMCM) as PhonePTFMCM,
            to_varchar(json.value:PHONE_PTFMCT) as PhonePTFMCT,
            to_varchar(json.value:PHONE_PTFMT) as PhonePTFMT,
            to_varchar(json.value:PHONE_PTFMTM) as PhonePTFMTM,
            to_varchar(json.value:PHONE_PTFMTT) as PhonePTFMTT,
            to_varchar(json.value:PHONE_PTFSR) as PhonePTFSR,
            to_varchar(json.value:PHONE_PTFSRD) as PhonePTFSRD,
            to_varchar(json.value:PHONE_PTFSRDM) as PhonePTFSRDM,
            to_varchar(json.value:PHONE_PTFSRM) as PhonePTFSRM,
            to_varchar(json.value:PHONE_PTFSRT) as PhonePTFSRT,
            to_varchar(json.value:PHONE_PTHFS) as PhonePTHFS,
            to_varchar(json.value:PHONE_PTHFSM) as PhonePTHFSM,
            to_varchar(json.value:PHONE_PTHFST) as PhonePTHFST,
            to_varchar(json.value:PHONE_PTUFS) as PhonePTUFS,
            to_varchar(json.value:PHONE_PTFDPPEP) as PhonePTFDPPEP,
            to_varchar(json.value:PHONE_PTFDPPNP) as PhonePTFDPPNP
        FROM cte_swimlane as s
        , lateral flatten(input => s.displaypartnerjson) as json
),
CTE_Swimlane_Phones as (
    select
        s.facilitycode,
        s.clienttoproductcode,
        s.lastupdatedate,
        s.sourcecode,
        s.rowrank,
        s.DisplayPartnerCode,
        s.PhonePTFDS,
        s.PhonePTFDSM,
        s.PhonePTFDST,
        s.PhonePTFMC,
        s.PhonePTFMCM,
        s.PhonePTFMCT,
        s.PhonePTFMT,
        s.PhonePTFMTM,
        s.PhonePTFMTT,
        s.PhonePTFSR,
        s.PhonePTFSRD,
        s.PhonePTFSRDM,
        s.PhonePTFSRM,
        s.PhonePTFSRT,
        s.PhonePTHFS,
        s.PhonePTHFSM,
        s.PhonePTHFST,
        s.PhonePTUFS,
        s.PhonePTFDPPEP,
        s.PhonePTFDPPNP
    from cte_display_partner as S
        inner join base.syndicationpartner as SP on sp.syndicationpartnercode = s.displaypartnercode
)
    ,
    cte_tmp_phones as (
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDS' as PhoneTypeCode,
            PhonePTFDS as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFDS is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDSM' as PhoneTypeCode,
            PhonePTFDSM as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFDSM is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDST' as PhoneTypeCode,
            PhonePTFDST as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFDST is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMC' as PhoneTypeCode,
            PhonePTFMC as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFMC is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMCM' as PhoneTypeCode,
            PhonePTFMCM as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFMCM is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMCT' as PhoneTypeCode,
            PhonePTFMCT as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFMCT is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMT' as PhoneTypeCode,
            PhonePTFMT as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFMT is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMTM' as PhoneTypeCode,
            PhonePTFMTM as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFMTM is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMTT' as PhoneTypeCode,
            PhonePTFMTT as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFMTT is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSR' as PhoneTypeCode,
            PhonePTFSR as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFSR is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRD' as PhoneTypeCode,
            PhonePTFSRD as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFSRD is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRDM' as PhoneTypeCode,
            PhonePTFSRDM as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFSRDM is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRM' as PhoneTypeCode,
            PhonePTFSRM as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFSRM is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRT' as PhoneTypeCode,
            PhonePTFSRT as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFSRT is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFS' as PhoneTypeCode,
            PhonePTHFS as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTHFS is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFSM' as PhoneTypeCode,
            PhonePTHFSM as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTHFSM is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFST' as PhoneTypeCode,
            PhonePTHFST as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTHFST is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTUFS' as PhoneTypeCode,
            PhonePTUFS as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTUFS is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDPPEP' as PhoneTypeCode,
            PhonePTFDPPEP as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFDPPEP is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDPPNP' as PhoneTypeCode,
            PhonePTFDPPNP as PhoneNumber,
            sourcecode,
            lastupdatedate
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFDPPNP is not null
            and RowRank = 1
    )
    select 
        cpe.clientproducttoentityid,
        pt.phonetypeid as PhoneTypeID,
        p.phoneid as PhoneID,
        s.SourceCode,
        s.LastUpdateDate
    from
        cte_tmp_phones s
        join base.entitytype as ET on et.entitytypecode = 'FAC'
        join base.clienttoproduct as CTP on ctp.clienttoproductcode = s.clienttoproductcode
        join base.facility as f on f.facilitycode = s.facilitycode
        join base.clientproducttoentity cpe on ctp.clienttoproductid = cpe.clienttoproductid
        and et.entitytypeid = cpe.entitytypeid
        and f.facilityid = cpe.entityid
        join base.phone as P on s.phonenumber = p.phonenumber
        join base.phonetype as PT on s.phonetypecode = pt.phonetypecode
    where
        s.displaypartnercode = 'HG' 
    qualify row_number() over(partition by clientproducttoentityid, phonetypeid, phoneid order by s.lastupdatedate desc) = 1 $$;
        
select_statement_2 := $$  with cte_swimlane_phones as (
            SELECT
                p.ref_customer_product_code as clienttoproductcode,
                to_varchar(json.value:DISPLAY_PARTNER_CODE) as DisplayPartnerCode,
                to_varchar(json.value:PHONE_PTDES) as PhonePtdes,
                to_varchar(json.value:PHONE_PTDESM) as PhonePtdesm,
                to_varchar(json.value:PHONE_PTDEST) as PhonePtdest,
                to_varchar(json.value:PHONE_PTMTR) as PhonePtmtr,
                to_varchar(json.value:PHONE_PTMTRM) as PhonePtmtrm,
                to_varchar(json.value:PHONE_PTMTRT) as PhonePtmtrt,
                to_varchar(json.value:PHONE_PTMWC) as PhonePtmwc,
                to_varchar(json.value:PHONE_PTMWCM) as PhonePtmwcm,
                to_varchar(json.value:PHONE_PTMWCT) as PhonePtmwct,
                to_varchar(json.value:PHONE_PTPSR) as PhonePtpsr,
                to_varchar(json.value:PHONE_PTPSRM) as PhonePtpsrm,
                to_varchar(json.value:PHONE_PTPSRT) as PhonePtPsrt,
                to_varchar(json.value:PHONE_PTHOS) as PhonePtHos,
                to_varchar(json.value:PHONE_PTHOSM) as PhonePtHosM,
                to_varchar(json.value:PHONE_PTHOST) as PhonePtHost,
                to_varchar(json.value:PHONE_PTPSRD) as PhonePtPsrd,
                to_varchar(json.value:PHONE_PTEMP) as PhonePtEmp,
                to_varchar(json.value:PHONE_PTEMPM) as PhonePtEmpM,
                to_varchar(json.value:PHONE_PTEMPT) as PhonePtEmpt,
                to_varchar(json.value:PHONE_PTDPPEP) as PhonePtDpPep,
                to_varchar(json.value:PHONE_PTDPPNP) as PhonePtDpPnp,
                to_varchar(json.value:DATA_SOURCE_CODE) as sourcecode,
                to_timestamp_ntz(json.value:UPDATED_DATETIME) as LastUpdateDate
            FROM $$ || mdm_db || $$.mst.customer_product_profile_processing as p
            , lateral flatten(input => p.CUSTOMER_PRODUCT_PROFILE:DISPLAY_PARTNER) as json
            where DisplayPartnerCode is not null
        ),
        cte_tmp_phones as (
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTDES' as PhoneTypeCode,
                PhonePTDES as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTDES is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTDESM' as PhoneTypeCode,
                PhonePTDESM as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTDESM is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTDEST' as PhoneTypeCode,
                PhonePTDEST as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTDEST is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTEMP' as PhoneTypeCode,
                PhonePTEMP as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTEMP is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTEMPM' as PhoneTypeCode,
                PhonePTEMPM as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTEMPM is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTEMPT' as PhoneTypeCode,
                PhonePTEMPT as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTEMPT is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTHOS' as PhoneTypeCode,
                PhonePTHOS as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTHOS is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTHOSM' as PhoneTypeCode,
                PhonePTHOSM as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTHOSM is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTHOST' as PhoneTypeCode,
                PhonePTHOST as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTHOST is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTMTR' as PhoneTypeCode,
                PhonePTMTR as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTMTR is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTMTRT' as PhoneTypeCode,
                PhonePTMTRT as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTMTRT is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTMTRM' as PhoneTypeCode,
                PhonePTMTRM as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTMTRM is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTMWC' as PhoneTypeCode,
                PhonePTMWC as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTMWC is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTMWCT' as PhoneTypeCode,
                PhonePTMWCT as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTMWCT is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTMWCM' as PhoneTypeCode,
                PhonePTMWCM as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTMWCM is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTPSR' as PhoneTypeCode,
                PhonePTPSR as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTPSR is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTPSRD' as PhoneTypeCode,
                PhonePTPSRD as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTPSRD is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTPSRM' as PhoneTypeCode,
                PhonePTPSRM as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTPSRM is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTPSRT' as PhoneTypeCode,
                PhonePTPSRT as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTPSRT is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTDPPEP' as PhoneTypeCode,
                PhonePTDPPEP as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTDPPEP is not null
            union all
            select
                ClientToProductCode,
                DisplayPartnerCode,
                'PTDPPNP' as PhoneTypeCode,
                PhonePTDPPNP as PhoneNumber,
                sourcecode,
                lastupdatedate
            from
                cte_swimlane_phones
            where
                PhonePTDPPNP is not null
        )
        select 
            cpte.clientproducttoentityid,
            pt.phonetypeid,
            ph.phoneid,
            s.SourceCode,
            s.LastUpdateDate
        from
            cte_tmp_phones s
            inner join base.entitytype b on b.entitytypecode = 'CLPROD'
            inner join base.phone ph on ph.phonenumber = s.phonenumber
            inner join base.phonetype pt on pt.phonetypecode = s.phonetypecode
            inner join base.clienttoproduct CtP on ctp.clienttoproductcode = s.clienttoproductcode
            inner join base.clientproducttoentity CPtE on cpte.clienttoproductid = ctp.clienttoproductid
            and cpte.entitytypeid = b.entitytypeid
        where
            s.displaypartnercode = 'HG' 
        qualify row_number() over(partition by clientproducttoentityid, phonetypeid, phoneid order by s.lastupdatedate desc) = 1  $$;
            
select_statement_3 := $$  with Cte_office as (
            SELECT
                p.ref_provider_code as providercode,
                created_datetime as create_date,
                to_varchar(json.value:OFFICE_CODE) as Office_OfficeCode,
                to_varchar(json.value:DATA_SOURCE_CODE) as Office_SourceCode,
                to_timestamp_ntz(json.value:UPDATED_DATETIME) as Office_LastUpdateDate,
                to_varchar(json.value:OFFICE_RANK) as Office_OfficeRank,
                to_varchar(json.value:PHONE_NUMBER) as Office_PhoneNumber
            FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
            , lateral flatten(input => p.PROVIDER_PROFILE:OFFICE) as json
            where Office_OfficeCode is not null
        ),
    
        Cte_customer_product as (
            SELECT
                p.ref_provider_code as providercode,
                to_varchar(json.value:CUSTOMER_PRODUCT_CODE) as CustomerProduct_CustomerProductCode,
                to_varchar(json.value:DATA_SOURCE_CODE) as CustomerProduct_SourceCode,
                to_timestamp_ntz(json.value:UPDATED_DATETIME) as CustomerProduct_LastUpdateDate,
                to_varchar(json.value:DISPLAY_PARTNER) as CustomerProduct_DisplayPartner
            FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
            , lateral flatten(input => p.PROVIDER_PROFILE:CUSTOMER_PRODUCT) as json
        ),
        
       cte_json_data as (
            select
                o.create_date,
                o.ProviderCode,
                o.office_officecode as OfficeCode,
                o.office_phonenumber as PhoneNumber,
                cp.customerproduct_customerproductcode as ClientToProductCode,
                ifnull(ifnull(o.office_lastupdatedate, cp.customerproduct_lastupdatedate),sysdate()) as lastupdatedate,
                ifnull(ifnull(o.office_sourcecode, cp.customerproduct_sourcecode), 'Profisee') as sourcecode
            from
                cte_office as o
                join cte_customer_product as cp on cp.providercode = o.providercode

        )
        
        select 
                cpe.clientproducttoentityid,
                op.phoneid,
                op.phonetypeid,
                t.SourceCode,
                t.LastUpdateDate
            from
                cte_json_data t
                join base.entitytype et on et.entitytypecode = 'OFFICE'
                join base.office o on o.officecode = t.officecode
                join base.officetophone op on op.officeid = o.officeid
                -- join base.phone p on op.phoneid = p.phoneid
                -- join base.phonetype pt on pt.phonetypeid = op.phonetypeid
                join base.clienttoproduct cp on cp.clienttoproductcode = t.clienttoproductcode
                join base.clientproducttoentity cpe on cpe.entitytypeid = et.entitytypeid
                    and cpe.entityid = o.officeid
                    and cpe.clienttoproductid = cp.clienttoproductid
            qualify row_number() over(partition by clientproducttoentityid, phonetypeid, phoneid order by t.lastupdatedate desc) = 1 $$;
            
--- update Statement
    update_statement := '
        update
        SET
            SourceCode = source.sourcecode,
            LastUpdateDate = source.lastupdatedate';
            
--- insert Statement
    insert_statement := ' 
        insert(
            ClientProductEntityToPhoneID,
            ClientProductToEntityID,
            PhoneTypeID,
            PhoneID,
            SourceCode,
            LastUpdateDate
        )
        values
        (
            utils.generate_uuid(ClientProductToEntityID || PhoneTypeID || PhoneID), 
            ClientProductToEntityID,
            PhoneTypeID,
            PhoneID,
            SourceCode,
            LastUpdateDate
        )';
        
    ---------------------------------------------------------
    --------- 4. actions (inserts and updates) --------------
    ---------------------------------------------------------
    
    merge_statement_1 := ' merge into base.clientproductentitytophone as target using
                   (' || select_statement_1 || ') as source 
                    on source.clientproducttoentityid = target.clientproducttoentityid AND source.PhoneTypeID = target.PhoneTypeID AND source.PhoneID = target.PhoneID
                    when matched then ' || update_statement || '
                    when not matched then ' || insert_statement;
                    
    merge_statement_2 := ' merge into base.clientproductentitytophone as target using
                   (' || select_statement_2 || ') as source 
                    on source.clientproducttoentityid = target.clientproducttoentityid AND source.PhoneTypeID = target.PhoneTypeID AND source.PhoneID = target.PhoneID
                    when matched then ' || update_statement || '
                    when not matched then ' || insert_statement;
                    
    merge_statement_3 := ' merge into base.clientproductentitytophone as target using 
                   (' || select_statement_3 || ') as source 
                    on source.clientproducttoentityid = target.clientproducttoentityid AND source.PhoneTypeID = target.PhoneTypeID AND source.PhoneID = target.PhoneID
                    when matched then ' || update_statement || '
                    when not matched then ' || insert_statement;
                    
    ---------------------------------------------------------
    ------------------- 5. execution ------------------------
    ---------------------------------------------------------

    if (is_full) then
        truncate table base.clientproductentitytophone;
    end if; 
    execute immediate merge_statement_1;
    execute immediate merge_statement_2;
    execute immediate merge_statement_3;
    
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
