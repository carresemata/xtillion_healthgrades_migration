CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_FACILITYHOURS() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.FacilityHours depends on: 
--- MDM_TEAM.MST.FACILITY_PROFILE_PROCESSING (RAW.VW_FACILITY_PROFILE)
--- Base.Facility
--- Base.DaysOfWeek

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
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
-- If no conditionals:
select_statement := $$ SELECT DISTINCT
                        Facility.FacilityId,
                        IFNULL(JSON.Hours_SourceCode, 'Profisee') AS SourceCode,
                        Days.DaysOfWeekId,
                        JSON.Hours_OpeningTime AS FacilityHoursOpeningTime,
                        JSON.Hours_ClosingTime AS FacilityHoursClosingTime,
                        JSON.Hours_IsClosed AS FacilityIsClosed,
                        JSON.Hours_IsOpen24Hours AS FacilityIsOpen24Hours,
                        IFNULL(JSON.Hours_LastUpdateDate, CAST(CURRENT_TIMESTAMP() AS TIMESTAMP_NTZ(3))) AS LastUpdateDate
                    FROM
                        Raw.VW_FACILITY_PROFILE AS JSON
                        LEFT JOIN Base.Facility AS Facility ON JSON.FacilityCode = Facility.FacilityCode
                        LEFT JOIN Base.DaysOfWeek AS Days ON Days.DaysOfWeekCode = JSON.Hours_DaysOfWeek
                    WHERE
                        JSON.FACILITY_PROFILE IS NOT NULL AND
                        FacilityId IS NOT NULL AND
                        DaysOFWeekID IS NOT NULL 
                        QUALIFY ROW_NUMBER() OVER(PARTITION BY Facility.FacilityID, Hours_DaysOfWeek
                                                    ORDER BY
                                                    CREATE_DATE DESC) = 1 $$;


--- Insert Statement
insert_statement := ' INSERT  
                        (FacilityHoursID, 
                         FacilityId, 
                         SourceCode, 
                         DaysOfWeekID, 
                         FacilityHoursOpeningTime, 
                         FacilityHoursClosingTime, 
                         FacilityIsClosed, 
                         FacilityIsOpen24Hours, 
                         LastUpdateDate)
                      VALUES 
                        (UUID_STRING(), 
                         source.FacilityId, 
                         source.SourceCode, 
                         source.DaysOfWeekID, 
                         source.FacilityHoursOpeningTime, 
                         source.FacilityHoursClosingTime, 
                         source.FacilityIsClosed, 
                         source.FacilityIsOpen24Hours, 
                         source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := $$ MERGE INTO Base.FacilityHours as target USING 
                   ($$ ||select_statement|| $$) as source 
                   ON source.Facilityid = target.Facilityid
                   WHEN MATCHED AND source.SourceCode != 'HG INST' THEN DELETE
                   WHEN NOT MATCHED THEN $$ ||insert_statement;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
EXECUTE IMMEDIATE merge_statement ;

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