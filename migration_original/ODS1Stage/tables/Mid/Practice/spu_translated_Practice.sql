
-- If statement two possible pracice batch tables

/*
WITH CTE_PracticeBatch AS (
    SELECT PracticeID
    FROM Base.Practice
    ORDER BY PracticeID
)

*/

WITH CTE_PracticeBatch AS (
    SELECT DISTINCT e.PracticeID
    -- We havent decided where this information is gonna live in snowlfake platform
    FROM Snowflake.etl.ProviderDeltaProcessing as a -- !!!!!!!!!!!!
        JOIN Base.ProviderToOffice AS d on d.ProviderID = a.ProviderID
        JOIN Base.Office AS e on e.OfficeID = d.OfficeID
    ORDER BY e.PracticeID
),

CTE_Service AS (
    SELECT  b.PhoneNumber, a.OfficeID
    FROM    Base.OfficeToPhone a
        JOIN Base.Phone b ON (a.PhoneID = b.PhoneID)
        JOIN Base.PhoneType c ON a.PhoneTypeID = c.PhoneTypeID AND PhoneTypeCode = 'Service'
),

CTE_Fax AS (
    SELECT  b.PhoneNumber, a.OfficeID
    FROM    Base.OfficeToPhone a
        JOIN Base.Phone b ON (a.PhoneID = b.PhoneID)
        JOIN Base.PhoneType c ON a.PhoneTypeID = c.PhoneTypeID AND PhoneTypeCode = 'Fax'
),


CTE_ProviderToPractice AS (
    SELECT  DISTINCT a.ProviderID, c.PracticeID
    FROM    Base.ProviderToOffice AS a
        JOIN Base.Office AS b ON b.OfficeID = a.OfficeID
        JOIN Base.Practice AS c ON c.PracticeID = b.PracticeID
),
CTE_PhysicianCount AS (
    SELECT PracticeID, COUNT(*) AS PhysicianCount
    FROM CTE_ProviderToPractice
    GROUP BY PracticeID
),
--build a temp table of practices with at least one dentist at one of their office
CTE_PracticesWithDentists AS (
    SELECT pb.PracticeID 
    FROM CTE_PracticeBatch AS pb 
        JOIN ODS1Stage.base.Office AS o ON o.PracticeID = pb.PracticeID
        JOIN ODS1Stage.base.ProviderToOffice AS po ON po.OfficeID = o.OfficeID
        JOIN ODS1Stage.base.ProviderToProviderType AS ppt ON ppt.ProviderID = po.ProviderID 
        JOIN ODS1Stage.base.ProviderType AS pt ON pt.ProviderTypeID = ppt.ProviderTypeID
    WHERE pt.ProviderTypeCode = 'DENT'
),
CTE_PROVTOOFF AS (
    SELECT u.ParentID, x.OfficeID, x.OfficeCode, x.OfficeName, y.PracticeID, y.PracticeCode, y.PracticeName,w.ClientProductToEntityID                           
    FROM Base.ClientProductEntityRelationship u 
        JOIN Base.RelationshipType v ON u.RelationshipTypeID = v.RelationshipTypeID
        JOIN Base.ClientProductToEntity w ON w.ClientProductToEntityID = u.ChildID
        JOIN Base.Office x ON w.EntityID = x.OfficeID 
        JOIN Base.Practice y ON x.PracticeID = y.PracticeID
    WHERE  v.RelationshipTypeCode = 'PROVTOOFF'   
),
CTE_OfficeCode_1 AS (
        SELECT x1.OfficeCode 
        FROM Base.Office x1 
        WHERE x1.OfficeCode IN ( 'OOO5XB5','OOO82BH','Y3GT4X','YBD8MY','YBD8V7','OOJQPVR','OOJQQB2','YCFH2F','YCFHK7','OOO38H7','YBV56C','OOJVW28','OOJQPWJ','OOS4S2S','OOJTJTQ','YBV5LG','OOO8HQ3')
),
CTE_OfficeCode_2 AS (
        SELECT g.OfficeCode
        FROM   Base.ClientToProduct a
            JOIN Base.Client b ON a.ClientID = b.ClientID
            JOIN Base.Product c ON a.ProductID = c.ProductID AND c.ProductCode = 'PDCPRAC'
            JOIN Base.ProductGroup pg ON c.ProductGroupID = pg.ProductGroupID AND pg.ProductGroupCode = 'PDC'
            JOIN Base.ClientProductToEntity d ON a.ClientToProductID = d.ClientToProductID
            JOIN Base.EntityType e ON d.EntityTypeID = e.EntityTypeID AND e.EntityTypeCode = 'PROV'
            JOIN base.Provider AS pb ON d.EntityID = pb.ProviderID --When not migrating a batch, this is all providers in Base.Provider. Otherwise it is just the providers in the batch
            JOIN Base.Provider f ON d.EntityID = f.ProviderID
            JOIN CTE_PROVTOOFF AS g ON d.ClientProductToEntityID = g.ParentID
        WHERE  a.ActiveFlag = 1
),
CTE_OfficeCode_3 AS (
        SELECT o.OfficeCode 
        FROM   Base.ClientToProduct a
            JOIN Base.Client b ON a.ClientID = b.ClientID
            JOIN Base.Product c ON a.ProductID = c.ProductID AND c.ProductCode <> 'PDCPRAC'
            JOIN Base.ProductGroup pg ON c.ProductGroupID = pg.ProductGroupID AND pg.ProductGroupCode = 'PDC'
            JOIN Base.ClientProductToEntity d ON a.ClientToProductID = d.ClientToProductID
            JOIN Base.EntityType e ON d.EntityTypeID = e.EntityTypeID AND e.EntityTypeCode = 'PROV'
            JOIN Base.Provider f ON d.EntityID = f.ProviderID
            JOIN Base.ProviderToOffice pto ON pto.ProviderID = f.ProviderID
            JOIN Base.Office o ON o.officeID = pto.OfficeID
        WHERE  a.ActiveFlag = 1
),
CTE_ColumnUpdates AS (
        SELECT  
            COULUM_NAME AS name, 
            ROW_NUMBER() OVER (ORDER BY name) AS recId
        FROM INFORMATION_SCHEMA.COLUMNS  
        WHERE TABLE_NAME = 'TempPracticeSponsorship' AND 
        name NOT IN ('PracticeCode', 'ProductCode', 'ActionCode')
),


