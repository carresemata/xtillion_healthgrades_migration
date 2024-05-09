CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTOMAPCUSTOMERPRODUCT() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderToMAPCustomerProduct depends on:
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.ClientToProduct
--- Base.ClientProductToEntity
--- Base.EntityType
--- Base.PhoneType 
--- Base.Phone
--- Base.Office
--- Base.ProviderToOffice
--- Base.OfficeToPhone
--- Base.OfficeToAddress
--- Base.Address
--- Base.CityStatePostalCode
--- Base.ClientProductEntityToPhone
--- Base.Product
--- Base.Client

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the insert
    insert_statement_1 STRING; 
    insert_statement_2 STRING;
    merge_statement_1 STRING; 
    merge_statement_2 STRING;
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    -- no conditionals


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
select_statement := $$ WITH CTE_ProviderCustomerProduct AS (
    SELECT DISTINCT
        P.ProviderId,
        CP.ClientToProductId,
        -- ProviderReltioEntityId
        JSON.ProviderCode,
        SUBSTRING(JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE, 1,  POSITION('-' IN JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE) - 1 ) AS ClientCode,
        SUBSTR(JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE, POSITION('-' IN JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE) + 1, LENGTH(JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE)) AS ProductCode,
        JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE AS ClientToProductCode,
        row_number() over(partition by P.ProviderId, JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE order by CREATE_DATE desc) as RowRank
    FROM RAW.VW_PROVIDER_PROFILE AS JSON
        LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
        INNER JOIN Base.ClientToProduct AS CP ON CP.ClientToProductCode = JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE
    WHERE PROVIDER_PROFILE IS NOT NULL
          AND JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE IS NOT NULL),

CTE_ProviderOfficeCustomerProduct AS (
    SELECT DISTINCT
        P.ProviderId,
        -- ProviderReltioEntityId
        JSON.ProviderCode,
        SUBSTRING(JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE, 1,  POSITION('-' IN JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE) - 1 ) AS ClientCode,
        SUBSTR(JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE, POSITION('-' IN JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE) + 1, LENGTH(JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE)) AS ProductCode,
        JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE AS ClientToProductCode,
        JSON.OFFICE_OFFICECODE AS OfficeCode,
        -- OfficeReltioEntityID
        -- TrackingNumber
        JSON.OFFICE_PHONENUMBER AS DisplayPhoneNumber,
        JSON.OFFICE_OFFICERANK AS ProviderOfficeRank,
        -- DisplayPartnerCode
        -- RingToNumber
        -- RingToNumberType
        row_number() over(partition by ProviderID, OFFICE_OFFICECODE order by CREATE_DATE desc) as RowRank
    FROM RAW.VW_PROVIDER_PROFILE AS JSON
        LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
        INNER JOIN Base.ClientToProduct AS CP ON CP.ClientToProductCode = JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE
    WHERE PROVIDER_PROFILE IS NOT NULL
          AND JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE IS NOT NULL
),
CTE_ClientLevelPhones AS (
    SELECT DISTINCT 
        CPE.ClientProductToEntityID, 
        CP.ClientToProductId, 
        CP.ClientToProductCode, 
        PT.PhoneTypeCode, 
        P.PhoneNumber
    FROM Base.ClientProductEntityToPhone AS CPEP
    	INNER JOIN	Base.ClientProductToEntity AS CPE ON CPE.ClientProductToEntityID = CPEP.ClientProductToEntityID
    	INNER JOIN	Base.EntityType AS ET ON ET.EntityTypeID = CPE.EntityTypeID
    	INNER JOIN	Base.ClientToProduct AS CP ON CP.ClientToProductId = CPE.ClientToProductId
    	INNER JOIN	Base.PhoneType AS PT ON PT.PhoneTypeID = CPEP.PhoneTypeID
    	INNER JOIN	Base.Phone AS P On P.PhoneID = CPEP.PhoneID
    	INNER JOIN	CTE_ProviderCustomerProduct AS cte ON cte.ClientToProductCode = CP.ClientToProductCode
	WHERE ET.EntityTypeCode = 'CLPROD'
),

CTE_Phone1 AS (
    SELECT 
        pocp.ProviderId,
        pocp.DisplayPhoneNumber AS ph, 
        'PTODS' AS phTyp
    FROM CTE_ProviderOfficeCustomerProduct AS pocp 
    UNION ALL
    SELECT 
        pcp.ProviderId,
        CLP.PhoneNumber AS ph, 
        CLP.PhoneTypeCode AS phTyp
    FROM CTE_ClientLevelPhones AS CLP 
    LEFT JOIN CTE_ProviderCustomerProduct AS pcp ON pcp.ClientToProductId = clp.ClientToProductId
    WHERE CLP.ClientToProductCode = pcp.ClientToProductCode
),

CTE_PhoneXML1 AS (
    SELECT
        providerId,
        utils.p_json_to_xml(
            ARRAY_AGG('{ '||
                            IFF(ph IS NOT NULL, '"ph":' || '"' || ph || '"' || ',', '') ||
                            IFF(phTyp IS NOT NULL, '"phTyp":' || '"' || phTyp || '"', '')
                            ||' }')::VARCHAR,
                                    '',
                                    'phone'
                                ) AS phoneXML
    FROM CTE_Phone1
    GROUP BY ProviderId
        
),

