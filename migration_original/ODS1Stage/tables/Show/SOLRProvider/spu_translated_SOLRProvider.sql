CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRPROVIDER()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER 
    AS
DECLARE 
---------------------------------------------------------
--------------- 1. Table dependencies -------------------
---------------------------------------------------------
    
-- Show.SOLRProvider depends on: 
--- Show.WebFreeze
--- Show.SOLRProvider_FREEZE (empty)
--- Show.ProviderSourceUpdate
--- Show.SOLRProviderDelta
--- Mid.ProviderPracticeOffice
--- Mid.ProviderEducation
--- Mid.ProviderSponsorship
--- Mid.ProviderSurveyResponse
--- Mid.ProviderMalpractice
--- Mid.ProviderProcedure
--- Mid.Provider
--- Mid.ClientMarket
--- Base.Provider
--- Base.ProviderImage
--- Base.ProviderEmail
--- Base.ProviderType
--- Base.ProviderSanction
--- Base.ProviderSubType
--- Base.ProviderSurveyAggregate
--- Base.ProviderSurveySuppression
--- Base.ProviderToSubStatus
--- Base.ProviderToProviderSubType
--- Base.ProviderAppointmentAvailabilityStatement (DEPRECATED)
--- Base.ProviderSubTypeToDegree
--- Base.ProviderToDegree
--- Base.ProviderToOffice
--- Base.ProviderToSpecialty
--- Base.ProviderLegacyKeys
--- Base.ProviderToAboutMe
--- Base.AboutMe
--- Base.Product
--- Base.MediaSize
--- Base.MediaImageHost
--- Base.MediaContextType
--- Base.SubStatus
--- Base.OfficeToAddress
--- Base.Address
--- Base.CityStatePostalCode
--- Base.GeographicArea
--- Base.DisplayStatus
--- Base.MalpracticeState
--- Base.SanctionAction
--- Base.SanctionActionType
--- Base.SpecialityGroup
--- Base.SpecialtyGroupToSpecialty
--- Base.Client
--- Base.ClientToProduct
--- Base.Specialty
--- 






---------------------------------------------------------
--------------- 2. Declaring variables ------------------
---------------------------------------------------------

    select_statement_1 STRING; -- CTE and Select statement for the Merge
    insert_statement_1 STRING; -- Insert statement for the Merge
    merge_statement_1 STRING; -- Merge statement to final table
    select_statement_2 STRING;
    insert_statement_2 STRING;
    update_statement_2 STRING;
    merge_statement_2 STRING;
    update_statement_3 STRING;
    update_statement_4 STRING;
    update_statement_5 STRING;
    update_statement_6 STRING;
    update_statement_7 STRING;
    update_statement_8 STRING;
    update_statement_9 STRING;
    update_statement_10 STRING;
    update_statement_11 STRING;
    update_statement_12 STRING;
    update_statement_13 STRING;
    update_statement_14 STRING;
    update_statement_15 STRING;
    update_statement_16 STRING;
    update_statement_17 STRING;
    update_statement_18 STRING;
    update_statement_19 STRING;
    update_statement_20 STRING;
    temp_table_statement_1 STRING;
    temp_table_statement_2 STRING;
    update_statement_temp_1 STRING;
    update_statement_temp_2 STRING;
    update_statement_21 STRING;
    update_statement_22 STRING;
    if_condition STRING;
    update_statement_23 STRING;
    update_statement_24 STRING;
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_solrprovider');
    execution_start datetime default getdate();


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     
begin

---------------- Step 1: Freeze Providers ------------------
--- Select Statement
select_statement_1 := $$ SELECT
                            *
                        FROM
                            Show.SOLRProvider_FREEZE
                        WHERE
                            SponsorCode IN (
                                SELECT
                                    ClientCode
                                FROM
                                    Show.WebFreeze
                                WHERE
                                    CURRENT_TIMESTAMP BETWEEN FreezeStartDate
                                    and IFNULL(FreezeEndDate, '9999-09-09')) $$;



--- Insert Statement
insert_statement_1 := ' INSERT
                            (
                                ProviderID,
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
                                --AvailabilityStatement,
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
                                TeleHealthXML
                            )
                        VALUES
                        (
                            source.ProviderID,
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
                            --source.AvailabilityStatement,
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
                            source.TeleHealthXML
                        );';


------------ Step 2: Generate From Mid --------------

