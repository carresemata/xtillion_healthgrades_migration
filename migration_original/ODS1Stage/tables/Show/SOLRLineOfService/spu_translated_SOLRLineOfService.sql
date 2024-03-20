-- Show_spuSOLRLineOfServiceGenerateFromMid
CREATE OR REPLACE PROCEDURE DEV.SP_LOAD_SOLRLINEOFSERVICE() 
    RETURNS STRING
    LANGUAGE SQL
    AS  

DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Show.SOLRLineOfService depends on: 
--- Mid.LineOfService
--- Show.SOLRLineOfServiceDelta  

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE statement
    update_statement STRING;
    insert_statement STRING;
    merge_statement STRING; -- Insert statement to final table
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    -- no conditionals


---------------------------------------------------------
--------------- 3. Select statements --------------------
---------------------------------------------------------     

select_statement :=
'SELECT
        midLine.LineOfServiceID,
        midLine.LineOfServiceCode,
        midLine.LineOfServiceTypeCode,
        midLine.LineOfServiceDescription,
        midLine.LegacyKey,
        midLine.LegacyKeyName,
        CURRENT_TIMESTAMP AS UpdatedDate,
        CURRENT_USER AS UpdatedSource
    FROM
        Mid.LineOfService midLine
    WHERE
        midLine.LineOfServiceID IN (
            SELECT
                DISTINCT LineOfServiceID
            FROM
                Show.SOLRLineOfServiceDelta
            WHERE
                StartDeltaProcessDate IS NULL
                AND EndDeltaProcessDate IS NULL
                AND SolrDeltaTypeCode = 1 --INSERT/UPDATEs
                AND MidDeltaProcessComplete = 1)'; --this will indicate the Mid tables have been refreshed with the updated data
                     
---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

update_statement :=
'UPDATE
SET
    solrLine.LineOfServiceID = LineService.LineOfServiceID,
    solrLine.LineOfServiceCode = LineService.LineOfServiceCode,
    solrLine.LineOfServiceTypeCode = LineService.LineOfServiceTypeCode,
    solrLine.LineOfServiceDescription = LineService.LineOfServiceDescription,
    solrLine.LegacyKey = LineService.LegacyKey,
    solrLine.LegacyKeyName = LineService.LegacyKeyName,
    solrLine.UpdatedDate = LineService.UpdatedDate,
    solrLine.UpdatedSource = LineService.UpdatedSource';
 

insert_statement :=
'INSERT
    (
        LineOfServiceID,
        LineOfServiceCode,
        LineOfServiceTypeCode,
        LineOfServiceDescription,
        LegacyKey,
        LegacyKeyName,
        UpdatedDate,
        UpdatedSource
    )
VALUES
    (
        LineService.LineOfServiceID,
        LineService.LineOfServiceCode,
        LineService.LineOfServiceTypeCode,
        LineService.LineOfServiceDescription,
        LineService.LegacyKey,
        LineService.LegacyKeyName,
        LineService.UpdatedDate,
        LineService.UpdatedSource
    )';

 
-- Start the MERGE operation
merge_statement := 
'MERGE INTO Dev.SOLRLineOfService AS solrLine USING 
    (' || select_statement || ') AS LineService 
    ON LineService.LineOfServiceID = solrLine.LineOfServiceID
    WHEN MATCHED THEN'
        || update_statement ||
    'WHEN NOT MATCHED THEN'
        || insert_statement ;

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