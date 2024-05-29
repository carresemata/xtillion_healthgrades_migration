CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDERFACILITY(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

-- mid.providerfacility depends on:
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.tempspecialtytoservicelineghetto
--- base.specialtygroup
--- base.medicalterm 
--- base.medicaltermtype
--- base.vwuproviderspecialty
--- base.facility
--- base.award 
--- base.awardcategory 
--- base.facilityimage 
--- base.mediaimagetype 
--- base.mediasize 
--- base.clienttoproduct 
--- base.client  
--- base.product 
--- base.productgroup 
--- base.clientproducttoentity 
--- base.entitytype 
--- base.cliententitytoclientfeature 
--- base.clientfeaturetoclientfeaturevalue 
--- base.clientfeature 
--- base.clientfeaturevalue 
--- base.providertofacility
--- base.clientproductentitytourl (base.vwupdcfacilitydetail)
--- base.urltype (base.vwupdcfacilitydetail)
--- base.url (base.vwupdcfacilitydetail)
--- Base.ClientProductEntityToPhone (base.vwupdcfacilitydetail)
--- Base.PhoneType (base.vwupdcfacilitydetail)
--- Base.Phone (base.vwupdcfacilitydetail)
--- Base.ClientProductImage (base.vwupdcclientdetail)
--- base.providerrole
--- mid.facility
--- ermart1.facility_facilityparentchild 
--- ermart1.facility_facility
--- ermart1.facility_facilitytoprocedurerating 
--- ermart1.facility_vwufacilityhgdisplayprocedures 
--- ermart1.facility_proceduretoserviceline 
--- ermart1.facility_serviceline 
--- ermart1.facility_facilitytoservicelinerating
--- ermart1.facility_procedure 
--- ermart1.facility_facilitytoaward 
--- ermart1.facility_facilityaddressdetail

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providerfacility');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin

--- Select Statement

select_statement := $$ with CTE_ProviderBatch as (
                select
                    p.providerid
                from
                    $$ || mdm_db || $$.mst.Provider_Profile_Processing as ppp
                    join base.provider as P on p.providercode = ppp.ref_provider_code),
                    cte_servicelinespecialty as (
    select 
        temp.servicelinecode,
        sg.legacykey,
        temp.specialtycode as medicaltermcode
    from base.tempspecialtytoservicelineghetto as temp
    inner join base.specialtygroup as sg on sg.specialtygroupcode = temp.specialtycode 
),
cte_parentchild as (
    select
        fpc.facilityidparent,
        fpc.facilityidchild,
        f.name as childfacilityname,
        1 as currentmerge
    from
        ermart1.facility_facilityparentchild fpc
        join ermart1.facility_facility f on fpc.facilityidchild = f.facilityid
    where
        fpc.ismaxyear = 1
        and f.isclosed = 0

    union all

    select
        fpc.facilityidparent,
        fpc.facilityidchild,
        f.name as childfacilityname,
        0 as currentmerge
    from
        ermart1.facility_facilityparentchild fpc
        join ermart1.facility_facility f on fpc.facilityidchild = f.facilityid
    where
        fpc.ismaxyear = 0
        and f.isclosed = 0
),
cte_serviceline as (
select 
    mt.medicaltermcode as servicelinecode, 
    mt.legacykey, 
    mt.medicaltermdescription1 as servicelinedescription
from 
    base.medicalterm mt
    join base.medicaltermtype mtt on mt.medicaltermtypeid = mtt.medicaltermtypeid
where 
    mtt.medicaltermtypecode = 'SERVICELINE'),

cte_ermartfacility as (
select
    fpr.facilityid,
    fpr.procedureid,
    fpr.ratingsourceid,
    fpr.ismaxyear,
    sl.servicelinecode,
    sl.servicelinedescription,
    sl.legacykey
from
    ermart1.facility_facilitytoprocedurerating fpr
    join ermart1.facility_vwufacilityhgdisplayprocedures fdp on fpr.procedureid = fdp.procedureid and fpr.ratingsourceid = fdp.ratingsourceid
    join ermart1.facility_proceduretoserviceline psl on fdp.procedureid = psl.procedureid
    join ermart1.facility_serviceline fsl on psl.servicelineid = fsl.servicelineid
    left join ermart1.facility_facilitytoservicelinerating fsr on fsl.servicelineid = fsr.servicelineid and fpr.facilityid = fsr.facilityid 
    join cte_serviceline as sl on ('SL' + fsl.servicelineid = sl.legacykey)
where
    fpr.ismaxyear = 1
),
cte_cohort as (
select
            mt.medicaltermcode as procedurecode,
            mt.legacykey,
            mt.medicaltermdescription1 as proceduredescription
        from
            base.medicalterm mt
            join base.medicaltermtype mtt on mt.medicaltermtypeid = mtt.medicaltermtypeid
        where
            mtt.medicaltermtypecode = 'COHORT'
),
cte_ratingsortvalue as (
select
    avg(
        (ifnull(fpr.overallsurvivalstar, 1) * ifnull(fpr.overallrecovery30star, 1))
        + (0.5 * ifnull(fpr.overallsurvivalstar, 0.001))
        + (ifnull(fpr.overallrecovery30star, 0.001))
    )
    + ((count(fpr.overallsurvivalstar) + count(fpr.overallrecovery30star)) * 0.25) as average_score
from
    ermart1.facility_facilitytoprocedurerating fpr
    join ermart1.facility_procedure b on fpr.procedureid = b.procedureid
    join ermart1.facility_proceduretoserviceline y on fpr.procedureid = y.procedureid
    join cte_cohort co on y.procedureid = co.legacykey
    join cte_ermartfacility as erfa on fpr.facilityid = erfa.facilityid
    and fpr.ismaxyear = erfa.ismaxyear
    and 'SL' || y.servicelineid = erfa.legacykey
    and fpr.ratingsourceid = erfa.ratingsourceid
    and (fpr.overallsurvivalstar is not null or fpr.overallrecovery30star is not null)
),

cte_tempqualityscoretable as (
select distinct 
    erfa.facilityid,
    erfa.servicelinecode,
    erfa.servicelinedescription,
    (select average_score from cte_ratingsortvalue) as ratingssortvalue
from cte_ermartfacility as erfa
),
cte_tempproviderspecialtyserviceline as (
select
    vw.providerid,
    vw.specialtycode,
    cte.servicelinecode
from base.vwuproviderspecialty as vw
inner join cte_servicelinespecialty as cte on cte.medicaltermcode = vw.specialtycode
where specialtyrank = 1
),
cte_specl as (
select
    ermart.servicelineid,
    cte.legacykey as lkey,
    cte.medicaltermcode as spcd
from cte_servicelinespecialty as cte
join ermart1.facility_facilitytoservicelinerating as ermart on ermart.servicelineid = cte.servicelinecode
),
cte_speclxml as (
select 
    servicelineid,
    utils.p_json_to_xml(array_agg(
  '{ '||
IFF(lkey IS NOT NULL, '"lkey":' || '"' || lkey || '"' || ',', '') ||
IFF(spcd IS NOT NULL, '"spcd":' || '"' || spcd || '"', '')
||' }'
    )::varchar,
    '',
    'spec') as specl
    
from cte_specl
group by servicelineid),

cte_union as (
select
    fsl.facilityid,
    fsl.servicelineid as svccd,
    sl.servicelinedescription as svcnm,
    (select specl from cte_speclxml) as specl
from
    ermart1.facility_facilitytoservicelinerating fsl
    join ermart1.facility_serviceline sl on fsl.servicelineid = sl.servicelineid
where
    fsl.ismaxyear = 1
    and fsl.survivalstar = 5

union all

select
    fpr.facilityid,
    psl.servicelineid as svccd,
    sl.servicelinedescription as svcnm,
    (select specl from cte_speclxml) as specl
from
    ermart1.facility_facilitytoprocedurerating fpr
    join ermart1.facility_proceduretoserviceline psl on fpr.procedureid = psl.procedureid
    join ermart1.facility_serviceline sl on psl.servicelineid = sl.servicelineid
where
    fpr.ismaxyear = 1
    and fpr.overallsurvivalstar = 5
    and fpr.procedureid = 'OB1'
),
cte_fivestarxml as (
select 
    facilityid,
    utils.p_json_to_xml(array_agg(
 '{ '||
IFF(svccd IS NOT NULL, '"svccd":' || '"' || svccd || '"' || ',', '') ||
IFF(svcnm IS NOT NULL, '"svcnm":' || '"' || svcnm || '"' || ',', '') ||
IFF(specl IS NOT NULL, '"specl":' || '"' || specl || '"', '')
||' }'
    )::varchar,
    '',
    'svcLn') as fivestarxml
from cte_union
group by
    facilityid
),
cte_hasaward as (
select distinct 
    facilityid,
    case when facilityid is not null then 1 end as hasaward
from 
    ermart1.facility_facilitytoaward 
where 
    ismaxyear = 1
),
cte_servicelineaward as (
select 
    facilityid,
    specialtycode as svccd,
    (select specl from cte_speclxml) as specl
from 
    ermart1.facility_facilitytoaward as fta
where 
    ismaxyear = 1
    and specialtycode is not null
order by 
    specialtycode
),
cte_servicelineawardxml as (
select
    facilityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(svccd IS NOT NULL, '"svccd":' || '"' || svccd || '"' || ',', '') ||
IFF(specl IS NOT NULL, '"specl":' || '"' || specl || '"', '')
||' }'
    )::varchar,
    '',
    'svcLn') as servicelineaward

