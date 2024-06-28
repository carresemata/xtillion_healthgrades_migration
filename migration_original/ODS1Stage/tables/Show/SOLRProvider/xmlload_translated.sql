
-- Mid.ProviderPracticeOffice
-- Base.OfficeHours
-- Base.DaysOfWeek
-- Base.Address
-- Base.CityStatePostalCode
-- Base.State
-- ERMART1.Facility_AwardToMedicalTerm
-- Base.FacilityToAward
-- Base.Award
-- Base.AwardCategory
-- ERMART1.Facility_ServiceLine
-- ERMART1.Facility_FacilityToAward
-- Mid.Provider
-- Mid.Practice
-- ERMART1.Facility_HospitalDetail
-- Base.FacilityImage
-- Base.MediaImageType
-- Base.vwuPDCFacilityDetail
-- Base.vwuPDCClientDetail
-- Base.FacilityCheckinURL
-- Base.ProviderType
-- Base.ProviderTypeToMedicalTerm
-- Base.ProviderToProviderType
-- Base.ProviderSubType
-- Base.ProviderSubTypeToMedicalTerm
-- Base.ProviderToSubStatus
-- Base.SubStatus
-- Base.DisplayStatus
-- Mid.ProviderSponsorship
-- Base.Product
-- ERMART1.Ref_ProcessMeasure
-- ERMART1.Facility_FacilityToProcessMeasures
-- ERMART1.Facility_FacilityAddressDetail
-- ERMART1.Facility_ProcessMeasureScore
-- Base.FacilityToRating
-- ERMART1.Facility_Rating
-- ERMART1.Facility_FacilityToTraumaLevel
-- Base.Client
-- Base.ClientToProduct
-- Base.EntityType
-- Base.MedicalTerm
-- Base.MedicalTermType
-- ERMART1.Facility_FacilityToMedicalTerm
-- ERMART1.Facility_FacilityToProcedureRating
-- ERMART1.Facility_vwuFacilityHGDisplayProcedures
-- ERMART1.Facility_ProcedureToServiceLine
-- ERMART1.Facility_ServiceLine
-- ERMART1.Facility_FacilityToServiceLineRating
-- ERMART1.Facility_ProcedureRatingsNationalAverage
-- ERMART1.Facility_Procedure
-- Base.CohortToProcedure
-- ERMART1.Facility_FacilityToMaternityDetail
-- Base.TempSpecialtyToServiceLineGhetto
-- Base.CertificationSpecialty
-- Base.ProviderToCertificationSpecialty
-- Base.CertificationAgency
-- Base.CertificationBoard
-- Base.CertificationStatus
-- Base.MOCLevel
-- Base.MOCPathway
-- Mid.ProviderLanguage
-- Base.Language
-- Base.FacilityToLanguage
-- Base.FacilityToService
-- Base.Service
-- Base.ClientEntityToClientFeature
-- Base.ClientFeatureToClientFeatureValue
-- Base.ClientFeature
-- Base.ClientFeatureValue
-- Base.ClientFeatureGroup
-- Base.vwuCallCenterDetails
-- Base.ProviderToTelehealthMethod
-- Base.TelehealthMethod
-- Base.TelehealthMethodType
-- Mid.PartnerEntity
-- Base.ProviderToClientProductToDisplayPartner
-- Base.SyndicationPartner
-- Mid.ProviderHealthInsurance
-- Base.HealthInsurancePlanToPlanType
-- Base.HealthInsurancePlan
-- Base.HealthInsurancePlanType
-- Base.HealthInsurancePayor
-- Base.HealthInsurancePayorOrganization
-- Base.ProviderMedia
-- Base.MediaType
-- Mid.ProviderRecognition
-- Base.EntityToMedicalTerm
-- Base.ProviderToSpecialty
-- Base.SpecialtyToProcedureMedical
-- Base.ProviderProcedure
-- Base.ProviderSanction
-- Base.SanctionType
-- Base.SanctionCategory
-- Base.SanctionAction
-- Base.StateReportingAgency
-- Base.SanctionActionType
-- Base.ProviderIdentification
-- Base.IdentificationType
-- Base.ProviderEmail
-- Base.Degree
-- Base.ProviderToDegree
-- Base.ProviderSurveyAggregate
-- Show.SOLRProviderSurveyQuestionAndAnswer
-- Mid.SurveyQuestionRangeMapping
-- Base.ClinicalFocusDCP
-- Base.ProviderToClinicalFocus
-- Base.ClinicalFocus
-- Base.ClinicalFocusToSpecialty
-- Base.Specialty
-- Base.ProviderTraining
-- Base.Training
-- Base.ProviderLastUpdateDate
-- Base.Provider
-- Base.vwuPDCClientDetail
-- Base.ProviderToClientToOASPartner
-- Base.OASPartner





-------------------------------------------------------------------------
-------------------------------------------------------------------------
------------------------------XML LOAD-----------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
WITH CTE_Temp_Provider AS (
    SELECT
        DISTINCT ProviderID
    FROM
        Show.SOLRProvider 
),
------------------------ProviderProcedureXMLLoads------------------------
CTE_ProviderProceduresq AS (
    SELECT
        a.ProviderID,
        a.ProcedureCode,
        0 AS IsMapped
    FROM
        Mid.ProviderProcedure a
        INNER JOIN CTE_Temp_Provider pr ON a.ProviderID = pr.ProviderId
    UNION ALL
    SELECT
        a.ProviderID,
        mt.MedicalTermCode AS ProcedureCode,
        1 AS IsMapped
    FROM
        Base.ProviderToSpecialty a
        INNER JOIN Base.Specialty b ON b.SpecialtyID = a.SpecialtyID
        INNER JOIN Base.SpecialtyToProcedureMedical spm ON b.SpecialtyID = spm.SpecialtyID
        INNER JOIN Base.MedicalTerm mt ON mt.MedicalTermID = spm.ProcedureMedicalID
        INNER JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID
            AND mtt.MedicalTermTypeCode = 'Procedure'
        INNER JOIN CTE_Temp_Provider pr ON a.ProviderID = pr.ProviderId
    WHERE
        a.SpecialtyIsRedundant = 0
        AND a.IsSearchableCalculated = 1
),

CTE_ProviderProcedureXMLLoads AS (
    SELECT
        ProviderID,
        ProcedureCode,
        IsMapped
    FROM
        CTE_ProviderProceduresq
),
------------------------ProviderConditionXMLLoads------------------------
CTE_ProviderConditionsq AS (
    SELECT
        a.ProviderID,
        a.ConditionCode,
        0 AS IsMapped
    FROM
        Mid.ProviderCondition a
        INNER JOIN CTE_Temp_Provider pr ON a.ProviderID = pr.ProviderId
    UNION ALL
    SELECT
        a.ProviderID,
        mt.MedicalTermCode AS ConditionCode,
        1 AS IsMapped
    FROM
        Base.ProviderToSpecialty a
        INNER JOIN Base.Specialty b ON b.SpecialtyID = a.SpecialtyID
        INNER JOIN Base.SpecialtyToCondition spm ON b.SpecialtyID = spm.SpecialtyID
        INNER JOIN Base.MedicalTerm mt ON mt.MedicalTermID = spm.ConditionID
        INNER JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID
            AND mtt.MedicalTermTypeCode = 'Condition'
        INNER JOIN CTE_Temp_Provider pr ON a.ProviderID = pr.ProviderId
    WHERE
        a.SpecialtyIsRedundant = 0
        AND a.IsSearchableCalculated = 1
),

CTE_ProviderConditionXMLLoads AS (
    SELECT
        ProviderID,
        ConditionCode,
        IsMapped
    FROM
        CTE_ProviderConditionsq
),

-----------------------------TeleHealthXML-----------------------------
CTE_TeleHealth AS (
    SELECT
        DISTINCT PTM.ProviderID,
        MT.MethodTypeCode AS type,
        M.TelehealthMethod AS method,
        M.ServiceName AS servicename
    FROM
        Base.ProviderToTelehealthMethod PTM
        INNER JOIN Base.TelehealthMethod M ON M.TelehealthMethodId = PTM.TelehealthMethodId
        INNER JOIN Base.TelehealthMethodType MT ON MT.TelehealthMethodTypeId = M.TelehealthMethodTypeId
    WHERE
        MT.MethodTypeCode IN ('URL', 'PHONE')
),
CTE_TelehealthXML AS (
    SELECT
        T.ProviderID,
        CASE
            WHEN P.ProviderId IS NULL THEN NULL
            ELSE '<Telehealth>' || '<hasTelehealth>' || 'true' || '</hasTelehealth>' || iff(cte_th.type is not null,'<type>' || cte_th.type || '</type>','') ||
iff(REPLACE is not null,'<method>' || REPLACE || '</method>','') ||
iff(cte_th.servicename is not null,'<servicename>' || cte_th.servicename || '</servicename>','') ||
 || '</Telehealth>'
        END AS XMLValue
    FROM
        CTE_Temp_Provider T
        INNER JOIN CTE_TeleHealth cte_th ON cte_th.ProviderId = T.ProviderID
        LEFT JOIN (
            SELECT
                DISTINCT ProviderId
            FROM
                Base.ProviderToTelehealthMethod
        ) P ON P.ProviderId = T.ProviderId
    GROUP BY
        T.ProviderID,
        P.ProviderID
),
------------------------ProviderTypeXML------------------------
CTE_ProviderType AS (
    SELECT
        bptpt.ProviderID,
        bpt.ProviderTypeCode AS ptCd,
        bpt.ProviderTypeDescription AS ptD,
        bptpt.ProviderTypeRank AS ptRank
    FROM
        Base.ProviderToProviderType bptpt
        INNER JOIN Base.ProviderType bpt ON bptpt.ProviderTypeID = bpt.ProviderTypeID
    WHERE
        ProviderTypeRank = CASE
            WHEN ProviderTypeCode = 'ALT' THEN 1
            ELSE ProviderTypeRank
        END
    ORDER BY
        IFNULL(bptpt.ProviderTypeRank, 2147483647)
),
CTE_ProviderTypeXML AS (
    SELECT
        T.ProviderID,
        iff(cte_pt.ptCd is not null,'<ptCd>' || cte_pt.ptCd || '</ptCd>','') ||
iff(cte_pt.ptD is not null,'<ptD>' || cte_pt.ptD || '</ptD>','') ||
iff(cte_pt.ptRank is not null,'<ptRank>' || cte_pt.ptRank || '</ptRank>','') ||
 AS XMLValue
    FROM
        CTE_Temp_Provider T
        LEFT JOIN CTE_ProviderType cte_pt ON cte_pt.ProviderId = T.ProviderID
    GROUP BY
        T.ProviderID
),
------------------------PracticeOfficeXML------------------------
CTE_PracticeOfficeHoursBase AS (
    SELECT
        dow.DaysOfWeekDescription AS _day,
        dow.SortOrder AS dispOrder,
        CAST(oh.OfficeHoursOpeningTime AS VARCHAR) AS _start,
        CAST(oh.OfficeHoursClosingTime AS VARCHAR) AS _end,
        oh.OfficeIsClosed AS closed,
        oh.OfficeIsOpen24Hours AS open24Hrs,
        ppo.ProviderId,
        ppo.OfficeID
    FROM
        Mid.ProviderPracticeOffice ppo
        INNER JOIN base.OfficeHours oh ON oh.OfficeID = ppo.OfficeID
        INNER JOIN base.DaysOfWeek dow ON dow.DaysOfWeekID = oh.DaysOfWeekID
        INNER JOIN CTE_Temp_Provider p ON ppo.ProviderID = p.ProviderID
    ORDER BY
        dow.SortOrder
),
CTE_PracticeOfficephFullBase AS (
    SELECT
        DISTINCT ppo.FullPhone AS phFull,
        ppo.ProviderId,
        ppo.OfficeID
    FROM
        Mid.ProviderPracticeOffice ppo
        INNER JOIN CTE_Temp_Provider p ON ppo.ProviderID = p.ProviderID
),
CTE_PracticeOfficefaxFullBase AS (
    SELECT
        DISTINCT ppo.FullFax AS faxFull,
        ppo.ProviderId,
        ppo.OfficeID
    FROM
        Mid.ProviderPracticeOffice ppo
        INNER JOIN CTE_Temp_Provider p ON ppo.ProviderID = p.ProviderID
),
CTE_PracticeOfficeBase AS (
    SELECT
        ppo.OfficeID AS oGUID,
        ppo.OfficeCode AS oID,
        ppo.OfficeName AS oNm,
        ppo.IsPrimaryOffice AS prmryO,
        ppo.ProviderOfficeRank AS oRank,
        ppo.AddressTypeCode AS addTp,
        ppo.AddressCode AS addCd,
        ppo.AddressLine1 AS ad1,
        ppo.AddressLine2 AS ad2,
        ppo.AddressLine3 AS ad3,
        ppo.AddressLine4 AS ad4,
        ppo.City AS city,
        ppo.State AS st,
        ppo.ZipCode AS zip,
        ppo.Latitude AS lat,
        ppo.Longitude AS lng,
        a.TimeZone AS tzn,
        ppo.HasBillingStaff AS isBStf,
        ppo.HasHandicapAccess isHcap,
        ppo.HasLabServicesOnSite isLab,
        ppo.HasPharmacyOnSite AS isPhrm,
        ppo.HasXrayOnSite isXray,
        ppo.IsSurgeryCenter AS isSrg,
        ppo.HasSurgeryOnSite hasSrg,
        ppo.AverageDailyPatientVolume AS avVol,
        ppo.OfficeCoordinatorName AS ocNm,
        ppo.ParkingInformation AS prkInf,
        ppo.PaymentPolicy AS payPol,
        a.AddressLine1 AS ast,
        a.Suite AS ste,
        ppo.LegacyKeyOffice AS oLegacyID,
        REPLACE(
            '/group-directory/' || LOWER(cspc.State) || '-' || LOWER(REPLACE(s.StateName, ' ', '-')) || '/' || LOWER(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                REPLACE(
                                    REPLACE(REPLACE(cspc.City, ' - ', ' '), '&', '-'),
                                    ' ',
                                    '-'
                                ),
                                '/',
                                '-'
                            ),
                            '''',
                            ''
                        ),
                        '.',
                        ''
                    ),
                    '--',
                    '-'
                )
            ) || '/' || LOWER(
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
                                                                                                                                                                        REPLACE(LTRIM(RTRIM(pr.PracticeName)), ' - ', ' '),
                                                                                                                                                                        '&',
                                                                                                                                                                        '-'
                                                                                                                                                                    ),
                                                                                                                                                                    ' ',
                                                                                                                                                                    '-'
                                                                                                                                                                ),
                                                                                                                                                                '/',
                                                                                                                                                                '-'
                                                                                                                                                            ),
                                                                                                                                                            '\\\\',
                                                                                                                                                            '-'
                                                                                                                                                        ),
                                                                                                                                                        '''',
                                                                                                                                                        ''
                                                                                                                                                    ),
                                                                                                                                                    ':',
                                                                                                                                                    ''
                                                                                                                                                ),
                                                                                                                                                '~',
                                                                                                                                                ''
                                                                                                                                            ),
                                                                                                                                            ';',
                                                                                                                                            ''
                                                                                                                                        ),
                                                                                                                                        '|',
                                                                                                                                        ''
                                                                                                                                    ),
                                                                                                                                    '<',
                                                                                                                                    ''
                                                                                                                                ),
                                                                                                                                '>',
                                                                                                                                ''
                                                                                                                            ),
                                                                                                                            '?',
                                                                                                                            ''
                                                                                                                        ),
                                                                                                                        '?',
                                                                                                                        ''
                                                                                                                    ),
                                                                                                                    '*',
                                                                                                                    ''
                                                                                                                ),
                                                                                                                '?',
                                                                                                                ''
                                                                                                            ),
                                                                                                            '+',
                                                                                                            ''
                                                                                                        ),
                                                                                                        '?',
                                                                                                        ''
                                                                                                    ),
                                                                                                    '!',
                                                                                                    ''
                                                                                                ),
                                                                                                '?',
                                                                                                ''
                                                                                            ),
                                                                                            '@',
                                                                                            ''
                                                                                        ),
                                                                                        '{',
                                                                                        ''
                                                                                    ),
                                                                                    '}',
                                                                                    ''
                                                                                ),
                                                                                '[',
                                                                                ''
                                                                            ),
                                                                            ']',
                                                                            ''
                                                                        ),
                                                                        '(',
                                                                        ''
                                                                    ),
                                                                    ')',
                                                                    ''
                                                                ),
                                                                '?',
                                                                'n'
                                                            ),
                                                            '?',
                                                            'a'
                                                        ),
                                                        '?',
                                                        'i'
                                                    ),
                                                    '"',
                                                    ''
                                                ),
                                                '?',
                                                ''
                                            ),
                                            ' ',
                                            ''
                                        ),
                                        '`',
                                        ''
                                    ),
                                    ',',
                                    ''
                                ),
                                '#',
                                ''
                            ),
                            '.',
                            ''
                        ),
                        '---',
                        '-'
                    ),
                    '--',
                    '-'
                )
            ) || '-' || LOWER(pr.OfficeCode),
            '--',
            '-'
        ) AS pracUrl,
        ppo.PracticeID,
        ppo.ProviderID
    FROM
        Mid.ProviderPracticeOffice ppo
        LEFT JOIN Mid.Practice pr ON ppo.OfficeID = pr.OfficeID
        AND ppo.PracticeID = pr.PracticeID
        LEFT JOIN Base.CityStatePostalCode cspc ON pr.CityStatePostalCodeID = cspc.CityStatePostalCodeID
        LEFT JOIN Base.State s ON s.state = cspc.state
        INNER JOIN Base.Address a ON ppo.AddressID = a.AddressID
        INNER JOIN CTE_Temp_Provider p ON ppo.ProviderID = p.ProviderID
    WHERE
        ppo.Latitude <> 0
        AND ppo.Longitude <> 0
    GROUP BY
        ppo.ProviderID,
        ppo.PracticeID,
        ppo.OfficeCode,
        ppo.OfficeName,
        ppo.IsPrimaryOffice,
        ppo.ProviderOfficeRank,
        ppo.AddressTypeCode,
        ppo.AddressCode,
        ppo.AddressLine1,
        ppo.AddressLine2,
        ppo.AddressLine3,
        ppo.AddressLine4,
        ppo.City,
        ppo.State,
        ppo.ZipCode,
        ppo.Latitude,
        ppo.Longitude,
        a.TimeZone,
        ppo.HasBillingStaff,
        ppo.HasHandicapAccess,
        ppo.HasLabServicesOnSite,
        ppo.HasPharmacyOnSite,
        ppo.HasXrayOnSite,
        ppo.IsSurgeryCenter,
        ppo.HasSurgeryOnSite,
        ppo.AverageDailyPatientVolume,
        ppo.OfficeCoordinatorName,
        ppo.ParkingInformation,
        ppo.PaymentPolicy,
        ppo.LegacyKeyOffice,
        ppo.OfficeID,
        s.StateName,
        cspc.State,
        cspc.City,
        pr.PracticeName,
        pr.LegacyKeyOffice,
        pr.OfficeCode,
        a.AddressLine1,
        a.Suite
    ORDER BY
        ppo.ProviderOfficeRank
),
CTE_ProviderPracticeOffice AS (
    SELECT
        p.ProviderID,
        ppo.PracticeID AS prGUID,
        ppo.PracticeCode AS prID,
        ppo.PracticeName AS prNm,
        ppo.YearPracticeEstablished AS yrEst,
        ppo.PracticeNPI AS prNpi,
        ppo.PracticeWebsite AS prUrl,
        ppo.PracticeDescription AS prD,
        ppo.PracticeLogo AS prLgo,
        ppo.PracticeMedicalDirector AS medDir,
        ppo.PracticeSoftware AS prSft,
        ppo.PracticeTIN AS prTin,
        ppo.LegacyKeyPractice AS pLegacyID,
        ppo.PhysicianCount AS pProvCnt,
    FROM
        Mid.ProviderPracticeOffice AS ppo
        INNER JOIN Base.Provider p ON p.ProviderId = ppo.ProviderId
        LEFT JOIN Mid.ProviderSponsorship ps ON p.ProviderCode = ps.ProviderCode
        AND ppo.PracticeCode = ps.PracticeCode
        AND ps.ProductCode IN (
            SELECT
                ProductCode
            FROM
                Base.Product
            WHERE
                ProductTypeCode = 'PRACTICE'
        )
    WHERE
        ppo.Latitude <> 0
        AND ppo.Longitude <> 0
        AND CAST(ppo.Latitude AS VARCHAR) <> '0.000000'
        AND CAST(ppo.Longitude AS VARCHAR) <> '0.000000'
),
CTE_PracticeOfficeBaseXML AS (
    SELECT
        cte_pob.ProviderID,
        iff(cte_pob.oGUID is not null,'<oGUID>' || cte_pob.oGUID || '</oGUID>','') ||
iff(cte_pob.oID is not null,'<oID>' || cte_pob.oID || '</oID>','') ||
iff(cte_pob.oNm is not null,'<oNm>' || cte_pob.oNm || '</oNm>','') ||
iff(cte_pob.prmryO is not null,'<prmryO>' || cte_pob.prmryO || '</prmryO>','') ||
iff(cte_pob.oRank is not null,'<oRank>' || cte_pob.oRank || '</oRank>','') ||
iff(cte_pob.addCd is not null,'<addCd>' || cte_pob.addCd || '</addCd>','') ||
iff(cte_pob.city is not null,'<city>' || cte_pob.city || '</city>','') ||
iff(cte_pob.st is not null,'<st>' || cte_pob.st || '</st>','') ||
iff(cte_pob.zip is not null,'<zip>' || cte_pob.zip || '</zip>','') ||
iff(cte_pob.lat is not null,'<lat>' || cte_pob.lat || '</lat>','') ||
iff(cte_pob.lng is not null,'<lng>' || cte_pob.lng || '</lng>','') ||
iff(cte_pob.tzn is not null,'<tzn>' || cte_pob.tzn || '</tzn>','') ||
iff(cte_pob.isBStf is not null,'<isBStf>' || cte_pob.isBStf || '</isBStf>','') ||
iff(cte_pob.isHcap is not null,'<isHcap>' || cte_pob.isHcap || '</isHcap>','') ||
iff(cte_pob.isLab is not null,'<isLab>' || cte_pob.isLab || '</isLab>','') ||
iff(cte_pob.isPhrm is not null,'<isPhrm>' || cte_pob.isPhrm || '</isPhrm>','') ||
iff(cte_pob.isXray is not null,'<isXray>' || cte_pob.isXray || '</isXray>','') ||
iff(cte_pob.isSrg is not null,'<isSrg>' || cte_pob.isSrg || '</isSrg>','') ||
iff(cte_pob.hasSrg is not null,'<hasSrg>' || cte_pob.hasSrg || '</hasSrg>','') ||
iff(cte_pob.avVol is not null,'<avVol>' || cte_pob.avVol || '</avVol>','') ||
iff(cte_pob.ocNm is not null,'<ocNm>' || cte_pob.ocNm || '</ocNm>','') ||
iff(cte_pob.prkInf is not null,'<prkInf>' || cte_pob.prkInf || '</prkInf>','') ||
iff(cte_pob.payPol is not null,'<payPol>' || cte_pob.payPol || '</payPol>','') ||
iff(cte_pob.ast is not null,'<ast>' || cte_pob.ast || '</ast>','') ||
iff(cte_pob.ste is not null,'<ste>' || cte_pob.ste || '</ste>','') ||
 AS XMLValue
    FROM
        CTE_PracticeOfficeBase cte_pob
    GROUP BY
        cte_pob.ProviderID
),
CTE_PracticeOfficeHoursBaseXML AS (
    SELECT
        cte_pohb.ProviderID,
        iff(cte_pohb._day is not null,'<day>' || cte_pohb._day || '</day>','') ||
iff(cte_pohb.dispOrder is not null,'<dispOrder>' || cte_pohb.dispOrder || '</dispOrder>','') ||
iff(cte_pohb._start is not null,'<start>' || cte_pohb._start || '</start>','') ||
iff(cte_pohb._end is not null,'<end>' || cte_pohb._end || '</end>','') ||
iff(cte_pohb.closed is not null,'<closed>' || cte_pohb.closed || '</closed>','') ||
 AS XMLValue
    FROM
        CTE_PracticeOfficeHoursBase cte_pohb
    GROUP BY
        cte_pohb.ProviderID
),
CTE_PracticeOfficephFullBaseXML AS (
    SELECT
        cte_pophfb.ProviderID,
        iff(cte_pophfb.phFull is not null,'<phFull>' || cte_pophfb.phFull || '</phFull>','') ||
 AS XMLValue
    FROM
        CTE_PracticeOfficephFullBase cte_pophfb
    GROUP BY
        cte_pophfb.ProviderID
),
CTE_PracticeOfficefaxFullBaseXML AS (
    SELECT
        cte_poffb.ProviderID,
        iff(cte_poffb.faxFull is not null,'<faxFull>' || cte_poffb.faxFull || '</faxFull>','') ||
 AS XMLValue
    FROM
        CTE_PracticeOfficefaxFullBase cte_poffb
    GROUP BY
        cte_poffb.ProviderID
),
CTE_PracticeUrlXML AS (
    SELECT
        cte_pob.ProviderID,
        iff(cte_pob.pracUrl is not null,'<pracUrl>' || cte_pob.pracUrl || '</pracUrl>','') ||
 AS XMLValue
    FROM
        CTE_PracticeOfficeBase cte_pob
    GROUP BY
        cte_pob.ProviderID
),
CTE_ProviderPracticeOfficeXML AS (
    SELECT
        cte_ppo.ProviderID,
        iff(cte_ppo.prGUID is not null,'<prGUID>' || cte_ppo.prGUID || '</prGUID>','') ||
iff(cte_ppo.prID is not null,'<prID>' || cte_ppo.prID || '</prID>','') ||
iff(cte_ppo.prNm is not null,'<prNm>' || cte_ppo.prNm || '</prNm>','') ||
iff(cte_ppo.yrEst is not null,'<yrEst>' || cte_ppo.yrEst || '</yrEst>','') ||
iff(cte_ppo.prNpi is not null,'<prNpi>' || cte_ppo.prNpi || '</prNpi>','') ||
iff(REPLACE is not null,'<prUrl>' || REPLACE || '</prUrl>','') ||
iff(cte_ppo.prD is not null,'<prD>' || cte_ppo.prD || '</prD>','') ||
iff(cte_ppo.prLgo is not null,'<prLgo>' || cte_ppo.prLgo || '</prLgo>','') ||
iff(cte_ppo.medDir is not null,'<medDir>' || cte_ppo.medDir || '</medDir>','') ||
iff(cte_ppo.prSft is not null,'<prSft>' || cte_ppo.prSft || '</prSft>','') ||
iff(cte_ppo.prTin is not null,'<prTin>' || cte_ppo.prTin || '</prTin>','') ||
iff(cte_ppo.pLegacyID is not null,'<pLegacyID>' || cte_ppo.pLegacyID || '</pLegacyID>','') ||
 AS XMLValue
    FROM
        CTE_ProviderPracticeOffice cte_ppo
    GROUP BY
        cte_ppo.ProviderID
),
CTE_PracticeOfficeXML AS (
    SELECT
        pob.ProviderID,
        '<poffL>' || '<poff>' || ppo.XMLValue || '<offL>' || '<off>' || pohb.XMLValue || pofb.XMLValue || poffb.XMLValue || purl.XMLValue || '</off>' || '</offL>' || '</poff>' || '</poffL>' AS CombinedXML
    FROM
        CTE_PracticeOfficeBaseXML pob
        INNER JOIN CTE_PracticeOfficeHoursBaseXML pohb ON pob.ProviderID = pohb.ProviderID
        INNER JOIN CTE_PracticeOfficephFullBaseXML pofb ON pob.ProviderId = pofb.ProviderID
        INNER JOIN CTE_PracticeOfficefaxFullBaseXML poffb ON pob.ProviderId = poffb.ProviderID
        INNER JOIN CTE_PracticeUrlXML purl ON pob.ProviderId = purl.ProviderID
        INNER JOIN CTE_ProviderPracticeOfficeXML ppo ON pob.ProviderId = ppo.ProviderID
),
------------------------AddressXML------------------------
CTE_Address AS (
    SELECT
        DISTINCT ppo.ProviderID AS ProviderID,
        ppo.AddressCode AS addCd,
        ppo.AddressLine1 AS ad1,
        ppo.AddressLine2 AS ad2,
        ppo.AddressLine3 AS ad3,
        ppo.AddressLine4 AS ad4,
        ppo.City AS city,
        ppo.State AS st,
        ppo.ZipCode AS zip,
        ppo.Latitude AS lat,
        ppo.Longitude AS lng,
        a.TimeZone AS tzn,
        ppo.AddressTypeCode AS addTp,
        ppo.OfficeCode AS offCd,
        ppo.OfficeID AS oGUID,
        ppo.ProviderOfficeRank AS oRank,
        ppo.FullPhone AS phFull
    FROM
        Show.SOLRProvider s
        INNER JOIN Mid.ProviderPracticeOffice ppo on s.ProviderID = ppo.ProviderID
        INNER JOIN Base.Address a ON a.AddressID = ppo.AddressID
        INNER JOIN CTE_Temp_Provider p ON s.ProviderID = p.ProviderID
),
CTE_AddressXML AS (
    SELECT
        cte_a.ProviderID,
        '<addrL>' || '<addr>' || iff(cte_a.addCd is not null,'<addCd>' || cte_a.addCd || '</addCd>','') ||
iff(cte_a.city is not null,'<city>' || cte_a.city || '</city>','') ||
iff(cte_a.st is not null,'<st>' || cte_a.st || '</st>','') ||
iff(cte_a.zip is not null,'<zip>' || cte_a.zip || '</zip>','') ||
iff(cte_a.lat is not null,'<lat>' || cte_a.lat || '</lat>','') ||
iff(cte_a.lng is not null,'<lng>' || cte_a.lng || '</lng>','') ||
iff(cte_a.tzn is not null,'<tzn>' || cte_a.tzn || '</tzn>','') ||
iff(cte_a.addTp is not null,'<addTp>' || cte_a.addTp || '</addTp>','') ||
iff(cte_a.offCd is not null,'<offCd>' || cte_a.offCd || '</offCd>','') ||
iff(cte_a.oGUID is not null,'<oGUID>' || cte_a.oGUID || '</oGUID>','') ||
iff(cte_a.oRank is not null,'<oRank>' || cte_a.oRank || '</oRank>','') ||
 || '<phL>' || '<phFull>' || IFF(cte_a.phFull IS NOT NULL, cte_a.phFull, '') || '</phFull>' || '</phL>' || '<addr>' || '</addrL>' AS XMLValue
    FROM
        CTE_Address cte_a
    GROUP BY
        cte_a.ProviderID,
        cte_a.phFull
),
------------------------SpecialtyXML------------------------
CTE_Y AS (
    SELECT
        p.ProviderID,
        d.SpecialtyGroupCode,
        a.SpecialtyRankCalculated,
        c.SpecialtyGroupRank,
        d.SpecialtyGroupDescription,
        d.SpecialistGroupDescription,
        d.SpecialistsGroupDescription,
        a.IsSearchableCalculated,
        a.SearchBoostExperience,
        a.SearchBoostHospitalCohortQuality,
        a.SearchBoostHospitalServiceLineQuality,
        d.LegacyKey,
        ROW_NUMBER() OVER (
            PARTITION BY d.SpecialtyGroupCode
            ORDER BY
                c.SpecialtyGroupRank,
                CASE
                    WHEN a.IsSearchableCalculated = 1 THEN 0
                    ELSE 1
                END,
                a.SpecialtyRankCalculated
        ) AS SpecialtyGroupCodeRank,
        a.SpecialtyID
    FROM
        Base.ProviderToSpecialty AS a
        INNER JOIN Base.SpecialtyGroupToSpecialty AS c ON c.SpecialtyID = a.SpecialtyID
        INNER JOIN Base.SpecialtyGroup AS d ON d.SpecialtyGroupID = c.SpecialtyGroupID
        INNER JOIN CTE_Temp_Provider p ON a.ProviderID = p.ProviderID
),
CTE_X AS (
    SELECT
        ProviderID,
        SpecialtyGroupCode,
        SpecialtyRankCalculated,
        SpecialtyGroupRank,
        SpecialtyGroupDescription,
        SpecialistGroupDescription,
        SpecialistsGroupDescription,
        IsSearchableCalculated,
        SearchBoostExperience,
        SearchBoostHospitalCohortQuality,
        SearchBoostHospitalServiceLineQuality,
        LegacyKey,
        ROW_NUMBER() OVER (
            ORDER BY
                SpecialtyRankCalculated,
                SpecialtyGroupRank
        ) AS spRank,
        SpecialtyID
    FROM
        CTE_Y
    WHERE
        SpecialtyGroupCodeRank = 1
),
--- left join
CTE_W AS (
    SELECT
        e.MedicalTermCode,
        RTRIM(LTRIM(h.ProviderTypeCode)) AS ProviderTypeCode
    FROM
        Base.MedicalTerm AS e
        INNER JOIN Base.ProviderTypeToMedicalTerm g ON g.MedicalTermID = e.MedicalTermID
        INNER JOIN Base.ProviderType h ON h.ProviderTypeID = g.ProviderTypeID
),
CTE_Specialty AS (
    SELECT
        s.ProviderID,
        cte_y.SpecialtyGroupCode AS spCd,
        cte_y.SpecialtyRankCalculated AS spRank,
        cte_y.SpecialtyGroupDescription AS spY,
        cte_y.SpecialistGroupDescription AS spIst,
        cte_y.SpecialistsGroupDescription AS spIsts,
        cte_y.IsSearchableCalculated AS srch,
        cte_y.SearchBoostExperience as boostExp,
        CASE
            WHEN cte_y.SearchBoostHospitalCohortQuality IS NOT NULL THEN cte_y.SearchBoostHospitalCohortQuality
            ELSE cte_y.SearchBoostHospitalServiceLineQuality
        END AS boostQual,
        CASE
            WHEN spRank = 1 THEN 1
            ELSE 0
        END AS prm,
        CASE
            WHEN cte_w.ProviderTypeCode IS NULL THEN 'ALT'
            ELSE cte_w.ProviderTypeCode
        END AS prvTypCd,
        (
            SELECT
                DISTINCT z.ServiceLineCode
        ) AS svcCd,
        cte_y.LegacyKey
    FROM
        Show.SOLRProvider s
        INNER JOIN CTE_y ON s.ProviderID = cte_y.ProviderID
        LEFT JOIN CTE_w ON cte_w.MedicalTermCode = cte_y.SpecialtyGroupCode
        LEFT JOIN Base.TempSpecialtyToServiceLineGhetto z ON z.SpecialtyCode = cte_y.SpecialtyGroupCode
    ORDER BY
        z.ServiceLineCode
),
CTE_SpecialtyXML AS (
    SELECT
        cte_s.ProviderID,
        '<spcL>' || '<spc>' || iff(cte_s.spCd is not null,'<spCd>' || cte_s.spCd || '</spCd>','') ||
iff(cte_s.spRank is not null,'<spRank>' || cte_s.spRank || '</spRank>','') ||
iff(cte_s.spY is not null,'<spY>' || cte_s.spY || '</spY>','') ||
iff(cte_s.spIst is not null,'<spIst>' || cte_s.spIst || '</spIst>','') ||
iff(cte_s.spIsts is not null,'<spIsts>' || cte_s.spIsts || '</spIsts>','') ||
iff(cte_s.srch is not null,'<srch>' || cte_s.srch || '</srch>','') ||
iff(cte_s.boostQual is not null,'<boostQual>' || cte_s.boostQual || '</boostQual>','') ||
iff(cte_s.prm is not null,'<prm>' || cte_s.prm || '</prm>','') ||
iff(cte_s.prvTypCd is not null,'<prvTypCd>' || cte_s.prvTypCd || '</prvTypCd>','') ||
 || iff(cte_s.svcCd is not null,'<svcCd>' || cte_s.svcCd || '</svcCd>','') ||
 || IFF(
            cte_s.LegacyKey IS NOT NULL,
            '<lKey>' || cte_s.LegacyKey || '</lkey>',
            ''
        ) || '<spc>' || '<spcL>' AS XMLValue
    FROM
        CTE_Specialty cte_s
    GROUP BY
        cte_s.ProviderID,
        cte_s.LegacyKey
),
------------------------PracticingSpecialtyXML------------------------

