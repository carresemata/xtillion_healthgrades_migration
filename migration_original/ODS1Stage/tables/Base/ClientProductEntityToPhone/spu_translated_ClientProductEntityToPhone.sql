CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CLIENTPRODUCTENTITYTOPHONE() -- Parameters
    RETURNS STRING
    LANGUAGE SQL EXECUTE
    as CALLER
    as declare 
    ---------------------------------------------------------
    --------------- 0. table dependencies -------------------
    ---------------------------------------------------------
    
    --- base.clientproductentitytophone depends on:
    --- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
    --- mdm_team.mst.facility_profile_processing (raw.vw_facility_profile)
    --- base.entitytype
    --- base.clienttoproduct
    --- base.facility
    --- base.clientproducttoentity
    --- base.phone
    --- base.phonetype
    --- base.syndicationpartner
    --- base.clientproductentitytophone
    --- base.office
    --- base.officetophone

    
    ---------------------------------------------------------
    --------------- 1. declaring variables ------------------
    ---------------------------------------------------------
    
    select_statement_1 string;
    select_statement_2 string;
    select_statement_3 string;
    update_statement string;
    insert_statement string;
    merge_statement_1 string;
    merge_statement_2 string;
    merge_statement_3 string;
    status string;
    procedure_name varchar(50) default('sp_load_clientproductentitytophone');
    execution_start datetime default getdate();


    ---------------------------------------------------------
    --------------- 2.conditionals if any -------------------
    ---------------------------------------------------------
    begin 
    ---------------------------------------------------------
    ----------------- 3. SQL Statements ---------------------
    ---------------------------------------------------------
    --- select Statement
    -- if no conditionals:
    select_statement_1 := $$with cte_swimlane as (
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
    select
        cpe.clientproducttoentityid,
        pt.phonetypeid as PhoneTypeID,
        p.phoneid as PhoneID,
        'Reltio' as SourceCode,
        sysdate() as LastUpdateDate
    from
        cte_tmp_phones s
        join base.entitytype as ET on et.entitytypecode = 'FAC'
        join base.clienttoproduct as CTP on ctp.clienttoproductcode = s.clienttoproductcode
        join base.facility as f on f.facilitycode = s.facilitycode
        join base.clientproducttoentity cpe on ctp.clienttoproductid = cpe.clienttoproductid
        and et.entitytypeid = cpe.entitytypeid
        and f.facilityid = cpe.entityid
        join base.phone as P on s.phonenumber = p.phonenumber
        join base.phonetype as PT on s.phonetypecode = pt.phonetypecode
    where
        s.displaypartnercode = 'HG' $$;
        
select_statement_2 := $$ with cte_swimlane_phones as (
            select
                ClientToProductCode,
                ProductCode,
                DISPLAY_PARTNER [0] :REF_DISPLAY_PARTNER_CODE as DisplayPartnerCode,
                DISPLAY_PARTNER [0] :PHONE_PTDES as PhonePTDES,
                DISPLAY_PARTNER [0] :PHONE_PTDESM as PhonePTDESM,
                DISPLAY_PARTNER [0] :PHONE_PTDEST as PhonePTDEST,
                DISPLAY_PARTNER [0] :PHONE_PTEMP as PhonePTEMP,
                DISPLAY_PARTNER [0] :PHONE_PTEMPM as PhonePTEMPM,
                DISPLAY_PARTNER [0] :PHONE_PTEMPT as PhonePTEMPT,
                DISPLAY_PARTNER [0] :PHONE_PTHOS as PhonePTHOS,
                DISPLAY_PARTNER [0] :PHONE_PTHOSM as PhonePTHOSM,
                DISPLAY_PARTNER [0] :PHONE_PTHOST as PhonePTHOST,
                DISPLAY_PARTNER [0] :PHONE_PTMTR as PhonePTMTR,
                DISPLAY_PARTNER [0] :PHONE_PTMTRT as PhonePTMTRT,
                DISPLAY_PARTNER [0] :PHONE_PTMTRM as PhonePTMTRM,
                DISPLAY_PARTNER [0] :PHONE_PTMWC as PhonePTMWC,
                DISPLAY_PARTNER [0] :PHONE_PTMWCT as PhonePTMWCT,
                DISPLAY_PARTNER [0] :PHONE_PTMWCM as PhonePTMWCM,
                DISPLAY_PARTNER [0] :PHONE_PTPSR as PhonePTPSR,
                DISPLAY_PARTNER [0] :PHONE_PTPSRD as PhonePTPSRD,
                DISPLAY_PARTNER [0] :PHONE_PTPSRM as PhonePTPSRM,
                DISPLAY_PARTNER [0] :PHONE_PTPSRT as PhonePTPSRT,
                DISPLAY_PARTNER [0] :PHONE_PTDPPEP as PhonePTDPPEP,
                DISPLAY_PARTNER [0] :PHONE_PTDPPNP as PhonePTDPPNP
            from(
                    select
                        CUSTOMERPRODUCTCODE as ClientToProductCode,
                        PRODUCTCODE as ProductCode,
                        customerproductjson:DISPLAY_PARTNER as DISPLAY_PARTNER
                    from
                        swimlane_base_client
                    where
                        DISPLAY_PARTNER is not null
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
            distinct cpte.clientproducttoentityid,
            pt.phonetypeid,
            ph.phoneid,
            'Profisee' as SourceCode,
            sysdate() as LastUpdateDate
        from
            cte_tmp_phones s
            inner join base.entitytype b on b.entitytypecode = 'CLPROD'
            inner join base.phone ph on ph.phonenumber = s.phonenumber
            inner join base.phonetype pt on pt.phonetypecode = s.phonetypecode
            inner join base.clienttoproduct CtP on ctp.clienttoproductcode = s.clienttoproductcode
            inner join base.clientproducttoentity CPtE on cpte.clienttoproductid = ctp.clienttoproductid
            and cpte.entitytypeid = b.entitytypeid
        where
            s.displaypartnercode = 'HG'$$;
            
select_statement_3 := $$with cte_json_data as (
            select
                p.create_DATE,
                p.providercode as ProviderCode,
                flattened_office.value as Office,
                Office:OFFICE_CODE as OfficeCode,
                Office:PHONE_NUMBER as PhoneNumber,
                customerproduct_customerproductcode as ClientToProductCode
            from
                raw.vw_provider_profile as p,
                LATERAL FLATTEN(input => p.provider_profile:OFFICE) as flattened_office
            where
                p.provider_profile is not null
                and flattened_office.value is not null
        ),
        cte_tmp_phones as (
            select
                t.officecode,
                t.clienttoproductcode,
                et.entitytypecode,
                'PTODS' as PhoneTypeCode,
                ph.phoneid as PhoneID
            from
                cte_json_data t
                join base.entitytype et on et.entitytypecode = 'OFFICE'
                join base.office as O on o.officecode = t.officecode
                join base.officetophone op on op.officeid = o.officeid
                join base.phone ph on ph.phoneid = op.phoneid
                join base.phonetype pt on pt.phonetypeid = op.phonetypeid
                and pt.phonetypecode = 'Service'
        )
        select
            distinct cpe.clientproducttoentityid as ClientProductToEntityID,
            p.phoneid,
            pt.phonetypeid,
            'Profisee' as SourceCode,
            sysdate() as LastUpdateDate
        from
            cte_tmp_phones as s -- on convert(uniqueidentifier, hashbytes('SHA1',  concat(ClientToProductCode,b.entitytypecode,s.officecode) ))=cpe.clientproducttoentityid
            join base.office as o on o.officecode = s.officecode
            join clienttoproduct as cp on cp.clienttoproductcode = s.clienttoproductcode
            join base.phone as p on s.phoneid = p.phoneid
            join base.phonetype as pt on s.phonetypecode = pt.phonetypecode
            join base.entitytype as et on s.entitytypecode = et.entitytypecode
            join clientproducttoentity as cpe on cpe.entitytypeid = et.entitytypeid
            and cpe.entityid = o.officeid
            and cpe.clienttoproductid = cp.clienttoproductid $$;
--- update Statement
    update_statement := '
        update
        SET
            SourceCode = source.sourcecode,
            LastUpdateDate = source.lastupdatedate';
--- insert Statement
    insert_statement := ' 
        insert(
            ClientProductEntityToPhoneID,
            ClientProductToEntityID,
            PhoneTypeID,
            PhoneID,
            SourceCode,
            LastUpdateDate
        )
        values
        (
            uuid_string(),
            ClientProductToEntityID,
            PhoneTypeID,
            PhoneID,
            SourceCode,
            LastUpdateDate
        )';
---------------------------------------------------------
    --------- 4. actions (inserts and updates) --------------
    ---------------------------------------------------------
    merge_statement_1 := '     merge into base.clientproductentitytophone as target using 
                   (' || select_statement_1 || ') as source on source.clientproducttoentityid = target.clientproducttoentityid
                    and source.phonetypeid = target.phonetypeid
                    and source.phoneid = target.phoneid
                    WHEN MATCHED then' || update_statement || '
                    when not matched then' || insert_statement;
merge_statement_2 := '     merge into base.clientproductentitytophone as target using 
                   (' || select_statement_2 || ') as source on source.clientproducttoentityid = target.clientproducttoentityid
                    and source.phonetypeid = target.phonetypeid
                    and source.phoneid = target.phoneid
                    WHEN MATCHED then' || update_statement || '
                    when not matched then' || insert_statement;
merge_statement_3 := '     merge into base.clientproductentitytophone as target using 
                   (' || select_statement_3 || ') as source on source.clientproducttoentityid = target.clientproducttoentityid
                    and source.phonetypeid = target.phonetypeid
                    and source.phoneid = target.phoneid
                    WHEN MATCHED then' || update_statement || '
                    when not matched then' || insert_statement;
    ---------------------------------------------------------
    ------------------- 5. execution ------------------------
    ---------------------------------------------------------
    -- execute immediate update_statement;
    execute immediate merge_statement_1;
    execute immediate merge_statement_2;
    execute immediate merge_statement_3;
    ---------------------------------------------------------
    --------------- 6. status monitoring --------------------
    ---------------------------------------------------------
    status := 'completed successfully';
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        return status;

        exception
        when other then
            status := 'failed during execution. ' || 'sql error: ' || sqlerrm || ' error code: ' || sqlcode || '. sql state: ' || sqlstate;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, split_part(regexp_substr(:status, 'error code: ([0-9]+)'), ':', 2)::integer, trim(split_part(split_part(:status, 'sql error:', 2), 'error code:', 1)), split_part(regexp_substr(:status, 'sql state: ([0-9]+)'), ':', 2)::integer; 

            return status;
end;