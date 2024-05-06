CREATE OR REPLACE PROCEDURE ODS1_STAGE.Show.SP_LOAD_TABLE_SOLRMarket() -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  

DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Show.SOLRMarket depends on:
--- Mid.ClientMarket
--- Base.ClientEntityToClientFeature
--- Base.EntityType
--- Base.ClientFeatureToClientFeatureValue
--- Base.ClientFeature
--- Base.ClientFeatureValue
--- Base.ClientFeatureGroup
--- Base.vwuCallCenterDetails
--- Base.Market

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
-- If no conditionals:
select_statement := '
WITH cte_mid AS (
    SELECT * FROM mid.clientmarket 
    -- Limit is added to facilitate batch processing
    -- LIMIT 100
),

CTE_spnFeat AS (
    SELECT
        ETF.EntityID AS EntityID,
        ClientFeatureCode AS featCd,
        CF.ClientFeatureDescription AS featDesc,
        CFV.ClientFeatureValueCode AS featValCd,
        CFV.ClientFeatureValueDescription AS featValDesc
    FROM
        Base.ClientEntityToClientFeature AS ETF
        JOIN Base.EntityType AS ET ON ETF.EntityTypeID = ET.EntityTypeID
        JOIN Base.ClientFeatureToClientFeatureValue AS FTFV ON ETF.ClientFeatureToClientFeatureValueID = FTFV.ClientFeatureToClientFeatureValueID
        JOIN Base.ClientFeature AS CF ON FTFV.ClientFeatureID = CF.ClientFeatureID
        JOIN Base.ClientFeatureValue AS CFV ON CFV.ClientFeatureValueID = FTFV.ClientFeatureValueID
        JOIN Base.ClientFeatureGroup AS CFG ON CF.ClientFeatureGroupID = CFG.ClientFeatureGroupID
    WHERE
        ET.EntityTypeCode = ''CLPROD''
    ORDER BY
        ClientFeatureCode,
        ClientFeatureValueCode
        LIMIT 1000
),
CTE_callCtrFeat AS (
    SELECT
        ETF.EntityId,
        ClientFeatureCode AS featCd,
        CF.ClientFeatureDescription AS featDesc,
        CFV.ClientFeatureValueCode AS featValCd,
        CFV.ClientFeatureValueDescription AS featValDesc
    FROM
        Base.ClientEntityToClientFeature ETF
        JOIN Base.EntityType ET ON ETF.EntityTypeID = ET.EntityTypeID
        JOIN Base.ClientFeatureToClientFeatureValue TCFV ON ETF.ClientFeatureToClientFeatureValueID = TCFV.ClientFeatureToClientFeatureValueID
        JOIN Base.ClientFeature CF ON TCFV.ClientFeatureID = CF.ClientFeatureID
        JOIN Base.ClientFeatureValue CFV ON CFV.ClientFeatureValueID = TCFV.ClientFeatureValueID
        JOIN Base.ClientFeatureGroup CFG ON CF.ClientFeatureGroupID = CFG.ClientFeatureGroupID
    WHERE
        CFG.ClientFeatureGroupCode = ''FGOAR''
        AND ET.EntityTypeCode = ''CLCTR'' 
    ORDER BY
        ClientFeatureCode,
        ClientFeatureValueCode
),
CTE_clCtr AS (
    SELECT
        CCD.ClientToProductID,
        CallCenterCode AS clCtrCd,
        CallCenterName AS clCtrNm,
        ReplyDays AS aptCoffDay,
        ApptCutOffTime AS aptCoffHr,
        EmailAddress AS eml,
        FaxNumber AS fxNo,
        utils.p_json_to_xml(
            ARRAY_AGG(
                ''{ '' || 
                ''"featCd":'' || CTE_CCF.featCd || '','' || 
                ''"featDesc":'' || CTE_CCF.featDesc || '','' || 
                ''"featValCd":'' || CTE_CCF.featValCd || '','' || 
                ''"featValDesc":'' || CTE_CCF.featValDesc || 
                '' }''
            )::VARCHAR,
            ''clCtrFeatL'',
            ''clCtrFeat''
        ) AS clCtrFeatL
    FROM
        Base.vwuCallCenterDetails AS CCD 
        left JOIN CTE_callCtrFeat AS CTE_CCF ON CCD.callcenterid = CTE_CCF.EntityID
    GROUP BY
        CallCenterCode,
        CallCenterName,
        ReplyDays,
        ApptCutOffTime,
        EmailAddress,
        FaxNumber,
        CallCenterID,
        ClientToProductID,
        CTE_CCF.featCd
        Order by clCtrCd
),
CTE_dispL AS (
    SELECT
        CM.MarketID,
        CM.ClientToProductID,
        CM.FacilityCode AS facCd,
        CM.FacilityName AS facNm,
        CM.PhoneMtrXML AS phoneMtrL,
        CM.PhonePsrXML AS phonePsrL,
        CM.MobilePhoneMtrXML AS mobilePhoneMtrL,
        CM.MobilePhonePsrXML AS mobilePhonePsrL,
        CM.URLXML AS urlL,
        CM.ImageXML AS imageL,
        CM.QuaMsgMtrXML AS quaMsgMtrL,
        CM.QuaMsgPsrXML AS quaMsgPsrL,
        CM.TabletPhoneMtrXML as tabletPhoneMtrL,
        CM.TabletPhonePsrXML as tabletPhonePsrL,
        CM.DesktopPhoneMtrXML as desktopPhoneMtrL,
        CM.DesktopPhonePsrXML as desktopPhonePsrL
    FROM
        CTE_MID AS CM
    WHERE(
            CM.FacilityCode IS NOT NULL
            OR CM.PhoneMtrXML IS NOT NULL
            OR CM.PhonePsrXML IS NOT NULL
            OR CM.URLXML IS NOT NULL
            OR CM.ImageXML IS NOT NULL
            OR CM.QuaMsgMtrXML IS NOT NULL
            OR CM.QuaMsgPsrXML IS NOT null
            OR CM.TabletPhoneMtrXML is not null
            OR CM.TabletPhonePsrXML is not null
            OR CM.DesktopPhoneMtrXML is NOT NULL
            OR CM.DesktopPhonePsrXML is NOT NULL
        )  

    ORDER BY
        FacilityCode 
),
CTE_spnL AS (
    SELECT
        CM.MarketId,
        CM.ClientCode AS spnCd,
        CM.ClientName AS spnNm,
        CM.SearchResultsMarketShareValue AS mktShr,
        CM.SearchResultsMarketShareValue AS psrMktShr,
        CM.CompetingProviderMarketShareValue AS provMktShr,
        CM.CallToActionMtrMsg AS caToActMsgMtr,
        CM.CallToActionPsrMsg AS caToActMsgPsr,
        CM.SafeHarborMsg AS safHarMsg,
        utils.p_json_to_xml(
            ARRAY_AGG(
                ''{ ''||
                IFF(CTE_SF.featCd IS NOT NULL, ''"featCd":'' || ''"'' || CTE_SF.featCd || ''"'' || '','', '''') ||
                IFF(CTE_SF.featDesc IS NOT NULL, ''"featDesc":'' || ''"'' || CTE_SF.featDesc || ''"'' || '','', '''') ||
                IFF(CTE_SF.featValCd IS NOT NULL, ''"featValCd":'' || ''"'' || CTE_SF.featValCd || ''"'' || '','', '''') ||
                IFF(CTE_SF.featValDesc IS NOT NULL, ''"featValDesc":'' || ''"'' || CTE_SF.featValDesc || ''"'', '''')
                ||'' }''
            )::VARCHAR,
            ''spnFeatL'',
            ''spnFeat''
        ) as spnFeatL,
        utils.p_json_to_xml(
            ARRAY_AGG(
                ''{ ''||
                IFF(CTE_clCtr.clCtrCd IS NOT NULL, ''"clCtrCd":'' || ''"'' || CTE_clCtr.clCtrCd || ''"'' || '','', '''') ||
                IFF(CTE_clCtr.clCtrNm IS NOT NULL, ''"clCtrNm":'' || ''"'' || CTE_clCtr.clCtrNm || ''"'' || '','', '''') ||
                IFF(CTE_clCtr.aptCoffDay IS NOT NULL, ''"aptCoffDay":'' || ''"'' || CTE_clCtr.aptCoffDay || ''"'' || '','', '''') ||
                IFF(CTE_clCtr.aptCoffHr IS NOT NULL, ''"aptCoffHr":'' || ''"'' || CTE_clCtr.aptCoffHr || ''"'' || '','', '''') ||
                IFF(CTE_clCtr.eml IS NOT NULL, ''"eml":'' || ''"'' || CTE_clCtr.eml || ''"'' || '','', '''') ||
                IFF(CTE_clCtr.fxNo IS NOT NULL, ''"fxNo":'' || ''"'' || CTE_clCtr.fxNo || ''"'' || '','', '''') ||
                IFF(CTE_clCtr.clCtrFeatL IS NOT NULL, ''"clCtrFeatL":'' || ''"'' || CTE_clCtr.clCtrFeatL || ''"'', '''')
                ||'' }''
            )::VARCHAR,
            ''clCtrL'',
            ''clCtr''
        ) as clCtrL,
        utils.p_json_to_xml(
            ARRAY_AGG(
                ''{ ''||
                IFF(CTE_dispL.facCd IS NOT NULL, ''"facCd":'' || ''"'' || CTE_dispL.facCd || ''"'' || '','', '''') ||
                IFF(CTE_dispL.facNm IS NOT NULL, ''"facNm":'' || ''"'' || CTE_dispL.facNm || ''"'' || '','', '''') ||
                IFF(CTE_dispL.phoneMtrL IS NOT NULL, ''"phoneMtrL":'' || ''"'' || CTE_dispL.phoneMtrL || ''"'' || '','', '''') ||
                IFF(CTE_dispL.phonePsrL IS NOT NULL, ''"phonePsrL":'' || ''"'' || CTE_dispL.phonePsrL || ''"'' || '','', '''') ||
                IFF(CTE_dispL.mobilePhoneMtrL IS NOT NULL, ''"mobilePhoneMtrL":'' || ''"'' || CTE_dispL.mobilePhoneMtrL || ''"'' || '','', '''') ||
                IFF(CTE_dispL.mobilePhonePsrL IS NOT NULL, ''"mobilePhonePsrL":'' || ''"'' || CTE_dispL.mobilePhonePsrL || ''"'' || '','', '''') ||
                IFF(CTE_dispL.urlL IS NOT NULL, ''"urlL":'' || ''"'' || CTE_dispL.urlL || ''"'' || '','', '''') ||
                IFF(CTE_dispL.imageL IS NOT NULL, ''"imageL":'' || ''"'' || CTE_dispL.imageL || ''"'' || '','', '''') ||
                IFF(CTE_dispL.quaMsgMtrL IS NOT NULL, ''"quaMsgMtrL":'' || ''"'' || CTE_dispL.quaMsgMtrL || ''"'' || '','', '''') ||
                IFF(CTE_dispL.quaMsgPsrL IS NOT NULL, ''"quaMsgPsrL":'' || ''"'' || CTE_dispL.quaMsgPsrL || ''"'' || '','', '''') ||
                IFF(CTE_dispL.tabletPhoneMtrL IS NOT NULL, ''"tabletPhoneMtrL":'' || ''"'' || CTE_dispL.tabletPhoneMtrL || ''"'' || '','', '''') ||
                IFF(CTE_dispL.tabletPhonePsrL IS NOT NULL, ''"tabletPhonePsrL":'' || ''"'' || CTE_dispL.tabletPhonePsrL || ''"'' || '','', '''') ||
                IFF(CTE_dispL.desktopPhoneMtrL IS NOT NULL, ''"desktopPhoneMtrL":'' || ''"'' || CTE_dispL.desktopPhoneMtrL || ''"'' || '','', '''') ||
                IFF(CTE_dispL.desktopPhonePsrL IS NOT NULL, ''"desktopPhonePsrL":'' || ''"'' || CTE_dispL.desktopPhonePsrL || ''"'', '''')
                ||'' }''
            )::VARCHAR,
            ''dispL'',
            ''disp''
        ) as dispL
    FROM
        CTE_MID AS CM
        LEFT JOIN CTE_spnFeat AS CTE_SF ON CTE_SF.EntityID = CM.ClientToProductID
        LEFT JOIN CTE_clCtr ON CTE_clCtr.ClientToProductID = CM.ClientToProductID
        JOIN CTE_dispL ON 
            CTE_dispL.MarketID = CM.MarketID AND 
            CTE_dispL.ClientToProductID = CM.ClientToProductID
    WHERE
        CM.FacilityCode IS NOT NULL 
    GROUP BY
        CM.ClientCode,
        CM.ClientName,
        CM.SearchResultsMarketShareValue,
        CM.CompetingProviderMarketShareValue,
        CM.MarketID,
        CM.CallToActionMtrMsg,
        CM.CallToActionPsrMsg,
        CM.SafeHarborMsg,
        CM.ClientToProductID
),
CTE_sponsorL AS (
        SELECT
            CM.MarketId,
            CM.ProductCode AS prCd,
            CM.ProductGroupCode AS prGrCd,
            CASE
                WHEN CM.ProductCode = ''MAP''
                AND (
                    PhoneMtrXML IS NOT NULL
                    OR PhonePsrXML IS NOT NULL
                ) THEN 1
                ELSE 0
            END AS compositePhone,
            utils.p_json_to_xml(
                ARRAY_AGG(
                    ''{ ''||
                    IFF(CTE_spnL.spnCd IS NOT NULL, ''"spnCd":'' || ''"'' || CTE_spnL.spnCd || ''"'' || '','', '''') ||
                    IFF(CTE_spnL.spnNm IS NOT NULL, ''"spnNm":'' || ''"'' || CTE_spnL.spnNm || ''"'' || '','', '''') ||
                    IFF(CTE_spnL.mktShr IS NOT NULL, ''"mktShr":'' || ''"'' || CTE_spnL.mktShr || ''"'' || '','', '''') ||
                    IFF(CTE_spnL.psrMktShr IS NOT NULL, ''"psrMktShr":'' || ''"'' || CTE_spnL.psrMktShr || ''"'' || '','', '''') ||
                    IFF(CTE_spnL.provMktShr IS NOT NULL, ''"provMktShr":'' || ''"'' || CTE_spnL.provMktShr || ''"'' || '','', '''') ||
                    IFF(CTE_spnL.caToActMsgMtr IS NOT NULL, ''"caToActMsgMtr":'' || ''"'' || CTE_spnL.caToActMsgMtr || ''"'' || '','', '''') ||
                    IFF(CTE_spnL.caToActMsgPsr IS NOT NULL, ''"caToActMsgPsr":'' || ''"'' || CTE_spnL.caToActMsgPsr || ''"'' || '','', '''') ||
                    IFF(CTE_spnL.safHarMsg IS NOT NULL, ''"safHarMsg":'' || ''"'' || CTE_spnL.safHarMsg || ''"'' || '','', '''') ||
                    IFF(CTE_spnL.spnFeatL IS NOT NULL, ''"xml_1":'' || ''"'' || CTE_spnL.spnFeatL || ''"'' || '','', '''') ||
                    IFF(CTE_spnL.clCtrL IS NOT NULL, ''"xml_2":'' || ''"'' || CTE_spnL.clCtrL || ''"'' || '','', '''') ||
                    IFF(CTE_spnL.dispL IS NOT NULL, ''"xml_3":'' || ''"'' || CTE_spnL.dispL || ''"'', '''')
                    ||'' }''
                )::VARCHAR,
                ''spn'',
                ''spnL''
            ) AS spnL
        FROM
            CTE_MID AS CM
            JOIN CTE_spnL AS CTE_spnL ON CTE_spnL.MarketID = CM.MarketID 
        GROUP BY
            CM.ProductCode,
            CM.ProductGroupCode,
            CM.ProductDescription,
            CM.MarketID,
            CM.ClientToProductID,
            CASE
                WHEN CM.ProductCode = ''MAP''
                AND (
                    PhoneMtrXML is not null
                    or PhonePsrXML is not null
                ) then 1
                else 0
            end 
    ),
    CTE_my AS (
        SELECT
            CM.MarketID,
            CM.MarketCode,
            CM.GeographicAreaCode,
            CM.GeographicAreaValue,
            CM.GeographicAreaTypeCode,
            CM.GeographicAreaTypeDescription,
            CM.LineOfServiceCode,
            CM.LegacyKey,
            CM.LineOfServiceDescription,
            CM.LineOfServiceTypeCode,
            CM.LineOfServiceTypeDescription,
            GETDATE() AS UpdatedDate,
            CURRENT_USER() AS UpdatedSource,
            utils.p_json_to_xml(
                ARRAY_AGG(
                    ''{ ''||
                    IFF(prCd IS NOT NULL, ''"prCd":'' || ''"'' || prCd || ''"'' || '','', '''') ||
                    IFF(prGrCd IS NOT NULL, ''"prGrCd":'' || ''"'' || prGrCd || ''"'' || '','', '''') ||
                    IFF(compositePhone IS NOT NULL, ''"compositePhone":'' || ''"'' || compositePhone || ''"'' || '','', '''') ||
                    IFF(spnL IS NOT NULL, ''"xml_1":'' || ''"'' || spnL || ''"'', '''')
                    ||'' }''
                )::VARCHAR,
                ''sponsorL'',
                ''sponsor''
            ) as SponsorshipXML
        FROM
            CTE_MID AS CM
            JOIN BASE.MARKET AS BM ON BM.MARKETID = CM.MARKETID
            LEFT JOIN CTE_sponsorL AS CTE_SL ON CM.MarketId = CTE_SL.MarketId
        WHERE
            CM.ClientCode NOT IN (
                select
                    DISTINCT ClientCode
                from
                    Show.DelayClient dc
                where
                    GoLiveDate > CAST(GETDATE() AS DATE)
            )
        GROUP BY
            CM.MarketID,
            CM.MarketCode,
            CM.GeographicAreaCode,
            CM.GeographicAreaValue,
            CM.GeographicAreaTypeCode,
            CM.GeographicAreaTypeDescription,
            CM.LineOfServiceCode,
            CM.LegacyKey,
            CM.LineOfServiceDescription,
            CM.LineOfServiceTypeCode,
            CM.LineOfServiceTypeDescription
    )
    SELECT
    MarketID,
    MarketCode,
    GeographicAreaCode,
    GeographicAreaValue,
    GeographicAreaTypeCode,
    GeographicAreaTypeDescription,
    LineOfServiceCode,
    LegacyKey,
    LineOfServiceDescription,
    LineOfServiceTypeCode,
    LineOfServiceTypeDescription,
    SponsorshipXML,
    UpdatedDate,
    UpdatedSource
FROM
    CTE_my
 ';


--- Update Statement
update_statement := ' 
                    UPDATE 
                        SET 
                            target.MarketID =                       source.MarketID,
                            target.MarketCode =                     source.MarketCode, 
                            target.GeographicAreaCode =             source.GeographicAreaCode,
                            target.GeographicAreaValue =            source.GeographicAreaValue, 
                            target.GeographicAreaTypeCode =         source.GeographicAreaTypeCode,
                            target.GeographicAreaTypeDescription =  source.GeographicAreaTypeDescription, 
                            target.LineOfServiceCode =              source.LineOfServiceCode,
                            target.LegacyKey =                      source.LegacyKey,
                            target.LineOfServiceDescription =       source.LineOfServiceDescription, 
                            target.LineOfServiceTypeCode =          source.LineOfServiceTypeCode,
                            target.LineOfServiceTypeDescription =   source.LineOfServiceTypeDescription, 
                            target.SponsorshipXML =                 source.SponsorshipXML,
                            target.UpdatedDate =                    source.UpdatedDate, 
                            target.UpdatedSource =                  source.UpdatedSource
                        ';

--- Insert Statement
insert_statement := ' INSERT( 
                            MarketID,
                            MarketCode,
                            GeographicAreaCode,
                            GeographicAreaValue,
                            GeographicAreaTypeCode,
                            GeographicAreaTypeDescription,
                            LineOfServiceCode,
                            LegacyKey,
                            LineOfServiceDescription,
                            LineOfServiceTypeCode,
                            LineOfServiceTypeDescription, 
                            SponsorshipXML, 
                            UpdatedDate,
                            UpdatedSource
                            )
                      VALUES (
                            source.MarketID,
                            source.MarketCode,
                            source.GeographicAreaCode,
                            source.GeographicAreaValue,
                            source.GeographicAreaTypeCode,
                            source.GeographicAreaTypeDescription, 
                            source.LineOfServiceCode,
                            source.LegacyKey,
                            source.LineOfServiceDescription,
                            source.LineOfServiceTypeCode,
                            source.LineOfServiceTypeDescription,
                            source.SponsorshipXML,
                            UpdatedDate,
                            UpdatedSource
                      )';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO ODS1_STAGE.DEV.SOLRMARKET as target USING 
                   ('||select_statement||') as source 
                   ON source.MarketID = target.MarketID
                   WHEN MATCHED THEN '||update_statement|| '
                   WHEN NOT MATCHED THEN '||insert_statement;
                   
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