cte_hg_choice as (
    SELECT 
        P.ProviderID, 
        Sp.SpecialtyID, 
        Sp.SpecialtyCode
    FROM Show.SOLRProvider P
    INNER JOIN Base.ProviderToSpecialty PS ON PS.ProviderID = P.ProviderID
    INNER JOIN Base.Specialty Sp ON Sp.SpecialtyID = PS.SpecialtyID
    -- INNER JOIN Base.ProviderSpecialtyZScore Z ON Z.ProviderID = PS.ProviderId AND Z.SpecialtyID = PS.SpecialtyID AND Z.AvgWeightedZscore > -1.645
    WHERE P.ProviderTypeGroup = 'DOC'
    AND P.DisplayStatusCode = 'A'
    AND Sp.SpecialtyCode IN ('PS780','PS962','PS863','PS324','PS534','PS574','PS645','PS127','PS548','PS1081')
    AND P.ProviderID NOT IN (SELECT ProviderID FROM Base.ProviderToSubStatus WHERE SubStatusID IN (SELECT SubStatusID FROM Base.SubStatus WHERE SubStatusCode IN ('B', 'L', 'L5')))
    AND P.ProviderID NOT IN (SELECT ProviderID FROM Base.NoIndexNoFollow)
    AND P.AcceptsNewPatients != 0
    AND (COALESCE(P.PatientExperienceSurveyOverallCount,0) >= 10 AND COALESCE(P.PatientExperienceSurveyOverallScore,0) >= 70)
    AND NOT EXISTS (SELECT 1 FROM Base.ProviderMalpractice pm WHERE pm.ProviderID = P.ProviderID)
    AND NOT EXISTS (SELECT 1 FROM Base.ProviderSanction psa WHERE psa.ProviderID = P.ProviderId) 
),

cte_patient_fav as (
    SELECT
        Providerid,
        providercode
    FROM 
        Show.SolrProvider
    WHERE patientexperiencesurveyoverallstarvalue >= 4.0
),

cte_specialty_score_with_boost as (
    SELECT		
        lPtS.ProviderId, 
        lPtS.SpecialtyID,
        TRY_CAST(lPtS.ProviderRawSpecialtyScore AS NUMERIC) AS SpecialtyScoreWithBoost,
		CASE WHEN H.ProviderID IS NOT NULL THEN 1 ELSE 0 END AS hgChoice
    FROM show.solrProvider P
    INNER JOIN Base.ProviderToSpecialty lPtS ON lPtS.ProviderID = P.ProviderID
    LEFT JOIN cte_HG_Choice H ON H.ProviderID = lPtS.ProviderID AND H.SpecialtyID = lPtS.SpecialtyID
),

cte_map_spc as (
    SELECT
        sg.specialtygroupid,
        sp.SpecialtyCode AS mapPracSpcCd,
        -- trim(sp.SpecialtyDescription) AS mapPracSpcDesc,
        'Athletic Training' as mappracspcdesc,
        sg.SpecialtyGroupRank
    FROM
        Base.Specialty sp
        JOIN Base.SpecialtyGroupToSpecialty sg 
            ON sp.SpecialtyID = sg.SpecialtyID
            AND sg.SpecialtyIsRedundant = 1
    ORDER BY
        specialtygrouprank
    LIMIT 1 
)
,

cte_map_spc_xml as (
    SELECT DISTINCT
        specialtygroupid,
        '<mapSpc>' || 
            '<mapPracSpcCd>' || mappracspccd  || '</mapPracSpcCd>' ||
            '<mapPracSpcDesc>' || mapPracSpcDesc  || '</mapPracSpcDesc>' ||
            '<SpecialtyGroupRank>' || SpecialtyGroupRank  || '</SpecialtyGroupRank>' ||
        '</mapSpc>' AS XMLValue
    FROM
        cte_map_spc
        
),

cte_spcg as (
    SELECT
        c.SpecialtyID,
        d.SpecialtyGroupCode AS spGCd,
        d.SpecialtyGroupDescription AS spGY,
        ROW_NUMBER() OVER (ORDER BY c.SpecialtyGroupRank) AS spGRank,
        d.LegacyKey AS glKey,
        map.xmlvalue as mapspc
    FROM
        Base.SpecialtyGroupToSpecialty AS c
        JOIN Base.SpecialtyGroup AS d ON d.SpecialtyGroupID = c.SpecialtyGroupID
        JOIN cte_map_spc_xml as map on map.specialtygroupid = c.specialtygroupid
    ORDER BY 
        IFNULL(c.SpecialtyGroupRank, 2147483647),
		d.SpecialtyGroupCode
),

cte_spcg_xml as (
    SELECT
        SpecialtyID,
        '<spcG>' ||  iff(spGCd is not null,'<spGCd>' || spGCd || '</spGCd>','') ||
iff(spGY is not null,'<spGY>' || spGY || '</spGY>','') ||
iff(spGRank is not null,'<spGRank>' || spGRank || '</spGRank>','') ||
iff(glKey is not null,'<glKey>' || glKey || '</glKey>','') ||
 || mapspc
        
        || '<\spcG>'
        
        AS XMLValue
    FROM
        cte_spcg
    GROUP BY
        SpecialtyID,
        mapspc
),


cte_practicing_specialty as (
    SELECT
        a.providerid,
        b.SpecialtyCode AS spCd,
		ROW_NUMBER()OVER (ORDER BY a.SpecialtyRankCalculated) AS spRank,
		b.SpecialtyDescription AS spY,
		b.SpecialistDescription AS spIst,
		b.SpecialistsDescription AS spIsts,
		a.IsSearchableCalculated AS srch,
		SEC.hgChoice,
		a.SearchBoostExperience as boostExp,
        CASE WHEN s.IsPatientFavorite = 1 and a.SpecialtyRankCalculated = 1 and PF.ProviderID IS NOT NULL THEN 1 ELSE 0 END AS PatientFav,
		CASE WHEN a.SearchBoostHospitalCohortQuality IS NOT NULL THEN a.SearchBoostHospitalCohortQuality ELSE a.SearchBoostHospitalServiceLineQuality END AS boostQual,
        spcg.xmlvalue as spcgl,
        b.LegacyKey AS lKey
    FROM Base.ProviderToSpecialty AS a
    LEFT JOIN	cte_Patient_Fav PF ON PF.ProviderID = A.ProviderID
    INNER JOIN	Base.Specialty AS b ON b.SpecialtyID = a.SpecialtyID
    LEFT JOIN	Base.ProviderToProviderType AS e ON e.ProviderID = a.ProviderID AND e.ProviderTypeRank = 1
    LEFT JOIN	Base.ProviderTypeToSpecialty AS f ON f.ProviderTypeID = e.ProviderTypeID AND f.SpecialtyID = a.SpecialtyID
    LEFT JOIN	cte_specialty_score_with_boost SEC ON SEC.Specialtyid = a.Specialtyid AND SEC.ProviderId = a.ProviderID
    -- LEFT JOIN	ProfiseeKube.data.trefSpecialty AS g ON g.refSpecialtyCode = b.SpecialtyCode
    JOIN cte_spcg_xml as spcg on spcg.specialtyid = b.specialtyid
    JOIN Base.provider as s on s.providerid = a.providerid
    WHERE a.SpecialtyIsRedundant = 0
    ORDER BY	
        IFNULL(a.SpecialtyRankCalculated, 2147483647),
		b.SpecialtyCode
),

cte_practicing_specialty_xml as (
    SELECT
        providerid,
        iff(spcd is not null,'<spcd>' || spcd || '</spcd>','') ||
iff(spRank is not null,'<spRank>' || spRank || '</spRank>','') ||
iff(spY is not null,'<spY>' || spY || '</spY>','') ||
iff(spIst is not null,'<spIst>' || spIst || '</spIst>','') ||
iff(spIsts is not null,'<spIsts>' || spIsts || '</spIsts>','') ||
iff(srch is not null,'<srch>' || srch || '</srch>','') ||
iff(hgChoice is not null,'<hgChoice>' || hgChoice || '</hgChoice>','') ||
iff(boostExp is not null,'<boostExp>' || boostExp || '</boostExp>','') ||
iff(PatientFav is not null,'<PatientFav>' || PatientFav || '</PatientFav>','') ||
iff(boostQual is not null,'<boostQual>' || boostQual || '</boostQual>','') ||
iff(spcgl is not null,'<spcgl>' || spcgl || '</spcgl>','') ||
iff(lKey is not null,'<lKey>' || lKey || '</lKey>','') ||
 AS XMLValue
    FROM
        cte_practicing_specialty
    GROUP BY
        providerid
)
,

