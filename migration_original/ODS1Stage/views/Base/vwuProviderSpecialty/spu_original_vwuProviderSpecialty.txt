SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [Base].[vwuProviderSpecialty]
AS 
select EntityToMedicalTermID ProviderToSpecialtyID, et.EntityID ProviderID, et.MedicalTermID, mt.MedicalTermCode SpecialtyCode, 
	mt.MedicalTermDescription1 Specialty, et.MedicalTermRank SpecialtyRank, et.Searchable, et.SourceCode
--select et.*
from Base.EntityToMedicalTerm et
	join Base.MedicalTerm mt on et.MedicalTermID = mt.MedicalTermID
	join Base.MedicalTermType mtt on mt.MedicalTermTypeID = mtt.MedicalTermTypeID
	join Base.EntityType enty on et.EntityTypeID = enty.EntityTypeID
where mtt.MedicalTermTypeCode = 'Specialty' and enty.EntityTypeCode = 'PROV'


GO