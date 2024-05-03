SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [Mid].[spuProviderLanguageRefresh]
(
    @IsProviderDeltaProcessing bit = 0
)
as

/*
    Created By:		John Tran
	Created On:		12/30/2011	

	Reoccurence:	This stored procedure will INSERT/UPDATE/DELETE data from the Mid.ProviderLanguage table that is used for the Provider SOLR Core
					This only has two fields in the table so it is pointless to create a process like the other SP's

	Updated By:		Zafer Faddah
	Updated On:		08/27/2014
	Update Note:	Replaced dbo.Individual with src.Provider 	

	Test:			EXEC Mid.spuProviderLanguageRefresh
						
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
        
        if @IsProviderDeltaProcessing = 0 begin
            insert into #ProviderBatch (ProviderID) 
            select a.ProviderID 
            from Base.Provider as a 
            order by a.ProviderID
          end
        else begin
			insert into #ProviderBatch (ProviderID)
            select a.ProviderID
            from Snowflake.etl.ProviderDeltaProcessing as a
        end

	--build a temp table with the same structure as the Mid.ProviderLanguage
		begin try drop table #ProviderLanguage end try begin catch end catch
		select top 0 *
		into #ProviderLanguage
		from Mid.ProviderLanguage
		
		alter table #ProviderLanguage
		add ActionCode int default 0
		
	--populate the temp table with data from Base schemas
		insert into #ProviderLanguage 
			(
				ProviderID, LanguageName
			)
		select a.ProviderID, b.LanguageName
		from #ProviderBatch as pb  --When not migrating a batch, this is all providers in Base.Provider. Otherwise it is just the providers in the batch
		inner join Base.ProviderToLanguage as a with (nolock) on a.ProviderID = pb.ProviderID
		inner join Base.Language as b with (nolock) on b.LanguageID = a.LanguageID

		create index temp on #ProviderLanguage (ProviderID)

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
			from #ProviderLanguage a
			left join Mid.ProviderLanguage b on (a.ProviderID = b.ProviderID and a.LanguageName = b.LanguageName)
			where b.ProviderId is null
		
		--Insert the new records
		insert into Mid.ProviderLanguage (ProviderId, LanguageName)
		select ProviderId, LanguageName
		from #ProviderLanguage 
		where ActionCode = 1
		
		--delete the records that DNE
		delete a
		--select *
		from Mid.ProviderLanguage a with (nolock)
        inner join #ProviderBatch as pb on pb.ProviderID = a.ProviderID	
		left join #ProviderLanguage b on (a.ProviderID = b.ProviderID and a.LanguageName = b.LanguageName)
		where b.ProviderID is null
	
	/*
		DELTAS FOR SOLR HERE
	*/		
		
		
end try
begin catch
    set @ErrorMessage = 'Error in procedure Mid.spuProviderLanguageRefresh, line ' + convert(varchar(20), error_line()) + ': ' + error_message()
    raiserror(@ErrorMessage, 18, 1)
end catch
GO