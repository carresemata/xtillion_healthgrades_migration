CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOCLIENTPRODUCTTODISPLAYPARTNER()
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
    procedure_name varchar(50) default('sp_load_ProviderToClientProductToDisplayPartner');
    execution_start DATETIME default getdate();

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
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        RETURN status;

        EXCEPTION
        WHEN OTHER THEN
            status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, SPLIT_PART(REGEXP_SUBSTR(:status, 'Error code: ([0-9]+)'), ':', 2)::INTEGER, TRIM(SPLIT_PART(SPLIT_PART(:status, 'SQL Error:', 2), 'Error code:', 1)), SPLIT_PART(REGEXP_SUBSTR(:status, 'SQL State: ([0-9]+)'), ':', 2)::INTEGER; 

            RETURN status;
END;