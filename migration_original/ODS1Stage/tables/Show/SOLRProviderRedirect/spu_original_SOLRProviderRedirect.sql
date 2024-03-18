-- 1. Show_spuSOLRProviderDeltaRefresh

    -- This only happens when @IsProviderDeltaProcessing = 0
	--get any providers that are in SOLRProvider but not in Mid.Provider and insert them into SOLRProviderRedirect before truncating SOLRProvider
		insert into Show.SOLRProviderRedirect(	ProviderCodeOld, ProviderCodeNew, ProviderURLOld, ProviderURLNew, LastName, FirstName, MiddleName, Suffix, DisplayName, Degree, Title, ProviderTypeID, ProviderTypeGroup, DeactivationReason, GENDer, DateOfBirth, PracticeOfficeXML, SpecialtyXML, EducationXML, ImageXML, LastUpdateDate, UpdateDate, UpdateSource)
		select	a.ProviderCode, a.ProviderCode, a.ProviderURL, a.ProviderURL,
				a.LastName, a.FirstName, a.MiddleName, a.Suffix, 
				a.FirstName + ' ' + case when a.MiddleName is null then '' else a.MiddleName + ' ' END + a.LastName + case when a.Suffix is null then '' else ' ' + a.Suffix END as DisplayName,
				a.Degree, a.Title, a.ProviderTypeID, a.ProviderTypeGroup, 'Deactivated' as DeactivationReason, a.GENDer, a.DateOfBirth, a.PracticeOfficeXML, a.SpecialtyXML, a.EducationXML, a.ImageXML, 
				getdate(), getdate(), suser_name()
		from	Show.SOLRProvider a
		left join Base.Provider b on b.ProviderID = a.ProviderID
		left join Show.SOLRProviderRedirect c on c.ProviderCodeOld = a.ProviderCode
			and c.ProviderCodeNew = a.ProviderCode
			and c.DeactivationReason = 'Deactivated'
		where	b.ProviderID is null
				and c.SOLRProviderRedirectID is null	
				
		--EGS 5/22/19: moved HealthMaster.dbo.ProviderURL to new table Base.ProverURLOld in prep for DB HealthMaster going away
		update c --Show.SOLRProviderRedirect
		set c.ProviderURLOld = a.URL
		from Base.ProviderURL a
		join Base.Provider b on a.ProviderID = b.ProviderID
		join Show.SOLRProviderRedirect c on b.ProviderCode = c.ProviderCodeOld
		where c.ProviderURLOld is null	



