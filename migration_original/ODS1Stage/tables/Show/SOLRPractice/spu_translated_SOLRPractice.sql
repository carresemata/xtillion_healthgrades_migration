CREATE OR REPLACE PROCEDURE ODS1_STAGE.SHOW.SP_LOAD_SOLRPRACTICE("ISPROVIDERDELTAPROCESSING" BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Show.SOLRPractice depends on: 
--- MDM_TEAM.MST.Provider_Profile_Processing
--- Base.Practice
--- Base.Office
--- Base.Client
--- Base.ProviderToOffice
--- Mid.PracticeSponsorship
--- Show.vwuProviderIndex
--- Show.ClientContract
--- Mid.Practice
--- Mid.OfficeSpecialty
--- Base.OfficeHours
--- Base.DaysOfWeek
--- Base.vwuPDCPracticeOfficeDetail
--- Base.CityStatePostalCode
--- Base.State
--- Base.Product
--- Base.PracticeEmail
--- Base.Provider


---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    truncate_statement STRING;
    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement_1 STRING; -- Merge statement to final table
    merge_statement_2 STRING;
    merge_statement_3 STRING;
    merge_statement_4 STRING;
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   

BEGIN
    IF (IsProviderDeltaProcessing) THEN
        select_statement := ''
        WITH cte_practice_batch AS (
                    SELECT DISTINCT 
                        BasePrac.PracticeID, 
                        BasePrac.PracticeCode 
                    FROM Base.Practice AS BasePrac 
                    INNER JOIN Base.Office Off ON Off.PracticeID = BasePrac.PracticeID
                    INNER JOIN Base.ProviderToOffice PTO ON PTO.OfficeID = Off.OfficeID
                    INNER JOIN Show.vwuProviderIndex ProvIndx ON ProvIndx.ProviderID = PTO.ProviderID
                    ORDER BY BasePrac.PracticeID
                    ),'';
    ELSE 

        truncate_statement := 'TRUNCATE TABLE Show.SOLRPractice;'; -- Truncated for full loads

        EXECUTE IMMEDIATE truncate_statement;
        
        select_statement := ''
        WITH cte_practice_batch AS (
                    SELECT DISTINCT 
                        BasePrac.PracticeID, 
                        BasePrac.PracticeCode
                    FROM Raw.Provider_Profile_Processing as ppp
                    JOIN Base.Provider AS P On p.providercode = ppp.ref_provider_code
                    INNER JOIN base.ProviderToOffice PTO ON p.ProviderID = PTO.ProviderID
                    INNER JOIN base.Office Off ON PTO.OfficeID = Off.OfficeID
                    INNER JOIN Base.Practice AS BasePrac ON BasePrac.PracticeID = Off.PracticeID
                    ORDER BY BasePrac.PracticeID
                    ),'';
    END IF;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement

select_statement := select_statement || 
                    $$
                        cte_phone AS (
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
                        )
                        ,
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
                                ps.ProductGroupCode = ''PDC''
                                AND bp.ProductTypeCode = ''Practice''
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
                                fa.PhoneTypeCode IN (''PTOOS'', ''PTOOSM'') -- PDC Designated - Office Specific
                            GROUP BY
                                mp.OfficeID,
                                fa.DesignatedProviderPhone,
                                fa.PhoneTypeCode
                        ),
                        
                         cte_phoneL_xml AS (
                            SELECT
                                OfficeID,
                                utils.p_json_to_xml(
                                    ARRAY_AGG(
                        ''{ '' ||
                        IFF(ph IS NOT NULL, ''"ph":'' || ''"'' || ph || ''"'' || '','', '''') ||
                        IFF(phTyp IS NOT NULL, ''"phTyp":'' || ''"'' || phTyp || ''"'', '''')
                        ||'' }''
                                    )::VARCHAR,
                                    '''',
                                    ''phone''
                                ) AS phoneL
                            FROM
                                cte_phoneL
                            WHERE
                                phTyp = ''PTOOS''
                            GROUP BY
                                OfficeID
                        )
                        ,
                        
                        cte_mobile_phoneL_xml AS (
                            SELECT
                                OfficeID,
                                utils.p_json_to_xml(
                                    ARRAY_AGG(
                                        ''{ '' ||
                                        IFF(ph IS NOT NULL, ''"ph":'' || ''"'' || ph || ''"'' || '','', '''') ||
                                        IFF(phTyp IS NOT NULL, ''"phTyp":'' || ''"'' || phTyp || ''"'', '''')
                                        ||'' }''
                                    )::VARCHAR,
                                    '''',
                                    ''mobilePhone''
                                ) AS mobilePhoneL
                            FROM
                                cte_phoneL
                            WHERE
                                phTyp = ''PTOOSM''
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
                                fa.ImageTypeCode in (''FCOLOGO'', ''FCOWALL'') -- PDC Designated - Office Specific
                            GROUP BY
                                mp.OfficeID,
                                fa.ImageFilePath,
                                fa.ImageTypeCode
                        ),
                        cte_imageL_xml AS (
                            SELECT
                                OfficeID,
                                utils.p_json_to_xml(
                                    ARRAY_AGG(
                                        ''{ '' ||
                                        IFF(img IS NOT NULL, ''"img":'' || ''"'' || img || ''"'' || '','', '''') ||
                                        IFF(imgTyp IS NOT NULL, ''"imgTyp":'' || ''"'' || imgTyp || ''"'', '''')
                                        ||'' }''
                                    )::VARCHAR,
                                    '''',
                                    ''image''
                                ) AS imageL
                            FROM
                                cte_imageL
                            GROUP BY
                                OfficeID
                        )
                        ,
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
                                utils.p_json_to_xml(
                                    ARRAY_AGG(
                                        ''{ '' ||
                                        IFF(prCd IS NOT NULL, ''"prCd":'' || ''"'' || prCd || ''"'' || '','', '''') ||
                                        IFF(prGrCd IS NOT NULL, ''"prGrCd":'' || ''"'' || prGrCd || ''"'' || '','', '''') ||
                                        IFF(spnCd IS NOT NULL, ''"spnCd":'' || ''"'' || spnCd || ''"'' || '','', '''') ||
                                        IFF(spnNm IS NOT NULL, ''"spnNm":'' || ''"'' || spnNm || ''"'', '''')
                                        ||'' }''
                                    )::VARCHAR
                                    ,
                                    ''sponsorL'',
                                    ''sponsor''
                                ) AS SponsorshipXML
                            FROM
                                cte_practice_sponsorship
                            GROUP BY
                                PracticeID
                        )
                        ,
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
                                utils.p_json_to_xml(
                                    ARRAY_AGG(
                                        ''{ '' ||
                                        IFF(pEmail IS NOT NULL, ''"pEmail":'' || ''"'' || pEmail || ''"'', '''')
                                        ||'' }''
                                    )::VARCHAR,
                                    ''pEmailL'',
                                    ''''
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
                        )
                        ,
                        cte_hours_xml as (
                            SELECT
                                OfficeID,
                                utils.p_json_to_xml(
                                    ARRAY_AGG(
                                        ''{ '' ||
                                        IFF("day" IS NOT NULL, ''"day":'' || ''"'' || "day" || ''"'' || '','', '''') ||
                                        IFF(dispOrder IS NOT NULL, ''"dispOrder":'' || ''"'' || dispOrder || ''"'' || '','', '''') ||
                                        IFF("start" IS NOT NULL, ''"start":'' || ''"'' || "start" || ''"'' || '','', '''') ||
                                        IFF("end" IS NOT NULL, ''"end":'' || ''"'' || "end" || ''"'' || '','', '''') ||
                                        IFF("closed" IS NOT NULL, ''"closed":'' || ''"'' || "closed" || ''"'' || '','', '''') ||
                                        IFF("open24Hrs" IS NOT NULL, ''"open24Hrs":'' || ''"'' || "open24Hrs" || ''"'', '''')
                                        ||'' }''
                                    )::VARCHAR
                                    ,
                                    ''hoursL'',
                                    ''hours''
                                ) AS hours_xml
                            FROM
                                cte_hours
                            GROUP BY
                                OfficeID
                        )
                        ,
                        cte_phone_xml AS (
                            SELECT
                                OfficeID,
                                utils.p_json_to_xml(
                                    ARRAY_AGG(
                                        ''{ '' ||
                                        IFF(phFull IS NOT NULL, ''"phFull":'' || ''"'' || phFull || ''"'', '''')
                                        ||'' }''
                                    )::VARCHAR,
                                    ''phL'',
                                    ''''
                                ) AS phone_xml
                            FROM
                                cte_phone
                            GROUP BY
                                OfficeID
                        )
                        ,
                        
                        cte_fax_xml AS (
                            SELECT
                                OfficeID,
                                utils.p_json_to_xml(
                                    ARRAY_AGG(
                                        ''{ '' ||
                                        IFF(faxFull IS NOT NULL, ''"faxFull":'' || ''"'' || faxFull || ''"'', '''')
                                        ||'' }''
                                    )::VARCHAR,
                                    ''faxL'',
                                    ''''
                                ) AS fax_xml
                            FROM
                                cte_fax
                            GROUP BY
                                OfficeID
                        )
                        ,
                        
                        cte_specialty_xml AS (
                            SELECT
                                OfficeID,
                                utils.p_json_to_xml(
                                    ARRAY_AGG(
                                        ''{ '' ||
                                        IFF(spCd IS NOT NULL, ''"spCd":'' || ''"'' || spCd || ''"'' || '','', '''') ||
                                        IFF(spY IS NOT NULL, ''"spY":'' || ''"'' || spY || ''"'' || '','', '''') ||
                                        IFF(spIst IS NOT NULL, ''"spIst":'' || ''"'' || spIst || ''"'' || '','', '''') ||
                                        IFF(spIsts IS NOT NULL, ''"spIsts":'' || ''"'' || spIsts || ''"'' || '','', '''') ||
                                        IFF(lKey IS NOT NULL, ''"lKey":'' || ''"'' || lKey || ''"'', '''')
                                        ||'' }''
                                    )::VARCHAR,
                                    ''spcL'',
                                    ''spc''
                                ) AS specialty_xml
                            FROM
                                cte_specialty
                            GROUP BY
                                OfficeID
                        )
                        ,
                        
                        cte_sponsor_xml AS (
                            SELECT
                                OfficeID,
                                utils.p_json_to_xml(
                                    ARRAY_AGG(
                                        ''{ '' ||
                                        IFF(phoneL IS NOT NULL, ''"phoneL":'' || ''"'' || phoneL || ''"'' || '','', '''') ||
                                        IFF(mobilePhoneL IS NOT NULL, ''"mobilePhoneL":'' || ''"'' || mobilePhoneL || ''"'' || '','', '''') ||
                                        IFF(imageL IS NOT NULL, ''"imageL":'' || ''"'' || imageL || ''"'', '''')
                                        ||'' }''
                                    )::VARCHAR,
                                    ''dispL'',
                                    ''disp''
                                ) AS sponsor
                            FROM
                                cte_sponsor
                            GROUP BY
                                OfficeID
                        )
                        ,
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
                                mp.GoogleScriptBlock AS GoogleScriptBlock
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
                                OfficeName,
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
                                GoogleScriptBlock
                            ORDER BY
                                mp.AddressLine1,
                                mp.State
                        )
                        ,
                        cte_office_xml AS (
                            SELECT
                                OfficeID,
                                utils.p_json_to_xml(
                                    ARRAY_AGG(
                                        REPLACE(
                                        ''{ ''||
                                            IFF(oID IS NOT NULL, ''"oID":'' || ''"'' || oID || ''"'' || '','', '''') ||
                                            IFF(oNm IS NOT NULL, ''"oNm":'' || ''"'' || replace(onm,''"'','''') || ''"'' || '','', '''') ||
                                            IFF(oRank IS NOT NULL, ''"oRank":'' || ''"'' || oRank || ''"'' || '','', '''') ||
                                            IFF(addTp IS NOT NULL, ''"addTp":'' || ''"'' || addTp || ''"'' || '','', '''') ||
                                            IFF(ad1 IS NOT NULL, ''"ad1":'' || ''"'' || ad1 || ''"'' || '','', '''') ||
                                            IFF(ad2 IS NOT NULL, ''"ad2":'' || ''"'' || ad2 || ''"'' || '','', '''') ||
                                            IFF(ad3 IS NOT NULL, ''"ad3":'' || ''"'' || ad3 || ''"'' || '','', '''') ||
                                            IFF(ad4 IS NOT NULL, ''"ad4":'' || ''"'' || ad4 || ''"'' || '','', '''') ||
                                            IFF(city IS NOT NULL, ''"city":'' || ''"'' || city || ''"'' || '','', '''') ||
                                            IFF(st IS NOT NULL, ''"st":'' || ''"'' || st || ''"'' || '','', '''') ||
                                            IFF(zip IS NOT NULL, ''"zip":'' || ''"'' || zip || ''"'' || '','', '''') ||
                                            IFF(lat IS NOT NULL, ''"lat":'' || ''"'' || lat || ''"'' || '','', '''') ||
                                            IFF(lng IS NOT NULL, ''"lng":'' || ''"'' || lng || ''"'' || '','', '''') ||
                                            IFF(isBStf IS NOT NULL, ''"isBStf":'' || ''"'' || isBStf || ''"'' || '','', '''') ||
                                            IFF(isHcap IS NOT NULL, ''"isHcap":'' || ''"'' || isHcap || ''"'' || '','', '''') ||
                                            IFF(isLab IS NOT NULL, ''"isLab":'' || ''"'' || isLab || ''"'' || '','', '''') ||
                                            IFF(isPhrm IS NOT NULL, ''"isPhrm":'' || ''"'' || isPhrm || ''"'' || '','', '''') ||
                                            IFF(isXray IS NOT NULL, ''"isXray":'' || ''"'' || isXray || ''"'' || '','', '''') ||
                                            IFF(isSrg IS NOT NULL, ''"isSrg":'' || ''"'' || isSrg || ''"'' || '','', '''') ||
                                            IFF(hasSrg IS NOT NULL, ''"hasSrg":'' || ''"'' || hasSrg || ''"'' || '','', '''') ||
                                            IFF(avVol IS NOT NULL, ''"avVol":'' || ''"'' || avVol || ''"'' || '','', '''') ||
                                            IFF(ocNm IS NOT NULL, ''"ocNm":'' || ''"'' || ocNm || ''"'' || '','', '''') ||
                                            IFF(prkInf IS NOT NULL, ''"prkInf":'' || ''"'' || prkInf || ''"'' || '','', '''') ||
                                            IFF(payPol IS NOT NULL, ''"payPol":'' || ''"'' || payPol || ''"'' || '','', '''') ||
                                            IFF(hours IS NOT NULL, ''"hours":'' || ''"'' || hours || ''"'' || '','', '''') ||
                                            IFF(phone IS NOT NULL, ''"phone":'' || ''"'' || phone || ''"'' || '','', '''') ||
                                            IFF(fax IS NOT NULL, ''"fax":'' || ''"'' || fax || ''"'' || '','', '''') ||
                                            IFF(specialty IS NOT NULL, ''"specialty":'' || ''"'' || specialty || ''"'' || '','', '''') ||
                                            IFF(sponsor IS NOT NULL, ''"sponsor":'' || ''"'' || sponsor || ''"'' || '','', '''') ||
                                            IFF(oLegacyID IS NOT NULL, ''"oLegacyID":'' || ''"'' || oLegacyID || ''"'' || '','', '''') ||
                                            IFF(oLegacyID2 IS NOT NULL, ''"oLegacyID2":'' || ''"'' || oLegacyID2 || ''"'' || '','', '''') ||
                                            IFF(oRank2 IS NOT NULL, ''"oRank2":'' || ''"'' || oRank2 || ''"'' || '','', '''') ||
                                            IFF(PracticeURL IS NOT NULL, ''"PracticeURL":'' || ''"'' || PracticeURL || ''"'' || '','', '''') ||
                                            IFF(GoogleScriptBlock IS NOT NULL, ''"GoogleScriptBlock":'' || ''"'' || GoogleScriptBlock || ''"'', '''')
                                            ||'' }''
                                    ,''\\'''',''\\\\\\'''')
                                    )::VARCHAR
                                    ,
                                    '''',
                                    ''''
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
                            TO_VARIANT(e.PracticeEmailXML) AS PracticeEmailXML,
                            p.PracticeWebsite,
                            p.PracticeDescription,
                            p.PracticeLogo,
                            p.PracticeMedicalDirector,
                            p.PracticeSoftware,
                            p.PracticeTIN,
                            TO_VARIANT(
                                utils.p_json_to_xml(
                                    ARRAY_AGG(
                                        REPLACE(
                                            ''{ ''||
                                            IFF(OfficeXML IS NOT NULL, ''"xml_1":'' || ''"'' || OfficeXML || ''"'', '''')
                                            ||'' }''
                                            ,''\\'''',''\\\\\\'''')
                                            )::VARCHAR
                                            , 
                                            ''offL'', 
                                            ''off'')) 
                                            AS OfficeXML,
                            p.LegacyKeyPractice,
                            p.PhysicianCount,
                            CURRENT_TIMESTAMP() AS UpdatedDate,
                            CURRENT_USER() AS UpdatedSource,
                            p.HasDentist,
                            TO_VARIANT(s.SponsorshipXML) AS SponsorshipXML
                        FROM
                            cte_practice_source AS p
                            LEFT JOIN cte_office_xml AS o ON p.OfficeID = o.OfficeID
                            LEFT JOIN cte_practice_sponsorship_xml AS s ON p.PracticeID = s.PracticeID
                            LEFT JOIN cte_email_xml AS e ON p.PracticeID = e.PracticeID
                        WHERE officexml is not null
                        GROUP BY
                            p.PracticeID,
                            p.PracticeCode,
                            p.PracticeName,
                            p.YearPracticeEstablished,
                            p.NPI,
                            TO_VARIANT(e.PracticeEmailXML),
                            p.PracticeWebsite,
                            p.PracticeDescription,
                            p.PracticeLogo,
                            p.PracticeMedicalDirector,
                            p.PracticeSoftware,
                            p.PracticeTIN,
                            p.LegacyKeyPractice,
                            p.PhysicianCount,
                            p.HasDentist,
                            TO_VARIANT(s.SponsorshipXML) 
                    
                    $$;

--- Update Statement
update_statement := ''UPDATE
                        SET
                            target.PracticeCode = source.PracticeCode,
                            target.PracticeName = source.PracticeName,
                            target.YearPracticeEstablished = source.YearPracticeEstablished,
                            target.NPI = source.NPI,
                            target.PracticeEmailXML = source.PracticeEmailXML,
                            target.PracticeWebsite = source.PracticeWebsite,
                            target.PracticeDescription = source.PracticeDescription,
                            target.PracticeLogo = source.PracticeLogo,
                            target.PracticeMedicalDirector = source.PracticeMedicalDirector,
                            target.PracticeSoftware = source.PracticeSoftware,
                            target.PracticeTIN = source.PracticeTIN,
                            target.LegacyKeyPractice = source.LegacyKeyPractice,
                            target.PhysicianCount = source.PhysicianCount,
                            target.HasDentist = source.HasDentist,
                            target.OfficeXML = source.OfficeXML,
                            target.SponsorshipXML = source.SponsorshipXML,
                            target.UpdatedDate = source.UpdatedDate,
                            target.UpdatedSource = source.UpdatedSource'';

--- Insert Statement
insert_statement := ''INSERT
                            (PracticeID,
                            PracticeCode,
                            PracticeName,
                            YearPracticeEstablished,
                            NPI,
                            PracticeEmailXML,
                            PracticeWebsite,
                            PracticeDescription,
                            PracticeLogo,
                            PracticeMedicalDirector,
                            PracticeSoftware,
                            PracticeTIN,
                            LegacyKeyPractice,
                            PhysicianCount,
                            HasDentist,
                            OfficeXML,
                            SponsorshipXML,
                            UpdatedDate,
                            UpdatedSource)
                    VALUES
                            (source.PracticeID,
                            source.PracticeCode,
                            source.PracticeName,
                            source.YearPracticeEstablished,
                            source.NPI,
                            source.PracticeEmailXML,
                            source.PracticeWebsite,
                            source.PracticeDescription,
                            source.PracticeLogo,
                            source.PracticeMedicalDirector,
                            source.PracticeSoftware,
                            source.PracticeTIN,
                            source.LegacyKeyPractice,
                            source.PhysicianCount,
                            source.HasDentist,
                            source.OfficeXML,
                            source.SponsorshipXML,
                            source.UpdatedDate,
                            source.UpdatedSource);'';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement_1 := '' MERGE INTO Show.SOLRPractice as target USING 
                   (''||select_statement||'') as source 
                   ON source.PracticeID = target.PracticeID
                   WHEN MATCHED THEN ''||update_statement|| ''
                   WHEN NOT MATCHED THEN ''||insert_statement;

                 
-- -- Nullify the SPONSORSHIPXML column for practices with client contracts set to start in the future
merge_statement_2 := ''MERGE INTO Show.SOLRPractice AS target 
                    USING (
                        SELECT SP.PRACTICEID
                        FROM SHOW.SOLRPRACTICE SP
                        JOIN MID.PRACTICESPONSORSHIP PS ON PS.PRACTICEID = SP.PRACTICEID
                        JOIN BASE.CLIENT C ON PS.CLIENTCODE = C.CLIENTCODE
                        JOIN SHOW.CLIENTCONTRACT CC ON C.CLIENTID = CC.CLIENTID
                        WHERE CC.CONTRACTSTARTDATE > CURRENT_TIMESTAMP()
                    ) AS source 
                    ON source.PRACTICEID = target.PRACTICEID
                    WHEN MATCHED THEN 
                        UPDATE SET SPONSORSHIPXML = NULL'';

-- -- Nullify the SPONSORSHIPXML column for practices with client contracts set to end in the past
merge_statement_3 := ''MERGE INTO Show.SOLRPRACTICE AS target 
                        USING (SELECT 
                                PRACTICEID, 
                                CONCAT(''''HGPPZ'''', SUBSTRING(REPLACE(PRACTICEID,''''-'''',''''''''), 1, 16)) AS NEWLEGACYKEYPRACTICE
                            FROM SHOW.SOLRPRACTICE
                            WHERE NEWLEGACYKEYPRACTICE IS NULL
                        ) AS source 
                        ON source.PRACTICEID = target.PRACTICEID
                        WHEN MATCHED THEN 
                            UPDATE SET LEGACYKEYPRACTICE = source.NEWLEGACYKEYPRACTICE'';

-- -- Remove practices with no providers and where PracticeName = Practice
merge_statement_4 := ''MERGE INTO Show.solrpractice AS target 
                    USING ( SELECT solrPrac.PracticeID 
                                                FROM Show.solrpractice solrPrac
                                                LEFT JOIN 
                                                ( SELECT BasePrac.PracticeID 
                                                    FROM Base.providertooffice AS BaseProvOff  
                                                    JOIN Base.office AS BaseOff ON BaseOff.OfficeID = BaseProvOff.OfficeID 
                                                    JOIN Base.practice AS BasePrac ON BasePrac.PracticeID = BaseOff.PracticeID 
                                                    JOIN Show.solrprovider solrProv ON BaseProvOff.ProviderID = solrProv.ProviderID 
                                                    GROUP BY BasePrac.PracticeID   
                                                ) subQuery ON solrPrac.PracticeID = subQuery.PracticeID 
                                                WHERE subQuery.PracticeID IS NULL) AS source
                    ON target.PracticeID = source.PracticeID
                    WHEN MATCHED THEN DELETE '';


---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
EXECUTE IMMEDIATE merge_statement_1 ;
EXECUTE IMMEDIATE merge_statement_2 ;
EXECUTE IMMEDIATE merge_statement_3 ;
EXECUTE IMMEDIATE merge_statement_4 ;

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
--------------------------------------------------------- 

status := ''Completed successfully'';
    RETURN status;


        
EXCEPTION
    WHEN OTHER THEN
          status := ''Failed during execution. '' || ''SQL Error: '' || SQLERRM || '' Error code: '' || SQLCODE || ''. SQL State: '' || SQLSTATE;
          RETURN status;


    
END';