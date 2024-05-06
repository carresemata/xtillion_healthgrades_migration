-- etl.spumergepractice

begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select x.PracticeID, x.PracticeCode,
        x.ReltioEntityID, y.DoSuppress, y.LastUpdateDate, y.NPI, y.PracticeDescription,  
        y.PracticeLogo, y.PracticeMedicalDirector, y.PracticeName, y.PracticeSoftware, y.PracticeTIN, 
        y.SourceCode, y.YearPracticeEstablished,
        ROW_NUMBER() OVER(partition by x.PracticeCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    --select *
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PRACTICE_CODE as PracticeCode, p.PracticeID,
                json_query(p.PAYLOAD, '$.EntityJSONString')  as PracticeJSON
            from raw.PracticeProfileProcessingDeDup as d with (nolock)
            inner join raw.PracticeProfileProcessing as p with (nolock) on p.rawPracticeProfileID = d.rawPracticeProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.PracticeJSON is not null
    ) as x
    cross apply 
    (
        select *
        from openjson(x.PracticeJSON) with (DoSuppress bit '$.DoSuppress', LastUpdateDate datetime '$.LastUpdateDate', 
            NPI varchar(10) '$.NPI', PracticeCode varchar(50) '$.PracticeCode', PracticeDescription varchar(1000) '$.Description', 
            PracticeLogo varchar(150) '$.Logo', 
            PracticeMedicalDirector varchar(150) '$.MedicalDirector', PracticeName varchar(200) '$.PracticeName', 
            PracticeSoftware varchar(50) '$.EMR', PracticeTIN char(9) '$.PracticeTIN', 
            --PracticeWebsite varchar(512) '$.WebsiteURL', -- no longer sent to the web 1/17/24, PDT-2346
            SourceCode varchar(25) '$.SourceCode', 
            YearPracticeEstablished int '$.EstablishedYear')
    ) as y
    where isnull(y.DoSuppress, 0) = 0 
    
    if @OutputDestination = 'ODS1Stage' begin
		update #swimlane
		set PracticeName = replace(PracticeName,'&amp;','&')
		where PracticeName like '%&amp;%'
		
		update	#swimlane
		set		PracticeLogo = null
		where	PracticeLogo = 'None'

		--UPDATE	#swimlane
		--SET		PracticeWebsite = NULL
		--WHERE	PracticeWebsite = 'None'

		update	#swimlane
		set		PracticeMedicalDirector = null
		where	PracticeMedicalDirector = 'None'


	    update pr 
		set pr.LastUpdateDate = s.LastUpdateDate, 
            pr.NPI = s.NPI, 
            pr.PracticeCode = s.PracticeCode, 
	        pr.PracticeDescription = s.PracticeDescription,  
	        pr.PracticeLogo = s.PracticeLogo, 
            pr.PracticeMedicalDirector = s.PracticeMedicalDirector, 
            pr.PracticeName = isnull(s.PracticeName,''),
	        pr.PracticeSoftware = s.PracticeSoftware, 
            pr.PracticeTIN = s.PracticeTIN, 
	        pr.SourceCode = s.SourceCode, --pr.PracticeWebsite = s.PracticeWebsite, 
	        pr.YearPracticeEstablished = s.YearPracticeEstablished
		--select s.*
	    from #swimlane as s
	    inner join ODS1Stage.Base.Practice as pr on pr.PracticeCode = s.PracticeCode
	    where s.RowRank = 1
			and 
			(
				isnull(pr.NPI, '') != isnull(s.NPI, '')
				or isnull(pr.PracticeCode, '') != isnull(s.PracticeCode, '')
				or isnull(pr.PracticeDescription, '') != isnull(s.PracticeDescription, '')
				or isnull(pr.PracticeLogo, '') != isnull(s.PracticeLogo, '')
				or isnull(pr.PracticeMedicalDirector, '') != isnull(s.PracticeMedicalDirector, '')
				or isnull(pr.PracticeName, '') != isnull(s.PracticeName,'')
				or isnull(pr.PracticeSoftware, '') != isnull(s.PracticeSoftware, '')
				or isnull(pr.PracticeTIN, '') != isnull(s.PracticeTIN, '')
				--or isnull(pr.PracticeWebsite, '') != isnull(s.PracticeWebsite, '')
			)
	


	    insert into ODS1Stage.Base.Practice (PracticeID, LastUpdateDate, NPI, PracticeCode, PracticeDescription, 
	        PracticeLogo, PracticeMedicalDirector, PracticeName, PracticeSoftware, PracticeTIN, 
	        SourceCode, YearPracticeEstablished, ReltioEntityID)
	    select distinct s.PracticeID, isnull(s.LastUpdateDate, getutcdate()), s.NPI, s.PracticeCode, s.PracticeDescription, 
	        s.PracticeLogo, s.PracticeMedicalDirector, isnull(s.PracticeName,'') as PracticeName, s.PracticeSoftware, s.PracticeTIN, 
	        isnull(s.SourceCode, 'Profisee'), s.YearPracticeEstablished, s.ReltioEntityID
	    from #swimlane as s
	    where not exists (select 1 from ODS1Stage.Base.Practice as pr where pr.PracticeCode = s.PracticeCode)
	        and s.RowRank = 1
			and s.PracticeCode is not null 
            and s.PracticeName is not null
            and len(s.PracticeCode) <= 10