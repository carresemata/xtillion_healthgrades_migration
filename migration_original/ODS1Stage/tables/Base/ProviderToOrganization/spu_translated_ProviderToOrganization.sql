CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTOORGANIZATION()
RETURNS STRING
LANGUAGE SQL EXECUTE
AS CALLER
AS DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- Base.ProviderToOrganization depends on:
-- Raw.Provider_Profile_JSON
-- Base.Provider

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

select_statement := $$
                    SELECT
                        IFNULL(JSON.Organization_SourceCode, 'Profisee') AS SourceCode,
                        UUID_STRING() AS ProviderToOrganizationID,
                        p.ProviderID AS ProviderID,
                        JSON.ProviderCode AS ProviderCode,
                        -- OrganizationID,
                        -- PositionID,
                        -- PositionStartDate,
                        -- PositionEndDate,
                        JSON.Organization_PositionRank AS PositionRank,
                        SYSDATE() AS LastUpdateDate,
                        CURRENT_USER() AS InsertedBy
                    FROM Raw.VW_PROVIDER_PROFILE AS JSON
                    LEFT JOIN Base.Provider AS p ON p.ProviderCode = JSON.ProviderCode
                    WHERE p.ProviderID IS NOT NULL
                    $$;


insert_statement := $$ 
                     INSERT  
                       (   
                        SourceCode,
                        ProviderToOrganizationID,
                        ProviderID,
                        -- OrganizationID,
                        -- PositionID,
                        -- PositionStartDate,
                        -- PositionEndDate,
                        PositionRank,
                        LastUpdateDate,
                        InsertedBy
                        )
                      VALUES 
                        (   
                        source.SourceCode,
                        source.ProviderToOrganizationID,
                        source.ProviderID,
                        -- OrganizationID,
                        -- PositionID,
                        -- PositionStartDate,
                        -- PositionEndDate,
                        source.PositionRank,
                        source.LastUpdateDate,
                        source.InsertedBy
                        )
                     $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := $$ MERGE INTO Base.ProviderToOrganization as target 
                    USING ($$||select_statement||$$) as source 
                   ON source.ProviderId = target.ProviderId
                   WHEN MATCHED THEN DELETE
                   WHEN NOT MATCHED THEN $$ ||insert_statement;

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