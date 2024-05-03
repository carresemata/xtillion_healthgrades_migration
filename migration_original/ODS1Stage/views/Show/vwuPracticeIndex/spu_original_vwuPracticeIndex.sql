SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Show].[vwuPracticeIndex]
AS

/*--------------------------------------------------------------------
View		: Show.vwuPracticeIndex

Description	: View to show Practice Solr Index data

CreatedBy	: Abhash Bhandary
CreatedOn	: 4/29/2012

Server		: ????

Testing		:  

select  * from Show.vwuPracticeIndex
select  * from Show.SOLRPractice


---------------------------------------------------------------------*/
	
SELECT  x.PracticeID ,
		x.PracticeCode , 
		ISNULL(x.LegacyKeyPractice,'HGPPZ'+left(replace(x.PracticeID,'-',''), 16)) as PracticeHGID,
		x.PracticeName, 
		x.YearPracticeEstablished, 
		x.PracticeEmailXML, 
		x.PracticeWebsite, 
		x.PracticeDescription, 
		x.PracticeLogo, 
		x.PracticeMedicalDirector, 
		x.PhysicianCount,
		x.HasDentist, 
		x.OfficeXML,
		x.SponsorshipXML
FROM	Show.SOLRPractice as x
where x.OfficeXML is not null



GO