SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Show].[spuUpdateSOLRProviderClientCertificationXml] (
    @ProviderId UNIQUEIDENTIFIER = NULL		-- for debug
  , @FullRefresh BIT = 0
  , @Debug		BIT = 0						-- optionally return result set rather than perform update
) 
/***********************************************************************************************************  
Procedure Description: 
  For Powered By Healthgrade (PBH) web service to override HG doc certifications with certifications from client.
    Also, update the "provider delta" so that SOLR updates.

  Test:
    exec Show.spuUpdateSOLRProviderClientCertificationXm @FullRefresh = 1

HISTORY
2016-07-21     mfleming    Created (TFS 143348)
*************************************************************************************************************/  
AS
BEGIN	
	SET NOCOUNT ON;
		
	DECLARE @now				DATETIME2(2)	=  SYSDATETIME();
    DECLARE @proc				VARCHAR(50)	    =  OBJECT_NAME(@@PROCID);
    DECLARE @ErrorMessage		VARCHAR(4000);
    DECLARE @ErrorSeverity		INT;
    DECLARE @ErrorState			INT;    
	
	-- Get Providers associated with a PBH client that overrides cert xml, and whether or not any certs are mapped.
	-- Including providers with no mapped certs in case previously mapped certs need set NULL.
    --drop table #ClientProviders
	SELECT distinct s.ProviderCode, s.providerId, s.SOLRProviderID, pc.SourceCode
	INTO #ClientProviders
	FROM Show.SOLRProvider AS s
	JOIN scdghcorp.ProviderCertification as pc on pc.ProviderCode = s.ProviderCode

	BEGIN TRY		
	    -- Generate client cert xml which PBH will use to override HG cert xml. We will update SOLRProvider!ClientCertificationXml with the most mapped certs found.
        --drop table #ClientCertsXml
		CREATE TABLE #ClientCertsXml (SOLRProviderID INT NOT NULL , certs XML NULL,CertsCount SMALLINT, DedupeRank TINYINT NOT NULL,PRIMARY KEY (SOLRProviderID,DedupeRank DESC));

		INSERT INTO #ClientCertsXml
		        ( SOLRProviderID
		        , certs
		        , CertsCount
				, DedupeRank
		        )
		SELECT prv.SOLRProviderID,
			CASE WHEN client.certs.value('count(cSpnL/cSpn/cSpcL/cSpC)', 'int')>0 THEN client.certs END,		
			client.certs.value('count(cSpnL/cSpn/cSpcL/cSpC)', 'int') AS CertsCount,
			ROW_NUMBER() OVER (PARTITION BY prv.SOLRProviderID ORDER BY client.certs.value('count(cSpnL/cSpn/cSpcL/cSpC)', 'int') DESC)
		-- For each provider, build the cert xml. Return NULL where no certs.
		FROM 
        (
            select DISTINCT SOLRProviderID, ProviderCode FROM #ClientProviders) AS prv		 
		    OUTER APPLY 
            (
			    SELECT SUBSTRING(cp.SourceCode,3,50) AS spnCd,
		        (
                    select pc.cSpCd, pc.cSpY, pc.caCd, pc.caD, pc.cbCd, pc.cbD, pc.csCd, pc.csD
			        FROM scdghcorp.ProviderCertification as pc
			        WHERE pc.ProviderCode = prv.ProviderCode
                        and (pc.cSpCd is not null or pc.cSpY is not null or pc.caCd is not null or pc.caD is not null or pc.cbCd is not null or pc.cbD is not null or pc.csCd is not null or pc.csD is not null)
                    order BY pc.cSpCd, pc.cSpY, pc.caCd, pc.caD, pc.cbCd, pc.cbD, pc.csCd, pc.csD
			        FOR XML RAW('cSpC'), ELEMENTS, TYPE
		        ) AS cSpcL 
		        FROM #ClientProviders AS cp 
		        WHERE cp.SOLRProviderID=prv.SOLRProviderID
		        ORDER BY cp.SourceCode
		        FOR XML RAW('cSpn'),ROOT('cSpnL'), ELEMENTS, TYPE
		  ) AS client (Certs);		 

	  IF @Debug=1
	   BEGIN
	       SELECT TOP (100) '#ClientProviders' AS TableName, * FROM #ClientProviders ORDER BY SOLRProviderID;
		   SELECT TOP (100) '#ClientCertsXml' AS TableName, * FROM #ClientCertsXml ORDER BY SOLRProviderID;
	   END		
	  ELSE	
	    BEGIN	
		  BEGIN TRAN			
			
			UPDATE p SET p.ClientCertificationXML=x.Certs
			FROM Show.SOLRProvider AS p
			JOIN #ClientCertsXml AS x ON x.SOLRProviderID = p.SOLRProviderID
			WHERE x.DedupeRank=1;

			PRINT 'Updated '+CAST(@@ROWCOUNT AS VARCHAR(15))+' ClientCertificationXml in Show.SOLRProvider.'

            --EGS 2019/10/11: Commented out the reference to @FullRefresh below...
                --There are no full refreshes anymore: The code below currently takes less than a second to run for the 16760 records involved, so it can be run for every batch (?)
			--IF @FullRefresh = 1 
			--BEGIN
				-- Update Provider Delta for SOLR
				-- Clear out for a potential re-run
				-- This list will later be combined with the regular provider delta in 
				-- Mid.spuMidProviderEntityRefresh (around line 780).
				-- As of 2016-08-02, this proc will need to run before 5PM MT for the list to be combined with the standard provider delta.
				TRUNCATE TABLE show.SOLRProviderDelta_PoweredByHealthgrades;

				INSERT  INTO Show.SOLRProviderDelta_PoweredByHealthgrades
						( ProviderID
						, SolrDeltaTypeCode
						, StartDeltaProcessDate
						, MidDeltaProcessComplete
						)
				SELECT DISTINCT
					prv.ProviderID 
				  , '1' AS SolrDeltaTypeCode
				  , getdate() AS StartDeltaProcessDate
				  , '1' AS MidDeltaProcessComplete
				FROM #ClientProviders AS prv	
				ORDER BY prv.ProviderID; 
			--END 
		  COMMIT TRAN;
	     END
	END TRY
	BEGIN CATCH		
	    SELECT 
	     @ErrorMessage  = ERROR_MESSAGE()
	    ,@ErrorSeverity = ERROR_SEVERITY()
	    ,@ErrorState	= ERROR_STATE()
 
	    IF XACT_STATE() <> 0 ROLLBACK TRAN; 

	    RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState); 		
	END CATCH	

	IF OBJECT_ID('tempdb..#ClientCertsXml') IS NOT NULL DROP TABLE #ClientCertsXml;
	IF OBJECT_ID('tempdb..#ClientProviders') IS NOT NULL DROP TABLE #ClientProviders;
END
GO