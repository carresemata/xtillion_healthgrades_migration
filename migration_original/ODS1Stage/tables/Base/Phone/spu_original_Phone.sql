-- etl.spumergecustomerproduct (line 52)

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


	-- Client to product ID is probably wrong. The only place it's right is in ODS1Stage.base.ClientToProduct
	update s set s.ClientToProductID = cp.ClientToProductID
	-- select count(*)
	--select s.ClientToProductID, cp.ClientToProductID
	from #swimlane s 
	inner join ODS1Stage.base.ClientToProduct cp with (nolock) on cp.ClientToProductCode = s.ClientToProductCode
	where s.ClientToProductID != cp.ClientToProductID


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


--------------------------------------------------------------------------------------------
-- etl.spumergeofficephone (line 63)
begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
	select		distinct identity(int, 1,1) as swimlaneID
				,x.OfficeID
				,y.PhoneTypeCode
				,case when len(y.PhoneNumber)>15 then left(y.PhoneNumber,charindex(y.PhoneNumber,'x')) else y.PhoneNumber end as PhoneNumber
				,case when len(y1.PhoneNumber)>15 then left(y1.PhoneNumber,charindex(y1.PhoneNumber,'x')) else y1.PhoneNumber end as PhoneNumberCustomerProduct
				,isnull(y.PhoneRank,1) as PhoneRank
				,'Reltio' as SourceCode
				,x.LastUpdateDate
				,convert(uniqueidentifier, convert(varbinary(20), y.PhoneNumber)) as PhoneID
				,pt.PhoneTypeID
				,x.OfficeCode
				,row_number() over(partition by x.OfficeID, convert(uniqueidentifier, convert(varbinary(20), y.PhoneNumber)), pt.PhoneTypeID order by x.LastUpdateDate desc) as PhoneRowRank
    into		#swimlane
    from(
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.OFFICE_CODE as OfficeCode, p.OfficeID, CREATE_DATE as LastUpdateDate, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Phone')  as OfficeJSON
				,json_query(p.PAYLOAD, '$.EntityJSONString.CustomerProduct')  as CustomerProductJSON
            from raw.OfficeProfileProcessingDeDup as d with (nolock)
            inner join raw.OfficeProfileProcessing as p with (nolock) on p.rawOfficeProfileID = d.rawOfficeProfileID
            where p.PAYLOAD is not null 
        ) as w
        where w.OfficeJSON is not null
    ) as x
    cross apply 
    (
        select z.PhoneTypeCode, z.PhoneRank,
            case when z.PhoneNumber not like '%ext.%' then z.PhoneNumber
            else replace(replace(replace(replace(replace(replace(z.PhoneNumber, 'ext', 'x'), '(', ''), ')', ''), '.', ''), '-', ''), ' ', '')
            end as PhoneNumber
        from
        (
            select *
            from openjson(x.OfficeJSON) with (
                PhoneTypeCode varchar(50) '$.Type', 
                PhoneNumber varchar(100) '$."FormattedNumber"',
                PhoneRank varchar(100) '$."Rank"')
        ) as z
    ) as y
    outer apply 
    (
        select 
            case when z.PhoneNumber not like '%ext.%' then z.PhoneNumber
            else replace(replace(replace(replace(replace(replace(z.PhoneNumber, 'ext', 'x'), '(', ''), ')', ''), '.', ''), '-', ''), ' ', '')
            end as PhoneNumber
        from
        (
            select *
            from openjson(x.CustomerProductJSON) with (
                PhoneNumber varchar(100) '$."PhonePTODS"'
				)
        ) as z
    ) as y1
    inner join 
    (
        select PhoneTypeID, PhoneTypeCode as PhoneTypeCodeOriginal,
            case when PhoneTypeCode = 'service' then 'Main'
                when PhoneTypeCode = 'fax' then 'Fax'
                else 'unknown' -- won't join below
            end as PhoneTypeCode
        from ODS1Stage.Base.PhoneType 
    ) as pt on pt.PhoneTypeCode = y.PhoneTypeCode
    where nullif(y.PhoneNumber,'') is not null and nullif(y.PhoneTypeCode,'') is not null
  
   	if @OutputDestination = 'ODS1Stage' begin
	    --Insert new phones into ODS1Stage.Base.Phone
	    insert into ODS1Stage.Base.Phone (PhoneID, PhoneNumber, SourceCode, LastUpdateDate)
	    select ph.PhoneID, ph.PhoneNumber, ph.SourceCode, ph.LastUpdateDate
	    from
	    (
	        select PhoneID, PhoneNumber, SourceCode, LastUpdateDate, 
	            row_number() over(partition by PhoneID order by LastUpdateDate desc, SourceCode) as PhoneRank
	        from #swimlane
	    ) as ph
		left join ODS1Stage.Base.Phone p
		on ph.PhoneID=p.PhoneID
	    where ph.PhoneRank = 1 
		and p.PhoneID is null
		
	    insert into ODS1Stage.Base.Phone (PhoneID, PhoneNumber, SourceCode, LastUpdateDate)
	    select ph.PhoneID, ph.PhoneNumber, ph.SourceCode, ph.LastUpdateDate
	    from
	    (
	        select convert(uniqueidentifier, convert(varbinary(20), PhoneNumberCustomerProduct)) as PhoneID, PhoneNumberCustomerProduct as PhoneNumber, SourceCode, LastUpdateDate, 
	            row_number() over(partition by PhoneNumberCustomerProduct order by LastUpdateDate desc, SourceCode) as PhoneRank
	        from #swimlane
			where PhoneNumberCustomerProduct is not null
	    ) as ph
		left join ODS1Stage.Base.Phone p
		on ph.PhoneID=p.PhoneID
	    where ph.PhoneRank = 1 
		and p.PhoneID is null