--- Select Statement 
select_statement_2 :=  $$ with cte_batch_process as (
                            	SELECT DISTINCT
                    					p.ProviderID
                    			From Base.Provider AS p 
                    			WHERE 	p.NPI IS NOT NULL
                    			UNION 
                    			SELECT DISTINCT
                    					p.ProviderID
                    			FROM    mdm_team.mst.provider_profile_processing AS ppp 
                    			INNER JOIN Base.Provider AS p ON p.providercode = ppp.REF_PROVIDER_CODE
                    			WHERE 	p.NPI IS NOT NULL
                                
                        ), cte_provider_image as (
                                SELECT
                                    *
                                FROM
                                    (
                                        SELECT
                                            a.ProviderID,
                                            a.FileName AS ImageFilePath,
                                            'http://d306gt4zvs7g2s.cloudfront.net/img/prov/' || SUBSTRING(a.FileName, 1, 1) || '/' || SUBSTRING(a.FileName, 2, 1) || '/' || SUBSTRING(a.FileName, 3, 1) || '/' || a.FileName AS imFull,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY a.ProviderId
                                                ORDER BY
                                                    a.ProviderId
                                            ) AS RN1
                                        FROM
                                            Base.ProviderImage a
                                            INNER JOIN Base.MediaSize ms ON a.MediaSizeID = ms.MediaSizeID
                                        WHERE
                                            ms.MediaSizeName = 'Medium'
                                    )
                                WHERE
                                    RN1 <= 1
                            ) 
                        ,
                            cte_care_philosophy as (
                                SELECT
                                    *
                                FROM
                                    (
                                        SELECT
                                            ProviderID,
                                            pam.ProviderAboutMeText,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY ProviderId
                                                ORDER BY
                                                    PAM.LastUpdatedDate DESC
                                            ) AS RN1
                                        FROM
                                            Base.AboutMe am
                                            INNER JOIN Base.ProviderToAboutMe pam ON am.AboutMeID = pam.AboutMeID
                                            AND am.AboutMeCode = 'CarePhilosophy'
                                    )
                                WHERE
                                    RN1 <= 1
                            ) 
                        ,
                            cte_city_state_greater_1 as (
                                SELECT
                                    ProviderID --652,813
                                FROM
                                    Mid.ProviderPracticeOffice
                                GROUP BY
                                    ProviderID
                                HAVING
                                    COUNT(DISTINCT CONCAT(City, State)) > 1
                            ),
                            cte_city_state_concat as (
                                SELECT
                                    providerID,
                                    LISTAGG(city || ', ' || state, '|') as CityState
                                FROM
                                    Mid.ProviderPracticeOffice
                                GROUP BY
                                    providerID
                            ),
                            cte_city_state_multiple as (
                                SELECT
                                    CTE_BATCH.ProviderID,
                                    CTE_CSC.CityState AS CityStateAll
                                FROM
                                    cte_batch_process as CTE_BATCH
                                    JOIN cte_city_state_greater_1 b ON CTE_BATCH.ProviderID = b.ProviderID
                                    LEFT JOIN cte_city_state_concat as CTE_CSC on CTE_BATCH.ProviderID = CTE_CSC.ProviderID
                            ),
                            cte_city_state_equal_1 as (
                                SELECT
                                    ProviderID --652,813
                                FROM
                                    Mid.ProviderPracticeOffice
                                GROUP BY
                                    ProviderID
                                HAVING
                                    COUNT(DISTINCT CONCAT(City, State)) = 1
                            ),
                            cte_city_state_single as (
                                SELECT
                                    MPPO.ProviderId,
                                    TRIM(City) || ', ' || State AS CityStateAll
                                FROM
                                    Mid.ProviderPracticeOffice AS MPPO
                                    JOIN cte_city_state_equal_1 AS CTE_CSE1 ON MPPO.providerid = CTE_CSE1.providerid
                            ),
                            cte_city_state_all as (
                                SELECT
                                    CTE_BP.ProviderId,
                                    CASE
                                        WHEN CTE_CSM.ProviderID IS NULL THEN CTE_CSS.CityStateAll
                                        ELSE CTE_CSM.CityStateAll
                                    END AS CityStateAll
                                FROM
                                    cte_batch_process AS CTE_BP
                                    LEFT JOIN cte_city_state_single AS CTE_CSS ON CTE_CSS.ProviderID = CTE_BP.ProviderID
                                    LEFT JOIN cte_city_state_multiple AS CTE_CSM ON CTE_CSM.ProviderID = CTE_BP.ProviderID
                            ),
                            cte_email as (
                                SELECT
                                    *
                                FROM
                                    (
                                        SELECT
                                            ProviderID,
                                            EmailAddress,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY ProviderId
                                                ORDER BY
                                                    LastUpdateDate DESC
                                            ) AS RN1
                                        FROM
                                            Base.ProviderEmail
                                    )
                                WHERE
                                    RN1 <= 1
                            ) 
                        ,
                            cte_provider_type_group as (
                                SELECT
                                    *
                                FROM
                                    (
                                        SELECT
                                            ProviderTypeID,
                                            TRIM(x.ProviderTypeCode) AS ProviderTypeCode,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY ProviderTypeID
                                                ORDER BY
                                                    X.LastUpdateDate DESC
                                            ) AS RN1
                                        FROM
                                            Base.ProviderType X
                                    )
                                WHERE
                                    RN1 <= 1
                            ),
                            cte_media_school_nation as (
                                SELECT
                                    *
                                FROM
                                    (
                                        SELECT
                                            MPE.ProviderID,
                                            MPE.NationName,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY MPE.ProviderId
                                                ORDER BY
                                                    MPE.NationName DESC,
                                                    MPE.GraduationYear DESC
                                            ) AS RN1
                                        FROM
                                            Mid.ProviderEducation AS MPE
                                            INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = MPE.ProviderID
                                    )
                                WHERE
                                    RN1 <= 1
                            ) 
                        ,
                            cte_years_since_medical_school_graduation as (
                                SELECT
                                    *
                                FROM
                                    (
                                        SELECT
                                            MPE.ProviderID,
                                            EXTRACT(
                                                YEAR
                                                FROM
                                                    CURRENT_DATE
                                            ) - CASE
                                                WHEN TRY_TO_NUMBER(GraduationYear) IS NULL THEN NULL
                                                ELSE TRY_TO_NUMBER(GraduationYear)
                                            END AS YearsSinceMedicalSchoolGraduation,
                                            ROW_NUMBER() OVER (
                                                PARTITION BY MPE.ProviderId
                                                ORDER BY
                                                    MPE.NationName DESC,
                                                    MPE.GraduationYear DESC
                                            ) AS RN1
                                        FROM
                                            Mid.ProviderEducation MPE
                                            INNER JOIN cte_batch_process CTE_BP ON CTE_BP.ProviderID = MPE.ProviderID
                                    )
                                WHERE
                                    RN1 <= 1
                            ) 
                        ,
                            cte_patient_experience_survey_overall_score as (
                                SELECT
                                    *
                                FROM
                                    (
                                        SELECT
                                            BPSA.ProviderID,
                                            (ProviderAverageScore / 5) * 100 AS PatientExperienceSurveyOverallScore,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY BPSA.ProviderId
                                                ORDER BY
                                                    BPSA.UpdatedOn DESC
                                            ) AS RN1
                                        FROM
                                            base.ProviderSurveyAggregate AS BPSA
                                            INNER JOIN cte_batch_process CTE_BP ON CTE_BP.ProviderID = BPSA.ProviderID
                                        WHERE
                                            QuestionID = 231
                                    )
                                WHERE
                                    RN1 <= 1
                            ),
                            cte_patient_experience_survey_overall_star_value as (
                                select
                                    *
                                from
                                    (
                                        SELECT
                                            BPSA.ProviderID,
                                            BPSA.ProviderAverageScore,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY BPSA.ProviderId
                                                ORDER BY
                                                    BPSA.UpdatedOn DESC
                                            ) AS RN1
                                        FROM
                                            base.ProviderSurveyAggregate AS BPSA
                                            INNER JOIN cte_batch_process CTE_BP ON CTE_BP.ProviderID = BPSA.ProviderID
                                        WHERE
                                            QuestionID = 231
                                    )
                                where
                                    rn1 <= 1
                            ),
                            cte_patient_experience_survey_overall_count as (
                                SELECT
                                    *
                                FROM
                                    (
                                        SELECT
                                            BPSA.ProviderID,
                                            BPSA.QuestionCount,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY BPSA.ProviderId
                                                ORDER BY
                                                    BPSA.UpdatedOn DESC
                                            ) AS RN1
                                        FROM
                                            base.ProviderSurveyAggregate AS BPSA
                                            INNER JOIN cte_batch_process CTE_BP ON CTE_BP.ProviderID = BPSA.ProviderID
                                        WHERE
                                            QuestionID = 231
                                    )
                                WHERE
                                    RN1 <= 1
                            ),
                            cte_display_status_code_sub as (
                                SELECT
                                    BPTSS.ProviderId,
                                    BDS.DisplayStatusCode,
                                    BPTSS.HierarchyRank,
                                    SS.SubStatusRank
                                FROM
                                    Base.ProviderToSubStatus AS BPTSS
                                    INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = BPTSS.ProviderID
                                    INNER JOIN Base.SubStatus AS SS ON SS.SubStatusID = BPTSS.SubStatusID
                                    INNER JOIN Base.DisplayStatus AS BDS ON BDS.DisplayStatusID = SS.DisplayStatusID
                                WHERE
                                    BPTSS.hierarchyrank = 1
                                UNION
                                SELECT
                                    ProviderId,
                                    'A' AS DisplayStatusCode,
                                    2147483647 AS HierarchyRank,
                                    2147483647 AS SubStatusRank
                                FROM
                                    Base.Provider
                            ),
                            cte_display_status_code as (
                                SELECT
                                    *
                                FROM(
                                        SELECT
                                            ProviderId,
                                            DisplayStatusCode,
                                            HierarchyRank,
                                            SubStatusRank,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY ProviderId
                                                ORDER BY
                                                    HierarchyRank,
                                                    SubStatusRank
                                            ) AS RN1
                                        from
                                            cte_display_status_code_sub
                                    )
                                WHERE
                                    RN1 <= 1
                            ),
                            cte_sub_status_code_sub AS (
                                SELECT
                                    BPSS.ProviderId,
                                    SS.SubStatusCode,
                                    BPSS.HierarchyRank,
                                    SS.SubStatusRank
                                FROM
                                    Base.ProviderToSubStatus AS BPSS
                                    INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = BPSS.ProviderID
                                    INNER JOIN Base.SubStatus AS SS ON SS.SubStatusID = BPSS.SubStatusID
                                    INNER JOIN Base.DisplayStatus AS BDS ON BDS.DisplayStatusID = SS.DisplayStatusID
                                WHERE
                                    BPSS.hierarchyrank = 1
                                UNION
                                SELECT
                                    ProviderId,
                                    'K' AS SubStatusCode,
                                    2147483647 AS HierarchyRank,
                                    2147483647 AS SubStatusRank
                                FROM
                                    Base.Provider
                            ),
                            cte_sub_status_code as (
                                SELECT
                                    *
                                FROM
                                    (
                                        SELECT
                                            ProviderId,
                                            SubStatusCode,
                                            HierarchyRank,
                                            SubStatusRank,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY ProviderId
                                                ORDER BY
                                                    HierarchyRank,
                                                    SubStatusRank
                                            ) AS RN1
                                        FROM
                                            cte_sub_status_code_sub
                                    )
                                WHERE
                                    RN1 <= 1
                            ),
                            cte_product_group_code as (
                                SELECT
                                    *
                                FROM
                                    (
                                        SELECT
                                            P.ProviderID,
                                            ProductGroupCode,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY P.ProviderId
                                                ORDER BY
                                                    ProductGroupCode DESC
                                            ) AS RN1
                                        FROM
                                            Mid.ProviderSponsorship AS MPS
                                            INNER JOIN Base.Provider AS P ON P.ProviderCode = MPS.ProviderCode
                                            INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = P.ProviderID
                                        WHERE
                                            ProductGroupCode = 'PDC'
                                    )
                                WHERE
                                    RN1 <= 1
                            ) 
                        ,
                            cte_product_code as (
                                SELECT
                                    *
                                FROM
                                    (
                                        SELECT
                                            P.ProviderID,
                                            ProductCode,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY P.ProviderId
                                                ORDER BY
                                                    ProductGroupCode DESC
                                            ) AS RN1
                                        FROM
                                            Mid.ProviderSponsorship AS MPS
                                            INNER JOIN Base.Provider AS P ON P.ProviderCode = MPS.ProviderCode
                                            INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = P.ProviderID
                                        WHERE
                                            ProductGroupCode = 'PDC'
                                    )
                                WHERE
                                    RN1 <= 1
                            ) 
                        ,
                            cte_sponsor_code as (
                                SELECT
                                    *
                                FROM
                                    (
                                        SELECT
                                            P.ProviderID,
                                            ClientCode AS SponsorCode,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY P.ProviderId
                                                ORDER BY
                                                    ProductGroupCode DESC
                                            ) AS RN1
                                        FROM
                                            Mid.ProviderSponsorship AS MPS
                                            INNER JOIN Base.Provider AS P ON P.ProviderCode = MPS.ProviderCode
                                            INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = P.ProviderID
                                        WHERE
                                            ProductGroupCode = 'PDC'
                                    )
                                WHERE
                                    RN1 <= 1
                            ) 
                        ,
                            cte_pipe_separated_facility as (
                                select
                                    P.ProviderID,
                                    listagg(MPS.providercode, '|') as codes
                                FROM
                                    Mid.ProviderSponsorship AS MPS
                                    INNER JOIN Base.Provider AS P ON P.ProviderCode = MPS.ProviderCode
                                    INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = P.ProviderID
                                WHERE
                                    ProductGroupCode = 'PDC'
                                group by
                                    P.providerid
                            ) 
                        ,
                            cte_facility_code as (
                                SELECT
                                    P.ProviderID,
                                    CTE_PSF.codes AS Facility,
                                    ROW_NUMBER() OVER(
                                        PARTITION BY P.ProviderId
                                        ORDER BY
                                            ProductGroupCode DESC
                                    ) AS RN1
                                FROM
                                    Mid.ProviderSponsorship AS MPS
                                    INNER JOIN Base.Provider AS P ON P.ProviderCode = MPS.ProviderCode
                                    INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = P.ProviderID
                                    INNER JOIN cte_pipe_separated_facility AS CTE_PSF ON CTE_PSF.ProviderID = P.ProviderID
                                WHERE
                                    ProductGroupCode = 'PDC'
                            ) 
                        ,
                            cte_about_me as (
                                SELECT
                                    PAM.ProviderID,
                                    ProviderAboutMeText,
                                    ROW_NUMBER() OVER(
                                        PARTITION BY CTE_BP.ProviderId
                                        ORDER BY
                                            PAM.LastUpdatedDate DESC
                                    ) AS RN1
                                FROM
                                    Base.AboutMe AS AM
                                    INNER JOIN Base.ProviderToAboutMe AS PAM ON AM.AboutMeID = PAM.AboutMeID
                                    AND AM.AboutMeCode = 'ResponseToPes'
                                    INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = PAM.ProviderID
                            ) 
                        ,
                            cte_survey_response_date as (
                                SELECT
                                    PAM.ProviderID,
                                    SurveyResponseDate,
                                    ROW_NUMBER() OVER(
                                        PARTITION BY CTE_BP.ProviderId
                                        ORDER BY
                                            PAM.SurveyResponseDate DESC
                                    ) AS RN1
                                FROM
                                    Mid.ProviderSurveyResponse AS PAM
                                    INNER JOIN CTE_BATCH_PROCESS AS CTE_BP ON CTE_BP.ProviderID = PAM.ProviderID
                            ) 
                        ,
                            cte_has_malpractice_state_sub as (
                                SELECT
                                    ProviderId,
                                    CASE
                                        WHEN EXISTS (
                                            SELECT
                                                1
                                            FROM
                                                Mid.ProviderPracticeOffice ppo
                                                JOIN Base.MalpracticeState mps ON ppo.State = mps.STATE
                                                AND IFNULL(mps.Active, 1) = 1
                                            WHERE
                                                p.ProviderID = ppo.ProviderID
                                        ) THEN 1
                                        WHEN EXISTS (
                                            SELECT
                                                1
                                            FROM
                                                Mid.ProviderMalpractice pm
                                            WHERE
                                                p.ProviderID = pm.ProviderID
                                        ) THEN 1
                                        ELSE 0
                                    END HasMalpracticeState
                                FROM
                                    cte_batch_process P
                            ) 
                        ,
                            cte_has_malpractice_state as (
                                select
                                    *
                                from
                                    (
                                        SELECT
                                            ProviderId,
                                            HasMalpracticeState,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY ProviderID
                                                ORDER BY
                                                    HasMalpracticeState DESC
                                            ) AS RN1
                                        FROM
                                            cte_has_malpractice_state_sub
                                    )
                                WHERE
                                    RN1 <= 1
                            ) 
                        ,
                            cte_procedure_count as (
                                SELECT
                                    MPP.ProviderID,
                                    COUNT(ProcedureCode) AS ProcedureCount
                                FROM
                                    Mid.ProviderProcedure AS MPP
                                    INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = MPP.ProviderID
                                GROUP BY
                                    MPP.ProviderID
                            ) 
                        ,
                            cte_condition_count as (
                                SELECT
                                    MPP.ProviderID,
                                    COUNT(ProcedureCode) AS ConditionCount
                                FROM
                                    Mid.ProviderProcedure AS MPP
                                    INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = MPP.ProviderID
                                GROUP BY
                                    MPP.ProviderID
                            ) 
                        ,
                            cte_condition_code as (
                                SELECT
                                    MPP.ProviderID,
                                    COUNT(ProcedureCode) AS ConditionCount
                                FROM
                                    Mid.ProviderProcedure AS MPP
                                    INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = MPP.ProviderID
                                GROUP BY
                                    MPP.ProviderID
                            ) 
                        ,
                            --THIS CTE RETURNS EMPTY, I VALIDATED IN SQL SERVER IT ALSO RETURNS EMPTY
                            cte_oar as (
                                SELECT
                                    DISTINCT CTE_BP.ProviderId,
                                    HasOar
                                FROM
                                    Mid.ProviderSponsorship AS MPS
                                    INNER JOIN Base.Product AS BP ON MPS.ProductCode = BP.ProductCode
                                    INNER JOIN Base.Provider AS P ON P.ProviderCode = MPS.ProviderCode
                                    INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = P.ProviderID
                                    AND(
                                        BP.ProductTypeCode = 'PRACTICE'
                                        OR MPS.clientcode IN ('OCHSNR', 'PRVHEW')
                                    )
                            ) 
                        ,
                            cte_availability_statement as (
                                SELECT
                                    BPAAS.ProviderID,
                                    AppointmentAvailabilityStatement,
                                    ROW_NUMBER() OVER(
                                        PARTITION BY BPAAS.ProviderId
                                        ORDER BY
                                            LastUpdatedDate DESC
                                    ) AS RN1
                                FROM
                                    Base.ProviderAppointmentAvailabilityStatement AS BPAAS
                                    INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = BPAAS.ProviderID
                            ) 
                        ,
                            cte_has_about_me as (
                                SELECT
                                    DISTINCT CTE_BP.ProviderID,
                                    1 AS HasAboutMe
                                FROM
                                    Base.AboutMe AS BAM
                                    INNER JOIN Base.ProviderToAboutMe AS PAM ON PAM.AboutMeID = BAM.AboutMeID
                                    INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = PAM.ProviderID
                                WHERE
                                    BAM.AboutMeCode = 'About'
                            ) 
                        ,
                            cte_provider_sub_type as (
                                select
                                    *
                                from
                                    (
                                        SELECT
                                            BPTPST.ProviderID,
                                            BPST.ProviderSubTypeCode,
                                            ROW_NUMBER() OVER(
                                                PARTITION BY BPTPST.ProviderId
                                                ORDER BY
                                                    BPST.ProviderSubTypeRank ASC,
                                                    BPTPST.LastUpdateDate DESC
                                            ) AS RN1
                                        FROM
                                            Base.ProviderToProviderSubType AS BPTPST
                                            INNER JOIN Base.ProviderSubType AS BPST ON BPTPST.ProviderSubTypeID = BPST.ProviderSubTypeID
                                            INNER JOIN cte_batch_process AS CTE_BP ON CTE_BP.ProviderID = BPTPST.ProviderID
                                    )
                                WHERE
                                    RN1 <= 1
                            ) 
                        ,
                            cte_provider_is_board_eligible as (
                                SELECT
                                    ps.ProviderID
                                FROM
                                    Base.ProviderSanction AS ps
                                    JOIN Base.SanctionAction AS sa ON sa.SanctionActionID = ps.SanctionActionID
                                    JOIN Base.SanctionActionType AS sat ON sat.SanctionActionTypeID = sa.SanctionActionTypeID
                                    JOIN cte_batch_process AS bp ON ps.ProviderID = bp.ProviderID
                                WHERE
                                    sat.SanctionActionTypeCode = 'B'
                                UNION
                                    --Using Only Provider SubType (DOC and NDOC)
                                SELECT
                                    ptpst.ProviderID
                                FROM
                                    Base.ProviderSubType AS pst
                                    JOIN Base.ProviderToProviderSubType AS ptpst ON ptpst.ProviderSubTypeID = pst.ProviderSubTypeID
                                    JOIN cte_batch_process AS bp ON ptpst.ProviderID = bp.ProviderID
                                WHERE
                                    pst.IsBoardActionEligible = 1
                                UNION
                                    --Using Provider SubType To Degree (MDEX Plus Degrees)
                                SELECT
                                    ptpst.ProviderID
                                FROM
                                    Base.ProviderSubTypeToDegree AS psttd
                                    JOIN Base.ProviderToProviderSubType AS ptpst ON psttd.ProviderSubTypeID = ptpst.ProviderSubTypeID
                                    JOIN Base.ProviderToDegree AS ptd ON ptd.ProviderID = ptpst.ProviderID
                                    AND psttd.DegreeID = ptd.DegreeID
                                    JOIN cte_batch_process AS bp ON ptpst.ProviderID = bp.ProviderID
                                WHERE
                                    psttd.IsBoardActionEligible = 1
                                UNION
                                    --Using Specialty Group (GMPA)
                                SELECT
                                    ps.ProviderID
                                FROM
                                    Base.SpecialtyGroup AS sg
                                    JOIN Base.SpecialtyGroupToSpecialty AS sgts ON sgts.SpecialtyGroupID = sg.SpecialtyGroupID
                                    JOIN Base.ProviderToSpecialty AS ps ON ps.SpecialtyID = sgts.SpecialtyID
                                    JOIN cte_batch_process AS bp ON ps.ProviderID = bp.ProviderID
                                WHERE
                                    sg.IsBoardActionEligible = 1
                            ) 
                        ,
                            cte_pss as (
                                SELECT
                                    a.ProviderID,
                                    a.SubStatusValueA
                                FROM
                                    Base.ProviderToSubStatus AS a
                                    JOIN Base.SubStatus AS b ON b.SubStatusID = a.SubStatusID
                                    AND b.SubStatusCode = 'U'
                            ) 
                        ,
                            cte_prov_updates_sub as (
                                SELECT
                                    DISTINCT p.ProviderID,
                                    p.ProviderCode,
                                    p.ProviderTypeID,
                                    p.FirstName,
                                    p.MiddleName,
                                    p.LastName,
                                    p.Suffix,
                                    p.Gender,
                                    p.NPI,
                                    p.AMAID,
                                    p.UPIN,
                                    p.MedicareID,
                                    p.DEANumber,
                                    p.TaxIDNumber,
                                    p.DateOfBirth,
                                    p.PlaceOfBirth,
                                    CTE_CP.ProviderID AS CarePhilosophy,
                                    p.ProfessionalInterest,
                                    p.AcceptsNewPatients,
                                    p.HasElectronicMedicalRecords,
                                    p.HasElectronicPrescription,
                                    p.LegacyKey,
                                    p.DegreeAbbreviation AS Degree,
                                    p.Title,
                                    p.ProviderURL,
                                    p.ExpireCode,
                                    pss.SubStatusValueA,
                                    CTE_CSA.CityStateAll AS CityStateAll,
                                    CTE_E.EmailAddress AS PrimaryEmailAddress,
                                    TRIM(CTE_PTG.ProviderTypeCode) AS ProviderTypeGroup,
                                    CTE_MSN.NationName AS MedicalSchoolNation,
                                    CTE_YSMSG.YearsSinceMedicalSchoolGraduation AS YearsSinceMedicalSchoolGraduation,
                                    CASE
                                        WHEN EXISTS(
                                            SELECT
                                                ProviderId
                                            FROM
                                                cte_provider_image AS a
                                            WHERE
                                                a.ProviderID = p.ProviderID
                                        ) THEN 1
                                        ELSE 0
                                    END AS HasDisplayImage,
                                    CTE_PI.ImageFilePath AS Image,
                                    CTE_PI.imFull AS imFull,
                                    NULL AS ProviderProfileViewOneYear,
                                    NULL AS YearlySearchVolume,
                                    CTE_PESOS.PatientExperienceSurveyOverallScore AS PatientExperienceSurveyOverallScore,
                                    CTE_PESOSV.ProviderAverageScore AS PatientExperienceSurveyOverallStarValue,
                                    CTE_PESOC.QuestionCount AS PatientExperienceSurveyOverallCount,
                                    NULL AS ProviderBiography,
                                    CTE_DSC.DisplayStatusCode AS DisplayStatusCode,
                                    CTE_SSC.SubStatusCode AS SubStatusCode,
                                    CTE_PGC.ProductGroupCode AS ProductGroupCode,
                                    CTE_SC.SponsorCode AS SponsorCode,
                                    CTE_PC.ProductCode AS ProductCode,
                                    CTE_FC.Facility AS FacilityCode,
                                    CTE_AM.ProviderAboutMeText AS SurveyResponse,
                                    CTE_SRD.SurveyResponseDate AS SurveyResponseDate,
                                    CTE_HMS.HasMalpracticeState AS HasMalpracticeState,
                                    CTE_PCOUNT.ProcedureCount AS ProcedureCount,
                                    CTE_CC.ConditionCount AS ConditionCount,
                                    NULL AS PatientVolume,
                                    -- CTE_AS.AppointmentAvailabilityStatement AS AvailabilityStatement,
                                    p.ProviderLastUpdateDateOverall AS UpdatedDate,
                                    NULL AS UpdatedSource,
                                    CTE_O.HasOar AS HasOar,
                                    NULL AS IsMMPUser,
                                    CTE_HAM.HasAboutMe AS HasAboutMe,
                                    pb.SearchBoostSatisfaction,
                                    pb.SearchBoostAccessibility,
                                    pb.IsPCPCalculated,
                                    pb.FAFBoostSatisfaction,
                                    pb.FAFBoostSancMalp,
                                    p.FFDisplaySpecialty,
                                    pb.FFESatisfactionBoost as FFPESBoost,
                                    pb.FFMalMultiHQ,
                                    pb.FFMalMulti,
                                    CTE_PST.ProviderSubTypeCode AS ProviderSubTypeCode
                                FROM
                                    Mid.Provider AS p
                                    INNER JOIN Base.Provider as pb on pb.ProviderID = p.ProviderID -- INNER JOIN #BatchInsertUpdateProcess
                                    -- AS batch ON batch.ProviderID = p.ProviderID
                                    INNER JOIN cte_batch_process as CTE_BP ON CTE_BP.ProviderID = p.providerid
                                    LEFT JOIN cte_city_state_multiple e ON p.ProviderID = e.ProviderID
                                    LEFT JOIN cte_pss AS pss on pss.ProviderID = p.ProviderID
                                    LEFT JOIN cte_care_philosophy AS CTE_CP ON CTE_CP.ProviderID = p.ProviderID
                                    LEFT JOIN cte_city_state_all AS CTE_CSA ON CTE_CSA.ProviderID = p.ProviderID
                                    LEFT JOIN cte_email AS CTE_E ON CTE_E.ProviderID = p.ProviderID
                                    LEFT JOIN cte_provider_type_group AS CTE_PTG ON CTE_PTG.ProviderTypeID = p.ProviderTypeID
                                    LEFT JOIN cte_media_school_nation AS CTE_MSN ON CTE_MSN.ProviderID = p.ProviderID
                                    LEFT JOIN cte_years_since_medical_school_graduation AS CTE_YSMSG ON CTE_YSMSG.ProviderID = p.ProviderID
                                    LEFT JOIN cte_provider_image AS CTE_PI ON CTE_PI.ProviderID = p.ProviderID
                                    LEFT JOIN cte_patient_experience_survey_overall_score AS CTE_PESOS ON CTE_PESOS.ProviderID = p.ProviderID
                                    LEFT JOIN cte_patient_experience_survey_overall_star_value AS CTE_PESOSV ON CTE_PESOSV.ProviderID = p.ProviderID
                                    LEFT JOIN cte_patient_experience_survey_overall_count AS CTE_PESOC ON CTE_PESOC.ProviderID = p.ProviderID
                                    LEFT JOIN cte_display_status_code AS CTE_DSC ON CTE_DSC.ProviderID = p.ProviderID
                                    LEFT JOIN cte_sub_status_code AS CTE_SSC ON CTE_SSC.ProviderID = p.ProviderID
                                    LEFT JOIN cte_product_group_code AS CTE_PGC ON CTE_PGC.ProviderID = p.ProviderID
                                    LEFT JOIN cte_sponsor_code AS CTE_SC ON CTE_SC.ProviderID = p.ProviderID
                                    LEFT JOIN cte_product_code AS CTE_PC ON CTE_PC.ProviderID = p.ProviderID
                                    LEFT JOIN cte_facility_code AS CTE_FC ON CTE_FC.ProviderID = p.ProviderID
                                    LEFT JOIN cte_about_me AS CTE_AM ON CTE_AM.ProviderID = p.ProviderID
                                    LEFT JOIN cte_survey_response_date AS CTE_SRD ON CTE_SRD.ProviderID = p.ProviderID
                                    LEFT JOIN cte_has_malpractice_state AS CTE_HMS ON CTE_HMS.ProviderID = p.ProviderID
                                    LEFT JOIN cte_procedure_count AS CTE_PCOUNT ON CTE_PCOUNT.ProviderID = p.ProviderID
                                    LEFT JOIN cte_condition_count AS CTE_CC ON CTE_CC.ProviderID = p.ProviderID
                                    LEFT JOIN cte_availability_statement AS CTE_AS ON CTE_AS.ProviderID = p.ProviderID
                                    LEFT JOIN cte_oar AS CTE_O ON CTE_O.ProviderID = p.ProviderID
                                    LEFT JOIN cte_has_about_me AS CTE_HAM ON CTE_HAM.ProviderID = p.ProviderID
                                    LEFT JOIN cte_provider_sub_type AS CTE_PST ON CTE_PST.ProviderID = p.ProviderID
                            ),
                            cte_prov_updates as (
                                SELECT
                                    CTE_PUS.ProviderID,
                                    ProviderCode,
                                    LegacyKey AS ProviderLegacyKey,
                                    ProviderTypeID,
                                    ProviderTypeGroup,
                                    FirstName,
                                    MiddleName,
                                    LastName,
                                    Suffix,
                                    UPPER(Degree) AS Degree,
                                    UPPER(Gender) AS Gender,
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
                                    /*City,St*/
                                    MedicalSchoolNation,
                                    YearsSinceMedicalSchoolGraduation,
                                    HasDisplayImage,
                                    imFull AS DisplayImage,
                                    HasElectronicMedicalRecords,
                                    HasElectronicPrescription,
                                    AcceptsNewPatients,
                                    YearlySearchVolume,
                                    ProviderProfileViewOneYear,
                                    PatientExperienceSurveyOverallScore,
                                    PatientExperienceSurveyOverallStarValue,
                                    PatientExperienceSurveyOverallCount,
                                    ProviderBiography,
                                    ProviderURL,
                                    CTE_PUS.DisplayStatusCode,
                                    CTE_PUS.SubStatusCode,
                                    CASE
                                        WHEN SubStatusCode = 'U' THEN SubStatusValueA
                                        ELSE NULL
                                    END AS DuplicateProviderCode,
                                    ProductGroupCode,
                                    SponsorCode,
                                    ProductCode,
                                    FacilityCode,
                                    SurveyResponse,
                                    SurveyResponseDate,
                                    HasMalpracticeState,
                                    ProcedureCount,
                                    ConditionCount,
                                    NULL AS IsActive,
                                    UpdatedDate,
                                    UpdatedSource,
                                    Title,
                                    CityStateAll,
                                    CASE
                                        WHEN PatientExperienceSurveyOverallScore >= 75 THEN 1
                                        ELSE 0
                                    END AS DisplayPatientExperienceSurveyOverallScore,
                                    CTE_DS.DeactivationReason AS DeactivationReason,
                                    PatientVolume,
                                    -- AvailabilityStatement,
                                    HasOAR,
                                    IsMMPUser,
                                    HasAboutMe,
                                    SearchBoostSatisfaction,
                                    SearchBoostAccessibility,
                                    IsPCPCalculated,
                                    FAFBoostSatisfaction,
                                    FAFBoostSancMalp,
                                    FFDisplaySpecialty,
                                    FFPESBoost,
                                    FFMalMultiHQ,
                                    FFMalMulti,
                                    ProviderSubTypeCode
                                FROM
                                    cte_prov_updates_sub AS CTE_PUS
                                    LEFT JOIN Base.DisplayStatus AS CTE_DS ON CTE_DS.DisplayStatusCode = CTE_PUS.DisplayStatusCode -- JOIN #BatchInsertUpdateProcess b ON b.ProviderID = py.ProviderID
                            ),
                            cte_display_image as (
                                SELECT
                                    PU.ProviderID,
                                    '/img/prov/' || LOWER(SUBSTRING(bp.ProviderCode, 1, 1)) || '/' || LOWER(SUBSTRING(bp.ProviderCode, 2, 1)) || '/' || LOWER(SUBSTRING(bp.ProviderCode, 3, 1)) || '/' || LOWER(bp.ProviderCode) || '_w' || CAST(ms.Width AS VARCHAR(10)) || 'h' || CAST(ms.Height AS VARCHAR(10)) || '_v' || bpi.ExternalIdentifier || '.jpg' AS DisplayImage
                                FROM
                                    Base.ProviderImage AS bpi
                                    INNER JOIN Base.Provider AS bp ON bp.ProviderID = bpi.ProviderID
                                    INNER JOIN cte_prov_updates AS PU ON PU.ProviderId = bp.ProviderId
                                    INNER JOIN Base.MediaImageHost AS mih ON mih.MediaImageHostID = bpi.MediaImageHostID
                                    INNER JOIN Base.MediaContextType AS mct ON mct.MediaContextTypeID = bpi.MediaContextTypeID
                                    CROSS JOIN Base.MediaSize AS ms
                                WHERE
                                    mih.MediaImageHostCode = 'BRIGHTSPOT'
                                    AND ms.MediaSizeCode IN ('MEDIUM')
                                    AND PU.DisplayImage IS NULL
                                    AND PU.HasDisplayImage = 1
                            ) 
                            SELECT
                                CTE_PU.ProviderID,
                                ProviderCode,
                                ProviderLegacyKey,
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
                                ----------------------------------
                                CASE
                                    WHEN CTE_PU.DisplayImage IS NULL
                                    AND CTE_PU.HasDisplayImage = 1 THEN CTE_DI.DisplayImage
                                    ELSE CTE_PU.DisplayImage
                                END AS DisplayImage,
                                ----------------------------------
                                HasDisplayImage,
                                HasElectronicMedicalRecords,
                                HasElectronicPrescription,
                                AcceptsNewPatients,
                                YearlySearchVolume,
                                ProviderProfileViewOneYear,
                                PatientExperienceSurveyOverallScore,
                                PatientExperienceSurveyOverallStarValue,
                                PatientExperienceSurveyOverallCount,
                                ProviderBiography,
                                ProviderURL,
                                DisplayStatusCode,
                                SubStatusCode,
                                DuplicateProviderCode,
                                ProductGroupCode,
                                SponsorCode,
                                ProductCode,
                                FacilityCode,
                                SurveyResponse,
                                SurveyResponseDate,
                                HasMalpracticeState,
                                ProcedureCount,
                                ConditionCount,
                                IsActive,
                                UpdatedDate,
                                UpdatedSource,
                                Title,
                                CityStateAll,
                                DisplayPatientExperienceSurveyOverallScore,
                                DeactivationReason,
                                PatientVolume,
                                -- AvailabilityStatement,
                                HasOAR,
                                IsMMPUser,
                                HasAboutMe,
                                SearchBoostSatisfaction,
                                SearchBoostAccessibility,
                                IsPCPCalculated,
                                FAFBoostSatisfaction,
                                FAFBoostSancMalp,
                                FFDisplaySpecialty,
                                FFPESBoost,
                                FFMalMultiHQ,
                                FFMalMulti,
                                ProviderSubTypeCode
                            FROM
                                cte_prov_updates AS CTE_PU
                                LEFT JOIN cte_display_image AS CTE_DI ON CTE_DI.ProviderID = CTE_PU.ProviderID $$;

