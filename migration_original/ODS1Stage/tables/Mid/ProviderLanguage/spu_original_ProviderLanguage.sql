SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [Mid].[spuProviderProcedureRefresh]
(
    @IsProviderDeltaProcessing bit = 0
)
as


declare @ErrorMessage varchar(1000)

begin try
        IF OBJECT_ID('tempdb..#ProviderBatch') IS NOT NULL DROP TABLE #ProviderBatch 
        CREATE TABLE #ProviderBatch (ProviderID uniqueidentifier)
        
        IF @IsProviderDeltaProcessing = 0
		BEGIN
            INSERT INTO #ProviderBatch (ProviderID) SELECT a.ProviderID FROM Base.Provider a ORDER BY a.ProviderID
        END
        ELSE
		BEGIN
            INSERT INTO #ProviderBatch (ProviderID)
            SELECT	a.ProviderID
            FROM	Snowflake.etl.ProviderDeltaProcessing as a
        END
		
	--build a temp table with the same structure as the Mid.ProviderProcedure
		IF OBJECT_ID('tempdb..#ProviderProcedure') IS NOT NULL DROP TABLE #ProviderProcedure
        SELECT	TOP 0 *
		INTO	#ProviderProcedure
		FROM	Mid.ProviderProcedure
		
		ALTER TABLE #ProviderProcedure
		ADD ActionCode int default 0
		
	--populate the temp table with data from Base schemas
		INSERT INTO #ProviderProcedure (ProviderToProcedureID,ProviderID, ProcedureCOde, ProcedureDescription,ProcedureGroupDescription, LegacyKey)
		SELECT		a.EntityToMedicalTermID as ProviderToProcedureID, a.EntityID as ProviderID, b.MedicalTermCode as ProcedureCode, b.MedicalTermDescription1 as ProcedureDescription, b.MedicalTermDescription2 as ProcedureGroupDescription, b.LegacyKey
		FROM		#ProviderBatch as pb  
		INNER JOIN	Base.EntityToMedicalTerm a with (nolock) 
					ON a.EntityID = pb.ProviderID
		INNER JOIN	Base.MedicalTerm b with (nolock) 
					ON b.MedicalTermID = a.MedicalTermID
		INNER JOIN	Base.EntityType d with (nolock) 
					ON d.EntityTypeID = a.EntityTypeID
		INNER JOIN	Base.MedicalTermSet e with (nolock) 
					ON e.MedicalTermSetID = b.MedicalTermSetID
		INNER JOIN	Base.MedicalTermType f with (nolock) 
					ON f.MedicalTermTypeID = b.MedicalTermTypeID
		WHERE		e.MedicalTermSetCode = 'HGProvider'
					AND f.MedicalTermTypeCode = 'Procedure'
		
		CREATE INDEX temp ON #ProviderProcedure (ProviderID)
		
        IF @IsProviderDeltaProcessing = 1
		BEGIN
			/*Update*/
			UPDATE		A
			SET			a.LegacyKey = b.LegacyKey,
						a.ProcedureCode = b.ProcedureCode,
						a.ProcedureDescription = b.ProcedureDescription,
						a.ProcedureGroupDescription = b.ProcedureGroupDescription,
						a.ProviderID = b.ProviderID
			--select *
			FROM		Mid.ProviderProcedure a with (nolock)
			INNER JOIN	#ProviderProcedure b 
						ON a.ProviderToProcedureID = b.ProviderToProcedureID
			WHERE		BINARY_CHECKSUM(isnull(cast(a.LegacyKey as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.LegacyKey as varchar(max)),''))
						OR BINARY_CHECKSUM(isnull(cast(a.ProcedureCode as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ProcedureCode as varchar(max)),''))
						OR BINARY_CHECKSUM(isnull(cast(a.ProcedureDescription as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ProcedureDescription as varchar(max)),''))
						OR BINARY_CHECKSUM(isnull(cast(a.ProcedureGroupDescription as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ProcedureGroupDescription as varchar(max)),''))
						OR BINARY_CHECKSUM(isnull(cast(a.ProviderID as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ProviderID as varchar(max)),''))

			/*Delete*/
			DELETE		A
			--select *
			FROM		Mid.ProviderProcedure a with (nolock)
			INNER JOIN	#ProviderBatch as pb 
						on pb.ProviderID = a.ProviderID	
			LEFT JOIN	#ProviderProcedure b 
						on (a.ProviderToProcedureID = b.ProviderToProcedureID)
			WHERE		b.ProviderToProcedureID IS NULL

			/*Insert*/
			INSERT INTO Mid.ProviderProcedure (LegacyKey,ProcedureCode,ProcedureDescription,ProcedureGroupDescription,ProviderID,ProviderToProcedureID)
			SELECT		A.LegacyKey, A.ProcedureCode, A.ProcedureDescription, A.ProcedureGroupDescription, A.ProviderID, A.ProviderToProcedureID 
			FROM		#ProviderProcedure A
			LEFT JOIN	Mid.ProviderProcedure b 
						ON a.ProviderToProcedureID = b.ProviderToProcedureID
			WHERE		b.ProviderToProcedureID IS NULL
		END
		
        IF @IsProviderDeltaProcessing = 0
		BEGIN
			TRUNCATE TABLE Mid.ProviderProcedure 
			INSERT INTO Mid.ProviderProcedure (LegacyKey,ProcedureCode,ProcedureDescription,ProcedureGroupDescription,ProviderID,ProviderToProcedureID)
			SELECT		A.LegacyKey, A.ProcedureCode, A.ProcedureDescription, A.ProcedureGroupDescription, A.ProviderID, A.ProviderToProcedureID 
			FROM		#ProviderProcedure A
		END
		
end try
begin catch
    set @ErrorMessage = 'Error in procedure Mid.spuProviderProcedureRefresh, line ' + convert(varchar(20), error_line()) + ': ' + error_message()
    raiserror(@ErrorMessage, 18, 1)
end catch
GO