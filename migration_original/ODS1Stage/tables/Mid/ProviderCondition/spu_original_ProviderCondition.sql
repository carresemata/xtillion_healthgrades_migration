SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [Mid].[spuProviderConditionRefresh]
(
    @IsProviderDeltaProcessing bit = 0
)
as

/*
    Created By:		John Tran
	Created On:		12/30/2011	

	Reoccurence:	This stored procedure will INSERT/UPDATE/DELETE data from the Mid.ProviderCondition table that is used for the Provider SOLR Core

	Updated By:		Zafer Faddah
	Updated On:		08/27/2014
	Update Note:	Replaced dbo.Individual with src.Provider 

	Test:			EXEC Mid.spuProviderConditionRefresh
						
*/


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

	--build a temp table with the same structure as the Mid.ProviderCondition
		IF OBJECT_ID('tempdb..#ProviderCondition') IS NOT NULL DROP TABLE #ProviderCondition
        SELECT TOP 0 *
		INTO	#ProviderCondition
		FROM	Mid.ProviderCondition
		
		ALTER TABLE #ProviderCondition
		ADD ActionCode int default 0
		
		CREATE CLUSTERED INDEX [CIX_TempProviderBatchConditionProviderId]	ON #ProviderBatch([ProviderID])

	--populate the temp table with data from Base schemas
		INSERT INTO	#ProviderCondition (ProviderToConditionID,ProviderID,ConditionCode,ConditionDescription,ConditionGroupDescription,LegacyKey)
		SELECT		a.EntityToMedicalTermID as ProviderToConditionID, a.EntityID as ProviderID, b.MedicalTermCode as ConditionCode, b.MedicalTermDescription1 as ConditionDescription, b.MedicalTermDescription2 ConditionGroupDescription, b.LegacyKey
		FROM		#ProviderBatch as pb 
		INNER JOIN	Base.EntityToMedicalTerm as a with (nolock) 
					on a.EntityID = pb.ProviderID
		INNER JOIN	Base.MedicalTerm as b with (nolock) 
					on b.MedicalTermID = a.MedicalTermID
		INNER JOIN	Base.EntityType as d with (nolock) 
					on d.EntityTypeID = a.EntityTypeID
		INNER JOIN	Base.MedicalTermSet as e with (nolock) 
					on e.MedicalTermSetID = b.MedicalTermSetID
		INNER JOIN	Base.MedicalTermType as f with (nolock) 
					on f.MedicalTermTypeID = b.MedicalTermTypeID
		WHERE		e.MedicalTermSetCode = 'HGProvider'
					and f.MedicalTermTypeCode = 'Condition'
		
		CREATE INDEX temp on #ProviderCondition (ProviderToConditionID)

        IF @IsProviderDeltaProcessing = 1
		BEGIN
			/*Updates*/
			UPDATE		A
			SET			a.ConditionCode = b.ConditionCode,
						a.ConditionDescription = b.ConditionDescription,
						a.ConditionGroupDescription = b.ConditionGroupDescription,
						a.LegacyKey = b.LegacyKey,
						a.ProviderID = b.ProviderID
			FROM		#ProviderCondition a
			INNER JOIN	Mid.ProviderCondition b with (nolock) 
						ON (a.ProviderToConditionID = b.ProviderToConditionID)
			WHERE		BINARY_CHECKSUM(isnull(cast(a.ConditionCode as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ConditionCode as varchar(max)),''))
						OR BINARY_CHECKSUM(isnull(cast(a.ConditionDescription as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ConditionDescription as varchar(max)),''))
						OR BINARY_CHECKSUM(isnull(cast(a.ConditionGroupDescription as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ConditionGroupDescription as varchar(max)),''))
						OR BINARY_CHECKSUM(isnull(cast(a.LegacyKey as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.LegacyKey as varchar(max)),''))
						OR BINARY_CHECKSUM(isnull(cast(a.ProviderID as varchar(max)),'')) <> BINARY_CHECKSUM(isnull(cast(b.ProviderID as varchar(max)),''))

			/*Inserts*/
			INSERT INTO Mid.ProviderCondition (ConditionCode,ConditionDescription,ConditionGroupDescription,LegacyKey,ProviderID,ProviderToConditionID)
			SELECT		A.ConditionCode, A.ConditionDescription, A.ConditionGroupDescription, A.LegacyKey, A.ProviderID, A.ProviderToConditionID 
			FROM		#ProviderCondition A
			LEFT JOIN	Mid.ProviderCondition B
						ON a.ProviderToConditionID = b.ProviderToConditionID
			WHERE		b.ProviderToConditionID is null
			
			/*Deletes*/
			DELETE		A
			--select *
			FROM		Mid.ProviderCondition a with (nolock)
            INNER JOIN	#ProviderBatch as pb 
						on pb.ProviderID = a.ProviderID	
			LEFT JOIN	#ProviderCondition b 
						on (a.ProviderToConditionID = b.ProviderToConditionID)
			WHERE		b.ProviderToConditionID is null
	
		END

        IF @IsProviderDeltaProcessing = 0
		BEGIN
			/*Full Inserts*/
			TRUNCATE TABLE Mid.ProviderCondition 
			INSERT INTO Mid.ProviderCondition (ConditionCode,ConditionDescription,ConditionGroupDescription,LegacyKey,ProviderID,ProviderToConditionID)
			SELECT		A.ConditionCode, A.ConditionDescription, A.ConditionGroupDescription, A.LegacyKey, A.ProviderID, A.ProviderToConditionID 
			FROM		#ProviderCondition A
		END

end try
begin catch
    set @ErrorMessage = 'Error in procedure Mid.spuProviderConditionRefresh, line ' + convert(varchar(20), error_line()) + ': ' + error_message()
    raiserror(@ErrorMessage, 18, 1)
end catch
GO
