	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct identity(int, 1, 1) as swimlaneID, 
        case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
		x.ProviderCode, r2.OrganizationID, y.OrganizationCode, r1.PositionID, y.PositionCode, y.DoSuppress, y.LastUpdateDate, y.PositionEndDate, y.PositionRank, y.PositionStartDate, y.SourceCode
    into #swimlane
    from
    (
		select w.* 
		from
		(
			select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
				json_query(p.PAYLOAD, '$.EntityJSONString.Organization') as ProviderJSON
			from raw.ProviderProfileProcessingDeDup as d with (nolock)
			inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
			where p.PAYLOAD is not null 
		) as w
		where w.ProviderJSON is not null
	) as x
	cross apply 
	(
		select *
		from openjson(x.ProviderJSON) with (DoSuppress bit '$.DoSuppress', LastUpdateDate date '$.LastUpdateDate', 
			OrganizationCode varchar(50) '$.OrganizationCode', 
			PositionCode varchar(50) '$.PositionCode', 
			PositionEndDate date '$.PositionEndDate', 
			PositionRank int '$.PositionRank', 
			PositionStartDate date '$.PositionStartDate', 
			SourceCode varchar(50) '$.SourceCode')
	) as y
	inner join ODS1Stage.Base.Position r1 on r1.PositionCode = y.PositionCode
	inner join ODS1Stage.Base.Organization r2 on r2.OrganizationCode = y.OrganizationCode 
	left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode

    if @OutputDestination = 'ODS1Stage' begin
	    --Delete all ProviderToOrganization (child) records for all parents in the #swimlane
	    delete pc
	    --select *
		--select count(*)
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderToOrganization as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderToOrganization child records
	    insert into ODS1Stage.Base.ProviderToOrganization (SourceCode, ProviderToOrganizationID, ProviderID, OrganizationID, PositionID, 
	        PositionStartDate, PositionEndDate, PositionRank, LastUpdateDate, InsertedBy)
	    select isnull(s.SourceCode, 'Profisee'), newid(), s.ProviderID, s.OrganizationID, s.PositionID, s.PositionStartDate, s.PositionEndDate, 
	        s.PositionRank, isnull(s.LastUpdateDate, getutcdate()), suser_name()
	    from #swimlane as s
		where (s.ProviderID is not null and s.OrganizationID is not null and s.PositionID is not null)
	end

	if @OutputDestination = 'ODS1Stage' and @IsTestRun = 0 begin
		insert into DBMetrics.dbo.ProcessStatus ( ServerName, ProcessName, ProcessSource, StepName, StepDescription, ProcessStatus )
		select @@SERVERNAME, 'SF to ' + replace(db_name(), 'Snow' + 'flake', 'ODS1' + 'Stage'), 'EDP Pipeline', object_name(@@PROCID), 'exec ' + object_name(@@PROCID), 'Complete'
	end