CREATE OR REPLACE PROCEDURE ODS1_STAGE.MID.SP_LOAD_PRACTICESPONSORSHIP(ISPROVIDERDELTAPROCESSING BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Mid.PracticeSponsorship depends on: 
--- MDM_TEAM.MST.Provider_Profile_Processing
--- Base.Practice
--- Base.ProviderToOffice
--- Base.Office
--- Base.ClientToProduct
--- Base.Client
--- Base.Product
--- Base.ProductGroup
--- Base.ClientProductToEntity
--- Base.EntityType
--- Mid.ProviderSponsorship

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
           WITH CTE_PracticeBatch AS (
                    SELECT 
                        p.PracticeID, 
                        p.PracticeCode
                    FROM raw.Provider_Profile_Processing AS a
                    JOIN base.providertooffice pto ON a.ProviderID = pto.ProviderID
                    JOIN base.Office o ON pto.OfficeID = o.OfficeID
                    JOIN Base.Practice AS p ON p.PracticeID = o.PracticeID
                    GROUP BY 
                        p.PracticeID, 
                        p.PracticeCode
                    ORDER BY p.PracticeID
                    ),';
           
    ELSE
           truncate_statement := 'TRUNCATE TABLE Mid.PracticeSponsorship';
           select_statement := 'WITH CTE_PracticeBatch AS (
                    SELECT 
                        PracticeID, 
                        PracticeCode 
                    FROM Base.Practice
                    GROUP BY 
                        PracticeID, 
                        PracticeCode
                    ORDER BY PracticeID
                    ),';
            EXECUTE IMMEDIATE truncate_statement;
    END IF;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

-- Select Statements
select_statement := select_statement || 
$$
CTE_RawPracData AS (
    SELECT	
        pract.PracticeID,
        pract.PracticeCode,
        prod.ProductCode,
        prod.ProductDescription,
        prodGrp.ProductGroupCode,
        prodGrp.ProductGroupDescription,
        cliToProd.ClientToProductID,
        cli.ClientCode,
        cli.ClientName,
        ROW_NUMBER() OVER (
            PARTITION BY pract.PracticeID, 
                         pract.PracticeCode, 
                         prod.ProductCode, 
                         prod.ProductDescription, 
                         prodGrp.ProductGroupCode, 
                         prodGrp.ProductGroupDescription  
            ORDER BY 
                cliProdToEnt.LastUpdateDate ASC) AS recID -- This assignes a sequential recID to rows that have the same PracticeID, PracticeCode, ProductCode, ProductDescription, ProductGroupCode, ProductGroupDescription
    FROM	
        Base.ClientToProduct as cliToProd
        JOIN Base.Client as cli ON cliToProd.ClientID = cli.ClientID
        JOIN Base.Product as prod ON cliToProd.ProductID = prod.ProductID
        JOIN Base.ProductGroup as prodGrp ON prod.ProductGroupID = prodGrp.ProductGroupID
        JOIN Base.ClientProductToEntity as cliProdToEnt ON cliToProd.ClientToProductID = cliProdToEnt.ClientToProductID
        JOIN Base.EntityType as entType ON cliProdToEnt.EntityTypeID = entType.EntityTypeID AND entType.EntityTypeCode = 'PRAC'
        JOIN Base.Practice as pract ON cliProdToEnt.EntityID = pract.PracticeID
        JOIN CTE_PracticeBatch as practBatch ON cliProdToEnt.EntityID = practBatch.PracticeID 
    WHERE	
        cliToProd.ActiveFlag = 1
),
CTE_PractMultClientRank AS (
    SELECT 
        rawPracData.ClientCode AS ClientCode, 
        rawPracData.PracticeCode AS PracticeCode, 
        rawPracData.ProductCode AS ProductCode, 
        ROW_NUMBER() OVER ( 
            PARTITION BY rawPracData.PracticeCode
            ORDER BY 
                rawPracData.ProductCode, 
                IFNULL(providerCount.ProvCount, 0) DESC, 
                rawPracData.ClientCode 
        ) AS ClientPractRank
    FROM  
        CTE_RawPracData as rawPracData
        LEFT JOIN ( 
            SELECT 
                provSpon.ClientCode AS ClientCode, 
                provSpon.PracticeCode AS PracticeCode, 
                provSpon.ProductCode AS ProductCode, 
                COUNT(DISTINCT provSpon.ProviderCode) AS ProvCount
            FROM 
                Mid.ProviderSponsorship as provSpon
            JOIN CTE_RawPracData as rawPracDataInner ON 
                rawPracDataInner.PracticeCode = provSpon.PracticeCode AND 
                rawPracDataInner.ClientCode = provSpon.ClientCode AND 
                rawPracDataInner.ProductCode = provSpon.ProductCode
            GROUP BY 
                provSpon.ClientCode, 
                provSpon.PracticeCode, 
                provSpon.ProductCode 
        ) AS providerCount ON 
            providerCount.ClientCode = rawPracData.ClientCode AND 
            providerCount.ProductCode = rawPracData.ProductCode AND 
            providerCount.PracticeCode = rawPracData.PracticeCode
),

