CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_OFFICE()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.Office depends on: 
--- MDM_TEAM.MST.OFFICE_PROFILE_PROCESSING (RAW.VW_OFFICE_PROFILE)
--- Base.Practice

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    update_clause STRING; -- where condition for update
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_Office');
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
select_statement := $$  SELECT 
                                -- ReltioEntityID,
                                UUID_STRING() AS OfficeID,
                                CASE WHEN LENGTH(JSON.OfficeCode)>10 THEN NULL ELSE JSON.OfficeCode END AS OfficeCode, 
                                P.PracticeId, 
                                -- HasBillingStaff
                                -- HasHandicapAccess
                                -- HasLabServicesOnSite
                                -- HasPharmacyOnSite
                                -- HasXrayOnSite
                                -- IsSurgeryCenter
                                -- HasSurgeryOnSite
                                -- AverageDailyPatientVolume
                                -- PhysicianCount
                                -- OfficeCoordinatorName
                                JSON.DEMOGRAPHICS_PARKINGINFORMATION AS ParkingInformation,
                                -- PaymentPolicy
                                JSON.DEMOGRAPHICS_OFFICENAME AS OfficeName,
                                IFNULL(JSON.DEMOGRAPHICS_SOURCECODE, 'Profisee') AS Sourcecode,
                                -- OfficeRank
                                -- Is Derived
                                -- NPI
                                IFNULL(JSON.DEMOGRAPHICS_LASTUPDATEDATE, SYSDATE() ) AS LastUpdateDate
                                -- OfficeDescription
                                -- HasChildPlayground
                                -- OfficeWebsite
                                -- OfficeEmail
                            FROM RAW.VW_OFFICE_PROFILE AS JSON
                                LEFT JOIN Base.Practice AS P ON P.PracticeCode = JSON.PRACTICE_PRACTICECODE
                            WHERE
                                OFFICE_PROFILE IS NOT NULL
                                AND OFFICECODE IS NOT NULL
                            QUALIFY row_number() over(partition by OfficeID order by CREATE_DATE desc) = 1 $$;



--- Update Statement
update_statement := ' UPDATE 
                     SET  target.OfficeCode = source.OfficeCode, 
                            target.PracticeID = source.PracticeID, 
                            target.ParkingInformation = source.ParkingInformation, 
                            target.OfficeName = source.OfficeName, 
                            target.SourceCode = source.SourceCode, 
                            target.LastUpdateDate = source.LastUpdateDate';
                            
-- Update Clause
update_clause := $$  IFNULL(target.OfficeCode, '') != IFNULL(source.OfficeCode, '') 
                    or IFNULL(target.OfficeName, '') != IFNULL(source.OfficeName, '') 
                    or IFNULL(target.SourceCode, '') != IFNULL(source.SourceCode, '') 
                    or IFNULL(target.ParkingInformation, '') != IFNULL(source.ParkingInformation, '') 
                    $$;                        
        
--- Insert Statement
insert_statement := ' INSERT  
                            (OfficeID,
                            OfficeCode,
                            PracticeID,
                            ParkingInformation,
                            OfficeName,
                            SourceCode,
                            LastUpdateDate)
                      VALUES 
                            (source.OfficeID,
                            source.OfficeCode,
                            source.PracticeID,
                            source.ParkingInformation,
                            source.OfficeName,
                            source.SourceCode,
                            source.LastUpdateDate )';


    
---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := ' MERGE INTO Base.Office as target USING 
                   ('||select_statement||') as source 
                   ON source.Officeid = target.officeid
                   WHEN MATCHED AND' || update_clause || 'THEN '||update_statement|| '
                   WHEN NOT MATCHED THEN '||insert_statement;
                   
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