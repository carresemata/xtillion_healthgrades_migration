
-- If statement two possible pracice batch tables

/*
WITH CTE_PracticeBatch AS (
    SELECT PracticeID
    FROM Base.Practice
    ORDER BY PracticeID
)

*/

WITH CTE_PracticeBatch AS (
    SELECT DISTINCT 
        O.PracticeID
    -- We havent decided where this information is gonna live in snowlfake platform
    FROM Snowflake.etl.ProviderDeltaProcessing as PDP -- !!!!!!!!!!!!
        JOIN Base.ProviderToOffice AS PTO on PTO.ProviderID = PDP.ProviderID
        JOIN Base.Office AS O on O.OfficeID = PTO.OfficeID
    ORDER BY O.PracticeID
),

CTE_Service AS (
    SELECT 
        P.PhoneNumber, 
        OTP.OfficeID
    FROM  Base.OfficeToPhone OTP
        JOIN Base.Phone P ON OTP.PhoneID = P.PhoneID
        JOIN Base.PhoneType PT ON OTP.PhoneTypeID = PT.PhoneTypeID 
        AND PhoneTypeCode = 'Service'
),

CTE_Fax AS (
    SELECT  
        P.PhoneNumber, 
        OTP.OfficeID
    FROM    Base.OfficeToPhone OTP
        JOIN Base.Phone P ON OTP.PhoneID = P.PhoneID
        JOIN Base.PhoneType PT ON OTP.PhoneTypeID = PT.PhoneTypeID 
        AND PhoneTypeCode = 'Fax'
),


