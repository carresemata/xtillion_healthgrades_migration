CREATE OR REPLACE PROCEDURE BASE.SP_LOAD_ClientProductEntityToDisplayPartnerPhone() -- Parameters
    RETURNS STRING
    LANGUAGE SQL EXECUTE
    AS CALLER
    AS DECLARE 
    ---------------------------------------------------------
    --------------- 0. Table dependencies -------------------
    ---------------------------------------------------------
    --- Base.ClientProductEntityToDisplayPartnerPhone depends on:
    --- Base.SWIMLANE_BASE_CLIENT
    --- BASE.PHONE
    --- BASE.PHONETYPE
    --- BASE.ENTITYTYPE
    --- BASE.CLIENTPRODUCTTOENTITY
    --- BASE.CLIENTTOPRODUCT
    --- BASE.FACILITY
    ---------------------------------------------------------
    --------------- 1. Declaring variables ------------------
    ---------------------------------------------------------
    select_statement_1 STRING;
    select_statement_2 STRING;
    update_statement STRING;
    insert_statement STRING;
    merge_statement_1 STRING;
    merge_statement_2 STRING;
    status STRING;
    ---------------------------------------------------------
    --------------- 2.Conditionals if any -------------------
    ---------------------------------------------------------
    BEGIN 
    ---------------------------------------------------------
    ----------------- 3. SQL Statements ---------------------
    ---------------------------------------------------------
    --- Select Statement
    -- If no conditionals:
    select_statement_1:= $$
            WITH cte_swimlane AS (
        SELECT
            *
        from
            base.swimlane_base_client qualify dense_rank() over(
                partition by customerproductcode
                order by
                    LastUpdateDate
            ) = 1
    ),
    CTE_SwimlanePhones AS (
        SELECT
            S.CUSTOMERPRODUCTCODE AS ClientToProductcode,
            S.ProductCode,
            JSON.DISPLAYPARTNER_REFDISPLAYPARTNERCODE AS DisplayPartnerCode,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTDES
            END AS PhonePTDES,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTDESM
            END AS PhonePTDESM,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTDEST
            END AS PhonePTDEST,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTMTR
            END AS PhonePTMTR,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTMTRM
            END AS PhonePTMTRM,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTMTRT
            END AS PhonePTMTRT,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTMWC
            END AS PhonePTMWC,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTMWCM
            END AS PhonePTMWCM,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTMWCT
            END AS PhonePTMWCT,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTPSR
            END AS PhonePTPSR,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTPSRM
            END AS PhonePTPSRM,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTPSRT
            END AS PhonePTPSRT,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTHOS
            END AS PhonePTHOS,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTHOSM
            END AS PhonePTHOSM,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTHOST
            END AS PhonePTHOST,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTPSRD
            END AS PhonePTPSRD,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTEMP
            END AS PhonePTEMP,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTEMPM
            END AS PhonePTEMPM,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTEMPT
            END AS PhonePTEMPT,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTDPPEP
            END AS PhonePTDPPEP,
            CASE
                WHEN S.ProductCode = 'MAP' THEN NULL
                ELSE JSON.DISPLAYPARTNER_PHONEPTDPPNP
            END AS PhonePTDPPNP
        FROM
            CTE_swimlane AS S
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
            CTE_SwimlanePhones
        where
            PhonePTDES is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTDESM' as PhoneTypeCode,
            PhonePTDESM as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTDESM is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTDEST' as PhoneTypeCode,
            PhonePTDEST as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTDEST is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTEMP' as PhoneTypeCode,
            PhonePTEMP as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTEMP is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTEMPM' as PhoneTypeCode,
            PhonePTEMPM as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTEMPM is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTEMPT' as PhoneTypeCode,
            PhonePTEMPT as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTEMPT is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHOS' as PhoneTypeCode,
            PhonePTHOS as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTHOS is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHOSM' as PhoneTypeCode,
            PhonePTHOSM as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTHOSM is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHOST' as PhoneTypeCode,
            PhonePTHOST as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTHOST is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTMTR' as PhoneTypeCode,
            PhonePTMTR as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTMTR is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTMTRT' as PhoneTypeCode,
            PhonePTMTRT as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTMTRT is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTMTRM' as PhoneTypeCode,
            PhonePTMTRM as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTMTRM is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTMWC' as PhoneTypeCode,
            PhonePTMWC as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTMWC is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTMWCT' as PhoneTypeCode,
            PhonePTMWCT as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTMWCT is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTMWCM' as PhoneTypeCode,
            PhonePTMWCM as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTMWCM is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTPSR' as PhoneTypeCode,
            PhonePTPSR as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTPSR is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTPSRD' as PhoneTypeCode,
            PhonePTPSRD as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTPSRD is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTPSRM' as PhoneTypeCode,
            PhonePTPSRM as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTPSRM is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTPSRT' as PhoneTypeCode,
            PhonePTPSRT as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTPSRT is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTDPPEP' as PhoneTypeCode,
            PhonePTDPPEP as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTDPPEP is not null
        union all
        select
            ClientToProductCode,
            DisplayPartnerCode,
            'PTDPPNP' as PhoneTypeCode,
            PhonePTDPPNP as PhoneNumber
        from
            CTE_SwimlanePhones
        where
            PhonePTDPPNP is not null
    )
    select
        distinct CPtE.ClientProductToEntityID,
        s.DisplayPartnerCode,
        pt.PhoneTypeID,
        s.PhoneNumber,
        'Profisee' as SourceCode,
        sysdate() as LastUpdateDate
    from
        cte_tmp_phones s
        inner join Base.EntityType as et on et.EntityTypeCode = 'CLPROD'
        inner join base.PhoneType as pt on pt.PhoneTypeCode = s.PhoneTypeCode
        inner join base.ClientToProduct as CtP on CtP.ClientToProductCode = s.ClientToProductCode
        inner join base.ClientProductToEntity as CPtE on CPtE.ClientToProductID = CtP.ClientToProductID
        and CPtE.EntityTypeID = et.EntityTypeID
    where
        s.DisplayPartnerCode != 'HG' $$;