from cte_servicelineaward
group by
    facilityid
),
cte_address as (
select distinct
    facilityid,
    replace(replace(replace(address, '\'', ''), '/', ''), '{', '') as ad1,
    city as city,
    state as st,
    zipcode as zip,
    cast(latitude as decimal(9,6)) as lat,
    cast(longitude as decimal(9,6)) as lng
from
    ermart1.facility_facilityaddressdetail 
),
cte_addressxml as (
select
    facilityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(ad1 IS NOT NULL, '"ad1":' || '"' || ad1 || '"' || ',', '') ||
IFF(city IS NOT NULL, '"city":' || '"' || city || '"' || ',', '') ||
IFF(st IS NOT NULL, '"st":' || '"' || st || '"' || ',', '') ||
IFF(zip IS NOT NULL, '"zip":' || '"' || zip || '"' || ',', '') ||
IFF(lat IS NOT NULL, '"lat":' || '"' || lat || '"' || ',', '') ||
IFF(lng IS NOT NULL, '"lng":' || '"' || lng || '"', '')
||' }'
    )::varchar
    ,
    '',
    'addr') as addressxml
from cte_address 
group by
    facilityid),

cte_child as (
select distinct
    f.facilityid,
    f.facilitycode as faccd,
    pc.childfacilityname as facnm
from
    cte_parentchild pc
    join base.facility f on pc.facilityidchild = f.legacykey
    join ermart1.facility_facilitytoaward as fta on pc.facilityidparent = fta.facilityid
    left join ermart1.facility_serviceline as fsl on fsl.servicelineid = fta.specialtycode
where
        (fsl.ratingsourceid = 1 and pc.currentmerge = 0)
        or (fsl.ratingsourceid is null and pc.currentmerge = 1)
        or (fsl.ratingsourceid = 0 and pc.currentmerge = 1)
    and pc.facilityidchild in (
        select
            awcat.facilityid
        from
            ermart1.facility_facilitytoaward as awcat
        where
            awcat.awardname = fta.awardname
            and iff(awcat.specialtycode is null, '', awcat.specialtycode) = iff(fta.specialtycode is null, '', fta.specialtycode)
            and awcat.mergeddata = 1
    )
order by
    pc.childfacilityname),
