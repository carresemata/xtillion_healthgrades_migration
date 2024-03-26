SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [Show].[vwuPracticingSpecialtyToGroupSpecialtyPrimary]
AS

/*--------------------------------------------------------------------
View		: Show.vwuPracticingSpecialtyToGroupSpecialtyPrimary

Description	: View to show Practicing Specialty Solr Index data

CreatedBy	: Abhash Bhandary
CreatedOn	: 10/10/2013

Server		: HGWDREP

Testing		:  

SELECT * FROM Show.vwuPracticingSpecialtyToGroupSpecialtyPrimary
WHERE RolledUpSpecialtyCode NOT IN 
(SELECT SpecialtyGroupCode from Base.SpecialtyGroup)

ORDER BY PracticingSpecialtyDescription

SELECT * from Base.SpecialtyGroup
WHERE SpecialtyGroupCode NOT IN 
(SELECT RolledUpSpecialtyCode FROM Show.vwuPracticingSpecialtyToGroupSpecialtyPrimary)

SELECT * from Base.SpecialtyGroup WHERE SpecialtyGroupCode = 'OTOR'
---------------------------------------------------------------------*/
	

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
WHERE	c.SpecialtyIsRedundant = 1
--WHERE	a.SpecialtyGroupDescription = b.SpecialtyDescription








GO