select_statement_2:= $$     with cte_swimlane as (
        SELECT
            facilityid as FacilityID,
            vfp.facilitycode as FacilityCode,
            cp.clienttoproductid,
            customerproduct_customerproductcode as ClientToProductCode,
            parse_json(customerproduct_displaypartner) as DisplayPartner,
            customerproduct_featurefcclurl,
            customerproduct_featurefcflogo,
            customerproduct_featurefcfurl,
            row_number() over(
                partition by FacilityID
                order by
                    CREATE_DATE desc
            ) as RowRank,
            'Reltio' as SourceCode,
            sysdate() as LastUpdateDate
        from
            raw.vw_facility_profile as vfp
            JOIN base.facility as f on vfp.facilitycode = f.facilitycode
            JOIN base.clienttoproduct as cp on cp.clienttoproductcode = vfp.customerproduct_customerproductcode
        WHERE
            customerproduct_customerproductcode is not null
    ),
    cte_swimlane_phones as (
        SELECT
            CTE.FACILITYCODE,
            CTE.CLIENTTOPRODUCTCODE,
            CTE.ROWRANK,
            DisplayPartner:DISPLAY_PARTNER_CODE as DisplayPartnerCode,
            DisplayPartner:PHONE_PTFDS as PhonePTFDS,
            DisplayPartner:PHONE_PTFDSM as PhonePTFDSM,
            DisplayPartner:PHONE_PTFDST as PhonePTFDST,
            DisplayPartner:PHONE_PTFMC as PhonePTFMC,
            DisplayPartner:PHONE_PTFMCM as PhonePTFMCM,
            DisplayPartner:PHONE_PTFMCT as PhonePTFMCT,
            DisplayPartner:PHONE_PTFMT as PhonePTFMT,
            DisplayPartner:PHONE_PTFMTM as PhonePTFMTM,
            DisplayPartner:PHONE_PTFMTT as PhonePTFMTT,
            DisplayPartner:PHONE_PTFSR as PhonePTFSR,
            DisplayPartner:PHONE_PTFSRD as PhonePTFSRD,
            DisplayPartner:PHONE_PTFSRDM as PhonePTFSRDM,
            DisplayPartner:PHONE_PTFSRM as PhonePTFSRM,
            DisplayPartner:PHONE_PTFSRT as PhonePTFSRT,
            DisplayPartner:PHONE_PTHFS as PhonePTHFS,
            DisplayPartner:PHONE_PTHFSM as PhonePTHFSM,
            DisplayPartner:PHONE_PTHFST as PhonePTHFST,
            DisplayPartner:PHONE_PTUFS as PhonePTUFS,
            DisplayPartner:PHONE_PTFDPPEP as PhonePTFDPPEP,
            DisplayPartner:PHONE_PTFDPPNP as PhonePTFDPPNP
        from
            cte_swimlane as cte
            JOIN Base.SyndicationPartner as sp on sp.syndicationPartnerCode = DisplayPartnerCode
    ),
    cte_tmp_phones as (
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDS' as PhoneTypeCode,
            PhonePTFDS as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFDS is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDSM' as PhoneTypeCode,
            PhonePTFDSM as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFDSM is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDST' as PhoneTypeCode,
            PhonePTFDST as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFDST is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMC' as PhoneTypeCode,
            PhonePTFMC as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFMC is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMCM' as PhoneTypeCode,
            PhonePTFMCM as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFMCM is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMCT' as PhoneTypeCode,
            PhonePTFMCT as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFMCT is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMT' as PhoneTypeCode,
            PhonePTFMT as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFMT is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMTM' as PhoneTypeCode,
            PhonePTFMTM as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFMTM is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMTT' as PhoneTypeCode,
            PhonePTFMTT as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFMTT is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSR' as PhoneTypeCode,
            PhonePTFSR as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFSR is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRD' as PhoneTypeCode,
            PhonePTFSRD as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFSRD is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRDM' as PhoneTypeCode,
            PhonePTFSRDM as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFSRDM is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRM' as PhoneTypeCode,
            PhonePTFSRM as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFSRM is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRT' as PhoneTypeCode,
            PhonePTFSRT as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFSRT is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFS' as PhoneTypeCode,
            PhonePTHFS as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTHFS is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFSM' as PhoneTypeCode,
            PhonePTHFSM as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTHFSM is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFST' as PhoneTypeCode,
            PhonePTHFST as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTHFST is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTUFS' as PhoneTypeCode,
            PhonePTUFS as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTUFS is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDPPEP' as PhoneTypeCode,
            PhonePTFDPPEP as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFDPPEP is not null
            and RowRank = 1
        UNION ALL
        SELECT
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDPPNP' as PhoneTypeCode,
            PhonePTFDPPNP as PhoneNumber
        FROM
            CTE_SWIMLANE_PHONES
        WHERE
            PhonePTFDPPNP is not null
            and RowRank = 1
    )    
    select distinct 
        cpe.ClientProductToEntityID, 
        s.DisplayPartnerCode, 
        pt.PhoneTypeID, 
        s.PhoneNumber, 
        'Profisee' as SourceCode, 
        SYSDATE() as LastUpdateDate
    from cte_tmp_phones as s
        join Base.EntityType b
        on b.EntityTypeCode='FAC'
        join base.facility as f on f.facilitycode = s.facilitycode
        join base.clienttoproduct as cp on cp.clienttoproductcode = s.ClientToProductCode
        join Base.ClientProductToEntity cpe on f.facilityid = cpe.entityid and b.entitytypeid = cpe.entitytypeid and cp.clienttoproductid = cpe.clienttoproductid
        join base.phonetype as pt on pt.phonetypecode = s.phonetypecode
    where s.DisplayPartnerCode != 'HG'$$;
    --- Update Statement
    update_statement:= '
        UPDATE
        SET
            SourceCode = source.SourceCode,
            LastUpdateDate = source.LastUpdateDate';
    --- Insert Statement
    insert_statement:= ' 
                INSERT(clientproductentitytodisplaypartnerphoneid,ClientProductToEntityID,DisplayPartnerCode,PhoneTypeID,PhoneNumber,SourceCode,LastUpdateDate)
                VALUES(uuid_string(),ClientProductToEntityID,DisplayPartnerCode,PhoneTypeID,PhoneNumber,SourceCode,LastUpdateDate)';
    ---------------------------------------------------------
    --------- 4. Actions (Inserts and Updates) --------------
    ---------------------------------------------------------
    merge_statement_1:= '     MERGE INTO BASE.ClientProductEntityToDisplayPartnerPhone as target USING 
                   (' || select_statement_1 || ') as source ON source.ClientProductToEntityID = target.ClientProductToEntityID and 
                   source.PhoneTypeID = target.PhoneTypeID and source.PhoneNumber = target.PhoneNumber and 
                   source.DisplayPartnerCode = target.DisplayPartnerCode
                    WHEN MATCHED THEN' || update_statement || '
                    WHEN NOT MATCHED THEN' || insert_statement;
merge_statement_2:= '     MERGE INTO BASE.ClientProductEntityToDisplayPartnerPhone as target USING 
                   (' || select_statement_2 || ') as source ON source.ClientProductToEntityID = target.ClientProductToEntityID and 
                   source.PhoneTypeID = target.PhoneTypeID and source.PhoneNumber = target.PhoneNumber and 
                   source.DisplayPartnerCode = target.DisplayPartnerCode
                    WHEN MATCHED THEN' || update_statement || '
                    WHEN NOT MATCHED THEN' || insert_statement;
    ---------------------------------------------------------
    ------------------- 5. Execution ------------------------
    ---------------------------------------------------------
    -- EXECUTE IMMEDIATE update_statement;
    EXECUTE IMMEDIATE merge_statement_1;
    EXECUTE IMMEDIATE merge_statement_2;
    ---------------------------------------------------------
    --------------- 6. Status monitoring --------------------
    ---------------------------------------------------------
    status:= 'Completed successfully';
RETURN status;
EXCEPTION
    WHEN OTHER THEN status:= 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
RETURN status;
END;