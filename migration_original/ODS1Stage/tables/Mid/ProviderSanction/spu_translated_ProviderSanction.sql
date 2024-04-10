CREATE OR REPLACE PROCEDURE ODS1_STAGE.MID.SP_LOAD_PROVIDERSANCTION(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Mid.ProviderSanction depends on: 
--- Raw.ProviderDeltaProcessing
--- Base.Provider
--- Base.ProviderSanction
--- Base.SanctionType
--- Base.SanctionCategory
--- Base.SanctionAction
--- Base.StateReportingAgency
--- Base.SanctionActionType
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
                    pdp.ProviderID
                FROM
                    Raw.ProviderDeltaProcessing as pdp),';
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
                    $$ CTE_ProviderSanction AS (
                            SELECT
                                ps.ProviderSanctionID,
                                ps.ProviderID,
                                ps.SanctionDescription,
                                ps.SanctionDate,
                                ps.SanctionReinstatementDate AS ReinstatementDate,
                                st.SanctionTypeCode,
                                st.SanctionTypeDescription,
                                sra.State,
                                sc.SanctionCategoryCode,
                                sc.SanctionCategoryDescription,
                                sa.SanctionActionCode,
                                sa.SanctionActionDescription,
                                sat.SanctionActionTypeCode,
                                sat.SanctionActionTypeDescription,
                                s.StateName AS StateFull,
                                0 AS ActionCode
                            FROM
                                CTE_ProviderBatch AS pb
                                JOIN Base.ProviderSanction AS ps ON ps.ProviderID = pb.ProviderID
                                JOIN Base.SanctionType AS st ON ps.SanctionTypeID = st.SanctionTypeID
                                JOIN Base.SanctionCategory AS sc ON ps.SanctionCategoryID = sc.SanctionCategoryID
                                JOIN Base.SanctionAction AS sa ON ps.SanctionActionID = sa.SanctionActionID
                                JOIN Base.StateReportingAgency AS sra ON ps.StateReportingAgencyID = sra.StateReportingAgencyID
                                LEFT JOIN Base.SanctionActionType AS sat ON sa.SanctionActionTypeID = sat.SanctionActionTypeID
                                LEFT JOIN Base.State AS s ON sra.State = s.State
                        ),
                        -- Insert Action
                        CTE_Action_1 AS (
                            SELECT
                                cte.ProviderSanctionID,
                                1 AS ActionCode
                            FROM
                                CTE_ProviderSanction AS cte
                                LEFT JOIN Mid.ProviderSanction AS mid ON cte.ProviderSanctionID = mid.ProviderSanctionID
                            WHERE
                                mid.ProviderSanctionID IS NULL
                        ),
                        -- Update Action
                        CTE_Action_2 AS (
                            SELECT
                                cte.ProviderSanctionID,
                                2 AS ActionCode
                            FROM
                                CTE_ProviderSanction AS cte
                                JOIN Mid.ProviderSanction AS mid ON cte.ProviderSanctionID = mid.ProviderSanctionID
                           WHERE 
                                MD5(IFNULL(cte.ProviderID::VARCHAR,'')) <> MD5(IFNULL(mid.ProviderID::VARCHAR,'')) OR
                                MD5(IFNULL(cte.SanctionDescription::VARCHAR,'')) <> MD5(IFNULL(mid.SanctionDescription::VARCHAR,'')) OR
                                MD5(IFNULL(cte.SanctionDate::VARCHAR,'')) <> MD5(IFNULL(mid.SanctionDate::VARCHAR,'')) OR
                                MD5(IFNULL(cte.ReinstatementDate::VARCHAR,'')) <> MD5(IFNULL(mid.ReinstatementDate::VARCHAR,'')) OR
                                MD5(IFNULL(cte.SanctionTypeCode::VARCHAR,'')) <> MD5(IFNULL(mid.SanctionTypeCode::VARCHAR,'')) OR
                                MD5(IFNULL(cte.SanctionTypeDescription::VARCHAR,'')) <> MD5(IFNULL(mid.SanctionTypeDescription::VARCHAR,'')) OR
                                MD5(IFNULL(cte.SanctionCategoryCode::VARCHAR,'')) <> MD5(IFNULL(mid.SanctionCategoryCode::VARCHAR,'')) OR
                                MD5(IFNULL(cte.SanctionCategoryDescription::VARCHAR,'')) <> MD5(IFNULL(mid.SanctionCategoryDescription::VARCHAR,'')) OR
                                MD5(IFNULL(cte.SanctionActionCode::VARCHAR,'')) <> MD5(IFNULL(mid.SanctionActionCode::VARCHAR,'')) OR
                                MD5(IFNULL(cte.SanctionActionDescription::VARCHAR,'')) <> MD5(IFNULL(mid.SanctionActionDescription::VARCHAR,'')) OR
                                MD5(IFNULL(cte.SanctionActionTypeCode::VARCHAR,'')) <> MD5(IFNULL(mid.SanctionActionTypeCode::VARCHAR,'')) OR
                                MD5(IFNULL(cte.SanctionActionTypeDescription::VARCHAR,'')) <> MD5(IFNULL(mid.SanctionActionTypeDescription::VARCHAR,'')) OR
                                MD5(IFNULL(cte.StateFull::VARCHAR,'')) <> MD5(IFNULL(mid.StateFull::VARCHAR,'')) 
                        )
                        SELECT
                            DISTINCT A0.ProviderSanctionID,
                            A0.ProviderID,
                            A0.SanctionDescription,
                            A0.SanctionDate,
                            A0.ReinstatementDate,
                            A0.SanctionTypeCode,
                            A0.SanctionTypeDescription,
                            A0.SanctionCategoryCode,
                            A0.SanctionCategoryDescription,
                            A0.SanctionActionCode,
                            A0.SanctionActionDescription,
                            A0.SanctionActionTypeCode,
                            A0.SanctionActionTypeDescription,
                            A0.StateFull,
                            IFNULL(
                                A1.ActionCode,
                                IFNULL(A2.ActionCode, A0.ActionCode)
                            ) AS ActionCode
                        FROM
                            CTE_ProviderSanction AS A0
                            LEFT JOIN CTE_Action_1 AS A1 ON A0.ProviderSanctionID = A1.ProviderSanctionID
                            LEFT JOIN CTE_Action_2 AS A2 ON A0.ProviderSanctionID = A2.ProviderSanctionID
                        WHERE
                            IFNULL(
                                A1.ActionCode,
                                IFNULL(A2.ActionCode, A0.ActionCode)
                            ) <> 0 $$;

