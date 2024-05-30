CREATE OR REPLACE MATERIALIZED VIEW ODS1_STAGE_TEAM.RAW.VW_PRACTICE_PROFILE AS (

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Raw.VW_PRACTICE_PROFILE depends on:
--- MDM_TEAM.MST.PRACTICE_PROFILE_PROCESSING

---------------------------------------------------------
-------------------- 1. JSON Keys -----------------------
---------------------------------------------------------

--- Demographics

SELECT
    Process.MST_PRACTICE_PROFILE_ID AS MST_id,
    Process.CREATED_DATETIME AS CREATE_DATE,
    Process.REF_PRACTICE_CODE AS PracticeCode,
    Process.PRACTICE_PROFILE,
    
    -- Demographics
    TO_VARCHAR(Process.PRACTICE_PROFILE:DEMOGRAPHICS[0].PRACTICE_NAME) AS Demographics_PracticeName,
    TO_VARCHAR(Process.PRACTICE_PROFILE:DEMOGRAPHICS[0].PRACTICE_CODE) AS Demographics_PracticeCode,
    TO_VARCHAR(Process.PRACTICE_PROFILE:DEMOGRAPHICS[0].YEAR_PRACTICE_ESTABLISHED) AS Demographics_YearPracticeEstablished,
    TO_VARCHAR(Process.PRACTICE_PROFILE:DEMOGRAPHICS[0].LOGO) AS Demographics_Logo,
    TO_VARCHAR(Process.PRACTICE_PROFILE:DEMOGRAPHICS[0].MEDICAL_DIRECTOR) AS Demographics_MedicalDirector,
    TO_VARCHAR(Process.PRACTICE_PROFILE:DEMOGRAPHICS[0].NPI) AS Demographics_NPI,
    TO_VARCHAR(Process.PRACTICE_PROFILE:DEMOGRAPHICS[0].DATA_SOURCE_CODE) AS Demographics_SourceCode,
    TO_TIMESTAMP_NTZ(Process.PRACTICE_PROFILE:DEMOGRAPHICS[0].UPDATED_DATETIME) AS Demographics_LastUpdateDate
    
FROM MDM_TEAM.MST.PRACTICE_PROFILE_PROCESSING AS Process);