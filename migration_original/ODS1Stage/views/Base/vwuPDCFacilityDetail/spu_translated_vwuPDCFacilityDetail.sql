CREATE OR REPLACE VIEW ODS1_STAGE_TEAM.BASE.VWUPDCFACILITYDETAIL as

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- base.vwupdcfacilitydetail depends on:
--- base.facility
--- base.clientproducttoentity
--- base.clienttoproduct
--- base.client
--- base.entitytype
--- base.facilityimage
--- base.mediaimagetype
--- base.clientproductentitytourl
--- base.urltype
--- base.url
--- Base.ClientProductEntityToPhone (base.vwuclientproductentitytophone)
--- Base.PhoneType (base.vwuclientproductentitytophone)
--- Base.Phone (base.vwuclientproductentitytophone)


WITH CTE_Image AS (
    SELECT  FacilityImage.FacilityID,
            FacilityImage.FacilityImageID,
            IFNULL(MediaImageType.MediaRelativePath, '') || CASE WHEN RIGHT(IFNULL(MediaImageType.MediaRelativePath, ''), 1) != '/' THEN '/' ELSE '' END || FacilityImage.FileName AS ImageFilePath,
            MediaImageType.MediaImageTypeCode
    FROM    Base.FacilityImage FacilityImage
            INNER JOIN Base.MediaImageType MediaImageType ON MediaImageType.MediaImageTypeID = FacilityImage.MediaImageTypeID
),
CTE_ClientProduct AS (
    SELECT  ClientProductURL.ClientProductToEntityID,
            URL.URL,
            URLType.URLTypeCode
    FROM    Base.ClientProductEntityToURL ClientProductURL
            JOIN Base.URLType URLType ON URLType.URLTypeID = ClientProductURL.URLTypeID 
            JOIN Base.URL URL ON ClientProductURL.URLID = URL.URLID
),
CTE_ClientEntity AS (
    SELECT  ClientProductPhone.ClientProductToEntityID,
            ClientProductPhone.AreaCode,
            ClientProductPhone.PhoneNumber,
            ClientProductPhone.PhoneTypeCode
    FROM    Base.vwuClientProductEntityToPhone ClientProductPhone
)

SELECT  ClientProduct.ClientToProductID,
        ClientProduct.ClientProductToEntityID,
        Facility.FacilityID,
        Facility.FacilityCode,
        Facility.FacilityName,
        Image.ImageFilePath,
        Image.MediaImageTypeCode,
        ProductURL.URL,
        ProductURL.URLTypeCode,
        ClientPhone.PhoneNumber AS DesignatedProviderPhone,
        ClientPhone.PhoneTypeCode,
        Facility.LegacyKey AS hgid
FROM    Base.Facility Facility
        JOIN Base.ClientProductToEntity ClientProduct ON Facility.FacilityID = ClientProduct.EntityID
        JOIN Base.ClientToProduct ClientProductActive ON ClientProduct.ClientToProductID = ClientProductActive.ClientToProductID AND ClientProductActive.ActiveFlag = 1
        JOIN Base.Client Client ON ClientProductActive.ClientID = Client.ClientID 
        JOIN Base.EntityType EntityType ON ClientProduct.EntityTypeID = EntityType.EntityTypeID AND EntityType.EntityTypeCode = 'FAC'
        LEFT JOIN CTE_Image Image ON Facility.FacilityID = Image.FacilityID
        LEFT JOIN CTE_ClientProduct ProductURL ON ClientProduct.ClientProductToEntityID = ProductURL.ClientProductToEntityID
        LEFT JOIN CTE_ClientEntity ClientPhone ON ClientProduct.ClientProductToEntityID = ClientPhone.ClientProductToEntityID;