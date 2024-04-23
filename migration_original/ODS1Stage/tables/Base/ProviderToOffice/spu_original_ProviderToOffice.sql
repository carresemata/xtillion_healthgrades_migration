-- etl.spumergeprovideroffice

begin
	if object_id('tempdb..#swimlane') IS NOT NULL DROP TABLE #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
		x.ProviderCode, y.OfficeCode, y.OfficeName, y.PracticeName,
        convert(uniqueidentifier, convert(varbinary(20), y.OfficeCode)) as OfficeID, 
        y.DoSuppress, y.IsPrimaryOffice, y.LastUpdateDate, y.ProviderOfficeRank, 
        y.ProviderOfficeRankInferenceCode, y.SourceAddressCount, y.SourceCode, 
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.OfficeCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Office') as ProviderJSON
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.ProviderJSON is not null
    ) as x
	left join ODS1Stage.Base.Provider pID on pID.providercode = x.ProviderCode
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (
			DoSuppress bit '$.DoSuppress'
			, IsDerived bit '$.IsDerived'
            , IsPrimaryOffice bit '$.IsPrimaryOffice'
			, LastUpdateDate datetime '$.LastUpdateDate'
            , OfficeCode varchar(50) '$.OfficeCode'
            , OfficeName varchar(250) '$.OfficeName'
            , PracticeName varchar(200) '$.PracticeName'
            , OfficeReltioEntityID varchar(50) '$.ReltioEntityID'
            , ProviderOfficeRank int '$.CalculatedOfficeRank'
			, ProviderOfficeRankInferenceCode varchar(25) '$.ProviderOfficeRankInferenceCode'
            , SourceAddressCount int '$.SourceAddressCount'
			, SourceCode varchar(25) '$.SourceCode'
		)
    ) as y
    where y.OfficeCode is not null
    
    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderToOffice (child) records for all parents in the #swimlane
	    delete pc
	    --select *
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderToOffice as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderToOffice child records
	    insert into ODS1Stage.Base.ProviderToOffice (ProviderToOfficeID, ProviderID, OfficeID, OfficeName, PracticeName, IsPrimaryOffice, ProviderOfficeRank, 
	        SourceCode, ProviderOfficeRankInferenceCode, SourceAddressCount, LastUpdateDate)
	    select newid(), s.ProviderID, o.OfficeID, s.OfficeName, s.PracticeName, s.IsPrimaryOffice, s.ProviderOfficeRank, isnull(s.SourceCode, 'Profisee'),
	        s.ProviderOfficeRankInferenceCode, s.SourceAddressCount, isnull(s.LastUpdateDate, getutcdate())
	    from #swimlane as s
		inner join ODS1Stage.Base.Office as o with (nolock) on o.OfficeCode = s.OfficeCode
	    where s.RowRank = 1	
		    and (s.ProviderID is not null and o.OfficeID is not null)
	end