--- Update Statement
update_statement_2 := ' UPDATE
                        SET
                            target.ProviderCode = source.ProviderCode,
                            target.ProviderTypeID = source.ProviderTypeID,
                            target.ProviderTypeGroup = source.ProviderTypeGroup,
                            target.FirstName = source.FirstName,
                            target.MiddleName = source.MiddleName,
                            target.LastName = source.LastName,
                            target.Suffix = source.Suffix,
                            target.Degree = source.Degree,
                            target.Gender = source.Gender,
                            target.NPI = source.NPI,
                            target.AMAID = source.AMAID,
                            target.UPIN = source.UPIN,
                            target.MedicareID = source.MedicareID,
                            target.DEANumber = source.DEANumber,
                            target.TaxIDNumber = source.TaxIDNumber,
                            target.DateOfBirth = source.DateOfBirth,
                            target.PlaceOfBirth = source.PlaceOfBirth,
                            target.CarePhilosophy = source.CarePhilosophy,
                            target.ProfessionalInterest = source.ProfessionalInterest,
                            target.PrimaryEmailAddress = source.PrimaryEmailAddress,
                            target.MedicalSchoolNation = source.MedicalSchoolNation,
                            target.YearsSinceMedicalSchoolGraduation = source.YearsSinceMedicalSchoolGraduation,
                            target.HasDisplayImage = source.HasDisplayImage,
                            target.HasElectronicMedicalRecords = source.HasElectronicMedicalRecords,
                            target.HasElectronicPrescription = source.HasElectronicPrescription,
                            target.AcceptsNewPatients = source.AcceptsNewPatients,
                            target.YearlySearchVolume = source.YearlySearchVolume,
                            target.ProviderProfileViewOneYear = source.ProviderProfileViewOneYear,
                            target.PatientExperienceSurveyOverallScore = source.PatientExperienceSurveyOverallScore,
                            target.PatientExperienceSurveyOverallStarValue = source.PatientExperienceSurveyOverallStarValue,
                            target.PatientExperienceSurveyOverallCount = source.PatientExperienceSurveyOverallCount,
                            target.ProviderBiography = source.ProviderBiography,
                            target.ProviderURL = source.ProviderURL,
                            target.ProductGroupCode = source.ProductGroupCode,
                            target.SponsorCode = source.SponsorCode,
                            target.ProductCode = source.ProductCode,
                            target.FacilityCode = source.FacilityCode,
                            target.ProviderLegacyKey = source.ProviderLegacyKey,
                            target.DisplayImage = source.DisplayImage,
                            target.SurveyResponse = source.SurveyResponse,
                            target.SurveyResponseDate = source.SurveyResponseDate,
                            target.UpdatedDate = source.UpdatedDate,
                            target.IsActive = source.IsActive,
                            target.UpdatedSource = source.UpdatedSource,
                            target.Title = source.Title,
                            target.CityStateAll = source.CityStateAll,
                            target.DisplayPatientExperienceSurveyOverallScore = source.DisplayPatientExperienceSurveyOverallScore,
                            target.DisplayStatusCode = source.DisplayStatusCode,
                            target.SubStatusCode = source.SubStatusCode,
                            target.DeactivationReason = source.DeactivationReason,
                            target.DuplicateProviderCode = source.DuplicateProviderCode,
                            target.PatientVolume = source.PatientVolume,
                            target.HasMalpracticeState = source.HasMalpracticeState,
                            target.ProcedureCount = source.ProcedureCount,
                            target.ConditionCount = source.ConditionCount,
                            -- target.AvailabilityStatement = source.AvailabilityStatement,
                            target.HasOar = source.HasOar,
                            target.IsMMPUser = source.IsMMPUser,
                            target.HasAboutMe = source.HasAboutMe,
                            target.SearchBoostSatisfaction = source.SearchBoostSatisfaction,
                            target.SearchBoostAccessibility = source.SearchBoostAccessibility,
                            target.isPCPCalculated = source.isPCPCalculated,
                            target.FAFBoostSatisfaction = source.FAFBoostSatisfaction,
                            target.FAFBoostSancMalp = source.FAFBoostSancMalp,
                            target.FFDisplaySpecialty = source.FFDisplaySpecialty,
                            target.FFPESBoost = source.FFPESBoost,
                            target.FFMalMultiHQ = source.FFMalMultiHQ,
                            target.FFMalMulti = source.FFMalMulti,
                            target.ProviderSubTypeCode = source.ProviderSubTypeCode';

