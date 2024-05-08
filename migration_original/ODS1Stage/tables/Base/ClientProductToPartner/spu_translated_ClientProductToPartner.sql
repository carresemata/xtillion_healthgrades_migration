CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_CLIENTPRODUCTTOPARTNER()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

--- Base.ClientProductToPartner depends on: 
-- MDM_TEAM.MST.CUSTOMER_PRODUCT_PROFILE_PROCESSING (Base.vw_swimlane_base_client)
-- Base.Client
-- Base.ClientToProduct
-- Base.Partner


---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

cte_sl STRING; -- bulk of swim lane
select_statement_1 STRING; 
select_statement_2 STRING; 
insert_statement STRING; 
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

cte_sl := $$
          WITH cte_swimlane AS (
                SELECT *
                FROM Base.vw_swimlane_base_client 
                QUALIFY DENSE_RANK() OVER(PARTITION BY customerproductcode ORDER BY LastUpdateDate) = 1
            ),
            
            CTE_FeatureFCBRL AS (
                SELECT *,
                CASE
                    WHEN LEFT(FeatureFCBRL, 2) != 'FV' THEN 'FV' || UPPER(
                        REPLACE(
                            REPLACE(
                                REPLACE(FeatureFCBRL, 'CLIENT', 'CLT'),
                                'CUSTOMER',
                                'CLT'
                            ),
                            'FACILITY',
                            'FAC'
                        )
                    )
                    ELSE FeatureFCBRL
                END AS FeatureFCBRLNew
                FROM CTE_swimlane
            ),
            
            CTE_OASPartnerTypeCode AS (
                SELECT *,
                CASE
                    WHEN PRODUCTCODE IN ('CDOAS', 'IOAS') AND OASPartnerTypeCode IS NULL THEN 'URL'
                    ELSE OASPartnerTypeCode
                END AS OASPartnerTypeCodeNew
                FROM CTE_FeatureFCBRL
            ),
            
            CTE_CustomerName AS (
                SELECT cte.*,
                CASE
                    WHEN cte.CustomerName IS NULL AND c.ClientName IS NULL THEN cte.ClientCode
                    WHEN cte.CustomerName IS NULL AND c.ClientName IS NOT NULL THEN c.ClientName
                    ELSE cte.CustomerName
                END AS CustomerNameNew
                FROM CTE_OASPartnerTypeCode AS cte
                LEFT JOIN Base.Client AS c ON c.ClientCode = cte.ClientCode
            ),
            
            CTE_FinalSwimlane AS (
                SELECT
                    CREATED_DATETIME,
                    CUSTOMERPRODUCTCODE,
                    CLIENTCODE,
                    PRODUCTCODE,
                    CUSTOMERPRODUCTJSON,
                    CUSTOMERNAMENEW AS CustomerName,
                    QUEUESIZE,
                    LASTUPDATEDATE,
                    SOURCECODE,
                    ACTIVEFLAG,
                    OASURLPATH,
                    OASPARTNERTYPECODENEW AS OASPartnerTypeCode,
                    FEATUREFCBFN,
                    FEATUREFCBRLNEW AS FeatureFCBRL,
                    FEATUREFCCCP_FVCLT,
                    FEATUREFCCCP_FVFAC,
                    FEATUREFCCCP_FVOFFICE,
                    FEATUREFCCLLOGO,
                    FEATUREFCCWALL,
                    FEATUREFCCLURL,
                    FEATUREFCDISLOC,
                    FEATUREFCDOA,
                    FEATUREFCDOS_FVFAX,
                    FEATUREFCDOS_FVMMPEML,
                    FEATUREFCDTP,
                    FEATUREFCEOARD,
                    FEATUREFCEPR,
                    FEATUREFCOOACP,
                    FEATUREFCLOT,
                    FEATUREFCMAR,
                    FEATUREFCMWC,
                    FEATUREFCNPA,
                    FEATUREFCOAS,
                    FEATUREFCOASURL,
                    FEATUREFCOASVT,
                    FEATUREFCOBT,
                    FEATUREFCODC_FVDFC,
                    FEATUREFCODC_FVDPR,
                    FEATUREFCODC_FVMT,
                    FEATUREFCODC_FVPSR,
                    FEATUREFCPNI,
                    FEATUREFCPQM,
                    FEATUREFCREL_FVCPOFFICE,
                    FEATUREFCREL_FVCPTOCC,
                    FEATUREFCREL_FVCPTOFAC,
                    FEATUREFCREL_FVCPTOPRAC,
                    FEATUREFCREL_FVCPTOPROV,
                    FEATUREFCREL_FVPRACOFF,
                    FEATUREFCREL_FVPROVFAC,
                    FEATUREFCREL_FVPROVOFF,
                    FEATUREFCSPC,
                    FEATUREFCOOPSR,
                    FEATUREFCOOMT
                FROM CTE_CustomerName
            )
          $$;

