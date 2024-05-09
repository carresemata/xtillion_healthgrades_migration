CREATE OR REPLACE PROCEDURE ODS1_STAGE.MID.SP_LOAD_PROVIDERAFFILIATION(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Mid.ProviderAffiliation depends on: 
--- MDM_TEAM.MST.Provider_Profile_Processing
--- Base.Provider
--- Base.ProviderToAffiliation
--- Base.Affiliation
--- Base.ProviderRole

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
                    p.ProviderID
                FROM
                    Base.Provider AS p
                ORDER BY
                    p.ProviderID),';
    END IF;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement

-- If conditionals:
select_statement := select_statement || 
                    $$ CTE_ProviderAffiliation AS (
                            SELECT
                                pta.ProviderToAffiliationID,
                                pta.ProviderID,
                                pta.AffiliationBeginDate,
                                pta.AffiliationEndDate,
                                pta.AffiliationName,
                                aff.AffiliationTypeCode,
                                aff.AffiliationTypeDescription,
                                pr.RoleCode,
                                pr.RoleDescription,
                                0 AS ActionCode
                            FROM
                                CTE_ProviderBatch AS pb
                                JOIN Base.ProviderToAffiliation AS pta ON pta.ProviderID = pb.ProviderID
                                JOIN Base.Affiliation AS aff ON pta.AffiliationID = aff.AffiliationID
                                JOIN Base.ProviderRole AS pr ON pta.ProviderRoleID = pr.ProviderRoleID
                        ),
                        -- Insert Action
                        CTE_Action_1 AS (
                            SELECT
                                cte.ProviderToAffiliationID,
                                1 AS ActionCode
                            FROM
                                CTE_ProviderAffiliation AS cte
                                LEFT JOIN Mid.ProviderAffiliation AS mid ON cte.ProviderToAffiliationID = mid.ProviderToAffiliationID
                            WHERE
                                mid.ProviderToAffiliationID IS NULL
                        ),
                        -- Update Action
                        CTE_Action_2 AS (
                            SELECT
                                cte.ProviderToAffiliationID,
                                2 AS ActionCode
                            FROM
                                CTE_ProviderAffiliation AS cte
                                LEFT JOIN Mid.ProviderAffiliation AS mid ON cte.ProviderToAffiliationID = mid.ProviderToAffiliationID
                            WHERE
                                MD5(IFNULL(cte.ProviderID::VARCHAR, '')) <> MD5(IFNULL(mid.ProviderID::VARCHAR, '')) OR
                                MD5(IFNULL(cte.AffiliationBeginDate::VARCHAR, '')) <> MD5(IFNULL(mid.AffiliationBeginDate::VARCHAR, ''))  OR
                                MD5(IFNULL(cte.AffiliationEndDate::VARCHAR, '')) <> MD5(IFNULL(mid.AffiliationEndDate::VARCHAR, ''))  OR
                                MD5(IFNULL(cte.AffiliationName::VARCHAR, '')) <> MD5(IFNULL(mid.AffiliationName::VARCHAR, '')) OR
                                MD5(IFNULL(cte.AffiliationTypeCode::VARCHAR, '')) <> MD5(IFNULL(mid.AffiliationTypeCode::VARCHAR, '')) OR
                                MD5(IFNULL(cte.AffiliationTypeDescription::VARCHAR, '')) <> MD5(IFNULL(mid.AffiliationTypeDescription::VARCHAR, '')) OR
                                MD5(IFNULL(cte.RoleCode::VARCHAR, '')) <> MD5(IFNULL(mid.RoleCode::VARCHAR, ''))OR
                                MD5(IFNULL(cte.RoleDescription::VARCHAR, '')) <> MD5(IFNULL(mid.RoleDescription::VARCHAR, '')) 
                        
                        )
                        SELECT
                            A0.ProviderToAffiliationID,
                            A0.ProviderID,
                            A0.AffiliationBeginDate,
                            A0.AffiliationEndDate,
                            A0.AffiliationName,
                            A0.AffiliationTypeCode,
                            A0.AffiliationTypeDescription,
                            A0.RoleCode,
                            A0.RoleDescription,
                            IFNULL(
                                A1.ActionCode,
                                IFNULL(A2.ActionCode, A0.ActionCode)
                            ) AS ActionCode
                        FROM
                            CTE_ProviderAffiliation AS A0
                            LEFT JOIN CTE_Action_1 AS A1 ON A0.ProviderToAffiliationID = A1.ProviderToAffiliationID
                            LEFT JOIN CTE_Action_2 AS A2 ON A0.ProviderToAffiliationID = A2.ProviderToAffiliationID
                        WHERE
                            IFNULL(
                                A1.ActionCode,
                                IFNULL(A2.ActionCode, A0.ActionCode)
                            ) <> 0 $$;

--- Update Statement
update_statement := ' UPDATE 
                     SET 
                        ProviderToAffiliationID = source.ProviderToAffiliationID,
                        ProviderID = source.ProviderID,
                        AffiliationBeginDate = source.AffiliationBeginDate,
                        AffiliationEndDate = source.AffiliationEndDate,
                        AffiliationName = source.AffiliationName,
                        AffiliationTypeCode = source.AffiliationTypeCode,
                        AffiliationTypeDescription = source.AffiliationTypeDescription,
                        RoleCode = source.RoleCode,
                        RoleDescription = source.RoleDescription';

--- Insert Statement
insert_statement := ' INSERT  (
                            ProviderToAffiliationID,
                            ProviderID,
                            AffiliationBeginDate,
                            AffiliationEndDate,
                            AffiliationName,
                            AffiliationTypeCode,
                            AffiliationTypeDescription,
                            RoleCode,
                            RoleDescription)
                      VALUES (
                            source.ProviderToAffiliationID,
                            source.ProviderID,
                            source.AffiliationBeginDate,
                            source.AffiliationEndDate,
                            source.AffiliationName,
                            source.AffiliationTypeCode,
                            source.AffiliationTypeDescription,
                            source.RoleCode,
                            source.RoleDescription)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Mid.ProviderAffiliation as target USING 
                   ('||select_statement||') as source 
                   ON source.ProviderToAffiliationID = target.ProviderToAffiliationID
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