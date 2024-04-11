CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_ADDRESS() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.CityStatePostalCode depends on: 
--- Raw.OFFICE_PROFILE_PROCESSING
--- Raw.FACILITY_OFFICE_PROCESSING
--- Base.Facility
--- Base.CityStatePostalCode

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement_1 STRING; -- CTE and Select statement for the Merge
    insert_statement_1 STRING; -- Insert statement for the Merge
    merge_statement_1 STRING; -- Merge statement to final table
    select_statement_2 STRING; -- CTE and Select statement for the Merge
    insert_statement_2 STRING; -- Insert statement for the Merge
    merge_statement_2 STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    -- no conditionals


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
select_statement_1 := $$ WITH CTE_FacilityJSON AS (
                            SELECT
                                Facility.FacilityID,
                                Process.CREATED_DATETIME AS CREATE_DATE,
                                -- Process.RELTIO_ID AS ReltioEntityId,
                                Process.REF_FACILITY_CODE AS FacilityCode,
                                -- Process.FacilityID,
                                Process.FACILITY_PROFILE:ADDRESS AS FacilityJSONAddress,
                                Process.FACILITY_PROFILE:DEMOGRAPHICS AS FacilityJSONDemographics,
                                    TO_VARCHAR(FacilityJSONAddress[0].ADDRESS_LINE_1) AS AddressLine1,
                                    TO_VARCHAR(FacilityJSONAddress[0].CITY) AS City,
                                    TO_VARCHAR(FacilityJSONAddress[0].STATE) AS State,
                                    -- TO_VARCHAR(FacilityJSONAddress[0].COUNTRY) AS Country,
                                    TO_VARCHAR(FacilityJSONAddress[0].ZIP) AS PostalCode,
                                    TO_VARCHAR(FacilityJSONAddress[0].LATITUDE) AS Latitude,
                                    TO_VARCHAR(FacilityJSONAddress[0].LONGITUDE) AS Longitude,
                                    TO_TIMESTAMP_NTZ(FacilityJSONAddress[0].UPDATED_DATETIME) AS LastUpdateDate,
                                    TO_VARCHAR(FacilityJSONDemographics[0].DATA_SOURCE_CODE) AS SourceCode
                            FROM
                                -- Raw.FacilityProfileProcessingDeDup AS DeDup
                            Raw.FACILITY_PROFILE_PROCESSING AS Process 
                            JOIN Base.Facility AS Facility ON Process.REF_FACILITY_CODE = Facility.FacilityCode
                            WHERE
                                Process.FACILITY_PROFILE IS NOT NULL AND 
                                FacilityJSONAddress IS NOT NULL AND
                                FacilityJSONDemographics IS NOT NULL AND 
                                    NULLIF(City,'') IS NOT NULL 
                                    AND NULLIF(State,'') IS NOT NULL 
                                    AND NULLIF(PostalCode,'') IS NOT NULL)
                            SELECT DISTINCT 
                                -- cte.FacilityID,
                                cte.AddressLine1,
                                -- cte.City,
                                -- cte.State,
                                -- Country,
                                -- cte.PostalCode,
                                cte.Latitude,
                                cte.Longitude,
                                -- cte.SourceCode,
                                -- cte.FacilityCode,
                                NULL AS TimeZone,
                                CSPC.CityStatePostalCodeID 
                                -- ROW_NUMBER() OVER(PARTITION BY FacilityID ORDER BY CREATE_DATE DESC) AS RowRank
                            FROM CTE_FacilityJSON AS cte
                            JOIN Base.CityStatePostalCode AS CSPC ON cte.City = CSPC.City AND cte.State = CSPC.State AND cte.PostalCode = CSPC.PostalCode $$;



--- Insert Statement
insert_statement_1 := $$ INSERT (
                                AddressId, 
                                NationId, 
                                AddressLine1, 
                                Latitude, 
                                Longitude, 
                                TimeZone, 
                                CityStatePostalCodeId
                        )
                        VALUES (
                                UUID_STRING(),
                                '00415355-0000-0000-0000-000000000000',
                                source.AddressLine1, 
                                source.Latitude, 
                                source.Longitude, 
                                source.TimeZone, 
                                source.CityStatePostalCodeId
                        )$$;

