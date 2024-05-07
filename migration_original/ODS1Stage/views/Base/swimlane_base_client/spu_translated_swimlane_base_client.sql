create or replace view ODS1_STAGE.BASE.SWIMLANE_BASE_CLIENT(
	CREATED_DATETIME,
	CUSTOMERPRODUCTCODE,
	CLIENTTOPRODUCTID,
	CLIENTCODE,
    PRODUCTCODE,
	CUSTOMERPRODUCTJSON,
	CUSTOMERNAME,
	QUEUESIZE,
	LASTUPDATEDATE,
	SOURCECODE,
	ACTIVEFLAG,
	OASURLPATH,
	OASPARTNERTYPECODE,
	FEATUREFCBFN,
	FEATUREFCBRL,
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
	-- DISPLAYPARTNERJSON,
	FEATUREFCOOPSR,
	FEATUREFCOOMT
) as(

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.Swimlane_Base_Client depends on: 
--- Raw.VW_CUSTOMER_PRODUCT_PROFILE
--- Base.ClientToProduct

---------------------------------------------------------
-------------------- 1. Columns -------------------------
---------------------------------------------------------


    select
        vw.create_date AS created_datetime, -- this should be create_Date
        -- RELTIO_ID as ReltioEntityID,
        replace(vw.CUSTOMERPRODUCTCODE, ' ', '') as CustomerProductCode,
        cp.ClientToProductID,
        vw.ClientCode,
        vw.ProductCode,
        vw.CUSTOMER_PRODUCT_PROFILE as CustomerProductJSON,
        vw.FEATURE_CUSTOMERNAME AS CustomerName,
        TO_NUMBER(vw.FEATURE_QUEUESIZE) AS QueueSize,
        vw.FEATURE_LASTUPDATEDATE AS LastUpdateDate,
        vw.FEATURE_SOURCECODE AS SourceCode,
        vw.FEATURE_ACTIVATIONFLAG AS ActiveFlag,
        vw.FEATURE_OASURLPATH AS OASURLPath,
        vw.FEATURE_REFOASPARTNERTYPECODE AS OASPartnerTypeCode,
        CASE WHEN vw.FEATURE_FEATUREFCBFN IN ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCBFN,
        REPLACE(REPLACE( vw.FEATURE_FEATUREFCBRL,'Customer', 'FVCLT'), 'Facility',  'FVFAC') AS FeatureFCBRL,
        CASE WHEN vw.FEATURE_FEATUREFCCCPFVCLT IN ('true', 'FVYES', 'FVCLT') then 'FVCLT' else null end AS FeatureFCCCP_FVCLT,
        CASE WHEN vw.FEATURE_FEATUREFCCCPFVFAC IN ('true', 'FVYES', 'FVFAC') then 'FVFAC' else null end AS FeatureFCCCP_FVFAC,
        CASE WHEN vw.FEATURE_FEATUREFCCCPFVOFFICE in ('true', 'FVYES', 'FVOFFICE') then 'FVOFFICE' else null end AS FeatureFCCCP_FVOFFICE,
        vw.FEATURE_FEATUREFCCLLOGO AS FeatureFCCLLOGO,
        vw.FEATURE_FEATUREFCCWALL AS FeatureFCCWALL,
        vw.FEATURE_FEATUREFCCLURL AS FeatureFCCLURL,
        vw.FEATURE_FEATUREFCDISLOC AS FeatureFCDISLOC,
        CASE WHEN vw.FEATURE_FEATUREFCDOA in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCDOA,
        CASE WHEN vw.FEATURE_FEATUREFCDOSFVFAX in ('true', 'FVYES', 'FVFAX') then 'FVFAX' else null end AS FeatureFCDOS_FVFAX,
        CASE WHEN vw.FEATURE_FEATUREFCDOSFVMMPEML in ('true', 'FVYES', 'FVMMPEML') then 'FVMMPEML' else null end AS FeatureFCDOS_FVMMPEML,
        vw.FEATURE_FEATUREFCDTP AS FeatureFCDTP,
        CASE WHEN vw.FEATURE_FEATUREFCEOARD in ('true', 'FVYES', 'FVAQSTD') then 'FVAQSTD' else null end AS FeatureFCEOARD,
        CASE WHEN vw.FEATURE_FEATUREFCEPR in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCEPR,
        CASE WHEN vw.FEATURE_FEATUREFCOOACP in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCOOACP,
        vw.FEATURE_FEATUREFCLOT AS FeatureFCLOT,
        vw.FEATURE_FEATUREFCMAR AS FeatureFCMAR,
        CASE WHEN vw.FEATURE_FEATUREFCMWC in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCMWC,
        CASE WHEN vw.FEATURE_FEATUREFCNPA in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCNPA,
        CASE WHEN vw.FEATURE_FEATUREFCOAS in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCOAS,
        vw.FEATURE_FEATUREFCOASURL AS FeatureFCOASURL,
        vw.FEATURE_FEATUREFCOASVT AS FeatureFCOASVT,
        vw.FEATURE_FEATUREFCOBT AS FeatureFCOBT,
        CASE WHEN vw.FEATURE_FEATUREFCODCFVDFC in ('true', 'FVYES', 'FVDFC') then 'FVDFC' else null end AS FeatureFCODC_FVDFC,
        CASE WHEN vw.FEATURE_FEATUREFCODCFVDPR in ('true', 'FVYES', 'FVDPR') then 'FVDPR' else null end AS FeatureFCODC_FVDPR,
        CASE WHEN vw.FEATURE_FEATUREFCODCFVMT in ('true', 'FVYES', 'FVMT') then 'FVMT' else null end AS FeatureFCODC_FVMT,
        CASE WHEN vw.FEATURE_FEATUREFCODCFVPSR in ('true', 'FVYES', 'FVPSR') then 'FVPSR' else null end AS FeatureFCODC_FVPSR,
        CASE WHEN vw.FEATURE_FEATUREFCPNI in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCPNI,
        CASE WHEN vw.FEATURE_FEATURE_FCPQM in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCPQM,
        CASE WHEN vw.FEATURE_FEATUREFCRELFVCPOFFICE in ('true', 'FVYES', 'FVCPOFFICE') then 'FVCPOFFICE' else null end AS FeatureFCREL_FVCPOFFICE,
        CASE WHEN vw.FEATURE_FEATUREFCRELFVCPTOCC in ('true', 'FVYES', 'FVCPTOCC') then 'FVCPTOCC' else null end AS FeatureFCREL_FVCPTOCC,
        CASE WHEN vw.FEATURE_FEATUREFCRELFVCPTOFAC in ('true', 'FVYES', 'FVCPTOFAC') then 'FVCPTOFAC' else null end AS FeatureFCREL_FVCPTOFAC,
        CASE WHEN vw.FEATURE_FEATUREFCRELFVCPTOPRAC in ('true', 'FVYES', 'FVCPTOPRAC') then 'FVCPTOPRAC' else null end AS FeatureFCREL_FVCPTOPRAC,
        CASE WHEN vw.FEATURE_FEATUREFCRELFVCPTOPROV in ('true', 'FVYES', 'FVCPTOPROV') then 'FVCPTOPROV' else null end AS FeatureFCREL_FVCPTOPROV,
        CASE WHEN vw.FEATURE_FEATUREFCRELFVPRACOFF in ('true', 'FVYES', 'FVPRACOFF') then 'FVPRACOFF' else null end AS FeatureFCREL_FVPRACOFF,
        CASE WHEN vw.FEATURE_FEATUREFCRELFVPROVFAC in ('true', 'FVYES', 'FVPROVFAC') then 'FVPROVFAC' else null end AS FeatureFCREL_FVPROVFAC,
        CASE WHEN vw.FEATURE_FEATUREFCRELFVPROVOFF in ('true', 'FVYES', 'FVPROVOFF') then 'FVPROVOFF' else null end AS FeatureFCREL_FVPROVOFF,
        vw.FEATURE_FEATUREFCSPC AS FeatureFCSPC,
        CASE WHEN vw.FEATURE_FEATUREFCOOPSR in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCOOPSR,
        CASE WHEN vw.FEATURE_FEATUREFCOOMT in ('true', 'FVYES') then 'FVYES' else 'FVNO' end AS FeatureFCOOMT
    from
        raw.vw_customer_product_profile as vw
        join base.clienttoproduct as cp on vw.CUSTOMERPRODUCTCODE = cp.clienttoproductcode
    where
        vw.CUSTOMERPRODUCTCODE IS NOT NULL
);