--- Update Statement
update_statement := ' UPDATE 
                     SET 
                        ProviderSanctionID = source.ProviderSanctionID,
                        ProviderID = source.ProviderID,
                        SanctionDescription = source.SanctionDescription,
                        SanctionDate = source.SanctionDate,
                        ReinstatementDate = source.ReinstatementDate,
                        SanctionTypeCode = source.SanctionTypeCode,
                        SanctionTypeDescription = source.SanctionTypeDescription,
                        SanctionCategoryCode = source.SanctionCategoryCode,
                        SanctionCategoryDescription = source.SanctionCategoryDescription,
                        SanctionActionCode = source.SanctionActionCode,
                        SanctionActionDescription = source.SanctionActionDescription,
                        SanctionActionTypeCode = source.SanctionActionTypeCode,
                        SanctionActionTypeDescription = source.SanctionActionTypeDescription,
                        StateFull = source.StateFull';

--- Insert Statement
insert_statement := ' INSERT  (
                            ProviderSanctionID,
                            ProviderID,
                            SanctionDescription,
                            SanctionDate,
                            ReinstatementDate,
                            SanctionTypeCode,
                            SanctionTypeDescription,
                            SanctionCategoryCode,
                            SanctionCategoryDescription,
                            SanctionActionCode,
                            SanctionActionDescription,
                            SanctionActionTypeCode,
                            SanctionActionTypeDescription,
                            StateFull)
                      VALUES (
                            source.ProviderSanctionID,
                            source.ProviderID,
                            source.SanctionDescription,
                            source.SanctionDate,
                            source.ReinstatementDate,
                            source.SanctionTypeCode,
                            source.SanctionTypeDescription,
                            source.SanctionCategoryCode,
                            source.SanctionCategoryDescription,
                            source.SanctionActionCode,
                            source.SanctionActionDescription,
                            source.SanctionActionTypeCode,
                            source.SanctionActionTypeDescription,
                            source.StateFull)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Mid.ProviderSanction as target USING 
                   ('||select_statement||') as source 
                   ON source.ProviderSanctionID = target.ProviderSanctionID
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