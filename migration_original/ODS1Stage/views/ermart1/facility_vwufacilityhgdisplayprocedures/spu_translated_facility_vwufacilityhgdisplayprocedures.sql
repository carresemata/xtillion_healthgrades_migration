CREATE OR REPLACE VIEW ODS1_STAGE_TEAM.ERMART1.FACILITY_VWUFACILITYHGDISPLAYPROCEDURES AS 

---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
-- ermart1.facility_vwufacilityhgdisplayprocedures depends on:
-- hosp_directory.dbo_hosp_cohort

---------------------------------------------------------
--------------------- 1. columns ------------------------
---------------------------------------------------------
-- procedureid
-- ratingsourceid

SELECT 
	proc_code AS ProcedureID,
	is_state AS RatingSourceID
FROM hosp_directory.dbo_hosp_cohort
WHERE active = 1;
