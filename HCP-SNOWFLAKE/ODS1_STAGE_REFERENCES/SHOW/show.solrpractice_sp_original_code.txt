------- 1. HACK.SPUSOLRPRACTICE

	update sp
	set SponsorshipXML = null
	--select * 
	from Show.SOLRPractice sp
	join Mid.PracticeSponsorship ps on ps.PracticeID = sp.PracticeID
	join Base.Client c on ps.ClientCode = c.ClientCode
	join Show.ClientContract cc on c.ClientID = cc.ClientID
	where cc.ContractStartDate > getdate()
	
	--THIS IS A HACK FOR THE HGID FIELD FOR SOLRPRACTICE
	update a
	set a.LegacyKeyPractice = 'HGPPZ'+left(replace(PracticeID,'-',''), 16)
	--select *
	from Show.SOLRPractice a
	where LegacyKeyPractice is null



------- 2. SHOW.SPUREMOVEPRACTICEWITHNOPROVIDER

delete p
-- SELECT p.PracticeID,PracticeCode, PracticeName,OfficeXML, ISNULL(a1.PhysicianCount,0) AS PhysicianCount
FROM Show.SOLRPractice p
LEFT JOIN
            (
                        SELECT            DISTINCT c.PracticeID, COUNT (a.ProviderID) as 'PhysicianCount'
                        FROM  Base.ProviderToOffice AS a WITH (NOLOCK)
                                                JOIN Base.Office AS b WITH (NOLOCK) ON b.OfficeID = a.OfficeID
                                                JOIN Base.Practice AS c WITH (NOLOCK) ON c.PracticeID = b.PracticeID
                                                JOIN Show.SOLRProvider d ON a.ProviderID = d.ProviderID
                        GROUP BY c.PracticeID          
 
            ) a1      ON p.PracticeID = a1.PracticeID
WHERE ISNULL(a1.PhysicianCount,0) = 0 