CREATE OR REPLACE TEMPORARY TABLE TempPractice AS (
    SELECT  DISTINCT 
        a.PracticeID,
        a.PracticeCode,
        TRIM(a.PracticeName) AS PracticeName,
        a.YearPracticeEstablished,
        a.NPI, 
        a.PracticeWebsite,
        a.PracticeDescription,
        a.PracticeLogo,
        a.PracticeMedicalDirector,
        a.PracticeSoftware,
        a.PracticeTIN,
        b.OfficeID,
        b.OfficeCode,
        TRIM(b.OfficeName) AS officename,
        d.AddressTypeCode,
        e.AddressLine1 || IFNULL( || ' ' || e.Suite,'') AS AddressLine1,
        e.AddressLine2,
        e.AddressLine3,
        e.AddressLine4,
        j.City, 
        j.State, 
        j.PostalCode AS ZipCode,
        j.County,
        k.NationName AS Nation,
        e.Latitude,e.Longitude,
        f.PhoneNumber AS FullPhone,
        z.PhoneNumber AS FullFax,
        b.HasBillingStaff,
        b.HasHandicapAccess,
        b.HasLabServicesOnSite,
        b.HasPharmacyOnSite,
        b.HasXrayOnSite,
        b.IsSurgeryCenter,
        b.HasSurgeryOnSite,
        b.AverageDailyPatientVolume,
        NULL AS PhysicianCount,
        b.OfficeCoordinatorName,
        b.ParkingInformation,
        b.PaymentPolicy,
        b.LegacyKey AS LegacyKeyOffice,
        a.LegacyKey AS LegacyKeyPractice,
        b.OfficeRank,
        e.CityStatePostalCodeID,
        0,
        REPLACE(
            REPLACE(
                replace('/group-directory/'||LOWER(j.State)||'-'|| LOWER(
                    REPLACE(c1.StateName,' ','-'))||'/'||
        lower(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
                j.City,
                ' - ',' '),
                '&','-'),
                ' ','-'),
                '/','-'),
                '''',''),
                '.',''),
                '--','-')) || '/' || 
        lower(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
                TRIM(a.PracticeName),
                ' - ',' '),
                '&','-'),
                ' ','-'),
                '/','-'),
                '\\','-'),
                '''',''),
                ':',''),
                '~',''),
                ';',''),
                '|',''),
                '<',''),
                '>',''),
                '™',''),
                '•',''),
                '*',''),
                '?',''),
                '+',''),
                '®',''),
                '!',''),
                '–',''),
                '@',''),
                '{',''),
                '}',''),
                '[',''),
                ']',''),
                '(',''),
                ')',''),
                'ñ','n'),
                'é','e'),
                'í','i'),
                '"',''),
                '’',''),
                ' ',''),
                '`',''),
                ',',''),
                '#',''),
                '.',''),
                '---','-'),
                '--','-')) || 
                '-' || LOWER(b.OfficeCode) ,'--','-'),char(13),''), char(10),'') AS OfficeURL
    FROM CTE_PracticeBatch as pb  --When not migrating a batch, this is all offices in Base.Office. Otherwise it is just the offices for the providers in the batch
        JOIN Base.Practice AS a on a.PracticeID = pb.PracticeID
        JOIN Base.Office AS b ON a.PracticeID = b.PracticeID
        JOIN Base.OfficeToAddress AS c ON b.OfficeID = c.OfficeID
        JOIN Base.ProviderToOffice po on b.OfficeID = po.OfficeID
        LEFT JOIN Base.AddressType AS d  ON d.AddressTypeID = c.AddressTypeID
        JOIN Base.Address AS e ON e.AddressID = c.AddressID
        JOIN Base.CityStatePostalCode AS j ON e.CityStatePostalCodeID = j.CityStatePostalCodeID
        JOIN Base.Nation k ON IFNULL(J.NationID,'00415355-0000-0000-0000-000000000000') = k.NationID
        JOIN Base.State c1 ON c1.state = j.state
        LEFT JOIN CTE_Service AS  f ON (f.OfficeID = b.OfficeID)
        LEFT JOIN CTE_Fax AS z  ON (z.OfficeID = b.OfficeID)
)

