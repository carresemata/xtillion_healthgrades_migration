CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_CLIENTTOPRODUCT()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
--- Base,ClientToProduct depends on:
-- Base.swimlane_base_client

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

select_statement STRING;
insert_statement STRING; 
merge_statement STRING;
status STRING; -- Status monitoring

---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   

BEGIN
-- no conditionals
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------   
select_statement := $$
                    WITH CTE_swimlane AS (
                        SELECT *
                        FROM Base.swimlane_base_client 
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
                            CLIENTTOPRODUCTID,
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
                    
                    SELECT
                        s.ClientCode AS ClientID,
                        s.ProductCode AS ProductID,
                        IFNULL(s.ActiveFlag, true) AS ActiveFlag,
                        IFNULL(s.SourceCode, 'Profisee') AS SourceCode,
                        IFNULL(s.LastUpdateDate, CURRENT_TIMESTAMP()) AS LastUpdateDate,
                        s.QueueSize,
                        s.ClientToProductID,
                        -- s.ReltioEntityID
                    FROM 
                        CTE_FinalSwimlane s
                    WHERE
                        s.ClientToProductID IS NOT NULL
                        AND s.ClientCode IS NOT NULL
                        AND s.ProductCode IS NOT NULL
                        AND NOT EXISTS (
                            SELECT 1
                            FROM Base.ClientToProduct cp
                            WHERE cp.ClientToProductCode = s.ClientToProductID
                        )
                    $$;


insert_statement := $$ 
                    INSERT  
                        (
                         ClientID, 
                         ProductID, 
                         ActiveFlag, 
                         SourceCode, 
                         LastUpdateDate, 
                         QueueSize,
                         ClientToProductID
                         )
                    VALUES 
                        (
                        source.ClientID,
                        source.ProductID,
                        source.ActiveFlag,
                        source.SourceCode,
                        source.LastUpdateDate,
                        source.QueueSize,
                        source.ClientToProductID
                        )
                    $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := $$ MERGE INTO Base.ClientToProduct as target USING 
                   ($$||select_statement||$$) as source 
                   ON source.ClientToProductID = target.ClientToProductID
                   WHEN NOT MATCHED THEN $$||insert_statement;

    
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE merge_statement;

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