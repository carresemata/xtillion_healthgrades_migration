CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CLIENTPRODUCENTITYRELATIONSHIP()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
--- Base.ClientProductEntityRelationship depends on:
-- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
-- MDM_TEAM.MST.OFFICE_PROFILE_PROCESSING (RAW.VW_OFFICE_PROFILE)
-- Base.Provider
-- Base.Facility
-- Base.Office
-- Base.RelationshipType
-- Base.ClientToProduct
-- Base.EntityType
-- Base.ClientProductToEntity
-- Base.Practice

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

select_statement_facility STRING;
select_statement_office STRING;
select_statement_practice STRING;
insert_statement STRING; 
merge_statement_facility STRING;
merge_statement_office STRING;
merge_statement_practice STRING;
status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_ClientProductEntityRelationship');
    execution_start DATETIME default getdate();


---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   

BEGIN
-- no conditionals
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------  

------------ spuMergeProviderFacilityCustomerProduct ------------
select_statement_facility := $$
                            WITH CTE_swimlane AS (
                                    SELECT DISTINCT
                                    -- ReltioEntityId (deprecated)
                                    p.ProviderID,
                                    f.FacilityID,
                                    -- SourceID (unused)
                                    IFNULL(CUSTOMERPRODUCT_LASTUPDATEDATE, SYSDATE()) AS LastUpdateDate,
                                    IFNULL(CUSTOMERPRODUCT_SOURCECODE, 'Profisee') AS SourceCode,
                                    JSON.PROVIDERCODE, 
                                    JSON.FACILITY_FACILITYCODE AS FacilityCode,
                                    JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE AS ClientToProductCode,
                                    cp.ClientToProductID,
                                    rt.RelationshipTypeID,
                                    rt.RelationshipTypeCode,
                                    ROW_NUMBER() OVER(PARTITION BY p.ProviderID, f.FacilityID ORDER BY CREATE_DATE DESC) AS RowRank
                                FROM RAW.VW_PROVIDER_PROFILE AS JSON
                                LEFT JOIN Base.Provider p ON p.ProviderCode = JSON.ProviderCode
                                INNER JOIN Base.Facility f ON f.FacilityCode = JSON.Facility_FacilityCode
                                LEFT JOIN Base.RelationshipType rt ON rt.RelationshipTypeCode='PROVTOFAC'
                                INNER JOIN Base.ClientToProduct cp ON cp.ClientToProductCode = JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE
                                WHERE JSON.PROVIDER_PROFILE IS NOT NULL
                            )
                            
                            SELECT 
                                s.RelationshipTypeID,
                                cptep.ClientProductToEntityID AS ParentID,
                                cptef.ClientProductToEntityID AS ChildID,
                                s.SourceCode,
                                s.LastUpdateDate
                            FROM CTE_Swimlane s
                            INNER JOIN Base.EntityType prov ON prov.EntityTypeCode='PROV'
                            INNER JOIN Base.EntityType fac ON fac.EntityTypeCode='FAC'
                            INNER JOIN Base.ClientProductToEntity cptep ON s.ProviderID = cptep.EntityID
                                AND prov.EntityTypeID = cptep.EntityTypeID 
                            INNER JOIN Base.ClientProductToEntity cptef ON s.FacilityID = cptef.EntityID
                                AND fac.EntityTypeID = cptef.EntityTypeID
                            WHERE s.RowRank = 1 AND cptep.ClientToProductID = cptef.ClientToProductID
                            $$;


------------ spuMergeProviderOfficeCustomerProduct ------------
select_statement_office := $$
                            WITH CTE_swimlane AS (
                                    SELECT DISTINCT
                                    -- ReltioEntityId (deprecated)
                                    p.ProviderID,
                                    o.OfficeID,
                                    -- SourceID (unused)
                                    IFNULL(CUSTOMERPRODUCT_LASTUPDATEDATE, SYSDATE()) AS LastUpdateDate,
                                    IFNULL(CUSTOMERPRODUCT_SOURCECODE, 'Profisee') AS SourceCode,
                                    JSON.PROVIDERCODE, 
                                    JSON.OFFICE_OFFICECODE AS OfficeCode,
                                    JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE AS ClientToProductCode,
                                    cp.ClientToProductID,
                                    rt.RelationshipTypeID,
                                    rt.RelationshipTypeCode,
                                    ROW_NUMBER() OVER(PARTITION BY p.ProviderID, o.OfficeID ORDER BY CREATE_DATE DESC) AS RowRank
                                FROM RAW.VW_PROVIDER_PROFILE AS JSON
                                LEFT JOIN Base.Provider p ON p.ProviderCode = JSON.ProviderCode
                                INNER JOIN Base.Office o ON o.OfficeCode = JSON.Office_OfficeCode
                                LEFT JOIN Base.RelationshipType rt ON rt.RelationshipTypeCode='PROVTOOFF'
                                INNER JOIN Base.ClientToProduct cp ON cp.ClientToProductCode = JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE
                                WHERE JSON.PROVIDER_PROFILE IS NOT NULL
                            )
                            
                            SELECT 
                                s.RelationshipTypeID,
                                cptep.ClientProductToEntityID AS ParentID,
                                cpteo.ClientProductToEntityID AS ChildID,
                                s.SourceCode,
                                s.LastUpdateDate
                            FROM CTE_Swimlane s
                            INNER JOIN Base.EntityType prov ON prov.EntityTypeCode='PROV'
                            INNER JOIN Base.EntityType off ON off.EntityTypeCode='OFFICE'
                            INNER JOIN Base.ClientProductToEntity cptep ON s.ProviderID = cptep.EntityID
                                AND prov.EntityTypeID = cptep.EntityTypeID 
                            INNER JOIN Base.ClientProductToEntity cpteo ON s.OfficeID = cpteo.EntityID
                                AND off.EntityTypeID = cpteo.EntityTypeID
                            WHERE s.RowRank = 1 AND cptep.ClientToProductID = cpteo.ClientToProductID
                            $$;

