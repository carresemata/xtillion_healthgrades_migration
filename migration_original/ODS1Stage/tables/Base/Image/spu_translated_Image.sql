CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_IMAGE() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.Image depends on:
--- MDM_TEAM.MST.FACILITY_PROFILE_PROCESSING (RAW.VW_FACILITY_PROFILE)
--- Base.Facility
--- Base.ClientToProduct

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the insert
    insert_statement STRING; -- Insert statement 
    merge_statement STRING;
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_Image');
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

-- If conditionals:
select_statement := $$ WITH CTE_Swimlane AS (SELECT 
                                UUID_STRING() AS URLId,
                                F.FACILITYID,
                                JSONFacility.FacilityCode,
                                CTC.ClientToProductCode,
                                'FCCIURL' AS URLTypeCode,
                                JSONFacility.CUSTOMERPRODUCT_FEATUREFCCLURL AS URL,
                                SYSDATE() AS LastUpdateDate,
                                JSONFacility.CUSTOMERPRODUCT_FEATUREFCFLOGO AS FeatureFCFLogo
                            FROM RAW.VW_FACILITY_PROFILE AS JSONFacility
                                JOIN Base.Facility AS F ON F.FACILITYCODE = JSONFacility.FACILITYCODE
                                JOIN Base.ClientToProduct AS CTC ON CTC.CLIENTTOPRODUCTCODE = JSONFacility.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE
                                
                            WHERE 
                                JSONFacility.FACILITY_PROFILE IS NOT NULL AND
                                JSONFacility.FacilityCode IS NOT NULL AND
                                JSONFacility.CUSTOMERPRODUCT_FEATUREFCCLURL IS NOT NULL
                            QUALIFY row_number() over(partition by f.FacilityID order by JSONFacility.CREATE_DATE desc) = 1),
                            CTE_TempImage AS (SELECT DISTINCT
                                FacilityID, 
                                FacilityCode, 
                                ClientToProductCode, 
                                'FCFLOGO' as ImageTypeCode, 
                                'LOGO' as ImageSize, 
                                FeatureFCFLOGO as ImageFilePath 
                            FROM CTE_Swimlane
                            WHERE FeatureFCFLOGO IS NOT NULL)
                            SELECT
                                UUID_STRING() AS ImageID,
                                ImageFilePath,
                                SYSDATE() AS LastUpdateDate
                            FROM CTE_TempImage  $$;


insert_statement := ' INSERT
                        (ImageId,
                        ImageFilePath,
                        LastUpdateDate)
                      VALUES
                        (source.ImageId,
                        source.ImageFilePath,
                        source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement:= ' MERGE INTO Dev.Image as target USING 
                   ('||select_statement||') as source 
                   ON source.imageid = target.imageid 
                   WHEN NOT MATCHED THEN '||insert_statement;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE merge_statement ;

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