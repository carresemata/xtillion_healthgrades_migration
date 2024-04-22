	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID,
		x.ProviderCode,
        convert(uniqueidentifier, convert(varbinary(20), upper(y.DegreeCode))) as DegreeID, y.DegreeCode,
        y.DegreePriority, y.DoSuppress, y.LastUpdateDate, y.SourceCode,
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.DegreeCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Credential') as ProviderJSON
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
        from openjson(x.ProviderJSON) with (DegreeCode varchar(50) '$.CredentialCode', CredentialTypeCode varchar(50) '$.CredentialTypeCode', 
            DegreePriority int '$.CredentialRank', DoSuppress bit '$.DoSuppress', LastUpdateDate datetime '$.LastUpdateDate', 
            SourceCode varchar(25) '$.SourceCode')
    ) as y
    where isnull(y.DoSuppress, 0) = 0 and y.DegreeCode is not null and y.CredentialTypeCode = 'Degree'

    if @OutputDestination = 'ODS1Stage' begin
	    --Could be getting new degrees from Reltio, add them to Base.Degree
        insert into ODS1Stage.Base.Degree (DegreeID, DegreeAbbreviation, DegreeDescription, refRank)
        select convert(uniqueidentifier, convert(varbinary(20), upper(S.DegreeCode))), S.DegreeCode, S.DegreeCode, (select max(refRank)from ODS1Stage.Base.Degree) + row_number() over (order by S.DegreeCode)
        from
        (
            select distinct S.DegreeCode
            from #swimlane as S
            where not exists (select c.DegreeAbbreviation from ODS1Stage.Base.Degree as c where c.DegreeAbbreviation = S.DegreeCode)
        ) S
        order by S.DegreeCode;