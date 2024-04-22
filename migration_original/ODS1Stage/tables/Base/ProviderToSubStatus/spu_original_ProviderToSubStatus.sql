-- etl.spumergeprovidersubstatus

begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
		x.ProviderCode,
        convert(uniqueidentifier, convert(varbinary(20), y.SubStatusCode )) as SubStatusID, y.SubStatusCode, y.DoSuppress, 
        row_number() over(partition by x.ProviderID order by isnull(y.HierarchyRank, 2147483647), ss.SubStatusRank) as HierarchyRank,  --Downstream code in Show.spuSOLRProviderGenerateFromMid expects a HierarchyRank of 1 for the primary substatus -- this row_number() guarantees HierarchyRank of 1 exists
        y.LastUpdateDate, y.SourceCode, y.SubStatusValueA,
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.SubStatusCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane 
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Status') as ProviderJSON
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.ProviderJSON is not null
    ) as x
    left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (DoSuppress bit '$.DoSuppress', 
            HierarchyRank int '$.HierarchyRank', 
            LastUpdateDate datetime '$.LastUpdateDate', 
            SourceCode varchar(25) '$.SourceCode', SubStatusCode varchar(50) '$.StatusCode', 
            SubStatusValueA varchar(25) '$.SubStatusValueA')
    ) as y
    inner join ODS1Stage.Base.SubStatus as ss on ss.SubStatusCode = y.SubStatusCode
    where x.ProviderID is not null and y.SubStatusCode is not null
	
    if @OutputDestination = 'ODS1Stage' begin
		/*Get all providers who are either incarcerated or listed as not an HCP*/
		if object_id('tempdb..#SubStatusFix') is not null drop table #SubStatusFix
		select		distinct t.* , ss.SubStatusRank
		into		#SubStatusFix
		from		#swimlane t
		inner join	ODS1Stage.Base.SubStatus ss on ss.SubStatusID = t.SubStatusID
	
		/*Delete other statuses*/
		delete	T
		--select	* 
		from	#swimlane T
		where	ProviderId in (select ProviderId from #SubStatusFix)
				and SubStatusID not in (select SubStatusID from #SubStatusFix)
				
		;with cteSS as (
			select	*, row_number()over(partition by ProviderId order by SubStatusRank) as RN1
			from	#SubStatusFix
		)
		/*Set these statuses as primary*/
		update T set T.HierarchyRank = S.RN1
		--SELECT		*
		from		#swimlane T
		inner join	cteSS S on S.ProviderId = T.ProviderId and S.SubStatusID = T.SubStatusID
	
	   --Delete all ProviderToSubStatus (child) records for all parents in raw.ProviderProfileProcessingDeDup, no matter if they have a status or not
	    delete pc
        --select count(*)
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderToSubStatus as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderToSubStatus child records
	    insert into ODS1Stage.Base.ProviderToSubStatus (ProviderToSubStatusID, ProviderID, SubStatusID, HierarchyRank, SourceCode, LastUpdateDate)
	    select newid(), s.ProviderID, s.SubStatusID, s.HierarchyRank, s.SourceCode, s.LastUpdateDate
		from #swimlane as s
	    where s.RowRank = 1  --returns one record per provider-substatus