CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_URL()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  

DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- BASE.URL depends on:
--- MDM_TEAM.MST.FACILITY_PROFILE_PROCESSING (RAW.VW_FACILITY_PROFILE)
--- MDM_TEAM.MST.CUSTOMER_PRODUCT_PROFILE_PROCESSING (RAW.VW_CUSTOMER_PRODUCT_PROFILE)
--- Base.Facility
--- Base.ClientToProduct

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
select_statement := $$  WITH CTE_swimlane AS (SELECT 
                                UUID_STRING() AS URLId,
                                F.FACILITYID,
                                JSONFacility.FacilityCode,
                                CTC.ClientToProductCode,
                                'FCCIURL' AS URLTypeCode,
                                JSONCustomer.Feature_FeatureFCCLURL AS URL,
                                SYSDATE() AS LastUpdateDate
                            FROM RAW.VW_FACILITY_PROFILE AS JSONFacility
                                JOIN Base.Facility AS F ON F.FACILITYCODE = JSONFacility.FACILITYCODE
                                JOIN Base.ClientToProduct AS CTC ON CTC.CLIENTTOPRODUCTCODE = JSONFacility.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE
                                LEFT JOIN Raw.VW_CUSTOMER_PRODUCT_PROFILE AS JSONCustomer ON JSONCustomer.CUSTOMERPRODUCTCODE = JSONFacility.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE
                            WHERE 
                                JSONFacility.FACILITY_PROFILE IS NOT NULL AND
                                JSONFacility.FacilityCode IS NOT NULL AND
                                JSONCustomer.Feature_FeatureFCCLURL IS NOT NULL
                            QUALIFY row_number() over(partition by f.FacilityID order by JSONFacility.CREATE_DATE desc) = 1)
                            SELECT 
                                URLid,
                                URL,
                                LastUpdateDate
                            FROM CTE_Swimlane  $$;

insert_statement := ' INSERT
                       (URLid,
                        URL,
                        LastUpdateDate)
                    VALUES
                        (source.URLid,
                        source.URL,
                        source.LastUpdateDate)';


---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------


merge_statement := ' MERGE INTO Base.URL AS target 
USING ('||select_statement||') AS source
ON source.URLId = target.URLID 
WHEN NOT MATCHED THEN '||insert_statement;

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