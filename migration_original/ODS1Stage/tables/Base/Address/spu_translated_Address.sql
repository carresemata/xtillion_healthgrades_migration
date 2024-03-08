--------------- 1. etl_spuMergeFacilityAddress (snowflake db)

-- First CTE: Extract 'Address' from 'EntityJSONString' in the tables FacilityProfileProcessing and FacilityProfileProcessingDeDup
WITH cteFacility AS (
    SELECT 
        p.CREATE_DATE, 
        p.RELTIO_ID AS ReltioEntityID, 
        p.Facility_CODE AS FacilityCode, 
        p.FacilityID,
        PARSE_JSON(p.PAYLOAD:EntityJSONString.Address) AS FacilityJSON -- The parse_json might not be needed 
    FROM raw.FacilityProfileProcessingDeDup AS d
    JOIN raw.FacilityProfileProcessing AS p ON p.rawFacilityProfileId = d.rawFacilityProfileId
    WHERE p.PAYLOAD IS NOT NULL
),

-- Second CTE: Filter out records where 'FacilityJSON' is not null
ctePayload AS (
    SELECT 
        f.FacilityID,
        f.FacilityCode,
        f.FacilityJSON,
        f.CREATE_DATE
    FROM cteFacility AS f
    WHERE cteFacility.FacilityJSON IS NOT NULL
),

-- Third CTE: Parse JSON fields from 'FacilityJSON' and assign them to SQL fields
cteParseAddress AS (
    SELECT 
        ctePayload.FacilityID,
        ctePayload.FacilityJSON:AddressLine1::VARCHAR(150),
        ctePayload.FacilityJSON:City::VARCHAR(150),
        ctePayload.FacilityJSON:StateProvince::VARCHAR(50) AS State,
        ctePayload.FacilityJSON:Country::VARCHAR(50),
        ctePayload.FacilityJSON:PostalCode::VARCHAR(50),
        ctePayload.FacilityJSON:Latitude::VARCHAR(50),
        ctePayload.FacilityJSON:Longitude::VARCHAR(50),
        ctePayload.FacilityJSON:LastUpdateDate::DATETIME,
        ctePayload.FacilityJSON:SourceCode::VARCHAR(80),
        ctePayload.FacilityCode,
        ROW_NUMBER() OVER(PARTITION BY ctePayload.FacilityID ORDER BY ctePayload.CREATE_DATE DESC) AS RowRank
    FROM ctePayload
),


-- Fourth CTE: Create 'Swimlane' structure with distinct data

cteInsertAddress AS (
    SELECT
        cteParseAddress.FacilityID,
        cteParseAddress.AddressLine1,
        cteParseAddress.City,
        cteParseAddress.State,
        cteParseAddress.Country,
        cteParseAddress.PostalCode,
        cteParseAddress.Latitude,
        cteParseAddress.Longitude,
        cteParseAddress.SourceCode,
        cteParseAddress.FacilityCode,
        ROW_NUMBER() OVER(PARTITION BY cteParseAddress.FacilityID ORDER BY cteParseAddress.LastUpdateDate DESC) AS RowRank
    FROM cteParseAddress
    GROUP BY 
        cteParseAddress.FacilityID, 
        cteParseAddress.AddressLine1, 
        cteParseAddress.City, 
        cteParseAddress.State, 
        cteParseAddress.Country, 
        cteParseAddress.PostalCode, 
        cteParseAddress.Latitude, 
        cteParseAddress.Longitude, 
        cteParseAddress.SourceCode, 
        cteParseAddress.FacilityCode
),

-- Fifth CTE: Prepare data for insertion into 'ods1stage.base.address' table
cteInsert AS (
        SELECT
            ia.AddressLine1, 
            ia.Latitude, 
            ia.Longitude, 
            NULL AS refTimeZoneCode, 
            csp.CityStatePostalCodeId
        FROM
            cteInsertAddress AS ia
        JOIN Base.CityStatePostalCode csp ON csp.City = ia.City AND csp.State = ia.State AND csp.PostalCode = ia.PostalCode
        LEFT JOIN Base.Address a ON a.AddressLine1 = ia.AddressLine1 AND csp.CityStatePostalCodeId = a.CityStatePostalCodeId
        WHERE
            a.AddressId IS NULL
        GROUP BY
            ia.AddressLine1, 
            ia.Latitude, 
            ia.Longitude, 
            csp.CityStatePostalCodeId
)


