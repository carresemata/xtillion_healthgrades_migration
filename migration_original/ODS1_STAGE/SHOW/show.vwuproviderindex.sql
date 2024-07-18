CREATE OR REPLACE VIEW ODS1_STAGE_TEAM.SHOW.VWUPROVIDERINDEX AS 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Show.vwuProviderIndex depends on:
--- Show.SOLRProvider
--- Show.ConsolidatedProviders
--- Show.DelayClient

SELECT
    SOLRProviderID,
    p.ProviderID AS ProviderID,
    p.ProviderCode AS ProviderCode,
    ProviderLegacyKey AS ProviderLegacyKey,
    FirstName AS FirstName,
    LastName AS LastName,
    MiddleName AS MiddleName,
    left(MiddleName, 1) AS MiddleInitial,
    Suffix AS Suffix,
    Degree AS Degree,
    Title AS Title,
    (
      IFNULL(FirstName, '') ||
      ' ' ||
      CASE WHEN MiddleName IS NULL
        THEN ''
        ELSE LEFT(IFNULL(MiddleName, ''), 1) || '. '
      END ||
      IFNULL(LastName, '') ||
      CASE WHEN Suffix IS NOT NULL
        THEN ' ' || IFNULL(Suffix, '')
        ELSE ''
      END
    ) AS FirstMiddleInitialLastName,
    (
        IFNULL(Title, '') ||
        CASE WHEN Title IS NULL
          THEN ''
          ELSE ' '
        END ||
        IFNULL(FirstName, '') || ' ' ||
        IFNULL(LastName, '') ||
        CASE WHEN Suffix IS NOT NULL
          THEN ' ' || IFNULL(Suffix, '')
          ELSE ''
        END ||
        CASE WHEN Degree IS NOT NULL
          THEN ', ' || Degree
          ELSE ''
        END
    ) AS DisplayName,
    CASE
        WHEN Title IS NOT NULL THEN Title || ' ' || IFNULL(LastName, '')
        ELSE IFNULL(FirstName, '') || ' ' || IFNULL(LastName, '')
    END || CASE
        WHEN Suffix IS NOT NULL THEN ' ' || IFNULL(Suffix, '')
        ELSE ''
    END AS DisplayLastName,
    CASE
        WHEN Title IS NOT NULL THEN Title || ' ' || IFNULL(LastName, '')
        ELSE IFNULL(FirstName, '') || ' ' || IFNULL(LastName, '')
    END || CASE
        WHEN Suffix IS NOT NULL THEN ' ' || IFNULL(Suffix, '')
        ELSE ''
    END || CASE
        WHEN RIGHT(LastName, 1) = 's' THEN ''''
        ELSE '''s'
    END AS DisplayLastNamePossessive,
    Gender AS Gender,
    DATEDIFF(year, DATE_TRUNC('YEAR', CURRENT_DATE()), DATE_TRUNC('YEAR', DateOfBirth)) AS Age,
    DateOfBirth,
    YearsSinceMedicalSchoolGraduation AS YearsSinceMedicalSchoolGraduation,
    p.ProviderTypeGroup AS ProviderTypeGroup,
    PatientExperienceSurveyOverallCount AS PatientExperienceSurveyOverallCount,
    CAST(ROUND(PatientExperienceSurveyOverallScore * 2, 0) / 2 AS DECIMAL(5, 2)) AS PatientExperienceSurveyOverallScore,
    DisplayPatientExperienceSurveyOverallScore AS DisplayPatientExperienceSurveyOverallScore,
    HasDisplayImage AS HasDisplayImage,
    DisplayImage AS DisplayImage,
    ProviderURL,
    AcceptsNewPatients AS AcceptsNewPatients,
    CarePhilosophy AS CarePhilosophy,
    YearlySearchVolume AS YearlySearchVolume,
    NULL AS ClientID,
    NULL AS ClientType,
    NULL AS ProfileType,
    RecognitionXML AS RecognitionXML,
    SpecialtyXML AS SpecialtyXML,
    AddressXML AS AddressXML,
    PracticeOfficeXML AS PracticeOfficeXML,
    CityStateAll AS CityStateAll,
    LicenseXML AS LicenseXML,
    p.ConditionXML AS ConditionXML,
    p.ProcedureXML AS ProcedureXML,
    EducationXML AS EducationXML,
    FacilityXML AS FacilityXML,
    SurveyXML AS SurveyXML,
    SurveyResponse AS SurveyResponse,
    SurveyResponseDate AS SurveyResponseDate,
    SuppressSurvey AS SuppressSurvey,
    MediaXML AS MediaXML,
    MalpracticeXML AS MalpracticeXML,
    SanctionXML AS SanctionXML,
    BoardActionXML AS BoardActionXML,
    LanguageXML AS LanguageXML,
    HealthInsuranceXML AS HealthInsuranceXML,
    HealthInsuranceXML_v2 AS HealthInsuranceXML_v2,
    CASE
        WHEN DC.ClientCode IS NOT NULL THEN NULL
        ELSE SponsorshipXML
    END AS SponsorshipXML,
    CASE
        WHEN DC.ClientCode IS NOT NULL THEN NULL
        ELSE SearchSponsorshipXML
    END AS SearchSponsorshipXML,
    CASE
        WHEN SponsorCode = 'xxx' THEN NULL
        ELSE OASXML
    END AS OASXML,
    ProviderSpecialtyFacility5StarXML AS ProviderSpecialtyFacility5StarXML,
    HasAddressXML AS HasAddressXML,
    HasSpecialtyXML AS HasSpecialtyXML,
    HasPhilosophy AS HasPhilosophy,
    HasMediaXML AS HasMediaXML,
    HasProcedureXML AS HasProcedureXML,
    HasConditionXML AS HasConditionXML,
    HasMalpracticeXML AS HasMalpracticeXML,
    HasSanctionXML AS HasSanctionXML,
    HasBoardActionXML AS HasBoardActionXML,
    HasProviderSpecialtyFacility5StarXML AS HasProviderSpecialtyFacility5StarXML,
    CASE
        WHEN DC.ClientCode IS NOT NULL THEN NULL
        ELSE ProductGroupCode
    END AS ProductGroupCode,
    CASE
        WHEN DC.ClientCode IS NOT NULL THEN NULL
        ELSE SponsorCode
    END AS SponsorCode,
    FacilityCode AS FacilityCode,CASE
        WHEN DC.ClientCode IS NOT NULL THEN NULL
        ELSE ProductCode
    END AS ProductCode,
    VideoXML AS VideoXML,
    CASE
        WHEN IFNULL(HasDisplayImage, 0) = 0 THEN CASE
            WHEN Gender = 'M' 
            THEN '<imgL> 
            
                      <img> 
                        <imgC>small</imgC> 
                        <imgU>/img/silhouettes/silhouette-male_w60h80_v1.jpg</imgU> 
                        <imgA>small image</imgA> 
                        <imgW>60</imgW> 
                        <imgH>80</imgH>                                                                                                                                                </img> 
                                                                                                                                                                                           <img> 
                        <imgC>medium</imgC> 
                        <imgU>/img/silhouettes/silhouette-male_w90h120_v1.jpg</imgU> 
                        <imgA>medium image</imgA> 
                        <imgW>90</imgW> 
                        <imgH>120</imgH> 
                      </img> 
                                                                                                                                                                                           <img> 
                        <imgC>large</imgC> 
                        <imgU>/img/silhouettes/silhouette-male_w120h160_v1.jpg</imgU> 
                        <imgA>large image</imgA> 
                        <imgW>120</imgW> 
                        <imgH>160</imgH> 
                      </img> 
                                                                                                                                                                                      </imgL>'
            WHEN Gender = 'F' 
            THEN '<imgL> 
                  
                     <img>                                                                                                                                                                    <imgC>small</imgC> 
                        <imgU>/img/silhouettes/silhouette-female_w60h80_v1.jpg</imgU> 
                        <imgA>small image</imgA> 
                        <imgW>60</imgW> 
                        <imgH>80</imgH> 
                     </img> 
                                                                                                                                                                                          <img> 
                        <imgC>medium</imgC> 
                        <imgU>/img/silhouettes/silhouette-female_w90h120_v1.jpg</imgU> 
                        <imgA>medium image</imgA> 
                        <imgW>90</imgW> 
                        <imgH>120</imgH>                                                                                                                                                   </img> 
                                                                                                                                                                                          <img> 
                        <imgC>large</imgC>                                                                                                                                                   <imgU>/img/silhouettes/silhouette-female_w120h160_v1.jpg</imgU> 
                        <imgA>large image</imgA> 
                        <imgW>120</imgW> 
                        <imgH>160</imgH>                                                                                                                                                   </img> 
                                                                                                                                                                                      </imgL>'
                                                                                                                                                                                      
            ELSE '<imgL> 
            
                     <img> 
                         <imgC>small</imgC> 
                         <imgU>/img/silhouettes/silhouette-unknown_w60h80_v1.jpg</imgU> 
                         <imgA>small image</imgA> 
                         <imgW>60</imgW> 
                         <imgH>80</imgH> 
                     </img> 
                     
                     <img> 
                        <imgC>medium</imgC> 
                         <imgU>/img/silhouettes/silhouette-unknown_w90h120_v1.jpg</imgU> 
                         <imgA>medium image</imgA> 
                         <imgW>90</imgW> 
                         <imgH>120</imgH> 
                     </img> 
                     
                     <img> 
                         <imgC>large</imgC> 
                         <imgU>/img/silhouettes/silhouette-unknown_w120h160_v1.jpg</imgU> 
                         <imgA>large image</imgA> 
                         <imgW>120</imgW> 
                         <imgH>160</imgH> 
                     </img> 
                     
                   </imgL>'
        END
        ELSE ImageXML
    END AS ImageXML,
    AdXML AS AdXML,
    IsActive AS IsActive,
    ExpireCode AS ExpireCode,
    UpdatedDate AS UpdatedDate,
    UpdatedSource AS UpdatedSource,
    HasProfessionalOrganizationXML AS HasProfessionalOrganizationXML,
    ProfessionalOrganizationXML AS ProfessionalOrganizationXML,
    ProviderProfileViewOneYear AS ProviderProfileViewOneYear,
    ProviderBiography AS ProviderBiography,
    PatientExperienceSurveyOverallStarValue AS PatientExperienceSurveyOverallStarValue,
    PracticingSpecialtyXML AS PracticingSpecialtyXML,
    HasPracticingSpecialtyXML AS HasPracticingSpecialtyXML,
    CertificationXML AS CertificationXML,
    HasCertificationXML AS HasCertificationXML,
    DisplayStatusCode,
    SubStatusCode,
    SubStatusDescription,
    CASE
        WHEN Degree IN ('MD','DO','PhD','PsyD','DDS','DMD','OD','DC','DPM') THEN 1
        ELSE 0
    END IsPremiumDegree,
    CASE
        WHEN Degree IN ('MD','DO','PhD','PsyD','DDS','DMD','OD','DC','DPM') THEN '0.40'
        WHEN Degree = 'PA' THEN '0.20'
        ELSE '0'
    END AS DegreeBoost,
    CASE
        WHEN HasCertificationXML = 1 THEN '0.25'
        ELSE '0'
    END AS CertificationBoost,
    CASE
        WHEN HasMalpracticeXML = 1 THEN '0'
        WHEN HasMalpracticeState = 0 THEN '0'
        ELSE '0.1'
    END AS MalpracticeBoost,
    CASE
        WHEN HasSanctionXML = 1 THEN '0'
        ELSE '0.4'
    END AS SanctionBoost,
    CASE
        WHEN HasBoardActionXML = 1 THEN '0'
        ELSE '0.4'
    END AS BoardActionBoost,
    HasMalpracticeState,
    ProcedureHierarchyXML,
    ConditionHierarchyXML,
    NPI,
    ProcMappedXML,
    CondMappedXML,
    PracSpecHeirXML,
    AboutMeXML,
    HasAboutMeXML,
    CASE
        WHEN cp.ProviderID IS NULL THEN 0
        ELSE 1
    END AS IsConsolidated,
    PatientVolume,
    CASE
        WHEN (ProcedureCount + ConditionCount) >= 5 THEN 0.5
        WHEN (
            (ProcedureCount + ConditionCount) > 0
            AND (ProcedureCount + ConditionCount) < 5
        ) THEN 0.2
        ELSE 0
    END AS DCPCountBoost,
    ProcedureCount,
    ConditionCount,
    AvailabilityXML,
    VideoXML2,
    AvailabilityStatement,
    1 AS ShowComment,
    HasOAR,
    NatlAdvertisingXML,
    APIXML AS APIXML,
    DIHGroupNumber,
    NULL AS UPIN,
    NULL AS SSN4,
    NULL AS ABMSUID,
    NULL AS SurveySuppressionReason,
    NULL AS DEAXML,
    NULL AS HasDEAXML,
    NULL AS EmailAddressXML,
    NULL AS HasEmailAddressXML,
    NULL AS DegreeXML,
    p.ClientCertificationXML,
    HasSurveyXML,
    HasGoogleOAS,
    HasVideoXML2,
    HasAboutMe,
    (
     (CAST(IFNULL(HasVideoXML2, 0) AS INT) * 0.1) + (CAST(IFNULL(HasPhilosophy, 0) AS INT) * 0.2) + (CAST(IFNULL(HasAboutMe, 0) AS INT) * 0.3) +                          (CAST(IFNULL(HasDisplayImage, 0) AS INT) * 0.4)
    ) AS CompatibilityBoost,
    ConversionPathXML,
    SearchBoostSatisfaction,
    SearchBoostAccessibility,
    IsPCPCalculated AS IsPCP,
    FAFBoostSatisfaction,
    FAFBoostSancMalp,
    FFDisplaySpecialty,
    p.FFPESBoost,
    p.FFMalMultiHQ,
    p.FFMalMulti,
    ClinicalFocusXML,
    ClinicalFocusDCPXML,
    SyndicationXML,
    TeleHealthXML,
    CASE
        WHEN p.ProviderId IN (
            SELECT ProviderId
            FROM Base.NoIndexNoFollow
        ) THEN 1
        ELSE 0
    END AS NoIndexNoFollow,
    CASE
        WHEN p.ProviderId IN (
            SELECT ProviderId
            FROM Base.NoIndexNoFollowSC
        ) THEN 1
        ELSE 0
    END AS NoIndexNoFollowSC,
    IFNULL(SourceUpdateDateTime, p.UpdatedDate) AS SourceUpdateDateTime,
    IFNULL(SourceUpdate, 'Vendor Data') AS SourceUpdate,
    DateOfFirstLoad,
    ProviderSubTypeCode,
    TrainingXML,
    LastUpdateDateXML,
    SmartReferralXML,
    p.SmartReferralClientCode
FROM
    Show.SOLRProvider p
    LEFT JOIN Show.ConsolidatedProviders cp ON p.ProviderID = cp.ProviderID
    LEFT JOIN Show.DelayClient dc ON dc.ClientCode = p.SponsorCode
    AND GoLiveDate > CAST(GETDATE() AS DATE)
    AND p.ProviderCode NOT IN ('y9tbn8z')
WHERE
    p.DisplayStatusCode NOT IN ('S', 'I', 'H')
    AND p.PracticingSpecialtyXML IS NOT NULL
    AND p.PracticeOfficeXML IS NOT NULL;