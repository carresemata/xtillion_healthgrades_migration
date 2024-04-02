SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--CREATE procedure [Show].[spuSOLRAutosuggestRefData]

ALTER   PROC [Show].[spuSOLRAutosuggestRefData]
AS

/*-------------------------------------------------------------------------------------

Procedure Name	: spuSOLRAutosuggestRefData
Description		: Generates the Survey Quesioon and Answer solr table for  providers


Created By		: Abhash Bhandary
Created On		: 01/27/2015	


EXEC Show.spuSOLRAutosuggestRefData

TRUNCATE TABLE [Show].[SOLRAutosuggestRefData]



SELECT * FROM [Show].[SOLRAutosuggestRefData] WHERE AutoType = 'Client'



-------------------------------------------------------------------------------------*/
set nocount off


declare @ErrorMessage VARCHAR(1000)

begin try

	TRUNCATE TABLE Show.SOLRAutosuggestRefData

	--build a temp TABLE with the same structure as the [Show].[SOLRAutosuggestRefData]
		BEGIN TRY DROP TABLE #TEMPAutosuggestRefData END TRY BEGIN CATCH END CATCH
		SELECT	TOP 0 Code,Description,Definition,Rank,TermID,AutoType,RelationshipXML
		INTO	#TEMPAutosuggestRefData
		FROM	[Show].[SOLRAutosuggestRefData]






	--this table will hold ALL of the records that we need to insert/update

		
		INSERT INTO	#TEMPAutosuggestRefData (Code,Description,Definition,Rank,TermID,AutoType)
		SELECT	Code,Description,Definition,Rank,TermID,AutoType
		FROM	(

					SELECT	 GenderCode AS 'Code'
							,GenderDescription AS 'Description'
							,NULL AS 'Definition'
							,NULL AS 'Rank'
							,GenderID AS 'TermID'
							,'GENDER' AS 'AutoType'
					FROM	Base.Gender

					UNION
										
					SELECT	 SuffixAbbreviation AS 'Code'
							,NULL AS 'Description' 
							,NULL AS 'Definition' 
							,null AS 'Rank'  
							,SuffixID AS 'TermID'
							,'SUFFIX' AS 'AutoType'
					FROM	Base.Suffix

					UNION

					SELECT	 ProviderTypeCode AS 'Code'
							,ProviderTypeDescription AS 'Description'
							,NULL AS 'Definition'
							,NULL AS 'Rank' 
							,ProviderTypeID AS 'TermID'
							,'PROVIDERTYPE' AS 'AutoType'
					FROM	Base.ProviderType

					UNION

  					SELECT	 SubStatusCode AS 'Code'
							,SubStatusDescription AS 'Description'
							,null AS 'Definition' 
							,SubStatusRank AS 'Rank'
							,SubStatusID AS 'TermID'
							,'SUBSTATUS' AS 'AutoType'
					FROM	Base.SubStatus

					UNION
	
					SELECT	 IdentificationTypeCode AS 'Code'
							,IdentificationTypeDescription AS 'Description'
							,NULL AS 'Definition'
							,NULL AS 'Rank'
							,IdentificationTypeID AS 'TermID'
							,'IDENTIFICATIONTYPE' AS 'AutoType'
					FROM	Base.IdentificationType

					UNION

					--SELECT	 [MediaTypeCode] AS 'Code'
					--		,[refMediaTypeDescription] AS 'Description'
					--		,[refMediaTypeName] AS 'Definition'
					--		,[refDisplaySeq] AS 'Rank'
					--		,[refMediaTypeID] AS 'TermID'
					--		,'MEDIATYPE' AS 'AutoType'
					--FROM	[HealthMaster].[ref].[MediaType]

					--UNION

					SELECT	 PositionCode AS 'Code'
							,PositionDescription AS 'Description'
							,null AS 'Definition'
							,refRank AS 'Rank'
							,PositionID AS 'TermID'
							,'POSITION' AS 'AutoType'
					FROM	Base.Position

					UNION

					SELECT   LanguageCode AS 'Code'
							,LanguageName AS 'Description'
							,NULL AS 'Definition'
							,NULL AS 'Rank'
							,LanguageID AS 'TermID'
							,'LANGUAGE' AS 'AutoType'		
					FROM	Base.Language

					UNION

					SELECT	 AboutMeCode AS 'Code'
							,AboutMeDescription AS 'Description'
							,NULL AS 'Definition'
							,DisplayOrder AS 'Rank'
							,AboutMeID AS 'TermID'
							,'ABOUTME' AS 'AutoType'	
					FROM	Base.AboutMe

					UNION

					SELECT	 AppointmentAvailabilityCode AS 'Code'
							,AppointmentAvailabilityDescription AS 'Description'
							,NULL AS 'Definition'
							,NULL AS 'Rank'
							,AppointmentAvailabilityID AS 'TermID'
							,'APPOINTMEMT' AS 'AutoType'	
					FROM	Base.AppointmentAvailability

					UNION

					SELECT	 HGProcedureGroupCode AS 'Code'
							,HGProcedureGroupDisplayDescription AS 'Description'
							,NULL AS 'Definition'
							,NULL AS 'Rank'
							,HGProcedureGroupID AS 'TermID'
							,'PROCGROUP' AS 'AutoType'	
					FROM	Base.HGProcedureGroup
					WHERE	IsActive = 1

					UNION

					SELECT	 SpecialtyGroupCode AS 'Code'
							,SpecialtyGroupDescription AS 'Description'
							,null AS 'Definition'
							,Rank AS 'Rank'
							,SpecialtyGroupID AS 'TermID'
							,'SPECGROUP' AS 'AutoType'	
					FROM	Base.[SpecialtyGroup]

					UNION

					SELECT	 CertificationBoardCode AS 'Code'
							,CertificationBoardDescription AS 'Description'
							,null AS 'Definition'
							,NULL AS 'Rank'
							,CertificationBoardID AS 'TermID'
							,'CERTBOARD' AS 'AutoType'
					FROM	Base.CertificationBoard

					UNION

					SELECT  CertificationAgencyCode AS 'Code'
							,CertificationAgencyDescription AS 'Description'
							,null AS 'Definition'
							,NULL AS 'Rank'
							,CertificationAgencyID AS 'TermID'
							,'CERTAGENCY' AS 'AutoType'
					FROM	Base.CertificationAgency

					UNION

					SELECT   CertificationStatusCode AS 'Code'
							,CertificationStatusDescription AS 'Description'
							,null AS 'Definition'
							,Rank AS 'Rank'
							,CertificationStatusID AS 'TermID'
							,'CERTSTATUS' AS 'AutoType'
					FROM	base.CertificationStatus

					UNION

					SELECT   SuppressionReasonCode AS 'Code'
							,SuppressionReasonDescription AS 'Description'
							,NULL AS 'Definition'
							,NULL AS 'Rank'
							,SurveySuppressionReasonID AS 'TermID'
							,'SURVEYSUPPRESSREASON' AS 'AutoType'
					FROM	Base.SurveySuppressionReason2

					UNION

					--SELECT   [refMalpracticeClaimTypeCode] AS 'Code'
					--		,[refMalpracticeClaimTypeDescription] AS 'Description'
					--		,NULL AS 'Definition'
					--		,NULL AS 'Rank'
					--		,[refMalpracticeClaimTypeKey] AS 'TermID'
					--		,'MALCLAIMTYPE' AS 'AutoType'
					--FROM	[HealthMaster].[ref].[MalpracticeClaimType]

					--UNION

					--SELECT   [refSanctionTypeCode] AS 'Code'
					--		,[refSanctionTypeDescription] AS 'Description'
					--		,NULL AS 'Definition'
					--		,NULL AS 'Rank'
					--		,[refSanctionTypeKey] AS 'TermID'
					--		,'SANCTYPE' AS 'AutoType'
					--FROM	[HealthMaster].[ref].[SanctionType]

					--UNION

					--SELECT   [refSanctionCategoryCode] AS 'Code'
					--		,[refSanctionCategoryDescription] AS 'Description'
					--		,NULL AS 'Definition'
					--		,NULL AS 'Rank'
					--		,[refSanctionCategoryKey] AS 'TermID'
					--		,'SANCCATEGORY' AS 'AutoType'
					--FROM	[HealthMaster].[ref].[SanctionCategory]

					--UNION

					--SELECT   [refSanctionActionCode] AS 'Code'
					--		,[refSanctionActionDescription] AS 'Description'
					--		,NULL AS 'Definition'
					--		,NULL AS 'Rank'
					--		,[refSanctionActionKey] AS 'TermID'
					--		,'SANCACTION' AS 'AutoType'
					--FROM	[HealthMaster].[ref].[SanctionAction]

					--UNION

					SELECT   LocationTypeCode AS 'Code'
							,LocationTypeDescription AS 'Description'
							,NULL AS 'Definition'
							,NULL AS 'Rank'
							,LocationTypeID AS 'TermID'
							,'LOCATIONTYPE' AS 'AutoType'
					FROM	base.LocationType
					UNION

					SELECT   [NationCode] AS 'Code'
							,[NationName] AS 'Description'
							,NULL AS 'Definition'
							,NULL AS 'Rank'
							,[NationID] AS 'TermID'
							,'NATION' AS 'AutoType'
					FROM	ODS1STAGE.Base.Nation

					UNION

					SELECT   LicenseTypeCode AS 'Code'
							,LicenseTypeDescription AS 'Description'
							,NULL AS 'Definition'
							,NULL AS 'Rank'
							,LicenseTypeID AS 'TermID'
							,'LICENSETYPE' AS 'AutoType'
					FROM	Base.LicenseType

					--UNION

					--SELECT   [SuppressionReasonCode] AS 'Code'
					--		,[SuppressionReasonDescription] AS 'Description'
					--		,NULL AS 'Definition'
					--		,NULL AS 'Rank'
					--		,[SurveySuppressionReasonID] AS 'TermID'
					--		,'SURVEYSUPPRESS' AS 'AutoType'
					--FROM	HealthMaster.ref.SurveySuppressionReason
					
					UNION 

					SELECT PlanCode AS 'Code'
						   ,PLanDisplayName AS 'Description'
						   ,NULL AS 'Definition'
						   ,NULL AS 'Rank'
						   ,HealthInsurancePlanID AS 'TermID'
						   ,'INSURANCEPLAN' AS 'AutoType'
					FROM base.HealthInsurancePlan


					UNION 

					select	c.ClientCode AS 'Code'
							,c.ClientName AS 'Description'
							,p.ProductCode AS 'Definition'
							,NULL AS 'Rank'
							,c.ClientID AS 'TermID'
							,'CLIENT' AS 'AutoType'
					from	ODS1Stage.Base.ClientToProduct cp
							join ODS1Stage.Base.Client c on cp.ClientID = c.ClientID
							join ODS1Stage.Base.Product p on cp.ProductID = p.ProductID
							join ODS1Stage.Base.ProductGroup pg on p.ProductGroupID = pg.ProductGroupID
					WHERE   cp.ActiveFlag = 1

					UNION 

					SELECT	[EducationInstitutionTypeCode] AS 'Code' 
							--,[EducationInstitutionTypeDescription] AS 'Description'
							,[EducationInstitutionTypeCode] AS 'Description'
							,NULL AS 'Definition'
							,NULL AS 'Rank'
							,EducationInstitutionTypeID AS 'TermID'
							,'EDUCATIONTYPE' AS 'AutoType'
					FROM [ODS1Stage].[Base].[EducationInstitutionType]

					UNION 

					SELECT	'DOCSPECLABEL' AS 'Code'
						   ,'Specialties' AS 'Description'
						   ,NULL AS 'Definition'
						   ,NULL AS 'Rank'
						   ,NEWID() AS 'TermID'
						   ,'SPECLABEL' AS 'AutoType'
					

					UNION 

					SELECT	'ALTSPECLABEL' AS 'Code'
						   ,'Specialties' AS 'Description'
						   ,NULL AS 'Definition'
						   ,NULL AS 'Rank'
						   ,NEWID() AS 'TermID'
						   ,'SPECLABEL' AS 'AutoType'
								

					UNION 

					SELECT	'DENTSPECLABEL' AS 'Code'
						   ,'Practice Areas' AS 'Description'
						   ,NULL AS 'Definition'
						   ,NULL AS 'Rank'
						   ,NEWID() AS 'TermID'
						   ,'SPECLABEL' AS 'AutoType'
					
					UNION 

					SELECT	'DOCPRACSPECLABEL' AS 'Code'
						   ,'Practicing Specialties' AS 'Description'
						   ,NULL AS 'Definition'
						   ,NULL AS 'Rank'
						   ,NEWID() AS 'TermID'
						   ,'SPECLABEL' AS 'AutoType'
					

					UNION 

					SELECT	'ALTPRACSPECLABEL' AS 'Code'
						   ,'Practicing Specialties' AS 'Description'
						   ,NULL AS 'Definition'
						   ,NULL AS 'Rank'
						   ,NEWID() AS 'TermID'
						   ,'SPECLABEL' AS 'AutoType'
								

					UNION 

					SELECT	'DENTPRACSPECLABEL' AS 'Code'
						   ,'Practice Areas' AS 'Description'
						   ,NULL AS 'Definition'
						   ,NULL AS 'Rank'
						   ,NEWID() AS 'TermID'
						   ,'SPECLABEL' AS 'AutoType'

					UNION

					 SELECT	TermCode AS 'Code'
							,TermDescription AS 'Description'
							,TermType AS 'Definition'
							,[Rank] AS 'Rank'
							,PopularSearchTermID AS 'TermID'
							,'POPULARSEARCHTERM' AS 'AutoType'
					FROM	[dbo].[PopularSearchTerm]

				) a



		/*****  Code modified for PDS-600
		******  Keeping in case of error in update, once PDS-600 passes Post Prod - QA this needs to be removed
		******
		INSERT INTO	#TEMPAutosuggestRefData (Code,Description,Definition,Rank,TermID,AutoType,RelationshipXML)
		SELECT	ip.refInsurancePayorCode as 'Code'
				,ip.refInsurancePayorDescription AS 'Description'
				,NULL AS 'Definition'
				,NULL AS 'Rank'
				,ip.refInsurancePayorKey AS 'TermID'
				,'INSURANCEPAYOR' AS 'AutoType'
				,(
					SELECT	ipr.refInsuranceProductCode as productCd,
							ipr.refInsuranceProductKey as productId,
							ipl.refInsurancePlanCode as planCd,
							ipl.refInsurancePlanDescription as planNm,
							ipt.refInsurancePlanTypeCode as planTpCd,
							ipt.refInsurancePlanTypeDescription as planTpNm
					FROM	HealthMaster.ref.InsuranceProduct ipr 
							INNER JOIN HealthMaster.ref.InsurancePlan ipl ON ipr.refInsurancePlanCode = ipl.refInsurancePlanCode
							INNER JOIN HealthMaster.ref.InsurancePlanType ipt ON ipr.refInsurancePlanTypeCode = ipt.refInsurancePlanTypeCode
					WHERE	ip.refInsurancePayorCode = ipr.refInsurancePayorCode
					FOR XML RAW('insurance') ,ELEMENTS, ROOT('insuranceL'), TYPE
				) AS RelationshipXML
		FROM	HealthMaster.ref.InsurancePayor ip 
		*/


		/***** Start: PDS - 600 *****/