-------------------------CertificationXML-------------------------
CTE_Certification AS (
    SELECT
        DISTINCT cs.CertificationSpecialtyCode AS cSpCd,
        ptcs.CertificationSpecialtyRank AS cSpRank,
        cs.CertificationSpecialtyDescription AS cSpY,
        ptcs.IsSearchable AS cSrch,
        ca.CertificationAgencyCode AS caCd,
        ca.CertificationAgencyDescription AS caD,
        cb.CertificationBoardCode AS cbCd,
        cb.CertificationBoardDescription AS cbD,
        cst.CertificationStatusCode AS csCd,
        cst.CertificationStatusDescription AS csD,
        mocl.MOCType AS mTyp,
        mocl.MOCLevelCode AS mLvC,
        mocl.MOCLevelDescription AS mLvD,
        mocp.MOCPathwayNumber AS mPwNo,
        mocp.MOCPathwaycode AS mPwCd,
        mocp.MOCPathwayName AS mPwNm,
        mocp.MOCPathwayBoardMessage AS mPwMsg,
        ptcs.CertificationStatusDate AS csDt,
        CASE
            WHEN ptcs.CertificationEffectiveDate IS NOT NULL
            AND ca.CertificationAgencyCode = 'ABMS' THEN NULL
            ELSE ptcs.CertificationEffectiveDate
        END AS ceffDt,
        CASE
            WHEN ptcs.CertificationExpirationDate IS NOT NULL THEN NULL
            ELSE ptcs.CertificationExpirationDate
        END AS ceExDt,
        IFNULL(ptcs.CertificationSpecialtyRank, 2147483647) AS TempDistinctSort1,
        cs.CertificationSpecialtyCode AS TempDistinctSort2,
        p.ProviderId,
        CASE
            WHEN ptcs.CertificationAgencyVerified = 1 THEN ca.CertificationAgencyCode
            ELSE 'SELF'
        END AS caVeri
    FROM
        Base.ProviderToCertificationSpecialty AS ptcs
        INNER JOIN CTE_Temp_Provider tp ON tp.ProviderID = ptcs.ProviderID
        INNER JOIN Show.SOLRProvider p ON p.ProviderID = ptcs.ProviderID
        INNER JOIN Base.CertificationSpecialty AS cs ON cs.CertificationSpecialtyID = ptcs.CertificationSpecialtyID
        INNER JOIN Base.CertificationAgency AS ca ON ca.CertificationAgencyID = ptcs.CertificationAgencyID
        INNER JOIN Base.CertificationBoard AS cb ON cb.CertificationBoardID = ptcs.CertificationBoardID
        INNER JOIN Base.CertificationStatus AS cst ON cst.CertificationStatusID = ptcs.CertificationStatusID
        LEFT JOIN Base.MOCLevel mocl ON ptcs.MOCLevelID = mocl.MOCLevelID
        LEFT JOIN Base.MOCPathway mocp ON ptcs.MOCPathwayID = mocp.MOCPathwayID
    WHERE
        cst.IndicatesNotCertified = 0
    ORDER BY
        IFNULL(ptcs.CertificationSpecialtyRank, 2147483647),
        cs.CertificationSpecialtyCode,
        TempDistinctSort1,
        TempDistinctSort2
),
CTE_CertificationXML AS (
    SELECT
        cte_c.ProviderID,
        iff(cte_c.cSpCd is not null,'<cSpCd>' || cte_c.cSpCd || '</cSpCd>','') ||
iff(cte_c.cSpRank is not null,'<cSpRank>' || cte_c.cSpRank || '</cSpRank>','') ||
iff(cte_c.cSpY is not null,'<cSpY>' || cte_c.cSpY || '</cSpY>','') ||
iff(cte_c.cSrch is not null,'<cSrch>' || cte_c.cSrch || '</cSrch>','') ||
iff(cte_c.caCd is not null,'<caCd>' || cte_c.caCd || '</caCd>','') ||
iff(cte_c.caD is not null,'<caD>' || cte_c.caD || '</caD>','') ||
iff(cte_c.cbCd is not null,'<cbCd>' || cte_c.cbCd || '</cbCd>','') ||
iff(cte_c.cbD is not null,'<cbD>' || cte_c.cbD || '</cbD>','') ||
iff(cte_c.csCd is not null,'<csCd>' || cte_c.csCd || '</csCd>','') ||
iff(cte_c.csD is not null,'<csD>' || cte_c.csD || '</csD>','') ||
iff(cte_c.mTyp is not null,'<mTyp>' || cte_c.mTyp || '</mTyp>','') ||
iff(cte_c.mLvC is not null,'<mLvC>' || cte_c.mLvC || '</mLvC>','') ||
iff(cte_c.mLvD is not null,'<mLvD>' || cte_c.mLvD || '</mLvD>','') ||
iff(cte_c.mPwNo is not null,'<mPwNo>' || cte_c.mPwNo || '</mPwNo>','') ||
iff(cte_c.mPwCd is not null,'<mPwCd>' || cte_c.mPwCd || '</mPwCd>','') ||
iff(cte_c.mPwNm is not null,'<mPwNm>' || cte_c.mPwNm || '</mPwNm>','') ||
iff(cte_c.mPwMsg is not null,'<mPwMsg>' || cte_c.mPwMsg || '</mPwMsg>','') ||
iff(cte_c.csDt is not null,'<csDt>' || cte_c.csDt || '</csDt>','') ||
iff(cte_c.ceffDt is not null,'<ceffDt>' || cte_c.ceffDt || '</ceffDt>','') ||
iff(cte_c.ceExDt is not null,'<ceExDt>' || cte_c.ceExDt || '</ceExDt>','') ||
 AS XMLValue
    FROM
        CTE_Certification cte_c
    GROUP BY
        cte_c.ProviderID
),
------------------------EducationXML------------------------
CTE_ProviderEducation AS (
    SELECT
        pe.ProviderID,
        pe.EducationInstitutionTypeDescription,
        pe.EducationInstitutionTypeCode
    FROM
        Mid.ProviderEducation pe
),
CTE_subquery AS (
    SELECT
        pe.ProviderID,
        pe.EducationInstitutionName AS edNm,
        CASE
            WHEN TRY_CAST(pe.GraduationYear AS INT) = 0 THEN NULL
            ELSE TRY_CAST(pe.GraduationYear AS INT)
        END AS yr,
        pe.PositionHeld AS posH,
        pe.DegreeAbbreviation AS deg,
        pe.City AS city,
        pe.State AS st,
        pe.NationName AS natn,
        cte_pe.EducationInstitutionTypeCode AS edTypC
    FROM
        CTE_ProviderEducation cte_pe
        JOIN Mid.ProviderEducation pe ON pe.ProviderID = cte_pe.ProviderID
        AND pe.EducationInstitutionTypeCode = cte_pe.EducationInstitutionTypeCode -- ORDER BY pe.EducationInstitutionName
),
CTE_Education AS (
    SELECT
        cte_pe.ProviderId,
        edTypC,
        edNm,
        yr,
        posH,
        deg,
        city,
        st,
        natn,
        cte_pe.EducationInstitutionTypeDescription
    FROM
        CTE_ProviderEducation cte_pe
        INNER JOIN Show.SOLRProvider s ON s.ProviderID = cte_pe.ProviderID -- INNER JOIN CTE_Temp_Provider p ON p.ProviderID = cte_pe.ProviderID
        INNER JOIN CTE_subquery cte_sq ON cte_sq.ProviderID = cte_pe.ProviderID
        AND cte_sq.edTypC = cte_pe.EducationInstitutionTypeCode
    GROUP BY
        cte_pe.ProviderID,
        cte_pe.EducationInstitutionTypeDescription,
        cte_pe.EducationInstitutionTypeCode,
        edTypC,
        edNm,
        yr,
        posH,
        deg,
        city,
        st,
        natn -- ORDER BY cte_pe.EducationInstitutionTypeDescription
),
CTE_XML AS (
    SELECT
        cte_e.ProviderID,
        '<edTypC>' || cte_e.edTypc || '</edTypC>' || iff(cte_e.edNm is not null,'<edNm>' || cte_e.edNm || '</edNm>','') ||
iff(cte_e.yr is not null,'<yr>' || cte_e.yr || '</yr>','') ||
iff(cte_e.posH is not null,'<posH>' || cte_e.posH || '</posH>','') ||
iff(cte_e.deg is not null,'<deg>' || cte_e.deg || '</deg>','') ||
iff(cte_e.city is not null,'<city>' || cte_e.city || '</city>','') ||
iff(cte_e.natn is not null,'<natn>' || cte_e.natn || '</natn>','') ||
 AS XMLs,
    FROM
        CTE_Education cte_e
    GROUP BY
        cte_e.ProviderID,
        cte_e.edTypc
),
CTE_EducationXML AS (
    SELECT
        ProviderID,
        LISTAGG(XMLs, '') AS XMLValue
    FROM
        CTE_XML
    GROUP BY
        ProviderID
),
------------------------AdXML------------------------
--------- this one is empty in SQL Server -----------
CTE_Ad AS (
    SELECT
        'prescription' AS adCat,
        'decile' AS adTp,
        pn.PrescriptionNTileCode AS adCd,
        nt.NTileTypeCode AS adGrp,
        'nrxCount' AS adValTp,
        ptpn.NTileValue AS adVal
    FROM
        Base.ProviderToPrescriptionNTile AS ptpn
        INNER JOIN Base.PrescriptionNTile AS pn ON pn.PrescriptionNTileID = ptpn.PrescriptionNTileID
        INNER JOIN Base.NTileType AS nt ON nt.NTileTypeID = ptpn.NTileTypeID
    UNION
    SELECT
        'HMSClaims' AS adCat,
        'decile' AS adTp,
        ConditionCode AS adCd,
        'Non-Specialist' AS adGrjp,
        'ClaimsCount' AS adValTp,
        Decile AS adVal
    FROM
        Base.ProviderToConditionAdTargeting ptpn
    UNION
    SELECT
        'HMSClaims' AS adCat,
        'decile' AS adTp,
        ProcedureMedicalCode AS adCd,
        'Non-Specialist' AS adGrjp,
        'ClaimsCount' AS adValTp,
        Decile AS adVal
    FROM
        Base.ProviderToProcedureMedicalAdTargeting ptpn
),
------------------------ProfessionalOrganizationXML------------------------
CTE_ProfessionalOrganization AS (
    SELECT
        pto.ProviderID,
        pto.OrganizationID,
        o.OrganizationCode AS porgCd,
        o.OrganizationDescription AS porgNm,
        o.refDefinition AS porgDesc,
        p.PositionCode AS porgPositCd,
        p.PositionDescription AS porgPositNm,
        pto.PositionRank AS posRk,
        pto.PositionStartDate AS posSt,
        pto.PositionEndDate AS posEnd
    FROM
        Base.ProviderToOrganization AS pto
        INNER JOIN Base.Organization AS o ON o.OrganizationID = pto.OrganizationID
        INNER JOIN Base.Position AS p ON p.PositionID = pto.PositionID
),
CTE_OrganizationImage AS (
    SELECT
        otip.OrganizationID,
        ip.ImagePathText AS porgImgU,
        ip.ImageWidth AS porgImgW,
        ip.ImageHeight AS porgImgH
    FROM
        Base.OrganizationToImagePath AS otip
        INNER JOIN Base.ImagePath AS ip ON ip.ImagePathID = otip.ImagePathID
),
CTE_ProfessionalOrganizationXML AS (
    SELECT
        cte_po.ProviderID,
        '<porgL>' || '<porg>' || iff(cte_po.porgCd is not null,'<porgCd>' || cte_po.porgCd || '</porgCd>','') ||
iff(cte_po.porgNm is not null,'<porgNm>' || cte_po.porgNm || '</porgNm>','') ||
iff(cte_po.porgDesc is not null,'<porgDesc>' || cte_po.porgDesc || '</porgDesc>','') ||
iff(cte_po.porgPositCd is not null,'<porgPositCd>' || cte_po.porgPositCd || '</porgPositCd>','') ||
iff(cte_po.porgPositNm is not null,'<porgPositNm>' || cte_po.porgPositNm || '</porgPositNm>','') ||
iff(cte_po.posRk is not null,'<posRk>' || cte_po.posRk || '</posRk>','') ||
iff(cte_po.posSt is not null,'<posSt>' || cte_po.posSt || '</posSt>','') ||
iff(cte_po.posEnd is not null,'<posEnd>' || cte_po.posEnd || '</posEnd>','') ||
 || iff(cte_oi.porgImgU is not null,'<porgImgU>' || cte_oi.porgImgU || '</porgImgU>','') ||
iff(cte_oi.porgImgW is not null,'<porgImgW>' || cte_oi.porgImgW || '</porgImgW>','') ||
iff(cte_oi.porgImgH is not null,'<porgImgH>' || cte_oi.porgImgH || '</porgImgH>','') ||
 || '<porg>' || '<porgL' AS XMLValue
    FROM
        CTE_ProfessionalOrganization cte_po
        INNER JOIN CTE_OrganizationImage cte_oi ON cte_oi.OrganizationID = cte_po.OrganizationID
    GROUP BY
        cte_po.ProviderID
),
------------------------LicenseXML------------------------
CTE_ProviderLicense AS (
    SELECT
        DISTINCT pl.ProviderID,
        pl.State AS licStAbr,
        pl.StateName AS licSt,
        pl.LicenseType AS licTp,
        pl.LicenseNumber AS licNr,
        pl.LicenseEffectiveDate AS licEfDt,
        pl.LicenseTerminationDate AS licTeDt
    FROM
        Mid.ProviderLicense AS pl ----- CHECK THIS LATER -----
        -- INNER JOIN CTE_Temp_Provider p ON p.ProviderID = pl.ProviderID
),
CTE_ProviderLicenseXML AS (
    SELECT
        cte_pl.ProviderID,
        iff(cte_pl.licStAbr is not null,'<licStAbr>' || cte_pl.licStAbr || '</licStAbr>','') ||
iff(cte_pl.licSt is not null,'<licSt>' || cte_pl.licSt || '</licSt>','') ||
iff(cte_pl.licTp is not null,'<licTp>' || cte_pl.licTp || '</licTp>','') ||
iff(cte_pl.licNr is not null,'<licNr>' || cte_pl.licNr || '</licNr>','') ||
iff(cte_pl.licEfDt is not null,'<licEfDt>' || cte_pl.licEfDt || '</licEfDt>','') ||
iff(cte_pl.licTeDt is not null,'<licTeDt>' || cte_pl.licTeDt || '</licTeDt>','') ||
 AS XMLValue
    FROM
        CTE_ProviderLicense cte_pl
    GROUP BY
        cte_pl.ProviderID,
        cte_pl.licStAbr,
        cte_pl.licSt,
        cte_pl.licTp,
        cte_pl.licNr,
        cte_pl.licEfDt,
        cte_pl.licTeDt
),
------------------------LanguageXML------------------------
CTE_Language AS (
    SELECT
        DISTINCT pl.ProviderID,
        pl.LanguageName AS langNm,
        l.LanguageCode AS langCd
    FROM
        Mid.ProviderLanguage AS pl
        INNER JOIN Base.Language l ON pl.LanguageName = l.LanguageName ----- CHECK THIS LATER -----
        -- INNER JOIN CTE_Temp_Provider p ON p.ProviderID = pl.ProviderID
),
CTE_LanguageXML AS (
    SELECT
        cte_l.ProviderID,
        iff(cte_l.langNm is not null,'<langNm>' || cte_l.langNm || '</langNm>','') ||
iff(cte_l.langCd is not null,'<langCd>' || cte_l.langCd || '</langCd>','') ||
 AS XMLValue
    FROM
        CTE_Language cte_l
    GROUP BY
        cte_l.ProviderID,
        cte_l.langNm,
        cte_l.langCd
),
------------------------MalpracticeXML------------------------
CTE_Malpractice AS (
    SELECT
        mp.ProviderID,
        mp.MalpracticeClaimTypeCode AS malC,
        mp.MalpracticeClaimTypeDescription AS malD,
        mp.ClaimNumber AS clNum,
        mp.ClaimDate AS clDt,
        mp.ClaimYear AS clYr,
        mp.ClaimAmount AS clAmt,
        mp.Complaint AS cmplt,
        mp.IncidentDate AS inDt,
        mp.ClosedDate AS endDt,
        mp.ClaimState AS malSt,
        mp.ClaimStateFull AS malStFl,
        mp.LicenseNumber AS LicNum,
        mp.ReportDate AS reDt
    FROM
        Mid.ProviderMalpractice mp
        INNER JOIN Base.MalpracticeState ms ON mp.ClaimState = ms.State
        AND IFNULL(ms.Active, 1) = 1 ----- CHECK THIS LATER -----
        -- INNER JOIN CTE_Temp_Provider p ON p.ProviderID = pl.ProviderID
),
CTE_MalpracticeXML AS (
    SELECT
        cte_mp.ProviderID,
        iff(cte_mp.malC is not null,'<malC>' || cte_mp.malC || '</malC>','') ||
iff(cte_mp.malD is not null,'<malD>' || cte_mp.malD || '</malD>','') ||
iff(cte_mp.clNum is not null,'<clNum>' || cte_mp.clNum || '</clNum>','') ||
iff(cte_mp.clDt is not null,'<clDt>' || cte_mp.clDt || '</clDt>','') ||
iff(cte_mp.clYr is not null,'<clYr>' || cte_mp.clYr || '</clYr>','') ||
iff(cte_mp.clAmt is not null,'<clAmt>' || cte_mp.clAmt || '</clAmt>','') ||
iff(cte_mp.cmplt is not null,'<cmplt>' || cte_mp.cmplt || '</cmplt>','') ||
iff(cte_mp.inDt is not null,'<inDt>' || cte_mp.inDt || '</inDt>','') ||
iff(cte_mp.endDt is not null,'<endDt>' || cte_mp.endDt || '</endDt>','') ||
iff(cte_mp.malSt is not null,'<malSt>' || cte_mp.malSt || '</malSt>','') ||
iff(cte_mp.malStFl is not null,'<malStFl>' || cte_mp.malStFl || '</malStFl>','') ||
iff(cte_mp.LicNum is not null,'<LicNum>' || cte_mp.LicNum || '</LicNum>','') ||
iff(cte_mp.reDt is not null,'<reDt>' || cte_mp.reDt || '</reDt>','') ||
 AS XMLValue
    FROM
        CTE_Malpractice cte_mp
    GROUP BY
        cte_mp.ProviderID
),
------------------------SanctionXML------------------------
CTE_ProviderSanction AS (
    SELECT
        ps.ProviderID,
        CASE
            WHEN ps.SanctionDescription LIKE 'hgpy%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%www.%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%HTTP%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%://%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%.gov%' THEN 'Please reference the following Document'
            ELSE ps.SanctionDescription
        END AS sancD,
        ps.SanctionDate AS sDt,
        ps.ReinstatementDate AS reinDt,
        ps.SanctionTypeCode AS sTyp,
        ps.SanctionTypeDescription AS sTypD,
        ps.State AS lSt,
        ps.SanctionCategoryCode AS sCat,
        ps.SanctionCategoryDescription AS sCatD,
        ps.SanctionActionCode AS sActC,
        ps.SanctionActionDescription AS sActD,
        CASE
            WHEN ps.SanctionDescription LIKE 'hgpy%' THEN 'https://www.healthgrades.com/media/english/pdf/sanctions/' || LTRIM(RTRIM(ps.SanctionDescription)) || '.pdf'
            WHEN ps.SanctionDescription LIKE '%www.%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            WHEN ps.SanctionDescription LIKE '%HTTP%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            WHEN ps.SanctionDescription LIKE '%://%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            WHEN ps.SanctionDescription LIKE '%.gov%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            ELSE ''
        END AS pdfUrl,
        ps.StateFull AS lStFl
    FROM
        Mid.ProviderSanction AS ps
),
CTE_ProviderSanctionXML AS (
    SELECT
        cte_ps.ProviderID,
        iff(cte_ps.sancD is not null,'<sancD>' || cte_ps.sancD || '</sancD>','') ||
iff(cte_ps.sDt is not null,'<sDt>' || cte_ps.sDt || '</sDt>','') ||
iff(cte_ps.reinDt is not null,'<reinDt>' || cte_ps.reinDt || '</reinDt>','') ||
iff(cte_ps.sTyp is not null,'<sTyp>' || cte_ps.sTyp || '</sTyp>','') ||
iff(cte_ps.sTypD is not null,'<sTypD>' || cte_ps.sTypD || '</sTypD>','') ||
iff(cte_ps.lSt is not null,'<lSt>' || cte_ps.lSt || '</lSt>','') ||
iff(cte_ps.sCat is not null,'<sCat>' || cte_ps.sCat || '</sCat>','') ||
iff(cte_ps.sCatD is not null,'<sCatD>' || cte_ps.sCatD || '</sCatD>','') ||
iff(cte_ps.sActC is not null,'<sActC>' || cte_ps.sActC || '</sActC>','') ||
iff(cte_ps.sActD is not null,'<sActD>' || cte_ps.sActD || '</sActD>','') ||
iff(cte_ps.pdfUrl is not null,'<pdfUrl>' || cte_ps.pdfUrl || '</pdfUrl>','') ||
iff(cte_ps.lStFl is not null,'<lStFl>' || cte_ps.lStFl || '</lStFl>','') ||
 AS XMLValue
    FROM
        CTE_ProviderSanction cte_ps
    GROUP BY
        cte_ps.ProviderID
),
------------------------BoardActionXML------------------------
CTE_BoardAction AS (
    SELECT
        ps.ProviderID,
        CASE
            WHEN ps.SanctionDescription LIKE 'hgpy%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%www.%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%HTTP%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%://%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%.gov%' THEN 'Please reference the following Document'
            ELSE ps.SanctionDescription
        END AS sancD,
        ps.SanctionDate AS sDt,
        ps.SanctionReinstatementDate AS reinDt,
        st.SanctionTypeCode AS sTyp,
        st.SanctionTypeDescription AS sTypD,
        sra.State AS lSt,
        sc.SanctionCategoryCode AS sCat,
        sc.SanctionCategoryDescription AS sCatD,
        sa.SanctionActionCode AS sActC,
        sa.SanctionActionDescription AS sActD,
        CASE
            WHEN ps.SanctionDescription LIKE 'hgpy%' THEN 'https://www.healthgrades.com/media/english/pdf/sanctions/' || LTRIM(RTRIM(ps.SanctionDescription)) || '.pdf'
            WHEN ps.SanctionDescription LIKE '%www.%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            WHEN ps.SanctionDescription LIKE '%HTTP%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            WHEN ps.SanctionDescription LIKE '%://%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            WHEN ps.SanctionDescription LIKE '%.gov%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            ELSE ''
        END AS pdfUrl,
        s.StateName AS lStFl,
        sra.StateReportingAgencyCode AS sBrdCd,
        sra.StateReportingAgencyDescription AS sBrdNm,
        sra.StateReportingAgencyURL AS sBrdUrl,
        ps.SanctionDate AS sAccDt
    FROM
        Base.ProviderSanction AS ps
        INNER JOIN Base.SanctionType st ON ps.SanctionTypeID = st.SanctionTypeID
        INNER JOIN Base.SanctionCategory sc ON ps.SanctionCategoryID = sc.SanctionCategoryID
        INNER JOIN Base.SanctionAction sa ON ps.SanctionActionID = sa.SanctionActionID
        INNER JOIN Base.StateReportingAgency sra ON ps.StateReportingAgencyID = sra.StateReportingAgencyID
        INNER JOIN Base.SanctionActionType sat ON sa.SanctionActionTypeID = sat.SanctionActionTypeID
        LEFT JOIN Base.State s ON sra.State = s.State
),
CTE_BoardActionXML AS (
    SELECT
        cte_ba.ProviderID,
        iff(cte_ba.sancD is not null,'<sancD>' || cte_ba.sancD || '</sancD>','') ||
iff(cte_ba.sDt is not null,'<sDt>' || cte_ba.sDt || '</sDt>','') ||
iff(cte_ba.reinDt is not null,'<reinDt>' || cte_ba.reinDt || '</reinDt>','') ||
iff(cte_ba.sTyp is not null,'<sTyp>' || cte_ba.sTyp || '</sTyp>','') ||
iff(cte_ba.sTypD is not null,'<sTypD>' || cte_ba.sTypD || '</sTypD>','') ||
iff(cte_ba.lSt is not null,'<lSt>' || cte_ba.lSt || '</lSt>','') ||
iff(cte_ba.sCat is not null,'<sCat>' || cte_ba.sCat || '</sCat>','') ||
iff(cte_ba.sCatD is not null,'<sCatD>' || cte_ba.sCatD || '</sCatD>','') ||
iff(cte_ba.sActC is not null,'<sActC>' || cte_ba.sActC || '</sActC>','') ||
iff(cte_ba.sActD is not null,'<sActD>' || cte_ba.sActD || '</sActD>','') ||
iff(cte_ba.pdfUrl is not null,'<pdfUrl>' || cte_ba.pdfUrl || '</pdfUrl>','') ||
iff(cte_ba.lStFl is not null,'<lStFl>' || cte_ba.lStFl || '</lStFl>','') ||
iff(cte_ba.sBrdCd is not null,'<sBrdCd>' || cte_ba.sBrdCd || '</sBrdCd>','') ||
iff(cte_ba.sBrdNm is not null,'<sBrdNm>' || cte_ba.sBrdNm || '</sBrdNm>','') ||
iff(cte_ba.sBrdUrl is not null,'<sBrdUrl>' || cte_ba.sBrdUrl || '</sBrdUrl>','') ||
iff(cte_ba.sAccDt is not null,'<sAccDt>' || cte_ba.sAccDt || '</sAccDt>','') ||
 AS XMLValue
    FROM
        CTE_BoardAction cte_ba
    GROUP BY
        cte_ba.ProviderID
),
------------------------NatlAdvertisingXML------------------------
CTE_ClientEntity AS (
    SELECT
        DISTINCT ps.ProviderCode,
        ps.ProductCode AS prCd,
        ps.ProductGroupCode AS prGrCd,
        ps.ClientCode AS adCd,
        ps.ClientName AS adNm,
        ps.CallToActionMsg AS caToActMsg,
        ps.SafeHarborMsg AS safHarMsg,
        ClientFeatureCode AS featCd,
        cf.ClientFeatureDescription AS featDesc,
        cfv.ClientFeatureValueCode AS featValCd,
        cfv.ClientFeatureValueDescription AS featValDesc,
        ps.AppointmentOptionDescription AS aptOptDesc
    FROM
        Base.ClientEntityToClientFeature cetcf
        INNER JOIN Base.EntityType et ON cetcf.EntityTypeID = et.EntityTypeID
        INNER JOIN Base.ClientFeatureToClientFeatureValue cftcv ON cetcf.ClientFeatureToClientFeatureValueID = cftcv.ClientFeatureToClientFeatureValueID
        INNER JOIN Base.ClientFeature cf ON cftcv.ClientFeatureID = cf.ClientFeatureID
        INNER JOIN Base.ClientFeatureValue cfv ON cfv.ClientFeatureValueID = cftcv.ClientFeatureValueID
        INNER JOIN Base.ClientFeatureGroup cfg ON cf.ClientFeatureGroupID = cfg.ClientFeatureGroupID
        INNER JOIN Mid.ProviderSponsorship ps ON ps.ClientToProductID = cetcf.EntityID
    WHERE
        ps.ProductGroupCode = 'LID'
),
CTE_NatlAdvertising AS (
    SELECT
        s.ProviderID,
        cte_ce.*
    FROM
        Show.SOLRProvider s
        INNER JOIN CTE_ClientEntity cte_ce ON cte_ce.ProviderCode = s.ProviderCode
),
CTE_NatlAdvertisingXML AS (
    SELECT
        cte_na.ProviderID,
        '<natladvL>' || '<natladv>' || iff(cte_na.prCd is not null,'<prCd>' || cte_na.prCd || '</prCd>','') ||
iff(cte_na.prGrCd is not null,'<prGrCd>' || cte_na.prGrCd || '</prGrCd>','') ||
 || iff(cte_na.adCd is not null,'<adCd>' || cte_na.adCd || '</adCd>','') ||
iff(cte_na.adNm is not null,'<adNm>' || cte_na.adNm || '</adNm>','') ||
iff(cte_na.caToActMsg is not null,'<caToActMsg>' || cte_na.caToActMsg || '</caToActMsg>','') ||
iff(cte_na.safHarMsg is not null,'<safHarMsg>' || cte_na.safHarMsg || '</safHarMsg>','') ||
iff(cte_na.featCd is not null,'<featCd>' || cte_na.featCd || '</featCd>','') ||
iff(cte_na.featDesc is not null,'<featDesc>' || cte_na.featDesc || '</featDesc>','') ||
iff(cte_na.featValCd is not null,'<featValCd>' || cte_na.featValCd || '</featValCd>','') ||
iff(cte_na.aptOptDesc is not null,'<aptOptDesc>' || cte_na.aptOptDesc || '</aptOptDesc>','') ||
 || '<natladv>' || '<natladvL' AS XMLValue
    FROM
        CTE_NatlAdvertising cte_na
    GROUP BY
        cte_na.ProviderID,
        cte_na.prCd,
        cte_na.prGrCd,
        cte_na.adCd,
        cte_na.adNm,
        cte_na.caToActMsg,
        cte_na.safHarMsg,
        cte_na.featCd,
        cte_na.featDesc,
        cte_na.featValCd,
        cte_na.aptOptDesc
),
------------------------SyndicationXML------------------------
CTE_FacilityPhones AS (
    SELECT
        tp.ProviderId,
        f.FacilityCode,
        cptedp.PhoneNumber AS Phone,
        cpte.ClientToProductID,
        mps.ClientCode,
        mps.ProductCode,
        mps.ProductGroupCode,
        cptedp.DisplayPartnerCode AS SyndicationPartnerCode,
        pt.PhoneTypeCode
    FROM
        CTE_Temp_Provider tp
        INNER JOIN Base.Provider p ON p.ProviderID = tp.ProviderID
        INNER JOIN Mid.ProviderSponsorship mps ON mps.ProviderCode = p.ProviderCode
        INNER JOIN Base.ProviderToFacility ptf ON ptf.ProviderID = p.ProviderID
        INNER JOIN Base.Facility f ON f.FacilityID = ptf.FacilityID
        INNER JOIN Base.ClientProductToEntity cpte ON cpte.EntityID = f.FacilityID
        INNER JOIN Base.ClientProductEntityToDisplayPartnerPhone cptedp ON cptedp.ClientProductToEntityID = cpte.ClientProductToEntityID
        INNER JOIN Base.PhoneType pt ON pt.PhoneTypeID = cptedp.PhoneTypeID
    WHERE
        mps.ProductGroupCode <> 'LID'
        AND mps.ProductCode IN (
            SELECT
                ProductCode
            FROM
                Base.Product
            WHERE
                ProductTypeCode != 'PRACTICE'
        )
        AND mps.ProductCode IN ('PDCHSP', 'MAP')
),
CTE_ClientPhones AS (
    SELECT
        DISTINCT tp.ProviderID,
        ctp.ClientToProductID,
        cptedp.DisplayPartnerCode AS SyndicationPartnerCode,
        cptedp.PhoneNumber,
        pt.PhoneTypeCode,
        mps.ClientCode,
        mps.ProductCode,
        mps.ProductGroupCode
    FROM
        CTE_Temp_Provider tp
        INNER JOIN Base.Provider p ON p.ProviderID = tp.ProviderID
        INNER JOIN Mid.ProviderSponsorship mps ON mps.ProviderCode = p.ProviderCode
        INNER JOIN Base.ClientProductToEntity CPE ON cpe.EntityID = p.ProviderID
        INNER JOIN Base.ClientToProduct ctp ON ctp.ClientToProductID = cpe.ClientToProductID
        INNER JOIN Base.ClientProductToEntity cpte ON cpte.EntityID = ctp.ClientToProductID
        INNER JOIN Base.ClientProductEntityToDisplayPartnerPhone cptedp ON cptedp.ClientProductToEntityID = cpte.ClientProductToEntityID
        INNER JOIN Base.PhoneType pt ON pt.PhoneTypeID = cptedp.PhoneTypeID
    WHERE
        mps.ProductGroupCode <> 'LID'
        AND mps.ProductCode IN (
            SELECT
                ProductCode
            FROM
                Base.Product
            WHERE
                ProductTypeCode != 'PRACTICE'
        )
        AND mps.ProductCode in ('PDCHSP', 'MAP')
),
CTE_SyndicationPDCHSP AS (
    SELECT
        ProviderID,
        ClientToProductID,
        ClientCode,
        ProductCode,
        ProductGroupCode,
        SyndicationPartnerCode
    FROM
        CTE_FacilityPhones
    UNION
    SELECT
        ProviderID,
        ClientToProductID,
        ClientCode,
        ProductCode,
        ProductGroupCode,
        SyndicationPartnerCode
    FROM
        CTE_ClientPhones
),
CTE_SP AS (
    SELECT
        SP.ProviderID,
        SP.SyndicationPartnerCode AS syndSpnCd
    FROM
        CTE_SyndicationPDCHSP SP
    WHERE
        SP.ProductCode = 'PDCHSP'
    GROUP BY
        SP.ProviderID,
        SP.SyndicationPartnerCode,
        SP.CLientToProductId
),
CTE_SP2 AS (
    SELECT
        SP2.ProviderID,
        SP2.ClientCode AS spn,
        SP2.ProductCode AS prCd,
        SP2.ProductGroupCode AS prGrCd
    FROM
        CTE_SyndicationPDCHSP SP2
        INNER JOIN CTE_SyndicationPDCHSP SP ON SP2.ProviderID = SP.ProviderID
    WHERE
        SP2.ProviderID = SP.ProviderID
        AND SP2.ClientToProductID = SP.ClientToProductID
        AND SP2.SyndicationPartnerCode = SP.SyndicationPartnerCode
        AND SP2.ProductCode = 'PDCHSP'
    GROUP BY
        SP2.ClientCode,
        SP2.ProductCode,
        SP2.ProductGroupCode,
        SP2.ProviderID,
        SP2.ClientToProductID,
        SP2.SyndicationPartnerCode
),
CTE_FP AS (
    SELECT
        FP.ProviderID,
        FP.FacilityCode AS fCd,
    FROM
        CTE_FacilityPhones FP
        INNER JOIN CTE_SyndicationPDCHSP SP2 ON SP2.ProviderID = FP.ProviderID
    WHERE
        FP.ClientToProductID = SP2.ClientToProductID
        AND FP.SyndicationPartnerCode = SP2.SyndicationPartnerCode
        AND FP.ProductCode = 'PDCHSP'
    GROUP BY
        FP.ClientToProductID,
        FP.ProviderID,
        FP.FacilityCode
),
CTE_FP2 AS (
    SELECT
        DISTINCT FP2.ProviderID,
        FP.FacilityCode AS fCd,
        FP2.Phone AS ph,
        FP2.PhoneTypeCode AS phTyp
    FROM
        CTE_FacilityPhones FP2
        INNER JOIN CTE_SyndicationPDCHSP SP2 ON FP2.ProviderID = SP2.ProviderID
        INNER JOIN CTE_FacilityPhones FP ON FP2.FacilityCode = FP.FacilityCode
    WHERE
        FP2.ClientToProductID = SP2.ClientToProductID
        AND FP2.SyndicationPartnerCode = SP2.SyndicationPartnerCode
        AND FP2.ProductCode = 'PDCHSP'
    GROUP BY
        fCd,
        FP2.ClientToProductID,
        FP2.ProviderID,
        FP2.FacilityCode,
        FP2.Phone,
        FP2.PhoneTypeCode
),
CTE_CP AS (
    SELECT
        DISTINCT cp.ProviderID,
        cp.PhoneNumber AS ph,
        cp.PhoneTypeCode AS phTyp
    FROM
        CTE_ClientPhones CP
        INNER JOIN CTE_SyndicationPDCHSP SP2 ON cp.ClientToProductID = sp2.ClientToProductID
    WHERE
        cp.SyndicationPartnerCode = sp2.SyndicationPartnerCode
        AND cp.ProductCode = 'PDCHSP'
),
CTE_SyndicationXML AS (
    SELECT
        cte_s.ProviderID,
        '<syndL>' || IFF(
            cte_sp.syndSpnCd IS NOT NULL,
            '"syndSpnCd":' || '"' || cte_sp.syndSpnCd || '"' || ',',
            ''
        ) || iff(cte_sp is not null,'<spn>' || cte_sp || '</spn>','') ||
iff(cte_sp is not null,'<prCd>' || cte_sp || '</prCd>','') ||
iff(cte_sp is not null,'<prGrCd>' || cte_sp || '</prGrCd>','') ||
 || iff(cte_fp is not null,'<fCd>' || cte_fp || '</fCd>','') ||
iff(cte_fp is not null,'<ph>' || cte_fp || '</ph>','') ||
iff(cte_fp is not null,'<phTyp>' || cte_fp || '</phTyp>','') ||
 || '<syndL>' AS XMLValue
    FROM
        CTE_SyndicationPDCHSP cte_s
        INNER JOIN CTE_SP ON cte_s.ProviderID = cte_sp.ProviderID
        INNER JOIN CTE_SP2 ON cte_s.ProviderID = cte_sp2.ProviderID
        INNER JOIN CTE_FP ON cte_s.ProviderID = cte_fp.ProviderID
        INNER JOIN CTE_FP2 ON cte_s.ProviderID = cte_fp2.ProviderID
        INNER JOIN CTE_CP ON cte_s.ProviderID = cte_cp.ProviderID
    GROUP BY
        cte_s.ProviderID,
        cte_sp.syndSpnCd
),
------------------------SponsorshipXML------------------------
CTE_ProviderToClientToProduct AS (
    SELECT
        DISTINCT dPv.ProviderId,
        lCP.ClientToProductID
    FROM
        Base.ClientProductToEntity lCPE
        INNER JOIN Base.EntityType dE ON dE.EntityTypeId = lCPE.EntityTypeID
        INNER JOIN Base.ClientToProduct lCP ON lCP.ClientToProductID = lCPE.ClientToProductID
        INNER JOIN Base.Client dC ON lCP.ClientID = dC.ClientID
        INNER JOIN Base.Product dP ON dP.ProductId = lCP.ProductID
        INNER JOIN Base.Provider dPv ON dPv.ProviderID = lCPE.EntityID
        INNER JOIN CTE_Temp_Provider P ON P.ProviderId = dPv.ProviderId
),
CTE_ProviderPracticeOfficeSponsorship AS (
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.PracticeCode,
        a.OfficeCode,
        a.PracticeName,
        a.OfficeName,
        a.OfficeID,
        a.PracticeID,
        a.PhoneXML,
        a.ImageXML,
        a.MobilePhoneXML,
        a.TabletPhoneXML,
        a.DesktopPhoneXML,
        a.URLXML,
        CASE
            WHEN LEN(CAST(a.PhoneXML AS VARCHAR)) - LEN(
                REPLACE(CAST(a.PhoneXML AS VARCHAR), '<phTyp>', '123456')
            ) > 1 THEN 1
            ELSE 0
        END AS compositePhone
    FROM
        (
            SELECT
                a.ProviderCode,
                a.ProductCode,
                a.ProductDescription,
                a.ProductGroupCode,
                a.ProductGroupDescription,
                a.ClientToProductID,
                a.ClientCode,
                a.ClientName,
                a.HasOAR,
                a.QualityMessageXML,
                a.AppointmentOptionDescription,
                a.CallToActionMsg,
                a.SafeHarborMsg,
                a.PracticeCode,
                a.OfficeCode,
                a.PracticeName,
                a.OfficeName,
                a.OfficeID,
                a.PracticeID,
                a.PhoneXML,
                a.ImageXML,
                a.MobilePhoneXML,
                a.TabletPhoneXML,
                a.DesktopPhoneXML,
                a.URLXML,
                ROW_NUMBER() OVER (
                    PARTITION BY A.ProviderCode,
                    A.ProductCode,
                    A.ClientCode,
                    A.OfficeCode
                    ORDER BY
                        CASE
                            WHEN PhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN URLXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN ImageXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN MobilePhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN TabletPhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN DesktopPhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END
                ) AS RN1
            FROM
                CTE_Temp_Provider AS p
                INNER JOIN Base.Provider AS p2 ON p2.ProviderID = p.ProviderID
                INNER JOIN Mid.ProviderSponsorship AS a ON a.ProviderCode = p2.ProviderCode
                INNER JOIN Base.Product PD ON PD.ProductCode = A.ProductCode
            WHERE
                ProductGroupCode != 'LID'
                AND PD.ProductTypeCode = 'PRACTICE'
        ) A
    WHERE
        RN1 = 1
),
CTE_ProviderPracticeOfficeSponsorshipMAP AS (
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.PracticeCode,
        a.OfficeCode,
        a.PracticeName,
        a.OfficeName,
        a.OfficeID,
        a.PracticeID,
        a.PhoneXML,
        a.ImageXML,
        a.MobilePhoneXML,
        a.TabletPhoneXML,
        a.DesktopPhoneXML,
        a.URLXML,
        CASE
            WHEN LEN(CAST(a.PhoneXML AS VARCHAR)) - LEN(
                REPLACE(CAST(a.PhoneXML AS VARCHAR), '<phTyp>', '123456')
            ) > 1 THEN 1
            ELSE 0
        END AS compositePhone
    FROM
        (
            SELECT
                p2.ProviderCode,
                PD.ProductCode,
                PD.ProductDescription,
                PRG.ProductGroupCode,
                PRG.ProductGroupDescription,
                a.ClientToProductID,
                C.ClientCode,
                C.ClientName,
                a.HasOAR,
                PS.QualityMessageXML,
                PS.AppointmentOptionDescription,
                PS.CallToActionMsg,
                PS.SafeHarborMsg,
                PC.PracticeCode,
                O.OfficeCode,
                PC.PracticeName,
                O.OfficeName,
                a.OfficeID,
                PC.PracticeID,
                a.PhoneXML,
                IFNULL(PS.ImageXML, PSc.ImageXML) AS ImageXML,
                PS.MobilePhoneXML,
                PS.TabletPhoneXML,
                PS.DesktopPhoneXML,
                PS.URLXML,
                ROW_NUMBER() OVER (
                    PARTITION BY P2.ProviderCode,
                    PD.ProductCode,
                    C.ClientCode,
                    O.OfficeCode
                    ORDER BY
                        CASE
                            WHEN PC.PracticeCode IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN a.PhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN PS.URLXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN PS.ImageXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN PS.MobilePhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN PS.TabletPhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN PS.DesktopPhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END
                ) AS RN1
            FROM
                CTE_Temp_Provider AS p
                INNER JOIN Base.Provider AS p2 ON p2.ProviderID = p.ProviderID
                INNER JOIN base.ProviderToMAPCustomerProduct AS a ON a.ProviderID = p2.ProviderID
                AND IFNULL(a.DisplayPartnerCode, 'HG.COM') = 'HG.COM'
                INNER JOIN CTE_ProviderToClientToProduct PCP ON PCP.ProviderId = a.ProviderId
                AND PCP.ClientToProductID = A.ClientToProductID
                INNER JOIN Base.Office O ON O.OfficeId = A.OfficeID
                LEFT JOIN base.Practice PC ON PC.PracticeID = O.PracticeID
                INNER JOIN Base.ClientToProduct AS cp ON cp.ClientToProductID = A.ClientToProductID
                INNER JOIN Base.Client AS c ON c.ClientID = cp.ClientID
                INNER JOIN Base.Product AS pd ON pd.ProductID = cp.ProductID
                INNER JOIN Base.ProductGroup AS prg ON prg.ProductGroupID = pd.ProductGroupID
                LEFT JOIN Mid.ProviderSponsorship AS PS ON PS.ProviderCode = p2.ProviderCode
                AND PS.OfficeCode = O.OfficeCode
                LEFT JOIN Mid.ProviderSponsorship AS PSc ON PSc.ProviderCode = p2.ProviderCode
            WHERE p2.ProviderCode IN (SELECT DISTINCT ProviderCode FROM Mid.ProviderSponsorship)
        ) A
    WHERE
        RN1 = 1
),
CTE_Url AS (
    SELECT
        fa.FacilityCode,
        FacilityURL AS urlVal,
        'FCURL' AS urlTyp,
        '<url>' || urlVal || urlTyp || '</url>' AS XML
    FROM
        Show.SOLRFacility fa
        INNER JOIN Mid.ProviderSponsorship AS a ON a.FacilityCode = fa.FacilityCode
    ORDER BY
        FacilityURL
),
CTE_A AS (
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.FacilityCode,
        a.FacilityName,
        a.FacilityState,
        a.PhoneXML,
        a.ImageXML,
        a.MobilePhoneXML,
        a.TabletPhoneXML,
        a.DesktopPhoneXML,
        CASE
            WHEN a.URLXML IS NOT NULL THEN a.URLXML
            ELSE CTE_Url.XML
        END AS URLXML
    FROM
        CTE_Temp_Provider AS p
        INNER JOIN Base.Provider AS p2 ON p2.ProviderID = p.ProviderID
        INNER JOIN Mid.ProviderSponsorship AS a ON a.ProviderCode = p2.ProviderCode
        INNER JOIN Base.Product PD ON PD.ProductCode = A.ProductCode
        INNER JOIN CTE_Url ON CTE_Url.FacilityCode = a.FacilityCode
    WHERE
        ProductGroupCode != 'LID'
        AND (
            a.FacilityCode IS NOT NULL
            OR a.ProductCode IN ('PDCWMDLITE', 'PDCWRITEMD')
        )
        AND (
            PD.ProductCode IN ('MAP')
            OR PD.ProductTypeCode = 'Hospital'
        )
),
CTE_ProviderFacilitySponsorship AS (
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.FacilityCode,
        a.FacilityName,
        a.FacilityState,
        a.PhoneXML,
        a.ImageXML,
        a.MobilePhoneXML,
        a.TabletPhoneXML,
        a.DesktopPhoneXML,
        URLXML,
        0 AS compositePhone
    FROM
        CTE_A a
),
CTE_ProviderClientDisplayPartner AS (
    SELECT
        p2.ProviderCode,
        c.ClientCode,
        sp.SyndicationPartnerCode AS DisplayPartnerCode
    FROM
        CTE_Temp_Provider AS p
        INNER JOIN Base.Provider AS p2 ON p2.ProviderID = p.ProviderID
        INNER JOIN Base.ProviderToClientProductToDisplayPartner AS pc ON pc.ProviderID = p2.ProviderID
        INNER JOIN Base.ClientToProduct AS cp ON cp.ClientToProductID = pc.ClientToProductID
        INNER JOIN Base.Client AS c ON c.ClientID = cp.ClientID
        INNER JOIN Base.Product AS prod ON prod.ProductID = cp.ProductID
        INNER JOIN Base.SyndicationPartner AS sp ON sp.SyndicationPartnerId = pc.SyndicationPartnerID
        INNER JOIN Mid.ProviderSponsorship AS mps ON mps.ProviderCode = p2.ProviderCode
        AND mps.ClientCode = c.ClientCode
        AND mps.ProductCode = prod.ProductCode
    WHERE
        prod.ProductCode IN ('PDCWRITEMD', 'PDCWMDLITE')
    ORDER BY
        p2.ProviderCode,
        c.ClientCode,
        sp.SyndicationPartnerCode
),
CTE_CompositePhonesX AS (
    SELECT
        s.ProviderCode,
        GET(XMLGET(TO_VARIANT(s.PHONEXML), 'phone'), '$') AS PhoneType,
        GET(
            XMLGET(TO_VARIANT(s.DESKTOPPHONEXML), 'phone'),
            '$'
        ) AS DesktopPhoneType,
        GET(
            XMLGET(TO_VARIANT(s.MOBILEPHONEXML), 'phone'),
            '$'
        ) AS MobilePhoneType,
        GET(
            XMLGET(TO_VARIANT(s.TABLETPHONEXML), 'phone'),
            '$'
        ) AS TabletPhoneType
    FROM
        CTE_ProviderFacilitySponsorship S
),
CTE_CompositePhones AS (
    SELECT
        ProviderCode
    FROM
        CTE_CompositePhonesX
    WHERE
        PhoneType IN (
            SELECT
                PhoneTypeCode
            FROM
                Base.PhoneType
            WHERE
                PhoneTypeDescription LIKE '%PSR%'
                OR PhoneTypeDescription LIKE '%Market Targeted%'
        )
        OR DesktopPhoneType IN (
            SELECT
                PhoneTypeCode
            FROM
                Base.PhoneType
            WHERE
                PhoneTypeDescription LIKE '%PSR%'
                OR PhoneTypeDescription LIKE '%Market Targeted%'
        )
        OR MobilePhoneType IN (
            SELECT
                PhoneTypeCode
            FROM
                Base.PhoneType
            WHERE
                PhoneTypeDescription LIKE '%PSR%'
                OR PhoneTypeDescription LIKE '%Market Targeted%'
        )
        OR TabletPhoneType IN (
            SELECT
                PhoneTypeCode
            FROM
                Base.PhoneType
            WHERE
                PhoneTypeDescription LIKE '%PSR%'
                OR PhoneTypeDescription LIKE '%Market Targeted%'
        )
),
CTE_ProviderSponsorship_sq1 AS (
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.compositePhone
    FROM
        CTE_ProviderPracticeOfficeSponsorship A
    UNION ALL
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.compositePhone
    FROM
        CTE_ProviderPracticeOfficeSponsorshipMAP A
    UNION ALL
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.compositePhone
    FROM
        CTE_ProviderFacilitySponsorship A
),
CTE_ProviderSponsorship_sq2 AS (
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.compositePhone,
        ROW_NUMBER() OVER(
            PARTITION BY a.ProviderCode,
            a.ProductCode,
            a.ClientCode
            ORDER BY
                a.compositePhone desc,
                CASE
                    WHEN HasOAR IS NOT NULL THEN 0
                    ELSE 1
                END,
                CASE
                    WHEN QualityMessageXML IS NOT NULL THEN 0
                    ELSE 1
                END,
                CASE
                    WHEN AppointmentOptionDescription IS NOT NULL THEN 0
                    ELSE 1
                END,
                CASE
                    WHEN CallToActionMsg IS NOT NULL THEN 0
                    ELSE 1
                END,
                CASE
                    WHEN SafeHarborMsg IS NOT NULL THEN 0
                    ELSE 1
                END
        ) RN1
    FROM
        CTE_ProviderSponsorship_sq1 a
),
CTE_ProviderSponsorship AS (
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM CTE_CompositePhones cp
                WHERE cp.ProviderCode = a.ProviderCode
            ) THEN 1
            ELSE 0
        END AS compositePhone
    FROM CTE_ProviderSponsorship_sq2 a
    WHERE RN1 = 1
),

