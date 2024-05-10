CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRAutosuggestRefData()
RETURNS varchar(16777216)
LANGUAGE SQL
EXECUTE as CALLER
as 
declare 

---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------

--- show.solrautosuggestrefdata depends on:
-- base.gender
-- base.suffix
-- base.providertype
-- base.substatus
-- base.identificationtype
-- base.position
-- base.language
-- base.aboutme
-- base.appointmentavailability
-- base.hgproceduregroup
-- base.specialtygroup
-- base.certificationboard
-- base.certificationagency
-- base.certificationstatus
-- base.surveysuppressionreason2
-- base.locationtype
-- base.nation
-- base.licensetype
-- base.healthinsuranceplan
-- base.clienttoproduct
-- base.client
-- base.product
-- base.productgroup
-- base.educationinstitutiontype
-- base.healthinsuranceplantoplantype
-- base.healthinsuranceplantype
-- base.healthinsurancepayor
-- base.certificationagencytoboardtospecialty
-- base.certificationspecialty
-- base.displaystatus
-- base.popularsearchterm (from dbo schema)

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

create_temp_statement string;

select_statement_union string;
-- these are the xml selects
select_statement_payor string;
select_statement_product string;
select_statement_certspec string;
select_statement_dispstatus string;
    procedure_name varchar(50) default('sp_load_solrautosuggestrefdata');
    execution_start datetime default getdate();


insert_statement_union string; 
-- these are the xml inserts
insert_statement_payor string; 
insert_statement_product string;
insert_statement_certspec string;
insert_statement_dispstatus string;

-- main statements from the temp table
select_statement string; -- select statement for the merge
insert_statement string; -- insert statement for the merge
update_statement string; -- update statement for the merge
merge_statement string; -- merge statement to final table
status string; -- status monitoring
begin

---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------  

create_temp_statement := $$
                         CREATE or REPLACE TEMPORARY TABLE show.tempautosuggestrefdata as
                         select Code, Description, Definition, Rank, TermID, AutoType, RelationshipXML, UpdatedDate, UpdatedSource
                         from show.solrautosuggestrefdata
                         LIMIT 0;
                         $$;

