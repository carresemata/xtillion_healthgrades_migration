-- etl.spumergefacilitycustomerproduct

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

		--Delete all ClientProductToEntity (child) records for all parents in the #swimlane   
		delete x
		--select *
		from raw.FacilityProfileProcessingDeDup as d with (nolock)
		join raw.FacilityProfileProcessing as p with (nolock) on p.rawFacilityProfileID = d.rawFacilityProfileID
		join ODS1Stage.Base.EntityType b on b.EntityTypeCode='FAC'
		join ODS1Stage.Base.Facility (nolock) f	on f.FacilityID=p.FacilityID
		join ODS1Stage.Base.ClientProductToEntity (nolock) c on c.EntityID=f.FacilityID
		join ODS1Stage.Base.ClientProductEntityToPhone x on x.ClientProductToEntityID=c.ClientProductToEntityID

		delete x
		--select x.*
		from raw.FacilityProfileProcessingDeDup as d with (nolock)
		join raw.FacilityProfileProcessing as p with (nolock) on p.rawFacilityProfileID = d.rawFacilityProfileID
		join ODS1Stage.Base.EntityType b on b.EntityTypeCode='FAC'
		join ODS1Stage.Base.Facility (nolock) f	on f.FacilityID=p.FacilityID
		join ODS1Stage.Base.ClientProductToEntity (nolock) c on c.EntityID=f.FacilityID
		join ODS1Stage.Base.ClientProductEntityToDisplayPartnerPhone x on x.ClientProductToEntityID=c.ClientProductToEntityID

		delete x
		--select *
		from raw.FacilityProfileProcessingDeDup as d with (nolock)
		join raw.FacilityProfileProcessing as p with (nolock) on p.rawFacilityProfileID = d.rawFacilityProfileID
		join ODS1Stage.Base.EntityType b on b.EntityTypeCode='FAC'
		join ODS1Stage.Base.Facility (nolock) f	on f.FacilityID=p.FacilityID
		join ODS1Stage.Base.ClientProductToEntity (nolock) c on c.EntityID=f.FacilityID
		join ODS1Stage.Base.ClientProductEntityToImage x on x.ClientProductToEntityID=c.ClientProductToEntityID
		
		delete x
		--select *
		from ODS1Stage.Base.ClientProductEntityToURL x 
			join ODS1Stage.Base.EntityType b on b.EntityTypeCode='FAC'
			join ODS1Stage.Base.ClientProductToEntity (nolock) c on x.ClientProductToEntityID=c.ClientProductToEntityID
			join ODS1Stage.Base.Facility (nolock) f	on c.EntityID=f.FacilityID
			join raw.FacilityProfileProcessing (nolock) p on p.FACILITY_CODE=f.FacilityCode
			join raw.FacilityProfileProcessingDeDup as d with (nolock) on d.rawFacilityProfileID = p.rawFacilityProfileID

		/**************************************
			Selective Deletes
		**************************************/
		IF OBJECT_ID('tempdb..#ClientProductToEntity') IS NOT NULL DROP TABLE #ClientProductToEntity
		select		DISTINCT lCPE.ClientProductToEntityID, lCP.ClientToProductID, dE.EntityTypeID, dF.FacilityID as EntityID
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
					AND S.ClientToProductCode != ISNULL(lCP.ClientToProductCode,'00000000-0000-0000-0000-000000000000')
		WHERE 		s.RowRank = 1
			OR NOT EXISTS (SELECT 1 FROM #swimlane s where s.FacilityCode = p.FACILITY_CODE) --no longer has a CustomerProduct
		UNION
		select		distinct convert(uniqueidentifier, HASHBYTES('SHA1', Concat(cp.ClientToProductCode,b.EntityTypeCode,s.FacilityCode))) as ClientProductToEntityID, s.ClientToProductID, b.EntityTypeID, s.FacilityID as EntityID
		--select *
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

		delete 		t
	   	--select *
		from		ODS1Stage.Base.ClientProductEntityToPhone as t 
		inner join	#ClientProductToEntity s
					ON S.ClientProductToEntityID = T.ClientProductToEntityID

		delete 		t
	   	--select *
		from		ODS1Stage.Base.ClientProductEntityToDisplayPartnerPhone as t 
		inner join	#ClientProductToEntity s
					ON S.ClientProductToEntityID = T.ClientProductToEntityID

		delete 		t
	   	--select *
		from		ODS1Stage.Base.ClientProductEntityToURL as t 
		inner join	#ClientProductToEntity s
					ON S.ClientProductToEntityID = T.ClientProductToEntityID

		delete		t
		--select	t.*
		from		ODS1Stage.Base.ClientProductEntityRelationship t
		inner join	#ClientProductToEntity s
					ON S.ClientProductToEntityID = T.ChildId

		delete		t
		--select	t.*
		from		ODS1Stage.Base.MarketShareToClientProductEntity t
		inner join	#ClientProductToEntity s
					ON S.ClientProductToEntityID = T.ClientProductToEntityID

		delete		t
		--select	t.*
		from		ODS1Stage.Base.ClientProductEntityToImage t
		inner join	#ClientProductToEntity s
					ON S.ClientProductToEntityID = T.ClientProductToEntityID

		delete T
	   --select *
		from		ODS1Stage.Base.ClientProductToEntity as T 
		inner join	#ClientProductToEntity s
					ON S.ClientProductToEntityID = T.ClientProductToEntityID
	
		--Insert all ClientProductToEntity child records
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

		--Base.ClientProductEntityToPhone for HG DisplayPartner
		insert into ODS1Stage.Base.ClientProductEntityToPhone (ClientProductEntityToPhoneID, ClientProductToEntityID, PhoneTypeID, PhoneID, SourceCode, LastUpdateDate)
		select distinct convert(uniqueidentifier, HASHBYTES('SHA1',  concat(s.ClientToProductCode,FacilityCode,s.PhoneTypeCode,s.PhoneNumber) )) as ClientProductEntityToPhoneID, 
			convert(uniqueidentifier, HASHBYTES('SHA1',  Concat(ClientToProductCode,b.EntityTypeCode,FacilityCode) )) as ClientProductToEntityID, 
			convert(uniqueidentifier, convert(varbinary, s.PhoneTypeCode )) as PhoneTypeID, 
			convert(uniqueidentifier, convert(varbinary, s.PhoneNumber )) as PhoneID, 
			'Reltio' as SourceCode, getutcdate() as LastUpdateDate
		from #tmp_phones s
			join ODS1Stage.Base.EntityType b
			on b.EntityTypeCode='FAC'
			join ODS1Stage.Base.ClientProductToEntity cpe
			on convert(uniqueidentifier, HASHBYTES('SHA1',  Concat(ClientToProductCode,b.EntityTypeCode,FacilityCode) ))=cpe.ClientProductToEntityID
			join ODS1Stage.Base.Phone o
			on convert(uniqueidentifier, convert(varbinary, s.PhoneNumber ))=o.PhoneID
		where convert(uniqueidentifier, HASHBYTES('SHA1',  concat(s.ClientToProductCode,FacilityCode,s.PhoneTypeCode,s.PhoneNumber) )) not in (select ClientProductEntityToPhoneID  from ODS1Stage.Base.ClientProductEntityToPhone)
			and s.DisplayPartnerCode = 'HG'

		--Base.ClientProductEntityToDisplayPartnerPhone for Non HG DisplayPartners
		insert into ODS1Stage.Base.ClientProductEntityToDisplayPartnerPhone (ClientProductToEntityID, DisplayPartnerCode, PhoneTypeID, PhoneNumber, SourceCode, LastUpdateDate)
		select distinct 
			convert(uniqueidentifier, HASHBYTES('SHA1',  Concat(ClientToProductCode,b.EntityTypeCode,FacilityCode) )) as ClientProductToEntityID, 
			s.DisplayPartnerCode, convert(uniqueidentifier, convert(varbinary, s.PhoneTypeCode )) as PhoneTypeID, 
			s.PhoneNumber, 'Profisee' as SourceCode, getutcdate() as LastUpdateDate
		from #tmp_phones s
			join ODS1Stage.Base.EntityType b
			on b.EntityTypeCode='FAC'
			join ODS1Stage.Base.ClientProductToEntity cpe
			on convert(uniqueidentifier, HASHBYTES('SHA1',  Concat(ClientToProductCode,b.EntityTypeCode,FacilityCode) ))=cpe.ClientProductToEntityID
		where s.DisplayPartnerCode != 'HG'
			and not exists (
				select 1 from ODS1Stage.Base.ClientProductEntityToDisplayPartnerPhone as cpedpp 
				where cpedpp.ClientProductToEntityID = convert(uniqueidentifier, HASHBYTES('SHA1',  Concat(ClientToProductCode,b.EntityTypeCode,FacilityCode))) 
					and cpedpp.PhoneTypeID = convert(uniqueidentifier, convert(varbinary, s.PhoneTypeCode )) 
					and cpedpp.PhoneNumber = s.PhoneNumber and cpedpp.DisplayPartnerCode = s.DisplayPartnerCode)

		--Image Updates
		--drop table #tmp_image
		select FacilityID, FacilityCode, ClientToProductCode, 'FCFLOGO' as ImageTypeCode, 'LOGO' as ImageSize, FeatureFCFLOGO as ImageFilePath into #tmp_image from #swimlane where FeatureFCFLOGO is not null and RowRank = 1
	
		--Base.Image Update
		insert into ODS1Stage.Base.Image (ImageID, ImageFilePath, LastUpdateDate)
		select distinct convert(uniqueidentifier, HASHBYTES('SHA1', s.ImageFilePath)) as ImageID, s.ImageFilePath, getutcdate() as LastUpdateDate
		from #tmp_image s
		where not exists (select 1 from ODS1Stage.Base.Image as p where p.ImageID=convert(uniqueidentifier, HASHBYTES('SHA1', s.ImageFilePath)))