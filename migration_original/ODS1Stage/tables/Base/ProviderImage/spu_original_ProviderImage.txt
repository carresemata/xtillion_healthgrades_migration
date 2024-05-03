-- etl.spumergeproviderimage
begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
		x.ProviderCode,
        convert(uniqueidentifier, convert(varbinary(20), y.MediaContextTypeCode)) as MediaContextTypeID, y.MediaContextTypeCode,
                dMIH.MediaImageHostID, y.MediaImageHostCode,
        convert(uniqueidentifier, convert(varbinary(20), isnull(y.MediaImageTypeCode,'PHYSPHOT'))) as MediaImageTypeID, y.MediaImageTypeCode,
        convert(uniqueidentifier, convert(varbinary(20), y.MediaReviewLevelCode)) as MediaReviewLevelID, y.MediaReviewLevelCode,
        convert(uniqueidentifier, convert(varbinary(20), y.MediaSizeCode)) as MediaSizeID, y.MediaSizeCode,
        y.DoSuppress, y.MediaFileName as FileName, y.ImagePath,
		case when y.MediaImageHostCode='Legacy' then null else y.ExternalIdentifier end as ExternalIdentifier,
        y.LastUpdateDate, y.SourceCode, 
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.MediaImageTypeCode, y.MediaSizeCode, y.MediaContextTypeCode, y.MediaImageHostCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Image') as ProviderJSON
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
        from openjson(x.ProviderJSON) with (
			DoSuppress bit '$.DoSuppress', 
            MediaFileName varchar(2000) '$.FileName',
			ExternalIdentifier varchar(2000) '$.ExternalIdentifier', 
            LastUpdateDate datetime '$.LastUpdateDate', 
            MediaContextTypeCode varchar(50) '$.ContextTypeCode',
			MediaImageHostCode varchar(50) '$.ImageHostCode', 
            MediaImageTypeCode varchar(50) '$.ImageTypeCode',
			MediaReviewLevelCode varchar(50) '$.ReviewLevelCode', 
            MediaSizeCode varchar(50) '$.SizeCode', 
            SourceCode varchar(80) '$.SourceCode', 
            ImagePath varchar(2000) '$.S3Prefix'
		)
    ) as y
    inner join ODS1Stage.Base.MediaImageHost dMIH ON dMIH.MediaImageHostCode = y.MediaImageHostCode
    where y.MediaFileName is not null
    
    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderImage (child) records for all parents in the #swimlane
	    delete pc
	    --select *
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderImage as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderImage child records
	    insert into ODS1Stage.Base.ProviderImage (ProviderImageID, ProviderID, MediaImageTypeID, FileName, MediaSizeID, MediaReviewLevelID, SourceCode, LastUpdateDate, MediaContextTypeID, MediaImageHostID, ExternalIdentifier, ImagePath)
	    select newid(), s.ProviderID, s.MediaImageTypeID, s.FileName, s.MediaSizeID, s.MediaReviewLevelID, isnull(s.SourceCode, 'Profisee'), isnull(s.LastUpdateDate, getutcdate()), s.MediaContextTypeID, s.MediaImageHostID, s.ExternalIdentifier, s.ImagePath
	    from #swimlane as s
	    where s.RowRank = 1	
		and (s.ProviderID is not null)
	end