--- Insert Statement
insert_statement_2 := ' INSERT
                            (
                                ProviderID,
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
                                ProviderProfileViewOneYear,
                                PatientExperienceSurveyOverallScore,
                                PatientExperienceSurveyOverallStarValue,
                                PatientExperienceSurveyOverallCount,
                                ProviderBiography,
                                ProviderURL,
                                ProductGroupCode,
                                SponsorCode,
                                ProductCode,
                                FacilityCode,
                                ProviderLegacyKey,
                                DisplayImage,
                                SurveyResponse,
                                SurveyResponseDate,
                                IsActive,
                                UpdatedDate,
                                UpdatedSource,
                                Title,
                                CityStateAll,
                                DisplayPatientExperienceSurveyOverallScore,
                                DisplayStatusCode,
                                SubStatusCode,
                                DuplicateProviderCode,
                                DeactivationReason,
                                PatientVolume,
                                HasMalpracticeState,
                                ProcedureCount,
                                ConditionCount,
                                -- AvailabilityStatement,
                                HasOar,
                                IsMMPUser,
                                HasAboutMe,
                                SearchBoostSatisfaction,
                                SearchBoostAccessibility,
                                isPCPCalculated,
                                FAFBoostSatisfaction,
                                FAFBoostSancMalp,
                                FFDisplaySpecialty,
                                FFPESBoost,
                                FFMalMultiHQ,
                                FFMalMulti,
                                ProviderSubTypeCode
                            )
                        VALUES(
                                source.ProviderID,
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
                                source.ProviderProfileViewOneYear,
                                source.PatientExperienceSurveyOverallScore,
                                source.PatientExperienceSurveyOverallStarValue,
                                source.PatientExperienceSurveyOverallCount,
                                source.ProviderBiography,
                                source.ProviderURL,
                                source.ProductGroupCode,
                                source.SponsorCode,
                                source.ProductCode,
                                source.FacilityCode,
                                source.ProviderLegacyKey,
                                source.DisplayImage,
                                source.SurveyResponse,
                                source.SurveyResponseDate,
                                source.IsActive,
                                source.UpdatedDate,
                                source.UpdatedSource,
                                source.Title,
                                source.CityStateAll,
                                source.DisplayPatientExperienceSurveyOverallScore,
                                source.DisplayStatusCode,
                                source.SubStatusCode,
                                source.DuplicateProviderCode,
                                source.DeactivationReason,
                                source.PatientVolume,
                                source.HasMalpracticeState,
                                source.ProcedureCount,
                                source.ConditionCount,
                                -- source.AvailabilityStatement,
                                source.HasOar,
                                source.IsMMPUser,
                                source.HasAboutMe,
                                source.SearchBoostSatisfaction,
                                source.SearchBoostAccessibility,
                                source.isPCPCalculated,
                                source.FAFBoostSatisfaction,
                                source.FAFBoostSancMalp,
                                source.FFDisplaySpecialty,
                                source.FFPESBoost,
                                source.FFMalMultiHQ,
                                source.FFMalMulti,
                                source.ProviderSubTypeCode
                            );';