CTE_ProviderToPractice AS (
    SELECT  DISTINCT 
        PTO.ProviderID, 
        P.PracticeID
    FROM    Base.ProviderToOffice AS PTO
        JOIN Base.Office AS O ON O.OfficeID = PTO.OfficeID
        JOIN Base.Practice AS P ON P.PracticeID = O.PracticeID
),
CTE_PhysicianCount AS (
    SELECT 
        PracticeID, 
        COUNT(*) AS PhysicianCount
    FROM CTE_ProviderToPractice
    GROUP BY PracticeID
),
--build a temp table of practices with at least one dentist at one of their office
CTE_PracticesWithDentists AS (
    SELECT 
        PB.PracticeID 
    FROM CTE_PracticeBatch AS PB 
        JOIN ODS1Stage.base.Office AS O ON O.PracticeID = PB.PracticeID
        JOIN ODS1Stage.base.ProviderToOffice AS PO ON PO.OfficeID = O.OfficeID
        JOIN ODS1Stage.base.ProviderToProviderType AS PPT ON PPT.ProviderID = PO.ProviderID 
        JOIN ODS1Stage.base.ProviderType AS PT ON PT.ProviderTypeID = PPT.ProviderTypeID
    WHERE PT.ProviderTypeCode = 'DENT'
),
CTE_PROVTOOFF AS (
    SELECT 
        CPER.ParentID, 
        O.OfficeID, 
        O.OfficeCode, 
        O.OfficeName, 
        P.PracticeID, 
        P.PracticeCode, 
        P.PracticeName,
        CPTE.ClientProductToEntityID                           
    FROM Base.ClientProductEntityRelationship AS CPER 
        JOIN Base.RelationshipType RT ON CPER.RelationshipTypeID = RT.RelationshipTypeID
        JOIN Base.ClientProductToEntity CPTE ON CPTE.ClientProductToEntityID = CPER.ChildID
        JOIN Base.Office O ON CPTE.EntityID = O.OfficeID 
        JOIN Base.Practice P ON O.PracticeID = P.PracticeID
    WHERE  RT.RelationshipTypeCode = 'PROVTOOFF'   
),
CTE_OfficeCode_1 AS (
        SELECT O.OfficeCode 
        FROM Base.Office AS O 
        WHERE O.OfficeCode IN ( 'OOO5XB5',
                                'OOO82BH',
                                'Y3GT4X',
                                'YBD8MY',
                                'YBD8V7',
                                'OOJQPVR',
                                'OOJQQB2',
                                'YCFH2F',
                                'YCFHK7',
                                'OOO38H7',
                                'YBV56C',
                                'OOJVW28',
                                'OOJQPWJ',
                                'OOS4S2S',
                                'OOJTJTQ',
                                'YBV5LG',
                                'OOO8HQ3')
),
CTE_OfficeCode_2 AS (
        SELECT 
            CTE.OfficeCode
        FROM   Base.ClientToProduct AS CTP
            JOIN Base.Client AS C ON CTP.ClientID = C.ClientID
            JOIN Base.Product AS P ON CTP.ProductID = P.ProductID AND c.ProductCode = 'PDCPRAC'
            JOIN Base.ProductGroup AS PG ON P.ProductGroupID = PG.ProductGroupID 
                AND PG.ProductGroupCode = 'PDC'
            JOIN Base.ClientProductToEntity AS CPTE ON CTP.ClientToProductID = CPTE.ClientToProductID
            JOIN Base.EntityType AS ET ON CPTE.EntityTypeID = ET.EntityTypeID 
                AND ET.EntityTypeCode = 'PROV'
            JOIN base.Provider AS P ON CPTE.EntityID = P.ProviderID --When not migrating a batch, this is all providers in Base.Provider. Otherwise it is just the providers in the batch
            JOIN Base.Provider AS BP ON CPTE.EntityID = BP.ProviderID
            JOIN CTE_PROVTOOFF AS CTE ON CPTE.ClientProductToEntityID = CTE.ParentID
        WHERE  CTP.ActiveFlag = 1
),
CTE_OfficeCode_3 AS (
        SELECT 
            O.OfficeCode 
        FROM Base.ClientToProduct AS CTP
            JOIN Base.Client AS C ON CTP.ClientID = CTP.ClientID
            JOIN Base.Product AS P ON CTP.ProductID = P.ProductID 
            AND c.ProductCode <> 'PDCPRAC'
            JOIN Base.ProductGroup AS PG ON P.ProductGroupID = PG.ProductGroupID 
                AND PG.ProductGroupCode = 'PDC'
            JOIN Base.ClientProductToEntity AS CPTE ON CTP.ClientToProductID = CPTE.ClientToProductID
            JOIN Base.EntityType AS ET ON CPTE.EntityTypeID = ET.EntityTypeID 
                AND ET.EntityTypeCode = 'PROV'
            JOIN Base.Provider AS BP ON CPTE.EntityID = BP.ProviderID
            JOIN Base.ProviderToOffice AS PTO ON PTO.ProviderID = BP.ProviderID
            JOIN Base.Office AS O ON O.officeID = PTO.OfficeID
        WHERE  CTP.ActiveFlag = 1
),
CTE_ColumnUpdates AS (
        SELECT  
            COULUM_NAME AS name, 
            ROW_NUMBER() OVER (ORDER BY name) AS recId
        FROM INFORMATION_SCHEMA.COLUMNS  
        WHERE TABLE_NAME = 'TempPracticeSponsorship' 
        AND name NOT IN ('PracticeCode', 'ProductCode', 'ActionCode')
),