cte_childxml as (
select    
    facilityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(facCd IS NOT NULL, '"faccd":' || '"' || facCd || '"' || ',', '') ||
IFF(facNm IS NOT NULL, '"facnm":' || '"' || facNm || '"', '')
||' }'
    )::varchar
    ,
    'childL',
    'child') as childxml
from cte_child
group by
    facilityid
),

cte_award as (
select
    fta.facilityid,
    award.awardcode as awcd,
    award_cat.awardcategorycode as awtypcd,
    award.awarddisplayname as awnm,
    fta.year as awyr,
    fta.displaydatayear as dispawyr,
    fta.mergeddata as mrgd,
    fta.isbestind as isbest,
    fta.ismaxyear as ismaxyr
from
    ermart1.facility_facilitytoaward fta
    join base.award award on fta.awardname = award.awardname
    join base.awardcategory award_cat on award_cat.awardcategoryid = award.awardcategoryid
    left join ermart1.facility_serviceline svc_line on fta.specialtycode = svc_line.servicelineid
group by
    fta.facilityid,
    award.awardcode,
    award.awarddisplayname,
    fta.displaydatayear,
    fta.mergeddata,
    fta.isbestind,
    fta.ismaxyear,
    award_cat.awardcategorycode,
    fta.year
),
cte_awardxml as (
select
    facilityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(awcd IS NOT NULL, '"awcd":' || '"' || awcd || '"' || ',', '') ||
IFF(awtypcd IS NOT NULL, '"awtypcd":' || '"' || awtypcd || '"' || ',', '') ||
IFF(awnm IS NOT NULL, '"awnm":' || '"' || awnm || '"' || ',', '') ||
IFF(awyr IS NOT NULL, '"awyr":' || '"' || awyr || '"' || ',', '') ||
IFF(dispawyr IS NOT NULL, '"dispawyr":' || '"' || dispawyr || '"' || ',', '') ||
IFF(mrgd IS NOT NULL, '"mrgd":' || '"' || mrgd || '"' || ',', '') ||
IFF(isbest IS NOT NULL, '"isbest":' || '"' || isbest || '"' || ',', '') ||
IFF(ismaxyr IS NOT NULL, '"ismaxyr":' || '"' || ismaxyr || '"', '')
||' }'
    )::varchar
    ,
    '',
    'award') as awardxml