update_statement_3 := $$ UPDATE show.solrprovider target
                            SET target.ProviderLegacyKey = src.LegacyKey
                            FROM base.ProviderLegacyKeys AS src where target.ProviderId = src.ProviderId; 
                        $$;

update_statement_4 := $$ DELETE FROM show.solrprovider
                        WHERE SOLRPRoviderID IN (
                            SELECT SOLRPRoviderID
                            FROM (
                                SELECT SOLRPRoviderID, ProviderId
                                FROM (
                                    SELECT SOLRPRoviderID, ProviderId, ProviderCode, 
                                    ROW_NUMBER() OVER(PARTITION BY ProviderCode ORDER BY CASE WHEN sponsorshipXML IS NOT NULL THEN 1 ELSE 9 END DESC, DisplayStatusCode, ProviderTypeGroup DESC, SOLRPRoviderID) AS SequenceId
                                    FROM show.solrprovider
                                ) X
                                WHERE SequenceId > 1
                            )
                        ); 
                        $$;

update_statement_5 := $$ UPDATE show.solrprovider target
                            SET DateOfFirstLoad = src.LastUpdateDate
                            FROM  Base.Provider src 
                            WHERE src.providercode = target.providercode; 
                        $$;

update_statement_6 := $$ UPDATE show.solrprovider target
                            SET 
                                target.SourceUpdate = src.SourceName, 
                                target.SourceUpdateDateTime = src.LastUpdateDateTime
                            FROM Show.ProviderSourceUpdate src 
                            WHERE src.ProviderID = target.ProviderID; 
                        $$;

