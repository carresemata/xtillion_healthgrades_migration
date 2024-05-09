CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_ENTITYTOMEDICALTERM() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    

-- Base.EntityToMedicalTerm depends on:
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.MedicalTerm
--- Base.EntityType
--- Base.MedicalTermType

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement_1 STRING;
    delete_statement_1 STRING;
    merge_statement_1 STRING;
    merge_statement_2 STRING;
    select_statement_2 STRING;
    merge_statement_3 STRING;
    merge_statement_4 STRING;
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_EntityToMedicalTerm');
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

select_statement_1 := $$ WITH CTE_Swimlane AS (
    SELECT
        P.ProviderId,
        JSON.ProviderCode,
        P.ProviderId AS EntityId,
        MT.MedicalTermId,
        -- ConditionCode
        -- DecileRank
        -- IsPreview
        JSON.MEDICALPROCEDURE_LASTUPDATEDATE AS LastUpdateDate,
        -- MedicalTermRank
        JSON.MEDICALPROCEDURE_NATIONALRANKINGA AS NationalRankingA,
        JSON.MEDICALPROCEDURE_NATIONALRANKINGB AS NationalRankingB,
        JSON.MEDICALPROCEDURE_PATIENTCOUNT AS PatientCount,
        JSON.MEDICALPROCEDURE_PATIENTCOUNTISFEW AS PatientCountIsFew,
        -- Searchable
        JSON.MEDICALPROCEDURE_SOURCECODE AS SourceCode
        -- SourceSearch
    FROM
        RAW.VW_PROVIDER_PROFILE AS JSON
        LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
        LEFT JOIN Base.EntityToMedicalTerm AS ETMT ON ETMT.EntityId = P.ProviderId
        INNER JOIN Base.MedicalTerm AS MT ON MT.MedicalTermID = ETMT.MedicalTermID
        INNER JOIN Base.MedicalTermType AS MTT ON MTT.MedicalTermTypeId = MT.MedicalTermTypeId AND MTT.MedicalTermTypeCode = 'Condition'
    WHERE 
        PROVIDER_PROFILE IS NOT NULL 
    QUALIFY row_number() over(partition by ProviderId order by CREATE_DATE desc) = 1
),

CTE_DeleteAll AS (
    SELECT DISTINCT
        EntityToMedicalTermId
    FROM Raw.VW_PROVIDER_PROFILE AS Process 
        INNER JOIN Base.Provider AS P ON P.ProviderCode = Process.ProviderCode
        INNER JOIN Base.EntityToMedicalTerm AS ETMT ON ETMT.EntityId = P.ProviderId
        INNER JOIN Base.MedicalTerm AS MT ON MT.MedicalTermID = ETMT.MedicalTermID AND MT.MedicalTermTypeId = (SELECT MedicalTermTypeId FROM Base.MedicalTermType WHERE MedicalTermTypeCode = 'Condition' )
),

CTE_DeleteSome AS (
    SELECT DISTINCT
        EntityToMedicalTermId
    FROM Raw.VW_PROVIDER_PROFILE AS Process
        INNER JOIN Base.Provider AS P ON P.ProviderCode = Process.ProviderCode
        INNER JOIN Base.EntityToMedicalTerm AS ETMT ON ETMT.EntityId = P.ProviderId
        INNER JOIN Base.MedicalTerm AS MT ON MT.MedicalTermID = ETMT.MedicalTermID AND MT.MedicalTermTypeId = (SELECT MedicalTermTypeId FROM Base.MedicalTermType WHERE MedicalTermTypeCode = 'Condition' )
        LEFT JOIN CTE_swimlane AS S ON S.ProviderID = ETMT.EntityId AND S.MedicalTermID = MT.MedicalTermID
    WHERE S.ProviderId IS NULL
),
CTE_Tmp2 AS (
    SELECT
        s.EntityID, 
        s.MedicalTermID, 
        (select EntityTypeID from Base.EntityType where EntityTypeCode = 'PROV') as EntityTypeID,  
	    s.SourceCode, 
        s.LastUpdateDate, 
        s.PatientCount, 
        s.PatientCountIsFew, 
        s.NationalRankingA, 
        s.NationalRankingB
    FROM CTE_Swimlane AS S 
    WHERE NOT EXISTS (
        select 1 
        from Base.EntityToMedicalTerm as ETMT 
            left join CTE_Swimlane AS S ON S.EntityId = ETMT.EntityId
        where ETMT.EntityID=S.ProviderID and
              ETMT.MedicalTermID=s.MedicalTermID) ) $$;


