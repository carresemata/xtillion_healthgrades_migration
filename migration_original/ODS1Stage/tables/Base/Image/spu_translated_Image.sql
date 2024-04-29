CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_IMAGE() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.Image depends on:
--- Raw.VW_FACILITY_PROFILE
--- Base.Facility
--- Base.ClientToProduct

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the insert
    insert_statement STRING; -- Insert statement 
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



---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

insert_statement := ' INSERT INTO Base.Image 
                        (ImageId,
                        ImageFilePath,
                        LastUpdateDate) ' ||select_statement;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE insert_statement ;

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