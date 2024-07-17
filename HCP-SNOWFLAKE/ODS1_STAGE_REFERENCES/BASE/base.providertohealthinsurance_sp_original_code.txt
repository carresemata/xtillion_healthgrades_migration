-- etl.spumergeproviderhealthinsurance
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
	create table #swimlane (
		ProviderID uniqueidentifier, 
		ProviderCode varchar(50),
		InsuranceProductCodeID uniqueidentifier, 
		InsuranceProductCode varchar(50), 
		DoSuppress bit, 
		LastUpdateDate datetime, 
		SourceCode varchar(25), 
		RowRank int,
		primary key (ProviderID, InsuranceProductCodeID)
	)

	-- 00:02:26 / 24,902,739 records
	insert into #swimlane (ProviderID, ProviderCode, InsuranceProductCodeID, InsuranceProductCode, DoSuppress, LastUpdateDate, SourceCode, RowRank)
    select ProviderID, ProviderCode, InsuranceProductCodeID, InsuranceProductCode, DoSuppress, LastUpdateDate, SourceCode, RowRank
    from 
    (
        select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
            x.ProviderCode,
            convert(uniqueidentifier, convert(varbinary(20), y.InsuranceProductCode)) as InsuranceProductCodeID, y.InsuranceProductCode,
            y.DoSuppress, y.LastUpdateDate, y.SourceCode, 
            row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.InsuranceProductCode order by x.CREATE_DATE desc) as RowRank 
        from
        (
            select w.* 
            from
            (
                select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                    p.Insurance_payload as ProviderJSON
                from raw.ProviderProfileProcessingDeDup as d with (nolock)
                inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
                where isnull(p.HasInsurance,0) = 1 and p.Insurance_payload is not null
            ) as w
            where w.ProviderJSON is not null
        ) as x
        cross apply 
        (
            select *
            from openjson(x.ProviderJSON) with (DoSuppress bit '$.DoSuppress', 
            InsuranceProductCode varchar(50) '$.InsuranceProductCode', 
            LastUpdateDate datetime '$.LastUpdateDate', 
            SourceCode varchar(25) '$.SourceCode')
        ) as y
        left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
        join ODS1Stage.base.HealthInsurancePlanToPlanType as h on convert(uniqueidentifier, convert(varbinary(20), y.InsuranceProductCode))=h.HealthInsurancePlanToPlanTypeID 
        where y.InsuranceProductCode is not null
    ) as z
    where z.RowRank = 1
    
    if @OutputDestination = 'ODS1Stage' begin
		--Records to Delete - All Providers in the current load who have Insurance
		delete pc
        --select count(*)
		from raw.ProviderProfileProcessing as p with (nolock) 
        inner join ODS1Stage.Base.Provider as p2 with (nolock) on p2.ProviderCode = p.PROVIDER_CODE
	    inner join ODS1Stage.Base.ProviderToHealthInsurance as pc on pc.ProviderID = p2.ProviderID	

	    --Records to Insert (Provider has Insurance)
		insert into ODS1Stage.Base.ProviderToHealthInsurance (ProviderToHealthInsuranceID, ProviderID, HealthInsurancePlanToPlanTypeID, SourceCode, LastUpdateDate)
		select 	newid()
				,ProviderID
				,InsuranceProductCodeID as HealthInsurancePlanToPlanTypeID
				,isnull(SourceCode, 'Profisee')
				,isnull(LastUpdateDate, getutcdate())
		from #swimlane s
		where s.RowRank=1
	end