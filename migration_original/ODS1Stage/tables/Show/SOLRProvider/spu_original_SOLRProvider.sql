------------------ SP ORDER OF EXECUTIONS
-- etl_spuMidProviderEntityRefresh 
-- hack_spuMAPFreeze (run inside Show_spuSOLRProviderGenerateFromMid at the beginning)
-- Show_spuSOLRProviderGenerateFromMid (line 306)
-- Show_spuUpdateSOLRProviderClientCertificationXml (line 319)
----- UPDATE DateOfBirth (line 327)
-- Mid_spuSuppressSurveyFlag (line 333)
-- hack_spuRemoveSuspecProviders (line 362)
-- Show_spuApplyProviderStatusBusinessRules (line 368)
----- UPDATE DisplayStatusCode (line 396)
----- UPDATE APIXML (line 440)
-- Mid_spuProviderIsInClientMarketRefresh (line 433, executed in spumidnonproviderentityrefresh)
----- UPDATE AcceptsNewPatients (line 499)
-- hack_spuMAPFreeze (line 507)
-- etl_spuCheckFinalResults (line 515)
----- UPDATE DisplayStatusCode (line 521)



-- ############ 1. hack_spuMAPFreeze ##########################################################################################################
-- Show.WebFreeze
-- Show.SOLRProvider_Freeze

IF OBJECT_ID('tempdb..#FreezeClientCode') IS NOT NULL DROP TABLE #FreezeClientCode
	SELECT	ClientCode 
	INTO	#FreezeClientCode
	FROM	Show.WebFreeze 
	WHERE	GETDATE() BETWEEN FreezeStartDate AND ISNULL(FreezeEndDate,'9999-09-09')


