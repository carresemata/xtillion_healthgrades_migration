IF OBJECT_ID('tempdb..#BatchProcess') IS NOT NULL DROP TABLE #BatchProcess;
	SELECT DISTINCT FacilityID
		,NULL AS BatchNumber
	INTO #BatchProcess
	FROM Show.SOLRFacilityDelta
	WHERE StartDeltaProcessDate IS NULL
		AND EndDeltaProcessDate IS NULL
		AND SolrDeltaTypeCode = 1 --INSERT/UPDATEs
		AND MidDeltaProcessComplete = 1;--this will indicate the Mid TABLEs have been refreshed with the Updated data
		
	IF OBJECT_ID('tempdb..#FacilityAddressDetail') IS NOT NULL DROP TABLE #FacilityAddressDetail;

	SELECT f.FacilityID,
			case when a.Suite is not null then concat(a.AddressLine1, ' ', a.Suite) else a.AddressLine1 end AS Address,
			NULL AS AddressSuite,
			cspc.City AS City,
			cspc.State AS State,
			cspc.PostalCode AS ZipCode,
			a.Latitude,
			a.Longitude,
			a.TimeZone
	INTO #FacilityAddressDetail
	FROM Base.Facility f
	JOIN Base.FacilityToAddress fa ON fa.FacilityID = f.FacilityID
	JOIN Base.Address a ON a.AddressID = fa.AddressID
	JOIN Base.CityStatePostalCode cspc ON cspc.CityStatePostalCodeID = a.CityStatePostalCodeID
	JOIN #BatchProcess bp on f.FacilityID = bp.FacilityID

	--SET the records a batch number based on a batch size we are SETting
	DECLARE @batchNumberMin INT;
	DECLARE @batchNumberMax INT;
	DECLARE @batchSize FLOAT;
	DECLARE @sql VARCHAR(MAX);

	SET @batchSize = 100000;--THIS IS THE BATCH SIZE WE ARE PROCESSING... 100K SEEMS TO BE THE FASTEST WITHOUT GOING OVERBOARD
	SET @batchNumberMin = 1;

	SELECT @batchNumberMax = CEILING(COUNT(*) / @batchSize)
	FROM #BatchProcess;

	WHILE @batchNumberMin <= @batchNumberMax
	BEGIN
		SET @sql = '
				UPDATE	a
				SET		a.BatchNumber = ' + CAST(@batchNumberMin AS VARCHAR(MAX)) + '
				--SELECT *
				FROM	#BatchProcess a
				JOIN 
				(
					SELECT	TOP ' + CAST(@batchSize AS VARCHAR(MAX)) + ' FacilityID
					FROM	#BatchProcess
					WHERE	BatchNumber IS NULL
				)b ON (a.FacilityID = b.FacilityID)
				';

		EXEC (@sql);

		SET @batchNumberMin = @batchNumberMin + 1;
	END;

	CREATE INDEX ix_Mid_FacilityID ON #BatchProcess (FacilityID);
	CREATE INDEX ix_Mid_BatchNumber ON #BatchProcess (BatchNumber);
		
	DECLARE @batchProcessMin INT;
	DECLARE @batchProcessMax INT;

	SET @batchProcessMin = 1;

	SELECT @batchProcessMax = MAX(BatchNumber)
	FROM #BatchProcess;

	PRINT 'Process Start';
	PRINT GETDATE();
	
	IF OBJECT_ID('tempdb..#SOLRFacility') IS NOT NULL DROP TABLE #SOLRFacility;
	SELECT	TOP 0 *
	INTO	#SOLRFacility
	FROM	Show.SOLRFacility

	WHILE @batchProcessMin <= @batchProcessMax
	BEGIN
		IF OBJECT_ID('tempdb..#BatchInsertUpdateProcess') IS NOT NULL DROP TABLE #BatchInsertUpdateProcess;

		SELECT DISTINCT FacilityID
		INTO #BatchInsertUpdateProcess
		FROM #BatchProcess
		WHERE BatchNumber = @batchProcessMin;

		CREATE INDEX ix_Mid_FacilityID ON #BatchInsertUpdateProcess (FacilityID);

		IF OBJECT_ID('tempdb..#ParentChild') IS NOT NULL DROP TABLE #ParentChild;

		SELECT a.FacilityIDParent
			,a.FacilityIDChild
			,b.Name AS ChildFacilityName
			,1 AS CurrentMerge
		INTO #ParentChild
		FROM ERMART1.Facility.FacilityParentChild a
		JOIN ERMART1.Facility.Facility b ON a.FacilityIDChild = b.FacilityID
		WHERE a.IsMaxYear = 1
			AND b.IsClosed = 0
		
		UNION
		
		SELECT a.FacilityIDParent
			,a.FacilityIDChild
			,b.Name AS ChildFacilityName
			,0 AS CurrentMerge
		FROM ERMART1.Facility.FacilityParentChild a
		JOIN ERMART1.Facility.Facility b ON (a.FacilityIDChild = b.FacilityID)
		WHERE a.IsMaxYear = 0
			AND b.IsClosed = 0;

		INSERT INTO #SOLRFacility([FacilityID], [LegacyKey], [LegacyKey8], [FacilityCode], [FacilityName], [FacilityType], [FacilityTypeCode], [FacilitySearchType], [Accreditation], [AccreditationDescription], [TreatmentSchedules], [PhoneNumber], [AdditionalTransportationInformation], [AfterHoursPhoneNumber], [ClosedHolidaysInformation], [CommunityActivitiesInformation], [CommunityOutreachProgramInformation], [CommunitySupportInformation], [FacilityDescription], [EmergencyAfterHoursPhoneNumber], [FoundationInformation], [HealthPlanInformation], [IsMedicaidAccepted], [IsMedicareAccepted], [IsTeaching], [LanguageInformation], [MedicalServicesInformation], [MissionStatement], [OfficeCloseTime], [OfficeOpenTime], [FacilityHoursXML], [OnsiteGuestServicesInformation], [OtherEducationAndTrainingInformation], [OtherServicesInformation], [OwnershipType], [ParkingInstructionsInformation], [PaymentPolicyInformation], [ProfessionalAffiliationInformation], [PublicTransportationInformation], [RegionalRelationshipInformation], [ReligiousAffiliationInformation], [SpecialProgramsInformation], [SurroundingAreaInformation], [TeachingProgramsInformation], [TollFreePhoneNumber], [TransplantCapabilitiesInformation], [VisitingHoursInformation], [VolunteerInformation], [YearEstablished], [HospitalAffiliationInformation], [PhysicianCallCenterPhoneNumber], [OverallHospitalStar], [ClientCode], [ProductCode], [ProviderCount], [AwardsInformation], [AwardCount], [ProcedureCount], [FiveStarProcedureCount], [ResidencyProgApproval], [MiscellaneousInformation], [AppointmentInformation], [VisitingHoursMonday], [VisitingHoursTuesday], [VisitingHoursWednesday], [VisitingHoursThursday], [VisitingHoursFriday], [VisitingHoursSaturday], [VisitingHoursSunday], [Website], [ForeignObjectLeftPercent], [AddressXML], [AwardXML], [ServiceLineXML], [PatientSatisfactionXML], [TopTenProcedureXML], [TransplantRatingsXML], [DistinctionXML], [PatientCareXML], [ReadmissionRateXML], [TimelyAndEffectiveCareXML], [PatientSafetyXML], [TraumaLevelXML], [SponsorshipXML], [AffiliationXML], [LeadershipXML], [AwardAchievementXML], [FacilityURL], [FacilityImagePath], [PatientSatisfaction], [IsPDC], [OverallPatientSafety], [UpdatedDate], [UpdatedSource], [LanguageXML], [ServiceXML])
		SELECT		fac.FacilityID
					,fac.LegacyKey
					,SUBSTRING(fac.LegacyKey, 5, 8) AS LegacyKey8
					,fac.FacilityCode
					, case when fac.FacilityTypeCode = 'HGPH' and charindex(concat(' ', fad.City, ', ', fad.State, ' ') , concat(ltrim(rtrim(fac.FacilityName)), ' ')) = 0 then concat(ltrim(rtrim(fac.FacilityName)), ' in ', fad.City, ', ', fad.State) else ltrim(rtrim(fac.FacilityName)) end as FacilityName
					,fac.FacilityType
					,fac.FacilityTypeCode
					,fac.FacilitySearchType
					,fac.Accreditation
					,fac.AccreditationDescription
					,fac.TreatmentSchedules
					,fac.PhoneNumber
					,fac.AdditionalTransportationInformation
					,fac.AfterHoursPhoneNumber
					,fac.ClosedHolidaysInformation
					,fac.CommunityActivitiesInformation
					,fac.CommunityOutreachProgramInformation
					,fac.CommunitySupportInformation
					,fac.FacilityDescription
					,fac.EmergencyAfterHoursPhoneNumber
					,fac.FoundationInformation
					,fac.HealthPlanInformation
					,fac.IsMedicaidAccepted
					,fac.IsMedicareAccepted
					,fac.IsTeaching
					,fac.LanguageInformation
					,fac.MedicalServicesInformation
					,fac.MissionStatement
					,fac.OfficeCloseTime
					,fac.OfficeOpenTime
					,(
						SELECT c.DaysOfWeekDescription AS day
							,c.SortOrder AS dispOrder
							,b.FacilityHoursOpeningTime AS start
							,b.FacilityHoursClosingTime AS [end]
							,b.FacilityIsClosed AS closed
							,b.FacilityIsOpen24Hours AS open24Hrs
						FROM Base.Facility a
						JOIN base.facilityHours b ON a.FacilityID = b.FacilityID
						JOIN Base.DaysOfWeek c ON b.DaysOfWeekID = c.DaysOfWeekID
						WHERE a.FacilityID = fac.FacilityId
						ORDER BY a.FacilityId
							,c.SortOrder
						FOR XML RAW('hours')
							,ELEMENTS
							,ROOT('hoursL')
							,TYPE
						) AS FacilityHoursXML
					,fac.OnsiteGuestServicesInformation
					,fac.OtherEducationAndTrainingInformation
					,fac.OtherServicesInformation
					,fac.OwnershipType
					,fac.ParkingInstructionsInformation
					,fac.PaymentPolicyInformation
					,fac.ProfessionalAffiliationInformation
					,fac.PublicTransportationInformation
					,fac.RegionalRelationshipInformation
					,fac.ReligiousAffiliationInformation
					,fac.SpecialProgramsInformation
					,fac.SurroundingAreaInformation
					,fac.TeachingProgramsInformation
					,fac.TollFreePhoneNumber
					,fac.TransplantCapabilitiesInformation
					,fac.VisitingHoursInformation
					,fac.VolunteerInformation
					,fac.YearEstablished
					,fac.HospitalAffiliationInformation
					,fac.PhysicianCallCenterPhoneNumber
					,fac.OverallHospitalStar
					,fac.ClientCode
					,fac.ProductCode
					,fac.ProviderCount
					,fac.AwardsInformation
					,fac.AwardCount
					,fac.ProcedureCount
					,fac.FiveStarProcedureCount
					,
					--(fac.ResPgmApprAma+', '+fac.ResPgmApprAoa+', '+fac.ResPgmApprAda) AS ResidencyProgApproval,
					REPLACE(LTRIM(COALESCE(fac.ResPgmApprAma, '')) + LTRIM(COALESCE(fac.ResPgmApprAoa, '')) + LTRIM(COALESCE(fac.ResPgmApprAda, '')), 'AA', 'A, A') AS ResidencyProgApproval
					,fac.MiscellaneousInformation
					,fac.AppointmentInformation
					,fac.VisitingHoursMonday
					,fac.VisitingHoursTuesday
					,fac.VisitingHoursWednesday
					,fac.VisitingHoursThursday
					,fac.VisitingHoursFriday
					,fac.VisitingHoursSaturday
					,fac.VisitingHoursSunday
					,fac.Website
					,fac.ForeignObjectLeftPercent
					,(
						SELECT DISTINCT u.Address AS ad1
							,u.City AS city
							,u.STATE AS st
							,u.Zipcode AS zip
							,CONVERT(DECIMAL(9, 6),u.Latitude) AS lat
							,CONVERT(DECIMAL(9, 6), u.Longitude) AS lng
							,u.TimeZone AS tzn
						FROM #FacilityAddressDetail u
						WHERE u.FacilityID = fac.FacilityId
						FOR XML RAW('addr')
							,ELEMENTS
							,ROOT('addrL')
							,TYPE
					) AS AddressXML
					,(
						SELECT y.AwardCode AS awCd
							,w.AwardCategoryCode AS awTypCd
							,y.AwardDisplayName AS awNm
							,x.Year AS awYr
							,x.DisplayDataYear AS dispAwYr
							,
							--a.IsMaxYear AS AwardIsMaxYear, 
							x.MergedData AS mrgd
							,x.IsBestInd AS isBest
							,x.Is50BestInd AS is50Best
							,x.isBestIndNonSEA AS isBestNonSEA
							,x.IsMaxYear AS isMaxYr
							,x.Ranking as awRnk
							,CASE WHEN x.AwardID = 11 THEN 1 ELSE 0 END as isStRnk
							,(
								SELECT DISTINCT v.MedicalTermCode AS specCd
									,v.AwardToMedicalTermOrder AS awToSpecSort
								FROM ERMart1.Facility.AwardToMedicalTerm v
								WHERE v.AwardName = x.AwardName
									AND v.AwardID = x.AwardID
									AND v.MedicalTermTypeCode = 'Specialty'
								FOR XML RAW('relatedSpec')
									,ELEMENTS
									,ROOT('relatedSpecL')
									,TYPE
								)
							,(
								SELECT DISTINCT f.FacilityCode AS facCd
									,p.ChildFacilityName AS facNm
								--pc.ChildState as st
								FROM #ParentChild p
								JOIN Base.Facility f ON p.FacilityIDChild = f.LegacyKey
								WHERE p.FacilityIDParent = x.FacilityID
									AND (
										(
											z.RatingSourceID = 1
											AND p.CurrentMerge = 0
											)
										OR (
											z.RatingSourceID = 1
											AND p.CurrentMerge = 1
											AND NOT EXISTS (
												SELECT *
												FROM #ParentChild pc
												WHERE pc.CurrentMerge = 0
													AND pc.FacilityIDChild = f.LegacyKey
												)
											)
										OR (
											z.RatingSourceID IS NULL
											AND p.CurrentMerge = 1
											)
										OR (
											z.RatingSourceID = 0
											AND p.CurrentMerge = 1
											)
										)
									AND p.FacilityIDChild IN (
										SELECT w.FacilityID
										FROM ERMART1.Facility.FacilityToAward w
										WHERE w.AwardName = x.AwardName
											AND ISNULL(w.SpecialtyCode, '') = ISNULL(x.SpecialtyCode, '')
											--AND w.IsMaxYear = 1
											AND w.MergedData = 1
											AND (
												-- Include PEDs child faclities for Labor and Delivery awards only.
												(
													LEFT(w.FacilityID, 4) = 'HGCH'
													AND w.SpecialtyCode = 'LAB'
													)
												OR (LEFT(w.FacilityID, 4) <> 'HGCH')
												)
										)
								ORDER BY p.ChildFacilityName
								FOR XML RAW('child')
									,ELEMENTS
									,ROOT('childL')
									,TYPE
								)
						-- SELECT *
						FROM ERMART1.Facility.FacilityToAward x
						JOIN Base.Award y ON x.AwardName = y.AwardName
						JOIN Base.AwardCategory w ON w.AwardCategoryID = y.AwardCategoryID
						LEFT JOIN ERMART1.Facility.ServiceLine z ON x.SpecialtyCode = z.ServiceLineID --WHERE x.AwardID = 10
						WHERE fac.LegacyKey = x.FacilityID
						AND (
							(
							LEFT(x.FacilityID, 4) = 'HGCH'
							AND x.SpecialtyCode = 'LAB'
							)
							OR (LEFT(x.FacilityID, 4) <> 'HGCH')
						)
						GROUP BY x.FacilityID
							,y.AwardCode
							,y.AwardDisplayName
							,x.DisplayDataYear
							,x.MergedData
							,x.IsBestInd
							,x.Is50BestInd
							,x.IsBestIndNonSEA
							,x.AwardID
							,x.SpecialtyCode
							,z.RatingSourceID
							,x.IsMaxYear
							,x.Ranking
							,CASE WHEN x.AwardID = 11 THEN 1 ELSE 0 END  
							,x.AwardName
							,w.AwardCategoryCode
							,x.Year
						FOR XML RAW('award')
							,ELEMENTS
							,ROOT('awardL')
							,TYPE
						) AS AwardXML


					,(
						SELECT qq.ServiceLineCode AS svcCd
							,qq.ZScore AS svcZScore
							,qq.ServiceLineDescription AS svcNm
							,qq.SurvivalStar AS svcLnRtg
							,qq.DataYear AS svcYr
							,qq.DisplayDataYear AS svcDispYr
							,qq.IsMaxYear AS isMaxYr
							,qq.RatingScorePercent AS qualPctScr
							,(
								SELECT zz.ProcedureCode AS pCd
									,b.ProcedureDescription AS pNm
									,b.RatingMethod AS rMth
									,CASE 
										WHEN z.ProcedureID = 'OB1'
											THEN 1
										END AS mcare
									,z.DataYear AS rYr
									,z.DisplayDataYear AS rDispYr
									,z.IsMaxYear AS isMaxYr
									,z.OverallSurvivalStar AS rStr
									,z.OverallRecovery30Star AS rStr30
									,-- z.OverallRecovery180Star as rStr180,
									z.CostStar AS chgStr
									,CASE 
										WHEN z.CostStar = 1
											THEN 'Higher Than Average'
										WHEN z.CostStar = 3
											THEN 'Average'
										WHEN z.CostStar = 5
											THEN 'Lower Than Average'
										END AS chgStrDisp
									,CAST(z.ActualCostValue AS VARCHAR(100)) AS cost
									,z.LengthOfStayStar AS losStr
									,CASE 
										WHEN z.LengthOfStayStar = 1
											THEN 'Longer Than Average'
										WHEN z.LengthOfStayStar = 3
											THEN 'Average'
										WHEN z.LengthOfStayStar = 5
											THEN 'Shorter Than Average'
										END AS losStrDisp
									,CAST(ROUND(z.ActualLengthOfStayValue, 1) AS VARCHAR(20)) AS los
									,z.Volume AS vol
									,CASE 
										WHEN b.RatingMethod = 'M'
											THEN CAST((z.ActualSurvivalPercentage) * 100 AS VARCHAR(10))
										WHEN b.RatingMethod = 'C'
											AND z.ProcedureID <> 'OB1'
											THEN CAST((z.ActualSurvivalPercentage * 100) AS VARCHAR(10))
										END AS actPct
									,CASE 
										WHEN b.RatingMethod = 'M'
											THEN CAST((z.ActualRecovery30Percentage) * 100 AS VARCHAR(10))
										WHEN b.RatingMethod = 'C'
											AND z.ProcedureID <> 'OB1'
											THEN CAST((z.ActualRecovery30Percentage * 100) AS VARCHAR(10))
										END AS actPct30
									,CASE 
										WHEN b.RatingMethod = 'M'
											THEN CAST((z.PredictedSurvivalPercentage) * 100 AS VARCHAR(10))
										WHEN b.RatingMethod = 'C'
											AND z.ProcedureID <> 'OB1'
											THEN CAST((z.PredictedSurvivalPercentage * 100) AS VARCHAR(10))
										END AS prdPct
									,CASE 
										WHEN b.RatingMethod = 'M'
											THEN CAST((z.PredictedRecovery30Percentage) * 100 AS VARCHAR(10))
										WHEN b.RatingMethod = 'C'
											AND z.ProcedureID <> 'OB1'
											THEN CAST((z.PredictedRecovery30Percentage * 100) AS VARCHAR(10))
										END AS prdPct30
									,CASE 
										WHEN z.ProcedureID = 'OB1'
											THEN (
													SELECT CSectionActualPercentage
													FROM ERMART1.Facility.FacilityToMaternityDetail zz
													WHERE FacilityID = z.FacilityID
														AND DataYear = z.DataYear
													)
										END AS cSectActPct
									,CASE 
										WHEN z.ProcedureID = 'OB1'
											THEN (
													SELECT CSectionNatlPercentage
													FROM ERMART1.Facility.FacilityToMaternityDetail qq
													WHERE FacilityID = z.FacilityID
														AND DataYear = z.DataYear
													)
										END AS cSectNatPct
									,CASE 
										WHEN z.ProcedureID = 'OB1'
											THEN (
													SELECT CSectionVolume
													FROM ERMART1.Facility.FacilityToMaternityDetail qq
													WHERE FacilityID = z.FacilityID
														AND DataYear = z.DataYear
													)
										END AS cSectVol
									,
									--VAGINAL DATA
									CASE 
										WHEN z.ProcedureID = 'OB1'
											THEN (
													SELECT VaginalActualPercentage
													FROM ERMART1.Facility.FacilityToMaternityDetail qq
													WHERE FacilityID = z.FacilityID
														AND DataYear = z.DataYear
													)
										END AS vagActPct
									,CASE 
										WHEN z.ProcedureID = 'OB1'
											THEN (
													SELECT VaginalNatlPercentage
													FROM ERMART1.Facility.FacilityToMaternityDetail qq
													WHERE FacilityID = z.FacilityID
														AND DataYear = z.DataYear
													)
										END AS vagNatPct
									,CASE 
										WHEN z.ProcedureID = 'OB1'
											THEN (
													SELECT VaginalVolume
													FROM ERMART1.Facility.FacilityToMaternityDetail qq
													WHERE FacilityID = z.FacilityID
														AND DataYear = z.DataYear
													)
										END AS vagVol
									,
									--NEWBORN	
									CASE 
										WHEN z.ProcedureID = 'OB1'
											THEN (
													SELECT NewbornSurvivalStar
													FROM ERMART1.Facility.FacilityToMaternityDetail qq
													WHERE FacilityID = z.FacilityID
														AND DataYear = z.DataYear
													)
										END AS nwbrnStr
									,CASE 
										WHEN z.ProcedureID = 'OB1'
											THEN (
													SELECT NewbornSurvivalStarDescription
													FROM ERMART1.Facility.FacilityToMaternityDetail qq
													WHERE FacilityID = z.FacilityID
														AND DataYear = z.DataYear
													)
										END AS nwbrnStrDesc
									,CONVERT(VARCHAR(20), CONVERT(DECIMAL(18, 15), z.WeightScore)) AS zScr
									,CASE 
										WHEN b.ProcedureID = 'OB1'
											THEN CAST(CONVERT(DECIMAL(30, 15), CONVERT(REAL, z.OverallSurvivalStar)) - CONVERT(DECIMAL(30, 15), CONVERT(REAL, z.WeightScore)) AS VARCHAR(50))
										WHEN b.RatingMethod = 'M'
											THEN CAST(CONVERT(DECIMAL(30, 15), CONVERT(REAL, z.WeightStar)) + CONVERT(DECIMAL(30, 15), CONVERT(REAL, z.WeightScore)) AS VARCHAR(50))
										WHEN b.RatingMethod = 'C'
											THEN CAST(CONVERT(DECIMAL(30, 15), CONVERT(REAL, z.OverallSurvivalStar)) + CONVERT(DECIMAL(30, 15), CONVERT(REAL, z.WeightScore)) AS VARCHAR(50))
										END AS pSort
									,CASE 
										WHEN b.RatingMethod = 'M'
											THEN CAST((p.ActualSurvivalPercentageNatl) * 100 AS VARCHAR(10))
										WHEN b.RatingMethod = 'C'
											THEN CAST((p.ActualSurvivalPercentageNatl * 100) AS VARCHAR(10))
										END AS actSurNatPer
									,CASE 
										WHEN b.RatingMethod = 'M'
											THEN CAST((p.PredictedSurvivalPercentageNatl) * 100 AS VARCHAR(10))
										WHEN b.RatingMethod = 'C'
											THEN CAST((p.PredictedSurvivalPercentageNatl * 100) AS VARCHAR(10))
										END AS predSurNatPer
									,p.OverallSurvivalStarNatl AS ovrAllSurNatStr
									,p.Survival30StarNatl AS SurNatStr30
									,
									--p.Survival180StarNatl AS SurNatStr180,
									p.AvgCasesNatl
									,p.AverageLengthOfStay AS losNatl
									,p.ChargeRange AS costNatl
									,(
										SELECT DISTINCT c1.STATE
											,c1.StateName AS fullState
											,AverageLengthOfStay AS stateLos
											,ChargeRange AS stateCost
										FROM ERMART1.Facility.StateNationalProcedureRatingsAverage z1
										JOIN ERMART1.Facility.[Procedure] b1 ON (z1.ProcedureID = b1.ProcedureID)
										JOIN ERMART1.Facility.ProcedureToServiceLine y1 ON (z1.ProcedureID = y1.ProcedureID)
										JOIN (
											SELECT MedicalTermCode AS ProcedureCode
												,a.LegacyKey
												,MedicalTermDescription1 AS ProcedureDescription
											FROM Base.MedicalTerm a
											JOIN Base.MedicalTermType b ON (a.MedicalTermTYpeID = b.MedicalTermTypeID)
											WHERE b.MedicalTermTypeCode = 'COHORT'
											) zz1 ON (z1.ProcedureID = zz1.LegacyKey)
										JOIN Base.STATE c1 ON z1.STATE = c1.STATE
										JOIN ERMART1.Facility.FacilityAddressDetail d1 ON d1.STATE = c1.STATE
										--WHERE  d1.FacilityID = 'HGST2539E6A6380033'		
										WHERE z1.DataYear = z.DataYear
											AND y1.ServiceLineID = y.ServiceLineID
											AND z1.ProcedureID = z.ProcedureID
											AND z1.RatingSource = z.RatingSourceID
											AND d1.FacilityID = z.FacilityID
										FOR XML RAW('stateAvg')
											,ELEMENTS
											,ROOT('stateAvgL')
											,TYPE
										)
									,
									-- SELECT * FROM ERMart1.Facility.ProcedureRatingsNationalAverage
									-- SELECT * FROM Ermart1.Facility.StateNationalProcedureRatingsAverage WHERE State = 'US'
									(
										SELECT z1.DataYear AS rYr
											,z1.DisplayDataYear AS rDispYr
											,z1.IsMaxYear AS isMaxYr
											,CASE 
												WHEN b1.RatingMethod = 'M'
													THEN CAST((z1.ActualSurvivalPercentage) * 100 AS VARCHAR(10))
												WHEN b1.RatingMethod = 'C'
													AND z1.ProcedureID <> 'OB1'
													THEN CAST((z1.ActualSurvivalPercentage * 100) AS VARCHAR(10))
												END AS actPct
											,CASE 
												WHEN b1.RatingMethod = 'M'
													THEN CAST((p1.ActualSurvivalPercentageNatl) * 100 AS VARCHAR(10))
												WHEN b1.RatingMethod = 'C'
													THEN CAST((p1.ActualSurvivalPercentageNatl * 100) AS VARCHAR(10))
												END AS actSurNatPer
										FROM ERMART1.Facility.FacilityToProcedureRating z1
										JOIN ERMART1.Facility.[Procedure] b1 ON (z1.ProcedureID = b1.ProcedureID)
										JOIN ERMART1.Facility.ProcedureToServiceLine y1 ON (z1.ProcedureID = y1.ProcedureID)
										JOIN ERMart1.Facility.ProcedureRatingsNationalAverage p1 ON (
												z1.ProcedureID = p1.ProcedureID
												AND z1.DataYear = p1.DataYear
												)
										JOIN (
											SELECT MedicalTermCode AS ProcedureCode
												,a.LegacyKey
												,MedicalTermDescription1 AS ProcedureDescription
											FROM Base.MedicalTerm a
											JOIN Base.MedicalTermType b ON (a.MedicalTermTYpeID = b.MedicalTermTypeID)
											WHERE b.MedicalTermTypeCode = 'COHORT'
											) zz1 ON (p1.ProcedureID = zz1.LegacyKey)
										WHERE --z.IsMaxYear = qq.IsMaxYear
											z1.FacilityID = z.FacilityID
											AND y1.ServiceLineID = y.ServiceLineID
											AND z1.ProcedureID = z.ProcedureID
											AND z1.RatingSourceID = z.RatingSourceID
										FOR XML RAW('rateTrend')
											,ELEMENTS
											,ROOT('rateTrendL')
											,TYPE
										)
									,(
										SELECT y1.AwardCode AS awCd
											,w1.AwardCategoryCode AS awTypCd
											,y1.AwardDisplayName AS awNm
											,x1.Year AS awYr
											,x1.DisplayDataYear AS dispAwYr
											,x1.MergedData AS mrgd
											,x1.IsBestInd AS isBest
											,x1.IsMaxYear AS isMaxYr
										FROM ERMART1.Facility.FacilityToAward x1
										JOIN Base.Award y1 ON x1.AwardName = y1.AwardName
										JOIN Base.AwardCategory w1 ON w1.AwardCategoryID = y1.AwardCategoryID
										JOIN ERMART1.Facility.ProcedureToAward u1 ON u1.SpecialtyCode = x1.SpecialtyCode
										--JOIN ERMART1.Facility.ServiceLine z1 ON u1.SpecialtyCode = z1.ServiceLineID
										WHERE x1.FacilityID = z.FacilityID
											AND u1.ProcedureID = y.ProcedureID
										GROUP BY x1.FacilityID
											,y1.AwardCode
											,y1.AwardDisplayName
											,x1.DisplayDataYear
											,x1.MergedData
											,x1.IsBestInd
											,x1.AwardID
											,x1.SpecialtyCode
											,x1.IsMaxYear
											,x1.AwardName
											,w1.AwardCategoryCode
											,x1.Year
										FOR XML RAW('RelatedAward')
											,ELEMENTS
											,ROOT('RelatedAwardL')
											,TYPE
										)
									,z.WeightStar AS wStr
									,z.RatingScorePercent AS qualPctScr
								
								FROM ERMART1.Facility.FacilityToProcedureRating z
								JOIN ERMART1.Facility.[Procedure] b ON (z.ProcedureID = b.ProcedureID)
								JOIN ERMART1.Facility.ProcedureToServiceLine y ON (z.ProcedureID = y.ProcedureID)
								JOIN ERMart1.Facility.ProcedureRatingsNationalAverage p ON (
										z.ProcedureID = p.ProcedureID
										AND z.DataYear = p.DataYear
										)
								JOIN (
									SELECT MedicalTermCode AS ProcedureCode
										,a.LegacyKey
										,MedicalTermDescription1 AS ProcedureDescription
									FROM Base.MedicalTerm a
									JOIN Base.MedicalTermType b ON (a.MedicalTermTYpeID = b.MedicalTermTypeID)
									WHERE b.MedicalTermTypeCode = 'COHORT'
									) zz ON (p.ProcedureID = zz.LegacyKey)
								WHERE z.IsMaxYear = qq.IsMaxYear
									AND z.FacilityID = qq.FacilityID
									AND 'SL' + y.ServiceLineID = qq.LegacyKey
									--and z.ProcedureID = qq.ProcedureID
									AND z.RatingSourceID = qq.RatingSourceID
								ORDER BY b.ProcedureDescription
								FOR XML RAW('proc')
									,ELEMENTS
									,ROOT('procL')
									,TYPE
								)









							,(
								--SELECT  ((SUM(z.OverallSurvivalStar) * SUM(z.OverallRecovery30Star)) + (0.5 * SUM(z.OverallSurvivalStar)) + SUM(z.OverallRecovery30Star))	
								SELECT AVG((z.OverallSurvivalStar * z.OverallRecovery30Star) + (0.5 * z.OverallSurvivalStar) + (z.OverallRecovery30Star)) + (COUNT(z.OverallSurvivalStar) + COUNT(z.OverallRecovery30Star)) * 0.25
								--SELECT  z.OverallSurvivalStar , z.OverallRecovery30Star
								FROM ERMART1.Facility.FacilityToProcedureRating z
								JOIN ERMART1.Facility.[Procedure] b ON (z.ProcedureID = b.ProcedureID)
								JOIN ERMART1.Facility.ProcedureToServiceLine y ON (z.ProcedureID = y.ProcedureID)
								JOIN (
									SELECT MedicalTermCode AS ProcedureCode
										,a.LegacyKey
										,MedicalTermDescription1 AS ProcedureDescription
									FROM Base.MedicalTerm a
									JOIN Base.MedicalTermType b ON (a.MedicalTermTYpeID = b.MedicalTermTypeID)
									WHERE b.MedicalTermTypeCode = 'COHORT'
									) zz ON (y.ProcedureID = zz.LegacyKey)
								WHERE z.FacilityID = qq.FacilityID
									AND z.IsMaxYear = qq.IsMaxYear
									AND 'SL' + y.ServiceLineID = qq.LegacyKey
									AND z.RatingSourceID = qq.RatingSourceID
									--WHERE		
									--		z.FacilityID = 'hgst55380596310001'
									--		and y.ServiceLineID = 'cvo'
									--		and z.IsMaxYear = 1
								) AS ratingsSortValue
						FROM (
							SELECT zz.FacilityID
								,zz.ProcedureID
								,zz.RatingSourceID
								,zz.DataYear AS ProcedureDataYear
								,zz.IsMaxYear
								,aa.ServiceLineCode
								,aa.ServiceLineDescription
								,aa.LegacyKey
								,vv.ZScore
								,
								--BECAUSE THE WAY MATERNITY CARE IS SET UP, THERE IS NOT DATA IN FacilityToServiceLineRating FOR MCA, IT IS ONE TO ONE WITH PROC OB1 to MCA... same thing
								CASE 
									WHEN zz.ProcedureID = 'OB1'
										THEN zz.OverallSurvivalStar
									ELSE vv.SurvivalStar
									END AS SurvivalStar
								,CASE 
									WHEN zz.ProcedureID = 'OB1'
										THEN zz.DataYear
									ELSE vv.DataYear
									END AS DataYear
								,CASE 
									WHEN zz.ProcedureID = 'OB1'
										THEN zz.DisplayDataYear
									ELSE vv.DisplayDataYear
									END AS DisplayDataYear
								,vv.RatingScorePercent
							-- SELECT *
							FROM ERMART1.Facility.FacilityToProcedureRating zz
							JOIN ERMART1.Facility.vwuFacilityHGDisplayProcedures yy ON (
									zz.ProcedureID = yy.ProcedureID
									AND zz.RatingSourceID = yy.RatingSourceID
									)
							JOIN ERMART1.Facility.ProcedureToServiceLine xx ON (yy.ProcedureID = xx.ProcedureID)
							JOIN ERMART1.Facility.ServiceLine ww ON (xx.ServiceLineID = ww.ServiceLineID)
							LEFT JOIN ERMART1.Facility.FacilityToServiceLineRating vv ON (
									ww.ServiceLineID = vv.ServiceLineID
									AND zz.FacilityID = vv.FacilityID
									AND vv.IsMaxYear = 1
									)
							JOIN (
								SELECT MedicalTermCode AS ServiceLineCode
									,a.LegacyKey
									,MedicalTermDescription1 AS ServiceLineDescription
								FROM Base.MedicalTerm a
								JOIN Base.MedicalTermType b ON (a.MedicalTermTYpeID = b.MedicalTermTypeID)
								WHERE b.MedicalTermTypeCode = 'SERVICELINE'
								) aa ON ('SL' + ww.ServiceLineID = aa.LegacyKey)
							WHERE zz.IsMaxYear = 1
								AND zz.FacilityID = fac.LegacyKey
							) qq
						GROUP BY qq.ServiceLineCode
							,qq.ZScore
							,qq.ServiceLineDescription
							,qq.SurvivalStar
							,qq.DataYear
							,qq.DisplayDataYear
							,qq.FacilityID
							,qq.RatingSourceID
							,qq.IsMaxYear
							,qq.LegacyKey
							,qq.RatingScorePercent
						ORDER BY qq.ServiceLineDescription
						FOR XML RAW('svcLn')
							,ELEMENTS
							,ROOT('svcLnL')
							,TYPE
						) AS ServiceLineXML



					,
					--(
					--SELECT	* FROM	ERMART1.dbo.facilityToProcessMeasure
					--) AS PatientCareXML
					(
						SELECT a.QuestionID AS queId
							,a.QuestionTextDisplay AS queTxt
							,a.NumberOfCompletedSurveys AS noOfSurv
							,a.SurveyResponseRatePercent AS surResRatePerc
							,a.AnswerID AS ansId
							,a.AnswerTextDisplay AS ansTxt
							,a.AnswerPercent AS ansPerc
							,a.Category AS cat
							,a.CategorySortID AS catSort
							,convert(int,c.Average) AS natAvg
						FROM ERMART1.Facility.FacilityToSurvey a
							LEFT JOIN ERMART1.PatientExperience.OPEAProviderToCohortRange b ON a.FacilityID = b.hgid 
							LEFT JOIN ERMART1.PatientExperience.OPEAAveragesByCohortRange c ON a.QuestionID = c.QuestionID AND b.cohortrange = c.cohortrange
						WHERE a.SurveyID = 1
							AND a.FacilityID = fac.LegacyKey
						FOR XML RAW('satis')
							,ELEMENTS
							,ROOT('satisL')
							,TYPE
						) AS PatientSatisfactionXML
					,(
						--SELECT	TOP 10 b.ProcedureDescription as procDesc 
						--FROM	ERMART1.Facility.FacilityToProcedureRating a
						--		JOIN ERMART1.Facility.[Procedure] b ON a.ProcedureID = b.ProcedureID
						--		JOIN ERMART1.Facility.HospitalCohort c ON a.ProcedureID = c.ProcedureID AND c.RatingSourceID = a.RatingSourceID
						--WHERE	IsMaxYear = 1
						--		and a.FacilityID = fac.LegacyKey
						--ORDER	BY Volume DESC,b.ProcedureDescription  
						--FOR XML RAW('topTenProc'), ELEMENTS, ROOT('topTenProcL'), TYPE 
						NULL
						) AS TopTenProcedureXML
					,(
						SELECT OrganType AS orgTypCd
							,OrganDesc AS orgDesc
							,MeasureIDDesc AS meaDesc
							,RatingsCode AS rateCd
							,RatingsCodeDesc AS rateCdDesc
						-- SELECT *
						FROM ERMART1.Facility.FacilityToOrganTransplantRatings a
						WHERE IsMaxYear = 1
							AND a.FacilityID = fac.LegacyKey
						FOR XML RAW('tran')
							,ELEMENTS
							,ROOT('tranL')
							,TYPE
						) AS TransplantRatingsXML
					,(
						SELECT a.CertificationDisplayName AS certNm
							,a.CertificationSourceDisplayName AS certSrcNm
							,a.CertificationSourceLongName AS certSrcLgNm
							,a.CertificationStartDate AS certStDt
							,a.CertificationEndDate AS certEndDt
						FROM ERMART1.Facility.FacilityToCertification a
						WHERE a.FacilityID = fac.LegacyKey
						FOR XML RAW('dist')
							,ELEMENTS
							,ROOT('distL')
							,TYPE
						) AS DistinctionXML
					,NULL AS PatientCareXML
					,(
						SELECT DISTINCT x.ConditionCode AS condCd
							,x.ConditionDisplayName AS condNm
							,x.MeasureCode AS measCd
							,x.MeasureDisplayName AS measNm
							,a.ScorePercent AS scPerc
							,a.SampleVolume AS sampVol
							,a.ComparisonNationalRate AS comprNat
							,b.ScorePercent AS natScPerc
							,x.ConditionCodeDisplayOrder AS condSort
							,x.MeasureCodeDisplayOrder AS measSort
						--, b.state, c.StateName as fullState
						FROM ERMart1.ref.ProcessMeasure x
						JOIN ERMART1.Facility.FacilityToProcessMeasures a ON a.ConditionCode = x.ConditionCode
							AND a.MeasureCode = x.MeasureCode
							AND a.FacilityID = fac.LegacyKey
						LEFT JOIN ERMART1.Facility.ProcessMeasureScore b ON x.ConditionCode = b.ConditionCode
							AND x.MeasureCode = b.MeasureCode
							AND b.STATE = 'US'
						--LEFT JOIN Base.State c ON b.state = c.state
						WHERE x.ConditionCode IN (
								'AMI'
								,'CHF'
								,'PNE'
								)
							AND x.MeasureDisplayName = '30-Day Readmission Rate'
							AND x.IsCurrent = 1
							AND x.IsDisplayed = 1
						ORDER BY x.ConditionCodeDisplayOrder
							,x.MeasureCodeDisplayOrder
						FOR XML RAW('reAdmi')
							,ELEMENTS
							,ROOT('reAdmiL')
							,TYPE
						) AS ReadmissionRateXML


					,(
						SELECT DISTINCT x.ConditionCode AS condCd
							,x.ConditionDisplayName AS condNm
							,x.MeasureCode AS measCd
							,x.MeasureDisplayName AS measNm
							,a.ScorePercent AS scPerc
							,a.SampleVolume AS sampVol
							,e.STATE
							,e.StateName AS fullState
							,d.ScorePercent AS stateScPerc
							,b.ScorePercent AS natScPerc
							,ConditionCodeDisplayOrder AS condSort
							,MeasureCodeDisplayOrder AS measSort
						FROM ERMart1.ref.ProcessMeasure x
						JOIN ERMART1.Facility.FacilityToProcessMeasures a ON a.ConditionCode = x.ConditionCode
							AND a.MeasureCode = x.MeasureCode
							AND a.FacilityID = fac.LegacyKey
						LEFT JOIN ERMART1.Facility.FacilityAddressDetail c ON c.FacilityID = fac.LegacyKey
						LEFT JOIN ERMART1.Facility.ProcessMeasureScore d ON x.ConditionCode = d.ConditionCode
							AND x.MeasureCode = d.MeasureCode
							AND d.STATE = c.STATE
						LEFT JOIN Base.STATE e ON e.STATE = c.STATE
						LEFT JOIN ERMART1.Facility.ProcessMeasureScore b ON x.ConditionCode = b.ConditionCode
							AND x.MeasureCode = b.MeasureCode
							AND b.STATE = 'US'
						WHERE x.ConditionCode IN (
								'AMI'
								,'PNE'
								,'SIP'
								,'CAS'
								,'CHF'
								,'IMM'
								)
							AND x.MeasureDisplayName <> '30-Day Readmission Rate'
							AND x.IsCurrent = 1
							AND x.IsDisplayed = 1
						ORDER BY x.ConditionCodeDisplayOrder
							,x.MeasureCodeDisplayOrder
						FOR XML RAW('effCare')
							,ELEMENTS
							,ROOT('effCareL')
							,TYPE
						) AS TimelyAndEffectiveCareXML
					,(
						SELECT b.DisplayRatingDescription AS rateDesc
							,a.RatingStar AS rateStr
							,EventCount AS evtCount
						FROM ERMART1.Facility.FacilityToRating a
						JOIN ERMART1.Facility.Rating b ON a.RatingID = b.RatingID
						WHERE a.FacilityID = fac.LegacyKey
							AND b.RatingCategoryId = 2
							AND a.IsMaxYear = 1
							AND b.RatingID <> 2
						ORDER BY b.RatingOrder
						FOR XML RAW('pSafe')
							,ELEMENTS
							,ROOT('pSafeL')
							,TYPE
						) AS PatientSafetyXML
					,(
						--TraumaLevel 
						SELECT AdultTraumaLevel AS aduTraLev
							,PediatricTraumaLevel AS pedTraLev
						FROM Mid.Facility a
						WHERE a.FacilityCode = fac.FacilityCode
							AND (
								AdultTraumaLevel IS NOT NULL
								OR PediatricTraumaLevel IS NOT NULL
								)
						FOR XML RAW('trauma')
							,ELEMENTS
							,ROOT('traumaL')
							,TYPE
						) AS TraumaLevelXML

                        
					,(
						--Sponsorship
						SELECT a.ProductCode AS prCd
							,a.ProductGroupCode AS prGrCd
							,(
								SELECT u.ClientCode AS spnCd
									,u.ClientName AS spnNm
									,(
										SELECT DISTINCT ClientFeatureCode AS featCd
											,d.ClientFeatureDescription AS featDesc
											,e.ClientFeatureValueCode AS featValCd
											,e.ClientFeatureValueDescription AS featValDesc
										FROM Base.ClientEntityToClientFeature a
										JOIN Base.EntityType b ON a.EntityTypeID = b.EntityTypeID
										JOIN Base.ClientFeatureToClientFeatureValue c ON a.ClientFeatureToClientFeatureValueID = c.ClientFeatureToClientFeatureValueID
										JOIN Base.ClientFeature d ON c.ClientFeatureID = d.ClientFeatureID
										JOIN Base.ClientFeatureValue e ON e.ClientFeatureValueID = c.ClientFeatureValueID
										JOIN Base.ClientFeatureGroup f ON d.ClientFeatureGroupID = f.ClientFeatureGroupID
										WHERE b.EntityTypeCode = 'CLPROD'
											AND u.ClientToProductID = a.EntityID
										FOR XML RAW('spnFeat')
											,ELEMENTS
											,TYPE
										) AS spnFeatL
								FROM Mid.Facility u
								WHERE a.FacilityCode = u.FacilityCode
									AND u.ClientCode IS NOT NULL
								GROUP BY ClientCode
									,ClientName
									,ClientToProductID
								FOR XML RAW('spn')
									,ELEMENTS
									,TYPE
								)
							,(
								SELECT CallCenterCode AS clCtrCd
									,CallCenterName AS clCtrNm
									,ReplyDays AS aptCoffDay
									,ApptCutOffTime AS aptCoffHr
									,EmailAddress AS eml
									,FaxNumber AS fxNo
									,(
										SELECT DISTINCT ClientFeatureCode AS featCd
											,d.ClientFeatureDescription AS featDesc
											,e.ClientFeatureValueCode AS featValCd
											,e.ClientFeatureValueDescription AS featValDesc
										FROM Base.ClientEntityToClientFeature a
										JOIN Base.EntityType b ON a.EntityTypeID = b.EntityTypeID
										JOIN Base.ClientFeatureToClientFeatureValue c ON a.ClientFeatureToClientFeatureValueID = c.ClientFeatureToClientFeatureValueID
										JOIN Base.ClientFeature d ON c.ClientFeatureID = d.ClientFeatureID
										JOIN Base.ClientFeatureValue e ON e.ClientFeatureValueID = c.ClientFeatureValueID
										JOIN Base.ClientFeatureGroup f ON d.ClientFeatureGroupID = f.ClientFeatureGroupID
										WHERE f.ClientFeatureGroupCode = 'FGOAR'
											AND b.EntityTypeCode = 'CLCTR'
											AND ccd.CallCenterID = a.EntityID
										FOR XML RAW('clCtrFeat')
											,ELEMENTS
											,TYPE
										) AS clCtrFeatL
								FROM Base.vwuCallCenterDetails ccd
								WHERE ccd.ClientToProductID = a.ClientToProductID
								GROUP BY CallCenterCode
									,CallCenterName
									,ReplyDays
									,ApptCutOffTime
									,EmailAddress
									,FaxNumber
									,CallCenterID
								FOR XML RAW('clCtrL')
									,ELEMENTS
									,TYPE
								)
							,(
								SELECT v.PhoneXML AS phoneL
									,v.MobilePhoneXML AS mobilePhoneL
									,v.URLXML AS urlL
									,v.ImageXML AS imageL
									,v.TabletPhoneXML AS tabletPhoneL
									,v.DesktopPhoneXML AS desktopPhoneL
								FROM Mid.Facility v
								WHERE v.FacilityCode = a.FacilityCode
									AND (
										v.PhoneXML IS NOT NULL
										OR v.URLXML IS NOT NULL
										OR v.ImageXML IS NOT NULL
										OR v.TabletPhoneXML IS NOT NULL
										)
								FOR XML RAW('disp')
									,ELEMENTS
									,ROOT('dispL')
									,TYPE
								)
						FROM Mid.Facility a
						WHERE a.FacilityCode = fac.FacilityCode
							--WHERE	a.FacilityCode = '029893'
							AND a.ClientToProductID IS NOT NULL
						GROUP BY a.ProductCode
							,a.ProductGroupCode
							,a.FacilityCode
							,a.ClientToProductID
						FOR XML RAW('sponsor')
							,ELEMENTS
							,ROOT('sponsorL')
							,TYPE
						) AS SponsorshipXML






					,(
						SELECT nm
						FROM (
							SELECT c.Name AS nm
							FROM ERMART1.Facility.FacilityParentChild a
							JOIN ERMART1.Facility.Facility b ON a.FacilityIDChild = b.FacilityID
							JOIN ERMART1.Facility.Facility c ON a.FacilityIDParent = c.FacilityID
							WHERE a.IsMaxYear = 1
								AND b.IsClosed = 0
								AND c.IsClosed = 0
								AND a.FacilityIDChild = fac.LegacyKey
							
							UNION
							
							SELECT c.Name AS nm
							FROM ERMART1.Facility.FacilityParentChild a
							JOIN ERMART1.Facility.Facility b ON a.FacilityIDParent = b.FacilityID
							JOIN ERMART1.Facility.Facility c ON a.FacilityIDChild = c.FacilityID
							WHERE a.IsMaxYear = 1
								AND b.IsClosed = 0
								AND a.FacilityIDParent = fac.LegacyKey
							) a
						FOR XML RAW('affil')
							,ELEMENTS
							,ROOT('affilL')
							,TYPE
						) AS AffiliationXML
					,(
						-- Populating it for only PDC Facilities
						SELECT DISTINCT ExecTeamName AS leadNm
							,title
							,bio
							,ExecTeamImage AS img
							,execEmail AS email
						FROM ERMart1.Facility.FacilityToExecLevelTeam a
						JOIN (
							SELECT DISTINCT f.LegacyKey AS FacilityID
							FROM Base.ClientToProduct a
							JOIN Base.Client b ON a.ClientID = b.ClientID
							JOIN Base.Product c ON a.ProductID = c.ProductID
							JOIN Base.ProductGroup pg ON c.ProductGroupID = pg.ProductGroupID
							JOIN Base.ClientProductToEntity d ON a.ClientToProductID = d.ClientToProductID
							JOIN Base.EntityType e ON d.EntityTypeID = e.EntityTypeID
								AND e.EntityTypeCode = 'FAC'
							JOIN Base.Facility f ON d.EntityID = f.FacilityID
							WHERE a.ActiveFlag = 1
								AND ProductGroupCode = 'PDC'
								AND f.IsClosed = 0
							) b ON a.FacilityID = b.FacilityID
						WHERE a.FacilityID = fac.LegacyKey
						FOR XML RAW('leader')
							,ELEMENTS
							,ROOT('leaderL')
							,TYPE
						) AS LeadershipXML
					,(
						SELECT AwardName AS awNm
							,StandardMessage AS standMsg
							,DisplayLabel AS dispYr
							,PriorityRank AS pri
							,ImageName AS imgPath
						FROM ERMart1.Facility.FacilityAwardMessage i
						JOIN (
							SELECT DISTINCT f.LegacyKey AS FacilityID
							FROM Base.ClientToProduct a
							JOIN Base.Client b ON a.ClientID = b.ClientID
							JOIN Base.Product c ON a.ProductID = c.ProductID
							JOIN Base.ProductGroup pg ON c.ProductGroupID = pg.ProductGroupID
							JOIN Base.ClientProductToEntity d ON a.ClientToProductID = d.ClientToProductID
							JOIN Base.EntityType e ON d.EntityTypeID = e.EntityTypeID
								AND e.EntityTypeCode = 'FAC'
							JOIN Base.Facility f ON d.EntityID = f.FacilityID
							WHERE a.ActiveFlag = 1
								AND ProductGroupCode = 'PDC'
								AND f.IsClosed = 0
							) j ON i.FacilityID = j.FacilityID
						WHERE i.FacilityID = fac.LegacyKey
						FOR XML RAW('awardMsg')
							,ELEMENTS
							,ROOT('awardMsgL')
							,TYPE
						) AS AwardAchievementXML
					,fac.FacilityURL
					,fac.FacilityImagePath
					,(
						SELECT AnswerPercent
						FROM ERMART1.Facility.FacilityToSurvey x
						WHERE SurveyID = 1
							AND QuestionID = 10
							AND x.FacilityID = fac.LegacyKey
						) AS PatientSatisfaction
					,CASE 
						WHEN fac.ProductGroupCode = 'PDC'
							THEN '1'
						ELSE '0'
						END AS IsPDC
					,NULL AS OverallPatientSafety
					,GETDATE() AS UpdatedDate
					,USER_NAME() AS UpdatedSource
					,(SELECT b.LanguageName AS langNm
							,b.LanguageCode as langCd
						FROM   Base.FacilityToLanguage AS a
						inner join base.Language b on b.LanguageID = a.LanguageID
						WHERE  a.FacilityID = fac.FacilityID
					FOR
						XML RAW('lang')
						,ELEMENTS
						,ROOT('langL')
						,TYPE
					) as LanguageXML
					,(SELECT b.ServiceName AS servNm
							,b.ServiceCode as servCd
							--select top 10 *
						FROM   Base.FacilityToService AS a
						inner join base.Service b on b.ServiceID = a.ServiceID
						WHERE  a.FacilityID = fac.FacilityID
					FOR
						XML RAW('serv')
						,ELEMENTS
						,ROOT('servL')
						,TYPE
					) as ServiceXML
				


				FROM Mid.Facility AS fac
				JOIN #FacilityAddressDetail FAD ON FAD.FacilityId = FAC.FacilityId
				JOIN #BatchInsertUpdateProcess AS batch ON batch.FacilityID = fac.FacilityID
				GROUP BY fac.FacilityID
					,fac.LegacyKey
					,fac.FacilityCode
					, case when fac.FacilityTypeCode = 'HGPH' and charindex(concat(' ', fad.City, ', ', fad.State, ' ') , concat(ltrim(rtrim(fac.FacilityName)), ' ')) = 0 then concat(ltrim(rtrim(fac.FacilityName)), ' in ', fad.City, ', ', fad.State) else ltrim(rtrim(fac.FacilityName)) end
					,fac.FacilityType
					,fac.FacilityTypeCode
					,fac.FacilitySearchType
					,fac.Accreditation
					,fac.AccreditationDescription
					,fac.TreatmentSchedules
					,fac.PhoneNumber
					,fac.AdditionalTransportationInformation
					,fac.AfterHoursPhoneNumber
					,fac.ClosedHolidaysInformation
					,fac.CommunityActivitiesInformation
					,fac.CommunityOutreachProgramInformation
					,fac.CommunitySupportInformation
					,fac.FacilityDescription
					,fac.EmergencyAfterHoursPhoneNumber
					,fac.FoundationInformation
					,fac.HealthPlanInformation
					,fac.IsMedicaidAccepted
					,fac.IsMedicareAccepted
					,fac.IsTeaching
					,fac.LanguageInformation
					,fac.MedicalServicesInformation
					,fac.MissionStatement
					,fac.OfficeCloseTime
					,fac.OfficeOpenTime
					,fac.OnsiteGuestServicesInformation
					,fac.OtherEducationAndTrainingInformation
					,fac.OtherServicesInformation
					,fac.OwnershipType
					,fac.ParkingInstructionsInformation
					,fac.PaymentPolicyInformation
					,fac.ProfessionalAffiliationInformation
					,fac.PublicTransportationInformation
					,fac.RegionalRelationshipInformation
					,fac.ReligiousAffiliationInformation
					,fac.SpecialProgramsInformation
					,fac.SurroundingAreaInformation
					,fac.TeachingProgramsInformation
					,fac.TollFreePhoneNumber
					,fac.TransplantCapabilitiesInformation
					,fac.VisitingHoursInformation
					,fac.VolunteerInformation
					,fac.YearEstablished
					,fac.HospitalAffiliationInformation
					,fac.PhysicianCallCenterPhoneNumber
					,fac.OverallHospitalStar
					,fac.ClientCode
					,fac.FacilityURL
					,fac.FacilityImagePath
					,fac.ProductCode
					,fac.ProviderCount
					,fac.AwardCount
					,fac.ProcedureCount
					,fac.FiveStarProcedureCount
					,fac.ResPgmApprAma
					,fac.ResPgmApprAoa
					,fac.ResPgmApprAda
					,fac.MiscellaneousInformation
					,fac.AppointmentInformation
					,fac.VisitingHoursMonday
					,fac.VisitingHoursTuesday
					,fac.VisitingHoursWednesday
					,fac.VisitingHoursThursday
					,fac.VisitingHoursFriday
					,fac.VisitingHoursSaturday
					,fac.VisitingHoursSunday
					,fac.Website
					,fac.ForeignObjectLeftPercent
					,fac.AwardsInformation
					,fac.ProductGroupCode

		PRINT 'Batch ' + CAST(@batchProcessMin AS VARCHAR(1000)) + ' Completed';

		SET @batchProcessMin = @batchProcessMin + 1;
	END;

	PRINT 'Process End';
	PRINT GETDATE();
	
	TRUNCATE TABLE Show.SOLRFacility

	INSERT INTO Show.SOLRFacility([FacilityID], [LegacyKey], [LegacyKey8], [FacilityCode], [FacilityName], [FacilityType], [FacilityTypeCode], [FacilitySearchType], [Accreditation], [AccreditationDescription], [TreatmentSchedules], [PhoneNumber], [AdditionalTransportationInformation], [AfterHoursPhoneNumber], [ClosedHolidaysInformation], [CommunityActivitiesInformation], [CommunityOutreachProgramInformation], [CommunitySupportInformation], [FacilityDescription], [EmergencyAfterHoursPhoneNumber], [FoundationInformation], [HealthPlanInformation], [IsMedicaidAccepted], [IsMedicareAccepted], [IsTeaching], [LanguageInformation], [MedicalServicesInformation], [MissionStatement], [OfficeCloseTime], [OfficeOpenTime], [FacilityHoursXML], [OnsiteGuestServicesInformation], [OtherEducationAndTrainingInformation], [OtherServicesInformation], [OwnershipType], [ParkingInstructionsInformation], [PaymentPolicyInformation], [ProfessionalAffiliationInformation], [PublicTransportationInformation], [RegionalRelationshipInformation], [ReligiousAffiliationInformation], [SpecialProgramsInformation], [SurroundingAreaInformation], [TeachingProgramsInformation], [TollFreePhoneNumber], [TransplantCapabilitiesInformation], [VisitingHoursInformation], [VolunteerInformation], [YearEstablished], [HospitalAffiliationInformation], [PhysicianCallCenterPhoneNumber], [OverallHospitalStar], [ClientCode], [ProductCode], [ProviderCount], [AwardsInformation], [AwardCount], [ProcedureCount], [FiveStarProcedureCount], [ResidencyProgApproval], [MiscellaneousInformation], [AppointmentInformation], [VisitingHoursMonday], [VisitingHoursTuesday], [VisitingHoursWednesday], [VisitingHoursThursday], [VisitingHoursFriday], [VisitingHoursSaturday], [VisitingHoursSunday], [Website], [ForeignObjectLeftPercent], [AddressXML], [AwardXML], [ServiceLineXML], [PatientSatisfactionXML], [TopTenProcedureXML], [TransplantRatingsXML], [DistinctionXML], [PatientCareXML], [ReadmissionRateXML], [TimelyAndEffectiveCareXML], [PatientSafetyXML], [TraumaLevelXML], [SponsorshipXML], [AffiliationXML], [LeadershipXML], [AwardAchievementXML], [FacilityURL], [FacilityImagePath], [PatientSatisfaction], [IsPDC], [OverallPatientSafety], [UpdatedDate], [UpdatedSource], [LanguageXML], [ServiceXML])
	SELECT		[FacilityID], [LegacyKey], [LegacyKey8], [FacilityCode], [FacilityName], [FacilityType], [FacilityTypeCode], [FacilitySearchType], [Accreditation], [AccreditationDescription], [TreatmentSchedules], [PhoneNumber], [AdditionalTransportationInformation], [AfterHoursPhoneNumber], [ClosedHolidaysInformation], [CommunityActivitiesInformation], [CommunityOutreachProgramInformation], [CommunitySupportInformation], [FacilityDescription], [EmergencyAfterHoursPhoneNumber], [FoundationInformation], [HealthPlanInformation], [IsMedicaidAccepted], [IsMedicareAccepted], [IsTeaching], [LanguageInformation], [MedicalServicesInformation], [MissionStatement], [OfficeCloseTime], [OfficeOpenTime], [FacilityHoursXML], [OnsiteGuestServicesInformation], [OtherEducationAndTrainingInformation], [OtherServicesInformation], [OwnershipType], [ParkingInstructionsInformation], [PaymentPolicyInformation], [ProfessionalAffiliationInformation], [PublicTransportationInformation], [RegionalRelationshipInformation], [ReligiousAffiliationInformation], [SpecialProgramsInformation], [SurroundingAreaInformation], [TeachingProgramsInformation], [TollFreePhoneNumber], [TransplantCapabilitiesInformation], [VisitingHoursInformation], [VolunteerInformation], [YearEstablished], [HospitalAffiliationInformation], [PhysicianCallCenterPhoneNumber], [OverallHospitalStar], [ClientCode], [ProductCode], [ProviderCount], [AwardsInformation], [AwardCount], [ProcedureCount], [FiveStarProcedureCount], [ResidencyProgApproval], [MiscellaneousInformation], [AppointmentInformation], [VisitingHoursMonday], [VisitingHoursTuesday], [VisitingHoursWednesday], [VisitingHoursThursday], [VisitingHoursFriday], [VisitingHoursSaturday], [VisitingHoursSunday], [Website], [ForeignObjectLeftPercent], [AddressXML], [AwardXML], [ServiceLineXML], [PatientSatisfactionXML], [TopTenProcedureXML], [TransplantRatingsXML], [DistinctionXML], [PatientCareXML], [ReadmissionRateXML], [TimelyAndEffectiveCareXML], [PatientSafetyXML], [TraumaLevelXML], [SponsorshipXML], [AffiliationXML], [LeadershipXML], [AwardAchievementXML], [FacilityURL], [FacilityImagePath], [PatientSatisfaction], [IsPDC], [OverallPatientSafety], [UpdatedDate], [UpdatedSource], [LanguageXML], [ServiceXML]
	FROM		#SOLRFacility

	/*Marionjoy Rehab (MJR) HG0675*/
	DELETE ods1STAGE.show.solrfacility
	WHERE facilitycode = (
			SELECT facilitycode
			FROM ods1STAGE.show.solrfacility_MJR
			)
		
	INSERT INTO ods1STAGE.show.solrfacility (
		FacilityID
		,LegacyKey
		,LegacyKey8
		,FacilityCode
		,FacilityName
		,FacilityType
		,FacilityTypeCode
		,FacilitySearchType
		,Accreditation
		,AccreditationDescription
		,TreatmentSchedules
		,PhoneNumber
		,AdditionalTransportationInformation
		,AfterHoursPhoneNumber
		,AwardsInformation
		,ClosedHolidaysInformation
		,CommunityActivitiesInformation
		,CommunityOutreachProgramInformation
		,CommunitySupportInformation
		,FacilityDescription
		,EmergencyAfterHoursPhoneNumber
		,FoundationInformation
		,HealthPlanInformation
		,IsMedicaidAccepted
		,IsMedicareAccepted
		,IsTeaching
		,LanguageInformation
		,MedicalServicesInformation
		,MissionStatement
		,OfficeCloseTime
		,OfficeOpenTime
		,OnsiteGuestServicesInformation
		,OtherEducationAndTrainingInformation
		,OtherServicesInformation
		,OwnershipType
		,ParkingInstructionsInformation
		,PaymentPolicyInformation
		,ProfessionalAffiliationInformation
		,PublicTransportationInformation
		,RegionalRelationshipInformation
		,ReligiousAffiliationInformation
		,SpecialProgramsInformation
		,SurroundingAreaInformation
		,TeachingProgramsInformation
		,TollFreePhoneNumber
		,TransplantCapabilitiesInformation
		,VisitingHoursInformation
		,VolunteerInformation
		,YearEstablished
		,HospitalAffiliationInformation
		,PhysicianCallCenterPhoneNumber
		,OverallHospitalStar
		,ClientCode
		,ProductCode
		,AwardCount
		,ProviderCount
		,ProcedureCount
		,FiveStarProcedureCount
		,ResidencyProgApproval
		,MiscellaneousInformation
		,AppointmentInformation
		,VisitingHoursMonday
		,VisitingHoursTuesday
		,VisitingHoursWednesday
		,VisitingHoursThursday
		,VisitingHoursFriday
		,VisitingHoursSaturday
		,VisitingHoursSunday
		,FacilityImagePath
		,WebSite
		,FacilityURL
		,ForeignObjectLeftPercent
		,AddressXML
		,AwardXML
		,ServiceLineXML
		,PatientSatisfactionXML
		,TopTenProcedureXML
		,TransplantRatingsXML
		,SponsorshipXML
		,TraumaLevelXML
		,DistinctionXML
		,PatientCareXML
		,PatientSafetyXML
		,AffiliationXML
		,LeadershipXML
		,AwardAchievementXML
		,UpdatedDate
		,UpdatedSource
		,PatientSatisfaction
		,IsPDC
		,OverallPatientSafety
		,ReadmissionRateXML
		,TimelyAndEffectiveCareXML
		,FacilityHoursXML
		)
	SELECT FacilityID
		,LegacyKey
		,LegacyKey8
		,FacilityCode
		,FacilityName
		,FacilityType
		,FacilityTypeCode
		,FacilitySearchType
		,Accreditation
		,AccreditationDescription
		,TreatmentSchedules
		,PhoneNumber
		,AdditionalTransportationInformation
		,AfterHoursPhoneNumber
		,AwardsInformation
		,ClosedHolidaysInformation
		,CommunityActivitiesInformation
		,CommunityOutreachProgramInformation
		,CommunitySupportInformation
		,FacilityDescription
		,EmergencyAfterHoursPhoneNumber
		,FoundationInformation
		,HealthPlanInformation
		,IsMedicaidAccepted
		,IsMedicareAccepted
		,IsTeaching
		,LanguageInformation
		,MedicalServicesInformation
		,MissionStatement
		,OfficeCloseTime
		,OfficeOpenTime
		,OnsiteGuestServicesInformation
		,OtherEducationAndTrainingInformation
		,OtherServicesInformation
		,OwnershipType
		,ParkingInstructionsInformation
		,PaymentPolicyInformation
		,ProfessionalAffiliationInformation
		,PublicTransportationInformation
		,RegionalRelationshipInformation
		,ReligiousAffiliationInformation
		,SpecialProgramsInformation
		,SurroundingAreaInformation
		,TeachingProgramsInformation
		,TollFreePhoneNumber
		,TransplantCapabilitiesInformation
		,VisitingHoursInformation
		,VolunteerInformation
		,YearEstablished
		,HospitalAffiliationInformation
		,PhysicianCallCenterPhoneNumber
		,OverallHospitalStar
		,ClientCode
		,ProductCode
		,AwardCount
		,ProviderCount
		,ProcedureCount
		,FiveStarProcedureCount
		,ResidencyProgApproval
		,MiscellaneousInformation
		,AppointmentInformation
		,VisitingHoursMonday
		,VisitingHoursTuesday
		,VisitingHoursWednesday
		,VisitingHoursThursday
		,VisitingHoursFriday
		,VisitingHoursSaturday
		,VisitingHoursSunday
		,FacilityImagePath
		,WebSite
		,FacilityURL
		,ForeignObjectLeftPercent
		,AddressXML
		,AwardXML
		,ServiceLineXML
		,PatientSatisfactionXML
		,TopTenProcedureXML
		,TransplantRatingsXML
		,SponsorshipXML
		,TraumaLevelXML
		,DistinctionXML
		,PatientCareXML
		,PatientSafetyXML
		,AffiliationXML
		,LeadershipXML
		,AwardAchievementXML
		,UpdatedDate
		,UpdatedSource
		,PatientSatisfaction
		,IsPDC
		,OverallPatientSafety
		,ReadmissionRateXML
		,TimelyAndEffectiveCareXML
		,FacilityHoursXML
	FROM ods1STAGE.show.solrfacility_MJR