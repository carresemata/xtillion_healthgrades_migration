CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERLASTUPDATEDATE(is_full BOOLEAN)
RETURNS varchar(16777216)
LANGUAGE SQL
EXECUTE as CALLER
as 

declare
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
--- base.providerlastupdatedate depends on:
-- mdm_team.mst.provider_profile_processing
-- base.provider
-- base.providertoaboutme
-- base.providerappointmentavailabilitystatement
-- base.provideremail
-- base.providerlicense
-- base.providertooffice
-- base.providertoprovidertype
-- base.providertosubstatus
-- base.providertoappointmentavailability
-- base.providertocertificationspecialty
-- base.providertofacility
-- base.providerimage
-- base.providermalpractice
-- base.providertoorganization
-- base.clientproducttoentity
-- base.clienttoproduct
-- base.product
-- base.providertodegree
-- base.providertoeducationinstitution
-- base.providertolanguage
-- base.providermedia
-- base.providertospecialty
-- base.providervideo
-- base.providertotelehealthmethod
-- base.entitytomedicalterm
-- base.medicalterm
-- base.medicaltermtype
-- base.providertoprovidersubtype
-- base.providertraining
-- base.provideridentification
-- base.entitytype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
    select_statement string;
    insert_statement string;
    update_statement string;
    merge_statement string;
    status string;
    procedure_name varchar(50) default('sp_load_providerlastupdatedate');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

