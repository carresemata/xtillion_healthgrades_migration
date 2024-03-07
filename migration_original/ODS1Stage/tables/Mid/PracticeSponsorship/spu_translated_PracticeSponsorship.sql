
--- Create temporary tables
-- 1. Create #PracticeBatch as a CTE
---- IF STATEMENT MISSING
-- WITH CTE_PracticeBatch AS (
--             SELECT 
--                 PracticeID, 
--                 PracticeCode 
--             FROM Base.Practice
--             GROUP BY 
--                 PracticeID, 
--                 PracticeCode
--             ORDER BY PracticeID),
            
WITH CTE_PracticeBatch AS (
            SELECT 
                p.PracticeID, 
                p.PracticeCode
            FROM Snowflake.etl.ProviderDeltaProcessing AS a
            JOIN base.provider_to_office pto ON a.ProviderID = pto.ProviderID
            JOIN base.Office o ON pto.OfficeID = o.OfficeID
            JOIN Base.Practice AS p ON p.PracticeID = o.PracticeID
            GROUP BY 
                p.PracticeID, 
                p.PracticeCode
            ORDER BY p.PracticeID),


------ !!!!!!!!!!!!!!!!!  TO DO: CHECK INDEX CREATION IN LINE 41 !!!!!!!!!!!!!!!!!!!!!

-- 2. Create RawPracData as CTE: get raw data from the Base.ClientToProduct table and join with other tables to get the necessary data
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

-- 3. Create PractMultClientRank as CTE: get practices associated to multiple clients, and use business rules to pick a winner
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

-- 4. Create InsertPracticeSponsorship as CTE: to insert data into PracticeSponsorship
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
                IFNULL(practMultClientRank.ClientPractRank, rawPracDataInner.recID) AS ClientPractRank -- Equivlaent to ISNULL in SQL Server
            FROM 
                CTE_RawPracData as rawPracDataInner
                LEFT JOIN CTE_PractMultClientRank as practMultClientRank ON 
                    practMultClientRank.PracticeCode = rawPracDataInner.PracticeCode AND 
                    practMultClientRank.ClientCode = rawPracDataInner.ClientCode AND 
                    practMultClientRank.ProductCode = rawPracDataInner.ProductCode
            WHERE 
                practMultClientRank.ClientPractRank = 1),

-- 5. Create PracticeSponsorship as temporary table: populate the temp TABLE with CTE_InsertPracticeSponsorship data
CREATE OR REPLACE TEMPORARY TABLE TempPracticeSponsorship AS (
    SELECT 
        CTE_InsertPracticeSponsorship.PracticeID, 
        CTE_InsertPracticeSponsorship.PracticeCode, 
        CTE_InsertPracticeSponsorship.ProductCode, 
        CTE_InsertPracticeSponsorship.ProductDescription, 
        CTE_InsertPracticeSponsorship.ProductGroupCode, 
        CTE_InsertPracticeSponsorship.ProductGroupDescription, 
        CTE_InsertPracticeSponsorship.ClientToProductID, 
        CTE_InsertPracticeSponsorship.ClientCode, 
        CTE_InsertPracticeSponsorship.ClientName,
        0 AS ActionCode -- Create a new column ActionCode and set it to 0 (default value: no change)
    FROM 
        CTE_InsertPracticeSponsorship)

-- 6. Create ColumnUpdates CTE: get the columns that need to be updated
WITH CTE_ColumnUpdates AS (
    SELECT 
        COULUM_NAME AS name, 
        ROW_NUMBER() OVER (ORDER BY name) AS recId -- Equivalent to IDENTITY(INT, 1, 1) in SQL Server
    FROM 
        INFORMATION_SCHEMA.COLUMNS 
    WHERE 
        TABLE_NAME = 'TempPracticeSponsorship' AND 
        name NOT IN ('PracticeCode', 'ProductCode', 'ActionCode'))

	/*
		Flag record level actions for ActionCode
			0 = No Change
			1 = Insert
			2 = UPDATE
	*/

-- ActionCode Insert
-- Set to 1 the ActionCode Column in TempPracticeSponsorship where PracticeID in Mid.PracticeSponsorship is null  
UPDATE TempPracticeSponsorship
SET ActionCode = 1 -- Set ActionCode to 1 (Insert) where PracticeID is null
FROM TempPracticeSponsorship AS tempPracSpon
LEFT JOIN Mid.PracticeSponsorship AS midPracSpon ON 
    tempPracSpon.PracticeID = midPracSpon.PracticeID AND 
    tempPracSpon.PracticeCode = midPracSpon.PracticeCode
WHERE midPracSpon.PracticeID IS NULL;

