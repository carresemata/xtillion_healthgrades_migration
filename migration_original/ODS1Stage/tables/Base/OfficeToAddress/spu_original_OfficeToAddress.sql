-- etl.spumergeofficeaddress
begin
	
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
	
		/************************************************************************************************************************************
			Create new AddressCode from AddressInt for now AddressCode can't be a computed column as it currently comes from HealthMaster
		************************************************************************************************************************************/	
		update		S
		set			AddressId = a.AddressID
		--SELECT		NEWID(), S.CityStatePostalCodeID, S.NationID, S.AddressLine1, S.AddressLine2, S.Latitude, S.Longitude, S.TimeZone, S.Suite, getutcdate()
		from		#swimlane S
		inner join	ODS1Stage.Base.Address as a with (nolock)	
					on isnull(upper(ltrim(rtrim(S.AddressLine1))),'') = isnull(upper(ltrim(rtrim(a.AddressLine1))),'')
					and isnull(upper(ltrim(rtrim(S.AddressLine2))),'') = isnull(upper(ltrim(rtrim(a.AddressLine2))),'')
					and isnull(upper(ltrim(rtrim(S.Suite))),'') = isnull(upper(ltrim(rtrim(a.Suite))),'') 
					and S.CityStatePostalCodeID = a.CityStatePostalCodeID

		/************************************************************************************************************************************
			Delete all OfficeToAddress (child) records for all parents in the #swimlane
		************************************************************************************************************************************/	
		if object_id('tempdb..#DeleteOfficeToAddress') is not null drop table #DeleteOfficeToAddress
		select	distinct OfficeID
		into	#DeleteOfficeToAddress
		from	#swimlane s
		where	s.RowRankOfficeAddress = 1
				and s.AddressId is not null

		delete		pc
		--select COUNT(1)
		from		#DeleteOfficeToAddress as p with (nolock)
		inner join	ODS1Stage.Base.OfficeToAddress as pc on pc.OfficeID = p.OfficeID
	
		/************************************************************************************************************************************
			Insert into ODS1Stage.Base.OfficeToAddress
		************************************************************************************************************************************/	
		insert into ODS1Stage.Base.OfficeToAddress (OfficeToAddressID, AddressTypeID, OfficeID, AddressID, SourceCode, IsDerived, LastUpdateDate)
		select		newid() as OfficeToAddressID, X.AddressTypeID, X.OfficeID, X.AddressId, X.SourceCode, X.IsDerived, X.LastUpdateDate		
		from(
			select		distinct isnull(S.AddressTypeID,convert(uniqueidentifier, convert(varbinary(20), 'OFFICE'))) as AddressTypeID, S.OfficeID, S.AddressId, 'Reltio' as SourceCode, 0 as IsDerived, getdate() LastUpdateDate		
			from		#swimlane S
			inner join	ODS1Stage.Base.Office O
						on O.OfficeID = S.OfficeID
			left join	ODS1Stage.Base.OfficeToAddress OA
						on OA.OfficeID = S.OfficeID 
			where		S.RowRankOfficeAddress = 1
						and S.AddressId is not null
						and OA.OfficeToAddressID is null
		)X
	end