CREATE OR REPLACE TEMPORARY TABLE TempPractice AS (
    SELECT  DISTINCT 
        P.PracticeID,
        P.PracticeCode,
        TRIM(P.PracticeName) AS PracticeName,
        P.YearPracticeEstablished,
        P.NPI, 
        P.PracticeWebsite,
        P.PracticeDescription,
        P.PracticeLogo,
        P.PracticeMedicalDirector,
        P.PracticeSoftware,
        P.PracticeTIN,
        O.OfficeID,
        O.OfficeCode,
        TRIM(O.OfficeName) AS officename,
        BAT.AddressTypeCode,
        A.AddressLine1 || IFNULL( || ' ' || A.Suite,'') AS AddressLine1,
        A.AddressLine2,
        A.AddressLine3,
        A.AddressLine4,
        CSPC.City, 
        CSPC.State, 
        CSPC.PostalCode AS ZipCode,
        CSPC.County,
        N.NationName AS Nation,
        A.Latitude,e.Longitude,
        CTE_S.PhoneNumber AS FullPhone,
        CTE_F.PhoneNumber AS FullFax,
        O.HasBillingStaff,
        O.HasHandicapAccess,
        O.HasLabServicesOnSite,
        O.HasPharmacyOnSite,
        O.HasXrayOnSite,
        O.IsSurgeryCenter,
        O.HasSurgeryOnSite,
        O.AverageDailyPatientVolume,
        NULL AS PhysicianCount,
        O.OfficeCoordinatorName,
        O.ParkingInformation,
        O.PaymentPolicy,
        O.LegacyKey AS LegacyKeyOffice,
        P.LegacyKey AS LegacyKeyPractice,
        O.OfficeRank,
        A.CityStatePostalCodeID,
        0,
        REPLACE(
            REPLACE(
                REPLACE('/group-directory/'||LOWER(CSPC.State)||'-'|| LOWER(
                    REPLACE(S.StateName,' ','-'))||'/'||
        LOWER(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
                CSPC.City,
                ' - ',' '),
                '&','-'),
                ' ','-'),
                '/','-'),
                '''',''),
                '.',''),
                '--','-')) || '/' || 
        LOWER(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
                TRIM(P.PracticeName),
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
                '-' || LOWER(O.OfficeCode) ,'--','-'),char(13),''), char(10),'') AS OfficeURL
    FROM CTE_PracticeBatch as PB  --When not migrating a batch, this is all offices in Base.Office. Otherwise it is just the offices for the providers in the batch
        JOIN Base.Practice AS P on P.PracticeID = PB.PracticeID
        JOIN Base.Office AS O ON P.PracticeID = O.PracticeID
        JOIN Base.OfficeToAddress AS OTA ON O.OfficeID = OTA.OfficeID
        JOIN Base.ProviderToOffice PTO on O.OfficeID = PTO.OfficeID
        LEFT JOIN Base.AddressType AS BAT  ON BAT.AddressTypeID = OTA.AddressTypeID
        JOIN Base.Address AS A ON A.AddressID = OTA.AddressID
        JOIN Base.CityStatePostalCode AS CSPC ON A.CityStatePostalCodeID = CSPC.CityStatePostalCodeID
        JOIN Base.Nation N ON IFNULL(J.NationID,'00415355-0000-0000-0000-000000000000') = N.NationID
        JOIN Base.State S ON S.state = CSPC.state
        LEFT JOIN CTE_Service AS  CTE_S ON CTE_S.OfficeID = O.OfficeID
        LEFT JOIN CTE_Fax AS CTE_F  ON CTE_F.OfficeID = O.OfficeID
)

--UPDATE the PhysicianCount based on DISTINCT providers at the Practice level
UPDATE TP 
SET TP.PhysicianCount = CTE_PC.PhysicianCount
FROM TempPractice AS TP
JOIN CTE_PhysicianCount AS CTE_PC ON CTE_PC.PracticeID = TP.PracticeID

UPDATE TP
SET HasDentist = 1
FROM TempPractice AS TP
JOIN CTE_PracticesWithDentists AS CTE_PWD ON TP.PracticeID = CTE_PWD.PracticeID

UPDATE TP
SET TP.GoogleScriptBlock = '{"@@context": "http://schema.org","@@type" : "MedicalClinic","@@id":"' || TP.OfficeURL || '","name":"' || TP.PracticeName || '","address": {"@@type": "PostalAddress","streetAddress":"' || TP.AddressLine1 || '","addressLocality":"' || TP.City || '","addressRegion":"' || TP.State || '","postalCode":"' || TP.ZipCode || '","addressCountry": "US"},"geo": {"@@type":"GeoCoordinates","latitude":"' || CAST(TP.Latitude AS VARCHAR(MAX)) || '","longitude":"' || CAST(TP.Longitude AS VARCHAR(MAX)) || '"},"telephone":"' || IFNULL(TP.FullPhone,'') || '","potentialAction":{"@@type":"ReserveAction","@@id":"/groupgoogleform/' || TP.OfficeCode || '","url":"/groupgoogleform"}}'
--select prac.GoogleScriptBlock, '{"@@context": "http://schema.org","@@type" : "MedicalClinic","@@id":"'+prac.OfficeURL+'","name":"'+prac.PracticeName+'","address": {"@@type": "PostalAddress","streetAddress":"'+prac.AddressLine1+'","addressLocality":"'+prac.City+'","addressRegion":"'+prac.State+'","postalCode":"'+prac.ZipCode+'","addressCountry": "US"},"geo": {"@@type":"GeoCoordinates","latitude":"'+CAST(prac.Latitude AS VARCHAR(MAX))+'","longitude":"'+CAST(prac.Longitude AS VARCHAR(MAX))+'"},"telephone":"'+ISNULL(prac.FullPhone,'')+'","potentialAction":{"@@type":"ReserveAction","@@id":"/groupgoogleform/'+prac.OfficeCode+'","url":"/groupgoogleform"}}'
FROM   TempPractice AS TP
JOIN (
        SELECT * FROM CTE_OfficeCode_1
        UNION
        SELECT * FROM CTE_OfficeCode_2
        UNION
        SELECT * FROM CTE_OfficeCode_3
    ) X ON X.OfficeCode = TP.OfficeCode


UPDATE  TP
SET     TP.ActionCode = 1
--SELECT *
FROM    TempPractice AS TP
LEFT JOIN Mid.Practice AS MP ON TP.PracticeID = MP.PracticeID and TP.OfficeID = MP.OfficeID
WHERE   MP.PracticeID IS NULL 

UPDATE TP
SET TP.ActionCode = 2
FROM TempPractice AS TP
JOIN Mid.Practice AS MP ON TP.PracticeID = MP.PracticeID AND TP.OfficeID = MP.OfficeID
WHERE
    MD5(IFNULL(TP.PracticeName::VARCHAR,''))<>           MD5(IFNULL(MP.PracticeName::VARCHAR,'')) OR
    MD5(IFNULL(TP.YearPracticeEstablished::VARCHAR,''))<>MD5(IFNULL(MP.YearPracticeEstablished::VARCHAR,'')) OR
    MD5(IFNULL(TP.NPI::VARCHAR,''))<>                    MD5(IFNULL(MP.NPI::VARCHAR,'')) OR
    MD5(IFNULL(TP.PracticeWebsite::VARCHAR,''))<>        MD5(IFNULL(MP.PracticeWebsite::VARCHAR,'')) OR
    MD5(IFNULL(TP.PracticeDescription::VARCHAR,''))<>    MD5(IFNULL(MP.PracticeDescription::VARCHAR,'')) OR
    MD5(IFNULL(TP.PracticeLogo::VARCHAR,''))<>           MD5(IFNULL(MP.PracticeLogo::VARCHAR,'')) OR
    MD5(IFNULL(TP.PracticeMedicalDirector::VARaHAR,''))<>MD5(IFNULL(MP.PracticeMedicalDirector::VARCHAR,'')) OR
    MD5(IFNULL(TP.PracticeSoftware::VARCHAR,''))<>       MD5(IFNULL(MP.PracticeSoftware::VARCHAR,'')) OR
    MD5(IFNULL(TP.PracticeTIN::VARCHAR,''))<>            MD5(IFNULL(MP.PracticeTIN::VARCHAR,'')) OR
    MD5(IFNULL(TP.OfficeID::VARCHAR,''))<>               MD5(IFNULL(MP.OfficeID::VARCHAR,'')) OR
    MD5(IFNULL(TP.OfficeCode::VARCHAR,''))<>             MD5(IFNULL(MP.OfficeCode::VARCHAR,'')) OR
    MD5(IFNULL(TP.officename::VARCHAR,''))<>             MD5(IFNULL(MP.officename::VARCHAR,'')) OR
    MD5(IFNULL(TP.AddressTypeCode::VARCHAR,''))<>        MD5(IFNULL(MP.AddressTypeCode::VARCHAR,'')) OR
    MD5(IFNULL(TP.AddressLine1::VARCHAR,''))<>           MD5(IFNULL(MP.AddressLine1::VARCHAR,'')) OR
    MD5(IFNULL(TP.AddressLine2::VARCHAR,''))<>           MD5(IFNULL(MP.AddressLine2::VARCHAR,'')) OR
    MD5(IFNULL(TP.AddressLine3::VARCHAR,''))<>           MD5(IFNULL(MP.AddressLine3::VARCHAR,'')) OR
    MD5(IFNULL(TP.AddressLine4::VARCHAR,''))<>           MD5(IFNULL(MP.AddressLine4::VARCHAR,'')) OR
    MD5(IFNULL(TP.City::VARCHAR,''))<>                   MD5(IFNULL(MP.City::VARCHAR,'')) OR
    MD5(IFNULL(TP.State::VARCHAR,''))<>                  MD5(IFNULL(MP.State::VARCHAR,'')) OR
    MD5(IFNULL(TP.ZipCode::VARCHAR,''))<>                MD5(IFNULL(MP.ZipCode::VARCHAR,'')) OR
    MD5(IFNULL(TP.County::VARCHAR,''))<>                 MD5(IFNULL(MP.County::VARCHAR,'')) OR
    MD5(IFNULL(TP.Nation::VARCHAR,''))<>                 MD5(IFNULL(MP.Nation::VARCHAR,'')) OR
    MD5(IFNULL(TP.Latitude::VARCHAR,''))<>               MD5(IFNULL(MP.Latitude::VARCHAR,'')) OR
    MD5(IFNULL(TP.Longitude::VARCHAR,''))<>              MD5(IFNULL(MP.Longitude::VARCHAR,'')) OR
    MD5(IFNULL(TP.FullPhone::VARCHAR,''))<>              MD5(IFNULL(MP.FullPhone::VARCHAR,'')) OR
    MD5(IFNULL(TP.FullFax::VARCHAR,''))<>                MD5(IFNULL(MP.FullFax::VARCHAR,'')) OR
    MD5(IFNULL(TP.HasBillingStaff::VARCHAR,''))<>        MD5(IFNULL(MP.HasBillingStaff::VARCHAR,'')) OR
    MD5(IFNULL(TP.HasHandicapAccess::VARCHAR,''))<>      MD5(IFNULL(MP.HasHandicapAccess::VARCHAR,'')) OR
    MD5(IFNULL(TP.HasLabServicesOnSite::VARCHAR,''))<>   MD5(IFNULL(MP.HasLabServicesOnSite::VARCHAR,'')) OR
    MD5(IFNULL(TP.HasPharmacyOnSite::VARCHAR,''))<>      MD5(IFNULL(MP.HasPharmacyOnSite::VARCHAR,'')) OR
    MD5(IFNULL(TP.HasXrayOnSite::VARCHAR,''))<>          MD5(IFNULL(MP.HasXrayOnSite::VARCHAR,'')) OR
    MD5(IFNULL(TP.IsSurgeryCenter::VARCHAR,''))<>        MD5(IFNULL(MP.IsSurgeryCenter::VARCHAR,'')) OR
    MD5(IFNULL(TP.HasSurgeryOnSite::VARCHAR,''))<>       MD5(IFNULL(MP.HasSurgeryOnSite::VARCHAR,'')) OR
    MD5(IFNULL(TP.AverageDailyPatientVolume::VARCHAR,''))<>MD5(IFNUL(MP.AverageDailyPatientVolume::VARCHAR,'')) OR
    MD5(IFNULL(TP.PhysicianCount::VARCHAR,''))<>         MD5(IFNULL(MP.PhysicianCount::VARCHAR,'')) OR
    MD5(IFNULL(TP.OfficeCoordinatorName::VARCHAR,''))<>  MD5(IFNULL(MP.OfficeCoordinatorName::VARCHAR,'')) OR
    MD5(IFNULL(TP.ParkingInformation::VARCHAR,''))<>     MD5(IFNULL(MP.ParkingInformation::VARCHAR,'')) OR
    MD5(IFNULL(TP.PaymentPolicy::VARCHAR,''))<>          MD5(IFNULL(MP.PaymentPolicy::VARCHAR,'')) OR
    MD5(IFNULL(TP.LegacyKeyOffice::VARCHAR,''))<>        MD5(IFNULL(MP.LegacyKeyOffice::VARCHAR,'')) OR
    MD5(IFNULL(TP.LegacyKeyPractice::VARCHAR,''))<>      MD5(IFNULL(MP.LegacyKeyPractice::VARCHAR,'')) OR
    MD5(IFNULL(TP.OfficeRank::VARCHAR,''))<>             MD5(IFNULL(MP.OfficeRank::VARCHAR,'')) OR
    MD5(IFNULL(TP.CityStatePostalCodeID::VARCHAR,''))<>  MD5(IFNULL(MP.CityStatePostalCodeID::VARCHAR,'')) OR
    MD5(IFNULL(TP.HasDentist::VARCHAR,''))<>             MD5(IFNULL(MP.HasDentist::VARCHAR,'')) OR
    MD5(IFNULL(TP.OfficeURL::VARCHAR,''))<>              MD5(IFNULL(MP.OfficeURL::VARCHAR,''))

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
    MP.PracticeName =               BTP.PracticeName,
    MP.YearPracticeEstablished =    BTP.YearPracticeEstablished,
    MP.NPI =                        BTP.NPI,
    MP.PracticeWebsite =            BTP.PracticeWebsite,
    MP.PracticeDescription =        BTP.PracticeDescription,
    MP.PracticeLogo =               BTP.PracticeLogo,
    MP.PracticeMedicalDirector =    BTP.PracticeMedicalDirector,
    MP.PracticeSoftware =           BTP.PracticeSoftware,
    MP.PracticeTIN =                BTP.PracticeTIN,
    MP.OfficeID =                   BTP.OfficeID,
    MP.OfficeCode =                 BTP.OfficeCode,
    MP.officename =                 BTP.officename,
    MP.AddressTypeCode =            BTP.AddressTypeCode,
    MP.AddressLine1 =               BTP.AddressLine1,
    MP.AddressLine2 =               BTP.AddressLine2,
    MP.AddressLine3 =               BTP.AddressLine3,
    MP.AddressLine4 =               BTP.AddressLine4,
    MP.City =                       BTP.City,
    MP.State =                      BTP.State,
    MP.ZipCode =                    BTP.ZipCode,
    MP.County =                     BTP.County,
    MP.Nation =                     BTP.Nation,
    MP.Latitude =                   BTP.Latitude,
    MP.Longitude =                  BTP.Longitude,
    MP.FullPhone =                  BTP.FullPhone,
    MP.FullFax =                    BTP.FullFax,
    MP.HasBillingStaff =            BTP.HasBillingStaff,
    MP.HasHandicapAccess =          BTP.HasHandicapAccess,
    MP.HasLabServicesOnSite =       BTP.HasLabServicesOnSite,
    MP.HasPharmacyOnSite =          BTP.HasPharmacyOnSite,
    MP.HasXrayOnSite =              BTP.HasXrayOnSite,
    MP.IsSurgeryCenter =            BTP.IsSurgeryCenter,
    MP.HasSurgeryOnSite =           BTP.HasSurgeryOnSite,
    MP.AverageDailyPatientVolume =  BTP.AverageDailyPatientVolume,
    MP.PhysicianCount =             BTP.PhysicianCount,
    MP.OfficeCoordinatorName =      BTP.OfficeCoordinatorName,
    MP.ParkingInformation =         BTP.ParkingInformation,
    MP.PaymentPolicy =              BTP.PaymentPolicy,
    MP.LegacyKeyOffice =            BTP.LegacyKeyOffice,
    MP.LegacyKeyPractice =          BTP.LegacyKeyPractice,
    MP.OfficeRank =                 BTP.OfficeRank,
    MP.CityStatePostalCodeID =      BTP.CityStatePostalCodeID,
    MP.HasDentist =                 BTP.HasDentist,
    MP.OfficeURL =                  BTP.OfficeURL
FROM Mid.Practice AS MP
JOIN TempPractice AS TP ON MP.PracticeID = TP.PracticeID AND MP.OfficeID = TP.OfficeID
WHERE TP.ActionCode = 2

DELETE  MP
FROM    Mid.Practice AS MP
JOIN CTE_PracticeBatch as PB on PB.PracticeID = MP.PracticeID
LEFT JOIN TempPractice AS TP ON MP.PracticeID = TP.PracticeID AND MP.OfficeID = TP.OfficeID
WHERE   TP.PracticeID IS NULL

/*
END TRY
BEGIN CATCH
    SET @ErrorMessage = 'Error in procedure Mid.spuPracticeRefresh, line ' + CONVERT(VARCHAR(20), ERROR_LINE()) + ': ' + ERROR_MESSAGE()
    RAISERROR(@ErrorMessage, 18, 1)
END CATCH
GO
*/
