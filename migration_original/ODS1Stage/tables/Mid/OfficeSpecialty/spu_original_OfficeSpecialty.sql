-- Mid_spuOfficeSpecialtyRefresh
begin try drop table #OfficeBatch end try begin catch end catch
        create table #OfficeBatch (OfficeID uniqueidentifier)
        
        if @IsProviderDeltaProcessing = 0 begin
            insert into #OfficeBatch (OfficeID) select a.OfficeID from Base.Office as a order by a.OfficeID
          end
        else begin
            insert into #OfficeBatch (OfficeID)
            select distinct d.OfficeID
            from Snowflake.etl.ProviderDeltaProcessing as a
            inner join Base.ProviderToOffice as d on d.ProviderID = a.ProviderID
            order by d.OfficeID
        end

	--build a temp table with the same structure as the Mid.OfficeSpecialty
		begin try drop table #OfficeSpecialty end try begin catch end catch
		select top 0 *
		into #OfficeSpecialty
		from Mid.OfficeSpecialty
		
		alter table #OfficeSpecialty
		add ActionCode int default 0
		
	--populate the temp table with data from Base schemas
		insert into #OfficeSpecialty 
			(
				OfficeToSpecialtyID,OfficeID,SpecialtyCode,Specialty,Specialist,Specialists,LegacyKey
			)
		select etmt.EntityToMedicalTermID as OfficeToSpecialtyID, etmt.EntityID as OfficeID, mt.MedicalTermCode as SpecialtyCode, mt.MedicalTermDescription1 as Specialty, mt.MedicalTermDescription2 as Specialist, mt.MedicalTermDescription3 as Specialists, mt.LegacyKey as LegacyKey
		from #OfficeBatch as pb  --When not migrating a batch, this is all offices in Base.Office. Otherwise it is just the offices for the providers in the batch
		inner join Base.EntityToMedicalTerm etmt with (nolock) on etmt.EntityID = pb.OfficeID
		join Base.MedicalTerm mt with (nolock) on etmt.MedicalTermID = mt.MedicalTermID
		join Base.MedicalTermType mtt with (nolock) on mt.MedicalTermTypeID = mtt.MedicalTermTypeID and mtt.MedicalTermTypeCode = 'Specialty'

		create index temp on #OfficeSpecialty (OfficeToSpecialtyID)

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
			from #OfficeSpecialty a
			left join Mid.OfficeSpecialty b on (a.OfficeToSpecialtyID = b.OfficeToSpecialtyID)
			where b.OfficeToSpecialtyID is null
		
		--ActionCode Update
			begin try drop table #ColumnsUpdates end try begin catch end catch
			
			select name, identity(int,1,1) as recId
			into #ColumnsUpdates
			from tempdb..syscolumns 
			where id = object_id('TempDB..#OfficeSpecialty')
			and name not in ('OfficeToSpecialtyID'/*PK*/, 'ActionCode')
				
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
						   'from #OfficeSpecialty a'+@newline+
						   'join Mid.OfficeSpecialty b with (nolock) on (a.OfficeToSpecialtyID = b.OfficeToSpecialtyID)'+@newline+
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
		where id = object_id('TempDB..#OfficeSpecialty')
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
			'insert into Mid.OfficeSpecialty ('+@columnListInsert+')
			select '+@columnListInsert+' from #OfficeSpecialty where ActionCode = 1'
			
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
							  'from Mid.OfficeSpecialty a with (nolock)'+@newlineUpdates+
							  'join #OfficeSpecialty b on (a.OfficeToSpecialtyID = b.OfficeToSpecialtyID)'+@newlineUpdates+
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
			from Mid.OfficeSpecialty a with (nolock)
            inner join #OfficeBatch as pb on pb.OfficeID = a.OfficeID	
			left join #OfficeSpecialty b on (a.OfficeToSpecialtyID = b.OfficeToSpecialtyID)
			where b.OfficeToSpecialtyID is null