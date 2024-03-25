-- hack_spuMAPFreeze
CREATE OR REPLACE PROCEDURE ODS1_STAGE.SHOW.SP_LOAD_SOLRPROVIDER_FREEZE() 
    RETURNS STRING
    LANGUAGE SQL
    AS  

DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Show.SOLRProvider_Freeze depends on: 
--- Show.WebFreeze
--- Show.SOLRProvider


---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------


    select_statement STRING; -- CTE statement
    cleanup_1 STRING; -- Cleanup for Show.SOLRProvider_Freeze
    cleanup_2 STRING; -- Cleanup for Show.WebFreeze
    insert_columns STRING; -- List of columns to insert
    insert_statement STRING; -- Insert statement to final table
    merge_statement STRING; -- Merge statement
    status STRING; -- Status monitoring

   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    -- no conditionals


---------------------------------------------------------
--------------- 3. Select statements --------------------
---------------------------------------------------------     


insert_columns := ' ProviderID,
                    ProviderCode,
                    ProviderTypeID,
                    ProviderTypeGroup,
                    FirstName,
                    MiddleName,
                    LastName,
                    Suffix,
                    Degree,
                    Gender,
                    NPI,
                    AMAID,
                    UPIN,
                    MedicareID,
                    DEANumber,
                    TaxIDNumber,
                    DateOfBirth,
                    PlaceOfBirth,
                    CarePhilosophy,
                    ProfessionalInterest,
                    PrimaryEmailAddress,
                    MedicalSchoolNation,
                    YearsSinceMedicalSchoolGraduation,
                    HasDisplayImage,
                    HasElectronicMedicalRecords,
                    HasElectronicPrescription,
                    AcceptsNewPatients,
                    YearlySearchVolume,
                    PatientExperienceSurveyOverallScore,
                    PatientExperienceSurveyOverallCount,
                    PracticeOfficeXML,
                    FacilityXML,
                    SpecialtyXML,
                    EducationXML,
                    LicenseXML,
                    LanguageXML,
                    MalpracticeXML,
                    SanctionXML,
                    SponsorshipXML,
                    AffiliationXML,
                    ProcedureXML,
                    ConditionXML,
                    HealthInsuranceXML,
                    MediaXML,
                    HasAddressXML,
                    HasSpecialtyXML,
                    Active,
                    UpdateDate,
                    InsertDate,
                    ProviderLegacyKey,
                    DisplayImage,
                    AddressXML,
                    BoardActionXML,
                    SurveyXML,
                    RecognitionXML,
                    SurveyResponse,
                    UpdatedDate,
                    UpdatedSource,
                    HasPhilosophy,
                    HasMediaXML,
                    HasProcedureXML,
                    HasConditionXML,
                    HasMalpracticeXML,
                    HasSanctionXML,
                    HasBoardActionXML,
                    IsActive,
                    ExpireCode,
                    Title,
                    CityStateAll,
                    SurveyResponseDate,
                    ProviderSpecialtyFacility5StarXML,
                    HasProviderSpecialtyFacility5StarXML,
                    DisplayPatientExperienceSurveyOverallScore,
                    ProductGroupCode,
                    SponsorCode,
                    FacilityCode,
                    SearchSponsorshipXML,
                    ProductCode,
                    VideoXML,
                    OASXML,
                    SuppressSurvey,
                    ProviderURL,
                    ImageXML,
                    AdXML,
                    HasProfessionalOrganizationXML,
                    ProfessionalOrganizationXML,
                    ProviderProfileViewOneYear,
                    PracticingSpecialtyXML,
                    CertificationXML,
                    HasPracticingSpecialtyXML,
                    HasCertificationXML,
                    PatientExperienceSurveyOverallStarValue,
                    ProviderBiography,
                    DisplayStatusCode,
                    HealthInsuranceXML_v2,
                    ProviderDEAXML,
                    ProviderTypeXML,
                    SubStatusCode,
                    DuplicateProviderCode,
                    DeactivationReason,
                    ProcedureHierarchyXML,
                    ConditionHierarchyXML,
                    ProcMappedXML,
                    CondMappedXML,
                    PracSpecHeirXML,
                    AboutMeXML,
                    HasAboutMeXML,
                    PatientVolume,
                    HasMalpracticeState,
                    ProcedureCount,
                    ConditionCount,
                    AvailabilityXML,
                    VideoXML2,
                    AvailabilityStatement,
                    IsInClientMarket,
                    HasOAR,
                    IsMMPUser,
                    NatlAdvertisingXML,
                    APIXML,
                    DIHGroupNumber,
                    SubStatusDescription,
                    DEAXML,
                    EmailAddressXML,
                    DegreeXML,
                    HasSurveyXML,
                    HasDEAXML,
                    HasEmailAddressXML,
                    ClientCertificationXML,
                    HasGoogleOAS,
                    HasVideoXML2,
                    HasAboutMe,
                    ConversionPathXML,
                    SearchBoostSatisfaction,
                    SearchBoostAccessibility,
                    IsPCPCalculated,
                    FAFBoostSatisfaction,
                    FAFBoostSancMalp,
                    FFDisplaySpecialty,
                    FFPESBoost,
                    FFMalMultiHQ,
                    FFMalMulti,
                    CLinicalFocusXML,
                    ClinicalFocusDCPXML,
                    SyndicationXML,
                    TeleHealthXML ';