from cte_award
group by
    facilityid
),

cte_facility as (
select
    fi.facilityid,
    fi.facilityimageid,
    iff(mi.mediarelativepath is null, '', mi.mediarelativepath)
    || case 
        when right(iff(mi.mediarelativepath is null, '', mi.mediarelativepath), 1) <> '/' then '/'
        else ''
    end
    || fi.filename as imagefilepath,
    mi.mediaimagetypecode
from
    base.facilityimage fi
    join base.mediaimagetype mi on fi.mediaimagetypeid = mi.mediaimagetypeid
    join base.mediasize ms on fi.mediasizeid = ms.mediasizeid
where
    mi.mediaimagetypecode = 'FACIMAGE'
),

cte_client as (
select
    cpte.clientproducttoentityid,
    ctp.clienttoproductid,
    cl.clientcode,
    cl.clientname,
    fac.facilityid,
    prod.productcode,
    pg.productgroupcode
from
    base.clienttoproduct ctp
    join base.client cl on ctp.clientid = cl.clientid
    join base.product prod on ctp.productid = prod.productid
    join base.productgroup pg on prod.productgroupid = pg.productgroupid
    join base.clientproducttoentity cpte on ctp.clienttoproductid = cpte.clienttoproductid
    join base.entitytype et on cpte.entitytypeid = et.entitytypeid and et.entitytypecode = 'fac'
    join base.facility fac on cpte.entityid = fac.facilityid
where
    ctp.activeflag = 1
    and pg.productgroupcode = 'PDC'
    and fac.isclosed = 0
),
cte_entity as (
select
    cetcf.cliententitytoclientfeatureid as clienttoproductid,
    cf.clientfeaturecode as fecd,
    cf.clientfeaturedescription as fedes,
    cfv.clientfeaturevaluecode,
    cfv.clientfeaturevaluedescription
from
    base.cliententitytoclientfeature cetcf
    join base.entitytype et on cetcf.entitytypeid = et.entitytypeid
    join base.clientfeaturetoclientfeaturevalue cftcfv on cetcf.clientfeaturetoclientfeaturevalueid = cftcfv.clientfeaturetoclientfeaturevalueid
    join base.clientfeature cf on cftcfv.clientfeatureid = cf.clientfeatureid
    join base.clientfeaturevalue cfv on cfv.clientfeaturevalueid = cftcfv.clientfeaturevalueid
where
    et.entitytypecode = 'CLPROD'
    and cf.clientfeaturecode = 'FCCCP' -- call center phone numbers
    and cfv.clientfeaturevaluecode = 'FVFAC' -- facility
),
cte_pfacility as (
    select
        ptf.providerid,
        f.legacykey
    from
        base.providertofacility ptf
        join base.facility f on ptf.facilityid = f.facilityid
),
cte_provider as (
select
    tpsl.providerid,
    tqs.facilityid,
    tqs.servicelinecode,
    tqs.ratingssortvalue
from
    cte_tempqualityscoretable tqs
    join cte_tempproviderspecialtyserviceline tpsl on tqs.servicelinecode = tpsl.servicelinecode
    join cte_pfacility pf on tqs.facilityid = pf.legacykey and tpsl.providerid = pf.providerid
where
    ifnull(tqs.ratingssortvalue, -1) <> -1
),
cte_phonehospital as (
select distinct 
    clientproducttoentityid,
    DesignatedProviderPhone AS ph, 
    PhoneTypeCode as phTyp
from Base.vwuPDCFacilityDetail
where PhoneTypeCode = 'PTHFS'
),
cte_phonepdc as (
select distinct 
    clientproducttoentityid,
    DesignatedProviderPhone AS ph, 
    PhoneTypeCode as phTyp
from Base.vwuPDCClientDetail 
where PhoneTypeCode = 'PTHOS'
),
cte_phonehospitalxml as (
select
    clientproducttoentityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(ph IS NOT NULL, '"ph":' || '"' || ph || '"' || ',', '') ||
IFF(phTyp IS NOT NULL, '"phTyp":' || '"' || phTyp || '"', '')
||' }'
    )::varchar
    ,
    '',
    'phone') as pdcphonexml
