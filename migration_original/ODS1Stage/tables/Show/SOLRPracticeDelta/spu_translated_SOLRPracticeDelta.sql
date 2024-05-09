CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRPRACTICEDELTA(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Show.SOLRPracticeDelta depends on:
--- MDM_TEAM.MST.Provider_Profile_Processing
--- Base.Practice
--- Base.ProviderToOffice
--- Base.Office
--- Base.Provider

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    truncate_statement STRING;
    merge_statement_1 STRING; -- Merge statement to final table
    merge_statement_2 STRING;
    merge_statement_3 STRING;
    merge_statement_4 STRING;
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_SOLRPracticeDelta');
    execution_start DATETIME default getdate();

   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
BEGIN
--- conditionals are executed in the execution section


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     
merge_statement_1 := 'MERGE INTO Show.SOLRPracticeDelta as target USING 
                                           (SELECT DISTINCT
                                                pr.PracticeID,
                                                spd.SolrDeltaTypeCode, 
                                                spd.MidDeltaProcessComplete, 
                                                spd.StartDeltaProcessDate,
                                                spd.EndDeltaProcessDate,
                                                spd.StartMoveDate,
                                                spd.EndMoveDate
                                            FROM	MDM_TEAM.MST.Provider_Profile_Processing as ppp
                                                    JOIN Base.Provider AS P On p.providercode = ppp.ref_provider_code
                                            		join	Base.ProviderToOffice po on p.ProviderID = po.ProviderID
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
                                    MDM_TEAM.MST.Provider_Profile_Processing as ppp
                                    inner JOIN Base.Provider AS P On p.providercode = ppp.ref_provider_code
                                    inner join Base.ProviderToOffice as pto on p.ProviderID = pto.ProviderID
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

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

-- Merge statement ran regardless of the parameter value
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

IF (IsProviderDeltaProcessing) THEN
        EXECUTE IMMEDIATE merge_statement_1;
ELSE
        EXECUTE IMMEDIATE truncate_statement;
        EXECUTE IMMEDIATE merge_statement_2;
        EXECUTE IMMEDIATE merge_statement_3;
END IF;
EXECUTE IMMEDIATE merge_statement_4 ;

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