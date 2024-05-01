CREATE OR REPLACE VIEW ODS1_STAGE.SHOW.VWUPRACTICINGSPECIALTYTOGROUPSPECIALTYPRIMARY(
	PRACTICINGSPECIALTYCODE,
	PRACTICINGSPECIALTYDESCRIPTION,
	ROLLEDUPSPECIALTYCODE,
	ROLLEDUPSPECIALTYDESCRIPTION,
	ROLLEDUPLEGACYID,
	ROLLEDUPSPECIALTYRANK,
	DIRECTORYNAME,
	DIRECTORYURL,
	DIRECTORYNAMESUFFIX
) AS

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Show.vwuPracticingSpecialtyToGroupSpecialtyPrimary depends on: 
--- Show.SOLRSpecialty
--- Base.SpecialtyGroup
--- Base.SpecialtyGroupToSpecialty
--- Base.Specialty

---------------------------------------------------------
--------------------- 1. Columns ------------------------
---------------------------------------------------------

-- PracticingSpecialtyCode
-- PracticingSpecialtyDescription
-- RolledUpSpecialtyCode
-- RolledUpSpecialtyDescription
-- RolledUpLegacyID
-- RolledUpSpecialtyRank
-- DirectoryName
-- DirectoryUrl
-- DirectoryNameSuffix

SELECT
  s.SpecialtyCode AS PracticingSpecialtyCode,
  LTRIM(RTRIM(s.SpecialtyDescription)) AS PracticingSpecialtyDescription,
  sg.SpecialtyGroupCode AS RolledUpSpecialtyCode,
  LTRIM(RTRIM(sg.SpecialtyGroupDescription)) AS RolledUpSpecialtyDescription,
  sg.LegacyKey AS RolledUpLegacyID,
  sgs.SpecialtyGroupRank AS RolledUpSpecialtyRank,
  ss.DirectoryNameIsts AS DirectoryName,
  ss.DirectoryUrl,
  ss.DirectoryNameSuffix
FROM Base.SpecialtyGroup sg
JOIN Base.SpecialtyGroupToSpecialty sgs ON sg.SpecialtyGroupID = sgs.SpecialtyGroupID
JOIN Show.SOLRSpecialty ss ON ss.SpecialtyCode = sg.SpecialtyGroupCode
JOIN Base.Specialty s ON s.SpecialtyID = sgs.SpecialtyID
WHERE sgs.SpecialtyIsRedundant = 1;