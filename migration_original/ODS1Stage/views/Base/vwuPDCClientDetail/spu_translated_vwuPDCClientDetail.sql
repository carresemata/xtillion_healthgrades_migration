CREATE OR REPLACE VIEW ODS1_STAGE_TEAM.BASE.VWUPDCCLIENTDETAIL
AS 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.VWUPDCCLIENTDETAIL depends on:
--- Base.ClientProductImage
--- Base.MediaImageType
--- Base.ClientProductEntityToURL
--- Base.URLType
--- Base.URL
--- Base.ClientProductToEntity
--- Base.EntityType
--- Base.ClientToProduct
--- Base.Client
--- BASE.CLIENTPRODUCTENTITYTOPHONE (BASE.VWUCLIENTPRODUCTENTITYTOPHONE)
--- BASE.PHONETYPE (BASE.VWUCLIENTPRODUCTENTITYTOPHONE)
--- BASE.PHONE (BASE.VWUCLIENTPRODUCTENTITYTOPHONE)


WITH CTE_images AS (
    SELECT
        cpi.ClientToProductID,
        CONCAT(
            COALESCE(mit.MediaRelativePath, ''),
            '/',
            cpi.FileName
        ) AS ImageFilePath,
        mit.MediaImageTypeCode
    FROM Base.ClientProductImage cpi
    INNER JOIN Base.MediaImageType mit ON mit.MediaImageTypeID = cpi.MediaImageTypeID
),

CTE_urls AS (
    SELECT
        cpeturl.ClientProductToEntityID,
        TRIM(REPLACE(u.URL, '--', '-')) AS URL,
        ut.URLTypeCode
    FROM Base.ClientProductEntityToURL cpeturl
    INNER JOIN Base.URLType ut ON ut.URLTypeID = cpeturl.URLTypeID
    INNER JOIN Base.URL u ON cpeturl.URLID = u.URLID
),

CTE_phones AS (
    SELECT
        vw.ClientProductToEntityID,
        cpte.ClientToProductID,
        vw.AreaCode,
        vw.PhoneNumber,
        vw.PhoneTypeCode
    FROM Base.vwuClientProductEntityToPhone vw
    INNER JOIN Base.ClientProductToEntity cpte ON vw.ClientProductToEntityID = cpte.ClientProductToEntityID
)

SELECT
    ctp.ClientToProductID,
    cpte.ClientProductToEntityID,
    img.ImageFilePath,
    img.MediaImageTypeCode,
    u.URL,
    u.URLTypeCode,
    ph.PhoneNumber AS DesignatedProviderPhone,
    ph.PhoneTypeCode
FROM Base.Client c
INNER JOIN Base.ClientToProduct ctp ON c.ClientID = ctp.ClientID AND ctp.ActiveFlag = 1
INNER JOIN Base.ClientProductToEntity cpte ON ctp.ClientToProductID = cpte.ClientToProductID
INNER JOIN Base.EntityType et ON cpte.EntityTypeID = et.EntityTypeID AND et.EntityTypeCode = 'CLPROD'
LEFT JOIN CTE_images img ON ctp.ClientToProductID = img.ClientToProductID
LEFT JOIN CTE_urls u ON cpte.ClientProductToEntityID = u.ClientProductToEntityID
LEFT JOIN CTE_phones ph ON cpte.ClientProductToEntityID = ph.ClientProductToEntityID;