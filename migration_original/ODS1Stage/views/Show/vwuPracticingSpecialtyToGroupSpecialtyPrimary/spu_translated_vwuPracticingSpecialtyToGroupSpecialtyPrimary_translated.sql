---------------------------------------------------------
---------------- 0. View dependencies -------------------
---------------------------------------------------------

-- Show.vwuPracticingSpecialtyToGroupSpecialtyPrimary depends on: 
--- Show.SOLRSpecialty (currently empty as of MAR 24 2024)
--- Base.SpecialtyGroup
--- Base.SpecialtyGroupToSpecialty
--- Base.Specialty

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