select_statement_2 := $$ WITH CTE_Swimlane AS (
    SELECT
        P.ProviderId,
        JSON.ProviderCode,
        P.ProviderId AS EntityId,
        MT.MedicalTermId,
        JSON.MEDICALPROCEDURE_MEDICALPROCEDURECODE AS ProcedureCode,
        -- DecileRank
        -- IsPreview
        IFNULL(JSON.MEDICALPROCEDURE_LASTUPDATEDATE, SYSDATE()) AS LastUpdateDate,
        -- MedicalTermRank
        JSON.MEDICALPROCEDURE_NATIONALRANKINGA AS NationalRankingA,
        JSON.MEDICALPROCEDURE_NATIONALRANKINGB AS NationalRankingB,
        JSON.MEDICALPROCEDURE_PATIENTCOUNT AS PatientCount,
        JSON.MEDICALPROCEDURE_PATIENTCOUNTISFEW AS PatientCountIsFew,
        -- Searchable
        IFNULL(JSON.MEDICALPROCEDURE_SOURCECODE, 'Profisee') AS SourceCode
        -- SourceSearch
    FROM
        RAW.VW_PROVIDER_PROFILE AS JSON
        LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
        LEFT JOIN Base.EntityToMedicalTerm AS ETMT ON ETMT.EntityId = P.ProviderId
        INNER JOIN Base.MedicalTerm AS MT ON MT.MedicalTermID = ETMT.MedicalTermID
        INNER JOIN Base.MedicalTermType AS MTT ON MTT.MedicalTermTypeId = MT.MedicalTermTypeId AND MTT.MedicalTermTypeCode = 'Procedure'
    WHERE 
        PROVIDER_PROFILE IS NOT NULL 
        AND JSON.MEDICALPROCEDURE_MEDICALPROCEDURECODE IS NOT NULL
    QUALIFY row_number() over(partition by ProviderId, JSON.MEDICALPROCEDURE_MEDICALPROCEDURECODE order by CREATE_DATE desc) = 1
),
CTE_Tmp2 AS (
    SELECT
        s.EntityID, 
        s.MedicalTermID, 
        (select EntityTypeID from Base.EntityType where EntityTypeCode = 'PROV') as EntityTypeID,  
	    s.SourceCode, 
        s.LastUpdateDate, 
        s.PatientCount, 
        s.PatientCountIsFew, 
        s.NationalRankingA, 
        s.NationalRankingB
    FROM CTE_Swimlane AS S 
    WHERE NOT EXISTS (
        select 1 
        from Base.EntityToMedicalTerm as ETMT 
            left join CTE_Swimlane AS S ON S.EntityId = ETMT.EntityId
        where ETMT.EntityID=S.ProviderID and
              ETMT.MedicalTermID=s.MedicalTermID)) $$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

delete_statement_1 := 'DELETE FROM Base.EntityToMedicalTerm 
            WHERE EntityToMedicalTermID IN 
                (' || select_statement_1 || 'SELECT EntityToMedicalTermID FROM CTE_DeleteAll)
            OR EntityToMedicalTermID IN 
                (' || select_statement_1 || 'SELECT EntityToMedicalTermID FROM CTE_DeleteSome)';


