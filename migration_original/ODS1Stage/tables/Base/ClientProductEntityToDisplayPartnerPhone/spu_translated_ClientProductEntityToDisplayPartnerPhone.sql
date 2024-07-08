CREATE or REPLACE PROCEDURE BASE.SP_LOAD_ClientProductEntityToDisplayPartnerPhone(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL EXECUTE
    as CALLER
    as declare 
    ---------------------------------------------------------
    --------------- 1. table dependencies -------------------
    ---------------------------------------------------------
    
    --- base.clientproductentitytodisplaypartnerphone depends on:
    --- mdm_team.mst.customer_product_profile_processing (base.vw_swimlane_base_client)
    --- mdm_team.mst.facility_profile_processing (raw.vw_facility_profile)
    --- base.phonetype
    --- base.entitytype
    --- base.clientproducttoentity
    --- base.clienttoproduct
    --- base.facility
    --- base.syndicationpartner

    ---------------------------------------------------------
    --------------- 2. declaring variables ------------------
    ---------------------------------------------------------
    select_statement_1 string;
    select_statement_2 string;
    update_statement string;
    insert_statement string;
    merge_statement_1 string;
    merge_statement_2 string;
    status string;
    procedure_name varchar(50) default('sp_load_clientproductentitytodisplaypartnerphone');
    execution_start datetime default getdate();

    begin 
    ---------------------------------------------------------
    ----------------- 3. SQL Statements ---------------------
    ---------------------------------------------------------
    --- select Statement
    -- if no conditionals:
    select_statement_1:= $$
            with cte_swimlane as (
        select
            *
        from
            base.vw_swimlane_base_client qualify dense_rank() over(
                partition by customerproductcode
                order by
                    LastUpdateDate
            ) = 1
    ),
    CTE_SwimlanePhones as (
        select
            s.customerproductcode as ClientToProductcode,
            s.productcode,
            json.displaypartner_REFDISPLAYPARTNERCODE as DisplayPartnerCode,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTDES
            END as PhonePTDES,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTDESM
            END as PhonePTDESM,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTDEST
            END as PhonePTDEST,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTMTR
            END as PhonePTMTR,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTMTRM
            END as PhonePTMTRM,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTMTRT
            END as PhonePTMTRT,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTMWC
            END as PhonePTMWC,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTMWCM
            END as PhonePTMWCM,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTMWCT
            END as PhonePTMWCT,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTPSR
            END as PhonePTPSR,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTPSRM
            END as PhonePTPSRM,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTPSRT
            END as PhonePTPSRT,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTHOS
            END as PhonePTHOS,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTHOSM
            END as PhonePTHOSM,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTHOST
            END as PhonePTHOST,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTPSRD
            END as PhonePTPSRD,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTEMP
            END as PhonePTEMP,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTEMPM
            END as PhonePTEMPM,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTEMPT
            END as PhonePTEMPT,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTDPPEP
            END as PhonePTDPPEP,
            CASE
                WHEN s.productcode = 'MAP' then null
                else json.displaypartner_PHONEPTDPPNP
            END as PhonePTDPPNP
        from
            CTE_swimlane as S
            left join raw.vw_CUSTOMER_PRODUCT_PROFILE as JSON on json.customerproductcode = s.customerproductcode
            inner join base.syndicationpartner as SP on sp.syndicationpartnercode = json.displaypartner_REFDISPLAYPARTNERCODE
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
        distinct cpte.clientproducttoentityid,
        s.displaypartnercode,
        pt.phonetypeid,
        s.phonenumber,
        'Profisee' as SourceCode,
        sysdate() as LastUpdateDate
    from
        cte_tmp_phones s
        inner join base.entitytype as et on et.entitytypecode = 'CLPROD'
        inner join base.phonetype as pt on pt.phonetypecode = s.phonetypecode
        inner join base.clienttoproduct as CtP on ctp.clienttoproductcode = s.clienttoproductcode
        inner join base.clientproducttoentity as CPtE on cpte.clienttoproductid = ctp.clienttoproductid
        and cpte.entitytypeid = et.entitytypeid
    where
        s.displaypartnercode != 'HG' $$;
select_statement_2:= $$     with cte_swimlane as (
        select
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
            join base.facility as f on vfp.facilitycode = f.facilitycode
            join base.clienttoproduct as cp on cp.clienttoproductcode = vfp.customerproduct_customerproductcode
        where
            customerproduct_customerproductcode is not null
    ),
    cte_swimlane_phones as (
        select
            cte.facilitycode,
            cte.clienttoproductcode,
            cte.rowrank,
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
            join base.syndicationpartner as sp on sp.syndicationpartnercode = DisplayPartnerCode
    ),
    cte_tmp_phones as (
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDS' as PhoneTypeCode,
            PhonePTFDS as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFDS is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDSM' as PhoneTypeCode,
            PhonePTFDSM as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFDSM is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDST' as PhoneTypeCode,
            PhonePTFDST as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFDST is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMC' as PhoneTypeCode,
            PhonePTFMC as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFMC is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMCM' as PhoneTypeCode,
            PhonePTFMCM as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFMCM is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMCT' as PhoneTypeCode,
            PhonePTFMCT as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFMCT is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMT' as PhoneTypeCode,
            PhonePTFMT as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFMT is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMTM' as PhoneTypeCode,
            PhonePTFMTM as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFMTM is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFMTT' as PhoneTypeCode,
            PhonePTFMTT as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFMTT is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSR' as PhoneTypeCode,
            PhonePTFSR as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFSR is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRD' as PhoneTypeCode,
            PhonePTFSRD as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFSRD is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRDM' as PhoneTypeCode,
            PhonePTFSRDM as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFSRDM is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRM' as PhoneTypeCode,
            PhonePTFSRM as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFSRM is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFSRT' as PhoneTypeCode,
            PhonePTFSRT as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFSRT is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFS' as PhoneTypeCode,
            PhonePTHFS as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTHFS is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFSM' as PhoneTypeCode,
            PhonePTHFSM as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTHFSM is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTHFST' as PhoneTypeCode,
            PhonePTHFST as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTHFST is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTUFS' as PhoneTypeCode,
            PhonePTUFS as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTUFS is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDPPEP' as PhoneTypeCode,
            PhonePTFDPPEP as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFDPPEP is not null
            and RowRank = 1
        union all
        select
            FacilityCode,
            ClientToProductCode,
            DisplayPartnerCode,
            'PTFDPPNP' as PhoneTypeCode,
            PhonePTFDPPNP as PhoneNumber
        from
            CTE_SWIMLANE_PHONES
        where
            PhonePTFDPPNP is not null
            and RowRank = 1
    )    
    select distinct 
        cpe.clientproducttoentityid, 
        s.displaypartnercode, 
        pt.phonetypeid, 
        s.phonenumber, 
        'Profisee' as SourceCode, 
        sysdate() as LastUpdateDate
    from cte_tmp_phones as s
        join base.entitytype b
        on b.entitytypecode='FAC'
        join base.facility as f on f.facilitycode = s.facilitycode
        join base.clienttoproduct as cp on cp.clienttoproductcode = s.clienttoproductcode
        join base.clientproducttoentity cpe on f.facilityid = cpe.entityid and b.entitytypeid = cpe.entitytypeid and cp.clienttoproductid = cpe.clienttoproductid
        join base.phonetype as pt on pt.phonetypecode = s.phonetypecode
    where s.displaypartnercode != 'HG'$$;
    --- update Statement
    update_statement:= '
        update
        SET
            SourceCode = source.sourcecode,
            LastUpdateDate = source.lastupdatedate';
    --- insert Statement
    insert_statement:= ' 
                insert(
                    clientproductentitytodisplaypartnerphoneid,
                    ClientProductToEntityID,
                    DisplayPartnerCode,
                    PhoneTypeID,
                    PhoneNumber,
                    SourceCode,
                    LastUpdateDate
                )
                values(
                    utils.generate_uuid(ClientProductToEntityID || DisplayPartnerCode || PhoneTypeID || PhoneNumber),
                    ClientProductToEntityID,
                    DisplayPartnerCode,
                    PhoneTypeID,
                    PhoneNumber,
                    SourceCode,
                    LastUpdateDate
                )'; 
    ---------------------------------------------------------
    --------- 4. actions (inserts and updates) --------------
    ---------------------------------------------------------
    merge_statement_1:= '     merge into base.clientproductentitytodisplaypartnerphone as target using 
                   (' || select_statement_1 || ') as source on source.clientproducttoentityid = target.clientproducttoentityid and 
                   source.phonetypeid = target.phonetypeid and source.phonenumber = target.phonenumber and 
                   source.displaypartnercode = target.displaypartnercode
                    WHEN MATCHED then' || update_statement || '
                    when not matched then' || insert_statement;
merge_statement_2:= '     merge into base.clientproductentitytodisplaypartnerphone as target using 
                   (' || select_statement_2 || ') as source on source.clientproducttoentityid = target.clientproducttoentityid and 
                   source.phonetypeid = target.phonetypeid and source.phonenumber = target.phonenumber and 
                   source.displaypartnercode = target.displaypartnercode
                    WHEN MATCHED then' || update_statement || '
                    when not matched then' || insert_statement;
    ---------------------------------------------------------
    ------------------- 5. execution ------------------------
    ---------------------------------------------------------

    if (is_full) then
        truncate table base.clientproductentitytodisplaypartnerphone;
    end if; 
    -- execute immediate update_statement;
    execute immediate merge_statement_1;
    execute immediate merge_statement_2;
    ---------------------------------------------------------
    --------------- 6. status monitoring --------------------
    ---------------------------------------------------------
    status:= 'completed successfully';
return status;
exception
    when other then status:= 'failed during execution. ' || 'sql error: ' || sqlerrm || ' error code: ' || sqlcode || '. sql state: ' || sqlstate;
return status;
end;