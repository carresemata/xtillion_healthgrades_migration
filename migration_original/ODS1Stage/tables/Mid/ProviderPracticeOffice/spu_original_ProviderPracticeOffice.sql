-- this comes from etl_spuMidProviderEntityRefresh
update Mid.ProviderPracticeOffice
SET CITY = LEFT(CITY,LEN(CITY)-1)
where City+', '+ State like '%,,%'

-- this comes from Mid_spuProviderPracticeOfficeRefresh
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   procedure [Mid].[spuProviderPracticeOfficeRefresh]
(
    @IsProviderDeltaProcessing bit = 0
)
as

declare @ErrorMessage varchar(1000)

begin try

		--THIS IS A TEMPORARY HACK/SOLUTION UNTIL THE "DUPLICATION ADDRESSES ARE FIXED"
		--WE ARE KEYING OFF OF THE PROVIDEROFFICEID TO MAKE UPDATES TO AND THIS IS CAUSING ISSUES
		--REMOVE THIS LATER!!!!!!!
			if @IsProviderDeltaProcessing = 0
				begin
					TRUNCATE TABLE Mid.ProviderPracticeOffice
					print 'truncate mid.ProviderPracticeOffice'
				END
			else
				begin
					delete ppo --Mid.ProviderPracticeOffice
					from Snowflake.etl.ProviderDeltaProcessing as a
						inner join Mid.ProviderPracticeOffice ppo on a.ProviderID = ppo.ProviderID	
				END
 		


    --Create & fill table that holds the list of provider records that were supposed to migrate with the batch.  
    --  If this is a full file refresh, migrate all Base.Provider records.
    --  If this is a batch migration, the list records comes from provider deltas
    --  Obviously, if this is a full file refresh then technically a list of the records that migrated isn't neccessary, but it makes
    --      the code that inserts into #Provider much simpler as it removes the need for separate insert queries or dynamic SQL

        begin try drop table #ProviderBatch end try begin catch end catch
        create table #ProviderBatch (ProviderID uniqueidentifier)
        
        if @IsProviderDeltaProcessing = 0 begin
            insert into #ProviderBatch (ProviderID) 
			select a.ProviderID 
			from Base.Provider as a 
			--where providercode = '3t345'
			order by a.ProviderID
          end
        else begin
			insert into #ProviderBatch (ProviderID)
            select a.ProviderID
            from Snowflake.etl.ProviderDeltaProcessing as a
        end
        
        create clustered index tmp_clu_ix on #ProviderBatch (ProviderID)

	--build a temp table with the same structure as the Mid.ProviderPracticeOffice
		begin try drop table #ProviderPracticeOffice end try begin catch end catch
		select top 0 *
		into #ProviderPracticeOffice
		from Mid.ProviderPracticeOffice
		
		alter table #ProviderPracticeOffice
		add ActionCode int default 0
		
	--populate the temp table with data from Base schemas
		--exec hack.spuGetSourceOfficePracticeNames --HACK to ensure the source PracticeName and OfficeName go out to the web

		insert into #ProviderPracticeOffice 
			(
				ProviderToOfficeID,ProviderID,PracticeID,PracticeCode,PracticeName,YearPracticeEstablished,PracticeNPI,
				PracticeEmail,PracticeWebsite,PracticeDescription,PracticeLogo,PracticeMedicalDirector,PracticeSoftware,
				PracticeTIN,OfficeToAddressID,OfficeID,OfficeCode,OfficeName,IsPrimaryOffice,ProviderOfficeRank,AddressID,AddressCode,AddressTypeCode,AddressLine1,
				AddressLine2,AddressLine3,AddressLine4,City,State,ZipCode,County,Nation,Latitude,Longitude,FullPhone,FullFax,IsDerived,
				HasBillingStaff,HasHandicapAccess,HasLabServicesOnSite,HasPharmacyOnSite,HasXrayOnSite,IsSurgeryCenter,HasSurgeryOnSite,
				AverageDailyPatientVolume,PhysicianCount,OfficeCoordinatorName,ParkingInformation,PaymentPolicy,LegacyKeyOffice,LegacyKeyPractice
			)
        select distinct --a.OfficeName, b.OfficeName, a.PracticeName, g.PracticeName,
                a.ProviderToOfficeID, a.ProviderID, g.PracticeID, g.PracticeCode, 
				case when a.PracticeName is not null then a.PracticeName else g.PracticeName end as PracticeName,
				g.YearPracticeEstablished, g.NPI, i.EmailAddress, g.PracticeWebsite, g.PracticeDescription, g.PracticeLogo, g.PracticeMedicalDirector, 
				g.PracticeSoftware, g.PracticeTIN, c.OfficeToAddressID, b.OfficeID, b.OfficeCode, 
				case when a.OfficeName is not null then a.OfficeName else b.OfficeName end as OfficeName,
				case
					when h.ProviderID is NOT NULL then 1
					else NULL
				end as IsPrimaryOffice, 
				a.ProviderOfficeRank, 
				--d.AddressTypeCode, -- COMMENTED BY NANDITA
				e.AddressID, e.AddressCode, 'Office' as AddressTypeCode, -- ADDED BY NANDITA
				e.AddressLine1 + ISNULL(+' '+e.Suite,'') as AddressLine1, null AddressLine2, e.AddressLine3, e.AddressLine4,
				j.City, j.State, j.PostalCode as ZipCode, j.County, k.NationName as Nation, e.Latitude, e.Longitude,
				f.PhoneNumber as FullPhone,
				z.PhoneNumber as FullFax,
				c.IsDerived, b.HasBillingStaff, b.HasHandicapAccess, b.HasLabServicesOnSite, 
				b.HasPharmacyOnSite, b.HasXrayOnSite, b.IsSurgeryCenter, b.HasSurgeryOnSite, 
				b.AverageDailyPatientVolume, NULL as PhysicianCount, b.OfficeCoordinatorName, b.ParkingInformation, b.PaymentPolicy,
				b.LegacyKey as LegacyKeyOffice, g.LegacyKey as LegacyKeyPractice
			from #ProviderBatch pb 
			inner join Base.ProviderToOffice as a with (nolock) on pb.ProviderID = a.ProviderID
			inner join Base.Office as b with (nolock) on b.OfficeID = a.OfficeID
			inner join Base.OfficeToAddress as c with (nolock) on b.OfficeID = c.OfficeID
			--inner join Base.AddressType as d with (nolock)  on d.AddressTypeID = c.AddressTypeID
			--left join Base.AddressType as d with (nolock)  on d.AddressTypeID = c.AddressTypeID--THIS IS TEMPORARY UNTIL THE ADDRESS_TYPE IS DONE... REMOVE THIS LATER -- COMMENTED BY NANDITA
			--inner join Base.AddressType as d with (nolock) on d.AddressTypeID = c.AddressTypeID and d.AddressTypeCode in ('OFFICE','Practice','Hospital') -- ADDED BY NANDITA
			inner join Base.Address as e with (nolock) on e.AddressID = c.AddressID	
			--inner join Base.OfficeToPhone as f with (nolock) on f.OfficeID = b.OfficeID
			left join 
				(
					--SERVICE NUMBERS
					select x.PhoneNumber, x.OfficeID
					from(
						select b.PhoneNumber, a.OfficeID,ROW_NUMBER()OVER(PARTITION BY a.OfficeID ORDER BY a.PhoneRank, a.LastUpdateDate DESC, b.LastUpdateDate, a.PhoneId) AS SequenceId1
						from Base.OfficeToPhone a
						join Base.Phone b on (a.PhoneID = b.PhoneID)
						where a.PhoneTypeID = (select PhoneTypeID from Base.PhoneType where PhoneTypeCode = 'Service')
					)x
					where SequenceId1 = 1
				) f on (f.OfficeID = b.OfficeID)
			left join 
				(
					--FAX NUMBERS
					select x.PhoneNumber, x.OfficeID
					from(
						select b.PhoneNumber, a.OfficeID,ROW_NUMBER()OVER(PARTITION BY a.OfficeID ORDER BY a.PhoneRank, a.LastUpdateDate DESC, b.LastUpdateDate, a.PhoneId) AS SequenceId1
						from Base.OfficeToPhone a
						join Base.Phone b on (a.PhoneID = b.PhoneID)
						where a.PhoneTypeID = (select PhoneTypeID from Base.PhoneType where PhoneTypeCode = 'Fax')
					)x
					where SequenceId1 = 1
				) z	on (z.OfficeID = b.OfficeID)	
			left join Base.CityStatePostalCode j with (nolock) on e.CityStatePostalCodeID = j.CityStatePostalCodeID
			left join Base.Nation k on j.NationID = k.NationID
			left join Base.Practice as g with (nolock) on g.PracticeID = b.PracticeID
			--/*HACK*/left join ProfiseeAux.util.OfficePracticeSourceNames as hack on hack.ProviderID = pb.ProviderID and hack.OfficeID = b.OfficeID
			left join 
				(
					select ProviderID, MIN(ProviderOfficeRank) as ProviderOfficeRank
					from Base.ProviderToOffice
					where ProviderOfficeRank is not null
					group by ProviderID
				)h on (a.ProviderID = h.ProviderID and a.ProviderOfficeRank = h.ProviderOfficeRank)
			left join 
				(
					select PracticeID, EmailAddress, row_number() over(partition by PracticeID order by len(EmailAddress)) as EmailRank
					from Base.PracticeEmail
					where EmailAddress is not null
				) i on i.PracticeID = b.PracticeID and i.EmailRank = 1
			--where d.AddressTypeCode  = 'Service'--THIS IS TEMPORARY UNTIL THE ADDRESS_TYPE IS DONE... UNCOMMENT THIS LATER	
			
		--Update the PhysicianCount based on distinct providers at the Practice level
			update a
			set a.PhysicianCount = b.PhysicianCount
			--select *
			from #ProviderPracticeOffice a
			join 
				(
					select PracticeID, COUNT(*) as PhysicianCount
					from
						(
							select distinct ProviderID, PracticeID
							from #ProviderPracticeOffice
							where PracticeID is not null
						)a	
					group by PracticeID	
				)b on (a.PracticeID = b.PracticeID)	
					
			create index temp on #ProviderPracticeOffice (ProviderToOfficeID)

	/*
		Flag record level actions for ActionCode
			0 = No Change
			1 = Insert
			2 = Update
	*/
		--ActionCode Insert
		update a
		set a.ActionCode = 1
		--select *
		from #ProviderPracticeOffice a
		left join Mid.ProviderPracticeOffice b on (a.ProviderID = b.ProviderID and a.OfficeID = b.OfficeID and isnull(a.FullPhone,'') = isnull(b.FullPhone,'') and isnull(a.FullFax,'') = isnull(b.FullFax,''))
		where b.ProviderToOfficeID is null
		
		--ActionCode Update
		update a
		set a.ActionCode = 2
		--select *
		from #ProviderPracticeOffice a
		join Mid.ProviderPracticeOffice b with (nolock) on (a.ProviderID = b.ProviderID and a.OfficeID = b.OfficeID and isnull(a.FullPhone,'') = isnull(b.FullPhone,'') and isnull(a.FullFax,'') = isnull(b.FullFax,''))
		where BINARY_CHECKSUM(isnull(cast(a.AddressCode as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.AddressCode as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.AddressID as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.AddressID as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.AddressLine1 as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.AddressLine1 as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.AddressLine2 as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.AddressLine2 as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.AddressLine3 as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.AddressLine3 as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.AddressLine4 as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.AddressLine4 as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.AddressTypeCode as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.AddressTypeCode as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.AverageDailyPatientVolume as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.AverageDailyPatientVolume as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.City as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.City as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.County as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.County as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.HasBillingStaff as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.HasBillingStaff as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.HasHandicapAccess as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.HasHandicapAccess as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.HasLabServicesOnSite as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.HasLabServicesOnSite as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.HasPharmacyOnSite as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.HasPharmacyOnSite as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.HasSurgeryOnSite as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.HasSurgeryOnSite as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.HasXrayOnSite as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.HasXrayOnSite as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.IsDerived as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.IsDerived as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.IsPrimaryOffice as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.IsPrimaryOffice as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.IsSurgeryCenter as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.IsSurgeryCenter as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.Latitude as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.Latitude as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.LegacyKeyOffice as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.LegacyKeyOffice as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.LegacyKeyPractice as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.LegacyKeyPractice as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.Longitude as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.Longitude as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.Nation as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.Nation as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.OfficeCode as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.OfficeCode as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.OfficeCoordinatorName as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.OfficeCoordinatorName as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.OfficeID as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.OfficeID as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.OfficeName as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.OfficeName as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.OfficeToAddressID as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.OfficeToAddressID as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.ParkingInformation as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ParkingInformation as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.PaymentPolicy as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.PaymentPolicy as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.PhysicianCount as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.PhysicianCount as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.PracticeCode as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.PracticeCode as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.PracticeDescription as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.PracticeDescription as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.PracticeEmail as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.PracticeEmail as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.PracticeID as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.PracticeID as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.PracticeLogo as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.PracticeLogo as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.PracticeMedicalDirector as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.PracticeMedicalDirector as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.PracticeName as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.PracticeName as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.PracticeNPI as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.PracticeNPI as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.PracticeSoftware as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.PracticeSoftware as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.PracticeTIN as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.PracticeTIN as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.PracticeWebsite as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.PracticeWebsite as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.ProviderID as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ProviderID as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.ProviderOfficeRank as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ProviderOfficeRank as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.State as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.State as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.YearPracticeEstablished as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.YearPracticeEstablished as varchar(max)),''))
		 or BINARY_CHECKSUM(isnull(cast(a.ZipCode as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ZipCode as varchar(max)),''))

		;WITH cte_Dups AS (
			SELECT	*,ROW_NUMBER()OVER(PARTITION BY ProviderId, OfficeId ORDER BY ProviderToOfficeId) AS SequenceId
			FROM	#ProviderPracticeOffice
		)
		DELETE cte_Dups WHERE SequenceId > 1

		insert into Mid.ProviderPracticeOffice (AddressCode,AddressID,AddressLine1,AddressLine2,AddressLine3,AddressLine4,AddressTypeCode,AverageDailyPatientVolume,City,County,FullFax,FullPhone,HasBillingStaff,HasHandicapAccess,HasLabServicesOnSite,HasPharmacyOnSite,HasSurgeryOnSite,HasXrayOnSite,IsDerived,IsPrimaryOffice,IsSurgeryCenter,Latitude,LegacyKeyOffice,LegacyKeyPractice,Longitude,Nation,OfficeCode,OfficeCoordinatorName,OfficeID,OfficeName,OfficeToAddressID,ParkingInformation,PaymentPolicy,PhysicianCount,PracticeCode,PracticeDescription,PracticeEmail,PracticeID,PracticeLogo,PracticeMedicalDirector,PracticeName,PracticeNPI,PracticeSoftware,PracticeTIN,PracticeWebsite,ProviderID,ProviderOfficeRank,ProviderToOfficeID,State,YearPracticeEstablished,ZipCode)
		select	AddressCode,AddressID,AddressLine1,AddressLine2,AddressLine3,AddressLine4,AddressTypeCode,AverageDailyPatientVolume,City,County,FullFax,FullPhone,HasBillingStaff,HasHandicapAccess,HasLabServicesOnSite,HasPharmacyOnSite,HasSurgeryOnSite,HasXrayOnSite,IsDerived,IsPrimaryOffice,IsSurgeryCenter,Latitude,LegacyKeyOffice,LegacyKeyPractice,Longitude,Nation,OfficeCode,OfficeCoordinatorName,OfficeID,OfficeName,OfficeToAddressID,ParkingInformation,PaymentPolicy,PhysicianCount,PracticeCode,PracticeDescription,PracticeEmail,PracticeID,PracticeLogo,PracticeMedicalDirector,PracticeName,PracticeNPI,PracticeSoftware,PracticeTIN,PracticeWebsite,ProviderID,ProviderOfficeRank,ProviderToOfficeID,State,YearPracticeEstablished,ZipCode 
		from	#ProviderPracticeOffice 
		where	ActionCode = 1

		update a
		set a.AddressCode = b.AddressCode,
		a.AddressID = b.AddressID,
		a.AddressLine1 = b.AddressLine1,
		a.AddressLine2 = b.AddressLine2,
		a.AddressLine3 = b.AddressLine3,
		a.AddressLine4 = b.AddressLine4,
		a.AddressTypeCode = b.AddressTypeCode,
		a.AverageDailyPatientVolume = b.AverageDailyPatientVolume,
		a.City = b.City,
		a.County = b.County,
		a.HasBillingStaff = b.HasBillingStaff,
		a.HasHandicapAccess = b.HasHandicapAccess,
		a.HasLabServicesOnSite = b.HasLabServicesOnSite,
		a.HasPharmacyOnSite = b.HasPharmacyOnSite,
		a.HasSurgeryOnSite = b.HasSurgeryOnSite,
		a.HasXrayOnSite = b.HasXrayOnSite,
		a.IsDerived = b.IsDerived,
		a.IsPrimaryOffice = b.IsPrimaryOffice,
		a.IsSurgeryCenter = b.IsSurgeryCenter,
		a.Latitude = b.Latitude,
		a.LegacyKeyOffice = b.LegacyKeyOffice,
		a.LegacyKeyPractice = b.LegacyKeyPractice,
		a.Longitude = b.Longitude,
		a.Nation = b.Nation,
		a.OfficeCode = b.OfficeCode,
		a.OfficeCoordinatorName = b.OfficeCoordinatorName,
		a.OfficeID = b.OfficeID,
		a.OfficeName = b.OfficeName,
		a.OfficeToAddressID = b.OfficeToAddressID,
		a.ParkingInformation = b.ParkingInformation,
		a.PaymentPolicy = b.PaymentPolicy,
		a.PhysicianCount = b.PhysicianCount,
		a.PracticeCode = b.PracticeCode,
		a.PracticeDescription = b.PracticeDescription,
		a.PracticeEmail = b.PracticeEmail,
		a.PracticeID = b.PracticeID,
		a.PracticeLogo = b.PracticeLogo,
		a.PracticeMedicalDirector = b.PracticeMedicalDirector,
		a.PracticeName = b.PracticeName,
		a.PracticeNPI = b.PracticeNPI,
		a.PracticeSoftware = b.PracticeSoftware,
		a.PracticeTIN = b.PracticeTIN,
		a.PracticeWebsite = b.PracticeWebsite,
		a.ProviderID = b.ProviderID,
		a.ProviderOfficeRank = b.ProviderOfficeRank,
		a.State = b.State,
		a.YearPracticeEstablished = b.YearPracticeEstablished,
		a.ZipCode = b.ZipCode
		--select *
		from Mid.ProviderPracticeOffice a with (nolock)
		join #ProviderPracticeOffice b on (a.ProviderID = b.ProviderID and a.OfficeID = b.OfficeID and isnull(a.FullPhone,'') = isnull(b.FullPhone,'') and isnull(a.FullFax,'') = isnull(b.FullFax,''))
		where b.ActionCode = 2

		--ActionCode = N (Deletes)
			delete a
			--select *
			from Mid.ProviderPracticeOffice a with (nolock)
			inner join #ProviderBatch pb on a.ProviderID = pb.ProviderID
			left join #ProviderPracticeOffice b on (a.ProviderID = b.ProviderID and a.OfficeID = b.OfficeID and isnull(a.FullPhone,'') = isnull(b.FullPhone,'') and isnull(a.FullFax,'') = isnull(b.FullFax,''))
			where b.ProviderToOfficeID is null
	
				
		UPDATE		A 
		SET			OfficeName = [dbo].[fnuRemoveSpecialHexadecimalCharacters](OfficeName)
		FROM		Mid.ProviderPracticeOffice a
		WHERE		CHARINDEX(CHAR(0x0000),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x0001),a.OfficeName) <> 0 
					OR CHARINDEX(CHAR(0x0002),a.OfficeName) <> 0 
					OR CHARINDEX(CHAR(0x0003),a.OfficeName) <> 0 
					OR CHARINDEX(CHAR(0x0004),a.OfficeName) <> 0 
					OR CHARINDEX(CHAR(0x0005),a.OfficeName) <> 0 
					OR CHARINDEX(CHAR(0x0006),a.OfficeName) <> 0 
					OR CHARINDEX(CHAR(0x0007),a.OfficeName) <> 0 
					OR CHARINDEX(CHAR(0x0008),a.OfficeName) <> 0 
					OR CHARINDEX(CHAR(0x000B),a.OfficeName) <> 0 
					OR CHARINDEX(CHAR(0x000C),a.OfficeName) <> 0 
					OR CHARINDEX(CHAR(0x000E),a.OfficeName) <> 0 
					OR CHARINDEX(CHAR(0x000F),a.OfficeName) <> 0 
					OR CHARINDEX(CHAR(0x0010),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x0011),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x0012),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x0013),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x0014),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x0015),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x0016),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x0017),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x0018),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x0019),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x001A),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x001B),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x001C),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x001D),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x001E),a.OfficeName) <> 0
					OR CHARINDEX(CHAR(0x001F),a.OfficeName) <> 0

	/*
		DELTAS FOR SOLR HERE
	*/		
		
		
end try
begin catch
    set @ErrorMessage = 'Error in procedure Mid.spuProviderPracticeOfficeRefresh, line ' + convert(varchar(20), error_line()) + ': ' + error_message()
    raiserror(@ErrorMessage, 18, 1)
end catch
GO
