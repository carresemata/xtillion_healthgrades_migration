-- etl.spumergeproviderlicense
begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
        x.ProviderCode,
        convert(uniqueidentifier, convert(varbinary(20), y.State)) as StateID, y.State,
        y.DoSuppress, y.LastUpdateDate, y.LicenseNumber,
        y.LicenseTerminationDate, y.LicenseType, y.SourceCode, y.Status,
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.State, y.LicenseNumber, y.LicenseType order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.License') as ProviderJSON
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
        from openjson(x.ProviderJSON) with (DoSuppress bit '$.DoSuppress', LastUpdateDate datetime '$.LastUpdateDate', 
            LicenseNumber varchar(50) '$.Number', 
            LicenseTerminationDate date '$.ExpirationDate', LicenseType varchar(255) '$.Type', 
            State varchar(50) '$.State', SourceCode varchar(50) '$.SourceCode',
            Status varchar(50) '$.Status')
    ) as y
	where (isnull(y.LicenseTerminationDate, getdate()) >= dateadd(day, -90, getdate())
		or not (y.Status = 'Inactive' and y.LicenseTerminationDate is null))

	if @OutputDestination = 'ODS1Stage' begin
        delete pc
        --select *
        from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as pID on pID.ProviderCode = p.ProviderCode
        inner join ODS1Stage.Base.ProviderLicense as pc on pc.ProviderID = pID.ProviderID
	    left join ODS1Stage.Base.ProviderMalpractice M ON M.ProviderLicenseID = PC.ProviderLicenseID
	    WHERE		M.ProviderMalpracticeID IS NULL

	    --Insert all ProviderLicense child records
	    insert into ODS1Stage.Base.ProviderLicense (ProviderLicenseID, ProviderID, StateID, LicenseNumber, LicenseTerminationDate, 
	        SourceCode, LastUpdateDate, LicenseType)
	    select newid(), s.ProviderID, s.StateID, s.LicenseNumber, s.LicenseTerminationDate, 
	        isnull(s.SourceCode, 'Profisee'), isnull(s.LastUpdateDate, getdate()), s.LicenseType
	    from #swimlane as s
	    where s.RowRank = 1
		    and (s.ProviderID is not null and s.LicenseNumber is not null and s.StateID is not null)
            and not exists 
            (
                select 1 
                from ODS1Stage.Base.ProviderLicense as pl2 
                where pl2.ProviderID = s.ProviderID 
                    and isnull(pl2.StateID,'00000000-0000-0000-0000-000000000000') = isnull(s.StateID,'00000000-0000-0000-0000-000000000000') 
                    and isnull(pl2.LicenseNumber,'') = isnull(s.LicenseNumber,'') 
                    and isnull(pl2.LicenseTerminationDate,getdate()) =  isnull(s.LicenseTerminationDate,getdate())
                    and isnull(pl2.LicenseType,'') = isnull(s.LicenseType,'') 
            )
	end