------- 3. Show.spuSOLRPracticeGenerateFromMid
BEGIN TRY
        
        begin try drop table #PracticeBatch end try begin catch end catch
        create table #PracticeBatch (PracticeID uniqueidentifier, PracticeCode varchar(25))

        if @IsDeltaProcessing = 0 
        begin
			TRUNCATE TABLE Show.SOLRPractice
        
            insert into #PracticeBatch (PracticeID, PracticeCode) 
            select		DISTINCT a.PracticeID, a.PracticeCode 
            FROM		Base.Practice as a 
			INNER JOIN	Base.Office O ON O.PracticeID = A.PracticeID
			INNER JOIN	Base.ProviderToOffice PO ON PO.OfficeID = PO.OfficeID
			INNER JOIN	Show.vwuProviderIndex P ON P.ProviderID = PO.ProviderID
            order	by a.PracticeID
          end
        else 
        begin
            insert into #PracticeBatch (PracticeID, PracticeCode)
            select distinct p.PracticeID, p.PracticeCode
            from Snowflake.etl.ProviderDeltaProcessing as a
            inner join base.ProviderToOffice pto on a.ProviderID = pto.ProviderID
            inner join base.Office o on pto.OfficeID = o.OfficeID
            inner join Base.Practice as p on p.PracticeID = o.PracticeID
            order by p.PracticeID
        end


	IF OBJECT_ID('tempdb..#Phone') IS NOT NULL DROP TABLE #Phone
	SELECT	DISTINCT z.OfficeID, z.FullPhone as phFull
	INTO	#Phone
	FROM	Mid.Practice z
	inner join #PracticeBatch X on X.PracticeID = Z.PracticeID
	WHERE	z.FullPhone IS NOT NULL

	IF OBJECT_ID('tempdb..#Fax') IS NOT NULL DROP TABLE #Fax
	SELECT	DISTINCT z.officeid, z.FullFax as faxFull
	into	#Fax
	FROM	Mid.Practice z
	inner join #PracticeBatch X on X.PracticeID = Z.PracticeID
	WHERE	z.FullFax IS NOT NULL

	IF OBJECT_ID('tempdb..#Specialty') IS NOT NULL DROP TABLE #Specialty
	SELECT	DISTINCT mt.OfficeID, SpecialtyCode as spCd, Specialty as spY, Specialist as spIst, Specialists as spIsts, LegacyKey as lKey
	INTO	#Specialty
	FROM	Mid.OfficeSpecialty mt
	
	IF OBJECT_ID('tempdb..#hours') IS NOT NULL DROP TABLE #hours
	SELECT		DISTINCT 
				Z.OfficeID
				,dow.DaysOfWeekDescription AS day
				,dow.SortOrder AS dispOrder
				,oh.OfficeHoursOpeningTime AS 'start'
				,oh.OfficeHoursClosingTime AS 'end'
				,oh.OfficeIsClosed AS closed
				,oh.OfficeIsOpen24Hours AS open24Hrs 
	into		#hours
	FROM		Mid.Practice z
	inner join #PracticeBatch X on X.PracticeID = Z.PracticeID
	INNER JOIN	base.OfficeHours oh 
				ON oh.OfficeID = z.OfficeID
	INNER JOIN	base.DaysOfWeek dow 
				ON dow.DaysOfWeekID = oh.DaysOfWeekID
	ORDER		BY dow.SortOrder

	IF OBJECT_ID('tempdb..#Sponsor') IS NOT NULL DROP TABLE #Sponsor
	SELECT		mp.OfficeID
				,(
					SELECT	DISTINCT DesignatedProviderPhone AS ph, 
							PhoneTypeCode as phTyp
					FROM	Base.vwuPDCPracticeOfficeDetail fa
					WHERE	fa.PhoneTypeCode in ('PTOOS') -- PDC Designated - Office Specific
							AND mp.OfficeID = fa.OfficeID
					FOR XML RAW ('phone'), ELEMENTS, TYPE 						
				) AS phoneL
				,(
					SELECT	DISTINCT DesignatedProviderPhone AS ph, 
							PhoneTypeCode as phTyp
					FROM	Base.vwuPDCPracticeOfficeDetail fa
					WHERE	fa.PhoneTypeCode in ('PTOOSM') -- PDC Designated - Office Specific - Mobile
							AND mp.OfficeID = fa.OfficeID
					FOR XML RAW ('mobilePhone'), ELEMENTS, TYPE						
				) AS mobilePhoneL
				,(
					SELECT  DISTINCT ImageFilePath AS img, ImageTypeCode as imgTyp
					FROM	Base.vwuPDCPracticeOfficeDetail fa
					WHERE	fa.ImageTypeCode in ('FCOLOGO', 'FCOWALL') --Office Logo and wallpaper
							AND mp.OfficeID = fa.OfficeID
					FOR XML RAW ('image'), ELEMENTS, TYPE
				) AS imageL
	INTO		#Sponsor
	FROM		Mid.PracticeSponsorship ps 
	inner join #PracticeBatch X on X.PracticeID = ps.PracticeID
	INNER JOIN	Mid.Practice mp 
				ON ps.PracticeID = mp.PracticeID
	INNER JOIN	Base.Product bp ON ps.ProductCode = bp.ProductCode
	WHERE		ps.ProductGroupCode = 'PDC'
				AND bp.ProductTypeCode = 'PRACTICE'
	group by	mp.officeid

	IF OBJECT_ID('tempdb..#PracticeSponsorship') IS NOT NULL DROP TABLE #PracticeSponsorship
	SELECT	a.ProductCode as prCd, 
			a.ProductGroupCode AS prGrCd,
			a.ClientCode as spnCd, 
			a.ClientName as spnNm
			,a.PracticeId
	INTO	#PracticeSponsorship
	FROM	Mid.PracticeSponsorship a
	inner join #PracticeBatch X on X.PracticeID = a.PracticeID

	IF OBJECT_ID('tempdb..#Email') IS NOT NULL DROP TABLE #Email
	SELECT	DISTINCT z.EmailAddress as pEmail, z.PracticeID
	INTO	#Email
	FROM	Base.PracticeEmail z
	inner join #PracticeBatch X on X.PracticeID = Z.PracticeID
	WHERE	z.EmailAddress IS NOT NULL
	
	/*Efficiency - original join of vwuProviderIndex in the select into statement below took 30 minutes*/
	IF OBJECT_ID('tempdb..#TempProviderId') IS NOT NULL DROP TABLE #TempProviderId
	create table #TempProviderId (providerID uniqueidentifier not null primary key)
	insert into #TempProviderId (providerID)
	SELECT ProviderID 
	FROM Show.vwuProviderIndex 
	order by ProviderID

	IF OBJECT_ID('tempdb..#PracticeSource') IS NOT NULL DROP TABLE #PracticeSource
	SELECT		DISTINCT x.PracticeID,x.PracticeCode,x.PracticeName,x.YearPracticeEstablished,x.NPI,x.PracticeWebsite,x.PracticeDescription,x.PracticeLogo,x.PracticeMedicalDirector,x.PracticeSoftware,x.PracticeTIN,x.LegacyKeyPractice,x.PhysicianCount,x.HasDentist
	INTO		#PracticeSource
	FROM		Mid.Practice as x --Mid.Practice contains Practice to Office relationships. We MUST join to Office on the OfficeID not the PracticeID.
	inner join	#PracticeBatch z on X.PracticeID = Z.PracticeID 
	INNER JOIN	Base.Office o on x.OfficeID = o.OfficeID
	INNER JOIN	Base.ProviderToOffice po on o.OfficeID = po.OfficeID
	INNER JOIN	#TempProviderId vpi on po.ProviderID = vpi.ProviderID

	IF OBJECT_ID('tempdb..#Practice') IS NOT NULL DROP TABLE #Practice
	CREATE TABLE #Practice(
			[PracticeID] [uniqueidentifier] NULL,
			[PracticeCode] [varchar](25) NULL,
			[PracticeName] [varchar](max) NULL,
			[YearPracticeEstablished] [int] NULL,
			[NPI] [char](10) NULL,
			[PracticeWebsite] [varchar](max) NULL,
			[PracticeDescription] [varchar](max) NULL,
			[PracticeLogo] [varchar](max) NULL,
			[PracticeMedicalDirector] [varchar](max) NULL,
			[PracticeSoftware] [varchar](max) NULL,
			[PracticeTIN] [char](9) NULL,
			[LegacyKeyPractice] [varchar](max) NULL,
			[PhysicianCount] [int] NULL,
			[HasDentist] [smallint] NOT NULL,
			[OfficeXML] [xml] NULL,
			[SponsorshipXML] [xml] NULL,
			[UpdatedDate] [datetime] NOT NULL,
			[UpdatedSource] [nvarchar](128) NULL,
			[PracticeEmailXML] [xml] NULL
		) 
	

	TRUNCATE TABLE #Practice
	INSERT INTO #Practice(PracticeID,PracticeCode,PracticeName,YearPracticeEstablished,NPI,PracticeWebsite,PracticeDescription,PracticeLogo,PracticeMedicalDirector,PracticeSoftware,PracticeTIN,LegacyKeyPractice,PhysicianCount,HasDentist,OfficeXML,SponsorshipXML,UpdatedDate,UpdatedSource,PracticeEmailXML)
	select	PracticeID,PracticeCode,PracticeName,YearPracticeEstablished,NPI,PracticeWebsite,PracticeDescription,PracticeLogo,PracticeMedicalDirector,PracticeSoftware,PracticeTIN,LegacyKeyPractice,PhysicianCount,HasDentist,OfficeXML,SponsorshipXML,UpdatedDate,UpdatedSource 
			,(
				SELECT	DISTINCT pEmail
				FROM	#Email z
				WHERE	z.PracticeID = my.PracticeID
						FOR XML RAW( '' ), ELEMENTS, TYPE, ROOT( 'pEmailL' )
			) as PracticeEmailXML
	FROM(
		SELECT		x.PracticeID,x.PracticeCode,x.PracticeName,x.YearPracticeEstablished,x.NPI,x.PracticeWebsite,x.PracticeDescription,x.PracticeLogo,x.PracticeMedicalDirector,x.PracticeSoftware,x.PracticeTIN,x.LegacyKeyPractice,x.PhysicianCount,x.HasDentist
					,(
						SELECT	a.OfficeCode as oID
								,a.OfficeName as oNm
								,a.OfficeRank as oRank
								,a.AddressTypeCode as addTp
								,a.AddressLine1 as ad1 
								,a.AddressLine2 as ad2
								,a.AddressLine3 as ad3
								,a.AddressLine4 as ad4
								,a.City as city
								,a.State as st
								,a.ZipCode as zip
								,a.Latitude as lat
								,a.Longitude as lng
								,a.HasBillingStaff as isBStf
								,a.HasHandicapAccess isHcap
								,a.HasLabServicesOnSite as isLab
								,a.HasPharmacyOnSite as isPhrm
								,a.HasXrayOnSite isXray
								,a.IsSurgeryCenter as isSrg
								,a.HasSurgeryOnSite hasSrg
								,a.AverageDailyPatientVolume as avVol
								,a.OfficeCoordinatorName as ocNm
								,a.ParkingInformation as prkInf
								,a.PaymentPolicy as payPol
								,(
									SELECT		DISTINCT day, dispOrder, [start], [end], closed, open24Hrs 
									FROM		#hours s
									WHERE		s.OfficeID = a.OfficeID
									ORDER		BY s.dispOrder
												FOR XML RAW('hours'),ELEMENTS,ROOT('hoursL'),TYPE
								)
								,(
									SELECT	DISTINCT phFull
									FROM	#phone s
									WHERE	s.OfficeID = a.OfficeID
									FOR XML RAW( '' ), ELEMENTS, TYPE, ROOT( 'phL' )
								)
								,(
									SELECT	DISTINCT faxFull
									FROM	#Fax s
									WHERE	s.OfficeID = a.OfficeID
																
									FOR XML RAW( '' ), ELEMENTS, TYPE, ROOT( 'faxL' )
								)
								,(
									SELECT	DISTINCT spCd, spY, spIst, spIsts, lKey
									FROM	#Specialty s
									WHERE	s.OfficeID = a.OfficeID
									FOR XML RAW ('spc'), ELEMENTS, ROOT('spcL'), TYPE  
								)
									,(
										SELECT	phoneL, mobilePhoneL, imageL
										FROM	#Sponsor s
										WHERE	s.OfficeID = a.OfficeID
										FOR XML RAW ('disp'), ELEMENTS, ROOT('dispL'), TYPE
									) as 'sponsor'
									,a.LegacyKeyOffice AS oLegacyID
									,SUBSTRING(a.LegacyKeyOffice, 5,8) as oLegacyID
									,a.OfficeRank as oRank
									,a.OfficeUrl AS PracticeURL
									,a.GoogleScriptBlock
						FROM		Mid.Practice a
						INNER JOIN	Base.CityStatePostalCode b WITH (NOLOCK) ON a.CityStatePostalCodeID = b.CityStatePostalCodeID
						INNER JOIN	Base.State c ON c.state = b.state
						WHERE		a.PracticeID = x.PracticeID 
						GROUP BY	a.PracticeID, a.OfficeCode, a.OfficeName, a.OfficeRank, a.AddressTypeCode, a.AddressLine1, a.AddressLine2, a.AddressLine3, a.AddressLine4,a.City, a.State, a.ZipCode, a.Latitude, a.Longitude, a.HasBillingStaff, a.HasHandicapAccess, a.HasLabServicesOnSite, a.HasPharmacyOnSite, a.HasXrayOnSite,a.IsSurgeryCenter, a.HasSurgeryOnSite, a.AverageDailyPatientVolume, a.OfficeCoordinatorName, a.ParkingInformation, a.PaymentPolicy, a.LegacyKeyOffice, a.OfficeID,c.StateName,b.State,b.City,a.PracticeName,a.OfficeUrl,a.GoogleScriptBlock
						ORDER BY	a.AddressLine1, a.State
						FOR XML	RAW( 'off' ), ELEMENTS, TYPE, ROOT( 'offL' )
					) as OfficeXML
					,(--Sponsorship 
						SELECT	a.prCd, 
								a.prGrCd,
								a.spnCd, 
								a.spnNm
						FROM	#PracticeSponsorship a
						WHERE	a.PracticeID = x.PracticeID 
						FOR XML RAW ('sponsor'), ELEMENTS, ROOT('sponsorL'), TYPE
					) as SponsorshipXML									
					,GETDATE() AS UpdatedDate
					,USER_NAME() AS UpdatedSource
		from		#PracticeSource X
		inner join #PracticeBatch z on X.PracticeID = Z.PracticeID
		GROUP BY	x.PracticeID, x.PracticeCode, x.PracticeName, x.YearPracticeEstablished, x.NPI, /*x.PracticeEmail,*/ x.PracticeWebsite, x.PracticeDescription, x.PracticeLogo,x.PracticeMedicalDirector, x.PracticeSoftware, x.PracticeTIN, x.LegacyKeyPractice, x.PracticeID, x.PhysicianCount,x.HasDentist
	)my

	DELETE		T
	--SELECT		*
	FROM		Show.SOLRPractice T
	INNER JOIN	#Practice S ON S.PracticeID = T.PracticeID

	INSERT		Show.SOLRPractice(PracticeID,PracticeCode,PracticeName,YearPracticeEstablished,NPI,PracticeEmailXML,PracticeWebsite,PracticeDescription,PracticeLogo,PracticeMedicalDirector,PracticeSoftware,PracticeTIN,LegacyKeyPractice,PhysicianCount,HasDentist,OfficeXML,SponsorshipXML, UpdatedDate,UpdatedSource)
	SELECT		S.PracticeID,S.PracticeCode,S.PracticeName,S.YearPracticeEstablished,S.NPI,S.PracticeEmailXML,S.PracticeWebsite,S.PracticeDescription,S.PracticeLogo,S.PracticeMedicalDirector,S.PracticeSoftware,S.PracticeTIN,S.LegacyKeyPractice,S.PhysicianCount,S.HasDentist,S.OfficeXML,S.SponsorshipXML,S. UpdatedDate,S.UpdatedSource
	FROM		#Practice S
	LEFT JOIN	Show.SOLRPractice T
				ON T.PracticeID = S.PracticeID
	WHERE		T.PracticeId IS NULL
		
	DELETE [Show].[vwuPracticeIndex] WHERE PracticeCode = 'PC9A16C'
	DELETE ods1stage.show.SOLRPractice where PracticeName = 'Practice'

END TRY