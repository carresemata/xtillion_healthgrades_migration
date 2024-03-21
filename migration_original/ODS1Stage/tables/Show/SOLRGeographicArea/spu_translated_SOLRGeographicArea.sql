-- spuSOLRGeographicAreaGenerateFromMid
CREATE OR REPLACE PROCEDURE SHOW.SP_LOAD_SOLRGEOGRAPHICAREA() 
    RETURNS STRING
    LANGUAGE SQL
    AS  

DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Show.SOLRGeographicArea depends on: 
--- Show.SOLRGeographicAreaDelta
--- Mid.GeographicArea

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
----------------- 3. SQL statements ---------------------
---------------------------------------------------------     

-- Select Statement
select_statement := 'WITH CTE_geoId AS (SELECT
    DISTINCT GeographicAreaID
FROM
    Show.SOLRGeographicAreaDelta
WHERE
    StartDeltaProcessDate IS NULL
    AND EndDeltaProcessDate IS NULL
    AND SolrDeltaTypeCode = 1 --INSERT/UPDATEs
    AND MidDeltaProcessComplete = 1 ) --this will indicate the Mid TABLEs have been refreshed with the updated data

SELECT
            midGeo.GeographicAreaID,
            midGeo.GeographicAreaCode,
            midGeo.GeographicAreaTypeCode,
            midGeo.GeographicAreaValue,
            CURRENT_TIMESTAMP AS UpdatedDate,
            CURRENT_USER AS UpdatedSource
        FROM
            Mid.GeographicArea midGeo
            JOIN (SELECT GeographicAreaID FROM CTE_geoId) as geoId on geoId.GeographicAreaID = midGeo.GeographicAreaID';

-- Update Statement
update_statement := 
'UPDATE
SET
    solrGeo.GeographicAreaID = GeoArea.GeographicAreaID,
    solrGeo.GeographicAreaCode = GeoArea.GeographicAreaCode,
    solrGeo.GeographicAreaTypeCode = GeoArea.GeographicAreaTypeCode,
    solrGeo.GeographicAreaValue = GeoArea.GeographicAreaValue,
    solrGeo.UpdatedDate = GeoArea.UpdatedDate,
    solrGeo.UpdatedSource = GeoArea.UpdatedSource';

-- Insert Statement 
insert_statement := 
'INSERT
    (
        GeographicAreaID,
        GeographicAreaCode,
        GeographicAreaTypeCode,
        GeographicAreaValue,
        UpdatedDate,
        UpdatedSource
    )
VALUES
    (
        GeoArea.GeographicAreaID,
        GeoArea.GeographicAreaCode,
        GeoArea.GeographicAreaTypeCode,
        GeoArea.GeographicAreaValue,
        GeoArea.UpdatedDate,
        GeoArea.UpdatedSource
    );';
                     
---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := 
'MERGE INTO SHOW.SOLRGeographicArea AS solrGeo USING 
    (' || select_statement || ') AS GeoArea 
    ON GeoArea.GeographicAreaID = solrGeo.GeographicAreaID
    WHEN MATCHED THEN '
        || update_statement ||
    ' WHEN NOT MATCHED THEN ' 
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
