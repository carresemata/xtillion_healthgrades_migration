-- 1. etl_spuMidProviderEntityRefresh
--- Base.SubStatus
--- Base.DisplayStatus
--- Base.Provider

UPDATE	Show.SOLRProvider SET DateOfBirth = NULL WHERE YEAR(DateOfBirth) = 1900

-- 2. hack_spuRemoveSuspecProviders
--- Base.ProviderRemoval
delete sp
	from Base.ProviderRemoval pr
		join Show.SOLRProvider sp on sp.ProviderCode = pr.ProviderCode


-- 3. Show.spuApplyProviderStatusBusinessRules
--- Show.SOLRProviderDelta

-- Update Accepts New Patients based on SubStatusCode
	UPDATE a 
	SET a.AcceptsNewPatients = 0
	--select a.AcceptsNewPatients
	FROM Show.SOLRProvider a
		JOIN Show.SOLRProviderDelta b ON b.ProviderID = a.ProviderID
	WHERE a.SubStatusCode IN ('C','Y','A')
		AND a.AcceptsNewPatients != 0

-- 1. etl_spuMidProviderEntityRefresh
UPDATE		P
				SET			DisplayStatusCode = DS.DisplayStatusCode
				FROM		Show.SOLRProvider P
				INNER JOIN	Base.SubStatus SS
							ON SS.SubStatusCode = P.SubStatusCode
				INNER JOIN	Base.DisplayStatus DS
							ON DS.DisplayStatusId = SS.DisplayStatusId
				WHERE		P.DisplayStatusCode != DS.DisplayStatusCode
							AND P.DisplayStatusCode = 'H'


IF @RefreshNonProvider = 1		
BEGIN
				update show.SOLRProvider 
				set APIXML = REPLACE(CAST(APIXML AS VARCHAR(MAX)), '</apiL>','
				  <api>
					<clientCd>OASTEST</clientCd>
					<camCd>OASTEST_005</camCd>
				  </api>
				</apiL>'
				)
				where providercode in ('G92WN','yj754','XYLGDMH','2p2v2','2CJGY','XCWYN','E5B5Z','YJLPH')
					and CAST(APIXML AS VARCHAR(MAX)) not like '%OASTEST_005%'
END

UPDATE		S 
		SET			S.AcceptsNewPatients =  1
		FROM		Show.SOLRProvider S
		INNER JOIN	Base.Provider P ON P.Providerid = S.ProviderID
		WHERE		ISNULL(S.ACCEPTSNEWPATIENTS,0) != P.AcceptsNewPatients

update ods1stage.Show.SOLRProvider 
		set DisplayStatusCode = 'A'
		WHERE DisplayStatusCode = 'H' AND SubStatusCode = '1'



