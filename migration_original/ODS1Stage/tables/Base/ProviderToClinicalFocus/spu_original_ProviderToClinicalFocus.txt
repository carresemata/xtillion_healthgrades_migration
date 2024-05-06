-- etl.spumergeproviderclinicalfocus
begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct p.ProviderID , p.ProviderCode, y.SourceCode, y.LastUpdateDate, cf.ClinicalFocusID,
        y.ClinicalFocusCode, y.ClinicalFocusDCPCount, y.ClinicalFocusMinBucketsCalculated, y.ProviderDCPCount, y.AverageBPercentile, 
        y.ProviderDCPFillPercent, y.IsProviderDCPCountOverLowThreshold, y.ClinicalFocusScore, y.ProviderClinicalFocusRank,
        row_number() over(partition by p.ProviderCode, y.ClinicalFocusCode order by rawProviderProfileID desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, p.rawProviderProfileID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.ClinicalFocus') as ProviderClinicalFocusJSON
            --from raw.ProviderProfile_HMSCLAIMS_Test as p with (nolock)
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.ProviderClinicalFocusJSON is not null
    ) as x
    cross apply 
    (
        select *
        from openjson(x.ProviderClinicalFocusJSON) with
        (
            ClinicalFocusCode varchar(50) '$.ClinicalFocusCode',
            ProviderClinicalFocusRank  decimal(16,6) '$.ProviderClinicalFocusRank',
            ClinicalFocusDCPCount int '$.ClinicalFocusDCPCount',
            ProviderDCPCount int '$.ProviderDCPCount',
            IsProviderDCPCountOverLowThreshold bit '$.IsProviderDCPCountOverLowThreshold',
            ClinicalFocusMinBucketsCalculated int '$.ClinicalFocusMinBucketsCalculated',
            AverageBPercentile decimal(16,6) '$.AverageBPercentile',
            ProviderDCPFillPercent decimal(16,6) '$.ProviderDCPFillPercent',
            ClinicalFocusScore decimal(16,6) '$.ClinicalFocusScore',
            SourceCode varchar(50) '$.SourceCode',
            LastUpdateDate varchar(50) '$.LastUpdateDate'
        )
    ) as y
    inner join ODS1Stage.Base.Provider as p with (nolock) on p.ProviderCode = x.ProviderCode
    inner join ODS1Stage.Base.ClinicalFocus as cf with (nolock) on cf.ClinicalFocusCode = y.ClinicalFocusCode
    where y.ClinicalFocusCode is not null

    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderToClinicalFocus (child) records for all parents in the #swimlane
	    delete pc
	    --select *
	    from raw.ProviderProfileProcessingDeDup as pdd with (nolock)
        inner join ODS1Stage.Base.Provider as p with (nolock) on p.ProviderCode = pdd.ProviderCode
	    inner join ODS1Stage.Base.ProviderToClinicalFocus as pc on pc.ProviderID = p.ProviderID
	
	    --Insert all ProviderToClinicalFocus child records
	    insert into ODS1Stage.Base.ProviderToClinicalFocus (ProviderToClinicalFocusID, ProviderID, ClinicalFocusID, 
            ClinicalFocusDCPCount, ClinicalFocusMinBucketsCalculated, ProviderDCPCount, AverageBPercentile, 
            ProviderDCPFillPercent, IsProviderDCPCountOverLowThreshold, ClinicalFocusScore, ProviderClinicalFocusRank, 
            SourceCode, InsertedOn)
	    select newid(), s.ProviderID, s.ClinicalFocusID, 
            s.ClinicalFocusDCPCount, s.ClinicalFocusMinBucketsCalculated, s.ProviderDCPCount, s.AverageBPercentile, 
            s.ProviderDCPFillPercent, s.IsProviderDCPCountOverLowThreshold, s.ClinicalFocusScore, s.ProviderClinicalFocusRank, 
            isnull(s.SourceCode, 'Profisee') as SourceCode, isnull(s.LastUpdateDate, getutcdate()) as InsertedOn
	    from #swimlane as s
	    where s.RowRank = 1	
	end