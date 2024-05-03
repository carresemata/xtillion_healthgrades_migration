SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Base].[vwuPDCClientDetail] 

AS

/*-------------------------------------------------------------------------------------------------------------
View Name		vwuPDCClientDetail

Created By		Abhash Bhandary
Created On		23rd Feb 2012

Description		This view will result the PDC clients's detail

Modified By     EGS
Modified On     5/16/12
Modification    Changed image (alias img) sub-query to point to new image tables

Server			

TEST EXAMPLE(S)
SELECT * FROM [Base].[vwuPDCClientDetail] WHERE ClientToProductID = '5D6F65D5-F03D-4AA3-BE1E-45657799B4B0'
SELECT * FROM [Base].[vwuPDCClientDetail_abhash] WHERE ClientToProductID = '5D6F65D5-F03D-4AA3-BE1E-45657799B4B0'

----------------------------------------------------------------------------------------------------------------*/


SELECT	b.ClientToProductID,m.ClientProductToEntityID, img.ImageFilePath, img.MediaImageTypeCode ,u.URL,u.URLTypeCode,
		--MAX(CASE WHEN ph.AreaCode > 1000 THEN ('1-'+CAST(ph.AreaCode - 1000 AS VARCHAR(5)) +'-'+ph.PhoneNumber) ELSE  (( '('+CAST(ph.AreaCode AS VARCHAR(5)) ) +') '+ph.PhoneNumber)END ) AS  'DesignatedProviderPhone',
		ph.PhoneNumber AS  'DesignatedProviderPhone',
		ph.PhoneTypeCode
-- SELECT *  
FROM	Base.Client a
		JOIN Base.ClientToProduct b  ON a.ClientID = b.ClientID AND b.ActiveFlag = 1
		JOIN Base.ClientProductToEntity m ON b.ClientToProductID = m.ClientToProductID 
		JOIN Base.EntityType c ON m.EntityTypeID = c.EntityTypeID AND c.EntityTypeCode = 'CLPROD'
		LEFT JOIN
				(
                    select d.ClientToProductID, 
                    isnull(e.MediaRelativePath,'') + case when right(isnull(e.MediaRelativePath,''),1) <> '/' then '/' else '' end + d.FileName as ImageFilePath, 
                        e.MediaImageTypeCode 
                    from Base.ClientProductImage d
                    inner join Base.MediaImageType e on e.MediaImageTypeID = d.MediaImageTypeID
				) img ON b.ClientToProductID = img.ClientToProductID
		
		LEFT JOIN 
		(
			SELECT g.ClientProductToEntityID, 
			ltrim(rtrim(replace(i.URL,'--','-'))) as URL,
			h.URLTypeCode
			FROM Base.ClientProductEntityToURL g 
			JOIN Base.URLType h ON h.URLTypeID = g.URLTypeID --AND h.URLTypeCode = 'ClientURL'
			JOIN Base.URL i ON g.URLID = i.URLID
			
		) u ON m.ClientProductToEntityID = u.ClientProductToEntityID 
				
		--LEFT JOIN 
		--(
			
		--	SELECT j.ClientProductToEntityID, cpe.ClientToProductID, l.AreaCode, l.PhoneNumber, k.PhoneTypeCode
		--	FROM Base.ClientProductEntityToPhone j 
		--	JOIN Base.PhoneType k ON j.PhoneTypeID = k.PhoneTypeID --AND k.PhoneTypeCode IN ( 'PDC Affiliated', 'Client-Employed')
		--	JOIN Base.Phone l ON j.PhoneID = l.PhoneID
		--	JOIN Base.ClientProductToEntity cpe on j.ClientProductToEntityID = cpe.ClientProductToEntityID
		--	--where J.ClientToProductID = m.ClientToProductID
		--) ph ON m.ClientToProductID = ph.ClientToProductID

		LEFT JOIN 
		(
			
			SELECT j.ClientProductToEntityID, cpe.ClientToProductID, j.AreaCode, j.PhoneNumber, j.PhoneTypeCode
			FROM [Base].[vwuClientProductEntityToPhone] j 
			JOIN Base.ClientProductToEntity cpe on j.ClientProductToEntityID = cpe.ClientProductToEntityID
			--where J.ClientToProductID = m.ClientToProductID
		) ph ON m.ClientToProductID = ph.ClientToProductID








GO
