CREATE OR REPLACE VIEW ODS1_STAGE_TEAM.SHOW.VWUPRACTICINGSPECIALTYTOGROUPSPECIALTYPRIMARY(
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
--- Base.SpecialtyGroup
--- Base.SpecialtyGroupToSpecialty
--- Show.SOLRSpecialty
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

SELECT	b.SpecialtyCode AS PracticingSpecialtyCode,
		LTRIM(RTRIM(b.SpecialtyDescription)) AS PracticingSpecialtyDescription,
		a.SpecialtyGroupCode AS RolledUpSpecialtyCode, 
		LTRIM(RTRIM(a.SpecialtyGroupDescription)) as RolledUpSpecialtyDescription, 
		a.LegacyKey as RolledUpLegacyID,
		c.SpecialtyGroupRank AS RolledUpSpecialtyRank,
		d.DirectoryNameIsts AS DirectoryName, 
		d.DirectoryUrl, 
		d.DirectoryNameSuffix

FROM	Base.SpecialtyGroup a
		JOIN Base.SpecialtyGroupToSpecialty c ON a.SpecialtyGroupID = c.SpecialtyGroupID
		JOIN Show.SOLRSpecialty d ON d.SpecialtyCode = a.SpecialtyGroupCode
		JOIN Base.Specialty b ON b.SpecialtyID = c.SpecialtyID
WHERE	c.SpecialtyIsRedundant = 1;