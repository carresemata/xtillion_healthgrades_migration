-- Show_spuSOLRProviderDeltaRefresh] only truncates SOLRProviderAddress in line 19
-- hack_spuRemoveSuspecProviders simply uses SOLRProviderAddress for a join statement in line 12
-- etl_spuMidProviderEntityRefresh simply calls the other procedures 

-- 1. Show_spuSOLRProviderAddressGenerateFromMid

IF OBJECT_ID('tempdb..#MultipleLocations') IS NOT NULL DROP TABLE #MultipleLocations
SELECT		ProviderID
INTO		#MultipleLocations
FROM(
        SELECT		ProviderID
        FROM		Mid.ProviderPracticeOffice WITH(NOLOCK)
        GROUP BY	ProviderID, City, State
    ) a
GROUP BY	ProviderID
HAVING		COUNT(*) > 1	

IF OBJECT_ID('tempdb..#Source') IS NOT NULL DROP TABLE #Source
SELECT		DISTINCT b.ProviderToOfficeID, 
        a.ProviderID, 
        a.ProviderCode, 
        b.AddressLine1, 
        b.AddressLine2, 
        b.City, 
        b.State, 
        b.ZipCode, 
        b.Latitude, 
        b.Longitude,  
        b.City+', '+ b.State as CityState, 
        --case when e.ProviderID is NULL then NULL else dbo.GetPipeSeparatedCityStateAlternative(b.ProviderID, b.OfficeID) end as CityStateAlternative,
        CAST(NULL AS VARCHAR(1000)) AS CityStateAlternative,
        b.OfficeCode,
        b.IsPrimaryOffice,
        b.FullPhone
        ,b.officeId
        ,CASE WHEN e.ProviderID IS NOT NULL THEN 1 ELSE 0 END AS MultipleLocations
        ,ROW_NUMBER()OVER(ORDER BY a.ProviderCode) AS SequenceId
INTO		#Source
FROM		Mid.Provider a
INNER JOIN	Mid.ProviderPracticeOffice b 
        ON a.ProviderID = b.ProviderID
INNER JOIN	#BatchInsertUpdateProcess c 
        ON a.ProviderID = c.ProviderID
LEFT JOIN	#MultipleLocations E
        ON a.ProviderID = e.ProviderID

-- This thing is from a different schema. ******** TOCHECK *********.
UPDATE	#Source
SET		CityStateAlternative = dbo.GetPipeSeparatedCityStateAlternative(ProviderID, OfficeID)
WHERE	MultipleLocations = 1

UPDATE		T
SET			T.ProviderID = S.ProviderID, 
            T.ProviderCode = S.ProviderCode, 
            T.AddressLine1 = S.AddressLine1, 
            T.AddressLine2 = S.AddressLine2, 
            T.City = S.City, 
            T.State = LEFT(S.State,2), 
            T.ZipCode = S.ZipCode, 
            T.Latitude = S.Latitude, 
            T.Longitude = S.Longitude, 
            T.CityState = S.CityState, 
            T.CityStateAlternative = S.CityStateAlternative, 
            T.OfficeCode = S.OfficeCode,
            T.IsPrimaryOffice = S.IsPrimaryOffice,
            T.FullPhone = S.FullPhone,
            T.RefreshDate = getdate()	
--SELECT		*
FROM		Show.SOLRProviderAddress T
INNER JOIN	#Source S
            ON S.ProviderToOfficeID = T.ProviderToOfficeID
WHERE		isnull(s.ProviderID,'') <> isnull(S.ProviderID,'') 
            OR isnull(s.ProviderCode,'') <> isnull(S.ProviderCode,'') 
            OR isnull(s.AddressLine1,'') <> isnull(S.AddressLine1,'') 
            OR isnull(s.AddressLine2,'') <> isnull(S.AddressLine2,'') 
            OR isnull(s.City,'') <> isnull(S.City,'') 
            OR isnull(s.State,'') <> isnull(S.State,'') 
            OR isnull(s.ZipCode,'') <> isnull(S.ZipCode,'') 
            OR isnull(cast(s.Latitude as varchar(max)),'') <> isnull(cast(S.Latitude as varchar(max)),'') 
            OR isnull(cast(s.Longitude as varchar(max)),'') <> isnull(cast(S.Longitude as varchar(max)),'')
            OR isnull(s.CityState,'') <> isnull(S.CityState,'')
            OR isnull(s.CityStateAlternative,'') <> isnull(S.CityStateAlternative,'')
            OR isnull(s.OfficeCode,'') <> isnull(S.OfficeCode,'')
            OR isnull(s.IsPrimaryOffice,'') <> isnull(S.IsPrimaryOffice,'')
            OR isnull(s.FullPhone,'') <> isnull(S.FullPhone,'')

    -- This batching loop was eliminated in translation. 
	DECLARE @int_MaxId BIGINT = (SELECT MAX(SequenceId) FROM #Source)
	DECLARE @int_MinId BIGINT = (SELECT MIN(SequenceId) FROM #Source)
	WHILE @int_MinId < @int_MaxId + 20000
	BEGIN		
		PRINT @int_MinId

		INSERT INTO Show.SOLRProviderAddress(ProviderToOfficeID, ProviderID, ProviderCode, AddressLine1, AddressLine2, City, State, ZipCode, Latitude, Longitude, CityState, CityStateAlternative,OfficeCode,IsPrimaryOffice,FullPhone)
		SELECT		S.ProviderToOfficeID, S.ProviderID, S.ProviderCode, S.AddressLine1, S.AddressLine2, S.City, LEFT(S.State,2), S.ZipCode, S.Latitude, S.Longitude, S.CityState, S.CityStateAlternative,S.OfficeCode,S.IsPrimaryOffice,S.FullPhone
		FROM		#Source S
		WHERE		SequenceId BETWEEN @int_MinId and @int_MinId + 10000

		DELETE	#Source
		WHERE	SequenceId BETWEEN @int_MinId and @int_MinId + 10000

		SET @int_MinId = @int_MinId + 10000
	END