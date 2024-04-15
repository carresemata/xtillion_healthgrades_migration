-- etl.spumergefacilitytofacilitytype
if not exists (select 1 from DBMetrics.dbo.ProcessStatus a where a.ServerName = @@SERVERNAME and a.ProcessName = 'SF to ' + replace(db_name(), 'Snow' + 'flake', 'ODS1' + 'Stage') and a.ProcessSource = 'EDP Pipeline' and a.StepName = object_name(@@PROCID) and a.ProcessStatus = 'Complete')
    begin
	    if object_id('tempdb..#swimlane') is not null drop table #swimlane
        select	distinct f.FacilityID
				,y.FacilityTypeCode
				,y.SourceCode
				,x.FacilityCode
				,y.LastUpdateDate
        into #swimlane
        from
        (
            select w.* 
            from
            (
                select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.Facility_CODE as FacilityCode, p.FacilityID, 
                    json_query(p.PAYLOAD, '$.EntityJSONString.FacilityType')  as FacilityJSON
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
			    FacilityTypeCode varchar(150) '$.FacilityTypeCode'
                ,LastUpdateDate datetime2 '$.LastUpdateDate'
			    ,SourceCode varchar(80) '$.SourceCode'
		    )
        ) as y
		join ODS1Stage.Base.Facility f on x.FacilityCode=f.FacilityCode

		if @OutputDestination = 'ODS1Stage' begin
			--Delete all FacilityToFacilityType (child) records for all parents in raw.FacilityProfileProcessingDeDup, no matter if they have a status or not
			delete fft
			--select count(*)
			from raw.FacilityProfileProcessingDeDup as f with (nolock)
				join ODS1Stage.Base.Facility as f2 on f2.FacilityID = f.FacilityID
				join ODS1Stage.Base.FacilityToFacilityType as fft on fft.FacilityID = f2.FacilityID

			if object_id('tempdb..#FacilityType') IS NOT NULL DROP TABLE #FacilityType
			select distinct F.FacilityId, FT.FacilityTypeId, S.SourceCode, S.LastUpdateDate
			into #FacilityType
			from #swimlane S
				JOIN ODS1Stage.Base.Facility F ON F.FacilityCode = S.FacilityCode
				JOIN ODS1Stage.Base.FacilityType FT ON FT.FacilityTypeCode = S.FacilityTypeCode
					
			insert into ODS1Stage.Base.FacilityToFacilityType(FacilityToFacilityTypeID, FacilityID, FacilityTypeID, SourceCode, LastUpdateDate)
			select newid(), F.Facilityid, F.FacilityTypeId, isnull(F.SourceCode, 'Profisee'), isnull(F.LastUpdateDate, getdate())
			from #FacilityType F
				LEFT JOIN ODS1Stage.Base.FacilityToFacilityType FtFT ON FtFT.FacilityId = F.FacilityId
			where FtFT.FacilityToFacilityTypeId IS NULL
		end