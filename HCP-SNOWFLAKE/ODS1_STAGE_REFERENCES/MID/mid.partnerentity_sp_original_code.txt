-- Mid_spuPartnerEntityRefresh
  if @IsProviderDeltaProcessing = 0 
        begin
            insert into #ProviderBatch (ProviderID, ProviderCode) 
            select distinct prov.ProviderID, prov.ProviderCode
			from Base.PartnerToEntity pte 
				join base.Provider prov on pte.PrimaryEntityID = prov.ProviderID
				--join base.Partner p on pte.PartnerID = p.PartnerID
				--where p.PartnerCode = 'MDVIPOAS'
				--where ProviderCode = 'cx9qz'
			--This will get us by for now... If we are doing a FULL FILE refresh, just truncate the table and start fresh
			truncate table Mid.PartnerEntity
          end
        else begin
            insert into #ProviderBatch (ProviderID, ProviderCode)
            select p.ProviderID, p.ProviderCode
			--from base.provider p where providercode = '3y6rn'
            from Snowflake.etl.ProviderDeltaProcessing as a
            inner join Base.Provider as p on p.ProviderID = a.ProviderID
        end

        create index ixPbProviderID on #ProviderBatch (ProviderID)

	--build a temp TABLE with the same structure as the Mid.ProviderSponsorship
		BEGIN TRY DROP TABLE #PartnerEntity END TRY BEGIN CATCH END CATCH
		SELECT	TOP 0 *
		INTO	#PartnerEntity
		FROM	Mid.PartnerEntity
		
		ALTER TABLE #PartnerEntity
		ADD ActionCode INT DEFAULT 0

		if object_id('tempdb..#PermittedOASRecords') is not null drop table #PermittedOASRecords
		select distinct cpte.*, 
			c.ClientCode,	
			p.PartnerID, 
			p.PartnerCode, 
			p.PartnerDescription
		into #PermittedOASRecords
		from base.ClientProductToEntity cpte
		join base.ClientToProduct ctp on cpte.ClientToProductID = ctp.ClientToProductID
		join base.Client c on c.ClientID = ctp.ClientID
		join base.ClientProductToPartner cptp on ctp.ClientToProductID = cptp.ClientToProductID
		join base.Partner p on cptp.PartnerID = p.PartnerID
		where p.PartnerProductCode = 'CDOAS'
		
		/*
		--delete records from Base that are Client-dependant but have no related designation
		delete t
		--select distinct t.*
		--select *
		from base.PartnerToEntity t
		join base.Partner p on t.PartnerID = p.PartnerID
		left join #PermittedOASRecords pOASr on pOASr.EntityID = t.PrimaryEntityID and pOASr.PartnerID = t.PartnerID
		where p.PartnerProductCode = 'CDOAS'
			and pOASR.ClientProductToEntityID is null
			*/

-- Office Dependent (API Partner Type)
		insert #PartnerEntity (
			PartnerToEntityID, 
			PartnerID, 
			PartnerCode, pa.PartnerDescription, 
			PartnerTypeCode, 
			PartnerTypeDescription, 
			PartnerProductCode,
			PartnerProductDescription,
			URLPath, 
			FullURL,
			PrimaryEntityID, 
			PartnerPrimaryEntityID, 
			SecondaryEntityID, 
			PartnerSecondaryEntityID, 
			TertiaryEntityID, 
			PartnerTertiaryEntityID, 
			ProviderCode, 
			OfficeCode, 
			PracticeCode,
			ExternalOASPartnerCode,
			ExternalOASPartnerDescription
		)
		select distinct
			pte.PartnerToEntityID, 
			pa.PartnerID, 
			pa.PartnerCode, pa.PartnerDescription, 
			pt.PartnerTypeCode, 
			pt.PartnerTypeDescription, 
			pa.PartnerProductCode,
			pa.PartnerProductDescription,
			pa.URLPath, 
			'https://' + pa.URLPath + pte.PartnerPrimaryEntityID + '/availability' as FullURL,
			pte.PrimaryEntityID, 
			pte.PartnerPrimaryEntityID, 
			pte.SecondaryEntityID, 
			pte.PartnerSecondaryEntityID, 
			pte.TertiaryEntityID, 
			pte.PartnerTertiaryEntityID, 
			p.ProviderCode, 
			o.OfficeCode, 
			prac.PracticeCode,
			eop.ExternalOASPartnerCode,
			eop.ExternalOASPartnerDescription
		from base.PartnerToEntity pte
		join base.Partner pa on pte.PartnerID = pa.PartnerID
		join base.Provider p on p.ProviderID = pte.PrimaryEntityID
		join base.EntityType pet on pte.PrimaryEntityTypeID = pet.EntityTypeID
		join base.Office o on o.OfficeID = pte.SecondaryEntityID
		join base.providertooffice po on p.ProviderID = po.ProviderID and o.OfficeID = po.OfficeID
		join base.EntityType seet on pte.PrimaryEntityTypeID = seet.EntityTypeID
		left join base.Practice prac on prac.PracticeID = pte.TertiaryEntityID
		left join base.EntityType tet on pte.TertiaryEntityTypeID = tet.EntityTypeID
		join base.PartnerType pt on pa.PartnerTypeID = pt.PartnerTypeID
		join #ProviderBatch pb on pte.PrimaryEntityID = pb.ProviderID
		left join base.ExternalOASPartner eop on pte.ExternalOASPartnerID = eop.ExternalOASPartnerID
		--WHERE pte.SourceCode NOT IN ('SCLIME') --Removed
		WHERE pt.PartnerTypeCode='API' --Added

		
