CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDEREDUCATION(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Mid.ProviderEducation depends on:
--- MDM_TEAM.MST.Provider_Profile_Processing
--- Base.ProviderToEducationInstitution
--- Base.EducationInstitution
--- Base.EducationInstitutionType
--- Base.Address
--- Base.CityStatePostalCode
--- Base.Nation
--- Base.Degree
--- Base.Provider

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_ProviderEducation');
    execution_start DATETIME default getdate();

   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    IF (IsProviderDeltaProcessing) THEN
           select_statement := '
           WITH CTE_ProviderBatch AS (
                SELECT
                    p.ProviderID
                FROM
                    MDM_TEAM.MST.Provider_Profile_Processing as ppp
                    JOIN Base.Provider AS P On p.providercode = ppp.ref_provider_code),';
    ELSE
           select_statement := '
           WITH CTE_ProviderBatch AS (
                SELECT
                    P.ProviderID
                from
                    Base.Provider as P
                order by
                    P.ProviderID),';
    END IF;

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement

select_statement := select_statement || 
                    $$
                    CTE_ProviderEducation AS (
                        SELECT DISTINCT 
                        ptei.ProviderToEducationInstitutionID, 
                        ptei.ProviderID, 
                        ei.EducationInstitutionName, 
                        eit.EducationInstitutionTypeCode, 
                        eit.EducationInstitutionTypeDescription,
                        ptei.GraduationYear, 
                        ptei.PositionHeld, 
                        d.DegreeAbbreviation, 
                        csp.City, 
                        csp.State, 
                        n.NationName,
                        0 AS ActionCode
                    FROM CTE_ProviderBatch AS pb 
                    JOIN Base.ProviderToEducationInstitution ptei ON ptei.ProviderID = pb.ProviderID
                    JOIN Base.EducationInstitution ei ON ei.EducationInstitutionID = ptei.EducationInstitutionID
                    JOIN Base.EducationInstitutionType eit ON eit.EducationInstitutionTypeID = ptei.EducationInstitutionTypeID
                    LEFT JOIN Base.Address a ON a.AddressID = ei.AddressID
                    LEFT JOIN Base.CityStatePostalCode csp ON a.CityStatePostalCodeID = csp.CityStatePostalCodeID
                    LEFT JOIN Base.Nation n ON csp.NationID = n.NationID
                    LEFT JOIN Base.Degree d ON d.DegreeID = ptei.DegreeID
                    ),
                    -- Insert Action
                    CTE_Action_1 AS (
                            SELECT 
                                cte.ProviderToEducationInstitutionID,
                                1 AS ActionCode
                            FROM CTE_ProviderEducation AS cte
                            LEFT JOIN Mid.ProviderEducation AS mid 
                                ON cte.ProviderToEducationInstitutionID = mid.ProviderToEducationInstitutionID 
                            WHERE mid.ProviderToEducationInstitutionID IS NULL),
                            
                     -- Update Action
                     CTE_Action_2 AS (
                            SELECT 
                                cte.ProviderToEducationInstitutionID,
                                2 AS ActionCode
                            FROM CTE_ProviderEducation AS cte
                            JOIN Mid.ProviderEducation AS mid 
                                ON cte.ProviderToEducationInstitutionID = mid.ProviderToEducationInstitutionID 
                            WHERE 
                                
                                MD5(IFNULL(cte.ProviderID::VARCHAR,'''')) <> MD5(IFNULL(mid.ProviderID::VARCHAR,'''')) OR 
                                MD5(IFNULL(cte.EducationInstitutionName::VARCHAR,'''')) <> MD5(IFNULL(mid.EducationInstitutionName::VARCHAR,'''')) OR 
                                MD5(IFNULL(cte.EducationInstitutionTypeCode::VARCHAR,'''')) <> MD5(IFNULL(mid.EducationInstitutionTypeCode::VARCHAR,'''')) OR 
                                MD5(IFNULL(cte.EducationInstitutionTypeDescription::VARCHAR,'''')) <> MD5(IFNULL(mid.EducationInstitutionTypeDescription::VARCHAR,'''')) OR 
                                MD5(IFNULL(cte.GraduationYear::VARCHAR,'''')) <> MD5(IFNULL(mid.GraduationYear::VARCHAR,'''')) OR 
                                MD5(IFNULL(cte.PositionHeld::VARCHAR,'''')) <> MD5(IFNULL(mid.PositionHeld::VARCHAR,'''')) OR 
                                MD5(IFNULL(cte.DegreeAbbreviation::VARCHAR,'''')) <> MD5(IFNULL(mid.DegreeAbbreviation::VARCHAR,'''')) OR 
                                MD5(IFNULL(cte.City::VARCHAR,'''')) <> MD5(IFNULL(mid.City::VARCHAR,'''')) OR 
                                MD5(IFNULL(cte.State::VARCHAR,'''')) <> MD5(IFNULL(mid.State::VARCHAR,'''')) OR 
                                MD5(IFNULL(cte.NationName::VARCHAR,'''')) <> MD5(IFNULL(mid.NationName::VARCHAR,'''')) 
                     )
        
                    SELECT DISTINCT
                        A0.ProviderToEducationInstitutionID, 
                        A0.ProviderID, 
                        A0.EducationInstitutionName, 
                        A0.EducationInstitutionTypeCode, 
                        A0.EducationInstitutionTypeDescription,
                        A0.GraduationYear, 
                        A0.PositionHeld, 
                        A0.DegreeAbbreviation, 
                        A0.City, 
                        A0.State, 
                        A0.NationName,
                        IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) AS ActionCode 
                    FROM CTE_ProviderEducation AS A0 
                                        LEFT JOIN CTE_Action_1 AS A1 ON A0.ProviderToEducationInstitutionID = A1.ProviderToEducationInstitutionID
                                        LEFT JOIN CTE_Action_2 AS A2 ON A0.ProviderToEducationInstitutionID = A2.ProviderToEducationInstitutionID
                                        WHERE IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) <> 0 
                                        $$;

--- Update Statement
update_statement := ' UPDATE 
                     SET 
                        ProviderToEducationInstitutionID = source.ProviderToEducationInstitutionID, 
                        ProviderID = source.ProviderID, 
                        EducationInstitutionName = source.EducationInstitutionName, 
                        EducationInstitutionTypeCode = source.EducationInstitutionTypeCode, 
                        EducationInstitutionTypeDescription = source.EducationInstitutionTypeDescription,
                        GraduationYear = source.GraduationYear, 
                        PositionHeld = source.PositionHeld, 
                        DegreeAbbreviation = source.DegreeAbbreviation, 
                        City = source.City, 
                        State = source.State, 
                        NationName = source.NationName';

--- Insert Statement
insert_statement := ' INSERT  
                        (ProviderToEducationInstitutionID,
                        ProviderID,
                        EducationInstitutionName,
                        EducationInstitutionTypeCode,
                        EducationInstitutionTypeDescription,
                        GraduationYear,
                        PositionHeld,
                        DegreeAbbreviation,
                        City,
                        State,
                        NationName)
                      VALUES 
                        (source.ProviderToEducationInstitutionID,
                        source.ProviderID,
                        source.EducationInstitutionName,
                        source.EducationInstitutionTypeCode,
                        source.EducationInstitutionTypeDescription,
                        source.GraduationYear,
                        source.PositionHeld,
                        source.DegreeAbbreviation,
                        source.City,
                        source.State,
                        source.NationName)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Mid.ProviderEducation as target USING 
                   ('||select_statement||') as source 
                   ON source.ProviderToEducationInstitutionID = target.ProviderToEducationInstitutionID
                   WHEN MATCHED AND source.ActionCode = 2 THEN '||update_statement|| '
                   WHEN NOT MATCHED AND source.ActionCode = 1 THEN '||insert_statement;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
EXECUTE IMMEDIATE merge_statement ;

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
--------------------------------------------------------- 

status := 'Completed successfully';
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        RETURN status;

        EXCEPTION
        WHEN OTHER THEN
            status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, SPLIT_PART(REGEXP_SUBSTR(:status, 'Error code: ([0-9]+)'), ':', 2)::INTEGER, TRIM(SPLIT_PART(SPLIT_PART(:status, 'SQL Error:', 2), 'Error code:', 1)), SPLIT_PART(REGEXP_SUBSTR(:status, 'SQL State: ([0-9]+)'), ':', 2)::INTEGER; 

            RETURN status;
END;