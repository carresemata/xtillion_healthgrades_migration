SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [Mid].[spuProviderRecognitionRefresh]
(
    @IsProviderDeltaProcessing bit = 0
)
as

/*
    Created By:		John Tran
	Created On:		12/30/2011	

	Updated By:		Zafer Faddah
	Updated On:		08/27/2014
	Update Note:	Replaced dbo.Individual with src.Provider 

	Reoccurence:	This stored procedure will INSERT/UPDATE/DELETE data from the Mid.ProviderRecognition table that is used for the Provider SOLR Core

	Test:			EXEC Mid.spuProviderRecognitionRefresh
						
*/


declare @ErrorMessage varchar(1000)

begin try

    --Create & fill table that holds the list of provider records that were supposed to migrate with the batch.  
    --  If this is a full file refresh, migrate all Base.Provider records.
    --  If this is a batch migration, the list records comes from provider deltas
    --  Obviously, if this is a full file refresh then technically a list of the records that migrated isn't neccessary, but it makes
    --      the code that inserts into #Provider much simpler as it removes the need for separate insert queries or dynamic SQL
        begin try drop table #ProviderBatch end try begin catch end catch
        create table #ProviderBatch (ProviderID uniqueidentifier)
        
        if @IsProviderDeltaProcessing = 0 
        begin
			truncate table Mid.ProviderRecognition
            insert into #ProviderBatch (ProviderID) select a.ProviderID from Base.Provider as a order by a.ProviderID
        end
        else begin
			insert into #ProviderBatch (ProviderID)
            select a.ProviderID
            from Snowflake.etl.ProviderDeltaProcessing as a
        end
		
	CREATE CLUSTERED INDEX [CIX_TempProviderBatchRecognitionProviderId]	ON #ProviderBatch([ProviderID])


	--build a temp table with the same structure as the Mid.ProviderRecognition
		begin try drop table #ProviderRecognition end try begin catch end catch
		select top 0 *
		into #ProviderRecognition
		from Mid.ProviderRecognition
		
		alter table #ProviderRecognition
		add ActionCode int default 0
		
	--populate the temp table with data from Base schemas
		insert into #ProviderRecognition 
			(
				ProviderID,RecognitionCode,RecognitionDisplayName,ServiceLine,FacilityCode,FacilityName
			)
		--HealthGrades Recognized Provider
		select distinct a.ProviderID, b.AwardCode as RecognitionCode, b.AwardDisplayName as RecognitionDisplayName, NULL as ServiceLine, NULL as FacilityCode, NULL as FacilityName
		from #ProviderBatch as pb  --When not migrating a batch, this is all providers in Base.Provider. Otherwise it is just the providers in the batch
		inner join Base.vwuProviderRecognition a with (nolock) on a.ProviderID = pb.ProviderID
		inner join Base.Award b with (nolock) on (a.AwardID = b.AwardID)
		/*
		union
		*/
		--HealthGrades 5STAR Providers
		
		create index temp on #ProviderRecognition (ProviderID)

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
			from #ProviderRecognition a
			left join Mid.ProviderRecognition b on (a.ProviderID = b.ProviderID and a.RecognitionCode = b.RecognitionCode and a.ServiceLine = b.ServiceLine and a.FacilityCode = b.FacilityCode)
			where b.ProviderID is null
		
		--ActionCode Update
			begin try drop table #ColumnsUpdates end try begin catch end catch
			
			select name, identity(int,1,1) as recId
			into #ColumnsUpdates
			from tempdb..syscolumns 
			where id = object_id('TempDB..#ProviderRecognition')
			and name not in ('ProviderID','RecognitionCode','ServiceLine','FacilityCode'/*PK's*/, 'ActionCode')
				
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
						   'from #ProviderRecognition a'+@newline+
						   'join Mid.ProviderRecognition b with (nolock) on (a.ProviderID = b.ProviderID and a.RecognitionCode = b.RecognitionCode and a.ServiceLine = b.ServiceLine and a.FacilityCode = b.FacilityCode)'+@newline+
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
		where id = object_id('TempDB..#ProviderRecognition')
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
			'insert into Mid.ProviderRecognition ('+@columnListInsert+')
			select '+@columnListInsert+' from #ProviderRecognition where ActionCode = 1'
			
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
							  'from Mid.ProviderRecognition a with (nolock)'+@newlineUpdates+
							  'join #ProviderRecognition b on (a.ProviderID = b.ProviderID and a.RecognitionCode = b.RecognitionCode and a.ServiceLine = b.ServiceLine and a.FacilityCode = b.FacilityCode)'+@newlineUpdates+
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
			from Mid.ProviderRecognition a with (nolock)
            inner join #ProviderBatch as pb on pb.ProviderID = a.ProviderID	
			left join #ProviderRecognition b on (a.ProviderID = b.ProviderID and a.RecognitionCode = b.RecognitionCode and isnull(a.ServiceLine,'') = isnull(b.ServiceLine,'') and isnull(a.FacilityCode,'') = isnull(b.FacilityCode,''))
			where b.ProviderID is null
	
	/*
		DELTAS FOR SOLR HERE
	*/		
		
		
end try
begin catch
    set @ErrorMessage = 'Error in procedure Mid.spuProviderRecognitionRefresh, line ' + convert(varchar(20), error_line()) + ': ' + error_message()
    raiserror(@ErrorMessage, 18, 1)
end catch
GO