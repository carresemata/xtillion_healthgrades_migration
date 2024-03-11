SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   procedure [Mid].[spuPracticeRefresh]
(
    @IsProviderDeltaProcessing bit = 0
)
AS

/*--------------------------------------------------------------------------------------------------------------------
Created By:     Abhash Bhandary
Created On:     04/30/2012

Updated By:     Zafer Faddah
Updated On:     08/27/2014
Update Note:    Replaced dbo.Individual with src.Provider 

Reoccurence:    This stored procedure will INSERT/UPDATE/DELETE data FROM the Mid.Practice table that is used for 
                the Practice SOLR Core

Test:           
EXEC Mid.spuPracticeRefresh
                    
TRUNCATE TABLE Mid.Practice

SELECT COUNT(0) FROM Mid.Practice
SELECT * FROM Mid.Practice WHERE GoogleScriptBlock IS NOT NULL
SELECT * FROM Mid.Practice WHERE OfficeCode IS NULL

SELECT PracticeCode, Count(PracticeCode )
FROM ODS2.Mid.Practice GROUP BY PracticeCode 
HAVING Count(PracticeCode) > 1


-----------------------------------------------------------------------------------------------------------------------*/


DECLARE @ErrorMessage VARCHAR(1000)

BEGIN TRY
            if @IsProviderDeltaProcessing = 0
            begin
                TRUNCATE TABLE Mid.Practice
            END



    --Create & fill table that holds the list of practices for provider records that were supposed to migrate with the batch.  
    --  If this is a full file refresh, migrate all Base.Practice records.
    --  If this is a batch migration, the list records comes from provider deltas
    --  Obviously, if this is a full file refresh then technically a list of the records that migrated isn't neccessary, but it makes
    --      the code that inserts into #Provider much simpler as it removes the need for separate insert queries or dynamic SQL
        begin try drop table #PracticeBatch end try begin catch end catch
        create table #PracticeBatch (PracticeID uniqueidentifier)
        
        if @IsProviderDeltaProcessing = 0 begin
            insert into #PracticeBatch (PracticeID) 
            select a.PracticeID 
            from Base.Practice as a 
            --where practicecode = 'PP3T3CT'
            order by a.PracticeID
          end
        else begin
            insert into #PracticeBatch (PracticeID)
            select distinct e.PracticeID
            from Snowflake.etl.ProviderDeltaProcessing as a
            inner join Base.ProviderToOffice as d on d.ProviderID = a.ProviderID
            inner join Base.Office as e on e.OfficeID = d.OfficeID
            order by e.PracticeID
        end

    --build a temp table with the same structure as the Mid.Practice
        BEGIN TRY DROP TABLE #Practice END TRY BEGIN CATCH END CATCH
        SELECT  TOP 0 *
        INTO    #Practice
        FROM    Mid.Practice
        
        ALTER TABLE #Practice
        ADD ActionCode INT DEFAULT 0
        
    --populate the temp table WITH data FROM Base schemas
        INSERT INTO #Practice 
            (
                    PracticeID,
                    PracticeCode,
                    PracticeName,
                    YearPracticeEstablished,
                    NPI,
                    PracticeWebsite,
                    PracticeDescription,
                    PracticeLogo,
                    PracticeMedicalDirector,
                    PracticeSoftware,
                    PracticeTIN,
                    OfficeID,
                    OfficeCode,
                    OfficeName,
                    AddressTypeCode,
                    AddressLine1,
                    AddressLine2,
                    AddressLine3,
                    AddressLine4,
                    City,
                    State,
                    ZipCode,
                    County,
                    Nation,
                    Latitude,
                    Longitude,
                    FullPhone,
                    FullFax,
                    HasBillingStaff,
                    HasHandicapAccess,
                    HasLabServicesOnSite,
                    HasPharmacyOnSite,
                    HasXrayOnSite,
                    IsSurgeryCenter,
                    HasSurgeryOnSite,
                    AverageDailyPatientVolume,
                    PhysicianCount,
                    OfficeCoordinatorName,
                    ParkingInformation,
                    PaymentPolicy,
                    LegacyKeyOffice,
                    LegacyKeyPractice,
                    OfficeRank,
                    CityStatePostalCodeID,
                    HasDentist,OfficeURL
            )
            SELECT  DISTINCT 
                    a.PracticeID,
                    a.PracticeCode,
                    ltrim(rtrim(a.PracticeName)) as PracticeName,
                    a.YearPracticeEstablished,
                    a.NPI, 
                    a.PracticeWebsite,
                    a.PracticeDescription,
                    a.PracticeLogo,
                    a.PracticeMedicalDirector,
                    a.PracticeSoftware,
                    a.PracticeTIN,
                    b.OfficeID,
                    b.OfficeCode,
                    ltrim(rtrim(b.OfficeName)) as officename,
                    d.AddressTypeCode,
                    e.AddressLine1 + ISNULL(+' '+e.Suite,'') as AddressLine1,
                    e.AddressLine2,
                    e.AddressLine3,
                    e.AddressLine4,
                    j.City, 
                    j.State, 
                    j.PostalCode AS ZipCode,
                    j.County,
                    k.NationName AS Nation,
                    e.Latitude,e.Longitude,
                    f.PhoneNumber AS FullPhone,
                    z.PhoneNumber AS FullFax,
                    b.HasBillingStaff,
                    b.HasHandicapAccess,
                    b.HasLabServicesOnSite,
                    b.HasPharmacyOnSite,
                    b.HasXrayOnSite,
                    b.IsSurgeryCenter,
                    b.HasSurgeryOnSite,
                    b.AverageDailyPatientVolume,
                    NULL AS PhysicianCount,
                    b.OfficeCoordinatorName,
                    b.ParkingInformation,
                    b.PaymentPolicy,
                    b.LegacyKey AS LegacyKeyOffice,
                    a.LegacyKey AS LegacyKeyPractice,
                    b.OfficeRank,
                    e.CityStatePostalCodeID,
                    0,
                    REPLACE(
                        REPLACE(
                            replace('/group-directory/'+LOWER(j.State)+'-'+ LOWER(
                                REPLACE(c1.StateName,' ','-'))+'/'+
                    lower(
                        replace(
                            replace(
                                replace(
                                    replace(
                                        replace(
                                            replace(
                                                replace(
                                                    j.City,
                                                    ' - ',' '),
                                                    '&','-'),
                                                    ' ','-'),
                                                    '/','-'),
                                                    '''',''),
                                                    '.',''),
                                                    '--','-')) + '/' + 
                    lower(
                        replace(
                            replace(
                                replace(
                                    replace(
                                        replace(
                                            replace(
                                                replace(
                                                    replace(
                                                        replace(
                                                            replace(
                                                                replace(
                                                                    replace(
                                                                        replace(
                                                                            replace(
                                                                                replace(
                                                                                    replace(
                                                                                        replace(
                                                                                            replace(
                                                                                                replace(
                                                                                                    replace(
                                                                                                        replace(
                                                                                                            replace(
                                                                                                                replace(
                                                                                                                    replace(
                                                                                                                        replace(
                                                                                                                            replace(
                                                                                                                                replace(
                                                                                                                                    replace(
                                                                                                                                        replace(
                                                                                                                                            replace(
                                                                                                                                                replace(
                                                                                                                                                    replace(
                                                                                                                                                        replace(
                                                                                                                                                            replace(
                                                                                                                                                                replace(
                                                                                                                                                                    replace(
                                                                                                                                                                        replace(
                                                                                                                                                                            replace(
                                                                                                                                                                                replace(
                                                                                                                                                                                    LTRIM(RTRIM(a.PracticeName)),
                                                                                                                                                                                    ' - ',' '),
                                                                                                                                                                                    '&','-'),
                                                                                                                                                                                    ' ','-'),
                                                                                                                                                                                    '/','-'),
                                                                                                                                                                                    '\','-'),
                                                                                                                                                                                    '''',''),
                                                                                                                                                                                    ':',''),
                                                                                                                                                                                    '~',''),
                                                                                                                                                                                    ';',''),
                                                                                                                                                                                    '|',''),
                                                                                                                                                                                    '<',''),
                                                                                                                                                                                    '>',''),
                                                                                                                                                                                    '™',''),
                                                                                                                                                                                    '•',''),
                                                                                                                                                                                    '*',''),
                                                                                                                                                                                    '?',''),
                                                                                                                                                                                    '+',''),
                                                                                                                                                                                    '®',''),
                                                                                                                                                                                    '!',''),
                                                                                                                                                                                    '–',''),
                                                                                                                                                                                    '@',''),
                                                                                                                                                                                    '{',''),
                                                                                                                                                                                    '}',''),
                                                                                                                                                                                    '[',''),
                                                                                                                                                                                    ']',''),
                                                                                                                                                                                    '(',''),
                                                                                                                                                                                    ')',''),
                                                                                                                                                                                    'ñ','n'),
                                                                                                                                                                                    'é','e'),
                                                                                                                                                                                    'í','i'),
                                                                                                                                                                                    '"',''),
                                                                                                                                                                                    '’',''),
                                                                                                                                                                                    ' ',''),
                                                                                                                                                                                    '`',''),
                                                                                                                                                                                    ',',''),
                                                                                                                                                                                    '#',''),
                                                                                                                                                                                    '.',''),
                                                                                                                                                                                    '---','-'),
                                                                                                                                                                                    '--','-')) + 
                                                                                                                                                                                    '-' + LOWER(b.OfficeCode) ,'--','-'),char(13),''), char(10),'') AS OfficeURL
            -- SELECT count(*)
            FROM    #PracticeBatch as pb  --When not migrating a batch, this is all offices in Base.Office. Otherwise it is just the offices for the providers in the batch
                    JOIN Base.Practice AS a WITH (NOLOCK) on a.PracticeID = pb.PracticeID
                    JOIN Base.Office AS b WITH (NOLOCK) ON a.PracticeID = b.PracticeID
                    JOIN Base.OfficeToAddress AS c WITH (NOLOCK) ON b.OfficeID = c.OfficeID
                    Join Base.ProviderToOffice po with (nolock) on b.OfficeID = po.OfficeID
                    LEFT JOIN Base.AddressType AS d WITH (NOLOCK)  ON d.AddressTypeID = c.AddressTypeID
                    JOIN Base.Address AS e WITH (NOLOCK) ON e.AddressID = c.AddressID
                    JOIN Base.CityStatePostalCode j WITH (NOLOCK) ON e.CityStatePostalCodeID = j.CityStatePostalCodeID
                    JOIN Base.Nation k ON ISNULL(J.NationID,'00415355-0000-0000-0000-000000000000') = k.NationID
                    JOIN Base.State c1 ON c1.state = j.state
                    LEFT JOIN 
                    (
                        --SERVICE NUMBERS
                        SELECT  b.PhoneNumber, a.OfficeID
                        FROM    Base.OfficeToPhone a
                                JOIN Base.Phone b ON (a.PhoneID = b.PhoneID)
                                JOIN Base.PhoneType c ON a.PhoneTypeID = c.PhoneTypeID AND PhoneTypeCode = 'Service'
                    ) f ON (f.OfficeID = b.OfficeID)
                    LEFT JOIN 
                    (
                        --FAX NUMBERS
                        SELECT  b.PhoneNumber, a.OfficeID
                        FROM    Base.OfficeToPhone a
                                JOIN Base.Phone b ON (a.PhoneID = b.PhoneID)
                                JOIN Base.PhoneType c ON a.PhoneTypeID = c.PhoneTypeID AND PhoneTypeCode = 'Fax'
                    ) z ON (z.OfficeID = b.OfficeID)    

        CREATE CLUSTERED INDEX Temp ON #Practice (PracticeID);
        CREATE NONCLUSTERED INDEX Temp2 ON #Practice (OfficeCode);

        --build a temp table of provider counts
        drop table if exists #TempPhysicianCount
        SELECT PracticeID, COUNT(*) AS PhysicianCount
        into #TempPhysicianCount
        FROM
            (
                SELECT  DISTINCT a.ProviderID, c.PracticeID
                FROM    Base.ProviderToOffice AS a WITH (NOLOCK)
                        JOIN Base.Office AS b WITH (NOLOCK) ON b.OfficeID = a.OfficeID
                        JOIN Base.Practice AS c WITH (NOLOCK) ON c.PracticeID = b.PracticeID
            ) a 
        GROUP BY PracticeID 

        --UPDATE the PhysicianCount based on DISTINCT providers at the Practice level
        update a set a.PhysicianCount = b.PhysicianCount
        --SELECT *
        from #Practice a
        inner join #TempPhysicianCount as b on b.PracticeID = a.PracticeID

        --build a temp table of practices with at least one dentist at one of their office
        drop table if exists #PracticesWithDentists
        select pb.PracticeID 
        into #PracticesWithDentists
        from #PracticeBatch as pb 
        inner join ODS1Stage.base.Office as o with (nolock) on o.PracticeID = pb.PracticeID
        inner join ODS1Stage.base.ProviderToOffice as po with (nolock) on po.OfficeID = o.OfficeID
        inner join ODS1Stage.base.ProviderToProviderType as ppt with (nolock) on ppt.ProviderID = po.ProviderID 
        inner join ODS1Stage.base.ProviderType as pt with (nolock) on pt.ProviderTypeID = ppt.ProviderTypeID
        where pt.ProviderTypeCode = 'DENT'

        update a set HasDentist = 1
        from #Practice as a 
        inner join #PracticesWithDentists as pwd on pwd.PracticeID = a.PracticeID
                
        UPDATE prac
        SET prac.GoogleScriptBlock =
                    '{"@@context": "http://schema.org","@@type" : "MedicalClinic","@@id":"'+prac.OfficeURL+'","name":"'+prac.PracticeName+'","address": {"@@type": "PostalAddress","streetAddress":"'+prac.AddressLine1+'","addressLocality":"'+prac.City+'","addressRegion":"'+prac.State+'","postalCode":"'+prac.ZipCode+'","addressCountry": "US"},"geo": {"@@type":"GeoCoordinates","latitude":"'+CAST(prac.Latitude AS VARCHAR(MAX))+'","longitude":"'+CAST(prac.Longitude AS VARCHAR(MAX))+'"},"telephone":"'+ISNULL(prac.FullPhone,'')+'","potentialAction":{"@@type":"ReserveAction","@@id":"/groupgoogleform/'+prac.OfficeCode+'","url":"/groupgoogleform"}}'
        --select prac.GoogleScriptBlock, '{"@@context": "http://schema.org","@@type" : "MedicalClinic","@@id":"'+prac.OfficeURL+'","name":"'+prac.PracticeName+'","address": {"@@type": "PostalAddress","streetAddress":"'+prac.AddressLine1+'","addressLocality":"'+prac.City+'","addressRegion":"'+prac.State+'","postalCode":"'+prac.ZipCode+'","addressCountry": "US"},"geo": {"@@type":"GeoCoordinates","latitude":"'+CAST(prac.Latitude AS VARCHAR(MAX))+'","longitude":"'+CAST(prac.Longitude AS VARCHAR(MAX))+'"},"telephone":"'+ISNULL(prac.FullPhone,'')+'","potentialAction":{"@@type":"ReserveAction","@@id":"/groupgoogleform/'+prac.OfficeCode+'","url":"/groupgoogleform"}}'
        FROM   #Practice prac
        JOIN (
                SELECT x1.OfficeCode FROM Base.Office x1 WHERE x1.OfficeCode IN
                ( 'OOO5XB5','OOO82BH','Y3GT4X','YBD8MY','YBD8V7','OOJQPVR','OOJQQB2','YCFH2F','YCFHK7','OOO38H7','YBV56C','OOJVW28','OOJQPWJ','OOS4S2S','OOJTJTQ','YBV5LG','OOO8HQ3')
                --AND x1.OfficeCode = prac.OfficeCode
                UNION

                SELECT g.OfficeCode
                FROM   Base.ClientToProduct a
                            JOIN Base.Client b ON a.ClientID = b.ClientID
                            JOIN Base.Product c ON a.ProductID = c.ProductID AND c.ProductCode = 'PDCPRAC'
                            JOIN Base.ProductGroup pg ON c.ProductGroupID = pg.ProductGroupID AND pg.ProductGroupCode = 'PDC'
                            JOIN Base.ClientProductToEntity d ON a.ClientToProductID = d.ClientToProductID
                            JOIN Base.EntityType e ON d.EntityTypeID = e.EntityTypeID AND e.EntityTypeCode = 'PROV'
                            JOIN base.Provider AS pb ON d.EntityID = pb.ProviderID --When not migrating a batch, this is all providers in Base.Provider. Otherwise it is just the providers in the batch
                            JOIN Base.Provider f ON d.EntityID = f.ProviderID
                            JOIN ( SELECT u.ParentID, x.OfficeID, x.OfficeCode, x.OfficeName, y.PracticeID, y.PracticeCode, y.PracticeName,w.ClientProductToEntityID                           
                                            FROM       Base.ClientProductEntityRelationship u 
                                                        JOIN Base.RelationshipType v ON u.RelationshipTypeID = v.RelationshipTypeID
                                                        JOIN Base.ClientProductToEntity w ON w.ClientProductToEntityID = u.ChildID
                                                        JOIN Base.Office x ON w.EntityID = x.OfficeID 
                                                        JOIN Base.Practice y WITH (NOLOCK) ON x.PracticeID = y.PracticeID
                                            WHERE  v.RelationshipTypeCode = 'PROVTOOFF'   
                                    ) g ON d.ClientProductToEntityID = g.ParentID
                WHERE  a.ActiveFlag = 1
                    --AND g.OfficeCode = prac.OfficeCode
                UNION

                SELECT o.OfficeCode 
                FROM   Base.ClientToProduct a
                            JOIN Base.Client b ON a.ClientID = b.ClientID
                            JOIN Base.Product c ON a.ProductID = c.ProductID AND c.ProductCode <> 'PDCPRAC'
                            JOIN Base.ProductGroup pg ON c.ProductGroupID = pg.ProductGroupID AND pg.ProductGroupCode = 'PDC'
                            JOIN Base.ClientProductToEntity d ON a.ClientToProductID = d.ClientToProductID
                            JOIN Base.EntityType e ON d.EntityTypeID = e.EntityTypeID AND e.EntityTypeCode = 'PROV'
                            JOIN Base.Provider f ON d.EntityID = f.ProviderID
                            JOIN Base.ProviderToOffice pto ON pto.ProviderID = f.ProviderID
                            JOIN Base.Office o ON o.officeID = pto.OfficeID
                WHERE  a.ActiveFlag = 1
                    --AND o.OfficeCode = prac.OfficeCode
             ) x ON x.OfficeCode = prac.OfficeCode
            

    /*
        Flag record level actions for ActionCode
            0 = No Change
            1 = Insert
            2 = UPDATE
    */
        --ActionCode Insert
            UPDATE  a
            SET     a.ActionCode = 1
            --SELECT *
            FROM    #Practice a
                    LEFT JOIN Mid.Practice b ON (a.PracticeID = b.PracticeID and a.OfficeID = b.OfficeID)
            WHERE   b.PracticeID IS NULL
        
        --ActionCode UPDATE
            BEGIN TRY DROP TABLE #ColumnsUpdates END TRY BEGIN CATCH END CATCH
            
            SELECT  name, IDENTITY(INT,1,1) AS recId
            INTO    #ColumnsUpdates
            FROM    tempdb..syscolumns 
            WHERE   id = object_id('TempDB..#Practice')
            AND name NOT IN ('PracticeID','OfficeID','ActionCode')
                
            --build the sql statement WITH dynamic sql to check if we need to UPDATE any columns
                DECLARE @sql VARCHAR(8000)
                DECLARE @min INT
                DECLARE @max INT
                DECLARE @WhereClause VARCHAR(8000)
                DECLARE @column VARCHAR(100)
                DECLARE @newline CHAR(1)
                DECLARE @globalCheck VARCHAR(3)

                SET @min = 1
                SET @WhereClause = ''
                SET @newline = CHAR(10)
                SET @sql = 'UPDATE a'+@newline+ 
                           'SET a.ActionCode = 2'+@newline+
                           '--SELECT *'+@newline+
                           'FROM #Practice a'+@newline+
                           'JOIN Mid.Practice b WITH (NOLOCK) ON (a.PracticeID = b.PracticeID and a.OfficeID = b.OfficeID)'+@newline+
                           'WHERE '
                           
                SELECT @max = MAX(recId) FROM #ColumnsUpdates

                while @min <= @max  
                    BEGIN
                        SELECT @column = name FROM #ColumnsUpdates WHERE recId = @min 
                        SET @WhereClause = @WhereClause +'BINARY_CHECKSUM(ISNULL(cast(a.'+@column+' AS VARCHAR(max)),'''')) <> BINARY_CHECKSUM(ISNULL(cast(b.'+@column+' AS VARCHAR(max)),''''))'+@newline
                            --put an OR for all except for the last column check
                            IF @min < @max 
                                BEGIN
                                    SET @WhereClause = @WhereClause+' or '
                                END

                        
                        SET @min = @min + 1
                    END

                SET @sql = @sql + @WhereClause
                EXEC (@sql)

    /*
        Complete the ActionCode
    */
    
        --define column SET for INSERTS 
        BEGIN TRY DROP TABLE #ColumnInserts END TRY BEGIN CATCH END CATCH

        SELECT  name, IDENTITY(INT,1,1) AS recId
        INTO    #ColumnInserts
        FROM    tempdb..syscolumns 
        WHERE   id = object_id('TempDB..#Practice')
                AND name <> 'ActionCode'--do not need to insert/UPDATE this field
        
        --create the column SET
        DECLARE @columnInsert VARCHAR(100)
        DECLARE @columnListInsert VARCHAR(8000)
        DECLARE @minInsert INT
        DECLARE @maxInsert INT
        
        SET @minInsert = 1
        SET @columnListInsert = ''
        SELECT @maxInsert = MAX(recId) FROM #ColumnInserts 
        
        WHILE @minInsert <= @maxInsert
            BEGIN
                SELECT @columnInsert = name FROM #ColumnInserts WHERE recId = @minInsert
                SET @columnListInsert = @columnListInsert + @columnInsert
                
                IF @minInsert <@maxInsert
                    BEGIN
                        SET @columnListInsert = @columnListInsert+','
                    END
                
                SET @minInsert = @minInsert + 1
            END
        
        --ActionCode = 1 (Inserts)
            DECLARE @sqlInsert VARCHAR(8000)
            SET @sqlInsert = 
            'INSERT INTO Mid.Practice ('+@columnListInsert+')
            SELECT '+@columnListInsert+' FROM #Practice WHERE ActionCode = 1'
            
            EXEC (@sqlInsert)
            
            --select *
            --from Mid.Practice p join #Practice tp on p.PracticeID = tp.PracticeID and p.OfficeID = tp.OfficeID
            --where p.AddressLine1 <> tp.AddressLine1
            
        
        --ActionCode = 2 (Updates)  
            DECLARE @minUpdates INT
            DECLARE @maxUpdates INT
            DECLARE @sqlUpdates VARCHAR(8000)
            DECLARE @sqlUpdatesClause VARCHAR(500)
            DECLARE @columnUpdates VARCHAR(150)
            DECLARE @columnListUpdates VARCHAR(8000)
            DECLARE @newlineUpdates CHAR(1)
            
            SET @newlineUpdates = CHAR(10)
            SET @columnListUpdates = ''
            SET @sqlUpdates = 'UPDATE a'+@newlineUpdates+
                              'SET '    
            SET @sqlUpdatesClause = '--SELECT *'+@newlineUpdates+
                              'FROM Mid.Practice a WITH (NOLOCK)'+@newlineUpdates+
                              'JOIN #Practice b ON (a.PracticeID = b.PracticeID AND a.OfficeID = b.OfficeID)'+@newlineUpdates+
                              'WHERE b.ActionCode = 2'
                              
            SELECT @minUpdates = MIN(recId) FROM #ColumnsUpdates 
            SELECT @maxUpdates = MAX(recId) FROM #ColumnsUpdates
            
            WHILE @minUpdates <= @maxUpdates
                BEGIN
                    SELECT @columnUpdates = name FROM #ColumnsUpdates WHERE recId = @minUpdates
                    SET @columnListUpdates = @columnListUpdates + 'a.'+@columnUpdates+' = b.'+@columnUpdates
                    
                    IF @minUpdates < @maxUpdates
                        BEGIN
                            SET @columnListUpdates = @columnListUpdates+','+@newlineUpdates+''
                        END
                    ELSE
                        BEGIN
                            SET @columnListUpdates = @columnListUpdates+@newlineUpdates+@sqlUpdatesClause
                        END
                    
                    SET @minUpdates = @minUpdates + 1
                END
            
            SET @sqlUpdates = @sqlUpdates + @columnListUpdates
            
            EXEC (@sqlUpdates)

        --ActionCode = N (Deletes)
            DELETE  a
            --SELECT *
            FROM    Mid.Practice a WITH (NOLOCK)
                    inner join #PracticeBatch as pb on pb.PracticeID = a.PracticeID
                    LEFT JOIN #Practice b ON (a.PracticeID = b.PracticeID AND a.OfficeID = b.OfficeID)
            WHERE   b.PracticeID IS NULL
    
    /*
        DELTAS FOR SOLR HERE
    */      
        
        
END TRY
BEGIN CATCH
    SET @ErrorMessage = 'Error in procedure Mid.spuPracticeRefresh, line ' + CONVERT(VARCHAR(20), ERROR_LINE()) + ': ' + ERROR_MESSAGE()
    RAISERROR(@ErrorMessage, 18, 1)
END CATCH
GO

