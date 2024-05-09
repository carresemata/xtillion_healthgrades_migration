CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERMALPRACTICE()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  

DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- BASE.ProviderMalpractice depends on:
--- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (RAW.VW_PROVIDER_PROFILE)
--- Base.Provider
--- Base.MalpracticeClaimType

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------
select_statement STRING;
insert_statement STRING;
merge_statement STRING;
status STRING;
    procedure_name varchar(50) default('sp_load_ProviderMalpractice');
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
select_statement := $$  WITH CTE_Swimlane AS (SELECT
    P.ProviderId,
    --PL.ProviderLicenseId,
    M.MalpracticeClaimTypeID,
    JSON.ProviderCode,
    JSON.MALPRACTICE_MALPRACTICECLAIMTYPECODE AS MalpracticeClaimTypeCode,
    JSON.MALPRACTICE_CLAIMNUMBER AS ClaimNumber,
    JSON.MALPRACTICE_CLAIMDATE AS ClaimDate,
    JSON.MALPRACTICE_CLAIMYEAR AS ClaimYear,
    TO_NUMBER(JSON.MALPRACTICE_CLAIMAMOUNT) AS ClaimAmount,
    JSON.MALPRACTICE_CLAIMSTATE AS ClaimState,
    JSON.MALPRACTICE_MALPRACTICECLAIMRANGE AS MalpracticeClaimRange,
    JSON.MALPRACTICE_COMPLAINT AS Complaint,
    JSON.MALPRACTICE_INCIDENTDATE AS IncidentDate,
    JSON.MALPRACTICE_CLOSEDDATE AS ClosedDate,
    JSON.MALPRACTICE_REPORTDATE AS ReportDate,
    JSON.MALPRACTICE_SOURCECODE AS SourceCode,
    JSON.MALPRACTICE_LICENSENUMBER AS LicenseNumber,
    JSON.MALPRACTICE_LASTUPDATEDATE AS LastUpdateDate,
    row_number() over(partition by P.ProviderId, JSON.MALPRACTICE_MALPRACTICECLAIMTYPECODE, JSON.MALPRACTICE_CLAIMDATE, JSON.MALPRACTICE_CLAIMYEAR, JSON.MALPRACTICE_CLAIMSTATE, JSON.MALPRACTICE_LICENSENUMBER, JSON.MALPRACTICE_MALPRACTICECLAIMRANGE order by CREATE_DATE desc, TO_NUMBER(JSON.MALPRACTICE_CLAIMAMOUNT) desc) as RowRank, 
	row_number()over(order by P.ProviderID) as RN1
FROM
    RAW.VW_PROVIDER_PROFILE AS JSON
    LEFT JOIN Base.Provider AS P ON JSON.ProviderCode = P.ProviderCode
    --LEFT JOIN Base.ProviderLicense AS PL ON PL.Providerid = P.ProviderId AND PL.licensenumber = JSON.MALPRACTICE_LICENSENUMBER
    LEFT JOIN Base.MalpracticeClaimType AS M ON M.MALPRACTICECLAIMTYPECODE = JSON.MALPRACTICE_MALPRACTICECLAIMTYPECODE
WHERE
    PROVIDER_PROFILE IS NOT NULL
    AND JSON.MALPRACTICE_CLAIMAMOUNT IS NOT NULL),
    
