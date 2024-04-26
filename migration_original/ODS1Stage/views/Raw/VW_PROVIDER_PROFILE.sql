CREATE OR REPLACE MATERIALIZED VIEW ODS1_STAGE.RAW.VW_PROVIDER_PROFILE AS  ( 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

--- Raw.PROVIDER_PROFILE_PROCESSING

---------------------------------------------------------
-------------------- 1. JSON Keys -----------------------
---------------------------------------------------------

--- About Me
--- Appointment Availability
--- Certification Specialty
--- Clinical Focus
--- Condition
--- Customer Product
--- Degree
--- Demographics
--- Education Institution
--- Email
--- Facility
--- Health Insurance
--- Image
--- Identification
--- Language
--- License
--- Malpractice
--- Medical Procedure
--- Media
--- OAS
--- Office
--- Organization
--- Provider Status
--- Provider SubType
--- Provider Type
--- Sanction
--- Specialty
--- Telehealth
--- Training
--- Video


SELECT
    Process.MST_PROVIDER_PROFILE_ID AS MST_id,
    Process.CREATED_DATETIME AS CREATE_DATE,
    Process.REF_PROVIDER_CODE AS ProviderCode,
    Process.PROVIDER_PROFILE,
    
    -- About Me
    TO_VARCHAR(Process.PROVIDER_PROFILE:ABOUT_ME[0].ABOUT_ME_CODE) AS AboutMe_AboutMeCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:ABOUT_ME[0].ABOUT_ME_TEXT) AS AboutMe_AboutMeText,
    TO_VARCHAR(Process.PROVIDER_PROFILE:ABOUT_ME[0].DATA_SOURCE_CODE) AS AboutMe_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:ABOUT_ME[0].UPDATED_DATETIME) AS AboutMe_LastUpdate,
    
    -- Appointment Availability
    TO_VARCHAR(Process.PROVIDER_PROFILE:APPOINTMENT_AVAILABILITY[0].APPOINTMENT_AVAILABILITY_CODE) AS AppointmentAvailability_AppointmentAvailabilityCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:APPOINTMENT_AVAILABILITY[0].DATA_SOURCE_CODE) AS AppointmentAvailability_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:APPOINTMENT_AVAILABILITY[0].UPDATED_DATETIME) AS AppointmentAvailability_LastUpdateDate,
    
    -- Certification Specialty
    TO_VARCHAR(Process.PROVIDER_PROFILE:CERTIFICATION_SPECIALTY[0].CERTIFICATION_SPECIALTY_CODE) AS CertificationSpecialty_CertificationSpecialtyCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CERTIFICATION_SPECIALTY[0].CERTIFICATION_BOARD_CODE) AS CertificationSpecialty_CertificationBoardCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CERTIFICATION_SPECIALTY[0].CERTIFICATION_AGENCY_CODE) AS CertificationSpecialty_CertificationAgencyCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CERTIFICATION_SPECIALTY[0].CERTIFICATION_STATUS_CODE) AS CertificationSpecialty_CertificationStatusCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CERTIFICATION_SPECIALTY[0].CERTIFICATION_EFFECTIVE_DATE) AS CertificationSpecialty_CertificationEffectiveDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CERTIFICATION_SPECIALTY[0].CERTIFICATION_EXPIRATION_DATE) AS CertificationSpecialty_CertificationExpirationDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CERTIFICATION_SPECIALTY[0].MOC_PATHWAY_CODE) AS CertificationSpecialty_MocPathwayCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CERTIFICATION_SPECIALTY[0].MOC_LEVEL_CODE) AS CertificationSpecialty_MocLevelCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CERTIFICATION_SPECIALTY[0].DATA_SOURCE_CODE) AS CertificationSpecialty_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:CERTIFICATION_SPECIALTY[0].UPDATED_DATETIME) AS CertificationSpecialty_LastUpdateDate,
    
    -- Clinical Focus
    TO_VARCHAR(Process.PROVIDER_PROFILE:CLINICAL_FOCUS[0].CLINICAL_FOCUS_CODE) AS ClinicalFocus_ClinicalFocusCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CLINICAL_FOCUS[0].CLINICAL_FOCUS_DCP_COUNT) AS ClinicalFocus_ClinicalFocusDcpCount,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CLINICAL_FOCUS[0].CLINICAL_FOCUS_MIN_BUCKETS_CALCULATED) AS ClinicalFocus_ClinicalFocusMinBucketsCalculated,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CLINICAL_FOCUS[0].PROVIDER_DCP_COUNT) AS ClinicalFocus_ProviderDcpCount,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CLINICAL_FOCUS[0].AVERAGE_B_PERCENTILE) AS ClinicalFocus_AverageBPercentile,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CLINICAL_FOCUS[0].PROVIDER_DCP_FILL_PERCENT) AS ClinicalFocus_ProviderDcpFillPercent,
    TO_BOOLEAN(Process.PROVIDER_PROFILE:CLINICAL_FOCUS[0].IS_PROVIDER_DCP_COUNT_OVER_LOW_THRESHOLD) AS ClinicalFocus_IsProviderDcpCountOverLowThreshold,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CLINICAL_FOCUS[0].CLINICAL_FOCUS_SCORE) AS ClinicalFocus_ClinicalFocusScore,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CLINICAL_FOCUS[0].PROVIDER_CLINICAL_FOCUS_RANK) AS ClinicalFocus_ProviderClinicalFocusRank,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CLINICAL_FOCUS[0].DATA_SOURCE_CODE) AS ClinicalFocus_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:CLINICAL_FOCUS[0].UPDATED_DATETIME) AS ClinicalFocus_LastUpdateDate,
    
    -- Condition
    TO_VARCHAR(Process.PROVIDER_PROFILE:CONDITION[0].CONDITION_CODE) AS Condition_ConditionCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CONDITION[0].CONDITION_RANK) AS Condition_ConditionRank,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CONDITION[0].NATIONAL_RANKING_A) AS Condition_NationalRankingA,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CONDITION[0].NATIONAL_RANKING_B) AS Condition_NationalRankingB,
    TO_BOOLEAN(Process.PROVIDER_PROFILE:CONDITION[0].PATIENT_COUNT_IS_FEW) AS Condition_PatientCountIsFew,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CONDITION[0].PATIENT_COUNT) AS Condition_PatientCount,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CONDITION[0].TREATMENT_LEVEL_CODE) AS Condition_TreatmentLevelCode,
    TO_BOOLEAN(Process.PROVIDER_PROFILE:CONDITION[0].IS_SCREENING_DEFAULT_CALCULATION) AS Condition_IsScreeningDefaultCalculation,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CONDITION[0].DATA_SOURCE_CODE) AS Condition_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:CONDITION[0].UPDATED_DATETIME) AS Condition_LastUpdateDate,
    
    -- Customer Product
    TO_VARCHAR(Process.PROVIDER_PROFILE:CUSTOMER_PRODUCT[0].CUSTOMER_PRODUCT_CODE) AS CustomerProduct_CustomerProductCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CUSTOMER_PRODUCT[0].DESIGNATED_DATETIME) AS CustomerProduct_DesignatedDatetime,
    TO_BOOLEAN(Process.PROVIDER_PROFILE:CUSTOMER_PRODUCT[0].IS_EMPLOYED) AS CustomerProduct_IsEmployed,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CUSTOMER_PRODUCT[0].DATA_SOURCE_CODE) AS CustomerProduct_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:CUSTOMER_PRODUCT[0].UPDATED_DATETIME) AS CustomerProduct_LastUpdateDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:CUSTOMER_PRODUCT[0].DISPLAY_PARTNER) AS CustomerProduct_DisplayPartner,
    
    -- Degree
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEGREE[0].DEGREE_CODE) AS Degree_DegreeCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEGREE[0].DEGREE_RANK) AS Degree_DegreeRank,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEGREE[0].DATA_SOURCE_CODE) AS Degree_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:DEGREE[0].UPDATED_DATETIME) AS Degree_LastUpdateDate,
    
    -- Demographics
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].PROVIDER_CODE) AS Demographics_ProviderCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].FIRST_NAME) AS Demographics_FirstName,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].MIDDLE_NAME) AS Demographics_MiddleName,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].LAST_NAME) AS Demographics_LastName,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].SUFFIX_CODE) AS Demographics_SuffixCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].NPI) AS Demographics_NPI,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].GENDER_CODE) AS Demographics_GenderCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].UPIN) AS Demographics_UPIN,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].DATE_OF_BIRTH) AS Demographics_DateOfBirth,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].SURVEY_SUPPRESSION_REASON_CODE) AS Demographics_SurveySuppressionReasonCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].SURVIVE_RESIDENTIAL_ADDRESSES) AS Demographics_SurviveResidentialAddresses,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].ABMSUID) AS Demographics_ABMSUID,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].DATA_SOURCE_CODE) AS Demographics_SourceCode,
    TO_BOOLEAN(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].IS_PATIENT_FAVORITE) AS Demographics_IsPatientFavorite,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].ACCEPTS_NEW_PATIENTS) AS Demographics_AcceptsNewPatients,
    TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].SUPPRESS_DOB_FROM_WEBSITE) AS Demographics_SuppressDOBFromWebsite,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].UPDATED_DATETIME) AS Demographics_LastUpdateDate,

    -- Education Institution
    TO_VARCHAR(Process.PROVIDER_PROFILE:EDUCATION_INSTITUTION[0].EDUCATION_INSTITUTION_CODE) AS EducationInstitution_EducationInstitutionCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:EDUCATION_INSTITUTION[0].EDUCATION_INSTITUTION_NAME) AS EducationInstitution_EducationInstitutionName,
    TO_VARCHAR(Process.PROVIDER_PROFILE:EDUCATION_INSTITUTION[0].EDUCATION_INSTITUTION_TYPE_CODE) AS EducationInstitution_EducationInstitutionTypeCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:EDUCATION_INSTITUTION[0].GRADUATION_YEAR) AS EducationInstitution_GraduationYear,
    TO_VARCHAR(Process.PROVIDER_PROFILE:EDUCATION_INSTITUTION[0].DATA_SOURCE_CODE) AS EducationInstitution_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:EDUCATION_INSTITUTION[0].UPDATED_DATETIME) AS EducationInstitution_LastUpdateDate,
    
    -- Email
    TO_VARCHAR(Process.PROVIDER_PROFILE:EMAIL[0].EMAIL) AS Email_Email,
    TO_VARCHAR(Process.PROVIDER_PROFILE:EMAIL[0].EMAIL_RANK) AS Email_EmailRank,
    TO_VARCHAR(Process.PROVIDER_PROFILE:EMAIL[0].DATA_SOURCE_CODE) AS Email_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:EMAIL[0].UPDATED_DATETIME) AS Email_LastUpdateDate,
    
    -- Facility
    TO_VARCHAR(Process.PROVIDER_PROFILE:FACILITY[0].FACILITY_CODE) AS Facility_FacilityCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:FACILITY[0].DATA_SOURCE_CODE) AS Facility_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:FACILITY[0].UPDATED_DATETIME) AS Facility_LastUpdateDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:FACILITY[0].CUSTOMER_PRODUCT) AS Facility_CustomerProduct,
    
    -- Health Insurance
    TO_VARCHAR(Process.PROVIDER_PROFILE:HEALTH_INSURANCE[0].HEALTH_INSURANCE_PRODUCT_CODE) AS HealthInsurance_HealthInsuranceProductCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:HEALTH_INSURANCE[0].DATA_SOURCE_CODE) AS HealthInsurance_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:HEALTH_INSURANCE[0].UPDATED_DATETIME) AS HealthInsurance_LastUpdateDate,

    -- Image
    TO_VARCHAR(Process.PROVIDER_PROFILE:IMAGE[0].IDENTIFIER) AS Image_Identifier,
    TO_VARCHAR(Process.PROVIDER_PROFILE:IMAGE[0].IMAGE_FILE_NAME) AS Image_ImageFileName,
    TO_VARCHAR(Process.PROVIDER_PROFILE:IMAGE[0].MEDIA_IMAGE_TYPE_CODE) AS Image_MediaImageTypeCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:IMAGE[0].MEDIA_REVIEW_LEVEL_CODE) AS Image_MediaReviewLevelCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:IMAGE[0].MEDIA_SIZE_CODE) AS Image_MediaSizeCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:IMAGE[0].MEDIA_IMAGE_HOST_CODE) AS Image_MediaImageHostCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:IMAGE[0].MEDIA_CONTEXT_TYPE_CODE) AS Image_MediaContextTypeCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:IMAGE[0].IMAGE_PATH) AS Image_ImagePath,
    TO_VARCHAR(Process.PROVIDER_PROFILE:IMAGE[0].DATA_SOURCE_CODE) AS Image_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:IMAGE[0].UPDATED_DATETIME) AS Image_LastUpdateDate,
    
    -- Identification
    TO_VARCHAR(Process.PROVIDER_PROFILE:IDENTIFICATION[0].IDENTIFIER) AS Identification_Identifier,
    TO_VARCHAR(Process.PROVIDER_PROFILE:IDENTIFICATION[0].IDENTIFICATION_TYPE_CODE) AS Identification_IdentificationTypeCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:IDENTIFICATION[0].EXPIRATION_DATE) AS Identification_ExpirationDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:IDENTIFICATION[0].DATA_SOURCE_CODE) AS Identification_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:IDENTIFICATION[0].UPDATED_DATETIME) AS Identification_LastUpdateDate,

    -- Language
    TO_VARCHAR(Process.PROVIDER_PROFILE:LANGUAGE[0].LANGUAGE_CODE) AS Language_LanguageCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:LANGUAGE[0].DATA_SOURCE_CODE) AS Language_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:LANGUAGE[0].UPDATED_DATETIME) AS Language_LastUpdateDate,
    
    -- License
    TO_VARCHAR(Process.PROVIDER_PROFILE:LICENSE[0].LICENSE_TYPE_CODE) AS License_LicenseTypeCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:LICENSE[0].LICENSE_STATUS_CODE) AS License_LicenseStatusCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:LICENSE[0].LICENSE_NUMBER) AS License_LicenseNumber,
    TO_VARCHAR(Process.PROVIDER_PROFILE:LICENSE[0].LICENSE_EFFECTIVE_DATE) AS License_LicenseEffectiveDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:LICENSE[0].STATE) AS License_State,
    TO_VARCHAR(Process.PROVIDER_PROFILE:LICENSE[0].LICENSE_TERMINATION_DATE) AS License_LicenseTerminationDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:LICENSE[0].DATA_SOURCE_CODE) AS License_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:LICENSE[0].UPDATED_DATETIME) AS License_LastUpdateDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:LICENSE[0].LID) AS License_LID,
    
    -- Malpractice
    TO_VARCHAR(Process.PROVIDER_PROFILE:MALPRACTICE[0].MALPRACTICE_CLAIM_TYPE_CODE) AS Malpractice_MalpracticeClaimTypeCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MALPRACTICE[0].CLAIM_NUMBER) AS Malpractice_ClaimNumber,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MALPRACTICE[0].CLAIM_DATE) AS Malpractice_ClaimDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MALPRACTICE[0].CLAIM_YEAR) AS Malpractice_ClaimYear,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MALPRACTICE[0].CLAIM_AMOUNT) AS Malpractice_ClaimAmount,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MALPRACTICE[0].CLAIM_STATE) AS Malpractice_ClaimState,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MALPRACTICE[0].MALPRACTICE_CLAIM_RANGE) AS Malpractice_MalpracticeClaimRange,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MALPRACTICE[0].COMPLAINT) AS Malpractice_Complaint,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MALPRACTICE[0].INCIDENT_DATE) AS Malpractice_IncidentDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MALPRACTICE[0].CLOSED_DATE) AS Malpractice_ClosedDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MALPRACTICE[0].REPORT_DATE) AS Malpractice_ReportDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MALPRACTICE[0].LICENSE_NUMBER) AS Malpractice_LicenseNumber,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MALPRACTICE[0].DATA_SOURCE_CODE) AS Malpractice_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:MALPRACTICE[0].UPDATED_DATETIME) AS Malpractice_LastUpdateDate,

   -- Media
    TO_VARCHAR(Process.PROVIDER_PROFILE:MEDIA[0].MEDIA_TYPE_CODE) AS Media_MediaTypeCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MEDIA[0].MEDIA_DATE) AS Media_MediaDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MEDIA[0].MEDIA_TITLE) AS Media_MediaTitle,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MEDIA[0].MEDIA_PUBLISHER) AS Media_MediaPublisher,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MEDIA[0].MEDIA_SYNOPSIS) AS Media_MediaSynopsis,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MEDIA[0].MEDIA_LINK) AS Media_MediaLink,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MEDIA[0].DATA_SOURCE_CODE) AS Media_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:MEDIA[0].UPDATED_DATETIME) AS Media_LastUpdateDate,
    
    -- Medical Procedure
    TO_VARCHAR(Process.PROVIDER_PROFILE:MEDICAL_PROCEDURE[0].MEDICAL_PROCEDURE_CODE) AS MedicalProcedure_MedicalProcedureCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MEDICAL_PROCEDURE[0].NATIONAL_RANKING_A) AS MedicalProcedure_NationalRankingA,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MEDICAL_PROCEDURE[0].NATIONAL_RANKING_B) AS MedicalProcedure_NationalRankingB,
    TO_BOOLEAN(Process.PROVIDER_PROFILE:MEDICAL_PROCEDURE[0].PATIENT_COUNT_IS_FEW) AS MedicalProcedure_PatientCountIsFew,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MEDICAL_PROCEDURE[0].PATIENT_COUNT) AS MedicalProcedure_PatientCount,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MEDICAL_PROCEDURE[0].TREATMENT_LEVEL_CODE) AS MedicalProcedure_TreatmentLevelCode,
    TO_BOOLEAN(Process.PROVIDER_PROFILE:MEDICAL_PROCEDURE[0].IS_SCREENING_DEFAULT_CALCULATION) AS MedicalProcedure_IsScreeningDefaultCalculation,
    TO_VARCHAR(Process.PROVIDER_PROFILE:MEDICAL_PROCEDURE[0].DATA_SOURCE_CODE) AS MedicalProcedure_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:MEDICAL_PROCEDURE[0].UPDATED_DATETIME) AS MedicalProcedure_LastUpdateDate,
    
    -- OAS
    TO_VARCHAR(Process.PROVIDER_PROFILE:OAS[0].CUSTOMER_PRODUCT_CODE) AS OAS_CustomerProductCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:OAS[0].DATA_SOURCE_CODE) AS OAS_SourceCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:OAS[0].URL) AS OAS_URL,
    
    -- Office
    TO_VARCHAR(Process.PROVIDER_PROFILE:OFFICE[0].OFFICE_CODE) AS Office_OfficeCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:OFFICE[0].DATA_SOURCE_CODE) AS Office_SourceCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:OFFICE[0].OFFICE_NAME) AS Office_OfficeName,
    TO_VARCHAR(Process.PROVIDER_PROFILE:OFFICE[0].PRACTICE_NAME) AS Office_PracticeName,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:OFFICE[0].UPDATED_DATETIME) AS Office_LastUpdateDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:OFFICE[0].OFFICE_RANK) AS Office_OfficeRank,
    TO_VARCHAR(Process.PROVIDER_PROFILE:OFFICE[0].PHONE_NUMBER) AS Office_PhoneNumber,
    TO_VARCHAR(Process.PROVIDER_PROFILE:OFFICE[0].OFFICE_OAS) AS Office_OfficeOAS,
    
    -- Organization
    TO_VARCHAR(Process.PROVIDER_PROFILE:ORGANIZATION[0].ORGANIZATION_DESCRIPTION) AS Organization_OrganizationDescription,
    TO_VARCHAR(Process.PROVIDER_PROFILE:ORGANIZATION[0].POSITION_DESCRIPTION) AS Organization_PositionDescription,
    TO_VARCHAR(Process.PROVIDER_PROFILE:ORGANIZATION[0].POSITION_RANK) AS Organization_PositionRank,
    TO_VARCHAR(Process.PROVIDER_PROFILE:ORGANIZATION[0].DATA_SOURCE_CODE) AS Organization_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:ORGANIZATION[0].UPDATED_DATETIME) AS Organization_LastUpdateDate,
    
    -- Provider Status
    TO_VARCHAR(Process.PROVIDER_PROFILE:PROVIDER_STATUS[0].PROVIDER_STATUS_CODE) AS ProviderStatus_ProviderStatusCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:PROVIDER_STATUS[0].PROVIDER_STATUS_RANK) AS ProviderStatus_ProviderStatusRank,
    TO_VARCHAR(Process.PROVIDER_PROFILE:PROVIDER_STATUS[0].DATA_SOURCE_CODE) AS ProviderStatus_SourceCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:PROVIDER_STATUS[0].UPDATED_DATETIME) AS ProviderStatus_LastUpdateDate,
    
    -- Provider SubType
    TO_VARCHAR(Process.PROVIDER_PROFILE:PROVIDER_SUB_TYPE[0].PROVIDER_SUB_TYPE_CODE) AS ProviderSubType_ProviderSubTypeCode,                  
    TO_VARCHAR(Process.PROVIDER_PROFILE:PROVIDER_SUB_TYPE[0].PROVIDER_SUB_TYPE_RANK) AS ProviderSubType_ProviderSubTypeRank,
    TO_VARCHAR(Process.PROVIDER_PROFILE:PROVIDER_SUB_TYPE[0].DATA_SOURCE_CODE) AS ProviderSubType_SourceCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:PROVIDER_SUB_TYPE[0].UPDATED_DATETIME) AS ProviderSubType_LastUpdateDate,

    -- Provider Type
    TO_VARCHAR(Process.PROVIDER_PROFILE:PROVIDER_TYPE[0].PROVIDER_TYPE_CODE) AS ProviderType_ProviderTypeCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:PROVIDER_TYPE[0].PROVIDER_TYPE_RANK) AS ProviderType_ProviderTypeRank,
    TO_VARCHAR(Process.PROVIDER_PROFILE:PROVIDER_TYPE[0].PROVIDER_TYPE_RANK_CALCULATED) AS ProviderType_ProviderTypeRankCalculated,
    TO_VARCHAR(Process.PROVIDER_PROFILE:PROVIDER_TYPE[0].DATA_SOURCE_CODE) AS ProviderType_SourceCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:PROVIDER_TYPE[0].UPDATED_DATETIME) AS ProviderType_LastUpdateDate,

    -- Sanction
    TO_VARCHAR(Process.PROVIDER_PROFILE:SANCTION [0].SANCTION_LICENSE) AS Sanction_SanctionLicense,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SANCTION [0].SANCTION_TYPE_CODE) AS Sanction_SanctionTypeCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SANCTION [0].SANCTION_CATEGORY_CODE) AS Sanction_SanctionCategoryCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SANCTION [0].SANCTION_RESIDENCE_STATE) AS Sanction_SanctionResidenceState,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SANCTION [0].SANCTION_ACTION_CODE) AS Sanction_SanctionActionCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SANCTION [0].SANCTION_DESCRIPTION) AS Sanction_SanctionDescription,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SANCTION [0].SANCTION_DATE) AS Sanction_SanctionDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SANCTION [0].SANCTION_REINSTATEMENT_DATE) AS Sanction_SanctionReinstatementDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SANCTION [0].DATA_SOURCE_CODE) AS Sanction_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:SANCTION [0].UPDATED_DATETIME) AS Sanction_LastUpdateDate,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SANCTION [0].STATE_REPORTING_AGENCY_CODE) AS Sanction_StateReportingAgencyCode,
    
    -- Specialty
    TO_VARCHAR(Process.PROVIDER_PROFILE:SPECIALTY [0].SPECIALTY_CODE) AS Specialty_SpecialtyCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SPECIALTY [0].SPECIALTY_RANK) AS Specialty_SpecialtyRank,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SPECIALTY [0].SPECIALTY_RANK_CALCULATED) AS Specialty_SpecialtyRankCalculated,
    TO_BOOLEAN(Process.PROVIDER_PROFILE:SPECIALTY [0].IS_SEARCHABLE) AS Specialty_IsSearchable,
    TO_BOOLEAN(Process.PROVIDER_PROFILE:SPECIALTY [0].IS_SEARCHABLE_CALCULATED) AS Specialty_IsSearchableCalculated,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SPECIALTY [0].SPECIALTY_DCP_COUNT) AS Specialty_SpecialtyDcpCount,
    TO_BOOLEAN(Process.PROVIDER_PROFILE:SPECIALTY [0].IS_SPECIALTY_REDUNDANT) AS Specialty_IsSpecialtyRedundant,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SPECIALTY [0].SPECIALTY_DCP_MIN_FILL_THRESHOLD) AS Specialty_SpecialtyDcpMinFillThreshold,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SPECIALTY [0].PROVIDER_SPECIALTY_DCP_COUNT) AS Specialty_ProviderSpecialtyDcpCount,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SPECIALTY [0].PROVIDER_SPECIALTY_AVERAGE_PERCENTILE) AS Specialty_ProviderSpecialtyAveragePercentile,
    TO_BOOLEAN(Process.PROVIDER_PROFILE:SPECIALTY [0].IS_MEETS_LOW_THRESHOLD) AS Specialty_IsMeetsLowThreshold,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SPECIALTY [0].PROVIDER_RAW_SPECIALTY_SCORE) AS Specialty_ProviderRawSpecialtyScore,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SPECIALTY [0].SCALED_SPECIALTY_BOOST) AS Specialty_ScaledSpecialtyBoost,
    TO_VARCHAR(Process.PROVIDER_PROFILE:SPECIALTY [0].DATA_SOURCE_CODE) AS Specialty_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:SPECIALTY [0].UPDATED_DATETIME) AS Specialty_LastUpdateDate,
    
    -- Telehealth
    TO_VARCHAR(Process.PROVIDER_PROFILE:TELEHEALTH [0].HAS_TELEHEALTH) AS Telehealth_HasTelehealth,
    TO_VARCHAR(Process.PROVIDER_PROFILE:TELEHEALTH [0].TELEHEALTH_URL) AS Telehealth_TelehealthURL,
    TO_VARCHAR(Process.PROVIDER_PROFILE:TELEHEALTH [0].TELEHEALTH_PHONE) AS Telehealth_TelehealthPhone,
    TO_VARCHAR(Process.PROVIDER_PROFILE:TELEHEALTH [0].TELEHEALTH_VENDOR_NAME) AS Telehealth_TelehealthVendorName,
    TO_VARCHAR(Process.PROVIDER_PROFILE:TELEHEALTH [0].TELEHEALTH_METHOD_CODE) AS Telehealth_TelehealthMethodCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:TELEHEALTH [0].DATA_SOURCE_CODE) AS Telehealth_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:TELEHEALTH [0].UPDATED_DATETIME) AS Telehealth_LastUpdateDate,
    
    -- Training
    TO_VARCHAR(Process.PROVIDER_PROFILE:TRAINING [0].TRAINING_CODE) AS Training_TrainingCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:TRAINING [0].TRAINING_LINK) AS Training_TrainingLink,
    TO_VARCHAR(Process.PROVIDER_PROFILE:TRAINING [0].DATA_SOURCE_CODE) AS Training_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:TRAINING [0].UPDATED_DATETIME) AS Training_LastUpdateDate,
    
    -- Video
    TO_VARCHAR(Process.PROVIDER_PROFILE:VIDEO [0].SRC_IDENTIFIER) AS Video_SrcIdentifier,
    TO_VARCHAR(Process.PROVIDER_PROFILE:VIDEO [0].REF_MEDIA_VIDEO_HOST_CODE) AS Video_RefMediaVideoHostCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:VIDEO [0].REF_MEDIA_REVIEW_LEVEL_CODE) AS Video_RefMediaReviewLevelCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:VIDEO [0].REF_MEDIA_CONTEXT_TYPE_CODE) AS Video_RefMediaContextTypeCode,
    TO_VARCHAR(Process.PROVIDER_PROFILE:VIDEO [0].DATA_SOURCE_CODE) AS Video_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:VIDEO [0].UPDATED_DATETIME) AS Video_LastUpdateDate
    
FROM
    Raw.PROVIDER_PROFILE_PROCESSING AS Process);