-- etl.spumergeprovider (line 81)

begin
    --00:11:37/1800918
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct x.ReltioEntityID, try_convert(bit, y.AcceptsNewPatients) as AcceptsNewPatients,
        case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID,
        convert(uniqueidentifier, convert(varbinary(20), y.SourceCode)) as SourceID, 
        try_convert(date,y.DateOfBirth) as DateOfBirth, y.DoSuppress, y.FirstName, y.Gender, y.IsInClinicalPractice, 
        y.IsPCPCalculated, y.LastName, y.LastUpdateDate, y.MiddleName, y.NPI, y.PatientCountIsFew, 
        y.PatientVolume, x.ProviderCode, isnull(y.SourceCode, 'Profisee') as SourceCode, y.Suffix,
        y.HasElectronicMedicalRecords, y.HasElectronicPrescription, y.ProfessionalInterest, y.SurviveResidentialAddresses,
        y.IsPatientFavorite, y.SmartReferralClientCode, c.ClientID as SmartReferralClientID,
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end) order by y.ProviderCode, x.CREATE_DATE desc, y.NPI) as RowRank
    into #swimlane
    from
    (
        select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
            json_query(p.PAYLOAD, '$.EntityJSONString') as ProviderJSON
        from raw.ProviderProfileProcessingDeDup as d with (nolock)
        inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID

    ) as x
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (AcceptsNewPatients varchar(10) '$.AcceptsNewPatients', 
            DateOfBirth varchar(100) '$.DoB', DoSuppress bit '$.DoSuppress', 
            FirstName varchar(50) '$.FirstName', Gender char(1) '$.Gender', HasElectronicMedicalRecords bit '$.HasElectronicMedicalRecords', 
            HasElectronicPrescription bit '$.HasElectronicPrescription', IsInClinicalPractice bit '$.IsInClinicalPractice', 
            IsPCPCalculated bit '$.IsPCPCalculated', LastName varchar(50) '$.LastName', LastUpdateDate datetime '$.LastUpdateDate', 
            MiddleName varchar(50) '$.MiddleName', NPI varchar(10) '$.NPI', PatientCountIsFew bit '$.PatientCountIsFew', 
            PatientVolume int '$.PatientVolume',  Suffix varchar(10) '$.SuffixName', ProviderCode varchar(50) '$.ProviderCode',
            SourceCode varchar(50) '$.SourceCode', ProfessionalInterest varchar(max) '$.ProfessionalInterest',
            SurviveResidentialAddresses bit '$.SurviveResidentialAddresses',
            IsPatientFavorite bit '$.IsPatientFavorite', SmartReferralClientCode varchar(50) '$.SmartReferralClientCode')
    ) as y
    left join ODS1Stage.Base.Provider pID on x.ProviderCode = pID.ProviderCode
	left join ODS1Stage.Base.Client c on c.ClientCode = y.SmartReferralClientCode
    where isnull(y.DoSuppress, 0) = 0

    if @OutputDestination = 'ODS1Stage' begin
        update p set p.ProviderCode = s.ProviderCode, p.EDWBaseRecordID = s.ProviderID, p.FirstName = s.FirstName, p.MiddleName = s.MiddleName, 
            p.LastName = s.LastName, p.Suffix = s.Suffix, p.Gender = s.Gender, 
            p.NPI = s.NPI, p.DateOfBirth = CONVERT(DATE,TRY_CONVERT(DATETIME,s.DateOfBirth)), p.AcceptsNewPatients = s.AcceptsNewPatients, 
            p.HasElectronicMedicalRecords = s.HasElectronicMedicalRecords, p.HasElectronicPrescription = s.HasElectronicPrescription, 
            p.SourceCode = s.SourceCode, p.SourceID = s.SourceID, p.LastUpdateDate = s.LastUpdateDate, p.PatientVolume = s.PatientVolume, 
            p.IsInClinicalPractice = s.IsInClinicalPractice, p.PatientCountIsFew = s.PatientCountIsFew, p.IsPCPCalculated = isnull(s.IsPCPCalculated,0),
            p.ProfessionalInterest = s.ProfessionalInterest, p.SurviveResidentialAddresses = s.SurviveResidentialAddresses,
            p.IsPatientFavorite = s.IsPatientFavorite, p.SmartReferralClientID = s.SmartReferralClientID
		from #swimlane as s
        inner join ODS1Stage.Base.Provider as p on p.ProviderID = s.ProviderID
        where s.RowRank = 1 and 
        ( 
            isnull(p.ProviderCode,'') != isnull(s.ProviderCode,'') or 
		    isnull(p.EDWBaseRecordID, '00000000-0000-0000-0000-000000000000') != isnull(s.ProviderID, '00000000-0000-0000-0000-000000000000') or 
		    isnull(p.FirstName,'') != isnull(s.FirstName,'') or isnull(p.MiddleName,'') != isnull(s.MiddleName,'') or isnull(p.LastName,'') != isnull(s.LastName,'') or 
		    isnull(p.Suffix,'') != isnull(s.Suffix,'') or isnull(p.Gender,'') != isnull(s.Gender,'') or 
            isnull(p.NPI,'') != isnull(s.NPI,'') or isnull(p.DateOfBirth,'1900-01-01') != isnull(CONVERT(DATE,TRY_CONVERT(DATETIME,s.DateOfBirth)),'1900-01-01') or isnull(p.AcceptsNewPatients, 0) != isnull(s.AcceptsNewPatients, 0) or 
            isnull(p.HasElectronicMedicalRecords, 0) != isnull(s.HasElectronicMedicalRecords, 0) or isnull(p.HasElectronicPrescription, 0) != isnull(s.HasElectronicPrescription, 0) or 
            isnull(p.SourceCode,'') != isnull(s.SourceCode,'') or 
		    isnull(p.SourceID, '00000000-0000-0000-0000-000000000000') != isnull(s.SourceID, '00000000-0000-0000-0000-000000000000') or 
		    isnull(p.LastUpdateDate, '1900-01-01') != isnull(s.LastUpdateDate, '1900-01-01') or 
		    isnull(p.PatientVolume,'') != isnull(s.PatientVolume,'') or 
            isnull(p.IsInClinicalPractice, 0) != isnull(s.IsInClinicalPractice, 0) or isnull(p.PatientCountIsFew, 0) != isnull(s.PatientCountIsFew, 0) or isnull(p.IsPCPCalculated, 0) != isnull(s.IsPCPCalculated, 0) or
		    isnull(p.ProfessionalInterest,'') != isnull(s.ProfessionalInterest,'') or
		    isnull(p.SurviveResidentialAddresses,0) != isnull(s.SurviveResidentialAddresses,0) or
            isnull(p.IsPatientFavorite,0) != isnull(s.IsPatientFavorite,0) or
			isnull(p.SmartReferralClientID, convert(uniqueidentifier, '00000000-0000-0000-0000-000000000000')) != isnull(s.SmartReferralClientID, convert(uniqueidentifier, '00000000-0000-0000-0000-000000000000'))
        )

        --00:01:07/1800918
        insert into ODS1Stage.Base.Provider (ReltioEntityID, ProviderID, EDWBaseRecordID, ProviderCode, FirstName, MiddleName, LastName, Suffix, Gender, 
            NPI, DateOfBirth, AcceptsNewPatients, HasElectronicMedicalRecords, HasElectronicPrescription, 
            SourceCode, SourceID, LastUpdateDate, PatientVolume, IsInClinicalPractice, PatientCountIsFew, 
            IsPCPCalculated, ProfessionalInterest, SurviveResidentialAddresses, IsPatientFavorite, SmartReferralClientID)
        select s.ReltioEntityID, s.ProviderID, s.ProviderID, s.ProviderCode, s.FirstName, s.MiddleName, s.LastName, s.Suffix, s.Gender, 
            s.NPI, CONVERT(DATE,TRY_CONVERT(DATETIME,s.DateOfBirth)), s.AcceptsNewPatients, s.HasElectronicMedicalRecords, s.HasElectronicPrescription, 
            isnull(s.SourceCode, 'Profisee'), convert(uniqueidentifier, convert(varbinary(20), isnull(s.SourceCode, 'Profisee'))), isnull(s.LastUpdateDate, getutcdate()), s.PatientVolume, s.IsInClinicalPractice, s.PatientCountIsFew, 
            isnull(s.IsPCPCalculated, ((0))) as IsPCPCalculated, s.ProfessionalInterest, s.SurviveResidentialAddresses, s.IsPatientFavorite, s.SmartReferralClientID
        from #swimlane as s
        where not exists (select 1 from ODS1Stage.Base.Provider as p where p.ProviderID = s.ProviderID)
            and s.RowRank = 1	
		    and s.ProviderID is not null

	    update	ODS1Stage.Base.Provider
	    set		SourceCode = 'Profisee'
			    ,SourceID = convert(uniqueidentifier, convert(varbinary(20), 'Profisee')) 
	    where	SourceCode is null
			    or SourceID is null

	    update	ODS1Stage.Base.Provider
	    set		NPI = null
	    where	ProviderCode = NPI
    end


