CREATE OR REPLACE PROCEDURE ODS1_STAGE.SHOW.SP_LOAD_SOLRPRACTICEDELTA(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Show.SOLRPracticeDelta depends on:
--- Raw.ProviderDeltaProcessing
--- Base.Practice
--- Base.ProviderToOffice
--- Base.Office

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
DECLARE 
    truncate_statement STRING;
    merge_statement_1 STRING; -- Merge statement to final table
    merge_statement_2 STRING;
    merge_statement_3 STRING;
    merge_statement_4 STRING;
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    IF (IsProviderDeltaProcessing) THEN
        merge_statement_1 := 'MERGE INTO Show.SOLRPracticeDelta as target USING 
                                           (SELECT DISTINCT
                                                pr.PracticeID,
                                                spd.SolrDeltaTypeCode, 
                                                spd.MidDeltaProcessComplete, 
                                                spd.StartDeltaProcessDate,
                                                spd.EndDeltaProcessDate,
                                                spd.StartMoveDate,
                                                spd.EndMoveDate
                                            FROM	Raw.ProviderDeltaProcessing as pdp
                                            		join	Base.ProviderToOffice po on pdp.ProviderID = po.ProviderID
                                            		join	Base.Office o on po.OfficeID = o.OfficeID
                                            		join	Base.Practice pr on o.PracticeID = pr.PracticeID		
                                            		left join	Show.SOLRPracticeDelta spd on pr.PracticeID = spd.PracticeID) as source 
                                           
                                ON source.Practiceid = target.Practiceid
                                WHEN MATCHED THEN 
                                            UPDATE 
                                                SET
                                                target.ENDDeltaProcessDate = null,
                                				target.StartMoveDate = null,
                                				target.ENDMoveDate = null
                                WHEN NOT MATCHED AND source.StartDeltaProcessDate IS NOT NULL AND source.EndDeltaProcessDate IS NULL AND source.PracticeID IS NULL THEN 
                                            INSERT (
                                            PracticeID,
                                            SolrDeltaTypeCode,
                                            StartDeltaProcessDate,
                                            MidDeltaProcessComplete
                                            )
                                            VALUES (
                                            source.PracticeID,
                                            source.SolrDeltaTypeCode,
                                            source.StartDeltaProcessDate,
                                            source.MidDeltaProcessComplete
                                            );';

        EXECUTE IMMEDIATE merge_statement_1;
            
           
    ELSE
        truncate_statement := 'TRUNCATE TABLE Show.SOLRPracticeDelta';
        merge_statement_2 := $$MERGE INTO Show.SOLRPracticeDelta as target USING 
                                   (select DISTINCT
                                        pr.PracticeID,
                                        '1' as SolrDeltaTypeCode,
                                        CURRENT_TIMESTAMP() as StartDeltaProcessDate,
                                        '1' as MidDeltaProcessComplete
                                    from
                                        Base.Practice pr
                                        left join Show.SOLRPracticeDelta spd on pr.PracticeID = spd.PracticeID
                                    where
                                        spd.PracticeID is null) as source 
                                   ON source.Practiceid = target.Practiceid
                                   WHEN NOT MATCHED THEN 
                                    INSERT (
                                    PracticeID,
                                    SolrDeltaTypeCode,
                                    StartDeltaProcessDate,
                                    MidDeltaProcessComplete
                                    )
                                    VALUES (
                                    source.PracticeID,
                                    source.SolrDeltaTypeCode,
                                    source.StartDeltaProcessDate,
                                    source.MidDeltaProcessComplete
                                    );$$;

        merge_statement_3 := $$
                            MERGE INTO Show.SOLRPracticeDelta as target USING 
                                (select DISTINCT
                                    o.practiceid,
                                    '1' as SolrDeltaTypeCode,
                                    CURRENT_TIMESTAMP() as StartDeltaProcessDate,
                                    '1' as MidDeltaProcessComplete
                                from
                                    Raw.ProviderDeltaProcessing as pdp
                                    inner join Base.ProviderToOffice as pto on pdp.ProviderID = pto.ProviderID
                                    inner join Base.Office as o on pto.OfficeID = o.OfficeID
                                WHERE
                                    o.practiceid not in (
                                        select
                                            practiceid
                                        from
                                            Show.SOLRPracticeDelta
                                    )) as source
                                ON source.Practiceid = target.Practiceid
                                WHEN NOT MATCHED THEN 
                                INSERT (
                                PracticeID,
                                SolrDeltaTypeCode,
                                StartDeltaProcessDate,
                                MidDeltaProcessComplete
                                )
                                VALUES (
                                source.PracticeID,
                                source.SolrDeltaTypeCode,
                                source.StartDeltaProcessDate,
                                source.MidDeltaProcessComplete
                                );$$;

        EXECUTE IMMEDIATE truncate_statement;
        EXECUTE IMMEDIATE merge_statement_2;
        EXECUTE IMMEDIATE merge_statement_3;
           
    END IF;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     



---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement_4 := 'MERGE INTO Show.SOLRPracticeDelta as target USING 
                   (SELECT DISTINCT
                        PracticeId,
                        StartDeltaProcessDate,
                        EndDeltaProcessDate
                   FROM Show.SOLRPracticeDelta
                   WHERE StartDeltaProcessDate IS NOT NULL AND EndDeltaProcessDate IS NULL) as source 
                   ON source.Practiceid = target.Practiceid
                   WHEN MATCHED THEN
                    UPDATE
                    SET 
                        target.EndDeltaProcessDate  = CURRENT_TIMESTAMP()';
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

-- EXECUTE IMMEDIATE truncate_statement;
-- EXECUTE IMMEDIATE merge_statement_1;
-- EXECUTE IMMEDIATE merge_statement_2;
-- EXECUTE IMMEDIATE merge_statement_3;
EXECUTE IMMEDIATE merge_statement_4 ;

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