update_statement_7 := $$ UPDATE show.solrprovider target
                            SET AcceptsNewPatients = 1
                            FROM Mid.Provider src 
                            where src.ProviderID = target.ProviderID
                            and src.acceptsnewpatients = 1 AND IFNULL(target.AcceptsNewPatients, 0) = 0; 
                        $$;

update_statement_8 := $$ UPDATE show.solrprovider target
                            SET SuppressSurvey = CASE WHEN src.ProviderID IS NOT NULL THEN 1 ELSE 0 END
                            FROM (
                                SELECT DISTINCT ProviderId
                                FROM Base.ProviderSurveySuppression
                            ) src 
                            WHERE src.ProviderID = target.ProviderID; 
                        $$;

update_statement_9 := $$UPDATE show.solrprovider target
                            SET IsBoardActionEligible = CASE WHEN X.ProviderID IS NOT NULL THEN 1 ELSE 0 END
                            FROM (
                                SELECT ps.ProviderID
                                FROM Base.ProviderSanction AS ps
                                JOIN Base.SanctionAction AS sa ON sa.SanctionActionID = ps.SanctionActionID
                                JOIN Base.SanctionActionType AS sat ON sat.SanctionActionTypeID = sa.SanctionActionTypeID
                                WHERE sat.SanctionActionTypeCode = 'B'
                                UNION
                                SELECT ptpst.ProviderID
                                FROM Base.ProviderSubType AS pst
                                JOIN Base.ProviderToProviderSubType AS ptpst ON ptpst.ProviderSubTypeID = pst.ProviderSubTypeID
                                WHERE pst.IsBoardActionEligible = 1
                                UNION
                                SELECT ptpst.ProviderID
                                FROM Base.ProviderSubTypeToDegree AS psttd
                                JOIN Base.ProviderToProviderSubType AS ptpst ON psttd.ProviderSubTypeID = ptpst.ProviderSubTypeID
                                JOIN Base.ProviderToDegree AS ptd ON ptd.ProviderID = ptpst.ProviderID AND psttd.DegreeID = ptd.DegreeID
                                WHERE psttd.IsBoardActionEligible = 1
                                UNION
                                SELECT ps.ProviderID
                                FROM Base.SpecialtyGroup AS sg
                                JOIN Base.SpecialtyGroupToSpecialty AS sgts ON sgts.SpecialtyGroupID = sg.SpecialtyGroupID
                                JOIN Base.ProviderToSpecialty AS ps ON ps.SpecialtyID = sgts.SpecialtyID
                                WHERE sg.IsBoardActionEligible = 1
                            ) X 
                            WHERE X.ProviderID = target.ProviderID; 
                        $$;


--------- Step 3: Client Certification XML ------------


update_statement_10 := $$ UPDATE
                                show.solrprovider target
                            SET
                                ClientCertificationXML = parse_xml(CTE_CCX.Certs)
                            FROM
                                (
                                    with cte_client_providers as (
                                        SELECT
                                            distinct s.ProviderCode,
                                            s.providerId,
                                            s.SOLRProviderID,
                                            pc.SourceCode
                                        FROM
                                            show.solrprovider AS s
                                            JOIN base.ProviderCertification as pc on pc.ProviderCode = s.ProviderCode
                                    ) -- select* from cte_client_providers;
                            ,
                                    cte_cSpcL as (
                                        select
                                            pc.providerCode,
                                            UTILS.P_JSON_TO_XML(
                                                array_agg(
                                                    '{ ' || IFF(
                                                        pc.cSpCd IS NOT NULL,
                                                        '"cSpCd":' || '"' || pc.cSpCd || '"' || ',',
                                                        ''
                                                    ) || IFF(
                                                        pc.cSpY IS NOT NULL,
                                                        '"cSpY":' || '"' || pc.cSpY || '"' || ',',
                                                        ''
                                                    ) || IFF(
                                                        pc.caCd IS NOT NULL,
                                                        '"caCd":' || '"' || pc.caCd || '"' || ',',
                                                        ''
                                                    ) || IFF(
                                                        pc.caD IS NOT NULL,
                                                        '"caD":' || '"' || pc.caD || '"' || ',',
                                                        ''
                                                    ) || IFF(
                                                        pc.cbCd IS NOT NULL,
                                                        '"cbCd":' || '"' || pc.cbCd || '"' || ',',
                                                        ''
                                                    ) || IFF(
                                                        pc.cbD IS NOT NULL,
                                                        '"cbD":' || '"' || pc.cbD || '"' || ',',
                                                        ''
                                                    ) || IFF(
                                                        pc.csCd IS NOT NULL,
                                                        '"csCd":' || '"' || pc.csCd || '"' || ',',
                                                        ''
                                                    ) || IFF(
                                                        pc.csD IS NOT NULL,
                                                        '"csD":' || '"' || pc.csD || '"',
                                                        ''
                                                    ) || ' }'
                                                )::varchar,
                                                '',
                                                'cSpC'
                                            ) as cSpcL
                                        FROM
                                            base.ProviderCertification as pc
                                        where
                                            (
                                                pc.cSpCd is not null
                                                or pc.cSpY is not null
                                                or pc.caCd is not null
                                                or pc.caD is not null
                                                or pc.cbCd is not null
                                                or pc.cbD is not null
                                                or pc.csCd is not null
                                                or pc.csD is not null
                                            )
                                        group by
                                            pc.providerCode
                                    ),
                                    cte_SpnL as (
                                        SELECT
                                            cp.SOLRProviderID,
                                            cp.ProviderCode,
                                            UTILS.P_JSON_TO_XML(
                                                array_agg(
                                                    '{ ' || IFF(
                                                        SUBSTRING(cp.SourceCode, 3, 50) IS NOT NULL,
                                                        '"spnCd":' || '"' || SUBSTRING(cp.SourceCode, 3, 50) || '"' || ',',
                                                        ''
                                                    ) || IFF(
                                                        CTE_cSpcL.cSpcL IS NOT NULL,
                                                        '"cSpcL":' || '"' || CTE_cSpcL.cSpcL || '"',
                                                        ''
                                                    ) || ' }'
                                                )::varchar,
                                                'cSpnL',
                                                'cSpn'
                                            ) as certs
                                        FROM
                                            cte_client_providers AS cp
                                            LEFT JOIN CTE_cSpcL ON CTE_cSpcL.ProviderCode = cp.ProviderCode -- WHERE cp.SOLRProviderID=prv.SOLRProviderID
                                        GROUP BY
                                            cp.SOLRProviderID,
                                            cp.ProviderCode
                                    ),
                                    cte_certs as (
                                        select
                                            DISTINCT prv.SOLRProviderID,
                                            prv.ProviderCode,
                                            certs
                                        FROM
                                            cte_client_providers AS prv
                                            left join cte_SpnL ON cte_SpnL.SOLRProviderID = prv.SOLRProviderID
                                            and cte_SpnL.ProviderCode = prv.ProviderCode
                                    )
                                    ,
                                    cte_client_certs_xml as (
                                        SELECT
                                            SOLRProviderID,
                                            CASE
                                                WHEN REGEXP_COUNT(certs, '<cSpnL><cSpn><spnCd>.*<cspc>', 1, 'i') > 0 THEN cte_certs.certs
                                            END AS certs,
                                            REGEXP_COUNT(certs, '<cSpnL><cSpn><spnCd>.*<cspc>', 1, 'i') AS CertsCount,
                                            ROW_NUMBER() OVER (
                                                PARTITION BY SOLRProviderID
                                                ORDER BY
                                                    REGEXP_COUNT(certs, '<cSpnL><cSpn><spnCd>.*<cspc>', 1, 'i') DESC
                                            ) AS DedupeRank
                                            
                                        from
                                            cte_certs
                                    )
                                    select * from cte_client_certs_xml
                                ) AS CTE_CCX 
                                where CTE_CCX.SOLRProviderID = target.SOLRProviderID
                            and
                                CTE_CCX.DedupeRank = 1; $$;