select_statement_union :=   $$
                            select Code, Description, Definition, Rank, TermID, AutoType
                            from
                                (
                                select 
                                    GenderCode as Code,
                                    GenderDescription as Description, 
                                    null as Definition,
                                    null as Rank,
                                    GenderID as TermID,
                                    'GENDER' as AutoType
                                from base.gender
                                
                                union
                                
                                select
                                    SuffixAbbreviation as Code,
                                    null as Description,
                                    null as Definition,
                                    null as Rank,
                                    SuffixID as TermID,
                                    'SUFFIX' as AutoType
                                from base.suffix
                                
                                union
                                
                                select
                                    ProviderTypeCode as Code,
                                    ProviderTypeDescription as Description,
                                    null as Definition,
                                    null as Rank,
                                    ProviderTypeID as TermID,
                                    'PROVIDERTYPE' as AutoType
                                from base.providertype
                                
                                union
                                
                                select
                                    SubStatusCode as Code,
                                    SubStatusDescription as Description,
                                    null as Definition,
                                    SubStatusRank as Rank,
                                    SubStatusID as TermID,
                                    'SUBSTATUS' as AutoType
                                from base.substatus
                            
                                union
                                
                                select
                                    IdentificationTypeCode as Code,
                                    IdentificationTypeDescription as Description,
                                    null as Definition,
                                    null as Rank,
                                    IdentificationTypeID as TermID,
                                    'IDENTIFICATIONTYPE' as AutoType
                                from base.identificationtype
                                
                                union 
                                
                                select
                                    PositionCode as Code,
                                    PositionDescription as Description,
                                    null as Definition,
                                    refRank as Rank,
                                    PositionID as TermID,
                                    'POSITION' as AutoType
                                from base.position
                                
                                union
                                
                                select
                                    LanguageCode as Code,
                                    LanguageName as Description,
                                    null as Definition,
                                    null as Rank,
                                    LanguageID as TermID,
                                    'LANGUAGE' as AutoType
                                from base.language
                                
                                union
                                
                                select
                                    AboutMeCode as Code,
                                    AboutMeDescription as Description,
                                    null as Definition,
                                    DisplayOrder as Rank,
                                    AboutMeID as TermID,
                                    'ABOUTME' as AutoType
                                from base.aboutme
                                
                                union
                                
                                select
                                    AppointmentAvailabilityCode as Code,
                                    AppointmentAvailabilityDescription as Description,
                                    null as Definition,
                                    null as Rank,
                                    AppointmentAvailabilityID as TermID,
                                    'APPOINTMEMT' as AutoType
                                from base.appointmentavailability
                                
                                union
                                
                                select
                                    HGProcedureGroupCode as Code,
                                    HGProcedureGroupDisplayDescription as Description,
                                    null as Definition,
                                    null as Rank,
                                    HGProcedureGroupID as TermID,
                                    'PROCGROUP' as AutoType
                                from base.hgproceduregroup
                                where IsActive = 1
                            
                                union
                                
                                select
                                    SpecialtyGroupCode as Code,
                                    SpecialtyGroupDescription as Description,
                                    null as Definition,
                                    Rank as Rank,
                                    SpecialtyGroupID as TermID,
                                    'SPECGROUP' as AutoType
                                from base.specialtygroup
                                
                                union
                                
                                select
                                    CertificationBoardCode as Code,
                                    CertificationBoardDescription as Description,
                                    null as Definition,
                                    null as Rank,
                                    CertificationBoardID as TermID,
                                    'CERTBOARD' as AutoType
                                from base.certificationboard
                                
                                union
                                
                                select
                                    CertificationAgencyCode as Code,
                                    CertificationAgencyDescription as Description,
                                    null as Definition,
                                    null as Rank,
                                    CertificationAgencyID as TermID,
                                    'CERTAGENCY' as AutoType
                                from base.certificationagency
                                
                                union
                                
                                select
                                    CertificationStatusCode as Code,
                                    CertificationStatusDescription as Description,
                                    null as Definition,
                                    Rank as Rank,
                                    CertificationStatusID as TermID,
                                    'CERTSTATUS' as AutoType
                                from base.certificationstatus
                                
                                union
                                
                                select
                                    SuppressionReasonCode as Code,
                                    SuppressionReasonDescription as Description,
                                    null as Definition,
                                    null as Rank,
                                    SurveySuppressionReasonID as TermID,
                                    'SURVEYSUPPRESSREASON' as AutoType
                                from base.surveysuppressionreason2
                                
                                union
                                
                                select
                                    LocationTypeCode as Code,
                                    LocationTypeDescription as Description,
                                    null as Definition,
                                    null as Rank,
                                    LocationTypeID as TermID,
                                    'LOCATIONTYPE' as AutoType
                                from base.locationtype
                                
                                union
                                
                                select
                                    NationCode as Code,
                                    NationName as Description,
                                    null as Definition,
                                    null as Rank,
                                    NationID as TermID,
                                    'NATION' as AutoType
                                from base.nation
                                
                                union
                                
                                select
                                    LicenseTypeCode as Code,
                                    LicenseTypeDescription as Description,
                                    null as Definition,
                                    null as Rank,
                                    LicenseTypeID as TermID,
                                    'LICENSETYPE' as AutoType
                                from base.licensetype
                                
                                union
                                
                                select 
                                    PlanCode as Code,
                                    PLanDisplayName as Description,
                                    null as Definition,
                                    null as Rank,
                                    HealthInsurancePlanID as TermID,
                                    'INSURANCEPLAN' as AutoType
                                from base.healthinsuranceplan
                                
                                union
                                
                                select
                                    c.clientcode as Code,
                                    c.clientname as Description,
                                    p.productcode as Definition,
                                    null as Rank,
                                    c.clientid as TermID,
                                    'CLIENT' as AutoType
                                from base.clienttoproduct cp
                                join base.client c on cp.clientid = c.clientid
                                join base.product p on cp.productid = p.productid
                                join base.productgroup pg on p.productgroupid = pg.productgroupid
                                where cp.activeflag = 1
                            
                                union
                                
                                select
                                    EducationInstitutionTypeCode as Code,
                                    EducationInstitutionTypeCode as Description,
                                    null as Definition,
                                    null as Rank,
                                    EducationInstitutionTypeID as TermID,
                                    'EDUCATIONTYPE' as AutoType
                                from base.educationinstitutiontype
                                
                                union
                                
                                select
                                    'DOCSPECLABEL' as Code,
                                    'Specialties' as Description,
                                    null as Definition,
                                    null as Rank,
                                    uuid_string() as TermID,
                                    'SPECLABEL' as AutoType
                                
                                union
                                
                                select
                                    'ALTSPECLABEL' as Code,
                                    'Specialties' as Description,
                                    null as Definition,
                                    null as Rank,
                                    uuid_string() as TermID,
                                    'SPECLABEL' as AutoType
                                
                                union
                                
                                select
                                    'DENTSPECLABEL' as Code,
                                    'Practice Areas' as Description,
                                    null as Definition,
                                    null as Rank,
                                    uuid_string() as TermID,
                                    'SPECLABEL' as AutoType
                                
                                union
                                
                                select
                                    'DOCPRACSPECLABEL' as Code,
                                    'Practicing Specialties' as Description,
                                    null as Definition,
                                    null as Rank,
                                    uuid_string() as TermID,
                                    'SPECLABEL' as AutoType
                                
                                union
                                
                                select
                                    'ALTPRACSPECLABEL' as Code,
                                    'Practicing Specialties' as Description,
                                    null as Definition,
                                    null as Rank,
                                    uuid_string() as TermID,
                                    'SPECLABEL' as AutoType
                                
                                union
                                
                                select
                                    'DENTPRACSPECLABEL' as Code,
                                    'Practice Areas' as Description,
                                    null as Definition,
                                    null as Rank,
                                    uuid_string() as TermID,
                                    'SPECLABEL' as AutoType
                                
                                union
                            
                                -- * THIS is THE TABLE THAT CAME from DBO SCHEMA * --
                                select
                                    TermCode as Code,
                                    TermDescription as Description,
                                    TermType as Definition,
                                    Rank as Rank,
                                    PopularSearchTermID as TermID,
                                    'POPULARSEARCHTERM' as AutoType
                                from base.popularsearchterm
                            
                                ) a;

                            $$;