--UPDATE the PhysicianCount based on DISTINCT providers at the Practice level
UPDATE a 
SET a.PhysicianCount = b.PhysicianCount
FROM TempPractice AS a
JOIN CTE_PhysicianCount AS b ON b.PracticeID = a.PracticeID

UPDATE A
SET HasDentist = 1
FROM TempPractice AS A
JOIN CTE_PracticesWithDentists AS B ON A.PracticeID = B.PracticeID

UPDATE prac
SET prac.GoogleScriptBlock = '{"@@context": "http://schema.org","@@type" : "MedicalClinic","@@id":"' || prac.OfficeURL || '","name":"' || prac.PracticeName || '","address": {"@@type": "PostalAddress","streetAddress":"' || prac.AddressLine1 || '","addressLocality":"' || prac.City || '","addressRegion":"' || prac.State || '","postalCode":"' || prac.ZipCode || '","addressCountry": "US"},"geo": {"@@type":"GeoCoordinates","latitude":"' || CAST(prac.Latitude AS VARCHAR(MAX)) || '","longitude":"' || CAST(prac.Longitude AS VARCHAR(MAX)) || '"},"telephone":"' || IFNULL(prac.FullPhone,'') || '","potentialAction":{"@@type":"ReserveAction","@@id":"/groupgoogleform/' || prac.OfficeCode || '","url":"/groupgoogleform"}}'
--select prac.GoogleScriptBlock, '{"@@context": "http://schema.org","@@type" : "MedicalClinic","@@id":"'+prac.OfficeURL+'","name":"'+prac.PracticeName+'","address": {"@@type": "PostalAddress","streetAddress":"'+prac.AddressLine1+'","addressLocality":"'+prac.City+'","addressRegion":"'+prac.State+'","postalCode":"'+prac.ZipCode+'","addressCountry": "US"},"geo": {"@@type":"GeoCoordinates","latitude":"'+CAST(prac.Latitude AS VARCHAR(MAX))+'","longitude":"'+CAST(prac.Longitude AS VARCHAR(MAX))+'"},"telephone":"'+ISNULL(prac.FullPhone,'')+'","potentialAction":{"@@type":"ReserveAction","@@id":"/groupgoogleform/'+prac.OfficeCode+'","url":"/groupgoogleform"}}'
FROM   TempPractice AS prac
JOIN (
        SELECT * FROM CTE_OfficeCode_1
        --AND x1.OfficeCode = prac.OfficeCode
        UNION
        SELECT * FROM CTE_OfficeCode_2
            --AND g.OfficeCode = prac.OfficeCode
        UNION
        SELECT * FROM CTE_OfficeCode_3
            --AND o.OfficeCode = prac.OfficeCode
    ) x ON x.OfficeCode = prac.OfficeCode


