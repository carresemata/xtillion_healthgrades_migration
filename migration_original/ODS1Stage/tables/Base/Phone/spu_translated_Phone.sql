CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PHONE()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

-- base.phone depends on:
--- mdm_team.mst.customer_product_profile_processing (raw.vw_customer_product_profile and base.vw_swimlane_base_client)
--- mdm_team.mst.office_profile_processing (raw.vw_office_profile)
--- mdm_team.mst.facility_profile_processing (raw.vw_facility_profile)
--- base.facility
--- base.clienttoproduct
--- base.syndicationpartner
--- base.office
--- base.phonetype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement_1 string; 
    merge_statement_1 string; 
    select_statement_2 string; 
    merge_statement_2 string;
    select_statement_3 string; 
    merge_statement_3 string;
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_phone');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement_1 := $$ with cte_swimlane as (
    select
        *
    from
        base.vw_swimlane_base_client qualify dense_rank() over(
            partition by customerproductcode
            order by
                LastUpdateDate
        ) = 1
),

CTE_Swimlane_Phones as (
    select
        s.customerproductcode as ClientToProductcode,
        s.productcode,
        json.displaypartner_REFDISPLAYPARTNERCODE as DisplayPartnerCode,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTDES END as PhonePTDES,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTDESM END as PhonePTDESM,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTDEST END as PhonePTDEST,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTEMP END as PhonePTEMP,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTEMPM END as PhonePTEMPM,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTEMPT END as PhonePTEMPT,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTHOS END as PhonePTHOS,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTHOSM END as PhonePTHOSM,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTHOST END as PhonePTHOST,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTMTR END as PhonePTMTR,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTMTRT END as PhonePTMTRT,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTMTRM END as PhonePTMTRM,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTMWC END as PhonePTMWC,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTMWCT END as PhonePTMWCT,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTMWCM END as PhonePTMWCM,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTPSR END as PhonePTPSR,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTPSRD END as PhonePTPSRD,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTPSRM END as PhonePTPSRM,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTPSRT END as PhonePTPSRT,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTDPPEP END as PhonePTDPPEP,
        CASE WHEN s.productcode='MAP' then null else json.displaypartner_PHONEPTDPPNP END as PhonePTDPPNP 
    from CTE_swimlane as S
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
CTE_NotExists as (
    select 1 
    from base.phone as p 
        left join CTE_Tmp_Phones as cte on cte.phonenumber = p.phonenumber
    where cte.displaypartnercode = 'HG'
)
select 
    uuid_string() as PhoneId,
    PhoneNumber
from CTE_TMP_PHONES
where not exists (select * from CTE_NOTEXISTS) $$;



select_statement_2 := $$ select distinct
                            uuid_string() as PhoneId,
                            o.officeid,
                            json.phone_PHONETYPECODE as PhoneTypecode,
                            CASE  WHEN json.phone_PHONENUMBER not LIKE '%ext.%' then json.phone_PHONENUMBER else REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(json.phone_PHONENUMBER, 'ext', 'x'), '(', ''), ')', ''), '.', ''), '-', ''), ' ', '') END as PhoneNumberReformat,
                            CASE WHEN LENGTH(PhoneNumberReformat) > 15 then SUBSTRING(PhoneNumberReformat, 1, POSITION('x' IN PhoneNumberReformat)) else PhoneNumberReformat END as PhoneNumber,
                            -- PhoneNumberCustomerProduct  
                            -- PhoneRank
                            ifnull(json.phone_SOURCECODE, 'Profisee') as SourceCode,
                            json.phone_LASTUPDATEDATE as LastUpdateDate,
                            pt.phonetypeid,
                            row_number() over(partition by o.officeid, json.phone_PHONENUMBER, pt.phonetypeid order by json.phone_LASTUPDATEDATE desc) as PhoneRowRank
                        from raw.vw_OFFICE_PROFILE as JSON
                            left join base.office as O on o.officecode = json.officecode
                            left join base.phonetype as PT on pt.phonetypecode = json.phone_PHONETYPECODE
                        where
                            OFFICE_PROFILE is not null
                            and OFFICEID is not null 
                            and PhonetypeId is not null
                        qualify row_number() over(partition by OfficeID, json.phone_PHONENUMBER, PhoneTypeID order by CREATE_DATE desc) = 1 $$;


                        
