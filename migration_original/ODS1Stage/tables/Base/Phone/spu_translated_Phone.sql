CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PHONE()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.Phone depends on:
--- MDM_TEAM.MST.CUSTOMER_PRODUCT_PROFILE_PROCESSING (RAW.VW_CUSTOMER_PRODUCT_PROFILE and Base.vw_Swimlane_base_client)
--- MDM_TEAM.MST.OFFICE_PROFILE_PROCESSING (RAW.VW_OFFICE_PROFILE)
--- MDM_TEAM.MST.FACILITY_PROFILE_PROCESSING (RAW.VW_FACILITY_PROFILE)
--- Base.Facility
--- Base.ClientToProduct
--- Base.SyndicationPartner
--- Base.Office
--- Base.PhoneType

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement_1 STRING; 
    merge_statement_1 STRING; 
    select_statement_2 STRING; 
    merge_statement_2 STRING;
    select_statement_3 STRING; 
    merge_statement_3 STRING;
    status STRING; -- Status monitoring
    procedure_name varchar(50) default('sp_load_Phone');
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
select_statement_1 := $$ WITH cte_swimlane AS (
    SELECT
        *
    from
        base.vw_swimlane_base_client qualify dense_rank() over(
            partition by customerproductcode
            order by
                LastUpdateDate
        ) = 1
),

CTE_Swimlane_Phones AS (
    SELECT
        S.CUSTOMERPRODUCTCODE AS ClientToProductcode,
        S.ProductCode,
        JSON.DISPLAYPARTNER_REFDISPLAYPARTNERCODE AS DisplayPartnerCode,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTDES END AS PhonePTDES,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTDESM END AS PhonePTDESM,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTDEST END AS PhonePTDEST,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTEMP END AS PhonePTEMP,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTEMPM END AS PhonePTEMPM,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTEMPT END AS PhonePTEMPT,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTHOS END AS PhonePTHOS,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTHOSM END AS PhonePTHOSM,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTHOST END AS PhonePTHOST,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTMTR END AS PhonePTMTR,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTMTRT END AS PhonePTMTRT,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTMTRM END AS PhonePTMTRM,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTMWC END AS PhonePTMWC,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTMWCT END AS PhonePTMWCT,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTMWCM END AS PhonePTMWCM,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTPSR END AS PhonePTPSR,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTPSRD END AS PhonePTPSRD,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTPSRM END AS PhonePTPSRM,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTPSRT END AS PhonePTPSRT,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTDPPEP END AS PhonePTDPPEP,
        CASE WHEN S.ProductCode='MAP' THEN NULL ELSE JSON.DISPLAYPARTNER_PHONEPTDPPNP END AS PhonePTDPPNP 
    FROM CTE_swimlane AS S
        LEFT JOIN RAW.VW_CUSTOMER_PRODUCT_PROFILE AS JSON ON JSON.CustomerProductCode = S.CustomerProductCode
        INNER JOIN Base.SyndicationPartner As SP ON SP.SyndicationPartnerCode = JSON.DISPLAYPARTNER_REFDISPLAYPARTNERCODE
),
cte_tmp_phones as (
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTDES' as PhoneTypeCode,
            PhonePTDES as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTDES is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTDESM' as PhoneTypeCode,
            PhonePTDESM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTDESM is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTDEST' as PhoneTypeCode,
            PhonePTDEST as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTDEST is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTEMP' as PhoneTypeCode,
            PhonePTEMP as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTEMP is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTEMPM' as PhoneTypeCode,
            PhonePTEMPM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTEMPM is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTEMPT' as PhoneTypeCode,
            PhonePTEMPT as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTEMPT is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHOS' as PhoneTypeCode,
            PhonePTHOS as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTHOS is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHOSM' as PhoneTypeCode,
            PhonePTHOSM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTHOSM is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHOST' as PhoneTypeCode,
            PhonePTHOST as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTHOST is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTMTR' as PhoneTypeCode,
            PhonePTMTR as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTMTR is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTMTRT' as PhoneTypeCode,
            PhonePTMTRT as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTMTRT is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTMTRM' as PhoneTypeCode,
            PhonePTMTRM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTMTRM is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTMWC' as PhoneTypeCode,
            PhonePTMWC as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTMWC is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTMWCT' as PhoneTypeCode,
            PhonePTMWCT as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTMWCT is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTMWCM' as PhoneTypeCode,
            PhonePTMWCM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTMWCM is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTPSR' as PhoneTypeCode,
            PhonePTPSR as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTPSR is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTPSRD' as PhoneTypeCode,
            PhonePTPSRD as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTPSRD is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTPSRM' as PhoneTypeCode,
            PhonePTPSRM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTPSRM is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTPSRT' as PhoneTypeCode,
            PhonePTPSRT as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTPSRT is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTDPPEP' as PhoneTypeCode,
            PhonePTDPPEP as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTDPPEP is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTDPPNP' as PhoneTypeCode,
            PhonePTDPPNP as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTDPPNP is not null
    ),
