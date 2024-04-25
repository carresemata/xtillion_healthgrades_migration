CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERLASTUPDATEDATE()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 

DECLARE
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
--- Base.ProviderLastUpdateDate depends on:
-- Base.ProviderProfileProcessing
-- Base.Provider
-- Base.ProviderToAboutMe
-- Base.ProviderAppointmentAvailabilityStatement
-- Base.ProviderEmail
-- Base.ProviderLicense
-- Base.ProviderToOffice
-- Base.ProviderToProviderType
-- Base.ProviderToSubStatus
-- Base.ProviderToAppointmentAvailability
-- Base.ProviderToCertificationSpecialty
-- Base.ProviderToFacility
-- Base.ProviderImage
-- Base.ProviderMalpractice
-- Base.ProviderToOrganization
-- Base.ClientProductToEntity
-- Base.ClientToProduct
-- Base.Product
-- Base.ProviderToDegree
-- Base.ProviderToEducationInstitution
-- Base.ProviderToHealthInsurance
-- Base.ProviderToLanguage
-- Base.ProviderMedia
-- Base.ProviderToSpecialty
-- Base.ProviderVideo
-- Base.ProviderToTelehealthMethod
-- Base.EntityToMedicalTerm
-- Base.MedicalTerm
-- Base.MedicalTermType
-- Base.ProviderToProviderSubType
-- Base.ProviderTraining
-- Base.ProviderIdentification

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
select_statement STRING;
insert_statement STRING;
delete_statement STRING;
merge_statement STRING;
status STRING;

---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------  
BEGIN
-- no conditionals
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

