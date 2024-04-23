CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTOEDUCATIONINSTITUTION()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderToEducationInstitution depends on: 
--- RAW.VW_PROVIDER_PROFILE
--- Base.Provider
--- Base.EducationInstitution
--- Base.EducationInstitutionType

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
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
select_statement := $$ SELECT 
                            P.ProviderId,
                            EI.EducationInstitutionID,
                            EIT.EducationInstitutionTypeID,
                            JSON.EducationInstitution_GraduationYear AS GraduationYear,
                            IFNULL(JSON.EducationInstitution_SourceCode, 'Profisee') AS SourceCode,
                            IFNULL(JSON.EducationInstitution_LastUpdateDate, SYSDATE()) AS LastUpdateDate,
                        FROM RAW.VW_PROVIDER_PROFILE AS JSON
                            LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                            LEFT JOIN Base.EducationInstitution AS EI ON EI.EducationInstitutionCode = JSON.EDUCATIONINSTITUTION_EDUCATIONINSTITUTIONCODE
                            LEFT JOIN Base.EducationInstitutionType AS EIT ON EIT.EducationInstitutionTypeCode = JSON.EDUCATIONINSTITUTION_EDUCATIONINSTITUTIONTYPECODE
                        WHERE 
                            PROVIDER_PROFILE IS NOT NULL AND
                            ProviderID IS NOT NULL AND
                            EducationInstitutionID IS NOT NULL AND
                            EducationInstitutionTypeID IS NOT NULL
$$;



--- Insert Statement
insert_statement := ' INSERT  
                            (ProviderToEducationInstitutionID,
                            ProviderID,
                            EducationInstitutionID,
                            EducationInstitutionTypeID,
                            GraduationYear,
                            SourceCode,
                            LastUpdateDate)
                      VALUES 
                            (UUID_STRING(),
                            source.ProviderID,
                            source.EducationInstitutionID,
                            source.EducationInstitutionTypeID,
                            source.GraduationYear,
                            source.SourceCode,
                            source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.ProviderToEducationInstitution as target USING 
                   ('||select_statement||') as source 
                   ON source.Providerid = target.Providerid
                   WHEN MATCHED THEN DELETE
                   WHEN NOT MATCHED THEN '||insert_statement;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
EXECUTE IMMEDIATE merge_statement ;

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