--- 1. etl_spuMergeOfficeAddress (snowflake db) 

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