------------------------SponsorshipXML------------------------
CTE_ClientFeatureCode AS (
    SELECT DISTINCT
         ClientFeatureCode AS featCd,
         d.ClientFeatureDescription AS featDesc,
         e.ClientFeatureValueCode AS featValCd,
         e.ClientFeatureValueDescription AS featValDesc,
         a.EntityID, 
         CP.ClientToProductCode
    FROM Base.ClientEntityToClientFeature a
    INNER JOIN Base.ClientToProduct CP on CP.ClientToProductID = a.EntityID
    INNER JOIN Base.Product P ON P.ProductId = CP.ProductID
    INNER JOIN Base.EntityType b ON a.EntityTypeID = b.EntityTypeID
    INNER JOIN Base.ClientFeatureToClientFeatureValue c ON a.ClientFeatureToClientFeatureValueID = c.ClientFeatureToClientFeatureValueID
    INNER JOIN Base.ClientFeature d ON c.ClientFeatureID = d.ClientFeatureID
    INNER JOIN Base.ClientFeatureValue e ON e.ClientFeatureValueID = c.ClientFeatureValueID
    INNER JOIN Base.ClientFeatureGroup f ON d.ClientFeatureGroupID = f.ClientFeatureGroupID
    WHERE b.EntityTypeCode = 'CLPROD'
        AND CASE WHEN ClientFeatureValueCode = 'FVNO' AND ClientFeatureCode IN ('FCOOMT','FCOOPSR', 'FCDOA') THEN 'REMOVE'                 ELSE 'KEEP' END = 'KEEP'
                AND NOT(
                    ClientFeatureCode = 'FCBFN'
                    AND a.EntityID IN (
                        SELECT ClientToProductID
                        FROM Base.ClientToProduct lCP
                        INNER JOIN Base.Client dC ON lCP.ClientID = dC.ClientID
                        WHERE ClientCode IN      ('HCACKS','HCACVA','HCAEFD','HCAFRFT','HCAGC','HCAHL1','HCALEW','HCAMT','HCAMW','HCANFD','HCAPASO','HCARES','HCASAM','HCASATL','HCATRI','HCAWFD','HCAWNV','STDAVD')
                    )
                )
),

CTE_spnFeatXML AS (
    SELECT
        cte_cfc.EntityID,
        iff(cte_cfc.featCd is not null,'<featCd>' || cte_cfc.featCd || '</featCd>','') ||
iff(cte_cfc.featDesc is not null,'<featDesc>' || cte_cfc.featDesc || '</featDesc>','') ||
iff(cte_cfc.featValCd is not null,'<featValCd>' || cte_cfc.featValCd || '</featValCd>','') ||
iff(cte_cfc.featValDesc is not null,'<featValDesc>' || cte_cfc.featValDesc || '</featValDesc>','') ||
 AS XMLValue
    FROM CTE_ClientFeatureCode cte_cfc
    GROUP BY cte_cfc.EntityID
),

CTE_spnFeat AS (
    SELECT 
       P.ProviderCode,
       MS.ClientCode AS spnCd,
       MS.ClientName AS spnNm,
       MS.CallToActionMsg AS caToActMsg,
       MS.SafeHarborMsg AS safHarMsg,
       MS.ProductDescription AS spnD,
       CAST(NULL AS BOOLEAN) AS isOarX,
       CTE_spnFeatXML.XMLValue AS XMLValue
    FROM CTE_ProviderSponsorship MS
    INNER JOIN Base.Provider P ON P.ProviderCode = MS.ProviderCode
    INNER JOIN CTE_Temp_Provider A ON A.Providerid = P.ProviderID
    INNER JOIN CTE_spnFeatXML ON MS.ClientToProductID = cte_spnfeatXML.EntityID
    GROUP BY P.ProviderCode,ClientCode,ClientName,ClientToProductID,
             CallToActionMsg,SafeHarborMsg,ProductDescription,XMLValue
),

CTE_clCtrFeatXML AS (
    SELECT DISTINCT
       a.EntityID,
       iff(ClientFeatureCode is not null,'<featCd>' || ClientFeatureCode || '</featCd>','') ||
iff(d.ClientFeatureDescription is not null,'<featDesc>' || d.ClientFeatureDescription || '</featDesc>','') ||
iff(e.ClientFeatureValueCode is not null,'<featValCd>' || e.ClientFeatureValueCode || '</featValCd>','') ||
iff(e.ClientFeatureValueDescription is not null,'<featValDesc>' || e.ClientFeatureValueDescription || '</featValDesc>','') ||
 AS XMLValue
    FROM Base.ClientEntityToClientFeature a
    INNER JOIN Base.EntityType b ON a.EntityTypeID = b.EntityTypeID
    INNER JOIN Base.ClientFeatureToClientFeatureValue c ON a.ClientFeatureToClientFeatureValueID = c.ClientFeatureToClientFeatureValueID
    INNER JOIN Base.ClientFeature d ON c.ClientFeatureID = d.ClientFeatureID
    INNER JOIN Base.ClientFeatureValue e ON e.ClientFeatureValueID = c.ClientFeatureValueID
    INNER JOIN Base.ClientFeatureGroup f ON d.ClientFeatureGroupID = f.ClientFeatureGroupID
    WHERE f.ClientFeatureGroupCode = 'FGOAR' AND b.EntityTypeCode = 'CLCTR'
    GROUP BY EntityID, ClientFeatureCode, d.ClientFeatureDescription, 
            e.ClientFeatureValueCode, e.ClientFeatureValueDescription
),

CTE_clCtrL AS (
    SELECT		
        CallCenterCode AS clCtrCd,
        CallCenterName AS clCtrNm,
        ReplyDays AS aptCoffDay,
        ApptCutOffTime AS aptCoffHr,
        EmailAddress AS eml,
        FaxNumber AS fxNo,
        CTE_clCtrFeatXML.XMLValue AS XMLValue,
        ccd.ClientToProductID
    FROM Base.vwuCallCenterDetails ccd
    INNER JOIN CTE_clCtrFeatXML ON ccd.CallCenterID = CTE_clCtrFeatXML.EntityID
    GROUP BY CallCenterCode,CallCenterName,ReplyDays,ApptCutOffTime,
             EmailAddress,FaxNumber,CallCenterID,ccd.ClientToProductID, XMLValue
),

CTE_OfficeXML AS (
    SELECT
        PPOx.ProviderCode,
        PPOx.OfficeCode,
        iff(OfficeCode is not null,'<offCd>' || OfficeCode || '</offCd>','') ||
iff(OfficeNAme is not null,'<offNm>' || OfficeNAme || '</offNm>','') ||
iff(PhoneXML is not null,'<phoneL>' || PhoneXML || '</phoneL>','') ||
iff(MobilePhoneXML is not null,'<mobilePhoneL>' || MobilePhoneXML || '</mobilePhoneL>','') ||
iff(URLXML is not null,'<urlL>' || URLXML || '</urlL>','') ||
iff(ImageXML is not null,'<imageL>' || ImageXML || '</imageL>','') ||
iff(TabletPhoneXML is not null,'<tabletPhoneL>' || TabletPhoneXML || '</tabletPhoneL>','') ||
iff(DesktopPhoneXML is not null,'<desktopPhoneL>' || DesktopPhoneXML || '</desktopPhoneL>','') ||
 AS XMLValue
    FROM CTE_ProviderPracticeOfficeSponsorship PPOx
    GROUP BY PPOx.ProviderCode, PPOx.OfficeCode, OfficeCode, OfficeNAme,
             PhoneXML, MobilePhoneXML, URLXML, ImageXML, TabletPhoneXML, DesktopPhoneXML
),

CTE_PracticePDCPRAC AS (
    SELECT
        PPO.PracticeCode AS pracCd,
        PPO.PracticeName AS pracName,
        CTE_OfficeXML.XMLValue AS offL,
        PPO.ProviderCode
    FROM CTE_ProviderPracticeOfficeSponsorship PPO
    INNER JOIN CTE_OfficeXML ON PPO.ProviderCode = CTE_OfficeXML.ProviderCode AND PPO.OfficeCode = CTE_OfficeXML.OfficeCode
    INNER JOIN Base.Provider P ON P.ProviderCode = PPO.ProviderCode
    INNER JOIN CTE_Temp_Provider Pt ON Pt.ProviderID = P.ProviderID
    WHERE PPO.ProviderCode = p.ProviderCode
    GROUP BY PPO.PracticeCode, PPO.PracticeName, PPO.ProviderCode, PPO.OfficeCode, CTE_OfficeXML.XMLValue
),

CTE_OfficeXMLMAP AS (
    SELECT
        PPO.ProviderCode,
        PPO.OfficeCode,
        iff(PPO.OfficeCode is not null,'<cd>' || PPO.OfficeCode || '</cd>','') ||
iff(PPO.OfficeName is not null,'<nm>' || PPO.OfficeName || '</nm>','') ||
iff(PPO.PhoneXML is not null,'<phoneL>' || PPO.PhoneXML || '</phoneL>','') ||
iff(PPO.MobilePhoneXML is not null,'<mobilePhoneL>' || PPO.MobilePhoneXML || '</mobilePhoneL>','') ||
iff(PPO.URLXML is not null,'<urlL>' || PPO.URLXML || '</urlL>','') ||
iff(PPO.TabletPhoneXML is not null,'<tabletPhoneL>' || PPO.TabletPhoneXML || '</tabletPhoneL>','') ||
iff(PPO.DesktopPhoneXML is not null,'<desktopPhoneL>' || PPO.DesktopPhoneXML || '</desktopPhoneL>','') ||
 AS XMLValue
    FROM CTE_ProviderPracticeOfficeSponsorshipMAP PPO
    GROUP BY PPO.ProviderCode, PPO.OfficeCode, PPO.OfficeName, PPO.PhoneXML, 
             PPO.MobilePhoneXML, PPO.URLXML, PPO.TabletPhoneXML, PPO.DesktopPhoneXML
),

CTE_MAPX AS (
    SELECT DISTINCT
        ProviderCode,
        PracticeCode,
        PracticeName,
        OfficeCode,
        OfficeName,
        CAST(PhoneXML AS VARCHAR()) AS PhoneXML,
        CAST(MobilePhoneXML AS VARCHAR()) AS MobilePhoneXML,
        CAST(URLXML AS VARCHAR()) AS URLXML,
        CAST(ImageXML AS VARCHAR()) AS ImageXML,
        CAST(TabletPhoneXML AS VARCHAR()) AS TabletPhoneXML,
        CAST(DesktopPhoneXML AS VARCHAR()) AS DesktopPhoneXML
    FROM CTE_ProviderPracticeOfficeSponsorshipMAP
),

CTE_PracticeMAP AS (
    SELECT
        'Practice' AS Type,
        X.PracticeCode AS cd,
        X.PracticeName AS nm,
        CAST(NULL AS OBJECT) AS st,
        CAST(NULL AS OBJECT) AS phoneL,
        CAST(NULL AS OBJECT) AS mobilePhoneL,
        CAST(NULL AS OBJECT) AS urlL,
        X.ImageXML AS imageL,
        CAST(NULL AS OBJECT) AS quaMsgL,
        CAST(NULL AS OBJECT) AS tabletPhoneL,
        CAST(NULL AS OBJECT) AS desktopPhoneL,
        X.ProviderCode,
        CTE_OfficeXMLMAP.XMLValue AS offL
    FROM CTE_MAPX AS X
    INNER JOIN CTE_OfficeXMLMAP ON X.ProviderCode = CTE_OfficeXMLMAP.ProviderCode AND X.OfficeCode = CTE_OfficeXMLMAP.OfficeCode
    INNER JOIN Base.Provider P ON P.ProviderCode = X.ProviderCode
    INNER JOIN CTE_Temp_Provider Pt ON Pt.ProviderID = P.ProviderID
),

CTE_FacilityMAP AS (
    SELECT
      'facility' AS Type,
      X.FacilityCode AS cd,
      X.FacilityName AS nm,
      X.FacilityState AS st,
      X.PhoneXML AS phoneL,
      X.MobilePhoneXML AS mobilePhoneL,
      X.URLXML AS urlL,
      X.ImageXML AS imageL,
      X.QualityMessageXML AS quaMsgL,
      X.TabletPhoneXML AS tabletPhoneL,
      X.DesktopPhoneXML AS desktopPhoneL,
      CAST(NULL AS OBJECT ) AS offL,
      P.ProviderCode
    FROM
      (
        SELECT
          ProviderCode,
          FacilityCode,
          FacilityName,
          FacilityState,
          PhoneXML,
          MobilePhoneXML,
          URLXML,
          ImageXML,
          QualityMessageXML,
          TabletPhoneXML,
          DesktopPhoneXML
        FROM
          (
            SELECT
              ProviderCode,
              FacilityCode,
              FacilityName,
              FacilityState,
              PhoneXML,
              MobilePhoneXML,
              URLXML,
              ImageXML,
              QualityMessageXML,
              TabletPhoneXML,
              DesktopPhoneXML,
              ROW_NUMBER() OVER (
                PARTITION BY ProviderCode,
                FacilityCode
                ORDER BY
                  FacilityName
              ) AS RN1
            FROM
              CTE_ProviderFacilitySponsorship
          ) X
        WHERE
          RN1 = 1
      ) X
      INNER JOIN Base.Provider P ON P.ProviderCode = X.ProviderCode
      INNER JOIN CTE_Temp_Provider Pt ON Pt.ProviderID = P.ProviderID
    WHERE
      X.FacilityCode IS NOT NULL
),

CTE_ClientLevelBranded AS (
    SELECT DISTINCT 
        t2.EntityID AS ClientToProductID, 
        t2.ClientToProductCode, 
        t2.featValDesc AS PhoneLevel
    FROM CTE_ClientFeatureCode AS t1
    INNER JOIN CTE_ClientFeatureCode AS t2 ON t2.EntityID = t1.EntityID
    WHERE t1.featDesc = 'Branding Level' AND t1.featValCd = 'FVCLT' AND t2.featCd = 'FCCCP' 
    ORDER BY t2.ClientToProductCode
), 

CTE_ProviderFacilitySponsorship_ClientLevelBranded AS (
    SELECT
        p.ProviderCode,
        p.ClientCode,
        p.ClientName,
        NULL AS FacilityState,
        p.PhoneXML,
        p.MobilePhoneXML,
        NULL AS URLXML,
        p.ImageXML,
        NULL AS QualityMessageXML,
        p.TabletPhoneXML,
        p.DesktopPhoneXML,
        c.PhoneLevel,
        ROW_NUMBER() OVER (PARTITION BY p.ProviderCode ORDER BY p.ClientCode) AS RN1
    FROM
        CTE_ProviderFacilitySponsorship p
        INNER JOIN CTE_ClientLevelBranded c ON c.ClientToProductID = p.ClientToProductID
),

CTE_ProviderSponsorship_ClientLevelBranded AS (
    SELECT
        m.ProviderCode,
        m.ClientCode,
        m.ClientName,
        NULL AS FacilityState,
        CAST(NULL AS VARCHAR()) AS PhoneXML,
        CAST(NULL AS VARCHAR()) AS MobilePhoneXML,
        NULL AS URLXML,
        CAST(NULL AS VARCHAR()) AS ImageXML,
        NULL AS QualityMessageXML,
        CAST(NULL AS VARCHAR()) AS TabletPhoneXML,
        CAST(NULL AS VARCHAR()) AS DesktopPhoneXML,
        c.PhoneLevel,
        ROW_NUMBER() OVER (PARTITION BY m.ProviderCode ORDER BY m.ClientCode) AS RN2
    FROM
        Mid.ProviderSponsorship m
        INNER JOIN CTE_ClientLevelBranded c ON c.ClientToProductID = m.ClientToProductID
    WHERE
        NOT EXISTS (SELECT 1 FROM CTE_ProviderFacilitySponsorship t WHERE t.ClientToProductID = c.ClientToProductID
                    AND t.ProviderCode = m.ProviderCode) AND m.ProductGroupCode != 'LID' AND m.FacilityCode IS NULL
),

CTE_ClientType AS (
    SELECT
        'client' AS Type,
        X.ClientCode AS cd,
        X.ClientName AS nm,
        CAST(NULL AS VARCHAR()) AS st,
        CASE WHEN X.PhoneLevel = 'Client' THEN X.PhoneXML ELSE NULL END AS phoneL,
        CASE WHEN X.PhoneLevel = 'Client' THEN X.MobilePhoneXML ELSE NULL END AS mobilePhoneL,
        CAST(NULL AS VARCHAR()) AS urlL,
        X.ImageXML AS imageL,
        CAST(NULL AS VARCHAR()) AS quaMsgL,
        CASE WHEN X.PhoneLevel = 'Client' THEN X.TabletPhoneXML ELSE NULL END AS tabletPhoneL,
        CASE WHEN X.PhoneLevel = 'Client' THEN X.DesktopPhoneXML ELSE NULL END AS desktopPhoneL,
        CAST(NULL AS VARCHAR()) AS offL,
        P.ProviderCode,
        X.ClientCode
    FROM
        (
            SELECT
                a.ProviderCode,
                a.ClientCode,
                a.ClientName,
                a.FacilityState,
                a.PhoneXML,
                a.MobilePhoneXML,
                a.URLXML,
                a.ImageXML,
                a.QualityMessageXML,
                a.TabletPhoneXML,
                a.DesktopPhoneXML,
                a.RN1,
                a.PhoneLevel
            FROM
                (
                    SELECT * FROM CTE_ProviderFacilitySponsorship_ClientLevelBranded WHERE RN1 = 1
                    UNION ALL
                    SELECT * FROM CTE_ProviderSponsorship_ClientLevelBranded WHERE RN2 = 1
                ) a
        ) X
        INNER JOIN Base.Provider P ON P.ProviderCode = X.ProviderCode
        INNER JOIN CTE_Temp_Provider Pt ON Pt.ProviderID = P.ProviderID
),

------------- FINALLY BUILD THE SPONSORSHIP XML --------------
CTE_ProviderFacilitySponsorshipFinal AS (
    SELECT	
        v.ProviderCode,
        NULL AS Type,
        NULL AS nm,
        v.FacilityCode AS facCd,
        v.FacilityName AS facNm,
        v.FacilityState AS facSt,
        v.PhoneXML AS phoneL,
        v.MobilePhoneXML AS mobilePhoneL,
        v.URLXML AS urlL,
        v.ImageXML AS imageL,
        v.QualityMessageXML AS quaMsgL,
        v.TabletPhoneXML AS tabletPhoneL,
        v.DesktopPhoneXML AS desktopPhoneL
    FROM CTE_ProviderFacilitySponsorship v
    INNER JOIN CTE_ProviderSponsorship a ON v.ProviderCode = a.ProviderCode AND v.ClientCode = a.ClientCode
    UNION ALL
    SELECT	
        v.ProviderCode,
        v.Type AS Type,
        v.nm AS nm, 
        NULL AS facCd, 
        NULL AS facNm, 
        NULL AS facSt, 
        v.phoneL AS phoneL, 
        v.mobilePhoneL AS mobilePhoneL,
        v.urlL AS urlL,
        v.imageL AS imageL, 
        v.quaMsgL AS quaMsgL, 
        v.tabletPhoneL AS tabletPhoneL, 
        v.desktopPhoneL AS desktopPhoneL
    FROM CTE_ClientType v
    INNER JOIN CTE_ProviderSponsorship a ON v.ProviderCode = a.ProviderCode AND v.cd = a.ClientCode
),

CTE_PracticeMapFacilityMapClientType AS (
    SELECT
        ProviderCode,
        Type,
        cd,
        nm,
        CAST(st AS VARCHAR()) AS st,
        CAST(phoneL AS VARCHAR()) AS phoneL,
        CAST(mobilePhoneL AS VARCHAR()) AS mobilePhoneL,
        CAST(urlL AS VARCHAR()) AS urlL,
        CAST(imageL AS VARCHAR()) AS imageL,
        CAST(quaMsgL AS VARCHAR()) AS quaMsgL,
        CAST(tabletPhoneL AS VARCHAR()) AS tabletPhoneL,
        CAST(desktopPhoneL AS VARCHAR()) AS desktopPhoneL,
        CAST(offL AS VARCHAR()) AS offL
    FROM CTE_PracticeMAP
    UNION ALL
    SELECT
        ProviderCode,
        Type,
        cd,
        nm,
        CAST(st AS VARCHAR()) AS st,
        CAST(phoneL AS VARCHAR()) AS phoneL,
        CAST(mobilePhoneL AS VARCHAR()) AS mobilePhoneL,
        CAST(urlL AS VARCHAR()) AS urlL,
        CAST(imageL AS VARCHAR()) AS imageL,
        CAST(quaMsgL AS VARCHAR()) AS quaMsgL,
        CAST(tabletPhoneL AS VARCHAR()) AS tabletPhoneL,
        CAST(desktopPhoneL AS VARCHAR()) AS desktopPhoneL,
        CAST(offL AS VARCHAR()) AS offL
    FROM CTE_FacilityMAP
    UNION ALL
    SELECT
        ProviderCode,
        Type,
        NULL AS cd,
        nm,
        CAST(st AS VARCHAR()) AS st,
        CAST(phoneL AS VARCHAR()) AS phoneL,
        CAST(mobilePhoneL AS VARCHAR()) AS mobilePhoneL,
        CAST(urlL AS VARCHAR()) AS urlL,
        CAST(imageL AS VARCHAR()) AS imageL,
        CAST(quaMsgL AS VARCHAR()) AS quaMsgL,
        CAST(tabletPhoneL AS VARCHAR()) AS tabletPhoneL,
        CAST(desktopPhoneL AS VARCHAR()) AS desktopPhoneL,
        CAST(offL AS VARCHAR()) AS offL
    FROM CTE_ClientType
),

CTE_spnFeatXML AS (
    SELECT
        s.ProviderID,
        XMLValue AS spnFeatL,
        iff(spnCd is not null,'<spnCd>' || spnCd || '</spnCd>','') ||
iff(spnNm is not null,'<spnNm>' || spnNm || '</spnNm>','') ||
iff(caToActMsg is not null,'<caToActMsg>' || caToActMsg || '</caToActMsg>','') ||
iff(safHarMsg is not null,'<safHarMsg>' || safHarMsg || '</safHarMsg>','') ||
iff(spnD is not null,'<spnD>' || spnD || '</spnD>','') ||
iff(isOarX is not null,'<isOarX>' || isOarX || '</isOarX>','') ||
iff(spnFeatL is not null,'<spnFeatL>' || spnFeatL || '</spnFeatL>','') ||
 AS XMLValue
    FROM CTE_spnFeat
    INNER JOIN Show.SOLRProvider s ON s.ProviderCode = cte_spnFeat.ProviderCode
    GROUP BY s.ProviderID, spnFeatL
),

CTE_PCDPXML AS (
    SELECT
        s.ProviderID,
        iff(DisplayPartnerCode is not null,'<dpcd>' || DisplayPartnerCode || '</dpcd>','') ||
 AS XMLValue
    FROM CTE_ProviderClientDisplayPartner cte_pcdp
    INNER JOIN Show.SOLRProvider s ON s.ProviderCode = cte_pcdp.ProviderCode
    GROUP BY s.ProviderID
),

