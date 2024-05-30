CREATE OR REPLACE VIEW ODS1_STAGE_TEAM.BASE.VWUPROVIDERTOSPECIALTY
AS

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.VWUPROVIDERTOSPECIALTY depends on:
--- Base.EntityToMedicalTerm
--- Base.MedicalTerm
--- Base.MedicalTermType
--- Base.EntityType

---------------------------------------------------------
--------------------- 1. Columns ------------------------
---------------------------------------------------------

-- ProviderToSpecialtyID
-- ProviderID
-- MedicalTermID
-- SpecialtyCode
-- Specialty
-- SpecialtyRank
-- Searchable
-- SourceCode

SELECT
  EntityToMedicalTermID AS ProviderToSpecialtyID,
  etmt.EntityID AS ProviderID,
  etmt.MedicalTermID,
  mt.MedicalTermCode AS SpecialtyCode,
  mt.MedicalTermDescription1 AS Specialty,
  etmt.MedicalTermRank AS SpecialtyRank,
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