select_statement_2 := $$ WITH CTE_OfficeJSON AS (
                            SELECT
                                Process.CREATED_DATETIME AS CREATE_DATE,
                                -- Process.RELTIO_ID AS ReltioEntityId,
                                Process.REF_OFFICE_CODE AS OfficeCode,
                                -- Process.OfficeID,
                                Process.OFFICE_PROFILE:ADDRESS AS OfficeJSONAddress,
                                Process.OFFICE_PROFILE:DEMOGRAPHICS AS OfficeJSONDemographics,
                                    TO_VARCHAR(OfficeJSONAddress[0].ADDRESS_TYPE_CODE) AS AddressTypeCode,
                                    -- TO_BOOLEAN(OfficeJSONAddress[0].IS_RESIDENTIAL) AS ResidentialDelivery,
                                    TO_VARCHAR(OfficeJSONDemographics[0].OFFICE_NAME) AS OfficeName,
                                    -- TO_NUMBER(OfficeJSON[0].RANK) AS AddressRank,
                                    TO_VARCHAR(OfficeJSONAddress[0].ADDRESS_LINE_1) AS AddressLine1,
                                    TO_VARCHAR(OfficeJSONAddress[0].ADDRESS_LINE_2) AS AddressLine2,
                                    TO_VARCHAR(OfficeJSONAddress[0].SUITE) AS Suite,
                                    TO_VARCHAR(OfficeJSONAddress[0].CITY) AS City,
                                    TO_VARCHAR(OfficeJSONAddress[0].STATE) AS State,
                                    TO_VARCHAR(OfficeJSONAddress[0].ZIP) AS PostalCode,
                                    TO_VARCHAR(OfficeJSONAddress[0].LATITUDE) AS Latitude,
                                    TO_VARCHAR(OfficeJSONAddress[0].LONGITUDE) AS Longitude,
                                    TO_VARCHAR(OfficeJSONAddress[0].TIME_ZONE) AS TimeZone,
                                    -- TO_BOOLEAN(OfficeJSON[0].DO_SUPPRESS) AS DoSuppress,
                                    -- TO_BOOLEAN(OfficeJSON[0].IS_DERIVED) AS IsDerived,
                                    TO_TIMESTAMP_NTZ(OfficeJSONAddress[0].UPDATED_DATETIME) AS LastUpdateDate,
                                    TO_VARCHAR(OfficeJSONDemographics[0].OFFICE_CODE) AS OfficeCode,
                                    TO_VARCHAR(OfficeJSONDemographics[0].DATA_SOURCE_CODE) AS SourceCode,
                                    
                            FROM
                                -- Raw.OfficeProfileProcessingDeDup AS DeDup
                                Raw.OFFICE_PROFILE_PROCESSING AS Process 
                                
                            WHERE
                                Process.OFFICE_PROFILE IS NOT NULL AND 
                                OfficeJSONAddress IS NOT NULL AND
                                OfficeJSONDemographics IS NOT NULL AND 
                                -- IFNULL(DoSuppress, 0) = 0 
                                    NULLIF(City,'') IS NOT NULL 
                                    AND NULLIF(State,'') IS NOT NULL 
                                    AND NULLIF(PostalCode,'') IS NOT NULL
                                    AND LENGTH(TRIM(UPPER(AddressLine1)) || IFNULL(TRIM(UPPER(AddressLine2)),'') || IFNULL(TRIM(UPPER(Suite)),'')) > 0
                                        
                            )
                            SELECT DISTINCT 
                                    CSPC.CityStatePostalCodeID, 
                                    CSPC.NationID, 
                                    cte.AddressLine1, 
                                    cte.AddressLine2, 
                                    cte.Latitude, 
                                    cte.Longitude, 
                                    cte.TimeZone, 
                                    cte.Suite
                            FROM CTE_OfficeJSON AS cte
                            JOIN Base.CityStatePostalCode AS CSPC ON cte.PostalCode = CSPC.PostalCode AND cte.City = CSPC.City AND cte.State = CSPC.State
                            WHERE CSPC.CityStatePostalCodeID IS NOT NULL
                            QUALIFY ROW_NUMBER() OVER(PARTITION BY AddressLine1, AddressLine2, Suite, CSPC.City, cte.State, cte.PostalCode ORDER BY CREATE_DATE DESC) = 1 $$;

insert_statement_2 := $$INSERT (
                           AddressID, 
                           CityStatePostalCodeID, 
                           NationID, 
                           AddressLine1, 
                           AddressLine2, 
                           Latitude, 
                           Longitude, 
                           TimeZone, 
                           Suite, 
                           LastUpdateDate 
                        )
                        VALUES 
                        (   UUID_STRING(),
                            source.CityStatePostalCodeID, 
                            source.NationID, 
                            source.AddressLine1, 
                            source.AddressLine2, 
                            source.Latitude, 
                            source.Longitude, 
                            source.TimeZone, 
                            source.Suite, 
                            CURRENT_TIMESTAMP()
                           
                        );$$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement_1 := ' MERGE INTO Base.Address as target USING 
                   ('||select_statement_1||') as source 
                   ON source.AddressLine1 = target.AddressLine1 AND source.CityStatePostalCodeId = target.CityStatePostalCodeId 
                   WHEN NOT MATCHED THEN '||insert_statement_1;

merge_statement_2 := $$ MERGE INTO Base.Address as target USING 
                   ($$||select_statement_2||$$) as source 
                   ON IFF(TRIM(UPPER(source.AddressLine1)) IS NULL, '', TRIM(UPPER(source.AddressLine1))) = IFF(TRIM(UPPER(target.AddressLine1)) IS NULL, '', TRIM(UPPER(target.AddressLine1)))
                   AND IFF(TRIM(UPPER(source.AddressLine2)) IS NULL, '', TRIM(UPPER(source.AddressLine2))) = IFF(TRIM(UPPER(target.AddressLine2)) IS NULL, '', TRIM(UPPER(target.AddressLine2)))
                   AND IFF(TRIM(UPPER(source.Suite)) IS NULL, '', TRIM(UPPER(source.Suite))) = IFF(TRIM(UPPER(target.Suite)) IS NULL, '', TRIM(UPPER(target.Suite)))
                   AND source.CityStatePostalCodeID = target.CityStatePostalCodeID
                   WHEN NOT MATCHED THEN $$||insert_statement_2;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
EXECUTE IMMEDIATE merge_statement_1 ;
EXECUTE IMMEDIATE merge_statement_2 ;

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
--------------------------------------------------------- 

status := 'Completed successfully';
    RETURN status;


        
EXCEPTION
    WHEN OTHER THEN
          status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
          RETURN status;

    
END;