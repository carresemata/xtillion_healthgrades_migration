-- etl.spumergeprovidermalpractice
begin
    declare @FiveYearsAgo datetime = dateadd(year, -5, getdate())

	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct y.ClaimAmount, y.ClaimDate, y.ClaimNumber, y.ClaimState, y.ClaimYear, y.ClosedDate, y.Complaint, x.ProviderCode,
        case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID,
        convert(uniqueidentifier, convert(varbinary(20), LTRIM(RTRIM(y.MalpracticeClaimTypeCode)))) as MalpracticeClaimTypeID, LTRIM(RTRIM(y.MalpracticeClaimTypeCode)) as MalpracticeClaimTypeCode,
        convert(uniqueidentifier, convert(varbinary(20), y.ProviderLicenseCode)) as ProviderLicenseID, y.ProviderLicenseCode,
        y.DoSuppress, y.IncidentDate, y.LastUpdateDate, y.LicenseNumber, y.MalpracticeClaimRange, y.ReportDate, y.SourceCode, 
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), LTRIM(RTRIM(y.MalpracticeClaimTypeCode)), y.ClaimDate, y.ClaimYear, y.ClaimState, y.LicenseNumber, y.MalpracticeClaimRange order by x.CREATE_DATE desc, y.ClaimAmount desc) as RowRank, --Used existing de duping logic from Rules Engine
	    row_number()over(order by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end)) as RN1
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Malpractice') as ProviderJSON
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null and p.Reltio_ID <> '5CriggW'
        ) as w
        where w.ProviderJSON is not null
    ) as x
    left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (ClaimAmount varchar(50) '$.ClaimAmount', ClaimDate varchar(50) '$.ClaimDate', 
            ClaimNumber varchar(30) '$.ClaimNumber', ClaimState varchar(2) '$.ClaimState', ClaimYear varchar(50) '$.ClaimYear', 
            ClosedDate varchar(50) '$.ClosedDate', Complaint varchar(2000) '$.Complaint', DoSuppress bit '$.DoSuppress', 
            IncidentDate varchar(50) '$.IncidentDate', LastUpdateDate varchar(50) '$.LastUpdateDate', 
            LicenseNumber varchar(50) '$.LicenseNumber', MalpracticeClaimRange varchar(50) '$.MalpracticeClaimRange', 
            MalpracticeClaimTypeCode varchar(50) '$.ClaimTypeCode',  
            ProviderLicenseCode varchar(50) '$.ProviderLicenseCode', 
            ReportDate varchar(50) '$.ReportDate', SourceCode varchar(25) '$.SourceCode', IsActiveMalpractice bit '$.Status')
    ) as y

	delete s
    --select *
    from #swimlane as s
    where isnumeric(isnull(s.ClaimAmount,0)) = 0

	--Protects the ODS1Stage table from numeric overload. 
	--Per Sandy Davis the Malpractice system is getting an overhaul so this happy hacky bullshit is acceptable.
	update s set s.ClaimAmount = '99999999.99'
	from #swimlane as s 
	where convert(decimal(15,2), claimAmount) >= 100000000

	--update top (1) #swimlane  set MalpracticeClaimTypeCode  = 'test'
	IF OBJECT_ID('tempdb..##BadMalpracticeClaimTypeCode') IS NOT NULL DROP TABLE ##BadMalpracticeClaimTypeCode
	SELECT		DISTINCT P.ProviderCode, 'Bad Malpractice Claim Type Code value of ' + ISNULL(S.MalpracticeClaimTypeCode,'NULL')  AS ProblemType, RN1
	INTO		##BadMalpracticeClaimTypeCode
	FROM		#swimlane S
	INNER JOIN	ODS1Stage.Base.Provider P 
				ON P.ProviderId = S.ProviderId
	LEFT JOIN	ODS1Stage.Base.MalpracticeClaimType MCT
				ON MCT.MalpracticeClaimTypeCode = S.MalpracticeClaimTypeCode
	WHERE		MCT.MalpracticeClaimTypeId IS NULL
	UNION
	SELECT		DISTINCT P.ProviderCode, 'Bad Malpractice Claim Type Code value of ' + ISNULL(S.MalpracticeClaimTypeCode,'NULL')  AS ProblemType, RN1
	FROM		#swimlane S
	INNER JOIN	ODS1Stage.Base.Provider P 
				ON P.ProviderId = S.ProviderId
	LEFT JOIN	ODS1Stage.Base.MalpracticeClaimType MCT
				ON MCT.MalpracticeClaimTypeID = S.MalpracticeClaimTypeID
	WHERE		MCT.MalpracticeClaimTypeId IS NULL	
	UNION
	SELECT	S.ProviderCode, 'Bad IncidentDate value: ' + cast(IncidentDate as varchar(100)) , RN1
	FROM	#swimlane S
	WHERE	(ISDATE(IncidentDate) = 0 AND IncidentDate IS NOT NULL)
	UNION
	SELECT	S.ProviderCode, 'Bad ReportDate value: ' + cast(ReportDate as varchar(100)) , RN1
	FROM	#swimlane S
	WHERE	(ISDATE(ReportDate) = 0 AND ReportDate IS NOT NULL)
	UNION
	SELECT	S.ProviderCode, 'Bad ClaimDate value: ' + cast(ClaimDate as varchar(100)) , RN1
	FROM	#swimlane S
	WHERE	(ISDATE(ClaimDate) = 0 AND ClaimDate IS NOT NULL)
	UNION
	SELECT	S.ProviderCode, 'Bad ClosedDate value: ' + cast(ClosedDate as varchar(100)) , RN1
	FROM	#swimlane S
	WHERE	(ISDATE(ClosedDate) = 0 AND ClosedDate IS NOT NULL)
	UNION
	SELECT	S.ProviderCode, 'Bad ClaimYear value: ' + cast(ClaimYear as varchar(100))  , RN1
	FROM	#swimlane S
	WHERE	(ISNUMERIC(ClaimYear) = 0 AND ClaimYear IS NOT NULL)
	
	;WITH CTE_KEEP AS (
		SELECT	*
		FROM	#swimlane Y
		where	(
					(TRY_convert(datetime,isnull(y.IncidentDate,'1900-01-01'),102) >  dateadd(year, -5, getdate()) --Any of these 4 dates are within 5 years
										  or TRY_convert(datetime,isnull(y.ReportDate,'1900-01-01'),102) >  dateadd(year, -5, getdate())
										  or TRY_convert(datetime,isnull(y.ClaimDate,'1900-01-01'),102) >  dateadd(year, -5, getdate()) 
										  or TRY_convert(datetime,isnull(y.ClosedDate,'1900-01-01'),102) >  dateadd(year, -5, getdate()))
					or (y.IncidentDate is null and y.ReportDate is null and y.ClaimDate is null and y.ClosedDate is null)  --or all 4 of these dates are null but Claim year is within 5 years
					and y.ClaimYear is not null and isnumeric(y.ClaimYear) = 1 and TRY_CONVERT(INT, y.ClaimYear) > datepart(year,  dateadd(year, -5, getdate()))
				)
	)
	DELETE #swimlane WHERE RN1 NOT IN (SELECT RN1 FROM CTE_KEEP)

	IF EXISTS(SELECT * FROM ##BadMalpracticeClaimTypeCode)
	BEGIN
		DELETE		S
        --select *
		FROM		#swimlane S
		INNER JOIN	##BadMalpracticeClaimTypeCode B
					ON B.RN1 = S.RN1		

		EXEC msdb..sp_send_dbmail @profile_name='db_mail',
			@recipients='sandy.davis@healthgrades.com;jarred.armijo@healthgrades.com;ehook@healthgrades.com;dfrisch@healthgrades.com',
			@subject='Bad Malpractice Information',
			@body='These records have incorrect values for their field types related to malpractice claims and will be dropped from the provider record. Please correct them in Reltio to secure provider updates for these provider-malpractice records.',
			@query='SELECT ProviderCode, [ProblemType] FROM ##BadMalpracticeClaimTypeCode'
	END

    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderMalpractice (child) records for all parents in the #swimlane
	    delete pc
	    --select *
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderMalpractice as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderMalpractice child records
	    insert into ODS1Stage.Base.ProviderMalpractice (ProviderMalpracticeID, ProviderID, ProviderLicenseID, MalpracticeClaimTypeID, ClaimNumber, ClaimDate, ClaimYear, ClaimAmount, ClaimState, MalpracticeClaimRange, Complaint, IncidentDate, ClosedDate, ReportDate, SourceCode, LicenseNumber, LastUpdateDate)
	    select newid(), s.ProviderID, s.ProviderLicenseID, s.MalpracticeClaimTypeID, s.ClaimNumber, s.ClaimDate, s.ClaimYear, s.ClaimAmount, s.ClaimState, s.MalpracticeClaimRange, s.Complaint, s.IncidentDate, s.ClosedDate, s.ReportDate, isnull(s.SourceCode, 'Profisee'), s.LicenseNumber, isnull(s.LastUpdateDate, getdate())
	    from #swimlane as s
	    where s.RowRank = 1
		and (s.ProviderID is not null and s.MalpracticeClaimTypeID is not null and s.ClaimState is not null)	
	end