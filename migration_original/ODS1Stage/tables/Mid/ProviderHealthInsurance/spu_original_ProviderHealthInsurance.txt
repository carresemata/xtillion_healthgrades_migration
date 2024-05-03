-- Mid_spuProviderHealthInsuranceRefresh
if @IsProviderDeltaProcessing = 0 begin
            insert into #ProviderBatch (ProviderID) select a.ProviderID from Base.Provider as a order by a.ProviderID
          truncate table Mid.ProviderHealthInsurance;
		  end
        else begin
			insert into #ProviderBatch (ProviderID)
            select a.ProviderID
            from Snowflake.etl.ProviderDeltaProcessing as a
        end

--build a temp table with the same structure as the Mid.ProviderHealthInsurance
		begin try drop table #ProviderHealthInsuranceRefresh end try begin catch end catch
		select top 0 *
		into #ProviderHealthInsuranceRefresh
		from Mid.ProviderHealthInsurance;

		alter table #ProviderHealthInsuranceRefresh
		add ActionCode int default 0
		
	--populate the temp table with data from Base schemas
		insert into #ProviderHealthInsuranceRefresh 
			(
				ProviderToHealthInsuranceID,ProviderID,HealthInsurancePlanToPlanTypeID,ProductName,
				PlanName,PlanDisplayName,PayorName,PlanTypeDescription,PlanTypeDisplayDescription, Searchable, PayorCode,
				HealthInsurancePayorID,PayorProductCount
			)
		select a.ProviderToHealthInsuranceID, a.ProviderID, b.HealthInsurancePlanToPlanTypeID, b.ProductName, c.PlanName, c.PlanDisplayName, d.PayorName, 
			e.PlanTypeDescription, e.PlanTypeDisplayDescription, 1 as Searchable, d.PayorCode,
			d.HealthInsurancePayorID, 0 as PayorProductCount
		from #ProviderBatch as pb  --When not migrating a batch, this is all providers in Base.Provider. Otherwise it is just the providers in the batch
		inner join Base.ProviderToHealthInsurance a with (nolock) on a.ProviderID = pb.ProviderID
		inner join Base.HealthInsurancePlanToPlanType b with (nolock) on a.HealthInsurancePlanToPlanTypeID = b.HealthInsurancePlanToPlanTypeID 
		inner join Base.HealthInsurancePlan c with (nolock) on b.HealthInsurancePlanID = c.HealthInsurancePlanID
		inner join Base.HealthInsurancePayor d with (nolock) on c.HealthInsurancePayorID = d.HealthInsurancePayorID
		inner join Base.HealthInsurancePlanType e with (nolock) on b.HealthInsurancePlanTypeID = e.HealthInsurancePlanTypeID
		
		update phi
		set Searchable = 0
		--select *
		--select distinct PayorName
		from #ProviderHealthInsuranceRefresh phi
		where phi.PayorName in ('Name of Insurance Unknown','Accepts most insurance','Accepts most major Health Plans. Please contact our office for details.')
				
		create index temp on #ProviderHealthInsuranceRefresh (ProviderToHealthInsuranceID)

		update a
		set		a.HealthInsurancePayorID = b.HealthInsurancePayorID,
				a.HealthInsurancePlanToPlanTypeID = b.HealthInsurancePlanToPlanTypeID,
				a.PayorCode = b.PayorCode,
				a.PayorName = b.PayorName,
				a.PlanDisplayName = b.PlanDisplayName,
				a.PlanName = b.PlanName,
				a.PlanTypeDescription = b.PlanTypeDescription,
				a.PlanTypeDisplayDescription = b.PlanTypeDisplayDescription,
				a.ProductName = b.ProductName,
				a.ProviderID = b.ProviderID,
				a.Searchable = b.Searchable
		--select *
		from		Mid.ProviderHealthInsurance a with (nolock)
		join		#ProviderHealthInsuranceRefresh b on (a.ProviderToHealthInsuranceID = b.ProviderToHealthInsuranceID)
		WHERE		a.HealthInsurancePayorID != b.HealthInsurancePayorID
					OR a.HealthInsurancePlanToPlanTypeID != b.HealthInsurancePlanToPlanTypeID
					OR a.PayorCode != b.PayorCode
					OR a.PayorName != b.PayorName
					OR a.PlanDisplayName != b.PlanDisplayName
					OR a.PlanName != b.PlanName
					OR a.PlanTypeDescription != b.PlanTypeDescription
					OR a.PlanTypeDisplayDescription != b.PlanTypeDisplayDescription
					OR a.ProductName != b.ProductName
					OR a.ProviderID != b.ProviderID
					OR a.Searchable != b.Searchable
					
	
		insert into Mid.ProviderHealthInsurance (HealthInsurancePayorID,HealthInsurancePlanToPlanTypeID,PayorCode,PayorName,PayorProductCount,PlanDisplayName,PlanName,PlanTypeDescription,PlanTypeDisplayDescription,ProductName,ProviderID,ProviderToHealthInsuranceID,Searchable)
		select		a.HealthInsurancePayorID,a.HealthInsurancePlanToPlanTypeID,a.PayorCode,a.PayorName,a.PayorProductCount,a.PlanDisplayName,a.PlanName,a.PlanTypeDescription,a.PlanTypeDisplayDescription,a.ProductName,a.ProviderID,a.ProviderToHealthInsuranceID,a.Searchable 
		from		#ProviderHealthInsuranceRefresh a
		left join	Mid.ProviderHealthInsurance b 
					on (a.ProviderToHealthInsuranceID = b.ProviderToHealthInsuranceID)
		where		b.ProviderToHealthInsuranceID is null


		--ActionCode = N (Deletes)
			delete a
			--select *
			from Mid.ProviderHealthInsurance a with (nolock)
            inner join #ProviderBatch as pb on pb.ProviderID = a.ProviderID	
			left join #ProviderHealthInsuranceRefresh b on (a.ProviderToHealthInsuranceID = b.ProviderToHealthInsuranceID)
			where b.ProviderToHealthInsuranceID is null;
			
		--Update Product(Plan) count.
			Update mid.ProviderHealthInsurance
			Set PayorProductCount = t.PayorProductCount
			From(
				select d.PayorCode,COUNT(*) as PayorProductCount
				From Base.HealthInsurancePlanToPlanType b 
				inner join Base.HealthInsurancePlan c with (nolock) on b.HealthInsurancePlanID = c.HealthInsurancePlanID
				Right join Base.HealthInsurancePayor d with (nolock) on c.HealthInsurancePayorID = d.HealthInsurancePayorID
					and d.PayorName <> b.ProductName
				group by d.PayorCode
				) t where t.PayorCode = mid.ProviderHealthInsurance.PayorCode
					and isnull(t.PayorProductCount,-99) <> isnull(mid.ProviderHealthInsurance.PayorProductCount,-99);	
	