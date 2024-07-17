-- etl.spumergeproviderfacility
begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
        select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
        x.ProviderCode,
        convert(uniqueidentifier, convert(varbinary(20), y.FacilityCode)) as FacilityID, y.FacilityCode,
        convert(uniqueidentifier, convert(varbinary(20), y.HonorRollTypeCode)) as HonorRollTypeID, y.HonorRollTypeCode,
        convert(uniqueidentifier, convert(varbinary(20), y.ProviderRoleCode)) as ProviderRoleID, y.ProviderRoleCode,
        y.DoSuppress, y.LastUpdateDate, y.SourceCode,
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.FacilityCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Facility') as ProviderJSON
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.ProviderJSON is not null
    ) as x
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (DoSuppress bit '$.DoSuppress', FacilityCode varchar(50) '$.FacilityCode', 
            FacilityReltioEntityID varchar(50) '$.ReltioEntityID', 
            HonorRollTypeCode varchar(50) '$.HonorRollTypeCode', LastUpdateDate datetime '$.LastUpdateDate', 
            ProviderRoleCode varchar(50) '$.ProviderRoleCode', SourceCode varchar(25) '$.SourceCode')
    ) as y
    left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
    where y.FacilityCode is not null 
    
    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderToFacility (child) records for all parents in the #swimlane
	    delete pc
	    --select *
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderToFacility as pc on pc.ProviderID = p2.ProviderID
	    
	    --Insert all ProviderToFacility child records
	    insert into ODS1Stage.Base.ProviderToFacility (ProviderToFacilityID, ProviderID, FacilityID, ProviderRoleID, HonorRollTypeID, SourceCode, LastUpdateDate)
	    select newid(), s.ProviderID, f.FacilityID, s.ProviderRoleID, s.HonorRollTypeID, isnull(s.SourceCode, 'Profisee'), isnull(s.LastUpdateDate, getutcdate())
	    from #swimlane as s
	    --EGS 3/18/19: Facilities are mastered outside of Reltio in SQL Server
	    -- When Reltio is used to master Facility, then we will remove this join and calculate FacilityID from ReltioEntityID
	    inner join ODS1Stage.Base.Facility as f with (nolock) on f.FacilityCode = s.FacilityCode  
	    where s.RowRank = 1	
		and (s.ProviderID is not null and s.FacilityID is not null)
	end