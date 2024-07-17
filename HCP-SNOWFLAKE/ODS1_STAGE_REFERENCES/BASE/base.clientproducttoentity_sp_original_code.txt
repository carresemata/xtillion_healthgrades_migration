
--------------------------------–------spuMergeCustomerProduct--------------------------------–------

if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct x.ReltioEntityID, replace(x.CustomerProductCode, ' ', '') as ClientToProductCode, x.ClientToProductID, x.ClientCode, c.ClientID,
		ltrim(rtrim(substring(x.CustomerProductCode,(charindex('-',x.CustomerProductCode)+1),len(x.CustomerProductCode)))) as ProductCode,
        convert(uniqueidentifier, convert(varbinary,  ltrim(rtrim(substring(x.CustomerProductCode,(charindex('-',x.CustomerProductCode)+1),len(x.CustomerProductCode)))))) as ProductID, 
        dense_rank() over(partition by x.CustomerProductCode order by x.ReltioEntityID, x.CREATE_DATE desc) as RowRank,
		y.*
    into #swimlane
    from
    (
       select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.CUSTOMER_PRODUCT_CODE as CustomerProductCode, p.ClientToProductID,
	   		ltrim(rtrim(left(p.CUSTOMER_PRODUCT_CODE,charindex('-',p.CUSTOMER_PRODUCT_CODE)-1))) as ClientCode,
	        json_query(p.PAYLOAD, '$.EntityJSONString')  as CustomerProductJSON
        from raw.CustomerProductProfileProcessingDeDup as d with (nolock)
        inner join raw.CustomerProductProfileProcessing as p with (nolock) on p.rawCustomerProductProfileID = d.rawCustomerProductProfileID
		--from (select * from Snowflake.raw.CustomerProductProfileComplete_20220723_200622_770 where customer_product_code = 'CHIFRAN-PDCHSP') p
    ) as x
	inner join ODS1Stage.Base.Client as c on c.ClientCode = x.ClientCode
    cross apply 
    (
        select z.CustomerName, z.QueueSize, z.LastUpdateDate, z.SourceCode, z.ActiveFlag, z.OASURLPath, z.OASPartnerTypeCode, 
            case when nullif(z.FeatureFCBFN,'') is null then null when z.FeatureFCBFN in ('true', 'FVYES') then 'FVYES' else 'FVNO' end as FeatureFCBFN,
            REPLACE(REPLACE(z.FeatureFCBRL,'Customer','FVCLT'),'Facility','FVFAC') as FeatureFCBRL, 
            case when nullif(z.FeatureFCCCP_FVCLT,'') is null then null when z.FeatureFCCCP_FVCLT in ('true', 'FVYES', 'FVCLT') then 'FVCLT' else null end as FeatureFCCCP_FVCLT,
            case when nullif(z.FeatureFCCCP_FVFAC,'') is null then null when z.FeatureFCCCP_FVFAC in ('true', 'FVYES', 'FVFAC') then 'FVFAC' else null end as FeatureFCCCP_FVFAC,
            case when nullif(z.FeatureFCCCP_FVOFFICE,'') is null then null when z.FeatureFCCCP_FVOFFICE in ('true', 'FVYES', 'FVOFFICE') then 'FVOFFICE' else null end as FeatureFCCCP_FVOFFICE,
            z.FeatureFCCLLOGO, z.FeatureFCCWALL, z.FeatureFCCLURL, z.FeatureFCDISLOC, 
            case when nullif(z.FeatureFCDOA,'') is null then null when z.FeatureFCDOA in ('true', 'FVYES') then 'FVYES' else 'FVNO' end as FeatureFCDOA,
            case when nullif(z.FeatureFCDOS_FVFAX,'') is null then null when z.FeatureFCDOS_FVFAX in ('true', 'FVYES', 'FVFAX') then 'FVFAX' else null end as FeatureFCDOS_FVFAX,
            case when nullif(z.FeatureFCDOS_FVMMPEML,'') is null then null when z.FeatureFCDOS_FVMMPEML in ('true', 'FVYES', 'FVMMPEML') then 'FVMMPEML' else null end as FeatureFCDOS_FVMMPEML,
            z.FeatureFCDTP, 
            case when nullif(z.FeatureFCEOARD,'') is null then null when z.FeatureFCEOARD in ('true', 'FVYES','FVAQSTD') then 'FVAQSTD' else null end as FeatureFCEOARD,
            case when nullif(z.FeatureFCEPR,'') is null then null when z.FeatureFCEPR in ('true', 'FVYES') then 'FVYES' else 'FVNO' end as FeatureFCEPR,
			case when nullif(z.FeatureFCOOACP,'') is null then null when z.FeatureFCOOACP in ('true', 'FVYES') then 'FVYES' else 'FVNO' end as FeatureFCOOACP,
            z.FeatureFCLOT, z.FeatureFCMAR, 
            case when nullif(z.FeatureFCMWC,'') is null then null when z.FeatureFCMWC in ('true', 'FVYES') then 'FVYES' else 'FVNO' end as FeatureFCMWC,
            case when nullif(z.FeatureFCNPA,'') is null then null when z.FeatureFCNPA in ('true', 'FVYES') then 'FVYES' else 'FVNO' end as FeatureFCNPA,
            case when nullif(z.FeatureFCOAS,'') is null then null when z.FeatureFCOAS in ('true', 'FVYES') then 'FVYES' else 'FVNO' end as FeatureFCOAS,
            z.FeatureFCOASURL, z.FeatureFCOASVT, z.FeatureFCOBT, 
            case when nullif(z.FeatureFCODC_FVDFC,'') is null then null when z.FeatureFCODC_FVDFC in ('true', 'FVYES', 'FVDFC') then 'FVDFC' else null end as FeatureFCODC_FVDFC,
            case when nullif(z.FeatureFCODC_FVDPR,'') is null then null when z.FeatureFCODC_FVDPR in ('true', 'FVYES', 'FVDPR') then 'FVDPR' else null end as FeatureFCODC_FVDPR,
            case when nullif(z.FeatureFCODC_FVMT,'') is null then null when z.FeatureFCODC_FVMT in ('true', 'FVYES', 'FVMT') then 'FVMT' else null end as FeatureFCODC_FVMT,
            case when nullif(z.FeatureFCODC_FVPSR,'') is null then null when z.FeatureFCODC_FVPSR in ('true', 'FVYES', 'FVPSR') then 'FVPSR' else null end as FeatureFCODC_FVPSR,
            case when nullif(z.FeatureFCPNI,'') is null then null when z.FeatureFCPNI in ('true', 'FVYES') then 'FVYES' else 'FVNO' end as FeatureFCPNI,
            case when nullif(z.FeatureFCPQM,'') is null then null when z.FeatureFCPQM in ('true', 'FVYES') then 'FVYES' else 'FVNO' end as FeatureFCPQM,
            case when nullif(z.FeatureFCREL_FVCPOFFICE,'') is null then null when z.FeatureFCREL_FVCPOFFICE in ('true', 'FVYES', 'FVCPOFFICE') then 'FVCPOFFICE' else null end as FeatureFCREL_FVCPOFFICE,
            case when nullif(z.FeatureFCREL_FVCPTOCC,'') is null then null when z.FeatureFCREL_FVCPTOCC in ('true', 'FVYES', 'FVCPTOCC') then 'FVCPTOCC' else null end as FeatureFCREL_FVCPTOCC,
            case when nullif(z.FeatureFCREL_FVCPTOFAC,'') is null then null when z.FeatureFCREL_FVCPTOFAC in ('true', 'FVYES', 'FVCPTOFAC') then 'FVCPTOFAC' else null end as FeatureFCREL_FVCPTOFAC,
            case when nullif(z.FeatureFCREL_FVCPTOPRAC,'') is null then null when z.FeatureFCREL_FVCPTOPRAC in ('true', 'FVYES', 'FVCPTOPRAC') then 'FVCPTOPRAC' else null end as FeatureFCREL_FVCPTOPRAC,
            case when nullif(z.FeatureFCREL_FVCPTOPROV,'') is null then null when z.FeatureFCREL_FVCPTOPROV in ('true', 'FVYES', 'FVCPTOPROV') then 'FVCPTOPROV' else null end as FeatureFCREL_FVCPTOPROV,
            case when nullif(z.FeatureFCREL_FVPRACOFF,'') is null then null when z.FeatureFCREL_FVPRACOFF in ('true', 'FVYES', 'FVPRACOFF') then 'FVPRACOFF' else null end as FeatureFCREL_FVPRACOFF,
            case when nullif(z.FeatureFCREL_FVPROVFAC,'') is null then null when z.FeatureFCREL_FVPROVFAC in ('true', 'FVYES', 'FVPROVFAC') then 'FVPROVFAC' else null end as FeatureFCREL_FVPROVFAC,
            case when nullif(z.FeatureFCREL_FVPROVOFF,'') is null then null when z.FeatureFCREL_FVPROVOFF in ('true', 'FVYES', 'FVPROVOFF') then 'FVPROVOFF' else null end as FeatureFCREL_FVPROVOFF,
            z.FeatureFCSPC, z.DisplayPartnerJSON,
			case when nullif(z.FeatureFCOOPSR,'') is null then null when z.FeatureFCOOPSR in ('true', 'FVYES') then 'FVYES' else 'FVNO' end as FeatureFCOOPSR,
			case when nullif(z.FeatureFCOOMT,'') is null then null when z.FeatureFCOOMT in ('true', 'FVYES') then 'FVYES' else 'FVNO' end as FeatureFCOOMT
        from
        (
            select *
            from openjson(x.CustomerProductJSON) with ( 
			    CustomerName varchar(50) '$.CustomerName',
			    QueueSize int '$.QueueSize',
			    LastUpdateDate datetime '$.LastUpdateDate',
			    SourceCode varchar(25) '$.SourceCode', 
			    ActiveFlag bit '$.ActiveFlag',
			    OASURLPath varchar(50) '$.OASURLPath',
			    OASPartnerTypeCode varchar(50) '$.OASPartnerTypeCode',
			    FeatureFCBFN varchar(50) '$.FeatureFCBFN',
			    FeatureFCBRL varchar(50) '$.FeatureFCBRL',
			    FeatureFCCCP_FVCLT varchar(50) '$.FeatureFCCCP_FVCLT',
			    FeatureFCCCP_FVFAC varchar(50) '$.FeatureFCCCP_FVFAC',
			    FeatureFCCCP_FVOFFICE varchar(50) '$.FeatureFCCCP_FVOFFICE',
			    FeatureFCCLLOGO varchar(50) '$.FeatureFCCLLOGO',
				FeatureFCCWALL varchar(50) '$.FeatureFCCWALL',
			    FeatureFCCLURL varchar(50) '$.FeatureFCCLURL',
			    FeatureFCDISLOC varchar(50) '$.FeatureFCDISLOC',
			    FeatureFCDOA varchar(50) '$.FeatureFCDOA',
			    FeatureFCDOS_FVFAX varchar(50) '$.FeatureFCDOS_FVFAX',
			    FeatureFCDOS_FVMMPEML varchar(50) '$.FeatureFCDOS_FVMMPEML',
			    FeatureFCDTP varchar(50) '$.FeatureFCDTP',
			    FeatureFCEOARD varchar(50) '$.FeatureFCEOARD',
			    FeatureFCEPR varchar(50) '$.FeatureFCEPR',
				FeatureFCOOACP varchar(50) '$.FeatureFCOOACP',
			    FeatureFCLOT varchar(50) '$.FeatureFCLOT',
			    FeatureFCMAR varchar(50) '$.FeatureFCMAR',
			    FeatureFCMWC varchar(50) '$.FeatureFCMWC',
			    FeatureFCNPA varchar(50) '$.FeatureFCNPA',
			    FeatureFCOAS varchar(50) '$.FeatureFCOAS',
			    FeatureFCOASURL varchar(50) '$.FeatureFCOASURL',
			    FeatureFCOASVT varchar(50) '$.FeatureFCOASVT',
			    FeatureFCOBT varchar(50) '$.FeatureFCOBT',
			    FeatureFCODC_FVDFC varchar(50) '$.FeatureFCODC_FVDFC',
			    FeatureFCODC_FVDPR varchar(50) '$.FeatureFCODC_FVDPR',
			    FeatureFCODC_FVMT varchar(50) '$.FeatureFCODC_FVMT',
			    FeatureFCODC_FVPSR varchar(50) '$.FeatureFCODC_FVPSR',
			    FeatureFCPNI varchar(50) '$.FeatureFCPNI',
			    FeatureFCPQM varchar(50) '$.FeatureFCPQM',
			    FeatureFCREL_FVCPOFFICE varchar(50) '$.FeatureFCREL_FVCPOFFICE',
			    FeatureFCREL_FVCPTOCC varchar(50) '$.FeatureFCREL_FVCPTOCC',
			    FeatureFCREL_FVCPTOFAC varchar(50) '$.FeatureFCREL_FVCPTOFAC',
			    FeatureFCREL_FVCPTOPRAC varchar(50) '$.FeatureFCREL_FVCPTOPRAC',
			    FeatureFCREL_FVCPTOPROV varchar(50) '$.FeatureFCREL_FVCPTOPROV',
			    FeatureFCREL_FVPRACOFF varchar(50) '$.FeatureFCREL_FVPRACOFF',
			    FeatureFCREL_FVPROVFAC varchar(50) '$.FeatureFCREL_FVPROVFAC',
			    FeatureFCREL_FVPROVOFF varchar(50) '$.FeatureFCREL_FVPROVOFF',
			    FeatureFCSPC varchar(50) '$.FeatureFCSPC',
				DisplayPartnerJSON nvarchar(max) '$.DisplayPartner' as json,
				FeatureFCOOPSR varchar(50) '$.FeatureFCOOPSR',
				FeatureFCOOMT varchar(50) '$.FeatureFCOOMT'
			    /*LastUpdateDate datetime '$.LastUpdateDate', SourceCode varchar(25) '$.SourceCode',
			    ActiveFlag bit '$.ActiveFlag', DoSuppress bit '$.DoSuppress',*/ )
        ) as z
    ) as y
	where x.CustomerProductCode is not null