select_statement_payor := $$

                          with cte_base as (
                            select distinct d.insurancepayorcode, e.healthinsuranceplanid, c.productname
                            from base.healthinsuranceplantoplantype c 
                            join base.healthinsuranceplan e on e.healthinsuranceplanid=c.healthinsuranceplanid
                            join base.healthinsuranceplantype f on f.healthinsuranceplantypeid=c.healthinsuranceplantypeid
                            join base.healthinsurancepayor d on d.healthinsurancepayorid=e.healthinsurancepayorid
                          ),
                        
                         cte_rel as (
                            select
                              pay.insurancepayorcode as InsurancePayorCode,
                              ipr.insuranceproductcode as productCd,
                              ipr.healthinsuranceplantoplantypeid as productId,
                              ipl.plancode as planCd,
                              ipl.planname as planNm,
                              ipt.plantypecode as planTpCd,
                              ipt.plantypedescription as planTpNm,
                              b.productname  as pktdokPlNm
                            from base.healthinsuranceplantoplantype ipr 
                              join base.healthinsuranceplan ipl on ipr.healthinsuranceplanid = ipl.healthinsuranceplanid
                              join base.healthinsuranceplantype ipt on ipr.healthinsuranceplantypeid = ipt.healthinsuranceplantypeid
                              join base.healthinsurancepayor pay on pay.healthinsurancepayorid = ipl.healthinsurancepayorid
                              left join cte_base b on b.insurancepayorcode = pay.insurancepayorcode and b.healthinsuranceplanid = ipr.healthinsuranceplanid 
                          ),
                        
                          cte_rel_xml as (
                              select 
                                InsurancePayorCode,
                                TO_VARIANT(utils.p_json_to_xml(
                                    array_agg(
                                    REPLACE(
                                    '{ '||
                                    iff(cte_rel.productcd is not null, '"productCd":' || '"' || cte_rel.productcd || '"' || ',', '') ||
                                    iff(cte_rel.productid is not null, '"productId":' || '"' || cte_rel.productid || '"' || ',', '') ||
                                    iff(cte_rel.plancd is not null, '"planCd":' || '"' || cte_rel.plancd || '"' || ',', '') ||
                                    iff(cte_rel.plannm is not null, '"planNm":' || '"' || replace(cte_rel.plannm,'\"','') || '"' || ',', '') || -- 
                                    iff(cte_rel.plantpcd is not null, '"planTpCd":' || '"' || cte_rel.plantpcd || '"' || ',', '') ||
                                    iff(cte_rel.plantpnm is not null, '"planTpNm":' || '"' || cte_rel.plantpnm || '"' || ',', '') ||
                                    iff(cte_rel.pktdokplnm is not null, '"pktdokPlNm":' || '"' || replace(cte_rel.pktdokplnm,'\"','') || '"', '') --
                                    ||' }'
                                    ,'\'','\\\'')
                                    )::varchar,
                                    'insuranceL',
                                    'insurance'
                                )) as RelationshipXML
                                from cte_rel
                                group by InsurancePayorCode
                            )
                        
                            select 
                                ip.insurancepayorcode as Code, -- col 1
                                ip.payorname as Description, -- col 2
                                null as Definition, -- col 3
                                null as Rank, -- col 4
                                ip.healthinsurancepayorid as TermID, -- col 5
                                'INSURANCEPAYOR' as AutoType, -- col 6 
                                r.relationshipxml as RelationshipXML
                            from base.healthinsurancepayor ip
                            left join cte_rel_xml r on r.insurancepayorcode = ip.insurancepayorcode;
                          $$;

