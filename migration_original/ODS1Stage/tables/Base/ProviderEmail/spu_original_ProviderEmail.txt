-- etl.spumergeprovideremail
begin
    if object_id(N'tempdb..#swimlane') is not null drop table #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
		x.ProviderCode, y.EmailTypeCode,
        convert(uniqueidentifier, convert(varbinary(20), upper(y.EmailTypeCode))) as EmailTypeID, 
        y.DoSuppress, y.EmailAddress, y.EmailRank, y.LastUpdateDate, y.SourceCode,
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.EmailTypeCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Email') as ProviderJSON
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.ProviderJSON is not null
    ) as x
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (DoSuppress bit '$.DoSuppress', EmailAddress varchar(250) '$.Email', 
            EmailRank smallint '$.Rank', EmailTypeCode varchar(50) '$.Type', 
            LastUpdateDate datetime2 '$.LastUpdateDate', 
            SourceCode varchar(25) '$.SourceCode')
    ) as y
    left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
    where y.EmailAddress is not null
    
    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderEmail (child) records for all parents in the #swimlane
	    delete pc
	    --select *
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderEmail as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderEmail child records
	    insert into ODS1Stage.Base.ProviderEmail (ProviderEmailID, ProviderID, EmailAddress, EmailRank, SourceCode, EmailTypeID, LastUpdateDate)
	    select newid(), s.ProviderID, s.EmailAddress, isnull(s.EmailRank, ((999))) as EmailRank, isnull(s.SourceCode, 'Profisee'), s.EmailTypeID, isnull(s.LastUpdateDate, getutcdate())
	    from #swimlane as s
	    where s.RowRank = 1	
		and s.ProviderCode is not null and s.EmailAddress is not null
	end