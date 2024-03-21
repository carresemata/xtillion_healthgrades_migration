-- hack_spuMAPFreeze


-- 4. Show_spuSOLRProviderGenerateFromMid


IF OBJECT_ID('tempdb..#ProvUpdates') IS NOT NULL DROP TABLE #ProvUpdates
		SELECT	TOP 0 [ProviderID], [ProviderCode], [ProviderLegacyKey], [ProviderTypeID], [ProviderTypeGroup], [FirstName], [MiddleName], [LastName], [Suffix], [Degree], [Gender], [NPI], [AMAID], [UPIN], [MedicareID], [DEANumber], [TaxIDNumber], [DateOfBirth], [PlaceOfBirth], [CarePhilosophy], [ProfessionalInterest], [PrimaryEmailAddress], [MedicalSchoolNation], [YearsSinceMedicalSchoolGraduation], [HasDisplayImage], [DisplayImage], [HasElectronicMedicalRecords], [HasElectronicPrescription], [AcceptsNewPatients], [YearlySearchVolume], [ProviderProfileViewOneYear], [PatientExperienceSurveyOverallScore], [PatientExperienceSurveyOverallStarValue], [PatientExperienceSurveyOverallCount], [ProviderBiography], [ProviderURL], [DisplayStatusCode], [SubStatusCode], [DuplicateProviderCode], [ProductGroupCode], [SponsorCode], [ProductCode], [FacilityCode], [SurveyResponse], [SurveyResponseDate], [HasMalpracticeState], [ProcedureCount], [ConditionCount], [IsActive], [UpdatedDate], [UpdatedSource], [Title], [CityStateAll], [DisplayPatientExperienceSurveyOverallScore], [DeactivationReason], [PatientVolume], [AvailabilityStatement], [HasOAR], [IsMMPUser], [HasAboutMe], [SearchBoostSatisfaction], [SearchBoostAccessibility], [IsPCPCalculated], [FAFBoostSatisfaction], [FAFBoostSancMalp], [FFDisplaySpecialty], [FFPESBoost], [FFMalMultiHQ], [FFMalMulti], [ProviderSubTypeCode]
		INTO	#ProvUpdates
		FROM	Show.SOLRProvider
        CREATE INDEX ix_ProvUpdates_ProviderID ON #ProvUpdates (ProviderID)	

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

-- 1. etl_spuMidProviderEntityRefresh
--- Base.SubStatus
--- Base.DisplayStatus
--- Base.Provider

UPDATE	Show.SOLRProvider SET DateOfBirth = NULL WHERE YEAR(DateOfBirth) = 1900

-- 2. hack_spuRemoveSuspecProviders
--- Base.ProviderRemoval
delete sp
	from Base.ProviderRemoval pr
		join Show.SOLRProvider sp on sp.ProviderCode = pr.ProviderCode


-- 3. Show.spuApplyProviderStatusBusinessRules
--- Show.SOLRProviderDelta

-- Update Accepts New Patients based on SubStatusCode
	UPDATE a 
	SET a.AcceptsNewPatients = 0
	--select a.AcceptsNewPatients
	FROM Show.SOLRProvider a
		JOIN Show.SOLRProviderDelta b ON b.ProviderID = a.ProviderID
	WHERE a.SubStatusCode IN ('C','Y','A')
		AND a.AcceptsNewPatients != 0

-- 1. etl_spuMidProviderEntityRefresh
UPDATE		P
				SET			DisplayStatusCode = DS.DisplayStatusCode
				FROM		Show.SOLRProvider P
				INNER JOIN	Base.SubStatus SS
							ON SS.SubStatusCode = P.SubStatusCode
				INNER JOIN	Base.DisplayStatus DS
							ON DS.DisplayStatusId = SS.DisplayStatusId
				WHERE		P.DisplayStatusCode != DS.DisplayStatusCode
							AND P.DisplayStatusCode = 'H'


IF @RefreshNonProvider = 1		
BEGIN
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
END

UPDATE		S 
		SET			S.AcceptsNewPatients =  1
		FROM		Show.SOLRProvider S
		INNER JOIN	Base.Provider P ON P.Providerid = S.ProviderID
		WHERE		ISNULL(S.ACCEPTSNEWPATIENTS,0) != P.AcceptsNewPatients

update ods1stage.Show.SOLRProvider 
		set DisplayStatusCode = 'A'
		WHERE DisplayStatusCode = 'H' AND SubStatusCode = '1'