select_statement := $$
                    WITH CTE_Provider AS (
                        SELECT ppp.ProviderID
                        FROM raw.ProviderProfileProcessing ppp 
                        INNER JOIN Base.Provider p ON p.ProviderCode = ppp.Provider_Code
                    ),
                    
                    CTE_Demographics AS (
                        SELECT p.ProviderID, p.SourceCode, p.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.Provider p ON p.ProviderID = cte_p.ProviderID
                    ),
                    
                    CTE_AboutMe AS (
                        SELECT ptam.ProviderID, ptam.SourceCode, ptam.LastUpdatedDate AS LastUpdateDate
                        FROM CTE_Provider p
                        INNER JOIN Base.ProviderToAboutMe ptam ON ptam.ProviderID = p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY ptam.ProviderID ORDER BY ptam.LastUpdatedDate DESC) = 1
                    ),
                    
                    CTE_AppointmentAvailabilityStatement AS (
                        SELECT paas.ProviderID, paas.SourceCode, paas.LastUpdatedDate AS LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderAppointmentAvailabilityStatement paas ON paas.ProviderID = cte_p.ProviderID
                    ),
                    
                    CTE_Email AS (
                        SELECT pe.ProviderID, pe.SourceCode, pe.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderEmail pe ON pe.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY pe.ProviderID ORDER BY pe.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_License AS (
                        SELECT pl.ProviderID, pl.SourceCode, pl.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderLicense pl ON pl.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY pl.ProviderID ORDER BY pl.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Office AS (
                        SELECT pto.ProviderID, pto.SourceCode, pto.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderToOffice pto ON pto.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY pto.ProviderID ORDER BY pto.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_ProviderType AS (
                        SELECT ptpt.ProviderID, ptpt.SourceCode, ptpt.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderToProviderType ptpt ON ptpt.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY ptpt.ProviderID ORDER BY ptpt.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Status AS (
                        SELECT ptss.ProviderID, ptss.SourceCode, ptss.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderToSubStatus ptss ON ptss.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY ptss.ProviderID ORDER BY ptss.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_AppointmentAvailability AS (
                        SELECT ptaa.ProviderID, ptaa.SourceCode, ptaa.LastUpdatedDate AS LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderToAppointmentAvailability ptaa ON ptaa.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY ptaa.ProviderID ORDER BY ptaa.LastUpdatedDate DESC) = 1
                    ),
                    
                    CTE_CertificationSpecialty AS (
                        SELECT ptcs.ProviderID, ptcs.SourceCode, ptcs.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderToCertificationSpecialty ptcs ON ptcs.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY ptcs.ProviderID ORDER BY ptcs.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Facility AS (
                        SELECT ptf.ProviderID, ptf.SourceCode, ptf.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderToFacility ptf ON ptf.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY ptf.ProviderID ORDER BY ptf.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Image AS (
                        SELECT i.ProviderID, i.SourceCode, i.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderImage i ON i.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY i.ProviderID ORDER BY i.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Malpractice AS (
                        SELECT m.ProviderID, m.SourceCode, m.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderMalpractice m ON m.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY m.ProviderID ORDER BY m.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Organization AS (
                        SELECT pto.ProviderID, pto.SourceCode, pto.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderToOrganization pto ON pto.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY pto.ProviderID ORDER BY pto.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Sponsorship AS (
                        SELECT cpte.EntityID AS ProviderID, ctp.ClientToProductCode AS SourceCode, cpte.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ClientProductToEntity cpte ON cpte.EntityID = cte_p.ProviderID
                        INNER JOIN Base.EntityType et ON et.EntityTypeCode = 'PROV'
                        INNER JOIN Base.ClientToProduct ctp ON cpte.ClientToProductID = ctp.ClientToProductID
                        INNER JOIN Base.Product prod ON prod.ProductID = ctp.ProductID AND prod.ProductCode != 'LID'
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY cpte.EntityID ORDER BY cpte.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Degree AS (
                        SELECT ptd.ProviderID, ptd.SourceCode, ptd.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderToDegree ptd ON ptd.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY ptd.ProviderID ORDER BY ptd.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Education AS (
                        SELECT ptei.ProviderID, ptei.SourceCode, ptei.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderToEducationInstitution ptei ON ptei.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY ptei.ProviderID ORDER BY ptei.LastUpdateDate DESC) = 1
                    ), 
                    
                    CTE_HealthInsurance AS (
                        SELECT pthi.ProviderID, pthi.SourceCode, pthi.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN ProviderToHealthInsurance pthi ON pthi.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY pthi.ProviderID ORDER BY pthi.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Language AS (
                        SELECT ptl.ProviderID, ptl.SourceCode, ptl.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderToLanguage ptl ON ptl.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY ptl.ProviderID ORDER BY ptl.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Media AS (
                        SELECT pm.ProviderID, pm.SourceCode, pm.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderMedia pm ON pm.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY pm.ProviderID ORDER BY pm.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Specialty AS (
                        SELECT ps.ProviderID, ps.SourceCode, ps.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderToSpecialty ps ON ps.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY ps.ProviderID ORDER BY ps.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Video AS (
                        SELECT pv.ProviderID, pv.SourceCode, pv.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderVideo pv ON pv.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY pv.ProviderID ORDER BY pv.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Telehealth AS (
                        SELECT pt.ProviderID, pt.SourceCode, pt.LastUpdatedDate AS LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderToTelehealthMethod pt ON pt.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY pt.ProviderID ORDER BY pt.LastUpdatedDate DESC) = 1
                    ),
                    
                    CTE_Condition AS (
                        SELECT etmt.EntityID AS ProviderID, etmt.SourceCode, etmt.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.EntityToMedicalTerm etmt ON etmt.EntityID = cte_p.ProviderID
                        INNER JOIN Base.MedicalTerm mt ON mt.MedicalTermID = etmt.MedicalTermID
                        INNER JOIN Base.MedicalTermType mtt ON mtt.MedicalTermTypeID = mt.MedicalTermTypeID AND mtt.MedicalTermTypeCode = 'Condition'
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY etmt.EntityID ORDER BY etmt.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Procedure AS (
                        SELECT etmt.EntityID AS ProviderID, etmt.SourceCode, etmt.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.EntityToMedicalTerm etmt ON etmt.EntityID = cte_p.ProviderID
                        INNER JOIN Base.MedicalTerm mt ON mt.MedicalTermID = etmt.MedicalTermID
                        INNER JOIN Base.MedicalTermType mtt ON mtt.MedicalTermTypeID = mt.MedicalTermTypeID AND mtt.MedicalTermTypeCode = 'Procedure'
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY etmt.EntityID ORDER BY etmt.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_ProviderSubType AS (
                        SELECT ptpst.ProviderID, ptpst.SourceCode, ptpst.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderToProviderSubType ptpst ON ptpst.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY ptpst.ProviderID ORDER BY ptpst.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Training AS (
                        SELECT pt.ProviderID, pt.SourceCode, pt.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderTraining pt ON pt.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY pt.ProviderID ORDER BY pt.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_Identification AS (
                        SELECT pid.ProviderID, pid.SourceCode, pid.LastUpdateDate
                        FROM CTE_Provider cte_p
                        INNER JOIN Base.ProviderIdentification pid ON pid.ProviderID = cte_p.ProviderID
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY pid.ProviderID ORDER BY pid.LastUpdateDate DESC) = 1
                    ),
                    
                    CTE_DemographicsXML AS (
                        SELECT 
                        cte_p.ProviderID,
                        Show.p_json_to_xml(
                            ARRAY_AGG(
                                '{ '||
                                IFF(cte_d.SourceCode IS NOT NULL, '"SourceCode":' || '"' || cte_d.SourceCode || '"' || ',', '') ||
                                IFF(cte_d.LastUpdateDate IS NOT NULL, '"LastUpdateDate":' || '"' || cte_d.LastUpdateDate || '"', '')
                                ||' }'
                            )::VARCHAR, 
                            'Demographics', 
                            ''
                        ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Demographics cte_d ON cte_d.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_AboutMeXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                '{ '||
                                IFF(cte_am.SourceCode IS NOT NULL, '"SourceCode":' || '"' || cte_am.SourceCode || '"' || ',', '') ||
                                IFF(cte_am.LastUpdateDate IS NOT NULL, '"LastUpdateDate":' || '"' || cte_am.LastUpdateDate || '"', '')
                                ||' }'
                                )::VARCHAR, 
                                'AboutMe', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_AboutMe cte_am ON cte_am.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_AppointmentAvailabilityStatementXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                '{ '||
                                IFF(cte_aas.SourceCode IS NOT NULL, '"SourceCode":' || '"' || cte_aas.SourceCode || '"' || ',', '') ||
                                IFF(cte_aas.LastUpdateDate IS NOT NULL, '"LastUpdateDate":' || '"' || cte_aas.LastUpdateDate || '"', '')
                                ||' }'
                                )::VARCHAR, 
                                'AppointmentAvailabilityStatement', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_AppointmentAvailabilityStatement cte_aas ON cte_aas.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_EmailXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                '{ '||
                                IFF(cte_e.SourceCode IS NOT NULL, '"SourceCode":' || '"' || cte_e.SourceCode || '"' || ',', '') ||
                                IFF(cte_e.LastUpdateDate IS NOT NULL, '"LastUpdateDate":' || '"' || cte_e.LastUpdateDate || '"', '')
                                ||' }'
                                )::VARCHAR, 
                                'Email', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Email cte_e ON cte_e.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_LicenseXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                '{ '||
                                IFF(cte_l.SourceCode IS NOT NULL, '"SourceCode":' || '"' || cte_l.SourceCode || '"' || ',', '') ||
                                IFF(cte_l.LastUpdateDate IS NOT NULL, '"LastUpdateDate":' || '"' || cte_l.LastUpdateDate || '"', '')
                                ||' }'
                                )::VARCHAR, 
                                'License', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_License cte_l ON cte_l.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_OfficeXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{ '||
                                    IFF(cte_o.SourceCode IS NOT NULL, '"SourceCode":' || '"' || cte_o.SourceCode || '"' || ',', '') ||
                                    IFF(cte_o.LastUpdateDate IS NOT NULL, '"LastUpdateDate":' || '"' || cte_o.LastUpdateDate || '"', '')
                                    ||' }'
                                )::VARCHAR, 
                                'Office', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Office cte_o ON cte_o.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_ProviderTypeXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{ '||
                                    IFF(cte_pt.SourceCode IS NOT NULL, '"SourceCode":' || '"' || cte_pt.SourceCode || '"' || ',', '') ||
                                    IFF(cte_pt.LastUpdateDate IS NOT NULL, '"LastUpdateDate":' || '"' || cte_pt.LastUpdateDate || '"', '')
                                    ||' }'
                                )::VARCHAR, 
                                'ProviderType', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_ProviderType cte_pt ON cte_pt.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_StatusXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{ '||
                                    IFF(cte_s.SourceCode IS NOT NULL, '"SourceCode":' || '"' || cte_s.SourceCode || '"' || ',', '') ||
                                    IFF(cte_s.LastUpdateDate IS NOT NULL, '"LastUpdateDate":' || '"' || cte_s.LastUpdateDate || '"', '')
                                    ||' }'
                                )::VARCHAR, 
                                'Status', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Status cte_s ON cte_s.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_AppointmentAvailabilityXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{ '||
                                    IFF(cte_aa.SourceCode IS NOT NULL, '"SourceCode":' || '"' || cte_aa.SourceCode || '"' || ',', '') ||
                                    IFF(cte_aa.LastUpdateDate IS NOT NULL, '"LastUpdateDate":' || '"' || cte_aa.LastUpdateDate || '"', '')
                                    ||' }'
                                )::VARCHAR, 
                                'AppointmentAvailability', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_AppointmentAvailability cte_aa ON cte_aa.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_CertificationSpecialtyXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{ '||
                                    IFF(cte_cs.SourceCode IS NOT NULL, '"SourceCode":' || '"' || cte_cs.SourceCode || '"' || ',', '') ||
                                    IFF(cte_cs.LastUpdateDate IS NOT NULL, '"LastUpdateDate":' || '"' || cte_cs.LastUpdateDate || '"', '')
                                    ||' }'
                                )::VARCHAR, 
                                'CertificationSpecialty', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_CertificationSpecialty cte_cs ON cte_cs.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_FacilityXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{ '||
                                    IFF(cte_f.SourceCode IS NOT NULL, '"SourceCode":' || '"' || cte_f.SourceCode || '"' || ',', '') ||
                                    IFF(cte_f.LastUpdateDate IS NOT NULL, '"LastUpdateDate":' || '"' || cte_f.LastUpdateDate || '"', '')
                                    ||' }'
                                )::VARCHAR, 
                                'Facility', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Facility cte_f ON cte_f.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_ImageXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{ '||
                                    IFF(cte_i.SourceCode IS NOT NULL, '"SourceCode":' || '"' || cte_i.SourceCode || '"' || ',', '') ||
                                    IFF(cte_i.LastUpdateDate IS NOT NULL, '"LastUpdateDate":' || '"' || cte_i.LastUpdateDate || '"', '')
                                    ||' }'
                                )::VARCHAR, 
                                'Image', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Image cte_i ON cte_i.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_MalpracticeXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{ '||
                                    IFF(cte_m.SourceCode IS NOT NULL, '"SourceCode":' || '"' || cte_m.SourceCode || '"' || ',', '') ||
                                    IFF(cte_m.LastUpdateDate IS NOT NULL, '"LastUpdateDate":' || '"' || cte_m.LastUpdateDate || '"', '')
                                    ||' }'
                                )::VARCHAR, 
                                'Malpractice', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Malpractice cte_m ON cte_m.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_OrganizationXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{ '||
                                    IFF(cte_o.SourceCode IS NOT NULL, '"SourceCode":' || '"' || cte_o.SourceCode || '"' || ',', '') ||
                                    IFF(cte_o.LastUpdateDate IS NOT NULL, '"LastUpdateDate":' || '"' || cte_o.LastUpdateDate || '"', '')
                                    ||' }'
                                )::VARCHAR, 
                                'Organization', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Organization cte_o ON cte_o.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_SponsorshipXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{' ||
                                    IFF(cte_s.SourceCode IS NOT NULL, '"SourceCode":"' || cte_s.SourceCode || '"', '') ||
                                    IFF(cte_s.LastUpdateDate IS NOT NULL, ',"LastUpdateDate":"' || cte_s.LastUpdateDate || '"', '')
                                    || '}'
                                )::VARCHAR, 
                                'Sponsorship', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Sponsorship cte_s ON cte_s.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_DegreeXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{' ||
                                    IFF(cte_d.SourceCode IS NOT NULL, '"SourceCode":"' || cte_d.SourceCode || '"', '') ||
                                    IFF(cte_d.LastUpdateDate IS NOT NULL, ',"LastUpdateDate":"' || cte_d.LastUpdateDate || '"', '')
                                    || '}'
                                )::VARCHAR, 
                                'Degree', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Degree cte_d ON cte_d.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_EducationXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{' ||
                                    IFF(cte_e.SourceCode IS NOT NULL, '"SourceCode":"' || cte_e.SourceCode || '"', '') ||
                                    IFF(cte_e.LastUpdateDate IS NOT NULL, ',"LastUpdateDate":"' || cte_e.LastUpdateDate || '"', '')
                                    || '}'
                                )::VARCHAR, 
                                'Education', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Education cte_e ON cte_e.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_HealthInsuranceXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{' ||
                                    IFF(cte_hi.SourceCode IS NOT NULL, '"SourceCode":"' || cte_hi.SourceCode || '"', '') ||
                                    IFF(cte_hi.LastUpdateDate IS NOT NULL, ',"LastUpdateDate":"' || cte_hi.LastUpdateDate || '"', '') 
                                    || '}'
                                )::VARCHAR, 
                                'HealthInsurance', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_HealthInsurance cte_hi ON cte_hi.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_LanguageXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{' ||
                                    IFF(cte_l.SourceCode IS NOT NULL, '"SourceCode":"' || cte_l.SourceCode || '"', '') ||
                                    IFF(cte_l.LastUpdateDate IS NOT NULL, ',"LastUpdateDate":"' || cte_l.LastUpdateDate || '"', '') 
                                    || '}'
                                )::VARCHAR, 
                                'Language', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Language cte_l ON cte_l.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_MediaXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{' ||
                                    IFF(cte_m.SourceCode IS NOT NULL, '"SourceCode":"' || cte_m.SourceCode || '"', '') ||
                                    IFF(cte_m.LastUpdateDate IS NOT NULL, ',"LastUpdateDate":"' || cte_m.LastUpdateDate || '"', '') 
                                    || '}'
                                )::VARCHAR, 
                                'Media', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Media cte_m ON cte_m.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    
                    CTE_SpecialtyXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{' ||
                                    IFF(cte_s.SourceCode IS NOT NULL, '"SourceCode":"' || cte_s.SourceCode || '"', '') ||
                                    IFF(cte_s.LastUpdateDate IS NOT NULL, ',"LastUpdateDate":"' || cte_s.LastUpdateDate || '"', '') 
                                    || '}'
                                )::VARCHAR, 
                                'Specialty', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Specialty cte_s ON cte_s.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_VideoXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{' ||
                                    IFF(cte_v.SourceCode IS NOT NULL, '"SourceCode":"' || cte_v.SourceCode || '"', '') ||
                                    IFF(cte_v.LastUpdateDate IS NOT NULL, ',"LastUpdateDate":"' || cte_v.LastUpdateDate || '"', '') 
                                    || '}'
                                )::VARCHAR, 
                                'Video', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Video cte_v ON cte_v.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_TelehealthXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{' ||
                                    IFF(cte_th.SourceCode IS NOT NULL, '"SourceCode":"' || cte_th.SourceCode || '"', '') ||
                                    IFF(cte_th.LastUpdateDate IS NOT NULL, ',"LastUpdateDate":"' || cte_th.LastUpdateDate || '"', '') 
                                    || '}'
                                )::VARCHAR, 
                                'Telehealth', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Telehealth cte_th ON cte_th.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_ConditionXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{' ||
                                    IFF(cte_c.SourceCode IS NOT NULL, '"SourceCode":"' || cte_c.SourceCode || '"', '') ||
                                    IFF(cte_c.LastUpdateDate IS NOT NULL, ',"LastUpdateDate":"' || cte_c.LastUpdateDate || '"', '') 
                                    || '}'
                                )::VARCHAR, 
                                'Condition', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Condition cte_c ON cte_c.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_ProcedureXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{' ||
                                    IFF(cte_pr.SourceCode IS NOT NULL, '"SourceCode":"' || cte_pr.SourceCode || '"', '') ||
                                    IFF(cte_pr.LastUpdateDate IS NOT NULL, ',"LastUpdateDate":"' || cte_pr.LastUpdateDate || '"', '') 
                                    || '}'
                                )::VARCHAR, 
                                'Procedure', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Procedure cte_pr ON cte_pr.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_ProviderSubTypeXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{' ||
                                    IFF(cte_pst.SourceCode IS NOT NULL, '"SourceCode":"' || cte_pst.SourceCode || '"', '') ||
                                    IFF(cte_pst.LastUpdateDate IS NOT NULL, ',"LastUpdateDate":"' || cte_pst.LastUpdateDate || '"', '') 
                                    || '}'
                                )::VARCHAR, 
                                'ProviderSubType', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_ProviderSubType cte_pst ON cte_pst.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_TrainingXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{' ||
                                    IFF(cte_t.SourceCode IS NOT NULL, '"SourceCode":"' || cte_t.SourceCode || '"', '') ||
                                    IFF(cte_t.LastUpdateDate IS NOT NULL, ',"LastUpdateDate":"' || cte_t.LastUpdateDate || '"', '') 
                                    || '}'
                                )::VARCHAR, 
                                'Training', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Training cte_t ON cte_t.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_IdentificationXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            Show.p_json_to_xml(
                                ARRAY_AGG(
                                    '{' ||
                                    IFF(cte_i.SourceCode IS NOT NULL, '"SourceCode":"' || cte_i.SourceCode || '"', '') ||
                                    IFF(cte_i.LastUpdateDate IS NOT NULL, ',"LastUpdateDate":"' || cte_i.LastUpdateDate || '"', '') 
                                    || '}'
                                )::VARCHAR, 
                                'Identification', 
                                ''
                            ) AS XML
                        FROM CTE_Provider cte_p
                        INNER JOIN CTE_Identification cte_i ON cte_i.ProviderID = cte_p.ProviderID
                        GROUP BY cte_p.ProviderID
                    ),
                    
                    CTE_FinalXML AS (
                        SELECT 
                            cte_p.ProviderID,
                            '<LastUpdateDateBySwimlane>' || 
                            COALESCE(cte_d.XML, '') ||
                            COALESCE(cte_am.XML, '') ||
                            COALESCE(cte_aas.XML, '') ||
                            COALESCE(cte_e.XML, '') ||
                            COALESCE(cte_l.XML, '') ||
                            COALESCE(cte_o.XML, '') ||
                            COALESCE(cte_pt.XML, '') ||
                            COALESCE(cte_s.XML, '') ||
                            COALESCE(cte_aa.XML, '') ||
                            COALESCE(cte_cs.XML, '') ||
                            COALESCE(cte_f.XML, '') ||
                            COALESCE(cte_i.XML, '') ||
                            COALESCE(cte_m.XML, '') ||
                            COALESCE(cte_org.XML, '') ||
                            COALESCE(cte_sp.XML, '') ||
                            COALESCE(cte_deg.XML, '') ||
                            COALESCE(cte_edu.XML, '') ||
                            COALESCE(cte_hi.XML, '') ||
                            COALESCE(cte_lang.XML, '') ||
                            COALESCE(cte_med.XML, '') ||
                            COALESCE(cte_spec.XML, '') ||
                            COALESCE(cte_v.XML, '') ||
                            COALESCE(cte_th.XML, '') ||
                            COALESCE(cte_c.XML, '') ||
                            COALESCE(cte_pr.XML, '') ||
                            COALESCE(cte_pst.XML, '') ||
                            COALESCE(cte_t.XML, '') ||
                            COALESCE(cte_iid.XML, '') ||
                            '</LastUpdateDateBySwimlane>' AS LastUpdateDatePayload
                        FROM CTE_Provider cte_p
                        LEFT JOIN CTE_DemographicsXML cte_d ON cte_d.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_AboutMeXML cte_am ON cte_am.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_AppointmentAvailabilityStatementXML cte_aas ON cte_aas.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_EmailXML cte_e ON cte_e.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_LicenseXML cte_l ON cte_l.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_OfficeXML cte_o ON cte_o.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_ProviderTypeXML cte_pt ON cte_pt.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_StatusXML cte_s ON cte_s.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_AppointmentAvailabilityXML cte_aa ON cte_aa.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_CertificationSpecialtyXML cte_cs ON cte_cs.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_FacilityXML cte_f ON cte_f.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_ImageXML cte_i ON cte_i.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_MalpracticeXML cte_m ON cte_m.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_OrganizationXML cte_org ON cte_org.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_SponsorshipXML cte_sp ON cte_sp.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_DegreeXML cte_deg ON cte_deg.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_EducationXML cte_edu ON cte_edu.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_HealthInsuranceXML cte_hi ON cte_hi.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_LanguageXML cte_lang ON cte_lang.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_MediaXML cte_med ON cte_med.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_SpecialtyXML cte_spec ON cte_spec.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_VideoXML cte_v ON cte_v.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_TelehealthXML cte_th ON cte_th.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_ConditionXML cte_c ON cte_c.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_ProcedureXML cte_pr ON cte_pr.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_ProviderSubTypeXML cte_pst ON cte_pst.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_TrainingXML cte_t ON cte_t.ProviderID = cte_p.ProviderID
                        LEFT JOIN CTE_IdentificationXML cte_iid ON cte_iid.ProviderID = cte_p.ProviderID
                    )

                    SELECT ProviderID, LastUpdateDatePayload
                    FROM CTE_FinalXML
                    $$;


insert_statement := $$ 
                    INSERT
                        (
                        ProviderID, 
                        LastUpdateDatePayload
                        )
                     VALUES 
                        (
                        source.ProviderID, 
                        TO_VARIANT(source.LastUpdateDatePayload)
                        )
                     $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := $$ MERGE INTO Base.ProviderLastUpdateDate as target 
                    USING ($$||select_statement||$$) as source 
                   ON source.ProviderId = target.ProviderId
                   WHEN NOT MATCHED THEN $$ ||insert_statement;

---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE merge_statement;

-- ---------------------------------------------------------
-- --------------- 6. Status monitoring --------------------
-- --------------------------------------------------------- 

status := 'Completed successfully';
    RETURN status;



EXCEPTION
    WHEN OTHER THEN
          status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
          RETURN status;

END;