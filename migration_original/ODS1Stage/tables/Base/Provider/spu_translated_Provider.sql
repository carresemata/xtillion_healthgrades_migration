CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDER()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.Provider depends on: 
--- Raw.VW_PROVIDER_PROFILE
--- Base.Source

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement_1 STRING; -- CTE and Select statement for the Merge
    update_statement_1 STRING; -- Update statement for the Merge
    update_clause_1 STRING; -- where condition for update
    insert_statement_1 STRING; -- Insert statement for the Merge
    merge_statement_1 STRING; -- Merge statement to final table

    update_statement_2 STRING; -- Update statement for the Merge
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    -- no conditionals


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
select_statement_1 := $$ SELECT
                            -- ReltioEntityId
                            UUID_STRING() AS ProviderId,
                            -- EDWBaseRecordID
                            JSON.ProviderCode,
                            JSON.DEMOGRAPHICS_FIRSTNAME AS FirstName,
                            JSON.DEMOGRAPHICS_MIDDLENAME AS MiddleName,
                            JSON.DEMOGRAPHICS_LASTNAME AS LastName,
                            JSON.DEMOGRAPHICS_SUFFIXCODE AS Suffix,
                            JSON.DEMOGRAPHICS_GENDERCODE AS Gender,
                            CASE
                                WHEN JSON.DEMOGRAPHICS_NPI = JSON.ProviderCode THEN NULL
                                ELSE JSON.DEMOGRAPHICS_NPI
                            END AS NPI,
                            TO_DATE(JSON.DEMOGRAPHICS_DATEOFBIRTH) AS DateOfBirth,
                            JSON.DEMOGRAPHICS_ACCEPTSNEWPATIENTS AS AcceptsNewPatients,
                            -- HasElectronicMedicalRecords,
                            -- HasElectronicPrescription,
                            IFNULL(JSON.DEMOGRAPHICS_SOURCECODE, 'Profisee') AS SourceCode,
                            S.SourceID,
                            IFNULL(JSON.DEMOGRAPHICS_LASTUPDATEDATE, SYSDATE()) AS LastUpdateDate,
                            -- PatientVolume
                            -- IsInClinicalPractice
                            -- PatientCountIsFew
                            -- IsPCPCalculated
                            -- ProfessionalInterest
                            JSON.DEMOGRAPHICS_SURVIVERESIDENTIALADDRESSES AS SurviveResidentialAddresses,
                            JSON.DEMOGRAPHICS_ISPATIENTFAVORITE AS IsPatientFavorite
                        FROM
                            RAW.VW_PROVIDER_PROFILE AS JSON
                            LEFT JOIN Base.Source AS S ON S.SOURCECODE = JSON.DEMOGRAPHICS_SOURCECODE
                        WHERE
                            PROVIDER_PROFILE IS NOT NULL
                        QUALIFY row_number() over(partition by ProviderID order by JSON.ProviderCode, CREATE_DATE desc, NPI) = 1 $$;



--- Update Statement
update_statement_1 := ' UPDATE 
                     SET  target.ProviderCode = source.ProviderCode,
                            target.FirstName = source.FirstName,
                            target.MiddleName = source.MiddleName,
                            target.LastName = source.LastName,
                            target.Suffix = source.Suffix,
                            target.Gender = source.Gender,
                            target.NPI = source.NPI,
                            target.DateOfBirth = source.DateOfBirth,
                            target.AcceptsNewPatients = source.AcceptsNewPatients,
                            target.SourceCode = source.SourceCode,
                            target.SourceID = source.SourceID,
                            target.LastUpdateDate = source.LastUpdateDate,
                            target.SurviveResidentialAddresses = source.SurviveResidentialAddresses,
                            target.IsPatientFavorite = source.IsPatientFavorite';
-- Update Clause
update_clause_1 := $$ IFNULL(target.ProviderCode, '') != IFNULL(source.ProviderCode, '')
        OR IFNULL(target.FirstName, '') != IFNULL(source.FirstName, '')
        OR IFNULL(target.MiddleName, '') != IFNULL(source.MiddleName, '')
        OR IFNULL(target.LastName, '') != IFNULL(source.LastName, '')
        OR IFNULL(target.Suffix, '') != IFNULL(source.Suffix, '')
        OR IFNULL(target.Gender, '') != IFNULL(source.Gender, '')
        OR IFNULL(target.NPI, '') != IFNULL(source.NPI, '')
        OR IFNULL(target.DateOfBirth, '1900-01-01') != IFNULL(source.DateOfBirth,'1900-01-01')
        OR IFNULL(target.AcceptsNewPatients, 0) != IFNULL(source.AcceptsNewPatients, 0)
        OR IFNULL(target.SourceCode, '') != IFNULL(source.SourceCode, '')
        OR IFNULL(target.SourceID, '00000000-0000-0000-0000-000000000000') != IFNULL(source.SourceID,'00000000-0000-0000-0000-000000000000')
        OR IFNULL(target.LastUpdateDate, '1900-01-01') != IFNULL(source.LastUpdateDate, '1900-01-01')
        OR IFNULL(target.SurviveResidentialAddresses, 0) != IFNULL(source.SurviveResidentialAddresses, 0)
        OR IFNULL(target.IsPatientFavorite, 0) != IFNULL(source.IsPatientFavorite, 0) $$;                        
        
--- Insert Statement
insert_statement_1 := ' INSERT  
                            (ProviderID,
                            ProviderCode,
                            FirstName,
                            MiddleName,
                            LastName,
                            Suffix,
                            Gender,
                            NPI,
                            DateOfBirth,
                            AcceptsNewPatients,
                            SourceCode,
                            SourceID,
                            LastUpdateDate,
                            SurviveResidentialAddresses,
                            IsPatientFavorite)
                      VALUES 
                          ( source.ProviderID,
                            source.ProviderCode,
                            source.FirstName,
                            source.MiddleName,
                            source.LastName,
                            source.Suffix,
                            source.Gender,
                            source.NPI,
                            source.DateOfBirth,
                            source.AcceptsNewPatients,
                            source.SourceCode,
                            source.SourceID,
                            source.LastUpdateDate,
                            source.SurviveResidentialAddresses,
                            source.IsPatientFavorite)';

-- Update Statement

update_statement_2 := $$UPDATE Base.Provider AS target
       SET target.CarePhilosophy = source.ProviderAboutMeText
         FROM (SELECT 
                    JSON.ProviderCode,
                    JSON.ABOUTME_ABOUTMECODE AS AboutMeCode,
                    JSON.ABOUTME_ABOUTMETEXT AS ProviderAboutMeText
                FROM RAW.VW_PROVIDER_PROFILE AS JSON
                    WHERE AboutMeCode = 'CarePhilosophy') AS source
         WHERE target.ProviderCode = source.ProviderCode
    $$;
    
---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement_1 := ' MERGE INTO Base.Provider as target USING 
                   ('||select_statement_1||') as source 
                   ON source.Providerid = target.Providerid
                   WHEN MATCHED AND' || update_clause_1 || 'THEN '||update_statement_1|| '
                   WHEN NOT MATCHED THEN '||insert_statement_1;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
EXECUTE IMMEDIATE merge_statement_1 ;
EXECUTE IMMEDIATE update_statement_2;

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