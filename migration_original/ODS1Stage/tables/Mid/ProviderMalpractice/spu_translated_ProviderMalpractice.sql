CREATE OR REPLACE PROCEDURE ODS1_STAGE.MID.SP_LOAD_PROVIDERMALPRACTICE(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Mid.ProviderMalpractice depends on: 
--- MDM_TEAM.MST.Provider_Profile_Processing
--- Base.Provider
--- Base.ProviderMalpractice
--- Base.MalpracticeClaimType
--- Base.MalpracticeState
--- Base.State

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
                    $$ CTE_ProviderMalpractice AS (
                            SELECT
                                DISTINCT pm.ProviderMalpracticeID,
                                pm.ProviderID,
                                mct.MalpracticeClaimTypeCode,
                                mct.MalpracticeClaimTypeDescription,
                                pm.ClaimNumber,
                                pm.ClaimDate,
                                pm.ClaimYear,
                                CASE
                                    WHEN pm.ClaimAmount IS NOT NULL THEN CAST(pm.ClaimAmount AS VARCHAR(50))
                                    ELSE pm.MalpracticeClaimRange
                                END AS ClaimAmount,
                                pm.Complaint,
                                pm.IncidentDate,
                                pm.ClosedDate,
                                pm.ClaimState,
                                st.StateName AS ClaimStateFull,
                                pm.LicenseNumber,
                                pm.ReportDate,
                                0 AS ActionCode
                            FROM
                                CTE_ProviderBatch AS pb
                                JOIN Base.ProviderMalpractice AS pm ON pm.ProviderID = pb.ProviderID
                                JOIN Base.MalpracticeClaimType AS mct ON pm.MalpracticeClaimTypeID = mct.MalpracticeClaimTypeID
                                JOIN Base.MalpracticeState AS ms ON pm.ClaimState = ms.State
                                AND IFNULL(ms.Active, 1) = 1
                                LEFT JOIN Base.State AS st ON pm.ClaimState = st.State
                        ),
                        -- Insert Action
                        CTE_Action_1 AS (
                            SELECT
                                cte.ProviderMalpracticeID,
                                1 AS ActionCode
                            FROM
                                CTE_ProviderMalpractice AS cte
                                LEFT JOIN Mid.ProviderMalpractice AS mid ON cte.ProviderMalpracticeID = mid.ProviderMalpracticeID
                            WHERE
                                mid.ProviderMalpracticeID IS NULL
                        ),
                        -- Update Action
                        CTE_Action_2 AS (
                            SELECT
                                cte.ProviderMalpracticeID,
                                2 AS ActionCode
                            FROM
                                CTE_ProviderMalpractice AS cte
                                JOIN Mid.ProviderMalpractice AS mid ON cte.ProviderMalpracticeID = mid.ProviderMalpracticeID
                            WHERE
                                MD5(IFNULL(cte.ProviderID::VARCHAR, '')) <> MD5(IFNULL(mid.ProviderID::VARCHAR, ''))
                                OR MD5(IFNULL(cte.MalpracticeClaimTypeCode::VARCHAR, '')) <> MD5(IFNULL(mid.MalpracticeClaimTypeCode::VARCHAR, ''))
                                OR MD5(IFNULL(cte.MalpracticeClaimTypeDescription::VARCHAR, '')) <> MD5(IFNULL(mid.MalpracticeClaimTypeDescription::VARCHAR, ''))
                                OR MD5(IFNULL(cte.ClaimNumber::VARCHAR, '')) <> MD5(IFNULL(mid.ClaimNumber::VARCHAR, ''))
                                OR MD5(IFNULL(cte.ClaimDate::VARCHAR, '')) <> MD5(IFNULL(mid.ClaimDate::VARCHAR, ''))
                                OR MD5(IFNULL(cte.ClaimYear::VARCHAR, '')) <> MD5(IFNULL(mid.ClaimYear::VARCHAR, ''))
                                OR MD5(IFNULL(cte.ClaimAmount::VARCHAR, '')) <> MD5(IFNULL(mid.ClaimAmount::VARCHAR, ''))
                                OR MD5(IFNULL(cte.Complaint::VARCHAR, '')) <> MD5(IFNULL(mid.Complaint::VARCHAR, ''))
                                OR MD5(IFNULL(cte.IncidentDate::VARCHAR, '')) <> MD5(IFNULL(mid.IncidentDate::VARCHAR, ''))
                                OR MD5(IFNULL(cte.ClosedDate::VARCHAR, '')) <> MD5(IFNULL(mid.ClosedDate::VARCHAR, ''))
                                OR MD5(IFNULL(cte.ClaimState::VARCHAR, '')) <> MD5(IFNULL(mid.ClaimState::VARCHAR, ''))
                                OR MD5(IFNULL(cte.ClaimStateFull::VARCHAR, '')) <> MD5(IFNULL(mid.ClaimStateFull::VARCHAR, ''))
                                OR MD5(IFNULL(cte.LicenseNumber::VARCHAR, '')) <> MD5(IFNULL(mid.LicenseNumber::VARCHAR, ''))
                                OR MD5(IFNULL(cte.ReportDate::VARCHAR, '')) <> MD5(IFNULL(mid.ReportDate::VARCHAR, ''))
                        )
                        SELECT
                            DISTINCT A0.ProviderMalpracticeID,
                            A0.ProviderID,
                            A0.MalpracticeClaimTypeCode,
                            A0.MalpracticeClaimTypeDescription,
                            A0.ClaimNumber,
                            A0.ClaimDate,
                            A0.ClaimYear,
                            A0.ClaimAmount,
                            A0.Complaint,
                            A0.IncidentDate,
                            A0.ClosedDate,
                            A0.ClaimState,
                            A0.ClaimStateFull,
                            A0.LicenseNumber,
                            A0.ReportDate,
                            IFNULL(
                                A1.ActionCode,
                                IFNULL(A2.ActionCode, A0.ActionCode)
                            ) AS ActionCode
                        FROM
                            CTE_ProviderMalpractice AS A0
                            LEFT JOIN CTE_Action_1 AS A1 ON A0.ProviderMalpracticeID = A1.ProviderMalpracticeID
                            LEFT JOIN CTE_Action_2 AS A2 ON A0.ProviderMalpracticeID = A2.ProviderMalpracticeID
                        WHERE
                            IFNULL(
                                A1.ActionCode,
                                IFNULL(A2.ActionCode, A0.ActionCode)
                            ) <> 0 $$;

--- Update Statement
update_statement := ' UPDATE 
                     SET 
                        ProviderMalpracticeID = source.ProviderMalpracticeID,
                        ProviderID = source.ProviderID,
                        MalpracticeClaimTypeCode = source.MalpracticeClaimTypeCode,
                        MalpracticeClaimTypeDescription = source.MalpracticeClaimTypeDescription,
                        ClaimNumber = source.ClaimNumber,
                        ClaimDate = source.ClaimDate,
                        ClaimYear = source.ClaimYear,
                        ClaimAmount = source.ClaimAmount,
                        Complaint = source.Complaint,
                        IncidentDate = source.IncidentDate,
                        ClosedDate = source.ClosedDate,
                        ClaimState = source.ClaimState,
                        ClaimStateFull = source.ClaimStateFull,
                        LicenseNumber = source.LicenseNumber,
                        ReportDate = source.ReportDate';

--- Insert Statement
insert_statement := ' INSERT  (
                        ProviderMalpracticeID,
                        ProviderID,
                        MalpracticeClaimTypeCode,
                        MalpracticeClaimTypeDescription,
                        ClaimNumber,
                        ClaimDate,
                        ClaimYear,
                        ClaimAmount,
                        Complaint,
                        IncidentDate,
                        ClosedDate,
                        ClaimState,
                        ClaimStateFull,
                        LicenseNumber,
                        ReportDate)
                      VALUES (
                        source.ProviderMalpracticeID,
                        source.ProviderID,
                        source.MalpracticeClaimTypeCode,
                        source.MalpracticeClaimTypeDescription,
                        source.ClaimNumber,
                        source.ClaimDate,
                        source.ClaimYear,
                        source.ClaimAmount,
                        source.Complaint,
                        source.IncidentDate,
                        source.ClosedDate,
                        source.ClaimState,
                        source.ClaimStateFull,
                        source.LicenseNumber,
                        source.ReportDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Mid.Providermalpractice as target USING 
                   ('||select_statement||') as source 
                   ON source.ProviderMalpracticeID = target.ProviderMalpracticeID
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