-- etl.spumergeproviderspecialty
begin
	if object_id('tempdb..#swimLane') is not null drop table #swimLane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
		x.ProviderCode,
        convert(uniqueidentifier, convert(varbinary(20), y.SpecialtyCode)) as SpecialtyID, y.DoSuppress,
        y.IsSearchable, y.IsSearchableCalculated, y.SourceCode, y.LastUpdateDate, y.SpecialtyIsRedundant, y.SpecialtyRank, y.SpecialtyRankCalculated, y.SpecialtyCode,
        y.SpecialtyDCPCount, y.SpecialtyDCPMinFillThreshold, y.ProviderSpecialtyDCPCount, y.ProviderSpecialtyAveragePercentile, y.MeetsLowThreshold, y.ProviderRawSpecialtyScore, y.ScaledSpecialtyBoost,
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.SpecialtyCode order by y.SpecialtyRankCalculated, x.CREATE_DATE desc) as RowRank
    into #swimlane
    from(
        select w.* 
        from(
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Specialty') as ProviderJSON
            --from raw.ProviderProfile_HMSCLAIMS_Test as p
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
        from openjson(x.ProviderJSON) with (
			DoSuppress bit '$.DoSuppress',
            IsSearchable bit '$.IsSearchable',
            IsSearchableCalculated bit '$.IsSearchableCalculated',
            SourceCode varchar(50) '$.SourceCode',
	        LastUpdateDate datetime '$.LastUpdateDate',
			SpecialtyCode varchar(50) '$.SpecialtyCode',
            SpecialtyIsRedundant bit '$.SpecialtyIsRedundant',
            SpecialtyRank int '$.Rank',
			SpecialtyRankCalculated int '$.CalculatedRank',
            SpecialtyDCPCount int '$.SpecialtyDCPCount',
            SpecialtyDCPMinFillThreshold int '$.SpecialtyDCPMinFillThreshold',
            ProviderSpecialtyDCPCount int '$.ProviderSpecialtyDCPCount',
            ProviderSpecialtyAveragePercentile int '$.ProviderSpecialtyAveragePercentile',
            MeetsLowThreshold bit '$.MeetsLowThreshold',
            ProviderRawSpecialtyScore decimal(16,8) '$.ProviderRawSpecialtyScore',
            ScaledSpecialtyBoost decimal(24,12) '$.ScaledSpecialtyBoost'
		)
    ) as y
    where isnull(y.DoSuppress, 0) = 0 and y.SpecialtyCode is not null

    if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderToSpecialty (child) records for all parents in the #swimlane
	    delete pc
		--select *
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderToSpecialty as pc on pc.ProviderID = p2.ProviderID
	
	    --Insert all ProviderToSpecialty child records
	    insert into ODS1Stage.Base.ProviderToSpecialty (ProviderToSpecialtyID, ProviderID, SpecialtyID, SourceCode, LastUpdateDate, SpecialtyRank, SpecialtyRankCalculated, IsSearchable, IsSearchableCalculated, SpecialtyIsRedundant,
                    SpecialtyDCPCount, SpecialtyDCPMinFillThreshold, ProviderSpecialtyDCPCount, ProviderSpecialtyAveragePercentile, MeetsLowThreshold, ProviderRawSpecialtyScore, ScaledSpecialtyBoost)
	    select		newid()
					,s.ProviderID
					,s.SpecialtyID
					,isnull(s.SourceCode, 'Profisee') as SourceCode
					,isnull(s.LastUpdateDate, getutcdate())
					,s.SpecialtyRank
					,isnull(s.SpecialtyRankCalculated,((2147483647))) as SpecialtyRankCalculated
					,s.IsSearchable
					,isnull(s.IsSearchableCalculated, ((1))) as IsSearchableCalculated
					,isnull(s.SpecialtyIsRedundant, ((0))) as SpecialtyIsRedundant
                    ,s.SpecialtyDCPCount
                    ,s.SpecialtyDCPMinFillThreshold 
                    ,s.ProviderSpecialtyDCPCount 
                    ,s.ProviderSpecialtyAveragePercentile 
                    ,s.MeetsLowThreshold 
                    ,s.ProviderRawSpecialtyScore 
                    ,s.ScaledSpecialtyBoost
	    from		#swimlane as s
		inner join	ODS1Stage.Base.Specialty dS
					on dS.SpecialtyID = s.SpecialtyID
	    where		s.RowRank = 1	
					and s.ProviderID is not null
					and s.SpecialtyID is not null