-- 2. Show_spuSOLRProviderRedirect

	IF OBJECT_ID('tempdb..#ProviderRedirect') IS NOT NULL DROP TABLE #ProviderRedirect 
			CREATE TABLE #ProviderRedirect(	
					ProviderCodeOld VARCHAR(10), 
					ProviderCodeNew VARCHAR(10), 
					ProviderURLOld VARCHAR(max), 
					ProviderURLNew VARCHAR(max), 
					HGIDOld VARCHAR(50), 
					HGIDNew VARCHAR(50), 
					HGID8Old VARCHAR(8), 
					HGID8New VARCHAR(8), 
					LastName VARCHAR(50), 
					FirstName VARCHAR(50), 
					MiddleName VARCHAR(50), 
					Suffix VARCHAR(50), 
					DisplayName VARCHAR(200), 
					Degree VARCHAR(50), 
					Title VARCHAR(25), 
					DegreePriority int, 
					ProviderTypeID uniqueidentifier, 
					ProviderTypeGroup varchar(10),
					CityState VARCHAR(100), 
					SpecialtyCode VARCHAR(25), 
					SpecialtyLegacyKey VARCHAR(50), 
					DeactivationReason VARCHAR(25), 
					LastUpdateDate datetime, 
					Gender char(1), 
					DateOfBirth datetime, 
					PracticeOfficeXML xml, 
					SpecialtyXML xml, 
					EducationXML xml, 
					ImageXML xml, 
					ExpireCode VARCHAR(10)
										
				)

			INSERT INTO #ProviderRedirect(ProviderCodeOld,ProviderCodeNew,ProviderURLOld,ProviderURLNew,HGIDOld,HGIDNew,HGID8Old,HGID8New,LastName,FirstName,MiddleName,Suffix,DisplayName,Degree,DegreePriority,ProviderTypeID,CityState,SpecialtyCode,SpecialtyLegacyKey,DeactivationReason,LastUpdateDate )
			SELECT ProviderCodeOld,ProviderCodeNew,ProviderURLOld,ProviderURLNew,HGIDOld,HGIDNew,HGID8Old,HGID8New,LastName,FirstName,MiddleName,Suffix,DisplayName,Degree,DegreePriority,ProviderTypeID,CityState,SpecialtyCode,SpecialtyLegacyKey,DeactivationReason,LastUpdateDate 
			FROM(
				SELECT	ProviderCodeOld 
						,ProviderCodeNew 
						,ProviderURLOld 
						,ProviderURLNew 
						,HGIDOld 
						,HGIDNew 
						,HGID8Old 
						,HGID8New 
						,LastName 
						,FirstName 
						,MiddleName 
						,Suffix 
						,DisplayName 
						,Degree 
						,DegreePriority 
						,ProviderTypeID 
						,CityState
						,SpecialtyCode
						,SpecialtyLegacyKey
						,DeactivationReason
						,LastUpdateDate 
						,ROW_NUMBER()OVER(PARTITION BY ProviderCodeOld ORDER BY LastUpdateDate DESC) AS SequenceId
				FROM	Base.ProviderRedirect
				WHERE	ProviderCodeOld NOT IN (SELECT ProviderCodeOld FROM #ProviderRedirect )
						AND ProviderCodeOld NOT IN (SELECT ProviderCode FROM Show.SOLRProvider )
			)X
			WHERE	SequenceId = 1
							
			UPDATE		S
			SET			ProviderCodeOld = T.ProviderCodeOld 
						,ProviderCodeNew = T.ProviderCodeNew 
						,ProviderURLOld = T.ProviderURLOld 
						,ProviderURLNew = T.ProviderURLNew 
						,HGIDOld = T.HGIDOld 
						,HGIDNew = T.HGIDNew 
						,HGID8Old = T.HGID8Old 
						,HGID8New = T.HGID8New 
						,LastName = T.LastName 
						,FirstName = T.FirstName 
						,MiddleName = T.MiddleName 
						,Suffix = T.Suffix 
						,DisplayName = T.DisplayName 
						,Degree = T.Degree 
						,DegreePriority = T.DegreePriority 
						,ProviderTypeID = T.ProviderTypeID 
						,CityState = T.CityState 
						,SpecialtyCode = T.SpecialtyCode 
						,SpecialtyLegacyKey = T.SpecialtyLegacyKey 
						,DeactivationReason = T.DeactivationReason 
						,LastUpdateDate = T.LastUpdateDate
			FROM		Show.SOLRProviderRedirect S
			INNER JOIN	#ProviderRedirect T
						ON T.ProviderCodeOld = S.ProviderCodeOld
			WHERE		T.ProviderCodeOld != S.ProviderCodeOld 
						OR T.ProviderCodeNew != S.ProviderCodeNew 
						OR T.ProviderURLOld != S.ProviderURLOld 
						OR T.ProviderURLNew != S.ProviderURLNew 
						OR T.HGIDOld != S.HGIDOld 
						OR T.HGIDNew != S.HGIDNew 
						OR T.HGID8Old != S.HGID8Old 
						OR T.HGID8New != S.HGID8New 
						OR T.LastName != S.LastName 
						OR T.FirstName != S.FirstName 
						OR T.MiddleName != S.MiddleName 
						OR T.Suffix != S.Suffix 
						OR T.DisplayName != S.DisplayName 
						OR T.Degree != S.Degree 
						OR T.DegreePriority != S.DegreePriority 
						OR T.ProviderTypeID != S.ProviderTypeID 
						OR T.CityState != S.CityState 
						OR T.SpecialtyCode != S.SpecialtyCode 
						OR T.SpecialtyLegacyKey != S.SpecialtyLegacyKey 
						OR T.DeactivationReason != S.DeactivationReason 
						OR T.LastUpdateDate != S.LastUpdateDate

		INSERT		Show.SOLRProviderRedirect(ProviderCodeOld, ProviderCodeNew, ProviderURLOld, ProviderURLNew, HGIDOld, HGIDNew, HGID8Old, HGID8New, LastName, FirstName, MiddleName, Suffix, DisplayName, Degree,Title, DegreePriority, ProviderTypeID,ProviderTypeGroup, CityState, SpecialtyCode, SpecialtyLegacyKey, DeactivationReason, LastUpdateDate, Gender, DateOfBirth, PracticeOfficeXML, SpecialtyXML, EducationXML, ImageXML, ExpireCode,UpdateDate,UpdateSource)
		SELECT		T.ProviderCodeOld
					,T.ProviderCodeNew 
					,T.ProviderURLOld 
					,T.ProviderURLNew 
					,T.HGIDOld 
					,T.HGIDNew 
					,T.HGID8Old 
					,T.HGID8New 
					,T.LastName 
					,T.FirstName 
					,T.MiddleName 
					,T.Suffix 
					,T.DisplayName 
					,T.Degree 
					,T.Title
					,T.DegreePriority 
					,T.ProviderTypeID
					,T.ProviderTypeGroup 
					,T.CityState 
					,T.SpecialtyCode 
					,T.SpecialtyLegacyKey 
					,T.DeactivationReason 
					,T.LastUpdateDate 
					,T.Gender 
					,T.DateOfBirth 
					,T.PracticeOfficeXML 
					,T.SpecialtyXML 
					,T.EducationXML 
					,T.ImageXML 
					,T.ExpireCode
					,GETDATE() AS UpdateDate
					,SUSER_NAME() AS UpdateSource
		FROM		#ProviderRedirect T
		LEFT JOIN	Show.SOLRProviderRedirect S
					ON S.ProviderCodeOld = T.ProviderCodeOld
		WHERE		S.SOLRProviderRedirectID IS NULL

		DELETE		a
		--select COUNT(1)
		FROM		ODS1Stage.SHow.SOLRProviderRedirect a
		INNER JOIN	ODS1Stage.Show.SOLRProvider b on (a.ProviderCodeOld = b.ProviderCode)