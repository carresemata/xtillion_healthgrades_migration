-- etl.spumergecitystatepostalcode (line 61, run inside etl.spumergeofficeaddress)

IF OBJECT_ID('tempdb..#SwimLane') IS NOT NULL DROP TABLE #SwimLane
	SELECT	DISTINCT y.City, y.State, y.PostalCode
	INTO	#swimlane
	FROM(
		SELECT	w.CREATE_DATE, w.ReltioEntityID, w.OfficeCode, w.OfficeID, w.OfficeJSON
		FROM(
			SELECT		p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.OFFICE_CODE as OfficeCode, p.OfficeID, 
						json_query(p.PAYLOAD, '$.EntityJSONString.Address')  as OfficeJSON
			FROM		raw.OfficeProfileProcessingDeDup as d with (nolock)
			INNER JOIN	raw.OfficeProfileProcessing as p with (nolock) on p.rawOfficeProfileID = d.rawOfficeProfileID
			WHERE		p.PAYLOAD is not null
		) AS w
		WHERE	w.OfficeJSON IS NOT NULL
	) AS x
	CROSS APPLY(
		SELECT	*
		FROM	openjson(x.OfficeJSON) with 
                (AddressTypeCode varchar(50) '$.AddressTypeCode', 
				OfficeName varchar(100) '$."OfficeName"',
				AddressRank int '$.Rank',
				AddressLine1 varchar(50) '$.AddressLine1',
				AddressLine2 varchar(50) '$.AddressLine2',
				Suite varchar(50) '$.Suite',
				City varchar(50) '$.City',
				State varchar(50) '$.StateProvince',
				PostalCode varchar(50) '$.PostalCode',
				Latitude varchar(50) '$.Latitude',
				Longitude varchar(50) '$.Longitude',
				TimeZone varchar(50) '$.TimeZone',
				DoSuppress bit '$.DoSuppress', 
				IsDerived bit '$.IsDerived', 
                LastUpdateDate datetime '$.LastUpdateDate', 
				OfficeCode varchar(50) '$.OfficeCode', 
                SourceCode varchar(25) '$.SourceCode')
	) AS y
	WHERE	isnull(y.DoSuppress, 0) = 0 
			AND nullif(y.City,'') IS NOT NULL 
			AND nullif(y.State,'') IS NOT NULL 
			AND nullif(y.PostalCode,'') IS NOT NULL
			AND LEN(UPPER(LTRIM(RTRIM(AddressLine1))) + ISNULL(UPPER(LTRIM(RTRIM(AddressLine2))),'') + ISNULL(UPPER(LTRIM(RTRIM(Suite))),'')) > 0

	UPDATE	#swimlane
	SET		City = LEFT(LTRIM(RTRIM(CITY)),LEN(CITY)-1)
	WHERE	LTRIM(RTRIM(City)) LIKE '%,'
	
	UPDATE		T
	SET			State = S.State
	FROM		#swimlane T
	INNER JOIN	ODS1Stage.Base.State S
				ON LTRIM(RTRIM(S.StateName)) = LTRIM(RTRIM(T.State))

    INSERT INTO	ODS1Stage.Base.CityStatePostalCode (CityStatePostalCodeID, City, State, PostalCode, LastUpdateDate)
    SELECT		newid(), s.City, s.State, s.PostalCode, GETDATE()
    FROM		#swimlane as s
	INNER JOIN	ODS1Stage.Base.[State] dST WITH(NOLOCK)
				ON dST.[State] = s.[State]
	LEFT JOIN	ODS1Stage.Base.CityStatePostalCode dCSP WITH(NOLOCK)
				ON dCSP.City = S.City
				AND dCSP.[State] = s.[State]
				AND dCSP.PostalCode = s.PostalCode
	WHERE		dCSP.CityStatePostalCodeID IS NULL
	
    INSERT INTO	ODS1Stage.Base.CityStatePostalCode (CityStatePostalCodeID, City, State, PostalCode, LastUpdateDate)
    SELECT		newid(), s.City, s.State, s.PostalCode, GETDATE()
    FROM		#swimlane as s
	INNER JOIN	ODS1Stage.Base.[State] dST WITH(NOLOCK)
				ON dST.[State] = dST.[StateName]
	LEFT JOIN	ODS1Stage.Base.CityStatePostalCode dCSP WITH(NOLOCK)
				ON dCSP.City = S.City
				AND dCSP.[State] = dST.[StateName]
				AND dCSP.PostalCode = s.PostalCode
	WHERE		dCSP.CityStatePostalCodeID IS NULL


-- etl.spumergefacilityaddress (line 72)

if object_id('tempdb..#swimlane') is not null drop table #swimlane
        select	distinct f.FacilityID
				,y.AddressLine1
				,y.City
				,y.State
				,y.Country
				,y.PostalCode
				,y.Latitude
				,y.Longitude
				,y.SourceCode
				,x.FacilityCode
				,row_number() over(partition by x.FacilityID order by x.CREATE_DATE desc) as RowRank
        into #swimlane
        from
        (
            select w.* 
            from
            (
                select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.Facility_CODE as FacilityCode, p.FacilityID, 
                    json_query(p.PAYLOAD, '$.EntityJSONString.Address')  as FacilityJSON
                from raw.FacilityProfileProcessingDeDup as d with (nolock)
                inner join raw.FacilityProfileProcessing as p with (nolock) on p.rawFacilityProfileID = d.rawFacilityProfileID
				--from(select * from Snowflake.raw.FacilityProfileComplete_20201026_132026_483 ) p
                where p.PAYLOAD is not null
            ) as w
            where w.FacilityJSON is not null
        ) as x
        cross apply 
        (
            select *
            from openjson(x.FacilityJSON) with (
			    AddressLine1 varchar(150) '$.AddressLine1'
			    ,City varchar(150)  '$.City'
				,State varchar(50)  '$.StateProvince'
				,Country varchar(50)  '$.Country'
				,PostalCode varchar(50)  '$.PostalCode'
				,Latitude varchar(50)  '$.Latitude'
				,Longitude varchar(50)  '$.Longitude'
                ,LastUpdateDate datetime2 '$.LastUpdateDate'
			    ,SourceCode varchar(80) '$.SourceCode'
		    )
        ) as y
		join ODS1Stage.Base.Facility f on x.FacilityCode=f.FacilityCode
		where nullif(y.City,'') is not null 
			and nullif(y.State,'') is not null 
			and nullif(y.PostalCode,'') is not null
    
		IF OBJECT_ID('tempdb..#TempCityStatePostal') IS NOT NULL DROP TABLE #TempCityStatePostal
		SELECT	DISTINCT City,State,PostalCode, Latitude, Longitude
		INTO	#TempCityStatePostal
		FROM	#swimlane

		INSERT INTO ODS1Stage.Base.CityStatePostalCode(CityStatePostalCodeId, City, State, PostalCode, CentroidLatitude, CentroidLongitude, NationId, LastUpdateDate)
		SELECT		NewId(), S.City, S.State, S.PostalCode, S.Latitude, S.Longitude, '00415355-0000-0000-0000-000000000000', getdate()
		FROM(
			SELECT DISTINCT S.City, S.State, S.PostalCode, S.Latitude, S.Longitude
			FROM #TempCityStatePostal S
				LEFT JOIN ODS1Stage.Base.CityStatePostalCode T ON T.City = S.City AND T.State = S.State AND T.PostalCode = S.PostalCode
			WHERE T.CityStatePostalCodeId IS NULL
		) S