-- 'etl.spumergeprovideraboutme’,  (line 82)
begin
	if object_id(N'tempdb..#swimlane') is not null drop table #swimlane
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
        x.ProviderCode,  
        convert(uniqueidentifier, convert(varbinary(20), x.AboutMeCode)) as AboutMeID, x.AboutMeCode,
        y.ProviderAboutMeText, y.CustomDisplayOrder, y.DoSuppress, y.LastUpdateDate,
        y.SourceCode,
        row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), x.AboutMeCode order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.*
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, json_query(p.PAYLOAD, '$.EntityJSONString.AboutMe') as ProviderJSON,
                'About' as AboutMeCode
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
            union all
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, json_query(p.PAYLOAD, '$.EntityJSONString.ProceduresPerformed') as ProviderJSON, 
                'ProceduresPerformed' as AboutMeCode
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
            union all
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, json_query(p.PAYLOAD, '$.EntityJSONString.ResponseToPes') as ProviderJSON,
                'ResponseToPes' as AboutMeCode
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
            union all
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, json_query(p.PAYLOAD, '$.EntityJSONString.ConditionsTreated') as ProviderJSON, 
                'ConditionsTreated' as AboutMeCode
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
            union all
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, json_query(p.PAYLOAD, '$.EntityJSONString.CarePhilosophy') as ProviderJSON, 
                'CarePhilosophy' as AboutMeCode
            from raw.ProviderProfileProcessingDeDup as d with (nolock)
            inner join raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.ProviderJSON is not null
    ) as x
    cross apply 
    (
        select *
        from openjson(x.ProviderJSON) with (ProviderAboutMeText varchar(max) '$.Text', CustomDisplayOrder int '$.Rank',
            DoSuppress bit '$.DoSuppress', LastUpdateDate datetime '$.LastUpdateDate', SourceCode varchar(25) '$.SourceCode')
    ) as y
    left join ODS1Stage.Base.Provider pID on pID.ProviderCode = x.ProviderCode
    
    if @OutputDestination = 'ODS1Stage' begin
	    --Care Philosphy is also stored in Base.Provider -- null out where DoSuppress is true
	    update p set p.CarePhilosophy = null
	    from #swimlane as s
	    inner join ODS1Stage.Base.Provider as p on p.ProviderID = s.ProviderID
	    where s.AboutMeCode = 'CarePhilosophy' and isnull(s.DoSuppress, 0) = 1
	
	    --Update Care Philosphy in Base.Provider
	    update p set p.CarePhilosophy = s.ProviderAboutMeText
	    from #swimlane as s
	    inner join ODS1Stage.Base.Provider as p on p.ProviderID = s.ProviderID
	    where s.AboutMeCode = 'CarePhilosophy' and isnull(s.DoSuppress, 0) = 0


