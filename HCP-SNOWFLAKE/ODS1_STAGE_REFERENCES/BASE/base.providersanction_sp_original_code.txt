-- etl.spumergeprovidersanction
begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
		x.ProviderCode,
        convert(uniqueidentifier, convert(varbinary(20), y.SanctionActionCode)) as SanctionActionID, y.SanctionActionCode, 
        convert(uniqueidentifier, convert(varbinary(20), y.SanctionCategoryCode)) as SanctionCategoryID, y.SanctionCategoryCode,
        convert(uniqueidentifier, convert(varbinary(20), y.SanctionTypeCode)) as SanctionTypeID, y.SanctionTypeCode,
		convert(uniqueidentifier, convert(varbinary(20), y.StateReportingAgencyCode)) as StateReportingAgencyID, y.StateReportingAgencyCode,
        y.DoSuppress, y.LastUpdateDate, y.SanctionDate, y.SanctionDescription, y.SanctionLicense, 
        y.SanctionReinstatementDate, y.SanctionAccuracyDate, y.SourceCode, 
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.SanctionDate, y.SanctionActionCode, y.SanctionCategoryCode, y.SanctionTypeCode, y.StateReportingAgencyCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Sanction') as ProviderJSON
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.ProviderJSON is not null
    ) as x
    left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
    cross apply 
    (
        select *, try_convert(date, sSanctionDate) as SanctionDate, 
            try_convert(date, sSanctionActionDate) as SanctionActionDate, 
            try_convert(date, sSanctionReinstatementDate) as SanctionReinstatementDate,
			try_convert(date, sSanctionAccuracyDate) as SanctionAccuracyDate
        from openjson(x.ProviderJSON) 
            with (DoSuppress bit '$.DoSuppress', LastUpdateDate datetime '$.LastUpdateDate', 
            SanctionActionCode varchar(50) '$.ActionCode', 
            SanctionActionTypeCode varchar(50) '$.ActionTypeCode', SanctionActionDescription varchar(250) '$.ActionDescription',
            SanctionBoardCode varchar(50) '$.BoardCode', SanctionBoardDescription varchar(50) '$.BoardDescription', 
            SanctionCategoryCode varchar(50) '$.CategoryCode',
            sSanctionDate varchar(100) '$.SanctionDate', 
            sSanctionActionDate varchar(100) '$.ActionDate', 
            sSanctionReinstatementDate varchar(100) '$.SanctionReinstatementDate', 
            SanctionDescription varchar(max) '$.SanctionDescription', 
            SanctionLicense varchar(255) '$.SanctionLicense', 
			SanctionTypeCode varchar(50) '$.TypeCode', 
			StateReportingAgencyCode varchar(50) '$.StateReportingAgencyCode', 
			sSanctionAccuracyDate varchar(100) '$.SanctionAccuracyDate', 
            SourceCode varchar(25) '$.SourceCode')
    ) as y

    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderSanction (child) records for all parents in the #swimlane
	    delete pc
	    --select *
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderSanction as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderSanction child records
	    insert into ODS1Stage.Base.ProviderSanction (ProviderSanctionID, ProviderID, SanctionLicense, StateReportingAgencyID, SanctionTypeID, SanctionCategoryID, SanctionActionID, SanctionDescription, SanctionDate, SanctionReinstatementDate, SanctionAccuracyDate, SourceCode, LastUpdateDate)
	    select newid(), s.ProviderID, s.SanctionLicense, s.StateReportingAgencyID, s.SanctionTypeID, s.SanctionCategoryID, s.SanctionActionID, s.SanctionDescription, s.SanctionDate, s.SanctionReinstatementDate, s.SanctionAccuracyDate, isnull(s.SourceCode, 'Profisee'), isnull(s.LastUpdateDate, getdate())
	    from #swimlane as s
	    where s.RowRank = 1	
		and (s.ProviderID is not null and s.SanctionDate is not null and s.SanctionCategoryID is not NULL and s.StateReportingAgencyID is not null)
	end