select_statement_3 := $$ with CTE_Swimlane as (
    select distinct
        f.facilityid,
        json.facilitycode,
        cp.clienttoproductid,
        json.customerproduct_CUSTOMERPRODUCTCODE as ClientToProductCode,
        -- ReltioEntityId
        PARSE_JSON(json.customerproduct_DISPLAYPARTNER) as DisplayPartnerJSON,
        -- FeatureFCCIURL
        json.customerproduct_FEATUREFCCLURL as FeatureFCCLURL,
        json.customerproduct_FEATUREFCCLLOGO as FeatuerFCCLLOGO,
        json.customerproduct_FEATUREFCFLOGO as FeatureFCFLogo,
        json.customerproduct_FEATUREFCFURL as FeatureFCFURL,
        row_number() over(partition by FacilityID order by CREATE_DATE desc) as RowRank,
        ifnull(json.customerproduct_SOURCECODE, 'Profisee') as SourceCode,
        ifnull(json.customerproduct_LASTUPDATEDATE, sysdate()) as LastUpdateDate
    from raw.vw_FACILITY_PROFILE as JSON
        join base.facility as F on f.facilitycode = json.facilitycode
        join base.clienttoproduct as cp on cp.clienttoproductcode = json.customerproduct_CUSTOMERPRODUCTCODE
    where FACILITY_PROFILE is not null
          and json.facilitycode is not null
),
CTE_Swimlane_Phones as (
    select
        s.facilitycode,
        s.clienttoproductcode,
        s.rowrank,
        s.lastupdatedate,
        to_varchar(s.displaypartnerjson:DISPLAY_PARTNER_CODE) as DisplayPartnerCode,
        to_varchar(s.displaypartnerjson:PHONE_PTFDS) as PhonePTFDS,
        to_varchar(s.displaypartnerjson:PHONE_PTFDSM) as PhonePTFDSM,
        to_varchar(s.displaypartnerjson:PHONE_PTFDST) as PhonePTFDST,
        to_varchar(s.displaypartnerjson:PHONE_PTFMC) as PhonePTFMC,
        to_varchar(s.displaypartnerjson:PHONE_PTFMCM) as PhonePTFMCM,
        to_varchar(s.displaypartnerjson:PHONE_PTFMCT) as PhonePTFMCT,
        to_varchar(s.displaypartnerjson:PHONE_PTFMT) as PhonePTFMT,
        to_varchar(s.displaypartnerjson:PHONE_PTFMTM) as PhonePTFMTM,
        to_varchar(s.displaypartnerjson:PHONE_PTFMTT) as PhonePTFMTT,
        to_varchar(s.displaypartnerjson:PHONE_PTFSR) as PhonePTFSR,
        to_varchar(s.displaypartnerjson:PHONE_PTFSRD) as PhonePTFSRD,
        to_varchar(s.displaypartnerjson:PHONE_PTFSRDM) as PhonePTFSRDM,
        to_varchar(s.displaypartnerjson:PHONE_PTFSRM) as PhonePTFSRM,
        to_varchar(s.displaypartnerjson:PHONE_PTFSRT) as PhonePTFSRT,
        to_varchar(s.displaypartnerjson:PHONE_PTHFS) as PhonePTHFS,
        to_varchar(s.displaypartnerjson:PHONE_PTHFSM) as PhonePTHFSM,
        to_varchar(s.displaypartnerjson:PHONE_PTHFST) as PhonePTHFST,
        to_varchar(s.displaypartnerjson:PHONE_PTUFS) as PhonePTUFS,
        to_varchar(s.displaypartnerjson:PHONE_PTFDPPEP) as PhonePTFDPPEP,
        to_varchar(s.displaypartnerjson:PHONE_PTFDPPNP) as PhonePTFDPPNP
    from CTE_Swimlane as S
        inner join base.syndicationpartner as SP on sp.syndicationpartnercode = s.displaypartnerjson:DISPLAY_PARTNER_CODE
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
CTE_NotExists as (
    select 1 
    from base.phone as p 
        left join CTE_Tmp_Phones as cte on cte.phonenumber = p.phonenumber
    where cte.displaypartnercode = 'HG'
)
select distinct
    uuid_string() as PhoneId,
    PhoneNumber,
    LastUpdateDate
from CTE_TMP_PHONES
where not exists (select * from CTE_NOTEXISTS)$$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement_1 := ' merge into base.phone as target using 
                   ('||select_statement_1||') as source 
                   on source.phoneid = target.phoneid
                   when not matched then
                    insert (PhoneId,
                            PhoneNumber,
                            LastUpdateDate)
                    values (source.phoneid,
                            source.phonenumber,
                            sysdate())';

merge_statement_2 := ' merge into base.phone as target using 
                   ('||select_statement_2||') as source 
                   on source.phoneid = target.phoneid
                   when not matched then
                    insert (PhoneId,
                            PhoneNumber,
                            SourceCode,
                            LastUpdateDate)
                    values (source.phoneid,
                            source.phonenumber,
                            source.sourcecode,
                            source.lastupdatedate)';

merge_statement_3 := ' merge into base.phone as target using 
                   ('||select_statement_3||') as source 
                   on source.phoneid = target.phoneid
                   when not matched then
                    insert (PhoneId,
                            PhoneNumber,
                            LastUpdateDate)
                    values (source.phoneid,
                            source.phonenumber,
                            source.lastupdatedate)';                            
                   
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 
                    
execute immediate merge_statement_1 ;
execute immediate merge_statement_2 ;
execute immediate merge_statement_3 ;

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