-- etl.spumergeproviderprovidertype
begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
	select	distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID
			,x.ProviderCode
			,convert(uniqueidentifier, convert(varbinary(20), isnull(y.ProviderTypeCode,'ALT'))) as ProviderTypeID
			,getdate() as LastUpdateDate
			,isnull(y.ProviderTypeRankCalculated,1) as ProviderTypeRank
			,null as ProviderTypeRankCalculated
			,'Profisee' as SourceCode
			,isnull(y.ProviderTypeCode,'ALT') as ProviderTypeCode
			,row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), isnull(y.ProviderTypeCode,'ALT') order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
            json_query(p.PAYLOAD, '$.EntityJSONString.ProviderType') as ProviderJSON
        from raw.ProviderProfileProcessingDeDup as d with (nolock)
        inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
        where p.PAYLOAD is not null
    ) as x
    left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (DoSuppress bit '$.DoSuppress', LastUpdateDate datetime '$.LastUpdateDate', 
            ProviderTypeCode varchar(50) '$.ProviderTypeCode', ProviderTypeRank int '$.ProviderTypeRank', 
            ProviderTypeRankCalculated int '$.ProviderTypeRankCalculated', SourceCode varchar(50) '$.SourceCode')
    ) as y
    
    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderToProviderType (child) records for all parents in the #swimlane
	    delete pc
        --select count(*)
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderToProviderType as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderToProviderType child records
	    insert into ODS1Stage.Base.ProviderToProviderType (ProviderToProviderTypeID, ProviderID, ProviderTypeID, SourceCode, ProviderTypeRank, ProviderTypeRankCalculated, LastUpdateDate)
	    select newid(), s.ProviderID, s.ProviderTypeID, isnull(s.SourceCode, 'Profisee'), s.ProviderTypeRank, isnull(s.ProviderTypeRankCalculated, ((2147483647))) as ProviderTypeRankCalculated, isnull(s.LastUpdateDate, getutcdate())
	    from #swimlane as s
		join ODS1Stage.Base.Provider p on s.ProviderID=p.ProviderID
		join ODS1Stage.Base.ProviderType pt on s.ProviderTypeID=pt.ProviderTypeID
	    where s.RowRank = 1	
		    and (s.ProviderID is not null and s.ProviderTypeID is not null)
	
	    --Make all providers in raw.ProviderProfileProcessing ProviderType = 'ALT' if they don't have a provider type
	    insert into ODS1Stage.Base.ProviderToProviderType (ProviderToProviderTypeID, ProviderID, ProviderTypeID, SourceCode, ProviderTypeRank, ProviderTypeRankCalculated, LastUpdateDate)
	    select	newid() as ProviderToProviderTypeID, x.ProviderID, 
				convert(uniqueidentifier, convert(varbinary(20), 'ALT')) as ProviderTypeID,
				'Profisee' as SourceCode,
				1 as ProviderTypeRank,
				2147483647 as ProviderTypeRankCalculated,
				isnull(x.LastUpdateDate, getutcdate())
	    from
	    (    
	        select p2.ProviderID, max(p.CREATE_DATE) as LastUpdateDate
	        from raw.ProviderProfileProcessing as p with (nolock)
            inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.PROVIDER_CODE
	        where not exists (select 1 from ODS1Stage.Base.ProviderToProviderType as ppt where ppt.ProviderID = p2.ProviderID)
	        group by p2.ProviderID
	    ) as x
	end