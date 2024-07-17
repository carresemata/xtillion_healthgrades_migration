begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct x.OfficeID,
        convert(uniqueidentifier, convert(varbinary(20), upper(y.DaysOfWeekCode))) as DaysOfWeekID, y.DaysOfWeekCode,
        y.DoSuppress, y.LastUpdateDate, y.OfficeHoursClosingTime, y.OfficeHoursOpeningTime, 
        case when y.OfficeIsClosed is null and  y.OfficeHoursOpeningTime is not null then 0 when y.OfficeIsClosed is null then 1 else y.OfficeIsClosed end as OfficeIsClosed, 
		isnull(y.OfficeIsOpen24Hours, 0) as OfficeIsOpen24Hours, y.SourceCode, x.OfficeCode,
		row_number() over(partition by x.OfficeID, y.DaysOfWeekCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.OFFICE_CODE as OfficeCode, p.OfficeID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.OfficeHours')  as OfficeJSON
            from raw.OfficeProfileProcessingDeDup as d with (nolock)
            inner join raw.OfficeProfileProcessing as p with (nolock) on p.rawOfficeProfileID = d.rawOfficeProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.OfficeJSON is not null
    ) as x
    cross apply 
    (
        select *
        from openjson(x.OfficeJSON) with (
			DaysOfWeekCode varchar(50) '$.DaysOfWeekCode'
			,DoSuppress bit '$.DoSuppress'
            ,LastUpdateDate varchar(80) '$.LastUpdateDate'
			,OfficeCode varchar(50) '$.OfficeCode'
			,OfficeHoursOpeningTime varchar(80) '$.OpeningTime'
			,OfficeHoursClosingTime varchar(80) '$.ClosingTime'
			,OfficeIsClosed bit '$.OfficeIsClosed'
            ,OfficeIsOpen24Hours bit '$.Open24Hours'
			,SourceCode varchar(80) '$.SourceCode'
		)
    ) as y
    where isnull(y.DoSuppress, 0) = 0
	
	update	#swimlane
	set		OfficeHoursOpeningTime = null
	where	OfficeHoursOpeningTime = 'None'

	update	#swimlane
	set		OfficeHoursClosingTime = null
	where	OfficeHoursClosingTime = 'None'
	
	alter table #swimlane
	alter column OfficeHoursOpeningTime time
	alter table #swimlane
	alter column OfficeHoursClosingTime time

	if @OutputDestination = 'ODS1Stage' begin

		if object_id('tempdb..#ChangedOfficeHours') is not null drop table #ChangedOfficeHours 
		create table #ChangedOfficeHours (OfficeID uniqueidentifier not null)

		--Delete all OfficeHours who no longer have OfficeHours at all 
		--We need to output these offices into #ChangedOfficeHours because they won't be upserted later
		delete oh
		--select oh.*
		output deleted.OfficeID into #ChangedOfficeHours(OfficeID)
		from raw.OfficeProfileProcessingDeDup as p with (nolock)
		inner join ODS1Stage.Base.OfficeHours as oh on oh.OfficeID = p.OfficeID
		where not exists (select 1 from #swimlane as s where s.OfficeID = oh.OfficeID)

		if object_id('tempdb..#DeleteOfficeHours') is not null drop table #DeleteOfficeHours
		create table #DeleteOfficeHours (OfficeID uniqueidentifier not null)
		
		--Delete OfficeHours whose DaysOfWeekID changed (case 1. has new DaysOfWeekID)  
		insert into #DeleteOfficeHours(OfficeID)
		select distinct o.OfficeID
		--select *
		from #swimlane as s
		inner join ODS1Stage.Base.Office as o on o.OfficeID = s.OfficeID
		inner join ODS1Stage.Base.DaysOfWeek as dw on dw.DaysOfWeekCode = s.DaysOfWeekCode
		where not exists (select 1 from ODS1Stage.base.OfficeHours as oh where oh.OfficeID = o.OfficeID and oh.DaysOfWeekID = dw.DaysOfWeekID)
		 
		--Delete OfficeHours whose DaysOfWeekID changed (case 2. no longer have the old DaysOfWeekID) 
		insert into #DeleteOfficeHours(OfficeID)
		select distinct oh.OfficeID
		from #swimlane as s
		inner join ODS1Stage.Base.Office as o on o.OfficeID = s.OfficeID 
		inner join ods1stage.Base.OfficeHours as oh on oh.OfficeID = o.OfficeID 
		where not exists
			(
				select 1 
				--select oh2.officeID, oh2.DaysofWeekID
				from #swimlane as s2 
				inner join ODS1Stage.Base.Office as o2 on o2.OfficeID = s2.OfficeID
				inner join ODS1Stage.Base.DaysOfWeek as dw on dw.DaysOfWeekCode = s2.DaysOfWeekCode
				inner join ods1stage.Base.OfficeHours as oh2 on oh2.OfficeID = s2.OfficeID and oh2.DaysOfWeekID = dw.DaysOfWeekID
				where oh2.OfficeID = oh.OfficeID and oh2.DaysOfWeekID = oh.DaysOfWeekID
			)
			and not exists (select 1 from #DeleteOfficeHours as t where t.OfficeID = oh.OfficeID)
		
		delete oh
		--select oh.*
		from ODS1Stage.base.OfficeHours as oh
		where oh.OfficeID in (select OfficeID from #DeleteOfficeHours)

		--Update OfficeHours whose DaysOfWeekID remained same
		update oh set oh.SourceCode = isnull(s.SourceCode, 'Profisee'), oh.OfficeHoursOpeningTime = s.OfficeHoursOpeningTime, oh.OfficeHoursClosingTime = s.OfficeHoursClosingTime, 
			oh.OfficeIsClosed = s.OfficeIsClosed, oh.OfficeIsOpen24Hours = s.OfficeIsOpen24Hours, oh.LastUpdateDate = s.LastUpdateDate
		--select oh.SourceCode, isnull(s.SourceCode, 'Profisee'), oh.OfficeHoursOpeningTime, s.OfficeHoursOpeningTime, oh.OfficeHoursClosingTime, s.OfficeHoursClosingTime, oh.OfficeIsClosed, s.OfficeIsClosed, oh.OfficeIsOpen24Hours, s.OfficeIsOpen24Hours, oh.LastUpdateDate, s.LastUpdateDate
		output inserted.OfficeID into #ChangedOfficeHours(OfficeID)
		from #swimlane as s
		inner join ODS1Stage.Base.Office as o on o.OfficeID = s.OfficeID
		inner join ODS1Stage.Base.DaysOfWeek as dw on dw.DaysOfWeekCode = s.DaysOfWeekCode
		inner join ODS1Stage.base.OfficeHours as oh on oh.OfficeID = o.OfficeID and oh.DaysOfWeekID = dw.DaysOfWeekID
		where (s.OfficeID is not null and s.DaysOfWeekID is not null and s.OfficeIsClosed is not null and s.OfficeIsOpen24Hours is not null and s.RowRank = 1)
			and (
				isnull(oh.SourceCode, 'Profisee') != isnull(s.SourceCode, 'Profisee')
				or isnull(oh.OfficeHoursOpeningTime, '08:00:00.0000000') != isnull(s.OfficeHoursOpeningTime, '08:00:00.0000000')
				or isnull(oh.OfficeHoursClosingTime, '17:00:00.0000000') != isnull(s.OfficeHoursClosingTime, '17:00:00.0000000')
				or isnull(oh.OfficeIsClosed, 1) != isnull(s.OfficeIsClosed, 1)
				or isnull(oh.OfficeIsOpen24Hours, 0) != isnull(s.OfficeIsOpen24Hours, 0)
			)

		--Insert new records
		insert into ODS1Stage.Base.OfficeHours (OfficeHoursID, OfficeID, SourceCode, DaysOfWeekID, OfficeHoursOpeningTime, OfficeHoursClosingTime, 
			OfficeIsClosed, OfficeIsOpen24Hours, LastUpdateDate)
		output inserted.OfficeID into #ChangedOfficeHours(OfficeID)
		select distinct newid(), s.OfficeID, isnull(s.SourceCode, 'Profisee'), dw.DaysOfWeekID, s.OfficeHoursOpeningTime, s.OfficeHoursClosingTime, 
			s.OfficeIsClosed, s.OfficeIsOpen24Hours, isnull(s.LastUpdateDate, getutcdate())
		-- select count(*)
		-- select distinct newid(), s.OfficeID, isnull(s.SourceCode, 'Profisee'), dw.DaysOfWeekID, s.OfficeHoursOpeningTime, s.OfficeHoursClosingTime, s.OfficeIsClosed, s.OfficeIsOpen24Hours, isnull(s.LastUpdateDate, getutcdate())
		from #swimlane as s	
		inner join ODS1Stage.Base.Office as o on o.OfficeID = s.OfficeID
		inner join ODS1Stage.Base.DaysOfWeek as dw on dw.DaysOfWeekCode = s.DaysOfWeekCode
		left join ODS1Stage.Base.OfficeHours as oh on oh.OfficeID = o.OfficeID and oh.DaysOfWeekID = dw.DaysOfWeekID
		where s.OfficeID is not null and s.DaysOfWeekID is not null and s.OfficeIsClosed is not null and s.OfficeIsOpen24Hours is not null and s.RowRank = 1
			and oh.OfficeID is null