-- etl_spuMergeFacilityHours
    if not exists (select 1 from DBMetrics.dbo.ProcessStatus a where a.ServerName = @@SERVERNAME and a.ProcessName = 'SF to ' + replace(db_name(), 'Snow' + 'flake', 'ODS1' + 'Stage') and a.ProcessSource = 'EDP Pipeline' and a.StepName = object_name(@@PROCID) and a.ProcessStatus = 'Complete')
    begin
	    if object_id('tempdb..#swimlane') is not null drop table #swimlane
        select distinct f.FacilityID,
            convert(uniqueidentifier, convert(varbinary(20), upper(y.DaysOfWeekCode))) as DaysOfWeekID, 
            y.DoSuppress, y.LastUpdateDate, y.FacilityHoursClosingTime, y.FacilityHoursOpeningTime, 
            y.FacilityIsClosed, y.FacilityIsOpen24Hours, y.SourceCode, x.FacilityCode,
		    row_number() over(partition by x.FacilityID, y.DaysOfWeekCode order by x.CREATE_DATE desc) as RowRank
        into #swimlane
        from
        (
            select w.* 
            from
            (
                select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.Facility_CODE as FacilityCode, p.FacilityID, 
                    json_query(p.PAYLOAD, '$.EntityJSONString.FacilityHours')  as FacilityJSON
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
			    DaysOfWeekCode varchar(50) '$.DaysOfWeekCode'
			    ,DoSuppress bit '$.DoSuppress'
                ,LastUpdateDate datetime2 '$.LastUpdateDate'
			    ,FacilityCode varchar(50) '$.FacilityCode'
                ,FacilityHoursOpeningTime time '$.FacilityHoursOpeningTime'
                ,FacilityHoursClosingTime time '$.FacilityHoursClosingTime'
			    ,FacilityIsClosed bit '$.FacilityIsClosed'
                ,FacilityIsOpen24Hours bit '$.FacilityIsOpen24Hours'
			    ,SourceCode varchar(80) '$.SourceCode'
		    )
        ) as y
		join ODS1Stage.Base.Facility f on x.FacilityCode=f.FacilityCode
        where isnull(y.DoSuppress, 0) = 0
    
		if @OutputDestination = 'ODS1Stage' begin
		   --Delete all FacilityHours (child) records for all parents in the #swimlane
			delete pc
			--select *
			from raw.FacilityProfileProcessingDeDup as d with (nolock)
			inner join raw.FacilityProfileProcessing as p with (nolock) on p.rawFacilityProfileID = d.rawFacilityProfileID
			inner join ODS1Stage.Base.Facility as f with (nolock) on p.Facility_Code=f.FacilityCode
			inner join ODS1Stage.Base.FacilityHours as pc on pc.FacilityID=f.FacilityID
			where pc.SourceCode != 'HG INST' --do not delete this source since they are hacked directly into ODS1Stage.Base.FacilityHours, not through the pipeline

			--Insert all FacilityHours child records
			insert into ODS1Stage.Base.FacilityHours (FacilityHoursID, FacilityId, SourceCode, DaysOfWeekID, FacilityHoursOpeningTime, 
				FacilityHoursClosingTime, FacilityIsClosed, FacilityIsOpen24Hours, LastUpdateDate)
			select distinct newid(), s.FacilityID, isnull(s.SourceCode, 'Profisee'), s.DaysOfWeekID, s.FacilityHoursOpeningTime, s.FacilityHoursClosingTime, s.FacilityIsClosed, s.FacilityIsOpen24Hours, isnull(s.LastUpdateDate, getutcdate())
			from #swimlane as s	
			join ODS1Stage.Base.Facility o on s.FacilityID=o.FacilityID
			where s.FacilityID is not null and s.DaysOfWeekID is not null
				and s.RowRank = 1
		end