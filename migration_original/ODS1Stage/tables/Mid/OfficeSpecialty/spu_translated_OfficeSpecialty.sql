CREATE OR REPLACE PROCEDURE ODS1_STAGE.MID.SP_LOAD_OFFICESPECIALTY(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Mid.OfficeSpecialty depends on: 
--- Raw.ProviderDeltaProcessing
--- Base.ProviderToOffice
--- Base.Office
--- Base.EntityToMedicalTerm 
--- Base.MedicalTerm
--- Base.MedicalTermType

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    IF (IsProviderDeltaProcessing) THEN
           select_statement := '
            WITH CTE_OfficeBatch AS (SELECT DISTINCT pto.OfficeID
            FROM Raw.ProviderDeltaProcessing AS pdp
            JOIN Base.ProviderToOffice AS pto ON pto.ProviderID = pdp.ProviderID
            ORDER BY pto.OfficeID),
           ';
    ELSE
           select_statement := '
           WITH CTE_OfficeBatch AS (
           SELECT DISTINCT o.OfficeID 
           FROM Base.Office AS o 
           ORDER BY o.OfficeID),
          ';
    END IF;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
select_statement := select_statement || 
                    $$ 
                    CTE_OfficeSpecialty AS (
                        SELECT 
                            etmt.EntityToMedicalTermID AS OfficeToSpecialtyID, 
                            etmt.EntityID AS OfficeID, 
                            mt.MedicalTermCode AS SpecialtyCode, 
                            mt.MedicalTermDescription1 AS Specialty, 
                            mt.MedicalTermDescription2 AS Specialist, 
                            mt.MedicalTermDescription3 AS Specialists, 
                            mt.LegacyKey AS LegacyKey,
                            0 AS ActionCode
                    		
                        FROM CTE_OfficeBatch AS cte
                            JOIN Base.EntityToMedicalTerm etmt ON etmt.EntityID = cte.OfficeID
                            JOIN Base.MedicalTerm mt ON etmt.MedicalTermID = mt.MedicalTermID
                    		join Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID and mtt.MedicalTermTypeCode = 'Specialty'
                    
                    ),
                    -- Insert Action
                    CTE_Action_1 AS (
                        SELECT 
                            cte.OfficeToSpecialtyId,
                            1 AS ActionCode
                        FROM CTE_OfficeSpecialty AS cte
                        JOIN Mid.OfficeSpecialty AS mid ON cte.OfficeToSpecialtyID = mid.OfficeToSpecialtyId 
                        WHERE cte.OfficeToSpecialtyId IS NULL
                    ),
                    -- Update Action
                    CTE_Action_2 AS (
                        SELECT
                            cte.OfficeToSpecialtyId,
                            2 AS ActionCode
                        FROM CTE_OfficeSpecialty AS cte
                        JOIN Mid.OfficeSpecialty AS mid ON cte.OfficeToSpecialtyID = mid.OfficeToSpecialtyId 
                        WHERE
                            MD5(IFNULL(cte.OfficeId::VARCHAR,''))<>           MD5(IFNULL(mid.OfficeId::VARCHAR,'')) OR
                            MD5(IFNULL(cte.SpecialtyCode::VARCHAR,''))<>      MD5(IFNULL(mid.SpecialtyCode::VARCHAR,'')) OR
                            MD5(IFNULL(cte.Specialty::VARCHAR,''))<>          MD5(IFNULL(mid.Specialty::VARCHAR,'')) OR
                            MD5(IFNULL(cte.Specialist::VARCHAR,''))<>         MD5(IFNULL(mid.Specialist::VARCHAR,'')) OR
                            MD5(IFNULL(cte.Specialists::VARCHAR,''))<>        MD5(IFNULL(mid.Specialists::VARCHAR,'')) OR
                            MD5(IFNULL(cte.LegacyKey::VARCHAR,''))<>          MD5(IFNULL(mid.LegacyKey::VARCHAR,'')) 
                    )
                    SELECT DISTINCT
                        A0.OfficeToSpecialtyId,
                        A0.OfficeId,
                        A0.SpecialtyCode,
                        A0.Specialty,
                        A0.Specialist,
                        A0.Specialists,
                        A0.LegacyKey,
                        IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) AS ActionCode
                    FROM CTE_OfficeSpecialty AS A0
                    LEFT JOIN CTE_Action_1 AS A1 ON A0.OfficeToSpecialtyId = A1.OfficeToSpecialtyId
                    LEFT JOIN CTE_Action_2 AS A2 ON A0.OfficeToSpecialtyId = A2.OfficeToSpecialtyId
                    WHERE IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) <> 0
                    $$;

--- Update Statement
update_statement := ' UPDATE 
                     SET 
                        OfficeToSpecialtyId = source.OfficeToSpecialtyId,
                        OfficeId = source.OfficeId,
                        SpecialtyCode = source.SpecialtyCode,
                        Specialty = source.Specialty,
                        Specialist = source.Specialist,
                        Specialists = source.Specialists,
                        LegacyKey = source.LegacyKey';

--- Insert Statement
insert_statement := ' INSERT  
                        (OfficeToSpecialtyId,
                        OfficeId,
                        SpecialtyCode,
                        Specialty,
                        Specialist,
                        Specialists,
                        LegacyKey)
                      VALUES 
                        (source.OfficeToSpecialtyId,
                        source.OfficeId,
                        source.SpecialtyCode,
                        source.Specialty,
                        source.Specialist,
                        source.Specialists,
                        source.LegacyKey)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Mid.OfficeSpecialty as target USING 
                   ('||select_statement||') as source 
                   ON target.OfficeToSpecialtyID = source.OfficeToSpecialtyID 
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
    RETURN status;


        
EXCEPTION
    WHEN OTHER THEN
          status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
          RETURN status;


    
END;