CREATE OR REPLACE VIEW ODS1_STAGE_TEAM.BASE.VWUPROVIDERSPECIALTY

---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
-- base.vwuProviderSpecialty depends on:
-- Base.EntityToMedicalTerm
-- Base.MedicalTerm
-- Base.MedicalTermType
-- Base.EntityType

---------------------------------------------------------
--------------------- 1. columns ------------------------
---------------------------------------------------------
-- ProviderToSpecialtyID
-- ProviderID
-- MedicalTermID
-- SpecialtyCode
-- Specialty
-- SpecialtyRank
-- Searchable
-- SourceCode

AS
SELECT
  EntityToMedicalTermID ProviderToSpecialtyID,
  etmt.EntityID ProviderID,
  etmt.MedicalTermID,
  mt.MedicalTermCode SpecialtyCode,
  mt.MedicalTermDescription1 Specialty,
  etmt.MedicalTermRank SpecialtyRank,
  etmt.Searchable,
  etmt.SourceCode
FROM
  Base.EntityToMedicalTerm etmt
  INNER JOIN Base.MedicalTerm mt ON etmt.MedicalTermID = mt.MedicalTermID
  INNER JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID
  INNER JOIN Base.EntityType et ON etmt.EntityTypeID = et.EntityTypeID
WHERE
  mtt.MedicalTermTypeCode = 'Specialty'
  AND et.EntityTypeCode = 'PROV';