insert into ODS1Stage.Base.ClientProductToEntity (ClientProductToEntityID, ClientToProductID, EntityTypeID, EntityID, LastUpdateDate)
select distinct 
    convert(uniqueidentifier, hashbytes('SHA1',  concat(ClientToProductCode,b.EntityTypeCode,ClientToProductCode) )) as ClientProductToEntityID,
    ClientToProductID, 
    b.EntityTypeID, 
    ClientToProductID as EntityID, 
    isnull(s.LastUpdateDate, getutcdate()) as LastUpdateDate
from #swimlane s
    join ODS1Stage.Base.EntityType b
    on b.EntityTypeCode='CLPROD'
where (s.ClientToProductID is not null and s.ClientID is not null and s.ProductID is not null)
    and not exists (select 1 
                    from ODS1Stage.Base.ClientProductToEntity as cpe2 
                    where cpe2.ClientProductToEntityID = convert(uniqueidentifier, hashbytes('SHA1',  concat(ClientToProductCode,b.EntityTypeCode,ClientToProductCode))))

--------------------------------–------spuMergeCustomerProduct--------------------------------–------

--------------------------------–------spuMergeFacilityCustomerProduct--------------------------------–------

if object_id('tempdb..#swimlane') is not null drop table #swimlane
		select distinct /*convert(uniqueidentifier, convert(varbinary(20), x.ReltioEntityID)) as FacilityID*/--Dont use until we actually master in Reltio, 
			f.FacilityID,
			x.FacilityCode,
			cp.ClientToProductID,
			y.CustomerProductCode as ClientToProductCode,
			x.ReltioEntityID,
			y.*,
			row_number() over(partition by x.FacilityID order by x.CREATE_DATE desc) as RowRank,
			'Reltio' as SourceCode,
			getutcdate() as LastUpdateDate
		into #swimlane
		from
		(
			select w.* 
			from
			(
				select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.Facility_Code as FacilityCode, p.FacilityID,
					json_query(p.PAYLOAD, '$.EntityJSONString.CustomerProduct') as FacilityJSON
				from raw.FacilityProfileProcessingDeDup as d with (nolock)
				inner join raw.FacilityProfileProcessing as p with (nolock) on p.rawFacilityProfileID = d.rawFacilityProfileID
				where p.PAYLOAD is not null
			) as w
			where w.FacilityJSON is not null
		) as x
		cross apply 
		(
			select *
			from openjson(x.FacilityJSON) with (
				CustomerProductCode varchar(50) '$.CustomerProductCode', 
				DisplayPartnerJSON nvarchar(max) '$.DisplayPartner' as json,
				FeatureFCCIURL varchar(max) '$.FeatureFCCIURL',
				FeatureFCCLURL varchar(max) '$.FeatureFCCLURL',
				FeatureFCFLOGO varchar(max) '$.FeatureFCFLOGO',
				FeatureFCFURL varchar(max) '$.FeatureFCFURL')
		) as y
		join ODS1Stage.Base.Facility f on x.FacilityCode=f.FacilityCode
		join ODS1Stage.Base.ClientToProduct as cp on cp.ClientToProductCode = y.CustomerProductCode
		where x.FacilityCode is not null 

		IF OBJECT_ID('tempdb..#ClientProductToEntity') IS NOT NULL DROP TABLE #ClientProductToEntity
		SELECT		DISTINCT 
            lCPE.ClientProductToEntityID,
            lCP.ClientToProductID, 
            dE.EntityTypeID, 
            dF.FacilityID as EntityID
		INTO		#ClientProductToEntity
		FROM		ODS1Stage.Base.ClientProductToEntity lCPE
		INNER JOIN	ODS1Stage.Base.EntityType dE
					ON dE.EntityTypeId = lCPE.EntityTypeID
		INNER JOIN	ODS1Stage.Base.ClientToProduct lCP
					ON lCP.ClientToProductID = lCPE.ClientToProductID
		INNER JOIN	ODS1Stage.Base.Client dC
					ON lCP.ClientID = dC.ClientID
		INNER JOIN	ODS1Stage.Base.Product dP
					ON dP.ProductId = lCP.ProductID
		INNER JOIN	ODS1Stage.Base.Facility dF
					ON dF.FacilityID = lCPE.EntityID
		INNER JOIN  raw.FacilityProfileProcessing p
					ON p.FACILITY_CODE = dF.FacilityCode
		LEFT JOIN	#swimlane S --has a new ClientProduct
					ON S.FacilityCode = dF.FacilityCode
					AND 
                    S.ClientToProductCode != ISNULL(lCP.ClientToProductCode,'00000000-0000-0000-0000-000000000000')
		WHERE 		s.RowRank = 1
			OR NOT EXISTS (SELECT 1 FROM #swimlane s where s.FacilityCode = p.FACILITY_CODE) --no longer has a CustomerProduct
		UNION
		SELECT		DISTINCT 
            convert(uniqueidentifier, HASHBYTES('SHA1', Concat(cp.ClientToProductCode,b.EntityTypeCode,s.FacilityCode))) as ClientProductToEntityID, 
            s.ClientToProductID, 
            b.EntityTypeID, 
            s.FacilityID as EntityID
		FROM		#swimlane s
		INNER JOIN	ODS1Stage.Base.EntityType b
					ON b.EntityTypeCode='FAC'
		LEFT JOIN	ODS1Stage.Base.ClientToProduct cp
					ON s.ClientToProductID=cp.ClientToProductID
		LEFT JOIN	ODS1Stage.Base.Facility o
					ON s.FacilityID=o.FacilityID
		LEFT JOIN	ODS1Stage.Base.ClientProductToEntity T
					ON T.ClientProductToEntityId = convert(uniqueidentifier, HASHBYTES('SHA1', Concat(cp.ClientToProductCode,b.EntityTypeCode,s.FacilityCode)))
		WHERE		s.RowRank = 1
					AND(
						s.ClientToProductID IS NULL 
						OR S.ClientToProductID != ISNULL(T.ClientToProductID,'00000000-0000-0000-0000-000000000000')
					)

		delete T
		from		ODS1Stage.Base.ClientProductToEntity as T 
		inner join	#ClientProductToEntity s
					ON S.ClientProductToEntityID = T.ClientProductToEntityID

		insert into ODS1Stage.Base.ClientProductToEntity (ClientProductToEntityID, ClientToProductID, EntityTypeID, EntityID, SourceCode, LastUpdateDate)
		select		distinct convert(uniqueidentifier, HASHBYTES('SHA1', Concat(cp.ClientToProductCode,b.EntityTypeCode,s.FacilityCode))) as ClientProductToEntityID, s.ClientToProductID, b.EntityTypeID, s.FacilityID as EntityID, s.SourceCode, s.LastUpdateDate
		FROM		#swimlane s
		INNER JOIN	ODS1Stage.Base.EntityType b
					ON b.EntityTypeCode='FAC'
		INNER JOIN	ODS1Stage.Base.ClientToProduct cp
					ON s.ClientToProductID=cp.ClientToProductID
		INNER JOIN	ODS1Stage.Base.Facility o
					ON s.FacilityID=o.FacilityID
		LEFT JOIN	ODS1Stage.Base.ClientProductToEntity T
					ON T.ClientProductToEntityId = convert(uniqueidentifier, HASHBYTES('SHA1', Concat(cp.ClientToProductCode,b.EntityTypeCode,s.FacilityCode)))
		WHERE		s.RowRank = 1
					AND (s.ClientToProductID is not null and s.FacilityID is not null)
					AND T.ClientProductToEntityId IS NULL
					AND S.CustomerProductCode IS NOT NULL

    --------------------------------–------spuMergeFacilityCustomerProduct--------------------------------–------
    --------------------------------–------spuMergeProviderCustomerProduct--------------------------------–------

    if object_id('tempdb..#swimlane') IS NOT NULL DROP TABLE #swimlane
    select distinct p.ProviderID, x.ReltioEntityID, x.ProviderCode,
		left(y.CustomerProductCode,charindex('-',y.CustomerProductCode)-1) as ClientCode,
		substring(y.CustomerProductCode,(charindex('-',y.CustomerProductCode)+1),len(y.CustomerProductCode)) as ProductCode,
		y.CustomerProductCode as ClientToProductCode,
        cp.ClientToProductID,
		y.LastUpdateDate,
		y.SourceCode,
		y.OptInOptOut,
		convert(bit, case when isnull(y.sIsEmployed,'false') in ('true','Y','Yes','1') then 1 else 0 end) as IsEmployed,
		y.FeatureFCEOARD,
		x.CREATE_DATE,
        row_number() over(partition by p.ProviderID, y.CustomerProductCode order by x.CREATE_DATE desc, convert(bit, case when isnull(y.sIsEmployed,'false') in ('true','Y','Yes','1') then 1 else 0 end)  desc) as RowRank,
        row_number() over(partition by p.ProviderID, REPLACE(substring(y.CustomerProductCode,(charindex('-',y.CustomerProductCode)+1),len(y.CustomerProductCode)),'T2','') order by x.CREATE_DATE desc, convert(bit, case when isnull(y.sIsEmployed,'false') in ('true','Y','Yes','1') then 1 else 0 end)  desc) as RowRank1
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
			UNION ALL
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Facility') as ProviderJSON
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
			sIsEmployed varchar(50) '$.IsEmployed', 
            LastUpdateDate datetime2 '$.LastUpdateDate',
			SourceCode varchar(50) '$.SourceCode',
            OptInOptOut varchar(5) '$.OptInOptOut',
			FeatureFCEOARD varchar(20) '$.FeatureFCEOARD')
    ) as y
    ------------------------------------------------------------------
	inner join ods1stage.base.provider p on p.providercode = x.ProviderCode
    ------------------------------------------------------------------
    join ODS1Stage.Base.ClientToProduct as cp on cp.ClientToProductCode = y.CustomerProductCode
    ------------------------------------------------------------------
    where y.CustomerProductCode is not null

    IF OBJECT_ID('tempdb..#Insert1') IS NOT NULL DROP TABLE #Insert1
	select distinct convert(uniqueidentifier, HASHBYTES('SHA1', Concat(cp.ClientToProductCode,b.EntityTypeCode,s.ProviderCode) )) as ClientProductToEntityID,
		s.ClientToProductID, b.EntityTypeID, s.ProviderID as EntityID, IsEmployed as IsEntityEmployed, isnull(s.SourceCode,'Profisee') as SourceCode, isnull(s.LastUpdateDate, getutcdate()) as LastUpdateDate
	into #Insert1
	from #swimlane s
		join ODS1Stage.Base.EntityType b
		on b.EntityTypeCode='PROV'
		join ods1stage.base.ClientToProduct as cp with (nolock)
		on s.ClientTOProductID=cp.ClientToProductID
		join ods1stage.base.Provider as p with (nolock)
		on s.ProviderID=p.ProviderID
	where s.RowRank = 1
		and (s.ClientToProductID is not null and s.ReltioEntityID is not null)
	union
	select distinct convert(uniqueidentifier, HASHBYTES('SHA1', Concat(cp.ClientToProductCode,b.EntityTypeCode,s.ProviderCode) )) as ClientProductToEntityID,
		s.ClientToProductID, b.EntityTypeID, s.ProviderID as EntityID, null as IsEntityEmployed, isnull(s.SourceCode,'Profisee') as SourceCode, isnull(s.LastUpdateDate, getutcdate()) as LastUpdateDate
		--select *
	from #swimlane_LID s
		join ODS1Stage.Base.EntityType b
		on b.EntityTypeCode='PROV'
		join ods1stage.base.ClientToProduct as cp with (nolock)
		on s.ClientTOProductID=cp.ClientToProductID
		join ods1stage.base.Provider as p with (nolock)
		on s.ProviderID=p.ProviderID
	where s.RowRank = 1
		and (s.ClientToProductID is not null and s.ReltioEntityID is not null)

   delete pc
	--select *
    from #provider as p
    inner join ODS1Stage.Base.ClientProductToEntity as pc on pc.EntityID = p.ProviderID

    DELETE ODS1Stage.Base.ClientProductToEntity WHERE ClientProductToEntityID IN (SELECT ClientProductToEntityID FROM #Insert1)

	--Insert all ClientProductToEntity child records
    insert into ODS1Stage.Base.ClientProductToEntity (ClientProductToEntityID, ClientToProductID, EntityTypeID, EntityID, IsEntityEmployed, SourceCode, LastUpdateDate)
	select distinct ClientProductToEntityID, ClientToProductID, EntityTypeID, EntityID, IsEntityEmployed, SourceCode, LastUpdateDate
		--select *
	from #Insert1 s

    --------------------------------–------spuMergeProviderCustomerProduct--------------------------------–------
    --------------------------------–------spuMergeProviderOfficeCustomerProduct--------------------------------–------


    if object_id('tempdb..#swimlane') IS NOT NULL DROP TABLE #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
        convert(uniqueidentifier, convert(varbinary(20), y.OfficeCode)) as OfficeID,
		x.ReltioEntityID, 
		y.OfficeReltioEntityID,
		y.OfficeCode, 
		x.ProviderCode,
        y.LastUpdateDate, 
		y.SourceCode, 
		y.CustomerProductCode as ClientToProductCode,
		rt.RelationshipTypeID,
		cp.ClientToProductID,
		convert(uniqueidentifier, HASHBYTES('SHA1', Concat(y.CustomerProductCode,rt.RelationshipTypeCode,x.ProviderCode,y.OfficeCode) )) as ClientProductEntityRelationshipID,
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), OfficeCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Office') as ProviderJSON
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.ProviderJSON is not null
    ) as x
	left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
	join ODS1Stage.Base.RelationshipType rt on rt.RelationshipTypeCode = 'PROVTOOFF'
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (
            LastUpdateDate datetime '$.LastUpdateDate', 
            OfficeCode varchar(50) '$.OfficeCode', 
            OfficeReltioEntityID varchar(50) '$.ReltioEntityID',  
			SourceCode varchar(25) '$.SourceCode',
			CustomerProductCode varchar(50) '$.CustomerProductCode')
    ) as y
    join ODS1Stage.Base.ClientToProduct as cp on cp.ClientToProductCode = y.CustomerProductCode
    where y.OfficeCode is not null and y.CustomerProductCode is not null
        and y.CustomerProductCode not like '%-PDCHSP'

	if @OutputDestination = 'ODS1Stage' begin
		insert into ODS1Stage.Base.ClientProductToEntity (ClientProductToEntityID, ClientToProductID, EntityTypeID, EntityID, SourceCode, LastUpdateDate)
		select X.ClientProductToEntityID, X.ClientToProductID, X.EntityTypeID, X.OfficeID, X.SourceCode, X.LastUpdateDate
		from(
			select distinct convert(uniqueidentifier, hashbytes('SHA1', concat(cp.ClientToProductCode,et.EntityTypeCode,o.OfficeCode) )) as ClientProductToEntityID
					,cp.ClientToProductID, et.EntityTypeID, T.OfficeID,'Profisee'as SourceCode, getdate() as LastUpdateDate
			from #swimlane T
			join ODS1Stage.Base.EntityType et
			on et.EntityTypeCode='OFFICE'
			join ODS1Stage.Base.ClientToProduct cp
			on T.ClientToProductID=cp.ClientToProductID
			join ODS1Stage.Base.Office o
			on o.OfficeID = T.OfficeID
			join ODS1Stage.Base.Product PR on PR.ProductID = cp.ProductID
			where ProductTypeCode = 'Practice'
		)X
		left join ODS1Stage.Base.ClientProductToEntity T 
					on T.ClientProductToEntityID = X.ClientProductToEntityID
		where T.ClientProductToEntityID is null
    --------------------------------–------spuMergeProviderOfficeCustomerProduct--------------------------------–------
    
    --------------------------------–------spuMergePracticeCustomerProduct--------------------------------–------

        if object_id('tempdb..#swimlane') is not null drop table #swimlane
        select x.PracticeID, x.ReltioEntityID,
            x.PracticeCode, y.CustomerProductCode as ClientToProductCode,
            cp.ClientToProductID,
            getutcdate() as LastUpdateDate,
            row_number() over(partition by x.PracticeID order by x.CREATE_DATE desc) as RowRank
        into #swimlane
        from
        (
            select w.*
            from
            (
                select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PRACTICE_CODE as PracticeCode, p.PracticeID,
                    json_query(p.PAYLOAD, '$.EntityJSONString.CustomerProduct')  as PracticeJSON
                from raw.PracticeProfileProcessingDeDup as d with (nolock)
                inner join raw.PracticeProfileProcessing as p with (nolock) on p.rawPracticeProfileID = d.rawPracticeProfileID
                where p.PAYLOAD is not null
            ) as w
            where w.PracticeJSON is not null
        ) as x
        cross apply
        (
            select *
            from openjson(x.PracticeJSON) with (CustomerProductCode varchar(50) '$.CustomerProductCode')
        ) as y
        join ODS1Stage.Base.ClientToProduct as cp on cp.ClientToProductCode = y.CustomerProductCode

    	delete T
		--select *
		from		ODS1Stage.Base.ClientProductToEntity as T
		inner join	#ClientProductToEntity s
					on s.ClientProductToEntityID = T.ClientProductToEntityID

        insert into ODS1Stage.Base.ClientProductToEntity (ClientProductToEntityID, ClientToProductID, EntityTypeID, EntityID, SourceCode, LastUpdateDate)
		select distinct convert(uniqueidentifier, hashbytes('SHA1', concat(cp.ClientToProductCode,b.EntityTypeCode,s.PracticeCode) )) as ClientProductToEntityID,
			s.ClientToProductID, b.EntityTypeID, s.PracticeID as EntityID, 'Reltio' as SourceCode, isnull(s.LastUpdateDate, getutcdate()) as LastUpdateDate
		from #swimlane s
			join ODS1Stage.Base.EntityType b
			on b.EntityTypeCode='PRAC'
			join ODS1Stage.Base.ClientToProduct cp
			on s.ClientToProductID=cp.ClientToProductID
			join ODS1Stage.Base.Practice o
			on s.PracticeID=o.PracticeID
		left join	ODS1Stage.Base.ClientProductToEntity T
					on convert(uniqueidentifier, hashbytes('SHA1', concat(cp.ClientToProductCode,b.EntityTypeCode,s.PracticeCode) )) = T.ClientProductToEntityID
		where	s.RowRank = 1
				and s.ClientToProductID is not null
				and s.PracticeID is not null
				and s.ClientToProductCode is not null
				and substring(s.ClientToProductCode,(charindex('-',s.ClientToProductCode)+1),len(s.ClientToProductCode)) not in ('CDOAS', 'IOAS')
				and T.ClientProductToEntityID is null

    --------------------------------–------spuMergePracticeCustomerProduct--------------------------------–------