------------ spuMergePracticeOfficeCustomerProduct ------------
select_statement_practice := $$
                            WITH CTE_swimlane AS (
                                SELECT DISTINCT
                                -- ReltioEntityId (deprecated)
                                o.OfficeID,
                                p.PracticeID,
                                -- SourceID (unused)
                                SYSDATE() AS LastUpdateDate,
                                'Profisee' AS SourceCode,
                                JSON.PRACTICE_PRACTICECODE AS PracticeCode, 
                                JSON.OFFICECODE AS OfficeCode,
                                ProviderJSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE AS ClientToProductCode,
                                cp.ClientToProductID,
                                rt.RelationshipTypeID,
                                rt.RelationshipTypeCode,
                                ROW_NUMBER() OVER(PARTITION BY o.OfficeID ORDER BY JSON.CREATE_DATE DESC) AS RowRank
                            FROM RAW.VW_OFFICE_PROFILE AS JSON
                            LEFT JOIN Base.Practice p ON p.PracticeCode = JSON.PRACTICE_PRACTICECODE
                            INNER JOIN Base.Office o ON o.OfficeCode = JSON.OFFICECODE
                            LEFT JOIN Base.RelationshipType rt ON rt.RelationshipTypeCode='PRACTOOFF'
                            LEFT JOIN RAW.VW_PROVIDER_PROFILE ProviderJSON ON JSON.OFFICECODE = ProviderJSON.OFFICE_OFFICECODE
                            INNER JOIN Base.ClientToProduct cp ON cp.ClientToProductCode = ClientToProductCode
                            WHERE JSON.OFFICE_PROFILE IS NOT NULL
                        )
                        
                        SELECT 
                            s.RelationshipTypeID,
                            cptep.ClientProductToEntityID AS ParentID,
                            cpteo.ClientProductToEntityID AS ChildID,
                            s.SourceCode,
                            s.LastUpdateDate
                        FROM CTE_Swimlane s
                        INNER JOIN Base.EntityType prac ON prac.EntityTypeCode='PRAC'
                        INNER JOIN Base.EntityType off ON off.EntityTypeCode='OFFICE'
                        INNER JOIN Base.ClientProductToEntity cptep ON s.PracticeID = cptep.EntityID
                            AND prac.EntityTypeID = cptep.EntityTypeID 
                        INNER JOIN Base.ClientProductToEntity cpteo ON s.OfficeID = cpteo.EntityID
                            AND off.EntityTypeID = cpteo.EntityTypeID
                        WHERE s.RowRank = 1 AND cptep.ClientToProductID = cpteo.ClientToProductID
                        $$;

                
insert_statement := $$ 
                    INSERT  
                        (
                         ClientProductEntityRelationshipID, 
                         RelationshipTypeID, 
                         ParentID, 
                         ChildID, 
                         SourceCode,
                         LastUpdateDate
                         )
                    VALUES 
                        (
                        UUID_STRING(),
                        source.RelationshipTypeID,
                        source.ParentID,
                        source.ChildID,
                        source.SourceCode,
                        source.LastUpdateDate
                        )
                    $$;


---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement_facility := $$ MERGE INTO Base.ClientProductEntityRelationship as target USING 
                           ($$||select_statement_facility||$$) as source 
                           ON source.RelationshipTypeID = target.RelationshipTypeID
                            AND source.ParentID = target.ParentID AND source.ChildID = target.ChildID
                           WHEN NOT MATCHED THEN $$||insert_statement;
                           

merge_statement_office := $$ MERGE INTO Base.ClientProductEntityRelationship as target USING 
                           ($$||select_statement_office||$$) as source 
                           ON source.RelationshipTypeID = target.RelationshipTypeID
                            AND source.ParentID = target.ParentID AND source.ChildID = target.ChildID
                           WHEN NOT MATCHED THEN $$||insert_statement;


merge_statement_practice := $$ MERGE INTO Base.ClientProductEntityRelationship as target USING 
                           ($$||select_statement_practice||$$) as source 
                           ON source.RelationshipTypeID = target.RelationshipTypeID
                            AND source.ParentID = target.ParentID AND source.ChildID = target.ChildID
                           WHEN NOT MATCHED THEN $$||insert_statement;

    
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE merge_statement_facility;
EXECUTE IMMEDIATE merge_statement_office;
EXECUTE IMMEDIATE merge_statement_practice;

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