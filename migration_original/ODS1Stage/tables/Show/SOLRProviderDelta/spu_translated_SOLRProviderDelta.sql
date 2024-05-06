CREATE OR REPLACE PROCEDURE ODS1_STAGE.SHOW.SP_LOAD_SOLRPROVIDERDELTA(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  

DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Show.SOLRProviderDelta depends on: 
--- MDM_TEAM.MST.Provider_Profile_Processing
--- Base.Provider
--- Base.ProvidersWithSponsorshipIssues (empty)
--- Show.SOLRProviderDelta_PoweredByHealthgrades (empty)

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    merge_statement_if_1 STRING;
    merge_statement_if_2 STRING;
    select_statement_if_3 STRING;
    insert_statement_if_3 STRING;
    merge_statement_if_3 STRING;
    select_statement_else STRING;
    insert_statement_else STRING;
    merge_statement_else STRING;
    update_statement STRING;
    status STRING;
    
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    IF (IsProviderDeltaProcessing) THEN

        merge_statement_if_1 := 'MERGE INTO Show.SOLRProviderDelta as target USING
                                    (SELECT	
                                        ProviderId, 
                                        1 AS SolrDeltaTypeCode, 
                                        CURRENT_TIMESTAMP() AS StartDeltaProcessDate
                            		FROM	Raw.Provider_Profile_Processing
                            		WHERE	ProviderId NOT IN (SELECT ProviderId FROM Show.SOLRProviderDelta)) as source
                                    ON source.ProviderId = target.ProviderId
                                    WHEN NOT MATCHED THEN
                                        INSERT (
                                            ProviderId, 
                                            SolrDeltaTypeCode, 
                                            StartDeltaProcessDate
                                        )
                                        VALUES (
                                            source.ProviderId, 
                                            source.SolrDeltaTypeCode, 
                                            source.StartDeltaProcessDate
                                        );';

         merge_statement_if_2 :=  'MERGE INTO Show.SOLRProviderDelta AS target USING 
                                    (SELECT 
                                        ProvDelta.ProviderID
                                    FROM 
                                        Raw.Provider_Profile_Processing AS ProvDelta
                                    INNER JOIN Show.SOLRProviderDelta SOLRProvDelta
                                    ON ProvDelta.ProviderID = SOLRProvDelta.ProviderID) AS source
                                    ON source.ProviderID = target.ProviderID
                                    WHEN MATCHED THEN 
                                        UPDATE SET
                                        target.ENDDeltaProcessDate = NULL,
                                        target.StartMoveDate = NULL,
                                        target.ENDMoveDate = NULL;';

         select_statement_if_3 := 'WITH CTE_union AS (
                                    SELECT
                                        DISTINCT ProvDelta.ProviderID,
                                        1 AS SolrDeltaTypeCode,
                                        CURRENT_TIMESTAMP() AS StartDeltaProcessDate,
                                        1 AS MidDeltaProcessComplete
                                    FROM
                                        Raw.Provider_Profile_Processing AS ProvDelta
                                        INNER JOIN Base.Provider AS BaseProv ON BaseProv.ProviderID = ProvDelta.ProviderID
                                        LEFT JOIN Show.SOLRProviderDelta AS SOLRProvDelta ON SOLRProvDelta.ProviderID = ProvDelta.ProviderID
                                        LEFT JOIN Base.ProvidersWithSponsorshipIssues AS ProvIssue ON ProvIssue.ProviderCode = BaseProv.ProviderCode
                                    WHERE
                                        SOLRProvDelta.ProviderID IS NULL
                                        AND ProvIssue.ProviderCode IS NULL
                                    UNION
                                    SELECT
                                        DISTINCT SOLRProvHealth.ProviderID,
                                        1 AS SolrDeltaTypeCode,
                                        CURRENT_TIMESTAMP() AS StartDeltaProcessDate,
                                        1 AS MidDeltaProcessComplete
                                    FROM
                                        Show.SOLRProviderDelta_PoweredByHealthgrades AS SOLRProvHealth
                                        LEFT JOIN Base.Provider AS BaseProv ON BaseProv.EDWBaseRecordID = SOLRProvHealth.ProviderID
                                    WHERE
                                        SOLRProvHealth.ProviderID NOT IN (
                                            SELECT
                                                ProviderID
                                            FROM
                                                Show.SOLRProviderDelta
                                        )
                                        AND BaseProv.ProviderCode NOT IN (
                                            SELECT
                                                ProviderCode
                                            FROM
                                                Base.ProvidersWithSponsorshipIssues
                                        )
                                ),
                                CTE_final AS (
                                    SELECT
                                        cteUnion.ProviderID,
                                        cteUnion.SolrDeltaTypeCode,
                                        CURRENT_TIMESTAMP() AS StartDeltaProcessDate,
                                        cteUnion.MidDeltaProcessComplete,
                                        ROW_NUMBER() OVER (
                                            PARTITION BY cteUnion.ProviderID
                                            ORDER BY
                                                cteUnion.SolrDeltaTypeCode
                                        ) AS RN1
                                    FROM
                                        cte_union as cteUnion
                                        LEFT JOIN Show.SOLRProviderDelta AS SOLRProvDelta ON SOLRProvDelta.ProviderID = cteUnion.ProviderID
                                    WHERE
                                        SOLRProvDelta.SOLRProviderDeltaID IS NULL
                                )
                                SELECT
                                    ProviderID,
                                    SolrDeltaTypeCode,
                                    StartDeltaProcessDate,
                                    MidDeltaProcessComplete
                                FROM
                                    CTE_final
                                WHERE
                                    RN1 = 1 ';
                            
          insert_statement_if_3 := ' INSERT (
                                        ProviderID,
                                        SolrDeltaTypeCode,
                                        StartDeltaProcessDate,
                                        MidDeltaProcessComplete
                                    )
                                    VALUES (
                                        source.ProviderID,
                                        source.SolrDeltaTypeCode,
                                        source.StartDeltaProcessDate,
                                        source.MidDeltaProcessComplete
                                    )';
                            
          merge_statement_if_3 := ' MERGE INTO Show.SOLRProviderDelta AS target
                                    USING (' || select_statement_if_3 || ') AS source
                                    ON target.ProviderID = source.ProviderID
                                    WHEN NOT MATCHED THEN ' || insert_statement_if_3;


         EXECUTE IMMEDIATE merge_statement_if_1;
         EXECUTE IMMEDIATE merge_statement_if_2;
         EXECUTE IMMEDIATE merge_statement_if_3;
        
    ELSE
        select_statement_else := 'SELECT 
                                    BaseProv.ProviderID, 
                                    ''1'' as SolrDeltaTypeCode, 
                                    CURRENT_TIMESTAMP() as StartDeltaProcessDate, 
                                    ''1'' as MidDeltaProcessComplete 
		                          FROM		
                                    Base.Provider as BaseProv ';
                                    
        insert_statement_else := ' INSERT 
                                        (ProviderID, 
                                        SolrDeltaTypeCode, 
                                        StartDeltaProcessDate, 
                                        MidDeltaProcessComplete)
                                   VALUES
                                        (source.ProviderID, 
                                        source.SolrDeltaTypeCode, 
                                        source.StartDeltaProcessDate, 
                                        source.MidDeltaProcessComplete)';
                                        
        merge_statement_else := ' MERGE INTO Show.SOLRProviderDelta as target USING 
                                       ('|| select_statement_else ||') as source 
                                       ON source.ProviderID = target.ProviderID
                                       WHEN NOT MATCHED THEN ' || insert_statement_else;
                                       
        EXECUTE IMMEDIATE merge_statement_else;
        
    END IF;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Update Statement
update_statement := ' UPDATE Show.SOLRProviderDelta 
                        SET ENDDeltaProcessDate = CURRENT_TIMESTAMP()
                        WHERE StartDeltaProcessDate IS NOT NULL
                        AND ENDDeltaProcessDate IS NULL;';


---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

-- EXECUTE IMMEDIATE merge_statement_if_1;
-- EXECUTE IMMEDIATE merge_statement_if_2;
-- EXECUTE IMMEDIATE merge_statement_if_3;
-- EXECUTE IMMEDIATE merge_statement_else;
EXECUTE IMMEDIATE update_statement ;

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