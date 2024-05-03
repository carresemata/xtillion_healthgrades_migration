-- etl_spuMidNonProviderEntityRefresh (line 433)

TRUNCATE TABLE Mid.LineOfService
EXEC Mid.spuLineOfServiceRefresh

-- Mid_spuLineOfServiceRefresh
--build a temp TABLE with the same structure as the Mid.LineOfService
		BEGIN TRY DROP TABLE #LineOfService END TRY BEGIN CATCH END CATCH
		SELECT	TOP 0 *
		INTO	#LineOfService
		FROM	Mid.LineOfService
		
		ALTER TABLE #LineOfService
		ADD ActionCode INT DEFAULT 0
		
		
	--	populate the temp TABLE with data FROM Base schemas
		INSERT INTO #LineOfService (LineOfServiceID, LineOfServiceCode, LineOfServiceTypeCode, LineOfServiceDescription, LegacyKey, LegacyKeyName)

		SELECT	a.LineOfServiceID, 
				a.LineOfServiceCode, 
				b.LineOfServiceTypeCode, 
				a.LineOfServiceDescription,
				r.LegacyKey, 
				r.SpecialtyGroupDescription AS LegacyKeyName
		
	--	SELECT * 
		FROM	Base.LineOfService a
				JOIN Base.LineOfServiceType b ON a.LineOfServiceTypeID = b.LineOfServiceTypeID
				JOIN Base.SpecialtyGroup r ON a.LineOfServiceCode = r.SpecialtyGroupCode


		
	/*
		Flag record level actions for ActionCode
			0 = No Change
			1 = Insert
			2 = UPDATE
	*/
		--ActionCode Insert
			UPDATE	a
			SET		a.ActionCode = 1
			--SELECT *
			FROM	#LineOfService a
					LEFT JOIN Mid.LineOfService b ON (a.LineOfServiceID = b.LineOfServiceID and a.LineOfServiceCode = b.LineOfServiceCode and a.LineOfServiceTypeCode = b.LineOfServiceTypeCode )
			WHERE	b.LineOfServiceID is null
		
		--ActionCode UPDATE
			BEGIN TRY DROP TABLE #ColumnsUpdates END TRY BEGIN CATCH END CATCH
			
			SELECT	name, identity(INT,1,1) as recId
			INTO	#ColumnsUpdates
			FROM	tempdb..syscolumns 
			WHERE	id = object_id('TempDB..#LineOfService')
					AND name NOT IN ('LineOfServiceID','LineOfServiceCode', 'ActionCode')
				
			--build the sql statement with dynamic sql to check if we need to UPDATE any columns
				DECLARE @sql VARCHAR(8000)
				DECLARE @min INT
				DECLARE @max INT
				DECLARE @WHEREClause VARCHAR(8000)
				DECLARE @column VARCHAR(100)
				DECLARE @newline CHAR(1)
				DECLARE @globalCheck VARCHAR(3)

				SET @min = 1
				SET @WHEREClause = ''
				SET @newline = CHAR(10)
				SET @sql = 'UPDATE	a'+@newline+ 
						   'SET		a.ActionCode = 2'+@newline+
						   '--SELECT *'+@newline+
						   'FROM	#LineOfService a'+@newline+
						   'JOIN Mid.LineOfService b with (nolock) on (a.LineOfServiceID = b.LineOfServiceID and a.LineOfServiceCode = b.LineOfServiceCode and a.LineOfServiceTypeCode = b.LineOfServiceTypeCode )'+@newline+
						   'WHERE '
						   
				SELECT @max = MAX(recId) FROM #ColumnsUpdates

				WHILE @min <= @max	
					BEGIN
						SELECT	@column = name FROM #ColumnsUpdates WHERE recId = @min 
						SET		@WHEREClause = @WHEREClause +'BINARY_CHECKSUM(isnull(cast(a.'+@column+' as VARCHAR(max)),'''')) <> BINARY_CHECKSUM(isnull(cast(b.'+@column+' as VARCHAR(max)),''''))'+@newline
							--put an OR for all except for the last column check
							IF @min < @max 
								BEGIN
									SET @WHEREClause = @WHEREClause+' or '
								END

						
						SET @min = @min + 1
					END

				SET @sql = @sql + @WHEREClause
				EXEC (@sql)

	/*
		Complete the ActionCode
	*/
	
		--define column SET for INSERTS 
		BEGIN TRY DROP TABLE #ColumnInserts END TRY BEGIN CATCH END CATCH

		SELECT	name, identity(INT,1,1) as recId
		INTO	#ColumnInserts
		FROM	tempdb..syscolumns 
		WHERE	id = object_id('TempDB..#LineOfService')
				AND name <> 'ActionCode'--do not need to insert/UPDATE this field
		
		--create the column SET
		DECLARE @columnInsert VARCHAR(100)
		DECLARE @columnListInsert VARCHAR(8000)
		DECLARE @minInsert INT
		DECLARE @maxInsert INT
		
		SET @minInsert = 1
		SET @columnListInsert = ''
		SELECT @maxInsert = MAX(recId) FROM #ColumnInserts 
		
		WHILE @minInsert <= @maxInsert
			BEGIN
				SELECT	@columnInsert = name FROM #ColumnInserts WHERE recId = @minInsert
				SET		@columnListInsert = @columnListInsert + @columnInsert
				
				IF @minInsert <@maxInsert
					BEGIN
						SET @columnListInsert = @columnListInsert+','
					END
				
				SET @minInsert = @minInsert + 1
			END
		
		--ActionCode = 1 (Inserts)
			DECLARE @sqlInsert VARCHAR(8000)
			SET @sqlInsert = 
			'insert INTO Mid.LineOfService ('+@columnListInsert+')
			SELECT '+@columnListInsert+' FROM #LineOfService WHERE ActionCode = 1'
			
			EXEC (@sqlInsert)
		
		--ActionCode = 2 (Updates)	
			DECLARE @minUpdates INT
			DECLARE @maxUpdates INT
			DECLARE @sqlUpdates VARCHAR(8000)
			DECLARE @sqlUpdatesClause VARCHAR(500)
			DECLARE @columnUpdates VARCHAR(150)
			DECLARE @columnListUpdates VARCHAR(8000)
			DECLARE @newlineUpdates CHAR(1)
			
			SET @newlineUpdates = CHAR(10)
			SET @columnListUpdates = ''
			SET @sqlUpdates = 'UPDATE a'+@newlineUpdates+
							  'SET '	
			SET @sqlUpdatesClause = '--SELECT *'+@newlineUpdates+
							  'FROM Mid.LineOfService a '+@newlineUpdates+
							  'JOIN #LineOfService b on (a.LineOfServiceID = b.LineOfServiceID and a.LineOfServiceCode = b.LineOfServiceCode and a.LineOfServiceTypeCode = b.LineOfServiceTypeCode )'+@newlineUpdates+
							  'WHERE b.ActionCode = 2'
							  
			SELECT @minUpdates = MIN(recId) FROM #ColumnsUpdates 
			SELECT @maxUpdates = MAX(recId) FROM #ColumnsUpdates
			
			WHILE @minUpdates <= @maxUpdates
				BEGIN
					SELECT @columnUpdates = name FROM #ColumnsUpdates WHERE recId = @minUpdates
					SET @columnListUpdates = @columnListUpdates + 'a.'+@columnUpdates+' = b.'+@columnUpdates
					
					IF @minUpdates < @maxUpdates
						BEGIN
							SET @columnListUpdates = @columnListUpdates+','+@newlineUpdates+''
						END
					ELSE
						BEGIN
							SET @columnListUpdates = @columnListUpdates+@newlineUpdates+@sqlUpdatesClause
						END
					
					SET @minUpdates = @minUpdates + 1
				END
			
			SET @sqlUpdates = @sqlUpdates + @columnListUpdates
			
			EXEC (@sqlUpdates)

		--ActionCode = N (Deletes)
			DELETE	a
			--SELECT	*
			FROM	Mid.LineOfService a 
					LEFT JOIN #LineOfService b ON (a.LineOfServiceID = b.LineOfServiceID and a.LineOfServiceCode = b.LineOfServiceCode and a.LineOfServiceTypeCode = b.LineOfServiceTypeCode )
			WHERE	b.LineOfServiceID IS NULL