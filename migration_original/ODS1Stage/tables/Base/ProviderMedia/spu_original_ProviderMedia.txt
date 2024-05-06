-- etl.spumergeprovidermedia

begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
		x.ProviderCode,
        convert(uniqueidentifier, convert(varbinary(20), y.MediaTypeCode)) as MediaTypeID, y.MediaTypeCode,
        y.DoSuppress, y.LastUpdateDate, y.MediaDate, y.MediaLink, y.MediaPublisher, y.MediaSynopsis, y.MediaTitle, y.SourceCode, 
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.MediaTypeCode, y.MediaDate, y.MediaLink, y.MediaPublisher, y.MediaSynopsis, y.MediaTitle order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Media') as ProviderJSON
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
        from openjson(x.ProviderJSON) with (DoSuppress bit '$.DoSuppress', LastUpdateDate datetime '$.LastUpdateDate', 
            MediaDate varchar(300) '$.MediaDate', MediaLink varchar(250) '$.MediaLink', 
            MediaPublisher varchar(300) '$.MediaPublisher', MediaSynopsis varchar(4000) '$.MediaSynopsis', 
            MediaTitle varchar(300) '$.MediaTitle', MediaTypeCode varchar(50) '$.MediaTypeCode', 
            SourceCode varchar(25) '$.SourceCode')
    ) as y

    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderMedia (child) records for all parents in the #swimlane
	    delete pc
	    --select *
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderMedia as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderMedia child records
	    insert into ODS1Stage.Base.ProviderMedia (ProviderMediaID, ProviderID, MediaTypeID, MediaDate, MediaTitle, MediaPublisher, MediaSynopsis, MediaLink, SourceCode, LastUpdateDate)
	    select newid(), s.ProviderID, s.MediaTypeID, s.MediaDate, s.MediaTitle, s.MediaPublisher, s.MediaSynopsis, s.MediaLink, isnull(s.SourceCode, 'Profisee'), isnull(s.LastUpdateDate, getdate())
	    from #swimlane as s
	    where s.RowRank = 1
		and (s.ProviderID is not null and MediaTypeID is not null)
	end