-- Non Office Dependent (URL Partner Type)
		insert #PartnerEntity (
			PartnerToEntityID, 
			PartnerID, 
			PartnerCode, pa.PartnerDescription, 
			PartnerTypeCode, 
			PartnerTypeDescription, 
			PartnerProductCode,
			PartnerProductDescription,
			URLPath, 
			FullURL,
			PrimaryEntityID, 
			PartnerPrimaryEntityID, 
			SecondaryEntityID, 
			PartnerSecondaryEntityID, 
			TertiaryEntityID, 
			PartnerTertiaryEntityID, 
			ProviderCode, 
			OfficeCode, 
			PracticeCode,
			ExternalOASPartnerCode,
			ExternalOASPartnerDescription
		)
		select distinct
			pte.PartnerToEntityID, 
			pa.PartnerID, 
			pa.PartnerCode, pa.PartnerDescription, 
			pt.PartnerTypeCode, 
			pt.PartnerTypeDescription, 
			pa.PartnerProductCode,
			pa.PartnerProductDescription,
			pa.URLPath, 
			case when OASURL is not null then OASURL
				else 'https://' + pa.URLPath + pte.PartnerPrimaryEntityID + '/availability' end as FullURL,
			pte.PrimaryEntityID, 
			pte.PartnerPrimaryEntityID, 
			pte.SecondaryEntityID, 
			pte.PartnerSecondaryEntityID, 
			pte.TertiaryEntityID, 
			pte.PartnerTertiaryEntityID, 
			p.ProviderCode, 
			o.OfficeCode, 
			prac.PracticeCode,
			eop.ExternalOASPartnerCode,
			eop.ExternalOASPartnerDescription
		from base.PartnerToEntity pte
		join #ProviderBatch pb on pte.PrimaryEntityID = pb.ProviderID
		join base.Partner pa on pte.PartnerID = pa.PartnerID
		join base.Provider p on p.ProviderID = pte.PrimaryEntityID
		join base.EntityType pet on pte.PrimaryEntityTypeID = pet.EntityTypeID
		join base.Office o on o.OfficeID = pte.SecondaryEntityID
		--join base.providertooffice po on p.ProviderID = po.ProviderID and --o.OfficeID = po.OfficeID --commented out the providerTooffice join
		join base.EntityType seet on pte.PrimaryEntityTypeID = seet.EntityTypeID
		left join base.Practice prac on prac.PracticeID = pte.TertiaryEntityID
		left join base.EntityType tet on pte.TertiaryEntityTypeID = tet.EntityTypeID
		join base.PartnerType pt on pa.PartnerTypeID = pt.PartnerTypeID
		left join base.ExternalOASPartner eop on pte.ExternalOASPartnerID = eop.ExternalOASPartnerID
		--WHERE pte.SourceCode NOT IN ('SCLIME') --Remove
		WHERE pt.PartnerTypeCode='URL' --Add
			UNION ALL	
		select distinct
			pte.PartnerToEntityID, 
			pa.PartnerID, 
			pa.PartnerCode, pa.PartnerDescription, 
			pt.PartnerTypeCode, 
			pt.PartnerTypeDescription, 
			pa.PartnerProductCode,
			pa.PartnerProductDescription,
			pa.URLPath, 
			case when OASURL is not null then OASURL
				else 'https://' + pa.URLPath + pte.PartnerPrimaryEntityID + '/availability' end as FullURL,
			pte.PrimaryEntityID, 
			pte.PartnerPrimaryEntityID, 
			pte.SecondaryEntityID, 
			pte.PartnerSecondaryEntityID, 
			pte.TertiaryEntityID, 
			pte.PartnerTertiaryEntityID, 
			p.ProviderCode, 
			o.OfficeCode, 
			prac.PracticeCode,
			eop.ExternalOASPartnerCode,
			eop.ExternalOASPartnerDescription
		from base.PartnerToEntity pte
		join #ProviderBatch pb on pte.PrimaryEntityID = pb.ProviderID
		join base.Partner pa on pte.PartnerID = pa.PartnerID
		join base.Provider p on p.ProviderID = pte.PrimaryEntityID
		join base.EntityType pet on pte.PrimaryEntityTypeID = pet.EntityTypeID
		left join base.Office o on o.OfficeID = pte.SecondaryEntityID and o.officeid is null
		join base.EntityType seet on pte.PrimaryEntityTypeID = seet.EntityTypeID
		left join base.Practice prac on prac.PracticeID = pte.TertiaryEntityID
		left join base.EntityType tet on pte.TertiaryEntityTypeID = tet.EntityTypeID
		join base.PartnerType pt on pa.PartnerTypeID = pt.PartnerTypeID
		left join base.ExternalOASPartner eop on pte.ExternalOASPartnerID = eop.ExternalOASPartnerID
		--WHERE pte.SourceCode NOT IN ('SCLIME') --Remove
		WHERE pt.PartnerTypeCode='URL' --Add

		 -- Commented out py Paul Orrison on 7/7/2014.  Will wait to enable until list of affected providers is analyzed.
		 /*
		delete t
		--select distinct t.*
		--select *
		from #PartnerEntity t
		join base.Partner p on t.PartnerID = p.PartnerID
		left join #PermittedOASRecords pOASr on pOASr.EntityID = t.PrimaryEntityID and pOASr.PartnerID = t.PartnerID
		where p.PartnerProductCode = 'CDOAS'
			and pOASR.ClientProductToEntityID is null
			*/
			
		-- Added by Nandita Krishna on 7/2/2014 
		-- HACK to manually delete people from ATHENA client	
