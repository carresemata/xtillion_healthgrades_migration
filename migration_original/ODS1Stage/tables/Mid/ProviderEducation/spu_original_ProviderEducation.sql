-- Mid_spuProviderEducationRefresh
if @IsProviderDeltaProcessing = 0 begin
            insert into #ProviderBatch (ProviderID) select a.ProviderID from Base.Provider as a order by a.ProviderID
          end
        else begin
            insert into #ProviderBatch (ProviderID)
            select a.ProviderID
            from Snowflake.etl.ProviderDeltaProcessing as a
        end

	--build a temp table with the same structure as the Mid.ProviderEducation
		begin try drop table #ProviderEducation end try begin catch end catch
		select top 0 *
		into #ProviderEducation
		from Mid.ProviderEducation
		
		alter table #ProviderEducation
		add ActionCode int default 0
		
		CREATE CLUSTERED INDEX ncix_providerid on #ProviderBatch ([ProviderID])

	--populate the temp table with data from Base schemas
		insert into #ProviderEducation 
			(
				ProviderToEducationInstitutionID, ProviderID,EducationInstitutionName,EducationInstitutionTypeCode,EducationInstitutionTypeDescription,
				GraduationYear,PositionHeld,DegreeAbbreviation,City,State,NationName
			)
		select distinct a.ProviderToEducationInstitutionID, a.ProviderID, b.EducationInstitutionName, c.EducationInstitutionTypeCode, c.EducationInstitutionTypeDescription,
			a.GraduationYear, a.PositionHeld, e.DegreeAbbreviation, f.City, f.State, g.NationName  
		from #ProviderBatch as pb  --When not migrating a batch, this is all providers in Base.Provider. Otherwise it is just the providers in the batch
		inner join Base.ProviderToEducationInstitution as a with (nolock) on a.ProviderID = pb.ProviderID
		inner join Base.EducationInstitution as b with (nolock) on b.EducationInstitutionID = a.EducationInstitutionID
		inner join Base.EducationInstitutionType as c with (nolock) on c.EducationInstitutionTypeID = a.EducationInstitutionTypeID
		left join Base.Address as d with (nolock) on d.AddressID = b.AddressID
		left join Base.CityStatePostalCode f with (nolock) on d.CityStatePostalCodeID = f.CityStatePostalCodeID
		left join Base.Nation g with (nolock) on f.NationID = g.NationID
		left join Base.Degree as e with (nolock) on e.DegreeID = a.DegreeID

		create index temp on #ProviderEducation (ProviderToEducationInstitutionID)

		declare @sql varchar(max), @CrLf varchar(2) = char(13) + char(10)
		
  --  --If Full-file refresh, truncate destination & just insert
		--declare @sql varchar(max), @CrLf varchar(2) = char(13) + char(10)
  --      if @IsProviderDeltaProcessing = 0 begin
  --          truncate table Mid.ProviderEducation

  --          declare @ColumnList varchar(max)
  --          select @ColumnList = coalesce(@ColumnList + ', ', '') + '[src].' + a.COLUMN_NAME 
  --          from (select name as COLUMN_NAME from tempdb..syscolumns where id = object_id('TempDB..#ProviderEducation')) as a 
  --          inner join INFORMATION_SCHEMA.COLUMNS as b on b.COLUMN_NAME = a.COLUMN_NAME 
  --          where b.TABLE_SCHEMA = 'mid' and b.TABLE_NAME = 'ProviderEducation'
  --          order by b.ORDINAL_POSITION
            
  --          set @sql = 'insert into Mid.ProviderEducation (' + replace(@ColumnList, '[src].', '') + ')' + @CrLf
  --              + 'select ' + @ColumnList + @CrLf
  --              + 'from #ProviderEducation as src' + @CrLf

  --          print '@sql: ' + isnull(@sql, 'null')
  --          exec (@sql)
  --        end
  --      else begin            
    
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
			    from #ProviderEducation a
			    left join Mid.ProviderEducation b on 
				    (
					    a.ProviderToEducationInstitutionID = b.ProviderToEducationInstitutionID 
				    )
			    where b.ProviderId is null
    		
		    --ActionCode Update
			    --define column set for UPDATES
			    begin try drop table #ColumnsUpdates end try begin catch end catch
    			
			    select name, identity(int,1,1) as recId
			    into #ColumnsUpdates
			    from tempdb..syscolumns 
			    where id = object_id('TempDB..#ProviderEducation')
			    and name not in ('ProviderToEducationInstitutionID', 'ActionCode')
    				
			    --build the sql statement with dynamic sql to check if we need to update any columns
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
						       'from #ProviderEducation a'+@newline+
						       'join Mid.ProviderEducation b with (nolock) on (a.ProviderToEducationInstitutionID = b.ProviderToEducationInstitutionID)'+@newline+ 
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
		    where id = object_id('TempDB..#ProviderEducation')
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
			    'insert into Mid.ProviderEducation ('+@columnListInsert+')
			    select '+@columnListInsert+' from #ProviderEducation where ActionCode = 1'
    			
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
							      'from Mid.ProviderEducation a with (nolock)'+@newlineUpdates+
							      'join #ProviderEducation b on (a.ProviderToEducationInstitutionID = b.ProviderToEducationInstitutionID)'+@newlineUpdates+
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
			    from Mid.ProviderEducation a with (nolock)
                inner join #ProviderBatch as pb on pb.ProviderID = a.ProviderID	
			    left join #ProviderEducation b on (a.ProviderToEducationInstitutionID = b.ProviderToEducationInstitutionID)
			    where b.ProviderToEducationInstitutionID is null