CTE_NotExists AS (
    SELECT 1 
    FROM Base.Phone as p 
        LEFT JOIN CTE_Tmp_Phones As cte ON cte.PhoneNumber = p.PhoneNumber
    WHERE cte.DisplayPartnerCode = 'HG'
)
SELECT 
    UUID_STRING() AS PhoneId,
    PhoneNumber
FROM CTE_TMP_PHONES
WHERE NOT EXISTS (SELECT * FROM CTE_NOTEXISTS) $$;



select_statement_2 := $$ SELECT DISTINCT
                            UUID_STRING() AS PhoneId,
                            O.OfficeId,
                            JSON.PHONE_PHONETYPECODE As PhoneTypecode,
                            CASE  WHEN JSON.PHONE_PHONENUMBER NOT LIKE '%ext.%' THEN JSON.PHONE_PHONENUMBER ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(JSON.PHONE_PHONENUMBER, 'ext', 'x'), '(', ''), ')', ''), '.', ''), '-', ''), ' ', '') END AS PhoneNumberReformat,
                            CASE WHEN LENGTH(PhoneNumberReformat) > 15 THEN SUBSTRING(PhoneNumberReformat, 1, POSITION('x' IN PhoneNumberReformat)) ELSE PhoneNumberReformat END AS PhoneNumber,
                            -- PhoneNumberCustomerProduct  
                            -- PhoneRank
                            IFNULL(JSON.PHONE_SOURCECODE, 'Profisee') As SourceCode,
                            JSON.PHONE_LASTUPDATEDATE AS LastUpdateDate,
                            PT.PhoneTypeID,
                            row_number() over(partition by O.OfficeID, JSON.PHONE_PHONENUMBER, pt.PhoneTypeID order by JSON.PHONE_LASTUPDATEDATE desc) as PhoneRowRank
                        FROM RAW.VW_OFFICE_PROFILE AS JSON
                            LEFT JOIN Base.Office AS O ON O.OfficeCode = JSON.OfficeCode
                            LEFT JOIN Base.PhoneType AS PT ON PT.PHONETYPECODE = JSON.PHONE_PHONETYPECODE
                        WHERE
                            OFFICE_PROFILE IS NOT NULL
                            AND OFFICEID IS NOT NULL 
                            AND PhonetypeId IS NOT NULL
                        QUALIFY row_number() over(partition by OfficeID, JSON.PHONE_PHONENUMBER, PhoneTypeID order by CREATE_DATE desc) = 1 $$;


                        
select_statement_3 := $$ WITH CTE_Swimlane AS (
    SELECT DISTINCT
        F.FacilityId,
        JSON.FacilityCode,
        CP.ClientToProductId,
        JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE AS ClientToProductCode,
        -- ReltioEntityId
        PARSE_JSON(JSON.CUSTOMERPRODUCT_DISPLAYPARTNER) AS DisplayPartnerJSON,
        -- FeatureFCCIURL
        JSON.CUSTOMERPRODUCT_FEATUREFCCLURL AS FeatureFCCLURL,
        JSON.CUSTOMERPRODUCT_FEATUREFCCLLOGO AS FeatuerFCCLLOGO,
        JSON.CUSTOMERPRODUCT_FEATUREFCFLOGO AS FeatureFCFLogo,
        JSON.CUSTOMERPRODUCT_FEATUREFCFURL AS FeatureFCFURL,
        row_number() over(partition by FacilityID order by CREATE_DATE desc) as RowRank,
        IFNULL(JSON.CUSTOMERPRODUCT_SOURCECODE, 'Profisee') AS SourceCode,
        IFNULL(JSON.CUSTOMERPRODUCT_LASTUPDATEDATE, SYSDATE()) AS LastUpdateDate
    FROM RAW.VW_FACILITY_PROFILE AS JSON
        JOIN Base.Facility AS F ON F.FacilityCode = JSON.FacilityCode
        JOIN Base.ClientToProduct as cp on cp.ClientToProductCode = JSON.CUSTOMERPRODUCT_CUSTOMERPRODUCTCODE
    WHERE FACILITY_PROFILE IS NOT NULL
          AND JSON.FACILITYCODE IS NOT NULL
),
CTE_Swimlane_Phones AS (
    SELECT
        S.FacilityCode,
        S.ClientToProductCode,
        S.RowRank,
        S.LastUpdateDate,
        TO_VARCHAR(S.DisplayPartnerJSON:DISPLAY_PARTNER_CODE) AS DisplayPartnerCode,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFDS) AS PhonePTFDS,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFDSM) AS PhonePTFDSM,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFDST) AS PhonePTFDST,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFMC) AS PhonePTFMC,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFMCM) AS PhonePTFMCM,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFMCT) AS PhonePTFMCT,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFMT) AS PhonePTFMT,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFMTM) AS PhonePTFMTM,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFMTT) AS PhonePTFMTT,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFSR) AS PhonePTFSR,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFSRD) AS PhonePTFSRD,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFSRDM) AS PhonePTFSRDM,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFSRM) AS PhonePTFSRM,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFSRT) AS PhonePTFSRT,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTHFS) AS PhonePTHFS,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTHFSM) AS PhonePTHFSM,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTHFST) AS PhonePTHFST,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTUFS) AS PhonePTUFS,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFDPPEP) AS PhonePTFDPPEP,
        TO_VARCHAR(S.DisplayPartnerJSON:PHONE_PTFDPPNP) AS PhonePTFDPPNP
    FROM CTE_Swimlane AS S
        INNER JOIN Base.SyndicationPartner AS SP ON SP.SyndicationPartnerCode = S.DisplayPartnerJSON:DISPLAY_PARTNER_CODE
),

