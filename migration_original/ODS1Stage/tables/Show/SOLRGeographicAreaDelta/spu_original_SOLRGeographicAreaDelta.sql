-- Show_spuSOLRGeographicAreaGenerateFromMid
--- no updates


-- Show_spuSOLRGeographicAreaDeltaRefresh

TRUNCATE TABLE Show.SOLRGeographicAreaDelta

	insert into Show.SOLRGeographicAreaDelta(GeographicAreaID, SolrDeltaTypeCode,  MidDeltaProcessComplete)
	select	distinct ga.GeographicAreaID , 1, 1 
	from	Mid.GeographicArea ga
		left join Show.SOLRGeographicAreaDelta gad on ga.GeographicAreaID = gad.GeographicAreaID
	where gad.GeographicAreaID is null