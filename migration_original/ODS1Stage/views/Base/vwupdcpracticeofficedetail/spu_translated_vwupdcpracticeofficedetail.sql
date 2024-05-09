create or replace view ODS1_STAGE.BASE.VWUPDCPRACTICEOFFICEDETAIL(
	CLIENTTOPRODUCTID,
	CLIENTCODE,
	CLIENTPRODUCTTOENTITYID,
	OFFICEID,
	OFFICECODE,
	OFFICENAME,
	PRACTICEID,
	PRACTICECODE,
	PRACTICENAME,
	IMAGEFILEPATH,
	IMAGETYPECODE,
	URL,
	URLTYPECODE,
	DESIGNATEDPROVIDERPHONE,
	PHONETYPECODE,
	HGID
) as


---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.vwuPdcPracticeOfficeDetail depends on:
--- Base.Office
--- Base.Practice
--- Base.ClientProductToEntity
--- Base.ClientToProduct
--- Base.Client
--- Base.EntityType
--- Base.ClientProductEntityToImage
--- Base.ImageType
--- Base.Image
--- Base.OfficeToAddress
--- Base.Address
--- Base.CityStatePostalCode
--- Base.State
--- BASE.CLIENTPRODUCTENTITYTOPHONE (BASE.VWUCLIENTPRODUCTENTITYTOPHONE)
--- BASE.PHONETYPE (BASE.VWUCLIENTPRODUCTENTITYTOPHONE)
--- BASE.PHONE (BASE.VWUCLIENTPRODUCTENTITYTOPHONE)

---------------------------------------------------------
--------------------- 1. Columns ------------------------
---------------------------------------------------------

-- ClientToProductID
-- ClientCode
-- ClientProductToEntityID
-- OfficeID
-- OfficeCode
-- OfficeName
-- PracticeID
-- PracticeCode
-- PracticeName
-- ImageFilePath
-- ImageTypeCode
-- URL
-- URLTypeCode
-- DesignatedProviderPhone
-- PhoneTypeCode
-- hgid


SELECT
  b.ClientToProductID,
  n.ClientCode,
  b.ClientProductToEntityID,
  a.OfficeID,
  a.OfficeCode,
  a.OfficeName,
  b1.PracticeID,
  b1.PracticeCode,
  b1.PracticeName,
  img.ImageFilePath,
  img.ImageTypeCode,
  u.URL,
  u.URLTypeCode,
  ph.PhoneNumber AS DesignatedProviderPhone,
  ph.PhoneTypeCode,
  a.LegacyKey AS hgid
FROM
  Base.Office AS a
  LEFT JOIN Base.Practice AS b1 ON a.PracticeID = b1.PracticeID
  JOIN Base.ClientProductToEntity b ON a.OfficeID = b.EntityID
  JOIN Base.ClientToProduct m ON b.ClientToProductID = m.ClientToProductID
  AND m.ActiveFlag = 1
  JOIN Base.Client n ON m.ClientID = n.ClientID
  JOIN Base.EntityType c ON b.EntityTypeID = c.EntityTypeID
  AND c.EntityTypeCode = 'OFFICE'
  LEFT JOIN (
    SELECT
      d.ClientProductToEntityID,
      f.ImageFilePath,
      e.ImageTypeCode
    FROM Base.ClientProductEntityToImage d
      JOIN Base.ImageType e ON e.ImageTypeID = d.ImageTypeID
      JOIN Base.Image f ON d.ImageID = f.ImageID
  ) img ON b.ClientProductToEntityID = img.ClientProductToEntityID
  LEFT JOIN (
    SELECT
      k.OfficeID,
      k.PracticeID,
      REPLACE(
        '/group-directory/' || LOWER(REPLACE(p.StateName, ' ', '-')) || '-' || LOWER(o.State) || '/' || LOWER(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(
                  REPLACE(
                    REPLACE(REPLACE(o.City, ' - ', ' '), '&', '-'),
                    ' ',
                    '-'
                  ),
                  '/',
                  '-'
                ),
                '''',
                ''
              ),
              '.',
              ''
            ),
            '--',
            '-'
          )
        ) || '/' || LOWER(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(
                  REPLACE(
                    REPLACE(
                      REPLACE(
                        REPLACE(
                          REPLACE(
                            REPLACE(
                              REPLACE(
                                REPLACE(
                                  REPLACE(
                                    REPLACE(
                                      REPLACE(
                                        REPLACE(
                                          REPLACE(
                                            REPLACE(
                                              REPLACE(
                                                REPLACE(
                                                  REPLACE(
                                                    REPLACE(
                                                      REPLACE(
                                                        REPLACE(
                                                          REPLACE(
                                                            REPLACE(
                                                              REPLACE(
                                                                REPLACE(
                                                                  REPLACE(
                                                                    REPLACE(
                                                                      REPLACE(
                                                                        REPLACE(
                                                                          REPLACE(
                                                                            REPLACE(
                                                                              REPLACE(
                                                                                REPLACE(
                                                                                  REPLACE(
                                                                                    REPLACE(
                                                                                      REPLACE(LTRIM(RTRIM(l.PracticeName)), ' - ', ' '),
                                                                                      '&',
                                                                                      '-'
                                                                                    ),
                                                                                    ' ',
                                                                                    '-'
                                                                                  ),
                                                                                  '/',
                                                                                  '-'
                                                                                ),
                                                                                '\\', ' - '), '''', ''), ' :', ''), ' ~ ', ''), ';
', ''), ' | ', ''), ' < ', ''), ' > ', ''), ' ™ ', ''), ' • ', ''), ' * ', ''), ' ? ', ''), ' + ', ''), ' ® ', ''), ' ! ', ''), ' – ', ''), ' @', ''), ' { ', ''), ' } ', ''), ' [', ''), '] ', ''), '(', ''), ') ', ''), ' ñ ', ' n '), ' é ', ' e '), ' í ', ' i '), ' "', ''), '’', ''), ' ', ''), '`', ''), ',', ''), '#', ''), '.', ''), '---', '-'), '--', '-')) || '-' || LOWER(IFNULL(SUBSTRING(k.LegacyKey, 5, 8), k.OfficeCode)), '--', '-') AS URL, 'FCOURL' AS URLTypeCode FROM 
    Base.Office k  
    JOIN Base.Practice l ON k.PracticeID = l.PracticeID  
    JOIN Base.OfficeToAddress AS m ON k.OfficeID = m.OfficeID  
    JOIN Base.Address AS n ON n.AddressID = m.AddressID  
    JOIN Base.CityStatePostalCode o ON o.CityStatePostalCodeID = n.CityStatePostalCodeID  JOIN Base.State p ON p.state = o.state) u ON a.OfficeID = u.OfficeID AND a.PracticeID = u.PracticeID  
    LEFT JOIN (SELECT j.ClientProductToEntityID, j.AreaCode, j.PhoneNumber, j.PhoneTypeCode FROM 
Base.vwuClientProductEntityToPhone j) ph ON b.ClientProductToEntityID = ph.ClientProductToEntityID;