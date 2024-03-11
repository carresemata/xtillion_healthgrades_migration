------------------ SPU 1: HACK.SPUSOLRPRACTICE --------------------
--- CAN BE ADDED IN TABLE CREATION IN THE COLUMN
--HACK 1: Nullify the SPONSORSHIPXML column for practices with client contracts set to start in the future
UPDATE SHOW.SOLR_PRACTICE
SET SPONSORSHIP_XML = NULL
WHERE PRACTICE_ID IN (
    SELECT SP.PRACTICE_ID
    FROM SHOW.SOLR_PRACTICE SP
    JOIN MID.PRACTICE_SPONSORSHIP PS ON PS.PRACTICE_ID = SP.PRACTICE_ID
    JOIN BASE.CLIENT C ON PS.CLIENT_CODE = C.CLIENT_CODE
    JOIN SHOW.CLIENT_CONTRACT CC ON C.CLIENT_ID = CC.CLIENT_ID
    WHERE CC.CONTRACT_START_DATE > GETDATE() );

--- CAN BE ADDED IN TABLE CREATION IN THE COLUMN
-- HACK 2: Nullify the SPONSORSHIPXML column for practices with client contracts set to end in the past
UPDATE SHOW.SOLR_PRACTICE
SET LEGACY_KEY_PRACTICE = CONCAT('HGPPZ', SUBSTRING(REPLACE(PRACTICEID,'-',''), 1, 16))
WHERE LEGACY_KEY_PRACTICE IS NULL;



----------------- SPU 2: SHOW.SPUREMOVEPRACTICEWITHNOPROVIDER ---------------------
-- CAN BE ADDED IN TABLE CREATION AS A DELETE STATEMENT AT THE END
-- Remove practices with no providers
DELETE FROM SHOW.SOLR_PRACTICE
WHERE NOT EXISTS (
    SELECT 1
    FROM BASE.PROVIDER_TO_OFFICE AS A 
    JOIN BASE.OFFICE AS B ON B.OFFICE_ID = A.OFFICE_ID
    JOIN BASE.PRACTICE AS C ON C.PRACTICE_ID = B.PRACTICE_ID
    JOIN SHOW.SOLR_PROVIDER D ON A.PROVIDER_ID = D.PROVIDER_ID
    WHERE SHOW.SOLR_PRACTICE.PRACTICE_ID = C.PRACTICE_ID
);
 

----------------- SPU 3: Show.spuSOLRPracticeGenerateFromMid ---------------------
-- Main SPU