select_statement_product := $$
                            with cte_rel as (
                            select
                              ip.healthinsuranceplantoplantypeid,
                              ipa.insurancepayorcode as payorCd,
                              ipa.payorname as payorNm,
                              ipl.plancode as planCd,
                              ipl.planname as planNm,
                              ipt.plantypecode as planTpCd,
                              ipt.plantypedescription as planTpNm,
                            from base.healthinsurancepayor ipa 
                                 inner join base.healthinsuranceplan ipl on ipa.healthinsurancepayorid = ipl.healthinsurancepayorid
                                 inner join base.healthinsuranceplantoplantype ip on ip.healthinsuranceplanid = ipl.healthinsuranceplanid 
                                 inner join base.healthinsuranceplantype ipt on ip.healthinsuranceplantypeid = ipt.healthinsuranceplantypeid
                            ),
                        
                            cte_rel_xml as (
                              select 
                                HealthInsurancePlanToPlanTypeID,
                                TO_VARIANT(utils.p_json_to_xml(
                                    array_agg(
                                    REPLACE(
                                    '{ '||
                                    iff(cte_rel.payorcd is not null, '"payorCd":' || '"' || cte_rel.payorcd || '"' || ',', '') ||
                                    iff(cte_rel.payornm is not null, '"payorNm":' || '"' || cte_rel.payornm || '"' || ',', '') ||
                                    iff(cte_rel.plancd is not null, '"planCd":' || '"' || cte_rel.plancd || '"' || ',', '') ||
                                    iff(cte_rel.plannm is not null, '"planNm":' || '"' || replace(cte_rel.plannm,'\"','') || '"' || ',', '') || 
                                    iff(cte_rel.plantpcd is not null, '"planTpCd":' || '"' || cte_rel.plantpcd || '"' || ',', '') ||
                                    iff(cte_rel.plantpnm is not null, '"planTpNm":' || '"' || cte_rel.plantpnm || '"' || ',', '') 
                                    ||' }'
                                    ,'\'','\\\'')
                                    )::varchar,
                                    'insuranceL',
                                    'insurance'
                                )) as RelationshipXML
                                from cte_rel
                                group by HealthInsurancePlanToPlanTypeID
                             )
                        
                            select 
                                ipr.insuranceproductcode as Code, -- col 1
                                null as Description, -- col 2
                                null as Definition, -- col 3
                                null as Rank, -- col 4
                                ipr.healthinsuranceplantoplantypeid as TermID, -- col 5
                                'INSURANCEPRODUCT' as AutoType, -- col 6 
                                r.relationshipxml as RelationshipXML
                            from base.healthinsuranceplantoplantype ipr 
                            left join cte_rel_xml r on r.healthinsuranceplantoplantypeid = ipr.healthinsuranceplantoplantypeid;
    
                            $$;