CTE_clCtrLXML AS (
    SELECT
        s.ProviderID,
        XMLValue AS clCtrFeatL,
        iff(clCtrCd is not null,'<clCtrCd>' || clCtrCd || '</clCtrCd>','') ||
iff(clCtrNm is not null,'<clCtrNm>' || clCtrNm || '</clCtrNm>','') ||
iff(aptCoffDay is not null,'<aptCoffDay>' || aptCoffDay || '</aptCoffDay>','') ||
iff(aptCoffHr is not null,'<aptCoffHr>' || aptCoffHr || '</aptCoffHr>','') ||
iff(eml is not null,'<eml>' || eml || '</eml>','') ||
iff(fxNo is not null,'<fxNo>' || fxNo || '</fxNo>','') ||
iff(clCtrFeatL is not null,'<clCtrFeatL>' || clCtrFeatL || '</clCtrFeatL>','') ||
 AS XMLValue
    FROM CTE_clCtrL
    INNER JOIN CTE_ProviderSponsorship ps ON ps.ClientToProductID = CTE_clCtrL.ClientToProductID
    INNER JOIN Show.SOLRProvider s ON ps.ProviderCode = s.ProviderCode
    GROUP BY s.ProviderID, clCtrFeatL
),

CTE_PracticePDCPRACXML AS (
    SELECT
        s.ProviderID,
        iff(pracCd is not null,'<pracCd>' || pracCd || '</pracCd>','') ||
iff(pracName is not null,'<pracName>' || pracName || '</pracName>','') ||
iff(offL is not null,'<offL>' || offL || '</offL>','') ||
 AS XMLValue
    FROM CTE_PracticePDCPRAC cte_pdcprac
    INNER JOIN Show.SOLRProvider s ON s.ProviderCode = cte_pdcprac.ProviderCode
    GROUP BY ProviderID
), 

CTE_PracticeMAPXML AS (
    SELECT
        s.ProviderID,
        iff(Type is not null,'<Type>' || Type || '</Type>','') ||
iff(cd is not null,'<cd>' || cd || '</cd>','') ||
iff(nm is not null,'<nm>' || nm || '</nm>','') ||
iff(st is not null,'<st>' || st || '</st>','') ||
iff(phoneL is not null,'<phoneL>' || phoneL || '</phoneL>','') ||
iff(mobilePhoneL is not null,'<mobilePhoneL>' || mobilePhoneL || '</mobilePhoneL>','') ||
iff(urlL is not null,'<urlL>' || urlL || '</urlL>','') ||
iff(imageL is not null,'<imageL>' || imageL || '</imageL>','') ||
iff(quaMsgL is not null,'<quaMsgL>' || quaMsgL || '</quaMsgL>','') ||
iff(tabletPhoneL is not null,'<tabletPhoneL>' || tabletPhoneL || '</tabletPhoneL>','') ||
iff(desktopPhoneL is not null,'<desktopPhoneL>' || desktopPhoneL || '</desktopPhoneL>','') ||
iff(offL is not null,'<offL>' || offL || '</offL>','') ||
 AS XMLValue
    FROM CTE_PracticeMapFacilityMapClientType cte_pmfmct
    INNER JOIN Show.SOLRProvider s ON s.ProviderCode = cte_pmfmct.ProviderCode
    GROUP BY s.ProviderID
),

CTE_ProviderFacilitySponsorshipXML AS (
    SELECT
        s.ProviderID,
        iff(Type is not null,'<Type>' || Type || '</Type>','') ||
iff(nm is not null,'<nm>' || nm || '</nm>','') ||
iff(facCd is not null,'<facCd>' || facCd || '</facCd>','') ||
iff(facNm is not null,'<facNm>' || facNm || '</facNm>','') ||
iff(facSt is not null,'<facSt>' || facSt || '</facSt>','') ||
iff(phoneL is not null,'<phoneL>' || phoneL || '</phoneL>','') ||
iff(mobilePhoneL is not null,'<mobilePhoneL>' || mobilePhoneL || '</mobilePhoneL>','') ||
iff(urlL is not null,'<urlL>' || urlL || '</urlL>','') ||
iff(imageL is not null,'<imageL>' || imageL || '</imageL>','') ||
iff(quaMsgL is not null,'<quaMsgL>' || quaMsgL || '</quaMsgL>','') ||
iff(tabletPhoneL is not null,'<tabletPhoneL>' || tabletPhoneL || '</tabletPhoneL>','') ||
iff(desktopPhoneL is not null,'<desktopPhoneL>' || desktopPhoneL || '</desktopPhoneL>','') ||
 AS XMLValue
    FROM CTE_ProviderFacilitySponsorshipFinal cte_pfs
    INNER JOIN Show.SOLRProvider s ON s.ProviderCode = cte_pfs.ProviderCode
    GROUP BY s.ProviderID
),

CTE_SponsorshipXML AS (
    SELECT
        s.ProviderID,
        '<sponsorL>' || '<sponsor>' ||
        iff(a.ProductCode is not null,'<prCd>' || a.ProductCode || '</prCd>','') ||
iff(a.ProductGroupCode is not null,'<prGrCd>' || a.ProductGroupCode || '</prGrCd>','') ||
iff(a.compositePhone is not null,'<compositePhone>' || a.compositePhone || '</compositePhone>','') ||
 ||
        spn.XMLValue ||
        pcdp.XMLValue ||
        clCtrL.XMLValue ||
        CASE
            WHEN a.ProductCode IN (SELECT ProductCode FROM Base.Product WHERE ProductTypeCode = 'PRACTICE') THEN pdcprac.XMLValue
            WHEN a.ProductCode IN (SELECT ProductCode FROM Base.Product WHERE ProductTypeCode = 'MAP') THEN map.XMLValue
            ELSE pfs.XMLValue
        END ||
        '</sponsor>' || '</sponsorL>' AS XMLValue,
        a.AppointmentOptionDescription AS aptOptDesc
    FROM
        CTE_ProviderSponsorship a
        INNER JOIN Show.SOLRProvider s ON a.ProviderCode = s.ProviderCode
        INNER JOIN CTE_spnFeatXML spn ON s.ProviderID = spn.EntityID 
        INNER JOIN CTE_PCDPXML pcdp ON s.ProviderID = pcdp.ProviderID 
        INNER JOIN CTE_clCtrLXML clCtrL ON s.ProviderID = clCtrL.ProviderID
        INNER JOIN CTE_PracticePDCPRACXML pdcprac ON s.ProviderID = pdcprac.ProviderID
        INNER JOIN CTE_PracticeMAPXML map ON s.ProviderID = map.ProviderID
        INNER JOIN CTE_ProviderFacilitySponsorshipXML pfs ON s.ProviderID = pfs.ProviderID
        GROUP BY s.ProviderID, pcdp.XMLValue, clCtrL.XMLValue, pdcprac.XMLValue, spn.XMLValue,
                 map.XMLValue, pfs.XMLValue, a.ProductCode, a.ProductGroupCode, 
                 a.compositePhone, a.ProviderCode, a.AppointmentOptionDescription, 
                 a.ClientToProductID, a.ClientCode
),

------------------------SearchSponsorshipXML------------------------
Cte_Search_Spn_feat AS (
    SELECT DISTINCT
        ClientFeatureCode AS featCd,
        cf.ClientFeatureDescription AS featDesc,
        cfv.ClientFeatureValueCode AS featValCd,
        cfv.ClientFeatureValueDescription AS featValDesc,
        ce.EntityID,
        ctp.ClientToProductCode
    FROM Base.ClientEntityToClientFeature ce
    INNER JOIN Base.ClientToProduct ctp ON ctp.ClientToProductID = ce.EntityID
    INNER JOIN Base.Product p ON p.ProductId = ctp.ProductID
    INNER JOIN Base.EntityType et ON ce.EntityTypeID = et.EntityTypeID
    INNER JOIN Base.ClientFeatureToClientFeatureValue cfcfv ON ce.ClientFeatureToClientFeatureValueID = cfcfv.ClientFeatureToClientFeatureValueID
    INNER JOIN Base.ClientFeature cf ON cfcfv.ClientFeatureID = cf.ClientFeatureID
    INNER JOIN Base.ClientFeatureValue cfv ON cfv.ClientFeatureValueID = cfcfv.ClientFeatureValueID
    INNER JOIN Base.ClientFeatureGroup cfg ON cf.ClientFeatureGroupID = cfg.ClientFeatureGroupID
    WHERE et.EntityTypeCode = 'CLPROD'
    AND ClientFeatureCode IN ('FCRAB', 'FCBRL')
    AND cfv.ClientFeatureValueCode IN ('FVPSR', 'FVCLT')
    AND CASE WHEN cfv.ClientFeatureValueCode = 'FVNO' AND ClientFeatureCode IN ('FCOOMT', 'FCOOPSR', 'FCDOA') THEN 'REMOVE' ELSE 'KEEP' END = 'KEEP'
),

Cte_spn_feat AS (
 SELECT
        DISTINCT 
        entityid as clienttoproductid,
        featCd,
        featDesc,
        featValCd,
        featValDesc
    FROM
        cte_Search_spn_Feat
),

Cte_spn_feat_xml as (
 SELECT
        clienttoproductid,
        iff(featCd is not null,'<featCd>' || featCd || '</featCd>','') ||
iff(featDesc is not null,'<featDesc>' || featDesc || '</featDesc>','') ||
iff(featValCd is not null,'<featValCd>' || featValCd || '</featValCd>','') ||
iff(featValDesc is not null,'<featValDesc>' || featValDesc || '</featValDesc>','') ||
 AS XMLValue
    FROM
        cte_spn_feat
    GROUP BY
        clienttoproductid
),

Cte_search_spn as (
    SELECT DISTINCT	
        P.ProviderCode,
        MS.ClientCode,
        MS.ClientCode AS spnCd,
        MS.ClientName AS spnNm,
        MS.SafeHarborMsg AS safHarMsg,
        spn.xmlvalue AS spnFeatL
    FROM		Mid.ProviderSponsorship MS
    INNER JOIN	Base.Provider P ON P.ProviderCode = MS.ProviderCode
    INNER JOIN	Show.SolrProvider A ON A.Providerid = P.ProviderID
    INNER JOIN  Cte_spn_feat_xml spn ON spn.clienttoproductid = Ms.Clienttoproductid
    WHERE		MS.ProductGroupCode <> 'LID'
),

cte_office_pdc_prac as (
    SELECT DISTINCT
        ProviderCode,
        OfficeCode,
        OfficeCode AS offCd,
        OfficeName AS offNm,
        PhoneXML AS phoneL,
        MobilePhoneXML AS mobilePhoneL,
        URLXML AS urlL,
        ImageXML AS imageL,
        TabletPhoneXML AS tabletPhoneL,
        DesktopPhoneXML AS desktopPhoneL
    FROM
        Cte_ProviderPracticeOfficeSponsorship 
),

cte_office_pdc_prac_xml as (
    SELECT
        ProviderCode,
        OfficeCode,
        iff(offCd is not null,'<offCd>' || offCd || '</offCd>','') ||
iff(offNm is not null,'<offNm>' || offNm || '</offNm>','') ||
iff(phoneL is not null,'<phoneL>' || phoneL || '</phoneL>','') ||
iff(mobilePhoneL is not null,'<mobilePhoneL>' || mobilePhoneL || '</mobilePhoneL>','') ||
iff(urlL is not null,'<urlL>' || urlL || '</urlL>','') ||
iff(imageL is not null,'<imageL>' || imageL || '</imageL>','') ||
iff(tabletPhoneL is not null,'<tabletPhoneL>' || tabletPhoneL || '</tabletPhoneL>','') ||
iff(desktopPhoneL is not null,'<desktopPhoneL>' || desktopPhoneL || '</desktopPhoneL>','') ||
 AS XMLValue
    FROM
        cte_office_pdc_prac
    GROUP BY
        ProviderCode,
        OfficeCode
),

Cte_search_practice_pdc_prac as (
        SELECT DISTINCT		
            PPO.PracticeCode AS pracCd,
            PPO.PracticeName AS pracName,
            off.xmlvalue AS offl,
            PPO.ProviderCode
		FROM Cte_ProviderPracticeOfficeSponsorship PPO
		INNER JOIN	Base.Provider P ON P.ProviderCode = PPO.ProviderCode
		INNER JOIN	Show.SolrProvider Pt ON Pt.ProviderID = P.ProviderID
        INNER JOIN cte_office_pdc_prac_xml off ON off.providercode = ppo.providercode and off.officecode = ppo.officecode
),

cte_providerclientdisplaypartner2 as (
    SELECT
        dis.providercode,
        dis.clientcode,
        case when dis.displaypartnercode is null then 'HG' else dis.displaypartnercode end as displaypartnercode
    FROM cte_providerclientdisplaypartner as dis
    JOIN cte_providersponsorship as spo on dis.providercode = spo.providercode
    WHERE spo.productcode in ('MAP', 'PDCHSP')
),

-- Define the CTE for Search Spn data
cte_spn_search as (
    SELECT DISTINCT
        providercode,
        clientcode,
        spnCd,
        spnNm,
        safHarMsg,
        spnFeatL
    FROM
        Cte_search_spn 
),

cte_spn_search_xml as (
    SELECT
        providercode,
        clientcode,
        iff(spnCd is not null,'<spnCd>' || spnCd || '</spnCd>','') ||
iff(spnNm is not null,'<spnNm>' || spnNm || '</spnNm>','') ||
iff(safHarMsg is not null,'<safHarMsg>' || safHarMsg || '</safHarMsg>','') ||
iff(spnFeatL is not null,'<spnFeatL>' || spnFeatL || '</spnFeatL>','') ||
 AS XMLValue
    FROM
        cte_spn_search
    GROUP BY
        providercode,
        clientcode
),

cte_dpc_search as (
    SELECT DISTINCT
        ProviderCode,
        ClientCode,
        DisplayPartnerCode as dpcd
    FROM
        cte_providerclientdisplaypartner2 
),

cte_dpc_search_xml as (
    SELECT
        ProviderCode,
        ClientCode,
        iff(dpcd is not null,'<dpcd>' || dpcd || '</dpcd>','') ||
 AS XMLValue
    FROM
        cte_dpc_search
    GROUP BY
        ProviderCode,
        ClientCode
),

cte_disp1_search as (
    SELECT
        ProviderCode,  
        pracCd,
        pracName,
        offL
    FROM
        Cte_search_practice_pdc_prac  
),

cte_disp1_search_xml as (
    SELECT
        ProviderCode,
        iff(pracCd is not null,'<pracCd>' || pracCd || '</pracCd>','') ||
iff(pracName is not null,'<pracName>' || pracName || '</pracName>','') ||
iff(offL is not null,'<offL>' || offL || '</offL>','') ||
 AS XMLValue
    FROM
        cte_disp1_search
    GROUP BY
        ProviderCode
),

cte_disp2_search as (
    SELECT 
        ProviderCode,
        Type,
        cd,
        nm,
        to_varchar(st) as st,
        to_varchar(phoneL) as phonel,
        to_varchar(mobilePhoneL) as mobilephonel,
        to_varchar(urlL) as urll,
        NULL as imageL,
        to_varchar(quaMsgL) as quamsgl,
        to_varchar(tabletPhoneL) as tabletphonel,
        to_varchar(desktopPhoneL) as desktopphonel,
        offL
    FROM cte_practicemap 
    UNION ALL
    SELECT 
        ProviderCode,
        Type,
        cd,
        nm,
        st,
        phoneL,
        mobilePhoneL,
        urlL,
        imageL,
        quaMsgL,
        tabletPhoneL,
        desktopPhoneL,
        to_varchar(offL) as offl
    FROM cte_facilitymap 
    UNION ALL
    SELECT 
        ProviderCode,
        Type,
        cd,
        nm,
        st,
        phoneL,
        mobilePhoneL,
        urlL,
        imageL,
        quaMsgL,
        tabletPhoneL,
        desktopPhoneL,
        offL
    FROM cte_clienttype 
),

cte_disp2_search_xml as (
    SELECT
        ProviderCode,
        iff(Type is not null,'<Type>' || Type || '</Type>','') ||
iff(cd is not null,'<cd>' || cd || '</cd>','') ||
iff(nm is not null,'<nm>' || nm || '</nm>','') ||
iff(st is not null,'<st>' || st || '</st>','') ||
iff(phoneL is not null,'<phoneL>' || phoneL || '</phoneL>','') ||
iff(mobilePhoneL is not null,'<mobilePhoneL>' || mobilePhoneL || '</mobilePhoneL>','') ||
iff(urlL is not null,'<urlL>' || urlL || '</urlL>','') ||
iff(imageL is not null,'<imageL>' || imageL || '</imageL>','') ||
iff(quaMsgL is not null,'<quaMsgL>' || quaMsgL || '</quaMsgL>','') ||
iff(tabletPhoneL is not null,'<tabletPhoneL>' || tabletPhoneL || '</tabletPhoneL>','') ||
iff(desktopPhoneL is not null,'<desktopPhoneL>' || desktopPhoneL || '</desktopPhoneL>','') ||
iff(offL is not null,'<offL>' || offL || '</offL>','') ||
 AS XMLValue
    FROM
        cte_disp2_search
    GROUP BY
        ProviderCode
),

cte_disp3_search as (
    SELECT
        providercode,
        clientcode,
        null AS Type,
        null AS nm,
        FacilityCode AS facCd,
        FacilityName AS facNm,
        FacilityState AS facSt,
        PhoneXML AS phoneL,
        MobilePhoneXML AS mobilePhoneL,
        URLXML AS urlL,
        ImageXML AS imageL,
        QualityMessageXML AS quaMsgL,
        TabletPhoneXML AS tabletPhoneL,
        DesktopPhoneXML AS desktopPhoneL
    FROM
        CTE_ProviderFacilitySponsorship 
    WHERE
        ProductGroupCode <> 'LID'
    UNION ALL
    SELECT
        ProviderCode,
        ClientCode,
        Type,
        nm,
        null AS facCd,
        null AS facNm,
        null AS facSt,
        phoneL,
        mobilePhoneL,
        urlL,
        imageL,
        quaMsgL,
        tabletPhoneL,
        desktopPhoneL
    FROM
        Cte_ClientType 
),

cte_disp3_search_xml as (
    SELECT
        providercode,
        clientcode,
        iff(Type is not null,'<Type>' || Type || '</Type>','') ||
iff(nm is not null,'<nm>' || nm || '</nm>','') ||
iff(facCd is not null,'<facCd>' || facCd || '</facCd>','') ||
iff(facNm is not null,'<facNm>' || facNm || '</facNm>','') ||
iff(facSt is not null,'<facSt>' || facSt || '</facSt>','') ||
iff(phoneL is not null,'<phoneL>' || phoneL || '</phoneL>','') ||
iff(mobilePhoneL is not null,'<mobilePhoneL>' || mobilePhoneL || '</mobilePhoneL>','') ||
iff(urlL is not null,'<urlL>' || urlL || '</urlL>','') ||
iff(imageL is not null,'<imageL>' || imageL || '</imageL>','') ||
iff(quaMsgL is not null,'<quaMsgL>' || quaMsgL || '</quaMsgL>','') ||
iff(tabletPhoneL is not null,'<tabletPhoneL>' || tabletPhoneL || '</tabletPhoneL>','') ||
iff(desktopPhoneL is not null,'<desktopPhoneL>' || desktopPhoneL || '</desktopPhoneL>','') ||
 AS XMLValue
    FROM
        cte_disp3_search
    GROUP BY
        providercode,
        clientcode
),


cte_search_sponsorship as (
    SELECT DISTINCT
        ps.providercode,
        ps.productcode as prcd,
        ps.productgroupcode as prgrcd,
        ps.compositePhone,
        CASE WHEN (SELECT COUNT(1) FROM cte_ProviderFacilitySponsorship as pfs JOIN mid.provider as p WHERE pfs.FacilityCode IS NOT NULL AND pfs.ProviderCode = p.ProviderCode) > 0 THEN 0 ELSE 1 END AS mtOfficeType,
        spn.xmlvalue as spn,
        dpc.xmlvalue as dpcl,
        CASE WHEN ps.ProductCode IN (select ProductCode FROM Base.Product WHERE ProductTypeCode = 'PRACTICE') THEN disp1.xmlvalue 
        WHEN ps.ProductCode IN (SELECT ProductCode FROM Base.Product WHERE ProductTypeCode = 'MAP') THEN disp2.xmlvalue
        ELSE disp3.xmlvalue end as displ,
        ps.appointmentoptiondescription as aptoptdesc
    FROM cte_providersponsorship ps
    JOIN cte_spn_search_xml spn on spn.providercode = ps.providercode and spn.clientcode = ps.clientcode
    JOIN cte_dpc_search_xml dpc on dpc.providercode = ps.providercode and dpc.clientcode = ps.clientcode
    JOIN cte_disp1_search_xml disp1 on disp1.providercode = ps.providercode
    JOIN cte_disp2_search_xml disp2 on disp2.providercode = ps.providercode
    JOIN cte_disp3_search_xml disp3 on disp3.providercode = ps.providercode and disp3.clientcode = ps.clientcode
    WHERE 
        ps.productgroupcode != 'LID'
),

cte_search_sponsorship_xml as (
SELECT
        ProviderCode, 
        iff(prcd is not null,'<prcd>' || prcd || '</prcd>','') ||
iff(prgrcd is not null,'<prgrcd>' || prgrcd || '</prgrcd>','') ||
iff(compositePhone is not null,'<compositePhone>' || compositePhone || '</compositePhone>','') ||
iff(mtOfficeType is not null,'<mtOfficeType>' || mtOfficeType || '</mtOfficeType>','') ||
iff(aptoptdesc is not null,'<aptoptdesc>' || aptoptdesc || '</aptoptdesc>','') ||
 AS XMLValue
    FROM
        cte_search_sponsorship
    GROUP BY
        ProviderCode
),

------------------------ProcedureXML------------------------

cte_prov_Proc AS (
    SELECT 
        etmt.EntityID, 
        mt.MedicalTermCode AS prC, 
        mt.MedicalTermDescription1 AS prD, 
        NULL AS prGD, 
        NULL AS lKey,
        etmt.NationalRankingA AS nrkA, 
        etmt.NationalRankingB AS nrkB, 
        etmt.SearchBoostExperience AS boostExp,
        etmt.FriendsAndFamilyDCPExperienceRatingPercent AS ffExpPscr,
        IFF(etmt.SearchBoostHospitalCohortQuality IS NOT NULL, etmt.SearchBoostHospitalCohortQuality, etmt.SearchBoostHospitalServiceLineQuality) AS boostQual,
        etmt.FriendsAndFamilyDCPQualityFacility AS ffQFac, 
        etmt.FriendsAndFamilyDCPQualityFacilityList AS ffQFacLst, 
        etmt.FriendsAndFamilyDCPQualityFacilityListLatLong AS ffQFacLatLongList,
        etmt.FriendsAndFamilyDCPQualityFacRatingPerList AS ffQFacScrLst,
        etmt.FriendsAndFamilyDCPQualityFacilityScoreList AS ffQFacHQList,
        etmt.FriendsAndFamilyDCPQualityZScore AS ffQZscr,
        etmt.FriendsAndFamilyDCPQualityRatingPercent AS ffQPscr, 
        etmt.FriendsAndFamilyDCPQualityCode AS ffQCd,
        CASE 
            WHEN etmt.FriendsAndFamilyDCPQualityCode IS NOT NULL AND rcp.CohortCode IS NOT NULL THEN 1
            WHEN etmt.FriendsAndFamilyDCPQualityCode IS NULL THEN NULL 
            ELSE 0 
        END AS IsCohort, 
        etmt.PatientCount AS vol,
        etmt.SourceSearch AS sSrch, 
        mt.VolumeIsCredible AS vCred, 
        mt.RefMedicalTermCode AS prRC, 
        mt.WebArticleURL AS aUrl,
        etmt.PatientCountIsFew, 
        etmt.MedicalTermID, 
        etmt.FFExpBoost, 
        etmt.FFQualityFaciltyWeightList AS FFHQualityWList, 
        etmt.FFHQualityWinWeight AS FFHQualityWinW
    FROM 
        Base.EntityToMedicalTerm etmt
        JOIN Show.solrProvider tprov ON etmt.EntityID = tprov.ProviderID
        JOIN Base.MedicalTerm mt ON etmt.MedicalTermID = mt.MedicalTermID
        JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID
        LEFT JOIN (
            SELECT DISTINCT CohortCode, ProcedureMedicalCode
            FROM Base.CohortToProcedure
        ) rcp ON rcp.CohortCode = etmt.FriendsAndFamilyDCPQualityCode AND rcp.ProcedureMedicalCode = mt.RefMedicalTermCode
    WHERE 
        mtt.MedicalTermTypeCode = 'Procedure' 
        AND COALESCE(etmt.IsPreview, 0) = 0
),

cte_prov_perf AS (
    SELECT 
        p.ProviderID, 
        emt.MedicalTermID, 
        MAX(to_decimal(stpm.Perform)) AS Perform
    FROM Base.ProviderToSpecialty pts
    JOIN cte_prov_Proc emt ON pts.ProviderID = emt.EntityID
    JOIN Base.SpecialtyToProcedureMedical stpm ON stpm.SpecialtyID = pts.SpecialtyID AND stpm.ProcedureMedicalID = emt.MedicalTermID
    JOIN Show.SolrProvider as p on p.providerid = pts.providerid
    WHERE 
        emt.PatientCountIsFew IS NOT NULL OR 
        emt.vol IS NOT NULL
    GROUP BY 
        p.ProviderID, 
        emt.MedicalTermID
),

cte_procedure as (
    SELECT 
        pp.providerid,
        p.prC, 
        p.prD, 
        p.prGD, 
        p.lKey,
        p.nrkA,
        p.nrkB, 
        p.boostExp, 
        p.ffExpPscr, 
        p.boostQual, 
        p.ffQFac,
        p.ffQFacLst, 
        p.ffQFacScrLst, 
        p.ffQFacHQList, 
        p.ffQFacLatLongList, 
        p.ffQZscr, 
        p.ffQPscr, 
        p.ffQCd, 
        p.IsCohort, 
        p.vol, 
        p.sSrch, 
        p.vCred, 
        p.prRC, 
        p.aUrl, 
        IFF(pp.ProviderID IS NULL, 1, pp.Perform) AS perform,
        p.FFExpBoost, 
        p.FFHQualityWList, 
        p.FFHQualityWinW
    FROM 
        cte_prov_Proc p
    LEFT JOIN 
        cte_prov_Perf pp ON pp.ProviderID = p.EntityID AND pp.MedicalTermID = p.MedicalTermID
    WHERE 
        providerid is not null
),

cte_procedure_xml as (
    SELECT
        ProviderID, 
        iff(prC is not null,'<prC>' || prC || '</prC>','') ||
iff(prD is not null,'<prD>' || prD || '</prD>','') ||
iff(prGD is not null,'<prGD>' || prGD || '</prGD>','') ||
iff(lKey is not null,'<lKey>' || lKey || '</lKey>','') ||
iff(nrkA is not null,'<nrkA>' || nrkA || '</nrkA>','') ||
iff(nrkB is not null,'<nrkB>' || nrkB || '</nrkB>','') ||
iff(boostExp is not null,'<boostExp>' || boostExp || '</boostExp>','') ||
iff(ffExpPscr is not null,'<ffExpPscr>' || ffExpPscr || '</ffExpPscr>','') ||
iff(boostQual is not null,'<boostQual>' || boostQual || '</boostQual>','') ||
iff(ffQFac is not null,'<ffQFac>' || ffQFac || '</ffQFac>','') ||
iff(ffQFacLst is not null,'<ffQFacLst>' || ffQFacLst || '</ffQFacLst>','') ||
iff(ffQFacScrLst is not null,'<ffQFacScrLst>' || ffQFacScrLst || '</ffQFacScrLst>','') ||
iff(ffQFacHQList is not null,'<ffQFacHQList>' || ffQFacHQList || '</ffQFacHQList>','') ||
iff(ffQFacLatLongList is not null,'<ffQFacLatLongList>' || ffQFacLatLongList || '</ffQFacLatLongList>','') ||
iff(ffQZscr is not null,'<ffQZscr>' || ffQZscr || '</ffQZscr>','') ||
iff(ffQPscr is not null,'<ffQPscr>' || ffQPscr || '</ffQPscr>','') ||
iff(ffQCd is not null,'<ffQCd>' || ffQCd || '</ffQCd>','') ||
iff(IsCohort is not null,'<IsCohort>' || IsCohort || '</IsCohort>','') ||
iff(vol is not null,'<vol>' || vol || '</vol>','') ||
iff(sSrch is not null,'<sSrch>' || sSrch || '</sSrch>','') ||
iff(vCred is not null,'<vCred>' || vCred || '</vCred>','') ||
iff(prRC is not null,'<prRC>' || prRC || '</prRC>','') ||
iff(aurl is not null,'<aurl>' || aurl || '</aurl>','') ||
iff(perform is not null,'<perform>' || perform || '</perform>','') ||
iff(FFExpBoost is not null,'<FFExpBoost>' || FFExpBoost || '</FFExpBoost>','') ||
iff(FFHQualityWList is not null,'<FFHQualityWList>' || FFHQualityWList || '</FFHQualityWList>','') ||
iff(FFHQualityWinW is not null,'<FFHQualityWinW>' || FFHQualityWinW || '</FFHQualityWinW>','') ||
 AS XMLValue
    FROM
        cte_procedure
    GROUP BY
        ProviderID
),
                
