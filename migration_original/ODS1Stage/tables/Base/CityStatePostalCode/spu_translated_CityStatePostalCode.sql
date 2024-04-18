CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_CITYSTATEPOSTALCODE() 
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
select_statement_1 := $$ SELECT DISTINCT
                                CASE WHEN TRIM(Address_City) LIKE '%,' THEN LEFT(TRIM(Address_City), LENGTH(Address_City)-1) ELSE Address_City END AS City,
                                Address_State AS State,
                                Address_PostalCode AS PostalCode
                            FROM
                                Raw.VW_OFFICE_PROFILE
                            WHERE
                                OFFICE_PROFILE IS NOT NULL AND
                                    NULLIF(Address_City,'') IS NOT NULL 
                                    AND NULLIF(Address_State,'') IS NOT NULL 
                                    AND NULLIF(Address_PostalCode,'') IS NOT NULL
                                    AND LENGTH(TRIM(UPPER(Address_AddressLine1)) || IFNULL(TRIM(UPPER(Address_AddressLine2)),'') || IFNULL(TRIM(UPPER(Address_Suite)),'')) > 0
                                         $$;



--- Insert Statement
insert_statement_1 := ' INSERT (
                                CityStatePostalCodeId,
                                City,
                                State,
                                PostalCode,
                                LastUpdateDate
                        )
                        VALUES (
                                UUID_STRING(),
                                source.city,
                                source.state,
                                source.postalcode,
                                CURRENT_TIMESTAMP()
                        )';

select_statement_2 := $$ SELECT DISTINCT
                                    Address_City AS City,
                                    Address_State AS State,
                                    Address_PostalCode AS PostalCode,
                                    Address_Latitude AS Latitude,
                                    Address_Longitude AS Longitude
                                FROM
                                    Raw.VW_FACILITY_PROFILE AS JSON 
                                    JOIN Base.Facility AS Facility ON JSON.FacilityCode = Facility.FacilityCode
                                WHERE
                                    JSON.FACILITY_PROFILE IS NOT NULL AND
                                    NULLIF(City,'') IS NOT NULL 
                                    AND NULLIF(State,'') IS NOT NULL 
                                    AND NULLIF(PostalCode,'') IS NOT NULL $$;

insert_statement_2 := $$INSERT (
                            CityStatePostalCodeId, 
                            City, 
                            State, 
                            PostalCode, 
                            CentroidLatitude, 
                            CentroidLongitude, 
                            NationId, 
                            LastUpdateDate
                        )
                        VALUES 
                        (   UUID_STRING(), 
                            source.City, 
                            source.State, 
                            source.PostalCode, 
                            source.Latitude, 
                            source.Longitude, 
                            '00415355-0000-0000-0000-000000000000', 
                            CURRENT_TIMESTAMP()
                        );$$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement_1 := ' MERGE INTO Base.CityStatePostalCode as target USING 
                   ('||select_statement_1||') as source 
                   ON source.city = target.city AND source.state = target.state AND source.postalcode = target.postalcode
                   WHEN NOT MATCHED THEN '||insert_statement_1;

merge_statement_2 := ' MERGE INTO Base.CityStatePostalCode as target USING 
                   ('||select_statement_2||') as source 
                   ON source.city = target.city AND source.state = target.state AND source.postalcode = target.postalcode
                   WHEN NOT MATCHED THEN '||insert_statement_2;
                   
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