select_statement_certspec := $$

                            with cte_rel as (
                                select
                                distinct RTRIM(b.certificationagencycode) as caCd, 
                                         b.certificationagencydescription as caD, 
                                         RTRIM(c.certificationboardcode) as cbCd, 
                                         c.certificationboarddescription as cbD,
                                         a.certificationspecialtyid as CertificationSpecialtyID
                                from base.certificationagencytoboardtospecialty a
                                join base.certificationagency b on a.certificationagencyid = b.certificationagencyid
                                join base.certificationboard c on a.certificationboardid = c.certificationboardid
                            ),
                        
                            cte_rel_xml as (
                              select 
                                CertificationSpecialtyID,
                                TO_VARIANT(utils.p_json_to_xml(
                                    array_agg(
                                    REPLACE(
                                    '{ '||
                                    iff(cte_rel.cacd is not null, '"caD":' || '"' || cte_rel.cacd || '"' || ',', '') ||
                                    iff(cte_rel.cad is not null, '"caD":' || '"' || cte_rel.cad || '"' || ',', '') ||
                                    iff(cte_rel.cbcd is not null, '"cbCd":' || '"' || cte_rel.cbcd || '"' || ',', '') ||
                                    iff(cte_rel.cbd is not null, '"cbD":' || '"' || replace(cte_rel.cbd,'\"','') || '"' || ',', '') 
                                    ||' }'
                                    ,'\'','\\\'')
                                    )::varchar,
                                    'certL',
                                    'cert'
                                )) as RelationshipXML
                                from cte_rel
                                group by CertificationSpecialtyID
                             )
                        
                            select 
                                CertificationSpecialtyCode as Code, -- col 1
                                CertificationSpecialtyDescription as Description, -- col 2
                                null as Definition, -- col 3
                                null as Rank, -- col 4
                                s.certificationspecialtyid as TermID, -- col 5
                                'CERTIFICATIONSPEC' as AutoType, -- col 6 
                                r.relationshipxml as RelationshipXML
                            from base.certificationspecialty s 
                            left join cte_rel_xml r on r.certificationspecialtyid = s.certificationspecialtyid;
                            $$;

