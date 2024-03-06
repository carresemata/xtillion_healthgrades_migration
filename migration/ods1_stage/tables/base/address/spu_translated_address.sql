--------------- 1. etl_spuMergeOfficeAddress (snowflake db)

-- First CTE: Extract 'Address' from 'EntityJSONString' in the tables FacilityProfileProcessing and FacilityProfileProcessingDeDup
WITH cte_facility AS (
    SELECT 
        p.create_date, 
        p.reltio_id AS reltio_entity_id, 
        p.facility_code AS facility_code, 
        p.facility_id,
        PARSE_JSON(p.payload:EntityJSONString.Address) AS facility_json -- The parse_json might not be needed
    FROM raw.facility_profile_processing_de_dup AS d
    JOIN raw.facility_profile_processing AS p ON p.raw_facility_profile_id = d.raw_facility_profile_id
    WHERE p.payload IS NOT NULL
),

-- Second CTE: Filter out records where 'FacilityJSON' is not null
cte_payload AS (
    SELECT 
        f.facility_id,
        f.facility_code,
        f.facility_json,
        f.create_date
    FROM cte_facility AS f
    WHERE cte_facility.facility_json IS NOT NULL
),

-- Third CTE: Parse JSON fields from 'FacilityJSON' and assign them to SQL fields
cte_parse_address AS (
    SELECT 
        cte_payload.facility_id,
        cte_payload.facility_json:AddressLine1::VARCHAR(150) AS address_line1,
        cte_payload.facility_json:City::VARCHAR(150) AS city,
        cte_payload.facility_json:StateProvince::VARCHAR(50) AS state,
        cte_payload.facility_json:Country::VARCHAR(50) AS country,
        cte_payload.facility_json:PostalCode::VARCHAR(50) AS postal_code,
        cte_payload.facility_json:Latitude::VARCHAR(50) AS latitude,
        cte_payload.facility_json:Longitude::VARCHAR(50) AS longitude,
        cte_payload.facility_json:LastUpdateDate::DATETIME AS last_update_date,
        cte_payload.facility_json:SourceCode::VARCHAR(80) AS source_code,
        cte_payload.facility_code,
        ROW_NUMBER() OVER(PARTITION BY cte_payload.facility_id ORDER BY cte_payload.create_date DESC) AS row_rank
    FROM cte_payload
),

-- Fourth CTE: Create 'Swimlane' structure with distinct data
cte_insert_address AS (
    SELECT
        cte_parse_address.facility_id,
        cte_parse_address.address_line1,
        cte_parse_address.city,
        cte_parse_address.state,
        cte_parse_address.country,
        cte_parse_address.postal_code,
        cte_parse_address.latitude,
        cte_parse_address.longitude,
        cte_parse_address.source_code,
        cte_parse_address.facility_code,
        ROW_NUMBER() OVER(PARTITION BY cte_parse_address.facility_id ORDER BY cte_parse_address.create_date DESC) AS row_rank
    FROM cte_parse_address
    GROUP BY 
        cte_parse_address.facility_id, 
        cte_parse_address.address_line1, 
        cte_parse_address.city, 
        cte_parse_address.state, 
        cte_parse_address.country, 
        cte_parse_address.postal_code, 
        cte_parse_address.latitude, 
        cte_parse_address.longitude, 
        cte_parse_address.source_code, 
        cte_parse_address.facility_code
),

-- Fifth CTE: Prepare data for insertion into 'ods1stage.base.address' table
cte_insert AS (
        SELECT
            ia.address_line1, 
            ia.latitude, 
            ia.longitude, 
            NULL AS ref_time_zone_code, 
            csp.city_state_postal_code_id
        FROM
            cte_insert_address AS ia
        JOIN ods1stage.base.city_state_postal_code csp ON csp.city = ia.city AND csp.state = ia.state AND csp.postal_code = ia.postal_code
        LEFT JOIN ods1stage.base.address a ON a.address_line1 = ia.address_line1 AND csp.city_state_postal_code_id = a.city_state_postal_code_id
        WHERE
            a.address_id IS NULL
        GROUP BY
            ia.address_line1, 
            ia.latitude, 
            ia.longitude, 
            csp.city_state_postal_code_id
)

-- Insert data into 'ods1stage.base.address' table
INSERT INTO ods1stage.base.address(
    address_id, 
    nation_id, 
    address_line1, 
    latitude, 
    longitude, 
    time_zone, 
    city_state_postal_code_id)
SELECT
    UUID_STRING(),  -- Equivalent to NewId() in T-SQL
    '00415355-0000-0000-0000-000000000000', 
    i.address_line1, 
    i.latitude, 
    i.longitude, 
    i.ref_time_zone_code, 
    i.city_state_postal_code_id
FROM
    cte_insert AS i;

-- Update 'address_code' when it is null (THIS CAN BE ADDED WHEN CREATING THE TABLE DIRECTLY)
UPDATE ods1stage.base.address
SET address_code = 'AD' || RIGHT(TO_HEX(TO_BINARY(address_int)), 10)  -- Equivalent to original T-SQL statement
WHERE address_code IS NULL;