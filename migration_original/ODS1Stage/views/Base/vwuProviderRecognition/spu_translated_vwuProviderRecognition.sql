CREATE OR REPLACE VIEW ODS1_STAGE.BASE.VWUPROVIDERRECOGNITION AS

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.VWUProviderRecognition depends on:
--- Base.ProviderSanction
--- Base.SanctionAction
--- Base.ProviderMalpractice
--- Base.Provider
--- Base.Award
--- Base.ProviderToCertificationSpecialty
--- Base.CertificationStatus

---------------------------------------------------------
--------------------- 1. Columns ------------------------
---------------------------------------------------------
-- ProviderID
-- AwardID


WITH CTE_ProviderSanctions AS (
    SELECT DISTINCT ps.ProviderID
    FROM Base.ProviderSanction ps
    LEFT OUTER JOIN Base.SanctionAction sa ON ps.SanctionActionID = sa.SanctionActionID
    WHERE sa.SanctionActionDescription IN ('Probation','Revocation','Probation Modification Order',
        'Probation Terminated (Ended)','Surrender','Suspension')
        OR DATEADD(YEAR, 5, ps.SanctionDate) > CURRENT_TIMESTAMP()
),
CTE_ProviderMalpractices AS (
    SELECT pm.ProviderID
    FROM Base.ProviderMalpractice pm
    WHERE DATEADD(YEAR, 5, TRY_CAST(
        CASE
            WHEN pm.ClaimDate > '5000-01-01' THEN DATE('5000-01-01')
            ELSE DATE(pm.ClaimDate)
        END AS DATE
    )) > CURRENT_TIMESTAMP()
    OR DATEADD(YEAR, 5, TRY_CAST(DATE(pm.ClosedDate) AS DATE)) > CURRENT_TIMESTAMP()
    OR DATEADD(YEAR, 5, TRY_CAST(DATE(pm.IncidentDate) AS DATE)) > CURRENT_TIMESTAMP()
    OR DATEADD(YEAR, 5, TRY_CAST(DATE(pm.ReportDate) AS DATE)) > CURRENT_TIMESTAMP()
    OR DATEADD(YEAR, 5, CAST('12/31/' || CAST(pm.ClaimYear AS VARCHAR) AS DATETIME)) > CURRENT_TIMESTAMP()
)
SELECT DISTINCT p.ProviderID, a.AwardID
FROM Base.Provider p
INNER JOIN Base.Award a ON a.AwardCode = 'HGRECOG'
INNER JOIN Base.ProviderToCertificationSpecialty ptcs ON ptcs.ProviderID = p.ProviderID
INNER JOIN Base.CertificationStatus AS cs ON cs.CertificationStatusID = ptcs.CertificationStatusID AND cs.CertificationStatusCode = 'C'
LEFT OUTER JOIN CTE_ProviderSanctions ps ON p.ProviderID = ps.ProviderID
LEFT OUTER JOIN CTE_ProviderMalpractices pm ON p.ProviderID = pm.ProviderID
WHERE ps.ProviderID IS NULL AND pm.ProviderID IS NULL;
