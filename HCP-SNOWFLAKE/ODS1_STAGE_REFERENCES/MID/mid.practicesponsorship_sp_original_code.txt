--- Mid_spuPracticeSponsorshipRefresh

    --Create & fill table that holds the list of Practice records that were supposed to migrate with the batch.  
    --  If this is a full file refresh, migrate all Base.Practice records.
    --  If this is a batch migration, the list records comes from provider deltas
    --  Obviously, if this is a full file refresh then technically a list of the records that migrated isn't neccessary, but it makes
    --  the code that inserts into #Practice much simpler as it removes the need for separate insert queries or dynamic SQL
       
        begin try drop table #PracticeBatch end try begin catch end catch
        create table #PracticeBatch (PracticeID uniqueidentifier, PracticeCode varchar(25))
        
        if @IsProviderDeltaProcessing = 0 
        begin
			truncate table Mid.PracticeSponsorship
        
            insert into #PracticeBatch (PracticeID, PracticeCode) 
            select	DISTINCT a.PracticeID, a.PracticeCode 
            from	Base.Practice as a 
            order	by a.PracticeID
          end
        else 
        begin
            insert into #PracticeBatch (PracticeID, PracticeCode)
            select distinct p.PracticeID, p.PracticeCode
            from Snowflake.etl.ProviderDeltaProcessing as a
            inner join base.ProviderToOffice pto on a.ProviderID = pto.ProviderID
            inner join base.Office o on pto.OfficeID = o.OfficeID
            inner join Base.Practice as p on p.PracticeID = o.PracticeID
            order by p.PracticeID
        end

        create index ixPbPracticeID on #PracticeBatch (PracticeID)

	--build a temp TABLE with the same structure as the Mid.PracticeSponsorship
		BEGIN TRY DROP TABLE #PracticeSponsorship END TRY BEGIN CATCH END CATCH
		SELECT	TOP 0 *
		INTO	#PracticeSponsorship
		FROM	Mid.PracticeSponsorship
		
		ALTER TABLE #PracticeSponsorship
		ADD ActionCode INT DEFAULT 0

		SELECT	f.PracticeID,f.PracticeCode,c.ProductCode,c.ProductDescription,pg.ProductGroupCode,pg.ProductGroupDescription,
				a.ClientToProductID,b.ClientCode,b.ClientName,
				ROW_NUMBER() OVER (PARTITION BY f.PracticeID,f.PracticeCode,c.ProductCode, c.ProductDescription,pg.ProductGroupCode,pg.ProductGroupDescription  ORDER BY d.LastUpdateDate ASC) AS recID
		into	#RawPracData
	--	SELECT * FROM Base.EntityType
		FROM	Base.ClientToProduct a
				JOIN Base.Client b ON a.ClientID = b.ClientID
				JOIN Base.Product c ON a.ProductID = c.ProductID
				JOIN Base.ProductGroup pg ON c.ProductGroupID = pg.ProductGroupID
				JOIN Base.ClientProductToEntity d ON a.ClientToProductID = d.ClientToProductID
				JOIN Base.EntityType e ON d.EntityTypeID = e.EntityTypeID AND e.EntityTypeCode = 'PRAC'
				JOIN Base.Practice f ON d.EntityID = f.PracticeID
				JOIN #PracticeBatch as pb ON d.EntityID = pb.PracticeID --When not migrating a batch, this is all Practices in Base.Practice. Otherwise it is just the Practices in the batch
		WHERE	a.ActiveFlag = 1 ---and

		create clustered index idx_RawPracData on #RawPracData (PracticeCode, ClientCode, ProductCode);

		--Get practices associated to multiple clients, and use business rules to pick a winner
		select b.ClientCode, b.PracticeCode, b.ProductCode, row_number() over ( partition by b.PracticeCode
									  order by b.ProductCode, isnull(pc.ProvCount, 0) desc, b.ClientCode ) as ClientPractRank
		into #PractMultClientRank
		from  #RawPracData b
		left join ( 
					select a1.ClientCode, a1.PracticeCode, a1.ProductCode, count(distinct a1.ProviderCode) as ProvCount
					from Mid.ProviderSponsorship a1 with ( nolock )
						join #RawPracData b1 on b1.PracticeCode = a1.PracticeCode and b1.ClientCode = a1.ClientCode and b1.ProductCode = a1.ProductCode
					group by a1.ClientCode, a1.PracticeCode, a1.ProductCode 
				) pc on pc.ClientCode=b.ClientCode and pc.ProductCode=b.ProductCode and pc.PracticeCode=b.PracticeCode;


		create clustered index idx_PractMultClient_clust on #PractMultClientRank (PracticeCode, ClientCode, ProductCode);

	--	populate the temp TABLE with data FROM Base schemas
		INSERT INTO #PracticeSponsorship 
			(
				PracticeID,PracticeCode,ProductCode,ProductDescription,ProductGroupCode,ProductGroupDescription,
				ClientToProductID,ClientCode,ClientName
			)
		SELECT PracticeID,PracticeCode,ProductCode,ProductDescription,ProductGroupCode,ProductGroupDescription,
		ClientToProductID,ClientCode,ClientName
		FROM
		(
			select a.PracticeID, a.PracticeCode, a.ProductCode, a.ProductDescription, a.ProductGroupCode,
					a.ProductGroupDescription, a.ClientToProductID, a.ClientCode, a.ClientName, isnull(b.ClientPractRank, a.recID) as ClientPractRank
			from #RawPracData a
				left join #PractMultClientRank b on b.PracticeCode = a.PracticeCode and b.ClientCode = a.ClientCode and b.ProductCode = a.ProductCode
		) AS x
		WHERE  x.ClientPractRank = 1

		drop table #RawPracData;
		drop table #PractMultClientRank;

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
			FROM	#PracticeSponsorship a
					LEFT JOIN Mid.PracticeSponsorship b ON (a.PracticeID = b.PracticeID and a.PracticeCode = b.PracticeCode /*and a.ProductCode = b.ProductCode*/)
			WHERE	b.PracticeID IS NULL
		
		--ActionCode UPDATE
			BEGIN TRY DROP TABLE #ColumnsUpdates END TRY BEGIN CATCH END CATCH
			
			SELECT	name, identity(INT,1,1) as recId
			INTO	#ColumnsUpdates
			FROM	tempdb..syscolumns 
			WHERE	id = object_id('TempDB..#PracticeSponsorship')
					AND name NOT IN ('PracticeCode','ProductCode', 'ActionCode')
				
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
						   'FROM	#PracticeSponsorship a'+@newline+
						   'JOIN Mid.PracticeSponsorship b with (nolock) on (a.PracticeID = b.PracticeID and a.PracticeCode = b.PracticeCode /*and a.ProductCode = b.ProductCode*/) '+@newline+
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
			insert INTO Mid.PracticeSponsorship (ClientCode,ClientName,ClientToProductID,PracticeCode,PracticeID,ProductCode,ProductDescription,ProductGroupCode,ProductGroupDescription)
			SELECT DISTINCT ClientCode,ClientName,ClientToProductID,PracticeCode,PracticeID,ProductCode,ProductDescription,ProductGroupCode,ProductGroupDescription 
			FROM #PracticeSponsorship 
			WHERE ActionCode = 1 and practiceid not in (select practiceid from Mid.PracticeSponsorship)

		
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
							  'FROM Mid.PracticeSponsorship a '+@newlineUpdates+
							  'JOIN #PracticeSponsorship b on (a.PracticeID = b.PracticeID and a.PracticeCode = b.PracticeCode /*and a.ProductCode = b.ProductCode*/) '+@newlineUpdates+
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
			FROM	Mid.PracticeSponsorship a 
					JOIN #PracticeBatch as pb on pb.PracticeCode = a.PracticeCode
					LEFT JOIN #PracticeSponsorship b ON (a.PracticeID = b.PracticeID and a.PracticeCode = b.PracticeCode and a.ProductCode = b.ProductCode and a.ClientToProductID = b.ClientToProductID and a.ClientCode = b.ClientCode )
			WHERE	b.PracticeID IS NULL
	

	/*
		DELTAS FOR SOLR HERE
	*/		

	EXEC [hack].[WriteMDLite]	
END TRY
BEGIN CATCH
    SET @ErrorMessage = 'Error in procedure Mid.spuPracticeSponsorshipRefresh, line ' + convert(VARCHAR(20), error_line()) + ': ' + error_message()
    RAISERROR(@ErrorMessage, 18, 1)
END CATCH
GO