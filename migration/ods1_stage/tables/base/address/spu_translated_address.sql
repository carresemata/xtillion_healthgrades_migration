--- 1. etl_spuMergeOfficeAddress (snowflake db)

-- CTE 'w' retrieves records from FacilityProfileProcessing and FacilityProfileProcessingDeDup tables
-- It also extracts 'Address' from 'EntityJSONString' and assigns it to the 'FacilityJSON' column
WITH cte_w AS (
    SELECT 
        p.CREATE_DATE, 
        p.RELTIO_ID as ReltioEntityID, 
        p.Facility_CODE as FacilityCode, 
        p.FacilityID,
        PARSE_JSON(p.PAYLOAD:EntityJSONString.Address) AS FacilityJSON  -- Extract 'Address' from 'EntityJSONString' !!!!!!!!!!!!!!!!! THIS MIGHT BE INCORRECT
    FROM raw.FacilityProfileProcessingDeDup AS d
    JOIN raw.FacilityProfileProcessing AS p ON p.rawFacilityProfileID = d.rawFacilityProfileID
    WHERE p.PAYLOAD IS NOT NULL
),

-- CTE 'x' retrieves all records from 'w' where 'FacilityJSON' is not NULL
cte_x AS (
    SELECT *
    FROM cte_w
    WHERE cte_w.FacilityJSON IS NOT NULL
),


-- CTE 'y' parses JSON fields from 'FacilityJSON' and assigns them to SQL fields
-- It also calculates the row number for each 'FacilityID' ordered by 'CREATE_DATE' in descending order
cte_y AS (
    SELECT 
        cte_x.FacilityID,
        cte_x.FacilityJSON:AddressLine1::VARCHAR(150) AS AddressLine1,  -- Parse 'AddressLine1' from 'FacilityJSON'
        cte_x.FacilityJSON:City::VARCHAR(150) AS City,  -- Parse 'City' from 'FacilityJSON'
        cte_x.FacilityJSON:StateProvince::VARCHAR(50) AS State,  -- Parse 'StateProvince' from 'FacilityJSON'
        cte_x.FacilityJSON:Country::VARCHAR(50) AS Country,  -- Parse 'Country' from 'FacilityJSON'
        cte_x.FacilityJSON:PostalCode::VARCHAR(50) AS PostalCode,  -- Parse 'PostalCode' from 'FacilityJSON'
        cte_x.FacilityJSON:Latitude::VARCHAR(50) AS Latitude,  -- Parse 'Latitude' from 'FacilityJSON'
        cte_x.FacilityJSON:Longitude::VARCHAR(50) AS Longitude,  -- Parse 'Longitude' from 'FacilityJSON'
        cte_x.FacilityJSON:LastUpdateDate::DATETIME AS LastUpdateDate,  -- Parse 'LastUpdateDate' from 'FacilityJSON'
        cte_x.FacilityJSON:SourceCode::VARCHAR(80) AS SourceCode,  -- Parse 'SourceCode' from 'FacilityJSON'
        cte_x.FacilityCode,
        ROW_NUMBER() OVER(PARTITION BY cte_x.FacilityID ORDER BY cte_x.CREATE_DATE DESC) AS RowRank  -- Calculate row number
    FROM cte_x
),
--- create swimlane CTE

cte_swimlane AS (
    SELECT
        DISTINCT cte_y.FacilityID
        ,cte_y.AddressLine1
        ,cte_y.City
        ,cte_y.State
        ,cte_y.Country
        ,cte_y.PostalCode
        ,cte_y.Latitude
        ,cte_y.Longitude
        ,cte_y.SourceCode
        ,cte_y.FacilityCode
        ,ROW_NUMBER() OVER(PARTITION BY cte_y.FacilityID ORDER BY cte_y.CREATE_DATE DESC) AS RowRank
    FROM cte_y )


------------  !!!!!!!!!!!!!!!!!! WE COULD REMOVE CTE_X


-- Create CTE to insert data into ODS1Stage.Base.Address table
WITH cte_insert AS (
        SELECT
            DISTINCT S.AddressLine1, 
            S.Latitude, 
            S.Longitude, 
            NULL AS refTimeZoneCode, --- !!! MAYBE THIS DOES NOT WORK
            CSP.CityStatePostalCodeId
        FROM
            cte_swimlane as S
        JOIN ODS1Stage.Base.CityStatePostalCode CSP ON CSP.City = S.City AND CSP.State = S.State AND CSP.PostalCode = S.PostalCode
        LEFT JOIN ODS1Stage.Base.Address A ON A.AddressLine1 = S.AddressLine1 AND CSP.CityStatePostalCodeId = A.CityStatePostalCodeId
        WHERE
            A.AddressId IS NULL)

-- Insert data into ODS1Stage.Base.Address table
INSERT INTO ODS1Stage.Base.Address(AddressId, NationId, AddressLine1, Latitude, Longitude, TimeZone, CityStatePostalCodeId)
SELECT
    UUID_STRING(),  -- Equivalent o NewId() in Snowflake
    '00415355-0000-0000-0000-000000000000', 
    S.AddressLine1, 
    S.Latitude, 
    S.Longitude, 
    refTimeZoneCode, 
    S.CityStatePostalCodeId
FROM
    cte_insert S


-- Update AddressCode when it is null (THIS CAN BE ADDED WHEN CREATING THE TABLE DIRECTLY)
UPDATE ODS1Stage.Base.Address
SET AddressCode = 'AD' || RIGHT(TO_HEX(TO_BINARY(AddressInt)), 10)  -- CHECK IF THIS WORKS
WHERE AddressCode IS NULL