merge_statement_1 := ' MERGE INTO Base.EntityToMedicalTerm as target USING 
                   ('||select_statement_1 ||' SELECT * FROM CTE_swimlane ) as source 
                   ON target.EntityID = source.EntityId AND target.MedicalTermID = source.MedicalTermID
                   WHEN MATCHED AND 
                                    IFNULL(target.PatientCountIsFew,0) <> IFNULL(source.PatientCountIsFew,0) 
                                    OR IFNULL(target.NationalRankingA,0) <> IFNULL(source.NationalRankingA,0) 
                                    OR IFNULL(target.PatientCount,0) <> IFNULL(source.PatientCount,0) 
                                    OR IFNULL(target.NationalRankingB,0) <> IFNULL(source.NationalRankingB,0)
                   THEN 
                    UPDATE 
                            SET 
                                target.PatientCountIsFew = source.PatientCountIsFew, 
                                target.LastUpdateDate = source.LastUpdateDate, 
                                target.NationalRankingA = source.NationalRankingA, 
                                target.PatientCount = source.PatientCount, 
                                target.NationalRankingB = source.NationalRankingB, 
                                target.SourceCode = source.SourceCode';

merge_statement_2 := ' MERGE INTO Base.EntityToMedicalTerm as target USING 
                   ('||select_statement_1 ||' SELECT * FROM CTE_Tmp2) as source 
                   ON target.EntityID = source.EntityID AND target.MedicalTermID = source.MedicalTermID
                   WHEN NOT MATCHED THEN 
                    INSERT (EntityID, 
                            MedicalTermID, 
                            EntityTypeID, 
                            SourceCode, 
                            LastUpdateDate, 
                            PatientCount, 
                            PatientCountIsFew,
                            NationalRankingA, 
                            NationalRankingB)
                    VALUES (source.EntityID, 
                            source.MedicalTermID, 
                            source.EntityTypeID,  
                            source.SourceCode,
                            source.LastUpdateDate, 
                            source.PatientCount,
                            source.PatientCountIsFew,  
                            source.NationalRankingA, 
                            source.NationalRankingB)';
                                


merge_statement_3 := ' MERGE INTO Base.EntityToMedicalTerm as target USING 
                   ('||select_statement_2 ||' SELECT * FROM CTE_swimlane )   as source 
                   ON target.EntityID = source.EntityId AND target.MedicalTermID = source.MedicalTermID
                   WHEN MATCHED AND 
                                    IFNULL(target.PatientCountIsFew,0) <> IFNULL(source.PatientCountIsFew,0) 
    OR IFNULL(target.NationalRankingA,0) <> IFNULL(source.NationalRankingA,0)
    OR IFNULL(target.PatientCount,0) <> IFNULL(source.PatientCount,0)
    OR IFNULL(target.NationalRankingB,0) <> IFNULL(source.NationalRankingB,0)
                   THEN UPDATE SET 
                            target.PatientCountIsFew = source.PatientCountIsFew,
                            target.LastUpdateDate = source.LastUpdateDate,
                            target.NationalRankingA = source.NationalRankingA,
                            target.PatientCount = source.PatientCount,
                            target.NationalRankingB = source.NationalRankingB,
                            target.SourceCode = source.SourceCode';

merge_statement_4 := ' MERGE INTO Base.EntityToMedicalTerm as target USING 
                   ('||select_statement_2 ||' SELECT * FROM CTE_Tmp2) as source 
                   ON target.EntityID = source.EntityID AND target.MedicalTermID = source.MedicalTermID
                   WHEN NOT MATCHED THEN 
                    INSERT (EntityID, 
                            MedicalTermID, 
                            EntityTypeID,  
                            SourceCode,
                            LastUpdateDate, 
                            PatientCount,
                            PatientCountIsFew,  
                            NationalRankingA, 
                            NationalRankingB)
                    VALUES (source.EntityID, 
                            source.MedicalTermID, 
                            source.EntityTypeID,  
                            source.SourceCode,
                            source.LastUpdateDate, 
                            source.PatientCount,
                            source.PatientCountIsFew,  
                            source.NationalRankingA, 
                            source.NationalRankingB)';
                            
                 
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE delete_statement_1 ;
EXECUTE IMMEDIATE merge_statement_1 ;
EXECUTE IMMEDIATE merge_statement_2 ;
EXECUTE IMMEDIATE merge_statement_3 ;
EXECUTE IMMEDIATE merge_statement_4 ;

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