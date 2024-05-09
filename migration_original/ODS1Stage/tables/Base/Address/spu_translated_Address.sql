CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_ADDRESS() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.Address depends on: 
--- MDM_TEAM.MST.OFFICE_PROFILE_PROCESSING (RAW.VW_OFFICE_PROFILE)
--- MDM_TEAM.MST.FACILITY_PROFILE_PROCESSING (RAW.VW_FACILITY_PROFILE)
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
    procedure_name varchar(50) default('sp_load_Address');
    execution_start DATETIME default getdate();

   
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
                                JSON.Address_AddressLine1 AS AddressLine1,
                                JSON.Address_Latitude AS Latitude,
                                JSON.Address_Longitude AS Longitude,
                                CSPC.CityStatePostalCodeID 
                                
                            FROM
                                Raw.VW_FACILITY_PROFILE AS JSON 
                                JOIN Base.Facility AS Facility ON JSON.FacilityCode = Facility.FacilityCode
                                JOIN Base.CityStatePostalCode AS CSPC ON JSON.Address_City = CSPC.City AND JSON.Address_State = CSPC.State AND JSON.Address_PostalCode = CSPC.PostalCode 
                            WHERE
                                JSON.FACILITY_PROFILE IS NOT NULL AND 
                                NULLIF(Address_City,'') IS NOT NULL 
                                AND NULLIF(Address_State,'') IS NOT NULL 
                                AND NULLIF(Address_PostalCode,'') IS NOT NULL $$;



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
                                NULL, 
                                source.CityStatePostalCodeId
                        )$$;

select_statement_2 := $$ SELECT DISTINCT
                                    CSPC.CityStatePostalCodeID, 
                                    CSPC.NationID, 
                                    JSON.Address_AddressLine1 AS AddressLine1, 
                                    JSON.Address_AddressLine2 AS AddressLine2, 
                                    JSON.Address_Latitude AS Latitude, 
                                    JSON.Address_Longitude AS Longitude, 
                                    JSON.Address_TimeZone AS TimeZone, 
                                    JSON.Address_Suite AS Suite
                            FROM
                                Raw.VW_OFFICE_PROFILE AS JSON 
                                JOIN Base.CityStatePostalCode AS CSPC ON JSON.Address_PostalCode = CSPC.PostalCode AND JSON.Address_City = CSPC.City AND JSON.Address_State = CSPC.State
                                
                            WHERE
                                JSON.OFFICE_PROFILE IS NOT NULL AND 
                                    NULLIF(Address_City,'') IS NOT NULL 
                                    AND NULLIF(Address_State,'') IS NOT NULL 
                                    AND NULLIF(Address_PostalCode,'') IS NOT NULL
                                    AND LENGTH(TRIM(UPPER(Address_AddressLine1)) || IFNULL(TRIM(UPPER(Address_AddressLine2)),'') || IFNULL(TRIM(UPPER(Address_Suite)),'')) > 0
                                    AND CSPC.CityStatePostalCodeID IS NOT NULL
                            QUALIFY ROW_NUMBER() OVER(PARTITION BY JSON.Address_AddressLine1, JSON.Address_AddressLine2, JSON.Address_Suite, CSPC.City, JSON.Address_State, JSON.Address_PostalCode ORDER BY CREATE_DATE DESC) = 1  $$;

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
                    
EXECUTE IMMEDIATE merge_statement_2 ;
EXECUTE IMMEDIATE merge_statement_1 ;

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
--------------------------------------------------------- 

status := 'Completed successfully';
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        RETURN status;

        EXCEPTION
        WHEN OTHER THEN
            status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, SPLIT_PART(REGEXP_SUBSTR(:status, 'Error code: ([0-9]+)'), ':', 2)::INTEGER, TRIM(SPLIT_PART(SPLIT_PART(:status, 'SQL Error:', 2), 'Error code:', 1)), SPLIT_PART(REGEXP_SUBSTR(:status, 'SQL State: ([0-9]+)'), ':', 2)::INTEGER; 

            RETURN status;
END;