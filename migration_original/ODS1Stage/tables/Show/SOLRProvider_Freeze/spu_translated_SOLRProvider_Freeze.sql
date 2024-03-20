-- hack_spuMAPFreeze
CREATE OR REPLACE PROCEDURE DEV.SP_LOAD_SOLRPROVIDER_FREEZE() 
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
    load_statement STRING; -- Insert statement to final table
    final_execution STRING; -- Execution of the load and select
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

select_statement := 'WITH CTE_ClientCode AS (SELECT
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
                        Show.WebFreeze
                );';

            EXECUTE IMMEDIATE cleanup_1;

cleanup_2 := 'DELETE FROM
                Show.WebFreeze
            WHERE
                CURRENT_TIMESTAMP > FreezeEndDate;';

            EXECUTE IMMEDIATE cleanup_2;         

load_statement := 'INSERT INTO
                      Show.SOLRProvider_Freeze('
                        || insert_columns || ' )' ;


---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
final_execution := load_statement || select_statement ;
EXECUTE IMMEDIATE final_execution ;


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