-- Insert data into 'ods1stage.base.address' table
INSERT INTO Base.Address(
    AddressId, 
    NationId, 
    AddressLine1, 
    Latitude, 
    Longitude, 
    TimeZone, 
    CityStatePostalCodeId,
    AddressCode)
SELECT
    UUID_STRING(),  -- Equivalent to NewId() in T-SQL
    '00415355-0000-0000-0000-000000000000', 
    i.AddressLine1,
    i.Latitude,
    i.Longitude,
    i.refTimeZoneCode,
    i.CityStatePostalCodeId
FROM
    cteInsert AS i;

-- Update 'address_code' when it is null (THIS CAN BE ADDED WHEN CREATING THE TABLE DIRECTLY)
UPDATE Base.Address
SET AddressCode = 'AD' || RIGHT(TO_HEX(TO_BINARY(AddressInt)), 10)  -- Equivalent to original T-SQL statement
FROM Base.Address
WHERE AddressCode IS NULL;






------------- 2. etl_spuMergeOfficeAddress (snowflake db)

-- First CTE: CTE_OfficeAddress (Extract 'Address' from 'EntityJSONString' in the tables OfficeProfileProcessing and OfficeProfileProcessingDeDup)
WITH CTE_OfficeAddress AS (
    SELECT 
        proces.create_date,
        proces.reltio_id AS ReltioEntityID,
        proces.office_code AS OfficeCode,
        proces.OfficeID,
        PARSE_JSON(proces.PAYLOAD:EntityJSONString.Address) AS OfficeJSON -- The parse_json might not be needed
    FROM 
        raw.OfficeProfileProcessingDeDup AS deDup
        JOIN raw.OfficeProfileProcessing AS proces ON proces.rawOfficeProfileID = deDup.rawOfficeProfileID
    WHERE proces.PAYLOAD IS NOT NULL
),

-- Second CTE: Filter out records where 'OfficeJSON' is not null
CTE_OfficeAddressPayload AS (
    SELECT 
        CTE_OfficeAddress.create_date,
        CTE_OfficeAddress.ReltioEntityID,
        CTE_OfficeAddress.OfficeCode,
        CTE_OfficeAddress.OfficeID,
        CTE_OfficeAddress.OfficeJSON
    FROM CTE_OfficeAddress
    WHERE CTE_OfficeAddress.OfficeJSON IS NOT NULL
),

-- Third CTE: Parse JSON fields from 'OfficeJSON' and assign them to SQL fields
CTE_ParseOfficeAddress AS (
    SELECT
        CTE_OfficeAddressPayload.OfficeJSON:AddressTypeCode::VARCHAR(50) AS AddressTypeCode,
        CTE_OfficeAddressPayload.OfficeJSON:ResidentialDelivery::VARCHAR(1) AS ResidentialDelivery,
        CTE_OfficeAddressPayload.OfficeJSON:OfficeName::VARCHAR(100) AS OfficeName,
        CTE_OfficeAddressPayload.OfficeJSON:Rank::INT AS AddressRank,
        CTE_OfficeAddressPayload.OfficeJSON:AddressLine1::VARCHAR(50) AS AddressLine1,
        CTE_OfficeAddressPayload.OfficeJSON:AddressLine2::VARCHAR(50) AS AddressLine2,
        CTE_OfficeAddressPayload.OfficeJSON:Suite::VARCHAR(50) AS Suite,
        CTE_OfficeAddressPayload.OfficeJSON:City::VARCHAR(50) AS City,
        CTE_OfficeAddressPayload.OfficeJSON:State::VARCHAR(50) AS State,
        CTE_OfficeAddressPayload.OfficeJSON:PostalCode::VARCHAR(50) AS PostalCode,
        CTE_OfficeAddressPayload.OfficeJSON:Latitude::VARCHAR(50) AS Latitude,
        CTE_OfficeAddressPayload.OfficeJSON:Longitude::VARCHAR(50) AS Longitude,
        CTE_OfficeAddressPayload.OfficeJSON:TimeZone::VARCHAR(50) AS TimeZone,
        CTE_OfficeAddressPayload.OfficeJSON:DoSuppress::VARCHAR(50) AS DoSuppress,
        CTE_OfficeAddressPayload.OfficeJSON:IsDerived::VARCHAR(50) AS IsDerived,
        CTE_OfficeAddressPayload.OfficeJSON:LastUpdateDate::DATETIME AS LastUpdateDate,
        CTE_OfficeAddressPayload.OfficeJSON:OfficeCode::VARCHAR(50) AS OfficeCode,
        CTE_OfficeAddressPayload.OfficeJSON:SourceCode::VARCHAR(50) AS SourceCode
    FROM 
        CTE_OfficeAddressPayload
)