------------------------ConditionXML------------------------

Cte_prov_Cond AS (
    SELECT 
        ent.EntityID, 
        mt.MedicalTermCode AS condC,
        mt.MedicalTermDescription1 AS conD,
        NULL AS conGD,
        NULL AS lKey,
        ent.NationalRankingA AS nrkA,
        ent.NationalRankingB AS nrkB,
        ent.SearchBoostExperience AS boostExp,
        ent.FriendsAndFamilyDCPExperienceRatingPercent AS ffExpPscr,
        IFF(ent.SearchBoostHospitalCohortQuality IS NOT NULL, ent.SearchBoostHospitalCohortQuality, ent.SearchBoostHospitalServiceLineQuality) AS boostQual,
        ent.FriendsAndFamilyDCPQualityFacility AS ffQFac,
        ent.FriendsAndFamilyDCPQualityFacilityList AS ffQFacLst, 
        ent.FriendsAndFamilyDCPQualityFacilityListLatLong AS ffQFacLatLongList,
        ent.FriendsAndFamilyDCPQualityFacRatingPerList AS ffQFacScrLst,
        ent.FriendsAndFamilyDCPQualityFacilityScoreList AS ffQFacHQList,
        ent.FriendsAndFamilyDCPQualityZScore AS ffQZscr,
        ent.FriendsAndFamilyDCPQualityRatingPercent AS ffQPscr,
        ent.FriendsAndFamilyDCPQualityCode AS ffQCd,
        IFF(ent.FriendsAndFamilyDCPQualityCode IS NOT NULL AND rcc.CohortCode IS NOT NULL, 1, IFF(ent.FriendsAndFamilyDCPQualityCode IS NULL, NULL, 0)) AS IsCohort,
        ent.PatientCount AS vol,
        ent.SourceSearch AS sSrch,
        mt.VolumeIsCredible AS vCred,
        mt.RefMedicalTermCode AS conRC,
        mt.WebArticleURL AS aUrl,
        ent.PatientCountIsFew, 
        ent.MedicalTermID, 
        ent.FFExpBoost, 
        ent.FFQualityFaciltyWeightList AS FFHQualityWList, 
        ent.FFHQualityWinWeight AS FFHQualityWinW
    FROM
        Base.EntityToMedicalTerm ent
        JOIN Base.MedicalTerm mt ON ent.MedicalTermID = mt.MedicalTermID
        JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID
        LEFT JOIN (
            SELECT DISTINCT CohortCode, ConditionCode 
            FROM Base.CohortToCondition
        ) rcc ON rcc.CohortCode = ent.FriendsAndFamilyDCPQualityCode 
            AND rcc.ConditionCode = mt.RefMedicalTermCode
    WHERE
        mtt.MedicalTermTypeCode = 'Condition'
        AND IFF(ent.IsPreview IS NULL, 0, ent.IsPreview) = 0
),

Cte_prov_Treat AS (
    SELECT 
        pts.ProviderID, 
        emt.MedicalTermID, 
        MAX(CAST(stpm.Treat AS INT)) AS Treat
    FROM 
        Base.ProviderToSpecialty pts
    JOIN 
        cte_prov_Cond emt ON pts.ProviderID = emt.EntityID
    JOIN 
        Base.SpecialtyToCondition stpm ON stpm.SpecialtyID = pts.SpecialtyID AND stpm.ConditionID = emt.MedicalTermID
    WHERE 
        emt.PatientCountIsFew IS NOT NULL OR emt.vol IS NOT NULL
    GROUP BY 
        pts.ProviderID, 
        emt.MedicalTermID
),

cte_condition as (
    SELECT DISTINCT
        cond.EntityID as ProviderID,
        cond.condC, 
        cond.conD, 
        cond.conGD, 
        cond.lKey, 
        cond.nrkA, 
        cond.nrkB, 
        cond.boostExp, 
        cond.ffExpPscr, 
        cond.boostQual, 
        cond.ffQFac, 
        cond.ffQFacLst,
        cond.ffQFacScrLst, 
        cond.ffQFacHQList, 
        cond.ffQFacLatLongList, 
        cond.ffQZscr, 
        cond.ffQPscr, 
        cond.ffQCd, 
        cond.IsCohort, 
        cond.vol, 
        cond.sSrch, 
        cond.vCred, 
        cond.conRC,
        cond.aUrl, 
        IFF(treat.ProviderID IS NULL, 1, treat.Treat) AS treat,
        cond.FFExpBoost, 
        cond.FFHQualityWList, 
        cond.FFHQualityWinW
    FROM
        show.solrprovider p 
        JOIN cte_prov_Cond cond on p.providerid = cond.entityid
        LEFT JOIN cte_prov_Treat treat ON treat.ProviderID = cond.EntityID AND treat.MedicalTermID = cond.MedicalTermID
),

cte_condition_xml as (
    SELECT
        ProviderID,
        iff(condc is not null,'<condc>' || condc || '</condc>','') ||
iff(conD is not null,'<conD>' || conD || '</conD>','') ||
iff(conGD is not null,'<conGD>' || conGD || '</conGD>','') ||
iff(lKey is not null,'<lKey>' || lKey || '</lKey>','') ||
iff(nrkA is not null,'<nrkA>' || nrkA || '</nrkA>','') ||
iff(nrkB is not null,'<nrkB>' || nrkB || '</nrkB>','') ||
iff(boostExp is not null,'<boostExp>' || boostExp || '</boostExp>','') ||
iff(ffExpPscr is not null,'<ffExpPscr>' || ffExpPscr || '</ffExpPscr>','') ||
iff(boostQual is not null,'<boostQual>' || boostQual || '</boostQual>','') ||
iff(ffQFac is not null,'<ffQFac>' || ffQFac || '</ffQFac>','') ||
iff(ffQFacLst is not null,'<ffQFacLst>' || ffQFacLst || '</ffQFacLst>','') ||
iff(ffQFacScrLst is not null,'<ffQFacScrLst>' || ffQFacScrLst || '</ffQFacScrLst>','') ||
iff(ffQFacHQList is not null,'<ffQFacHQList>' || ffQFacHQList || '</ffQFacHQList>','') ||
iff(ffQFacLatLongList is not null,'<ffQFacLatLongList>' || ffQFacLatLongList || '</ffQFacLatLongList>','') ||
iff(ffQZscr is not null,'<ffQZscr>' || ffQZscr || '</ffQZscr>','') ||
iff(ffQPscr is not null,'<ffQPscr>' || ffQPscr || '</ffQPscr>','') ||
iff(ffQCd is not null,'<ffQCd>' || ffQCd || '</ffQCd>','') ||
iff(IsCohort is not null,'<IsCohort>' || IsCohort || '</IsCohort>','') ||
iff(vol is not null,'<vol>' || vol || '</vol>','') ||
iff(sSrch is not null,'<sSrch>' || sSrch || '</sSrch>','') ||
iff(vCred is not null,'<vCred>' || vCred || '</vCred>','') ||
iff(conRC is not null,'<conRC>' || conRC || '</conRC>','') ||
iff(aUrl is not null,'<aUrl>' || aUrl || '</aUrl>','') ||
iff(treat is not null,'<treat>' || treat || '</treat>','') ||
iff(FFExpBoost is not null,'<FFExpBoost>' || FFExpBoost || '</FFExpBoost>','') ||
iff(FFHQualityWList is not null,'<FFHQualityWList>' || FFHQualityWList || '</FFHQualityWList>','') ||
iff(FFHQualityWinW is not null,'<FFHQualityWinW>' || FFHQualityWinW || '</FFHQualityWinW>','') ||
 AS XMLValue
    FROM
        cte_condition
    GROUP BY
        ProviderID
),

------------------------HealthInsuranceXML_v2------------------------

CTE_Health_Insurance_Product AS (
    SELECT
        P.ProviderID,
        PH.PayorName,
        replace(PH.ProductName, '\'', '') AS prodNm,
        PHtPT.ProductCode AS prodCd,
        H.PlanCode AS plCd,
        PT.PlanTypeCode AS plTpCd,
        1 AS srch
    FROM
        Mid.ProviderHealthInsurance PH
        INNER JOIN Base.HealthInsurancePlanToPlanType PHtPT ON PHtPT.HealthInsurancePlanToPlanTypeID = PH.HealthInsurancePlanToPlanTypeID
        INNER JOIN Base.HealthInsurancePlan H ON PHtPT.HealthInsurancePlanID = H.HealthInsurancePlanID
        INNER JOIN Base.HealthInsurancePlanType PT ON PHtPT.HealthInsurancePlanTypeID = PT.HealthInsurancePlanTypeID
        INNER JOIN Show.SolrProvider P ON P.ProviderID = PH.ProviderID
),

CTE_Health_Insurance_Plan AS (
    SELECT DISTINCT
        P.ProviderID,
        PH.PayorName,
        replace(PH.ProductName, '\'', '') AS prodNm,
        PH.HealthInsurancePlanToPlanTypeID AS prodNmID,
        PH.Searchable AS srch,
        PH.PlanDisplayName AS plNm,
        PH.PlanTypeDisplayDescription AS plTp,
    FROM
        Mid.ProviderHealthInsurance PH
    JOIN
        Show.SolrProvider P ON P.ProviderID = PH.ProviderID

),

CTE_Health_Insurance_Base AS (
    SELECT DISTINCT
        replace(ph.PayorName, '\'', '') as payorname,
        po.PayorOrganizationName,
        ph.Searchable,
        ph.HealthInsurancePayorID,
        ph.PayorCode,
        ph.PayorProductCount,
        hpo.InsurancePayorCode,
        P.ProviderID
    FROM
        Mid.ProviderHealthInsurance ph
    JOIN
        (SELECT DISTINCT HealthInsurancePayorID, PayorCode, InsurancePayorCode, HealthInsurancePayorOrganizationID 
         FROM Base.HealthInsurancePayor) hpo ON ph.PayorCode = hpo.PayorCode
    JOIN
        Show.SolrProvider P ON P.ProviderID = ph.ProviderID
    LEFT JOIN
        Base.HealthInsurancePayorOrganization po ON po.HealthInsurancePayorOrganizationID = hpo.HealthInsurancePayorOrganizationID
),

cte_plan_xml as (
    SELECT
        ProviderID,
        payorname,
        iff(prodNm is not null,'<prodNm>' || prodNm || '</prodNm>','') ||
iff(prodNmID is not null,'<prodNmID>' || prodNmID || '</prodNmID>','') ||
iff(srch is not null,'<srch>' || srch || '</srch>','') ||
iff(plNm is not null,'<plNm>' || plNm || '</plNm>','') ||
iff(plTp is not null,'<plTp>' || plTp || '</plTp>','') ||
 AS XMLValue
    FROM
        cte_health_insurance_plan
    GROUP BY
        ProviderID,
        payorname
)
,


cte_product_xml as (
    SELECT
        ProviderID,
        payorname,
        iff(prodNm is not null,'<prodNm>' || prodNm || '</prodNm>','') ||
iff(prodCd is not null,'<prodCd>' || prodCd || '</prodCd>','') ||
iff(plCd is not null,'<plCd>' || plCd || '</plCd>','') ||
iff(plTpCd is not null,'<plTpCd>' || plTpCd || '</plTpCd>','') ||
iff(srch is not null,'<srch>' || srch || '</srch>','') ||
 AS XMLValue
    FROM
        Cte_Health_Insurance_Product
    GROUP BY
        ProviderID,
        payorname
),

CTE_Health_Insurnace_v2 as (
    SELECT DISTINCT
        p.ProviderID,
        base.PayorName AS paNm,
        base.PayorOrganizationName AS paOrgNm,
        base.Searchable AS srch,
        base.HealthInsurancePayorID AS paGUID,
        base.PayorCode AS paCd,
        base.PayorProductCount AS plCount,
        base.InsurancePayorCode AS paNewCd,
        -- to_varchar(replace(replace(
        -- (SELECT LISTAGG(cte.xmlvalue, '') WITHIN GROUP (ORDER BY cte.xmlvalue) 
        -- FROM cte_plan_xml cte 
        -- WHERE cte.providerid = p.providerid and cte.payorname = base.payorname)
        -- , '\"<', '<'), '>\"', '>')) AS pll,
        -- to_varchar(replace(replace(
        -- (SELECT LISTAGG(cte.xmlvalue, '') WITHIN GROUP (ORDER BY cte.xmlvalue) 
        -- FROM cte_product_xml cte 
        -- WHERE cte.providerid = p.providerid and cte.payorname = base.payorname)
        -- , '\"<', '<'), '>\"', '>')) AS prl,
        to_varchar(SELECT LISTAGG(cte.xmlvalue, '') WITHIN GROUP (ORDER BY cte.xmlvalue) 
        FROM cte_plan_xml cte 
        WHERE cte.providerid = p.providerid and cte.payorname = base.payorname) as pll,
        to_varchar(SELECT LISTAGG(cte.xmlvalue, '') WITHIN GROUP (ORDER BY cte.xmlvalue) 
        FROM cte_product_xml cte 
        WHERE cte.providerid = p.providerid and cte.payorname = base.payorname) as prl
    
    FROM
        Show.solrprovider as p 
        JOIN cte_health_insurance_base base on p.providerid = base.providerid
    WHERE
        base.HealthInsurancePayorID IS NOT NULL
)
,

CTE_Health_Insurnace_v2_xml as (
    SELECT
        ProviderID,
        '<paL><pa>' || iff(paNm is not null,'<paNm>' || paNm || '</paNm>','') ||
iff(paOrgNm is not null,'<paOrgNm>' || paOrgNm || '</paOrgNm>','') ||
iff(srch is not null,'<srch>' || srch || '</srch>','') ||
iff(paGUID is not null,'<paGUID>' || paGUID || '</paGUID>','') ||
iff(paCd is not null,'<paCd>' || paCd || '</paCd>','') ||
iff(plCount is not null,'<plCount>' || plCount || '</plCount>','') ||
iff(paNewCd is not null,'<paNewCd>' || paNewCd || '</paNewCd>','') ||
 || '<plL>' || pll || '</plL>' 
          || '<prL>' || prl || '</prL>' ||
          '</pa></paL>'
        AS XMLValue
    FROM
        CTE_Health_Insurnace_v2
    GROUP BY
        ProviderID,
        pll,
        prl
),


-----------------HealthInsuranceXML------------------------

cte_provider_health_insurance as (
    SELECT DISTINCT
        p.ProviderID,
        h.PayorName AS paNm,
        h.Searchable AS srch,
        h.PayorCode AS paCd
    FROM
        Mid.ProviderHealthInsurance h
        JOIN Show.solrprovider as p on p.providerid = h.providerid
),

cte_health_insurance_xml as (
    SELECT
        ProviderID,
        iff(paNm is not null,'<paNm>' || paNm || '</paNm>','') ||
iff(srch is not null,'<srch>' || srch || '</srch>','') ||
iff(paCd is not null,'<paCd>' || paCd || '</paCd>','') ||
 AS XMLValue
    FROM
        cte_provider_health_insurance
    GROUP BY
        ProviderID
),

------------------------MediaXML------------------------
Cte_Media as (
    SELECT
        DISTINCT pm.providerid,
        pm.MediaDate AS mDt,
        pm.MediaTitle AS mTit,
        pm.MediaPublisher AS mPub,
        REPLACE(pm.MediaSynopsis, '', '') AS mSyn,
        pm.MediaLink AS mLink,
        mt.MediaTypeCode AS mC,
        mt.MediaTypeDescription AS mD
    FROM
        Base.ProviderMedia pm
        JOIN Base.MediaType mt ON pm.MediaTypeID = mt.MediaTypeID
),
cte_Media_XML as (
    SELECT
        ProviderID,
        iff(mdt is not null,'<mdt>' || mdt || '</mdt>','') ||
iff(mTit is not null,'<mTit>' || mTit || '</mTit>','') ||
iff(mPub is not null,'<mPub>' || mPub || '</mPub>','') ||
iff(mSyn is not null,'<mSyn>' || mSyn || '</mSyn>','') ||
iff(mLink is not null,'<mLink>' || mLink || '</mLink>','') ||
iff(mC is not null,'<mC>' || mC || '</mC>','') ||
iff(mD is not null,'<mD>' || mD || '</mD>','') ||
 AS XMLValue
    FROM
        CTE_Media
    GROUP BY
        ProviderID
),
------------------------RecognitionXML------------------------

cte_recogsl as (
SELECT DISTINCT
    Providerid,
    ServiceLine AS recogSl
FROM   
    Mid.ProviderRecognition
),

cte_recogsl_xml as (
SELECT
        ProviderID,
        iff(recogsl is not null,'<recogsl>' || recogsl || '</recogsl>','') ||
 AS XMLValue
    FROM
        cte_recogsl
    GROUP BY
        ProviderID
),

cte_recogdl as (
SELECT DISTINCT
    pr.providerid,
    pr.FacilityName AS recogHosp,
	pr.FacilityCode recogHospID,
    xml.xmlvalue
FROM Mid.ProviderRecognition pr
JOIN cte_recogsl_xml as xml on xml.providerid = pr.providerid
),

cte_recogdl_xml as (
SELECT
        ProviderID,
        iff(recogHosp is not null,'<recogHosp>' || recogHosp || '</recogHosp>','') ||
iff(recogHospID is not null,'<recogHospID>' || recogHospID || '</recogHospID>','') ||
 AS XMLValue
    FROM
        cte_recogdl
    GROUP BY
        ProviderID
),

cte_recognition as (
SELECT DISTINCT
    pr.providerid,
    pr.RecognitionCode AS recogCd,
	pr.RecognitionDisplayName AS recogDName,
	xml.xmlvalue
FROM  Mid.ProviderRecognition pr
JOIN cte_recogdl_xml as xml on xml.providerid = pr.providerid
ORDER BY pr.RecognitionCode
),

cte_recognition_xml as (
SELECT
        ProviderID,
        iff(recogCd is not null,'<recogcd>' || recogCd || '</recogcd>','') ||
iff(recogDName is not null,'<recogdname>' || recogDName || '</recogdname>','') ||
 AS XMLValue
FROM
    cte_recognition
GROUP BY
    ProviderID
),

------------------------ProviderSpecialtyFacility5StarXML------------------------

cte_spec as (
SELECT DISTINCT
    ProviderId,
    LegacyKey AS lKey,
    SpecialtyCode AS spCd 
FROM Mid.ProviderSpecialtyFacilityServiceLineRating
),
cte_spec_xml as (
SELECT
        ProviderID,
        iff(lkey is not null,'<lkey>' || lkey || '</lkey>','') ||
iff(spcd is not null,'<spcd>' || spcd || '</spcd>','') ||
 AS XMLValue
FROM
    cte_spec
GROUP BY
    ProviderID
),

cte_provider_speciality_facility_5star as (
SELECT DISTINCT
    pr.providerid,
    pr.ServiceLineCode AS svcCd,
    pr.ServiceLineDescription AS svcNm,
    xml.xmlvalue
 FROM   Mid.ProviderSpecialtyFacilityServiceLineRating pr
 JOIN cte_spec_xml as xml on xml.providerid = pr.providerid
 WHERE  pr.ServiceLineStar = 5
),

cte_provider_speciality_facility_5star_xml as (
SELECT
        ProviderID,
        iff(svcCd is not null,'<svcCd>' || svcCd || '</svcCd>','') ||
iff(svcNm is not null,'<svcNm>' || svcNm || '</svcNm>','') ||
 AS XMLValue
FROM
    cte_provider_speciality_facility_5star
GROUP BY
    ProviderID
),

------------------------VideoXML------------------------

