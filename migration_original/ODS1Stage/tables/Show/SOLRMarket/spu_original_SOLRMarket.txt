------------------------------------------------ Show.spuSOLRMarketaGenerateFromMid------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [Show].[spuSOLRMarketGenerateFromMid]
as

/*-------------------------------------------------------------------------------------------------------------
Procedure Name	: spuSOLRMarketGenerateFromMid
Description		: Generate one record per sold Market for SOLR Market Core

Created By		: Abhash Bhandary
Created On		: 02/27/2012	

EXEC Show.spuSOLRMarketGenerateFromMid

SELECT COUNT(0) FROM ODS2.Show.SOLRMarket
SELECT * FROM ODS2.Show.SOLRMarket WHERE MarketID = '5860828D-9A0B-4D17-A4F0-7F3513A21DCC'
SELECT * FROM ODS2.Show.SOLRMarket WHERE MarketID ='26E74C12-EEFB-4FA6-87F2-2ED67D10776C'
SELECT * FROM ODS2.Show.SOLRMarket WHERE GeographicAreaValue = 'tampa,fl' and LineOfServiceCode = 'CARD'
SELECT * FROM ODS2.Show.SOLRMarket WHERE MarketID = '53D7886A-1708-42D8-BFA8-0006DCF795DB'


INSERT	INTO Show.SOLRMarketDelta(MarketID, SolrDeltaTypeCode,  MidDeltaProcessComplete)
SELECT	DISTINCT MarketID , 1, 1 
FROM	Mid.ClientMarket
		
		
SELECT * FROM ODS2.Show.SOLRMarket WHERE GeographicAreaValue = 'tampa,fl' and LineOfServiceCode = 'CARD'
SELECT * FROM ODS2.Show.SOLRMarket WHERE GeographicAreaValue = 'tampa,fl' and LineOfServiceCode = 'CARD'

SELECT * FROM ODS2.Base.Product

TRUNCATE Table Show.SOLRMarket
TRUNCATE Table Show.SOLRMarketDelta

--------------------------------------------------------------------------------------------------------------*/
SET nocount off


DECLARE @ErrorMessage varchar(1000)