CTE_insert_1 AS (
    SELECT 
        pcp.ProviderID, 
        o.OfficeID, 
        cp.ClientToProductID, 
        TO_VARIANT(XML.PhoneXML) AS PhoneXML,
        -- RingToNumberType,
        -- DisplayPartnerCode,
        -- InsertedBy,
        pocp.DisplayPhoneNumber, 
        -- RingToNumber,
        -- TrackingNumber
    FROM CTE_ProviderCustomerProduct AS pcp 
        INNER JOIN CTE_ProviderOfficeCustomerProduct AS pocp ON pocp.ProviderID = pcp.ProviderID AND pocp.ClientToProductCode = pcp.ClientToProductCode 
        INNER JOIN Base.Office AS o ON o.OfficeCode = pocp.OfficeCode
        INNER JOIN Base.ClientToProduct AS cp ON cp.ClientToProductCode = pcp.ClientToProductCode
        INNER JOIN CTE_PhoneXML1 AS XML ON XML.ProviderId = pocp.ProviderId
    WHERE 
        pcp.RowRank = 1 
        AND pocp.RowRank = 1
        AND pcp.ProductCode = 'MAP'
        AND LENGTH(XML.PhoneXML) >= LENGTH('<phone><phTyp>PTODS</phTyp></phone>')
),
CTE_Phone2 AS (
    SELECT 
        OPH.OfficeId,
        PH.PhoneNumber as ph, 
        'PTODS' as phTyp
    FROM Base.Phone AS PH
        LEFT JOIN Base.OfficeToPhone AS OPH ON PH.PhoneId = OPH.PhoneId
),

CTE_PhoneXML2 AS (
        SELECT
        OfficeId,
        utils.p_json_to_xml(
            ARRAY_AGG('{ '||
                            IFF(ph IS NOT NULL, '"ph":' || '"' || ph || '"' || ',', '') ||
                            IFF(phTyp IS NOT NULL, '"phTyp":' || '"' || phTyp || '"', '')
                            ||' }')::VARCHAR,
                                    '',
                                    'phone'
                                ) AS phoneXML
    FROM CTE_Phone2
    GROUP BY OfficeId
),

CTE_Insert_2 AS (
    SELECT 
        P.ProviderId, 
        O.OfficeID, 
        lCP.ClientToProductID,
		TO_VARIANT(XML.PhoneXML) AS PhoneXML,
		'HG' AS DisplayPartnerCode
	    FROM	Base.Provider P
    	    INNER JOIN	Base.ProviderToOffice PO on PO.ProviderId = P.ProviderID
    	    INNER JOIN	Base.OfficeToPhone OPH ON OPH.OfficeID = PO.OfficeID 
    	    INNER JOIN	Base.Phone PH ON PH.PhoneId = OPH.PhoneID
    	    INNER JOIN  Base.PhoneType PT ON PT.PhoneTypeId = OPH.PhoneTypeId AND PT.PhoneTypeCode = 'SERVICE'
    	    INNER JOIN	Base.Office O ON O.OfficeId = PO.OfficeID
    	    INNER JOIN	Base.OfficeToAddress OA on OA.OfficeId = O.OfficeId
    	    INNER JOIN	Base.Address A on A.AddressId = OA.AddressId
    	    INNER JOIN	Base.CityStatePostalCode CSPC on CSPC.CityStatePostalCodeID = A.CityStatePostalCodeID
    	    INNER JOIN	Base.ClientProductToEntity lCPE ON lCPE.EntityId = P.ProviderId
    	    INNER JOIN	Base.EntityType dE ON dE.EntityTypeId = lCPE.EntityTypeID
    	    INNER JOIN	Base.ClientToProduct lCP ON lCP.ClientToProductID = lCPE.ClientToProductID
    	    INNER JOIN	Base.Client dC ON lCP.ClientID = dC.ClientID
    	    INNER JOIN	Base.Product dP ON dP.ProductId = lCP.ProductID
            INNER JOIN CTE_PhoneXML2 AS XML ON XML.OfficeId = P.ProviderId
	    WHERE		dP.ProductCode = 'MAP'
                    AND LENGTH(XML.PhoneXML) >= LENGTH('<phone><phTyp>PTODS</phTyp></phone>')
) $$;


insert_statement_1 := 'INSERT (ProviderToMapCustomerProductId,
                            ProviderID, 
                            OfficeID, 
                            ClientToProductID, 
                            PhoneXML, 
                            DisplayPhoneNumber)
                    VALUES (UUID_STRING(),
                            source.ProviderID, 
                            source.OfficeID, 
                            source.ClientToProductID, 
                            source.PhoneXML, 
                            source.DisplayPhoneNumber)';
                
insert_statement_2 := 'INSERT (ProviderToMapCustomerProductId,
                            ProviderID, 
                            OfficeID, 
                            ClientToProductID, 
                            PhoneXML, 
                            DisplayPartnerCode)
                    VALUES (UUID_STRING(),
                            source.ProviderID, 
                            source.OfficeID, 
                            source.ClientToProductID, 
                            source.PhoneXML, 
                            source.DisplayPartnerCode)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement_1 := ' MERGE INTO Base.ProviderToMapCustomerProduct as target USING 
                   ('||select_statement ||' SELECT * FROM CTE_insert_1) as source 
                   ON target.ProviderId = source.ProviderId AND target.OfficeId = source.OfficeId
                   WHEN NOT MATCHED THEN ' || insert_statement_1;

                    
merge_statement_2 := ' MERGE INTO Base.ProviderToMapCustomerProduct as target USING 
                   ('||select_statement || ' SELECT * FROM CTE_insert_2) as source 
                   ON target.ProviderId = source.ProviderId AND target.OfficeId = source.OfficeId
                   WHEN NOT MATCHED THEN ' || insert_statement_2;
                    
 
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE merge_statement_1 ;
EXECUTE IMMEDIATE merge_statement_2 ;

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
--------------------------------------------------------- 

status := 'Completed successfully';
    RETURN status;


        
EXCEPTION
    WHEN OTHER THEN
          status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '.f SQL State: ' || SQLSTATE;
          RETURN status;


    
END;