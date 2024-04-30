SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create   procedure [etl].[spuMergeProviderLastUpdateDate] (@IsTestRun bit = 0, @SourceName varchar(10) = 'Reltio', @OutputDestination varchar(10) = 'ODS1Stage')
as
begin try
/*-------------------------------------------------------------------------------------------------------------
Description   : Insert LastUpdateDate and Source from all the swimlane in XML format
               

Test:
    use Snowflake
    
    select * from ODS1Stage.Base.ProviderLastUpdateDate

    exec etl.spuMergeProviderLastUpdateDate @IsTestRun = 1    
--------------------------------------------------------------------------------------------------------------*/
if @OutputDestination != 'ODS1Stage' or not exists (select 1 from DBMetrics.dbo.ProcessStatus a where a.ServerName = @@SERVERNAME and a.ProcessName = 'SF to ' + replace(db_name(), 'Snow' + 'flake', 'ODS1' + 'Stage') and a.ProcessSource = 'EDP Pipeline' and a.StepName = object_name(@@PROCID) and a.ProcessStatus = 'Complete')
begin
	
	--Get ProviderList
	if object_id(N'tempdb..#Provider') is not null drop table #Provider
	create table #Provider(ProviderID uniqueidentifier primary key)
	
	insert into #Provider (ProviderID)
	select p.ProviderID
	from raw.ProviderProfileProcessingDeDup as d with (nolock)
	inner join raw.ProviderProfileProcessing as pp with (nolock) on pp.rawProviderProfileID = d.rawProviderProfileID
	inner join ODS1Stage.Base.Provider as p with (nolock) on p.ProviderCode = pp.provider_code

	/*Get individual swimlanes*/

	--Demographics includes SurveySuppression as well
	if object_id(N'tempdb..#Demographics') is not null drop table #Demographics
	select c.ProviderID, c.SourceCode, c.LastUpdateDate
	into #Demographics
	from #Provider as p
	inner join ODS1Stage.Base.Provider as c with (nolock) on c.ProviderID = p.ProviderID

	if object_id(N'tempdb..#AboutMe') is not null drop table #AboutMe
	select x.ProviderID, x.SourceCode, x.LastUpdatedDate as LastUpdateDate
	into #AboutMe
	from 
	(	
		select c.ProviderID, c.LastUpdatedDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdatedDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToAboutMe as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#AppointmentAvailabilityStatement') is not null drop table #AppointmentAvailabilityStatement
	select c.ProviderID, c.SourceCode, c.LastUpdatedDate as LastUpdateDate
	into #AppointmentAvailabilityStatement
	from #Provider as p
	inner join ODS1Stage.Base.ProviderAppointmentAvailabilityStatement as c with (nolock) on c.ProviderID = p.ProviderID

	if object_id(N'tempdb..#Email') is not null drop table #Email
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Email
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderEmail as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#License') is not null drop table #License
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #License
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderLicense as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Office') is not null drop table #Office
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Office
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToOffice as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	--ProviderType includes ProviderURL as well
	if object_id(N'tempdb..#ProviderType') is not null drop table #ProviderType
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #ProviderType
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToProviderType as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Status') is not null drop table #Status
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Status
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToSubStatus as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#AppointmentAvailability') is not null drop table #AppointmentAvailability
	select x.ProviderID, x.SourceCode, x.LastUpdatedDate as LastUpdateDate
	into #AppointmentAvailability
	from 
	(	
		select c.ProviderID, c.LastUpdatedDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdatedDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToAppointmentAvailability as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#CertificationSpecialty') is not null drop table #CertificationSpecialty
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #CertificationSpecialty
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToCertificationSpecialty as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Facility') is not null drop table #Facility
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Facility
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToFacility as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Image') is not null drop table #Image
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Image
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderImage as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Malpractice') is not null drop table #Malpractice
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Malpractice
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderMalpractice as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Organization') is not null drop table #Organization
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Organization
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToOrganization as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	--if object_id(N'tempdb..#Sanction') is not null drop table #Sanction
	--select x.ProviderID, x.SourceCode, x.LastUpdateDate
	--into #Sanction
	--from 
	--(	
	--	select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
	--	from #Provider as p
	--	inner join ODS1Stage.Base.ProviderSanction as c with (nolock) on c.ProviderID = p.ProviderID	
	--) as x
	--where x.RowRank = 1

	if object_id(N'tempdb..#Sponsorship') is not null drop table #Sponsorship
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Sponsorship
	from 
	(	
		select c.EntityID as ProviderID, c.LastUpdateDate, cp.ClientToProductCode as SourceCode, row_number() over (partition by c.EntityID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ClientProductToEntity as c with (nolock) on c.EntityID = p.ProviderID	
		inner join ODS1Stage.Base.EntityType as b with (nolock) on b.EntityTypeCode = 'PROV'
		inner join ODS1Stage.Base.ClientToProduct as cp with (nolock) on c.ClientTOProductID = cp.ClientToProductID
		inner join ODS1Stage.Base.Product as prod with (nolock) on prod.ProductID = cp.ProductID and prod.ProductCode != 'LID'
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Degree') is not null drop table #Degree
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Degree
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToDegree as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Education') is not null drop table #Education
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Education
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToEducationInstitution as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#HealthInsurance') is not null drop table #HealthInsurance
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #HealthInsurance
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToHealthInsurance as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Language') is not null drop table #Language
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Language
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToLanguage as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Media') is not null drop table #Media
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Media
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderMedia as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Specialty') is not null drop table #Specialty
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Specialty
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToSpecialty as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Video') is not null drop table #Video
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Video
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderVideo as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	--ToDo. etl.spuMergeProviderOASCustomerProduct in the future when this proc is being used

	if object_id(N'tempdb..#Telehealth') is not null drop table #Telehealth
	select x.ProviderID, x.SourceCode, x.LastUpdatedDate as LastUpdateDate
	into #Telehealth
	from 
	(	
		select c.ProviderID, c.LastUpdatedDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdatedDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToTelehealthMethod as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	--can't differentiate between Condition and Procedure since 
	if object_id(N'tempdb..#Condition') is not null drop table #Condition
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Condition
	from 
	(	
		select c.EntityID as ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.EntityID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.EntityToMedicalTerm as c with (nolock) on c.EntityID = p.ProviderID
		inner join ODS1Stage.Base.MedicalTerm as mt with (nolock) on mt.MedicalTermID = c.MedicalTermID
		inner join ODS1Stage.Base.MedicalTermType as mtt with (nolock) on mtt.MedicalTermTypeID = mt.MedicalTermTypeID and mtt.MedicalTermTypeCode = 'Condition'  
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Procedure') is not null drop table #Procedure
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Procedure
	from 
	(	
		select c.EntityID as ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.EntityID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.EntityToMedicalTerm as c with (nolock) on c.EntityID = p.ProviderID
		inner join ODS1Stage.Base.MedicalTerm as mt with (nolock) on mt.MedicalTermID = c.MedicalTermID
		inner join ODS1Stage.Base.MedicalTermType as mtt with (nolock) on mtt.MedicalTermTypeID = mt.MedicalTermTypeID and mtt.MedicalTermTypeCode = 'Procedure'  
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#ProviderSubType') is not null drop table #ProviderSubType
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #ProviderSubType
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToProviderSubType as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Training') is not null drop table #Training
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Training
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderTraining as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	if object_id(N'tempdb..#Identification') is not null drop table #Identification
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #Identification
	from 
	(	
		select c.ProviderID, c.LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.LastUpdateDate desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderIdentification as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1

	/* --wait till it's ready in Prod
	if object_id(N'tempdb..#ClinicalFocus') is not null drop table #ClinicalFocus
	select x.ProviderID, x.SourceCode, x.LastUpdateDate
	into #ClinicalFocus
	from 
	(	
		select c.ProviderID, c.InsertedOn as LastUpdateDate, c.SourceCode, row_number() over (partition by c.ProviderID order by c.InsertedOn desc) as RowRank 
		from #Provider as p
		inner join ODS1Stage.Base.ProviderToClinicalFocus as c with (nolock) on c.ProviderID = p.ProviderID	
	) as x
	where x.RowRank = 1
	*/

	/*Generate XML*/
	
	if object_id(N'tempdb..#ProviderXML') is not null drop table #ProviderXML
    create table #ProviderXML(ProviderID uniqueidentifier primary key, XMLValue xml)
	
	insert into #ProviderXML (ProviderID, XMLValue)
	select p2.ProviderID, 
		(	select
			(	
				select c.SourceCode, c.LastUpdateDate 
				from #Demographics as c
				where c.ProviderID = p.ProviderID
				for xml raw('Demographics'), elements, type
			),	
			(	
				select c.SourceCode, c.LastUpdateDate 
				from #AboutMe as c
				where c.ProviderID = p.ProviderID
				for xml raw('AboutMe'), elements, type
			),
			(	
				select c.SourceCode, c.LastUpdateDate 
				from #AboutMe as c
				where c.ProviderID = p.ProviderID
				for xml raw('AppointmentAvailabilityStatement'), elements, type
			),				
			(	
				select c.SourceCode, c.LastUpdateDate 
				from #Email as c
				where c.ProviderID = p.ProviderID
				for xml raw('Email'), elements, type
			),	
			(	
				select c.SourceCode, c.LastUpdateDate 
				from #License as c
				where c.ProviderID = p.ProviderID
				for xml raw('License'), elements, type
			),			
			(	
				select c.SourceCode, c.LastUpdateDate
				from #Office as c
				where c.ProviderID = p.ProviderID
				for xml raw('Office'), elements, type
			),
			(	
				select c.SourceCode, c.LastUpdateDate
				from #ProviderType as c
				where c.ProviderID = p.ProviderID
				for xml raw('ProviderType'), elements, type
			),
			(	
				select c.SourceCode, c.LastUpdateDate
				from #Status as c
				where c.ProviderID = p.ProviderID
				for xml raw('Status'), elements, type
			),
			(	
				select c.SourceCode, c.LastUpdateDate
				from #AppointmentAvailability as c
				where c.ProviderID = p.ProviderID
				for xml raw('AppointmentAvailability'), elements, type
			),
			(	
				select c.SourceCode, c.LastUpdateDate
				from #CertificationSpecialty as c
				where c.ProviderID = p.ProviderID
				for xml raw('CertificationSpecialty'), elements, type
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Facility as c
				where c.ProviderID = p.ProviderID
				for xml raw('Facility'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Image as c
				where c.ProviderID = p.ProviderID
				for xml raw('Image'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Malpractice as c
				where c.ProviderID = p.ProviderID
				for xml raw('Malpractice'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Organization as c
				where c.ProviderID = p.ProviderID
				for xml raw('Organization'), elements, type			
			),
			--(
			--	select c.SourceCode, c.LastUpdateDate
			--	from #Sanction as c
			--	where c.ProviderID = p.ProviderID
			--	for xml raw('Sanction'), elements, type			
			--),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Sponsorship as c
				where c.ProviderID = p.ProviderID
				for xml raw('Sponsorship'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Degree as c
				where c.ProviderID = p.ProviderID
				for xml raw('Degree'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Education as c
				where c.ProviderID = p.ProviderID
				for xml raw('Education'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #HealthInsurance as c
				where c.ProviderID = p.ProviderID
				for xml raw('HealthInsurance'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Language as c
				where c.ProviderID = p.ProviderID
				for xml raw('Language'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Media as c
				where c.ProviderID = p.ProviderID
				for xml raw('Media'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Specialty as c
				where c.ProviderID = p.ProviderID
				for xml raw('Specialty'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Video as c
				where c.ProviderID = p.ProviderID
				for xml raw('Video'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Telehealth as c
				where c.ProviderID = p.ProviderID
				for xml raw('Telehealth'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Condition as c
				where c.ProviderID = p.ProviderID
				for xml raw('Condition'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Procedure as c
				where c.ProviderID = p.ProviderID
				for xml raw('Procedure'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #ProviderSubType as c
				where c.ProviderID = p.ProviderID
				for xml raw('ProviderSubType'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Training as c
				where c.ProviderID = p.ProviderID
				for xml raw('Training'), elements, type			
			),
			(
				select c.SourceCode, c.LastUpdateDate
				from #Identification as c
				where c.ProviderID = p.ProviderID
				for xml raw('Identification'), elements, type			
			)--,
			--(
			--	select c.SourceCode, c.LastUpdateDate
			--	from #ClinicalFocus as c
			--	where c.ProviderID = p.ProviderID
			--	for xml raw('ClinicalFocus'), elements, type			
			--)
		from #Provider as p
		where p.ProviderID = p2.ProviderID
		group by p.ProviderID
		for xml raw('LastUpdateDateBySwimlane'), elements, type
		) as XML
	from #Provider as p2

	--Delete and insert records
	delete c
	--select c.*
	from #Provider as p
	inner join ODS1Stage.Base.ProviderLastUpdateDate as c on c.ProviderID = p.ProviderID
	
	--Insert all ProviderToOffice child records
	insert into ODS1Stage.Base.ProviderLastUpdateDate (ProviderID, LastUpdateDatePayload)  
	select s.ProviderID, s.XMLValue
	from #ProviderXML as s

	if @OutputDestination = 'ODS1Stage' and @IsTestRun = 0 begin
		insert into DBMetrics.dbo.ProcessStatus ( ServerName, ProcessName, ProcessSource, StepName, StepDescription, ProcessStatus )
		select @@SERVERNAME, 'SF to ' + replace(db_name(), 'Snow' + 'flake', 'ODS1' + 'Stage'), 'EDP Pipeline', object_name(@@PROCID), 'exec ' + object_name(@@PROCID), 'Complete'
	end
end
end try
begin catch
	exec util.spuGetErrorInfo @@PROCID  
end catch
GO