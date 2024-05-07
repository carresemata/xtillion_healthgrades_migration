CREATE OR REPLACE PROCEDURE ODS1_STAGE.MID.SP_LOAD_PRACTICE(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Mid.Practice depends on:
--- MDM_TEAM.MST.Provider_Profile_Processing
--- Base.ProviderToProviderType
--- Base.ProviderType
--- Base.Provider
--- Base.ProviderToOffice 
--- Base.Office
--- Base.OfficeToAddress
--- Base.AddressType
--- Base.Address
--- Base.CityStatePostalCode 
--- Base.Nation 
--- Base.State
--- Base.OfficeToPhone 
--- Base.Phone 
--- Base.PhoneType
--- Base.Practice
--- Base.ClientProductEntityRelationship
--- Base.RelationshipType 
--- Base.ClientProductToEntity
--- Base.EntityType
--- Base.ClientToProduct 
--- Base.Client 
--- Base.Product
--- Base.ProductGroup 

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    IF (IsProviderDeltaProcessing) THEN
           select_statement := '
           WITH CTE_PracticeBatch AS (
                SELECT DISTINCT 
                O.PracticeID
                FROM Raw.Provider_Profile_Processing as PDP 
                    JOIN Base.Provider As P ON P.ProviderCode = PDP.REF_PROVIDER_CODE
                    JOIN Base.ProviderToOffice AS PTO on PTO.ProviderID = P.ProviderID
                    JOIN Base.Office AS O on O.OfficeID = PTO.OfficeID
                ORDER BY O.PracticeID), ';
    ELSE
           select_statement := '
           WITH CTE_PracticeBatch AS (
                SELECT PracticeID
                FROM Base.Practice
                ORDER BY PracticeID ),';
    END IF;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
select_statement := select_statement || 
                    $$
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
                        FROM  Base.OfficeToPhone OTP
                            JOIN Base.Phone P ON OTP.PhoneID = P.PhoneID
                            JOIN Base.PhoneType PT ON OTP.PhoneTypeID = PT.PhoneTypeID 
                            AND PhoneTypeCode = 'FAX'
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
                    )
                    ,
                    --build a temp table of practices with at least one dentist at one of their office
                    CTE_PracticesWithDentists AS (
                        SELECT 
                            PB.PracticeID 
                        FROM CTE_PracticeBatch AS PB 
                            JOIN Base.Office AS O ON O.PracticeID = PB.PracticeID
                            JOIN Base.ProviderToOffice AS PO ON PO.OfficeID = O.OfficeID
                            JOIN Base.ProviderToProviderType AS PPT ON PPT.ProviderID = PO.ProviderID 
                            JOIN Base.ProviderType AS PT ON PT.ProviderTypeID = PPT.ProviderTypeID
                        WHERE PT.ProviderTypeCode = 'DENT'
                        GROUP BY 
                            PB.PracticeID
                    )
                    ,
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
                    )
                    ,
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
                    )
                    ,
                    CTE_OfficeCode_2 AS (
                            SELECT 
                                CTE.OfficeCode
                            FROM   Base.ClientToProduct AS CTP
                                JOIN Base.Client AS C ON CTP.ClientID = C.ClientID
                                JOIN Base.Product AS P ON CTP.ProductID = P.ProductID AND P.ProductCode = 'PDCPRAC'
                                JOIN Base.ProductGroup AS PG ON P.ProductGroupID = PG.ProductGroupID 
                                    AND PG.ProductGroupCode = 'PDC'
                                JOIN Base.ClientProductToEntity AS CPTE ON CTP.ClientToProductID = CPTE.ClientToProductID
                                JOIN Base.EntityType AS ET ON CPTE.EntityTypeID = ET.EntityTypeID 
                                    AND ET.EntityTypeCode = 'PROV'
                                JOIN Base.Provider AS BP ON CPTE.EntityID = BP.ProviderID
                                JOIN CTE_PROVTOOFF AS CTE ON CPTE.ClientProductToEntityID = CTE.ParentID
                            WHERE  CTP.ActiveFlag = 1
                    )
                    ,
                    CTE_OfficeCode_3 AS (
                            SELECT 
                                O.OfficeCode 
                            FROM Base.ClientToProduct AS CTP
                                JOIN Base.Client AS C ON CTP.ClientID = CTP.ClientID
                                JOIN Base.Product AS P ON CTP.ProductID = P.ProductID 
                                AND P.ProductCode <> 'PDCPRAC'
                                JOIN Base.ProductGroup AS PG ON P.ProductGroupID = PG.ProductGroupID 
                                    AND PG.ProductGroupCode = 'PDC'
                                JOIN Base.ClientProductToEntity AS CPTE ON CTP.ClientToProductID = CPTE.ClientToProductID
                                JOIN Base.EntityType AS ET ON CPTE.EntityTypeID = ET.EntityTypeID 
                                    AND ET.EntityTypeCode = 'PROV'
                                JOIN Base.Provider AS BP ON CPTE.EntityID = BP.ProviderID
                                JOIN Base.ProviderToOffice AS PTO ON PTO.ProviderID = BP.ProviderID
                                JOIN Base.Office AS O ON O.officeID = PTO.OfficeID
                            WHERE  CTP.ActiveFlag = 1
                            GROUP BY
                                O.OfficeCode 
                    )
                    ,
                    CTE_Practice AS (SELECT  
                    DISTINCT 
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
                            A.AddressLine1 || IFNULL( ' ' || A.Suite,'') AS AddressLine1,
                            A.AddressLine2,
                            A.AddressLine3,
                            A.AddressLine4,
                            CSPC.City, 
                            CSPC.State, 
                            CSPC.PostalCode AS ZipCode,
                            CSPC.County,
                            N.NationName AS Nation,
                            A.Latitude,
                            A.Longitude,
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
                            CTE_PC.PhysicianCount,
                            O.OfficeCoordinatorName,
                            O.ParkingInformation,
                            O.PaymentPolicy,
                            O.LegacyKey AS LegacyKeyOffice,
                            P.LegacyKey AS LegacyKeyPractice,
                            O.OfficeRank,
                            A.CityStatePostalCodeID,
                            CASE 
                                WHEN P.PracticeID IN (
                                    SELECT CTE_PWD.PracticeID 
                                    FROM CTE_PracticesWithDentists AS CTE_PWD
                                ) THEN 1
                                ELSE 0
                            END AS HasDentist, 
                            REGEXP_REPLACE(
                            REGEXP_REPLACE(
                                CONCAT(
                                    '/group-directory/',
                                    LOWER(CSPC.State),
                                    '-',
                                    LOWER(REPLACE(S.StateName, ' ', '-')),
                                    '/',
                                    LOWER(REGEXP_REPLACE(CSPC.City, '[ -&/''\.]', '-', 1, 0)),
                                    '/',
                                    LOWER(REGEXP_REPLACE(REGEXP_REPLACE(REPLACE(REPLACE(TRIM(P.PracticeName),CHAR(UNICODE('\u0060'))), ' ', '-'), '[&/''\:\\~\\;\\|<>™•*?+®!–@{}\\[\\]()ñéí"’ #,\.]', ''), '--', '-')),
                                    '-',
                                    LOWER(O.OfficeCode)
                                ),
                                '--',
                                '-'
                            ),
                            '\\r|\\n',
                            ''
                        ) AS OfficeURL
                        FROM CTE_PracticeBatch as PB  --When not migrating a batch, this is all offices in Base.Office. Otherwise it is just the offices for the providers in the batch
                            JOIN Base.Practice AS P on P.PracticeID = PB.PracticeID
                            JOIN Base.Office AS O ON P.PracticeID = O.PracticeID
                            JOIN Base.OfficeToAddress AS OTA ON O.OfficeID = OTA.OfficeID
                            JOIN Base.ProviderToOffice PTO on O.OfficeID = PTO.OfficeID
                            LEFT JOIN Base.AddressType AS BAT  ON BAT.AddressTypeID = OTA.AddressTypeID
                            JOIN Base.Address AS A ON A.AddressID = OTA.AddressID
                            JOIN Base.CityStatePostalCode AS CSPC ON A.CityStatePostalCodeID = CSPC.CityStatePostalCodeID
                            JOIN Base.Nation N ON IFNULL(CSPC.NationID,'00415355-0000-0000-0000-000000000000') = N.NationID
                            JOIN Base.State S ON S.state = CSPC.state
                            LEFT JOIN CTE_Service AS  CTE_S ON CTE_S.OfficeID = O.OfficeID
                            LEFT JOIN CTE_Fax AS CTE_F  ON CTE_F.OfficeID = O.OfficeID
                            LEFT JOIN CTE_PhysicianCount AS CTE_PC ON CTE_PC.PracticeID = P.PracticeID
                    ),
                    CTE_FinalPractice AS (
                    SELECT DISTINCT
                            P.PracticeID,
                            P.PracticeCode,
                            P.PracticeName,
                            P.YearPracticeEstablished,
                            P.NPI, 
                            P.PracticeWebsite,
                            P.PracticeDescription,
                            P.PracticeLogo,
                            P.PracticeMedicalDirector,
                            P.PracticeSoftware,
                            P.PracticeTIN,
                            P.OfficeID,
                            P.OfficeCode,
                            P.officename,
                            P.AddressTypeCode,
                            P.AddressLine1,
                            P.AddressLine2,
                            P.AddressLine3,
                            P.AddressLine4,
                            P.City, 
                            P.State, 
                            P.ZipCode,
                            P.County,
                            P.Nation,
                            P.Latitude,
                            P.Longitude,
                            P.FullPhone,
                            P.FullFax,
                            P.HasBillingStaff,
                            P.HasHandicapAccess,
                            P.HasLabServicesOnSite,
                            P.HasPharmacyOnSite,
                            P.HasXrayOnSite,
                            P.IsSurgeryCenter,
                            P.HasSurgeryOnSite,
                            P.AverageDailyPatientVolume,
                            P.PhysicianCount,
                            P.OfficeCoordinatorName,
                            P.ParkingInformation,
                            P.PaymentPolicy,
                            P.LegacyKeyOffice,
                            P.LegacyKeyPractice,
                            P.OfficeRank,
                            P.CityStatePostalCodeID,
                            P.HasDentist, 
                    '''{"@@context": "http://schema.org","@@type" : "MedicalClinic","@@id":"' || P.OfficeURL || '","name":"' || P.PracticeName || '","address": {"@@type": "PostalAddress","streetAddress":"' || P.AddressLine1 || '","addressLocality":"' || P.City || '","addressRegion":"' || P.State || '","postalCode":"' || P.ZipCode || '","addressCountry": "US"},"geo": {"@@type":"GeoCoordinates","latitude":"' || to_varchar(P.Latitude) || '","longitude":"' || to_varchar(P.Longitude) || '"},"telephone":"' || IFNULL(P.FullPhone,'') || '","potentialAction":{"@@type":"ReserveAction","@@id":"/groupgoogleform/' || P.OfficeCode || '","url":"/groupgoogleform"}}''' AS GoogleScriptBlock,
                            P.OfficeURL,
                            0 AS ActionCode -- Action code 0, no changes
                    FROM cte_practice AS P
                    JOIN (
                            SELECT * FROM CTE_OfficeCode_1
                            UNION
                            SELECT * FROM CTE_OfficeCode_2
                            UNION
                            SELECT * FROM CTE_OfficeCode_3
                        ) offices ON offices.OfficeCode = P.OfficeCode),
                        
                    -- Insert Action    
                    CTE_Action_1 AS 
                            (SELECT 
                                cte.PracticeId,
                                1 AS ActionCode
                            FROM CTE_FinalPractice AS cte
                            LEFT JOIN Mid.Practice AS mp ON
                                cte.PracticeID = mp.PracticeID AND 
                                cte.PracticeCode = mp.PracticeCode
                            WHERE mp.PracticeID IS NULL
                            GROUP BY cte.PracticeID
                            )
                            
                    -- Update Action
                    ,
                    CTE_Action_2 AS 
                            (SELECT
                                cte.PracticeId,
                                2 AS ActionCode
                            FROM CTE_FinalPractice AS cte
                            JOIN Mid.Practice AS mp ON
                                cte.PracticeID = mp.PracticeID AND 
                                cte.PracticeCode = mp.PracticeCode
                            WHERE
                                MD5(IFNULL(cte.PracticeName::VARCHAR,''))<>           MD5(IFNULL(MP.PracticeName::VARCHAR,'')) OR
                                MD5(IFNULL(cte.YearPracticeEstablished::VARCHAR,''))<>MD5(IFNULL(MP.YearPracticeEstablished::VARCHAR,'')) OR
                                MD5(IFNULL(cte.NPI::VARCHAR,''))<>                    MD5(IFNULL(MP.NPI::VARCHAR,'')) OR
                                MD5(IFNULL(cte.PracticeWebsite::VARCHAR,''))<>        MD5(IFNULL(MP.PracticeWebsite::VARCHAR,'')) OR
                                MD5(IFNULL(cte.PracticeDescription::VARCHAR,''))<>    MD5(IFNULL(MP.PracticeDescription::VARCHAR,'')) OR
                                MD5(IFNULL(cte.PracticeLogo::VARCHAR,''))<>           MD5(IFNULL(MP.PracticeLogo::VARCHAR,'')) OR
                                MD5(IFNULL(cte.PracticeMedicalDirector::VARCHAR,''))<>MD5(IFNULL(MP.PracticeMedicalDirector::VARCHAR,'')) OR
                                MD5(IFNULL(cte.PracticeSoftware::VARCHAR,''))<>       MD5(IFNULL(MP.PracticeSoftware::VARCHAR,'')) OR
                                MD5(IFNULL(cte.PracticeTIN::VARCHAR,''))<>            MD5(IFNULL(MP.PracticeTIN::VARCHAR,'')) OR
                                MD5(IFNULL(cte.OfficeID::VARCHAR,''))<>               MD5(IFNULL(MP.OfficeID::VARCHAR,'')) OR
                                MD5(IFNULL(cte.OfficeCode::VARCHAR,''))<>             MD5(IFNULL(MP.OfficeCode::VARCHAR,'')) OR
                                MD5(IFNULL(cte.officename::VARCHAR,''))<>             MD5(IFNULL(MP.officename::VARCHAR,'')) OR
                                MD5(IFNULL(cte.AddressTypeCode::VARCHAR,''))<>        MD5(IFNULL(MP.AddressTypeCode::VARCHAR,'')) OR
                                MD5(IFNULL(cte.AddressLine1::VARCHAR,''))<>           MD5(IFNULL(MP.AddressLine1::VARCHAR,'')) OR
                                MD5(IFNULL(cte.AddressLine2::VARCHAR,''))<>           MD5(IFNULL(MP.AddressLine2::VARCHAR,'')) OR
                                MD5(IFNULL(cte.AddressLine3::VARCHAR,''))<>           MD5(IFNULL(MP.AddressLine3::VARCHAR,'')) OR
                                MD5(IFNULL(cte.AddressLine4::VARCHAR,''))<>           MD5(IFNULL(MP.AddressLine4::VARCHAR,'')) OR
                                MD5(IFNULL(cte.City::VARCHAR,''))<>                   MD5(IFNULL(MP.City::VARCHAR,'')) OR
                                MD5(IFNULL(cte.State::VARCHAR,''))<>                  MD5(IFNULL(MP.State::VARCHAR,'')) OR
                                MD5(IFNULL(cte.ZipCode::VARCHAR,''))<>                MD5(IFNULL(MP.ZipCode::VARCHAR,'')) OR
                                MD5(IFNULL(cte.County::VARCHAR,''))<>                 MD5(IFNULL(MP.County::VARCHAR,'')) OR
                                MD5(IFNULL(cte.Nation::VARCHAR,''))<>                 MD5(IFNULL(MP.Nation::VARCHAR,'')) OR
                                MD5(IFNULL(cte.Latitude::VARCHAR,''))<>               MD5(IFNULL(MP.Latitude::VARCHAR,'')) OR
                                MD5(IFNULL(cte.Longitude::VARCHAR,''))<>              MD5(IFNULL(MP.Longitude::VARCHAR,'')) OR
                                MD5(IFNULL(cte.FullPhone::VARCHAR,''))<>              MD5(IFNULL(MP.FullPhone::VARCHAR,'')) OR
                                MD5(IFNULL(cte.FullFax::VARCHAR,''))<>                MD5(IFNULL(MP.FullFax::VARCHAR,'')) OR
                                MD5(IFNULL(cte.HasBillingStaff::VARCHAR,''))<>        MD5(IFNULL(MP.HasBillingStaff::VARCHAR,'')) OR
                                MD5(IFNULL(cte.HasHandicapAccess::VARCHAR,''))<>      MD5(IFNULL(MP.HasHandicapAccess::VARCHAR,'')) OR
                                MD5(IFNULL(cte.HasLabServicesOnSite::VARCHAR,''))<>   MD5(IFNULL(MP.HasLabServicesOnSite::VARCHAR,'')) OR
                                MD5(IFNULL(cte.HasPharmacyOnSite::VARCHAR,''))<>      MD5(IFNULL(MP.HasPharmacyOnSite::VARCHAR,'')) OR
                                MD5(IFNULL(cte.HasXrayOnSite::VARCHAR,''))<>          MD5(IFNULL(MP.HasXrayOnSite::VARCHAR,'')) OR
                                MD5(IFNULL(cte.IsSurgeryCenter::VARCHAR,''))<>        MD5(IFNULL(MP.IsSurgeryCenter::VARCHAR,'')) OR
                                MD5(IFNULL(cte.HasSurgeryOnSite::VARCHAR,''))<>       MD5(IFNULL(MP.HasSurgeryOnSite::VARCHAR,'')) OR
                                MD5(IFNULL(cte.AverageDailyPatientVolume::VARCHAR,''))<>MD5(IFNULL(MP.AverageDailyPatientVolume::VARCHAR,'')) OR
                                MD5(IFNULL(cte.PhysicianCount::VARCHAR,''))<>         MD5(IFNULL(MP.PhysicianCount::VARCHAR,'')) OR
                                MD5(IFNULL(cte.OfficeCoordinatorName::VARCHAR,''))<>  MD5(IFNULL(MP.OfficeCoordinatorName::VARCHAR,'')) OR
                                MD5(IFNULL(cte.ParkingInformation::VARCHAR,''))<>     MD5(IFNULL(MP.ParkingInformation::VARCHAR,'')) OR
                                MD5(IFNULL(cte.PaymentPolicy::VARCHAR,''))<>          MD5(IFNULL(MP.PaymentPolicy::VARCHAR,'')) OR
                                MD5(IFNULL(cte.LegacyKeyOffice::VARCHAR,''))<>        MD5(IFNULL(MP.LegacyKeyOffice::VARCHAR,'')) OR
                                MD5(IFNULL(cte.LegacyKeyPractice::VARCHAR,''))<>      MD5(IFNULL(MP.LegacyKeyPractice::VARCHAR,'')) OR
                                MD5(IFNULL(cte.OfficeRank::VARCHAR,''))<>             MD5(IFNULL(MP.OfficeRank::VARCHAR,'')) OR
                                MD5(IFNULL(cte.CityStatePostalCodeID::VARCHAR,''))<>  MD5(IFNULL(MP.CityStatePostalCodeID::VARCHAR,'')) OR
                                MD5(IFNULL(cte.HasDentist::VARCHAR,''))<>             MD5(IFNULL(MP.HasDentist::VARCHAR,'')) OR
                                MD5(IFNULL(cte.GoogleScriptBlock::VARCHAR,''))<>      MD5(IFNULL(MP.GoogleScriptBlock::VARCHAR,'')) OR
                                MD5(IFNULL(cte.OfficeURL::VARCHAR,''))<>              MD5(IFNULL(MP.OfficeURL::VARCHAR,''))
                            GROUP BY
                                cte.PracticeID
                            )
                    SELECT
                        A0.PracticeId,
                        A0.PracticeCode,
                        A0.PracticeName,
                        A0.YearPracticeEstablished,
                        A0.NPI,
                        A0.PracticeWebsite,
                        A0.PracticeDescription,
                        A0.PracticeLogo,
                        A0.PracticeMedicalDirector,
                        A0.PracticeSoftware,
                        A0.PracticeTIN,
                        A0.OfficeID,
                        A0.OfficeCode,
                        A0.officename,
                        A0.AddressTypeCode,
                        A0.AddressLine1,
                        A0.AddressLine2,
                        A0.AddressLine3,
                        A0.AddressLine4,
                        A0.City,
                        A0.State,
                        A0.ZipCode,
                        A0.County,
                        A0.Nation,
                        A0.Latitude,
                        A0.Longitude,
                        A0.FullPhone,
                        A0.FullFax,
                        A0.HasBillingStaff,
                        A0.HasHandicapAccess,
                        A0.HasLabServicesOnSite,
                        A0.HasPharmacyOnSite,
                        A0.HasXrayOnSite,
                        A0.IsSurgeryCenter,
                        A0.HasSurgeryOnSite,
                        A0.AverageDailyPatientVolume,
                        A0.PhysicianCount,
                        A0.OfficeCoordinatorName,
                        A0.ParkingInformation,
                        A0.PaymentPolicy,
                        A0.LegacyKeyOffice,
                        A0.LegacyKeyPractice,
                        A0.OfficeRank,
                        A0.CityStatePostalCodeID,
                        A0.HasDentist,
                        A0.GoogleScriptBlock,
                        A0.OfficeURL,
                        IFNULL(A1.ActionCode, IFNULL(A2.ActionCode, A0.ActionCode)) AS ActionCode
                    FROM CTE_FinalPractice AS A0
                        LEFT JOIN CTE_Action_1 AS A1 ON A0.PracticeID = A1.PracticeID
                        LEFT JOIN CTE_Action_2 AS A2 ON A0.PracticeID = A2.PracticeID
                    WHERE
                        IFNULL(A1.ActionCode, IFNULL(A2.ActionCode, A0.ActionCode)) <> 0
                    $$;