-- Insert data into Mid.PracticeSponsorship where ActionCode is 1 
INSERT INTO Mid.PracticeSponsorship 
    (
        ClientCode,
        ClientName,
        ClientToProductID,
        PracticeCode,
        PracticeID,
        ProductCode,
        ProductDescription,
        ProductGroupCode,
        ProductGroupDescription
    )
SELECT 
    ClientCode,
    ClientName,
    ClientToProductID,
    PracticeCode,
    PracticeID,
    ProductCode,
    ProductDescription,
    ProductGroupCode,
    ProductGroupDescription
FROM
    TempPracticeSponsorship
WHERE 
    ActionCode = 1 AND PracticeID NOT IN (SELECT PracticeID FROM Mid.PracticeSponsorship);


-- ActionCode Update
--- Declare and set all variables
SET min = 1;
SET WHEREClause = '';
SET sql = 'UPDATE TempPracticeSponsorship TempPracSpon' ||
          'SET TempPracSpon.ActionCode = 2' ||
          'FROM TempPracticeSponsorship TempPracSpon' ||
          'JOIN Mid.PracticeSponsorship MidPracSpon ON TempPracSpon.PracticeID = MidPracSpon.PracticeID AND TempPracSpon.PracticeCode = MidPracSpon.PracticeCode' ||
          'WHERE ';
SET max = (SELECT MAX(recId) FROM CTE_ColumnUpdates)
SET column = '';
SET globalCheck = '';

--- Define the while loop to check if we need to update any columns
------ CHECK IF THE WHILE LOOP IS CORRECT
WHILE $min <= $max
    BEGIN
        SET column = (SELECT name FROM CTE_ColumnUpdates WHERE recId = min);
        SET WHEREClause = WHEREClause || 'BINARY_CHECKSUM(isnull(cast(TempPracSpon.' || column || ' as VARCHAR(max)),'''')) <> BINARY_CHECKSUM(isnull(cast(MidPracSpon.' || column || ' as VARCHAR(max)),''''))' || CHAR(10);
        IF min < max
            BEGIN
                SET WHEREClause = WHEREClause || ' or ';
            END;
        SET min = min + 1;
    END;


--- Action 2: Update data in TempPracticeSponsorship where ActionCode is 2 (This is substituting the dynamic SQL in SQL Server, the loop)
-- We need to try if this works
UPDATE TempPracticeSponsorship
SET ActionCode = 2
FROM TempPracticeSponsorship AS tempPracSpon
JOIN Mid.PracticeSponsorship PracSpon ON 
    tempPracSpon.PracticeID = PracSpon.PracticeID AND 
    tempPracSpon.PracticeCode = PracSpon.PracticeCode
WHERE 
    MD5(IFNULL(tempPracSpon.ProductDescription::VARCHAR, '')) <> MD5(IFNULL(PracSpon.ProductDescription::VARCHAR, ''))
    OR MD5(IFNULL(tempPracSpon.ProductGroupCode::VARCHAR, '')) <> MD5(IFNULL(PracSpon.ProductGroupCode::VARCHAR, ''))
    OR MD5(IFNULL(tempPracSpon.ProductGroupDescription::VARCHAR, '')) <> MD5(IFNULL(PracSpon.ProductGroupDescription::VARCHAR, ''))
    OR MD5(IFNULL(tempPracSpon.ClientToProductID::VARCHAR, '')) <> MD5(IFNULL(PracSpon.ClientToProductID::VARCHAR, ''))
    OR MD5(IFNULL(tempPracSpon.ClientCode::VARCHAR, '')) <> MD5(IFNULL(PracSpon.ClientCode::VARCHAR, ''))
    OR MD5(IFNULL(tempPracSpon.ClientName::VARCHAR, '')) <> MD5(IFNULL(PracSpon.ClientName::VARCHAR, ''));



-- Update data in Mid.PracticeSponsorship where ActionCode is 2
DELETE Mid.PracticeSponsorship
FROM 
    Mid.PracticeSponsorship AS midPracSpon
    JOIN CTE_PracticeBatch AS pracBatch ON midPracSpon.PracticeCode = pracBatch.PracticeCode
    LEFT JOIN TempPracticeSponsorship AS tempPracSpon ON 
        midPracSpon.PracticeID = tempPracSpon.PracticeID AND 
        midPracSpon.PracticeCode = tempPracSpon.PracticeCode AND
        midPracSpon.ProductCode = tempPracSpon.ProductCode AND
        midPracSpon.ClientToProductID = tempPracSpon.ClientToProductID AND
        midPracSpon.ClientCode = tempPracSpon.ClientCode
WHERE 
    tempPracSpon.PracticeID IS NULL;