/*
		INSERT INTO base.ProviderPartnerApproval(ProviderID, PartnerID, IsActive, EndDate)
		select ProviderId , '00485441-0000-0000-0000-000000000000', 1, '9999-09-09'
		FROM	BASE.PROVIDER WHERE PROVIDERCODE IN ('3CX6C','YXX4W','7Y64Z','XXL4J')
*/

/*
		delete t
        --select distinct t.*
        --select *
        from #PartnerEntity t
                join base.Partner p on t.PartnerID = p.PartnerID
                left outer join base.ProviderPartnerApproval pOASr 
                            on pOASr.ProviderID = t.PrimaryEntityID 
                            and pOASr.PartnerID = t.PartnerID
                            and pOASr.isActive = 1
							and pOASr.enddate > getdate()
        where     p.PartnerCode = 'ATH'
                and pOASR.ProviderID is null 
*/

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
			FROM	#PartnerEntity a
					LEFT JOIN Mid.PartnerEntity b ON (a.ProviderCode = b.ProviderCode 
						and a.PartnerProductCode = b.PartnerProductCode 
						and a.PartnerCode = b.PartnerCode 
						and ISNULL(CAST(a.PracticeCode AS VARCHAR(100)), 'ZZZ') =  ISNULL(CAST(b.PracticeCode AS VARCHAR(100)), 'ZZZ')
						and ISNULL(CAST(a.OfficeCode AS VARCHAR(100)), 'ZZZ') =  ISNULL(CAST(b.OfficeCode AS VARCHAR(100)), 'ZZZ')
						)
			WHERE	b.ProviderCode is null
		
		--ActionCode UPDATE
			BEGIN TRY DROP TABLE #ColumnsUPDATEs END TRY BEGIN CATCH END CATCH
			
			SELECT	name, identity(INT,1,1) as recId
			INTO	#ColumnsUPDATEs
			FROM	tempdb..syscolumns 
			WHERE	id = object_id('TempDB..#PartnerEntity')
					AND name NOT IN ('PartnerToEntityID','ProviderCode','PartnerProductCode', 'PartnerCode', 'ActionCode', 'PracticeCode', 'OfficeCode')
				
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
						   'FROM	#PartnerEntity a'+@newline+
						   'JOIN Mid.PartnerEntity b with (nolock) on (a.ProviderCode = b.ProviderCode'+@newline+ 
								'and a.PartnerProductCode = b.PartnerProductCode'+@newline+ 
								'and a.PartnerCode = b.PartnerCode'+@newline+ 
								'and ISNULL(CAST(a.PracticeCode AS VARCHAR(100)), ''ZZZ'') =  ISNULL(CAST(b.PracticeCode AS VARCHAR(100)), ''ZZZ'')'+@newline+
								'and ISNULL(CAST(a.OfficeCode AS VARCHAR(100)), ''ZZZ'') =  ISNULL(CAST(b.OfficeCode AS VARCHAR(100)), ''ZZZ'')'+@newline+
								')'+@newline+
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
		WHERE	id = object_id('TempDB..#PartnerEntity')
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
			'insert INTO Mid.PartnerEntity ('+@columnListInsert+')
			SELECT '+@columnListInsert+' FROM #PartnerEntity WHERE ActionCode = 1'
			
			EXEC (@sqlInsert)
		
		--ActionCode = 2 (UPDATEs)	
			DECLARE @minUPDATEs INT
			DECLARE @maxUPDATEs INT
			DECLARE @sqlUPDATEs VARCHAR(8000)
			DECLARE @sqlUPDATEsClause VARCHAR(5000)
			DECLARE @columnUPDATEs VARCHAR(1500)
			DECLARE @columnListUPDATEs VARCHAR(8000)
			DECLARE @newlineUPDATEs CHAR(1)
			
			SET @newlineUPDATEs = CHAR(10)
			SET @columnListUPDATEs = ''
			SET @sqlUPDATEs = 'UPDATE a'+@newlineUPDATEs+
							  'SET '	
			SET @sqlUPDATEsClause = '--SELECT *'+@newlineUPDATEs+
							  'FROM Mid.PartnerEntity a '+@newlineUPDATEs+
							  'JOIN #PartnerEntity b with (nolock) on (a.ProviderCode = b.ProviderCode'+@newlineUPDATEs+ 
								'and a.PartnerProductCode = b.PartnerProductCode'+@newlineUPDATEs+ 
								'and a.PartnerCode = b.PartnerCode'+@newlineUPDATEs+ 
								'and ISNULL(CAST(a.PracticeCode AS VARCHAR(100)), ''ZZZ'') =  ISNULL(CAST(b.PracticeCode AS VARCHAR(100)), ''ZZZ'')'+@newlineUPDATEs+
								'and ISNULL(CAST(a.OfficeCode AS VARCHAR(100)), ''ZZZ'') =  ISNULL(CAST(b.OfficeCode AS VARCHAR(100)), ''ZZZ'')'+@newlineUPDATEs+
							  ')'+@newlineUPDATEs+
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
			FROM	Mid.PartnerEntity a 
					inner join #ProviderBatch as pb on pb.ProviderCode = a.ProviderCode
					LEFT JOIN #PartnerEntity b ON (a.ProviderCode = b.ProviderCode 
						and a.PartnerProductCode = b.PartnerProductCode 
						and a.PartnerCode = b.PartnerCode
						and ISNULL(CAST(a.PracticeCode AS VARCHAR(100)), 'ZZZ') =  ISNULL(CAST(b.PracticeCode AS VARCHAR(100)), 'ZZZ')
						and ISNULL(CAST(a.OfficeCode AS VARCHAR(100)), 'ZZZ') =  ISNULL(CAST(b.OfficeCode AS VARCHAR(100)), 'ZZZ')
						)
			WHERE	b.ProviderCode IS NULL
			
		--	Fix multiple Partner Entity IDs per HG ID
			update pe
			set PartnerPrimaryEntityID = pte.PartnerPrimaryEntityID,
				PartnerSecondaryEntityID = pte.PartnerSecondaryEntityID,
				PartnerTertiaryEntityID = pte.PartnerTertiaryEntityID
			--select *
			from mid.PartnerEntity pe
			join Base.PartnerToEntity pte on pe.PartnerToEntityID = pte.PartnerToEntityID
			where ISNULL(pe.PartnerPrimaryEntityID, '') <> ISNULL(pte.PartnerPrimaryEntityID, '') 
			or ISNULL(pe.PartnerSecondaryEntityID, '') <> ISNULL(pte.PartnerSecondaryEntityID, '') 
			or ISNULL(pe.PartnerTertiaryEntityID, '') <> ISNULL(pte.PartnerTertiaryEntityID, '') 