-- etl.spumergeoffice
begin
    select distinct y.AverageDailyPatientVolume, x.ReltioEntityID,
        x.OfficeID,
        convert(uniqueidentifier, convert(varbinary(20), z.PracticeCode)) as PracticeID, z.PracticeCode,
        convert(uniqueidentifier, convert(varbinary(20), y.SourceCode)) as SourceID, 
        y.DoSuppress, y.HasBillingStaff, y.HasChildPlayground, y.HasHandicapAccess, 
        y.HasLabServicesOnSite, y.HasPharmacyOnSite, y.HasSurgeryOnSite, y.HasXrayOnSite, 
        y.IsDerived, y.IsSurgeryCenter, y.LastUpdateDate, case when y.NPI = 'None' then null else y.NPI end as NPI,
        y.OfficeCoordinatorName, y.OfficeDescription, y.OfficeEmail, replace(y.OfficeName,'&amp;','&') as OfficeName, 
        y.OfficeRank, y.OfficeWebsite, y.ParkingInformation, y.PaymentPolicy, 
        y.PhysicianCount, y.SourceCode, isnull(y.OfficeCode,x.OfficeCode) as OfficeCode,
        row_number() over(partition by x.OfficeID order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.OFFICE_CODE as OfficeCode, p.OfficeID, 
                json_query(p.PAYLOAD, '$.EntityJSONString')  as OfficeJSON
            from raw.OfficeProfileProcessingDeDup as d with (nolock)
            inner join raw.OfficeProfileProcessing as p with (nolock) on p.rawOfficeProfileID = d.rawOfficeProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.OfficeJSON is not null
    ) as x
    cross apply 
    (
        select *
        from openjson(x.OfficeJSON) with (AverageDailyPatientVolume int '$.AverageDailyPatientVolume', 
            DoSuppress bit '$.DoSuppress', HasBillingStaff bit '$.HasBillingStaff', HasChildPlayground bit '$.HasChildPlayground', 
            HasHandicapAccess bit '$.HasHandicapAccess', HasLabServicesOnSite bit '$.HasLabServicesOnSite', 
            HasPharmacyOnSite bit '$.HasPharmacyOnSite', HasSurgeryOnSite bit '$.HasSurgeryOnSite', 
            HasXrayOnSite bit '$.HasXrayOnSite', IsDerived bit '$.IsDerived', IsSurgeryCenter bit '$.IsSurgeryCenter', 
            LastUpdateDate datetime '$.LastUpdateDate', NPI varchar(10) '$.NPI', OfficeCode varchar(50) '$.OfficeCode', 
            OfficeCoordinatorName varchar(100) '$.OfficeCoordinatorName', OfficeDescription varchar(1000) '$.OfficeDescription', 
            OfficeEmail varchar(150) '$.OfficeEmail', OfficeName varchar(250) '$.OfficeName', OfficeRank int '$.OfficeRank', 
            OfficeWebsite varchar(150) '$.OfficeWebsite', ParkingInformation varchar(max) '$.ParkingInformation', 
            PaymentPolicy varchar(1000) '$.PaymentPolicy', PhysicianCount int '$.PhysicianCount',  SourceCode varchar(25) '$.SourceCode')
    ) as y
    outer apply 
    (
        select *
        from openjson(x.OfficeJSON,'$.Practice') with (
            PracticeCode varchar(50) '$.PracticeCode'
        )
    ) as z
    where isnull(y.DoSuppress, 0) = 0

    --In order to eliminate foreign Key violations, deleting data. this needs to be changed in the future
	delete s
    from #swimlane s
	where len(OfficeCode)>10

	update s
	set s.PracticeID = null
	from #swimlane s 
	where not exists (select 1 from ODS1Stage.Base.Practice b where s.PracticeID=b.PracticeID)
	and s.PracticeID is not null

	if @OutputDestination = 'ODS1Stage' begin
		if object_id('tempdb..#ChangedOffices') is not null drop table #ChangedOffices 
		create table #ChangedOffices (OfficeID uniqueidentifier not null primary key)
		
		INSERT INTO	#ChangedOffices(OfficeID)
		SELECT		O.OfficeID
		from		#swimlane as s
		inner join	ODS1Stage.Base.Office as o on o.OfficeID = s.OfficeID
		where		s.RowRank = 1
					and(
						isnull(o.OfficeCode, '') != isnull(s.OfficeCode, '') 
						or isnull(o.OfficeName, '') != isnull(s.OfficeName, '') 
					)


		update o 
		set			o.OfficeCode = s.OfficeCode, o.PracticeID = s.PracticeID, o.HasBillingStaff = s.HasBillingStaff, 
					o.HasHandicapAccess = s.HasHandicapAccess, o.HasLabServicesOnSite = s.HasLabServicesOnSite, 
					o.HasPharmacyOnSite = s.HasPharmacyOnSite, o.HasXrayOnSite = s.HasXrayOnSite, o.IsSurgeryCenter = s.IsSurgeryCenter, 
					o.HasSurgeryOnSite = s.HasSurgeryOnSite, o.AverageDailyPatientVolume = s.AverageDailyPatientVolume, 
					o.PhysicianCount = s.PhysicianCount, o.OfficeCoordinatorName = s.OfficeCoordinatorName, 
					o.ParkingInformation = s.ParkingInformation, o.PaymentPolicy = s.PaymentPolicy,
					o.OfficeName = s.OfficeName, o.SourceCode = isnull(s.SourceCode, 'Profisee'), o.OfficeRank = s.OfficeRank, o.IsDerived = isnull(s.IsDerived, ((0))), 
					o.NPI = s.NPI, o.HasChildPlayground = s.HasChildPlayground, o.LastUpdateDate = isnull(s.LastUpdateDate, getutcdate()), 
					o.OfficeDescription = s.OfficeDescription, o.OfficeWebsite = s.OfficeWebsite, o.OfficeEmail = s.OfficeEmail
		from		#swimlane as s
		inner join	ODS1Stage.Base.Office as o on o.OfficeID = s.OfficeID
		where		s.RowRank = 1
					and(
						isnull(o.OfficeCode, '') != isnull(s.OfficeCode, '') 
						--or isnull(o.PracticeID, convert(uniqueidentifier, '00000000-0000-0000-0000-000000000000')) != isnull(s.PracticeID, convert(uniqueidentifier, '00000000-0000-0000-0000-000000000000')) 
						or isnull(o.OfficeName, '') != isnull(s.OfficeName, '') 
						or isnull(o.SourceCode, '') != isnull(s.SourceCode, '') 
						or isnull(o.OfficeRank, 0) != isnull(s.OfficeRank, 0) 
						or isnull(o.OfficeWebsite, '') != isnull(s.OfficeWebsite, '') 
						or isnull(o.HasBillingStaff, 0) != isnull(s.HasBillingStaff, 0) 
						or isnull(o.HasHandicapAccess, 0) != isnull(s.HasHandicapAccess, 0) 
						or isnull(o.HasLabServicesOnSite, 0) != isnull(s.HasLabServicesOnSite, 0) 
						or isnull(o.HasPharmacyOnSite, 0) != isnull(s.HasPharmacyOnSite, 0) 
						or isnull(o.HasXrayOnSite, 0) != isnull(s.HasXrayOnSite, 0) 
						or isnull(o.IsSurgeryCenter, 0) != isnull(s.IsSurgeryCenter, 0) 
						or isnull(o.HasSurgeryOnSite, 0) != isnull(s.HasSurgeryOnSite, 0) 
						or isnull(o.AverageDailyPatientVolume, 0) != isnull(s.AverageDailyPatientVolume, 0) 
						or isnull(o.PhysicianCount, 0) != isnull(s.PhysicianCount, 0) 
						or isnull(o.OfficeCoordinatorName, '') != isnull(s.OfficeCoordinatorName, '') 
						or isnull(o.ParkingInformation, '') != isnull(s.ParkingInformation, '') 
						or isnull(o.PaymentPolicy, '') != isnull(s.PaymentPolicy, '') 
						or isnull(o.IsDerived, 0) != isnull(s.IsDerived, 0) 
						or isnull(o.NPI, '') != isnull(s.NPI, '') 
						or isnull(o.HasChildPlayground, 0) != isnull(s.HasChildPlayground, 0) 
						or isnull(o.OfficeDescription, '') != isnull(s.OfficeDescription, '') 
						or isnull(o.OfficeEmail, '') != isnull(s.OfficeEmail, '')
					)

		update		o 
		set			o.PracticeID = s.PracticeID
		from		#swimlane as s
		inner join	ODS1Stage.Base.Office as o on o.OfficeID = s.OfficeID
		where		s.RowRank = 1
					and isnull(o.PracticeID, convert(uniqueidentifier, '00000000-0000-0000-0000-000000000000')) != isnull(s.PracticeID, convert(uniqueidentifier, '00000000-0000-0000-0000-000000000000')) 

		insert into ODS1Stage.Base.Office (ReltioEntityID, OfficeID, OfficeCode, PracticeID, HasBillingStaff, HasHandicapAccess, 
			HasLabServicesOnSite, HasPharmacyOnSite, HasXrayOnSite, IsSurgeryCenter, HasSurgeryOnSite, 
			AverageDailyPatientVolume, PhysicianCount, OfficeCoordinatorName, ParkingInformation, PaymentPolicy, 
			OfficeName, SourceCode, OfficeRank, IsDerived, NPI, HasChildPlayground, LastUpdateDate, OfficeDescription, 
			OfficeWebsite, OfficeEmail)
		select s.ReltioEntityID, s.OfficeID, s.OfficeCode, s.PracticeID, s.HasBillingStaff, s.HasHandicapAccess, 
			s.HasLabServicesOnSite, s.HasPharmacyOnSite, s.HasXrayOnSite, s.IsSurgeryCenter, s.HasSurgeryOnSite, 
			s.AverageDailyPatientVolume, s.PhysicianCount, s.OfficeCoordinatorName, s.ParkingInformation, s.PaymentPolicy,
			s.OfficeName, isnull(s.SourceCode, 'Profisee'), s.OfficeRank, isnull(s.IsDerived, ((0))) as IsDerived, s.NPI, s.HasChildPlayground, 
			isnull(s.LastUpdateDate, getutcdate()), s.OfficeDescription, s.OfficeWebsite, s.OfficeEmail
		from #swimlane as s
		where not exists (select 1 from ODS1Stage.Base.Office as o where o.OfficeID = s.OfficeID)
			and s.RowRank = 1	
			and (s.OfficeID is not null)