--- Update Statement
update_statement := ' UPDATE 
                        SET
                            PracticeName = source.PracticeName,
                            YearPracticeEstablished = source.YearPracticeEstablished,
                            NPI = source.NPI,
                            PracticeWebsite = source.PracticeWebsite,
                            PracticeDescription = source.PracticeDescription,
                            PracticeLogo = source.PracticeLogo,
                            PracticeMedicalDirector = source.PracticeMedicalDirector,
                            PracticeSoftware = source.PracticeSoftware,
                            PracticeTIN = source.PracticeTIN,
                            OfficeID = source.OfficeID,
                            OfficeCode = source.OfficeCode,
                            officename = source.officename,
                            AddressTypeCode = source.AddressTypeCode,
                            AddressLine1 = source.AddressLine1,
                            AddressLine2 = source.AddressLine2,
                            AddressLine3 = source.AddressLine3,
                            AddressLine4 = source.AddressLine4,
                            City = source.City,
                            State = source.State,
                            ZipCode = source.ZipCode,
                            County = source.County,
                            Nation = source.Nation,
                            Latitude = source.Latitude,
                            Longitude = source.Longitude,
                            FullPhone = source.FullPhone,
                            FullFax = source.FullFax,
                            HasBillingStaff = source.HasBillingStaff,
                            HasHandicapAccess = source.HasHandicapAccess,
                            HasLabServicesOnSite = source.HasLabServicesOnSite,
                            HasPharmacyOnSite = source.HasPharmacyOnSite,
                            HasXrayOnSite = source.HasXrayOnSite,
                            IsSurgeryCenter = source.IsSurgeryCenter,
                            HasSurgeryOnSite = source.HasSurgeryOnSite,
                            AverageDailyPatientVolume = source.AverageDailyPatientVolume,
                            PhysicianCount = source.PhysicianCount,
                            OfficeCoordinatorName = source.OfficeCoordinatorName,
                            ParkingInformation = source.ParkingInformation,
                            PaymentPolicy = source.PaymentPolicy,
                            LegacyKeyOffice = source.LegacyKeyOffice,
                            LegacyKeyPractice = source.LegacyKeyPractice,
                            OfficeRank = source.OfficeRank,
                            CityStatePostalCodeID = source.CityStatePostalCodeID,
                            HasDentist = source.HasDentist,
                            GoogleScriptBlock = source.GoogleScriptBlock,
                            OfficeURL = source.OfficeURL';

