-- etl.spumergeprovidercustomerproductdisplaypartner
begin

	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct p.ProviderID, x.ReltioEntityID, x.ProviderCode,
		left(y.CustomerProductCode,charindex('-',y.CustomerProductCode)-1) as ClientCode,
		substring(y.CustomerProductCode,(charindex('-',y.CustomerProductCode)+1),len(y.CustomerProductCode)) as ProductCode,
		y.CustomerProductCode as ClientToProductCode, cp.ClientToProductID,	--y.LastUpdateDate,
		x.CREATE_DATE, z.DisplayPartnerCode, sp.SyndicationPartnerID, z.LastUpdateDate,
		dense_rank() over(partition by p.ProviderID, y.CustomerProductCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.CustomerProduct') as ProviderJSON
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.ProviderJSON is not null
    ) as x
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (
			CustomerProductCode varchar(50) '$.CustomerProductCode', 
            --LastUpdateDate datetime2 '$.LastUpdateDate',
			DisplayPartnerJSON nvarchar(max) '$.DisplayPartner' as json
			)
    ) as y
	cross apply 
	(
		select *
		from openjson(y.DisplayPartnerJSON) with (
		DisplayPartnerCode varchar(10) '$.DisplayPartnerCode', 
		LastUpdateDate datetime2 '$.LastUpdateDate'
		)	
	) as z
	inner join ODS1Stage.Base.Provider p on p.ProviderCode = x.ProviderCode
    inner join ODS1Stage.Base.ClientToProduct as cp on cp.ClientToProductCode = y.CustomerProductCode
	inner join ODS1Stage.Base.Product as prod on prod.ProductID = cp.ProductID
	inner join ODS1Stage.Base.SyndicationPartner as sp on sp.SyndicationPartnerCode = z.DisplayPartnerCode
    where y.CustomerProductCode is not null and z.DisplayPartnerCode is not null and prod.ProductCode in ('PDCWRITEMD', 'PDCWMDLITE')

    create table #provider (ProviderID uniqueidentifier primary key)
    insert into #provider(ProviderID)
    select T.ProviderID
    from raw.ProviderProfileProcessingDeDup as d with (nolock)
    inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
    inner join ODS1Stage.Base.Provider t on t.ProviderCode = p.PROVIDER_CODE
	order by T.ProviderID

    delete pc
	--select pc.*
    from #provider as p
    inner join ODS1Stage.Base.ProviderToClientProductToDisplayPartner as pc on pc.ProviderID = p.ProviderID
	
	if object_id('tempdb..#Insert') is not null drop table #Insert
	select distinct s.ProviderID, s.ClientToProductID, s.SyndicationPartnerId, 'Reltio' as SourceCode, isnull(s.LastUpdateDate, getutcdate()) as LastUpdateDate
	into #Insert
	from #swimlane as s
	inner join ODS1Stage.Base.Provider as p with (nolock) on p.ProviderID = s.ProviderID
	inner join ODS1Stage.Base.ClientToProduct as cp with (nolock) on cp.ClientToProductID = s.ClientToProductID
	inner join ODS1Stage.Base.SyndicationPartner as sp with (nolock) on sp.SyndicationPartnerId = s.SyndicationPartnerId
	where s.RowRank = 1 
		and (s.ClientToProductID is not null and s.ReltioEntityID is not null)
	
	insert into ODS1Stage.Base.ProviderToClientProductToDisplayPartner (ProviderID, ClientToProductID, SyndicationPartnerId, SourceCode, LastUpdateDate)
	select distinct s.ProviderID, s.ClientToProductID, s.SyndicationPartnerId, s.SourceCode, s.LastUpdateDate
	--select *
	from #Insert as s