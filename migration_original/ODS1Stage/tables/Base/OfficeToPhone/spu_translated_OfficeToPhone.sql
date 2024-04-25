CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_OFFICETOPHONE()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  

DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- BASE.OfficeToPhone depends on:
--- Raw.VW_OFFICE_PROFILE
--- Base.Office
--- Base.PhoneType

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
    select_statement := $$  SELECT DISTINCT
                            PT.PhoneTypeID,
                            -- PhoneId
                            O.OfficeId,
                            IFNULL(JSON.PHONE_SOURCECODE , 'Reltio') AS SourceCode,
                            IFNULL(JSON.PHONE_LASTUPDATEDATE , CURRENT_TIMESTAMP()) AS LastUpdateDate,
                            1 AS PhoneRank
                        FROM RAW.VW_OFFICE_PROFILE AS JSON
                            LEFT JOIN Base.Office AS O ON O.OfficeCode = JSON.OfficeCode
                            LEFT JOIN Base.PhoneType AS PT ON PT.PHONETYPECODE = JSON.PHONE_PHONETYPECODE
                        WHERE
                            OFFICE_PROFILE IS NOT NULL
                            AND OFFICEID IS NOT NULL 
                            AND PhonetypeId IS NOT NULL
                        QUALIFY row_number() over(partition by OfficeID, JSON.PHONE_PHONENUMBER, PhoneTypeID order by CREATE_DATE desc) = 1 $$;


    -- Insert Statement
insert_statement := ' INSERT  
                            (OfficeToPhoneID,
                            PhoneTypeID,
                            --PhoneID,
                            OfficeID,
                            SourceCode,
                            LastUpdateDate,
                            PhoneRank)
                    VALUES 
                          (UUID_STRING(),
                            source.PhoneTypeID,
                            --source.PhoneID,
                            source.OfficeID,
                            source.SourceCode,
                            source.LastUpdateDate,
                            source.PhoneRank)';



---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------

merge_statement := ' MERGE INTO Base.OfficeToPhone AS target 
USING ('||select_statement||') AS source
ON source.OfficeId = target.OfficeId AND source.PhoneTypeId = target.PhoneTypeId
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
RETURN status;

EXCEPTION
WHEN OTHER THEN
status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
RETURN status;

END;