CREATE OR REPLACE PROCEDURE ODS1_STAGE.MID.SP_LOAD_PROVIDERPRACTICEOFFICE(IsProviderDeltaProcessing BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- base.officetoaddress
-- base.practice
-- base.officetophone
-- mid.providerpracticeoffice
-- base.provider
-- base.phone
-- base.nation
-- base.address
-- base.phonetype
-- base.practiceemail
-- base.office
-- base.providertooffice
-- raw.providerdeltaprocessing
-- base.citystate

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

delta_select_statement STRING; -- CTE and Select statement for delta
select_statement STRING; -- CTE and Select statement for the Merge
update_statement STRING; -- Main Update statement for the Merge
insert_statement STRING; -- Insert statement for the Merge
merge_statement STRING; -- Merge statement to final table
status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    IF (IsProviderDeltaProcessing) THEN
       EXECUTE IMMEDIATE $$ TRUNCATE TABLE Mid.ProviderPracticeOffice $$;
       delta_select_statement :=  $$        
                            WITH CTE_ProviderBatch AS (
                            SELECT pdp.ProviderID
                            FROM Raw.ProviderDeltaProcessing as pdp), 
                            $$;
    ELSE
       EXECUTE IMMEDIATE $$ DELETE FROM Mid.ProviderPracticeOffice ppo 
                              USING raw.ProviderDeltaProcessing pdp
                              WHERE pdp.ProviderID = ppo.ProviderID 
                         $$;
            
       delta_select_statement := $$
                               WITH CTE_ProviderBatch AS (
                                    SELECT p.ProviderID
                                    FROM Base.Provider as p
                                    ORDER BY p.ProviderID),
                               $$;
    END IF;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

select_statement := delta_select_statement || 
            $$
            CTE_ServiceNumbers AS (
                SELECT o.PhoneNumber, pto.OfficeID, ROW_NUMBER() OVER(PARTITION BY pto.OfficeID ORDER BY pto.PhoneRank, pto.LastUpdateDate DESC, 
                       o.LastUpdateDate, pto.PhoneId) AS SequenceId1   
                FROM Base.OfficeToPhone pto
                JOIN Base.Phone o ON (pto.PhoneID = o.PhoneID)
                WHERE pto.PhoneTypeID = (SELECT PhoneTypeID FROM Base.PhoneType WHERE PhoneTypeCode = 'Service') 
            ),
            
            CTE_FaxNumbers AS (
                SELECT o.PhoneNumber, pto.OfficeID, ROW_NUMBER() OVER(PARTITION BY pto.OfficeID ORDER BY pto.PhoneRank, pto.LastUpdateDate DESC,                      o.LastUpdateDate, pto.PhoneId) AS SequenceId1
                FROM Base.OfficeToPhone pto
                JOIN Base.Phone o ON (pto.PhoneID = o.PhoneID)
                WHERE pto.PhoneTypeID = (SELECT PhoneTypeID FROM Base.PhoneType WHERE PhoneTypeCode = 'Fax') 
            ),
            
            CTE_ProviderOfficeRank AS (
                SELECT ProviderID, MIN(ProviderOfficeRank) AS ProviderOfficeRank
                FROM Base.ProviderToOffice
                WHERE ProviderOfficeRank IS NOT NULL
                GROUP BY ProviderID
            ),
            
            CTE_PracticeEmails AS (
                SELECT PracticeID, EmailAddress, ROW_NUMBER() OVER (PARTITION BY PracticeID ORDER BY LEN(EmailAddress)) AS EmailRank
                FROM Base.PracticeEmail
                WHERE EmailAddress IS NOT NULL
            ),
            
            CTE_ProviderPracticeOffice AS (
                SELECT DISTINCT 
                    pto.ProviderToOfficeID, 
                    pto.ProviderID,  
                    p.PracticeID, 
                    p.PracticeCode, 
                    CASE 
                        WHEN pto.PracticeName IS NOT NULL THEN pto.PracticeName 
                        ELSE p.PracticeName 
                    END AS PracticeName,
                    p.YearPracticeEstablished, 
                    p.NPI AS PracticeNPI, 
                    cte_pe.EmailAddress AS PracticeEmail,
                    p.PracticeWebsite, 
                    p.PracticeDescription, 
                    p.PracticeLogo, 
                    p.PracticeMedicalDirector, 
                    p.PracticeSoftware, 
                    p.PracticeTIN, 
                    ota.OfficeToAddressID, 
                    o.OfficeID, 
                    o.OfficeCode, 
                    CASE 
                        WHEN pto.OfficeName IS NOT NULL THEN pto.OfficeName 
                        ELSE o.OfficeName 
                    END AS OfficeName, 
                    CASE
                        WHEN cte_por.ProviderID IS NOT NULL THEN 1
                        ELSE NULL 
                    END AS IsPrimaryOffice, 
                    pto.ProviderOfficeRank, 
                    a.AddressID, 
                    a.AddressCode, 
                    'Office' AS AddressTypeCode, 
                    a.AddressLine1 AS AddressLine1, 
                    NULL AS AddressLine2, 
                    a.AddressLine3, 
                    a.AddressLine4,
                    cspc.City, 
                    cspc.State, 
                    cspc.PostalCode AS ZipCode, 
                    cspc.County, 
                    n.NationName AS Nation, 
                    a.Latitude, 
                    a.Longitude,
                    cte_sn.PhoneNumber AS FullPhone,
                    cte_fn.PhoneNumber AS FullFax,
                    ota.IsDerived, 
                    o.HasBillingStaff,
                    o.HasHandicapAccess, 
                    o.HasLabServicesOnSite, 
                    o.HasPharmacyOnSite, 
                    o.HasXrayOnSite, 
                    o.IsSurgeryCenter, 
                    o.HasSurgeryOnSite, 
                    o.AverageDailyPatientVolume, 
                    NULL AS PhysicianCount, 
                    o.OfficeCoordinatorName, 
                    o.ParkingInformation, 
                    o.PaymentPolicy,
                    o.LegacyKey AS LegacyKeyOffice, 
                    p.LegacyKey AS LegacyKeyPractice,
                    0 AS ActionCode
                FROM CTE_ProviderBatch pb 
                INNER JOIN Base.ProviderToOffice AS pto ON pb.ProviderID = pto.ProviderID
                INNER JOIN Base.Office AS o ON o.OfficeID = pto.OfficeID
                INNER JOIN Base.OfficeToAddress AS ota ON o.OfficeID = ota.OfficeID
                INNER JOIN Base.Address AS a ON a.AddressID = ota.AddressID	
                LEFT JOIN CTE_ServiceNumbers AS cte_sn ON cte_sn.OfficeID = o.OfficeID AND cte_sn.SequenceId1 = 1
                LEFT JOIN CTE_FaxNumbers AS cte_fn ON cte_fn.OfficeID = o.OfficeID AND cte_fn.SequenceId1 = 1
                LEFT JOIN Base.CityStatePostalCode AS cspc ON a.CityStatePostalCodeID = cspc.CityStatePostalCodeID
                LEFT JOIN Base.Nation AS n ON cspc.NationID = n.NationID
                LEFT JOIN Base.Practice AS p ON o.PracticeID = p.PracticeID
                LEFT JOIN CTE_ProviderOfficeRank AS cte_por ON pto.ProviderID = cte_por.ProviderID AND pto.ProviderOfficeRank = cte_por.ProviderOfficeRank
                LEFT JOIN CTE_PracticeEmails cte_pe ON cte_pe.PracticeID = o.PracticeID AND cte_pe.EmailRank = 1
            ),
            
            -- Insert Action
            CTE_Action_1 AS (
                    SELECT 
                        cte.ProviderID,
                        cte.OfficeID,
                        cte.FullPhone,
                        cte.FullFax,
                        1 AS ActionCode
                    FROM CTE_ProviderPracticeOffice AS cte
                    LEFT JOIN Mid.ProviderPracticeOffice AS mid 
                        ON (cte.ProviderID = mid.ProviderID AND cte.OfficeID = mid.OfficeID
                        AND IFNULL(cte.FullPhone, '') = IFNULL(mid.FullPhone, '')
                        AND IFNULL(cte.FullFax, '') = IFNULL(mid.FullFax, ''))
                    WHERE mid.ProviderToOfficeID IS NULL
            ),
            
            -- Update Action
            CTE_Action_2 AS (
                    SELECT 
                        cte.ProviderID,
                        cte.OfficeID,
                        cte.FullPhone,
                        cte.FullFax,
                        2 AS ActionCode
                    FROM CTE_ProviderPracticeOffice AS cte
                    INNER JOIN Mid.ProviderPracticeOffice AS mid 
                        ON (cte.ProviderID = mid.ProviderID AND cte.OfficeID = mid.OfficeID
                        AND IFNULL(cte.FullPhone, '') = IFNULL(mid.FullPhone, '')
                        AND IFNULL(cte.FullFax, '') = IFNULL(mid.FullFax, ''))
                    WHERE 
                        MD5(IFNULL(cte.AddressCode::VARCHAR,'''')) <> MD5(IFNULL(mid.AddressCode::VARCHAR,'''')) OR 
                        MD5(IFNULL(cte.AddressID::VARCHAR,'''')) <> MD5(IFNULL(mid.AddressID::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.AddressLine1::VARCHAR,'''')) <> MD5(IFNULL(mid.AddressLine1::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.AddressLine2::VARCHAR,'''')) <> MD5(IFNULL(mid.AddressLine2::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.AddressLine3::VARCHAR,'''')) <> MD5(IFNULL(mid.AddressLine3::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.AddressLine4::VARCHAR,'''')) <> MD5(IFNULL(mid.AddressLine4::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.AddressTypeCode::VARCHAR,'''')) <> MD5(IFNULL(mid.AddressTypeCode::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.AverageDailyPatientVolume::VARCHAR,'''')) <> MD5(IFNULL(mid.AverageDailyPatientVolume::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.City::VARCHAR,'''')) <> MD5(IFNULL(mid.City::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.County::VARCHAR,'''')) <> MD5(IFNULL(mid.County::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.FullFax::VARCHAR,'''')) <> MD5(IFNULL(mid.FullFax::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.FullPhone::VARCHAR,'''')) <> MD5(IFNULL(mid.FullPhone::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.HasBillingStaff::VARCHAR,'''')) <> MD5(IFNULL(mid.HasBillingStaff::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.HasHandicapAccess::VARCHAR,'''')) <> MD5(IFNULL(mid.HasHandicapAccess::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.HasLabServicesOnSite::VARCHAR,'''')) <> MD5(IFNULL(mid.HasLabServicesOnSite::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.HasPharmacyOnSite::VARCHAR,'''')) <> MD5(IFNULL(mid.HasPharmacyOnSite::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.HasSurgeryOnSite::VARCHAR,'''')) <> MD5(IFNULL(mid.HasSurgeryOnSite::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.HasXrayOnSite::VARCHAR,'''')) <> MD5(IFNULL(mid.HasXrayOnSite::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.IsDerived::VARCHAR,'''')) <> MD5(IFNULL(mid.IsDerived::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.IsPrimaryOffice::VARCHAR,'''')) <> MD5(IFNULL(mid.IsPrimaryOffice::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.IsSurgeryCenter::VARCHAR,'''')) <> MD5(IFNULL(mid.IsSurgeryCenter::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.Latitude::VARCHAR,'''')) <> MD5(IFNULL(mid.Latitude::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.LegacyKeyOffice::VARCHAR,'''')) <> MD5(IFNULL(mid.LegacyKeyOffice::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.LegacyKeyPractice::VARCHAR,'''')) <> MD5(IFNULL(mid.LegacyKeyPractice::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.Longitude::VARCHAR,'''')) <> MD5(IFNULL(mid.Longitude::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.Nation::VARCHAR,'''')) <> MD5(IFNULL(mid.Nation::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.OfficeCode::VARCHAR,'''')) <> MD5(IFNULL(mid.OfficeCode::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.OfficeCoordinatorName::VARCHAR,'''')) <> MD5(IFNULL(mid.OfficeCoordinatorName::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.OfficeID::VARCHAR,'''')) <> MD5(IFNULL(mid.OfficeID::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.OfficeName::VARCHAR,'''')) <> MD5(IFNULL(mid.OfficeName::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.OfficeToAddressID::VARCHAR,'''')) <> MD5(IFNULL(mid.OfficeToAddressID::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.ParkingInformation::VARCHAR,'''')) <> MD5(IFNULL(mid.ParkingInformation::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.PaymentPolicy::VARCHAR,'''')) <> MD5(IFNULL(mid.PaymentPolicy::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.PhysicianCount::VARCHAR,'''')) <> MD5(IFNULL(mid.PhysicianCount::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.PracticeCode::VARCHAR,'''')) <> MD5(IFNULL(mid.PracticeCode::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.PracticeDescription::VARCHAR,'''')) <> MD5(IFNULL(mid.PracticeDescription::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.PracticeEmail::VARCHAR,'''')) <> MD5(IFNULL(mid.PracticeEmail::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.PracticeID::VARCHAR,'''')) <> MD5(IFNULL(mid.PracticeID::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.PracticeLogo::VARCHAR,'''')) <> MD5(IFNULL(mid.PracticeLogo::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.PracticeMedicalDirector::VARCHAR,'''')) <> MD5(IFNULL(mid.PracticeMedicalDirector::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.PracticeName::VARCHAR,'''')) <> MD5(IFNULL(mid.PracticeName::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.PracticeNPI::VARCHAR,'''')) <> MD5(IFNULL(mid.PracticeNPI::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.PracticeSoftware::VARCHAR,'''')) <> MD5(IFNULL(mid.PracticeSoftware::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.PracticeTIN::VARCHAR,'''')) <> MD5(IFNULL(mid.PracticeTIN::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.PracticeWebsite::VARCHAR,'''')) <> MD5(IFNULL(mid.PracticeWebsite::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.ProviderID::VARCHAR,'''')) <> MD5(IFNULL(mid.ProviderID::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.ProviderOfficeRank::VARCHAR,'''')) <> MD5(IFNULL(mid.ProviderOfficeRank::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.ProviderToOfficeID::VARCHAR,'''')) <> MD5(IFNULL(mid.ProviderToOfficeID::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.State::VARCHAR,'''')) <> MD5(IFNULL(mid.State::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.YearPracticeEstablished::VARCHAR,'''')) <> MD5(IFNULL(mid.YearPracticeEstablished::VARCHAR,'''')) OR
                        MD5(IFNULL(cte.ZipCode::VARCHAR,'''')) <> MD5(IFNULL(mid.ZipCode::VARCHAR,''''))
            )
            
            SELECT DISTINCT
                A0.AddressCode,
                A0.AddressID,
                A0.AddressLine1,
                A0.AddressLine2,
                A0.AddressLine3,
                A0.AddressLine4,
                A0.AddressTypeCode,
                A0.AverageDailyPatientVolume,
                A0.City,
                A0.County,
                A0.FullFax,
                A0.FullPhone,
                A0.HasBillingStaff,
                A0.HasHandicapAccess,
                A0.HasLabServicesOnSite,
                A0.HasPharmacyOnSite,
                A0.HasSurgeryOnSite,
                A0.HasXrayOnSite,
                A0.IsDerived,
                A0.IsPrimaryOffice,
                A0.IsSurgeryCenter,
                A0.Latitude,
                A0.LegacyKeyOffice,
                A0.LegacyKeyPractice,
                A0.Longitude,
                A0.Nation,
                A0.OfficeCode,
                A0.OfficeCoordinatorName,
                A0.OfficeID,
                A0.OfficeName,
                A0.OfficeToAddressID,
                A0.ParkingInformation,
                A0.PaymentPolicy,
                A0.PhysicianCount,
                A0.PracticeCode,
                A0.PracticeDescription,
                A0.PracticeEmail,
                A0.PracticeID,
                A0.PracticeLogo,
                A0.PracticeMedicalDirector,
                A0.PracticeName,
                A0.PracticeNPI,
                A0.PracticeSoftware,
                A0.PracticeTIN,
                A0.PracticeWebsite,
                A0.ProviderID,
                A0.ProviderOfficeRank,
                A0.ProviderToOfficeID,
                A0.State,
                A0.YearPracticeEstablished,
                A0.ZipCode,
                IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) AS ActionCode  
            FROM CTE_ProviderPracticeOffice AS A0
            LEFT JOIN CTE_Action_1 AS A1 ON A0.ProviderID = A1.ProviderID AND A0.OfficeID = A1.OfficeID
            LEFT JOIN CTE_Action_2 AS A2 ON A0.ProviderID = A2.ProviderID AND A0.OfficeID = A2.OfficeID
            WHERE IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) <> 0
            $$;
                        


---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------

update_statement := $$
                     UPDATE SET 
                        target.AddressCode = source.AddressCode,
                        target.AddressID = source.AddressID,
                        target.AddressLine1 = source.AddressLine1,
                        target.AddressLine2 = source.AddressLine2,
                        target.AddressLine3 = source.AddressLine3,
                        target.AddressLine4 = source.AddressLine4,
                        target.AddressTypeCode = source.AddressTypeCode,
                        target.AverageDailyPatientVolume = source.AverageDailyPatientVolume,
                        target.City = CASE 
                                        WHEN source.City || ', ' || source.State LIKE '%,,%' THEN LEFT(source.City, LENGTH(source.City) - 1)
                                        ELSE source.City
                                      END,
                        target.County = source.County,
                        target.FullFax = source.FullFax,
                        target.FullPhone = source.FullPhone,
                        target.HasBillingStaff = source.HasBillingStaff,
                        target.HasHandicapAccess = source.HasHandicapAccess,
                        target.HasLabServicesOnSite = source.HasLabServicesOnSite,
                        target.HasPharmacyOnSite = source.HasPharmacyOnSite,
                        target.HasSurgeryOnSite = source.HasSurgeryOnSite,
                        target.HasXrayOnSite = source.HasXrayOnSite,
                        target.IsDerived = source.IsDerived,
                        target.IsPrimaryOffice = source.IsPrimaryOffice,
                        target.IsSurgeryCenter = source.IsSurgeryCenter,
                        target.Latitude = source.Latitude,
                        target.LegacyKeyOffice = source.LegacyKeyOffice,
                        target.LegacyKeyPractice = source.LegacyKeyPractice,
                        target.Longitude = source.Longitude,
                        target.Nation = source.Nation,
                        target.OfficeCode = source.OfficeCode,
                        target.OfficeCoordinatorName = source.OfficeCoordinatorName,
                        target.OfficeID = source.OfficeID,
                        target.OfficeName = Mid.FNUREMOVESPECIALHEXADECIMALCHARACTERS(source.OfficeName),
                        target.OfficeToAddressID = source.OfficeToAddressID,
                        target.ParkingInformation = source.ParkingInformation,
                        target.PaymentPolicy = source.PaymentPolicy,
                        target.PhysicianCount = source.PhysicianCount,
                        target.PracticeCode = source.PracticeCode,
                        target.PracticeDescription = source.PracticeDescription,
                        target.PracticeEmail = source.PracticeEmail,
                        target.PracticeID = source.PracticeID,
                        target.PracticeLogo = source.PracticeLogo,
                        target.PracticeMedicalDirector = source.PracticeMedicalDirector,
                        target.PracticeName = source.PracticeName,
                        target.PracticeNPI = source.PracticeNPI,
                        target.PracticeSoftware = source.PracticeSoftware,
                        target.PracticeTIN = source.PracticeTIN,
                        target.PracticeWebsite = source.PracticeWebsite,
                        target.ProviderID = source.ProviderID,
                        target.ProviderOfficeRank = source.ProviderOfficeRank,
                        target.ProviderToOfficeID = source.ProviderToOfficeID,
                        target.State = source.State,
                        target.YearPracticeEstablished = source.YearPracticeEstablished,
                        target.ZipCode = source.ZipCode
                      $$;


--- Insert Statement
insert_statement :=   $$
                      INSERT  (
                                AddressCode,
                                AddressID,
                                AddressLine1,
                                AddressLine2,
                                AddressLine3,
                                AddressLine4,
                                AddressTypeCode,
                                AverageDailyPatientVolume,
                                City,
                                County,
                                FullFax,
                                FullPhone,
                                HasBillingStaff,
                                HasHandicapAccess,
                                HasLabServicesOnSite,
                                HasPharmacyOnSite,
                                HasSurgeryOnSite,
                                HasXrayOnSite,
                                IsDerived,
                                IsPrimaryOffice,
                                IsSurgeryCenter,
                                Latitude,
                                LegacyKeyOffice,
                                LegacyKeyPractice,
                                Longitude,
                                Nation,
                                OfficeCode,
                                OfficeCoordinatorName,
                                OfficeID,
                                OfficeName,
                                OfficeToAddressID,
                                ParkingInformation,
                                PaymentPolicy,
                                PhysicianCount,
                                PracticeCode,
                                PracticeDescription,
                                PracticeEmail,
                                PracticeID,
                                PracticeLogo,
                                PracticeMedicalDirector,
                                PracticeName,
                                PracticeNPI,
                                PracticeSoftware,
                                PracticeTIN,
                                PracticeWebsite,
                                ProviderID,
                                ProviderOfficeRank,
                                ProviderToOfficeID,
                                State,
                                YearPracticeEstablished,
                                ZipCode
                               )
                      VALUES  (
                                source.AddressCode,
                                source.AddressID,
                                source.AddressLine1,
                                source.AddressLine2,
                                source.AddressLine3,
                                source.AddressLine4,
                                source.AddressTypeCode,
                                source.AverageDailyPatientVolume,
                                source.City,
                                source.County,
                                source.FullFax,
                                source.FullPhone,
                                source.HasBillingStaff,
                                source.HasHandicapAccess,
                                source.HasLabServicesOnSite,
                                source.HasPharmacyOnSite,
                                source.HasSurgeryOnSite,
                                source.HasXrayOnSite,
                                source.IsDerived,
                                source.IsPrimaryOffice,
                                source.IsSurgeryCenter,
                                source.Latitude,
                                source.LegacyKeyOffice,
                                source.LegacyKeyPractice,
                                source.Longitude,
                                source.Nation,
                                source.OfficeCode,
                                source.OfficeCoordinatorName,
                                source.OfficeID,
                                source.OfficeName,
                                source.OfficeToAddressID,
                                source.ParkingInformation,
                                source.PaymentPolicy,
                                source.PhysicianCount,
                                source.PracticeCode,
                                source.PracticeDescription,
                                source.PracticeEmail,
                                source.PracticeID,
                                source.PracticeLogo,
                                source.PracticeMedicalDirector,
                                source.PracticeName,
                                source.PracticeNPI,
                                source.PracticeSoftware,
                                source.PracticeTIN,
                                source.PracticeWebsite,
                                source.ProviderID,
                                source.ProviderOfficeRank,
                                source.ProviderToOfficeID,
                                source.State,
                                source.YearPracticeEstablished,
                                source.ZipCode
                               )
                       $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement :=  $$
                    MERGE INTO Mid.ProviderPracticeOffice as target USING ($$|| select_statement ||$$) as source 
                    ON source.ProviderID = target.ProviderID
                    WHEN MATCHED AND source.ActionCode = 2 THEN $$|| update_statement ||$$
                    WHEN NOT MATCHED AND source.ActionCode = 1 THEN $$ || insert_statement;

                
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE merge_statement;

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
