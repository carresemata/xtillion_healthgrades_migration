CREATE OR REPLACE PROCEDURE ODS1_STAGE.Mid.SP_LOAD_PROVIDER(IsProviderDeltaProcessing BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.Provider
-- Base.ProviderToDegree
-- Base.Degree
-- Base.ProviderToProviderType
-- Base.ProviderType
-- Base.ProviderToProviderSubType
-- Base.ProviderSubType
-- Base.ProviderToDisplaySpecialty
-- Base.Specialty

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

DECLARE
create_temp STRING; 
insert_temp STRING; -- delta logic of insert to temporary table
join_temp_delta STRING;

-- updates to temporary version of Mid.Provider
update_temp_1 STRING;
update_temp_2 STRING;
update_temp_3 STRING;
update_temp_4 STRING;
update_temp_5 STRING;
update_temp_6 STRING;

-- changes to Mid.Provider from temp version
update_statement STRING;
insert_statement STRING;
select_statement STRING; 
merge_statement STRING;

status STRING;


---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------  

BEGIN
         create_temp := $$
                        CREATE OR REPLACE TEMPORARY TABLE Mid.TEMPProvider AS
                        SELECT * FROM  Mid.Provider LIMIT 0;
                        $$;
                        
         insert_temp := $$ 
                      INSERT INTO Mid.TEMPProvider (
                          ProviderID,
                          ProviderCode,
                          ProviderTypeID,
                          FirstName,
                          MiddleName,
                          LastName,
                          CarePhilosophy,
                          ProfessionalInterest,
                          Suffix,
                          Gender,
                          NPI,
                          AMAID,
                          UPIN,
                          MedicareID,
                          DEANumber,
                          TaxIDNumber,
                          DateOfBirth,
                          PlaceOfBirth,
                          AcceptsNewPatients,
                          HasElectronicMedicalRecords,
                          HasElectronicPrescription,
                          LegacyKey,
                          ProviderLastUpdateDateOverall,
                          ProviderLastUpdateDateOverallSourceTable,
                          SearchBoostSatisfaction,
                          SearchBoostAccessibility
                      )
                      SELECT
                        p.ProviderID,
                        p.ProviderCode,
                        p.ProviderTypeID,
                        p.FirstName,
                        p.MiddleName,
                        p.LastName,
                        p.CarePhilosophy,
                        p.ProfessionalInterest,
                        p.Suffix,
                        p.Gender,
                        p.NPI,
                        p.AMAID,
                        p.UPIN,
                        p.MedicareID,
                        p.DEANumber,
                        p.TaxIDNumber,
                        p.DateOfBirth,
                        p.PlaceOfBirth,
                        p.AcceptsNewPatients,
                        p.HasElectronicMedicalRecords,
                        p.HasElectronicPrescription,
                        p.LegacyKey,
                        IFNULL(p.ProviderLastUpdateDateOverall, p.LastUpdateDate),
                        IFNULL(p.ProviderLastUpdateDateOverallSourceTable, p.LastUpdateDate),
                        p.SearchBoostSatisfaction,
                        p.SearchBoostAccessibility
                       FROM (SELECT * FROM Base.Provider) AS p
                   $$;
                   
      IF (IsProviderDeltaProcessing) THEN
        join_temp_delta := $$ INNER JOIN raw.ProviderDeltaProcessing AS pdp ON pdp.ProviderID = p.ProviderID $$;
        insert_temp := insert_temp || join_temp_delta;
      ELSE
        insert_temp := insert_temp;
      END IF;

      ---------------------------------------------------------
      ----------------- 3. SQL Statements ---------------------
      ---------------------------------------------------------  
      select_statement := $$
                          (SELECT * FROM Mid.TEMPProvider)
                          $$;

      ---------------------------------------------------------
      --------- 4. Actions (Inserts and Updates) --------------
      ---------------------------------------------------------

      update_temp_1 := $$ 
                      UPDATE Mid.TEMPProvider p
                      SET p.DegreeAbbreviation = s.DegreeAbbreviation
                      FROM
                        (
                          SELECT
                            ptd.ProviderID,
                            d.DegreeAbbreviation,
                            ROW_NUMBER() OVER (
                              PARTITION BY ptd.ProviderID
                              ORDER BY
                                ptd.DegreePriority ASC NULLS FIRST,
                                ptd.LastUpdateDate DESC NULLS LAST,
                                d.DegreeAbbreviation NULLS FIRST
                            ) AS recID
                          FROM  Base.ProviderToDegree ptd
                          INNER JOIN Base.Degree d ON ptd.DegreeID = d.DegreeID
                        ) s
                      WHERE p.ProviderID = s.ProviderID AND recID = 1;
                       $$;

      update_temp_2 := $$
                      UPDATE Mid.TEMPProvider p
                      SET p.ProviderTypeID = ptpt.ProviderTypeID
                      FROM Base.ProviderToProviderType ptpt
                      WHERE p.ProviderID = ptpt.ProviderID AND ptpt.ProviderTypeRank = 1;
                       $$;

      update_temp_3 := $$
                      UPDATE Mid.TEMPProvider p
                      SET p.ProviderTypeID =(SELECT ProviderTypeID FROM Base.ProviderType WHERE ProviderTypeCode = 'ALT') 
                      WHERE p.ProviderTypeID IS NULL;
                       $$;

      update_temp_4 := $$
                      UPDATE Mid.TEMPProvider p 
                      SET p.Title = 'Dr.'
                      FROM Base.ProviderToProviderSubType ptpst, Base.ProviderSubType pst
                      WHERE p.ProviderID = ptpst.ProviderID AND ptpst.ProviderSubTypeID = pst.ProviderSubTypeID 
                            AND pst.IsDoctor = 1 AND IFNULL(Title, '') != 'Dr.';
                       $$;


      update_temp_5 := $$
                        UPDATE Mid.TEMPProvider p 
                        SET p.ProviderURL = 
                          CASE
                            WHEN pt.ProviderTypeCode = 'ALT' THEN REPLACE(REPLACE(
                                '/' || 'providers/' || IFNULL(LOWER(p.FirstName), '') || '-' || IFNULL(LOWER(p.LastName), '') || '-' || IFNULL(LOWER(p.ProviderCode),''),
                                '''', ''), ' ', '-')
                            WHEN pt.ProviderTypeCode = 'DOC' THEN REPLACE(REPLACE(
                                '/' || 'physician/dr-' || IFNULL(LOWER(p.FirstName), '') || '-' || IFNULL(LOWER(p.LastName), '') || '-' || IFNULL(LOWER(p.ProviderCode), ''),
                                '''', ''), ' ', '-')
                            WHEN pt.ProviderTypeCode = 'DENT' THEN REPLACE(REPLACE(
                                '/' || 'dentist/dr-' || IFNULL(LOWER(p.FirstName), '') || '-' || IFNULL(LOWER(p.LastName), '') || '-' || IFNULL(LOWER(p.ProviderCode), ''),'''', ''), ' ', '-')
                            ELSE REPLACE(REPLACE('/' || 'providers/' || IFNULL(LOWER(p.FirstName), '') || '-' || IFNULL(LOWER(p.LastName), '') || '-' || IFNULL(LOWER(p.ProviderCode), ''),
                                '''', ''), ' ', '-')
                          END
                        FROM Base.ProviderToProviderType ptpt, Base.ProviderType pt
                        WHERE p.ProviderID = ptpt.ProviderID AND ptpt.ProviderTypeRank = 1 AND ptpt.ProviderTypeID = pt.ProviderTypeID;
                       $$;

      update_temp_6 := $$
                      UPDATE Mid.TEMPProvider p
                      SET p.FFDisplaySpecialty = s.SpecialtyCode
                      FROM Base.ProviderToDisplaySpecialty ptds, Base.Specialty s
                      WHERE ptds.ProviderID = p.ProviderID AND s.SpecialtyID = ptds.SpecialtyID;
                       $$;


      update_statement := $$ 
                        UPDATE SET
                            target.AcceptsNewPatients = source.AcceptsNewPatients,
                            target.AMAID = source.AMAID,
                            target.CarePhilosophy = source.CarePhilosophy,
                            target.DateOfBirth = source.DateOfBirth,
                            target.DEANumber = source.DEANumber,
                            target.DegreeAbbreviation = source.DegreeAbbreviation,
                            target.ExpireCode = source.ExpireCode,
                            target.FFDisplaySpecialty = source.FFDisplaySpecialty,
                            target.FirstName = source.FirstName,
                            target.Gender = source.Gender,
                            target.HasElectronicMedicalRecords = source.HasElectronicMedicalRecords,
                            target.HasElectronicPrescription = source.HasElectronicPrescription,
                            target.LastName = source.LastName,
                            target.LegacyKey = source.LegacyKey,
                            target.MedicareID = source.MedicareID,
                            target.MiddleName = source.MiddleName,
                            target.NPI = source.NPI,
                            target.PlaceOfBirth = source.PlaceOfBirth,
                            target.ProfessionalInterest = source.ProfessionalInterest,
                            target.ProviderCode = source.ProviderCode,
                            target.ProviderLastUpdateDateOverall = source.ProviderLastUpdateDateOverall,
                            target.ProviderLastUpdateDateOverallSourceTable = source.ProviderLastUpdateDateOverallSourceTable,
                            target.ProviderTypeID = source.ProviderTypeID,
                            target.ProviderURL = source.ProviderURL,
                            target.SearchBoostAccessibility = source.SearchBoostAccessibility,
                            target.SearchBoostSatisfaction = source.SearchBoostSatisfaction,
                            target.Suffix = source.Suffix,
                            target.TaxIDNumber = source.TaxIDNumber,
                            target.Title = source.Title,
                            target.UPIN = source.UPIN
                          $$;

        insert_statement := $$
                            INSERT (
                                      AcceptsNewPatients,
                                      AMAID,
                                      CarePhilosophy,
                                      DateOfBirth,
                                      DEANumber,
                                      DegreeAbbreviation,
                                      ExpireCode,
                                      FFDisplaySpecialty,
                                      FirstName,
                                      Gender,
                                      HasElectronicMedicalRecords,
                                      HasElectronicPrescription,
                                      LastName,
                                      LegacyKey,
                                      MedicareID,
                                      MiddleName,
                                      NPI,
                                      PlaceOfBirth,
                                      ProfessionalInterest,
                                      ProviderCode,
                                      ProviderID,
                                      ProviderLastUpdateDateOverall,
                                      ProviderLastUpdateDateOverallSourceTable,
                                      ProviderTypeID,
                                      ProviderURL,
                                      SearchBoostAccessibility,
                                      SearchBoostSatisfaction,
                                      Suffix,
                                      TaxIDNumber,
                                      Title,
                                      UPIN
                                 )
                          VALUES (	
                                source.AcceptsNewPatients,
                                source.AMAID,
                                source.CarePhilosophy,
                                source.DateOfBirth,
                                source.DEANumber,
                                source.DegreeAbbreviation,
                                source.ExpireCode,
                                source.FFDisplaySpecialty,
                                source.FirstName,
                                source.Gender,
                                source.HasElectronicMedicalRecords,
                                source.HasElectronicPrescription,
                                source.LastName,
                                source.LegacyKey,
                                source.MedicareID,
                                source.MiddleName,
                                source.NPI,
                                source.PlaceOfBirth,
                                source.ProfessionalInterest,
                                source.ProviderCode,
                                source.ProviderID,
                                source.ProviderLastUpdateDateOverall,
                                source.ProviderLastUpdateDateOverallSourceTable,
                                source.ProviderTypeID,
                                source.ProviderURL,
                                source.SearchBoostAccessibility,
                                source.SearchBoostSatisfaction,
                                source.Suffix,
                                source.TaxIDNumber,
                                source.Title,
                                source.UPIN
                                )
                            $$;
                     

      merge_statement := $$
                        MERGE INTO Mid.PROVIDER AS target 
                        USING $$|| select_statement ||$$ as source	
                        ON source.ProviderID = target.ProviderID
                        WHEN MATCHED AND MD5(IFNULL(CAST(target.AcceptsNewPatients AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.AcceptsNewPatients AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.AMAID AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.AMAID AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.CarePhilosophy AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.CarePhilosophy AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.DateOfBirth AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.DateOfBirth AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.DEANumber AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.DEANumber AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.DegreeAbbreviation AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.DegreeAbbreviation AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.ExpireCode AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.ExpireCode AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.FFDisplaySpecialty AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.FFDisplaySpecialty AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.FirstName AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.FirstName AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.Gender AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.Gender AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.HasElectronicMedicalRecords AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.HasElectronicMedicalRecords AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.HasElectronicPrescription AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.HasElectronicPrescription AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.LastName AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.LastName AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.LegacyKey AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.LegacyKey AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.MedicareID AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.MedicareID AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.MiddleName AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.MiddleName AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.NPI AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.NPI AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.PlaceOfBirth AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.PlaceOfBirth AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.ProfessionalInterest AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.ProfessionalInterest AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.ProviderCode AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.ProviderCode AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.ProviderLastUpdateDateOverall AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.ProviderLastUpdateDateOverall AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.ProviderLastUpdateDateOverallSourceTable AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.ProviderLastUpdateDateOverallSourceTable AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.ProviderTypeID AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.ProviderTypeID AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.ProviderURL AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.ProviderURL AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.SearchBoostAccessibility AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.SearchBoostAccessibility AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.SearchBoostSatisfaction AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.SearchBoostSatisfaction AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.Suffix AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.Suffix AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.TaxIDNumber AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.TaxIDNumber AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.Title AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.Title AS VARCHAR), '')) OR 
                                        MD5(IFNULL(CAST(target.UPIN AS VARCHAR), '')) <> MD5(IFNULL(CAST(source.UPIN AS VARCHAR), '')) THEN $$ || update_statement || $$ 
                        WHEN NOT MATCHED THEN $$ || insert_statement;

     ---------------------------------------------------------
     ------------------- 5. Execution ------------------------
     --------------------------------------------------------- 
     EXECUTE IMMEDIATE create_temp;        
     EXECUTE IMMEDIATE insert_temp;

     -- updates to temporary version of Mid.Provider
     EXECUTE IMMEDIATE update_temp_1;
     EXECUTE IMMEDIATE update_temp_2;
     EXECUTE IMMEDIATE update_temp_3;
     EXECUTE IMMEDIATE update_temp_4;
     EXECUTE IMMEDIATE update_temp_5;
     EXECUTE IMMEDIATE update_temp_6;
     
     -- merge to final Mid.Prover table
     EXECUTE IMMEDIATE merge_statement;

     ---------------------------------------------------------
    --------------- 6. Status monitoring --------------------
    --------------------------------------------------------- 
    
    status := 'Completed successfully';
        RETURN status;
    
    
    EXCEPTION
        WHEN OTHER THEN
              status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
              RETURN status;
                    
END;