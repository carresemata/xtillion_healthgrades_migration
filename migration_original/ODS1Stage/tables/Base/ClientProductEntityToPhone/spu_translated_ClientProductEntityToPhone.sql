CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_CLIENTPRODUCTENTITYTOPHONE() -- Parameters
    RETURNS STRING
    LANGUAGE SQL EXECUTE
    AS CALLER
    AS DECLARE 
    ---------------------------------------------------------
    --------------- 0. Table dependencies -------------------
    ---------------------------------------------------------
    
    --- Base.ClientProductEntityToPhone depends on:
    --- MDM_TEAM.MST.PROVIDER_PROFILE_PROCESSING (raw.vw_provider_profile)
    --- MDM_TEAM.MST.FACILITY_PROFILE_PROCESSING (raw.vw_facility_profile)
    --- Base.EntityType
    --- Base.CLIENTTOPRODUCT
    --- Base.Facility
    --- Base.ClientProductToEntity
    --- Base.Phone
    --- Base.PhoneType
    --- Base.SyndicationPartner
    --- Base.ClientProductEntityToPhone
    --- Base.Office
    --- Base.OfficeToPhone

    
    ---------------------------------------------------------
    --------------- 1. Declaring variables ------------------
    ---------------------------------------------------------
    
    select_statement_1 STRING;
    select_statement_2 STRING;
    select_statement_3 STRING;
    update_statement STRING;
    insert_statement STRING;
    merge_statement_1 STRING;
    merge_statement_2 STRING;
    merge_statement_3 STRING;
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
    select_statement_1 := $$with cte_swimlane as (
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
    select
        cpe.clientproducttoentityid,
        PT.PHONETYPEID as PhoneTypeID,
        P.PHONEID as PhoneID,
        'Reltio' as SourceCode,
        sysdate() as LastUpdateDate
    from
        cte_tmp_phones s
        join Base.EntityType as ET on ET.EntityTypeCode = 'FAC'
        join Base.CLIENTTOPRODUCT as CTP on CTP.CLIENTTOPRODUCTCODE = s.clienttoproductcode
        join base.facility as f on f.facilitycode = s.facilitycode
        join Base.ClientProductToEntity cpe on CTP.CLIENTTOPRODUCTID = cpe.CLIENTTOPRODUCTID
        and ET.entitytypeid = cpe.entitytypeid
        and f.facilityid = cpe.entityid
        join Base.Phone AS P on s.PhoneNumber = P.PhoneNumber
        join Base.PhoneType as PT on s.PhoneTypeCode = PT.PhoneTypeCode
    where
        s.DisplayPartnerCode = 'HG' $$;
        
select_statement_2 := $$ with cte_swimlane_phones as (
            SELECT
                ClientToProductCode,
                ProductCode,
                DISPLAY_PARTNER [0] :REF_DISPLAY_PARTNER_CODE AS DisplayPartnerCode,
                DISPLAY_PARTNER [0] :PHONE_PTDES AS PhonePTDES,
                DISPLAY_PARTNER [0] :PHONE_PTDESM AS PhonePTDESM,
                DISPLAY_PARTNER [0] :PHONE_PTDEST AS PhonePTDEST,
                DISPLAY_PARTNER [0] :PHONE_PTEMP AS PhonePTEMP,
                DISPLAY_PARTNER [0] :PHONE_PTEMPM AS PhonePTEMPM,
                DISPLAY_PARTNER [0] :PHONE_PTEMPT AS PhonePTEMPT,
                DISPLAY_PARTNER [0] :PHONE_PTHOS AS PhonePTHOS,
                DISPLAY_PARTNER [0] :PHONE_PTHOSM AS PhonePTHOSM,
                DISPLAY_PARTNER [0] :PHONE_PTHOST AS PhonePTHOST,
                DISPLAY_PARTNER [0] :PHONE_PTMTR AS PhonePTMTR,
                DISPLAY_PARTNER [0] :PHONE_PTMTRT AS PhonePTMTRT,
                DISPLAY_PARTNER [0] :PHONE_PTMTRM AS PhonePTMTRM,
                DISPLAY_PARTNER [0] :PHONE_PTMWC AS PhonePTMWC,
                DISPLAY_PARTNER [0] :PHONE_PTMWCT AS PhonePTMWCT,
                DISPLAY_PARTNER [0] :PHONE_PTMWCM AS PhonePTMWCM,
                DISPLAY_PARTNER [0] :PHONE_PTPSR AS PhonePTPSR,
                DISPLAY_PARTNER [0] :PHONE_PTPSRD AS PhonePTPSRD,
                DISPLAY_PARTNER [0] :PHONE_PTPSRM AS PhonePTPSRM,
                DISPLAY_PARTNER [0] :PHONE_PTPSRT AS PhonePTPSRT,
                DISPLAY_PARTNER [0] :PHONE_PTDPPEP AS PhonePTDPPEP,
                DISPLAY_PARTNER [0] :PHONE_PTDPPNP AS PhonePTDPPNP
            FROM(
                    select
                        CUSTOMERPRODUCTCODE AS ClientToProductCode,
                        PRODUCTCODE as ProductCode,
                        customerproductjson:DISPLAY_PARTNER AS DISPLAY_PARTNER
                    from
                        swimlane_base_client
                    WHERE
                        DISPLAY_PARTNER IS NOT NULL
                )
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
        )
        select
            distinct CPtE.ClientProductToEntityID,
            pt.PhoneTypeID,
            ph.PhoneID,
            'Profisee' as SourceCode,
            sysdate() as LastUpdateDate
        from
            cte_tmp_phones s
            inner join Base.EntityType b on b.EntityTypeCode = 'CLPROD'
            inner join base.Phone ph on ph.PhoneNumber = s.PhoneNumber
            inner join base.PhoneType pt on pt.PhoneTypeCode = s.PhoneTypeCode
            inner join base.ClientToProduct CtP on CtP.ClientToProductCode = s.ClientToProductCode
            inner join base.ClientProductToEntity CPtE on CPtE.ClientToProductID = CtP.ClientToProductID
            and CPtE.EntityTypeID = b.EntityTypeID
        where
            s.DisplayPartnerCode = 'HG'$$;
            
select_statement_3 := $$with cte_json_data as (
            SELECT
                p.CREATE_DATE,
                p.PROVIDERCODE AS ProviderCode,
                flattened_office.value AS Office,
                Office:OFFICE_CODE as OfficeCode,
                Office:PHONE_NUMBER as PhoneNumber,
                customerproduct_customerproductcode as ClientToProductCode
            FROM
                raw.vw_provider_profile AS p,
                LATERAL FLATTEN(input => p.provider_profile:OFFICE) AS flattened_office
            WHERE
                p.provider_profile IS NOT NULL
                AND flattened_office.value IS NOT NULL
        ),
        cte_tmp_phones as (
            select
                t.OfficeCode,
                t.ClientToProductCode,
                et.EntityTypeCode,
                'PTODS' as PhoneTypeCode,
                ph.PhoneID as PhoneID
            from
                cte_json_data t
                join Base.EntityType et on et.EntityTypeCode = 'OFFICE'
                join BASE.OFFICE AS O ON O.OFFICECODE = T.OFFICECODE
                join Base.OfficeToPhone op on op.OfficeID = o.OfficeID
                join Base.Phone ph on ph.PhoneID = op.PhoneID
                join Base.PhoneType pt on pt.PhoneTypeID = op.PhoneTypeID
                and pt.PhoneTypeCode = 'Service'
        )
        select
            distinct cpe.ClientProductToEntityID as ClientProductToEntityID,
            p.PhoneID,
            pt.PhoneTypeID,
            'Profisee' as SourceCode,
            sysdate() as LastUpdateDate
        from
            cte_tmp_phones as s -- on convert(uniqueidentifier, hashbytes('SHA1',  concat(ClientToProductCode,b.EntityTypeCode,s.OfficeCode) ))=cpe.ClientProductToEntityID
            join base.office as o on o.officecode = s.officecode
            join clienttoproduct as cp on cp.clienttoproductcode = s.clienttoproductcode
            join Base.Phone as p on s.PhoneID = p.PhoneID
            join Base.PhoneType as pt on s.PhoneTypeCode = pt.PhoneTypeCode
            join Base.EntityType as et on s.EntityTypeCode = et.EntityTypeCode
            join clientproducttoentity as cpe on cpe.entitytypeid = et.entitytypeid
            and cpe.entityid = o.officeid
            and cpe.clienttoproductid = cp.clienttoproductid $$;
--- Update Statement
    update_statement := '
        UPDATE
        SET
            SourceCode = source.SourceCode,
            LastUpdateDate = source.LastUpdateDate';
--- Insert Statement
    insert_statement := ' 
        INSERT(
            ClientProductEntityToPhoneID,
            ClientProductToEntityID,
            PhoneTypeID,
            PhoneID,
            SourceCode,
            LastUpdateDate
        )
        VALUES
        (
            UUID_STRING(),
            ClientProductToEntityID,
            PhoneTypeID,
            PhoneID,
            SourceCode,
            LastUpdateDate
        )';
---------------------------------------------------------
    --------- 4. Actions (Inserts and Updates) --------------
    ---------------------------------------------------------
    merge_statement_1 := '     MERGE INTO BASE.CLIENTPRODUCTENTITYTOPHONE as target USING 
                   (' || select_statement_1 || ') as source ON source.clientproducttoentityid = target.clientproducttoentityid
                    AND source.PhoneTypeID = target.PhoneTypeID
                    AND source.PhoneID = target.PhoneID
                    WHEN MATCHED THEN' || update_statement || '
                    WHEN NOT MATCHED THEN' || insert_statement;
merge_statement_2 := '     MERGE INTO BASE.CLIENTPRODUCTENTITYTOPHONE as target USING 
                   (' || select_statement_2 || ') as source ON source.clientproducttoentityid = target.clientproducttoentityid
                    AND source.PhoneTypeID = target.PhoneTypeID
                    AND source.PhoneID = target.PhoneID
                    WHEN MATCHED THEN' || update_statement || '
                    WHEN NOT MATCHED THEN' || insert_statement;
merge_statement_3 := '     MERGE INTO BASE.CLIENTPRODUCTENTITYTOPHONE as target USING 
                   (' || select_statement_3 || ') as source ON source.clientproducttoentityid = target.clientproducttoentityid
                    AND source.PhoneTypeID = target.PhoneTypeID
                    AND source.PhoneID = target.PhoneID
                    WHEN MATCHED THEN' || update_statement || '
                    WHEN NOT MATCHED THEN' || insert_statement;
---------------------------------------------------------
    ------------------- 5. Execution ------------------------
    ---------------------------------------------------------
    -- EXECUTE IMMEDIATE update_statement;
    EXECUTE IMMEDIATE merge_statement_1;
    EXECUTE IMMEDIATE merge_statement_2;
    EXECUTE IMMEDIATE merge_statement_3;
---------------------------------------------------------
    --------------- 6. Status monitoring --------------------
    ---------------------------------------------------------
    status := 'Completed successfully';
RETURN status;
EXCEPTION
    WHEN OTHER THEN status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
RETURN status;
END;
CALL BASE.SP_LOAD_CLIENTPRODUCTENTITYTOPHONE();