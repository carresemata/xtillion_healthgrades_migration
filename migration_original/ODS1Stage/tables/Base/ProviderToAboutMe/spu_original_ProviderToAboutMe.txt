-- etl.spumergeprovideraboutme
if object_id(N'tempdb..#swimlane') is not null drop table #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
        x.ProviderCode,  
        convert(uniqueidentifier, convert(varbinary(20), x.AboutMeCode)) as AboutMeID, x.AboutMeCode,
        y.ProviderAboutMeText, y.CustomDisplayOrder, y.DoSuppress, y.LastUpdateDate,
        y.SourceCode,
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), x.AboutMeCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.*
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, json_query(p.PAYLOAD, '$.EntityJSONString.AboutMe') as ProviderJSON,
                'About' as AboutMeCode
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
            union all
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, json_query(p.PAYLOAD, '$.EntityJSONString.ProceduresPerformed') as ProviderJSON, 
                'ProceduresPerformed' as AboutMeCode
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
            union all
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, json_query(p.PAYLOAD, '$.EntityJSONString.ResponseToPes') as ProviderJSON,
                'ResponseToPes' as AboutMeCode
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
            union all
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, json_query(p.PAYLOAD, '$.EntityJSONString.ConditionsTreated') as ProviderJSON, 
                'ConditionsTreated' as AboutMeCode
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
            union all
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, json_query(p.PAYLOAD, '$.EntityJSONString.CarePhilosophy') as ProviderJSON, 
                'CarePhilosophy' as AboutMeCode
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.ProviderJSON is not null
    ) as x
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (ProviderAboutMeText varchar(max) '$.Text', CustomDisplayOrder int '$.Rank',
            DoSuppress bit '$.DoSuppress', LastUpdateDate datetime '$.LastUpdateDate', SourceCode varchar(25) '$.SourceCode')
    ) as y
    left join ODS1Stage.Base.Provider pID on pID.ProviderCode = x.ProviderCode
    
    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderToAboutMe (child) records for all parents in the #swimlane
	    delete pc
	    --select * 
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderToAboutMe as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderToAboutMe child records
	    insert into ODS1Stage.Base.ProviderToAboutMe (ProviderToAboutMeID, ProviderID, SourceCode, AboutMeID, ProviderAboutMeText, CustomDisplayOrder, LastUpdatedDate)
	    select newid(), s.ProviderID, isnull(s.SourceCode, 'Profisee'), s.AboutMeID, s.ProviderAboutMeText, s.CustomDisplayOrder, isnull(s.LastUpdateDate, getdate())
	    from #swimlane as s
	    where s.RowRank = 1 and isnull(s.DoSuppress, 0) = 0
		and (s.ProviderID is not null and s.AboutMeID is not null and s.ProviderAboutMeText is not null)
	end