SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [Base].[vwuClientProductEntityToPhone] 

AS

/*-------------------------------------------------------------------------------------------------------------
View Name:		vwuClientProductEntityToPhone

Created By:		Abhash Bhandary
Created On:		5th May 2016

Description:	This view will result PDC phone numbers

PSR Designated - Provider Specific (HG3 Desktop)

Server			

TEST EXAMPLE(S):  
SELECT * FROM [Base].[vwuClientProductEntityToPhone]
WHERE PhoneNumber = '(615) 326-5043'

SELECT * FROM Base.PhoneType

SELECT * FROM [Base].[vwuPDCClientDetail] WHERE ClientToProductID = '01B55B7C-9CDF-4D8D-B993-06CEC23E7FC2' AND DesignatedProviderPhone = '1-888-387-4026'

----------------------------------------------------------------------------------------------------------------*/


SELECT	j.ClientProductToEntityID, 
		l.AreaCode, 
		l.PhoneNumber, 
		j.PhoneID,
		j.PhoneTypeID,
		CASE 
			WHEN PhoneTypeCode = 'PTPRSRDM' THEN 'PTPRSRDDTP'
			WHEN PhoneTypeCode = 'PTPRSRM'	THEN 'PTPRSRDTP'
			WHEN PhoneTypeCode = 'PTPMTM'	THEN 'PTPMTDTP'
			WHEN PhoneTypeCode = 'PTPDSM'	THEN 'PTPDSDTP'
			WHEN PhoneTypeCode = 'PTPMCM'	THEN 'PTPMCDTP'
			WHEN PhoneTypeCode = 'PTODSM'	THEN 'PTODSDTP'
			WHEN PhoneTypeCode = 'PTOMCM'	THEN 'PTOMCDTP'
			WHEN PhoneTypeCode = 'PTOMTM'	THEN 'PTOMTDTP'
			WHEN PhoneTypeCode = 'PTOOSM'	THEN 'PTOOSDTP'
			WHEN PhoneTypeCode = 'PTOSRDM'	THEN 'PTOSRDDTP'
			WHEN PhoneTypeCode = 'PTOSRM'	THEN 'PTOSRDTP'
			WHEN PhoneTypeCode = 'PTPSRDM'	THEN 'PTPSRDDTP'
			WHEN PhoneTypeCode = 'PTFSRDM'	THEN 'PTFSRDDTP'
			WHEN PhoneTypeCode = 'PTMWCM'	THEN 'PTMWCDTP'
			WHEN PhoneTypeCode = 'PTFMCM'	THEN 'PTFMCDTP'
			WHEN PhoneTypeCode = 'PTDESM'	THEN 'PTDESDTP'
			WHEN PhoneTypeCode = 'PTEMPM'	THEN 'PTEMPDTP'
			WHEN PhoneTypeCode = 'PTFDSM'	THEN 'PTFDSDTP'
			WHEN PhoneTypeCode = 'PTFMTM'	THEN 'PTFMTDTP'
			WHEN PhoneTypeCode = 'PTFSRM'	THEN 'PTFSRDTP'
			WHEN PhoneTypeCode = 'PTHFSM'	THEN 'PTHFSDTP'
			WHEN PhoneTypeCode = 'PTHOSM'	THEN 'PTHOSDTP'
			WHEN PhoneTypeCode = 'PTMTRM'	THEN 'PTMTRDTP'
			WHEN PhoneTypeCode = 'PTPSRM'	THEN 'PTPSRDTP'
			ELSE PhoneTypeCode
		END AS 'PhoneTypeCode'
FROM Base.ClientProductEntityToPhone j 
JOIN Base.PhoneType k ON j.PhoneTypeID = k.PhoneTypeID 
JOIN Base.Phone l ON j.PhoneID = l.PhoneID




GO