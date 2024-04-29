-- etl.spumergecustomerproduct

begin

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

	DELETE #swimlane WHERE RowRank > 1

	--Parsing DisplayPartner-Phone.
	if object_id('tempdb..#swimlanePhones') is not null drop table #swimlanePhones
	select s.ClientToProductCode, s.ProductCode, x.*
	into #swimlanePhones
	from #swimlane as s
	outer apply
	(
		select *
		from openjson(s.DisplayPartnerJSON) with
		(	
			DisplayPartnerCode varchar(15) '$.refDisplayPartnerCode',
			PhonePTDES varchar(15) '$.PhonePTDES',
			PhonePTDESM varchar(15) '$.PhonePTDESM',
			PhonePTDEST varchar(15) '$.PhonePTDEST',
			PhonePTEMP varchar(15) '$.PhonePTEMP',
			PhonePTEMPM varchar(15) '$.PhonePTEMPM',
			PhonePTEMPT varchar(15) '$.PhonePTEMPT',
			PhonePTHOS varchar(15) '$.PhonePTHOS',
			PhonePTHOSM varchar(15) '$.PhonePTHOSM',
			PhonePTHOST varchar(15) '$.PhonePTHOST',
			PhonePTMTR varchar(15) '$.PhonePTMTR',
			PhonePTMTRT varchar(15) '$.PhonePTMTRT',
			PhonePTMTRM varchar(15) '$.PhonePTMTRM',
			PhonePTMWC varchar(15) '$.PhonePTMWC',
			PhonePTMWCT varchar(15) '$.PhonePTMWCT',
			PhonePTMWCM varchar(15) '$.PhonePTMWCM',
			PhonePTPSR varchar(15) '$.PhonePTPSR',
			PhonePTPSRD varchar(15) '$.PhonePTPSRD',
			PhonePTPSRM varchar(15) '$.PhonePTPSRM',
			PhonePTPSRT varchar(15) '$.PhonePTPSRT',
			PhonePTDPPEP varchar(15) '$.PhonePTDPPEP',
			PhonePTDPPNP varchar(15) '$.PhonePTDPPNP'			
		)
	)as x
	inner join ODS1Stage.Base.SyndicationPartner as sp on sp.SyndicationPartnerCode = x.DisplayPartnerCode

	UPDATE T SET FeatureFCBRL = 'FV' + UPPER(REPLACE(REPLACE(REPLACE(FeatureFCBRL,'CLIENT','CLT'),'CUSTOMER','CLT'),'FACILITY','FAC'))
	--select T.FeatureFCBRL
	FROM	#swimlane T
	WHERE	LEFT(FeatureFCBRL,2) != 'FV'
		
	UPDATE	#swimlane 
	SET		OASPartnerTypeCode = 'URL'
	WHERE	PRODUCTCODE IN ('CDOAS','IOAS') AND OASPartnerTypeCode IS NULL
    
	--Customer Name often not included in data from Snowflake
    update s set CustomerName = 
        case 
            when s.CustomerName is null and c.ClientName is null then s.ClientCode 
            when s.CustomerName is null and c.ClientName is not null then c.ClientName 
            else s.CustomerName
        end
    --select s.CustomerName
	from #swimlane as s
    left join ODS1Stage.Base.Client as c on c.ClientCode = s.ClientCode

	/*
	UPDATE	T
	SET		PhonePTDES = NULL
			,PhonePTDESM = NULL
			,PhonePTDEST = NULL
			,PhonePTEMP = NULL
			,PhonePTEMPM = NULL
			,PhonePTEMPT = NULL
			,PhonePTHOS = NULL
			,PhonePTHOSM = NULL
			,PhonePTHOST = NULL
			,PhonePTMTR = NULL
			,PhonePTMTRT = NULL
			,PhonePTMTRM = NULL
			,PhonePTMWC = NULL
			,PhonePTMWCT = NULL
			,PhonePTMWCM = NULL
			,PhonePTPSR = NULL
			,PhonePTPSRD = NULL
			,PhonePTPSRM = NULL
			,PhonePTPSRT = NULL
			,PhonePTDPPEP = NULL
			,PhonePTDPPNP = NULL
	--SELECT *
	FROM	#swimlane T
	WHERE	ClientCode IN ('STDAVD','HCASAM',/*'HCAPASO',*/'HCAWNV','HCAGC', 'HCAHL1','HCACKS','HCALEW','HCACARES','HCACVA','HCAFRFT','HCATRI','HCASATL','HCANFD','HCAMW','HCAWFD','HCAMT') 
			AND ProductCode = 'MAP'
	*/

	UPDATE	T
	SET		PhonePTDES = NULL
			,PhonePTDESM = NULL
			,PhonePTDEST = NULL
			,PhonePTEMP = NULL
			,PhonePTEMPM = NULL
			,PhonePTEMPT = NULL
			,PhonePTHOS = NULL
			,PhonePTHOSM = NULL
			,PhonePTHOST = NULL
			--,PhonePTMTR = NULL--Standard MT
			,PhonePTMTRT = NULL
			,PhonePTMTRM = NULL
			,PhonePTMWC = NULL
			,PhonePTMWCT = NULL
			,PhonePTMWCM = NULL
			--,PhonePTPSR = NULL--Standard PSR
			,PhonePTPSRD = NULL
			,PhonePTPSRM = NULL
			,PhonePTPSRT = NULL
			,PhonePTDPPEP = NULL
			,PhonePTDPPNP = NULL
	--SELECT *
	FROM	#swimlanePhones T
	WHERE	ProductCode = 'MAP'

    insert into ODS1Stage.Base.ClientToProduct (ClientID, ProductID, ActiveFlag, SourceCode, LastUpdateDate, QueueSize, ClientToProductCode, ReltioEntityID)
    select s.ClientID, s.ProductID, isnull(s.ActiveFlag, 1) as ActiveFlag, isnull(s.SourceCode, 'Profisee') as SourceCode,
		isnull(s.LastUpdateDate, getutcdate()) as LastUpdateDate, s.QueueSize, s.ClientToProductCode, s.ReltioEntityID
    from (select distinct ClientCode, ClientID, ProductID, CustomerName as ClientName, ClientToProductCode, ReltioEntityID,
        LastUpdateDate, SourceCode, QueueSize, ActiveFlag from #swimlane where RowRank = 1) as s
    where (s.ClientToProductCode is not null and s.ClientID is not null and s.ProductID is not null)	
        and not exists (select 1 from ODS1Stage.Base.ClientToProduct as cp where cp.ClientToProductCode = s.ClientToProductCode)

	-- Client to product ID is probably wrong. The only place it's right is in ODS1Stage.base.ClientToProduct
	update p set p.ClientToProductID = cp.ClientToProductID
	-- select p.ClientToProductID, cp.ClientToProductID
	from raw.CustomerProductProfileProcessingDeDup as p
	inner join ODS1Stage.base.ClientToProduct cp with (nolock) on cp.ClientToProductCode = p.ClientToProductCode
	where p.ClientToProductID != cp.ClientToProductID

	-- Client to product ID is probably wrong. The only place it's right is in ODS1Stage.base.ClientToProduct
	update s set s.ClientToProductID = cp.ClientToProductID
	-- select count(*)
	--select s.ClientToProductID, cp.ClientToProductID
	from #swimlane s 
	inner join ODS1Stage.base.ClientToProduct cp with (nolock) on cp.ClientToProductCode = s.ClientToProductCode
	where s.ClientToProductID != cp.ClientToProductID

--Deletes
 --   delete x
	----select *
	--from ODS1Stage.Base.ClientProductEntityToPhone x 
	--	join ODS1Stage.Base.EntityType b
	--	on b.EntityTypeCode='CLPROD'
	--	join ODS1Stage.Base.ClientProductToEntity c on x.ClientProductToEntityID=c.ClientProductToEntityID
	--	join raw.CustomerProductProfileProcessing s on c.EntityID=convert(uniqueidentifier, convert(varbinary, replace(s.CUSTOMER_PRODUCT_CODE, ' ', '')))

	delete pc
	--select *
    from raw.CustomerProductProfileProcessingDeDup as p with (nolock)
	inner join ODS1Stage.Base.ClientProductToEntity c  with (nolock) on c.EntityID = p.ClientToProductID
    inner join ODS1Stage.Base.EntityType b with (nolock) on b.EntityTypeID = c.EntityTypeID and b.EntityTypeCode='CLPROD'
    inner join ODS1Stage.Base.ClientProductEntityToPhone pc on pc.ClientProductToEntityID=c.ClientProductToEntityID

	delete pc
	--select *
    from raw.CustomerProductProfileProcessingDeDup as p with (nolock)
	inner join ODS1Stage.Base.ClientProductToEntity c  with (nolock) on c.EntityID = p.ClientToProductID
    inner join ODS1Stage.Base.EntityType b with (nolock) on b.EntityTypeID = c.EntityTypeID and b.EntityTypeCode='CLPROD'
    inner join ODS1Stage.Base.ClientProductEntityToDisplayPartnerPhone pc on pc.ClientProductToEntityID=c.ClientProductToEntityID

	--delete x
	--from ODS1Stage.Base.ClientEntityToClientFeature x 
	--join raw.CustomerProductProfileProcessing s on x.EntityID=convert(uniqueidentifier, convert(varbinary, replace(s.CUSTOMER_PRODUCT_CODE, ' ', '')))

	delete x
	--select *
    from raw.CustomerProductProfileProcessingDeDup as d with (nolock)
    inner join raw.CustomerProductProfileProcessing as p with (nolock) on p.rawCustomerProductProfileID = d.rawCustomerProductProfileID
	inner join ODS1Stage.Base.ClientEntityToClientFeature x  with (nolock) on x.EntityID = p.ClientToProductID
	
	delete x
	--select *
    from #swimlane S
	inner join ODS1Stage.Base.ClientEntityToClientFeature x  with (nolock) on x.EntityID = S.ClientToProductID

	delete x
	--select *
    from raw.CustomerProductProfileProcessingDeDup as d with (nolock)
    inner join raw.CustomerProductProfileProcessing as p with (nolock) on p.rawCustomerProductProfileID = d.rawCustomerProductProfileID
	inner join ODS1Stage.Base.ClientProductToEntity x with (nolock) on x.EntityID = p.ClientToProductID

	/*delete x
	from ODS1Stage.Base.Client x 
	join raw.CustomerProductProfileProcessing s on x.ClientCode=left(s.CustomerProductCode,charindex('-',s.CUSTOMER_PRODUCT_CODE)-1)*/
	

	--Base.Client Update
	update p set p.ClientName=s.ClientName, p.LastUpdateDate = isnull(s.LastUpdateDate, getutcdate())
    from (select distinct ClientCode, ClientID, CustomerName as ClientName, LastUpdateDate  from #swimlane where RowRank = 1) as s
    inner join ODS1Stage.Base.Client as p on p.ClientID = s.ClientID

    insert into ODS1Stage.Base.Client (ClientID, ClientCode, ClientName, SourceCode, LastUpdateDate )
    select s.ClientID, s.ClientCode, s.ClientName, isnull(s.SourceCode, 'Profisee') as SourceCode, isnull(s.LastUpdateDate, getutcdate()) as LastUpdateDate
    from (select distinct ClientCode, ClientID, CustomerName as ClientName, LastUpdateDate, SourceCode from #swimlane where RowRank = 1) as s
    where not exists (select 1 from ODS1Stage.Base.Client as p where p.ClientID = s.ClientID)
		and (s.ClientID is not null and s.ClientCode is not null)

	--Base.ClientProductToEntity Update
	insert into ODS1Stage.Base.ClientProductToEntity (ClientProductToEntityID, ClientToProductID, EntityTypeID, EntityID, LastUpdateDate)
	select distinct convert(uniqueidentifier, hashbytes('SHA1',  concat(ClientToProductCode,b.EntityTypeCode,ClientToProductCode) )) as ClientProductToEntityID,
		ClientToProductID, b.EntityTypeID, ClientToProductID as EntityID, isnull(s.LastUpdateDate, getutcdate()) as LastUpdateDate
	from #swimlane s
		join ODS1Stage.Base.EntityType b
		on b.EntityTypeCode='CLPROD'
	where (s.ClientToProductID is not null and s.ClientID is not null and s.ProductID is not null)
		and not exists (select 1 from ODS1Stage.Base.ClientProductToEntity as cpe2 where cpe2.ClientProductToEntityID = convert(uniqueidentifier, hashbytes('SHA1',  concat(ClientToProductCode,b.EntityTypeCode,ClientToProductCode))))

	--Base.ClientProductEntityRelationship
	--Not used here, just PRACTOOFF, PROVTOFAC, PROVTOOFF

	--Feature Updates
	--drop table #tmp_Features
	if object_id('tempdb..#tmp_Features') IS NOT NULL DROP TABLE #tmp_Features
	select ClientToProductCode, 'FCBFN' as ClientFeatureCode, FeatureFCBFN as ClientFeatureValueCode into #tmp_Features from #swimlane where FeatureFCBFN='FVNO' and RowRank = 1 union
	select ClientToProductCode, 'FCBFN' as ClientFeatureCode, FeatureFCBFN as ClientFeatureValueCode from #swimlane where FeatureFCBFN='FVYES' and RowRank = 1 union
	select ClientToProductCode, 'FCCCP' as ClientFeatureCode, FeatureFCCCP_FVCLT as ClientFeatureValueCode from #swimlane where FeatureFCCCP_FVCLT='FVCLT' and RowRank = 1 union
	select ClientToProductCode, 'FCCCP' as ClientFeatureCode, FeatureFCCCP_FVFAC as ClientFeatureValueCode from #swimlane where FeatureFCCCP_FVFAC='FVFAC' and RowRank = 1 union
	select ClientToProductCode, 'FCCCP' as ClientFeatureCode, FeatureFCCCP_FVOFFICE as ClientFeatureValueCode from #swimlane where FeatureFCCCP_FVOFFICE='FVOFFICE' and RowRank = 1 union
	select ClientToProductCode, 'FCDTP' as ClientFeatureCode, FeatureFCDTP as ClientFeatureValueCode from #swimlane where FeatureFCDTP='FVPPN' and RowRank = 1 union
	select ClientToProductCode, 'FCDTP' as ClientFeatureCode, FeatureFCDTP as ClientFeatureValueCode from #swimlane where FeatureFCDTP='FVPTN' and RowRank = 1 union
	select ClientToProductCode, 'FCMWC' as ClientFeatureCode, FeatureFCMWC as ClientFeatureValueCode from #swimlane where FeatureFCMWC='FVNO' and RowRank = 1 union
	select ClientToProductCode, 'FCMWC' as ClientFeatureCode, FeatureFCMWC as ClientFeatureValueCode from #swimlane where FeatureFCMWC='FVYES' and RowRank = 1 union
	select ClientToProductCode, 'FCNPA' as ClientFeatureCode, FeatureFCNPA as ClientFeatureValueCode from #swimlane where FeatureFCNPA='FVYES' and RowRank = 1 union
	select ClientToProductCode, 'FCNPA' as ClientFeatureCode, FeatureFCNPA as ClientFeatureValueCode from #swimlane where FeatureFCNPA='FVNO' and RowRank = 1 union
	select ClientToProductCode, 'FCBRL' as ClientFeatureCode, FeatureFCBRL as ClientFeatureValueCode from #swimlane where FeatureFCBRL='FVCLT' and RowRank = 1 union
	select ClientToProductCode, 'FCBRL' as ClientFeatureCode, FeatureFCBRL as ClientFeatureValueCode from #swimlane where FeatureFCBRL='FVFAC' and RowRank = 1 union
	select ClientToProductCode, 'FCBRL' as ClientFeatureCode, FeatureFCBRL as ClientFeatureValueCode from #swimlane where FeatureFCBRL='FVOFFICE' and RowRank = 1 union
	select ClientToProductCode, 'FCEPR' as ClientFeatureCode, FeatureFCEPR as ClientFeatureValueCode from #swimlane where FeatureFCEPR='FVYES' and RowRank = 1 union
	select ClientToProductCode, 'FCEPR' as ClientFeatureCode, FeatureFCEPR as ClientFeatureValueCode from #swimlane where FeatureFCEPR='FVNO' and RowRank = 1 union
	select ClientToProductCode, 'FCOOACP' as ClientFeatureCode, FeatureFCOOACP as ClientFeatureValueCode from #swimlane where FeatureFCOOACP='FVYES' and RowRank = 1 union
	select ClientToProductCode, 'FCOOACP' as ClientFeatureCode, FeatureFCOOACP as ClientFeatureValueCode from #swimlane where FeatureFCOOACP='FVNO' and RowRank = 1 union
	select ClientToProductCode, 'FCLOT' as ClientFeatureCode, FeatureFCLOT as ClientFeatureValueCode from #swimlane where FeatureFCLOT='FVCUS' and RowRank = 1 union
	select ClientToProductCode, 'FCMAR' as ClientFeatureCode, FeatureFCMAR as ClientFeatureValueCode from #swimlane where FeatureFCMAR='FVFAC' and RowRank = 1 union
	select ClientToProductCode, 'FCDOA' as ClientFeatureCode, FeatureFCDOA as ClientFeatureValueCode from #swimlane where FeatureFCDOA='FVNO' and RowRank = 1 union
	select ClientToProductCode, 'FCDOA' as ClientFeatureCode, FeatureFCDOA as ClientFeatureValueCode from #swimlane where FeatureFCDOA='FVYES' and RowRank = 1 union
	select ClientToProductCode, 'FCDOS' as ClientFeatureCode, FeatureFCDOS_FVFAX as ClientFeatureValueCode from #swimlane where FeatureFCDOS_FVFAX='FVFAX' and RowRank = 1 union
	select ClientToProductCode, 'FCDOS' as ClientFeatureCode, FeatureFCDOS_FVMMPEML as ClientFeatureValueCode from #swimlane where FeatureFCDOS_FVMMPEML='FVMMPEML' and RowRank = 1 union
	select ClientToProductCode, 'FCEOARD' as ClientFeatureCode, FeatureFCEOARD as ClientFeatureValueCode from #swimlane where FeatureFCEOARD='FVAQSTD' and RowRank = 1 union
	select ClientToProductCode, 'FCOBT' as ClientFeatureCode, FeatureFCOBT as ClientFeatureValueCode from #swimlane where FeatureFCOBT='FVRAPT' and RowRank = 1 union
	select ClientToProductCode, 'FCODC' as ClientFeatureCode, FeatureFCODC_FVDFC as ClientFeatureValueCode from #swimlane where FeatureFCODC_FVDFC='FVDFC' and RowRank = 1 union
	select ClientToProductCode, 'FCODC' as ClientFeatureCode, FeatureFCODC_FVDPR as ClientFeatureValueCode from #swimlane where FeatureFCODC_FVDPR='FVDPR' and RowRank = 1 union
	select ClientToProductCode, 'FCODC' as ClientFeatureCode, FeatureFCODC_FVMT as ClientFeatureValueCode from #swimlane where FeatureFCODC_FVMT='FVMT' and RowRank = 1 union
	select ClientToProductCode, 'FCODC' as ClientFeatureCode, FeatureFCODC_FVPSR as ClientFeatureValueCode from #swimlane where FeatureFCODC_FVPSR='FVPSR' and RowRank = 1 union
	select ClientToProductCode, 'FCOAS' as ClientFeatureCode, FeatureFCOAS as ClientFeatureValueCode from #swimlane where FeatureFCOAS='FVYES' and RowRank = 1 union
	select ClientToProductCode, 'FCSPC' as ClientFeatureCode, FeatureFCSPC as ClientFeatureValueCode from #swimlane where FeatureFCSPC='FVABR1' and RowRank = 1 union
	select ClientToProductCode, 'FCPNI' as ClientFeatureCode, FeatureFCPNI as ClientFeatureValueCode from #swimlane where FeatureFCPNI='FVYES' and RowRank = 1 union
	select ClientToProductCode, 'FCPQM' as ClientFeatureCode, FeatureFCPQM as ClientFeatureValueCode from #swimlane where FeatureFCPQM='FVNO' and RowRank = 1 union
	select ClientToProductCode, 'FCPQM' as ClientFeatureCode, FeatureFCPQM as ClientFeatureValueCode from #swimlane where FeatureFCPQM='FVYES' and RowRank = 1 union
	select ClientToProductCode, 'FCREL' as ClientFeatureCode, FeatureFCREL_FVCPOFFICE as ClientFeatureValueCode from #swimlane where FeatureFCREL_FVCPOFFICE='FVCPOFFICE' and RowRank = 1 union
	select ClientToProductCode, 'FCREL' as ClientFeatureCode, FeatureFCREL_FVCPTOCC as ClientFeatureValueCode from #swimlane where FeatureFCREL_FVCPTOCC='FVCPTOCC' and RowRank = 1 union
	select ClientToProductCode, 'FCREL' as ClientFeatureCode, FeatureFCREL_FVCPTOFAC as ClientFeatureValueCode from #swimlane where FeatureFCREL_FVCPTOFAC='FVCPTOFAC' and RowRank = 1 union
	select ClientToProductCode, 'FCREL' as ClientFeatureCode, FeatureFCREL_FVCPTOPRAC as ClientFeatureValueCode from #swimlane where FeatureFCREL_FVCPTOPRAC='FVCPTOPRAC' and RowRank = 1 union
	select ClientToProductCode, 'FCREL' as ClientFeatureCode, FeatureFCREL_FVCPTOPROV as ClientFeatureValueCode from #swimlane where FeatureFCREL_FVCPTOPROV='FVCPTOPROV' and RowRank = 1 union
	select ClientToProductCode, 'FCREL' as ClientFeatureCode, FeatureFCREL_FVPRACOFF as ClientFeatureValueCode from #swimlane where FeatureFCREL_FVPRACOFF='FVPRACOFF' and RowRank = 1 union
	select ClientToProductCode, 'FCREL' as ClientFeatureCode, FeatureFCREL_FVPROVFAC as ClientFeatureValueCode from #swimlane where FeatureFCREL_FVPROVFAC='FVPROVFAC' and RowRank = 1 union
	select ClientToProductCode, 'FCREL' as ClientFeatureCode, FeatureFCREL_FVPROVOFF as ClientFeatureValueCode from #swimlane where FeatureFCREL_FVPROVOFF='FVPROVOFF' and RowRank = 1 union
	select ClientToProductCode, 'FCOOPSR' as ClientFeatureCode, FeatureFCOOPSR as ClientFeatureValueCode from #swimlane where FeatureFCOOPSR='FVNO' and RowRank = 1 union
	select ClientToProductCode, 'FCOOPSR' as ClientFeatureCode, FeatureFCOOPSR as ClientFeatureValueCode from #swimlane where FeatureFCOOPSR='FVYES' and RowRank = 1 union
	select ClientToProductCode, 'FCOOMT' as ClientFeatureCode, FeatureFCOOMT as ClientFeatureValueCode from #swimlane where FeatureFCOOMT='FVNO' and RowRank = 1 union
	select ClientToProductCode, 'FCOOMT' as ClientFeatureCode, FeatureFCOOMT as ClientFeatureValueCode from #swimlane where FeatureFCOOMT='FVYES' and RowRank = 1 
	
	--ClientFeatureToClientFeatureValue
	INSERT INTO ODS1Stage.Base.ClientFeatureToClientFeatureValue(ClientFeatureToClientFeatureValueId, ClientFeatureId, ClientFeatureValueId, SourceCode, LastUpdateDate)
	SELECT	X.*
	FROM(
		SELECT		DISTINCT 
					convert(uniqueidentifier, hashbytes('SHA1',  concat(T.ClientFeatureCode,T.ClientFeatureValueCode))) as ClientFeatureToClientFeatureValueID
					,ClientFeatureId
					,ClientFeatureValueId
					,'Reltio' as SourceCode, getutcdate() as LastUpdateDate
		FROM		#tmp_Features T
		INNER JOIN	ODS1Stage.Base.ClientFeature CF
					ON CF.ClientFeatureCode = T.ClientFeatureCode
		INNER JOIN	ODS1Stage.Base.ClientFeatureValue CFV
					ON CFV.ClientFeatureValueCode = T.ClientFeatureValueCode
	)X
	LEFT JOIN	ODS1Stage.Base.ClientFeatureToClientFeatureValue T
				ON T.ClientFeatureToClientFeatureValueId = X.ClientFeatureToClientFeatureValueId
	WHERE		T.ClientFeatureToClientFeatureValueId IS NULL

	--Base.ClientEntityToClientFeature
	insert into ODS1Stage.Base.ClientEntityToClientFeature
	select distinct convert(uniqueidentifier, hashbytes('SHA1',  concat(s.ClientToProductCode, s.ClientFeatureCode, s.ClientFeatureValueCode))) as ClientEntityToClientFeatureID, 
		b.EntityTypeID, 
		convert(uniqueidentifier, convert(varbinary, ClientFeatureCode)) as ClientFeatureID, 
		convert(uniqueidentifier, hashbytes('SHA1',  concat(ClientFeatureCode,ClientFeatureValueCode))) as ClientFeatureToClientFeatureValueID, 
		c.ClientToProductID as EntityID, 'Reltio' as SourceCode, getutcdate() as LastUpdateDate
	from #tmp_Features s
		join ODS1Stage.Base.EntityType b
		on b.EntityTypeCode='CLPROD'
		join (select distinct ClientToProductCode, ClientToProductID from #swimlane) c
		on s.ClientToProductCode=c.ClientToProductCode
	where not exists
		(
			select 1
			from ODS1Stage.Base.ClientEntityToClientFeature CEtCF 
			where CEtCF.ClientEntityToClientFeatureID = convert(uniqueidentifier, hashbytes('SHA1',  concat(s.ClientToProductCode, s.ClientFeatureCode, s.ClientFeatureValueCode)))
		)

	--Phone Updates
	IF OBJECT_ID('tempdb..#tmp_Phones') is not null drop table #tmp_Phones
	select ClientToProductCode, DisplayPartnerCode, 'PTDES' as PhoneTypeCode, PhonePTDES as PhoneNumber into #tmp_Phones from #swimlanePhones where PhonePTDES is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTDESM' as PhoneTypeCode, PhonePTDESM as PhoneNumber from #swimlanePhones where PhonePTDESM is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTDEST' as PhoneTypeCode, PhonePTDEST as PhoneNumber from #swimlanePhones where PhonePTDEST is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTEMP' as PhoneTypeCode, PhonePTEMP as PhoneNumber from #swimlanePhones where PhonePTEMP is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTEMPM' as PhoneTypeCode, PhonePTEMPM as PhoneNumber from #swimlanePhones where PhonePTEMPM is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTEMPT' as PhoneTypeCode, PhonePTEMPT as PhoneNumber from #swimlanePhones where PhonePTEMPT is not null  union
	select ClientToProductCode, DisplayPartnerCode, 'PTHOS' as PhoneTypeCode, PhonePTHOS as PhoneNumber from #swimlanePhones where PhonePTHOS is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTHOSM' as PhoneTypeCode, PhonePTHOSM as PhoneNumber from #swimlanePhones where PhonePTHOSM is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTHOST' as PhoneTypeCode, PhonePTHOST as PhoneNumber from #swimlanePhones where PhonePTHOST is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTMTR' as PhoneTypeCode, PhonePTMTR as PhoneNumber from #swimlanePhones where PhonePTMTR is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTMTRT' as PhoneTypeCode, PhonePTMTRT as PhoneNumber from #swimlanePhones where PhonePTMTRT is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTMTRM' as PhoneTypeCode, PhonePTMTRM as PhoneNumber from #swimlanePhones where PhonePTMTRM is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTMWC' as PhoneTypeCode, PhonePTMWC as PhoneNumber from #swimlanePhones where PhonePTMWC is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTMWCT' as PhoneTypeCode, PhonePTMWCT as PhoneNumber from #swimlanePhones where PhonePTMWCT is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTMWCM' as PhoneTypeCode, PhonePTMWCM as PhoneNumber from #swimlanePhones where PhonePTMWCM is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTPSR' as PhoneTypeCode, PhonePTPSR as PhoneNumber from #swimlanePhones where PhonePTPSR is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTPSRD' as PhoneTypeCode, PhonePTPSRD as PhoneNumber from #swimlanePhones where PhonePTPSRD is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTPSRM' as PhoneTypeCode, PhonePTPSRM as PhoneNumber from #swimlanePhones where PhonePTPSRM is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTPSRT' as PhoneTypeCode, PhonePTPSRT as PhoneNumber from #swimlanePhones where PhonePTPSRT is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTDPPEP' as PhoneTypeCode, PhonePTDPPEP as PhoneNumber from #swimlanePhones where PhonePTDPPEP is not null union
	select ClientToProductCode, DisplayPartnerCode, 'PTDPPNP' as PhoneTypeCode, PhonePTDPPNP as PhoneNumber from #swimlanePhones where PhonePTDPPNP is not null  

	--Base.Phone Update for HG
	-- default sequential ID is generated by the table
	insert into ODS1Stage.Base.Phone (PhoneNumber, LastUpdateDate)
	select distinct s.PhoneNumber, getutcdate() as LastUpdateDate
	from #tmp_Phones s
	where not exists (select 1 from ODS1Stage.Base.Phone as p where s.PhoneNumber=p.PhoneNumber)
		and s.DisplayPartnerCode = 'HG'

	--Base.ClientProductEntityToPhone for HG
	-- default ClientProductToEntityToPhoneID is generated by the table. 
	-- also, the ClientToProductID and the EntityID have the same value in table base.ClientProductToEntity for EntityTypeCode='CLPROD'
	insert into ODS1Stage.Base.ClientProductEntityToPhone (ClientProductToEntityID, PhoneTypeID, PhoneID, SourceCode, LastUpdateDate)
	select distinct CPtE.ClientProductToEntityID, pt.PhoneTypeID, ph.PhoneID, 'Profisee' as SourceCode, getutcdate() as LastUpdateDate
	-- select *
	from #tmp_Phones s
	inner join ODS1Stage.Base.EntityType b on b.EntityTypeCode='CLPROD'
	inner join ODS1Stage.base.Phone ph on ph.PhoneNumber = s.PhoneNumber
	inner join ODS1Stage.base.PhoneType pt on pt.PhoneTypeCode = s.PhoneTypeCode
	inner join ODS1Stage.base.ClientToProduct CtP on CtP.ClientToProductCode = s.ClientToProductCode
	inner join ODS1Stage.base.ClientProductToEntity CPtE on CPtE.ClientToProductID = CtP.ClientToProductID and CPtE.EntityTypeID = b.EntityTypeID
	where not exists(select 1 from ODS1Stage.Base.ClientProductEntityToPhone CPEtP where CPEtP.ClientProductToEntityID = CPtE.ClientProductToEntityID and CPEtP.PhoneTypeID = pt.PhoneTypeID and CPEtP.PhoneID = ph.PhoneID)
		and s.DisplayPartnerCode = 'HG'

	--Base.ClientProductEntityToDisplayPartnerPhone update for Non HG
	insert into ODS1Stage.Base.ClientProductEntityToDisplayPartnerPhone (ClientProductToEntityID, DisplayPartnerCode, PhoneTypeID, PhoneNumber, SourceCode, LastUpdateDate)
	select distinct CPtE.ClientProductToEntityID, s.DisplayPartnerCode, pt.PhoneTypeID, s.PhoneNumber, 'Profisee' as SourceCode, getutcdate() as LastUpdateDate
	--select *
	from #tmp_Phones s
	inner join ODS1Stage.Base.EntityType b on b.EntityTypeCode='CLPROD'
	inner join ODS1Stage.base.PhoneType pt on pt.PhoneTypeCode = s.PhoneTypeCode
	inner join ODS1Stage.base.ClientToProduct CtP on CtP.ClientToProductCode = s.ClientToProductCode
	inner join ODS1Stage.base.ClientProductToEntity CPtE on CPtE.ClientToProductID = CtP.ClientToProductID and CPtE.EntityTypeID = b.EntityTypeID
	where not exists(select 1 from ODS1Stage.Base.ClientProductEntityToDisplayPartnerPhone as cpedpp where cpedpp.ClientProductToEntityID = CPtE.ClientProductToEntityID and cpedpp.PhoneTypeID = pt.PhoneTypeID and cpedpp.PhoneNumber = s.PhoneNumber and cpedpp.DisplayPartnerCode = s.DisplayPartnerCode)
		and s.DisplayPartnerCode != 'HG'

	--ODS1Stage.Base.Partner
	insert into ODS1Stage.Base.Partner (PartnerID, PartnerCode, PartnerDescription, PartnerTypeID, PartnerProductCode, PartnerProductDescription, URLPath)
    select s.ClientID, cast(s.ClientCode as varchar(50)), cast(c.ClientName as varchar(50)), pt.PartnerTypeID, cast(s.ProductCode as varchar(10)), cast(prd.ProductDescription as varchar(500)), cast(s.OASURLPath as varchar(150))
    from #swimlane as s
    inner join ODS1Stage.Base.PartnerType pt with (nolock)  on pt.PartnerTypeCode =s.OASPartnerTypeCode
    inner join ODS1Stage.Base.Client as c on c.ClientCode = s.ClientCode
    inner join ODS1Stage.Base.Product as prd on prd.ProductCode = s.ProductCode
    where not exists (select 1 from ODS1Stage.Base.Partner as p where p.PartnerCode = s.ClientCode)

    update p set p.PartnerTypeID = pt.PartnerTypeID, p.PartnerProductCode = s.ProductCode, p.URLPath = s.OASURLPath,
        p.PartnerDescription = c.ClientName, p.PartnerProductDescription = prd.ProductDescription
	-- select p.PartnerTypeID, pt.PartnerTypeID, p.PartnerProductCode, s.ProductCode, p.URLPath, s.OASURLPath, p.PartnerDescription, c.ClientName, p.PartnerProductDescription, prd.ProductDescription
    from #swimlane as s
    inner join ODS1Stage.Base.Partner as p on p.PartnerCode = s.ClientCode
    inner join ODS1Stage.Base.PartnerType pt with (nolock)  on pt.PartnerTypeCode =s.OASPartnerTypeCode
    inner join ODS1Stage.Base.Client as c on c.ClientCode = s.ClientCode
    inner join ODS1Stage.Base.Product as prd on prd.ProductCode = s.ProductCode
    where (isnull(p.PartnerTypeID,'00000000-0000-0000-0000-000000000000') != isnull(pt.PartnerTypeID,'00000000-0000-0000-0000-000000000000') or 
		isnull(p.PartnerProductCode,'') != isnull(s.ProductCode,'') or isnull(p.URLPath,'') != isnull(s.OASURLPath,'')
        or isnull(p.PartnerDescription,'') != isnull(c.ClientName,'') or isnull(p.PartnerProductDescription,'') != isnull(prd.ProductDescription,''))