update_statement_11 := $$ UPDATE show.solrprovider
                            SET DateOfBirth = NULL
                            WHERE EXTRACT(YEAR FROM DateOfBirth) = 1900;$$;

--------- Step 4: spuSuppressSurveyFlag

update_statement_12 := $$ UPDATE
                                show.solrprovider target
                            SET
                                SuppressSurvey = 1
                            FROM
                                Base.ProviderToSpecialty AS a
                                JOIN Base.Specialty as b ON b.SpecialtyID = a.SpecialtyID
                                JOIN Base.SpecialtyGroupToSpecialty c ON c.SpecialtyID = a.SpecialtyID
                                JOIN Base.SpecialtyGroup d ON d.SpecialtyGroupID = c.SpecialtyGroupID
                            where target.ProviderID = a.ProviderID
                            and
                                d.SpecialtyGroupCode IN ('NPHR', 'PNPH')
                                AND IFNULL(target.SuppressSurvey, 0) = 0;$$;
    
update_statement_13 := $$ UPDATE
                                show.solrprovider target
                            SET
                                SuppressSurvey = 0
                            FROM
                                SHOW.SOLRPROVIDERDelta src 
                            WHERE src.ProviderID = target.ProviderID
                            AND
                                target.SuppressSurvey = 1;$$;
    
update_statement_14 := $$ UPDATE
                                show.solrprovider target
                            SET
                                SuppressSurvey = 1
                            FROM SHOW.SOLRPROVIDERDelta b , Base.ProviderSurveySuppressiON ps 
                            WHERE
                            b.ProviderID = target.ProviderID AND target.ProviderID = ps.ProviderID;$$;
    
update_statement_15 := $$ UPDATE
                                show.solrprovider target
                            SET
                                SuppressSurvey = 1
                            FROM
                                SHOW.SOLRPROVIDERDelta b 
                                JOIN (
                                    SELECT
                                        DISTINCT p.ProviderID
                                    FROM
                                        Base.Provider p
                                        JOIN SHOW.SOLRPROVIDERDelta b ON b.ProviderID = p.ProviderID
                                        JOIN Base.ProviderToSubStatus ap ON p.ProviderID = ap.ProviderID
                                        JOIN Base.SubStatus ss ON ap.SubStatusID = ss.SubStatusID
                                    WHERE
                                        ss.SubStatusCode IN ('B', 'L')
                                        AND ap.HierarchyRank = 1
                                ) x 
                                where x.ProviderID = target.ProviderID
                                and b.ProviderID = target.ProviderID;$$;

update_statement_16 := $$ UPDATE
                                show.solrprovider target
                            SET
                                SuppressSurvey = 0 --select SuppressSurvey, *
                            FROM
                                Mid.ProviderSpONsorship ps,
                                Base.ProviderToSpecialty a 
                                JOIN Base.Specialty b ON b.SpecialtyID = a.SpecialtyID
                                JOIN Base.SpecialtyGroupToSpecialty c ON c.SpecialtyID = a.SpecialtyID
                                JOIN Base.SpecialtyGroup d ON d.SpecialtyGroupID = c.SpecialtyGroupID
                            WHERE
                                d.SpecialtyGroupCode IN ('NPHR', 'PNPH')
                                AND ps.ClientCode <> 'Fresen'
                                AND ps.ProviderCode = target.ProviderCode
                                and target.ProviderID = a.ProviderID
                                AND target.SuppressSurvey = 1; $$;
--------------------- 

update_statement_17 := $$ 
DELETE FROM show.solrprovider
WHERE ProviderCode IN (
    SELECT pr.ProviderCode
    FROM Base.ProviderRemoval pr
    WHERE show.solrprovider.ProviderCode = pr.ProviderCode
); 
$$;

update_statement_18 := $$ 
UPDATE show.solrprovider
SET AcceptsNewPatients = 0
WHERE ProviderID IN (
    SELECT b.ProviderID
    FROM Show.SOLRProviderDelta b
    WHERE show.solrprovider.ProviderID = b.ProviderID
    AND SubStatusCode IN ('C', 'Y', 'A')
    AND AcceptsNewPatients != 0
);
$$;

update_statement_19 := $$ 
MERGE INTO show.solrprovider AS P USING (
    SELECT SS.SubStatusCode, DS.DisplayStatusCode
    FROM Base.SubStatus AS SS
    JOIN Base.DisplayStatus AS DS ON DS.DisplayStatusId = SS.DisplayStatusId
) AS sub ON P.SubStatusCode = sub.SubStatusCode
WHEN MATCHED AND P.DisplayStatusCode != sub.DisplayStatusCode AND P.DisplayStatusCode = 'H' THEN
UPDATE SET P.DisplayStatusCode = sub.DisplayStatusCode; 
$$;

update_statement_20 := $$ 
UPDATE show.solrprovider 
SET APIXML = TO_VARIANT(REPLACE(CAST(APIXML AS VARCHAR(16777216)), '</apiL>', '
<api>
<clientCd>OASTEST</clientCd>
<camCd>OASTEST_005</camCd>
</api>
</apiL>'))
WHERE ProviderCode IN ('G92WN', 'yj754', 'XYLGDMH', '2p2v2', '2CJGY', 'XCWYN', 'E5B5Z', 'YJLPH')
AND CAST(APIXML AS VARCHAR(16777216)) NOT LIKE '%OASTEST_005%'; 
$$;

------ Client Market Refresh

temp_table_statement_1 := 'CREATE OR REPLACE TEMPORARY TABLE temp_provider as (
    SELECT
        p.ProviderID,
        p.ProviderID as EDWBaseRecordID,
        0 AS IsInClientMarket
    FROM
        mdm_team.mst.provider_profile_processing as ppp
        Join Base.Provider as p on p.providercode = ppp.REF_PROVIDER_CODE
    LIMIT 50000
);';

-- temp_table_statement_2 := 'CREATE OR REPLACE TEMPORARY TABLE temp_provider as (
--                     SELECT
--                         src.ProviderID,
--                         src.EDWBaseRecordID,
--                         0 AS IsInClientMarket
--                     FROM
--                         Base.Provider AS src
--                     LIMIT 50000
--                 );';

update_statement_temp_1 := 'UPDATE
                                    temp_provider target
                                SET
                                    IsInClientMarket = 1
                                FROM
                                    Base.ProviderToOffice pto 
                                    JOIN Base.OfficeToAddress ota ON pto.OfficeID = ota.OfficeID
                                    JOIN Base.Address a ON ota.AddressID = a.AddressID
                                    JOIN Base.CityStatePostalCode csz ON a.CityStatePostalCodeID = csz.CityStatePostalCodeID
                                    JOIN Base.GeographicArea geo ON (
                                        csz.City = geo.GeographicAreaValue1
                                        AND csz.State = geo.GeographicAreaValue2
                                    )
                                    JOIN Mid.ClientMarket cm ON geo.GeographicAreaCode = cm.GeographicAreaCode,
                                    Base.ProviderToSpecialty pts  
                                    JOIN Base.SpecialtyGroupToSpecialty sgs ON pts.SpecialtyID = sgs.SpecialtyID,
                                    Base.SpecialtyGroup sg
                                WHERE
                                    pts.IsSearchable = 1
                                    AND target.ProviderID = pto.ProviderID
                                    AND target.ProviderID = pts.ProviderID
                                    AND sgs.SpecialtyGroupID = sg.SpecialtyGroupID
                                    AND cm.LineOfServiceCode = sg.SpecialtyGroupCode;';

update_statement_temp_2 := 'UPDATE
                                    temp_provider target
                                SET
                                    IsInClientMarket = 1
                                FROM
                                    Base.ProviderToOffice pto 
                                    JOIN Base.OfficeToAddress ota ON pto.OfficeID = ota.OfficeID
                                    JOIN Base.Address a ON ota.AddressID = a.AddressID
                                    JOIN Base.CityStatePostalCode csz ON a.CityStatePostalCodeID = csz.CityStatePostalCodeID
                                    JOIN Base.GeographicArea geo ON (
                                        csz.PostalCode = geo.GeographicAreaValue1
                                        AND geo.GeographicAreaValue2 IS NULL
                                    )
                                    JOIN Mid.ClientMarket cm ON geo.GeographicAreaCode = cm.GeographicAreaCode,
                                    Base.ProviderToSpecialty pts 
                                    JOIN Base.SpecialtyGroupToSpecialty sgs ON pts.SpecialtyID = sgs.SpecialtyID,
                                    Base.SpecialtyGroup sg 
                                WHERE
                                    pts.IsSearchable = 1
                                    AND target.IsInClientMarket = 0
                                    AND target.ProviderID = pto.ProviderID
                                    AND target.ProviderID = pts.ProviderID
                                    AND sgs.SpecialtyGroupID = sg.SpecialtyGroupID
                                    AND cm.LineOfServiceCode = sg.SpecialtyGroupCode;;';                                