UPDATE  a
SET     a.ActionCode = 1
--SELECT *
FROM    TempPractice a
    LEFT JOIN Mid.Practice b ON (a.PracticeID = b.PracticeID and a.OfficeID = b.OfficeID)
WHERE   b.PracticeID IS NULL 

UPDATE A
SET A.ActionCode = 2
FROM TempPractice A
JOIN Mid.Practice B ON A.PracticeID = B.PracticeID AND A.OfficeID = B.OfficeID
WHERE
    MD5(IFNULL(A.PracticeName::VARCHAR,''))<>MD5(IFNULL(B.PracticeName::VARCHAR,'')) OR
    MD5(IFNULL(A.YearPracticeEstablished::VARCHAR,''))<>MD5(IFNULL(B.YearPracticeEstablished::VARCHAR,'')) OR
    MD5(IFNULL(A.NPI::VARCHAR,''))<>MD5(IFNULL(B.NPI::VARCHAR,'')) OR
    MD5(IFNULL(A.PracticeWebsite::VARCHAR,''))<>MD5(IFNULL(B.PracticeWebsite::VARCHAR,'')) OR
    MD5(IFNULL(A.PracticeDescription::VARCHAR,''))<>MD5(IFNULL(B.PracticeDescription::VARCHAR,'')) OR
    MD5(IFNULL(A.PracticeLogo::VARCHAR,''))<>MD5(IFNULL(B.PracticeLogo::VARCHAR,'')) OR
    MD5(IFNULL(A.PracticeMedicalDirector::VARaHAR,''))<>MD5(IFNULL(B.PracticeMedicalDirector::VARCHAR,'')) OR
    MD5(IFNULL(A.PracticeSoftware::VARCHAR,''))<>MD5(IFNULL(B.PracticeSoftware::VARCHAR,'')) OR
    MD5(IFNULL(A.PracticeTIN::VARCHAR,''))<>MD5(IFNULL(B.PracticeTIN::VARCHAR,'')) OR
    MD5(IFNULL(A.OfficeID::VARCHAR,''))<>MD5(IFNULL(B.OfficeID::VARCHAR,'')) OR
    MD5(IFNULL(A.OfficeCode::VARCHAR,''))<>MD5(IFNULL(B.OfficeCode::VARCHAR,'')) OR
    MD5(IFNULL(A.officename::VARCHAR,''))<>MD5(IFNULL(B.officename::VARCHAR,'')) OR
    MD5(IFNULL(A.AddressTypeCode::VARCHAR,''))<>MD5(IFNULL(B.AddressTypeCode::VARCHAR,'')) OR
    MD5(IFNULL(A.AddressLine1::VARCHAR,''))<>MD5(IFNULL(B.AddressLine1::VARCHAR,'')) OR
    MD5(IFNULL(A.AddressLine2::VARCHAR,''))<>MD5(IFNULL(B.AddressLine2::VARCHAR,'')) OR
    MD5(IFNULL(A.AddressLine3::VARCHAR,''))<>MD5(IFNULL(B.AddressLine3::VARCHAR,'')) OR
    MD5(IFNULL(A.AddressLine4::VARCHAR,''))<>MD5(IFNULL(B.AddressLine4::VARCHAR,'')) OR
    MD5(IFNULL(A.City::VARCHAR,''))<>MD5(IFNULL(B.City::VARCHAR,'')) OR
    MD5(IFNULL(A.State::VARCHAR,''))<>MD5(IFNULL(B.State::VARCHAR,'')) OR
    MD5(IFNULL(A.ZipCode::VARCHAR,''))<>MD5(IFNULL(B.ZipCode::VARCHAR,'')) OR
    MD5(IFNULL(A.County::VARCHAR,''))<>MD5(IFNULL(B.County::VARCHAR,'')) OR
    MD5(IFNULL(A.Nation::VARCHAR,''))<>MD5(IFNULL(B.Nation::VARCHAR,'')) OR
    MD5(IFNULL(A.Latitude::VARCHAR,''))<>MD5(IFNULL(B.Latitude::VARCHAR,'')) OR
    MD5(IFNULL(A.Longitude::VARCHAR,''))<>MD5(IFNULL(B.Longitude::VARCHAR,'')) OR
    MD5(IFNULL(A.FullPhone::VARCHAR,''))<>MD5(IFNULL(B.FullPhone::VARCHAR,'')) OR
    MD5(IFNULL(A.FullFax::VARCHAR,''))<>MD5(IFNULL(B.FullFax::VARCHAR,'')) OR
    MD5(IFNULL(A.HasBillingStaff::VARCHAR,''))<>MD5(IFNULL(B.HasBillingStaff::VARCHAR,'')) OR
    MD5(IFNULL(A.HasHandicapAccess::VARCHAR,''))<>MD5(IFNULL(B.HasHandicapAccess::VARCHAR,'')) OR
    MD5(IFNULL(A.HasLabServicesOnSite::VARCHAR,''))<>MD5(IFNULL(B.HasLabServicesOnSite::VARCHAR,'')) OR
    MD5(IFNULL(A.HasPharmacyOnSite::VARCHAR,''))<>MD5(IFNULL(B.HasPharmacyOnSite::VARCHAR,'')) OR
    MD5(IFNULL(A.HasXrayOnSite::VARCHAR,''))<>MD5(IFNULL(B.HasXrayOnSite::VARCHAR,'')) OR
    MD5(IFNULL(A.IsSurgeryCenter::VARCHAR,''))<>MD5(IFNULL(B.IsSurgeryCenter::VARCHAR,'')) OR
    MD5(IFNULL(A.HasSurgeryOnSite::VARCHAR,''))<>MD5(IFNULL(B.HasSurgeryOnSite::VARCHAR,'')) OR
    MD5(IFNULL(A.AverageDailyPatientVolume::VARCHAR,''))<>MD5(IFNULL(B.AverageDailyPatientVolume::VARCHAR,'')) OR
    MD5(IFNULL(A.PhysicianCount::VARCHAR,''))<>MD5(IFNULL(B.PhysicianCount::VARCHAR,'')) OR
    MD5(IFNULL(A.OfficeCoordinatorName::VARCHAR,''))<>MD5(IFNULL(B.OfficeCoordinatorName::VARCHAR,'')) OR
    MD5(IFNULL(A.ParkingInformation::VARCHAR,''))<>MD5(IFNULL(B.ParkingInformation::VARCHAR,'')) OR
    MD5(IFNULL(A.PaymentPolicy::VARCHAR,''))<>MD5(IFNULL(B.PaymentPolicy::VARCHAR,'')) OR
    MD5(IFNULL(A.LegacyKeyOffice::VARCHAR,''))<>MD5(IFNULL(B.LegacyKeyOffice::VARCHAR,'')) OR
    MD5(IFNULL(A.LegacyKeyPractice::VARCHAR,''))<>MD5(IFNULL(B.LegacyKeyPractice::VARCHAR,'')) OR
    MD5(IFNULL(A.OfficeRank::VARCHAR,''))<>MD5(IFNULL(B.OfficeRank::VARCHAR,'')) OR
    MD5(IFNULL(A.CityStatePostalCodeID::VARCHAR,''))<>MD5(IFNULL(B.CityStatePostalCodeID::VARCHAR,'')) OR
    MD5(IFNULL(A.HasDentist::VARCHAR,''))<>MD5(IFNULL(B.HasDentist::VARCHAR,'')) OR
    MD5(IFNULL(A.OfficeURL::VARCHAR,''))<>MD5(IFNULL(B.OfficeURL::VARCHAR,''))

