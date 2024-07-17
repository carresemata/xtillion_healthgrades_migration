-- etl.spuMergeProviderOASCustomerProduct

begin

	--OASCustomerProduct for provider URL
	if object_id('tempdb..#swimlaneURL') is not null drop table #swimlaneURL
	select distinct pb.ProviderID, x.ProviderCode,
		left(y.OASCustomerProductCode,charindex('-',y.OASCustomerProductCode)-1) as PartnerCode,
		y.OASCustomerProductCode,
		coalesce(y.OASPartnerPrimaryEntityID,pb.NPI) as OASPartnerPrimaryEntityID, y.OASURL,
		z.ExternalOASPartnerCode,
		row_number() over(partition by x.ProviderCode, y.OASCustomerProductCode order by x.CREATE_DATE desc) as RowRank
	into #swimlaneURL
	from
	(
		select w.* 
		from
		(
            select p.CREATE_DATE, p.PROVIDER_CODE as ProviderCode,
				json_query(p.PAYLOAD, '$.EntityJSONString.OASCustomerProduct') as ProviderJSON
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
			where p.PAYLOAD is not null
		) as w
		where w.ProviderJSON is not null
	) as x
	cross apply 
	(
		select *
		from openjson(x.ProviderJSON) 
		with (
				OASCustomerProductCode varchar(50) '$.CustomerToProductCode', 
				OASPartnerPrimaryEntityID varchar(50) '$.OASPartnerPrimaryEntityID',
				OASURL varchar(1000) '$.OASURL',
				LastUpdateDate datetime '$.LastUpdateDate',
				ExternalOASPartnerJSON nvarchar(max) '$.ExternalOASPartner' as json
			)
	) as y
	outer apply
	(
		select *
		from openjson(y.ExternalOASPartnerJSON) with (
		ExternalOASPartnerCode varchar(50) '$.ExternalOASPartnerCode',
		LastUpdateDate datetime2 '$.LastUpdateDate'
		)
	) as z
	inner join ODS1Stage.Base.Provider pb on pb.ProviderCode = x.ProviderCode
	where y.OASCustomerProductCode is not null --and y.OASURL is not null -- EGS 11/6/19 removed requirement that OASURL is not null, as some URLs are constructed in a Mid process

	--OASCustomerProduct for provider-office API components
	if object_id('tempdb..#swimlaneAPI') is not null drop table #swimlaneAPI
	select x.ProviderCode, pb.ProviderID, y.OfficeCode, ob.OfficeID,
		left(zz.OASCustomerProductCode,charindex('-',zz.OASCustomerProductCode)-1) as PartnerCode,
		zz.OASCustomerProductCode, coalesce(zz.OASPartnerPrimaryEntityID,pb.NPI) as OASPartnerPrimaryEntityID, zz.OASPartnerSecondaryEntityID, zz.OASPartnerTertiaryEntityID,
		row_number() over(partition by x.ProviderCode, y.OfficeCode order by x.CREATE_DATE desc, isnull(zz.OASCustomerProductCode,'') desc) as RowRank
	into #swimlaneAPI
	from
	(
		select w.* 
		from
		(
			select p.CREATE_DATE, p.PROVIDER_CODE as ProviderCode,
				json_query(p.PAYLOAD, '$.EntityJSONString.Office') as ProviderOfficeJSON
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
			where p.PAYLOAD is not null
        ) as w
		where w.ProviderOfficeJSON is not null
	) as x
	cross apply --All provider-offices are needed for a join back to #swimlaneURL for insert into Base.PartnerToEntity for OASURL
	(
		select *
		from openjson(x.ProviderOfficeJSON) 
			with (
				LastUpdateDate datetime '$.LastUpdateDate', 
				OfficeCode varchar(50) '$.OfficeCode', 
				SourceCode varchar(25) '$.SourceCode',
				OASCustomerProduct nvarchar(max) '$.OASCustomerProduct' as json
			)
	) as y
    outer apply 
    (
        select *
        from openjson(y.OASCustomerProduct) with (
				OASCustomerProductCode varchar(50) '$.CustomerToProductCode',
				OASPartnerPrimaryEntityID varchar(50) '$.OASPartnerPrimaryEntityID',
				OASPartnerSecondaryEntityID varchar(50) '$.OASPartnerSecondaryEntityID',
				OASPartnerTertiaryEntityID varchar(50) '$.OASPartnerTertiaryEntityID'
				)
    ) as zz
	inner join ODS1Stage.Base.Provider as pb on pb.ProviderCode = x.ProviderCode
	inner join ODS1Stage.Base.Office as ob on ob.OfficeCode = y.OfficeCode
	where zz.OASCustomerProductCode is not null
	
	declare @ProviderEntityTypeID uniqueidentifier, @OfficeEntityTypeID uniqueidentifier, @PracticeEntityTypeID uniqueidentifier
	select @ProviderEntityTypeID = et.EntityTypeID from ODS1Stage.Base.EntityType as et where et.EntityTypeCode = 'PROV'
	select @OfficeEntityTypeID = et.EntityTypeID from ODS1Stage.Base.EntityType as et where et.EntityTypeCode = 'OFFICE'
	select @PracticeEntityTypeID = et.EntityTypeID from ODS1Stage.Base.EntityType as et where et.EntityTypeCode = 'PRAC'
	
	if object_id('tempdb..#swimlaneURL2') is not null drop table #swimlaneURL2
	select s.ProviderCode, s.RowRank, s.OASCustomerProductCode, s.OASPartnerPrimaryEntityID, s.PartnerCode, pp.PartnerID, p.ProviderID as PrimaryEntityID, 
        @ProviderEntityTypeID as PrimaryEntityTypeID, s.OASPartnerPrimaryEntityID as PartnerPrimaryEntityID, s2.OfficeID as SecondaryEntityID, 
        @OfficeEntityTypeID as SecondaryEntityTypeID, s2.OfficeID as PartnerSecondaryEntityID, s.OASURL, getutcdate() as LastUpdateDate,
		eop.ExternalOASPartnerID
    into #swimlaneURL2
	from #swimlaneURL as s
	inner join ODS1Stage.Base.Provider as p on s.ProviderCode=p.ProviderCode
	inner join ODS1Stage.Base.ProviderToOffice as s2 on s2.ProviderID = p.ProviderID  --this join gets all offices for the provider
	inner join ODS1Stage.Base.Partner pp on s.PartnerCode = pp.PartnerCode
	left join ODS1Stage.Base.ExternalOASPartner as eop on eop.ExternalOASPartnerCode = s.ExternalOASPartnerCode
	where s.RowRank = 1 and s.OASPartnerPrimaryEntityID is not null

	if object_id('tempdb..#swimlaneAPI2') is not null drop table #swimlaneAPI2
	select s.ProviderCode, s.RowRank, s.OASCustomerProductCode, s.OASPartnerPrimaryEntityID, s.PartnerCode, pp.PartnerID, p.ProviderID as PrimaryEntityID, 
        @ProviderEntityTypeID as PrimaryEntityTypeID, s.OASPartnerPrimaryEntityID as PartnerPrimaryEntityID, 
		s.OfficeID as SecondaryEntityID, @OfficeEntityTypeID as SecondaryEntityTypeID, coalesce(s.OASPartnerSecondaryEntityID, cast(s.OfficeID as varchar(100))) as PartnerSecondaryEntityID,
		case when s.OASPartnerTertiaryEntityID is not null then o.PracticeID end as TertiaryEntityID, 
		case when s.OASPartnerTertiaryEntityID is not null then @PracticeEntityTypeID end as TertiaryEntityTypeID, 
		s.OASPartnerTertiaryEntityID as PartnerTertiaryEntityID, getutcdate() as LastUpdateDate
    into #swimlaneAPI2
	from #swimlaneAPI as s
	inner join ODS1Stage.Base.Provider p on s.ProviderCode=p.ProviderCode
	inner join ODS1Stage.Base.Partner pp on s.PartnerCode = pp.PartnerCode
	inner join ODS1Stage.Base.Office as o with (nolock) on o.OfficeID = s.OfficeID
	where s.RowRank = 1 and s.OASPartnerPrimaryEntityID is not null

	if @OutputDestination = 'ODS1Stage' begin
		--Delete Records who don't have any CP
		delete a
		from #swimlaneAPI a
		where not exists (select 1 from #swimlaneAPI as z where OASCustomerProductCode is not null and a.ProviderCode = z.ProviderCode)
	
		--Delete all PartnerToEntity for all providers in the raw.ProviderProfileProcessing
		delete pc
		--select count(*)
        from raw.ProviderProfileProcessingDeDup as p with (nolock)
	    inner join ODS1Stage.Base.Provider p2 on p2.ProviderCode = p.ProviderCode
		inner join ODS1Stage.Base.PartnerToEntity as pc on pc.PrimaryEntityID = p2.ProviderID

		--select * from ODS1Stage.Base.PartnerToEntity
		insert into ODS1Stage.Base.PartnerToEntity (PartnerID, PrimaryEntityID, PrimaryEntityTypeID, PartnerPrimaryEntityID, SecondaryEntityID, SecondaryEntityTypeID, PartnerSecondaryEntityID, OASURL, LastUpdateDate, ExternalOASPartnerID)
        select PartnerID, PrimaryEntityID, PrimaryEntityTypeID, PartnerPrimaryEntityID, SecondaryEntityID, SecondaryEntityTypeID, PartnerSecondaryEntityID, OASURL, LastUpdateDate, ExternalOASPartnerID
        from #swimlaneURL2
	
		--Primary, secondary & tertiary are always provider, office, practice in order
		insert into ODS1Stage.Base.PartnerToEntity (PartnerID, PrimaryEntityID, PrimaryEntityTypeID, PartnerPrimaryEntityID, SecondaryEntityID, SecondaryEntityTypeID, PartnerSecondaryEntityID, TertiaryEntityID, TertiaryEntityTypeID, PartnerTertiaryEntityID, LastUpdateDate)
        select PartnerID, PrimaryEntityID, PrimaryEntityTypeID, PartnerPrimaryEntityID, SecondaryEntityID, SecondaryEntityTypeID, PartnerSecondaryEntityID, TertiaryEntityID, TertiaryEntityTypeID, PartnerTertiaryEntityID, LastUpdateDate
        from #swimlaneAPI2
	end


    -- mid.spuPartnerEntityRefresh

    	DELETE .Base.PartnerToEntity 
	WHERE	PrimaryEntityId IN (
				SELECT	DISTINCT PrimaryEntityId
				FROM	.Base.PartnerToEntity
				WHERE	OASURL IS NOT NULL 
			)
			AND OASURL IS NULL

