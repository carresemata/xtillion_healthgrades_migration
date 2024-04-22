SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [Base].[vwuPDCEmployedProviderPhone] 

AS

/*-------------------------------------------------------------------------------------------------------------
View Name:		vwuPDCEmployedProviderPhone

Created By:		Abhash Bhandary
Created On:		4th April 2012

Description:	This view will result the PDC Employed provider's phone

Modified By:	Louise Martin
Modified On:	5th July 2012  
Modification:   Added join to ClientToProduct table with condition of ActiveFlag=1

Server			

TEST EXAMPLE(S):  
SELECT * FROM [Base].[vwuPDCEmployedProviderPhone]

----------------------------------------------------------------------------------------------------------------*/


SELECT	/*i.EntityID AS ProviderID,*/ i.ClientToProductID,j.ClientProductToEntityID, 
		--MAX(CASE WHEN l.AreaCode > 1000 THEN ('1-'+CAST(l.AreaCode - 1000 AS VARCHAR(5)) +'-'+l.PhoneNumber) ELSE  (( '('+CAST(l.AreaCode AS VARCHAR(5)) ) +') '+l.PhoneNumber)END ) AS  'EmployedProviderPhone',
		j.PhoneNumber as EmployedProviderPhone,
		j.PhoneTypeCode
-- select * 
FROM	Base.ClientProductToEntity as i
		INNER JOIN [Base].[vwuClientProductEntityToPhone] as j ON i.ClientProductToEntityID = j.ClientProductToEntityID
		INNER JOIN Base.ClientToProduct as cp ON i.ClientToProductID = cp.ClientToProductID 
		
WHERE	j.PhoneTypeCode IN ('PTEMP','PTEMPM','PTEMPDTP', 'PTEMPT') -- Client-Employed Provider
  AND   cp.ActiveFlag = 1





GO