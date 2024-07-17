-- etl.spumergeprovidervideo
begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID,
        convert(uniqueidentifier, convert(varbinary(20), y.MediaContextTypeCode)) as MediaContextTypeID, y.MediaContextTypeCode,
        convert(uniqueidentifier, convert(varbinary(20), y.MediaReviewLevelCode)) as MediaReviewLevelID, y.MediaReviewLevelCode,
        convert(uniqueidentifier, convert(varbinary(20), y.MediaVideoHostCode)) as MediaVideoHostID, y.MediaVideoHostCode,
        y.DoSuppress, y.ExternalIdentifier, y.LastUpdateDate, y.SourceCode, x.ProviderCode,
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.MediaContextTypeCode, y.MediaVideoHostCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Video') as ProviderJSON
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
        from openjson(x.ProviderJSON) with (DoSuppress bit '$.DoSuppress', ExternalIdentifier varchar(2000) '$.ExternalIdentifier',
            LastUpdateDate datetime '$.LastUpdateDate', MediaContextTypeCode varchar(50) '$.MediaContextTypeCode',
            MediaReviewLevelCode varchar(50) '$.MediaReviewLevelCode', MediaVideoHostCode varchar(50) '$.MediaVideoHostCode',
            ProviderCode varchar(50) '$.ProviderCode', SourceCode varchar(80) '$.SourceCode')
    ) as y
    where isnull(y.DoSuppress, 0) = 0 and (y.MediaReviewLevelCode is not null or y.MediaContextTypeCode is not null
        or y.MediaReviewLevelCode is not null or y.MediaVideoHostCode is not null)

    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderVideo (child) records for all parents in the #swimlane
	    delete pc
        --select count(*)
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderVideo as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderVideo child records
	    insert into ODS1Stage.Base.ProviderVideo (ProviderVideoID, ProviderID, ExternalIdentifier, MediaVideoHostID, MediaReviewLevelID, SourceCode, LastUpdateDate, MediaContextTypeID)
	    select newid(), s.ProviderID, s.ExternalIdentifier, s.MediaVideoHostID, s.MediaReviewLevelID, isnull(s.SourceCode, 'Profisee'), isnull(s.LastUpdateDate, getutcdate()), s.MediaContextTypeID
	    from #swimlane as s
	    where s.RowRank = 1
		and (s.ProviderID is not null and s.ExternalIdentifier is not null and MediaVideoHostID is not null and MediaReviewLevelID is not null and MediaContextTypeID is not null)
	end