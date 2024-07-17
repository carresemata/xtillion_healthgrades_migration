-- etl.spumergeprovidercertificationspecialty
begin
    --00:03:58/121638
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct y.CertificationEffectiveDate, y.CertificationExpirationDate, y.CertificationSpecialtyRank, y.CertificationStatusDate, 
        case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
		x.ProviderCode,
        convert(uniqueidentifier, convert(varbinary(20), y.CertificationAgencyCode)) as CertificationAgencyID, y.CertificationAgencyCode,
        convert(uniqueidentifier, convert(varbinary(20), y.CertificationBoardCode)) as CertificationBoardID, y.CertificationBoardCode,
        convert(uniqueidentifier, convert(varbinary(20), y.CertificationSpecialtyCode)) as CertificationSpecialtyID, y.CertificationSpecialtyCode,
        isnull(convert(uniqueidentifier, convert(varbinary(20), y.CertificationStatusCode)),(select CertificationStatusID from ODS1Stage.Base.CertificationStatus where CertificationStatusCode = 'U')) as CertificationStatusID, y.CertificationStatusCode,
        convert(uniqueidentifier, convert(varbinary(20), y.MOCLevelCode)) as MOCLevelID, y.MOCLevelCode,
        convert(uniqueidentifier, convert(varbinary(20), y.MOCPathwayCode)) as MOCPathwayID, y.MOCPathwayCode,
        y.DoSuppress, y.IsSearchable, y.SourceCode, y.LastUpdateDate, y.CertificationAgencyVerified,
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.CertificationAgencyCode, y.CertificationBoardCode, y.CertificationSpecialtyCode order by y.CertificationEffectiveDate desc, y.CertificationExpirationDate desc, case when y.CertificationStatusCode = 'C' then 1 else 9 end, x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.CertificationSpecialty') as ProviderJSON
            from raw.ProviderProfileProcessing d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null 
        ) as w
        where w.ProviderJSON is not null
    ) as x
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (CertificationAgencyCode varchar(50) '$.CertificationAgencyCode', 
            CertificationBoardCode varchar(50) '$.CertificationBoardCode', CertificationEffectiveDate datetime '$.CertificationEffectiveDate', 
            CertificationExpirationDate datetime '$.CertificationExpirationDate', CertificationSpecialtyCode varchar(50) '$.CertificationSpecialtyCode', 
            CertificationSpecialtyRank int '$.CertificationSpecialtyRank', CertificationStatusCode varchar(50) '$.CertificationStatusCode', 
            CertificationStatusDate datetime '$.CertificationStatusDate', DoSuppress bit '$.DoSuppress', IsSearchable bit '$.IsSearchable', 
            MOCType varchar(50) '$.MOCType', MOCLevelCode varchar(50) '$.MOCLevelCode', MOCPathwayCode varchar(50) '$.MOCPathwayID', 
            SourceCode varchar(50) '$.SourceCode', LastUpdateDate datetime '$.LastUpdateDate', CertificationAgencyVerified BIT '$.CertificationAgencyVerified')
    ) as y
    left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
    where y.CertificationSpecialtyCode is not null and y.CertificationBoardCode is not null and y.CertificationAgencyCode is not null


    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderToCertificationSpecialty (child) records for all parents in the #swimlane
	    delete pc
	    --select *
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
	    inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderToCertificationSpecialty as pc on pc.ProviderID = p2.ProviderID

	    --Insert all ProviderToCertificationSpecialty child records
	    insert into ODS1Stage.Base.ProviderToCertificationSpecialty (ProviderToCertificationSpecialtyID, ProviderID, CertificationSpecialtyID, SourceCode, LastUpdateDate, CertificationBoardID, CertificationAgencyID, CertificationSpecialtyRank, CertificationStatusID, CertificationStatusDate, CertificationEffectiveDate, CertificationExpirationDate, IsSearchable, CertificationAgencyVerified, MOCPathwayID, MOCLevelID)
	    select newid(), s.ProviderID, s.CertificationSpecialtyID, isnull(s.SourceCode, 'Profisee'), isnull(s.LastUpdateDate, getutcdate()), s.CertificationBoardID, s.CertificationAgencyID, 
	        s.CertificationSpecialtyRank, cst.CertificationStatusID, s.CertificationStatusDate, s.CertificationEffectiveDate, s.CertificationExpirationDate, 
	        s.IsSearchable, s.CertificationAgencyVerified, null, null --, s.MOCPathwayID, s.MOCLevelID
	    from #swimlane as s
	    inner join ODS1Stage.Base.CertificationBoard as cb on cb.CertificationBoardID = s.CertificationBoardID
	    inner join ODS1Stage.Base.CertificationSpecialty as cs on cs.CertificationSpecialtyID = s.CertificationSpecialtyID
	    inner join ODS1Stage.Base.CertificationAgency as ca on ca.CertificationAgencyID = s.CertificationAgencyID
	    inner join ODS1Stage.Base.CertificationStatus as cst on cst.CertificationStatusID = s.CertificationStatusID
	    where s.RowRank = 1	
		    and (s.ProviderID is not null and s.CertificationSpecialtyID is not null and s.CertificationBoardID is not null and s.CertificationAgencyID is not null)
	end