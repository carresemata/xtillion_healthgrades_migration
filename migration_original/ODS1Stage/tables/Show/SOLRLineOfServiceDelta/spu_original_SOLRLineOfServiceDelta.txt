-- 1. Show_spuSOLRLineOfServiceDeltaRefresh
TRUNCATE TABLE Show.SOLRLineOfServiceDelta

	insert into Show.SOLRLineOfServiceDelta(LineOfServiceID, SolrDeltaTypeCode,  MidDeltaProcessComplete)
	select	distinct ls.LineOfServiceID , 1, 1 
	from	Mid.LineOfService ls
		left join Show.SOLRLineOfServiceDelta lsd on ls.LineOfServiceID = lsd.LineOfServiceID
	where lsd.LineOfServiceID is null

-- 2. Show_spuSOLRLineOfServiceGenerateFromMid
-- nothing