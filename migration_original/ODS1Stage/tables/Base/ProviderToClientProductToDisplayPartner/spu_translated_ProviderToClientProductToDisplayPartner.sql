CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTOCLIENTPRODUCTTODISPLAYPARTNER()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
DECLARE
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- Base.ProviderToClientProductToDisplayPartner depends on :
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.ClientToProduct
--- Base.SyndicationPartner


---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
select_statement STRING;
insert_statement STRING;
merge_statement STRING;
status STRING;
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------
BEGIN
-- no conditionals
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- Select Statement
select_statement := $$  SELECT DISTINCT
                        P.ProviderID,
                        CP.ClientToProductID,
                        SP.SyndicationPartnerId,
                        JSON.CUSTOMERPRODUCT_SOURCECODE AS SourceCode,
                        IFNULL(JSON.CUSTOMERPRODUCT_LASTUPDATEDATE, SYSDATE()) AS LastUpdateDate
                        
                        FROM Raw.VW_PROVIDER_PROFILE AS JSON
                            INNER JOIN Base.Provider AS P ON p.ProviderCode = JSON.ProviderCode
                            INNER JOIN Base.ClientToProduct AS cp ON cp.ClientToProductCode = JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE
                            INNER JOIN Base.SyndicationPartner AS SP ON SP.SYNDICATIONPARTNERCODE = JSON.CUSTOMERPRODUCT_DISPLAYPARTNER
                        
                        WHERE
                            PROVIDER_PROFILE IS NOT NULL AND
                            JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE IS NOT NULL AND
                            JSON.CUSTOMERPRODUCT_DISPLAYPARTNER IS NOT NULL AND
                            ClientToProductID IS NOT NULL AND
                            ProviderID IS NOT NULL
                        
                        QUALIFY dense_rank() over(partition by ProviderID, JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE order by CREATE_DATE desc) = 1 $$;

-- Insert Statement
insert_statement := ' INSERT (
                        ProviderCPDPID,
                        ProviderID,
                        ClientToProductID,
                        SyndicationPartnerId,
                        SourceCode,
                        LastUpdateDate)
                     VALUES (
                        UUID_STRING(),
                        source.ProviderID,
                        source.ClientToProductID,
                        source.SyndicationPartnerId,
                        source.SourceCode,
                        source.LastUpdateDate)';


---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := 'MERGE INTO Base.ProviderToClientProductToDisplayPartner AS target
USING
('||select_statement||') AS source
ON source.ProviderID = target.ProviderID
AND source.ClientToProductID = target.ClientToProductID
AND source.SyndicationPartnerId = target.SyndicationPartnerId
WHEN MATCHED THEN DELETE
WHEN NOT MATCHED THEN' || insert_statement;

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