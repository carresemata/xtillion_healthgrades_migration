-- etl.spumergeprovidercondition

begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
	create table #swimlane (
		ProviderID uniqueidentifier, 
		ProviderCode varchar(50),
		EntityID uniqueidentifier, 
		MedicalTermID uniqueidentifier, 
		ConditionCode varchar(50),
		DecileRank int, 
		IsPreview bit, 
		LastUpdateDate datetime, 
		MedicalTermRank int, 
		NationalRankingA int, 
		NationalRankingB int, 
		PatientCount int, 
		PatientCountIsFew bit, 
		Searchable int, 
		SourceCode varchar(50), 
		SourceSearch tinyint, 
		RowRank int,
		primary key (ProviderID, MedicalTermID)
	)
		
	insert into	#swimlane (ProviderID, ProviderCode, EntityID, MedicalTermID, ConditionCode, DecileRank, IsPreview, LastUpdateDate, MedicalTermRank, NationalRankingA, NationalRankingB,PatientCount, PatientCountIsFew, Searchable, SourceCode, SourceSearch, RowRank)
	select		ProviderID, ProviderCode, EntityID, MedicalTermID, ConditionCode, DecileRank, IsPreview, LastUpdateDate, MedicalTermRank, NationalRankingA, NationalRankingB,PatientCount, PatientCountIsFew, Searchable, SourceCode, SourceSearch, RowRank
	from(
		select	case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
				case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as EntityID, 
				x.ProviderCode, y.MedicalTermID, y.ConditionCode, y.DecileRank, y.IsPreview, isnull(y.LastUpdateDate, getutcdate()) as LastUpdateDate, y.MedicalTermRank, y.NationalRankingA, y.NationalRankingB, y.PatientCount, y.PatientCountIsFew, y.Searchable, isnull(y.SourceCode, 'Profisee') as SourceCode, isnull(y.SourceSearch, 0) as SourceSearch, 
				row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.ConditionCode order by x.CREATE_DATE desc) as RowRank
		from(
			select	w.* 
			from(
				select		p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, p.Condition_Payload as ProviderJSON
				from		raw.ProviderProfileProcessingDeDup as d with (nolock)
				inner join	raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
				where		isnull(p.HasCondition,0) = 1 
							and p.Condition_Payload is not null
			) w
			where	w.ProviderJSON is not null
		) x
		cross apply(
			select	*, convert(uniqueidentifier, convert(varbinary(20), z.ConditionCode)) as MedicalTermID
			from(
				select	*
				from	openjson(x.ProviderJSON) with (
							DecileRank int '$.DecileRank'
							,IsPreview bit '$.IsPreview'
							,LastUpdateDate datetime '$.LastUpdateDate'
							,ConditionCode varchar(50) '$.ConditionCode'
							,MedicalTermRank int '$.MedicalTermRank'
							,NationalRankingA int '$.NationalRankingA'
							,NationalRankingB int '$.NationalRankingB'
							,PatientCount int '$.PatientCount'
							,PatientCountIsFew bit '$.PatientCountIsFew'
							,Searchable int '$.Searchable'
							,SourceCode varchar(25) '$.SourceCode'
							,SourceSearch tinyint '$.SourceSearch')
			) z
		) y
		inner join	ODS1Stage.Base.MedicalTerm as mt 
					on mt.MedicalTermID = y.MedicalTermID
		inner join	ODS1Stage.Base.MedicalTermType as mtt 
					on mtt.MedicalTermTypeID = mt.MedicalTermTypeID 
					and mtt.MedicalTermTypeCode = 'Condition'
        left join 	ODS1Stage.Base.Provider as pID 
					on pID.ProviderCode = x.ProviderCode
		where		y.ConditionCode is not null
	) a
	where		a.RowRank=1
	order by	ProviderID, MedicalTermID

	if @OutputDestination = 'ODS1Stage' begin
		declare @EntityTypeID uniqueidentifier = (select EntityTypeID from ODS1Stage.Base.EntityType where EntityTypeCode = 'PROV')	
		declare @medicaltermtypeID uniqueidentifier = (select MedicalTermTypeID from ODS1Stage.Base.MedicalTermType where MedicalTermTypeCode='Condition')
		
		--Records to Delete (where the provider loses all DCPs)
		if object_id('tempdb..#DeleteAll') is not null drop table #DeleteAll
		select		EntityToMedicalTermID
		into		#DeleteAll
		from		raw.ProviderProfileProcessingDeDup as d with (nolock)
		inner join	raw.ProviderProfileProcessing as p with (nolock) 
					on p.rawProviderProfileID=d.rawProviderProfileID
        inner join  ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.PROVIDER_CODE
	    inner join	ODS1Stage.Base.EntityToMedicalTerm pc with (nolock) 
					on pc.EntityID = p2.ProviderID
	    inner join	ODS1Stage.Base.MedicalTerm as mt with (nolock) 
					on mt.MedicalTermID = pc.MedicalTermID 
					and mt.MedicalTermTypeID = @medicaltermtypeID
		where		isnull(p.HasCondition,0) = 0
	
		delete ODS1Stage.Base.EntityToMedicalTerm where EntityToMedicalTermID in (select EntityToMedicalTermID from #DeleteAll)
	
		--Records to Delete (where the provider loses some DCPs)
		if object_id('tempdb..#DeleteSome') is not null drop table #DeleteSome
		select	    EntityToMedicalTermID
		into		#DeleteSome
	    from		raw.ProviderProfileProcessingDeDup as d with (nolock)
		inner join	raw.ProviderProfileProcessing as p with (nolock) 
					on p.rawProviderProfileID=d.rawProviderProfileID
        inner join  ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.PROVIDER_CODE
	    inner join	ODS1Stage.Base.EntityToMedicalTerm pc with (nolock) 
					on pc.EntityID = p2.ProviderID
	    inner join	ODS1Stage.Base.MedicalTerm as mt with (nolock) 
					on mt.MedicalTermID = pc.MedicalTermID 
					and mt.MedicalTermTypeID = @medicaltermtypeID
		left join	#swimlane T
					on T.ProviderID = pc.EntityID
					and T.MedicalTermID = pc.MedicalTermID
		where		isnull(p.HasCondition,0) = 1
					and T.ProviderID is null

		delete ODS1Stage.Base.EntityToMedicalTerm where EntityToMedicalTermID in (select EntityToMedicalTermID from #DeleteSome)
	
		--Records to Update (Provider already has DCPs)
		update dest
		set dest.PatientCountIsFew = src.PatientCountIsFew, dest.LastUpdateDate = src.LastUpdateDate, dest.IsPreview = src.IsPreview, 
				dest.NationalRankingA = src.NationalRankingA, dest.PatientCount = src.PatientCount, dest.SourceSearch = src.SourceSearch, 
				dest.NationalRankingB = src.NationalRankingB, /*dest.EntityToMedicalTermID = newid(),*/ dest.SourceCode = src.SourceCode, 
				/*dest.EntityTypeID = @EntityTypeID,*/ dest.MedicalTermRank = src.MedicalTermRank
		--select count(*)
		from #swimlane src
	    inner join ODS1Stage.Base.EntityToMedicalTerm dest on dest.EntityID = src.ProviderID and dest.MedicalTermID = src.MedicalTermID
		where (isnull(dest.PatientCountIsFew,0) <> isnull(src.PatientCountIsFew,0) or /*dest.LastUpdateDate <> src.LastUpdateDate or*/ isnull(dest.IsPreview,0) <> isnull(src.IsPreview,0) or 
				isnull(dest.NationalRankingA,0) <> isnull(src.NationalRankingA,0) or isnull(dest.PatientCount,0) <> isnull(src.PatientCount,0) or isnull(dest.SourceSearch,0) <> isnull(src.SourceSearch,0) or 
				isnull(dest.NationalRankingB,0) <> isnull(src.NationalRankingB,0) or /*dest.SourceCode <> src.SourceCode or*/ isnull(dest.MedicalTermRank,0) <> isnull(src.MedicalTermRank,0))
		--46 min, 137,137,120 without the WHERE clause	
		--2 min to run the entire statement, 20 rows affected		
	
		--Records to Insert (Provider has New DCPs)
		select s.EntityID, s.MedicalTermID, @EntityTypeID as EntityTypeID, s.MedicalTermRank, 
	        s.SourceCode, s.Searchable, s.LastUpdateDate, s.PatientCount, s.DecileRank, s.PatientCountIsFew, s.SourceSearch, 
			s.IsPreview, s.NationalRankingA, s.NationalRankingB
		into #tmp2
		from #swimlane s
		where not exists (select 1 from ODS1Stage.Base.EntityToMedicalTerm as pc with (nolock) where pc.EntityID=s.ProviderID and pc.MedicalTermID=s.MedicalTermID)
		order by EntityID, MedicalTermID

		insert into ODS1Stage.Base.EntityToMedicalTerm (EntityID, MedicalTermID, EntityTypeID, MedicalTermRank, 
	        SourceCode, Searchable, LastUpdateDate, PatientCount, DecileRank, PatientCountIsFew, SourceSearch, 
	        IsPreview, NationalRankingA, NationalRankingB)
		select EntityID, MedicalTermID, EntityTypeID, MedicalTermRank, 
	        SourceCode, Searchable, LastUpdateDate, PatientCount, DecileRank, PatientCountIsFew, SourceSearch, 
	        IsPreview, NationalRankingA, NationalRankingB
		from #tmp2
	end

    
-- etl.spumergeproviderprocedure

begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
	create table #swimlane (
		ProviderID uniqueidentifier, 
		ProviderCode varchar(50),
		EntityID uniqueidentifier, 
		MedicalTermID uniqueidentifier, 
		ProcedureCode varchar(50),
		DecileRank int, 
		IsPreview bit, 
		LastUpdateDate datetime, 
		MedicalTermRank int, 
		NationalRankingA int, 
		NationalRankingB int, 
		PatientCount int, 
		PatientCountIsFew bit, 
		Searchable int, 
		SourceCode varchar(50), 
		SourceSearch tinyint, 
		RowRank int,
		primary key (ProviderID, MedicalTermID)
		)

	insert into #swimlane (ProviderID, ProviderCode, EntityID, MedicalTermID, ProcedureCode, DecileRank, IsPreview, LastUpdateDate, MedicalTermRank, NationalRankingA, NationalRankingB,
			PatientCount, PatientCountIsFew, Searchable, SourceCode, SourceSearch, RowRank)
	select ProviderID, ProviderCode, EntityID, MedicalTermID, ProcedureCode, DecileRank, IsPreview, LastUpdateDate, MedicalTermRank, NationalRankingA, NationalRankingB,
			PatientCount, PatientCountIsFew, Searchable, SourceCode, SourceSearch, RowRank 
	from (
		select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
			x.ProviderCode, pID.ProviderID as EntityID, 
			y.MedicalTermID, y.ProcedureCode, y.DecileRank, y.IsPreview, isnull(y.LastUpdateDate, getutcdate()) as LastUpdateDate, y.MedicalTermRank, 
			y.NationalRankingA, y.NationalRankingB, --y.NationalRankingBCalc, 
			y.PatientCount, y.PatientCountIsFew, y.Searchable, isnull(y.SourceCode, 'Profisee') as SourceCode, isnull(y.SourceSearch, 0) as SourceSearch, 
			row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.ProcedureCode order by x.CREATE_DATE desc) as RowRank
		from
		(
			select w.*
			from
			(
				select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, p.Procedure_Payload as ProviderJSON
				from raw.ProviderProfileProcessingDeDup as d with (nolock)
				inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
				where isnull(p.HasProcedure,0) = 1 and p.Procedure_Payload is not null
			) as w
			where w.ProviderJSON is not null
		) as x
		left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
		cross apply 
		(
			select *, convert(uniqueidentifier, convert(varbinary(20), z.ProcedureCode)) as MedicalTermID
			from 
			(
				select *
				from openjson(x.ProviderJSON) with (DecileRank int '$.DecileRank',  
				IsPreview bit '$.IsPreview', LastUpdateDate datetime '$.LastUpdateDate', ProcedureCode varchar(50) '$.ProcedureCode', 
				MedicalTermRank int '$.MedicalTermRank', 
				NationalRankingA int '$.NationalRankingA', NationalRankingB int '$.NationalRankingB',
				PatientCount int '$.PatientCount', PatientCountIsFew bit '$.PatientCountIsFew', Searchable int '$.Searchable', 
				SourceCode varchar(25) '$.SourceCode', SourceSearch tinyint '$.SourceSearch')
			) as z
		) as y
		join ODS1Stage.Base.MedicalTerm as mt on mt.MedicalTermID = y.MedicalTermID
		join ODS1Stage.Base.MedicalTermType as mtt on mtt.MedicalTermTypeID = mt.MedicalTermTypeID 
			and mtt.MedicalTermTypeCode = 'Procedure'
		where y.ProcedureCode is not null
	) a
	where RowRank=1
	order by ProviderID, MedicalTermID

	if @OutputDestination = 'ODS1Stage' begin
		declare @EntityTypeID uniqueidentifier
	    select @EntityTypeID = EntityTypeID from ODS1Stage.Base.EntityType where EntityTypeCode = 'PROV'
		
		declare @MedicalTermTypeID uniqueidentifier = (select MedicalTermTypeID from ODS1Stage.Base.MedicalTermType where MedicalTermTypeCode='Procedure')
		
		--Records to Delete (where the provider loses all DCPs)
		delete pc
		--select count(*)
		from raw.ProviderProfileProcessingDeDup as d with (nolock)
		inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID=d.rawProviderProfileID
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.PROVIDER_CODE
	    inner join ODS1Stage.Base.EntityToMedicalTerm pc with (nolock) on pc.EntityID = p2.ProviderID
	    inner join ODS1Stage.Base.MedicalTerm as mt with (nolock) on mt.MedicalTermID = pc.MedicalTermID and mt.MedicalTermTypeID = @MedicalTermTypeID
		where isnull(p.HasProcedure,0)=0
	
		--Records to Delete (where the provider loses some DCPs)
		delete pc
		--declare @MedicalTermTypeID uniqueidentifier = (select MedicalTermTypeID from ODS1Stage.Base.MedicalTermType where MedicalTermTypeCode='Procedure');select count(*)
		from raw.ProviderProfileProcessingDeDup as d with (nolock)
		inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID=d.rawProviderProfileID
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = d.ProviderCode
	    inner join ODS1Stage.Base.EntityToMedicalTerm pc with (nolock) on pc.EntityID = p2.ProviderID
	    inner join ODS1Stage.Base.MedicalTerm as mt with (nolock) on mt.MedicalTermID = pc.MedicalTermID and mt.MedicalTermTypeID = @MedicalTermTypeID
		where isnull(p.HasProcedure,0)=1
		and not exists (select 1 from #swimlane s where pc.EntityID=s.ProviderID and pc.MedicalTermID=s.MedicalTermID)
	
		--Records to Update (Provider already has DCPs)
		update dest
		set dest.PatientCountIsFew = src.PatientCountIsFew, dest.LastUpdateDate = src.LastUpdateDate, dest.IsPreview = src.IsPreview, 
				dest.NationalRankingA = src.NationalRankingA, dest.PatientCount = src.PatientCount, dest.SourceSearch = src.SourceSearch, 
				dest.NationalRankingB = src.NationalRankingB, /*dest.EntityToMedicalTermID = newid(),*/ dest.SourceCode = src.SourceCode, 
				/*dest.EntityTypeID = @EntityTypeID,*/ dest.MedicalTermRank = src.MedicalTermRank
		--select count(*)
		from #swimlane src
	    inner join ODS1Stage.Base.EntityToMedicalTerm dest on dest.EntityID = src.ProviderID and dest.MedicalTermID = src.MedicalTermID
		where (isnull(dest.PatientCountIsFew,0) <> isnull(src.PatientCountIsFew,0) or /*dest.LastUpdateDate <> src.LastUpdateDate or*/ isnull(dest.IsPreview,0) <> isnull(src.IsPreview,0) or 
				isnull(dest.NationalRankingA,0) <> isnull(src.NationalRankingA,0) or isnull(dest.PatientCount,0) <> isnull(src.PatientCount,0) or isnull(dest.SourceSearch,0) <> isnull(src.SourceSearch,0) or 
				isnull(dest.NationalRankingB,0) <> isnull(src.NationalRankingB,0) or /*dest.SourceCode <> src.SourceCode or*/ isnull(dest.MedicalTermRank,0) <> isnull(src.MedicalTermRank,0))
	
		--Records to Insert (Provider has New DCPs)
        --declare @EntityTypeID uniqueidentifier; select @EntityTypeID = EntityTypeID from ODS1Stage.Base.EntityType where EntityTypeCode = 'PROV'
		select s.EntityID, s.MedicalTermID, @EntityTypeID as EntityTypeID, s.MedicalTermRank, 
	        s.SourceCode, s.Searchable, s.LastUpdateDate, s.PatientCount, s.DecileRank, s.PatientCountIsFew, s.SourceSearch, 
			s.IsPreview, s.NationalRankingA, s.NationalRankingB
		into #tmp2
		from #swimlane s
		where not exists (select 1 from ODS1Stage.Base.EntityToMedicalTerm as pc with (nolock) where pc.EntityID=s.ProviderID and pc.MedicalTermID=s.MedicalTermID)
		order by EntityID, MedicalTermID
	
		insert into ODS1Stage.Base.EntityToMedicalTerm (EntityID, MedicalTermID, EntityTypeID, MedicalTermRank, 
	        SourceCode, Searchable, LastUpdateDate, PatientCount, DecileRank, PatientCountIsFew, SourceSearch, 
	        IsPreview, NationalRankingA, NationalRankingB)
		select distinct S.EntityID, S.MedicalTermID, S.EntityTypeID, S.MedicalTermRank, 
	        S.SourceCode, S.Searchable, S.LastUpdateDate, S.PatientCount, S.DecileRank, S.PatientCountIsFew, S.SourceSearch, 
	        S.IsPreview, S.NationalRankingA, S.NationalRankingB
		from #tmp2 S
		left join ODS1Stage.Base.EntityToMedicalTerm T on T.EntityID = S.EntityID and T.EntityTypeID = S.EntityTypeID and T.MedicalTermID = S.MedicalTermID
		where	T.EntityToMedicalTermID is null
	end
