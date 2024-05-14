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

---------------------------------------------------------
--------------------- 1. Columns ------------------------
---------------------------------------------------------

-- ClientToProductID
-- ClientProductToEntityID
-- FacilityID
-- FacilityCode
-- FacilityName
-- ImageFilePath
-- MediaImageTypeCode
-- URL
-- URLTypeCode
-- DesignatedProviderPhone
-- PhoneTypeCode
-- hgid


SELECT  b.ClientToProductID,
        b.ClientProductToEntityID,
        a.FacilityID,
        a.FacilityCode,
        a.FacilityName,
        img.ImageFilePath,
        img.MediaImageTypeCode,
        u.URL,
        u.URLTypeCode,
        ph.PhoneNumber AS DesignatedProviderPhone,
        ph.PhoneTypeCode,
        a.LegacyKey AS hgid
FROM    Base.Facility a
        JOIN Base.ClientProductToEntity b ON a.FacilityID = b.EntityID
        JOIN Base.ClientToProduct m ON b.ClientToProductID = m.ClientToProductID AND m.ActiveFlag = 1
        JOIN Base.Client n ON m.ClientID = n.ClientID 
        JOIN Base.EntityType c ON b.EntityTypeID = c.EntityTypeID AND c.EntityTypeCode = 'FAC'
        LEFT JOIN (
            SELECT  d.FacilityID,
                    d.FacilityImageID,
                    IFNULL(e.MediaRelativePath, '') || CASE WHEN RIGHT(IFNULL(e.MediaRelativePath, ''), 1) != '/' THEN '/' ELSE '' END || d.FileName AS ImageFilePath,
                    e.MediaImageTypeCode
            FROM    Base.FacilityImage d
                    INNER JOIN Base.MediaImageType e ON e.MediaImageTypeID = d.MediaImageTypeID
        ) img ON a.FacilityID = img.FacilityID
        LEFT JOIN (
            SELECT  g.ClientProductToEntityID,
                    i.URL,
                    h.URLTypeCode
            FROM    Base.ClientProductEntityToURL g
                    JOIN Base.URLType h ON h.URLTypeID = g.URLTypeID 
                    JOIN Base.URL i ON g.URLID = i.URLID
        ) u ON b.ClientProductToEntityID = u.ClientProductToEntityID
        LEFT JOIN (
            SELECT  j.ClientProductToEntityID,
                    j.AreaCode,
                    j.PhoneNumber,
                    j.PhoneTypeCode
            FROM    Base.vwuClientProductEntityToPhone j
        ) ph ON b.ClientProductToEntityID = ph.ClientProductToEntityID;