CTE_BadMalpracticeClaimTypeCode AS (
    SELECT DISTINCT 
        P.ProviderCode, 
        'Bad Malpractice Claim Type Code value of ' || COALESCE(S.MalpracticeClaimTypeCode,'NULL') AS ProblemType, 
        RN1
    FROM CTE_swimlane S
    JOIN Base.Provider P ON P.ProviderId = S.ProviderId
    LEFT JOIN Base.MalpracticeClaimType MCT ON MCT.MalpracticeClaimTypeCode = S.MalpracticeClaimTypeCode
    WHERE MCT.MalpracticeClaimTypeId IS NULL
    
            UNION ALL
    
    SELECT DISTINCT 
        P.ProviderCode, 
        'Bad Malpractice Claim Type Code value of ' || COALESCE(S.MalpracticeClaimTypeCode,'NULL') AS ProblemType, 
        RN1
    FROM CTE_swimlane S
    JOIN Base.Provider P ON P.ProviderId = S.ProviderId
    LEFT JOIN Base.MalpracticeClaimType MCT ON MCT.MalpracticeClaimTypeID = S.MalpracticeClaimTypeID
    WHERE MCT.MalpracticeClaimTypeId IS NULL	
    
            UNION ALL
    
    SELECT 
        S.ProviderCode, 
        'Bad IncidentDate value: ' || TO_VARCHAR(IncidentDate), 
        RN1
    FROM CTE_swimlane S
    WHERE TRY_CAST(IncidentDate AS DATE) IS NULL AND IncidentDate IS NOT NULL
    
            UNION ALL
    
    SELECT 
        S.ProviderCode, 
        'Bad ReportDate value: ' || TO_VARCHAR(ReportDate), 
        RN1
    FROM CTE_swimlane S
    WHERE TRY_CAST(ReportDate AS DATE) IS NULL AND ReportDate IS NOT NULL
    
            UNION ALL
    
    SELECT 
        S.ProviderCode, 
        'Bad ClaimDate value: ' || TO_VARCHAR(ClaimDate), 
        RN1
    FROM CTE_swimlane S
    WHERE TRY_CAST(ClaimDate AS DATE) IS NULL AND ClaimDate IS NOT NULL
    
            UNION ALL
    
    SELECT 
        S.ProviderCode, 
        'Bad ClosedDate value: ' || TO_VARCHAR(ClosedDate), 
        RN1
    FROM CTE_swimlane S
    WHERE TRY_CAST(ClosedDate AS DATE) IS NULL AND ClosedDate IS NOT NULL
    
            UNION ALL
    
    SELECT 
        S.ProviderCode, 
        'Bad ClaimYear value: ' || TO_VARCHAR(ClaimYear),
        RN1
    FROM CTE_swimlane S
    WHERE TRY_CAST(ClaimYear AS INT) IS NULL AND ClaimYear IS NOT NULL
),
CTE_KEEP AS (
    SELECT 
        S.ProviderId,
        --S.ProviderLicenseId,
        S.MalpracticeClaimTypeID,
        S.ProviderCode,
        S.MalpracticeClaimTypeCode,
        S.ClaimNumber,
        S.ClaimDate,
        S.ClaimYear,
        S.ClaimAmount,
        S.ClaimState,
        S.MalpracticeClaimRange,
        S.Complaint,
        S.IncidentDate,
        S.ClosedDate,
        S.ReportDate,
        S.SourceCode,
        S.LicenseNumber,
        S.LastUpdateDate,
        S.RowRank, 
        S.RN1
    FROM CTE_swimlane AS S
    WHERE (
        (
            COALESCE(TRY_CAST(S.IncidentDate AS DATE), '1900-01-01'::DATE) > DATEADD('YEAR', -5, CURRENT_DATE()) OR 
            COALESCE(TRY_CAST(S.ReportDate AS DATE), '1900-01-01'::DATE) > DATEADD('YEAR', -5, CURRENT_DATE()) OR 
            COALESCE(TRY_CAST(S.ClaimDate AS DATE), '1900-01-01'::DATE) > DATEADD('YEAR', -5, CURRENT_DATE()) OR 
            COALESCE(TRY_CAST(S.ClosedDate AS DATE), '1900-01-01'::DATE) > DATEADD('YEAR', -5, CURRENT_DATE())
        )
        OR (
            S.IncidentDate IS NULL AND 
            S.ReportDate IS NULL AND 
            S.ClaimDate IS NULL AND 
            S.ClosedDate IS NULL AND 
            S.ClaimYear IS NOT NULL AND 
            TRY_CAST(S.ClaimYear AS INT) > EXTRACT(YEAR FROM DATEADD('YEAR', -5, CURRENT_DATE()))))), 
CTE_Delete1 AS (
    SELECT 
        ProviderId,
        --ProviderLicenseId,
        MalpracticeClaimTypeID,
        ProviderCode,
        MalpracticeClaimTypeCode,
        ClaimNumber,
        ClaimDate,
        ClaimYear,
        ClaimAmount,
        ClaimState,
        MalpracticeClaimRange,
        Complaint,
        IncidentDate,
        ClosedDate,
        ReportDate,
        SourceCode,
        LicenseNumber,
        LastUpdateDate,
        RowRank,
        RN1
    FROM CTE_Swimlane
    WHERE RN1 IN (SELECT RN1 FROM CTE_KEEP))
SELECT 
    ProviderId,
    --ProviderLicenseId,
    MalpracticeClaimTypeID,
    ProviderCode,
    MalpracticeClaimTypeCode,
    ClaimNumber,
    ClaimDate,
    ClaimYear,
    ClaimAmount,
    ClaimState,
    MalpracticeClaimRange,
    Complaint,
    IncidentDate,
    ClosedDate,
    ReportDate,
    SourceCode,
    LicenseNumber,
    LastUpdateDate,
    RowRank,
    RN1
FROM CTE_Delete1 AS D
WHERE D.RN1 NOT IN (SELECT RN1 FROM CTE_BadMalpracticeClaimTypeCode) $$;


    -- Insert Statement
insert_statement := ' INSERT  
                            (ProviderMalpracticeID,
                            ProviderID,
                            --ProviderLicenseID,
                            MalpracticeClaimTypeID,
                            ClaimNumber,
                            ClaimDate,
                            ClaimYear,
                            ClaimAmount,
                            ClaimState,
                            MalpracticeClaimRange,
                            Complaint,
                            IncidentDate,
                            ClosedDate,
                            ReportDate,
                            SourceCode,
                            LicenseNumber,
                            LastUpdateDate)
                    VALUES 
                          ( UUID_STRING(),
                            source.ProviderID,
                            --source.ProviderLicenseID,
                            source.MalpracticeClaimTypeID,
                            source.ClaimNumber,
                            source.ClaimDate,
                            source.ClaimYear,
                            source.ClaimAmount,
                            source.ClaimState,
                            source.MalpracticeClaimRange,
                            source.Complaint,
                            source.IncidentDate,
                            source.ClosedDate,
                            source.ReportDate,
                            source.SourceCode,
                            source.LicenseNumber,
                            source.LastUpdateDate)';



---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------

merge_statement := ' MERGE INTO Base.ProviderMalpractice AS target 
USING ('||select_statement||') AS source
ON source.ProviderID = target.ProviderID AND source.MalpracticeClaimTypeID = target.MalpracticeClaimTypeID --AND source.ProviderLicenseId = target.ProviderLicenseId
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