--- Insert Statement
insert_statement := ' INSERT
                        (PracticeId,
                        PracticeCode,
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
                        GoogleScriptBlock,
                        OfficeURL)
                    VALUES
                        (source.PracticeId,
                        source.PracticeCode,
                        source.PracticeName,
                        source.YearPracticeEstablished,
                        source.NPI,
                        source.PracticeWebsite,
                        source.PracticeDescription,
                        source.PracticeLogo,
                        source.PracticeMedicalDirector,
                        source.PracticeSoftware,
                        source.PracticeTIN,
                        source.OfficeID,
                        source.OfficeCode,
                        source.officename,
                        source.AddressTypeCode,
                        source.AddressLine1,
                        source.AddressLine2,
                        source.AddressLine3,
                        source.AddressLine4,
                        source.City,
                        source.State,
                        source.ZipCode,
                        source.County,
                        source.Nation,
                        source.Latitude,
                        source.Longitude,
                        source.FullPhone,
                        source.FullFax,
                        source.HasBillingStaff,
                        source.HasHandicapAccess,
                        source.HasLabServicesOnSite,
                        source.HasPharmacyOnSite,
                        source.HasXrayOnSite,
                        source.IsSurgeryCenter,
                        source.HasSurgeryOnSite,
                        source.AverageDailyPatientVolume,
                        source.PhysicianCount,
                        source.OfficeCoordinatorName,
                        source.ParkingInformation,
                        source.PaymentPolicy,
                        source.LegacyKeyOffice,
                        source.LegacyKeyPractice,
                        source.OfficeRank,
                        source.CityStatePostalCodeID,
                        source.HasDentist,
                        source.GoogleScriptBlock,
                        source.OfficeURL);';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Dev.MidPractice as target USING 
                   ('||select_statement||') as source 
                   ON source.PracticeId = target.PracticeId AND source.OfficeId = target.OfficeId
                   WHEN MATCHED AND ActionCode = 2 THEN '||update_statement|| '
                   WHEN NOT MATCHED And ActionCode = 1 THEN '||insert_statement;
                   
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