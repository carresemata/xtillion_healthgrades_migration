-- mid.spuprovideraffiliationrefresh

if @IsProviderDeltaProcessing = 0 begin
            insert into #ProviderBatch (ProviderID) select a.ProviderID from Base.Provider as a order by a.ProviderID
          end
        else begin
            insert into #ProviderBatch (ProviderID)
            select a.ProviderID
            from Snowflake.etl.ProviderDeltaProcessing as a
        end

	--build a temp table with the same structure as the Mid.ProviderAffiliation
		begin try drop table #ProviderAffiliation end try begin catch end catch
		select top 0 *
		into #ProviderAffiliation
		from Mid.ProviderAffiliation
		
		alter table #ProviderAffiliation
		add ActionCode int default 0
		
	--populate the temp table with data from Base schemas
		insert into #ProviderAffiliation 
			(
				ProviderToAffiliationID,ProviderID,AffiliationBeginDate,AffiliationEndDate,AffiliationName,
				AffiliationTypeCode,AffiliationTypeDescription,RoleCode,RoleDescription
			)
		select a.ProviderToAffiliationID,a.ProviderID, a.AffiliationBeginDate, a.AffiliationEndDate, a.AffiliationName, 
		b.AffiliationTypeCode, b.AffiliationTypeDescription, c.RoleCode, c.RoleDescription
		from #ProviderBatch as pb  --When not migrating a batch, this is all providers in Base.Provider. Otherwise it is just the providers in the batch
		inner join Base.ProviderToAffiliation as a with (nolock) on a.ProviderID = pb.ProviderID
		inner join Base.Affiliation as b with (nolock) on a.AffiliationID = b.AffiliationID
		inner join Base.ProviderRole as c with (nolock) on a.ProviderRoleID = c.ProviderRoleID
		
		create index temp on #ProviderAffiliation (ProviderToAffiliationID)

	/*
		Flag record level actions for ActionCode
			0 = No Change
			1 = Insert
			2 = Update
	*/
		--ActionCode Insert
			update a
			set a.ActionCode = 1
			--select *
			from #ProviderAffiliation a
			left join Mid.ProviderAffiliation b on (a.ProviderToAffiliationID = b.ProviderToAffiliationID)
			where b.ProviderToAffiliationID is null
		
		--ActionCode Update
			begin try drop table #ColumnsUpdates end try begin catch end catch
			
			select name, identity(int,1,1) as recId
			into #ColumnsUpdates
			from tempdb..syscolumns 
			where id = object_id('TempDB..#ProviderAffiliation')
			and name not in ('ProviderToAffiliationID'/*PK*/, 'ActionCode')
				
			--build the sql statement with dynamic sql to check if we need to update any columns
				declare @sql varchar(8000)
				declare @min int
				declare @max int
				declare @whereClause varchar(8000)
				declare @column varchar(100)
				declare @newline char(1)
				declare @globalCheck varchar(3)

				set @min = 1
				set @whereClause = ''
				set @newline = char(10)
				set @sql = 'update a'+@newline+ 
						   'set a.ActionCode = 2'+@newline+
						   '--select *'+@newline+
						   'from #ProviderAffiliation a'+@newline+
						   'join Mid.ProviderAffiliation b with (nolock) on (a.ProviderToAffiliationID = b.ProviderToAffiliationID)'+@newline+
						   'where '
						   
				select @max = MAX(recId) from #ColumnsUpdates

				while @min <= @max	
					begin
						select @column = name from #ColumnsUpdates where recId = @min 
						set @whereClause = @whereClause +'BINARY_CHECKSUM(isnull(cast(a.'+@column+' as varchar(max)),'''')) <> BINARY_CHECKSUM(isnull(cast(b.'+@column+' as varchar(max)),''''))'+@newline
							--put an OR for all except for the last column check
							if @min < @max 
								begin
									set @whereClause = @whereClause+' or '
								end

						
						set @min = @min + 1
					end

				set @sql = @sql + @whereClause
				exec (@sql)

	/*
		Complete the ActionCode
	*/
	
		--define column set for INSERTS 
		begin try drop table #ColumnInserts end try begin catch end catch

		select name, identity(int,1,1) as recId
		into #ColumnInserts
		from tempdb..syscolumns 
		where id = object_id('TempDB..#ProviderAffiliation')
		and name <> 'ActionCode'--do not need to insert/update this field
		
		--create the column set
		declare @columnInsert varchar(100)
		declare @columnListInsert varchar(8000)
		declare @minInsert int
		declare @maxInsert int
		
		set @minInsert = 1
		set @columnListInsert = ''
		select @maxInsert = MAX(recId) from #ColumnInserts 
		
		while @minInsert <= @maxInsert
			begin
				select @columnInsert = name from #ColumnInserts where recId = @minInsert
				set @columnListInsert = @columnListInsert + @columnInsert
				
				if @minInsert <@maxInsert
					begin
						set @columnListInsert = @columnListInsert+','
					end
				
				set @minInsert = @minInsert + 1
			end
		
		--ActionCode = 1 (Inserts)
			declare @sqlInsert varchar(8000)
			set @sqlInsert = 
			'insert into Mid.ProviderAffiliation ('+@columnListInsert+')
			select '+@columnListInsert+' from #ProviderAffiliation where ActionCode = 1'
			
			exec (@sqlInsert)
		
		--ActionCode = 2 (Updates)	
			declare @minUpdates int
			declare @maxUpdates int
			declare @sqlUpdates varchar(8000)
			declare @sqlUpdatesClause varchar(500)
			declare @columnUpdates varchar(150)
			declare @columnListUpdates varchar(8000)
			declare @newlineUpdates char(1)
			
			set @newlineUpdates = char(10)
			set @columnListUpdates = ''
			set @sqlUpdates = 'update a'+@newlineUpdates+
							  'set '	
			set @sqlUpdatesClause = '--select *'+@newlineUpdates+
							  'from Mid.ProviderAffiliation a with (nolock)'+@newlineUpdates+
							  'join #ProviderAffiliation b on (a.ProviderToAffiliationID = b.ProviderToAffiliationID)'+@newlineUpdates+
							  'where b.ActionCode = 2'
							  
			select @minUpdates = MIN(recId) from #ColumnsUpdates 
			select @maxUpdates = MAX(recId) from #ColumnsUpdates
			
			while @minUpdates <= @maxUpdates
				begin
					select @columnUpdates = name from #ColumnsUpdates where recId = @minUpdates
					set @columnListUpdates = @columnListUpdates + 'a.'+@columnUpdates+' = b.'+@columnUpdates
					
					if @minUpdates < @maxUpdates
						begin
							set @columnListUpdates = @columnListUpdates+','+@newlineUpdates+''
						end
					else
						begin
							set @columnListUpdates = @columnListUpdates+@newlineUpdates+@sqlUpdatesClause
						end
					
					set @minUpdates = @minUpdates + 1
				end
			
			set @sqlUpdates = @sqlUpdates + @columnListUpdates
			
			exec (@sqlUpdates)

		--ActionCode = N (Deletes)
			delete a
			--select *
			from Mid.ProviderAffiliation a with (nolock)
            inner join #ProviderBatch as pb on pb.ProviderID = a.ProviderID	
			left join #ProviderAffiliation b on (a.ProviderToAffiliationID = b.ProviderToAffiliationID)
			where b.ProviderToAffiliationID is null