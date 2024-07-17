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
    
--Insert all ProviderToDegree child records
insert into ODS1Stage.Base.ProviderToDegree (ProviderToDegreeID, ProviderID, DegreeID, DegreePriority, SourceCode, LastUpdateDate)
select newid(), s.ProviderID, s.DegreeID, s.DegreePriority, isnull(s.SourceCode, 'Profisee'), isnull(s.LastUpdateDate, getutcdate())
from #swimlane as s
where s.RowRank = 1	
    and s.ProviderID is not null and s.DegreeID is not null