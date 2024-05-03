SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [Mid].[spuProviderRefresh]
(
    @IsProviderDeltaProcessing bit = 0
)
as


declare @ErrorMessage varchar(1000)

begin try
		--declare @IsProviderDeltaProcessing bit = 0

        IF OBJECT_ID('tempdb..#Provider') IS NOT NULL DROP TABLE #Provider 
        SELECT TOP 0 * INTO #Provider FROM Mid.Provider; 
        ALTER TABLE #Provider 
			ADD ActionCode INT DEFAULT 0
        ALTER TABLE #Provider 
			ADD PRIMARY KEY CLUSTERED (ProviderID) 
		
		IF @IsProviderDeltaProcessing = 0
		BEGIN
			TRUNCATE TABLE Mid.Provider
			INSERT INTO #Provider (ProviderID, ProviderCode, ProviderTypeID, FirstName, MiddleName, LastName, CarePhilosophy, ProfessionalInterest, Suffix, Gender, NPI, AMAID, UPIN, MedicareID, DEANumber, TaxIDNumber, DateOfBirth, PlaceOfBirth, AcceptsNewPatients, HasElectronicMedicalRecords, HasElectronicPrescription, LegacyKey, ProviderLastUpdateDateOverall, ProviderLastUpdateDateOverallSourceTable, SearchBoostSatisfaction, SearchBoostAccessibility, ActionCode)
			SELECT	src.ProviderID, src.ProviderCode, src.ProviderTypeID, src.FirstName, src.MiddleName, src.LastName, src.CarePhilosophy, src.ProfessionalInterest, src.Suffix, src.Gender, src.NPI, src.AMAID, src.UPIN, src.MedicareID, src.DEANumber, src.TaxIDNumber, src.DateOfBirth, src.PlaceOfBirth, src.AcceptsNewPatients, src.HasElectronicMedicalRecords, src.HasElectronicPrescription, src.LegacyKey, isnull(src.ProviderLastUpdateDateOverall,src.LastUpdateDate), isnull(src.ProviderLastUpdateDateOverallSourceTable,src.LastUpdateDate), src.SearchBoostSatisfaction, src.SearchBoostAccessibility, 0
			FROM	Base.Provider as src
		END
		IF @IsProviderDeltaProcessing = 1
		BEGIN
			INSERT INTO #Provider (ProviderID, ProviderCode, ProviderTypeID, FirstName, MiddleName, LastName, CarePhilosophy, ProfessionalInterest, Suffix, Gender, NPI, AMAID, UPIN, MedicareID, DEANumber, TaxIDNumber, DateOfBirth, PlaceOfBirth, AcceptsNewPatients, HasElectronicMedicalRecords, HasElectronicPrescription, LegacyKey, ProviderLastUpdateDateOverall, ProviderLastUpdateDateOverallSourceTable, SearchBoostSatisfaction, SearchBoostAccessibility, ActionCode)
			SELECT		src.ProviderID, src.ProviderCode, src.ProviderTypeID, src.FirstName, src.MiddleName, src.LastName, src.CarePhilosophy, src.ProfessionalInterest, src.Suffix, src.Gender, src.NPI, src.AMAID, src.UPIN, src.MedicareID, src.DEANumber, src.TaxIDNumber, src.DateOfBirth, src.PlaceOfBirth, src.AcceptsNewPatients, src.HasElectronicMedicalRecords, src.HasElectronicPrescription, src.LegacyKey, isnull(src.ProviderLastUpdateDateOverall,src.LastUpdateDate), isnull(src.ProviderLastUpdateDateOverallSourceTable,src.LastUpdateDate), src.SearchBoostSatisfaction, src.SearchBoostAccessibility, 0
			FROM		Base.Provider as src
			INNER JOIN	Snowflake.etl.ProviderDeltaProcessing as a on a.ProviderID = src.ProviderID
		END

		CREATE INDEX temp ON #Provider (ProviderID)
	
		/*update the Degree Use the best DegreePriority*/
		UPDATE		A
		SET			a.DegreeAbbreviation = b.DegreeAbbreviation
		FROM		#Provider a	
		INNER JOIN(
				SELECT		z.ProviderID, zz.DegreeAbbreviation, ROW_NUMBER() OVER (PARTITION BY z.ProviderID ORDER BY z.DegreePriority ASC, z.LastUpdateDate DESC, zz.DegreeAbbreviation) AS recID
				FROM		Base.ProviderToDegree z
				INNER JOIN	Base.Degree zz 
							ON z.DegreeID = zz.DegreeID
		)b ON a.ProviderID = b.ProviderID
		WHERE		recID = 1
	
		UPDATE		A
		SET			a.ProviderTypeID = b.ProviderTypeID
		FROM		#Provider a
		INNER JOIN	Base.ProviderToProviderType b 
					ON a.ProviderID = b.ProviderID
		WHERE		b.ProviderTypeRank = 1;			
						
		/*these providers are missing ProviderType, hard code as a safety net as Show needs this field*/
		UPDATE	A
		SET		a.ProviderTypeID = (select ProviderTypeID from Base.ProviderType where ProviderTypeCode = 'ALT')
		FROM	#Provider a
		WHERE	ProviderTypeID IS NULL


		/*update the title here*/
		UPDATE		A
        SET			a.Title = 'Dr.'
        FROM		#Provider a
		INNER JOIN	Base.ProviderToProviderSubType b On a.ProviderID = b.ProviderID
		INNER JOIN  Base.ProviderSubType c on b.ProviderSubTypeID = c.ProviderSubTypeID
		WHERE		c.IsDoctor = 1
					AND isnull(a.Title, '') != 'Dr.'

		--generate the url every time so name changes are reflected in the url
		UPDATE		p
        SET			p.ProviderURL =	CASE WHEN pt.ProviderTypeCode = 'ALT'  then replace(replace('/'  + 'providers/'     + ISNULL(LOWER(p.FirstName),'') + '-' + ISNULL(LOWER(p.LastName),'') + '-' + ISNULL(LOWER(p.ProviderCode),''),'''',''),' ','-')
									when pt.ProviderTypeCode = 'DOC'  then replace(replace('/'  + 'physician/dr-' + ISNULL(LOWER(p.FirstName),'') + '-' + ISNULL(LOWER(p.LastName),'') + '-' + ISNULL(LOWER(p.ProviderCode),''),'''',''),' ','-')
									when pt.ProviderTypeCode = 'DENT' then replace(replace('/'  + 'dentist/dr-'   + ISNULL(LOWER(p.FirstName),'') + '-' + ISNULL(LOWER(p.LastName),'') + '-' + ISNULL(LOWER(p.ProviderCode),''),'''',''),' ','-') 
									else replace(replace('/'  + 'providers/' + ISNULL(LOWER(p.FirstName),'') + '-' + ISNULL(LOWER(p.LastName),'') + '-' + ISNULL(LOWER(p.ProviderCode),''),'''',''),' ','-')
									end
		FROM		#Provider as p
		LEFT JOIN	base.ProviderToProviderType ptpt 
					on p.ProviderID = ptpt.ProviderID
					AND ptpt.ProviderTypeRank = 1
		LEFT JOIN	Base.ProviderType as pt 
					on ptpt.ProviderTypeID = pt.ProviderTypeID 

		UPDATE		a 
		set			a.URL = b.ProviderURL
		FROM		Base.ProviderURL a
		INNER JOIN	#Provider b 
					on b.ProviderID = a.ProviderID
		WHERE		a.URL != b.ProviderURL
		
		update		a set a.ProviderURLNew = b.ProviderURL
		FROM		Base.ProviderRedirect a
		INNER JOIN	#Provider b 
					on b.ProviderCode = a.ProviderCodeNew
		WHERE		a.ProviderURLNew is not null
					AND b.ProviderURL != a.ProviderURLNew
					AND a.DeactivationReason not in ('Deactivated','HomePageRedirect')

		--update f&f display specialty
		update a 
		set a.FFDisplaySpecialty = c.SpecialtyCode
		from #provider a
			join Base.ProviderToDisplaySpecialty b on b.ProviderID = a.ProviderID
			join Base.Specialty c on c.SpecialtyID = b.SpecialtyID

		/*Updates to Mid.Provider*/
		UPDATE		A
		SET			a.AcceptsNewPatients = b.AcceptsNewPatients,
					a.AMAID = b.AMAID,
					a.CarePhilosophy = b.CarePhilosophy,
					a.DateOfBirth = b.DateOfBirth,
					a.DEANumber = b.DEANumber,
					a.DegreeAbbreviation = b.DegreeAbbreviation,
					a.ExpireCode = b.ExpireCode,
					a.FFDisplaySpecialty = b.FFDisplaySpecialty,
					a.FirstName = b.FirstName,
					a.Gender = b.Gender,
					a.HasElectronicMedicalRecords = b.HasElectronicMedicalRecords,
					a.HasElectronicPrescription = b.HasElectronicPrescription,
					a.LastName = b.LastName,
					a.LegacyKey = b.LegacyKey,
					a.MedicareID = b.MedicareID,
					a.MiddleName = b.MiddleName,
					a.NPI = b.NPI,
					a.PlaceOfBirth = b.PlaceOfBirth,
					a.ProfessionalInterest = b.ProfessionalInterest,
					a.ProviderCode = b.ProviderCode,
					a.ProviderLastUpdateDateOverall = b.ProviderLastUpdateDateOverall,
					a.ProviderLastUpdateDateOverallSourceTable = b.ProviderLastUpdateDateOverallSourceTable,
					a.ProviderTypeID = b.ProviderTypeID,
					a.ProviderURL = b.ProviderURL,
					a.SearchBoostAccessibility = b.SearchBoostAccessibility,
					a.SearchBoostSatisfaction = b.SearchBoostSatisfaction,
					a.Suffix = b.Suffix,
					a.TaxIDNumber = b.TaxIDNumber,
					a.Title = b.Title,
					a.UPIN = b.UPIN
		FROM		Mid.Provider a with (nolock)
		INNER JOIN	#Provider b on (a.ProviderID = b.ProviderID)
		WHERE		BINARY_CHECKSUM(isnull(cast(a.AcceptsNewPatients as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.AcceptsNewPatients as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.AMAID as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.AMAID as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.CarePhilosophy as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.CarePhilosophy as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.DateOfBirth as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.DateOfBirth as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.DEANumber as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.DEANumber as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.DegreeAbbreviation as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.DegreeAbbreviation as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.ExpireCode as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ExpireCode as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.FFDisplaySpecialty as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.FFDisplaySpecialty as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.FirstName as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.FirstName as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.Gender as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.Gender as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.HasElectronicMedicalRecords as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.HasElectronicMedicalRecords as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.HasElectronicPrescription as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.HasElectronicPrescription as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.LastName as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.LastName as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.LegacyKey as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.LegacyKey as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.MedicareID as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.MedicareID as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.MiddleName as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.MiddleName as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.NPI as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.NPI as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.PlaceOfBirth as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.PlaceOfBirth as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.ProfessionalInterest as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ProfessionalInterest as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.ProviderCode as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ProviderCode as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.ProviderLastUpdateDateOverall as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ProviderLastUpdateDateOverall as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.ProviderLastUpdateDateOverallSourceTable as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ProviderLastUpdateDateOverallSourceTable as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.ProviderTypeID as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ProviderTypeID as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.ProviderURL as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ProviderURL as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.SearchBoostAccessibility as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.SearchBoostAccessibility as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.SearchBoostSatisfaction as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.SearchBoostSatisfaction as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.Suffix as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.Suffix as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.TaxIDNumber as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.TaxIDNumber as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.Title as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.Title as varchar(max)),''))
					OR BINARY_CHECKSUM(isnull(cast(a.UPIN as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.UPIN as varchar(max)),''))

				
		/*Inserts to Mid.Provider*/
		INSERT INTO Mid.Provider (AcceptsNewPatients,AMAID,CarePhilosophy,DateOfBirth,DEANumber,DegreeAbbreviation,ExpireCode,FFDisplaySpecialty,FirstName,Gender,HasElectronicMedicalRecords,HasElectronicPrescription,LastName,LegacyKey,MedicareID,MiddleName,NPI,PlaceOfBirth,ProfessionalInterest,ProviderCode,ProviderID,ProviderLastUpdateDateOverall,ProviderLastUpdateDateOverallSourceTable,ProviderTypeID,ProviderURL,SearchBoostAccessibility,SearchBoostSatisfaction,Suffix,TaxIDNumber,Title,UPIN)
		SELECT		S.AcceptsNewPatients,S.AMAID,S.CarePhilosophy,S.DateOfBirth,S.DEANumber,S.DegreeAbbreviation,S.ExpireCode,S.FFDisplaySpecialty,S.FirstName,S.Gender,S.HasElectronicMedicalRecords,S.HasElectronicPrescription,S.LastName,S.LegacyKey,S.MedicareID,S.MiddleName,S.NPI,S.PlaceOfBirth,S.ProfessionalInterest,S.ProviderCode,S.ProviderID,S.ProviderLastUpdateDateOverall,S.ProviderLastUpdateDateOverallSourceTable,S.ProviderTypeID,S.ProviderURL,S.SearchBoostAccessibility,S.SearchBoostSatisfaction,S.Suffix,S.TaxIDNumber,S.Title,S.UPIN 
		FROM		#Provider S
		LEFT JOIN	Mid.Provider T
					ON T.ProviderId = S.ProviderId
		WHERE		T.ProviderId IS NULL
				
end try
begin catch
    set @ErrorMessage = 'Error in procedure Mid.spuProviderRefresh, line ' + convert(varchar(20), error_line()) + ': ' + error_message()
    raiserror(@ErrorMessage, 18, 1)
end catch
GO