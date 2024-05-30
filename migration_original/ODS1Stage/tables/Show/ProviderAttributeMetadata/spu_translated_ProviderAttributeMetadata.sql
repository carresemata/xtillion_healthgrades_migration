CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_PROVIDERATTRIBUTEMETADATA(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- show.providerattributemetadata depends on: 
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.medicalterm
--- base.medicaltermtype
--- base.entitytomedicalterm
--- base.providertoaboutme
--- base.aboutme
--- base.providertooffice
--- base.officetoaddress
--- base.providertoappointmentavailability (empty)
--- base.providerappointmentavailabilitystatement (empty)
--- base.providertocertificationspecialty (empty)
--- base.providertodegree
--- base.providertohealthinsurance
--- base.providertofacility
--- base.providertolanguage
--- base.providermalpractice
--- base.providermedia
--- base.officetophone
--- base.phonetype
--- base.office
--- base.providerimage
--- base.providertoorganization
--- base.practice
--- base.providersanction
--- base.providertospecialty
--- base.providervideo

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providerattributemetadata');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team'); 
   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
-- if no conditionals:
select_statement := $$
                    with CTE_ProviderIdList as (
    select
        distinct 
        p.providerid,
        pdp.ref_provider_code as ProviderCode
    from
        $$ || mdm_db || $$.mst.Provider_Profile_Processing as PDP
        join base.provider as P on pdp.ref_provider_code = p.providercode
    order by
        p.providerid
            ),
            CTE_MedicalTerm as (
                select
                    mt.medicaltermid,
                    mtt.medicaltermtypecode,
                    mt.refmedicaltermcode,
                    mt.medicaltermdescription1
                from
                    base.medicalterm as mt
                    join base.medicaltermtype as mtt on mtt.medicaltermtypeid = mt.medicaltermtypeid
                where
                    mtt.medicaltermtypecode IN ('Condition', 'Procedure')
                order by
                    mt.medicaltermid
            ),
            CTE_ProviderMedical as (
                select
                    p.providerid,
                    emt.entityid,
                    emt.medicaltermid,
                    emt.sourcecode,
                    emt.lastupdatedate,
                    ifnull(emt.ispreview, 0) as IsPreview,
                    emt.nationalrankinga,
                    emt.nationalrankingb,
                    emt.nationalrankingbcalc
                from
                    CTE_ProviderIdList as p
                    join base.entitytomedicalterm as emt on emt.entityid = p.providerid
            ),
            CTE_ProviderEntityToMedicalTermList as (
                select
                    distinct pm.providerid,
                    pm.entityid,
                    pm.medicaltermid,
                    mt.medicaltermtypecode,
                    mt.refmedicaltermcode,
                    pm.sourcecode,
                    pm.lastupdatedate,
                    pm.ispreview,
                    pm.nationalrankinga,
                    pm.nationalrankingb,
                    pm.nationalrankingbcalc
                from
                    CTE_ProviderMedical as pm
                    join CTE_MedicalTerm as mt on mt.medicaltermid = pm.medicaltermid
                order by
                    pm.entityid,
                    pm.medicaltermid,
                    mt.medicaltermtypecode
            ),
            CTE_updates as (
                --About Me
                select
                    ptam.providerid,
                    'AboutMe ' || AboutMeCode as DataElement,
                    ifnull(SourceCode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(ptam.lastupdateddate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providertoaboutme ptam on pid.providerid = ptam.providerid
                    join base.aboutme am on ptam.aboutmeid = am.aboutmeid
                group by
                    ptam.providerid,
                    AboutMeCode,
                    SourceCode
                union all
                    --Provider Address:
                select
                    pto.providerid,
                    'Address' as DataElement,
                    ifnull(ota.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(ota.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providertooffice PTO on pid.providerid = pto.providerid
                    join base.officetoaddress OTA on ota.officeid = pto.officeid
                group by
                    pto.providerid,
                    ota.sourcecode
                union all
                    --Appointment Availability:
                select
                    paa.providerid,
                    'Appointment Availability' as DataElement,
                    ifnull(paa.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(paa.insertedon) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providertoappointmentavailability paa on pid.providerid = paa.providerid
                group by
                    paa.providerid,
                    paa.sourcecode
                union all
                    --Provider Availability Statement:
                select
                    pas.providerid,
                    'Availability Statement' as DataElement,
                    ifnull(pas.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(pas.insertedon) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providerappointmentavailabilitystatement pas on pid.providerid = pas.providerid
                group by
                    pas.providerid,
                    pas.sourcecode
                union all
                    --Certifications:
                select
                    ptc.providerid,
                    'Certifications' as DataElement,
                    ifnull(ptc.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(ptc.insertedon) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providertocertificationspecialty ptc on pid.providerid = ptc.providerid
                group by
                    ptc.providerid,
                    ptc.sourcecode
                union all
                    --Condition:
                select
                    emt.entityid as ProviderID,
                    MedicalTermTypeCode as DataElement,
                    ifnull(emt.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(emt.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderEntityToMedicalTermList as emt
                where
                    emt.medicaltermtypecode = 'Condition'
                group by
                    emt.entityid,
                    emt.medicaltermtypecode,
                    emt.sourcecode
                union all
                    --Degree:
                select
                    ptd.providerid,
                    'Degree' as DataElement,
                    ifnull(ptd.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(ptd.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providertodegree ptd on pid.providerid = ptd.providerid
                group by
                    ptd.providerid,
                    ptd.sourcecode
                union all
                    --FirstName:
                select
                    a.providerid,
                    'FirstName' as DataElement,
                    ifnull(a.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(a.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.provider a on pid.providerid = a.providerid
                group by
                    a.providerid,
                    a.sourcecode
                union all
                    --Health Insurance:
                select
                    phi.providerid,
                    'Health Insurance' as DataElement,
                    ifnull(phi.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(phi.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providertohealthinsurance phi on pid.providerid = phi.providerid
                group by
                    phi.providerid,
                    phi.sourcecode
                union all
                    --Hospital Affiliation
                select
                    ptf.providerid,
                    'Hospital Affiliation' as DataElement,
                    ifnull(ptf.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(ptf.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providertofacility ptf on pid.providerid = ptf.providerid
                group by
                    ptf.providerid,
                    ptf.sourcecode
                union all
                    --Languages Spoken:
                select
                    pl.providerid,
                    'Languages Spoken' as DataElement,
                    ifnull(pl.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(pl.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providertolanguage pl on pid.providerid = pl.providerid
                group by
                    pl.providerid,
                    pl.sourcecode
                union all
                    --LastName:
                select
                    a.providerid,
                    'LastName' as DataElement,
                    ifnull(a.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(a.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.provider a on pid.providerid = a.providerid
                group by
                    a.providerid,
                    a.sourcecode
                union all
                    --Malpractice:
                select
                    pm.providerid,
                    'Malpractice' as DataElement,
                    ifnull(pm.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(pm.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providermalpractice pm on pid.providerid = pm.providerid
                group by
                    pm.providerid,
                    pm.sourcecode
                union all
                    --Media:
                select
                    pm.providerid,
                    'Media' as DataElement,
                    ifnull(pm.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(pm.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providermedia pm on pid.providerid = pm.providerid
                group by
                    pm.providerid,
                    pm.sourcecode
                union all
                    --Office:
                select
                    pto.providerid,
                    'Office' as DataElement,
                    ifnull(pto.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(pto.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providertooffice pto on pid.providerid = pto.providerid
                group by
                    pto.providerid,
                    pto.sourcecode
                union all
                    --Office Fax:
                select
                    pto.providerid,
                    'Office Fax' as DataElement,
                    ifnull(op.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(op.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providertooffice PTO on pid.providerid = pto.providerid
                    join base.officetophone op on pto.officeid = op.officeid
                    join base.phonetype pt on pt.phonetypeid = op.phonetypeid
                where
                    pt.phonetypecode = 'FAX'
                group by
                    pto.providerid,
                    op.sourcecode
                union all
                    --Office Name:
                select
                    a.providerid,
                    'Office Name' as DataElement,
                    ifnull(b.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(b.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providertooffice a on pid.providerid = a.providerid
                    join base.office b on b.officeid = a.officeid
                group by
                    a.providerid,
                    b.sourcecode
                union all
                    --Photo:
                select
                    pimg.providerid,
                    'Photo' as DataElement,
                    ifnull(pimg.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(pimg.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providerimage pimg on pid.providerid = pimg.providerid
                group by
                    pimg.providerid,
                    pimg.sourcecode
                union all
                    --Positions:
                select
                    po.providerid,
                    'Positions' as DataElement,
                    ifnull(po.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(po.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providertoorganization po on pid.providerid = po.providerid
                where
                    po.positionenddate is null
                group by
                    po.providerid,
                    po.sourcecode
                union all
                    --Practice Name:
                select
                    po.providerid,
                    'Practice Name' as DataElement,
                    ifnull(a.sourcecode, '') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(a.lastupdatedate) as LastUpdateDate
                from
                    base.practice a
                    join base.office o on a.practiceid = o.practiceid
                    join base.providertooffice po on po.officeid = o.officeid
                    join CTE_ProviderIDList pid on pid.providerid = po.providerid
                group by
                    po.providerid,
                    a.sourcecode
                union all
                    --Procedure:
                select
                    emt.entityid as ProviderID,
                    MedicalTermTypeCode as DataElement,
                    ifnull(emt.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(emt.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderEntityToMedicalTermList as emt
                where
                    emt.medicaltermtypecode = 'Procedure'
                group by
                    emt.entityid,
                    emt.medicaltermtypecode,
                    emt.sourcecode
                union all
                    -- Sanctions:
                select
                    ps.providerid,
                    'Sanctions' as DataElement,
                    ifnull(ps.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(ps.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providersanction ps on pid.providerid = ps.providerid
                group by
                    ps.providerid,
                    ps.sourcecode
                union all
                    --Specialty:
                select
                    pts.providerid,
                    'Specialty' as DataElement,
                    ifnull(pts.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(pts.insertedon) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providertospecialty pts on pid.providerid = pts.providerid
                group by
                    pts.providerid,
                    pts.sourcecode
                union all
                    --Video:
                select
                    a.providerid,
                    'Video' as DataElement,
                    ifnull(a.sourcecode, 'N/A') as SourceCode,
                    CURRENT_USER() as UpdatedBy, 
                    MAX(a.lastupdatedate) as LastUpdateDate
                from
                    CTE_ProviderIDList pid
                    join base.providervideo a on pid.providerid = a.providerid
                group by
                    a.providerid,
                    a.sourcecode
                order by
                    DataElement ASC
            ), 
            CTE_UpdateTrackingXML as (
            select distinct
                    p.providerid,
                    p.providercode,
                    CTE_updates.dataelement,
                    utils.p_json_to_xml(
                        array_agg(
                            '{ ' || iff(
                                CTE_updates.dataelement is not null,
                                '"elem":' || '"' || CTE_updates.dataelement || '"' || ',',
                                ''
                            ) || iff(
                                CTE_updates.sourcecode is not null,
                                '"src":' || '"' || CTE_updates.sourcecode || '"' || ',',
                                ''
                            ) || iff(
                                CTE_updates.lastupdatedate is not null,
                                '"upd":' || '"' || CTE_updates.lastupdatedate || '"',
                                ''
                            ) || ' }'
                        )::varchar,
                        '',
                        ''
                    ) as UpdateTrackingXML,
                    CTE_updates.updatedby,
                    CTE_updates.lastupdatedate as UpdatedOn
                from
                    CTE_ProviderIdList as p
                    join CTE_updates on CTE_updates.providerid = p.providerid
                    
                group by
                    p.providerid,
                    p.providercode,
                    CTE_updates.updatedby,
                    CTE_updates.lastupdatedate,
                    CTE_updates.dataelement
                order by
                    CTE_updates.dataelement)
            
            select distinct
                p.providerid,
                p.providercode,
                TO_VARIANT(utils.p_json_to_xml(
                        array_agg( 
                        '{ '||
            iff(UpdateTrackingXML is not null, '"xml_1":' || '"' || UpdateTrackingXML || '"', '')
            ||' }'
                        )::varchar
                        ,
                        'prov',
                        'de'
                    )) as UpdateTrackingXML, -- TO_VARIANT()
                u.updatedby,
                MAX(u.lastupdatedate) as UpdatedOn
            
            from CTE_ProviderIDList as p
            join CTE_updates as u on p.providerid = u.providerid
            join CTE_UpdateTrackingXML as xml on p.providerid = xml.providerid
            group by
                p.providerid,
                p.providercode,
                u.updatedby
            order by
                p.providerid,
                p.providercode
            $$;


--- update Statement
update_statement := ' update 
                        SET
                            ProviderCode = source.providercode,
                            UpdateTrackingXML = source.updatetrackingxml,
                            UpdatedBy = CURRENT_USER(),
                            UpdatedOn = current_timestamp()';
                        
--- insert Statement
insert_statement := ' insert (
                            ProviderId,
                            ProviderCode,
                            UpdateTrackingXML,
                            UpdatedBy,
                            UpdatedOn
                        )
                        values (
                            source.providerid,
                            source.providercode,
                            source.updatetrackingxml,
                            source.updatedby,
                            source.updatedon
                        );';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into show.providerattributemetadata as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid
                   WHEN MATCHED then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Show.ProviderAttributeMetadata;
end if; 
execute immediate merge_statement ;

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