select_statement_1 := cte_sl || $$
                                SELECT DISTINCT
                                   UUID_STRING() AS ClientProductToPartnerID,
                                   ctp.ClientToProductId, 
                                   c.ClientId AS PartnerID,
                                   'HG Reference' AS SourceCode, 
                                   SYSDATE() AS LastUpdateDate, 
                                   CURRENT_USER() AS LastUpdateUser, 
                                FROM CTE_FinalSwimlane AS cte
                                INNER JOIN Base.Client c ON c.ClientCode = LEFT(cte.ClientCode, LEN(cte.ClientCode) - 3)
                                INNER JOIN Base.ClientToProduct ctp ON ctp.ClientId = c.ClientId
                                LEFT JOIN Base.ClientProductToPartner cptp ON cptp.ClientToProductID = ctp.ClientToProductID
                                WHERE cptp.ClientProductToPartnerID IS NULL
                                $$;


select_statement_2 := cte_sl || $$
                                SELECT DISTINCT
                                   UUID_STRING() AS ClientProductToPartnerID,
                                   ctp.ClientToProductId, 
                                   (SELECT PartnerId FROM Base.Partner WHERE PartnerCode = 'MHD') AS PartnerID,
                                   'HG Reference' AS SourceCode, 
                                   SYSDATE() AS LastUpdateDate, 
                                   CURRENT_USER() AS LastUpdateUser, 
                                FROM CTE_FinalSwimlane AS cte
                                INNER JOIN Base.Client c ON c.ClientCode = LEFT(cte.ClientCode, LEN(cte.ClientCode) - 3)
                                INNER JOIN Base.ClientToProduct ctp ON ctp.ClientId = c.ClientId
                                LEFT JOIN Base.ClientProductToPartner cptp ON cptp.ClientToProductID = ctp.ClientToProductID
                                WHERE cptp.ClientProductToPartnerID IS NULL AND ctp.ClientToProductID LIKE '%-MAP' 
                                    AND LEFT(ctp.ClientToProductID, POSITION('-', ctp.ClientToProductID) - 1) IN ('STDAVD','HCASAM','HCASM','HCAPASO','HCAWNV','HCAGC','HCAHL1','HCACKS','HCALEW','HCACARES','HCACVA','HCAFRFT','HCATRI','HCASATL','HCANFD','HCAMW','HCAWFD','HCAMT','HCANTD','HCACVA','HCAMT','HCAMW','HCACKS','HCAEFD','HCAGC','HCAHL1','HCALEW','HCANFD','HCAPASO','HCASAM','HCASATL','HCATRI','HCAWFD','HCAWNV','HCAFRFT','HCARES','STDAVD')
                                $$;

                                
insert_statement := $$ 
                    INSERT  
                        (
                         ClientProductToPartnerID, 
                         ClientToProductID, 
                         PartnerID, 
                         SourceCode, 
                         LastUpdateDate, 
                         LastUpdateUser 
                         )
                    VALUES 
                        (
                        source.ClientProductToPartnerID,
                        source.ClientToProductID,
                        source.PartnerID,
                        source.SourceCode,
                        source.LastUpdateDate,
                        source.LastUpdateUser
                        )
                    $$;


---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement_1 := $$ MERGE INTO Base.ClientProductToPartner as target USING 
                   ($$||select_statement_1||$$) as source 
                   ON source.ClientProductToPartnerID = target.ClientProductToPartnerID 
                   WHEN NOT MATCHED THEN $$||insert_statement;

merge_statement_2 := $$ MERGE INTO Base.ClientProductToPartner as target USING 
                   ($$||select_statement_2||$$) as source 
                   ON source.ClientProductToPartnerID = target.ClientProductToPartnerID 
                   WHEN NOT MATCHED THEN $$||insert_statement;

---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE merge_statement_1;
EXECUTE IMMEDIATE merge_statement_2;

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