WITH cte_practice_batch AS (
    SELECT
        p.PracticeID,
        p.PracticeCode
    FROM
        Base.ProviderToOffice AS pto
        -- IF @IsDeltaProcessing = 1:
            JOIN Raw.ProviderDeltaProcessing AS delta ON delta.ProviderID = pto.ProviderID
        -- END OF IF
        JOIN Base.Office AS o ON pto.OfficeID = o.OfficeID
        JOIN Base.Practice AS p ON p.PracticeID = o.PracticeID
    GROUP BY
        p.PracticeID,
        p.PracticeCode
),cte_phone AS (
    SELECT
        p.OfficeID,
        p.FullPhone AS phFull
    FROM
        Mid.Practice AS p
        JOIN cte_practice_batch AS pb ON p.PracticeID = pb.PracticeID
    WHERE
        p.FullPhone IS NOT NULL
    GROUP BY
        p.OfficeID,
        p.FullPhone
),
cte_fax AS (
    SELECT
        p.officeid,
        p.FullFax as faxFull
    FROM
        Mid.Practice AS p
        JOIN cte_practice_batch AS pb ON p.PracticeID = pb.PracticeID
    WHERE
        p.FullFax IS NOT NULL
    GROUP BY
        p.officeid,
        p.FullFax
),
cte_specialty AS (
    SELECT
        OfficeID,
        SpecialtyCode AS spCd,
        Specialty AS spY,
        Specialist AS spIst,
        Specialists AS spIsts,
        LegacyKey AS lKey
    FROM
        Mid.OfficeSpecialty
    GROUP BY
        OfficeID,
        SpecialtyCode,
        Specialty,
        Specialist,
        Specialists,
        LegacyKey
),
cte_hours AS (
    SELECT
        p.OfficeID,
        dow.DaysOfWeekDescription AS "day",
        dow.SortOrder AS dispOrder,
        oh.OfficeHoursOpeningTime AS "start",
        oh.OfficeHoursClosingTime AS "end",
        oh.OfficeIsClosed AS "closed",
        oh.OfficeIsOpen24Hours AS "open24Hrs"
    FROM
        Mid.Practice AS p
        JOIN cte_practice_batch AS pb ON p.PracticeID = pb.PracticeID
        JOIN Base.OfficeHours AS oh ON oh.OfficeID = p.OfficeID
        JOIN Base.DaysOfWeek AS dow ON dow.DaysOfWeekID = oh.DaysOfWeekID
    GROUP BY
        p.OfficeID,
        dow.DaysOfWeekDescription,
        dow.SortOrder,
        oh.OfficeHoursOpeningTime,
        oh.OfficeHoursClosingTime,
        oh.OfficeIsClosed,
        oh.OfficeIsOpen24Hours
),
cte_sponsor_stg AS (
    SELECT
        ps.PracticeID,
        mp.OfficeID,
    FROM
        Mid.PracticeSponsorship AS ps
        JOIN cte_practice_batch AS pb ON pb.PracticeID = ps.PracticeID
        JOIN Mid.Practice AS mp ON ps.PracticeID = mp.PracticeID
        JOIN Base.Product AS bp ON ps.ProductCode = bp.ProductCode
    WHERE
        ps.ProductGroupCode = 'PDC'
        AND 
    bp.ProductTypeCode = 'Practice'
    GROUP BY
        ps.PracticeID,
        mp.officeid
),
cte_phoneL AS (
    SELECT
        mp.OfficeID,
        fa.DesignatedProviderPhone AS ph,
        fa.PhoneTypeCode AS phTyp
    FROM
        Base.vwuPDCPracticeOfficeDetail AS fa
        JOIN cte_sponsor_stg AS mp ON mp.OfficeID = fa.OfficeID
    WHERE
        fa.PhoneTypeCode IN ('PTOOS', 'PTOOSM') -- PDC Designated - Office Specific
    GROUP BY
        mp.OfficeID,
        fa.DesignatedProviderPhone,
        fa.PhoneTypeCode
),
cte_phoneL_xml AS (
    SELECT
        OfficeID,
        p_json_to_xml(
            ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'ph', ph,
                    'phTyp', phTyp
                )
            )::VARCHAR,
            '', 'phone'
        ) AS phoneL
    FROM
        cte_phoneL
    WHERE
        phTyp = 'PTOOS'
    GROUP BY
        OfficeID
),
cte_mobile_phoneL_xml AS (
    SELECT
        OfficeID,
        p_json_to_xml(
            ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'ph', ph,
                    'phTyp', phTyp
                )
            )::VARCHAR,
            '', 'mobilePhone'
        ) AS mobilePhoneL
    FROM
        cte_phoneL
    WHERE
        phTyp = 'PTOOSM'
    GROUP BY
        OfficeID
),
cte_imageL AS (
    SELECT
        mp.OfficeID,
        fa.ImageFilePath AS img,
        fa.ImageTypeCode AS imgTyp
    FROM
        Base.vwuPDCPracticeOfficeDetail AS fa
        JOIN cte_sponsor_stg AS mp ON mp.OfficeID = fa.OfficeID
    WHERE
        fa.ImageTypeCode in ('FCOLOGO', 'FCOWALL') -- PDC Designated - Office Specific
    GROUP BY
        mp.OfficeID,
        fa.ImageFilePath,
        fa.ImageTypeCode
),
cte_imageL_xml AS (
    SELECT
        OfficeID,
        p_json_to_xml(
            ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'img', img,
                    'imgTyp', imgTyp
                )
            )::VARCHAR,
            '', 'image'
        ) AS imageL
    FROM
        cte_imageL
    GROUP BY
        OfficeID
),
cte_sponsor AS (
    SELECT
        s.OfficeID,
        p.phoneL,
        mp.mobilePhoneL, 
        i.imageL
    FROM
        cte_sponsor_stg AS s
        LEFT JOIN cte_phoneL_xml AS p ON s.OfficeID = p.OfficeID
        LEFT JOIN cte_mobile_phoneL_xml AS mp ON s.OfficeID = mp.OfficeID
        LEFT JOIN cte_imageL_xml AS i ON s.OfficeID = i.OfficeID
),
cte_practice_sponsorship AS (
    SELECT
        ps.ProductCode AS prCd,
        ps.ProductGroupCode AS prGrCd,
        ps.ClientCode AS spnCd,
        ps.ClientName AS spnNm,
        ps.PracticeId
    FROM
        Mid.PracticeSponsorship AS ps
        JOIN cte_practice_batch AS pb ON pb.PracticeID = ps.PracticeID
),
cte_practice_sponsorship_xml AS (
    SELECT
        PracticeID,
        p_json_to_xml(
            ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'prCd', prCd,
                    'prGrCd', prGrCd,
                    'spnCd', spnCd,
                    'spnNm', spnNm
                )
            )::VARCHAR,
            'sponsorL', 'sponsor'
        ) AS SponsorshipXML
    FROM
        cte_practice_sponsorship
    GROUP BY
        PracticeID
),
cte_email AS (
    SELECT
        pe.EmailAddress AS pEmail,
        pe.PracticeID
    FROM
        Base.PracticeEmail pe
        JOIN cte_practice_batch AS pb ON pb.PracticeID = pe.PracticeID
    WHERE
        pe.EmailAddress IS NOT NULL
    GROUP BY
        pe.EmailAddress,
        pe.PracticeID
),
cte_email_xml AS (
    SELECT
        PracticeID,
        p_json_to_xml(
            ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'pEmail', pEmail
                )
            )::VARCHAR,
            'pEmailL', ''
        ) AS PracticeEmailXML
    FROM
        cte_email
    GROUP BY
        PracticeID
),
cte_practice_source AS (
    SELECT
        p.PracticeID,
        p.OfficeId,
        p.PracticeCode,
        p.PracticeName,
        p.YearPracticeEstablished,
        p.NPI,
        p.PracticeWebsite,
        p.PracticeDescription,
        p.PracticeLogo,
        p.PracticeMedicalDirector,
        p.PracticeSoftware,
        p.PracticeTIN,
        p.LegacyKeyPractice,
        p.PhysicianCount,
        p.HasDentist
    FROM
        Mid.Practice AS p
        JOIN cte_practice_batch AS pb ON p.PracticeID = pb.PracticeID
        JOIN Base.Office AS o ON p.OfficeID = o.OfficeID
        JOIN Base.ProviderToOffice AS po ON o.OfficeID = po.OfficeID
        JOIN Show.vwuProviderIndex AS vpi ON po.ProviderID = vpi.ProviderID
),
cte_hours_xml as (
       SELECT
        OfficeID,
        p_json_to_xml(
            ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'day', "day",
                    'dispOrder', dispOrder,
                    'start', "start",
                    'end', "end",
                    'closed', "closed",
                    'open24Hrs', "open24Hrs"
                )
            )::VARCHAR,
            'hoursL', 'hours'
        ) AS hours_xml
    FROM
        cte_hours
    GROUP BY
        OfficeID
),
cte_phone_xml AS (
    SELECT
        OfficeID,
        p_json_to_xml(
            ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'phFull', phFull
                )
            )::VARCHAR,
            'phL', ''
        ) AS phone_xml
    FROM
        cte_phone
    GROUP BY
        OfficeID
),
cte_fax_xml AS (
    SELECT
        OfficeID,
        p_json_to_xml(
            ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'faxFull', faxFull
                )
            )::VARCHAR,
            'faxL', ''
        ) AS fax_xml
    FROM
        cte_fax
    GROUP BY
        OfficeID
),
cte_specialty_xml AS (
    SELECT
        OfficeID,
        p_json_to_xml(
            ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'spCd', spCd,
                    'spY', spY,
                    'spIst', spIst,
                    'spIsts', spIsts,
                    'lKey', lKey
                )
            )::VARCHAR,
            'spcL', 'spc'
        ) AS specialty_xml
    FROM
        cte_specialty
    GROUP BY
        OfficeID
),
cte_sponsor_xml AS (
    SELECT
        OfficeID,
        p_json_to_xml(
            ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'phoneL', phoneL,
                    'mobilePhoneL', mobilePhoneL,
                    'imageL', imageL
                )
            )::VARCHAR,
            'dispL', 'disp'
        ) AS sponsor
    FROM
        cte_sponsor
    GROUP BY
        OfficeID
),
cte_office AS (
    SELECT
        mp.OfficeID,
        mp.OfficeCode as oID,
        mp.OfficeName as oNm,
        mp.OfficeRank as oRank,
        mp.AddressTypeCode as addTp,
        mp.AddressLine1 as ad1,
        mp.AddressLine2 as ad2,
        mp.AddressLine3 as ad3,
        mp.AddressLine4 as ad4,
        mp.City as city,
        mp.State as st,
        mp.ZipCode as zip,
        mp.Latitude as lat,
        mp.Longitude as lng,
        mp.HasBillingStaff as isBStf,
        mp.HasHandicapAccess isHcap,
        mp.HasLabServicesOnSite as isLab,
        mp.HasPharmacyOnSite as isPhrm,
        mp.HasXrayOnSite isXray,
        mp.IsSurgeryCenter as isSrg,
        mp.HasSurgeryOnSite hasSrg,
        mp.AverageDailyPatientVolume as avVol,
        mp.OfficeCoordinatorName as ocNm,
        mp.ParkingInformation as prkInf,
        mp.PaymentPolicy as payPol,
        h.hours_xml as hours,
        p.phone_xml as phone,
        f.fax_xml as fax,
        s.specialty_xml as specialty,
        sp.sponsor as sponsor,
        mp.LegacyKeyOffice AS oLegacyID,
        SUBSTRING(mp.LegacyKeyOffice, 5, 8) as oLegacyID2,
        mp.OfficeRank as oRank2,
        mp.OfficeUrl AS PracticeURL,
        mp.GoogleScriptBlock
    FROM
        Mid.Practice mp
        LEFT JOIN cte_hours_xml h ON mp.OfficeID = h.OfficeID
        LEFT JOIN cte_phone_xml p ON mp.OfficeID = p.OfficeID
        LEFT JOIN cte_fax_xml f ON mp.OfficeID = f.OfficeID
        LEFT JOIN cte_specialty_xml s ON mp.OfficeID = s.OfficeID
        LEFT JOIN cte_sponsor_xml sp ON mp.OfficeID = sp.OfficeID
        JOIN Base.CityStatePostalCode b ON mp.CityStatePostalCodeID = b.CityStatePostalCodeID
        JOIN Base.State c ON c.state = b.state
    GROUP BY
        mp.OfficeID,
        mp.OfficeCode,
        mp.OfficeName,
        mp.OfficeRank,
        mp.AddressTypeCode,
        mp.AddressLine1,
        mp.AddressLine2,
        mp.AddressLine3,
        mp.AddressLine4,
        mp.City,
        mp.State,
        mp.ZipCode,
        mp.Latitude,
        mp.Longitude,
        mp.HasBillingStaff,
        mp.HasHandicapAccess,
        mp.HasLabServicesOnSite,
        mp.HasPharmacyOnSite,
        mp.HasXrayOnSite,
        mp.IsSurgeryCenter,
        mp.HasSurgeryOnSite,
        mp.AverageDailyPatientVolume,
        mp.OfficeCoordinatorName,
        mp.ParkingInformation,
        mp.PaymentPolicy,
        h.hours_xml,
        p.phone_xml,
        f.fax_xml,
        s.specialty_xml,
        sp.sponsor,
        mp.LegacyKeyOffice,
        mp.OfficeID,
        c.StateName,
        b.State,
        b.City,
        mp.PracticeName,
        mp.OfficeUrl,
        mp.GoogleScriptBlock
    ORDER BY
        mp.AddressLine1,
        mp.State
),
cte_office_xml AS (
    SELECT
        OfficeID,
        p_json_to_xml(
            ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'oID', oID,
                    'oNm', oNm,
                    'oRank', oRank,
                    'addTp', addTp,
                    'ad1', ad1,
                    'ad2', ad2,
                    'ad3', ad3,
                    'ad4', ad4,
                    'city', city,
                    'st', st,
                    'zip', zip,
                    'lat', lat,
                    'lng', lng,
                    'isBStf', isBStf,
                    'isHcap', isHcap,
                    'isLab', isLab,
                    'isPhrm', isPhrm,
                    'isXray', isXray,
                    'isSrg', isSrg,
                    'hasSrg', hasSrg,
                    'avVol', avVol,
                    'ocNm', ocNm,
                    'prkInf', prkInf,
                    'payPol', payPol,
                    'hours', hours,
                    'phone', phone,
                    'fax', fax,
                    'specialty', specialty,
                    'sponsor', sponsor,
                    'oLegacyID', oLegacyID,
                    'oLegacyID', oLegacyID2,
                    'oRank', oRank2,
                    'PracticeURL', PracticeURL,
                    'GoogleScriptBlock', GoogleScriptBlock
                )
            )::VARCHAR,
            'offL', 'off'
        ) AS OfficeXML
    FROM
        cte_office
    GROUP BY
        OfficeID
)
SELECT
    p.PracticeID,
    p.PracticeCode,
    p.PracticeName,
    p.YearPracticeEstablished,
    p.NPI,
    e.PracticeEmailXML,
    p.PracticeWebsite,
    p.PracticeDescription,
    p.PracticeLogo,
    p.PracticeMedicalDirector,
    p.PracticeSoftware,
    p.PracticeTIN,
    o.OfficeXML,
    p.LegacyKeyPractice,
    p.PhysicianCount,
    GETDATE() AS UpdatedDate,
    CURRENT_USER() AS UpdatedSource,
    p.HasDentist,
    s.SponsorshipXML
FROM
    cte_practice_source AS p
    LEFT JOIN cte_office_xml AS o ON p.OfficeID = o.OfficeID
    LEFT JOIN cte_practice_sponsorship_xml AS s ON p.PracticeID = s.PracticeID
    LEFT JOIN cte_email_xml AS e ON p.PracticeID = e.PracticeID
GROUP BY	
    p.PracticeID,
    p.PracticeCode,
    p.PracticeName,
    p.YearPracticeEstablished,
    p.NPI,
    e.PracticeEmailXML,
    p.PracticeWebsite,
    p.PracticeDescription,
    p.PracticeLogo,
    p.PracticeMedicalDirector,
    p.PracticeSoftware,
    p.PracticeTIN,
    o.OfficeXML,
    p.LegacyKeyPractice,
    p.PhysicianCount,
    p.HasDentist,
    s.SponsorshipXML