cte_video_xml as (
SELECT DISTINCT
    pv.providerid,
    CONCAT('<video>
            <vidL>
            <flash>
                <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"      codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,115,0"      id="i_051bb5a507614c37917aad1705f5dd93"      width="450"      height="392">
                <param name="movie" value="http://applications.fliqz.com/',  pv.ExternalIdentifier , '.swf"/>
                <param name="allowfullscreen" value="true" />
                <param name="menu" value="false" />
                <param name="bgcolor" value="#ffffff"/>
                <param name="wmode" value="window"/>
                <param name="allowscriptaccess" value="always"/>
                <param name="flashvars" value=" file=', pv.ExternalIdentifier , '"/>
                <embed name="i_f3fa611a238b4b14a65e4985373ead58"  src="http://applications.fliqz.com/', pv.ExternalIdentifier , '.swf" flashvars="file=',  pv.ExternalIdentifier , '"                 width="450"                 height="392"                 pluginspage="http://www.macromedia.com/go/getflashplayer"                 allowfullscreen="true"                 menu="false"                 bgcolor="#ffffff"                 wmode="window"                 allowscriptaccess="always"                 type="application/x-shockwave-flash"/>
                </object>
            </flash>
            </vidL>
        </video>') as xmlvalue
FROM Base.ProviderVideo AS pv 
JOIN Base.MediaContextType mc ON mc.MediaContextTypeID = pv.MediaContextTypeID
JOIN Base.MediaVideoHost mh ON mh.MediaVideoHostID = pv.MediaVideoHostID AND mh.MediaVideoHostCode = 'FLIQZ' 
),

------------------------VideoXML2------------------------
cte_video_xml2 as (
SELECT DISTINCT
    pv.providerid,
    CONCAT('<vidL>
                <vid>
                    <vidHostCd>', mh.MediaVideoHostCode, '</vidHostCd>
                    <vidContCd>', mc.MediaContextTypeCode, '</vidContCd>
                    <vidSrc>/video/',lower(pv.ExternalIdentifier), '</vidSrc>
                </vid>     
            </vidL>') as xmlvalue
FROM Base.ProviderVideo AS pv 
JOIN Base.MediaContextType mc ON mc.MediaContextTypeID = pv.MediaContextTypeID
JOIN Base.MediaVideoHost mh ON mh.MediaVideoHostID = pv.MediaVideoHostID AND mh.MediaVideoHostCode = 'FLIQZ' 
),


------------------------ImageXML------------------------

CTE_From_Temp_UpdateDate AS (
    SELECT 
        PI.Providerid,
        CASE WHEN LEFT(ExternalIdentifier, 1) = 'v'
            THEN RIGHT(ExternalIdentifier, LENGTH(ExternalIdentifier) - 1)
            ELSE ExternalIdentifier
        END AS ExternalIdentifier,
        ImagePath,
        Filename,
        MIN(LastUpdateDate) AS LastUpdateDate,
        MediaContextTypeID,
        MediaImageHostID
    FROM Base.ProviderImage PI
    INNER JOIN Show.SolrProvider P ON P.ProviderID = PI.ProviderID
    WHERE ImagePath IS NOT NULL
    GROUP BY 
    PI.ProviderId, 
    ExternalIdentifier, 
    ImagePath, 
    Filename,
    MediaContextTypeID,
    MediaImageHostID
),

CTE_Temp_Update_Date AS (
    SELECT
        ProviderId,
        IFNULL(ExternalIdentifier, CASE WHEN POSITION('v_' IN REVERSE(FileName)) > 0
            THEN REPLACE(SUBSTRING(FileName, LENGTH(FileName) - POSITION('v_' IN REVERSE(FileName)) + 2, LENGTH(FileName)), '.jpg', '')
            ELSE ''
        END) AS ExternalIdentifier,
        CASE WHEN LEFT(TRIM(ImagePath), 1) = '/' THEN '' ELSE '/' END || ImagePath || CASE WHEN RIGHT(TRIM(ImagePath), 1) = '/' THEN '' ELSE '/' END AS ImagePath,
        IFF(IS_INTEGER(TRY_CAST(IFNULL(ExternalIdentifier, CASE WHEN POSITION('v_' IN REVERSE(FileName)) > 0 THEN
            REPLACE(SUBSTRING(FileName, LENGTH(FileName) - POSITION('v_' IN REVERSE(FileName)) + 2, LENGTH(FileName)), '.jpg', '')
            ELSE '0'
        END) AS INT)) = 1, 1, 0) AS IsLegacy,
        MediaContextTypeID,
        MediaImageHostID,
        ExternalIdentifier AS OriginalExternalIdentifier,
        ImagePath AS OriginalImagePath,
        LastUpdateDate
    FROM CTE_From_Temp_UpdateDate
),

CTE_Temp_Provider_Image AS (
SELECT
    cte.ProviderId,
    ImagePath || CASE WHEN cte.IsLegacy = 1 THEN UPPER(P.ProviderCode) ELSE LOWER(P.ProviderCode) END || '_' || 'w60h80' || '_v' || ExternalIdentifier || '.jpg' AS imgU,
    'small' AS imgC,
    60 AS imgW,
    80 AS imgH,
    'image' AS imgA
FROM
    cte_temp_update_date cte
INNER JOIN
    Base.Provider P ON P.ProviderId = cte.ProviderID

UNION ALL

SELECT
    cte.ProviderId,
    ImagePath || CASE WHEN cte.IsLegacy = 1 THEN UPPER(P.ProviderCode) ELSE LOWER(P.ProviderCode) END || '_' || 'w90h120' || '_v' || ExternalIdentifier || '.jpg' AS imgU,
    'medium' AS imgC,
    90 AS imgW,
    120 AS imgH,
    'image' AS imgA
FROM
    cte_temp_update_date cte
INNER JOIN
    Base.Provider P ON P.ProviderId = cte.ProviderID
WHERE
    LENGTH(ExternalIdentifier) > 0

UNION ALL

SELECT
    cte.ProviderId,
    ImagePath || CASE WHEN cte.IsLegacy = 1 THEN UPPER(P.ProviderCode) ELSE LOWER(P.ProviderCode) END || '_' || 'w120h160' || '_v' || ExternalIdentifier || '.jpg' AS imgU,
    'large' AS imgC,
    120 AS imgW,
    160 AS imgH,
    'image' AS imgA
FROM
    cte_temp_update_date cte
INNER JOIN
    Base.Provider P ON P.ProviderId = cte.ProviderID
WHERE
    LENGTH(ExternalIdentifier) > 0

UNION ALL

SELECT
    cte.ProviderId,
    ImagePath || CASE WHEN cte.IsLegacy = 1 THEN UPPER(P.ProviderCode) ELSE LOWER(P.ProviderCode) END || '_' || 'w90h120.jpg' AS imgU,
    'medium' AS imgC,
    90 AS imgW,
    120 AS imgH,
    'image' AS imgA
FROM
    cte_temp_update_date cte
INNER JOIN
    Base.Provider P ON P.ProviderId = cte.ProviderID
WHERE
    cte.IsLegacy = 1
    AND LENGTH(ExternalIdentifier) = 0
),

CTE_Image_XML AS (
    SELECT
        ProviderId,
        iff(imgC is not null,'<imgC>' || imgC || '</imgC>','') ||
iff(imgU is not null,'<imgU>' || imgU || '</imgU>','') ||
iff(imgA is not null,'<imgA>' || imgA || '</imgA>','') ||
iff(imgW is not null,'<imgW>' || imgW || '</imgW>','') ||
iff(imgH is not null,'<imgH>' || imgH || '</imgH>','') ||
 AS XMLValue
    FROM
        CTE_Temp_Provider_Image
    GROUP BY
        ProviderId
),

------------------------AboutMeXML------------------------

cte_aboutme as (
    SELECT DISTINCT
        pam.ProviderID,
        am.AboutMeCode AS type,
        CASE WHEN am.DescriptionEdit = 1 AND IFNULL(pam.CustomAboutMeDescription, '') <> ''
            THEN pam.CustomAboutMeDescription
            ELSE IFNULL(am.AboutMeDescription, '')
        END AS title,
        am.DisplayOrder AS sort,
        -- pam.ProviderAboutMeText AS text,
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REPLACE(REPLACE(trim(REGEXP_REPLACE(pam.ProviderAboutMeText, '\\x00|\\x01|\\x02|\\x03|\\x04|\\x05|\\x06|\\x07|\\x08|\\x0B|\\x0C|\\x0E|\\x0F|\\x10|\\x11|\\x12|\\x13|\\x14|\\x15|\\x16|\\x17|\\x18|\\x19|\\x1A|\\x1B|\\x1C|\\x1D|\\x1E|\\x1F|\\&amp', '', 1, 0, 'e')),CHAR(UNICODE('\\u0060'))), ''), '[&/''''\\:\\\\~\\\\;\\\\|<>™•*?+®!–@{}\\\\[\\\\]()ñéí"’ #,\\.]', ''), '--', '-'), '\'', ''), '\"' , ''), CHAR(UNICODE('\\u0060')), ''), '{', ''), '}', '') as text,
        IFNULL(TO_DATE(pam.LastUpdatedDate), TO_DATE(pam.InsertedOn)) AS updDte
    FROM
        Base.AboutMe am
        JOIN Base.ProviderToAboutMe pam ON am.AboutMeID = pam.AboutMeID
),

cte_aboutme_xml as (
    SELECT
        ProviderID,
        iff(type is not null,'<type>' || type || '</type>','') ||
iff(title is not null,'<title>' || title || '</title>','') ||
iff(sort is not null,'<sort>' || sort || '</sort>','') ||
iff(text is not null,'<text>' || text || '</text>','') ||
iff(updDte is not null,'<updDte>' || updDte || '</updDte>','') ||
 AS XMLValue
    FROM
        cte_aboutme
    GROUP BY
        ProviderID
),

------------------------AvailabilityXML------------------------

cte_appointment_availability as (
    SELECT DISTINCT
        poaa.ProviderID,
        aa.AppointmentAvailabilityCode AS aptCd,
        aa.AppointmentAvailabilityDescription AS aptD
    FROM
        Base.ProviderToAppointmentAvailability poaa
        JOIN Base.AppointmentAvailability aa ON aa.AppointmentAvailabilityID = poaa.AppointmentAvailabilityID
),

cte_availability_xml as (
    SELECT
        ProviderID,
        iff(aptCd is not null,'<aptCd>' || aptCd || '</aptCd>','') ||
iff(aptD is not null,'<aptD>' || aptD || '</aptD>','') ||
 AS XMLValue
    FROM
        cte_appointment_availability
    GROUP BY
        ProviderID
),

-----------------------ProcedureHierarchyXML--------------------

cte_procedure_hierarchy as (
    SELECT DISTINCT
        pp.ProviderID,
        dcp.MedicalInt AS prC,
        dcp.parentHier AS pHier,
        dcp.childHier AS cHier,
        dcp.parentSelfHier AS pSelfHier,
        dcp.parentByTwosHier AS pTwoHier,
        dcp.parentSelfByTwosHier AS pSelfTwoHier,
        dcp.ParentNameCodesAlpha AS pNmCdAlpha,
        dcp.ParentNameCodesInitials AS pNmCdInitial,
        pp.IsMapped AS isMap
    FROM
        CTE_ProviderProcedureXMLLoads pp -- temp schema before
        JOIN base.DCPHierarchy dcp ON dcp.MedicalInt = pp.ProcedureCode AND dcp.medicaltype = 'Procedure' -- dbo schema before
),

cte_procedure_hierarchy_xml as (
    SELECT
        ProviderID,
        iff(prC is not null,'<prC>' || prC || '</prC>','') ||
iff(pHier is not null,'<pHier>' || pHier || '</pHier>','') ||
iff(cHier is not null,'<cHier>' || cHier || '</cHier>','') ||
iff(pSelfHier is not null,'<pSelfHier>' || pSelfHier || '</pSelfHier>','') ||
iff(pTwoHier is not null,'<pTwoHier>' || pTwoHier || '</pTwoHier>','') ||
iff(pSelfTwoHier is not null,'<pSelfTwoHier>' || pSelfTwoHier || '</pSelfTwoHier>','') ||
iff(pNmCdAlpha is not null,'<pNmCdAlpha>' || pNmCdAlpha || '</pNmCdAlpha>','') ||
iff(pNmCdInitial is not null,'<pNmCdInitial>' || pNmCdInitial || '</pNmCdInitial>','') ||
iff(isMap is not null,'<isMap>' || isMap || '</isMap>','') ||
 AS XMLValue
    FROM
        cte_procedure_hierarchy
    GROUP BY
        ProviderID
),

--------------------------ConditionHierarchyXML--------------------------

cte_condition_hierarchy as (
    SELECT
        DISTINCT 
        pp.ProviderID,
        dcp.MedicalInt AS condC,
        dcp.parentHier AS pHier,
        dcp.childHier AS cHier,
        dcp.parentSelfHier AS pSelfHier,
        dcp.parentByTwosHier AS pTwoHier,
        dcp.parentSelfByTwosHier AS pSelfTwoHier,
        dcp.ParentNameCodesAlpha AS pNmCdAlpha,
        dcp.ParentNameCodesInitials AS pNmCdInitial,
        pp.IsMapped AS isMap
    FROM
        CTE_ProviderConditionXMLLoads pp -- temp schema before
        INNER JOIN base.DCPHierarchy dcp ON dcp.MedicalInt = pp.ConditionCode AND dcp.medicaltype = 'Condition' -- dbo schema before
),

cte_condition_hierarchy_xml as (
    SELECT
        ProviderID,
        iff(condC is not null,'<condC>' || condC || '</condC>','') ||
iff(pHier is not null,'<pHier>' || pHier || '</pHier>','') ||
iff(cHier is not null,'<cHier>' || cHier || '</cHier>','') ||
iff(pSelfHier is not null,'<pSelfHier>' || pSelfHier || '</pSelfHier>','') ||
iff(pTwoHier is not null,'<pTwoHier>' || pTwoHier || '</pTwoHier>','') ||
iff(pSelfTwoHier is not null,'<pSelfTwoHier>' || pSelfTwoHier || '</pSelfTwoHier>','') ||
iff(pNmCdAlpha is not null,'<pNmCdAlpha>' || pNmCdAlpha || '</pNmCdAlpha>','') ||
iff(pNmCdInitial is not null,'<pNmCdInitial>' || pNmCdInitial || '</pNmCdInitial>','') ||
iff(isMap is not null,'<isMap>' || isMap || '</isMap>','') ||
 AS XMLValue
    FROM
        cte_condition_hierarchy
    GROUP BY
        ProviderID
),

--------------------------ProcMappedXML--------------------------

cte_proc_mapped as (
    SELECT DISTINCT
        sp.ProviderID,
        mt.MedicalTermCode AS prC,
        s.SpecialtyCode || '/' || mt.MedicalTermDescription1 || '|' || mt.MedicalTermCode AS prcN
    FROM
        Base.SpecialtyToProcedureMedical stpm
        JOIN Base.MedicalTerm mt ON mt.MedicalTermID = stpm.ProcedureMedicalID
        JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID AND mtt.MedicalTermTypeCode = 'Procedure'
        JOIN Base.Specialty s ON stpm.SpecialtyID = s.SpecialtyID
        JOIN Base.ProviderToSpecialty pts ON pts.SpecialtyID = stpm.SpecialtyID
        JOIN Show.SolrProvider as sp on sp.providerid = pts.providerid
    WHERE 
        pts.SpecialtyIsRedundant = 0
        AND pts.IsSearchableCalculated = 1
        AND sp.ProviderId is not null
),

cte_proc_mapped_xml as (
    SELECT
        ProviderID,
        iff(prC is not null,'<prC>' || prC || '</prC>','') ||
iff(prcN is not null,'<prcN>' || prcN || '</prcN>','') ||
 AS XMLValue
    FROM
        cte_proc_mapped
    GROUP BY
        ProviderID
),

--------------------------CondMappedXML--------------------------

cte_cond_mapped as (
    SELECT DISTINCT
        sp.ProviderId,
        mt.MedicalTermCode AS cndC,
        s.SpecialtyCode || '/' || mt.MedicalTermDescription1 || '|' || mt.MedicalTermCode AS cndN,
    FROM
        Base.SpecialtyToCondition stc
        JOIN Base.MedicalTerm mt ON mt.MedicalTermID = stc.ConditionID
        JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID AND mtt.MedicalTermTypeCode = 'Condition'
        JOIN Base.Specialty s ON stc.SpecialtyID = s.SpecialtyID
        JOIN Base.ProviderToSpecialty pts ON pts.SpecialtyID = stc.SpecialtyID AND pts.SpecialtyIsRedundant = 0 AND pts.IsSearchableCalculated = 1
        JOIN Show.SolrProvider as sp on sp.providerid = pts.providerid
    WHERE sp.providerid is not null
),

cte_cond_mapped_xml as (
    SELECT
        ProviderId,
        iff(cndC is not null,'<cndC>' || cndC || '</cndC>','') ||
iff(cndN is not null,'<cndN>' || cndN || '</cndN>','') ||
 AS XMLValue
    FROM
        cte_cond_mapped
    GROUP BY
        ProviderId
),

--------------------------PracSpecHeirXML--------------------------

-- Define the CTE for extracting and transforming specialty data
cte_specialty_hierarchy as (
    SELECT
        p.providerid,
        spec.SpecialtyCode AS spCd,
        spec.SpecialtyCode || '/' || TRIM(spec.SpecialtyDescription) || '|' || spec.specialtycode AS prSpHeirBar
    FROM
        Base.SpecialtyGroup sgr
        JOIN Base.SpecialtyGroupToSpecialty sgs ON sgr.SpecialtyGroupID = sgs.SpecialtyGroupID
        JOIN Base.Specialty spec ON spec.SpecialtyID = sgs.SpecialtyID AND sgr.SpecialtyGroupDescription = spec.SpecialtyDescription
        JOIN base.providertospecialty as p on p.specialtyid = spec.specialtyid 
),

-- Convert CTE data to JSON string and then to XML format using iff(spCd is not null,'<spCd>' || spCd || '</spCd>','') ||
iff(prSpHeirBar is not null,'<prSpHeirBar>' || prSpHeirBar || '</prSpHeirBar>','') ||
,

--------------------------OASXML--------------------------	
cte_oas_partner AS (
    SELECT DISTINCT 
        ProviderId, 
        P.OASPartnerCode
    FROM Base.ProviderToClientToOASPartner O 
        INNER JOIN Base.OASPartner P ON P.OASPartnerId = O.OASPartnerId
),
cte_TempPartnerEntity AS (
    SELECT DISTINCT 
        pte.primaryentityid as providerid,
        pte.PartnerCode,
        pte.PartnerDescription,
        pte.PartnerTypeCode,
        pte.PartnerPrimaryEntityID,
        pte.OfficeCode,
        pte.PartnerSecondaryEntityID,
        pte.PartnerTertiaryEntityID,
        pte.FullURL,
        pte.PrimaryEntityID,
        pte.PartnerId,
        O.OASPartnerCode,
        pte.ExternalOASPartnerDescription
    FROM mid.PartnerEntity pte
    INNER JOIN Show.SolrProvider P ON P.ProviderId = pte.PrimaryEntityID
    LEFT JOIN cte_oas_partner O ON O.ProviderId = P.ProviderID
),

Cte_Oas as (
    SELECT DISTINCT 
        pte.PrimaryEntityId AS Providerid,
        pte.OASPartnerCode,
        pte.PartnerCode AS partCd,
        pte.PartnerDescription AS partDesc,
        pte.PartnerTypeCode AS partTyCd,
        pte.PartnerPrimaryEntityID AS partProvId,
        pte.OfficeCode AS offCd,
        pte.PartnerSecondaryEntityID AS partOffId,
        pte.PartnerTertiaryEntityID AS partPracId,
        pte.FullURL,
        pte.ExternalOASPartnerDescription AS ExternalOASPartner
        -- configL (always empty)
    FROM
        cte_TempPartnerEntity pte 
),

Cte_Oas_xml as (
    SELECT
        ProviderID, -- Ensure this is defined or adjust as needed for your context
        iff(OASPartnerCode is not null,'<OASPartnerCode>' || OASPartnerCode || '</OASPartnerCode>','') ||
iff(partCd is not null,'<partCd>' || partCd || '</partCd>','') ||
iff(partDesc is not null,'<partDesc>' || partDesc || '</partDesc>','') ||
iff(partTyCd is not null,'<partTyCd>' || partTyCd || '</partTyCd>','') ||
iff(partProvId is not null,'<partProvId>' || partProvId || '</partProvId>','') ||
iff(offCd is not null,'<offCd>' || offCd || '</offCd>','') ||
iff(partOffId is not null,'<partOffId>' || partOffId || '</partOffId>','') ||
iff(partPracId is not null,'<partPracId>' || partPracId || '</partPracId>','') ||
iff(FullURL is not null,'<FullURL>' || FullURL || '</FullURL>','') ||
iff(ExternalOASPartner is not null,'<ExternalOASPartner>' || ExternalOASPartner || '</ExternalOASPartner>','') ||
 AS XMLValue
    FROM
        cte_oas
    GROUP BY
        ProviderID -- This grouping must match your context's need to aggregate data
),



------------------------FacilityXML------------------------

cte_related_spec AS (
    SELECT
        DISTINCT 
        ats.awardcode AS awardid,
        s.SpecialtyCode || '|' AS SpecialtyCode
    FROM
        Base.AwardToSpecialty ats
        JOIN Base.Specialty s ON ats.SpecialtyCode = s.SpecialtyCode
        JOIN Base.ProviderToSpecialty pts ON pts.SpecialtyID = s.SpecialtyID
    WHERE
        pts.SpecialtyIsRedundant = 0
        AND pts.IsSearchableCalculated = 1
),

cte_related_spec_xml AS (
    SELECT
        awardid,
         AS XMLValue
    FROM
        cte_related_spec
    GROUP BY
        awardId
),

cte_related_parent_spec AS (
    SELECT
        ats.AwardCode AS Awardid,
        s.SpecialtyCode || ':' || psp.PracticingSpecialtyCode || '|' AS SpecialtyCode
    FROM
        Base.AwardToSpecialty ats
        JOIN Base.Specialty s ON ats.SpecialtyCode = s.SpecialtyCode
        JOIN Base.ProviderToSpecialty pts ON pts.SpecialtyID = s.SpecialtyID
        JOIN Base.SpecialtyGroupToSpecialty sgtos ON s.SpecialtyID = sgtos.SpecialtyID
        JOIN Base.SpecialtyGroup sg ON sg.SpecialtyGroupID = sgtos.SpecialtyGroupID
        JOIN Show.vwuPracticingSpecialtyToGroupSpecialtyPrimary psp ON sg.SpecialtyGroupCode = psp.RolledUpSpecialtyCode
    WHERE
        pts.SpecialtyIsRedundant = 0
        AND s.IsPediatricAdolescent = 0
        AND pts.IsSearchableCalculated = 1
        AND psp.PracticingSpecialtyCode <> s.SpecialtyCode
),

cte_related_parent_spec_xml AS (
    SELECT
        awardid,
         AS XMLValue
    FROM
        cte_related_parent_spec
    GROUP BY
        awardid
),

cte_related_child_spec AS (
    SELECT
        ats.awardcode AS awardid,
        j.SpecialtyCode || ':' || s.SpecialtyCode || '|' AS SpecialtyCode
    FROM
        Base.AwardToSpecialty ats
        JOIN Base.Specialty j ON ats.SpecialtyCode = j.SpecialtyCode
        JOIN Base.ProviderToSpecialty pts ON pts.SpecialtyID = j.SpecialtyID
        JOIN Show.vwuPracticingSpecialtyToGroupSpecialtyPrimary psp ON j.SpecialtyCode = psp.PracticingSpecialtyCode
        JOIN Base.SpecialtyGroup sg ON psp.RolledUpSpecialtyCode = sg.SpecialtyGroupCode
        JOIN Base.SpecialtyGroupToSpecialty sgtos ON sg.SpecialtyGroupID = sgtos.SpecialtyGroupID
        JOIN Base.Specialty s ON s.SpecialtyID = sgtos.SpecialtyID
    WHERE
        pts.SpecialtyIsRedundant = 0
        AND s.IsPediatricAdolescent = 0
        AND j.IsPediatricAdolescent = 0
        AND pts.IsSearchableCalculated = 1
        AND j.SpecialtyCode <> s.SpecialtyCode
),

cte_related_child_spec_xml AS (
    SELECT
        awardid,
         AS XMLValue
    FROM
        cte_related_child_spec
    GROUP BY
        awardid
),

cte_related_proc AS (
    SELECT DISTINCT
        atp.awardcode AS awardid,
        pp.ProcedureCode || '|' AS ProcedureCode
    FROM
        Base.AwardToProcedure atp
        JOIN Base.MedicalTerm mt ON atp.ProcedureMedicalID = mt.MedicalTermID
        JOIN CTE_ProviderProcedureXMLLoads pp ON mt.MedicalTermCode = pp.ProcedureCode
),

cte_related_proc_xml AS (
    SELECT
        awardid,
         AS XMLValue
    FROM
        cte_related_proc
    GROUP BY
        awardid
),

cte_related_cond AS (
    SELECT DISTINCT
        atc.awardcode AS awardid,
        pc.ConditionCode || '|' as conditioncode
    FROM
        Base.AwardToCondition atc
        JOIN Base.MedicalTerm mt ON atc.ConditionID = mt.MedicalTermID
        JOIN CTE_ProviderConditionXMLLoads pc ON mt.MedicalTermCode = pc.ConditionCode
),

cte_related_cond_xml AS (
    SELECT
        awardid,
         AS XMLValue
    FROM
        cte_related_cond
    GROUP BY
        awardid
),

cte_award AS (
SELECT	
    x.facilityid,
    y.AwardCode AS awCd, 
    w.AwardCategoryCode AS awTypCd,
    y.AwardDisplayName AS awNm, 
    x.DisplayDataYear AS dispAwYr,
    x.IsBestInd AS isBest,
    x.IsMaxYear AS isMaxYr,
    rspec.xmlvalue as relatedspec,
    rpar.xmlvalue as relatedparentspec,
    rchild.xmlvalue as relatedchildspec,
    rproc.xmlvalue as relatedproc,
    rcond.xmlvalue as relatedcond
FROM ERMART1.Facility_FacilityToAward x
    JOIN Base.Award y ON  x.AwardName = y.AwardName
    JOIN Base.AwardCategory w ON w.AwardCategoryID = y.AwardCategoryID
    LEFT JOIN ERMART1.Facility_ServiceLine z ON x.SpecialtyCode = z.ServiceLineID
    JOIN Cte_Related_spec_xml as rspec on rspec.awardid = x.awardid 
    JOIN Cte_Related_parent_Spec_xml as rpar on rpar.awardid = x.awardid
    JOIN cte_related_child_spec_xml as rchild on rchild.awardid = x.awardid
    JOIN Cte_related_proc_xml as rproc on rproc.awardid = x.awardid
    JOIN Cte_related_cond_xml as rcond on rcond.awardid = x.awardid
WHERE	
    x.IsMaxYear = 1
),

cte_award_xml AS (
 SELECT
        facilityid,
        iff(awCd is not null,'<awcd>' || awCd || '</awcd>','') ||
iff(awTypCd is not null,'<awtypcd>' || awTypCd || '</awtypcd>','') ||
iff(awNm is not null,'<awnm>' || awNm || '</awnm>','') ||
iff(dispAwYr is not null,'<dispawyr>' || dispAwYr || '</dispawyr>','') ||
iff(isBest is not null,'<isbest>' || isBest || '</isbest>','') ||
iff(isMaxYr is not null,'<ismaxyr>' || isMaxYr || '</ismaxyr>','') ||
iff(relatedspec is not null,'<relatedspec>' || relatedspec || '</relatedspec>','') ||
iff(relatedparentspec is not null,'<relatedparentspec>' || relatedparentspec || '</relatedparentspec>','') ||
iff(relatedchildspec is not null,'<relatedchildspec>' || relatedchildspec || '</relatedchildspec>','') ||
iff(relatedproc is not null,'<relatedproc>' || relatedproc || '</relatedproc>','') ||
iff(relatedcond is not null,'<relatedcond>' || relatedcond || '</relatedcond>','') ||
 AS XMLValue
    FROM
        cte_award
    GROUP BY
        facilityid
),

cte_related_spec2 as (
    SELECT DISTINCT
        i.CohortCode as procedureid,
        j.SpecialtyCode || '|' as specialtycode
    FROM
        Base.CohortToSpecialty i
        JOIN Base.Specialty j ON i.SpecialtyCode = j.SpecialtyCode
        JOIN Base.ProviderToSpecialty k ON k.SpecialtyID = j.SpecialtyID
    WHERE
        k.SpecialtyIsRedundant = 0
        AND k.IsSearchableCalculated = 1
),

cte_related_spec_xml2 as (
    SELECT
        procedureid,
         AS XMLValue
    FROM
        cte_related_spec2
    GROUP BY
        procedureid
),

cte_related_parent_spec2 as (
    SELECT
        i.cohortcode as procedureid,
        j.SpecialtyCode || ':' || d1.PracticingSpecialtyCode || '|' AS SpecialtyCode
    FROM
        Base.CohortToSpecialty i
        JOIN Base.Specialty j ON i.SpecialtyCode = j.SpecialtyCode
        JOIN Base.ProviderToSpecialty k ON k.SpecialtyID = j.SpecialtyID
        JOIN Base.SpecialtyGroupToSpecialty c1 ON j.SpecialtyID = c1.SpecialtyID
        JOIN Base.SpecialtyGroup a1 ON a1.SpecialtyGroupID = c1.SpecialtyGroupID
        JOIN Show.vwuPracticingSpecialtyToGroupSpecialtyPrimary d1 ON a1.SpecialtyGroupCode = d1.RolledUpSpecialtyCode
    WHERE
        j.IsPediatricAdolescent = 0
        AND k.SpecialtyIsRedundant = 0
        AND k.IsSearchableCalculated = 1
        AND d1.PracticingSpecialtyCode <> j.SpecialtyCode
),

cte_related_parent_spec_xml2 as (
    SELECT
        procedureid,
         AS XMLValue
    FROM
        cte_related_parent_spec2
    GROUP BY
        procedureid
),


cte_related_child_spec2 as (
    SELECT
        i.CohortCode as procedureid,
        j.SpecialtyCode || ':' || s.SpecialtyCode || '|' AS SpecialtyCode
    FROM
        Base.CohortToSpecialty i
        JOIN Base.Specialty j ON i.SpecialtyCode = j.SpecialtyCode
        JOIN Base.ProviderToSpecialty k ON k.SpecialtyID = j.SpecialtyID
        JOIN Show.vwuPracticingSpecialtyToGroupSpecialtyPrimary d1 ON j.SpecialtyCode = d1.PracticingSpecialtyCode
        JOIN Base.SpecialtyGroup a1 ON d1.RolledUpSpecialtyCode = a1.SpecialtyGroupCode
        JOIN Base.SpecialtyGroupToSpecialty c1 ON a1.SpecialtyGroupID = c1.SpecialtyGroupID
        JOIN Base.Specialty s ON s.SpecialtyID = c1.SpecialtyID
    WHERE
        j.IsPediatricAdolescent = 0
        AND s.IsPediatricAdolescent = 0
        AND k.SpecialtyIsRedundant = 0
        AND k.IsSearchableCalculated = 1
        AND j.SpecialtyCode <> s.SpecialtyCode
),

cte_related_child_spec_xml2 as (
    SELECT
        procedureid,
         AS XMLValue
    FROM
        cte_related_child_spec2
    GROUP BY
        procedureid
),


cte_related_proc2 as (
    SELECT DISTINCT
        g.CohortCode as procedureid,
        h.ProcedureCode || '|' as procedurecode
    FROM
        Base.CohortToProcedure g
        JOIN Base.MedicalTerm i ON g.ProcedureMedicalID = i.MedicalTermID
        JOIN CTE_ProviderProcedureXMLLoads h ON i.MedicalTermCode = h.ProcedureCode
),

cte_related_proc_xml2 as (
    SELECT
        procedureid,
         AS XMLValue
    FROM
        cte_related_proc2
    GROUP BY
        procedureid
),

cte_related_cond2 AS (
    SELECT DISTINCT
        atc.cohortcode as procedureid,
        pc.ConditionCode || '|' as conditioncode
    FROM
        Base.CohortToCondition atc
        JOIN Base.MedicalTerm mt ON atc.ConditionID = mt.MedicalTermID
        JOIN CTE_ProviderConditionXMLLoads pc ON mt.MedicalTermCode = pc.ConditionCode
),

cte_related_cond_xml2 AS (
    SELECT
        procedureid,
         AS XMLValue
    FROM
        cte_related_cond2
    GROUP BY
        procedureid
),

cte_ratings AS (
    SELECT DISTINCT 
        fpr.facilityid,
        proc.ProcedureID AS pCd, 
        proc.ProcedureDescription AS pNm, 
        'SL' + sl.ServiceLineID AS svcCd,
        sl.ServiceLineDescription AS svcNm,
        proc.RatingMethod AS rMth, 
        CASE 
            WHEN fpr.ProcedureID = 'OB1' THEN 1
        END AS mcare,
        fpr.DataYear AS rYr, 
        fpr.DisplayDataYear AS rDispYr,
        fpr.OverallSurvivalStar AS rStr, 
        fpr.OverallRecovery30Star AS rStr30,
        rspec.xmlvalue AS relatedspec,
        rpar.xmlvalue AS relatedparentspec,
        rchild.xmlvalue AS relatedchildspec,
        rproc.xmlvalue AS relatedproc,
        rcond.xmlvalue AS relatedcond
    FROM	
        ERMART1.Facility_FacilityToProcedureRating fpr
        JOIN ERMART1.Facility_vwuFacilityHGDisplayProcedures vfdp ON fpr.ProcedureID = vfdp.ProcedureID AND fpr.RatingSourceID = vfdp.RatingSourceID
        JOIN ERMART1.Facility_Procedure proc ON fpr.ProcedureID = proc.ProcedureID
        JOIN ERMART1.Facility_ProcedureToServiceLine ptsl ON fpr.ProcedureID = ptsl.ProcedureID
        JOIN ERMART1.Facility_ServiceLine sl ON ptsl.ServiceLineID = sl.ServiceLineID
        JOIN Cte_Related_spec_xml2 AS rspec ON rspec.procedureid = proc.procedureid
        JOIN Cte_Related_parent_Spec_xml2 AS rpar ON rpar.procedureid = proc.procedureid
        JOIN cte_related_child_spec_xml2 AS rchild ON rchild.procedureid = proc.procedureid
        JOIN Cte_related_proc_xml2 AS rproc ON rproc.procedureid = proc.procedureid
        JOIN Cte_related_cond_xml2 AS rcond ON rcond.procedureid = proc.procedureid
    WHERE	
        fpr.IsMaxYear = 1
),



cte_ratings_xml as (
    SELECT
        facilityid,
        iff(pcd is not null,'<pcd>' || pcd || '</pcd>','') ||
iff(pnm is not null,'<pnm>' || pnm || '</pnm>','') ||
iff(svccd is not null,'<svccd>' || svccd || '</svccd>','') ||
iff(svcnm is not null,'<svcnm>' || svcnm || '</svcnm>','') ||
iff(rmth is not null,'<rmth>' || rmth || '</rmth>','') ||
iff(mcare is not null,'<mcare>' || mcare || '</mcare>','') ||
iff(ryr is not null,'<ryr>' || ryr || '</ryr>','') ||
iff(rdispyr is not null,'<rdispyr>' || rdispyr || '</rdispyr>','') ||
iff(rstr is not null,'<rstr>' || rstr || '</rstr>','') ||
iff(relatedspec is not null,'<relatedspec>' || relatedspec || '</relatedspec>','') ||
iff(relatedparentspec is not null,'<relatedparentspec>' || relatedparentspec || '</relatedparentspec>','') ||
iff(relatedchildspec is not null,'<relatedchildspec>' || relatedchildspec || '</relatedchildspec>','') ||
iff(relatedproc is not null,'<relatedproc>' || relatedproc || '</relatedproc>','') ||
iff(relatedcond is not null,'<relatedcond>' || relatedcond || '</relatedcond>','') ||
 AS XMLValue
    FROM
        cte_ratings
    GROUP BY
        facilityid
),

cte_facility AS (
SELECT 
    pf.ProviderId,
    pf.FacilityCode AS fID,
    pf.LegacyKey AS fLegacyId,
    pf.FacilityName AS fNm,
    pf.ImageFilePath AS fLogo,
    pf.HasAward AS awrd,
    pf.AddressXML AS addrL,
    pf.PDCPhoneXML AS pdcPhoneL,
    pf.FacilityURL AS fUrl,
    pf.FacilityType AS fType,
    pf.FacilityTypeCode AS fTypeCd,
    pf.FacilitySearchType AS fSearchTyp,
    pf.FiveStarProcedureCount AS fiveStrCnt,
    f.ImageXML AS imageL,
    f.AwardCount AS awCnt,
    f.MedicalServicesInformation AS medSvc,
    (SELECT AnswerPercent
        FROM   ERMART1.Facility_FacilityToSurvey fs
        WHERE  fs.SurveyID = 1
            AND fs.QuestionID = 10
            AND fs.FacilityID = f.LegacyKey
    ) AS patientSatis,
    NULL AS topProcL,
    CASE 
        WHEN ps.ProductGroupCode = 'PDC' THEN '1'
        ELSE '0'
    END AS isPDC,
    pf.qualityScore,
    f.MissionStatement AS misson,
    aw.xmlvalue as awardxml,
    rat.xmlvalue as ratingsxml 
FROM Mid.ProviderFacility AS pf
    JOIN Mid.Facility f ON pf.FacilityID = f.FacilityID
    JOIN Mid.Provider p ON p.ProviderID = pf.ProviderID
    LEFT JOIN Mid.ProviderSponsorship ps ON p.ProviderCode = ps.ProviderCode AND f.FacilityCode = ps.FacilityCode
    JOIN Cte_award_xml as aw on aw.facilityid = pf.legacykey
    JOIN Cte_ratings_xml as rat on rat.facilityid = pf.legacykey
),

Cte_Facility_XML AS (
SELECT
        providerid,
        iff(fId is not null,'<fId>' || fId || '</fId>','') ||
iff(fLegacyId is not null,'<fLegacyId>' || fLegacyId || '</fLegacyId>','') ||
iff(fNm is not null,'<fNm>' || fNm || '</fNm>','') ||
iff(fLogo is not null,'<fLogo>' || fLogo || '</fLogo>','') ||
iff(awrd is not null,'<awrd>' || awrd || '</awrd>','') ||
iff(addrL is not null,'<addrL>' || addrL || '</addrL>','') ||
iff(pdcPhoneL is not null,'<pdcPhoneL>' || pdcPhoneL || '</pdcPhoneL>','') ||
iff(fUrl is not null,'<fUrl>' || fUrl || '</fUrl>','') ||
iff(fType is not null,'<fType>' || fType || '</fType>','') ||
iff(fTypeCd is not null,'<fTypeCd>' || fTypeCd || '</fTypeCd>','') ||
iff(fSearchTyp is not null,'<fSearchTyp>' || fSearchTyp || '</fSearchTyp>','') ||
iff(fiveStrCnt is not null,'<fiveStrCnt>' || fiveStrCnt || '</fiveStrCnt>','') ||
iff(imageL is not null,'<imageL>' || imageL || '</imageL>','') ||
iff(awCnt is not null,'<awCnt>' || awCnt || '</awCnt>','') ||
iff(medSvc is not null,'<medSvc>' || medSvc || '</medSvc>','') ||
iff(patientSatis is not null,'<patientSatis>' || patientSatis || '</patientSatis>','') ||
iff(topProcL is not null,'<topProcL>' || topProcL || '</topProcL>','') ||
iff(isPDC is not null,'<isPDC>' || isPDC || '</isPDC>','') ||
iff(qualityScore is not null,'<qualityScore>' || qualityScore || '</qualityScore>','') ||
iff(misson is not null,'<misson>' || misson || '</misson>','') ||
iff(awardxml is not null,'<awardxml>' || awardxml || '</awardxml>','') ||
iff(ratingsxml is not null,'<ratingsxml>' || ratingsxml || '</ratingsxml>','') ||
 AS XMLValue
    FROM
        cte_facility
    GROUP BY
        providerid
),


------------------------APIXML------------------------

-- The same update is already included in previous updates (update_statement_20)

------------------------DEAXML------------------------

cte_dea_identification as (
    SELECT DISTINCT
        ppi.ProviderID,
        ppi.IdentificationValue AS deaN,
        ppi.EffectiveDate AS deaEfDt,
        ppi.ExpirationDate AS deaExDt
    FROM
        Base.ProviderIdentification ppi
        JOIN Base.IdentificationType it ON it.IdentificationTypeID = ppi.IdentificationTypeID
    WHERE 
        it.IdentificationTypeCode = 'DEA'
),

cte_dea_xml as (
    SELECT
        ProviderID,
        iff(deaN is not null,'<deaN>' || deaN || '</deaN>','') ||
iff(deaEfDt is not null,'<deaEfDt>' || deaEfDt || '</deaEfDt>','') ||
iff(deaExDt is not null,'<deaExDt>' || deaExDt || '</deaExDt>','') ||
 AS XMLValue
    FROM
        cte_dea_identification
    GROUP BY
        ProviderID
),

------------------------EmailAddressXML------------------------
-- Define the CTE for Provider Email data
cte_provider_email as (
    SELECT DISTINCT
        ProviderID,
        EmailAddress AS eAdd,
        EmailRank AS eRank
    FROM
        Base.ProviderEmail 
),

cte_email_address_xml as (
    SELECT
        ProviderID,
        iff(eAdd is not null,'<eAdd>' || eAdd || '</eAdd>','') ||
iff(eRank is not null,'<eRank>' || eRank || '</eRank>','') ||
 AS XMLValue
    FROM
        cte_provider_email
    GROUP BY
        ProviderID
),

------------------------DegreeXML------------------------
-- Define the CTE for Degree data
cte_degree as (
    SELECT DISTINCT
        ptd.ProviderID,
        d.DegreeAbbreviation AS degA,
        d.DegreeDescription AS degD,
        ptd.DegreePriority AS rank,
        TO_DATE(ptd.LastUpdateDate) AS updDte
    FROM
        Base.Degree d
        JOIN Base.ProviderToDegree ptd ON d.DegreeID = ptd.DegreeID
),

cte_degree_xml as (
    SELECT
        ProviderID,
        iff(degA is not null,'<degA>' || degA || '</degA>','') ||
iff(degD is not null,'<degD>' || degD || '</degD>','') ||
iff(rank is not null,'<rank>' || rank || '</rank>','') ||
iff(TO_CHAR is not null,'<updDte>' || TO_CHAR || '</updDte>','') ||
 AS XMLValue
    FROM
        cte_degree
    GROUP BY
        ProviderID
),

------------------------SurveyXML------------------------

cte_survey as (
    SELECT DISTINCT
        dP.ProviderID,
        sqa.SurveyQuestion AS qstn,
        sqa.SurveyQuestionGroupDescription AS qGrp,
        psqrm.SurveyAnswer AS ansId,
        ps.QuestionID AS qId,
        ps.QuestionSort AS qSrt,
        0 AS qDSrt, -- Originally ps.QuestionDisplaySort
        ps.ProviderAverageScore AS pScr,
        ps.QuestionCount AS qCnt,
        ps.NationalAverageScore AS nScr,
        (ps.ProviderAverageScore / 5) * 100 AS pScrPct,
        ROUND((((ps.ProviderAverageScore / 5) * 100) / 5), 0) * 5 AS pScrPctRnd,
        (ps.NationalAverageScore / 5) * 100 AS nScrPct,
        ROUND((((ps.NationalAverageScore / 5) * 100) / 5), 0) * 5 AS nScrPctRnd,
        ps.PositiveResponse AS nPosScr,
        ps.NegativeResponse AS nNegScr,
        psqrm.SurveyAnswerText AS range,
        nsqrm.SurveyAnswerText || ' National Average' AS nRange,
        IFF(psqrm.SurveyScore < nsqrm.SurveyScore AND psqrm.SurveyQuestionCode = '226', 'longer than national average',
            IFF(psqrm.SurveyScore > nsqrm.SurveyScore AND psqrm.SurveyQuestionCode = '226', 'shorter than national average',
                IFF(psqrm.SurveyScore = nsqrm.SurveyScore AND psqrm.SurveyQuestionCode = '226', 'same as national average',
                    IFF(psqrm.SurveyScore < nsqrm.SurveyScore, 'below national average',
                        IFF(psqrm.SurveyScore > nsqrm.SurveyScore, 'above national average',
                            IFF(psqrm.SurveyScore = nsqrm.SurveyScore, 'same as national average',
                                IFF(ps.ProviderAverageScore < ps.NationalAverageScore, 'below national average',
                                    IFF(ps.ProviderAverageScore > ps.NationalAverageScore, 'above national average',
                                        IFF(ps.ProviderAverageScore = ps.NationalAverageScore, 'same as national average', '')
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ) AS nScrCompr
    FROM
        Base.ProviderSurveyAggregate ps
        INNER JOIN base.Provider dP ON dP.ProviderCode = ps.ProviderCode
        INNER JOIN Show.SOLRProviderSurveyQuestionAndAnswer sqa ON ps.QuestionID = sqa.SurveyQuestionCode AND sqa.SurveyTempletVersion IS NULL
        LEFT JOIN Mid.SurveyQuestionRangeMapping psqrm ON ps.QuestionID = psqrm.SurveyQuestionCode AND ROUND(ps.ProviderAverageScore,0) = psqrm.SurveyScore
        LEFT JOIN Mid.SurveyQuestionRangeMapping nsqrm ON ps.QuestionID = nsqrm.SurveyQuestionCode AND ROUND(ps.NationalAverageScore,0) = nsqrm.SurveyScore
),

cte_survey_xml as (
    SELECT
        ProviderID,
        iff(qstn is not null,'<qstn>' || qstn || '</qstn>','') ||
iff(qGrp is not null,'<qGrp>' || qGrp || '</qGrp>','') ||
iff(ansId is not null,'<ansId>' || ansId || '</ansId>','') ||
iff(qId is not null,'<qId>' || qId || '</qId>','') ||
iff(qSrt is not null,'<qSrt>' || qSrt || '</qSrt>','') ||
iff(pScr is not null,'<pScr>' || pScr || '</pScr>','') ||
iff(qCnt is not null,'<qCnt>' || qCnt || '</qCnt>','') ||
iff(nScr is not null,'<nScr>' || nScr || '</nScr>','') ||
iff(pScrPct is not null,'<pScrPct>' || pScrPct || '</pScrPct>','') ||
iff(pScrPctRnd is not null,'<pScrPctRnd>' || pScrPctRnd || '</pScrPctRnd>','') ||
iff(nScrPct is not null,'<nScrPct>' || nScrPct || '</nScrPct>','') ||
iff(nScrPctRnd is not null,'<nScrPctRnd>' || nScrPctRnd || '</nScrPctRnd>','') ||
iff(nPosScr is not null,'<nPosScr>' || nPosScr || '</nPosScr>','') ||
iff(nNegScr is not null,'<nNegScr>' || nNegScr || '</nNegScr>','') ||
iff(range is not null,'<range>' || range || '</range>','') ||
iff(nRange is not null,'<nRange>' || nRange || '</nRange>','') ||
iff(nScrCompr is not null,'<nScrCompr>' || nScrCompr || '</nScrCompr>','') ||
 AS XMLValue
    FROM
        cte_survey
    GROUP BY
        ProviderID
),
------------------------NullOutSponsorship------------------------

------------------------ClinicalFocusDCPXML------------------------

cte_mtcode as (
    SELECT
        ProviderId,
        refMedicalTermCode AS MTCode,
        NationalRankingB AS NRankB,
        ClinicalFocusShortDescription
    FROM
        Base.ClinicalFocusDCP 
),

cte_mtcode_xml as (
    SELECT
        ProviderId,
        iff(MTCode is not null,'<MTCode>' || MTCode || '</MTCode>','') ||
iff(NRankB is not null,'<NRankB>' || NRankB || '</NRankB>','') ||
 AS XMLValue
    FROM
        cte_mtcode
    GROUP BY
        ProviderId
),

cte_clinical_focus_dcp as (
    SELECT
        C.providerid,
        C.ClinicalFocusShortDescription AS CLFdesc,
        cte.xmlvalue
    FROM
        Base.ClinicalFocusDCP C
        JOIN cte_mtcode_xml cte ON cte.providerid = C.providerid
),

cte_clinical_focus_dcp_xml as (
    SELECT
        providerid,
        iff(CLFdesc is not null,'<CLFdesc>' || CLFdesc || '</CLFdesc>','') ||
 AS XMLValue
    FROM
        cte_clinical_focus_dcp
    GROUP BY
        providerid
),


------------------------CLinicalFocusXML------------------------

cte_from_clinical_focus as (
SELECT DISTINCT 
    C.ProviderID, 
    dCF.ClinicalFocusId, 
    dCF.ClinicalFocusDescription
FROM Base.ProviderToClinicalFocus C
    INNER JOIN	Base.ClinicalFocus dCF ON dCF.ClinicalFocusID = C.ClinicalFocusID
),

cte_specialty_codes as (
    SELECT
        cfs.ClinicalFocusID,
        '|' || s.SpecialtyCode AS SpecialtyCode
    FROM
        Base.ClinicalFocusToSpecialty cfs
        INNER JOIN Base.Specialty s ON s.SpecialtyID = cfs.SpecialtyID
),

cte_concatenated_specialty_codes as (
    SELECT
        ClinicalFocusID,
        LISTAGG(SpecialtyCode, '') WITHIN GROUP (ORDER BY SpecialtyCode) AS CLFSpecId
    FROM
        cte_specialty_codes
    GROUP BY
        ClinicalFocusID
),

cte_specialty_codes_xml as (
    SELECT
        ClinicalFocusID,
        iff(CLFSpecId is not null,'<CLFSpecId>' || CLFSpecId || '</CLFSpecId>','') ||
 AS XMLValue
    FROM
        cte_concatenated_specialty_codes
    GROUP BY
        ClinicalFocusId
),

cte_mtcode2 as (
    SELECT
        ProviderId,
        ProviderDCPCount AS PDCP,
        CAST(AverageBPercentile AS INT) AS AvgP,
        ProviderDCPFillPercent AS CFProvFill,
        IsProviderDCPCountOverLowThreshold AS DCPThresh,
        ClinicalFocusScore AS CFScore,
        ProviderClinicalFocusRank AS CFRank
    FROM
        Base.ProviderToClinicalFocus 
),

cte_mtcode_xml as (
    SELECT
        ProviderId,
        iff(PDCP is not null,'<pdcp>' || PDCP || '</pdcp>','') ||
iff(avgp is not null,'<avgp>' || avgp || '</avgp>','') ||
iff(CFProvFill is not null,'<cfprovfill>' || CFProvFill || '</cfprovfill>','') ||
iff(DCPThresh is not null,'<dcpthresh>' || DCPThresh || '</dcpthresh>','') ||
iff(CFScore is not null,'<cfscore>' || CFScore || '</cfscore>','') ||
iff(CFRank is not null,'<cfrank>' || CFRank || '</cfrank>','') ||
 AS XMLValue
    FROM
        cte_mtcode2
    GROUP BY
        ProviderId
),

cte_clinical_focus as (
SELECT		
    C.ProviderId,
    C.ClinicalFocusId AS CLFId,
	C.ClinicalFocusDescription AS CLFDesc,
    code.xmlvalue as clfspecid,
    mt.xmlvalue as mtcode
FROM Cte_from_clinical_focus as c
    JOIN cte_specialty_codes_xml as code on code.clinicalfocusid = c.clinicalfocusid
    JOIN cte_mtcode_xml as mt on mt.providerid = c.providerid
),

cte_clinical_focus_xml as (
SELECT
        providerid,
        iff(clfId is not null,'<clfId>' || clfId || '</clfId>','') ||
iff(clfDesc is not null,'<clfDesc>' || clfDesc || '</clfDesc>','') ||
iff(clfspecid is not null,'<clfspecid>' || clfspecid || '</clfspecid>','') ||
 AS XMLValue
    FROM
        cte_clinical_focus
    GROUP BY
        providerid
),

------------------------TrainingXML------------------------

cte_training as (
    SELECT
        trn.ProviderID,
        t.TrainingCode AS trCd,
        t.TrainingDescription AS trD,
        trn.TrainingLink AS trUrl
    FROM
        Base.ProviderTraining trn
        INNER JOIN Base.Training t ON trn.TrainingID = t.TrainingID
    WHERE
        t.IsActive = 1
),

cte_training_xml as (
    SELECT
        ProviderID,
        iff(trCd is not null,'<trCd>' || trCd || '</trCd>','') ||
iff(trD is not null,'<trD>' || trD || '</trD>','') ||
iff(trUrl is not null,'<trUrl>' || trUrl || '</trUrl>','') ||
 AS XMLValue
    FROM
        cte_training
    GROUP BY
        ProviderID
),

------------------------ProviderURL------------------------

------------------------XML_Indicators------------------------

-- CASE WHEN PracticeOfficeXML IS NULL THEN 0 ELSE 1 END AS HasAddressXML,
-- CASE WHEN SpecialtyXML IS NULL THEN 0 ELSE 1 END AS HasSpecialtyXML,
-- CASE WHEN PracticingSpecialtyXML IS NULL THEN 0 ELSE 1 END AS HasPracticingSpecialtyXML,
-- CASE WHEN CertificationXML IS NULL THEN 0 ELSE 1 END AS HasCertificationXML,
-- CASE WHEN CarePhilosophy IS NULL THEN 0 ELSE 1 END AS HasPhilosophy,
-- CASE WHEN ProcedureXML IS NULL THEN 0 ELSE 1 END AS HasProcedureXML,
-- CASE WHEN ConditionXML IS NULL THEN 0 ELSE 1 END AS HasConditionXML,
-- CASE WHEN MalpracticeXML IS NULL THEN 0 ELSE 1 END AS HasMalpracticeXML,
-- CASE WHEN SanctionXML IS NULL THEN 0 ELSE 1 END AS HasSanctionXML,
-- CASE WHEN BoardActionXML IS NULL THEN 0 ELSE 1 END AS HasBoardActionXML,
-- CASE WHEN ProfessionalOrganizationXML IS NULL THEN 0 ELSE 1 END AS HasProfessionalOrganizationXML,
-- CASE WHEN ExpireCode IS NOT NULL THEN ExpireCode ELSE (CASE WHEN SpecialtyXML IS NULL OR PracticeOfficeXML IS NULL THEN 'RE' ELSE NULL END) END AS ExpireCode,
-- CASE WHEN ProviderSpecialtyFacility5StarXML IS NULL THEN 0 ELSE 1 END AS HasProviderSpecialtyFacility5StarXML,


------------------------LastUpdateDateXML------------------------
cte_last_update_date_xml as (
SELECT
    ProviderId,
    LastUpdateDatePayload as XMLValue
FROM Base.ProviderLastUpdateDate
),

------------------------SmartReferralXML------------------------

CTE_ClientImages AS (
SELECT DISTINCT 
    fd.ClientToProductID, 
    fd.ImageFilePath as Logo
FROM Base.vwuPDCClientDetail fd 
WHERE fd.ImageFilePath IS NOT NULL
),

CTE_Smart_Referral AS (
SELECT 	   
    p.ProviderID, 
    c.ClientCode as srCli, 
    ci.Logo as srLogo
FROM Show.SolrProvider as p   
INNER JOIN Base.Provider p2 ON p2.ProviderID = p.ProviderID
INNER JOIN Base.Client c ON c.ClientID = p2.SmartReferralClientID
INNER JOIN Base.ClientToProduct cp  ON cp.ClientID = c.ClientID
LEFT JOIN  CTE_ClientImages ci ON ci.ClientToProductID = cp.ClientToProductID
QUALIFY ROW_NUMBER() OVER (PARTITION BY p.ProviderID ORDER BY CASE WHEN ci.logo IS NOT NULL THEN 0 ELSE 1 END) = 1
),

cte_smart_referral_xml as (
    SELECT
        ProviderID,
        iff(srCli is not null,'<srCli>' || srCli || '</srCli>','') ||
iff(srLogo is not null,'<srLogo>' || srLogo || '</srLogo>','') ||
 AS XMLValue
    FROM
        cte_smart_referral
    GROUP BY
        ProviderID
)

SELECT
    p.providerid,
    to_Variant(tele.xmlvalue) AS telehealthxml,
    to_variant(ptype.xmlvalue) AS providertypexml,
    to_variant(poffice.xmlvalue) AS practiceofficexml,
    to_variant(addr.xmlvalue) AS addressxml,
    to_variant(spec.xmlvalue) AS specialtyxml,
    to_variant(pract_spec.xmlvalue) AS practicingspecialtyxml,
    to_variant(cert.xmlvalue) AS certificationxml,
    to_variant(edu.xmlvalue) AS educationxml,
    to_variant(org.xmlvalue) AS professionalorganizationxml,
    to_variant(licensexml.xmlvalue) AS licensexml,
    to_variant(lang.xmlvalue) AS languagexml,
    to_variant(mal.xmlvalue) AS malpracticexml,
    to_variant(sanctionxml.xmlvalue) AS sanctionxml,
    to_variant(baction.xmlvalue) AS boardactionxml,
    to_variant(adxml.xmlvalue) AS natladvertisingxml,
    to_variant(synd.xmlvalue) AS syndicationxml,
    to_variant(sponsor.xmlvalue) AS sponsorshipxml,
    to_variant(search_sponsorship.xmlvalue) AS searchsponsorshipxml,
    to_variant( proced.xmlvalue) as procedurexml,
    to_variant( cond.xmlvalue) as conditionxml,
    to_variant( hivw.xmlvalue) as healthinsurancexml_v2,
    to_variant( hins.xmlvalue) as healthinsurancexml,
    to_variant( media.xmlvalue) as mediaxml,
    to_variant( rec.xmlvalue) as recognitionxml,
    to_variant( fstar.xmlvalue) as ProviderSpecialtyFacility5StarXML,
    to_variant( video.xmlvalue) as VideoXML,
    to_variant( video2.xmlvalue) as videoxml2,
    to_variant( image.xmlvalue) as imagexml,
    -- case when image.xmlvalue is not null then 1 else 0 end as hasdisplayimage,
    to_variant( aboutme.xmlvalue) as aboutmexml,
    to_variant( avail.xmlvalue) as availabilityxml,
    to_variant( proch.xmlvalue) as procedurehierarchyxml,
    to_variant( condh.xmlvalue) as conditionhierarchyxml,
    to_variant( procm.xmlvalue) as procmappedxml,
    to_variant( condm.xmlvalue) as condmappedxml,
    to_variant( pspec.xmlvalue) as pracspecheirxml,
    to_variant( oas.xmlvalue) as oasxml,
    -- to_variant( facil.xmlvalue) as facilityxml, --needs ermart1
    to_variant( dea.xmlvalue) as deaxml,
    to_variant( emad.xmlvalue) as emailaddressxml,
    to_variant( degree.xmlvalue) as degreexml,
    to_variant( survey.xmlvalue) as surveyxml,
    to_variant( cfdcp.xmlvalue) as clinicalfocusdcpxml,
    to_variant( cfoc.xmlvalue) as clinicalfocusxml,
    to_variant( train.xmlvalue) as trainingxml,
    to_variant( ldate.xmlvalue) as lastupdatedatexml,
    -- smref.srcli as smartreferralclientcode,
    to_variant( smart.xmlvalue) as smartreferralxml,
    -- CASE WHEN media.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasMediaXML,
    -- CASE WHEN video2.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasVideoXML2,
    -- CASE WHEN fstar.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasProviderSpecialtyFacility5StarXML,
    -- CASE WHEN survey.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasSurveyXML,
    -- CASE WHEN dea.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasDEAXML,
    -- CASE WHEN emad.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasEmailAddressXML,
    -- CASE WHEN poffice.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasAddressXML,
    -- CASE WHEN spec.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasSpecialtyXML,
    -- CASE WHEN pract_spec.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasPracticingSpecialtyXML,
    -- CASE WHEN cert.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasCertificationXML,
    -- CASE WHEN p.CarePhilosophy IS NULL THEN 0 ELSE 1 END AS HasPhilosophy,
    -- CASE WHEN proced.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasProcedureXML,
    -- CASE WHEN cond.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasConditionXML,
    -- CASE WHEN mal.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasMalpracticeXML,
    -- CASE WHEN sanctionxml.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasSanctionXML,
    -- CASE WHEN baction.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasBoardActionXML,
    -- CASE WHEN org.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasProfessionalOrganizationXML,
    -- CASE WHEN p.ExpireCode IS NOT NULL THEN ExpireCode ELSE (CASE WHEN spec.xmlvalue IS NULL OR poffice.xmlvalue IS NULL THEN 'RE' ELSE NULL END) END AS ExpireCode
FROM Show.SolrProvider as P
    LEFT JOIN CTE_TelehealthXML AS tele ON tele.providerid = p.providerid
    LEFT JOIN CTE_ProviderTypeXML AS ptype ON ptype.providerid = p.providerid
    LEFT JOIN CTE_ProviderPracticeOfficeXML AS poffice ON poffice.providerid = p.providerid
    LEFT JOIN CTE_AddressXML AS addr ON addr.providerid = p.providerid
    LEFT JOIN CTE_SpecialtyXML AS spec ON spec.providerid = p.providerid
    LEFT JOIN cte_practicing_specialty_xml AS pract_spec ON pract_spec.providerid = p.providerid
    LEFT JOIN CTE_CertificationXML AS cert ON cert.providerid = p.providerid
    LEFT JOIN CTE_EducationXML AS edu ON edu.providerid = p.providerid
    LEFT JOIN CTE_ProfessionalOrganizationXML AS org ON org.providerid = p.providerid
    LEFT JOIN CTE_ProviderLicenseXML AS licensexml ON licensexml.providerid = p.providerid
    LEFT JOIN CTE_LanguageXML AS lang ON lang.providerid = p.providerid
    LEFT JOIN CTE_MalpracticeXML AS mal ON mal.providerid = p.providerid
    LEFT JOIN CTE_ProviderSanctionXML AS sanctionxml ON sanctionxml.providerid = p.providerid
    LEFT JOIN CTE_BoardActionXML AS baction ON baction.providerid = p.providerid
    LEFT JOIN CTE_NatlAdvertisingXML AS adxml ON adxml.providerid = p.providerid
    LEFT JOIN CTE_SyndicationXML AS synd ON synd.providerid = p.providerid
    LEFT JOIN CTE_SponsorshipXML AS sponsor ON sponsor.providerid = p.providerid
    LEFT JOIN cte_search_sponsorship_xml AS search_sponsorship ON search_sponsorship.providercode = p.providercode
    LEFT JOIN cte_procedure_xml as proced on proced.providerid = p.providerid
    LEFT JOIN Cte_condition_xml as  cond on cond.providerid = p.providerid
    LEFT JOIN CTE_Health_Insurnace_v2_xml as hivw on hivw.providerid = p.providerid
    LEFT JOIN cte_health_insurance_xml AS hins ON hins.providerid = p.providerid
    LEFT JOIN cte_media_xml AS media ON media.providerid = p.providerid
    LEFT JOIN cte_recognition_xml AS rec ON rec.providerid = p.providerid
    LEFT JOIN cte_provider_speciality_facility_5star_xml AS fstar ON fstar.providerid = p.providerid
    LEFT JOIN cte_video_xml AS video ON video.providerid = p.providerid
    LEFT JOIN cte_video_xml2 AS video2 ON   video2.providerid = p.providerid
    LEFT JOIN cte_image_xml AS image ON image.providerid = p.providerid
    LEFT JOIN cte_aboutme_xml AS aboutme ON aboutme.providerid = p.providerid
    LEFT JOIN cte_availability_xml AS avail ON avail.providerid = p.providerid
    LEFT JOIN cte_procedure_hierarchy_xml  AS proch ON proch.providerid = p.providerid
    LEFT JOIN cte_condition_hierarchy_xml  AS condh ON condh.providerid = p.providerid
    LEFT JOIN cte_proc_mapped_xml AS procm ON procm.providerid = p.providerid
    LEFT JOIN cte_cond_mapped_xml  AS condm ON condm.providerid = p.providerid
    LEFT JOIN cte_prac_spec_hier_xml AS pspec ON pspec.providerid = p.providerid
    LEFT JOIN cte_oas_xml  AS oas ON oas.providerid = p.providerid
    -- LEFT JOIN cte_facility_xml  AS facil ON facil.providerid = p.providerid
    LEFT JOIN cte_dea_xml AS dea ON dea.providerid = p.providerid
    LEFT JOIN cte_email_address_xml AS emad ON emad.providerid = p.providerid
    LEFT JOIN cte_degree_xml  AS degree ON degree.providerid = p.providerid
    LEFT JOIN cte_survey_xml  AS survey ON survey.providerid = p.providerid
    LEFT JOIN cte_clinical_focus_dcp_xml AS cfdcp ON cfdcp.providerid = p.providerid
    LEFT JOIN cte_clinical_focus_xml  AS cfoc ON cfoc.providerid = p.providerid
    LEFT JOIN cte_training_xml  AS train ON train.providerid = p.providerid
    LEFT JOIN cte_last_update_date_xml AS ldate ON ldate.providerid = p.providerid
    LEFT JOIN CTE_Smart_Referral  AS smref ON smref.providerid = p.providerid
    LEFT JOIN cte_smart_referral_xml  AS smart ON smart.providerid = p.providerid;



-- update:

UPDATE
    SET
        target.telehealthxml = source.telehealthxml,
        target.providertypexml = source.providertypexml,
        target.practiceofficexml = source.practiceofficexml,
        target.addressxml = source.addressxml,
        target.specialtyxml = source.specialtyxml,
        target.practicingspecialtyxml = source.practicingspecialtyxml,
        target.certificationxml = source.certificationxml,
        target.educationxml = source.educationxml,
        target.professionalorganizationxml = source.professionalorganizationxml,
        target.licensxml = source.licensexml,
        target.languagexml = source.languagexml,
        target.malpracticexml = source.malpracticexml,
        target.sanctionxml = source.sanctionxml,
        target.boardactionxml = source.boardactionxml,
        target.natladvertisingxml = source.natladvertisingxml,
        target.syndicationxml = source.syndicationxml,
        target.sponsorshipxml = source.sponsorshipxml,
        target.searchsponsorshipxml = source.searchsponsorshipxml,
        target.procedurexml = source.procedurexml,
        target.conditionxml = source.conditionxml,
        target.healthinsurancexml_v2 = source.healthinsurancexml_v2,
        target.healthinsurancexml = source.healthinsurancexml,
        target.mediaxml = source.mediaxml,
        target.recognitionxml = source.recognitionxml,
        target.ProviderSpecialtyFacility5StarXML = source.ProviderSpecialtyFacility5StarXML,
        target.VideoXML = source.VideoXML,
        target.videoxml2 = source.videoxml2,
        target.imagexml = source.imagexml,
        target.hasdisplayimage = source.hasdisplayimage,
        target.aboutmexml = source.aboutmexml,
        target.availabilityxml = source.availabilityxml,
        target.procedurehierarchyxml = source.procedurehierarchyxml,
        target.conditionhierarchyxml = source.conditionhierarchyxml,
        target.procmappedxml = source.procmappedxml,
        target.condmappedxml = source.condmappedxml,
        target.pracspecheirxml = source.pracspecheirxml,
        target.oasxml = source.oasxml,
        target.facilityxml = source.facilityxml,
        target.deaxml = source.deaxml,
        target.emailaddressxml = source.emailaddressxml,
        target.degreexml = source.degreexml,
        target.surveyxml = source.surveyxml,
        target.clinicalfocusdcpxml = source.clinicalfocusdcpxml,
        target.clinicalfocusxml = source.clinicalfocusxml,
        target.trainingxml = source.trainingxml,
        target.lastupdatedatexml = source.lastupdatedatexml,
        target.smartreferralclientcode = source.smartreferralclientcode,
        target.smartreferralxml = source.smartreferralxml,
        target.HasMediaXML = source.HasMediaXML,
        target.HasVideoXML2 = source.HasVideoXML2,
        target.HasProviderSpecialtyFacility5StarXML = source.HasProviderSpecialtyFacility5StarXML,
        target.HasSurveyXML = source.HasSurveyXML,
        target.HasDEAXML = source.HasDEAXML,
        target.HasEmailAddressXML = source.HasEmailAddressXML,
        target.HasAddressXML = source.HasAddressXML,
        target.HasSpecialtyXML = source.HasSpecialtyXML,
        target.HasPracticingSpecialtyXML = source.HasPracticingSpecialtyXML,
        target.HasCertificationXML = source.HasCertificationXML,
        target.HasPhilosophy = source.HasPhilosophy,
        target.HasProcedureXML = source.HasProcedureXML,
        target.HasConditionXML = source.HasConditionXML,
        target.HasMalpracticeXML = source.HasMalpracticeXML,
        target.HasSanctionXML = source.HasSanctionXML,
        target.HasBoardActionXML = source.HasBoardActionXML,
        target.HasProfessionalOrganizationXML = source.HasProfessionalOrganizationXML,
        target.ExpireCode = source.ExpireCode

