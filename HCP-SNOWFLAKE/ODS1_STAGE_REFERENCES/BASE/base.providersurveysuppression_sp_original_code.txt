-- etl.spumergeprovidersurveysuppression

begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID,
        convert(uniqueidentifier, convert(varbinary(20), y.SurveySuppressionReasonCode)) as SurveySuppressionReasonID, y.SurveySuppressionReasonCode,
        y.DoSuppress, y.SourceCode, x.ProviderCode,
        dense_rank() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end) order by x.ReltioEntityID, x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString') as ProviderJSON
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.ProviderJSON is not null
    ) as x
    left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (DoSuppress bit '$.DoSuppress', 
            ProviderCode varchar(50) '$.ProviderCode', SourceCode varchar(25) '$.SourceCode', 
            SurveySuppressionReasonCode varchar(50) '$.SurveySuppressionCode')
    ) as y
    where /*isnull(y.DoSuppress, 0) = 0 and*/ y.SurveySuppressionReasonCode is not null
    
    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderSurveySuppression (child) records for all parents in the #swimlane
	    delete pc
        --select count(*)
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderSurveySuppression as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderSurveySuppression child records
	    insert into ODS1Stage.Base.ProviderSurveySuppression (ProviderSurveySuppressionID, ProviderID, SurveySuppressionReasonID, SourceCode)
	    select newid(), s.ProviderID, s.SurveySuppressionReasonID, isnull(s.SourceCode, 'Profisee')
	    from #swimlane as s
		join ODS1Stage.Base.Provider (nolock) p
		on s.ProviderID=p.ProviderID
		join ODS1Stage.Base.SurveySuppressionReason (nolock) ss
		on s.SurveySuppressionReasonID=ss.SurveySuppressionReasonID
	    where s.RowRank = 1 and isnull(s.DoSuppress, 0) = 0	
		and (s.ProviderID is not null and s.SurveySuppressionReasonID is not null)
	end