CREATE OR REPLACE MATERIALIZED VIEW ODS1_STAGE.RAW.VW_FACILITY_PROFILE AS (

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

--- Raw.FACILITY_PROFILE_PROCESSING

---------------------------------------------------------
-------------------- 1. JSON Keys -----------------------
---------------------------------------------------------

--- Address
--- Customer Product
--- Demographics
--- Facility Service
--- Facility Profile
--- Hours
--- Image
--- Language
--- Syndication

SELECT  
    Process.MST_FACILITY_PROFILE_ID AS MST_id,
    Process.CREATED_DATETIME AS CREATE_DATE,
    Process.REF_FACILITY_CODE AS FacilityCode,
    Process.FACILITY_PROFILE,

    -- Address
    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].ADDRESS_TYPE_CODE) AS Address_AddressTypeCode,
    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].ADDRESS_LINE_1) AS Address_AddressLine1,
    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].ADDRESS_LINE_2) AS Address_AddressLine2,
    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].SUITE) AS Address_Suite,
    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].CITY) AS Address_City,
    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].STATE) AS Address_State,
    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].ZIP) AS Address_PostalCode,
    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].LATITUDE) AS Address_Latitude,
    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].LONGITUDE) AS Address_Longitude,
    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].TIME_ZONE) AS Address_TimeZone,
    TO_BOOLEAN(Process.FACILITY_PROFILE:ADDRESS[0].IS_PO_BOX) AS Address_IsPOBox,
    TO_BOOLEAN(Process.FACILITY_PROFILE:ADDRESS[0].IS_MILITARY) AS Address_IsMilitary,
    TO_BOOLEAN(Process.FACILITY_PROFILE:ADDRESS[0].IS_ROOFTOP_GEOCODE) AS Address_IsRooftopGeocode,
    TO_BOOLEAN(Process.FACILITY_PROFILE:ADDRESS[0].IS_MISSING_SUITE) AS Address_IsMissingSuite,
    TO_BOOLEAN(Process.FACILITY_PROFILE:ADDRESS[0].IS_INVALID_SUITE) AS Address_IsInvalidSuite,
    TO_BOOLEAN(Process.FACILITY_PROFILE:ADDRESS[0].IS_RESIDENTIAL) AS Address_IsResidential,
    TO_BOOLEAN(Process.FACILITY_PROFILE:ADDRESS[0].IS_VALID_ADDRESS) AS Address_IsValidAddress,
    TO_VARCHAR(Process.FACILITY_PROFILE:ADDRESS[0].DATA_SOURCE_CODE) AS Address_SourceCode,
    TO_TIMESTAMP_NTZ(Process.FACILITY_PROFILE:ADDRESS[0].UPDATED_DATETIME) AS Address_LastUpdateDate,

    -- Customer Product
    TO_VARCHAR(Process.FACILITY_PROFILE:CUSTOMER_PRODUCT[0].CUSTOMER_PRODUCT_CODE) AS CustomerProduct_CustomerProductCode,
    TO_VARCHAR(Process.FACILITY_PROFILE:CUSTOMER_PRODUCT[0].FEATURE_FCCLLOGO) AS CustomerProduct_FeatureFcclLogo,
    TO_VARCHAR(Process.FACILITY_PROFILE:CUSTOMER_PRODUCT[0].FEATURE_FCCLURL) AS CustomerProduct_FeatureFcclUrl,
    TO_TIMESTAMP_NTZ(Process.FACILITY_PROFILE:CUSTOMER_PRODUCT[0].DESIGNATED_DATETIME) AS CustomerProduct_DesignatedDatetime,
    TO_VARCHAR(Process.FACILITY_PROFILE:CUSTOMER_PRODUCT[0].FEATURE_FCFLOGO) AS CustomerProduct_FeatureFcfLogo,
    TO_VARCHAR(Process.FACILITY_PROFILE:CUSTOMER_PRODUCT[0].FEATURE_FCFURL) AS CustomerProduct_FeatureFcfUrl,
    TO_VARCHAR(Process.FACILITY_PROFILE:CUSTOMER_PRODUCT[0].OPT_OUT) AS CustomerProduct_OptOut,
    TO_VARCHAR(Process.FACILITY_PROFILE:CUSTOMER_PRODUCT[0].DATA_SOURCE_CODE) AS CustomerProduct_SourceCode,
    TO_TIMESTAMP_NTZ(Process.FACILITY_PROFILE:CUSTOMER_PRODUCT[0].UPDATED_DATETIME) AS CustomerProduct_LastUpdateDate,

    -- Demographics
    TO_VARCHAR(Process.FACILITY_PROFILE:DEMOGRAPHICS[0].FACILITY_CODE) AS Demographics_FacilityCode,
    TO_VARCHAR(Process.FACILITY_PROFILE:DEMOGRAPHICS[0].FACILITY_NAME) AS Demographics_FacilityName,
    TO_VARCHAR(Process.FACILITY_PROFILE:DEMOGRAPHICS[0].LEGACY_KEY) AS Demographics_LegacyKey,
    TO_BOOLEAN(Process.FACILITY_PROFILE:DEMOGRAPHICS[0].IS_CLOSED) AS Demographics_IsClosed,
    TO_VARCHAR(Process.FACILITY_PROFILE:DEMOGRAPHICS[0].DATA_SOURCE_CODE) AS Demographics_SourceCode,
    TO_TIMESTAMP_NTZ(Process.FACILITY_PROFILE:DEMOGRAPHICS[0].UPDATED_DATETIME) AS Demographics_LastUpdateDate,
    
    -- Facility Service
    TO_VARCHAR(Process.FACILITY_PROFILE:FACILITY_SERVICE[0].FACILITY_SERVICE_CODE) AS FacilityService_FacilityServiceCode,
    TO_VARCHAR(Process.FACILITY_PROFILE:FACILITY_SERVICE[0].DATA_SOURCE_CODE) AS FacilityService_SourceCode,
    TO_TIMESTAMP_NTZ(Process.FACILITY_PROFILE:FACILITY_SERVICE[0].UPDATED_DATETIME) AS FacilityService_LastUpdateDate,

    -- Facility Profile
    TO_VARCHAR(Process.FACILITY_PROFILE:FACILITY_TYPE[0].FACILITY_TYPE_CODE) AS Facility_Type_Code,
    TO_VARCHAR(Process.FACILITY_PROFILE:FACILITY_TYPE[0].DATA_SOURCE_CODE) AS Facility_Type_SourceCode,
    TO_TIMESTAMP_NTZ(Process.FACILITY_PROFILE:FACILITY_TYPE[0].UPDATED_DATETIME) AS Facility_Type_LastUpdateDate,

    -- Hours
    TO_VARCHAR(Process.FACILITY_PROFILE:HOURS[0].DAYS_OF_WEEK_CODE) AS Hours_DaysOfWeek,
    TO_VARCHAR(Process.FACILITY_PROFILE:HOURS[0].OPENING_TIME) AS Hours_OpeningTime,
    TO_VARCHAR(Process.FACILITY_PROFILE:HOURS[0].CLOSING_TIME) AS Hours_ClosingTime,
    TO_BOOLEAN(Process.FACILITY_PROFILE:HOURS[0].IS_CLOSED) AS Hours_IsClosed,
    TO_BOOLEAN(Process.FACILITY_PROFILE:HOURS[0].IS_OPEN_24_HOURS) AS Hours_IsOpen24Hours,
    TO_VARCHAR(Process.FACILITY_PROFILE:HOURS[0].DATA_SOURCE_CODE) AS Hours_SourceCode,
    TO_TIMESTAMP_NTZ(Process.FACILITY_PROFILE:HOURS[0].UPDATED_DATETIME) AS Hours_LastUpdateDate,

    -- Image
    TO_VARCHAR(Process.FACILITY_PROFILE:IMAGE[0].IMAGE_PATH) AS Image_Path,
    TO_VARCHAR(Process.FACILITY_PROFILE:IMAGE[0].IMAGE_FILE_NAME) AS Image_FileName,
    TO_VARCHAR(Process.FACILITY_PROFILE:IMAGE[0].MEDIA_IMAGE_TYPE_CODE) AS Image_TypeCode,
    TO_VARCHAR(Process.FACILITY_PROFILE:IMAGE[0].MEDIA_SIZE_CODE) AS Image_SizeCode,
    TO_VARCHAR(Process.FACILITY_PROFILE:IMAGE[0].MEDIA_REVIEW_LEVEL_CODE) AS Image_ReviewLevel,
    TO_VARCHAR(Process.FACILITY_PROFILE:IMAGE[0].DATA_SOURCE_CODE) AS Image_SourceCode,
    TO_TIMESTAMP_NTZ(Process.FACILITY_PROFILE:IMAGE[0].UPDATED_DATETIME) AS Image_LastUpdateDate,

    -- Language
    TO_VARCHAR(Process.FACILITY_PROFILE:LANGUAGE[0].LANGUAGE_CODE) AS Language_Code,
    TO_VARCHAR(Process.FACILITY_PROFILE:LANGUAGE[0].DATA_SOURCE_CODE) AS Language_SourceCode,
    TO_TIMESTAMP_NTZ(Process.FACILITY_PROFILE:LANGUAGE[0].UPDATED_DATETIME) AS Language_LastUpdateDate,

    -- Syndication
    TO_VARCHAR(Process.FACILITY_PROFILE:SYNDICATION[0].CUSTOMER_PRODUCT_CODE) AS Syndication_CustomerProductCode,
    TO_VARCHAR(Process.FACILITY_PROFILE:SYNDICATION[0].SYNDICATION_PHONE) AS Syndication_Phone,
    TO_VARCHAR(Process.FACILITY_PROFILE:SYNDICATION[0].SYNDICATION_FORWARD_TO_PHONE) AS Syndication_ForwardToPhone,
    TO_VARCHAR(Process.FACILITY_PROFILE:SYNDICATION[0].DATA_SOURCE_CODE) AS Syndication_SourceCode,
    TO_TIMESTAMP_NTZ(Process.FACILITY_PROFILE:SYNDICATION[0].UPDATED_DATETIME) AS Syndication_LastUpdateDate


FROM
    Raw.FACILITY_PROFILE_PROCESSING AS Process);