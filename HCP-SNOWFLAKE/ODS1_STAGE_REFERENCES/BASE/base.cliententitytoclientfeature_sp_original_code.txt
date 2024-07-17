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
    
    delete x
	--select *
    from raw.CustomerProductProfileProcessingDeDup as d with (nolock)
    inner join raw.CustomerProductProfileProcessing as p with (nolock) on p.rawCustomerProductProfileID = d.rawCustomerProductProfileID
	inner join ODS1Stage.Base.ClientEntityToClientFeature x  with (nolock) on x.EntityID = p.ClientToProductID
	
	delete x
	--select *
    from #swimlane S
	inner join ODS1Stage.Base.ClientEntityToClientFeature x  with (nolock) on x.EntityID = S.ClientToProductID

    insert into ODS1Stage.Base.ClientEntityToClientFeature
	select distinct 
    convert(uniqueidentifier, hashbytes('SHA1',  concat(s.ClientToProductCode, s.ClientFeatureCode, s.ClientFeatureValueCode))) as ClientEntityToClientFeatureID, 
		b.EntityTypeID, 
		convert(uniqueidentifier, convert(varbinary, ClientFeatureCode)) as ClientFeatureID, 
		convert(uniqueidentifier, hashbytes('SHA1',  concat(ClientFeatureCode,ClientFeatureValueCode))) as ClientFeatureToClientFeatureValueID, 
		c.ClientToProductID as EntityID, 
        'Reltio' as SourceCode, 
        getutcdate() as LastUpdateDate
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