select_statement_dispstatus := $$
                    
                            with cte_rel as (
                                select SubStatusCode as SubStatusCode, 
                                       SubStatusDescription as SubStatusDesc,
                                       b.displaystatuscode as DisplayStatusCode
                                from base.substatus a
                                join base.displaystatus b on b.displaystatusid = a.displaystatusid
                            ),
                        
                            cte_rel_xml as (
                              select 
                                DisplayStatusCode,
                                TO_VARIANT(utils.p_json_to_xml(
                                    array_agg(
                                    REPLACE(
                                    '{ '||
                                    iff(cte_rel.substatuscode is not null, '"SubStatusCode":' || '"' || cte_rel.substatuscode || '"' || ',', '') ||
                                    iff(cte_rel.substatusdesc is not null, '"SubStatusDesc":' || '"' || cte_rel.substatusdesc || '"' || ',', '')
                                    ||' }'
                                    ,'\'','\\\'')
                                    )::varchar,
                                    'subStatusL',
                                    'subStatus'
                                )) as RelationshipXML
                                from cte_rel
                                group by DisplayStatusCode
                             )
                        
                            select 
                                ds.displaystatuscode as Code, -- col 1
                                DisplayStatusDescription as Description, -- col 2
                                null as Definition, -- col 3
                                DisplayStatusRank as Rank, -- col 4
                                DisplayStatusID as TermID, -- col 5
                                'DISPLAYSTATUS' as AutoType, -- col 6 
                                r.relationshipxml as RelationshipXML
                            from base.displaystatus ds 
                            left join cte_rel_xml r on r.displaystatuscode = ds.displaystatuscode;
    
                            $$;
        
                        
insert_statement_union := $$
                          insert INTO show.tempautosuggestrefdata (Code, Description, Definition, Rank, TermID, AutoType) 
                          $$
                          || select_statement_union;

insert_statement_payor := $$
                          insert INTO show.tempautosuggestrefdata (Code, Description, Definition, Rank, TermID, AutoType, RelationshipXML) 
                          $$
                          || select_statement_payor;

insert_statement_product := $$
                          insert INTO show.tempautosuggestrefdata (Code, Description, Definition, Rank, TermID, AutoType, RelationshipXML) 
                          $$
                          || select_statement_product;

insert_statement_certspec := $$
                          insert INTO show.tempautosuggestrefdata (Code, Description, Definition, Rank, TermID, AutoType, RelationshipXML) 
                          $$
                          || select_statement_certspec;

insert_statement_dispstatus := $$
                          insert INTO show.tempautosuggestrefdata (Code, Description, Definition, Rank, TermID, AutoType, RelationshipXML) 
                          $$
                          || select_statement_dispstatus;


insert_statement :=     $$
                        insert (
                                   Code,
                                   Description,
                                   Definition,
                                   Rank,
                                   TermID,
                                   AutoType,
                                   RelationshipXML,
                                   UpdatedDate,
                                   UpdatedSource
                                 )
                          values (	
                                   source.code,
                                   source.description,
                                   source.definition,
                                   source.rank,
                                   source.termid,
                                   source.autotype,
                                   source.relationshipxml,
                                   current_timestamp(),
                                   CURRENT_USER()
                                )
                        $$;

update_statement :=     $$
                        update SET target.code = source.code,
                                     target.description = source.description,
                                     target.definition = source.definition,
                                     target.rank = source.rank,
                                     target.termid = source.termid,
                                     target.autotype = source.autotype,
                                     target.relationshipxml = source.relationshipxml,
                                     target.updateddate = current_timestamp(),
                                     target.updatedsource = CURRENT_USER()
                        $$;

merge_statement :=      $$
                        merge into show.solrautosuggestrefdata as target 
                        using (
                              select Code, Description, Definition, Rank, TermID, AutoType, RelationshipXML, UpdatedDate, UpdatedSource
                              from show.tempautosuggestrefdata
                              ) as source
                        on source.termid = target.termid
                        WHEN MATCHED and source.code = target.code and source.description = target.description
                            and source.definition = target.definition and source.rank = target.rank 
                            and source.autotype = target.autotype then $$ || update_statement || $$ 
                        when not matched then $$ || insert_statement;


---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 

execute immediate create_temp_statement; 
-- inserting xmls to temp table
execute immediate insert_statement_union; 
execute immediate insert_statement_payor;
execute immediate insert_statement_product;
execute immediate insert_statement_certspec;
execute immediate insert_statement_dispstatus;
-- final merge from temp
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