INSERT INTO Mid.Practice
(
    PracticeName,
    YearPracticeEstablished,
    NPI,
    PracticeWebsite,
    PracticeDescription,
    PracticeLogo,
    PracticeMedicalDirector,
    PracticeSoftware,
    PracticeTIN,
    OfficeID,
    OfficeCode,
    officename,
    AddressTypeCode,
    AddressLine1,
    AddressLine2,
    AddressLine3,
    AddressLine4,
    City,
    State,
    ZipCode,
    County,
    Nation,
    Latitude,
    Longitude,
    FullPhone,
    FullFax,
    HasBillingStaff,
    HasHandicapAccess,
    HasLabServicesOnSite,
    HasPharmacyOnSite,
    HasXrayOnSite,
    IsSurgeryCenter,
    HasSurgeryOnSite,
    AverageDailyPatientVolume,
    PhysicianCount,
    OfficeCoordinatorName,
    ParkingInformation,
    PaymentPolicy,
    LegacyKeyOffice,
    LegacyKeyPractice,
    OfficeRank,
    CityStatePostalCodeID,
    HasDentist,
    OfficeURL,
)
SELECT
    PracticeName,
    YearPracticeEstablished,
    NPI,
    PracticeWebsite,
    PracticeDescription,
    PracticeLogo,
    PracticeMedicalDirector,
    PracticeSoftware,
    PracticeTIN,
    OfficeID,
    OfficeCode,
    officename,
    AddressTypeCode,
    AddressLine1,
    AddressLine2,
    AddressLine3,
    AddressLine4,
    City,
    State,
    ZipCode,
    County,
    Nation,
    Latitude,
    Longitude,
    FullPhone,
    FullFax,
    HasBillingStaff,
    HasHandicapAccess,
    HasLabServicesOnSite,
    HasPharmacyOnSite,
    HasXrayOnSite,
    IsSurgeryCenter,
    HasSurgeryOnSite,
    AverageDailyPatientVolume,
    PhysicianCount,
    OfficeCoordinatorName,
    ParkingInformation,
    PaymentPolicy,
    LegacyKeyOffice,
    LegacyKeyPractice,
    OfficeRank,
    CityStatePostalCodeID,
    HasDentist,
    OfficeURL,
