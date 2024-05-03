-- etl.spumergeproviderprovidersubtype
BEGIN
	IF OBJECT_ID('tempdb..#swimlane') IS NOT NULL DROP TABLE #swimlane
	SELECT	DISTINCT CASE WHEN pID.ProviderID IS NOT NULL THEN pID.ProviderID ELSE x.ProviderID END AS ProviderID
			,x.ProviderCode
			,y.LastUpdateDate AS LastUpdateDate
			,ISNULL(y.ProviderSubTypeRankCalculated,1) AS ProviderSubTypeRank
			,NULL AS ProviderSubTypeRankCalculated
			,y.SourceCode AS SourceCode
			,y.ProviderSubTypeCode
			,ROW_NUMBER() OVER(PARTITION BY (CASE WHEN pID.ProviderID IS NOT NULL THEN pID.ProviderID ELSE x.ProviderID END), ISNULL(y.ProviderSubTypeCode,'ALT') ORDER BY x.CREATE_DATE DESC) AS RowRank
    INTO #swimlane
    FROM
    (
        SELECT p.CREATE_DATE, p.RELTIO_ID AS ReltioEntityID, p.PROVIDER_CODE AS ProviderCode, p.ProviderID, 
            JSON_QUERY(p.PAYLOAD, '$.EntityJSONString.ProviderSubType') AS ProviderJSON
        FROM raw.ProviderProfileProcessingDeDup AS d WITH (NOLOCK)
        INNER JOIN raw.ProviderProfileProcessing AS p WITH (NOLOCK) ON p.rawProviderProfileID = d.rawProviderProfileID
        WHERE p.PAYLOAD IS NOT NULL
    ) AS x
    LEFT JOIN ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (DoSuppress bit '$.DoSuppress', LastUpdateDate datetime '$.LastUpdateDate', 
            ProviderSubTypeCode varchar(50) '$.ProviderSubTypeCode', ProviderSubTypeRank int '$.ProviderSubTypeRank', 
            ProviderSubTypeRankCalculated int '$.ProviderSubTypeRankCalculated', SourceCode varchar(50) '$.SourceCode')
    ) as y
    
    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderToProviderSubType (child) records for all parents in the #swimlane
	    delete pc
        --select count(*)
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderToProviderSubType as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderToProviderSubType child records
	    insert into ODS1Stage.Base.ProviderToProviderSubType (ProviderToProviderSubTypeID, ProviderID, ProviderSubTypeID, SourceCode, ProviderSubTypeRank, ProviderSubTypeRankCalculated, LastUpdateDate)
	    select newid(), s.ProviderID, pt.ProviderSubTypeID, isnull(s.SourceCode, 'Profisee'), s.ProviderSubTypeRank, isnull(s.ProviderSubTypeRankCalculated, ((2147483647))) as ProviderSubTypeRankCalculated, isnull(s.LastUpdateDate, getutcdate())
	    from #swimlane as s
		join ODS1Stage.Base.Provider p on s.ProviderID=p.ProviderID
		join ODS1Stage.Base.ProviderSubType pt on s.ProviderSubTypeCode=pt.ProviderSubTypeCode
	    where s.RowRank = 1	
		    and (s.ProviderID is not null and s.ProviderSubTypeCode is not null)
	
	end