from cte_phonehospital
group by
    clientproducttoentityid
),
cte_phonepdcxml as (
select
    clientproducttoentityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(ph IS NOT NULL, '"ph":' || '"' || ph || '"' || ',', '') ||
IFF(phTyp IS NOT NULL, '"phTyp":' || '"' || phTyp || '"', '')
||' }'
    )::varchar
    ,
    '',
    'phone') as pdcphonexml
from cte_phonepdc
group by
    clientproducttoentityid
),
cte_providerfacility as (
select 
    ptf.ProviderToFacilityID,
    ptf.ProviderID, 
    ptf.FacilityID,
    f.FacilityCode,
    mf.FacilityName,
    f.IsClosed, 
    ctefac.imagefilepath, 
    pr.RoleCode,
    pr.RoleDescription,
    f.LegacyKey,
    to_variant(fsxml.fivestarxml) as fivestarxml,
    award.hasaward,
    to_variant(slaxml.servicelineaward) as servicelineaward,
    to_variant(addxml.addressxml) as addressxml, 
    to_variant(awxml.awardxml) as awardxml,
    case when (ifnull(to_varchar(cteent.clienttoproductid), '') <> '') then to_variant(phxml.pdcphonexml) else to_variant(ppxml.pdcphonexml) end as pdcphonexml,
    mf.FacilityURL,
    mf.FacilityType,
    mf.FacilityTypeCode,
    mf.FacilitySearchType,
    mf.FiveStarProcedureCount,
    (avg(cteprov.ratingsSortValue) + count(cteprov.ServiceLineCode)*0.25) as qualityscore,
    0 as actioncode
from cte_providerbatch as pb
    join base.providertofacility as ptf on ptf.providerid = pb.providerid
    join base.facility as f on f.facilityid = ptf.facilityid
    join ermart1.facility_facilityaddressdetail as fad on fad.facilityid = f.legacykey
    join mid.facility as mf on f.facilityid = mf.facilityid
    left join base.providerrole as pr on pr.providerroleid = ptf.providerroleid
    join cte_hasaward as award on award.facilityid = f.legacykey
    join cte_fivestarxml as fsxml on fsxml.facilityid = f.legacykey
    join cte_servicelineawardxml as slaxml on slaxml.facilityid = f.legacykey
    join cte_addressxml as addxml on addxml.facilityid = f.legacykey
    join cte_awardxml as awxml on awxml.facilityid = f.legacykey
    left join cte_facility as ctefac on ctefac.facilityid = f.facilityid
    left join cte_client as ctecl on ctecl.facilityid = f.facilityid
    left join cte_entity as cteent on cteent.clienttoproductid = ctecl.clienttoproductid
    left join cte_provider as cteprov on cteprov.facilityid = f.legacykey and cteprov.providerid = ptf.providerid
    join cte_phonehospitalxml as phxml on phxml.clientproducttoentityid = ctecl.clientproducttoentityid
    join cte_phonepdcxml as ppxml on ppxml.clientproducttoentityid = ctecl.clientproducttoentityid
group by 
    ptf.ProviderToFacilityID,
    ptf.ProviderID, 
    ptf.FacilityID,
    f.FacilityCode,
    mf.FacilityName,
    f.IsClosed, 
    ctefac.imagefilepath, 
    pr.RoleCode,
    pr.RoleDescription,
    f.LegacyKey,
    mf.FacilityURL,
    mf.FacilityType,
    mf.FacilityTypeCode,
    mf.FacilitySearchType,
    mf.FiveStarProcedureCount,
    ctecl.clientproducttoentityid,
    cteent.clienttoproductid,
    ctecl.clienttoproductid,
    award.hasaward,
    fsxml.fivestarxml,
    slaxml.servicelineaward,
    addxml.addressxml,
    awxml.awardxml,
    phxml.pdcphonexml,
    ppxml.pdcphonexml
    
),
-- insert action
cte_action_1 as (
    select 
        cte.providertofacilityid,
        1 as actioncode
    from cte_providerfacility as cte
    left join mid.providerfacility as mid
    on cte.providertofacilityid = mid.providertofacilityid 
    where mid.providertofacilityid is null
),

