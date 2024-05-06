-- etl.spumergeprovidereducationinstitution
begin
	if object_id('tempdb..#tmp_Education') is not null drop table #tmp_Education
    create table #tmp_Education (rawProviderProfileID int primary key)

    --00:45:51 / 1,515,686
	insert into #tmp_Education (rawProviderProfileID)
    select d.rawProviderProfileID
    from raw.ProviderProfileProcessingDeDup as d with (nolock)
    inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
    --where isnull(p.HasEducation,0) = 1
    where p.PAYLOAD like ('%"Education%')
    order by rawProviderProfileID

	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
		x.ProviderCode, r1.EducationInstitutionID, y.EducationInstitutionCode, r2.EducationInstitutionTypeID, y.EducationRelationshipTypeCode,
        y.DoSuppress, trim(y.GraduationYear) as GraduationYear, y.LastUpdateDate, y.SourceCode, x.ProviderJSON
    into #swimlane
    from
        (
            select w.* 
            from
            (
                select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                    json_query(p.PAYLOAD, '$.EntityJSONString.EducationMedSch') as ProviderJSON
                from #tmp_Education t
                inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = t.rawProviderProfileID
                union all
                select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                    json_query(p.PAYLOAD, '$.EntityJSONString.EducationFellow') as ProviderJSON
                from #tmp_Education t
                inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = t.rawProviderProfileID
                union all
                select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                    json_query(p.PAYLOAD, '$.EntityJSONString.EducationIntern') as ProviderJSON
                from #tmp_Education t
                inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = t.rawProviderProfileID
                union all
                select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                    json_query(p.PAYLOAD, '$.EntityJSONString.EducationReside') as ProviderJSON
                from #tmp_Education t
                inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = t.rawProviderProfileID
                union all
                select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                    json_query(p.PAYLOAD, '$.EntityJSONString.EducationPracTeach') as ProviderJSON
                from #tmp_Education t
                inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = t.rawProviderProfileID
                union all
                select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                    json_query(p.PAYLOAD, '$.EntityJSONString.EducationEduTra') as ProviderJSON
                from #tmp_Education t
                inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = t.rawProviderProfileID
                union all
                select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                    json_query(p.PAYLOAD, '$.EntityJSONString.EducationUndUni') as ProviderJSON
                from #tmp_Education t
                inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = t.rawProviderProfileID
            ) as w
            where w.ProviderJSON is not null
        ) as x
        cross apply
        (
            select *
            from openjson(x.ProviderJSON) with (
                DegreeCode varchar(50) '$.Degree'
                ,DoSuppress bit '$.DoSuppress'
                ,EducationInstitutionCode varchar(50) '$.InstitutionCode'
                ,EducationRelationshipTypeCode varchar(50) '$.Type'
                ,GraduationYear char(4) '$.YearOfGraduation'
                ,LastUpdateDate datetime '$.LastUpdateDate'
                ,SourceCode varchar(25) '$.SourceCode')
        ) as y
        inner join ods1Stage.base.EducationInstitution r1 on r1.EducationInstitutionCode = y.EducationInstitutionCode
        inner join ods1stage.base.EducationInstitutionType r2 on r2.EducationInstitutionTypeCode = y.EducationRelationshipTypeCode
        left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode


	if @OutputDestination = 'ODS1Stage' begin
	   --Delete all ProviderToEducationInstitution (child) records for all parents in the #swimlane
	    delete pc
	    --select *
        --select count(*)
	    from raw.ProviderProfileProcessingDeDup as p with (nolock)
        inner join ODS1Stage.Base.Provider as p2 on p2.ProviderCode = p.ProviderCode
	    inner join ODS1Stage.Base.ProviderToEducationInstitution as pc on pc.ProviderID = p2.ProviderID

	    --Insert all ProviderToEducationInstitution child records
	    insert into ODS1Stage.Base.ProviderToEducationInstitution (ProviderToEducationInstitutionID, ProviderID, EducationInstitutionID,
	        EducationInstitutionTypeID, GraduationYear, SourceCode, LastUpdateDate)
	    select newid(), s.ProviderID, s.EducationInstitutionID, s.EducationInstitutionTypeID, s.GraduationYear,
	        isnull(s.SourceCode, 'Profisee'), isnull(s.LastUpdateDate, getutcdate())
	    from #swimlane as s
		inner join ODS1Stage.Base.Provider p on s.ProviderID=p.ProviderID
		inner join ODS1Stage.Base.EducationInstitution ed on s.EducationInstitutionID=ed.EducationInstitutionID
		and (s.ProviderID is not null and s.EducationInstitutionID is not null and EducationInstitutionTypeID is not null)
	end