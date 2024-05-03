-- etl.spumergefacilityaddress

if not exists (select 1 from DBMetrics.dbo.ProcessStatus a where a.ServerName = @@SERVERNAME and a.ProcessName = 'SF to ' + replace(db_name(), 'Snow' + 'flake', 'ODS1' + 'Stage') and a.ProcessSource = 'EDP Pipeline' and a.StepName = object_name(@@PROCID) and a.ProcessStatus = 'Complete')
    begin
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


if @OutputDestination = 'ODS1Stage' begin
		--delete all addresses for the facility
		delete		fa
		--select COUNT(1)
		from		#swimlane as s with (nolock)
		inner join	ODS1Stage.Base.FacilityToAddress as fa on fa.FacilityID = s.FacilityID

		insert into ODS1Stage.Base.FacilityToAddress(FacilityToAddressId, FacilityId, AddressId, AddressTypeId, SourceCode, LastUpdateDate)
		select		newid(), S.FacilityId, S.AddressId, '4946464F-4543-0000-0000-000000000000', SourceCode, getdate()
		from ( 
			select distinct F.FacilityId, A.AddressId, S.SourceCode, row_number() over (partition by F.FacilityId order by A.AddressId) as RN1
			from #swimlane S
				join ODS1Stage.Base.Facility F on F.FacilityID = S.FacilityID
				join ODS1Stage.Base.CityStatePostalCode CSP on CSP.City = S.City AND CSP.State = S.State AND CSP.PostalCode = S.PostalCode
				join ODS1Stage.Base.Address A on A.AddressLine1 = S.AddressLine1 AND CSP.CityStatePostalCodeId = A.CityStatePostalCodeId
			) S
		where RN1 = 1
	end