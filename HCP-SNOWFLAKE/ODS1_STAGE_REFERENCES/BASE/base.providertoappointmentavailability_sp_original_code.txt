-- etl.spumergeproviderappointmentavailability
begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
        x.ProviderCode,
        convert(uniqueidentifier, convert(varbinary(20), y.AppointmentAvailabilityCode)) as AppointmentAvailabilityID, y.AppointmentAvailabilityCode,
        y.DoSuppress, y.LastUpdateDate, y.SourceCode, 
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.AppointmentAvailabilityCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, json_query(p.PAYLOAD, '$.EntityJSONString.AppointmentAvailability') as ProviderJSON
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PROVIDER_CODE is not null
        ) as w
        where w.ProviderJSON is not null
    ) as x
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (AppointmentAvailabilityCode varchar(50) '$.AppointmentAvailabilityCode', 
            DoSuppress bit '$.DoSuppress', LastUpdateDate datetime '$.LastUpdateDate', 
            SourceCode varchar(25) '$.SourceCode')
    ) as y
    left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
    where y.AppointmentAvailabilityCode is not null
    
    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderToAppointmentAvailability (child) records for all parents in the #swimlane
	    delete pc
	    --select *
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
	    inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
        inner join ODS1Stage.Base.ProviderToAppointmentAvailability as pc on pc.ProviderID = p2.ProviderID

	    --Insert all ProviderToAppointmentAvailability child records
	    insert into ODS1Stage.Base.ProviderToAppointmentAvailability (ProviderToAppointmentAvailabilityID, ProviderID, AppointmentAvailabilityID, SourceCode, LastUpdatedDate)
	    select newid(), s.ProviderID, s.AppointmentAvailabilityID, isnull(s.SourceCode, 'Profisee'), isnull(s.LastUpdateDate, getutcdate())
	    from #swimlane as s
	    where s.RowRank = 1
		and (s.ProviderID is not null and s.AppointmentAvailabilityID is not null)
	end