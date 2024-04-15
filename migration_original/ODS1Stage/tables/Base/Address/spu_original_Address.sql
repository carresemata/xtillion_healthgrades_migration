--- 1. etl_spuMergeFacilityAddress (snowflake db) line 72

if object_id('tempdb..#swimlane') is not null drop table #swimlane
        select	distinct x.FacilityID
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
    

		INSERT INTO ODS1Stage.Base.Address(AddressId, NationId, AddressLine1, Latitude, Longitude, TimeZone, CityStatePostalCodeId)
		SELECT		NewId(), '00415355-0000-0000-0000-000000000000', S.AddressLine1, S.Latitude, S.Longitude, refTimeZoneCode, S.CityStatePostalCodeId
		FROM(
			SELECT		DISTINCT S.AddressLine1, S.Latitude, S.Longitude, null as refTimeZoneCode, CSP.CityStatePostalCodeId
			FROM		#swimlane S
			INNER JOIN	ODS1Stage.Base.CityStatePostalCode CSP 
						ON CSP.City = S.City
						AND CSP.State = S.State
						AND CSP.PostalCode = S.PostalCode
			LEFT JOIN	ODS1Stage.Base.Address A
						ON A.AddressLine1 = S.AddressLine1
						AND CSP.CityStatePostalCodeId = A.CityStatePostalCodeId
			WHERE		A.AddressId IS NULL
		)S

		update	c 
		set		c.AddressCode = 'AD'+right(convert(varchar(50),convert(binary(20),AddressInt,0),1),10)
		from	ODS1Stage.Base.Address as c
		where	c.AddressCode is null







 --------------- 2. etl_spuMergeOfficeAddress (snowflake db) (line 61)
 exec etl.spuMergeCityStatePostalCode

	if object_id('tempdb..#SwimLane') is not null drop table #SwimLane
	select	distinct identity(int, 1,1) as swimlaneID
			,cast(null as uniqueidentifier) as CityStatePostalCodeID
			,cast(null as uniqueidentifier) as NationID
			,cast(null as uniqueidentifier) as AddressId
			,convert(uniqueidentifier, convert(varbinary(20), y.AddressTypeCode)) as AddressTypeID, y.AddressTypeCode
			,x.OfficeID,y.OfficeName,y.AddressRank,y.AddressLine1,y.AddressLine2,y.Suite,y.City,y.State,y.PostalCode,y.Latitude,y.Longitude,y.TimeZone,y.DoSuppress,y.IsDerived,y.LastUpdateDate,y.SourceCode,x.OfficeCode
			,row_number() over(partition by x.OfficeID, y.AddressLine1, y.AddressLine2, y.Suite, y.City, y.State, y.PostalCode order by x.CREATE_DATE desc) as RowRankOfficeAddress
			,row_number() over(partition by y.AddressLine1, y.AddressLine2, y.Suite, y.City, y.State, y.PostalCode order by x.CREATE_DATE desc) as RowRankAddress
	into	#swimlane
	from(
		select	w.CREATE_DATE, w.ReltioEntityID, w.OfficeCode, w.OfficeID, w.OfficeJSON
		from(
			select		p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.OFFICE_CODE as OfficeCode, p.OfficeID, 
						json_query(p.PAYLOAD, '$.EntityJSONString.Address')  as OfficeJSON
			from		raw.OfficeProfileProcessingDeDup as d with (nolock)
			inner join	raw.OfficeProfileProcessing as p with (nolock) 
						on p.rawOfficeProfileID = d.rawOfficeProfileID
            where		p.PAYLOAD is not null 
		) as w
		where	w.OfficeJSON is not null
	) as x
	cross apply(
		select	*
		from	openjson(x.OfficeJSON) with (
					AddressTypeCode varchar(50) '$.AddressTypeCode', 
					ResidentialDelivery varchar(1) '$.ResidentialDelivery', 
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
					IsDerived bit '$.IsDerived', LastUpdateDate datetime '$.LastUpdateDate', 
					OfficeCode varchar(50) '$.OfficeCode', SourceCode varchar(25) '$.SourceCode'
				)
	) as y
	where	isnull(y.DoSuppress, 0) = 0 
			and nullif(y.City,'') is not null 
			and nullif(y.State,'') is not null 
			and nullif(y.PostalCode,'') is not null
			and len(upper(ltrim(rtrim(AddressLine1))) + isnull(upper(ltrim(rtrim(AddressLine2))),'') + isnull(upper(ltrim(rtrim(Suite))),'')) > 0
			
	update	#swimlane
	set		City = left(ltrim(rtrim(City)),len(City)-1)
	where	ltrim(rtrim(City)) like '%,'
 
	update		T
	set			State = S.State
	from		#swimlane T
	inner join	ODS1Stage.Base.State S
				on ltrim(rtrim(S.StateName)) = ltrim(rtrim(T.State))
				
	update		s
	set			CityStatePostalCodeID = c.CityStatePostalCodeID
				,NationID = c.NationID
				--,Compare = HASHBYTES('MD5', (UPPER(LTRIM(RTRIM(s.AddressLine1))) + '|' + ISNULL(UPPER(LTRIM(RTRIM(s.AddressLine2))),'') + '|' + ISNULL(UPPER(LTRIM(RTRIM(s.Suite))),'') + '|' + ISNULL(UPPER(LTRIM(RTRIM(s.City))),'') + '|' + ISNULL(UPPER(LTRIM(RTRIM(s.State))),'') + '|' + ISNULL(UPPER(LTRIM(RTRIM(s.PostalCode))),''))) 
	--SELECT		S.*, C.*
	from		#swimlane as s
	inner join	ODS1Stage.Base.CityStatePostalCode as c on c.City = s.City and c.State = s.State and c.PostalCode = s.PostalCode
	
	if @OutputDestination = 'ODS1Stage' begin
		insert into	ODS1Stage.Base.Address (AddressID, CityStatePostalCodeID, NationID, AddressLine1, AddressLine2, Latitude, Longitude, TimeZone, Suite, LastUpdateDate)
		select		newid(), S.CityStatePostalCodeID, S.NationID, S.AddressLine1, S.AddressLine2, S.Latitude, S.Longitude, S.TimeZone, S.Suite, getutcdate()
					--select S.*
		from		#swimlane S
		left join	ODS1Stage.Base.Address as a with (nolock)	
					on isnull(upper(ltrim(rtrim(S.AddressLine1))),'') = isnull(upper(ltrim(rtrim(a.AddressLine1))),'')
					and isnull(upper(ltrim(rtrim(S.AddressLine2))),'') = isnull(upper(ltrim(rtrim(a.AddressLine2))),'')
					and isnull(upper(ltrim(rtrim(S.Suite))),'') = isnull(upper(ltrim(rtrim(a.Suite))),'') 
					and S.CityStatePostalCodeID = a.CityStatePostalCodeID
		where		S.RowRankAddress = 1
					and S.CityStatePostalCodeID is not null
					and a.AddressID is null
				
		/************************************************************************************************************************************
			Create new AddressCode from AddressInt for now AddressCode can't be a computed column as it currently comes from HealthMaster
		************************************************************************************************************************************/	
		update	c 
		set		c.AddressCode = 'AD'+right(convert(varchar(50),convert(binary(20),AddressInt,0),1),10)
		from	ODS1Stage.Base.Address as c
		where	c.AddressCode is null


--  ODSFix.spuOfficeDuplicateSuiteAddress (line 155)