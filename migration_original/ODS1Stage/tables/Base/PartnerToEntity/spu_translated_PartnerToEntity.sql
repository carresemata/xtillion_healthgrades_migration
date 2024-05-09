CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PARTNERTOENTITY() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.PartnerToEntity depends on:
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.Partner
--- Base.Office
--- Base.ProviderToOffice
--- Base.EntityType

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement_1 STRING; -- CTE and Select statement for the insert
    select_statement_2 STRING;
    insert_statement_1 STRING; -- Insert statement 
    insert_statement_2 STRING;
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_PartnerToEntity');
    execution_start DATETIME default getdate();

   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    -- no conditionals


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
select_statement_1 := $$
WITH CTE_SwimlaneURL AS (
    SELECT DISTINCT
        P.ProviderId,
        JSON.ProviderCode,
        LEFT(JSON.OAS_CUSTOMERPRODUCTCODE, POSITION('-' IN JSON.OAS_CUSTOMERPRODUCTCODE) - 1) AS PartnerCode,
        JSON.OAS_CUSTOMERPRODUCTCODE AS OASCustomerProductCode,
        JSON.OAS_URL AS OasURL,
        row_number() over(partition by JSON.ProviderCode, JSON.OAS_CUSTOMERPRODUCTCODE order by CREATE_DATE desc) as RowRank
    FROM RAW.VW_PROVIDER_PROFILE AS JSON
    INNER JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
    WHERE PROVIDER_PROFILE IS NOT NULL AND
        OAS_CUSTOMERPRODUCTCODE IS NOT NULL
),
CTE_SwimlaneAPI AS (
    SELECT 
        JSON.ProviderCode,
        P.ProviderId,
        O.OfficeId,
        JSON.OFFICE_OFFICECODE AS OfficeCode,
        SUBSTRING(
        JSON.OAS_CUSTOMERPRODUCTCODE, 
        1, POSITION('-' IN JSON.OAS_CUSTOMERPRODUCTCODE) - 1) AS PartnerCode ,
        JSON.OAS_CUSTOMERPRODUCTCODE AS OasCustomerProductCode,
        row_number() over(partition by JSON.ProviderCode, JSON.OFFICE_OFFICECODE order by CREATE_DATE desc) as RowRank
    FROM RAW.VW_PROVIDER_PROFILE AS JSON
    INNER JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
    INNER JOIN Base.Office AS O ON O.OFFICECODE = JSON.OFFICE_OFFICECODE
),
CTE_SwimlaneAPIUpdated AS (
    select * 
    from cte_swimlaneapi AS api1
    where exists (select * from cte_swimlaneapi AS api2 JOIN cte_swimlaneapi AS api1 ON api1.Providercode = api2.ProviderCode AND api2.OASCustomerProductCode IS NOT NULL)
), 
CTE_SwimlaneURL2 AS (
    SELECT
        UUID_STRING() AS PartnerToEntityId,
        Par.PartnerId,
        Prov.ProviderId AS PrimaryEntityId,
        (select entitytypeid from Base.entitytype where entitytypecode = 'PROV') As PrimaryEntityTypeId,
        ProvOff.OfficeId AS SecondaryEntityID,
        (select entitytypeid from Base.entitytype where entitytypecode = 'OFFICE') As SecondaryEntityTypeID,
        ProvOff.OfficeId AS PartnerSecondaryEntityId,
        cte.OASUrl,
        SYSDATE() AS LastUpdateDate
    FROM CTE_swimlaneUrl AS cte
    INNER JOIN Base.Partner AS Par ON Par.PartnerCode = cte.PartnerCode
    INNER JOIN Base.Provider AS Prov ON Prov.ProviderCode = cte.ProviderCode
    INNER JOIN Base.ProviderToOffice AS ProvOff ON ProvOff.ProviderID = cte.ProviderId
    WHERE RowRank = 1 
)$$;


select_statement_2 := select_statement_1 || 
$$, CTE_SwimlaneAPI2 AS (
    SELECT
        UUID_STRING() AS PartnerToEntityId,
        Par.PartnerId,
        Prov.ProviderId AS PrimaryEntityId,
        (select entitytypeid from Base.entitytype where entitytypecode = 'PROV') As PrimaryEntityTypeId,
        cte.OfficeId AS SecondaryEntityID,
        (select entitytypeid from Base.entitytype where entitytypecode = 'OFFICE') As SecondaryEntityTypeID,
        Off.PracticeId AS TertiaryEntityId,
        (select entitytypeid from Base.entitytype where entitytypecode = 'PRAC') As TertiaryEntityTypeID,
        SYSDATE() AS LastUpdateDate
    FROM CTE_SwimlaneAPIUpdated AS cte
    INNER JOIN Base.Partner AS Par ON Par.PartnerCode = cte.PartnerCode
    INNER JOIN Base.Provider AS Prov ON Prov.ProviderCode = cte.ProviderCode
    INNER JOIN Base.Office AS Off ON Off.OfficeId = cte.OfficeID
    WHERE RowRank = 1
)
select * from cte_swimlaneapi2$$;



---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

insert_statement_1 := ' MERGE INTO Base.PartnerToEntity as target USING 
                   ('||select_statement_1 ||' SELECT * FROM CTE_swimlaneURL2) as source 
                   ON target.PartnerToEntityId = source.PartnerToEntityId AND target.PartnerId = source.PartnerId
                   WHEN NOT MATCHED THEN 
                    INSERT (PartnerToEntityId,
                            PartnerID, 
                            PrimaryEntityID, 
                            PrimaryEntityTypeID, 
                            SecondaryEntityID, 
                            SecondaryEntityTypeID, 
                            PartnerSecondaryEntityId,
                            OASURL, 
                            LastUpdateDate)
                    VALUES (source.PartnerToEntityId,
                            source.PartnerID, 
                            source.PrimaryEntityID, 
                            source.PrimaryEntityTypeID, 
                            source.SecondaryEntityID, 
                            source.SecondaryEntityTypeID, 
                            source.PartnerSecondaryEntityId,
                            source.OASURL, 
                            source.LastUpdateDate)';

                    
insert_statement_2 := ' MERGE INTO Base.PartnerToEntity as target USING 
                   ('||select_statement_2 ||') as source 
                   ON target.PartnerToEntityId = source.PartnerToEntityId AND target.PartnerId = source.PartnerId
                   WHEN NOT MATCHED THEN 
                    INSERT (PartnerToEntityId,
                            PartnerID, 
                            PrimaryEntityID, 
                            PrimaryEntityTypeID, 
                            SecondaryEntityID, 
                            SecondaryEntityTypeID,  
                            TertiaryEntityID, 
                            TertiaryEntityTypeID, 
                            LastUpdateDate)
                    VALUES (source.PartnerToEntityId,
                            source.PartnerID, 
                            source.PrimaryEntityID, 
                            source.PrimaryEntityTypeID, 
                            source.SecondaryEntityID, 
                            source.SecondaryEntityTypeID, 
                            source.TertiaryEntityID,
                            source.TertiaryEntityTypeID, 
                            source.LastUpdateDate)';
                    
 
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE insert_statement_1 ;
EXECUTE IMMEDIATE insert_statement_2 ;

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
