--

begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select z.ProviderID, z.DoSuppress, z.LastUpdateDate, z.ProviderCode, z.ProviderTypeCode, z.ProviderTypeRank, z.ProviderTypeRankCalculated, z.SourceCode, z.ProviderTypeCodeRank, z.RowRank,
    replace(replace('/' + case when z.ProviderTypeCode = 'DOC' then 'physician/dr-' when z.ProviderTypeCode = 'DENT' then 'dentist/dr-' else 'providers/' end 
	                + lower(p3.FirstName) + '-' + lower(p3.LastName) + '-' + lower(p3.ProviderCode),
	'''',''),' ','-') as URL
    into #swimlane
    from 
    (
        select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID,
            x.DoSuppress, x.LastUpdateDate, x.ProviderCode, 
			--x.LastName, x.FirstName, 
			isnull( y.ProviderTypeCode, 'ALT') as ProviderTypeCode, 
			isnull(y.ProviderTypeRank,1) as ProviderTypeRank,
            isnull(y.ProviderTypeRankCalculated,1) as ProviderTypeRankCalculated, y.SourceCode,
            row_number() over(partition by x.ProviderCode order by isnull(y.ProviderTypeRankCalculated, 2147483647), isnull(y.ProviderTypeRank,1), 
	    case when y.ProviderTypeCode = 'DOC' then 1 when y.ProviderTypeCode = 'DENT' then 2 else 3 end) as ProviderTypeCodeRank,
            row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end) order by isnull(y.ProviderTypeRankCalculated,1), x.CREATE_DATE desc) as RowRank
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.ProviderType') as ProviderJSON, 
                convert(bit, json_value(p.PAYLOAD, '$.EntityJSONString.DoSuppress')) as DoSuppress,
                p.CREATE_DATE as LastUpdateDate
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
        ) as x
        left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
        cross apply 
        (
            select *
            from openjson(x.ProviderJSON) with (DoSuppress bit '$.DoSuppress', LastUpdateDate datetime '$.LastUpdateDate', 
                ProviderCode varchar(50) '$.ProviderCode', 
                ProviderTypeCode varchar(50) '$.ProviderTypeCode', ProviderTypeRank int '$.ProviderTypeRank', 
                ProviderTypeRankCalculated int '$.ProviderTypeRankCalculated', SourceCode varchar(50) '$.SourceCode')
        ) as y
        where isnull(x.DoSuppress, 0) = 0 and isnull( y.ProviderTypeCode, 'ALT') is not null
    ) as z 
    inner join ODS1Stage.Base.Provider as p3 with (nolock) on p3.ProviderCode = z.ProviderCode
    where isnull(z.DoSuppress, 0) = 0 and z.ProviderTypeCodeRank = 1
    	and p3.ProviderCode is not null and p3.FirstName is not null and p3.LastName is not null and z.ProviderTypeCode is not null

    if @OutputDestination = 'ODS1Stage' begin
	    --Insert all ProviderURL child records
	    insert into ODS1Stage.Base.ProviderURL (ProviderURLID, ProviderID, URL, SourceCode, LastUpdateDate)
	    select newid(), s.ProviderID, s.URL, isnull(s.SourceCode, 'Profisee'), isnull(s.LastUpdateDate, getutcdate())
	    from #swimlane as s
	    where not exists (select * from ODS1Stage.Base.ProviderURL as u where u.ProviderID = s.ProviderID)
	        and s.RowRank = 1	
	end