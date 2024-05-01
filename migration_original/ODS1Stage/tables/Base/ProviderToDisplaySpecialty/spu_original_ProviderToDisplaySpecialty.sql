-- 	base.spucalculateproviderdisplayspecialty

begin try drop table #ProviderBatch end try begin catch end catch
	create table #ProviderBatch (ProviderID uniqueidentifier)

	if @IsProviderDeltaProcessing = 0
	begin --full
		truncate table Base.ProviderToDisplaySpecialty

		insert into #ProviderBatch(ProviderID)
		select p.ProviderID
		from Base.Provider p
	end
	else
	begin --batch
		delete pcf 
		from Base.ProviderToDisplaySpecialty pcf
			join Snowflake.etl.ProviderDeltaProcessing p on p.ProviderID=pcf.ProviderID
				 
		insert into #ProviderBatch(ProviderID)
        select a.ProviderID
        from Snowflake.etl.ProviderDeltaProcessing as a
	end

	create clustered index idx_provData_clust on #ProviderBatch (ProviderId);

	--providers to consider based on specialty check
	select distinct c.DisplaySpecialtyRuleID, a.ProviderID 
	into #ProvDS
	from Base.ProviderToSpecialty a
		join #ProviderBatch b on b.ProviderID = a.ProviderID
		join Base.DisplaySpecialtyRule c on c.SpecialtyID = a.SpecialtyID
	where a.IsSearchableCalculated = 1 
		and not exists (
		select 1
		from Base.ProviderToSpecialty xps
			left join Base.DisplaySpecialtyRuleToSpecialty dsrs on dsrs.DisplaySpecialtyRuleID = c.DisplaySpecialtyRuleID 
				and dsrs.SpecialtyID = xps.SpecialtyID
		where xps.ProviderID = a.ProviderID
			and xps.IsSearchableCalculated = 1 
			and dsrs.SpecialtyID is null
	)

	create clustered index idx_ProvDS_clust on #ProvDS (ProviderID);

	--grab the certs for each provider
	select distinct a.ProviderID, c.DisplaySpecialtyRuleID
	into #ProvCerts
	from Base.ProviderToCertificationSpecialty a
		join #ProvDS b on b.ProviderID = a.ProviderID
		join Base.DisplaySpecialtyRuleToCertificationSpecialty c on c.DisplaySpecialtyRuleID = b.DisplaySpecialtyRuleID and c.CertificationSpecialtyID = a.CertificationSpecialtyID

	create clustered index idx_ProvCerts_clust on #ProvCerts (ProviderID);

	--grab the clinical focus for each provider
	select distinct a.ProviderID, c.DisplaySpecialtyRuleID
	into #ProvCFs
	from Base.ProviderToClinicalFocus a
		join #ProvDS b on b.ProviderID = a.ProviderID
		join Base.DisplaySpecialtyRuleToClinicalFocus c on c.DisplaySpecialtyRuleID = b.DisplaySpecialtyRuleID and c.ClinicalFocusID = a.ClinicalFocusID

	create clustered index idx_ProvCFs_clust on #ProvCFs (ProviderID);

	select distinct a.ProviderID, c.DisplaySpecialtyRuleID
	into #ProvPrimarySpec
	from Base.ProviderToSpecialty a
		join #ProvDS b on b.ProviderID = a.ProviderID
		join Base.DisplaySpecialtyRule c on c.DisplaySpecialtyRuleID = b.DisplaySpecialtyRuleID and c.SpecialtyID = a.SpecialtyID
	where a.SpecialtyRank = 1 and c.IsPrimaryRequired = 1

	create clustered index idx_ProvPrimarySpec_clust on #ProvPrimarySpec (ProviderID);

	insert into Base.ProviderToDisplaySpecialty (ProviderID, SpecialtyID)
	select distinct x.ProviderID, x.SpecialtyID
	from (
		select a.ProviderID, b.SpecialtyID, row_number() over (partition by a.ProviderID order by b.DisplaySpecialtyRuleRank, case when b.IsPrimaryRequired = 1 and e.ProviderID is not null then 1 else 2 end, b.DisplaySpecialtyRuleTieBreaker) as DupeRank
		from #ProvDS a
			join Base.DisplaySpecialtyRule b on b.DisplaySpecialtyRuleID = a.DisplaySpecialtyRuleID
			left join #ProvCerts c on c.ProviderID = a.ProviderID and c.DisplaySpecialtyRuleID = b.DisplaySpecialtyRuleID
			left join #ProvCFs d on d.ProviderID = a.ProviderID and d.DisplaySpecialtyRuleID = b.DisplaySpecialtyRuleID
			left join #ProvPrimarySpec e on e.ProviderID = a.ProviderID and e.DisplaySpecialtyRuleID = b.DisplaySpecialtyRuleID
		where (((((b.IsCertificationSpecialtyRequired = 1 and c.ProviderID is not null) or (b.IsCertificationSpecialtyRequired = 0))
			or ((b.IsClinicalFocuRequired = 1 and d.ProviderID is not null) or (b.IsClinicalFocuRequired = 0)))
			/*and ((b.IsPrimaryRequired = 1 and e.ProviderID is not null) or (b.IsPrimaryRequired = 0))*/) 
			and b.DisplaySpecialtyRuleCondition = 'AND')
			or (((((b.IsCertificationSpecialtyRequired = 1 and c.ProviderID is not null) or (b.IsCertificationSpecialtyRequired = 0))
			or ((b.IsClinicalFocuRequired = 1 and d.ProviderID is not null) or (b.IsClinicalFocuRequired = 0)))
			/*or ((b.IsPrimaryRequired = 1 and e.ProviderID is not null) or (b.IsPrimaryRequired = 0))*/) 
			and b.DisplaySpecialtyRuleCondition = 'OR')
	) x
	where x.DupeRank = 1