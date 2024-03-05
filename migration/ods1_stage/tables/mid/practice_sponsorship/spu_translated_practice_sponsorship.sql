
--- Create temporary tables
-- 1. Create #PracticeBatch as a CTE

WITH CTE_PracticeBatch AS (
    CASE 
        WHEN @IsProviderDeltaProcessing = 0 THEN
            SELECT DISTINCT a.PracticeID, a.PracticeCode 
            FROM Base.Practice AS a 
        ELSE 
            SELECT DISTINCT p.PracticeID, p.PracticeCode
            FROM Snowflake.etl.ProviderDeltaProcessing AS a
            JOIN base.ProviderToOffice pto ON a.ProviderID = pto.ProviderID
            JOIN base.Office o ON pto.OfficeID = o.OfficeID
            JOIN Base.Practice AS p ON p.PracticeID = o.PracticeID
    END
)
SELECT * FROM CTE_PracticeBatch 
ORDER BY PracticeID;
------ !!!!!!!!!!!!!!!!!  TO DO: CHECK INDEX CREATION IN LINE 41 !!!!!!!!!!!!!!!!!!!!!

-- 2. Create #PracticeSponsorship


-- 3. Create RawPracData as CTE
WITH RawPracData AS (
SELECT	f.PracticeID,f.PracticeCode,c.ProductCode,c.ProductDescription,pg.ProductGroupCode,pg.ProductGroupDescription,
	a.ClientToProductID,b.ClientCode,b.ClientName,
	ROW_NUMBER() OVER (PARTITION BY f.PracticeID,f.PracticeCode,c.ProductCode, c.ProductDescription,pg.ProductGroupCode,pg.ProductGroupDescription  ORDER BY d.LastUpdateDate ASC) AS recID
FROM	Base.ClientToProduct a
        JOIN Base.Client b ON a.ClientID = b.ClientID
		JOIN Base.Product c ON a.ProductID = c.ProductID
		JOIN Base.ProductGroup pg ON c.ProductGroupID = pg.ProductGroupID
		JOIN Base.ClientProductToEntity d ON a.ClientToProductID = d.ClientToProductID
		JOIN Base.EntityType e ON d.EntityTypeID = e.EntityTypeID AND e.EntityTypeCode = 'PRAC'
		JOIN Base.Practice f ON d.EntityID = f.PracticeID
		JOIN CTE_PracticeBatch as pb ON d.EntityID = pb.PracticeID --When not migrating a batch, this is all Practices in Base.Practice. Otherwise it is just the Practices in the batch
		WHERE	a.ActiveFlag = 1)

-- #PractMultClientRank

-- #ColumnsUpdates