select_statement := $$
                    with CTE_Provider as (
                        select ppp.providerid
                        from $$ || mdm_db || $$.mst.Provider_Profile_Processing ppp 
                        inner join base.provider p on p.providercode = ppp.ref_Provider_Code
                    ),
                    
                    CTE_Demographics as (
                        select p.providerid, p.sourcecode, p.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.provider p on p.providerid = cte_p.providerid
                    ),
                    
                    CTE_AboutMe as (
                        select ptam.providerid, ptam.sourcecode, ptam.lastupdateddate as LastUpdateDate
                        from CTE_Provider p
                        inner join base.providertoaboutme ptam on ptam.providerid = p.providerid
                        qualify row_number() over (partition by ptam.providerid order by ptam.lastupdateddate desc) = 1
                    ),
                    
                    CTE_AppointmentAvailabilityStatement as (
                        select paas.providerid, paas.sourcecode, paas.lastupdateddate as LastUpdateDate
                        from CTE_Provider cte_p
                        inner join base.providerappointmentavailabilitystatement paas on paas.providerid = cte_p.providerid
                    ),
                    
                    CTE_Email as (
                        select pe.providerid, pe.sourcecode, pe.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.provideremail pe on pe.providerid = cte_p.providerid
                        qualify row_number() over (partition by pe.providerid order by pe.lastupdatedate desc) = 1
                    ),
                    
                    CTE_License as (
                        select pl.providerid, pl.sourcecode, pl.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providerlicense pl on pl.providerid = cte_p.providerid
                        qualify row_number() over (partition by pl.providerid order by pl.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Office as (
                        select pto.providerid, pto.sourcecode, pto.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providertooffice pto on pto.providerid = cte_p.providerid
                        qualify row_number() over (partition by pto.providerid order by pto.lastupdatedate desc) = 1
                    ),
                    
                    CTE_ProviderType as (
                        select ptpt.providerid, ptpt.sourcecode, ptpt.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providertoprovidertype ptpt on ptpt.providerid = cte_p.providerid
                        qualify row_number() over (partition by ptpt.providerid order by ptpt.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Status as (
                        select ptss.providerid, ptss.sourcecode, ptss.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providertosubstatus ptss on ptss.providerid = cte_p.providerid
                        qualify row_number() over (partition by ptss.providerid order by ptss.lastupdatedate desc) = 1
                    ),
                    
                    CTE_AppointmentAvailability as (
                        select ptaa.providerid, ptaa.sourcecode, ptaa.lastupdateddate as LastUpdateDate
                        from CTE_Provider cte_p
                        inner join base.providertoappointmentavailability ptaa on ptaa.providerid = cte_p.providerid
                        qualify row_number() over (partition by ptaa.providerid order by ptaa.lastupdateddate desc) = 1
                    ),
                    
                    CTE_CertificationSpecialty as (
                        select ptcs.providerid, ptcs.sourcecode, ptcs.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providertocertificationspecialty ptcs on ptcs.providerid = cte_p.providerid
                        qualify row_number() over (partition by ptcs.providerid order by ptcs.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Facility as (
                        select ptf.providerid, ptf.sourcecode, ptf.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providertofacility ptf on ptf.providerid = cte_p.providerid
                        qualify row_number() over (partition by ptf.providerid order by ptf.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Image as (
                        select i.providerid, i.sourcecode, i.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providerimage i on i.providerid = cte_p.providerid
                        qualify row_number() over (partition by i.providerid order by i.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Malpractice as (
                        select m.providerid, m.sourcecode, m.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providermalpractice m on m.providerid = cte_p.providerid
                        qualify row_number() over (partition by m.providerid order by m.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Organization as (
                        select pto.providerid, pto.sourcecode, pto.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providertoorganization pto on pto.providerid = cte_p.providerid
                        qualify row_number() over (partition by pto.providerid order by pto.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Sponsorship as (
                        select cpte.entityid as ProviderID, ctp.clienttoproductcode as SourceCode, cpte.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.clientproducttoentity cpte on cpte.entityid = cte_p.providerid
                        inner join base.entitytype et on et.entitytypecode = 'PROV'
                        inner join base.clienttoproduct ctp on cpte.clienttoproductid = ctp.clienttoproductid
                        inner join base.product prod on prod.productid = ctp.productid and prod.productcode != 'LID'
                        qualify row_number() over (partition by cpte.entityid order by cpte.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Degree as (
                        select ptd.providerid, ptd.sourcecode, ptd.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providertodegree ptd on ptd.providerid = cte_p.providerid
                        qualify row_number() over (partition by ptd.providerid order by ptd.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Education as (
                        select ptei.providerid, ptei.sourcecode, ptei.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providertoeducationinstitution ptei on ptei.providerid = cte_p.providerid
                        qualify row_number() over (partition by ptei.providerid order by ptei.lastupdatedate desc) = 1
                    ), 
                    
                    CTE_HealthInsurance as (
                        select pthi.providerid, pthi.sourcecode, pthi.lastupdatedate
                        from CTE_Provider cte_p
                        inner join ProviderToHealthInsurance pthi on pthi.providerid = cte_p.providerid
                        qualify row_number() over (partition by pthi.providerid order by pthi.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Language as (
                        select ptl.providerid, ptl.sourcecode, ptl.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providertolanguage ptl on ptl.providerid = cte_p.providerid
                        qualify row_number() over (partition by ptl.providerid order by ptl.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Media as (
                        select pm.providerid, pm.sourcecode, pm.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providermedia pm on pm.providerid = cte_p.providerid
                        qualify row_number() over (partition by pm.providerid order by pm.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Specialty as (
                        select ps.providerid, ps.sourcecode, ps.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providertospecialty ps on ps.providerid = cte_p.providerid
                        qualify row_number() over (partition by ps.providerid order by ps.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Video as (
                        select pv.providerid, pv.sourcecode, pv.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providervideo pv on pv.providerid = cte_p.providerid
                        qualify row_number() over (partition by pv.providerid order by pv.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Telehealth as (
                        select pt.providerid, pt.sourcecode, pt.lastupdateddate as LastUpdateDate
                        from CTE_Provider cte_p
                        inner join base.providertotelehealthmethod pt on pt.providerid = cte_p.providerid
                        qualify row_number() over (partition by pt.providerid order by pt.lastupdateddate desc) = 1
                    ),
                    
                    CTE_Condition as (
                        select etmt.entityid as ProviderID, etmt.sourcecode, etmt.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.entitytomedicalterm etmt on etmt.entityid = cte_p.providerid
                        inner join base.medicalterm mt on mt.medicaltermid = etmt.medicaltermid
                        inner join base.medicaltermtype mtt on mtt.medicaltermtypeid = mt.medicaltermtypeid and mtt.medicaltermtypecode = 'Condition'
                        qualify row_number() over (partition by etmt.entityid order by etmt.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Procedure as (
                        select etmt.entityid as ProviderID, etmt.sourcecode, etmt.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.entitytomedicalterm etmt on etmt.entityid = cte_p.providerid
                        inner join base.medicalterm mt on mt.medicaltermid = etmt.medicaltermid
                        inner join base.medicaltermtype mtt on mtt.medicaltermtypeid = mt.medicaltermtypeid and mtt.medicaltermtypecode = 'Procedure'
                        qualify row_number() over (partition by etmt.entityid order by etmt.lastupdatedate desc) = 1
                    ),
                    
                    CTE_ProviderSubType as (
                        select ptpst.providerid, ptpst.sourcecode, ptpst.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providertoprovidersubtype ptpst on ptpst.providerid = cte_p.providerid
                        qualify row_number() over (partition by ptpst.providerid order by ptpst.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Training as (
                        select pt.providerid, pt.sourcecode, pt.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.providertraining pt on pt.providerid = cte_p.providerid
                        qualify row_number() over (partition by pt.providerid order by pt.lastupdatedate desc) = 1
                    ),
                    
                    CTE_Identification as (
                        select pid.providerid, pid.sourcecode, pid.lastupdatedate
                        from CTE_Provider cte_p
                        inner join base.provideridentification pid on pid.providerid = cte_p.providerid
                        qualify row_number() over (partition by pid.providerid order by pid.lastupdatedate desc) = 1
                    ),
                    
                    CTE_DemographicsXML as (
                        select 
                        cte_p.providerid,
                        utils.p_json_to_xml(
                            array_agg(
                                '{ '||
                                iff(cte_d.sourcecode is not null, '"SourceCode":' || '"' || cte_d.sourcecode || '"' || ',', '') ||
                                iff(cte_d.lastupdatedate is not null, '"LastUpdateDate":' || '"' || cte_d.lastupdatedate || '"', '')
                                ||' }'
                            )::varchar, 
                            'Demographics', 
                            ''
                        ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Demographics cte_d on cte_d.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_AboutMeXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                '{ '||
                                iff(cte_am.sourcecode is not null, '"SourceCode":' || '"' || cte_am.sourcecode || '"' || ',', '') ||
                                iff(cte_am.lastupdatedate is not null, '"LastUpdateDate":' || '"' || cte_am.lastupdatedate || '"', '')
                                ||' }'
                                )::varchar, 
                                'AboutMe', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_AboutMe cte_am on cte_am.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_AppointmentAvailabilityStatementXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                '{ '||
                                iff(cte_aas.sourcecode is not null, '"SourceCode":' || '"' || cte_aas.sourcecode || '"' || ',', '') ||
                                iff(cte_aas.lastupdatedate is not null, '"LastUpdateDate":' || '"' || cte_aas.lastupdatedate || '"', '')
                                ||' }'
                                )::varchar, 
                                'AppointmentAvailabilityStatement', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_AppointmentAvailabilityStatement cte_aas on cte_aas.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_EmailXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                '{ '||
                                iff(cte_e.sourcecode is not null, '"SourceCode":' || '"' || cte_e.sourcecode || '"' || ',', '') ||
                                iff(cte_e.lastupdatedate is not null, '"LastUpdateDate":' || '"' || cte_e.lastupdatedate || '"', '')
                                ||' }'
                                )::varchar, 
                                'Email', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Email cte_e on cte_e.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_LicenseXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                '{ '||
                                iff(cte_l.sourcecode is not null, '"SourceCode":' || '"' || cte_l.sourcecode || '"' || ',', '') ||
                                iff(cte_l.lastupdatedate is not null, '"LastUpdateDate":' || '"' || cte_l.lastupdatedate || '"', '')
                                ||' }'
                                )::varchar, 
                                'License', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_License cte_l on cte_l.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_OfficeXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{ '||
                                    iff(cte_o.sourcecode is not null, '"SourceCode":' || '"' || cte_o.sourcecode || '"' || ',', '') ||
                                    iff(cte_o.lastupdatedate is not null, '"LastUpdateDate":' || '"' || cte_o.lastupdatedate || '"', '')
                                    ||' }'
                                )::varchar, 
                                'Office', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Office cte_o on cte_o.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_ProviderTypeXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{ '||
                                    iff(cte_pt.sourcecode is not null, '"SourceCode":' || '"' || cte_pt.sourcecode || '"' || ',', '') ||
                                    iff(cte_pt.lastupdatedate is not null, '"LastUpdateDate":' || '"' || cte_pt.lastupdatedate || '"', '')
                                    ||' }'
                                )::varchar, 
                                'ProviderType', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_ProviderType cte_pt on cte_pt.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_StatusXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{ '||
                                    iff(cte_s.sourcecode is not null, '"SourceCode":' || '"' || cte_s.sourcecode || '"' || ',', '') ||
                                    iff(cte_s.lastupdatedate is not null, '"LastUpdateDate":' || '"' || cte_s.lastupdatedate || '"', '')
                                    ||' }'
                                )::varchar, 
                                'Status', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Status cte_s on cte_s.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_AppointmentAvailabilityXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{ '||
                                    iff(cte_aa.sourcecode is not null, '"SourceCode":' || '"' || cte_aa.sourcecode || '"' || ',', '') ||
                                    iff(cte_aa.lastupdatedate is not null, '"LastUpdateDate":' || '"' || cte_aa.lastupdatedate || '"', '')
                                    ||' }'
                                )::varchar, 
                                'AppointmentAvailability', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_AppointmentAvailability cte_aa on cte_aa.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_CertificationSpecialtyXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{ '||
                                    iff(cte_cs.sourcecode is not null, '"SourceCode":' || '"' || cte_cs.sourcecode || '"' || ',', '') ||
                                    iff(cte_cs.lastupdatedate is not null, '"LastUpdateDate":' || '"' || cte_cs.lastupdatedate || '"', '')
                                    ||' }'
                                )::varchar, 
                                'CertificationSpecialty', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_CertificationSpecialty cte_cs on cte_cs.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_FacilityXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{ '||
                                    iff(cte_f.sourcecode is not null, '"SourceCode":' || '"' || cte_f.sourcecode || '"' || ',', '') ||
                                    iff(cte_f.lastupdatedate is not null, '"LastUpdateDate":' || '"' || cte_f.lastupdatedate || '"', '')
                                    ||' }'
                                )::varchar, 
                                'Facility', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Facility cte_f on cte_f.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_ImageXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{ '||
                                    iff(cte_i.sourcecode is not null, '"SourceCode":' || '"' || cte_i.sourcecode || '"' || ',', '') ||
                                    iff(cte_i.lastupdatedate is not null, '"LastUpdateDate":' || '"' || cte_i.lastupdatedate || '"', '')
                                    ||' }'
                                )::varchar, 
                                'Image', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Image cte_i on cte_i.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_MalpracticeXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{ '||
                                    iff(cte_m.sourcecode is not null, '"SourceCode":' || '"' || cte_m.sourcecode || '"' || ',', '') ||
                                    iff(cte_m.lastupdatedate is not null, '"LastUpdateDate":' || '"' || cte_m.lastupdatedate || '"', '')
                                    ||' }'
                                )::varchar, 
                                'Malpractice', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Malpractice cte_m on cte_m.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_OrganizationXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{ '||
                                    iff(cte_o.sourcecode is not null, '"SourceCode":' || '"' || cte_o.sourcecode || '"' || ',', '') ||
                                    iff(cte_o.lastupdatedate is not null, '"LastUpdateDate":' || '"' || cte_o.lastupdatedate || '"', '')
                                    ||' }'
                                )::varchar, 
                                'Organization', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Organization cte_o on cte_o.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_SponsorshipXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{' ||
                                    iff(cte_s.sourcecode is not null, '"SourceCode":"' || cte_s.sourcecode || '"', '') ||
                                    iff(cte_s.lastupdatedate is not null, ',"LastUpdateDate":"' || cte_s.lastupdatedate || '"', '')
                                    || '}'
                                )::varchar, 
                                'Sponsorship', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Sponsorship cte_s on cte_s.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_DegreeXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{' ||
                                    iff(cte_d.sourcecode is not null, '"SourceCode":"' || cte_d.sourcecode || '"', '') ||
                                    iff(cte_d.lastupdatedate is not null, ',"LastUpdateDate":"' || cte_d.lastupdatedate || '"', '')
                                    || '}'
                                )::varchar, 
                                'Degree', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Degree cte_d on cte_d.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_EducationXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{' ||
                                    iff(cte_e.sourcecode is not null, '"SourceCode":"' || cte_e.sourcecode || '"', '') ||
                                    iff(cte_e.lastupdatedate is not null, ',"LastUpdateDate":"' || cte_e.lastupdatedate || '"', '')
                                    || '}'
                                )::varchar, 
                                'Education', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Education cte_e on cte_e.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_HealthInsuranceXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{' ||
                                    iff(cte_hi.sourcecode is not null, '"SourceCode":"' || cte_hi.sourcecode || '"', '') ||
                                    iff(cte_hi.lastupdatedate is not null, ',"LastUpdateDate":"' || cte_hi.lastupdatedate || '"', '') 
                                    || '}'
                                )::varchar, 
                                'HealthInsurance', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_HealthInsurance cte_hi on cte_hi.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_LanguageXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{' ||
                                    iff(cte_l.sourcecode is not null, '"SourceCode":"' || cte_l.sourcecode || '"', '') ||
                                    iff(cte_l.lastupdatedate is not null, ',"LastUpdateDate":"' || cte_l.lastupdatedate || '"', '') 
                                    || '}'
                                )::varchar, 
                                'Language', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Language cte_l on cte_l.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_MediaXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{' ||
                                    iff(cte_m.sourcecode is not null, '"SourceCode":"' || cte_m.sourcecode || '"', '') ||
                                    iff(cte_m.lastupdatedate is not null, ',"LastUpdateDate":"' || cte_m.lastupdatedate || '"', '') 
                                    || '}'
                                )::varchar, 
                                'Media', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Media cte_m on cte_m.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    
                    CTE_SpecialtyXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{' ||
                                    iff(cte_s.sourcecode is not null, '"SourceCode":"' || cte_s.sourcecode || '"', '') ||
                                    iff(cte_s.lastupdatedate is not null, ',"LastUpdateDate":"' || cte_s.lastupdatedate || '"', '') 
                                    || '}'
                                )::varchar, 
                                'Specialty', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Specialty cte_s on cte_s.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_VideoXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{' ||
                                    iff(cte_v.sourcecode is not null, '"SourceCode":"' || cte_v.sourcecode || '"', '') ||
                                    iff(cte_v.lastupdatedate is not null, ',"LastUpdateDate":"' || cte_v.lastupdatedate || '"', '') 
                                    || '}'
                                )::varchar, 
                                'Video', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Video cte_v on cte_v.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_TelehealthXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{' ||
                                    iff(cte_th.sourcecode is not null, '"SourceCode":"' || cte_th.sourcecode || '"', '') ||
                                    iff(cte_th.lastupdatedate is not null, ',"LastUpdateDate":"' || cte_th.lastupdatedate || '"', '') 
                                    || '}'
                                )::varchar, 
                                'Telehealth', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Telehealth cte_th on cte_th.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_ConditionXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{' ||
                                    iff(cte_c.sourcecode is not null, '"SourceCode":"' || cte_c.sourcecode || '"', '') ||
                                    iff(cte_c.lastupdatedate is not null, ',"LastUpdateDate":"' || cte_c.lastupdatedate || '"', '') 
                                    || '}'
                                )::varchar, 
                                'Condition', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Condition cte_c on cte_c.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_ProcedureXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{' ||
                                    iff(cte_pr.sourcecode is not null, '"SourceCode":"' || cte_pr.sourcecode || '"', '') ||
                                    iff(cte_pr.lastupdatedate is not null, ',"LastUpdateDate":"' || cte_pr.lastupdatedate || '"', '') 
                                    || '}'
                                )::varchar, 
                                'Procedure', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Procedure cte_pr on cte_pr.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_ProviderSubTypeXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{' ||
                                    iff(cte_pst.sourcecode is not null, '"SourceCode":"' || cte_pst.sourcecode || '"', '') ||
                                    iff(cte_pst.lastupdatedate is not null, ',"LastUpdateDate":"' || cte_pst.lastupdatedate || '"', '') 
                                    || '}'
                                )::varchar, 
                                'ProviderSubType', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_ProviderSubType cte_pst on cte_pst.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_TrainingXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{' ||
                                    iff(cte_t.sourcecode is not null, '"SourceCode":"' || cte_t.sourcecode || '"', '') ||
                                    iff(cte_t.lastupdatedate is not null, ',"LastUpdateDate":"' || cte_t.lastupdatedate || '"', '') 
                                    || '}'
                                )::varchar, 
                                'Training', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Training cte_t on cte_t.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_IdentificationXML as (
                        select 
                            cte_p.providerid,
                            utils.p_json_to_xml(
                                array_agg(
                                    '{' ||
                                    iff(cte_i.sourcecode is not null, '"SourceCode":"' || cte_i.sourcecode || '"', '') ||
                                    iff(cte_i.lastupdatedate is not null, ',"LastUpdateDate":"' || cte_i.lastupdatedate || '"', '') 
                                    || '}'
                                )::varchar, 
                                'Identification', 
                                ''
                            ) as XML
                        from CTE_Provider cte_p
                        inner join CTE_Identification cte_i on cte_i.providerid = cte_p.providerid
                        group by cte_p.providerid
                    ),
                    
                    CTE_FinalXML as (
                        select distinct
                            cte_p.providerid,
                            '<LastUpdateDateBySwimlane>' || 
                            COALESCE(cte_d.xml, '') ||
                            COALESCE(cte_am.xml, '') ||
                            COALESCE(cte_aas.xml, '') ||
                            COALESCE(cte_e.xml, '') ||
                            COALESCE(cte_l.xml, '') ||
                            COALESCE(cte_o.xml, '') ||
                            COALESCE(cte_pt.xml, '') ||
                            COALESCE(cte_s.xml, '') ||
                            COALESCE(cte_aa.xml, '') ||
                            COALESCE(cte_cs.xml, '') ||
                            COALESCE(cte_f.xml, '') ||
                            COALESCE(cte_i.xml, '') ||
                            COALESCE(cte_m.xml, '') ||
                            COALESCE(cte_org.xml, '') ||
                            COALESCE(cte_sp.xml, '') ||
                            COALESCE(cte_deg.xml, '') ||
                            COALESCE(cte_edu.xml, '') ||
                            COALESCE(cte_hi.xml, '') ||
                            COALESCE(cte_lang.xml, '') ||
                            COALESCE(cte_med.xml, '') ||
                            COALESCE(cte_spec.xml, '') ||
                            COALESCE(cte_v.xml, '') ||
                            COALESCE(cte_th.xml, '') ||
                            COALESCE(cte_c.xml, '') ||
                            COALESCE(cte_pr.xml, '') ||
                            COALESCE(cte_pst.xml, '') ||
                            COALESCE(cte_t.xml, '') ||
                            COALESCE(cte_iid.xml, '') ||
                            '</LastUpdateDateBySwimlane>' as LastUpdateDatePayload
                        from CTE_Provider cte_p
                        left join CTE_DemographicsXML cte_d on cte_d.providerid = cte_p.providerid
                        left join CTE_AboutMeXML cte_am on cte_am.providerid = cte_p.providerid
                        left join CTE_AppointmentAvailabilityStatementXML cte_aas on cte_aas.providerid = cte_p.providerid
                        left join CTE_EmailXML cte_e on cte_e.providerid = cte_p.providerid
                        left join CTE_LicenseXML cte_l on cte_l.providerid = cte_p.providerid
                        left join CTE_OfficeXML cte_o on cte_o.providerid = cte_p.providerid
                        left join CTE_ProviderTypeXML cte_pt on cte_pt.providerid = cte_p.providerid
                        left join CTE_StatusXML cte_s on cte_s.providerid = cte_p.providerid
                        left join CTE_AppointmentAvailabilityXML cte_aa on cte_aa.providerid = cte_p.providerid
                        left join CTE_CertificationSpecialtyXML cte_cs on cte_cs.providerid = cte_p.providerid
                        left join CTE_FacilityXML cte_f on cte_f.providerid = cte_p.providerid
                        left join CTE_ImageXML cte_i on cte_i.providerid = cte_p.providerid
                        left join CTE_MalpracticeXML cte_m on cte_m.providerid = cte_p.providerid
                        left join CTE_OrganizationXML cte_org on cte_org.providerid = cte_p.providerid
                        left join CTE_SponsorshipXML cte_sp on cte_sp.providerid = cte_p.providerid
                        left join CTE_DegreeXML cte_deg on cte_deg.providerid = cte_p.providerid
                        left join CTE_EducationXML cte_edu on cte_edu.providerid = cte_p.providerid
                        left join CTE_HealthInsuranceXML cte_hi on cte_hi.providerid = cte_p.providerid
                        left join CTE_LanguageXML cte_lang on cte_lang.providerid = cte_p.providerid
                        left join CTE_MediaXML cte_med on cte_med.providerid = cte_p.providerid
                        left join CTE_SpecialtyXML cte_spec on cte_spec.providerid = cte_p.providerid
                        left join CTE_VideoXML cte_v on cte_v.providerid = cte_p.providerid
                        left join CTE_TelehealthXML cte_th on cte_th.providerid = cte_p.providerid
                        left join CTE_ConditionXML cte_c on cte_c.providerid = cte_p.providerid
                        left join CTE_ProcedureXML cte_pr on cte_pr.providerid = cte_p.providerid
                        left join CTE_ProviderSubTypeXML cte_pst on cte_pst.providerid = cte_p.providerid
                        left join CTE_TrainingXML cte_t on cte_t.providerid = cte_p.providerid
                        left join CTE_IdentificationXML cte_iid on cte_iid.providerid = cte_p.providerid
                    )

                    select ProviderID, LastUpdateDatePayload
                    from CTE_FinalXML
                    $$;


insert_statement := $$ 
                    insert
                        (
                        ProviderID, 
                        LastUpdateDatePayload
                        )
                     values 
                        (
                        source.providerid, 
                        TO_VARIANT(source.lastupdatedatepayload)
                        )
                     $$;

update_statement := $$
                    update SET target.lastupdatedatepayload = TO_VARIANT(source.lastupdatedatepayload)
                    $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := $$ merge into base.providerlastupdatedate as target 
                    using ($$||select_statement||$$) as source 
                   on source.providerid = target.providerid
                   WHEN MATCHED then $$||update_statement||$$
                   when not matched then $$ ||insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderLastUpdateDate;
end if; 
execute immediate merge_statement;

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