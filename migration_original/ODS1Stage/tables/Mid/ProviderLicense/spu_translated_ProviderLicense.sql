CREATE OR REPLACE PROCEDURE ODS1_STAGE.MID.SP_LOAD_PROVIDERLICENSE(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Mid.ProviderLicense depends on: 
--- MDM_TEAM.MST.Provider_Profile_Processing
--- Base.Provider
--- Base.ProviderLicense
--- Base.State

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    truncate_statement STRING;
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
                    pdp.ProviderID
                FROM
                    Raw.Provider_Profile_Processing as pdp),';
    ELSE
           truncate_statement := 'TRUNCATE TABLE Mid.ProviderLicense';
           EXECUTE IMMEDIATE truncate_statement;
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
                    $$ CTE_ProviderLicense AS (
                        SELECT
                            pl.ProviderID,
                            pl.LicenseNumber,
                            pl.LicenseEffectiveDate,
                            pl.LicenseTerminationDate,
                            st.State,
                            st.StateName,
                            pl.LicenseType,
                            0 AS ActionCode
                        FROM
                            CTE_ProviderBatch AS pb
                            JOIN Base.ProviderLicense AS pl ON pl.ProviderID = pb.ProviderID
                            JOIN Base.State AS st ON st.StateID = pl.StateID
                    ),
                    -- Insert Action
                    CTE_Action_1 AS (
                        SELECT
                            cte.ProviderID,
                            1 AS ActionCode
                        FROM
                            CTE_ProviderLicense AS cte
                            LEFT JOIN Mid.ProviderLicense AS mid ON cte.ProviderID = mid.ProviderID
                        WHERE
                            mid.ProviderID IS NULL
                    ),
                    -- Update Action
                    CTE_Action_2 AS (
                        SELECT
                            cte.ProviderID,
                            2 AS ActionCode
                        FROM
                            CTE_ProviderLicense AS cte
                            JOIN Mid.ProviderLicense AS mid ON cte.ProviderID = mid.ProviderID
                        WHERE
                            MD5(IFNULL(cte.LicenseNumber::VARCHAR, '')) <> MD5(IFNULL(mid.LicenseNumber::VARCHAR, ''))
                            OR MD5(IFNULL(cte.LicenseEffectiveDate::VARCHAR, '')) <> MD5(IFNULL(mid.LicenseEffectiveDate::VARCHAR, ''))
                            OR MD5(IFNULL(cte.LicenseTerminationDate::VARCHAR, '')) <> MD5(IFNULL(mid.LicenseTerminationDate::VARCHAR, ''))
                            OR MD5(IFNULL(cte.State::VARCHAR, '')) <> MD5(IFNULL(mid.State::VARCHAR, ''))
                            OR MD5(IFNULL(cte.StateName::VARCHAR, '')) <> MD5(IFNULL(mid.StateName::VARCHAR, ''))
                            OR MD5(IFNULL(cte.LicenseType::VARCHAR, '')) <> MD5(IFNULL(mid.LicenseType::VARCHAR, ''))
                    )
                    SELECT DISTINCT
                        A0.ProviderID,
                        A0.LicenseNumber,
                        A0.LicenseEffectiveDate,
                        A0.LicenseTerminationDate,
                        A0.State,
                        A0.StateName,
                        A0.LicenseType,
                        IFNULL(
                            A1.ActionCode,
                            IFNULL(A2.ActionCode, A0.ActionCode)
                        ) AS ActionCode
                    FROM
                        CTE_ProviderLicense AS A0
                        LEFT JOIN CTE_Action_1 AS A1 ON A0.ProviderID = A1.ProviderID
                        LEFT JOIN CTE_Action_2 AS A2 ON A0.ProviderID = A2.ProviderID
                    WHERE
                        IFNULL(
                            A1.ActionCode,
                            IFNULL(A2.ActionCode, A0.ActionCode)
                        ) <> 0 $$;

--- Update Statement
update_statement := ' UPDATE 
                     SET 
                        ProviderID = source.ProviderID,
                        LicenseNumber = source.LicenseNumber,
                        LicenseEffectiveDate = source.LicenseEffectiveDate,
                        LicenseTerminationDate = source.LicenseTerminationDate,
                        State = source.State,
                        StateName = source.StateName,
                        LicenseType = source.LicenseType';

--- Insert Statement
insert_statement := ' INSERT  (
                            ProviderID,
                            LicenseNumber,
                            LicenseEffectiveDate,
                            LicenseTerminationDate,
                            State,
                            StateName,
                            LicenseType)
                      VALUES (
                            source.ProviderID,
                            source.LicenseNumber,
                            source.LicenseEffectiveDate,
                            source.LicenseTerminationDate,
                            source.State,
                            source.StateName,
                            source.LicenseType)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Mid.ProviderLicense as target USING 
                   ('||select_statement||') as source 
                   ON source.ProviderID = target.ProviderID AND source.LicenseNumber = target.LicenseNumber AND source.LicenseType = target.LicenseType
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