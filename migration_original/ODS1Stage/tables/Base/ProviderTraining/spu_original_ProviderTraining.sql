-- etl.spumergeprovidertraining
IF OBJECT_ID('tempdb..#swimlane') IS NOT NULL DROP TABLE #swimlane
    SELECT DISTINCT CASE WHEN pID.ProviderID IS NOT NULL THEN pID.ProviderID ELSE x.ProviderID END AS ProviderID, 
		x.ProviderCode,
        CONVERT(UNIQUEIDENTIFIER, CONVERT(VARBINARY(20), y.TrainingCode)) AS TrainingID, y.TrainingCode,
        y.DoSuppress, y.LastUpdateDate, y.TrainingLink, y.SourceCode, 
        ROW_NUMBER() OVER(PARTITION BY (CASE WHEN pID.ProviderID IS NOT NULL THEN pID.ProviderID ELSE x.ProviderID END), y.TrainingCode ORDER BY x.CREATE_DATE DESC) AS RowRank
    INTO #swimlane
    FROM
    (
        SELECT w.* 
        FROM
        (
            SELECT p.CREATE_DATE, p.RELTIO_ID AS ReltioEntityID, p.PROVIDER_CODE AS ProviderCode, p.ProviderID, 
                JSON_QUERY(p.PAYLOAD, '$.EntityJSONString.Training') AS ProviderJSON
            FROM raw.ProviderProfileProcessingDeDup as d with (nolock)
            INNER JOIN raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            WHERE p.PAYLOAD IS NOT NULL
        ) AS w
        WHERE w.ProviderJSON IS NOT NULL
    ) AS x
    LEFT JOIN ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (DoSuppress bit '$.DoSuppress', LastUpdateDate datetime '$.LastUpdateDate', 
            TrainingLink varchar(250) '$.TrainingLink', 
            TrainingCode varchar(50) '$.TrainingCode', 
            SourceCode varchar(25) '$.SourceCode')
    ) as y

    IF @OutputDestination = 'ODS1Stage' BEGIN
	   --Delete all ProviderTraining (child) records for all parents in the #swimlane
	    delete pc
	    --select *
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderTraining as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderTraining child records
	    insert into ODS1Stage.Base.ProviderTraining (ProviderTrainingID, ProviderID, TrainingID, TrainingLink, SourceCode, LastUpdateDate)
	    select newid(), s.ProviderID, s.TrainingID, s.TrainingLink, isnull(s.SourceCode, 'Profisee'), isnull(s.LastUpdateDate, getdate())
	    from #swimlane as s
	    where s.RowRank = 1
		and (s.ProviderID is not null and TrainingID is not null)
	END