--------------------------------------------------------------------
-- etl.spumergefacilitycustomerproduct (line 69)
begin

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
				--and y.CustomerProductCode is not null

	--Parsing DisplayPartner-Phones.
	if object_id('tempdb..#swimlanePhones') is not null drop table #swimlanePhones
	select s.FacilityCode, s.ClientToProductCode, s.RowRank, x.*
	into #swimlanePhones
	from #swimlane as s
	outer apply
	(
		select *
		from openjson(s.DisplayPartnerJSON) with
		(	
			DisplayPartnerCode varchar(15) '$.refDisplayPartnerCode',
			PhonePTFDS varchar(20) '$.PhonePTFDS',
			PhonePTFDSM varchar(20) '$.PhonePTFDSM',
			PhonePTFDST varchar(20) '$.PhonePTFDST',
			PhonePTFMC varchar(20) '$.PhonePTFMC',
			PhonePTFMCM varchar(20) '$.PhonePTFMCM',
			PhonePTFMCT varchar(20) '$.PhonePTFMCT',
			PhonePTFMT varchar(20) '$.PhonePTFMT',
			PhonePTFMTM varchar(20) '$.PhonePTFMTM',
			PhonePTFMTT varchar(20) '$.PhonePTFMTT',
			PhonePTFSR varchar(20) '$.PhonePTFSR',
			PhonePTFSRD varchar(20) '$.PhonePTFSRD',
			PhonePTFSRDM varchar(20) '$.PhonePTFSRDM',
			PhonePTFSRM varchar(20) '$.PhonePTFSRM',
			PhonePTFSRT varchar(20) '$.PhonePTFSRT',
			PhonePTHFS varchar(20) '$.PhonePTHFS',
			PhonePTHFSM varchar(20) '$.PhonePTHFSM',
			PhonePTHFST varchar(20) '$.PhonePTHFST',
			PhonePTUFS varchar(20) '$.PhonePTUFS',
			PhonePTFDPPEP varchar(20) '$.PhonePTFDPPEP',
			PhonePTFDPPNP varchar(20) '$.PhonePTFDPPNP'			
		)
	)as x
	inner join ODS1Stage.Base.SyndicationPartner as sp on sp.SyndicationPartnerCode = x.DisplayPartnerCode

		
		--Phone Updates
		if object_id('tempdb..#tmp_Phones') is not null drop table #tmp_Phones
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFDS' as PhoneTypeCode, PhonePTFDS as PhoneNumber into #tmp_Phones from #swimlanePhones where PhonePTFDS is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFDSM' as PhoneTypeCode, PhonePTFDSM as PhoneNumber from #swimlanePhones where PhonePTFDSM is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFDST' as PhoneTypeCode, PhonePTFDST as PhoneNumber from #swimlanePhones where PhonePTFDST is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFMC' as PhoneTypeCode, PhonePTFMC as PhoneNumber from #swimlanePhones where PhonePTFMC is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFMCM' as PhoneTypeCode, PhonePTFMCM as PhoneNumber from #swimlanePhones where PhonePTFMCM is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFMCT' as PhoneTypeCode, PhonePTFMCT as PhoneNumber from #swimlanePhones where PhonePTFMCT is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFMT' as PhoneTypeCode, PhonePTFMT as PhoneNumber from #swimlanePhones where PhonePTFMT is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFMTM' as PhoneTypeCode, PhonePTFMTM as PhoneNumber from #swimlanePhones where PhonePTFMTM is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFMTT' as PhoneTypeCode, PhonePTFMTT as PhoneNumber from #swimlanePhones where PhonePTFMTT is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFSR' as PhoneTypeCode, PhonePTFSR as PhoneNumber from #swimlanePhones where PhonePTFSR is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFSRD' as PhoneTypeCode, PhonePTFSRD as PhoneNumber from #swimlanePhones where PhonePTFSRD is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFSRDM' as PhoneTypeCode, PhonePTFSRDM as PhoneNumber from #swimlanePhones where PhonePTFSRDM is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFSRM' as PhoneTypeCode, PhonePTFSRM as PhoneNumber from #swimlanePhones where PhonePTFSRM is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFSRT' as PhoneTypeCode, PhonePTFSRT as PhoneNumber from #swimlanePhones where PhonePTFSRT is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTHFS' as PhoneTypeCode, PhonePTHFS as PhoneNumber from #swimlanePhones where PhonePTHFS is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTHFSM' as PhoneTypeCode, PhonePTHFSM as PhoneNumber from #swimlanePhones where PhonePTHFSM is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTHFST' as PhoneTypeCode, PhonePTHFST as PhoneNumber from #swimlanePhones where PhonePTHFST is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTUFS' as PhoneTypeCode, PhonePTUFS as PhoneNumber from #swimlanePhones where PhonePTUFS is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFDPPEP' as PhoneTypeCode, PhonePTFDPPEP as PhoneNumber from #swimlanePhones where PhonePTFDPPEP is not null and RowRank = 1 union
		select FacilityCode, ClientToProductCode, DisplayPartnerCode, 'PTFDPPNP' as PhoneTypeCode, PhonePTFDPPNP as PhoneNumber from #swimlanePhones where PhonePTFDPPNP is not null and RowRank = 1
	
		--Base.Phone Update for HG DisplayPartner
		insert into ODS1Stage.Base.Phone (PhoneID, PhoneNumber, LastUpdateDate)
		select distinct convert(uniqueidentifier, convert(varbinary, s.PhoneNumber )) as PhoneID, s.PhoneNumber, getutcdate() as LastUpdateDate
		from #tmp_phones s
		--this is a short term hack to get Facility CP numbers to the web. This will be cleaned up in a future story. Will join on phone number, not ID. We can't do it now because there are 100k duplicate phone numbers in base.Phone. 
		where not exists (select 1 from ODS1Stage.Base.Phone as p where convert(uniqueidentifier, convert(varbinary, s.PhoneNumber ))=p.PhoneID)
			and s.DisplayPartnerCode = 'HG'


