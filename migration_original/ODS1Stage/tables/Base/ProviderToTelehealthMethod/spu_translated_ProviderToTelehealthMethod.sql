CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTOTELEHEALTHMETHOD()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderToTeleHealthMethod depends on: 
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.TelehealthMethod
--- Base.TeleHealthMethodType

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
select_statement := $$ SELECT DISTINCT
                            P.ProviderId,
                            TM.TelehealthMethodId, 
                            IFNULL(JSON.Telehealth_SourceCode, 'Profisee') AS SourceCode,
                            CASE WHEN IFNULL(JSON.TeleHealth_HasTelehealth, 'N') IN ('yes', 'true', '1', 'Y', 'T') THEN 'TRUE' ELSE 'FALSE' END AS HasTeleHealth,
                            JSON.Telehealth_LastUpdateDate AS LastUpdatedDate
                        FROM
                            RAW.VW_PROVIDER_PROFILE AS JSON
                            LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                            LEFT JOIN Base.TelehealthMethodType AS TMT ON TMT.MethodTypeCode = JSON.Telehealth_TelehealthMethodCode
                            LEFT JOIN Base.TeleHealthMethod AS TM ON TM.TelehealthMethodTypeID = TMT.TelehealthMethodTypeId
                        WHERE
                            PROVIDER_PROFILE IS NOT NULL AND
                            HasTeleHealth = 'TRUE' AND
                            TelehealthMethodId IS NOT NULL$$;




--- Insert Statement
insert_statement := ' INSERT  
                            (ProviderToTelehealthMethodId,
                            ProviderId,
                            TelehealthMethodId,
                            SourceCode,
                            LastUpdatedDate)
                      VALUES 
                            (UUID_STRING(),
                            source.ProviderId,
                            source.TelehealthMethodId,
                            source.SourceCode,
                            source.LastUpdatedDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.Providertotelehealthmethod as target USING 
                   ('||select_statement||') as source 
                   ON source.Providerid = target.Providerid
                   WHEN MATCHED THEN DELETE
                   WHEN NOT MATCHED THEN '||insert_statement;
                   
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