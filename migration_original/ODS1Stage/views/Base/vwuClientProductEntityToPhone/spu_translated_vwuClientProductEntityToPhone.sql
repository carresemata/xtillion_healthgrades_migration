CREATE OR REPLACE VIEW ODS1_STAGE_TEAM.BASE.VWUCLIENTPRODUCTENTITYTOPHONE AS

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.VwuClientProductEntityToPhone depends on:
--- Base.ClientProductEntityToPhone
--- Base.PhoneType
--- Base.Phone

---------------------------------------------------------
--------------------- 1. Columns ------------------------
---------------------------------------------------------
-- ClientProductToEntityID
-- AreaCode
-- PhoneNumber
-- PhoneID
-- PhoneTypeID
-- PhoneTypeCode

SELECT	cpetp.ClientProductToEntityID, 
        p.AreaCode, 
        p.PhoneNumber, 
        cpetp.PhoneID,
        cpetp.PhoneTypeID,
        CASE 
            WHEN pt.PhoneTypeCode = 'PTPRSRDM' THEN 'PTPRSRDDTP'
            WHEN pt.PhoneTypeCode = 'PTPRSRM'	THEN 'PTPRSRDTP'
            WHEN pt.PhoneTypeCode = 'PTPMTM'	THEN 'PTPMTDTP'
            WHEN pt.PhoneTypeCode = 'PTPDSM'	THEN 'PTPDSDTP'
            WHEN pt.PhoneTypeCode = 'PTPMCM'	THEN 'PTPMCDTP'
            WHEN pt.PhoneTypeCode = 'PTODSM'	THEN 'PTODSDTP'
            WHEN pt.PhoneTypeCode = 'PTOMCM'	THEN 'PTOMCDTP'
            WHEN pt.PhoneTypeCode = 'PTOMTM'	THEN 'PTOMTDTP'
            WHEN pt.PhoneTypeCode = 'PTOOSM'	THEN 'PTOOSDTP'
            WHEN pt.PhoneTypeCode = 'PTOSRDM'	THEN 'PTOSRDDTP'
            WHEN pt.PhoneTypeCode = 'PTOSRM'	THEN 'PTOSRDTP'
            WHEN pt.PhoneTypeCode = 'PTPSRDM'	THEN 'PTPSRDDTP'
            WHEN pt.PhoneTypeCode = 'PTFSRDM'	THEN 'PTFSRDDTP'
            WHEN pt.PhoneTypeCode = 'PTMWCM'	THEN 'PTMWCDTP'
            WHEN pt.PhoneTypeCode = 'PTFMCM'	THEN 'PTFMCDTP'
            WHEN pt.PhoneTypeCode = 'PTDESM'	THEN 'PTDESDTP'
            WHEN pt.PhoneTypeCode = 'PTEMPM'	THEN 'PTEMPDTP'
            WHEN pt.PhoneTypeCode = 'PTFDSM'	THEN 'PTFDSDTP'
            WHEN pt.PhoneTypeCode = 'PTFMTM'	THEN 'PTFMTDTP'
            WHEN pt.PhoneTypeCode = 'PTFSRM'	THEN 'PTFSRDTP'
            WHEN pt.PhoneTypeCode = 'PTHFSM'	THEN 'PTHFSDTP'
            WHEN pt.PhoneTypeCode = 'PTHOSM'	THEN 'PTHOSDTP'
            WHEN pt.PhoneTypeCode = 'PTMTRM'	THEN 'PTMTRDTP'
            WHEN pt.PhoneTypeCode = 'PTPSRM'	THEN 'PTPSRDTP'
            ELSE pt.PhoneTypeCode
        END AS PhoneTypeCode
FROM Base.ClientProductEntityToPhone cpetp 
INNER JOIN Base.PhoneType pt ON cpetp.PhoneTypeID = pt.PhoneTypeID 
INNER JOIN Base.Phone p ON cpetp.PhoneID = p.PhoneID;