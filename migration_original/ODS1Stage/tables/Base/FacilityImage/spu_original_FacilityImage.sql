-- etl.spumergefacilityimage
if not exists (select 1 from DBMetrics.dbo.ProcessStatus a where a.ServerName = @@servername and a.ProcessName = 'SF to ' + replace(db_name(), 'Snow' + 'flake', 'ODS1' + 'Stage') and a.ProcessSource = 'EDP Pipeline' and a.StepName = object_name(@@PROCID) and a.ProcessStatus = 'Complete')
begin
    select 
		f.FacilityID,
        convert(uniqueidentifier, convert(varbinary(20), y.MediaImageTypeCode)) as MediaImageTypeID, 
        convert(uniqueidentifier, convert(varbinary(20), y.MediaReviewLevelCode)) as MediaReviewLevelID, 
        convert(uniqueidentifier, convert(varbinary(20), y.MediaSizeCode)) as MediaSizeID, 
        y.MediaFileName,
		y.ImagePath,
        y.LastUpdateDate, 
		y.SourceCode, 
        row_number() over(partition by x.FacilityID, y.MediaImageTypeCode, y.MediaSizeCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.FACILITY_CODE as FacilityCode, d.FacilityID,
                json_query(p.PAYLOAD, '$.EntityJSONString.Image')  as FacilityJSON
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
            MediaFileName varchar(2000) '$.FileName', 
            MediaImageTypeCode varchar(50) '$.ImageTypeCode', 
            MediaSizeCode varchar(50) '$.SizeCode', 
			MediaReviewLevelCode varchar(50) '$.ReviewLevelCode',  
            LastUpdateDate datetime '$.LastUpdateDate', 
            SourceCode varchar(80) '$.SourceCode', 
            ImagePath varchar(80) '$.S3Prefix'
			
		)
    ) as y
	join ODS1Stage.Base.Facility f on x.FacilityCode=f.FacilityCode
    where y.MediaFileName is not null and f.FacilityID is not null


   --Delete all FacilityImage (child) records for all parents in the #swimlane
    delete pc
    --select *
    from raw.FacilityProfileProcessingDeDup as d with (nolock)
    inner join raw.FacilityProfileProcessing as p with (nolock) on p.rawFacilityProfileID = d.rawFacilityProfileID
	inner join ODS1Stage.Base.Facility as f with (nolock) on p.Facility_Code=f.FacilityCode
    inner join ODS1Stage.Base.FacilityImage as pc on pc.FacilityID=f.FacilityID
    where pc.SourceCode = 'MergeFacilityImage'

    --Insert all FacilityImage child records
	insert into ODS1Stage.Base.FacilityImage (FacilityImageID, FacilityID, FileName, ImagePath, MediaImageTypeID, MediaSizeID, MediaReviewLevelID, SourceCode, LastUpdateDate)
	select distinct convert(uniqueidentifier, HASHBYTES('SHA1',  concat(a.FacilityID,b.EntityTypeCode,a.MediaImageTypeID, a.MediaFileName) )) as FacilityImageID,
		a.FacilityID, a.MediaFileName, a.ImagePath, c.MediaImageTypeID, d.MediaSizeID, e.MediaReviewLevelID, 'MergeFacilityImage' as SourceCode, getutcdate() as LastUpdateDate
	from #swimlane a
		join ODS1Stage.Base.EntityType b on b.EntityTypeCode='FAC'
		join ODS1Stage.Base.MediaImageType c on c.MediaImageTypeID = a.MediaImageTypeID
		join ODS1Stage.Base.MediaSize d on d.MediaSizeID = a.MediaSizeID
		join ODS1Stage.Base.MediaReviewLevel e on e.MediaReviewLevelCode = 'PRODUCTION'
		join ODS1Stage.Base.Facility f on a.FacilityID=f.FacilityID
    where a.RowRank = 1	
        and not exists (select 1 from ODS1Stage.base.FacilityImage fi where fi.FacilityImageID = convert(uniqueidentifier, HASHBYTES('SHA1',  concat(a.FacilityID,b.EntityTypeCode,a.MediaImageTypeID, a.MediaFileName))))
