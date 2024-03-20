-- spuSOLRGeographicAreaGenerateFromMid
TRUNCATE TABLE Show.SOLRGeographicArea

	--this TABLE will hold ALL of the records that we need to INSERT/UPDATE
		BEGIN TRY DROP TABLE #BatchProcess END TRY BEGIN CATCH END CATCH
		SELECT	DISTINCT GeographicAreaID, NULL as BatchNumber
		INTO	#BatchProcess
		FROM	Show.SOLRGeographicAreaDelta
		WHERE	StartDeltaProcessDate IS NULL 
				AND EndDeltaProcessDate IS NULL
				AND SolrDeltaTypeCode = 1 --INSERT/UPDATEs
				AND MidDeltaProcessComplete = 1 --this will indicate the Mid TABLEs have been refreshed with the UPDATEd data

	--SET the records a batch number based on a batch size we are SETting
		DECLARE @batchNumberMin INT
		DECLARE @batchNumberMax INT
		DECLARE @batchSize FLOAT
		DECLARE @sql VARCHAR(MAX)

		SET @batchSize = 100000--THIS IS THE BATCH SIZE WE ARE PROCESSING... 100K SEEMS TO BE THE FASTEST WITHOUT GOING OVERBOARD
		SET @batchNumberMin = 1
		SELECT @batchNumberMax = ceiling(COUNT(*)/@batchSize) FROM #BatchProcess


		WHILE @batchNumberMin <= @batchNumberMax
			BEGIN
				SET @sql = 
				'
				UPDATE	a
				SET		a.BatchNumber = '+cast(@batchNumberMin AS VARCHAR(max))+'
				--SELECT *
				FROM	#BatchProcess a
				JOIN 
				(
					SELECT	TOP '+cast(@batchSize AS VARCHAR(max))+' GeographicAreaID
					FROM	#BatchProcess
					WHERE	BatchNumber IS NULL
				)b ON (a.GeographicAreaID = b.GeographicAreaID)
				'
				EXEC (@sql)
			
				SET @batchNumberMin = @batchNumberMin + 1	
			END	

			CREATE INDEX ix_Mid_GeographicAreaID ON #BatchProcess (GeographicAreaID)	
			CREATE INDEX ix_Mid_BatchNumber ON #BatchProcess (BatchNumber)
	
	--process the records based on designated batches			
		DECLARE @batchProcessMin INT
		DECLARE @batchProcessMax INT

		SET @batchProcessMin = 1
		SELECT @batchProcessMax = MAX(BatchNumber) FROM #BatchProcess


		PRINT 'Process Start'
		PRINT GETDATE()
		WHILE @batchProcessMin <= @batchProcessMax
			BEGIN	

					--get the records to process that are new or deltas within a batch
						BEGIN TRY DROP TABLE #BatchInsertUpdateProcess END TRY BEGIN CATCH END CATCH
						SELECT	DISTINCT GeographicAreaID
						INTO	#BatchInsertUpdateProcess
						FROM	#BatchProcess
						WHERE	BatchNumber = @batchProcessMin
						
						CREATE INDEX ix_Mid_GeographicAreaID on #BatchInsertUpdateProcess (GeographicAreaID)

					--get the records to remove as the GeographicArea level entity is gone
					--DEAL WITH THESE LATER
						--BEGIN TRY DROP TABLE #BatchDeleteProcess END TRY BEGIN CATCH END CATCH
						--SELECT DISTINCT GeographicAreaID
						--INTO #BatchDeleteProcess
						--FROM Show.SOLRGeographicAreaDelta
						--WHERE StartDeltaProcessDate IS NULL and ENDDeltaProcessDate IS NULL
						--and SolrDeltaTypeCode = 2--Deletes
						--and MidDeltaProcessComplete = 1--this will indicate the Mid TABLEs have been refreshed with the UPDATEd data
						
						--CREATE INDEX ix_Mid_GeographicAreaID on #BatchDeleteProcess (GeographicAreaID)
					
										
					MERGE Show.SOLRGeographicArea AS s
						USING 
						(
							SELECT	c.GeographicAreaID, c.GeographicAreaCode, c.GeographicAreaTypeCode, c.GeographicAreaValue, 
									GETDATE() AS UpdatedDate, USER_NAME() AS UpdatedSource
								
							FROM	Mid.GeographicArea c
									JOIN #BatchInsertUpdateProcess as batch on batch.GeographicAreaID = c.GeographicAreaID
							/*--if you want to test it, plug in a GeographicAreaID here
							WHERE c.GeographicAreaID = '8E83D778-ECFD-4956-B86A-000F1ADD5099'
							*/
							
						) AS ls ON ls.GeographicAreaID = s.GeographicAreaID
							
					WHEN MATCHED THEN     
						UPDATE SET 
						s.GeographicAreaID = ls.GeographicAreaID, s.GeographicAreaCode = ls.GeographicAreaCode, 
						s.GeographicAreaTypeCode = ls.GeographicAreaTypeCode, s.GeographicAreaValue = ls.GeographicAreaValue, 
						s.UpdatedDate = ls.UpdatedDate, s.UpdatedSource = ls.UpdatedSource					
						WHEN NOT MATCHED BY TARGET THEN
						INSERT (	
									GeographicAreaID, GeographicAreaCode, GeographicAreaTypeCode, GeographicAreaValue, 
									UpdatedDate, UpdatedSource
								)
						VALUES (	
									ls.GeographicAreaID, ls.GeographicAreaCode, ls.GeographicAreaTypeCode, ls.GeographicAreaValue, 
									ls.UpdatedDate, ls.UpdatedSource
								);