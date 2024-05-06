-- 1. spuSOLRTreatmentEntryLevel
TRUNCATE TABLE [Show].[SOLRTreatmentEntryLevel]
	INSERT INTO [Show].[SOLRTreatmentEntryLevel]
	(DCPCode,TreatmentLevelDescription,SpecialtyCode,SpecialtyDescription,ForMarketViewLoad)
	SELECT DISTINCT c.RefMedicalTermCode AS DCPCode, a.TreatmentLevelDescription, b.SpecialtyCode, b.SpecialtyDescription, a.IsMarketView AS ForMarketViewLoad
	FROM
	(
		--REPLACEMENT FOR DataScience.dbo.SpecialtyToMedicalTerm
		SELECT a.SpecialtyID, a.ConditionID AS MedicalTermID, b.TreatmentLevelDescription, b.IsMarketView
		FROM ODS1Stage.Base.SpecialtyToCondition a
		JOIN ODS1Stage.Base.TreatmentLevel b ON b.TreatmentLevelID = a.TreatmentLevelID
		UNION
		SELECT a.SpecialtyID, a.ProcedureMedicalID AS MedicalTermID, b.TreatmentLevelDescription, b.IsMarketView
		FROM ODS1Stage.Base.SpecialtyToProcedureMedical a
		JOIN ODS1Stage.Base.TreatmentLevel b ON b.TreatmentLevelID = a.TreatmentLevelID
	)a
	JOIN ODS1Stage.Base.Specialty b ON b.SpecialtyID = a.SpecialtyID
	JOIN ODS1Stage.Base.MedicalTerm c ON c.MedicalTermID = a.MedicalTermID