select_statement := 'WITH CTE_ClientCode AS (
                    SELECT
                        ClientCode
                    FROM
                        Show.WebFreeze
                    WHERE
                        CURRENT_TIMESTAMP BETWEEN FreezeStartDate
                        AND IFNULL(FreezeEndDate, ''999-09-09''))
                    
                    SELECT '
                      || insert_columns || '
                    FROM
                        Show.SOLRProvider
                    WHERE
                        SponsorCode IN ( SELECT ClientCode FROM CTE_ClientCode )
                                AND SponsorCode NOT IN (
                                    SELECT
                                        DISTINCT SponsorCode
                                    FROM
                                        Show.SOLRProvider_Freeze)';

--- Insert Statement
insert_statement := ' INSERT  (' || insert_columns ||')
                      VALUES (  source.ProviderID,
                                source.ProviderCode,
                                source.ProviderTypeID,
                                source.ProviderTypeGroup,
                                source.FirstName,
                                source.MiddleName,
                                source.LastName,
                                source.Suffix,
                                source.Degree,
                                source.Gender,
                                source.NPI,
                                source.AMAID,
                                source.UPIN,
                                source.MedicareID,
                                source.DEANumber,
                                source.TaxIDNumber,
                                source.DateOfBirth,
                                source.PlaceOfBirth,
                                source.CarePhilosophy,
                                source.ProfessionalInterest,
                                source.PrimaryEmailAddress,
                                source.MedicalSchoolNation,
                                source.YearsSinceMedicalSchoolGraduation,
                                source.HasDisplayImage,
                                source.HasElectronicMedicalRecords,
                                source.HasElectronicPrescription,
                                source.AcceptsNewPatients,
                                source.YearlySearchVolume,
                                source.PatientExperienceSurveyOverallScore,
                                source.PatientExperienceSurveyOverallCount,
                                source.PracticeOfficeXML,
                                source.FacilityXML,
                                source.SpecialtyXML,
                                source.EducationXML,
                                source.LicenseXML,
                                source.LanguageXML,
                                source.MalpracticeXML,
                                source.SanctionXML,
                                source.SponsorshipXML,
                                source.AffiliationXML,
                                source.ProcedureXML,
                                source.ConditionXML,
                                source.HealthInsuranceXML,
                                source.MediaXML,
                                source.HasAddressXML,
                                source.HasSpecialtyXML,
                                source.Active,
                                source.UpdateDate,
                                source.InsertDate,
                                source.ProviderLegacyKey,
                                source.DisplayImage,
                                source.AddressXML,
                                source.BoardActionXML,
                                source.SurveyXML,
                                source.RecognitionXML,
                                source.SurveyResponse,
                                source.UpdatedDate,
                                source.UpdatedSource,
                                source.HasPhilosophy,
                                source.HasMediaXML,
                                source.HasProcedureXML,
                                source.HasConditionXML,
                                source.HasMalpracticeXML,
                                source.HasSanctionXML,
                                source.HasBoardActionXML,
                                source.IsActive,
                                source.ExpireCode,
                                source.Title,
                                source.CityStateAll,
                                source.SurveyResponseDate,
                                source.ProviderSpecialtyFacility5StarXML,
                                source.HasProviderSpecialtyFacility5StarXML,
                                source.DisplayPatientExperienceSurveyOverallScore,
                                source.ProductGroupCode,
                                source.SponsorCode,
                                source.FacilityCode,
                                source.SearchSponsorshipXML,
                                source.ProductCode,
                                source.VideoXML,
                                source.OASXML,
                                source.SuppressSurvey,
                                source.ProviderURL,
                                source.ImageXML,
                                source.AdXML,
                                source.HasProfessionalOrganizationXML,
                                source.ProfessionalOrganizationXML,
                                source.ProviderProfileViewOneYear,
                                source.PracticingSpecialtyXML,
                                source.CertificationXML,
                                source.HasPracticingSpecialtyXML,
                                source.HasCertificationXML,
                                source.PatientExperienceSurveyOverallStarValue,
                                source.ProviderBiography,
                                source.DisplayStatusCode,
                                source.HealthInsuranceXML_v2,
                                source.ProviderDEAXML,
                                source.ProviderTypeXML,
                                source.SubStatusCode,
                                source.DuplicateProviderCode,
                                source.DeactivationReason,
                                source.ProcedureHierarchyXML,
                                source.ConditionHierarchyXML,
                                source.ProcMappedXML,
                                source.CondMappedXML,
                                source.PracSpecHeirXML,
                                source.AboutMeXML,
                                source.HasAboutMeXML,
                                source.PatientVolume,
                                source.HasMalpracticeState,
                                source.ProcedureCount,
                                source.ConditionCount,
                                source.AvailabilityXML,
                                source.VideoXML2,
                                source.AvailabilityStatement,
                                source.IsInClientMarket,
                                source.HasOAR,
                                source.IsMMPUser,
                                source.NatlAdvertisingXML,
                                source.APIXML,
                                source.DIHGroupNumber,
                                source.SubStatusDescription,
                                source.DEAXML,
                                source.EmailAddressXML,
                                source.DegreeXML,
                                source.HasSurveyXML,
                                source.HasDEAXML,
                                source.HasEmailAddressXML,
                                source.ClientCertificationXML,
                                source.HasGoogleOAS,
                                source.HasVideoXML2,
                                source.HasAboutMe,
                                source.ConversionPathXML,
                                source.SearchBoostSatisfaction,
                                source.SearchBoostAccessibility,
                                source.IsPCPCalculated,
                                source.FAFBoostSatisfaction,
                                source.FAFBoostSancMalp,
                                source.FFDisplaySpecialty,
                                source.FFPESBoost,
                                source.FFMalMultiHQ,
                                source.FFMalMulti,
                                source.CLinicalFocusXML,
                                source.ClinicalFocusDCPXML,
                                source.SyndicationXML,
                                source.TeleHealthXML);';
                     
---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

cleanup_1 := 'DELETE FROM
                Show.SOLRProvider_Freeze
            WHERE
                SponsorCode NOT IN (
                    SELECT
                        ClientCode
                    FROM
                        Show.WebFreeze);';

            

cleanup_2 := 'DELETE FROM
                Show.WebFreeze
            WHERE
                CURRENT_TIMESTAMP > FreezeEndDate;';


merge_statement := ' MERGE INTO Show.SOLRProvider_Freeze as target USING 
                   ('||select_statement||') as source 
                   ON source.ProviderID = target.ProviderID
                   WHEN NOT MATCHED THEN '||insert_statement ;             

                   


---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE cleanup_1;
EXECUTE IMMEDIATE cleanup_2;  
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