-- 'etl.spumergeprovideridentifier', (line 85)

begin
    select distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID, 
		x.ProviderCode, y.IDNumber, y.IdentifierType, isnull(y.DoSuppress,0) as DoSuppress, y.EffectiveDate, y.ExpirationDate, y.LastUpdateDate, y.SourceCode, 
		row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end), y.IDNumber, y.IdentifierType order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Identifiers') as ProviderJSON
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
        from openjson(x.ProviderJSON) with (IDNumber varchar(50) '$.ID', IdentifierType varchar(50) '$.Type', DoSuppress bit '$.DoSuppress', 
            EffectiveDate datetime '$.ActivationDate', ExpirationDate datetime '$.ExpirationDate', 
            LastUpdateDate datetime '$.LastUpdateDate', 
            SourceCode varchar(50) '$.SourceCode')
    ) as y
    where y.IDNumber is not null and y.IdentifierType is not null
    
    if @OutputDestination = 'ODS1Stage' begin
	    update p set UPIN = case when s.DoSuppress = 1 then null else s.IDNumber end
	    from #swimlane as s
	    inner join ODS1Stage.Base.Provider as p on p.ProviderCode = s.ProviderCode
	    where s.IdentifierType = 'UPIN'
		and s.IDNumber is not null
	    
	    update p set ABMSUID = case when s.DoSuppress = 1 then null else s.IDNumber end
	    from #swimlane as s
	    inner join ODS1Stage.Base.Provider as p on p.ProviderCode = s.ProviderCode
	    where s.IdentifierType = 'ABMSUID'
		and s.IDNumber is not null


