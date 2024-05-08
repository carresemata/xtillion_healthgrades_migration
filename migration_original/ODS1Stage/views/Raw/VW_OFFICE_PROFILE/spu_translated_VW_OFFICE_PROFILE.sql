CREATE OR REPLACE MATERIALIZED VIEW ODS1_STAGE.RAW.VW_OFFICE_PROFILE AS (

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Raw.VW_OFFICE_PROFILE depends on:
--- MDM_TEAM.MST.OFFICE_PROFILE_PROCESSING

---------------------------------------------------------
-------------------- 1. JSON Keys -----------------------
---------------------------------------------------------

--- Address
--- Demographics
--- Hours
--- Phone
--- Practice


SELECT
    Process.MST_OFFICE_PROFILE_ID AS MST_id,
    Process.CREATED_DATETIME AS CREATE_DATE,
    Process.REF_OFFICE_CODE AS OfficeCode,
    Process.OFFICE_PROFILE,
    
    -- Address
    TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].ADDRESS_TYPE_CODE) AS Address_AddressTypeCode,
    TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].ADDRESS_LINE_1) AS Address_AddressLine1,
    TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].ADDRESS_LINE_2) AS Address_AddressLine2,
    TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].SUITE) AS Address_Suite,
    TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].CITY) AS Address_City,
    TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].STATE) AS Address_State,
    TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].ZIP) AS Address_PostalCode,
    TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].LATITUDE) AS Address_Latitude,
    TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].LONGITUDE) AS Address_Longitude,
    TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].TIME_ZONE) AS Address_TimeZone,
    TO_BOOLEAN(Process.OFFICE_PROFILE:ADDRESS[0].IS_PO_BOX) AS Address_IsPOBox,
    TO_BOOLEAN(Process.OFFICE_PROFILE:ADDRESS[0].IS_MILITARY) AS Address_IsMilitary,
    TO_BOOLEAN(Process.OFFICE_PROFILE:ADDRESS[0].IS_ROOFTOP_GEOCODE) AS Address_IsRooftopGeocode,
    TO_BOOLEAN(Process.OFFICE_PROFILE:ADDRESS[0].IS_MISSING_SUITE) AS Address_IsMissingSuite,
    TO_BOOLEAN(Process.OFFICE_PROFILE:ADDRESS[0].IS_INVALID_SUITE) AS Address_IsInvalidSuite,
    TO_BOOLEAN(Process.OFFICE_PROFILE:ADDRESS[0].IS_RESIDENTIAL) AS Address_IsResidential,
    TO_BOOLEAN(Process.OFFICE_PROFILE:ADDRESS[0].IS_VALID_ADDRESS) AS Address_IsValidAddress,
    TO_VARCHAR(Process.OFFICE_PROFILE:ADDRESS[0].DATA_SOURCE_CODE) AS Address_SourceCode,
    TO_TIMESTAMP_NTZ(Process.OFFICE_PROFILE:ADDRESS[0].UPDATED_DATETIME) AS Address_LastUpdateDate,
    
    -- Demographics
    TO_VARCHAR(Process.OFFICE_PROFILE:DEMOGRAPHICS[0].OFFICE_NAME) AS Demographics_OfficeName,
    TO_VARCHAR(Process.OFFICE_PROFILE:DEMOGRAPHICS[0].OFFICE_CODE) AS Demographics_OfficeCode,
    TO_VARCHAR(Process.OFFICE_PROFILE:DEMOGRAPHICS[0].PARKING_INFORMATION) AS Demographics_ParkingInformation,
    TO_VARCHAR(Process.OFFICE_PROFILE:DEMOGRAPHICS[0].DATA_SOURCE_CODE) AS Demographics_SourceCode,
    TO_TIMESTAMP_NTZ(Process.OFFICE_PROFILE:DEMOGRAPHICS[0].UPDATED_DATETIME) AS Demographics_LastUpdateDate,
    
    -- Hours
    TO_VARCHAR(Process.OFFICE_PROFILE:HOURS[0].DAYS_OF_WEEK_CODE) AS Hours_DaysOfWeekCode,
    TO_VARCHAR(Process.OFFICE_PROFILE:HOURS[0].OPENING_TIME) AS Hours_OpeningTime,
    TO_VARCHAR(Process.OFFICE_PROFILE:HOURS[0].CLOSING_TIME) AS Hours_ClosingTime,
    TO_BOOLEAN(Process.OFFICE_PROFILE:HOURS[0].IS_CLOSED) AS Hours_IsClosed,
    TO_BOOLEAN(Process.OFFICE_PROFILE:HOURS[0].IS_OPEN_24_HOURS) AS Hours_IsOpen24Hours,
    TO_VARCHAR(Process.OFFICE_PROFILE:HOURS[0].DATA_SOURCE_CODE) AS Hours_SourceCode,
    TO_TIMESTAMP_NTZ(Process.OFFICE_PROFILE:HOURS[0].UPDATED_DATETIME) AS Hours_LastUpdateDate,
    
    -- Phone
    TO_VARCHAR(Process.OFFICE_PROFILE:PHONE[0].PHONE_NUMBER) AS Phone_PhoneNumber,
    TO_VARCHAR(Process.OFFICE_PROFILE:PHONE[0].PHONE_TYPE_CODE) AS Phone_PhoneTypeCode,
    TO_VARCHAR(Process.OFFICE_PROFILE:PHONE[0].DATA_SOURCE_CODE) AS Phone_SourceCode,
    TO_TIMESTAMP_NTZ(Process.OFFICE_PROFILE:PHONE[0].UPDATED_DATETIME) AS Phone_LastUpdateDate,
    
    -- Practice
    TO_VARCHAR(Process.OFFICE_PROFILE:PRACTICE[0].PRACTICE_CODE) AS Practice_PracticeCode,
    TO_VARCHAR(Process.OFFICE_PROFILE:PRACTICE[0].DATA_SOURCE_CODE) AS Practice_SourceCode,
    TO_TIMESTAMP_NTZ(Process.OFFICE_PROFILE:PRACTICE[0].UPDATED_DATETIME) AS Practice_LastUpdateDate
    
FROM
    MDM_TEAM.MST.OFFICE_PROFILE_PROCESSING AS Process);