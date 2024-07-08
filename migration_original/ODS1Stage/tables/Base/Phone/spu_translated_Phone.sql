CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PHONE(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

-- base.phone depends on:
--- mdm_team.mst.customer_product_profile_processing (base.vw_swimlane_base_client)
--- mdm_team.mst.office_profile_processing 
--- mdm_team.mst.facility_profile_processing 
--- base.facility
--- base.clienttoproduct
--- base.syndicationpartner

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement_1 string; 
    merge_statement_1 string; 
    select_statement_2 string; 
    merge_statement_2 string;
    select_statement_3 string; 
    merge_statement_3 string;
    insert_statement string;
    update_statement string;
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_phone');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
begin
    
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement_1 := $$  with cte_swimlane as (
    select
        *
    from
        base.vw_swimlane_base_client qualify dense_rank() over(
            partition by customerproductcode
            order by
                LastUpdateDate
        ) = 1
),
Cte_display_partner as (
    SELECT
        p.ref_customer_product_code as customerproductcode,
        to_varchar(json.value:DISPLAY_PARTNER_CODE) as DisplayPartner_DisplayPartnerCode,
        to_varchar(json.value:PHONE_PTDES) as DisplayPartner_PhonePtdes,
        to_varchar(json.value:PHONE_PTDESM) as DisplayPartner_PhonePtdesm,
        to_varchar(json.value:PHONE_PTDEST) as DisplayPartner_PhonePtdest,
        to_varchar(json.value:PHONE_PTMTR) as DisplayPartner_PhonePtmtr,
        to_varchar(json.value:PHONE_PTMTRM) as DisplayPartner_PhonePtmtrm,
        to_varchar(json.value:PHONE_PTMTRT) as DisplayPartner_PhonePtmtrt,
        to_varchar(json.value:PHONE_PTMWC) as DisplayPartner_PhonePtmwc,
        to_varchar(json.value:PHONE_PTMWCM) as DisplayPartner_PhonePtmwcm,
        to_varchar(json.value:PHONE_PTMWCT) as DisplayPartner_PhonePtmwct,
        to_varchar(json.value:PHONE_PTPSR) as DisplayPartner_PhonePtpsr,
        to_varchar(json.value:PHONE_PTPSRM) as DisplayPartner_PhonePtpsrm,
        to_varchar(json.value:PHONE_PTPSRT) as DisplayPartner_PhonePtPsrt,
        to_varchar(json.value:PHONE_PTHOS) as DisplayPartner_PhonePtHos,
        to_varchar(json.value:PHONE_PTHOSM) as DisplayPartner_PhonePtHosM,
        to_varchar(json.value:PHONE_PTHOST) as DisplayPartner_PhonePtHost,
        to_varchar(json.value:PHONE_PTPSRD) as DisplayPartner_PhonePtPsrd,
        to_varchar(json.value:PHONE_PTEMP) as DisplayPartner_PhonePtEmp,
        to_varchar(json.value:PHONE_PTEMPM) as DisplayPartner_PhonePtEmpM,
        to_varchar(json.value:PHONE_PTEMPT) as DisplayPartner_PhonePtEmpt,
        to_varchar(json.value:PHONE_PTDPPEP) as DisplayPartner_PhonePtDpPep,
        to_varchar(json.value:PHONE_PTDPPNP) as DisplayPartner_PhonePtDpPnp,
        to_varchar(json.value:DATA_SOURCE_CODE) as DisplayPartner_SourceCode,
        to_timestamp_ntz(json.value:UPDATED_DATETIME) as DisplayPartner_LastUpdateDate
    FROM $$ || mdm_db || $$.mst.customer_product_profile_processing as p
    , lateral flatten(input => p.CUSTOMER_PRODUCT_PROFILE:DISPLAY_PARTNER) as json
),

CTE_Swimlane_Phones as (
    select
        s.customerproductcode as ClientToProductcode,
        s.productcode,
        json.displaypartner_DISPLAYPARTNERCODE as DisplayPartnerCode,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTDES END as PhonePTDES,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTDESM END as PhonePTDESM,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTDEST END as PhonePTDEST,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTEMP END as PhonePTEMP,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTEMPM END as PhonePTEMPM,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTEMPT END as PhonePTEMPT,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTHOS END as PhonePTHOS,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTHOSM END as PhonePTHOSM,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTHOST END as PhonePTHOST,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTMTR END as PhonePTMTR,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTMTRT END as PhonePTMTRT,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTMTRM END as PhonePTMTRM,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTMWC END as PhonePTMWC,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTMWCT END as PhonePTMWCT,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTMWCM END as PhonePTMWCM,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTPSR END as PhonePTPSR,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTPSRD END as PhonePTPSRD,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTPSRM END as PhonePTPSRM,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTPSRT END as PhonePTPSRT,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTDPPEP END as PhonePTDPPEP,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTDPPNP END as PhonePTDPPNP,
        json.DisplayPartner_LastUpdateDate as LastUpdateDate,
        json.DisplayPartner_SourceCode as sourcecode
    from CTE_swimlane as S
        left join cte_display_partner as JSON on json.customerproductcode = s.customerproductcode
        inner join base.syndicationpartner as SP on sp.syndicationpartnercode = json.displaypartner_DISPLAYPARTNERCODE 
)
,
cte_tmp_phones as (
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTDES' as PhoneTypeCode,
            PhonePTDES as PhoneNumber,
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
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
            lastupdatedate,
            sourcecode
        from
            cte_swimlane_phones
        where
            PhonePTDPPNP is not null
    )
select 
    distinct 
        sourcecode, 
        phonenumber, 
        lastupdatedate 
from cte_tmp_phones 
qualify row_number() over(partition by phonenumber order by lastupdatedate desc) = 1 $$;



select_statement_2 := $$ with Cte_phone as (
                        SELECT
                            p.ref_office_code as officecode,
                            p.CREATED_DATETIME as create_date,
                            to_varchar(json.value:PHONE_NUMBER) as Phone_PhoneNumber,
                            to_varchar(json.value:DATA_SOURCE_CODE) as Phone_SourceCode,
                            to_timestamp_ntz(json.value:UPDATED_DATETIME) as Phone_LastUpdateDate
                        FROM $$ || mdm_db || $$.mst.office_profile_processing as p
                        , lateral flatten(input => p.OFFICE_PROFILE:PHONE) as json
                    )
                    select distinct
                            CASE WHEN LENGTH(json.phone_PHONENUMBER) > 15 then SUBSTRING(json.phone_PHONENUMBER, 1, POSITION('x' IN json.phone_PHONENUMBER)) else json.phone_PHONENUMBER END as PhoneNumber,
                            ifnull(json.phone_SOURCECODE, 'Profisee') as SourceCode,
                            json.phone_LASTUPDATEDATE as LastUpdateDate
                        from cte_phone as JSON
                        qualify row_number() over(partition by json.phone_phonenumber order by Phone_LastUpdateDate desc) = 1  $$;


                        
select_statement_3 := $$ with Cte_customer_product as (
    SELECT
        p.ref_facility_code as facilitycode,
        to_varchar(json.value:CUSTOMER_PRODUCT_CODE) as CustomerProduct_CustomerProductCode,
        to_varchar(json.value:FEATURE_FCCLLOGO) as CustomerProduct_FeatureFcclLogo,
        to_varchar(json.value:FEATURE_FCCLURL) as CustomerProduct_FeatureFcclUrl,
        to_timestamp_ntz(json.value:DESIGNATED_DATETIME) as CustomerProduct_DesignatedDatetime,
        to_varchar(json.value:FEATURE_FCFLOGO) as CustomerProduct_FeatureFcfLogo,
        to_varchar(json.value:FEATURE_FCFURL) as CustomerProduct_FeatureFcfUrl,
        to_varchar(json.value:OPT_OUT) as CustomerProduct_OptOut,
        to_varchar(json.value:DATA_SOURCE_CODE) as CustomerProduct_SourceCode,
        to_timestamp_ntz(json.value:UPDATED_DATETIME) as CustomerProduct_LastUpdateDate,
        parse_json(json.value:DISPLAY_PARTNER) as displaypartnerjson
    FROM $$ || mdm_db || $$.mst.facility_profile_processing as p
    , lateral flatten(input => p.FACILITY_PROFILE:CUSTOMER_PRODUCT) as json
),

CTE_Swimlane as (
    select distinct
        f.facilityid,
        json.facilitycode,
        cp.clienttoproductid,
        json.customerproduct_CUSTOMERPRODUCTCODE as ClientToProductCode,
        -- ReltioEntityId
        json.DisplayPartnerJSON,
        -- FeatureFCCIURL
        json.customerproduct_FEATUREFCCLURL as FeatureFCCLURL,
        json.customerproduct_FEATUREFCCLLOGO as FeatuerFCCLLOGO,
        json.customerproduct_FEATUREFCFLOGO as FeatureFCFLogo,
        json.customerproduct_FEATUREFCFURL as FeatureFCFURL,
        ifnull(json.customerproduct_SOURCECODE, 'Profisee') as SourceCode,
        ifnull(json.customerproduct_LASTUPDATEDATE, sysdate()) as LastUpdateDate
    from cte_customer_product as JSON
        join base.facility as F on f.facilitycode = json.facilitycode
        join base.clienttoproduct as cp on cp.clienttoproductcode = json.customerproduct_CUSTOMERPRODUCTCODE
),

cte_display_partner as 
    (SELECT
        s.facilitycode,
        s.clienttoproductcode,
        s.lastupdatedate,
        s.sourcecode,
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
),

cte_tmp_phones as (
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDS' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFDS as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFDS is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDSM' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFDSM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFDSM is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDST' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFDST as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFDST is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMC' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFMC as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFMC is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMCM' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFMCM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFMCM is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMCT' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFMCT as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFMCT is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMT' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFMT as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFMT is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMTM' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFMTM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFMTM is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMTT' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFMTT as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFMTT is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSR' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFSR as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFSR is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRD' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFSRD as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFSRD is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRDM' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFSRDM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFSRDM is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRM' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFSRM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFSRM is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRT' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFSRT as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFSRT is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFS' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTHFS as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTHFS is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFSM' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTHFSM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTHFSM is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFST' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTHFST as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTHFST is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTUFS' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTUFS as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTUFS is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDPPEP' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFDPPEP as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFDPPEP is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDPPNP' as PhoneTypeCode,
            LastUpdateDate,
            sourcecode,
            PhonePTFDPPNP as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFDPPNP is not null
    )
    
    select 
        distinct 
            phonenumber, 
            sourcecode, 
            lastupdatedate 
    from cte_tmp_phones  
    qualify row_number() over(partition by phonenumber order by lastupdatedate desc) = 1 $$;


    -- insert statement
    insert_statement := ' insert (
                            PhoneId,
                            PhoneNumber,
                            SourceCode,
                            LastUpdateDate)
                         values (
                            utils.generate_uuid(source.phonenumber), -- done
                            source.phonenumber,
                            source.sourcecode,
                            source.lastupdatedate)';

     -- update statement
     update_statement := ' update
                            set
                                target.sourcecode = source.sourcecode,
                                target.lastupdatedate = source.lastupdatedate';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement_1 := ' merge into base.phone as target using 
                   ('||select_statement_1||') as source 
                   on source.phonenumber = target.phonenumber 
                   when matched then ' || update_statement || '
                   when not matched then' || insert_statement;

merge_statement_2 := ' merge into base.phone as target using 
                   ('||select_statement_2||') as source 
                   on source.phonenumber = target.phonenumber 
                   when matched then ' || update_statement || '
                   when not matched then' || insert_statement;

merge_statement_3 := ' merge into base.phone as target using 
                   ('||select_statement_3||') as source 
                   on source.phonenumber = target.phonenumber 
                   when matched then ' || update_statement || '
                   when not matched then' || insert_statement;                            
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.Phone;
end if; 
execute immediate merge_statement_1 ;
execute immediate merge_statement_2 ;
execute immediate merge_statement_3 ;

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