FROM TempPractice
WHERE ActionCode = 1

UPDATE A
SET 
    A.PracticeName = B.PracticeName,
    A.YearPracticeEstablished = B.YearPracticeEstablished,
    A.NPI = B.NPI,
    A.PracticeWebsite = B.PracticeWebsite,
    A.PracticeDescription = B.PracticeDescription,
    A.PracticeLogo = B.PracticeLogo,
    A.PracticeMedicalDirector = B.PracticeMedicalDirector,
    A.PracticeSoftware = B.PracticeSoftware,
    A.PracticeTIN = B.PracticeTIN,
    A.OfficeID = B.OfficeID,
    A.OfficeCode = B.OfficeCode,
    A.officename = B.officename,
    A.AddressTypeCode = B.AddressTypeCode,
    A.AddressLine1 = B.AddressLine1,
    A.AddressLine2 = B.AddressLine2,
    A.AddressLine3 = B.AddressLine3,
    A.AddressLine4 = B.AddressLine4,
    A.City = B.City,
    A.State = B.State,
    A.ZipCode = B.ZipCode,
    A.County = B.County,
    A.Nation = B.Nation,
    A.Latitude = B.Latitude,
    A.Longitude = B.Longitude,
    A.FullPhone = B.FullPhone,
    A.FullFax = B.FullFax,
    A.HasBillingStaff = B.HasBillingStaff,
    A.HasHandicapAccess = B.HasHandicapAccess,
    A.HasLabServicesOnSite = B.HasLabServicesOnSite,
    A.HasPharmacyOnSite = B.HasPharmacyOnSite,
    A.HasXrayOnSite = B.HasXrayOnSite,
    A.IsSurgeryCenter = B.IsSurgeryCenter,
    A.HasSurgeryOnSite = B.HasSurgeryOnSite,
    A.AverageDailyPatientVolume = B.AverageDailyPatientVolume,
    A.PhysicianCount = B.PhysicianCount,
    A.OfficeCoordinatorName = B.OfficeCoordinatorName,
    A.ParkingInformation = B.ParkingInformation,
    A.PaymentPolicy = B.PaymentPolicy,
    A.LegacyKeyOffice = B.LegacyKeyOffice,
    A.LegacyKeyPractice = B.LegacyKeyPractice,
    A.OfficeRank = B.OfficeRank,
    A.CityStatePostalCodeID = B.CityStatePostalCodeID,
    A.HasDentist = B.HasDentist,
    A.OfficeURL = B.OfficeURL
FROM Mid.Practice A
JOIN TempPractice B ON (A.PracticeID = B.PracticeID AND A.OfficeID = B.OfficeID)
WHERE B.ActionCode = 2

DELETE  a
FROM    Mid.Practice AS a 
JOIN CTE_PracticeBatch as pb on pb.PracticeID = a.PracticeID
LEFT JOIN TempPractice b ON (a.PracticeID = b.PracticeID AND a.OfficeID = b.OfficeID)
WHERE   b.PracticeID IS NULL

/*
END TRY
BEGIN CATCH
    SET @ErrorMessage = 'Error in procedure Mid.spuPracticeRefresh, line ' + CONVERT(VARCHAR(20), ERROR_LINE()) + ': ' + ERROR_MESSAGE()
    RAISERROR(@ErrorMessage, 18, 1)
END CATCH
GO
*/