/*
		;WITH base as (
			select distinct d.refInsurancePayorCode, a.srcInsuranceProductDescription
			from HealthMaster.src.InsuranceProduct a
			join HealthMaster.map.InsuranceProduct b on b.refSourceCode=a.refSourceCode
														and b.srcInsuranceProductHash1=a.srcInsuranceProductHash1
			join HealthMaster.ref.InsuranceProduct c on c.refInsuranceProductCode=b.refInsuranceProductCode
			join HealthMaster.ref.InsurancePayor d on d.refInsurancePayorCode=c.refInsurancePayorCode
			join HealthMaster.ref.InsurancePlan e on e.refInsurancePlanCode=c.refInsurancePlanCode
			join HealthMaster.ref.InsurancePlanType f on f.refInsurancePlanTypeCode=c.refInsurancePlanTypeCode
			where a.refSourceCode='SCPOKITDOK'
		)
*/
		;WITH base as (
			select distinct d.InsurancePayorCode, e.HealthInsurancePlanID, c.ProductName
			from ODS1Stage.Base.HealthInsurancePlanToPlanType c 
			join ODS1Stage.Base.HealthInsurancePlan e on e.HealthInsurancePlanID=c.HealthInsurancePlanID
			join ODS1Stage.Base.HealthInsurancePlanType f on f.HealthInsurancePlanTypeID=c.HealthInsurancePlanTypeID
			join ODS1Stage.Base.HealthInsurancePayor d on d.HealthInsurancePayorID=e.HealthInsurancePayorID
		)

		INSERT INTO	#TEMPAutosuggestRefData (Code,Description,Definition,Rank,TermID,AutoType,RelationshipXML)
		SELECT	
			ip.InsurancePayorCode as 'Code'
			,ip.PayorName AS 'Description'
			,NULL AS 'Definition'
			,NULL AS 'Rank'
			,ip.HealthInsurancePayorID AS 'TermID'
			,'INSURANCEPAYOR' AS 'AutoType'
			,(
				SELECT	ipr.InsuranceProductCode as productCd,
						ipr.HealthInsurancePlanToPlanTypeID as productId,
						ipl.PlanCode as planCd,
						ipl.PlanName as planNm,
						ipt.PlanTypeCode as planTpCd,
						ipt.PlanTypeDescription as planTpNm,
						b.ProductName as pktdokPlNm -- pockitDoc
				FROM	ODS1Stage.Base.HealthInsurancePlanToPlanType ipr 
						INNER JOIN ODS1Stage.Base.HealthInsurancePlan ipl ON ipr.HealthInsurancePlanID = ipl.HealthInsurancePlanID
						INNER JOIN ODS1Stage.Base.HealthInsurancePlanType ipt ON ipr.HealthInsurancePlanTypeID = ipt.HealthInsurancePlanTypeID
						INNER JOIN  ODS1Stage.Base.HealthInsurancePayor pay ON pay.HealthInsurancePayorID = ipl.HealthInsurancePayorID
						LEFT JOIN base b on b.InsurancePayorCode = pay.InsurancePayorCode and b.HealthInsurancePlanID = ipr.HealthInsurancePlanID 
				WHERE	ip.InsurancePayorCode = pay.InsurancePayorCode 
				FOR XML RAW('insurance') ,ELEMENTS, ROOT('insuranceL'), TYPE
			) AS RelationshipXML
		FROM ODS1Stage.Base.HealthInsurancePayor ip 
		/***** END: PDS - 600 *****/

		INSERT INTO	#TEMPAutosuggestRefData (Code,Description,Definition,Rank,TermID,AutoType,RelationshipXML)
		SELECT	ipr.InsuranceProductCode as 'Code'
				,NULL AS 'Description'
				,NULL AS 'Definition'
				,NULL AS 'Rank'
				,ipr.HealthInsurancePlanToPlanTypeID AS 'TermID'
				,'INSURANCEPRODUCT' AS 'AutoType'
				,(
					SELECT	ipa.InsurancePayorCode as payorCd,
							ipa.PayorName as payorNm,
							ipl.PlanCode as planCd,
							ipl.PlanName as planNm,
							ipt.PlanTypeCode as planTpCd,
							ipt.PlanTypeDescription as planTpNm
					-- SELECT *
					FROM	ODS1Stage.Base.HealthInsurancePayor ipa 
							INNER JOIN ODS1Stage.Base.HealthInsurancePlan ipl ON ipa.HealthInsurancePayorID = ipl.HealthInsurancePayorID
							INNER JOIN ODS1Stage.Base.HealthInsurancePlanToPlanType ip ON ip.HealthInsurancePlanID = ipl.HealthInsurancePlanID 
							INNER JOIN ODS1Stage.Base.HealthInsurancePlanType ipt ON ip.HealthInsurancePlanTypeID = ipt.HealthInsurancePlanTypeID
					WHERE	ip.HealthInsurancePlanToPlanTypeID = ipr.HealthInsurancePlanToPlanTypeID
					FOR XML RAW('insurance') ,ELEMENTS, ROOT('insuranceL'), TYPE
				) AS RelationshipXML
		-- SELECT *
		FROM	ODS1Stage.Base.HealthInsurancePlanToPlanType ipr 

		INSERT INTO	#TEMPAutosuggestRefData (Code,Description,Definition,Rank,TermID,AutoType,RelationshipXML)
		SELECT	CertificationSpecialtyCode  as 'Code',
				CertificationSpecialtyDescription AS 'Description'
				,NULL AS 'Definition'
				,NULL AS 'Rank'
				,CertificationSpecialtyID AS 'TermID'
				,'CERTIFICATIONSPEC' AS 'AutoType'
				,(	SELECT  DISTINCT RTRIM(b.CertificationAgencyCode) AS caCd, 
							b.CertificationAgencyDescription AS caD, 
							RTRIM(c.CertificationBoardCode) AS cbCd, 
							c.CertificationBoardDescription	AS cbD				
					FROM	[Base].[CertificationAgencyToBoardToSpecialty] a with (nolock)
							JOIN  [Base].[CertificationAgency] b with (nolock) on a.CertificationagencyID = b.CertificationAgencyID
							JOIN [Base].[CertificationBoard] c with (nolock) on a.CertificationBoardID = c.CertificationBoardID
					WHERE  s.CertificationSpecialtyID = a.CertificationSpecialtyID
					FOR XML RAW('cert') ,ELEMENTS, ROOT('certL'), TYPE
				) AS RelationshipXML
		-- SELECT * 
		FROM	[Base].[CertificationSpecialty] s with (nolock)


		INSERT INTO	#TEMPAutosuggestRefData (Code,Description,Definition,Rank,TermID,AutoType,RelationshipXML)
		SELECT	 DisplayStatusCode AS 'Code'
				,DisplayStatusDescription AS 'Description'
				,null AS 'Definition'
				,DisplayStatusRank AS 'Rank'
				,DisplayStatusID AS 'TermID'
				,'DISPLAYSTATUS' AS 'AutoType'
				,(
					SELECT	SubStatusCode AS SubStatusCode, SubStatusDescription AS SubStatusDesc
					FROM	Base.SubStatus a
							JOIN Base.DisplayStatus b ON b.DisplayStatusID = a.DisplayStatusID
					WHERE	ds.DisplayStatusCode = b.DisplayStatusCode
					FOR XML RAW('subStatus') ,ELEMENTS, ROOT('subStatusL'), TYPE

				) AS RelationshipXML
		FROM	Base.DisplayStatus ds

						
					merge [Show].[SOLRAutosuggestRefData] as s
						using 
						(
							SELECT		 [Code]
										,[Description]
										,[Definition]
										,[Rank]
										,[TermID]
										,[AutoType]
										,[RelationshipXML]
										,[UpdatedDate]
										,[UpdatedSource]
							FROM
							(
								SELECT	 [Code]
										,[Description]
										,[Definition]
										,[Rank]
										,[TermID]
										,[AutoType]
										,[RelationshipXML]
										,GETDATE() AS UpdatedDate
										,USER_NAME() AS UpdatedSource 
								-- SELECT *
								FROM	#TEMPAutosuggestRefData 
							
							) AS sq
						) AS sx
						ON sx.[TermID] = s.[TermID]
				        
					WHEN MATCHED THEN     
						UPDATE SET	s.[Code] = sx.[Code],
									s.[Description] = sx.[Description],
									s.[Definition] = sx.[Definition],
									s.[Rank] = sx.[Rank],
									s.[TermID] = sx.[TermID],
									s.[AutoType] = sx.[AutoType],
									s.[RelationshipXML] = sx.[RelationshipXML],
									s.[UpdatedDate] = sx.[UpdatedDate],
									s.[UpdatedSource] = sx.[UpdatedSource]
				        
					WHEN NOT MATCHED BY TARGET THEN 
						INSERT (	
  									 [Code]
									,[Description]
									,[Definition]
									,[Rank]
									,[TermID]
									,[AutoType]
									,[RelationshipXML]
									,[UpdatedDate]
									,[UpdatedSource]
								)
						VALUES (	
									 sx.[Code]
									,sx.[Description]
									,sx.[Definition]
									,sx.[Rank]
									,sx.[TermID]
									,sx.[AutoType]
									,sx.[RelationshipXML]
									,sx.[UpdatedDate]
									,sx.[UpdatedSource]
								);

			
		PRINT 'Process End'
		PRINT GETDATE()						
END TRY
BEGIN CATCH
    SET @ErrorMessage = 'Error in procedure spuSOLRAutosuggestRefData, line ' + CONVERT(VARCHAR(20), ERROR_LINE()) + ': ' + ERROR_MESSAGE()
    RAISERROR(@ErrorMessage, 18, 1)
END CATCH
GO