update_statement_21 := 'UPDATE
                                show.solrprovider target
                            SET
                                IsInClientMarket = p1.IsInClientMarket
                            FROM
                                TEMP_PROVIDER p1
                            WHERE
                                p1.IsInClientMarket <> target.IsInClientMarket
                                and p1.ProviderID = target.ProviderID;';


update_statement_22 := 'UPDATE		show.solrprovider target
SET			AcceptsNewPatients =  1
FROM		Base.Provider P 
WHERE		IFNULL(target.ACCEPTSNEWPATIENTS,0) != P.AcceptsNewPatients
AND P.Providerid = target.ProviderID';


if_condition := $$ SELECT
    COUNT(1)
FROM
    Show.SOLRprovider P
    LEFT JOIN (
        SELECT
            DISTINCT *
        FROM(
                SELECT
                    ProviderId,
                    ProviderCode,
                    SponsorCode,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                    'dispL'
                                ),
                                'disp'
                            ),
                            'Type'
                        ),
                        '$'
                    ) AS DisplayType,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                    'dispL'
                                ),
                                'disp'
                            ),
                            'cd'
                        ),
                        '$'
                    ) AS PracticeCode,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(
                                        xmlget(
                                            xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                            'dispL'
                                        ),
                                        'disp'
                                    ),
                                    'offL'
                                ),
                                'off'
                            ),
                            'cd'
                        ),
                        '$'
                    ) AS OfficeCode,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(
                                        xmlget(
                                            xmlget(
                                                xmlget(
                                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                    'dispL'
                                                ),
                                                'disp'
                                            ),
                                            'offL'
                                        ),
                                        'off'
                                    ),
                                    'phoneL'
                                ),
                                'phone'
                            ),
                            'ph'
                        ),
                        '$'
                    ) AS PhoneNumber,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(
                                        xmlget(
                                            xmlget(
                                                xmlget(
                                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                    'dispL'
                                                ),
                                                'disp'
                                            ),
                                            'offL'
                                        ),
                                        'off'
                                    ),
                                    'phoneL'
                                ),
                                'phone'
                            ),
                            'phTyp'
                        ),
                        '$'
                    ) AS PhoneType,
                FROM
                    show.solrprovider,
                WHERE
                    ProductCode = 'MAP'
            )
    ) X ON X.ProviderId = P.ProviderId
WHERE
    ProductCode = 'MAP'
    AND PracticeOfficeXML IS NOT NULL
    AND(
        X.ProviderId IS NULL
        OR LEN(PhoneNumber) = 0
    )
    AND P.DisplayStatusCode != 'H'
    AND SponsorshipXML IS NOT NULL $$;

update_statement_23 := $$ Update
    show.solrprovider
SET
    SponsorshipXML = null,
    SearchSponsorshipXML = null
FROM
    show.solrprovider AS P
    LEFT JOIN (
        SELECT
            DISTINCT *
        FROM(
                SELECT
                    ProviderId,
                    ProviderCode,
                    SponsorCode,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                    'dispL'
                                ),
                                'disp'
                            ),
                            'Type'
                        ),
                        '$'
                    ) AS DisplayType,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                    'dispL'
                                ),
                                'disp'
                            ),
                            'cd'
                        ),
                        '$'
                    ) AS PracticeCode,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(
                                        xmlget(
                                            xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                            'dispL'
                                        ),
                                        'disp'
                                    ),
                                    'offL'
                                ),
                                'off'
                            ),
                            'cd'
                        ),
                        '$'
                    ) AS OfficeCode,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(
                                        xmlget(
                                            xmlget(
                                                xmlget(
                                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                    'dispL'
                                                ),
                                                'disp'
                                            ),
                                            'offL'
                                        ),
                                        'off'
                                    ),
                                    'phoneL'
                                ),
                                'phone'
                            ),
                            'ph'
                        ),
                        '$'
                    ) AS PhoneNumber,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(
                                        xmlget(
                                            xmlget(
                                                xmlget(
                                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                    'dispL'
                                                ),
                                                'disp'
                                            ),
                                            'offL'
                                        ),
                                        'off'
                                    ),
                                    'phoneL'
                                ),
                                'phone'
                            ),
                            'phTyp'
                        ),
                        '$'
                    ) AS PhoneType,
                FROM
                    show.solrprovider,
                WHERE
                    ProductCode = 'MAP'
            )
    ) as x ON X.ProviderId = P.ProviderId
WHERE
    P.ProductCode = 'MAP'
    AND P.PracticeOfficeXML IS NOT NULL
    AND(
        X.ProviderId IS NULL
        OR LEN(PhoneNumber) = 0
    )
    AND P.DisplayStatusCode != 'H'
    AND P.SponsorshipXML IS NOT NULL; $$;

update_statement_24 := $$UPDATE show.solrprovider 
		SET DisplayStatusCode = 'A'
		WHERE DisplayStatusCode = 'H' AND SubStatusCode = '1'$$;
---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement_1 := ' MERGE INTO show.solrprovider as target USING 
                   ('||select_statement_1||') as source 
                   ON source.Providerid = target.Providerid
                   WHEN MATCHED THEN DELETE
                   WHEN NOT MATCHED THEN '||insert_statement_1;

merge_statement_2 := ' MERGE INTO show.solrprovider as target USING 
                   ('||select_statement_2 ||') as source 
                   ON source.Providerid = target.Providerid
                   WHEN MATCHED THEN '||update_statement_2 || '
                   WHEN NOT MATCHED THEN '||insert_statement_2 ;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
EXECUTE IMMEDIATE merge_statement_1 ;
EXECUTE IMMEDIATE merge_statement_2 ;
EXECUTE IMMEDIATE update_statement_3;
EXECUTE IMMEDIATE update_statement_4;
EXECUTE IMMEDIATE update_statement_5;
EXECUTE IMMEDIATE update_statement_6;
EXECUTE IMMEDIATE update_statement_7;
EXECUTE IMMEDIATE update_statement_8;
EXECUTE IMMEDIATE update_statement_9;
EXECUTE IMMEDIATE update_statement_10; 
EXECUTE IMMEDIATE update_statement_11;
IF ((select count(*) from Base.Client c JOIN Base.ClientToProduct ctp ON c.ClientID = ctp.ClientID WHERE c.ClientCode = 'Fresen') > 1) THEN
    EXECUTE IMMEDIATE update_statement_12;
END IF;
EXECUTE IMMEDIATE update_statement_13;
EXECUTE IMMEDIATE update_statement_14;
EXECUTE IMMEDIATE update_statement_15;
EXECUTE IMMEDIATE update_statement_16;
EXECUTE IMMEDIATE update_statement_17;
EXECUTE IMMEDIATE update_statement_18;
EXECUTE IMMEDIATE update_statement_19;
EXECUTE IMMEDIATE update_statement_20;
EXECUTE IMMEDIATE temp_table_statement_1;
EXECUTE IMMEDIATE update_statement_temp_1;
EXECUTE IMMEDIATE update_statement_temp_2;
EXECUTE IMMEDIATE update_statement_21;
EXECUTE IMMEDIATE update_statement_22;
EXECUTE IMMEDIATE if_condition;
IF ((SELECT
    COUNT(1)
FROM
    Show.SOLRprovider P
    LEFT JOIN (
        SELECT
            DISTINCT *
        FROM(
                SELECT
                    ProviderId,
                    ProviderCode,
                    SponsorCode,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                    'dispL'
                                ),
                                'disp'
                            ),
                            'Type'
                        ),
                        '$'
                    ) AS DisplayType,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                    'dispL'
                                ),
                                'disp'
                            ),
                            'cd'
                        ),
                        '$'
                    ) AS PracticeCode,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(
                                        xmlget(
                                            xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                            'dispL'
                                        ),
                                        'disp'
                                    ),
                                    'offL'
                                ),
                                'off'
                            ),
                            'cd'
                        ),
                        '$'
                    ) AS OfficeCode,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(
                                        xmlget(
                                            xmlget(
                                                xmlget(
                                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                    'dispL'
                                                ),
                                                'disp'
                                            ),
                                            'offL'
                                        ),
                                        'off'
                                    ),
                                    'phoneL'
                                ),
                                'phone'
                            ),
                            'ph'
                        ),
                        '$'
                    ) AS PhoneNumber,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(
                                        xmlget(
                                            xmlget(
                                                xmlget(
                                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                    'dispL'
                                                ),
                                                'disp'
                                            ),
                                            'offL'
                                        ),
                                        'off'
                                    ),
                                    'phoneL'
                                ),
                                'phone'
                            ),
                            'phTyp'
                        ),
                        '$'
                    ) AS PhoneType,
                FROM
                    show.solrprovider,
                WHERE
                    ProductCode = 'MAP'
            )
    ) X ON X.ProviderId = P.ProviderId
WHERE
    ProductCode = 'MAP'
    AND PracticeOfficeXML IS NOT NULL
    AND(
        X.ProviderId IS NULL
        OR LEN(PhoneNumber) = 0
    )
    AND P.DisplayStatusCode != 'H'
    AND SponsorshipXML IS NOT NULL)< 20 ) THEN 
    EXECUTE IMMEDIATE update_statement_23;
END IF;
EXECUTE IMMEDIATE update_statement_24;

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
--------------------------------------------------------- 

status := 'completed successfully';
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        return status;

        exception
        when other then
            status := 'failed during execution. ' || 'sql error: ' || sqlerrm || ' error code: ' || sqlcode || ' sql state: ' || sqlstate;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, split_part(regexp_substr(:status, 'error code: ([0-9]+)'), ':', 2)::integer, trim(split_part(split_part(:status, 'sql error:', 2), 'error code:', 1)), split_part(regexp_substr(:status, 'sql state: ([0-9]+)'), ':', 2)::integer; 

            return status;


    
END;