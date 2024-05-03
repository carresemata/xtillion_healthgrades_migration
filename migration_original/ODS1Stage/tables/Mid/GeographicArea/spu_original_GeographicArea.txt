-- 1. etl_spuMidNonProviderEntityRefresh
TRUNCATE TABLE Mid.GeographicArea	


-- 2. Mid_spuGeographicAreaRefresh
--build a temp TABLE with the same structure as the Mid.GeographicArea
		BEGIN TRY DROP TABLE #GeographicArea END TRY BEGIN CATCH END CATCH
		SELECT	TOP 0 *
		INTO	#GeographicArea
		FROM	Mid.GeographicArea
		
		ALTER TABLE #GeographicArea
		ADD ActionCode INT DEFAULT 0
		
		
	--	populate the temp TABLE with data FROM Base schemas
		INSERT INTO #GeographicArea 
			(GeographicAreaID, GeographicAreaCode, GeographicAreaTypeCode, GeographicAreaValue)

		SELECT	a.GeographicAreaID, 
				a.GeographicAreaCode, 
				b.GeographicAreaTypeCode, 
				CASE 
					WHEN b.GeographicAreaTypeCode = 'CITYST' THEN a.GeographicAreaValue1+','+a.GeographicAreaValue2
					else a.GeographicAreaValue1
				END AS GeographicAreaValue
		
	--	SELECT * 
		FROM	Base.GeographicArea a
				JOIN Base.GeographicAreaType b ON a.GeographicAreaTypeID = b.GeographicAreaTypeID

--ActionCode Insert
			UPDATE	a
			SET		a.ActionCode = 1
			--SELECT *
			FROM	#GeographicArea a
					LEFT JOIN Mid.GeographicArea b ON (a.GeographicAreaID = b.GeographicAreaID and a.GeographicAreaCode = b.GeographicAreaCode and a.GeographicAreaTypeCode = b.GeographicAreaTypeCode and a.GeographicAreaValue = b.GeographicAreaValue )
			WHERE	b.GeographicAreaID is null
		
		--ActionCode UPDATE
			BEGIN TRY DROP TABLE #ColumnsUPDATEs END TRY BEGIN CATCH END CATCH
			
			SELECT	name, identity(INT,1,1) as recId
			INTO	#ColumnsUPDATEs
			FROM	tempdb..syscolumns 
			WHERE	id = object_id('TempDB..#GeographicArea')
					AND name NOT IN ('GeographicAreaID','GeographicAreaCode', 'ActionCode')
				
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
						   'FROM	#GeographicArea a'+@newline+
						   'JOIN Mid.GeographicArea b with (nolock) on (a.GeographicAreaID = b.GeographicAreaID and a.GeographicAreaCode = b.GeographicAreaCode and a.GeographicAreaTypeCode = b.GeographicAreaTypeCode and a.GeographicAreaValue = b.GeographicAreaValue )'+@newline+
						   'WHERE '
						   
				SELECT @max = MAX(recId) FROM #ColumnsUPDATEs

				WHILE @min <= @max	
					BEGIN
						SELECT	@column = name FROM #ColumnsUPDATEs WHERE recId = @min 
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
		WHERE	id = object_id('TempDB..#GeographicArea')
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
			'insert INTO Mid.GeographicArea ('+@columnListInsert+')
			SELECT '+@columnListInsert+' FROM #GeographicArea WHERE ActionCode = 1'
			
			EXEC (@sqlInsert)
		
		--ActionCode = 2 (UPDATEs)	
			DECLARE @minUPDATEs INT
			DECLARE @maxUPDATEs INT
			DECLARE @sqlUPDATEs VARCHAR(8000)
			DECLARE @sqlUPDATEsClause VARCHAR(500)
			DECLARE @columnUPDATEs VARCHAR(150)
			DECLARE @columnListUPDATEs VARCHAR(8000)
			DECLARE @newlineUPDATEs CHAR(1)
			
			SET @newlineUPDATEs = CHAR(10)
			SET @columnListUPDATEs = ''
			SET @sqlUPDATEs = 'UPDATE a'+@newlineUPDATEs+
							  'SET '	
			SET @sqlUPDATEsClause = '--SELECT *'+@newlineUPDATEs+
							  'FROM Mid.GeographicArea a '+@newlineUPDATEs+
							  'JOIN #GeographicArea b on (a.GeographicAreaID = b.GeographicAreaID and a.GeographicAreaCode = b.GeographicAreaCode and a.GeographicAreaTypeCode = b.GeographicAreaTypeCode and a.GeographicAreaValue = b.GeographicAreaValue )'+@newlineUPDATEs+
							  'WHERE b.ActionCode = 2'
							  
			SELECT @minUPDATEs = MIN(recId) FROM #ColumnsUPDATEs 
			SELECT @maxUPDATEs = MAX(recId) FROM #ColumnsUPDATEs
			
			WHILE @minUPDATEs <= @maxUPDATEs
				BEGIN
					SELECT @columnUPDATEs = name FROM #ColumnsUPDATEs WHERE recId = @minUPDATEs
					SET @columnListUPDATEs = @columnListUpdates + 'a.'+@columnUpdates+' = b.'+@columnUpdates
					
					IF @minUPDATEs < @maxUPDATEs
						BEGIN
							SET @columnListUPDATEs = @columnListUPDATEs+','+@newlineUPDATEs+''
						END
					ELSE
						BEGIN
							SET @columnListUPDATEs = @columnListUPDATEs+@newlineUPDATEs+@sqlUPDATEsClause
						END
					
					SET @minUPDATEs = @minUPDATEs + 1
				END
			
			SET @sqlUPDATEs = @sqlUPDATEs + @columnListUPDATEs
			
			EXEC (@sqlUPDATEs)

		--ActionCode = N (Deletes)
			DELETE	a
			--SELECT	*
			FROM	Mid.GeographicArea a 
					LEFT JOIN #GeographicArea b ON (a.GeographicAreaID = b.GeographicAreaID and a.GeographicAreaCode = b.GeographicAreaCode and a.GeographicAreaTypeCode = b.GeographicAreaTypeCode and a.GeographicAreaValue = b.GeographicAreaValue )
			WHERE	b.GeographicAreaID IS NULL




	