UPDATE	T
		SET		ProductCode = null
				,SponsorCode = null
				,SponsorshipXML = null
				,SearchSponsorshipXML = null
		FROM	Show.SOLRProvider T
		WHERE	SponsorCode IN (SELECT ClientCode FROM #FreezeClientCode)

DELETE	Show.SOLRProvider 
		WHERE	PROVIDERID IN (SELECT DISTINCT PROVIDERID FROM Show.SOLRProvider_Freeze WHERE SponsorCode IN (SELECT ClientCode FROM #FreezeClientCode)) 
		
INSERT INTO Show.SOLRProvider(ProviderID, ProviderCode, ProviderTypeID, ProviderTypeGroup, FirstName, MiddleName, LastName, Suffix, Degree, Gender, NPI, AMAID, UPIN, MedicareID, DEANumber, TaxIDNumber, DateOfBirth, PlaceOfBirth, CarePhilosophy, ProfessionalInterest, PrimaryEmailAddress, MedicalSchoolNation, YearsSinceMedicalSchoolGraduation, HasDisplayImage, HasElectronicMedicalRecords, HasElectronicPrescription, AcceptsNewPatients, YearlySearchVolume, PatientExperienceSurveyOverallScore, PatientExperienceSurveyOverallCount, PracticeOfficeXML, FacilityXML, SpecialtyXML, EducationXML, LicenseXML, LanguageXML, MalpracticeXML, SanctionXML, SponsorshipXML, AffiliationXML, ProcedureXML, ConditionXML, HealthInsuranceXML, MediaXML, HasAddressXML, HasSpecialtyXML, Active, UpdateDate, InsertDate, ProviderLegacyKey, DisplayImage, AddressXML, BoardActionXML, SurveyXML, RecognitionXML, SurveyResponse, UpdatedDate, UpdatedSource, HasPhilosophy, HasMediaXML, HasProcedureXML, HasConditionXML, HasMalpracticeXML, HasSanctionXML, HasBoardActionXML, IsActive, ExpireCode, Title, CityStateAll, SurveyResponseDate, ProviderSpecialtyFacility5StarXML, HasProviderSpecialtyFacility5StarXML, DisplayPatientExperienceSurveyOverallScore, ProductGroupCode, SponsorCode, FacilityCode, SearchSponsorshipXML, ProductCode, VideoXML, OASXML, SuppressSurvey, ProviderURL, ImageXML, AdXML, HasProfessionalOrganizationXML, ProfessionalOrganizationXML, ProviderProfileViewOneYear, PracticingSpecialtyXML, CertificationXML, HasPracticingSpecialtyXML, HasCertificationXML, PatientExperienceSurveyOverallStarValue, ProviderBiography, DisplayStatusCode, HealthInsuranceXML_v2, ProviderDEAXML, ProviderTypeXML, SubStatusCode, DuplicateProviderCode, DeactivationReason, ProcedureHierarchyXML, ConditionHierarchyXML, ProcMappedXML, CondMappedXML, PracSpecHeirXML, AboutMeXML, HasAboutMeXML, PatientVolume, HasMalpracticeState, ProcedureCount, ConditionCount, AvailabilityXML, VideoXML2, AvailabilityStatement, IsInClientMarket, HasOAR, IsMMPUser, NatlAdvertisingXML, APIXML, DIHGroupNumber, SubStatusDescription, DEAXML, EmailAddressXML, DegreeXML, HasSurveyXML, HasDEAXML, HasEmailAddressXML, ClientCertificationXML, HasGoogleOAS, HasVideoXML2, HasAboutMe, ConversionPathXML, SearchBoostSatisfaction, SearchBoostAccessibility, IsPCPCalculated, FAFBoostSatisfaction, FAFBoostSancMalp, FFDisplaySpecialty, FFPESBoost, FFMalMultiHQ, FFMalMulti, CLinicalFocusXML, ClinicalFocusDCPXML, SyndicationXML, TeleHealthXML)
		SELECT	ProviderID, ProviderCode, ProviderTypeID, ProviderTypeGroup, FirstName, MiddleName, LastName, Suffix, Degree, Gender, NPI, AMAID, UPIN, MedicareID, DEANumber, TaxIDNumber, DateOfBirth, PlaceOfBirth, CarePhilosophy, ProfessionalInterest, PrimaryEmailAddress, MedicalSchoolNation, YearsSinceMedicalSchoolGraduation, HasDisplayImage, HasElectronicMedicalRecords, HasElectronicPrescription, AcceptsNewPatients, YearlySearchVolume, PatientExperienceSurveyOverallScore, PatientExperienceSurveyOverallCount, PracticeOfficeXML, FacilityXML, SpecialtyXML, EducationXML, LicenseXML, LanguageXML, MalpracticeXML, SanctionXML, SponsorshipXML, AffiliationXML, ProcedureXML, ConditionXML, HealthInsuranceXML, MediaXML, HasAddressXML, HasSpecialtyXML, Active, UpdateDate, InsertDate, ProviderLegacyKey, DisplayImage, AddressXML, BoardActionXML, SurveyXML, RecognitionXML, SurveyResponse, UpdatedDate, UpdatedSource, HasPhilosophy, HasMediaXML, HasProcedureXML, HasConditionXML, HasMalpracticeXML, HasSanctionXML, HasBoardActionXML, IsActive, ExpireCode, Title, CityStateAll, SurveyResponseDate, ProviderSpecialtyFacility5StarXML, HasProviderSpecialtyFacility5StarXML, DisplayPatientExperienceSurveyOverallScore, ProductGroupCode, SponsorCode, FacilityCode, SearchSponsorshipXML, ProductCode, VideoXML, OASXML, SuppressSurvey, ProviderURL, ImageXML, AdXML, HasProfessionalOrganizationXML, ProfessionalOrganizationXML, ProviderProfileViewOneYear, PracticingSpecialtyXML, CertificationXML, HasPracticingSpecialtyXML, HasCertificationXML, PatientExperienceSurveyOverallStarValue, ProviderBiography, DisplayStatusCode, HealthInsuranceXML_v2, ProviderDEAXML, ProviderTypeXML, SubStatusCode, DuplicateProviderCode, DeactivationReason, ProcedureHierarchyXML, ConditionHierarchyXML, ProcMappedXML, CondMappedXML, PracSpecHeirXML, AboutMeXML, HasAboutMeXML, PatientVolume, HasMalpracticeState, ProcedureCount, ConditionCount, AvailabilityXML, VideoXML2, AvailabilityStatement, IsInClientMarket, HasOAR, IsMMPUser, NatlAdvertisingXML, APIXML, DIHGroupNumber, SubStatusDescription, DEAXML, EmailAddressXML, DegreeXML, HasSurveyXML, HasDEAXML, HasEmailAddressXML, ClientCertificationXML, HasGoogleOAS, HasVideoXML2, HasAboutMe, ConversionPathXML, SearchBoostSatisfaction, SearchBoostAccessibility, IsPCPCalculated, FAFBoostSatisfaction, FAFBoostSancMalp, FFDisplaySpecialty, FFPESBoost, FFMalMultiHQ, FFMalMulti, CLinicalFocusXML, ClinicalFocusDCPXML, SyndicationXML, TeleHealthXML
		FROM	Show.SOLRProvider_FREEZE 
		WHERE	SponsorCode IN (SELECT ClientCode FROM #FreezeClientCode)
				AND ProviderId NOT IN (SELECT ProviderId FROM Show.SOLRProvider)
	END


-- ############ 2. Show_spuSOLRProviderGenerateFromMid #########################################################################################


IF OBJECT_ID('tempdb..#ProvUpdates') IS NOT NULL DROP TABLE #ProvUpdates
		SELECT	TOP 0 [ProviderID], [ProviderCode], [ProviderLegacyKey], [ProviderTypeID], [ProviderTypeGroup], [FirstName], [MiddleName], [LastName], [Suffix], [Degree], [Gender], [NPI], [AMAID], [UPIN], [MedicareID], [DEANumber], [TaxIDNumber], [DateOfBirth], [PlaceOfBirth], [CarePhilosophy], [ProfessionalInterest], [PrimaryEmailAddress], [MedicalSchoolNation], [YearsSinceMedicalSchoolGraduation], [HasDisplayImage], [DisplayImage], [HasElectronicMedicalRecords], [HasElectronicPrescription], [AcceptsNewPatients], [YearlySearchVolume], [ProviderProfileViewOneYear], [PatientExperienceSurveyOverallScore], [PatientExperienceSurveyOverallStarValue], [PatientExperienceSurveyOverallCount], [ProviderBiography], [ProviderURL], [DisplayStatusCode], [SubStatusCode], [DuplicateProviderCode], [ProductGroupCode], [SponsorCode], [ProductCode], [FacilityCode], [SurveyResponse], [SurveyResponseDate], [HasMalpracticeState], [ProcedureCount], [ConditionCount], [IsActive], [UpdatedDate], [UpdatedSource], [Title], [CityStateAll], [DisplayPatientExperienceSurveyOverallScore], [DeactivationReason], [PatientVolume], [AvailabilityStatement], [HasOAR], [IsMMPUser], [HasAboutMe], [SearchBoostSatisfaction], [SearchBoostAccessibility], [IsPCPCalculated], [FAFBoostSatisfaction], [FAFBoostSancMalp], [FFDisplaySpecialty], [FFPESBoost], [FFMalMultiHQ], [FFMalMulti], [ProviderSubTypeCode]
		INTO	#ProvUpdates
		FROM	Show.SOLRProvider
        CREATE INDEX ix_ProvUpdates_ProviderID ON #ProvUpdates (ProviderID)	

		IF OBJECT_ID('tempdb..#BatchProcess') IS NOT NULL DROP TABLE #BatchProcess
		SELECT	TOP 0 ProviderId, NULL AS BatchNumber
		INTO	#BatchProcess
		FROM	Base.Provider
		
		IF @IsProviderDeltaProcessing = 0 
		BEGIN
			TRUNCATE TABLE Show.SOLRProvider
			INSERT INTO #BatchProcess
			SELECT	ProviderId, NULL
			FROM	Base.Provider
			WHERE	NULLIF(NPI, '') IS NOT NULL
		END
		IF @IsProviderDeltaProcessing = 1
		BEGIN
			INSERT INTO #BatchProcess
			SELECT DISTINCT
					pd.ProviderID
				   ,NULL AS BatchNumber
			FROM    xfr.SOLRProviderDelta AS pd 
			INNER JOIN Base.Provider AS p ON p.ProviderID = pd.ProviderID
			WHERE 	p.NPI IS NOT NULL
			UNION 
			SELECT DISTINCT
					pdp.ProviderID
				   ,NULL AS BatchNumber
			FROM    snowflake.etl.ProviderDeltaProcessing AS pdp 
			INNER JOIN Base.Provider AS p ON p.ProviderID = pdp.ProviderID
			WHERE 	p.NPI IS NOT NULL
		END
        CREATE INDEX ix_Mid_ProviderID ON #BatchProcess (ProviderID)	
        CREATE INDEX ix_Mid_BatchNumber ON #BatchProcess (BatchNumber) INCLUDE ([ProviderID])

	--set the records a batch number based on a batch size we are setting
        DECLARE @batchNumberMin INT
        DECLARE @batchNumberMax INT
        DECLARE @batchSize FLOAT
        DECLARE @sql VARCHAR(MAX)

        SET @batchSize = 10000
				--THIS IS THE BATCH SIZE WE ARE PROCESSING... 100K SEEMS TO BE THE FASTEST WITHOUT GOING OVERBOARD
				-- Steve O changed the batch size on 6/8 because of some hardware changes made on the server.
        SET @batchNumberMin = 1
        SELECT  @batchNumberMax = CEILING(COUNT(*) / @batchSize)
        FROM    #BatchProcess

		
		--IF @IsProviderDeltaProcessing = 1
		--BEGIN
			WHILE @batchNumberMin <= @batchNumberMax 
				BEGIN
					SET @sql = '
					update a
					set a.BatchNumber = ' + CAST(@batchNumberMin AS VARCHAR(MAX))
						+ '
					--select *
					from #BatchProcess a
					join 
					(
						select top ' + CAST(@batchSize AS VARCHAR(MAX))
						+ ' ProviderId
						from #BatchProcess
						where BatchNumber is null
					)b on (a.ProviderID = b.ProviderID)
					'
					EXEC (@sql)
			
					SET @batchNumberMin = @batchNumberMin + 1	
				END	
		--END
	--process the records based on designated batches			
        DECLARE @batchProcessMin INT
        DECLARE @batchProcessMax INT

        SET @batchProcessMin = 1
        SELECT  @batchProcessMax = MAX(BatchNumber)
        FROM    #BatchProcess
				 
		IF OBJECT_ID('tempdb..#ProviderImage') IS NOT NULL DROP TABLE #ProviderImage
		SELECT		a.ProviderID
					,a.[FileName] AS ImageFilePath
					,'http://d306gt4zvs7g2s.cloudfront.net/img/prov/'+SUBSTRING(a.FileName,1,1) +  '/' + SUBSTRING(a.FileName,2,1) +  '/' + SUBSTRING(a.FileName,3,1)  +  '/' + a.FileName AS imFull 
					,ROW_NUMBER()OVER(PARTITION BY a.ProviderId ORDER BY a.ProviderId) RN1
        INTO		#ProviderImage
		FROM		Base.ProviderImage a
		INNER JOIN	Base.MediaSize ms WITH(NOLOCK) 
					ON a.MediaSizeID = ms.MediaSizeID 
        WHERE		ms.MediaSizeName='medium' 
		DELETE #ProviderImage WHERE RN1 > 1
		CREATE INDEX ix_ProviderImage_ProviderID ON #ProviderImage (ProviderID)	
		
		IF OBJECT_ID('tempdb..#CarePhilosophy') IS NOT NULL DROP TABLE #CarePhilosophy
		SELECT		ProviderID, pam.ProviderAboutMeText, ROW_NUMBER()OVER(PARTITION BY ProviderId ORDER BY PAM.LastUpdatedDate DESC) AS RN1
		INTO		#CarePhilosophy
		FROM		Base.AboutMe am
		INNER JOIN	Base.ProviderToAboutMe pam 
					ON am.AboutMeID = pam.AboutMeID
					AND am.AboutMeCode = 'CarePhilosophy'
		DELETE #CarePhilosophy WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#CarePhilosophy_ProviderID ON #CarePhilosophy(ProviderID)	
		
		IF OBJECT_ID('tempdb..#cityStateMultiple') IS NOT NULL DROP TABLE #cityStateMultiple
        SELECT  a.ProviderID
                ,dbo.GetPipeSeparatedCityState(a.ProviderID) AS CityStateAll
        INTO    #cityStateMultiple
        FROM    #BatchProcess a
		INNER JOIN (
						SELECT		ProviderID--652,813
						FROM		Mid.ProviderPracticeOffice
						GROUP BY	ProviderID
						HAVING		COUNT(DISTINCT CONCAT(City, State)) > 1
					) b ON (a.ProviderID = b.ProviderID)		
        CREATE INDEX CIX_#cityStateMultiple_ProviderID ON #cityStateMultiple (ProviderID)	
		
		IF OBJECT_ID('tempdb..#cityStateSingle') IS NOT NULL DROP TABLE #cityStateSingle
		;WITH cte_ProviderId AS (
			SELECT		ProviderID--652,813
			FROM		Mid.ProviderPracticeOffice
			GROUP BY	ProviderID
			HAVING		COUNT(DISTINCT CONCAT(City, State)) = 1
		)

		SELECT	ProviderId, RTRIM(LTRIM(City)) + ', ' + State AS CityStateAll
		INTO	#cityStateSingle
		FROM	Mid.ProviderPracticeOffice
		WHERE	ProviderId IN (
					SELECT		ProviderID--652,813
					FROM		cte_ProviderId 
				)
        CREATE INDEX CIX_#cityStateSingle_ProviderID ON #cityStateSingle (ProviderID)	

		IF OBJECT_ID('tempdb..#CityStateAll') IS NOT NULL DROP TABLE #CityStateAll
        SELECT		P.ProviderId
					,CASE WHEN C.ProviderID IS NULL THEN S.CityStateAll ELSE C.CityStateAll
					END AS CityStateAll
		INTO		#CityStateAll
		FROM		#BatchProcess P
		LEFT JOIN	#cityStateSingle S ON S.ProviderID = P.ProviderID
		LEFT JOIN	#cityStateMultiple C ON C.ProviderID = P.ProviderID
        CREATE INDEX CIX_#CityStateAll_ProviderID ON #CityStateAll (ProviderID)	
		
		IF OBJECT_ID('tempdb..#Email') IS NOT NULL DROP TABLE #Email
		SELECT		ProviderID, X.EmailAddress, ROW_NUMBER()OVER(PARTITION BY ProviderId ORDER BY X.LastUpdateDate DESC) AS RN1
		INTO		#Email
		FROM		Base.ProviderEmail X
		DELETE #Email WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#Email_ProviderID ON #Email(ProviderID)
		
		IF OBJECT_ID('tempdb..#ProviderTypeGroup') IS NOT NULL DROP TABLE #ProviderTypeGroup
		SELECT		ProviderTypeID, RTRIM(LTRIM(x.ProviderTypeCode)) AS ProviderTypeCode, ROW_NUMBER()OVER(PARTITION BY ProviderTypeID ORDER BY X.LastUpdateDate DESC) AS RN1
		INTO		#ProviderTypeGroup
		FROM		Base.ProviderType X
		DELETE #Email WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#ProviderTypeGroup_ProviderID ON #ProviderTypeGroup(ProviderTypeID)
		
		IF OBJECT_ID('tempdb..#MedicalSchoolNation') IS NOT NULL DROP TABLE #MedicalSchoolNation
		SELECT		X.ProviderID, X.NationName, ROW_NUMBER()OVER(PARTITION BY X.ProviderId ORDER BY X.NationName DESC, X.GraduationYear DESC) AS RN1
		INTO		#MedicalSchoolNation
		FROM		Mid.ProviderEducation X
		INNER JOIN	#BatchProcess B ON B.ProviderID = X.ProviderID
		DELETE #MedicalSchoolNation WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#MedicalSchoolNation_ProviderID ON #MedicalSchoolNation(ProviderID)
		
		IF OBJECT_ID('tempdb..#YearsSinceMedicalSchoolGraduation') IS NOT NULL DROP TABLE #YearsSinceMedicalSchoolGraduation
		SELECT		X.ProviderID, YEAR(GETDATE()) - NULLIF(TRY_CONVERT(INT, GraduationYear), 0) AS YearsSinceMedicalSchoolGraduation, ROW_NUMBER()OVER(PARTITION BY X.ProviderId ORDER BY X.NationName DESC, X.GraduationYear DESC) AS RN1
		INTO		#YearsSinceMedicalSchoolGraduation
		FROM		Mid.ProviderEducation X
		INNER JOIN	#BatchProcess B ON B.ProviderID = X.ProviderID
		DELETE #YearsSinceMedicalSchoolGraduation WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#YearsSinceMedicalSchoolGraduation_ProviderID ON #YearsSinceMedicalSchoolGraduation(ProviderID)	
		
		IF OBJECT_ID('tempdb..#PatientExperienceSurveyOverallScore') IS NOT NULL DROP TABLE #PatientExperienceSurveyOverallScore
		SELECT		X.ProviderID, (ProviderAverageScore / 5) * 100 AS PatientExperienceSurveyOverallScore, ROW_NUMBER()OVER(PARTITION BY X.ProviderId ORDER BY X.UpdatedOn DESC) AS RN1
		INTO		#PatientExperienceSurveyOverallScore
		FROM		dbo.ProviderSurveyAggregate X
		INNER JOIN	#BatchProcess B ON B.ProviderID = X.ProviderID
		WHERE		QuestionID = 231
		DELETE #PatientExperienceSurveyOverallScore WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#PatientExperienceSurveyOverallScore_ProviderID ON #PatientExperienceSurveyOverallScore(ProviderID)
		
		IF OBJECT_ID('tempdb..#PatientExperienceSurveyOverallStarValue') IS NOT NULL DROP TABLE #PatientExperienceSurveyOverallStarValue
		SELECT		X.ProviderID, X.ProviderAverageScore, ROW_NUMBER()OVER(PARTITION BY X.ProviderId ORDER BY X.UpdatedOn DESC) AS RN1
		INTO		#PatientExperienceSurveyOverallStarValue
		FROM		dbo.ProviderSurveyAggregate X
		INNER JOIN	#BatchProcess B ON B.ProviderID = X.ProviderID
		WHERE		QuestionID = 231
		DELETE #PatientExperienceSurveyOverallStarValue WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#PatientExperienceSurveyOverallStarValue_ProviderID ON #PatientExperienceSurveyOverallStarValue(ProviderID)
		
		IF OBJECT_ID('tempdb..#PatientExperienceSurveyOverallCount') IS NOT NULL DROP TABLE #PatientExperienceSurveyOverallCount
		SELECT		X.ProviderID, X.QuestionCount, ROW_NUMBER()OVER(PARTITION BY X.ProviderId ORDER BY X.UpdatedOn DESC) AS RN1
		INTO		#PatientExperienceSurveyOverallCount
		FROM		dbo.ProviderSurveyAggregate X
		INNER JOIN	#BatchProcess B ON B.ProviderID = X.ProviderID
		WHERE		QuestionID = 231
		DELETE #PatientExperienceSurveyOverallCount WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#PatientExperienceSurveyOverallCount_ProviderID ON #PatientExperienceSurveyOverallCount(ProviderID)
		
		IF OBJECT_ID('tempdb..#DisplayStatusCode') IS NOT NULL DROP TABLE #DisplayStatusCode
		SELECT	X.ProviderId, X.DisplayStatusCode, X.HierarchyRank, X.SubStatusRank, ROW_NUMBER()OVER(PARTITION BY X.ProviderId ORDER BY X.HierarchyRank, X.SubStatusRank) AS RN1
		INTO	#DisplayStatusCode
		FROM(
			SELECT		A.ProviderId, c.DisplayStatusCode, a.HierarchyRank, SS.SubStatusRank
			FROM		Base.ProviderToSubStatus AS a 
			INNER JOIN	#BatchProcess B ON B.ProviderID = A.ProviderID
			INNER JOIN	Base.SubStatus AS SS ON SS.SubStatusID = a.SubStatusID
			INNER JOIN	Base.DisplayStatus AS c ON c.DisplayStatusID = SS.DisplayStatusID
			WHERE		a.hierarchyrank = 1
			UNION
			SELECT		ProviderId, 'A' AS DisplayStatusCode, 2147483647 AS HierarchyRank, 2147483647 AS SubStatusRank
			FROM		Base.Provider
		)X
		DELETE #DisplayStatusCode WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#DisplayStatusCode_ProviderID ON #DisplayStatusCode(ProviderID)
		
		IF OBJECT_ID('tempdb..#SubStatusCode') IS NOT NULL DROP TABLE #SubStatusCode
		SELECT	X.ProviderId, X.SubStatusCode, X.HierarchyRank, X.SubStatusRank, ROW_NUMBER()OVER(PARTITION BY X.ProviderId ORDER BY X.HierarchyRank, X.SubStatusRank) AS RN1
		INTO	#SubStatusCode
		FROM(
			SELECT		A.ProviderId, SS.SubStatusCode, a.HierarchyRank, SS.SubStatusRank
			FROM		Base.ProviderToSubStatus AS a 
			INNER JOIN	#BatchProcess B ON B.ProviderID = A.ProviderID
			INNER JOIN	Base.SubStatus AS SS ON SS.SubStatusID = a.SubStatusID
			INNER JOIN	Base.DisplayStatus AS c ON c.DisplayStatusID = SS.DisplayStatusID
			WHERE		a.hierarchyrank = 1
			UNION
			SELECT		ProviderId, 'K' AS SubStatusCode, 2147483647 AS HierarchyRank, 2147483647 AS SubStatusRank
			FROM		Base.Provider
		)X
		DELETE #SubStatusCode WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#SubStatusCode_ProviderID ON #SubStatusCode(ProviderID)
		
		IF OBJECT_ID('tempdb..#ProductGroupCode') IS NOT NULL DROP TABLE #ProductGroupCode
		SELECT		P.ProviderID, ProductGroupCode, ROW_NUMBER()OVER(PARTITION BY P.ProviderId ORDER BY ProductGroupCode DESC) AS RN1
		INTO		#ProductGroupCode
		FROM		Mid.ProviderSponsorship X
		INNER JOIN	Base.Provider P ON P.ProviderCode = X.ProviderCode
		INNER JOIN	#BatchProcess B ON B.ProviderID = P.ProviderID
		WHERE		ProductGroupCode = 'PDC'
		DELETE #ProductGroupCode WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#ProductGroupCode_ProviderID ON #ProductGroupCode(ProviderID)
		
		IF OBJECT_ID('tempdb..#ProductCode') IS NOT NULL DROP TABLE #ProductCode
		SELECT		P.ProviderID, ProductCode, ROW_NUMBER()OVER(PARTITION BY P.ProviderId ORDER BY ProductGroupCode DESC) AS RN1
		INTO		#ProductCode
		FROM		Mid.ProviderSponsorship X
		INNER JOIN	Base.Provider P ON P.ProviderCode = X.ProviderCode
		INNER JOIN	#BatchProcess B ON B.ProviderID = P.ProviderID
		WHERE		ProductGroupCode = 'PDC'
		DELETE #ProductCode WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#ProductCode_ProviderID ON #ProductCode(ProviderID)
		
		IF OBJECT_ID('tempdb..#SponsorCode') IS NOT NULL DROP TABLE #SponsorCode
		SELECT		P.ProviderID, ClientCode AS SponsorCode, ROW_NUMBER()OVER(PARTITION BY P.ProviderId ORDER BY ProductGroupCode DESC) AS RN1
		INTO		#SponsorCode
		FROM		Mid.ProviderSponsorship X
		INNER JOIN	Base.Provider P ON P.ProviderCode = X.ProviderCode
		INNER JOIN	#BatchProcess B ON B.ProviderID = P.ProviderID
		WHERE		ProductGroupCode = 'PDC'
		DELETE #SponsorCode WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#SponsorCode_ProviderID ON #SponsorCode(ProviderID)
		
		IF OBJECT_ID('tempdb..#FacilityCode') IS NOT NULL DROP TABLE #FacilityCode
		SELECT		P.ProviderID, dbo.GetPipeSeparatedPDCFacility(X.ProviderCode) Facility, ROW_NUMBER()OVER(PARTITION BY P.ProviderId ORDER BY ProductGroupCode DESC) AS RN1
		INTO		#FacilityCode
		FROM		Mid.ProviderSponsorship X
		INNER JOIN	Base.Provider P ON P.ProviderCode = X.ProviderCode
		INNER JOIN	#BatchProcess B ON B.ProviderID = P.ProviderID
		WHERE		ProductGroupCode = 'PDC'
		DELETE #FacilityCode WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#FacilityCode_ProviderID ON #FacilityCode(ProviderID)
		
		IF OBJECT_ID('tempdb..#AboutMe') IS NOT NULL DROP TABLE #AboutMe
		SELECT		PAM.ProviderID, ProviderAboutMeText, ROW_NUMBER()OVER(PARTITION BY B.ProviderId ORDER BY PAM.LastUpdatedDate DESC) AS RN1
		INTO		#AboutMe
		FROM		Base.AboutMe am
		INNER JOIN	Base.ProviderToAboutMe pam 
					ON am.AboutMeID = pam.AboutMeID
					AND am.AboutMeCode = 'ResponseToPes'
		INNER JOIN	#BatchProcess B ON B.ProviderID = PAM.ProviderID
		DELETE #AboutMe WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#AboutMe_ProviderID ON #AboutMe(ProviderID)
		
		IF OBJECT_ID('tempdb..#SurveyResponseDate') IS NOT NULL DROP TABLE #SurveyResponseDate
		SELECT		pam.ProviderID, SurveyResponseDate, ROW_NUMBER()OVER(PARTITION BY B.ProviderId ORDER BY PAM.SurveyResponseDate DESC) AS RN1
		INTO		#SurveyResponseDate
		FROM		Mid.ProviderSurveyResponse pam 
		INNER JOIN	#BatchProcess B ON B.ProviderID = PAM.ProviderID
		DELETE #SurveyResponseDate WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#SurveyResponseDate_ProviderID ON #SurveyResponseDate(ProviderID)
							
		IF OBJECT_ID('tempdb..#HasMalpracticeState') IS NOT NULL DROP TABLE #HasMalpracticeState
		SELECT	ProviderId, HasMalpracticeState, ROW_NUMBER()OVER(PARTITION BY ProviderID ORDER BY HasMalpracticeState DESC) AS RN1
		INTO	#HasMalpracticeState
		FROM(
			SELECT	ProviderId
					,CASE WHEN EXISTS (
								SELECT 1
								FROM Mid.ProviderPracticeOffice ppo
								JOIN Base.MalpracticeState mps ON ppo.State = mps.STATE AND ISNULL(mps.Active,1) = 1
								WHERE p.ProviderID = ppo.ProviderID
							)
						THEN 1
						WHEN EXISTS (
								SELECT 1
								FROM Mid.ProviderMalpractice pm
								WHERE p.ProviderID = pm.ProviderID
							)
						THEN 1 ELSE 0 END HasMalpracticeState
			FROM		#BatchProcess P
		)X
		DELETE #HasMalpracticeState WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#HasMalpracticeState_ProviderID ON #HasMalpracticeState(ProviderID)
		
		IF OBJECT_ID('tempdb..#ProcedureCount') IS NOT NULL DROP TABLE #ProcedureCount
		SELECT		X.ProviderID, COUNT(ProcedureCode) AS ProcedureCount
		INTO		#ProcedureCount
		FROM		Mid.ProviderProcedure X
		INNER JOIN	#BatchProcess B ON B.ProviderID = X.ProviderID
		GROUP BY	X.ProviderID
		CREATE CLUSTERED INDEX CIX_#ProcedureCount_ProviderID ON #ProcedureCount(ProviderID)
		
		IF OBJECT_ID('tempdb..#ConditionCount') IS NOT NULL DROP TABLE #ConditionCount
		SELECT		X.ProviderID, COUNT(ProcedureCode) AS ConditionCount
		INTO		#ConditionCount
		FROM		Mid.ProviderProcedure X
		INNER JOIN	#BatchProcess B ON B.ProviderID = X.ProviderID
		GROUP BY	X.ProviderID
		CREATE CLUSTERED INDEX CIX_#ConditionCount_ProviderID ON #ConditionCount(ProviderID)
		
		IF OBJECT_ID('tempdb..#ConditionCode') IS NOT NULL DROP TABLE #ConditionCode
		SELECT		X.ProviderID, COUNT(ProcedureCode) AS ConditionCount
		INTO		#ConditionCode
		FROM		Mid.ProviderProcedure X
		INNER JOIN	#BatchProcess B ON B.ProviderID = X.ProviderID
		GROUP BY	X.ProviderID
		CREATE CLUSTERED INDEX CIX_#ConditionCode_ProviderID ON #ConditionCode(ProviderID)
		
		IF OBJECT_ID('tempdb..#OAR') IS NOT NULL DROP TABLE #OAR
        SELECT		DISTINCT B.ProviderId, HasOar
		INTO		#OAR
        FROM		Mid.ProviderSponsorship X
		INNER JOIN	Base.Product bp ON X.ProductCode = bp.ProductCode
		INNER JOIN	Base.Provider P ON P.ProviderCode = X.ProviderCode
		INNER JOIN	#BatchProcess B ON B.ProviderID = P.ProviderID
					AND(
						bp.ProductTypeCode = 'PRACTICE'
						OR x.clientcode  IN ('OCHSNR', 'PRVHEW')
					)
		
		IF OBJECT_ID('tempdb..#AvailabilityStatement') IS NOT NULL DROP TABLE #AvailabilityStatement
		SELECT		X.ProviderID, AppointmentAvailabilityStatement, ROW_NUMBER()OVER(PARTITION BY X.ProviderId ORDER BY LastUpdatedDate DESC) AS RN1
		INTO		#AvailabilityStatement
		FROM		Base.ProviderAppointmentAvailabilityStatement X
		INNER JOIN	#BatchProcess B ON B.ProviderID = X.ProviderID
		CREATE CLUSTERED INDEX CIX_#AvailabilityStatement_ProviderID ON #AvailabilityStatement(ProviderID)
		
		IF OBJECT_ID('tempdb..#HasAboutMe') IS NOT NULL DROP TABLE #HasAboutMe
		SELECT		DISTINCT B.ProviderID, 1 AS HasAboutMe
		INTO		#HasAboutMe
		FROM		Base.AboutMe X
		INNER JOIN	Base.ProviderToAboutMe PAM ON PAM.AboutMeID = X.AboutMeID
		INNER JOIN	#BatchProcess B ON B.ProviderID = PAM.ProviderID
		WHERE		X.AboutMeCode = 'About'
		CREATE CLUSTERED INDEX CIX_#HasAboutMe_ProviderID ON #HasAboutMe(ProviderID)

		IF OBJECT_ID('tempdb..#ProviderSubType') IS NOT NULL DROP TABLE #ProviderSubType
		SELECT		x.ProviderID, z.ProviderSubTypeCode, ROW_NUMBER()OVER(PARTITION BY x.ProviderId ORDER BY z.ProviderSubTypeRank ASC, x.LastUpdateDate DESC) AS RN1
		INTO		#ProviderSubType
		FROM		Base.ProviderToProviderSubType x
		INNER JOIN	Base.ProviderSubType z ON x.ProviderSubTypeID = z.ProviderSubTypeID
		INNER JOIN	#BatchProcess B ON B.ProviderID = x.ProviderID
		DELETE #ProviderSubType WHERE RN1 > 1
		CREATE CLUSTERED INDEX CIX_#ProviderSubType_ProviderID ON #ProviderSubType(ProviderID)

		DROP TABLE IF EXISTS #ProviderIsBoardEligible
		--Using ANY Providers that have Board Actions (Sanctions)
		SELECT ps.ProviderID
		INTO #ProviderIsBoardEligible
		FROM Base.ProviderSanction ps
		JOIN Base.SanctionAction sa ON sa.SanctionActionID = ps.SanctionActionID
		JOIN Base.SanctionActionType sat ON sat.SanctionActionTypeID = sa.SanctionActionTypeID
		JOIN #BatchProcess bp ON ps.ProviderID = bp.ProviderID
		WHERE sat.SanctionActionTypeCode = 'B'
		UNION
		--Using Only Provider SubType (DOC and NDOC)
		SELECT ptpst.ProviderID
		FROM Base.ProviderSubType pst
		JOIN Base.ProviderToProviderSubType ptpst ON ptpst.ProviderSubTypeID = pst.ProviderSubTypeID
		JOIN #BatchProcess bp ON ptpst.ProviderID = bp.ProviderID
		WHERE pst.IsBoardActionEligible = 1
		UNION
		--Using Provider SubType To Degree (MDEX Plus Degrees)
		SELECT ptpst.ProviderID
		FROM Base.ProviderSubTypeToDegree psttd
		JOIN Base.ProviderToProviderSubType ptpst ON psttd.ProviderSubTypeID = ptpst.ProviderSubTypeID
		JOIN Base.ProviderToDegree ptd ON ptd.ProviderID = ptpst.ProviderID AND psttd.DegreeID = ptd.DegreeID
		JOIN #BatchProcess bp ON ptpst.ProviderID = bp.ProviderID
		WHERE psttd.IsBoardActionEligible = 1
		UNION
		--Using Specialty Group (GMPA)
		SELECT ps.ProviderID
		FROM Base.SpecialtyGroup sg
		JOIN Base.SpecialtyGroupToSpecialty sgts ON sgts.SpecialtyGroupID = sg.SpecialtyGroupID
		JOIN Base.ProviderToSpecialty ps ON ps.SpecialtyID = sgts.SpecialtyID
		JOIN #BatchProcess bp ON ps.ProviderID = bp.ProviderID
		WHERE sg.IsBoardActionEligible = 1

		CREATE CLUSTERED INDEX CIX_#ProviderIsBoardEligible_ProviderID ON #ProviderIsBoardEligible(ProviderID)
				
        PRINT 'Process Start'
        PRINT GETDATE()
        WHILE @batchProcessMin <= @batchProcessMax 
            BEGIN	
				--get the records to process that are new or deltas within a batch
                BEGIN TRY
                    DROP TABLE #BatchInsertUpdateProcess
                END TRY
                BEGIN CATCH
                END CATCH
                SELECT DISTINCT
                        ProviderID
                INTO    #BatchInsertUpdateProcess
                FROM    #BatchProcess
                WHERE   BatchNumber = @batchProcessMin




INSERT INTO #ProvUpdates([ProviderID], [ProviderCode], [ProviderLegacyKey], [ProviderTypeID], [ProviderTypeGroup], [FirstName], [MiddleName], [LastName], [Suffix], [Degree], [Gender], [NPI], [AMAID], [UPIN], [MedicareID], [DEANumber], [TaxIDNumber], [DateOfBirth], [PlaceOfBirth], [CarePhilosophy], [ProfessionalInterest], [PrimaryEmailAddress], [MedicalSchoolNation], [YearsSinceMedicalSchoolGraduation], [HasDisplayImage], [DisplayImage], [HasElectronicMedicalRecords], [HasElectronicPrescription], [AcceptsNewPatients], [YearlySearchVolume], [ProviderProfileViewOneYear], [PatientExperienceSurveyOverallScore], [PatientExperienceSurveyOverallStarValue], [PatientExperienceSurveyOverallCount], [ProviderBiography], [ProviderURL], [DisplayStatusCode], [SubStatusCode], [DuplicateProviderCode], [ProductGroupCode], [SponsorCode], [ProductCode], [FacilityCode], [SurveyResponse], [SurveyResponseDate], [HasMalpracticeState], [ProcedureCount], [ConditionCount], [IsActive], [UpdatedDate], [UpdatedSource], [Title], [CityStateAll], [DisplayPatientExperienceSurveyOverallScore], [DeactivationReason], [PatientVolume], [AvailabilityStatement], [HasOAR], [IsMMPUser], [HasAboutMe], [SearchBoostSatisfaction], [SearchBoostAccessibility], [IsPCPCalculated], [FAFBoostSatisfaction], [FAFBoostSancMalp], [FFDisplaySpecialty], [FFPESBoost], [FFMalMultiHQ], [FFMalMulti], [ProviderSubTypeCode])
				SELECT b.ProviderID
                    ,ProviderCode
                    ,LegacyKey AS ProviderLegacyKey
                    ,ProviderTypeID
                    ,ProviderTypeGroup
                    ,FirstName
                    ,MiddleName
                    ,LastName
                    ,Suffix
                    ,UPPER(Degree) AS Degree
                    ,UPPER(Gender) AS Gender
                    ,NPI
                    ,AMAID
                    ,UPIN
                    ,MedicareID
                    ,DEANumber
                    ,TaxIDNumber
                    ,DateOfBirth
                    ,PlaceOfBirth
                    ,CarePhilosophy
                    ,ProfessionalInterest
                    ,PrimaryEmailAddress
                    , /*City,St*/MedicalSchoolNation
                    ,YearsSinceMedicalSchoolGraduation
                    ,HasDisplayImage
                    ,imFull AS DisplayImage
                    ,HasElectronicMedicalRecords
                    ,HasElectronicPrescription
                    ,AcceptsNewPatients
                    ,YearlySearchVolume
                    ,ProviderProfileViewOneYear
                    ,PatientExperienceSurveyOverallScore
                    ,PatientExperienceSurveyOverallStarValue
                    ,PatientExperienceSurveyOverallCount
                    ,ProviderBiography
                    ,ProviderURL
                    ,py.DisplayStatusCode
                    ,py.SubStatusCode
                    ,CASE WHEN SubStatusCode = 'U' THEN SubStatusValueA ELSE NULL END AS DuplicateProviderCode
                    ,ProductGroupCode
                    ,SponsorCode
                    ,ProductCode
                    ,FacilityCode
                    ,SurveyResponse
                    ,SurveyResponseDate
					,HasMalpracticeState
					,ProcedureCount
					,ConditionCount
                    ,NULL AS IsActive
                    ,UpdatedDate
                    ,UpdatedSource
                    ,Title
                    ,CityStateAll
                    ,CASE WHEN PatientExperienceSurveyOverallScore >= 75 THEN 1 ELSE 0 END AS DisplayPatientExperienceSurveyOverallScore
                    ,ds.DeactivationReason AS DeactivationReason
					,PatientVolume
                    ,AvailabilityStatement
					,HasOAR
                    ,IsMMPUser
					,HasAboutMe
                    ,SearchBoostSatisfaction
                    ,SearchBoostAccessibility
					,IsPCPCalculated
					,FAFBoostSatisfaction
					,FAFBoostSancMalp
					,FFDisplaySpecialty
					,FFPESBoost
					,FFMalMultiHQ
					,FFMalMulti
					,ProviderSubTypeCode
                FROM(
                        SELECT p.ProviderID
                            ,p.ProviderCode
                            ,p.ProviderTypeID
                            ,p.FirstName
                            ,p.MiddleName
                            ,p.LastName
                            ,p.Suffix
                            ,p.Gender
                            ,p.NPI
                            ,p.AMAID
                            ,p.UPIN
                            ,p.MedicareID
                            ,p.DEANumber
                            ,p.TaxIDNumber
                            ,p.DateOfBirth
                            ,p.PlaceOfBirth
							,(
								SELECT	TOP 1 ProviderAboutMeText 
								FROM	#CarePhilosophy X
								WHERE	X.ProviderID = p.ProviderID
							) AS CarePhilosophy
                            ,p.ProfessionalInterest
                            ,p.AcceptsNewPatients
                            ,p.HasElectronicMedicalRecords
                            ,p.HasElectronicPrescription
                            ,p.LegacyKey
                            ,p.DegreeAbbreviation AS Degree
                            ,p.Title
                            ,p.ProviderURL
                            ,p.ExpireCode
                            ,pss.SubStatusValueA
							,(
								SELECT	TOP 1 X.CityStateAll
								FROM	#CityStateAll X
								WHERE	X.ProviderID = p.ProviderID
							)AS CityStateAll
                            ,(
								SELECT	TOP 1 EmailAddress 
								FROM	#Email X
								WHERE	X.ProviderID = p.ProviderID
                            ) AS PrimaryEmailAddress
                            ,(
                                SELECT	TOP 1 RTRIM(LTRIM(ProviderTypeCode))
								FROM	#ProviderTypeGroup X
								WHERE	X.ProviderTypeID = p.ProviderTypeID
                            ) AS ProviderTypeGroup
                            ,(
                                SELECT TOP 1 NationName
                                FROM   #MedicalSchoolNation X
								WHERE	X.ProviderID = p.ProviderID
                            ) AS MedicalSchoolNation
                            ,(
								SELECT	TOP 1 YearsSinceMedicalSchoolGraduation
                                FROM	#YearsSinceMedicalSchoolGraduation X
                                WHERE	X.ProviderID = p.ProviderID
                            ) AS YearsSinceMedicalSchoolGraduation    
                            ,CASE WHEN EXISTS(SELECT ProviderId FROM #ProviderImage a WHERE a.ProviderID = p.ProviderID) THEN 1 ELSE 0 END AS HasDisplayImage
                            ,(
                                SELECT	TOP 1 ImageFilePath
                                FROM	#ProviderImage a
                                WHERE	a.ProviderID = p.ProviderID
                            ) AS [Image]
                            ,(
                                SELECT	TOP 1 imFull
                                FROM	#ProviderImage a
                                WHERE	a.ProviderID = p.ProviderID
                            ) AS imFull
							,NULL AS ProviderProfileViewOneYear
                            ,NULL AS YearlySearchVolume
                            ,(
                                SELECT	TOP 1 PatientExperienceSurveyOverallScore
                                FROM	#PatientExperienceSurveyOverallScore X
								WHERE	X.ProviderID = p.ProviderID
                            ) AS PatientExperienceSurveyOverallScore
                            ,(
                                SELECT	TOP 1 ProviderAverageScore
                                FROM	#PatientExperienceSurveyOverallStarValue X
								WHERE	X.ProviderID = p.ProviderID
                            ) AS PatientExperienceSurveyOverallStarValue
                            ,(
                                SELECT	TOP 1 QuestionCount
                                FROM	#PatientExperienceSurveyOverallCount X
								WHERE	X.ProviderID = p.ProviderID
                            ) AS PatientExperienceSurveyOverallCount
                            ,NULL AS ProviderBiography
                            ,(
								SELECT	TOP 1 DisplayStatusCode
								FROM	#DisplayStatusCode X
								WHERE	X.ProviderID = p.ProviderID
                            ) AS DisplayStatusCode
                            ,(
								SELECT	TOP 1 SubStatusCode
								FROM	#SubStatusCode X
								WHERE	X.ProviderID = p.ProviderID
                            ) AS SubStatusCode
                            ,(
								SELECT	TOP 1 ProductGroupCode
								FROM	#ProductGroupCode X
								WHERE	X.ProviderID = p.ProviderID
                            ) AS ProductGroupCode
                            ,(
                                SELECT	TOP 1 SponsorCode
								FROM	#SponsorCode X
								WHERE	X.ProviderID = p.ProviderID
                            ) AS SponsorCode
                            ,(
                                SELECT	TOP 1 ProductCode
								FROM	#ProductCode X
								WHERE	X.ProviderID = p.ProviderID
                            ) AS ProductCode
                            ,(
                                SELECT	TOP 1 Facility
								FROM	#FacilityCode X
								WHERE	X.ProviderID = p.ProviderID
                            ) AS FacilityCode
							,(
                                SELECT	TOP 1 ProviderAboutMeText
								FROM	#AboutMe X
								WHERE	X.ProviderID = p.ProviderID
                            ) AS SurveyResponse
                            ,(
                                SELECT	TOP 1 SurveyResponseDate
                                FROM	#SurveyResponseDate X
                                WHERE	X.ProviderID = p.ProviderID
                            ) AS SurveyResponseDate
							,(
                                SELECT	TOP 1 HasMalpracticeState
                                FROM	#HasMalpracticeState X
                                WHERE	X.ProviderID = p.ProviderID
							) AS HasMalpracticeState
							,(
								SELECT ProcedureCount
								FROM   #ProcedureCount X
								WHERE  X.ProviderID = P.ProviderID
							) AS ProcedureCount
							,(
								SELECT ConditionCount
								FROM   #ConditionCount X
								WHERE  X.ProviderID = P.ProviderID
							) AS ConditionCount
							,NULL AS PatientVolume
							,(
                                SELECT	TOP 1 AppointmentAvailabilityStatement
                                FROM	#AvailabilityStatement X
                                WHERE	X.ProviderID = p.ProviderID
                            ) AS AvailabilityStatement
                            ,p.ProviderLastUpdateDateOverall AS UpdatedDate
                            ,NULL AS UpdatedSource
                            ,(
                                SELECT	TOP 1 HasOar
                                FROM	#OAR X
                                WHERE	X.ProviderID = p.ProviderID
                            ) AS HasOar
							,NULL AS IsMMPUser,
							(
                                SELECT	TOP 1 HasAboutMe
                                FROM	#HasAboutMe X
                                WHERE	X.ProviderID = p.ProviderID
							) AS HasAboutMe
							,pb.SearchBoostSatisfaction
                            ,pb.SearchBoostAccessibility
							,pb.IsPCPCalculated
							,pb.FAFBoostSatisfaction
							,pb.FAFBoostSancMalp
							,p.FFDisplaySpecialty
							,pb.FFESatisfactionBoost as FFPESBoost
							,pb.FFMalMultiHQ
							,pb.FFMalMulti
                            ,(
								SELECT	TOP 1 x.ProviderSubTypeCode 
								FROM	#ProviderSubType x
								WHERE	x.ProviderID = p.ProviderID
                            ) AS ProviderSubTypeCode
                        FROM   Mid.Provider AS p
						inner join Base.Provider as pb on pb.ProviderID = p.ProviderID
                            INNER JOIN #BatchInsertUpdateProcess
                            AS batch ON batch.ProviderID = p.ProviderID
                            LEFT JOIN #cityStateMultiple e ON (p.ProviderID = e.ProviderID)
                            LEFT JOIN (SELECT   a.ProviderID
                                                ,a.SubStatusValueA
                                        FROM     Base.ProviderToSubStatus a
                                                JOIN Base.SubStatus b ON b.SubStatusID = a.SubStatusID
                                                    AND b.SubStatusCode = 'U'
                                        ) pss ON pss.ProviderID = p.ProviderID  


                    ) AS py
                    LEFT JOIN Base.DisplayStatus ds ON ds.DisplayStatusCode = py.DisplayStatusCode
					JOIN #BatchInsertUpdateProcess b ON b.ProviderID = py.ProviderID




        IF @IsProviderDeltaProcessing = 1
		BEGIN
				UPDATE s
				SET s.ProviderCode = px.ProviderCode
					,s.ProviderTypeID = px.ProviderTypeID
					,s.ProviderTypeGroup = px.ProviderTypeGroup
					,s.FirstName = px.FirstName
					,s.MiddleName = px.MiddleName
					,s.LastName = px.LastName
					,s.Suffix = px.Suffix
					,s.Degree = px.Degree
					,s.Gender = px.Gender
					,s.NPI = px.NPI
					,s.AMAID = px.AMAID
					,s.UPIN = px.UPIN
					,s.MedicareID = px.MedicareID
					,s.DEANumber = px.DEANumber
					,s.TaxIDNumber = px.TaxIDNumber
					,s.DateOfBirth = px.DateOfBirth
					,s.PlaceOfBirth = px.PlaceOfBirth
					,s.CarePhilosophy = px.CarePhilosophy
					,s.ProfessionalInterest = px.ProfessionalInterest
					,s.PrimaryEmailAddress = px.PrimaryEmailAddress
					,s.MedicalSchoolNation = px.MedicalSchoolNation
					,s.YearsSinceMedicalSchoolGraduation = px.YearsSinceMedicalSchoolGraduation
					,s.HasDisplayImage = px.HasDisplayImage
					,s.HasElectronicMedicalRecords = px.HasElectronicMedicalRecords
					,s.HasElectronicPrescription = px.HasElectronicPrescription
					,s.AcceptsNewPatients = px.AcceptsNewPatients
					,s.YearlySearchVolume = px.YearlySearchVolume
					,s.ProviderProfileViewOneYear = px.ProviderProfileViewOneYear
					,s.PatientExperienceSurveyOverallScore = px.PatientExperienceSurveyOverallScore
					,s.PatientExperienceSurveyOverallStarValue = px.PatientExperienceSurveyOverallStarValue
					,s.PatientExperienceSurveyOverallCount = px.PatientExperienceSurveyOverallCount
					,s.ProviderBiography = px.ProviderBiography
					,s.ProviderURL = px.ProviderURL
					,s.ProductGroupCode = px.ProductGroupCode
					,s.SponsorCode = px.SponsorCode
					,s.ProductCode = px.ProductCode
					,s.FacilityCode = px.FacilityCode
					,s.ProviderLegacyKey = px.ProviderLegacyKey
					,s.DisplayImage = px.DisplayImage
					,s.SurveyResponse = px.SurveyResponse
					,s.SurveyResponseDate = px.SurveyResponseDate
					,s.UpdatedDate = px.UpdatedDate
					,s.IsActive = px.IsActive
					,s.UpdatedSource = px.UpdatedSource
					,s.Title = px.Title
					,s.CityStateAll = px.CityStateAll
					,s.DisplayPatientExperienceSurveyOverallScore = px.DisplayPatientExperienceSurveyOverallScore
					,s.DisplayStatusCode = px.DisplayStatusCode
					,s.SubStatusCode = px.SubStatusCode
					,s.DeactivationReason = px.DeactivationReason
					,s.DuplicateProviderCode = px.DuplicateProviderCode
					,s.PatientVolume = px.PatientVolume
					,s.HasMalpracticeState = px.HasMalpracticeState
					,s.ProcedureCount = px.ProcedureCount
					,s.ConditionCount = px.ConditionCount
					,s.AvailabilityStatement = px.AvailabilityStatement
					,s.HasOar = px.HasOar
					,s.IsMMPUser = px.IsMMPUser
					,s.HasAboutMe = px.HasAboutMe
                    ,s.SearchBoostSatisfaction = px.SearchBoostSatisfaction
                    ,s.SearchBoostAccessibility = px.SearchBoostAccessibility
					,s.isPCPCalculated = px.isPCPCalculated
					,s.FAFBoostSatisfaction = px.FAFBoostSatisfaction
					,s.FAFBoostSancMalp = px.FAFBoostSancMalp
					,s.FFDisplaySpecialty = px.FFDisplaySpecialty
					,s.FFPESBoost = px.FFPESBoost
					,s.FFMalMultiHQ = px.FFMalMultiHQ
					,s.FFMalMulti = px.FFMalMulti
					,s.ProviderSubTypeCode = px.ProviderSubTypeCode
				FROM Show.SOLRProvider s		
					JOIN #ProvUpdates px ON px.ProviderID = s.ProviderID;
		END			

		
		INSERT INTO Show.SOLRProvider (
                                 ProviderID
                                ,ProviderCode
                                ,ProviderTypeID
                                ,ProviderTypeGroup
                                ,FirstName
                                ,MiddleName
                                ,LastName
                                ,Suffix
                                ,Degree
                                ,Gender
                                ,NPI
                                ,AMAID
                                ,UPIN
                                ,MedicareID
                                ,DEANumber
                                ,TaxIDNumber
                                ,DateOfBirth
                                ,PlaceOfBirth
                                ,CarePhilosophy
                                ,ProfessionalInterest
                                ,PrimaryEmailAddress
                                ,MedicalSchoolNation
                                ,YearsSinceMedicalSchoolGraduation
                                ,HasDisplayImage
                                ,HasElectronicMedicalRecords
                                ,HasElectronicPrescription
                                ,AcceptsNewPatients
                                ,YearlySearchVolume
                                ,ProviderProfileViewOneYear
                                ,PatientExperienceSurveyOverallScore
                                ,PatientExperienceSurveyOverallStarValue
                                ,PatientExperienceSurveyOverallCount
                                ,ProviderBiography
								,ProviderURL
                                ,ProductGroupCode
                                ,SponsorCode
                                ,ProductCode
                                ,FacilityCode
                                ,ProviderLegacyKey
                                ,DisplayImage
                                ,SurveyResponse
                                ,SurveyResponseDate
                                ,IsActive
                                ,UpdatedDate
                                ,UpdatedSource
                                ,Title
                                ,CityStateAll
                                ,DisplayPatientExperienceSurveyOverallScore
                                ,DisplayStatusCode
                                ,SubStatusCode
                                ,DuplicateProviderCode
                                ,DeactivationReason
								,PatientVolume
								,HasMalpracticeState
								,ProcedureCount
								,ConditionCount
                                ,AvailabilityStatement
								,HasOar
								,IsMMPUser
								,HasAboutMe
                                ,SearchBoostSatisfaction
                                ,SearchBoostAccessibility
								,isPCPCalculated
								,FAFBoostSatisfaction
								,FAFBoostSancMalp
								,FFDisplaySpecialty
								,FFPESBoost
								,FFMalMultiHQ
								,FFMalMulti
								,ProviderSubTypeCode)
                         select px.ProviderID
                                ,px.ProviderCode
                                ,px.ProviderTypeID
                                ,px.ProviderTypeGroup
                                ,px.FirstName
                                ,px.MiddleName
                                ,px.LastName
                                ,px.Suffix
                                ,px.Degree
                                ,px.Gender
                                ,px.NPI
                                ,px.AMAID
                                ,px.UPIN
                                ,px.MedicareID
                                ,px.DEANumber
                                ,px.TaxIDNumber
                                ,px.DateOfBirth
                                ,px.PlaceOfBirth
                                ,px.CarePhilosophy
                                ,px.ProfessionalInterest
                                ,px.PrimaryEmailAddress
                                ,px.MedicalSchoolNation
                                ,px.YearsSinceMedicalSchoolGraduation
                                ,px.HasDisplayImage
                                ,px.HasElectronicMedicalRecords
                                ,px.HasElectronicPrescription
                                ,px.AcceptsNewPatients
                                ,px.YearlySearchVolume
                                ,px.ProviderProfileViewOneYear
                                ,px.PatientExperienceSurveyOverallScore
                                ,px.PatientExperienceSurveyOverallStarValue
                                ,px.PatientExperienceSurveyOverallCount
                                ,px.ProviderBiography
								,px.ProviderURL
                                ,px.ProductGroupCode
                                ,px.SponsorCode
                                ,px.ProductCode
                                ,px.FacilityCode
                                ,px.ProviderLegacyKey
                                ,px.DisplayImage
                                ,px.SurveyResponse
                                ,px.SurveyResponseDate
                                ,px.IsActive
                                ,px.UpdatedDate
                                ,px.UpdatedSource
                                ,px.Title
                                ,px.CityStateAll
                                ,px.DisplayPatientExperienceSurveyOverallScore
                                ,px.DisplayStatusCode
                                ,px.SubStatusCode
                                ,px.DuplicateProviderCode
                                ,px.DeactivationReason
								,px.PatientVolume
								,px.HasMalpracticeState
								,px.ProcedureCount
								,px.ConditionCount
                                ,px.AvailabilityStatement
								,px.HasOar	
								,px.IsMMPUser		
								,px.HasAboutMe	
                                ,px.SearchBoostSatisfaction
                                ,px.SearchBoostAccessibility	
								,px.isPCPCalculated			
								,px.FAFBoostSatisfaction
								,px.FAFBoostSancMalp
								,px.FFDisplaySpecialty
								,px.FFPESBoost
								,px.FFMalMultiHQ
								,px.FFMalMulti
								,px.ProviderSubTypeCode
							from #ProvUpdates px
							where not exists (select 1 from Show.SOLRProvider x where x.ProviderID = px.ProviderID);	


        UPDATE		T
		SET			ProviderLegacyKey = S.LegacyKey
		--SELECT	*
		FROM		Show.SOLRProvider T
		INNER JOIN	#BatchProcess P
					ON P.ProviderId = T.ProviderId
		INNER JOIN	base.ProviderLegacyKeys S
					ON T.ProviderId = S.ProviderId

		IF OBJECT_ID('tempdb..#TempDeleteDuplicates') IS NOT NULL DROP TABLE #TempDeleteDuplicates
		SELECT	SOLRPRoviderID, ProviderId
		INTO	#TempDeleteDuplicates
		FROM(
			SELECT	SOLRPRoviderID
					,ProviderId
					,ProviderCode
					,ROW_NUMBER()OVER(PARTITION BY ProviderCode ORDER BY CASE WHEN sponsorshipXML IS NOT NULL THEN 1 ELSE 9 END DESC, DisplayStatusCode, ProviderTypeGroup DESC, SOLRPRoviderID) AS SequenceId
			FROM    Show.SOLRProvider
		)X
		WHERE	SequenceId > 1
		
		DELETE Show.SOLRProvider WHERE SOLRPRoviderID IN (SELECT SOLRPRoviderID FROM #TempDeleteDuplicates)
		
		UPDATE		T
		SET			DateOfFirstLoad = S.LastUpdateDate
		FROM		Show.SOLRProvider T
		INNER JOIN	#BatchProcess P
					ON P.ProviderId = T.ProviderId
		INNER JOIN	Base.Provider S ON S.ProviderID = T.ProviderID

		UPDATE		T
		SET			SourceUpdate = S.SourceName
					,SourceUpdateDateTime = S.LastUpdateDateTime
		FROM		Show.SOLRProvider T
		INNER JOIN	#BatchProcess P
					ON P.ProviderId = T.ProviderId
		INNER JOIN	Show.ProviderSourceUpdate S ON S.ProviderID = T.ProviderID

		UPDATE S SET AcceptsNewPatients = 1
		FROM		Show.SOLRProvider S
		INNER JOIN	Mid.Provider M ON M.ProviderID = S.ProviderID
		WHERE		M.acceptsnewpatients = 1 AND ISNULL(S.AcceptsNewPatients,0) = 0

		UPDATE		S SET SuppressSurvey = CASE WHEN X.ProviderID IS NOT NULL THEN 1 ELSE 0 END
		FROM		#BatchProcess B
		INNER JOIN	Show.SOLRProvider S ON S.ProviderID = B.ProviderID
		LEFT JOIN (SELECT DISTINCT ProviderId FROM ODS1Stage.Base.ProviderSurveySuppression) X ON X.ProviderID = B.ProviderID

		UPDATE		S SET IsBoardActionEligible = CASE WHEN X.ProviderID IS NOT NULL THEN 1 ELSE 0 END
		FROM		#BatchProcess B
		INNER JOIN	Show.SOLRProvider S ON S.ProviderID = B.ProviderID
		LEFT JOIN	#ProviderIsBoardEligible X ON X.ProviderID = B.ProviderID



-- ########### 3. Show_spuUpdateSOLRProviderClientCertificationXml #######################################################################################
CREATE TABLE #ClientCertsXml (SOLRProviderID INT NOT NULL , certs XML NULL,CertsCount SMALLINT, DedupeRank TINYINT NOT NULL,PRIMARY KEY (SOLRProviderID,DedupeRank DESC));

		INSERT INTO #ClientCertsXml
		        ( SOLRProviderID
		        , certs
		        , CertsCount
				, DedupeRank
		        )
		SELECT prv.SOLRProviderID,
			CASE WHEN client.certs.value('count(cSpnL/cSpn/cSpcL/cSpC)', 'int')>0 THEN client.certs END,		
			client.certs.value('count(cSpnL/cSpn/cSpcL/cSpC)', 'int') AS CertsCount,
			ROW_NUMBER() OVER (PARTITION BY prv.SOLRProviderID ORDER BY client.certs.value('count(cSpnL/cSpn/cSpcL/cSpC)', 'int') DESC)
		-- For each provider, build the cert xml. Return NULL where no certs.
		FROM 
        (
            select DISTINCT SOLRProviderID, ProviderCode FROM #ClientProviders) AS prv		 
		    OUTER APPLY 
            (
			    SELECT SUBSTRING(cp.SourceCode,3,50) AS spnCd,
		        (
                    select pc.cSpCd, pc.cSpY, pc.caCd, pc.caD, pc.cbCd, pc.cbD, pc.csCd, pc.csD
			        FROM scdghcorp.ProviderCertification as pc
			        WHERE pc.ProviderCode = prv.ProviderCode
                        and (pc.cSpCd is not null or pc.cSpY is not null or pc.caCd is not null or pc.caD is not null or pc.cbCd is not null or pc.cbD is not null or pc.csCd is not null or pc.csD is not null)
                    order BY pc.cSpCd, pc.cSpY, pc.caCd, pc.caD, pc.cbCd, pc.cbD, pc.csCd, pc.csD
			        FOR XML RAW('cSpC'), ELEMENTS, TYPE
		        ) AS cSpcL 
		        FROM #ClientProviders AS cp 
		        WHERE cp.SOLRProviderID=prv.SOLRProviderID
		        ORDER BY cp.SourceCode
		        FOR XML RAW('cSpn'),ROOT('cSpnL'), ELEMENTS, TYPE
		  ) AS client (Certs);	

UPDATE p SET p.ClientCertificationXML=x.Certs
			FROM Show.SOLRProvider AS p
			JOIN #ClientCertsXml AS x ON x.SOLRProviderID = p.SOLRProviderID
			WHERE x.DedupeRank=1;


-- ########### 4. Update Date of Birth #########################################################################################

UPDATE	Show.SOLRProvider SET DateOfBirth = NULL WHERE YEAR(DateOfBirth) = 1900

-- ########### 5. Mid_spuSuppressSurveyFlag ################################################################################################
BEGIN
			--This section added for TFS#41643							
			update sp set sp.SuppressSurvey = 1
			--select distinct a.ProviderID
			from Base.ProviderToSpecialty as a with (nolock)
					inner join Base.Specialty as b on b.SpecialtyID = a.SpecialtyID
					inner join Base.SpecialtyGroupToSpecialty c on c.SpecialtyID = a.SpecialtyID
					inner join Base.SpecialtyGroup d on d.SpecialtyGroupID = c.SpecialtyGroupID
					inner join Show.SOLRProvider sp on sp.ProviderID = a.ProviderID
			where d.SpecialtyGroupCode in ('NPHR', 'PNPH')
				and isnull(sp.SuppressSurvey,0) = 0
		END
				
		update a 
		set a.SuppressSurvey = 0
		--select SuppressSurvey
		from Show.SOLRProvider a with (nolock)
			join Show.SOLRProviderDelta b on b.ProviderID = a.ProviderID
		where a.SuppressSurvey = 1
						
		update sp set sp.SuppressSurvey = 1
		--select SuppressSurvey           
		from  Show.SOLRProvider sp
		join Show.SOLRProviderDelta b on b.ProviderID = sp.ProviderID
		inner join Base.ProviderSurveySuppression ps on sp.ProviderID =  ps.ProviderID  

		-- Suppress Surveys for Providers with Revoked, SurrENDered, or SuspENDed Licenses. 	
		update sp set sp.SuppressSurvey = 1   
		--select sp.ProviderID, sp.SuppressSurvey          
		from  Show.SOLRProvider sp  
		join Show.SOLRProviderDelta b on b.ProviderID = sp.ProviderID
		join (
			select distinct p.ProviderID
			from Base.Provider p with(nolock)
			join Show.SOLRProviderDelta b on b.ProviderID = p.ProviderID
			join Base.ProviderToSubStatus ap with(nolock) on p.ProviderID = ap.ProviderID
			join Base.SubStatus ss with(nolock) on ap.SubStatusID= ss.SubStatusID
			where ss.SubStatusCode in ('B','L') and ap.HierarchyRank = 1
		) x on x.ProviderID = sp.ProviderID

	-- Unsuppress Surveys for Nephrologists who are sponsored by a client other than Fresenius
	update sp
		set SuppressSurvey = 0
	--select SuppressSurvey, *
	from Mid.ProviderSponsorship				ps
		join Show.SOLRProvider				sp on ps.ProviderCode = sp.ProviderCode
		join Base.ProviderToSpecialty			a with (nolock) on sp.ProviderID = a.ProviderID
		join Base.Specialty					b on b.SpecialtyID = a.SpecialtyID
		join Base.SpecialtyGroupToSpecialty	c on c.SpecialtyID = a.SpecialtyID
		join Base.SpecialtyGroup				d on d.SpecialtyGroupID = c.SpecialtyGroupID
	where d.SpecialtyGroupCode in ('NPHR', 'PNPH')
		and ps.ClientCode <> 'Fresen'
		and sp.SuppressSurvey = 1




-- ########### 6. hack_spuRemoveSuspecProviders ################################################################################################
--- Base.ProviderRemoval
delete sp
	from Base.ProviderRemoval pr
		join Show.SOLRProvider sp on sp.ProviderCode = pr.ProviderCode


-- ########### 7. Show_spuApplyProviderStatusBusinessRules ################################################################################################
--- Show.SOLRProviderDelta

-- Update Accepts New Patients based on SubStatusCode
	UPDATE a 
	SET a.AcceptsNewPatients = 0
	--select a.AcceptsNewPatients
	FROM Show.SOLRProvider a
		JOIN Show.SOLRProviderDelta b ON b.ProviderID = a.ProviderID
	WHERE a.SubStatusCode IN ('C','Y','A')
		AND a.AcceptsNewPatients != 0


-- ########## 8. UPDATE DisplayStatusCode ##########################################################################################################
--- Base.SubStatus
--- Base.DisplayStatus

UPDATE		P
				SET			DisplayStatusCode = DS.DisplayStatusCode
				FROM		Show.SOLRProvider P
				INNER JOIN	Base.SubStatus SS
							ON SS.SubStatusCode = P.SubStatusCode
				INNER JOIN	Base.DisplayStatus DS
							ON DS.DisplayStatusId = SS.DisplayStatusId
				WHERE		P.DisplayStatusCode != DS.DisplayStatusCode
							AND P.DisplayStatusCode = 'H'


-- ########## 9. UPDATE APIXML ##########################################################################################################

update show.SOLRProvider 
				set APIXML = REPLACE(CAST(APIXML AS VARCHAR(MAX)), '</apiL>','
				  <api>
					<clientCd>OASTEST</clientCd>
					<camCd>OASTEST_005</camCd>
				  </api>
				</apiL>'
				)
				where providercode in ('G92WN','yj754','XYLGDMH','2p2v2','2CJGY','XCWYN','E5B5Z','YJLPH')
					and CAST(APIXML AS VARCHAR(MAX)) not like '%OASTEST_005%'



-- ########## 10. Mid_spuProviderIsInClientMarketRefresh ##########################################################################################################

-- Get a list of providers that need to be checked 
		if object_id('tempdb..#Provider') is not null
		 begin
			drop table #Provider
		 end

		create table #Provider(
			ProviderID uniqueidentifier, 
			EDWBaseRecordID uniqueidentifier, 
			IsInClientMarket int default(0)
			)

		if @IsProviderDeltaProcessing = 0
		 begin
			-- This is not a batch, get all providers
			insert into #Provider (ProviderID, EDWBaseRecordID)
			select src.ProviderID, src.EDWBaseRecordID
			from Base.Provider as src
		 end
		else
		 begin
			-- This is a batch, just get the providers that are in the specified batch
			insert into #Provider (ProviderID, EDWBaseRecordID)
			select a.ProviderID, a.ProviderID
			from Snowflake.etl.ProviderDeltaProcessing as a
		 end

		create index temp on #Provider (ProviderID)
	
	-- update the temp table with the current value of IsInClientMarket. 
	-- If the provider is not found with these joins, the default value of 0 has already been added
	-- update the temp table with the current value of IsInClientMarket. 
	-- If the provider is not found with these joins, the default value of 0 has already been added
		update  #Provider
		set     IsInClientMarket = 1
		from    #Provider p
				join Base.ProviderToOffice pto on p.ProviderID = pto.ProviderID
				join Base.OfficeToAddress ota on pto.OfficeID = ota.OfficeID
				join Base.Address a on ota.AddressID = a.AddressID
				join Base.CityStatePostalCode csz on a.CityStatePostalCodeID = csz.CityStatePostalCodeID
				join Base.GeographicArea geo on (csz.City = geo.GeographicAreaValue1 and csz.State = geo.GeographicAreaValue2)
				join Mid.ClientMarket cm on geo.GeographicAreaCode = cm.GeographicAreaCode
				join Base.ProviderToSpecialty pts on p.ProviderID = pts.ProviderID
				join Base.SpecialtyGroupToSpecialty sgs on pts.SpecialtyID = sgs.SpecialtyID
				join Base.SpecialtyGroup sg on sgs.SpecialtyGroupID = sg.SpecialtyGroupID and cm.LineOfServiceCode = sg.SpecialtyGroupCode
		where	pts.IsSearchable = 1;

		update  #Provider
		set     IsInClientMarket = 1
		from    #Provider p
				join Base.ProviderToOffice pto on p.ProviderID = pto.ProviderID
				join Base.OfficeToAddress ota on pto.OfficeID = ota.OfficeID
				join Base.Address a on ota.AddressID = a.AddressID
				join Base.CityStatePostalCode csz on a.CityStatePostalCodeID = csz.CityStatePostalCodeID
				join Base.GeographicArea geo on  (csz.PostalCode = geo.GeographicAreaValue1 and geo.GeographicAreaValue2 IS NULL)
				join Mid.ClientMarket cm on geo.GeographicAreaCode = cm.GeographicAreaCode
				join Base.ProviderToSpecialty pts on p.ProviderID = pts.ProviderID
				join Base.SpecialtyGroupToSpecialty sgs on pts.SpecialtyID = sgs.SpecialtyID
				join Base.SpecialtyGroup sg on sgs.SpecialtyGroupID = sg.SpecialtyGroupID and cm.LineOfServiceCode = sg.SpecialtyGroupCode
		where	pts.IsSearchable = 1 and
				p.IsInClientMarket = 0;
		

update Show.SOLRProvider
		 set IsInClientMarket = p1.IsInClientMarket
		 output inserted.ProviderID into #Updates(ProviderID)
		 from
			#Provider p1 join
			Show.SOLRProvider p2 on
				p1.ProviderID = p2.ProviderID
		 where
			p1.IsInClientMarket <> p2.IsInClientMarket


-- ########## 11. UPDATE AcceptsNewPatients ################################################################################################################
--- Base.Provider

UPDATE		S 
		SET			S.AcceptsNewPatients =  1
		FROM		Show.SOLRProvider S
		INNER JOIN	Base.Provider P ON P.Providerid = S.ProviderID
		WHERE		ISNULL(S.ACCEPTSNEWPATIENTS,0) != P.AcceptsNewPatients


-- ########## 12. etl_spuCheckFinalResults #################################################################################################################

IF OBJECT_ID('tempdb..#tempMAPProvidersClients') IS NOT NULL DROP TABLE #tempMAPProvidersClients
		SELECT DISTINCT *
		INTO	#tempMAPProvidersClients
		FROM(
				SELECT		ProviderId, ProviderCode, SponsorCode/*, SponsorshipXML, SearchSponsorshipXML, PracticeOfficeXML*/
							,T3.Loc.query('./Type/.').value('.','varchar(20)') AS DisplayType
							,T3.Loc.query('./cd/.').value('.','varchar(20)') AS PracticeCode
							,ot.Loc.query('./cd/.').value('.','varchar(20)') AS OfficeCode
							,ot.Loc.query('./phoneL/phone/ph/.').value('.','varchar(20)') AS PhoneNumber
							,ot.Loc.query('./phoneL/phone/phTyp/.').value('.','varchar(20)') AS PhoneType
				FROM		Show.SOLRProvider with(nolock) 
				CROSS APPLY SponsorshipXML.nodes('sponsorL/sponsor/dispL/disp') AS T3(Loc)
				CROSS APPLY T3.Loc.nodes('./offL/off') AS ot(Loc)
				WHERE		ProductCode = 'MAP' 
				--AND SPONSORCODE  = 'SHCS' AND PROVIDERCODE = '2MYBR'
		)X

UPDATE		P
			SET			SponsorshipXML = null
						,SearchSponsorshipXML = null
			FROM		Show.SOLRprovider P 
			LEFT JOIN	#tempMAPProvidersClients X
						ON X.ProviderId = P.ProviderId
			WHERE		ProductCode = 'MAP' 
						AND PracticeOfficeXML IS NOT NULL
						AND(
							X.ProviderId IS NULL
							OR LEN(PhoneNumber) = 0
						)
						AND P.DisplayStatusCode != 'H'
						AND SponsorshipXML IS NOT NULL

update p set DisplayStatusCode = 'H'
			FROM		Show.SOLRprovider P 
			LEFT JOIN	#tempMAPProvidersClients X
						ON X.ProviderId = P.ProviderId
			WHERE		ProductCode = 'MAP' AND PracticeOfficeXML IS NOT NULL
						AND(
							X.ProviderId IS NULL
							OR LEN(PhoneNumber) = 0
						)
						AND P.DisplayStatusCode != 'H'


-- ############ 13. UPDATE DisplayStatusCode #########################################################################################################

update ods1stage.Show.SOLRProvider 
		set DisplayStatusCode = 'A'
		WHERE DisplayStatusCode = 'H' AND SubStatusCode = '1'