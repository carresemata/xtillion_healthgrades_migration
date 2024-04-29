CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PARTNER()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.Partner depends on: 
--- Base.swimlane_base_client
--- Base.Client
--- Base.PartnerType
--- Base.Product

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    update_clause STRING; -- where condition for update
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
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
select_statement := $$  WITH cte_swimlane AS (
    SELECT
        *
    from
        base.swimlane_base_client qualify dense_rank() over(
            partition by customerproductcode
            order by
                LastUpdateDate
        ) = 1
),
CTE_FeatureFCBRL AS (
    SELECT
        *,
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
    FROM
        CTE_swimlane
),
CTE_OASPartnerTypeCode AS (
    SELECT
        *,
        CASE
            WHEN PRODUCTCODE IN ('CDOAS', 'IOAS')
            AND OASPartnerTypeCode IS NULL THEN 'URL'
            ELSE OASPartnerTypeCode
        END AS OASPartnerTypeCodeNew
    FROM
        CTE_FeatureFCBRL
),
CTE_CustomerName AS (
    SELECT
        cte.*,
        CASE
            WHEN cte.CustomerName IS NULL
            AND c.ClientName IS NULL THEN cte.ClientCode
            WHEN cte.CustomerName IS NULL
            AND c.ClientName IS NOT NULL THEN c.ClientName
            ELSE cte.CustomerName
        END AS CustomerNameNew
    FROM
        CTE_OASPartnerTypeCode AS cte
        LEFT JOIN Base.Client AS C ON C.ClientCode = cte.ClientCode
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
    FROM
        CTE_CustomerName
)
SELECT DISTINCT
    C.ClientID AS PartnerID,
    cte.ClientCode AS PartnerCode,
    cte.CustomerName AS PartnerDescription,
    PT.PartnerTypeID,
    cte.ProductCode AS PartnerProductCode,
    p.ProductDescription AS PartnerProductDescription,
    cte.OASURLPath AS URLPath 
FROM CTE_FinalSwimlane AS cte
    INNER JOIN Base.PartnerType AS PT ON PT.PartnerTypeCode = cte.OASPartnerTypeCode
    INNER JOIN Base.Client AS C ON C.CLIENTCODE = cte.CLIENTCODE
    INNER JOIN Base.Product AS P ON p.Productcode = cte.ProductCode  $$;



--- Update Statement
update_statement := ' UPDATE 
                     SET  
                        target.PartnerTypeID = source.PartnerTypeID, 
                        target.PartnerProductCode = source.PartnerProductCode, 
                        target.URLPath = source.URLPath,
                        target.PartnerDescription = source.PartnerDescription,
                        target.PartnerProductDescription = source.PartnerProductDescription';
                            
-- Update Clause
update_clause := $$ IFNULL(target.PartnerTypeID,'00000000-0000-0000-0000-000000000000') != IFNULL(source.PartnerTypeID,'00000000-0000-0000-0000-000000000000') 
                    or IFNULL(target.PartnerProductCode,'') != IFNULL(source.PartnerProductCode,'') 
                    or IFNULL(target.URLPath,'') != IFNULL(source.URLPath,'')
                    or IFNULL(target.PartnerDescription,'') != IFNULL(source.PartnerDescription,'') 
                    or IFNULL(target.PartnerProductDescription,'') != IFNULL(source.PartnerProductDescription,'')
                    
                    $$;                        
        
--- Insert Statement
insert_statement := ' INSERT  
                            (PartnerID,
                            PartnerCode,
                            PartnerDescription,
                            PartnerTypeID,
                            PartnerProductCode,
                            PartnerProductDescription,
                            URLPath )
                      VALUES 
                            (source.PartnerID,
                            source.PartnerCode,
                            source.PartnerDescription,
                            source.PartnerTypeID,
                            source.PartnerProductCode,
                            source.PartnerProductDescription,
                            source.URLPath
                            )';


    
---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := ' MERGE INTO Base.Partner as target USING 
                   ('||select_statement||') as source 
                   ON source.partnerid = target.partnerid AND source.partnertypeid = target.partnertypeid
                   WHEN MATCHED AND' || update_clause || 'THEN '||update_statement|| '
                   WHEN NOT MATCHED AND 
                   not exists (select 1 from Base.Partner as p where p.PartnerCode = p.PartnerCode) THEN'||insert_statement;
                   
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