-- Fourth Step: Create Swimlane temporary table
CREATE OR REPLACE TEMPORARY TABLE swimlane AS (
    SELECT
        ROW_NUMBER () OVER (ORDER BY (SELECT NULL)) AS swimlaneID, -- Equivalent to Identity(int, 1, 1) in T-SQL
        CAST(NULL AS STRING) AS CityStatePostalCodeID,
        CAST(NULL AS STRING) AS NationID,
        CAST(NULL AS STRING) AS AddressId,
        CAST(CTE_ParseOfficeAddress.AddressTypeCode AS STRING) AS AddressTypeID,
        CTE_ParseOfficeAddress.AddressTypeCode,
        CTE_OfficeAddressPayload.OfficeID,
        CTE_ParseOfficeAddress.OfficeName,
        CTE_ParseOfficeAddress.AddressRank,
        CTE_ParseOfficeAddress.AddressLine1,
        CTE_ParseOfficeAddress.AddressLine2,
        CTE_ParseOfficeAddress.Suite,
        CTE_ParseOfficeAddress.City,
        CTE_ParseOfficeAddress.State,
        CTE_ParseOfficeAddress.PostalCode,
        CTE_ParseOfficeAddress.Latitude,
        CTE_ParseOfficeAddress.Longitude,
        CTE_ParseOfficeAddress.TimeZone,
        CTE_ParseOfficeAddress.DoSuppress,
        CTE_ParseOfficeAddress.IsDerived,
        CTE_ParseOfficeAddress.LastUpdateDate,
        CTE_ParseOfficeAddress.SourceCode,
        CTE_OfficeAddressPayload.OfficeCode,
        ROW_NUMBER() OVER(PARTITION BY CTE_OfficeAddressPayload.OfficeID, CTE_ParseOfficeAddress.AddressLine1, CTE_ParseOfficeAddress.AddressLine2, CTE_ParseOfficeAddress.Suite, CTE_ParseOfficeAddress.City, CTE_ParseOfficeAddress.State, CTE_ParseOfficeAddress.PostalCode ORDER BY CTE_OfficeAddressPayload.create_date DESC) AS RowRankOfficeAddress,
        ROW_NUMBER() OVER(PARTITION BY CTE_ParseOfficeAddress.AddressLine1, CTE_ParseOfficeAddress.AddressLine2, CTE_ParseOfficeAddress.Suite, CTE_ParseOfficeAddress.City, CTE_ParseOfficeAddress.State, CTE_ParseOfficeAddress.PostalCode ORDER BY CTE_OfficeAddressPayload.create_date DESC) AS RowRankAddress

    FROM
        CTE_OfficeAddressPayload AS officePayload
        JOIN CTE_ParseOfficeAddress AS parseAddress ON parseAddress.OfficeCode = officePayload.OfficeCode

    WHERE
        IFNULL(CTE_ParseOfficeAddress.DoSuppress, 0) = 0 AND
        IFF(CTE_ParseOfficeAddress.City='', NULL, CTE_ParseOfficeAddress.City) IS NOT NULL AND
        IFF(CTE_ParseOfficeAddress.State='', NULL, CTE_ParseOfficeAddress.State) IS NOT NULL AND
        IFF(CTE_ParseOfficeAddress.PostalCode='', NULL, CTE_ParseOfficeAddress.PostalCode) IS NOT NULL AND
        LENGTH(TRIM(UPPER(CTE_ParseOfficeAddress.AddressLine1))) || IFNULL(TRIM(UPPER(CTE_ParseOfficeAddress.AddressLine2, ''))) || IFNULL(TRIM(UPPER(CTE_ParseOfficeAddress.Suite, ''))) > 0

    GROUP BY 
        CTE_ParseOfficeAddress.AddressTypeCode,
        CTE_OfficeAddressPayload.OfficeID,
        CTE_ParseOfficeAddress.OfficeName,
        CTE_ParseOfficeAddress.AddressRank,
        CTE_ParseOfficeAddress.AddressLine1,
        CTE_ParseOfficeAddress.AddressLine2,
        CTE_ParseOfficeAddress.Suite,
        CTE_ParseOfficeAddress.City,
        CTE_ParseOfficeAddress.State,
        CTE_ParseOfficeAddress.PostalCode,
        CTE_ParseOfficeAddress.Latitude,
        CTE_ParseOfficeAddress.Longitude,
        CTE_ParseOfficeAddress.TimeZone,
        CTE_ParseOfficeAddress.DoSuppress,
        CTE_ParseOfficeAddress.IsDerived,
        CTE_ParseOfficeAddress.LastUpdateDate,
        CTE_ParseOfficeAddress.SourceCode,
        CTE_OfficeAddressPayload.OfficeCode

)

