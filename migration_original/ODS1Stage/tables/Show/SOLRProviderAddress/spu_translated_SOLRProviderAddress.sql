-- sp_load_solrprovideraddress

CREATE OR REPLACE PROCEDURE ODS1_STAGE.Show.SP_LOAD_SOLRPROVIDERADDRESS()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 

    ---------------------------------------------------------
    --------------- 0. Table dependencies -------------------
    ---------------------------------------------------------
    
    -- Show.SOLRProviderAddress depends on: 
    --- Show.SOLRProvider 
    --- Mid.ProviderPracticeOffice
    --- Mid.Provider
    --- Base.ProviderRemoval
    

    ---------------------------------------------------------
    --------------- 1. Declaring variables ------------------
    ---------------------------------------------------------
    DECLARE 
    select_statement STRING; -- CTEs
    insert_statement STRING; -- Insert statements
    update_statement STRING; -- Update statements
    delete_statement STRING; -- Delete statements
    merge_statement STRING; -- Merge statement combining everything
    status STRING; -- Status monitoring

    ---------------------------------------------------------
    --------------- 2.Conditionals if any -------------------
    ---------------------------------------------------------   
    
    ---------------------------------------------------------
    --------------- 3. Select statements --------------------
    ---------------------------------------------------------     
    BEGIN
    
    select_statement := '
                WITH CTE_ProviderID AS (
    
                SELECT ProviderID
                FROM Mid.ProviderPracticeOffice
                GROUP BY
                    ProviderID,
                    City,
                    State
                ),
                
                CTE_MultipleLocations AS (
                    SELECT ProviderID
                    FROM CTE_ProviderID
                    GROUP BY ProviderID
                    HAVING COUNT(*) > 1
                ),
                
                CTE_Source AS (
                    SELECT
                        DISTINCT ppo.ProviderToOfficeID,
                        p.ProviderID,
                        p.ProviderCode,
                        ppo.AddressLine1,
                        ppo.AddressLine2,
                        ppo.City,
                        ppo.State,
                        ppo.ZipCode,
                        ppo.Latitude,
                        ppo.Longitude,
                        CONCAT(ppo.City, '''', '''', ppo.State) AS CityState,
                        CAST(NULL AS VARCHAR(1000)) AS CityStateAlternative,
                        ppo.OfficeCode,
                        ppo.IsPrimaryOffice,
                        ppo.FullPhone,
                        ppo.officeId,
                        CASE
                            WHEN ml.ProviderID IS NOT NULL THEN 1
                            ELSE 0
                        END AS MultipleLocations,
                        TO_GEOGRAPHY(ST_MAKEPOINT(ppo.LONGITUDE, ppo.LATITUDE)) As AddressGeoPoint,
                        ROW_NUMBER() OVER (ORDER BY p.ProviderCode NULLS FIRST) AS SequenceId
                    FROM
                        Mid.Provider p
                        INNER JOIN Mid.ProviderPracticeOffice ppo ON p.ProviderID = ppo.ProviderID
                        LEFT JOIN CTE_MultipleLocations ml ON p.ProviderID = ml.ProviderID
                )
                
                SELECT
                    ProviderToOfficeID,
                    ProviderID,
                    ProviderCode,
                    AddressLine1,
                    AddressLine2,
                    City,
                    State,
                    ZipCode,
                    Latitude,
                    Longitude,
                    CityState,
                    CityStateAlternative,
                    OfficeCode,
                    IsPrimaryOffice,
                    FullPhone,
                    AddressGeoPoint
                FROM CTE_Source
               ';

                     
---------------------------------------------------------
--------------------  4. Actions ------------------------
---------------------------------------------------------  

insert_statement := '
                  INSERT (
                            ProviderToOfficeID,
                            ProviderID,
                            ProviderCode,
                            AddressLine1,
                            AddressLine2,
                            City,
                            State,
                            ZipCode,
                            Latitude,
                            Longitude,
                            CityState,
                            CityStateAlternative,
                            OfficeCode,
                            IsPrimaryOffice,
                            FullPhone,
                            AddressGeoPoint
                            )
                    VALUES (
                            s.ProviderToOfficeID,
                            s.ProviderID,
                            s.ProviderCode,
                            s.AddressLine1,
                            s.AddressLine2,
                            s.City,
                            s.State,
                            s.ZipCode,
                            s.Latitude,
                            s.Longitude,
                            s.CityState,
                            s.CityStateAlternative,
                            s.OfficeCode,
                            s.IsPrimaryOffice,
                            s.FullPhone,
                            s.AddressGeoPoint
                            ) 
                    ';

update_statement := '
                    UPDATE 
                    SET
                      ProviderID = s.ProviderID,
                      ProviderCode = s.ProviderCode,
                      AddressLine1 = s.AddressLine1,
                      AddressLine2 = s.AddressLine2,
                      City = s.City,
                      State = LEFT(s.State, 2),
                      ZipCode = s.ZipCode,
                      Latitude = s.Latitude,
                      Longitude = s.Longitude,
                      CityState = s.CityState,
                      CityStateAlternative = s.CityStateAlternative,
                      OfficeCode = s.OfficeCode,
                      IsPrimaryOffice = s.IsPrimaryOffice,
                      FullPhone = s.FullPhone,
                      RefreshDate = CURRENT_TIMESTAMP()
                    ';

-- This is the merge statement from logic of show.spuSOLRProviderAddressGenerateFromMid                     
merge_statement := '
                   MERGE INTO DEV.SOLRProviderAddress USING 
                   ('||select_statement||') as s 
                   ON DEV.SOLRPROVIDERADDRESS.ProviderToOfficeID = s.ProviderToOfficeID
                   WHEN MATCHED THEN '||update_statement||'
                   WHEN NOT MATCHED THEN '||insert_statement||'
                   ';

-- This delete comes from hack.spuRemoveSuspecProviders
delete_statement := '
                    DELETE FROM DEV.SOLRProviderAddress spa
                    USING Base.ProviderRemoval pr, Show.SOLRProvider sp
                    WHERE sp.ProviderCode = pr.ProviderCode
                    AND sp.ProviderID = spa.ProviderID
                    ';

---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
EXECUTE IMMEDIATE delete_statement; 
EXECUTE IMMEDIATE merge_statement;

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
--------------------------------------------------------- 

status := 'Completed successfully';
    RETURN status;
        
EXCEPTION
    WHEN OTHER THEN
          status := 'Failed during execution.' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
          RETURN status;
END
;