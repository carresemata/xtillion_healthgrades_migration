create or replace view ODS1_STAGE_TEAM.BASE.VW_SWIMLANE_BASE_CLIENT
as

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.vw_Swimlane_Base_Client depends on: 
--- MDM_TEAM.MST.CUSTOMER_PRODUCT_PROFILE_PROCESSING 

---------------------------------------------------------
-------------------- 1. Columns -------------------------
---------------------------------------------------------

with cte_processing as (
    SELECT
        Process.MST_CUSTOMER_PRODUCT_PROFILE_ID AS MST_id,
        Process.CREATED_DATETIME,
        Process.REF_CUSTOMER_PRODUCT_CODE AS CustomerProductCode,
        SPLIT_PART(CustomerProductCode, '-', 1) AS ClientCode,
        SPLIT_PART(CustomerProductCode, '-', 2) AS ProductCode,
        Process.CUSTOMER_PRODUCT_PROFILE,
    
        -- Feature
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].CUSTOMER_NAME) AS Feature_CustomerName,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].QUEUE_SIZE) AS Feature_QueueSize,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].OAS_URL_PATH) AS Feature_OasUrlPath,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].REF_OAS_PARTNER_TYPE_CODE) AS Feature_RefOasPartnerTypeCode,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCBFN) AS Feature_FeatureFcbfn,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCBRL) AS Feature_FeatureFcbrl,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCCCP_FVCLT) AS Feature_FeatureFcccpFvclt,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCCCP_FVFAC) AS Feature_FeatureFcccpFvfac,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCCCP_FVOFFICE) AS Feature_FeatureFcccpFvoffice,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCCLLOGO) AS Feature_FeatureFccllogo,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCCWALL) AS Feature_FeatureFccwall,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCCLURL) AS Feature_FeatureFcclurl,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCDISLOC) AS Feature_FeatureFcdisloc,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCDOA) AS Feature_FeatureFcdoa,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCDOS_FVFAX) AS Feature_FeatureFcdosFvfax,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCDOS_FVMMPEML) AS Feature_FeatureFcdosFvmmpeml,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCDTP) AS Feature_FeatureFcdtp,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCEOARD) AS Feature_FeatureFceoard,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCEPR) AS Feature_FeatureFcepr,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCOOACP) AS Feature_FeatureFcooacp,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCLOT) AS Feature_FeatureFclot,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCMAR) AS Feature_FeatureFcmar,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCMWC) AS Feature_FeatureFcmwc,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCNPA) AS Feature_FeatureFcnpa,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCOAS) AS Feature_FeatureFcoas,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCOASURL) AS Feature_FeatureFcoasurl,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCOASVT) AS Feature_FeatureFcoasvt,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCOBT) AS Feature_FeatureFcobt,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCODC_FVDFC) AS Feature_FeatureFcodcFvdfc,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCODC_FVDPR) AS Feature_FeatureFcodcFvdpr,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCODC_FVMT) AS Feature_FeatureFcodcFvmt,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCODC_FVPSR) AS Feature_FeatureFcodcFvpsr,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCPNI) AS Feature_FeatureFcpni,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCPQM) AS Feature_FEATURE_FCPQM,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCPQM) AS Feature_FeatureFcpqm,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCREL_FVCPOFFICE) AS Feature_FeatureFcrelFvcpoffice,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCREL_FVCPTOCC) AS Feature_FeatureFcrelFvcptocc,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCREL_FVCPTOFAC) AS Feature_FeatureFcrelFvcptofac,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCREL_FVCPTOPRAC) AS Feature_FeatureFcrelFvcptoprac,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCREL_FVCPTOPROV) AS Feature_FeatureFcrelFvcptoprov,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCREL_FVPRACOFF) AS Feature_FeatureFcrelFvpracoff,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCREL_FVPROVFAC) AS Feature_FeatureFcrelFvprovfac,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCREL_FVPROVOFF) AS Feature_FeatureFcrelFvprovoff,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCSPC) AS Feature_FeatureFcspc,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCOOPSR) AS Feature_FeatureFcoopsr,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].FEATURE_FCOOMT) AS Feature_FeatureFcoomt,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].ACTIVATION_FLAG) AS Feature_ActivationFlag,
        TO_VARCHAR(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].DATA_SOURCE_CODE) AS Feature_SourceCode,
        TO_TIMESTAMP_NTZ(Process.CUSTOMER_PRODUCT_PROFILE:FEATURE[0].UPDATED_DATETIME) AS Feature_LastUpdateDate
    FROM
        MDM_TEAM.MST.CUSTOMER_PRODUCT_PROFILE_PROCESSING AS Process
    WHERE
        Process.REF_CUSTOMER_PRODUCT_CODE IS NOT NULL
    )
    
    select
        cte.created_datetime, -- this should be create_Date
        -- RELTIO_ID as ReltioEntityID,
        replace(cte.CUSTOMERPRODUCTCODE, ' ', '') as CustomerProductCode,
        --cp.ClientToProductID,
        cte.ClientCode,
        cte.ProductCode,
        cte.CUSTOMER_PRODUCT_PROFILE as CustomerProductJSON,
        cte.FEATURE_CUSTOMERNAME AS CustomerName,
        TO_NUMBER(cte.FEATURE_QUEUESIZE) AS QueueSize,
        cte.FEATURE_LASTUPDATEDATE AS LastUpdateDate,
        cte.FEATURE_SOURCECODE AS SourceCode,
        cte.FEATURE_ACTIVATIONFLAG AS ActiveFlag,
        cte.FEATURE_OASURLPATH AS OASURLPath,
        cte.FEATURE_REFOASPARTNERTYPECODE AS OASPartnerTypeCode,
        CASE WHEN cte.FEATURE_FEATUREFCBFN IN ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCBFN,
        REPLACE(REPLACE( cte.FEATURE_FEATUREFCBRL,'Customer', 'FVCLT'), 'Facility',  'FVFAC') AS FeatureFCBRL,
        CASE WHEN cte.FEATURE_FEATUREFCCCPFVCLT IN ('true', 'FVYES', 'FVCLT') then 'FVCLT' else null end AS FeatureFCCCP_FVCLT,
        CASE WHEN cte.FEATURE_FEATUREFCCCPFVFAC IN ('true', 'FVYES', 'FVFAC') then 'FVFAC' else null end AS FeatureFCCCP_FVFAC,
        CASE WHEN cte.FEATURE_FEATUREFCCCPFVOFFICE in ('true', 'FVYES', 'FVOFFICE') then 'FVOFFICE' else null end AS FeatureFCCCP_FVOFFICE,
        cte.FEATURE_FEATUREFCCLLOGO AS FeatureFCCLLOGO,
        cte.FEATURE_FEATUREFCCWALL AS FeatureFCCWALL,
        cte.FEATURE_FEATUREFCCLURL AS FeatureFCCLURL,
        cte.FEATURE_FEATUREFCDISLOC AS FeatureFCDISLOC,
        CASE WHEN cte.FEATURE_FEATUREFCDOA in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCDOA,
        CASE WHEN cte.FEATURE_FEATUREFCDOSFVFAX in ('true', 'FVYES', 'FVFAX') then 'FVFAX' else null end AS FeatureFCDOS_FVFAX,
        CASE WHEN cte.FEATURE_FEATUREFCDOSFVMMPEML in ('true', 'FVYES', 'FVMMPEML') then 'FVMMPEML' else null end AS FeatureFCDOS_FVMMPEML,
        cte.FEATURE_FEATUREFCDTP AS FeatureFCDTP,
        CASE WHEN cte.FEATURE_FEATUREFCEOARD in ('true', 'FVYES', 'FVAQSTD') then 'FVAQSTD' else null end AS FeatureFCEOARD,
        CASE WHEN cte.FEATURE_FEATUREFCEPR in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCEPR,
        CASE WHEN cte.FEATURE_FEATUREFCOOACP in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCOOACP,
        cte.FEATURE_FEATUREFCLOT AS FeatureFCLOT,
        cte.FEATURE_FEATUREFCMAR AS FeatureFCMAR,
        CASE WHEN cte.FEATURE_FEATUREFCMWC in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCMWC,
        CASE WHEN cte.FEATURE_FEATUREFCNPA in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCNPA,
        CASE WHEN cte.FEATURE_FEATUREFCOAS in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCOAS,
        cte.FEATURE_FEATUREFCOASURL AS FeatureFCOASURL,
        cte.FEATURE_FEATUREFCOASVT AS FeatureFCOASVT,
        cte.FEATURE_FEATUREFCOBT AS FeatureFCOBT,
        CASE WHEN cte.FEATURE_FEATUREFCODCFVDFC in ('true', 'FVYES', 'FVDFC') then 'FVDFC' else null end AS FeatureFCODC_FVDFC,
        CASE WHEN cte.FEATURE_FEATUREFCODCFVDPR in ('true', 'FVYES', 'FVDPR') then 'FVDPR' else null end AS FeatureFCODC_FVDPR,
        CASE WHEN cte.FEATURE_FEATUREFCODCFVMT in ('true', 'FVYES', 'FVMT') then 'FVMT' else null end AS FeatureFCODC_FVMT,
        CASE WHEN cte.FEATURE_FEATUREFCODCFVPSR in ('true', 'FVYES', 'FVPSR') then 'FVPSR' else null end AS FeatureFCODC_FVPSR,
        CASE WHEN cte.FEATURE_FEATUREFCPNI in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCPNI,
        CASE WHEN cte.FEATURE_FEATUREFCPQM in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCPQM,
        CASE WHEN cte.FEATURE_FEATUREFCRELFVCPOFFICE in ('true', 'FVYES', 'FVCPOFFICE') then 'FVCPOFFICE' else null end AS FeatureFCREL_FVCPOFFICE,
        CASE WHEN cte.FEATURE_FEATUREFCRELFVCPTOCC in ('true', 'FVYES', 'FVCPTOCC') then 'FVCPTOCC' else null end AS FeatureFCREL_FVCPTOCC,
        CASE WHEN cte.FEATURE_FEATUREFCRELFVCPTOFAC in ('true', 'FVYES', 'FVCPTOFAC') then 'FVCPTOFAC' else null end AS FeatureFCREL_FVCPTOFAC,
        CASE WHEN cte.FEATURE_FEATUREFCRELFVCPTOPRAC in ('true', 'FVYES', 'FVCPTOPRAC') then 'FVCPTOPRAC' else null end AS FeatureFCREL_FVCPTOPRAC,
        CASE WHEN cte.FEATURE_FEATUREFCRELFVCPTOPROV in ('true', 'FVYES', 'FVCPTOPROV') then 'FVCPTOPROV' else null end AS FeatureFCREL_FVCPTOPROV,
        CASE WHEN cte.FEATURE_FEATUREFCRELFVPRACOFF in ('true', 'FVYES', 'FVPRACOFF') then 'FVPRACOFF' else null end AS FeatureFCREL_FVPRACOFF,
        CASE WHEN cte.FEATURE_FEATUREFCRELFVPROVFAC in ('true', 'FVYES', 'FVPROVFAC') then 'FVPROVFAC' else null end AS FeatureFCREL_FVPROVFAC,
        CASE WHEN cte.FEATURE_FEATUREFCRELFVPROVOFF in ('true', 'FVYES', 'FVPROVOFF') then 'FVPROVOFF' else null end AS FeatureFCREL_FVPROVOFF,
        cte.FEATURE_FEATUREFCSPC AS FeatureFCSPC,
        CASE WHEN cte.FEATURE_FEATUREFCOOPSR in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCOOPSR,
        CASE WHEN cte.FEATURE_FEATUREFCOOMT in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCOOMT
    from
        cte_processing as cte;

        