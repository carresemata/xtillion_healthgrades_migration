CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_OFFICETOADDRESS()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  

DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- BASE.OfficeToAddress depends on:
--- MDM_TEAM.MST.OFFICE_PROFILE_PROCESSING (RAW.VW_OFFICE_PROFILE)
--- Base.Office
--- Base.AddressType

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
select_statement STRING;
insert_statement STRING;
merge_statement STRING;
status STRING;
    procedure_name varchar(50) default('sp_load_OfficeToAddress');
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
                                    AT.AddressTypeID,
                                    O.OfficeID,
                                    -- addressId
                                    JSON.ADDRESS_SOURCECODE AS SourceCode,
                                    -- isderived
                                    JSON.ADDRESS_LASTUPDATEDATE AS LastUpdateDate
                            FROM
                                Raw.VW_OFFICE_PROFILE AS JSON 
                                LEFT JOIN Base.AddressType AS AT ON AT.AddressTypeCode = JSON.ADDRESS_ADDRESSTYPECODE
                                LEFT JOIN Base.Office AS O ON O.OFFICECODE = JSON.OfficeCode
                                
                            WHERE
                                    JSON.OFFICE_PROFILE IS NOT NULL  
                                    AND OfficeId IS NOT NULL 
                                    AND NULLIF(JSON.ADDRESS_CITY,'') IS NOT NULL 
                                    AND NULLIF(JSON.ADDRESS_STATE,'') IS NOT NULL 
                                    AND NULLIF(JSON.ADDRESS_POSTALCODE,'') IS NOT NULL
                                    AND LENGTH(TRIM(UPPER(JSON.Address_AddressLine1)) || IFNULL(TRIM(UPPER(JSON.Address_AddressLine2)),'') || IFNULL(TRIM(UPPER(JSON.Address_Suite)),'')) > 0
                            QUALIFY row_number() over(partition by OfficeID, JSON.ADDRESS_ADDRESSLINE1, JSON.ADDRESS_ADDRESSLINE2, JSON.ADDRESS_SUITE, JSON.ADDRESS_CITY, JSON.ADDRESS_STATE, JSON.ADDRESS_POSTALCODE order by CREATE_DATE desc) = 1$$;


    -- Insert Statement
insert_statement := ' INSERT  
                            (OfficeToAddressID,
                            AddressTypeID,
                            OfficeID,
                            --AddressID,
                            SourceCode,
                            --IsDerived,
                            LastUpdateDate)
                    VALUES 
                          (UUID_STRING(),
                            source.AddressTypeID,
                            source.OfficeID,
                            --AddressID,
                            source.SourceCode,
                            --IsDerived,
                            source.LastUpdateDate)';



---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------

merge_statement := ' MERGE INTO Base.OfficeToAddress AS target 
USING ('||select_statement||') AS source
ON source.OfficeId = target.OfficeId AND source.AddressTypeId = target.AddressTypeId
WHEN MATCHED THEN DELETE 
WHEN NOT MATCHED THEN'||insert_statement;

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