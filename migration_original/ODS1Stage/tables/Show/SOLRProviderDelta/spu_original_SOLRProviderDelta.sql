-- 1. etl_spuMidProviderEntityRefresh
UPDATE	A
							SET		A.ENDDeltaProcessDate = getdate()
							FROM	Show.SOLRProviderDelta a
							WHERE	StartDeltaProcessDate IS NOT NULL
									AND ENDDeltaProcessDate IS NULL

-- 2. Show_spuSOLRProviderDeltaRefresh
IF @IsProviderDeltaProcessing = 0
	BEGIN
		TRUNCATE TABLE Show.SOLRProviderDelta						
		INSERT INTO Show.SOLRProviderDelta (ProviderID, SolrDeltaTypeCode, StartDeltaProcessDate, MidDeltaProcessComplete)
		SELECT		a.ProviderID, '1' as SolrDeltaTypeCode, getdate() as StartDeltaProcessDate, '1' as MidDeltaProcessComplete 
		FROM		Base.Provider as a 

END

IF @IsProviderDeltaProcessing = 1
	BEGIN
		INSERT INTO Show.SOLRProviderDelta(ProviderId, SolrDeltaTypeCode, StartDeltaProcessDate)
		SELECT	ProviderId, 1, GETDATE()
		FROM	Snowflake.etl.ProviderDeltaProcessing
		WHERE	ProviderId NOT IN (SELECT ProviderId FROM Show.SOLRProviderDelta)

		update		spd
		set			ENDDeltaProcessDate = null,
					StartMoveDate = null,
					ENDMoveDate = null
		from		Snowflake.etl.ProviderDeltaProcessing as a
		inner join	Show.SOLRProviderDelta spd 
					on a.ProviderID = spd.ProviderID
					

		INSERT INTO	Show.SOLRProviderDelta (ProviderID, SolrDeltaTypeCode, StartDeltaProcessDate, MidDeltaProcessComplete)
		SELECT		X.ProviderID, SolrDeltaTypeCode, StartDeltaProcessDate, MidDeltaProcessComplete 
		FROM(
			SELECT		X.ProviderID, X.SolrDeltaTypeCode, X.StartDeltaProcessDate, X.MidDeltaProcessComplete 
						,ROW_NUMBER()OVER(PARTITION BY X.ProviderId ORDER BY X.SolrDeltaTypeCode) AS RN1
			FROM(
				select		distinct a.ProviderID as ProviderID, '1' as SolrDeltaTypeCode, GETDATE() as StartDeltaProcessDate, '1' as MidDeltaProcessComplete 
				from		Snowflake.etl.ProviderDeltaProcessing as a
				inner join	Base.Provider as c on c.ProviderID = a.ProviderID
				left join	Show.SOLRProviderDelta d on (d.ProviderID = a.ProviderID)
				left join	Base.ProvidersWithSponsorshipIssues as i on i.ProviderCode = c.ProviderCode
				where		d.ProviderID is null and i.ProviderCode is null
	
				union	-- Mark Fleming 2016-08-02 added UNION for Powered By Healthgrades (TFS 143348).
				
				select		distinct pbh.ProviderID as ProviderID, '1' as SolrDeltaTypeCode, GETDATE() as StartDeltaProcessDate, '1' as MidDeltaProcessComplete 
				from		Show.SOLRProviderDelta_PoweredByHealthgrades as pbh
				left join	Base.Provider as c on c.EDWBaseRecordID = pbh.ProviderID  --EGS 5/22/10: removed reference to DB HealthMaster in prep for it going away
				WHERE		pbh.ProviderId NOT IN(SELECT ProviderId FROM Show.SOLRProviderDelta)
							AND c.ProviderCode NOT IN(SELECT ProviderCode FROM Base.ProvidersWithSponsorshipIssues)
			)X
			LEFT JOIN	Show.SOLRProviderDelta d 
						ON D.ProviderID = X.ProviderID
			WHERE		d.SOLRProviderDeltaID IS NULL
		)X
		WHERE		RN1 = 1
		ORDER BY	1
END