cte_tmp_phones as (
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDS' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFDS as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFDS is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDSM' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFDSM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFDSM is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDST' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFDST as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFDST is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMC' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFMC as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFMC is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMCM' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFMCM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFMCM is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMCT' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFMCT as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFMCT is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMT' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFMT as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFMT is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMTM' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFMTM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFMTM is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMTT' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFMTT as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFMTT is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSR' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFSR as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFSR is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRD' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFSRD as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFSRD is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRDM' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFSRDM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFSRDM is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRM' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFSRM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFSRM is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRT' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFSRT as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFSRT is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFS' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTHFS as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTHFS is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFSM' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTHFSM as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTHFSM is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFST' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTHFST as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTHFST is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTUFS' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTUFS as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTUFS is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDPPEP' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFDPPEP as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFDPPEP is not null
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDPPNP' as PhoneTypeCode,
            LastUpdateDate,
            PhonePTFDPPNP as PhoneNumber
        from
            cte_swimlane_phones
        where
            PhonePTFDPPNP is not null
    ),
CTE_NotExists AS (
    SELECT 1 
    FROM Base.Phone as p 
        LEFT JOIN CTE_Tmp_Phones As cte ON cte.PhoneNumber = p.PhoneNumber
    WHERE cte.DisplayPartnerCode = 'HG'
)
SELECT DISTINCT
    UUID_STRING() AS PhoneId,
    PhoneNumber,
    LastUpdateDate
FROM CTE_TMP_PHONES
WHERE NOT EXISTS (SELECT * FROM CTE_NOTEXISTS)$$;

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement_1 := ' MERGE INTO Base.Phone as target USING 
                   ('||select_statement_1||') as source 
                   ON source.PhoneId = target.PhoneId
                   WHEN NOT MATCHED THEN
                    INSERT (PhoneId,
                            PhoneNumber,
                            LastUpdateDate)
                    VALUES (source.PhoneId,
                            source.PhoneNumber,
                            SYSDATE())';

merge_statement_2 := ' MERGE INTO Base.Phone as target USING 
                   ('||select_statement_2||') as source 
                   ON source.PhoneId = target.PhoneId
                   WHEN NOT MATCHED THEN
                    INSERT (PhoneId,
                            PhoneNumber,
                            SourceCode,
                            LastUpdateDate)
                    VALUES (source.PhoneId,
                            source.PhoneNumber,
                            source.SourceCode,
                            source.LastUpdateDate)';

merge_statement_3 := ' MERGE INTO Base.Phone as target USING 
                   ('||select_statement_3||') as source 
                   ON source.PhoneId = target.PhoneId
                   WHEN NOT MATCHED THEN
                    INSERT (PhoneId,
                            PhoneNumber,
                            LastUpdateDate)
                    VALUES (source.PhoneId,
                            source.PhoneNumber,
                            source.LastUpdateDate)';                            
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
EXECUTE IMMEDIATE merge_statement_1 ;
EXECUTE IMMEDIATE merge_statement_2 ;
EXECUTE IMMEDIATE merge_statement_3 ;

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