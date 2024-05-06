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
    
    
    
    
    /***********************************
	Insert new ClientProducttoPartner
	***********************************/
	INSERT INTO ODS1Stage.Base.ClientProductToPartner (ClientProductToPartnerID, ClientToProductID, PartnerID, SourceCode, LastUpdateDate, LastUpdateUser)
	SELECT	NEWID() ClientProductToPartnerID, CtP.ClientToProductId as ClientToProductID, S.ClientId as PartnerID,'HG Reference' as SourceCode,getutcdate() as LastUpdateDate,suser_name() as LastUpdateUser
				--,S.*
	FROM		#SwimLane S
	INNER JOIN	ODS1Stage.Base.Client C 
				ON C.ClientCode = LEFT(S.ClientCode,LEN(S.ClientCode) - 3)
	INNER JOIN	ODS1Stage.Base.ClientToProduct  CtP
				ON CtP.ClientId = C.ClientId
	LEFT JOIN	ODS1Stage.Base.ClientProductToPartner T
				ON T.ClientToProductID = CtP.ClientToProductID
				AND T.PartnerID = S.ClientID
	WHERE		S.ClientCode LIKE '%OAS'
				AND t.ClientProductToPartnerID IS NULL

	INSERT INTO ODS1Stage.Base.ClientProductToPartner (ClientProductToPartnerID, ClientToProductID, PartnerID, SourceCode, LastUpdateDate, LastUpdateUser)
	SELECT	NEWID() ClientProductToPartnerID, CtP.ClientToProductId as ClientToProductID, (SELECT PartnerId FROM ODS1Stage.Base.Partner WHERE PartnerCode = 'MHD') as PartnerID,'HG Reference' as SourceCode,getutcdate() as LastUpdateDate,suser_name() as LastUpdateUser
				--,S.*
	FROM		#SwimLane S
	INNER JOIN	ODS1Stage.Base.Client C 
				ON C.ClientCode = S.ClientCode
	INNER JOIN	ODS1Stage.Base.Product P
				ON P.ProductCode = S.ProductCode
	INNER JOIN	ODS1Stage.Base.ClientToProduct  CtP
				ON CtP.ClientToProductCode = S.ClientToProductCode
	LEFT JOIN	ODS1Stage.Base.ClientProductToPartner T
				ON T.ClientToProductID = CtP.ClientToProductID
				AND T.PartnerID = (SELECT PartnerId FROM ODS1Stage.Base.Partner WHERE PartnerCode = 'MHD')
	WHERE		t.ClientProductToPartnerID IS NULL
				AND CTP.ClientToProductCode LIKE '%-MAP'
				AND LEFT(S.ClientToProductCode,charindex('-',S.ClientToProductCode)-1) in ('STDAVD','HCASAM','HCASM','HCAPASO','HCAWNV','HCAGC', 'HCAHL1','HCACKS','HCALEW','HCACARES','HCACVA','HCAFRFT','HCATRI','HCASATL','HCANFD','HCAMW','HCAWFD','HCAMT','HCANTD','HCACVA','HCAMT','HCAMW','HCACKS','HCAEFD','HCAGC','HCAHL1','HCALEW','HCANFD','HCAPASO','HCASAM','HCASATL','HCATRI','HCAWFD','HCAWNV','HCAFRFT','HCARES','STDAVD') 