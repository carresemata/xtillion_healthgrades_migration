CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_FACILITYTOADDRESS() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.FacilityToAddress depends on: 
--- Raw.VW_FACILITY_PROFILE
--- Base.Facility
--- Base.CityStatePostalCode
--- Base.Address

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
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
select_statement := $$  SELECT DISTINCT
                                Facility.FacilityID,
                                Address.AddressID,
                                JSON.Address_SourceCode AS SourceCode
                            FROM
                                Raw.VW_FACILITY_PROFILE AS JSON 
                                JOIN Base.Facility AS Facility ON JSON.FacilityCode = Facility.FacilityCode
                                JOIN Base.CityStatePostalCode AS CSPC ON JSON.Address_City = CSPC.City AND JSON.Address_State = CSPC.State AND JSON.Address_PostalCode = CSPC.PostalCode 
                                JOIN Base.Address AS Address ON Address.AddressLine1 = JSON.Address_AddressLine1 AND CSPC.CityStatePostalCodeID = Address.CityStatePostalCodeID 
                            WHERE
                                JSON.FACILITY_PROFILE IS NOT NULL AND 
                                NULLIF(Address_City,'') IS NOT NULL 
                                AND NULLIF(Address_State,'') IS NOT NULL 
                                AND NULLIF(Address_PostalCode,'') IS NOT NULL
                            QUALIFY ROW_NUMBER() OVER(
                                PARTITION BY Facility.FacilityID
                                ORDER BY
                                    Address.AddressID DESC
                            ) = 1 $$;


--- Insert Statement
insert_statement := $$ INSERT (
                            FacilityToAddressId, 
                            FacilityId, 
                            AddressId, 
                            AddressTypeId, 
                            SourceCode, 
                            LastUpdateDate)
                       VALUES (
                            UUID_STRING(), 
                            source.FacilityId, 
                            source.AddressId, 
                            '4946464F-4543-0000-0000-000000000000',
                            source.SourceCode, 
                            CURRENT_TIMESTAMP())
                    $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.FacilityToAddress as target USING 
                   ('||select_statement||') as source 
                   ON source.Facilityid = target.Facilityid
                   WHEN MATCHED THEN DELETE
                   WHEN NOT MATCHED THEN '||insert_statement;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
EXECUTE IMMEDIATE merge_statement ;

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