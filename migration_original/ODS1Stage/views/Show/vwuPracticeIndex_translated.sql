---------------------------------------------------------
---------------- 0. View dependencies -------------------
---------------------------------------------------------

-- Show.vwuPracticeIndex depends on: 
--- Show.SOLRPractice

CREATE OR REPLACE VIEW ODS1_STAGE.SHOW.VWUPRACTICEINDEX(
    PRACTICEID,
    PRACTICECODE,
    PRACTICEHGID,
    PRACTICENAME,
    YEARPRACTICEESTABLISHED,
    PRACTICEEMAILXML,
    PRACTICEWEBSITE,
    PRACTICEDESCRIPTION,
    PRACTICELOGO,
    PRACTICEMEDICALDIRECTOR,
    PHYSICIANCOUNT,
    HASDENTIST,
    OFFICEXML,
    SPONSORSHIPXML
) AS
SELECT
  p.PracticeID,
  p.PracticeCode,
  IFNULL(
    p.LegacyKeyPractice,
    'HGPPZ' || LEFT(REPLACE(p.PracticeID, '-', ''), 16)
  ) AS PracticeHGID,
  p.PracticeName,
  p.YearPracticeEstablished,
  p.PracticeEmailXML,
  p.PracticeWebsite,
  p.PracticeDescription,
  p.PracticeLogo,
  p.PracticeMedicalDirector,
  p.PhysicianCount,
  p.HasDentist,
  p.OfficeXML,
  p.SponsorshipXML
FROM Show.SOLRPractice AS p
WHERE p.OfficeXML IS NOT NULL;