BEGIN TRY
	TRUNCATE TABLE Show.SOLRMarket
	--this TABLE will hold ALL of the records that we need to INSERT/UPDATE
		BEGIN TRY DROP TABLE #BatchProcess END TRY BEGIN CATCH END CATCH
		SELECT	DISTINCT MarketID, NULL as BatchNumber
		INTO	#BatchProcess
		FROM	BASE.Market
		/*
		FROM	Show.SOLRMarketDelta
		WHERE	StartDeltaProcessDate IS NULL 
				AND EndDeltaProcessDate IS NULL
				AND SolrDeltaTypeCode = 1 --INSERT/UPDATEs
				AND MidDeltaProcessComplete = 1 --this will indicate the Mid TABLEs have been refreshed with the UPDATEd data
				*/
	--SET the records a batch number based on a batch size we are SETting
		DECLARE @batchNumberMin INT
		DECLARE @batchNumberMax INT
		DECLARE @batchSize FLOAT
		DECLARE @sql VARCHAR(MAX)

		SET @batchSize = 100000--THIS IS THE BATCH SIZE WE ARE PROCESSING... 100K SEEMS TO BE THE FASTEST WITHOUT GOING OVERBOARD
		SET @batchNumberMin = 1
		SELECT @batchNumberMax = ceiling(COUNT(*)/@batchSize) FROM #BatchProcess


		WHILE @batchNumberMin <= @batchNumberMax
			BEGIN
				SET @sql = 
				'
				UPDATE	a
				SET		a.BatchNumber = '+cast(@batchNumberMin AS VARCHAR(max))+'
				--SELECT *
				FROM	#BatchProcess a
				JOIN 
				(
					SELECT	TOP '+cast(@batchSize AS VARCHAR(max))+' MarketID
					FROM	#BatchProcess
					WHERE	BatchNumber IS NULL
				)b ON (a.MarketID = b.MarketID)
				'
				EXEC (@sql)
			
				SET @batchNumberMin = @batchNumberMin + 1	
			END	

			CREATE INDEX ix_Mid_MarketID ON #BatchProcess (MarketID)	
			CREATE INDEX ix_Mid_BatchNumber ON #BatchProcess (BatchNumber)
	
	--process the records based on designated batches			
		DECLARE @batchProcessMin INT
		DECLARE @batchProcessMax INT

		SET @batchProcessMin = 1
		SELECT @batchProcessMax = MAX(BatchNumber) FROM #BatchProcess


		PRINT 'Process Start'
		PRINT GETDATE()
		WHILE @batchProcessMin <= @batchProcessMax
			BEGIN	

					--get the records to process that are new or deltas within a batch
						BEGIN TRY DROP TABLE #BatchInsertUpdateProcess END TRY BEGIN CATCH END CATCH
						SELECT	DISTINCT MarketID
						INTO	#BatchInsertUpdateProcess
						FROM	#BatchProcess
						WHERE	BatchNumber = @batchProcessMin
						
						CREATE INDEX ix_Mid_MarketID on #BatchInsertUpdateProcess (MarketID)

					--get the records to remove as the Market level entity is gone
					--DEAL WITH THESE LATER
						--BEGIN TRY DROP TABLE #BatchDeleteProcess END TRY BEGIN CATCH END CATCH
						--SELECT DISTINCT MarketID
						--INTO #BatchDeleteProcess
						--FROM Show.SOLRMarketDelta
						--WHERE StartDeltaProcessDate IS NULL and ENDDeltaProcessDate IS NULL
						--and SolrDeltaTypeCode = 2--Deletes
						--and MidDeltaProcessComplete = 1--this will indicate the Mid TABLEs have been refreshed with the UPDATEd data
						
						--CREATE INDEX ix_Mid_MarketID on #BatchDeleteProcess (MarketID)
					
										
					MERGE Show.SOLRMarket AS s
						USING 
						(
							SELECT	
                                MarketID,
                                MarketCode,
                                GeographicAreaCode,
                                GeographicAreaValue,
                                GeographicAreaTypeCode,
                                GeographicAreaTypeDescription, 
                                LineOfServiceCode,
                                LegacyKey,
                                LineOfServiceDescription,
                                LineOfServiceTypeCode,
                                LineOfServiceTypeDescription, 
                                SponsorshipXML,
                                UpdatedDate,
                                UpdatedSource 
							FROM
							(
								SELECT	
                                    c.MarketID,
                                    c.MarketCode,
                                    c.GeographicAreaCode,
                                    c.GeographicAreaValue,
                                    c.GeographicAreaTypeCode,
                                    c.GeographicAreaTypeDescription, 
                                    c.LineOfServiceCode,
                                    c.LegacyKey,
                                    c.LineOfServiceDescription,
                                    c.LineOfServiceTypeCode,
                                    c.LineOfServiceTypeDescription, 
                                    GETDATE() AS UpdatedDate,
                                    USER_NAME() AS UpdatedSource,
								(--Sponsorship
									SELECT  
                                        m.ProductCode AS prCd, 
                                        m.ProductGroupCode AS prGrCd,
                                        CASE 
                                            WHEN m.ProductCode = 'MAP' AND (PhoneMtrXML is not null or PhonePsrXML is not null) 
                                                then 1 
                                                else 0 
                                        end as compositePhone,
                                        (	
                                            SELECT	
                                                u.ClientCode AS spnCd, 
                                                u.ClientName AS spnNm,
                                                SearchResultsMarketShareValue AS mktShr,
                                                SearchResultsMarketShareValue AS psrMktShr,
                                                CompetingProviderMarketShareValue AS provMktShr,
                                                u.CallToActionMtrMsg AS caToActMsgMtr,
                                                u.CallToActionPsrMsg AS caToActMsgPsr,
                                                u.SafeHarborMsg AS safHarMsg,
                                                    (	SELECT	
                                                            ClientFeatureCode AS featCd,
                                                            d.ClientFeatureDescription AS featDesc,
                                                            e.ClientFeatureValueCode AS featValCd,
                                                            e.ClientFeatureValueDescription AS featValDesc
                                                        FROM	Base.ClientEntityToClientFeature a
                                                                JOIN Base.EntityType b ON a.EntityTypeID = b.EntityTypeID 
                                                                JOIN Base.ClientFeatureToClientFeatureValue c ON a.ClientFeatureToClientFeatureValueID = c.ClientFeatureToClientFeatureValueID
                                                                JOIN Base.ClientFeature d ON c.ClientFeatureID = d.ClientFeatureID
                                                                JOIN Base.ClientFeatureValue e ON e.ClientFeatureValueID = c.ClientFeatureValueID
                                                                JOIN Base.ClientFeatureGroup f ON d.ClientFeatureGroupID = f.ClientFeatureGroupID
                                                        WHERE	b.EntityTypeCode = 'CLPROD'
                                                                AND u.ClientToProductID = a.EntityID
                                                        ORDER BY	ClientFeatureCode, ClientFeatureValueCode
                                                        FOR XML RAW ('spnFeat'), ELEMENTS, ROOT('spnFeatL'), TYPE		
                                                        --FOR XML RAW ('spnFeat'), ELEMENTS, ROOT('spnFeatL'), TYPE
                                                    ), --AS spnFeat,
                                                    (
                                                        SELECT	
                                                            CallCenterCode AS clCtrCd,
                                                            CallCenterName AS clCtrNm,
                                                            ReplyDays AS aptCoffDay, 
                                                            ApptCutOffTime AS aptCoffHr,
                                                            EmailAddress AS eml, 
                                                            FaxNumber AS fxNo,
                                                            (	SELECT	
                                                                    ClientFeatureCode AS featCd,
                                                                    d.ClientFeatureDescription AS featDesc,
                                                                    e.ClientFeatureValueCode AS featValCd,
                                                                    e.ClientFeatureValueDescription AS featValDesc
                                                                FROM	Base.ClientEntityToClientFeature a
                                                                        JOIN Base.EntityType b ON a.EntityTypeID = b.EntityTypeID 
                                                                        JOIN Base.ClientFeatureToClientFeatureValue c ON a.ClientFeatureToClientFeatureValueID = c.ClientFeatureToClientFeatureValueID
                                                                        JOIN Base.ClientFeature d ON c.ClientFeatureID = d.ClientFeatureID
                                                                        JOIN Base.ClientFeatureValue e ON e.ClientFeatureValueID = c.ClientFeatureValueID
                                                                        JOIN Base.ClientFeatureGroup f ON d.ClientFeatureGroupID = f.ClientFeatureGroupID
                                                                WHERE	f.ClientFeatureGroupCode = 'FGOAR' 
                                                                        AND b.EntityTypeCode = 'CLCTR'
                                                                        AND ccd.CallCenterID = a.EntityID
                                                                ORDER BY	ClientFeatureCode, ClientFeatureValueCode
                                                                FOR XML RAW ('clCtrFeat'), ELEMENTS, ROOT('clCtrFeatL'), TYPE		
                                                                --FOR XML RAW ('Feat'), ELEMENTS, ROOT('FeatL'), TYPE
                                                            ) --AS callCtrFeatL
                                                        FROM	Base.vwuCallCenterDetails ccd
                                                        WHERE	ccd.ClientToProductID = u.ClientToProductID
                                                        --WHERE ccd.ClientToProductID ='2F54DFC2-2FF8-4463-BC21-D01CF3F158E8'
                                                        GROUP	BY 
                                                            CallCenterCode, 
                                                            CallCenterName, 
                                                            ReplyDays, 
                                                            ApptCutOffTime,
                                                            EmailAddress, 
                                                            FaxNumber, 
                                                            CallCenterID
                                                        FOR XML RAW (''), ELEMENTS, ROOT('clCtrL'), TYPE
                                                    ),
                                                    (	
                                                        SELECT	
                                                            v.FacilityCode AS facCd,
                                                            v.FacilityName AS facNm, 
                                                            v.PhoneMtrXML AS phoneMtrL,
                                                            v.PhonePsrXML AS phonePsrL,
                                                            v.MobilePhoneMtrXML AS mobilePhoneMtrL, 
                                                            v.MobilePhonePsrXML AS mobilePhonePsrL, 
                                                            v.URLXML AS urlL, v.ImageXML AS imageL, 
                                                            v.QuaMsgMtrXML AS quaMsgMtrL, 
                                                            v.QuaMsgPsrXML AS quaMsgPsrL,
                                                            v.TabletPhoneMtrXML as tabletPhoneMtrL, 
                                                            v.TabletPhonePsrXML as tabletPhonePsrL,
                                                            v.DesktopPhoneMtrXML as desktopPhoneMtrL, 
                                                            v.DesktopPhonePsrXML as desktopPhonePsrL
                                                        FROM	Mid.ClientMarket v
                                                        WHERE	v.MarketID = u.MarketID
                                                                AND v.ClientToProductID = u.ClientToProductID
                                                                AND (	v.FacilityCode IS NOT NULL  
                                                                        OR v.PhoneMtrXML IS NOT NULL 
                                                                        OR v.PhonePsrXML IS NOT NULL
                                                                        OR v.URLXML IS NOT NULL
                                                                        OR v.ImageXML IS NOT NULL
                                                                        OR v.QuaMsgMtrXML IS NOT NULL
                                                                        OR v.QuaMsgPsrXML IS NOT null
                                                                        OR v.TabletPhoneMtrXML is not null
                                                                        OR v.TabletPhonePsrXML is not null
                                                                        OR v.DesktopPhoneMtrXML is NOT NULL
                                                                        OR v.DesktopPhonePsrXML is NOT NULL
                                                                    ) 
                                                        ORDER BY	FacilityCode
                                                                --AND v.FacilityCode = u.FacilityCode
                                                        --WHERE  a.MarketID = '55818A56-B045-4673-BBD9-56EEA6520DD2' 
                                                        FOR XML RAW ('disp'), ELEMENTS, ROOT('dispL'), TYPE 
                                                    )
                                            FROM	Mid.ClientMarket u
                                            WHERE	u.MarketID = m.MarketID
                                                    AND FacilityCode IS NOT NULL
                                                    AND u.ClientToProductID = m.ClientToProductID
                                            --AND  a.MarketID = '55818A56-B045-4673-BBD9-56EEA6520DD2' 
                                            GROUP	BY 
                                                u.ClientCode,
                                                u.ClientName,
                                                u.SearchResultsMarketShareValue,
                                                u.CompetingProviderMarketShareValue,
                                                u.MarketID,u.CallToActionMtrMsg,
                                                u.CallToActionPsrMsg,
                                                u.SafeHarborMsg,
                                                u.ClientToProductID--,u.FacilityCode
                                            FOR XML RAW ('spn'), ELEMENTS, ROOT('spnL'), TYPE
                                        )	
									FROM	Mid.ClientMarket m
									WHERE	c.MarketID = m.MarketID
									  -- m.MarketID = '55818A56-B045-4673-BBD9-56EEA6520DD2'
									GROUP BY	
                                        m.ProductCode,
                                        m.ProductGroupCode, 
                                        m.ProductDescription, 
                                        m.MarketID, 
                                        m.ClientToProductID,
                                        CASE 
                                            WHEN m.ProductCode = 'MAP' AND (PhoneMtrXML is not null or PhonePsrXML is not null) 
                                                then 1 
                                                else 0 
                                            end 
									FOR XML RAW ('sponsor'), ELEMENTS, ROOT('sponsorL'), TYPE
								) AS SponsorshipXML
								
								FROM	Mid.ClientMarket c
										JOIN #BatchInsertUpdateProcess as batch on batch.MarketID = c.MarketID
								WHERE	C.ClientCode NOT IN (select DISTINCT ClientCode from Show.DelayClient dc where GoLiveDate > CAST(GETDATE() AS DATE))
								GROUP	BY c.MarketID,c.MarketCode, c.GeographicAreaCode, c.GeographicAreaValue,c.GeographicAreaTypeCode,
										c.GeographicAreaTypeDescription, c.LineOfServiceCode,c.LegacyKey,c.LineOfServiceDescription,
										c.LineOfServiceTypeCode,c.LineOfServiceTypeDescription
									/*--if you want to test it, plug in a MarketID here
									WHERE c.MarketID = '8E83D778-ECFD-4956-B86A-000F1ADD5099'
									*/
							) AS my
						) AS mx ON mx.MarketID = s.MarketID
							
					WHEN MATCHED THEN     
						UPDATE SET 
                            s.MarketID = mx.MarketID,
                            s.MarketCode = mx.MarketCode, 
                            s.GeographicAreaCode = mx.GeographicAreaCode,
                            s.GeographicAreaValue = mx.GeographicAreaValue, 
                            s.GeographicAreaTypeCode = mx.GeographicAreaTypeCode,
                            s.GeographicAreaTypeDescription = mx.GeographicAreaTypeDescription, 
                            s.LineOfServiceCode = mx.LineOfServiceCode,
                            s.LegacyKey = mx.LegacyKey,
                            s.LineOfServiceDescription = mx.LineOfServiceDescription, 
                            s.LineOfServiceTypeCode = mx.LineOfServiceTypeCode,
                            s.LineOfServiceTypeDescription = mx.LineOfServiceTypeDescription, 
                            s.SponsorshipXML = mx.SponsorshipXML,
                            s.UpdatedDate = mx.UpdatedDate, 
                            s.UpdatedSource = mx.UpdatedSource
					WHEN NOT MATCHED BY TARGET THEN
						INSERT (	
									MarketID,
                                    MarketCode,
                                    GeographicAreaCode,
                                    GeographicAreaValue,
                                    GeographicAreaTypeCode,
									GeographicAreaTypeDescription,
                                    LineOfServiceCode,
                                    LegacyKey,
                                    LineOfServiceDescription,
									LineOfServiceTypeCode,
                                    LineOfServiceTypeDescription, 
                                    SponsorshipXML, 
									UpdatedDate,
                                    UpdatedSource
								)
						VALUES (	
									mx.MarketID,
                                    mx.MarketCode,
                                    mx.GeographicAreaCode,
                                    mx.GeographicAreaValue,
                                    mx.GeographicAreaTypeCode,
									mx.GeographicAreaTypeDescription, 
                                    mx.LineOfServiceCode,
                                    mx.LegacyKey,
                                    mx.LineOfServiceDescription,
									mx.LineOfServiceTypeCode,
                                    mx.LineOfServiceTypeDescription,
                                    mx.SponsorshipXML,
									UpdatedDate,
                                    UpdatedSource
								);
			
					PRINT 'Batch '+CAST(@batchProcessMin AS VARCHAR(1000))+' Completed'
				SET @batchProcessMin = @batchProcessMin + 1	
			END

/*	
		update	m
		SET		IsDart = 1
		--select c.*
		FROM	Show.SOLRMarket m
				JOIN Mid.ClientMarket c ON m.MarketID = c.MarketID
		WHERE	ProductCode = 'PDCHSP'
				

			
		print 'Update DART flag'
		print getdate()	
*/						

		PRINT 'Process End'
		PRINT GETDATE()						
END TRY
BEGIN CATCH
    SET @ErrorMessage = 'Error in procedure spuSOLRMarketGenerateFromMid, line ' + CONVERT(VARCHAR(20), ERROR_LINE()) + ': ' + ERROR_MESSAGE()
    RAISERROR(@ErrorMessage, 18, 1)
END CATCH
GO