-- update action
cte_action_2 as (
   select 
        cte.providertofacilityid,
        1 as actioncode
    from cte_providerfacility as cte
    left join mid.providerfacility as mid
    on cte.providertofacilityid = mid.providertofacilityid 
    where
        md5(ifnull(cte.providerid::varchar, '')) <> md5(ifnull(mid.providerid::varchar, '')) or
        md5(ifnull(cte.facilityid::varchar, '')) <> md5(ifnull(mid.facilityid::varchar, '')) or
        md5(ifnull(cte.facilitycode::varchar, '')) <> md5(ifnull(mid.facilitycode::varchar, '')) or
        md5(ifnull(cte.facilityname::varchar, '')) <> md5(ifnull(mid.facilityname::varchar, '')) or
        md5(ifnull(cte.isclosed::varchar, '')) <> md5(ifnull(mid.isclosed::varchar, '')) or
        md5(ifnull(cte.imagefilepath::varchar, '')) <> md5(ifnull(mid.imagefilepath::varchar, '')) or
        md5(ifnull(cte.rolecode::varchar, '')) <> md5(ifnull(mid.rolecode::varchar, '')) or
        md5(ifnull(cte.roledescription::varchar, '')) <> md5(ifnull(mid.roledescription::varchar, '')) or
        md5(ifnull(cte.legacykey::varchar, '')) <> md5(ifnull(mid.legacykey::varchar, '')) or
        md5(ifnull(cte.fivestarxml::varchar, '')) <> md5(ifnull(mid.fivestarxml::varchar, '')) or
        md5(ifnull(cte.hasaward::varchar, '')) <> md5(ifnull(mid.hasaward::varchar, '')) or
        md5(ifnull(cte.servicelineaward::varchar, '')) <> md5(ifnull(mid.servicelineaward::varchar, '')) or
        md5(ifnull(cte.addressxml::varchar, '')) <> md5(ifnull(mid.addressxml::varchar, '')) or
        md5(ifnull(cte.awardxml::varchar, '')) <> md5(ifnull(mid.awardxml::varchar, '')) or
        md5(ifnull(cte.pdcphonexml::varchar, '')) <> md5(ifnull(mid.pdcphonexml::varchar, '')) or
        md5(ifnull(cte.facilityurl::varchar, '')) <> md5(ifnull(mid.facilityurl::varchar, '')) or
        md5(ifnull(cte.facilitytype::varchar, '')) <> md5(ifnull(mid.facilitytype::varchar, '')) or
        md5(ifnull(cte.facilitytypecode::varchar, '')) <> md5(ifnull(mid.facilitytypecode::varchar, '')) or
        md5(ifnull(cte.facilitysearchtype::varchar, '')) <> md5(ifnull(mid.facilitysearchtype::varchar, '')) or
        md5(ifnull(cte.fivestarprocedurecount::varchar, '')) <> md5(ifnull(mid.fivestarprocedurecount::varchar, '')) or
        md5(ifnull(cte.qualityscore::varchar, '')) <> md5(ifnull(mid.qualityscore::varchar, ''))
)
select distinct
    a0.providertofacilityid,
    a0.providerid, 
    a0.facilityid,
    a0.facilitycode,
    a0.facilityname,
    a0.isclosed, 
    a0.imagefilepath, 
    a0.rolecode,
    a0.roledescription,
    a0.legacykey,
    a0.fivestarxml,
    a0.hasaward,
    a0.servicelineaward,
    a0.addressxml, 
    a0.awardxml,
    a0.pdcphonexml,
    a0.facilityurl,
    a0.facilitytype,
    a0.facilitytypecode,
    a0.facilitysearchtype,
    a0.fivestarprocedurecount,
    a0.qualityscore,
    ifnull(a1.actioncode, ifnull(a2.actioncode, a0.actioncode)) as ActionCode 
