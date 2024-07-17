-- etl.spumergeprovideridentification

BEGIN
	IF OBJECT_ID('tempdb..#swimlane') IS NOT NULL DROP TABLE #swimlane
    SELECT DISTINCT CASE WHEN pID.ProviderID IS NOT NULL THEN pID.ProviderID ELSE x.ProviderID END AS ProviderID, 
		x.ProviderCode,
        CONVERT(UNIQUEIDENTIFIER, CONVERT(VARBINARY(20), y.IdentificationTypeCode)) AS IdentificationTypeID, y.IdentificationTypeCode, y.IdentificationValue, y.ExpirationDate,
        y.DoSuppress, y.LastUpdateDate, y.SourceCode, 
        ROW_NUMBER() OVER(PARTITION BY (CASE WHEN pID.ProviderID IS NOT NULL THEN pID.ProviderID ELSE x.ProviderID END), y.IdentificationTypeCode, y.IdentificationValue ORDER BY x.CREATE_DATE DESC) AS RowRank
    INTO #swimlane
    FROM
    (
        SELECT w.* 
        FROM
        (
            SELECT p.CREATE_DATE, p.RELTIO_ID AS ReltioEntityID, p.PROVIDER_CODE AS ProviderCode, p.ProviderID, 
                JSON_QUERY(p.PAYLOAD, '$.EntityJSONString.Identification') AS ProviderJSON
            FROM raw.ProviderProfileProcessingDeDup AS d WITH (NOLOCK)
            INNER JOIN raw.ProviderProfileProcessing AS p WITH (NOLOCK) ON p.rawProviderProfileID = d.rawProviderProfileID
            WHERE p.PAYLOAD IS NOT NULL
        ) AS w
        WHERE w.ProviderJSON IS NOT NULL
    ) AS x
    LEFT JOIN ODS1Stage.Base.Provider AS pID ON pID.ProviderCode = x.ProviderCode
    CROSS APPLY 
    (
        SELECT *
        FROM OPENJSON(x.ProviderJSON) WITH (DoSuppress BIT '$.DoSuppress', LastUpdateDate DATETIME '$.LastUpdateDate', 
            IdentificationValue VARCHAR(50) '$.IdentificationValue', 
            IdentificationTypeCode VARCHAR(50) '$.IdentificationTypeCode', 
			ExpirationDate date '$.ExpirationDate', 
            SourceCode VARCHAR(25) '$.SourceCode')
    ) AS y

    IF @OutputDestination = 'ODS1Stage' BEGIN
	   --Delete all ProviderIdentification (child) records for all parents in the #swimlane
	    DELETE pc
	    --select *
	    FROM raw.ProviderProfileProcessingDeDup AS p WITH (NOLOCK)
        INNER JOIN ODS1Stage.Base.Provider AS p2 ON p2.ProviderCode = p.ProviderCode
	    INNER JOIN ODS1Stage.Base.ProviderIdentification AS pc ON pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderIdentification child records
	    INSERT INTO ODS1Stage.Base.ProviderIdentification (ProviderIdentificationID, ProviderID, IdentificationTypeID, IdentificationValue, ExpirationDate, SourceCode, LastUpdateDate)
	    SELECT NEWID(), s.ProviderID, s.IdentificationTypeID, s.IdentificationValue, s.ExpirationDate, ISNULL(s.SourceCode, 'Profisee'), ISNULL(s.LastUpdateDate, GETDATE())
	    FROM #swimlane AS s
	    WHERE s.RowRank = 1
		AND (s.ProviderID IS NOT NULL AND IdentificationTypeID IS NOT NULL)