CTE_InsertPracticeSponsorship AS (
            SELECT 
                rawPracDataInner.PracticeID, 
                rawPracDataInner.PracticeCode, 
                rawPracDataInner.ProductCode, 
                rawPracDataInner.ProductDescription, 
                rawPracDataInner.ProductGroupCode, 
                rawPracDataInner.ProductGroupDescription, 
                rawPracDataInner.ClientToProductID, 
                rawPracDataInner.ClientCode, 
                rawPracDataInner.ClientName, 
                IFNULL(practMultClientRank.ClientPractRank, rawPracDataInner.recID) AS ClientPractRank, -- Equivlaent to ISNULL in SQL Server
                0 AS ActionCode -- Create a new column ActionCode and set it to 0 (default value: no change)

            FROM 
                CTE_RawPracData as rawPracDataInner
                LEFT JOIN CTE_PractMultClientRank as practMultClientRank ON 
                    practMultClientRank.PracticeCode = rawPracDataInner.PracticeCode AND 
                    practMultClientRank.ClientCode = rawPracDataInner.ClientCode AND 
                    practMultClientRank.ProductCode = rawPracDataInner.ProductCode
            WHERE 
                practMultClientRank.ClientPractRank = 1
),
-- Insert Action
CTE_Action_1 AS (
    Select tempPracSpon.PracticeID, 1 AS ActionCode
    FROM CTE_InsertPracticeSponsorship AS tempPracSpon
    LEFT JOIN Mid.PracticeSponsorship AS midPracSpon ON 
        tempPracSpon.PracticeID = midPracSpon.PracticeID AND 
        tempPracSpon.PracticeCode = midPracSpon.PracticeCode
    WHERE midPracSpon.PracticeID IS NULL
    GROUP BY tempPracSpon.PracticeID
),
-- Update Action
CTE_Action_2 AS (
    SELECT tempPracSpon.PracticeID, 2 AS ActionCode
    FROM CTE_InsertPracticeSponsorship AS tempPracSpon
    JOIN Mid.PracticeSponsorship PracSpon ON 
        tempPracSpon.PracticeID = PracSpon.PracticeID AND 
        tempPracSpon.PracticeCode = PracSpon.PracticeCode
    WHERE 
        MD5(IFNULL(tempPracSpon.ProductDescription::VARCHAR, '''''''')) <> MD5(IFNULL(PracSpon.ProductDescription::VARCHAR, ''''''''))
        OR MD5(IFNULL(tempPracSpon.ProductGroupCode::VARCHAR, '''''''')) <> MD5(IFNULL(PracSpon.ProductGroupCode::VARCHAR, ''''''''))
        OR MD5(IFNULL(tempPracSpon.ProductGroupDescription::VARCHAR, '''''''')) <> MD5(IFNULL(PracSpon.ProductGroupDescription::VARCHAR, ''''''''))
        OR MD5(IFNULL(tempPracSpon.ClientToProductID::VARCHAR, '''''''')) <> MD5(IFNULL(PracSpon.ClientToProductID::VARCHAR, ''''''''))
        OR MD5(IFNULL(tempPracSpon.ClientCode::VARCHAR, '''''''')) <> MD5(IFNULL(PracSpon.ClientCode::VARCHAR, ''''''''))
        OR MD5(IFNULL(tempPracSpon.ClientName::VARCHAR, '''''''')) <> MD5(IFNULL(PracSpon.ClientName::VARCHAR, ''''''''))
    GROUP BY tempPracSpon.PracticeID
)
SELECT 
DISTINCT
    A0.PracticeID,
    A0.PracticeCode,
    A0.ProductCode,
    A0.ProductDescription,
    A0.ProductGroupCode ,
    A0.ProductGroupDescription,
    A0.ClientToProductId,
    A0.ClientCode,
    A0.ClientName,
    IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) AS ActionCode
FROM CTE_InsertPracticeSponsorship AS A0
LEFT JOIN
    CTE_ACTION_1 AS A1 ON A0.PracticeID = A1.PracticeID
LEFT JOIN
    CTE_ACTION_2 AS A2 ON A0.PracticeID = A2.PracticeID
WHERE
    IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) <> 0


$$;

--- Update Statement
update_statement := ' UPDATE 
                     SET 
                        PRACTICEID = source.PRACTICEID, 
                        PRACTICECODE = source.PRACTICECODE, 
                        PRODUCTCODE = source.PRODUCTCODE, 
                        PRODUCTDESCRIPTION = source.PRODUCTDESCRIPTION, 
                        PRODUCTGROUPCODE = source.PRODUCTGROUPCODE, 
                        PRODUCTGROUPDESCRIPTION = source.PRODUCTGROUPDESCRIPTION, 
                        CLIENTTOPRODUCTID = source.CLIENTTOPRODUCTID, 
                        CLIENTCODE = source.CLIENTCODE, 
                        CLIENTNAME = source.CLIENTNAME';

--- Insert Statement
insert_statement := ' INSERT  
                        (PRACTICEID, 
                        PRACTICECODE, 
                        PRODUCTCODE, 
                        PRODUCTDESCRIPTION, 
                        PRODUCTGROUPCODE, 
                        PRODUCTGROUPDESCRIPTION, 
                        CLIENTTOPRODUCTID, 
                        CLIENTCODE, 
                        CLIENTNAME)
                      VALUES 
                        (source.PRACTICEID, 
                        source.PRACTICECODE, 
                        source.PRODUCTCODE, 
                        source.PRODUCTDESCRIPTION, 
                        source.PRODUCTGROUPCODE, 
                        source.PRODUCTGROUPDESCRIPTION, 
                        source.CLIENTTOPRODUCTID, 
                        source.CLIENTCODE, 
                        source.CLIENTNAME)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Mid.PracticeSponsorship as target USING 
                   ('||select_statement||') as source 
                   ON source.PracticeId = target.PracticeId
                   WHEN MATCHED AND ActionCode = 2 THEN '||update_statement|| '
                   WHEN NOT MATCHED And ActionCode = 1 THEN '||insert_statement;
                   
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