from cte_providerfacility as a0 
left join cte_action_1 as a1 on a0.providertofacilityid = a1.providertofacilityid
left join cte_action_2 as a2 on a0.providertofacilityid = a2.providertofacilityid
where ifnull(a1.actioncode, ifnull(a2.actioncode, a0.actioncode)) <> 0 $$;

--- Update Statement
update_statement := ' update 
                     set
                        target.providerid = source.providerid,
                        target.facilityid = source.facilityid,
                        target.facilitycode = source.facilitycode,
                        target.facilityname = source.facilityname,
                        target.isclosed = source.isclosed,
                        target.imagefilepath = source.imagefilepath,
                        target.rolecode = source.rolecode,
                        target.roledescription = source.roledescription,
                        target.legacykey = source.legacykey,
                        target.fivestarxml = source.fivestarxml,
                        target.hasaward = source.hasaward,
                        target.servicelineaward = source.servicelineaward,
                        target.addressxml = source.addressxml,
                        target.awardxml = source.awardxml,
                        target.pdcphonexml = source.pdcphonexml,
                        target.facilityurl = source.facilityurl,
                        target.facilitytype = source.facilitytype,
                        target.facilitytypecode = source.facilitytypecode,
                        target.facilitysearchtype = source.facilitysearchtype,
                        target.fivestarprocedurecount = source.fivestarprocedurecount,
                        target.qualityscore = source.qualityscore';

--- Insert Statement
insert_statement := ' insert  (
                        providertofacilityid,
                        providerid, 
                        facilityid,
                        facilitycode,
                        facilityname,
                        isclosed, 
                        imagefilepath, 
                        rolecode,
                        roledescription,
                        legacykey,
                        fivestarxml,
                        hasaward,
                        servicelineaward,
                        addressxml, 
                        awardxml,
                        pdcphonexml,
                        facilityurl,
                        facilitytype,
                        facilitytypecode,
                        facilitysearchtype,
                        fivestarprocedurecount,
                        qualityscore)
                      values (
                        source.providertofacilityid,
                        source.providerid, 
                        source.facilityid,
                        source.facilitycode,
                        source.facilityname,
                        source.isclosed, 
                        source.imagefilepath, 
                        source.rolecode,
                        source.roledescription,
                        source.legacykey,
                        source.fivestarxml,
                        source.hasaward,
                        source.servicelineaward,
                        source.addressxml, 
                        source.awardxml,
                        source.pdcphonexml,
                        source.facilityurl,
                        source.facilitytype,
                        source.facilitytypecode,
                        source.facilitysearchtype,
                        source.fivestarprocedurecount,
                        source.qualityscore
                        
                        )';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.providerfacility as target using 
                   ('||select_statement||') as source 
                   on source.providertofacilityid = target.providertofacilityid 
                   when matched and source.actioncode = 2 then '||update_statement|| '
                   when not matched and source.actioncode = 1 then '||insert_statement;
                   
        
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.ProviderFacility;
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