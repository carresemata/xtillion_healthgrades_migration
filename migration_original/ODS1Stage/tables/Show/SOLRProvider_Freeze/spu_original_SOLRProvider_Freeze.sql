-- 1. hack_spuMAPFreeze
	IF OBJECT_ID('tempdb..#BatchProviders') IS NOT NULL DROP TABLE #BatchProviders
	CREATE TABLE #BatchProviders(ProviderId UNIQUEIDENTIFIER)
	
	INSERT INTO #BatchProviders
	SELECT		DISTINCT dPv.ProviderID
	FROM		[Base].[ClientProductToEntity] lCPE
	INNER JOIN	[Base].[EntityType] dE
				ON dE.EntityTypeId = lCPE.EntityTypeID
	INNER JOIN	[Base].[ClientToProduct] lCP
				ON lCP.ClientToProductID = lCPE.ClientToProductID
	INNER JOIN	[Base].[Client] dC
				ON lCP.ClientID = dC.ClientID
	INNER JOIN	[Base].[Product] dP
				ON dP.ProductId = lCP.ProductID
	INNER JOIN	[Base].[Provider] dPv
				ON dPv.ProviderID = lCPE.EntityID
	WHERE		(
					DC.clientcode in (SELECT ClientCode FROM Show.WebFreeze WHERE GETDATE() NOT BETWEEN FreezeStartDate AND FreezeEndDate AND GETDATE() > FreezeEndDate)
					AND dPv.ProviderID NOT IN (SELECT ProviderId FROM ODS1Stage.etl.ProviderPriorityLoad)
				)
				
	INSERT INTO #BatchProviders
	SELECT		DISTINCT dPv.ProviderID
	FROM		[Base].[ClientProductToEntity] lCPE
	INNER JOIN	[Base].[EntityType] dE
				ON dE.EntityTypeId = lCPE.EntityTypeID
	INNER JOIN	[Base].[ClientToProduct] lCP
				ON lCP.ClientToProductID = lCPE.ClientToProductID
	INNER JOIN	[Base].[Client] dC
				ON lCP.ClientID = dC.ClientID
	INNER JOIN	[Base].[Product] dP
				ON dP.ProductId = lCP.ProductID
	INNER JOIN	[Base].[Provider] dPv
				ON dPv.ProviderID = lCPE.EntityID
	WHERE		(
					DC.ClientCode IN (SELECT DISTINCT SponsorCode FROM SHow.SOLRProvider_Freeze)
					AND DC.clientcode NOT IN (SELECT ClientCode FROM Show.WebFreeze)
				)
				
	INSERT INTO ODS1Stage.etl.ProviderPriorityLoad(ProviderId, Source)
	SELECT ProviderId, '[hack].[spuMAPFreeze]' FROM #BatchProviders	
	IF OBJECT_ID('tempdb..#BatchProviders') IS NOT NULL DROP TABLE #BatchProviders

	/*Cleanup*/
	DELETE FROM Show.SOLRProvider_Freeze WHERE SponsorCode NOT IN (SELECT ClientCode FROM Show.WebFreeze)
	DELETE Show.WebFreeze WHERE GETDATE() > FreezeEndDate

	IF OBJECT_ID('tempdb..#FreezeClientCode') IS NOT NULL DROP TABLE #FreezeClientCode
	SELECT	ClientCode 
	INTO	#FreezeClientCode
	FROM	Show.WebFreeze 
	WHERE	GETDATE() BETWEEN FreezeStartDate AND ISNULL(FreezeEndDate,'9999-09-09')

	INSERT INTO Show.SOLRProvider_Freeze(ProviderID, ProviderCode, ProviderTypeID, ProviderTypeGroup, FirstName, MiddleName, LastName, Suffix, Degree, Gender, NPI, AMAID, UPIN, MedicareID, DEANumber, TaxIDNumber, DateOfBirth, PlaceOfBirth, CarePhilosophy, ProfessionalInterest, PrimaryEmailAddress, MedicalSchoolNation, YearsSinceMedicalSchoolGraduation, HasDisplayImage, HasElectronicMedicalRecords, HasElectronicPrescription, AcceptsNewPatients, YearlySearchVolume, PatientExperienceSurveyOverallScore, PatientExperienceSurveyOverallCount, PracticeOfficeXML, FacilityXML, SpecialtyXML, EducationXML, LicenseXML, LanguageXML, MalpracticeXML, SanctionXML, SponsorshipXML, AffiliationXML, ProcedureXML, ConditionXML, HealthInsuranceXML, MediaXML, HasAddressXML, HasSpecialtyXML, Active, UpdateDate, InsertDate, ProviderLegacyKey, DisplayImage, AddressXML, BoardActionXML, SurveyXML, RecognitionXML, SurveyResponse, UpdatedDate, UpdatedSource, HasPhilosophy, HasMediaXML, HasProcedureXML, HasConditionXML, HasMalpracticeXML, HasSanctionXML, HasBoardActionXML, IsActive, ExpireCode, Title, CityStateAll, SurveyResponseDate, ProviderSpecialtyFacility5StarXML, HasProviderSpecialtyFacility5StarXML, DisplayPatientExperienceSurveyOverallScore, ProductGroupCode, SponsorCode, FacilityCode, SearchSponsorshipXML, ProductCode, VideoXML, OASXML, SuppressSurvey, ProviderURL, ImageXML, AdXML, HasProfessionalOrganizationXML, ProfessionalOrganizationXML, ProviderProfileViewOneYear, PracticingSpecialtyXML, CertificationXML, HasPracticingSpecialtyXML, HasCertificationXML, PatientExperienceSurveyOverallStarValue, ProviderBiography, DisplayStatusCode, HealthInsuranceXML_v2, ProviderDEAXML, ProviderTypeXML, SubStatusCode, DuplicateProviderCode, DeactivationReason, ProcedureHierarchyXML, ConditionHierarchyXML, ProcMappedXML, CondMappedXML, PracSpecHeirXML, AboutMeXML, HasAboutMeXML, PatientVolume, HasMalpracticeState, ProcedureCount, ConditionCount, AvailabilityXML, VideoXML2, AvailabilityStatement, IsInClientMarket, HasOAR, IsMMPUser, NatlAdvertisingXML, APIXML, DIHGroupNumber, SubStatusDescription, DEAXML, EmailAddressXML, DegreeXML, HasSurveyXML, HasDEAXML, HasEmailAddressXML, ClientCertificationXML, HasGoogleOAS, HasVideoXML2, HasAboutMe, ConversionPathXML, SearchBoostSatisfaction, SearchBoostAccessibility, IsPCPCalculated, FAFBoostSatisfaction, FAFBoostSancMalp, FFDisplaySpecialty, FFPESBoost, FFMalMultiHQ, FFMalMulti, CLinicalFocusXML, ClinicalFocusDCPXML, SyndicationXML, TeleHealthXML)
	SELECT	ProviderID, ProviderCode, ProviderTypeID, ProviderTypeGroup, FirstName, MiddleName, LastName, Suffix, Degree, Gender, NPI, AMAID, UPIN, MedicareID, DEANumber, TaxIDNumber, DateOfBirth, PlaceOfBirth, CarePhilosophy, ProfessionalInterest, PrimaryEmailAddress, MedicalSchoolNation, YearsSinceMedicalSchoolGraduation, HasDisplayImage, HasElectronicMedicalRecords, HasElectronicPrescription, AcceptsNewPatients, YearlySearchVolume, PatientExperienceSurveyOverallScore, PatientExperienceSurveyOverallCount, PracticeOfficeXML, FacilityXML, SpecialtyXML, EducationXML, LicenseXML, LanguageXML, MalpracticeXML, SanctionXML, SponsorshipXML, AffiliationXML, ProcedureXML, ConditionXML, HealthInsuranceXML, MediaXML, HasAddressXML, HasSpecialtyXML, Active, UpdateDate, InsertDate, ProviderLegacyKey, DisplayImage, AddressXML, BoardActionXML, SurveyXML, RecognitionXML, SurveyResponse, UpdatedDate, UpdatedSource, HasPhilosophy, HasMediaXML, HasProcedureXML, HasConditionXML, HasMalpracticeXML, HasSanctionXML, HasBoardActionXML, IsActive, ExpireCode, Title, CityStateAll, SurveyResponseDate, ProviderSpecialtyFacility5StarXML, HasProviderSpecialtyFacility5StarXML, DisplayPatientExperienceSurveyOverallScore, ProductGroupCode, SponsorCode, FacilityCode, SearchSponsorshipXML, ProductCode, VideoXML, OASXML, SuppressSurvey, ProviderURL, ImageXML, AdXML, HasProfessionalOrganizationXML, ProfessionalOrganizationXML, ProviderProfileViewOneYear, PracticingSpecialtyXML, CertificationXML, HasPracticingSpecialtyXML, HasCertificationXML, PatientExperienceSurveyOverallStarValue, ProviderBiography, DisplayStatusCode, HealthInsuranceXML_v2, ProviderDEAXML, ProviderTypeXML, SubStatusCode, DuplicateProviderCode, DeactivationReason, ProcedureHierarchyXML, ConditionHierarchyXML, ProcMappedXML, CondMappedXML, PracSpecHeirXML, AboutMeXML, HasAboutMeXML, PatientVolume, HasMalpracticeState, ProcedureCount, ConditionCount, AvailabilityXML, VideoXML2, AvailabilityStatement, IsInClientMarket, HasOAR, IsMMPUser, NatlAdvertisingXML, APIXML, DIHGroupNumber, SubStatusDescription, DEAXML, EmailAddressXML, DegreeXML, HasSurveyXML, HasDEAXML, HasEmailAddressXML, ClientCertificationXML, HasGoogleOAS, HasVideoXML2, HasAboutMe, ConversionPathXML, SearchBoostSatisfaction, SearchBoostAccessibility, IsPCPCalculated, FAFBoostSatisfaction, FAFBoostSancMalp, FFDisplaySpecialty, FFPESBoost, FFMalMultiHQ, FFMalMulti, CLinicalFocusXML, ClinicalFocusDCPXML, SyndicationXML, TeleHealthXML
	FROM	Show.SOLRProvider
	WHERE	SponsorCode IN (SELECT ClientCode FROM #FreezeClientCode)
			AND SponsorCode NOT IN (SELECT DISTINCT SponsorCode FROM Show.SOLRProvider_Freeze)