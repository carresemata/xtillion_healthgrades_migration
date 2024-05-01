-- etl.spumergeprovidermapcustomerproduct
begin
    --Get all MAP Provider-CustomerProduct info for the provider
	if object_id('tempdb..#ProviderCustomerProduct') is not null drop table #ProviderCustomerProduct
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
		x.ProviderReltioEntityID, x.ProviderCode,
        left(y.CustomerProductCode,charindex('-',y.CustomerProductCode)-1) as ClientCode,
        substring(y.CustomerProductCode,(charindex('-',y.CustomerProductCode)+1),len(y.CustomerProductCode)) as ProductCode,
        y.CustomerProductCode as ClientToProductCode, 
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.CustomerProductCode order by x.CREATE_DATE desc) as RowRank
    into #ProviderCustomerProduct
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ProviderReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.CustomerProduct') as ProviderJSON
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.ProviderJSON is not null
    ) as x
    left join ODS1Stage.Base.Provider pID on pID.providercode = x.ProviderCode
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (
            CustomerProductCode varchar(50) '$.CustomerProductCode')
    ) as y
    join ODS1Stage.Base.ClientToProduct as cp on cp.ClientToProductCode = y.CustomerProductCode
    where y.CustomerProductCode is not null
		
    --Get all MAP Provider-Office-CustomerProduct info for the provider
	if object_id('tempdb..#ProviderOfficeCustomerProduct') is not null drop table #ProviderOfficeCustomerProduct
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end ProviderID
		,x.ProviderReltioEntityID
		,x.ProviderCode
        ,left(y.CustomerProductCode,charindex('-',y.CustomerProductCode)-1) as ClientCode
        ,substring(y.CustomerProductCode,(charindex('-',y.CustomerProductCode)+1),len(y.CustomerProductCode)) as ProductCode
        ,y.CustomerProductCode as ClientToProductCode
		,y.OfficeCode
		,y.OfficeReltioEntityID
		,y.TrackingNumber
		,y.DisplayPhoneNumber
		,y.ProviderOfficeRank
		,y.DisplayPartnerCode
		,y.RingToNumber
		,y.RingToNumberType
		,row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.OfficeCode, y.DisplayPartnerCode order by case when y.TrackingNumber is not null then 0 else 1 end, x.CREATE_DATE desc) as RowRank
    into #ProviderOfficeCustomerProduct
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ProviderReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Office') as ProviderJSON
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.ProviderJSON is not null
    ) as x
    left join ODS1Stage.Base.Provider pID on pID.providercode = x.ProviderCode
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (
            ProviderOfficeRank varchar(50) '$."CalculatedOfficeRank"',
            OfficeCode varchar(50) '$."OfficeCode"',
            OfficeReltioEntityID varchar(50) '$."ReltioEntityID"',
            CustomerProductCode varchar(50) '$.CustomerProductCode',
            RingToNumber varchar(50) '$.DestinationPhoneNumber',
            TrackingNumber varchar(50) '$.TrackingPhoneNumber',
			DisplayPhoneNumber varchar(50) '$.DisplayPhoneNumber',
			DisplayPartnerCode varchar(50) '$.DisplayPartnerCode',
			RingToNumberType varchar(50) '$.DestinationPhoneNumberTypeCode'
		)
    ) as y
    inner join ODS1Stage.Base.ClientToProduct as cp on cp.ClientToProductCode = y.CustomerProductCode
	inner join ODS1Stage.Base.SyndicationPartner as sp on sp.SyndicationPartnerCode = y.DisplayPartnerCode
	inner join ODS1Stage.Base.DestinationPhoneNumberType as dp on dp.DestinationPhoneNumberTypeCode = y.RingToNumberType
    where y.CustomerProductCode is not null

    create index ixTem on #ProviderOfficeCustomerProduct (ProviderID, ClientToProductCode)
	
	update	T
	set		TrackingNumber = '('+stuff(stuff(REPLACE(TrackingNumber,'-',''),4,0,') '),9,0,'-')
	--SELECT	'('+STUFF(STUFF(REPLACE(TrackingNumber,'-',''),4,0,') '),9,0,'-'),TrackingNumber
	from	#ProviderOfficeCustomerProduct T
	where	TrackingNumber is not null
			and isnumeric(REPLACE(TrackingNumber,'-','')) = 1


	IF OBJECT_ID('tempdb..#ClientLevelPhones') IS NOT NULL DROP TABLE #ClientLevelPhones
	SELECT		DISTINCT CPE.ClientProductToEntityID, CP.ClientToProductId, CP.ClientToProductCode, PT.PhoneTypeCode, P.PhoneNumber
	INTO		#ClientLevelPhones
	FROM		ODS1Stage.Base.ClientProductEntityToPhone CPEP
	INNER JOIN	ODS1Stage.Base.ClientProductToEntity CPE ON CPE.ClientProductToEntityID = CPEP.ClientProductToEntityID
	INNER JOIN	ODS1Stage.Base.EntityType ET ON ET.EntityTypeID = CPE.EntityTypeID
	INNER JOIN	ODS1Stage.Base.ClientToProduct CP ON CP.ClientToProductId = CPE.ClientToProductId
	INNER JOIN	ODS1Stage.Base.PhoneType PT ON PT.PhoneTypeID = CPEP.PhoneTypeID
	INNER JOIN	ODS1Stage.Base.Phone P On P.PhoneID = CPEP.PhoneID
	INNER JOIN	#ProviderCustomerProduct T ON T.ClientToProductCode = CP.ClientToProductCode
	WHERE		ET.EntityTypeCode = 'CLPROD'

	if @OutputDestination = 'ODS1Stage' begin
        --Delete all ProviderToMAPCustomerProduct records for all parents in p.ProviderProfileProcessing_EGS

        delete pc
        --select pc.*
        from raw.ProviderProfileProcessingDeDup as d with (nolock)
        inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.PROVIDER_CODE
        inner join ODS1Stage.Base.ProviderToMAPCustomerProduct as pc on pc.ProviderID = p2.ProviderID
	
	    --select * from ODS1Stage.Base.ProviderToMAPCustomerProduct 
        --Insert all ProviderToMAPCustomerProduct records
        insert into ODS1Stage.Base.ProviderToMAPCustomerProduct (ProviderID, OfficeID, ClientToProductID, PhoneXML, RingToNumberType, DisplayPartnerCode, InsertedBy, DisplayPhoneNumber, RingToNumber, TrackingNumber)
        select pcp.ProviderID, o.OfficeID, cp.ClientToProductID, 
            (
			    select ph, phTyp
			    from(
				    select pocp.DisplayPhoneNumber as ph, 'PTODS' as phTyp
				    union
				    select CLP.PhoneNumber as ph, CLP.PhoneTypeCode as phTyp
				    from #ClientLevelPhones CLP where CLP.ClientToProductCode = pcp.ClientToProductCode
			    )X
                for xml raw('phone'), elements, type
            ) as PhoneXML
			,pocp.RingToNumberType
		    ,pocp.DisplayPartnerCode
			,case when pocp.TrackingNumber is not null then 'CallCap' else 'No Tracking #' end as InsertedBy
			,pocp.DisplayPhoneNumber 
			,pocp.RingToNumber
			,pocp.TrackingNumber
        --select pocp.*
		from #ProviderCustomerProduct pcp
        inner join #ProviderOfficeCustomerProduct as pocp on pocp.ProviderID = pcp.ProviderID and pocp.ClientToProductCode = pcp.ClientToProductCode	
        inner join ODS1Stage.Base.Office as o on o.OfficeCode = pocp.OfficeCode
        inner join ODS1Stage.Base.ClientToProduct as cp on cp.ClientToProductCode = pcp.ClientToProductCode
        where pcp.RowRank=1 and pocp.RowRank = 1
			    AND pcp.ProductCode = 'MAP'
		
		
	    /*Add Missing*/
	    insert into ODS1Stage.Base.ProviderToMAPCustomerProduct (ProviderID, OfficeID, ClientToProductID, PhoneXML, DisplayPartnerCode)
	    SELECT P.ProviderId, O.OfficeID, lCP.ClientToProductID,
			    (
				    SELECT ph, phTyp
				    FROM(
					    select PH.PhoneNumber as ph, 'PTODS' as phTyp
				    )X
				    for xml raw('phone'), elements, type
			    ) as PhoneXML
			    ,'HG' AS DisplayPartnerCode
	    FROM	ODS1Stage.Base.Provider P
	    INNER JOIN	ODS1Stage.Base.ProviderToOffice PO on PO.ProviderId = P.ProviderID
	    INNER JOIN	ODS1Stage.Base.OfficeToPhone OPH ON OPH.OfficeID = PO.OfficeID 
	    INNER JOIN	ODS1Stage.Base.Phone PH ON PH.PhoneId = OPH.PhoneID
	    INNER JOIN  ODS1Stage.Base.PhoneType PT ON PT.PhoneTypeId = OPH.PhoneTypeId AND PT.PhoneTypeCode = 'SERVICE'
	    INNER JOIN	ODS1Stage.Base.Office O ON O.OfficeId = PO.OfficeID
	    INNER JOIN	ODS1Stage.Base.OfficeToAddress OA on OA.OfficeId = O.OfficeId
	    INNER JOIN	ODS1Stage.Base.Address A on A.AddressId = OA.AddressId
	    INNER JOIN	ODS1Stage.Base.CityStatePostalCode CSPC on CSPC.CityStatePostalCodeID = A.CityStatePostalCodeID
	    INNER JOIN	ODS1Stage.Base.ClientProductToEntity lCPE ON lCPE.EntityId = P.ProviderId
	    INNER JOIN	ODS1Stage.Base.EntityType dE ON dE.EntityTypeId = lCPE.EntityTypeID
	    INNER JOIN	ODS1Stage.Base.ClientToProduct lCP ON lCP.ClientToProductID = lCPE.ClientToProductID
	    INNER JOIN	ODS1Stage.Base.Client dC ON lCP.ClientID = dC.ClientID
	    INNER JOIN	ODS1Stage.Base.Product dP ON dP.ProductId = lCP.ProductID
	    LEFT JOIN	ODS1Stage.Base.ProviderToMAPCustomerProduct T ON T.ProviderId = P.ProviderId AND T.OfficeID = O.OfficeID AND T.DisplayPartnerCode = 'HG'
	    WHERE		dP.ProductCode = 'MAP'
				    AND T.ProviderToMAPCustomerProductID IS NULL

	    DELETE pmcp
        --select *
        from ods1stage.base.ProviderToMAPCustomerProduct  as pmcp
	    where len(cast(phonexml as varchar(max))) <= len('<phone><phTyp>PTODS</phTyp></phone>')
	end