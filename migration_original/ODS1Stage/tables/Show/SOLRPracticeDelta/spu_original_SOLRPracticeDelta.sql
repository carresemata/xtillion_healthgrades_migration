-- 1. Show_spuSOLRPracticeDeltaRefresh (line 408)

	if @IsProviderDeltaProcessing = 0 
	BEGIN		
		TRUNCATE TABLE Show.SOLRPracticeDelta
	     
		insert into Show.SOLRPracticeDelta (PracticeID, SolrDeltaTypeCode, StartDeltaProcessDate, MidDeltaProcessComplete)
		select pr.PracticeID, '1' as SolrDeltaTypeCode, getdate() as StartDeltaProcessDate, '1' as MidDeltaProcessComplete 
  		from Base.Practice pr
  			left join Show.SOLRPracticeDelta spd on pr.PracticeID = spd.PracticeID
  		where spd.PracticeID is null
  	
		insert into Show.SOLRPracticeDelta (PracticeID, SolrDeltaTypeCode, StartDeltaProcessDate, MidDeltaProcessComplete)
		select e.practiceid, '1' as SolrDeltaTypeCode, getdate() as StartDeltaProcessDate, '1' as MidDeltaProcessComplete 
        from Snowflake.etl.ProviderDeltaProcessing as a
        inner join Base.ProviderToOffice as d on d.ProviderID = a.ProviderID
        inner join Base.Office as e on e.OfficeID = d.OfficeID
        WHERE	e.practiceid not in (select practiceid from Show.SOLRPracticeDelta)

  		TRUNCATE TABLE Show.SOLRPractice
	END        
	ELSE
	BEGIN
		UPDATE	Show.SOLRPracticeDelta 
		SET		ENDDeltaProcessDate = null,
				StartMoveDate = null,
				ENDMoveDate = null
		FROM	Snowflake.etl.ProviderDeltaProcessing as a
		join	Base.ProviderToOffice po on a.ProviderID = po.ProviderID
		join	Base.Office o on po.OfficeID = o.OfficeID
		join	Base.Practice pr on o.PracticeID = pr.PracticeID		
		join	Show.SOLRPracticeDelta spd on pr.PracticeID = spd.PracticeID

		select distinct pr.PracticeID, '1' as SolrDeltaTypeCode, '1' as MidDeltaProcessComplete, getdate() as StartDeltaProcessDate
		into #PracticeAdds
		from Snowflake.etl.ProviderDeltaProcessing as a
		join Base.ProviderToOffice po on a.ProviderID = po.ProviderID
		join Base.Office o on po.OfficeID = o.OfficeID
		join Base.Practice pr on o.PracticeID = pr.PracticeID	
		left join Show.SOLRPracticeDelta spd on pr.PracticeID = spd.PracticeID and spd.StartDeltaProcessDate is not null and spd.ENDDeltaProcessDate is null
		where spd.PracticeID is null		
				
		insert into Show.SOLRPracticeDelta (PracticeID, SolrDeltaTypeCode, MidDeltaProcessComplete, StartDeltaProcessDate)
		select PracticeID, SolrDeltaTypeCode, MidDeltaProcessComplete, StartDeltaProcessDate
		from #PracticeAdds
			
	END




-- 2. hack_spuSOLRPractice (line 423)

--STAMP THE ENDDeltaProcessDate FOR THE ONES WE ALREADY PROCESSED (Look at the notes above for possible expansion)
	update a
	set a.ENDDeltaProcessDate = getdate()
	--select *
	from Show.SOLRPracticeDelta a
	where StartDeltaProcessDate is not null
	and ENDDeltaProcessDate is null