-- Updating swimlane temporary table
--- Update 'City' field when it ends with a comma
UPDATE swimlane
SET City = LEFT(TRIM(City), LENGTH(TRIM(City)) - 1)
WHERE TRIM(City) LIKE '%,';

--- Update 'State' field 
UPDATE swimlane
SET State = S.State
FROM swimlane SL
INNER JOIN Base.State S ON TRIM(S.StateName) = TRIM(SL.State);

--- Update 'CityStatePostalCodeID' and 'NationID' fields
UPDATE swimlane
SET CityStatePostalCodeID = PC.CityStatePostalCodeId, 
    NationID = PC.NationId
FROM swimlane SL
INNER JOIN Base.CityStatePostalCode PC ON PC.City = SL.City AND PC.State = SL.State AND PC.PostalCode = SL.PostalCode


---------------- UPDATING BASE.ADDRESS TABLE
--- Insert data into Base.Address
INSERT INTO Base.Address(
    AddressId, 
    CityStatePostalCodeId,
    NationId, 
    AddressLine1, 
    AddressLine2,
    Latitude, 
    Longitude, 
    TimeZone, 
    Suite,
    LastUpdateDate)
SELECT
    UUID_STRING(),  -- Equivalent to NewId() in T-SQL
    SL.CityStatePostalCodeID,
    SL.NationID,
    SL.AddressLine1,
    SL.AddressLine2,
    SL.Latitude,
    SL.Longitude,
    SL.TimeZone,
    SL.Suite,
    CURRENT_TIMESTAMP() -- Equivalent to GETUTCDATE() in T-SQL
FROM
    swimlane S
    LEFT JOIN Base.Address AS a  
    ON IFF(UPPER(TRIM(S.AddressLine1)) IS NULL, '', UPPER(TRIM(S.AddressLine1))) = IFF(UPPER(TRIM(a.AddressLine1)) IS NULL, '', UPPER(TRIM(a.AddressLine1)))
    AND IFF(UPPER(TRIM(S.AddressLine2)) IS NULL, '', UPPER(TRIM(S.AddressLine2))) = IFF(UPPER(TRIM(a.AddressLine2)) IS NULL, '', UPPER(TRIM(a.AddressLine2)))
    AND IFF(UPPER(TRIM(S.Suite)) IS NULL, '', UPPER(TRIM(S.Suite))) = IFF(UPPER(TRIM(a.Suite)) IS NULL, '', UPPER(TRIM(a.Suite)))
    AND S.CityStatePostalCodeID = a.CityStatePostalCodeID
WHERE S.RowRankAddress = 1
    AND S.CityStatePostalCodeID IS NOT NULL
    AND a.AddressID IS NULL


--- Update AddressCode from Base.Address (THIS IS THE SAME THAT WAS DONE IN THE FIRST SPU, IT IS REDUNDANT)
-- UPDATE Base.Address
-- SET AddressCode = 'AD' || RIGHT(TO_HEX(TO_BINARY(AddressInt)), 10)  -- Equivalent to original T-SQL statement
-- WHERE AddressCode IS NULL;

