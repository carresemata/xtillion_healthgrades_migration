-- etl.spumergefacilitycustomerproduct
	begin

		if object_id('tempdb..#swimlane') is not null drop table #swimlane
		select distinct /*convert(uniqueidentifier, convert(varbinary(20), x.ReltioEntityID)) as FacilityID*/--Dont use until we actually master in Reltio, 
			f.FacilityID,
			x.FacilityCode,
			cp.ClientToProductID,
			y.CustomerProductCode as ClientToProductCode,
			x.ReltioEntityID,
			y.*,
			row_number() over(partition by x.FacilityID order by x.CREATE_DATE desc) as RowRank,
			'Reltio' as SourceCode,
			getutcdate() as LastUpdateDate
		into #swimlane
		from
		(
			select w.* 
			from
			(
				select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.Facility_Code as FacilityCode, p.FacilityID,
					json_query(p.PAYLOAD, '$.EntityJSONString.CustomerProduct') as FacilityJSON
				from raw.FacilityProfileProcessingDeDup as d with (nolock)
				inner join raw.FacilityProfileProcessing as p with (nolock) on p.rawFacilityProfileID = d.rawFacilityProfileID
				where p.PAYLOAD is not null
			) as w
			where w.FacilityJSON is not null
		) as x
		cross apply 
		(
			select *
			from openjson(x.FacilityJSON) with (
				CustomerProductCode varchar(50) '$.CustomerProductCode', 
				DisplayPartnerJSON nvarchar(max) '$.DisplayPartner' as json,
				FeatureFCCIURL varchar(max) '$.FeatureFCCIURL',
				FeatureFCCLURL varchar(max) '$.FeatureFCCLURL',
				FeatureFCFLOGO varchar(max) '$.FeatureFCFLOGO',
				FeatureFCFURL varchar(max) '$.FeatureFCFURL')
		) as y
		join ODS1Stage.Base.Facility f on x.FacilityCode=f.FacilityCode
		join ODS1Stage.Base.ClientToProduct as cp on cp.ClientToProductCode = y.CustomerProductCode
		where x.FacilityCode is not null 

        --URL Updates
		--drop table #tmp_URL
		select FacilityCode, ClientToProductCode, 'FCCIURL' as URLTypeCode, FeatureFCCIURL as URL into #tmp_url from #swimlane where FeatureFCCIURL is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, 'FCCLURL' as URLTypeCode, FeatureFCCLURL as URL from #swimlane where FeatureFCCLURL is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, 'FCFURL' as URLTypeCode, FeatureFCFURL as URL from #swimlane where FeatureFCFURL is not null and RowRank = 1

		--Base.URL Update
		insert into ODS1Stage.Base.URL (URLID, URL, LastUpdateDate)
		select distinct convert(uniqueidentifier, HASHBYTES('SHA1', s.URL)) as URLID, s.URL, getutcdate() as LastUpdateDate
		from #tmp_url s
		where not exists (select 1 from ODS1Stage.Base.URL as p where p.URLID=convert(uniqueidentifier, HASHBYTES('SHA1', s.URL)))