CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CLIENTFEATURETOCLIENTFEATUREVALUE() -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

--- BASE.CLIENTFEATURETOCLIENTFEATUREVALUE depends on:
--- BASE.CLIENTFEATURE
--- BASE.CLIENTFEATUREVALUE
--- MDM_TEAM.MST.CUSTOMER_PRODUCT_PROFILE_PROCESSING  (BASE.vw_SWIMLANE_BASE_CLIENT)

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_ClientFeatureToClientFeatureValue');
    execution_start DATETIME default getdate();

   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   

BEGIN

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
-- If no conditionals:
select_statement := $$with cte_swimlane as (
    select
        *,
        rank() over(
            partition by customerproductcode
            order by
                LastUpdateDate
        ) as rowrank,
    from
        base.vw_swimlane_base_client
),
cte_tmp_features as (
    select
        CustomerProductCode,
        'FCBFN' as ClientFeatureCode,
        FeatureFCBFN as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCBFN = 'FVNO'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCBFN' as ClientFeatureCode,
        FeatureFCBFN as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCBFN = 'FVYES'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCCCP' as ClientFeatureCode,
        FeatureFCCCP_FVCLT as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCCCP_FVCLT = 'FVCLT'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCCCP' as ClientFeatureCode,
        FeatureFCCCP_FVFAC as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCCCP_FVFAC = 'FVFAC'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCCCP' as ClientFeatureCode,
        FeatureFCCCP_FVOFFICE as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCCCP_FVOFFICE = 'FVOFFICE'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCDTP' as ClientFeatureCode,
        FeatureFCDTP as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCDTP = 'FVPPN'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCDTP' as ClientFeatureCode,
        FeatureFCDTP as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCDTP = 'FVPTN'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCMWC' as ClientFeatureCode,
        FeatureFCMWC as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCMWC = 'FVNO'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCMWC' as ClientFeatureCode,
        FeatureFCMWC as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCMWC = 'FVYES'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCNPA' as ClientFeatureCode,
        FeatureFCNPA as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCNPA = 'FVYES'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCNPA' as ClientFeatureCode,
        FeatureFCNPA as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCNPA = 'FVNO'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCBRL' as ClientFeatureCode,
        FeatureFCBRL as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCBRL = 'FVCLT'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCBRL' as ClientFeatureCode,
        FeatureFCBRL as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCBRL = 'FVFAC'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCBRL' as ClientFeatureCode,
        FeatureFCBRL as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCBRL = 'FVOFFICE'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCEPR' as ClientFeatureCode,
        FeatureFCEPR as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCEPR = 'FVYES'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCEPR' as ClientFeatureCode,
        FeatureFCEPR as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCEPR = 'FVNO'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCOOACP' as ClientFeatureCode,
        FeatureFCOOACP as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCOOACP = 'FVYES'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCOOACP' as ClientFeatureCode,
        FeatureFCOOACP as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCOOACP = 'FVNO'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCLOT' as ClientFeatureCode,
        FeatureFCLOT as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCLOT = 'FVCUS'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCMAR' as ClientFeatureCode,
        FeatureFCMAR as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCMAR = 'FVFAC'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCDOA' as ClientFeatureCode,
        FeatureFCDOA as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCDOA = 'FVNO'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCDOA' as ClientFeatureCode,
        FeatureFCDOA as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCDOA = 'FVYES'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCDOS' as ClientFeatureCode,
        FeatureFCDOS_FVFAX as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCDOS_FVFAX = 'FVFAX'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCDOS' as ClientFeatureCode,
        FeatureFCDOS_FVMMPEML as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCDOS_FVMMPEML = 'FVMMPEML'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCEOARD' as ClientFeatureCode,
        FeatureFCEOARD as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCEOARD = 'FVAQSTD'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCOBT' as ClientFeatureCode,
        FeatureFCOBT as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCOBT = 'FVRAPT'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCODC' as ClientFeatureCode,
        FeatureFCODC_FVDFC as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCODC_FVDFC = 'FVDFC'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCODC' as ClientFeatureCode,
        FeatureFCODC_FVDPR as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCODC_FVDPR = 'FVDPR'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCODC' as ClientFeatureCode,
        FeatureFCODC_FVMT as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCODC_FVMT = 'FVMT'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCODC' as ClientFeatureCode,
        FeatureFCODC_FVPSR as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCODC_FVPSR = 'FVPSR'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCOAS' as ClientFeatureCode,
        FeatureFCOAS as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCOAS = 'FVYES'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCSPC' as ClientFeatureCode,
        FeatureFCSPC as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCSPC = 'FVABR1'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCPNI' as ClientFeatureCode,
        FeatureFCPNI as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCPNI = 'FVYES'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCPQM' as ClientFeatureCode,
        FeatureFCPQM as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCPQM = 'FVNO'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCPQM' as ClientFeatureCode,
        FeatureFCPQM as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCPQM = 'FVYES'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVCPOFFICE as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCREL_FVCPOFFICE = 'FVCPOFFICE'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVCPTOCC as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCREL_FVCPTOCC = 'FVCPTOCC'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVCPTOFAC as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCREL_FVCPTOFAC = 'FVCPTOFAC'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVCPTOPRAC as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCREL_FVCPTOPRAC = 'FVCPTOPRAC'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVCPTOPROV as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCREL_FVCPTOPROV = 'FVCPTOPROV'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVPRACOFF as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCREL_FVPRACOFF = 'FVPRACOFF'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVPROVFAC as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCREL_FVPROVFAC = 'FVPROVFAC'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVPROVOFF as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCREL_FVPROVOFF = 'FVPROVOFF'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCOOPSR' as ClientFeatureCode,
        FeatureFCOOPSR as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCOOPSR = 'FVNO'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCOOPSR' as ClientFeatureCode,
        FeatureFCOOPSR as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCOOPSR = 'FVYES'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCOOMT' as ClientFeatureCode,
        FeatureFCOOMT as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCOOMT = 'FVNO'
        and RowRank = 1
    UNION ALL
    select
        CustomerProductCode,
        'FCOOMT' as ClientFeatureCode,
        FeatureFCOOMT as ClientFeatureValueCode
    from
        cte_swimlane
    where
        FeatureFCOOMT = 'FVYES'
        and RowRank = 1
)
SELECT DISTINCT 
            UUID_STRING() as ClientFeatureToClientFeatureValueID,
            ClientFeatureId,
            ClientFeatureValueId,
            'Reltio' as SourceCode,
            CURRENT_TIMESTAMP() as LastUpdateDate
        FROM
            cte_tmp_features AS T
            INNER JOIN Base.ClientFeature AS CF ON CF.ClientFeatureCode = T.ClientFeatureCode
            INNER JOIN Base.ClientFeatureValue AS CFV ON CFV.ClientFeatureValueCode = T.ClientFeatureValueCode
$$;

--- Insert Statement
insert_statement := '  INSERT (ClientFeatureToClientFeatureValueID, ClientFeatureID, ClientFeatureValueID, SourceCode, LastUpdateDate)
    VALUES (Source.ClientFeatureToClientFeatureValueID, Source.ClientFeatureID, Source.ClientFeatureValueID, Source.SourceCode, Source.LastUpdateDate);';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO BASE.CLIENTFEATURETOCLIENTFEATUREVALUE as target USING 
                   ('||select_statement||') AS Source
                    ON Target.ClientFeatureID = Source.ClientFeatureID AND Target.ClientFeatureValueID = Source.ClientFeatureValueID
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