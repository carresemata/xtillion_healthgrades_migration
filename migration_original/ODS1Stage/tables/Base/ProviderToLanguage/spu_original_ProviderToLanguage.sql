-- etl.spumergeproviderlanguage
begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID,
        x.ProviderCode,
        convert(uniqueidentifier, convert(varbinary(20), y.LanguageCode)) as LanguageID, y.LanguageCode,
        y.DoSuppress, y.LastUpdateDate, y.SourceCode, 
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.LanguageCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Language') as ProviderJSON
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
        from openjson(x.ProviderJSON) with (DoSuppress bit '$.DoSuppress', LanguageCode varchar(50) '$.LanguageCode', 
            LastUpdateDate datetime '$.LastUpdateDate',  
            SourceCode varchar(25) '$.SourceCode')
    ) as y
    where isnull(y.DoSuppress, 0) = 0 and y.LanguageCode is not null and y.LanguageCode <> 'LN0000C3A1'  --Discard English

    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderToLanguage (child) records for all parents in the #swimlane
	    delete pc
	    --select *
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderToLanguage as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderToLanguage child records
	    insert into ODS1Stage.Base.ProviderToLanguage (ProviderToLanguageID, ProviderID, LanguageID, SourceCode, LastUpdateDate)
	    select newid(), s.ProviderID, s.LanguageID, isnull(s.SourceCode, 'Profisee'), isnull(s.LastUpdateDate, getutcdate())
	    from #swimlane as s
	    where s.RowRank = 1	
		and (s.ProviderID is not null and s.LanguageID is not null)