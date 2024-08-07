CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDERSPONSORSHIP(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

-- mid.providersponsorship depends on:
-- mdm_team.mst.Provider_Profile_Processing
-- base.address
-- base.citystatepostalcode
-- base.cliententitytoclientfeature
-- base.clientfeature
-- base.clientfeaturegroup
-- base.clientfeaturetoclientfeaturevalue
-- base.clientfeaturevalue
-- base.clientproductentityrelationship
-- base.clientproductentitytophone
-- base.clientproducttoentity
-- base.clienttoproduct
-- base.entitytype
-- base.facility
-- base.facilitytoaddress
-- base.facilitytofacilitytype
-- base.facilitytype
-- base.message
-- base.messagepage
-- base.messagetomessagetoentitytopagetoyear
-- base.messagetype
-- base.office
-- base.officetophone
-- base.phone
-- base.phonetype
-- base.practice
-- base.product
-- base.productgroup
-- base.provider
-- base.providertofacility
-- base.providertooffice
-- base.relationshiptype
-- base.state
-- Base.ClientProductImage (base.vwupdcclientdetail)
-- Base.MediaImageType (base.vwupdcclientdetail)
-- Base.ClientProductEntityToURL (base.vwupdcclientdetail)
-- Base.URLType (base.vwupdcclientdetail)
-- Base.URL (base.vwupdcclientdetail)
-- base.client (base.vwupdcfacilitydetail)
-- base.facilityimage (base.vwupdcfacilitydetail)
-- ermart1.facility_facility
-- ermart1.facility_hospitaldetail
-- hosp_directory.dbo_master_directory


---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    delete_statement string;
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providersponsorship');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement

begin
select_statement := 
$$ with CTE_Provider_Batch as (
select
    p.providerid,
    ppp.ref_provider_code as providercode
from
    $$ || mdm_db || $$.mst.Provider_Profile_Processing as ppp
    join base.provider as P on p.providercode = ppp.ref_provider_code
order by
    p.providerid),
                    
cte_client_to_product_phone as (
    select
        cl.clienttoproductid,
        cl.designatedproviderphone as ph,
        cl.phonetypecode as phtyp
    from
        base.vwupdcclientdetail cl
    where
        cl.phonetypecode in ('PTDES', 'PTMWC', 'PTPSRD', 'PTDPPEP', 'PTDPPNP')
    union all
    select
        cp.clienttoproductid,
        p.phonenumber as ph,
        pt.phonetypecode as phtyp
    from
        base.clientproductentitytophone cpep
        inner join base.clientproducttoentity cpe on cpe.clientproducttoentityid = cpep.clientproducttoentityid
        inner join base.entitytype et on et.entitytypeid = cpe.entitytypeid
        inner join base.clienttoproduct cp on cp.clienttoproductid = cpe.clienttoproductid
        inner join base.phonetype pt on pt.phonetypeid = cpep.phonetypeid
        inner join base.phone p on p.phoneid = cpep.phoneid
    where
        et.entitytypecode = 'CLPROD'
),
cte_facility_phones as (
    select
        pf.providerid,
        m.phone_nbr as ph,
        'PTDES' as phtyp,
        f.facilityid
    from
        base.providertofacility pf
        inner join cte_provider_batch x on x.providerid = pf.providerid
        inner join base.facility f on f.facilityid = pf.facilityid
        inner join hosp_directory.dbo_master_directory m on m.hgid = f.legacykey
    qualify row_number() over(partition by pf.providerid, f.facilityid order by m.phone_nbr)  <= 1
),
cte_provider_office_phones as (
    select
        a.providerid,
        d.phonenumber as ph,
        e.phonetypecode as phtyp
    from
        base.providertooffice a
        inner join cte_provider_batch x on x.providerid = a.providerid
        inner join base.office b on b.officeid = a.officeid
        inner join base.officetophone c on c.officeid = b.officeid
        inner join base.phone d on c.phoneid = d.phoneid
        inner join base.phonetype e on e.phonetypeid = c.phonetypeid
    where
        e.phonetypecode = 'MAIN' -- Before was Service but not we don't have Service any longer
    qualify row_number() over(partition by a.providerid order by a.isprimaryoffice, a.providerofficerank) <= 1
),
cte_facility_url as (
    select
        distinct f.facilityid,
        f.facilitycode,
        case
            when ft.facilitytypecode in ('CHDR', 'STAC') then 
                regexp_replace(
                    concat(
                        '/hospital-directory/',
                        lower(ifnull(hd.hospseourl, replace(lower(trim(s.statename)), ' ', '-') || '-' || lower(s.state))),
                        '/',
                        lower(regexp_replace(replace(replace(trim(f.facilityname), char(unicode('\u0060')), ''), ' ', '-'), '[&/''\:\\~\\;\\|<>™•*?+®!–@{}\\[\\]()ñéí"’ #,\\.]', '-')),
                        '-',
                        lower(f.legacykey)
                    ),
                    '--',
                    '-'
                ) 
            when ft.facilitytypecode = 'ESRD' then
                regexp_replace(
                    concat(
                        '/clinic-directory/dialysis-centers/',
                        lower(replace(s.statename, ' ', '-')),
                        '-',
                        lower(s.state),
                        '/',
                        lower(regexp_replace(csp.city, '[ -&/''\.]', '-', 1, 0)),
                        '/',
                        lower(regexp_replace(trim(f.facilityname), '[&/''\:\\~\\;\\|<>™•*?+®!–@{}\\[\\]()ñéí"’ #,\\.]', '-')),
                        '-',
                        lower(substring(f.legacykey, 5, 8))
                    ),
                    '--',
                    '-'
                )
            when ft.facilitytypecode ='HGUC' then
                regexp_replace(
                    concat(
                        '/urgent-care/',
                        lower(regexp_replace(trim(f.facilityname), '[&/''\:\\~\\;\\|<>™•*?+®!–@{}\\[\\]()ñéí"’ #,\\.]', '-')),
                        '-',
                        lower(f.facilitycode)
                    ),
                    '--',
                    '-'
                ) end as facilityurl
    from
        base.facility f
        inner join base.facilitytofacilitytype ftft on ftft.facilityid = f.facilityid
        inner join base.facilitytype ft on ft.facilitytypeid = ftft.facilitytypeid
        left join base.facilitytoaddress fa on fa.facilityid = f.facilityid
        left join base.address a on a.addressid = fa.addressid
        left join base.citystatepostalcode csp on csp.citystatepostalcodeid = a.citystatepostalcodeid
        left join base.state s on s.state = csp.state
        left join ermart1.facility_facility ef on ef.facilityid = f.legacykey
        left join ermart1.facility_hospitaldetail hd on hd.facilityid = ef.facilityid
    where
        f.isclosed = 0
        and ef.facsearchtypeid in (1,4,8)
        and ft.facilitytypecode in ('CHDR','ESRD','STAC','HGUC')
),
cte_temp_facility_pdc as (
    select
        rel.parentid,
        fac.facilityid,
        fac.facilitycode,
        fac.facilityname,
        cp2e.clientproducttoentityid,
        csp.state
    from
        base.clientproductentityrelationship rel
        join base.relationshiptype rtype on rel.relationshiptypeid = rtype.relationshiptypeid
        join base.clientproducttoentity cp2e on cp2e.clientproducttoentityid = rel.childid
        join base.facility fac on cp2e.entityid = fac.facilityid
        join base.facilitytoaddress f2a on f2a.facilityid = fac.facilityid
        join base.address addr on addr.addressid = f2a.addressid
        join base.citystatepostalcode csp on csp.citystatepostalcodeid = addr.citystatepostalcodeid
    where
        rtype.relationshiptypecode = 'PROVTOFAC'
        and ifnull(fac.isclosed, 0) = 0
) ,

-- Joins

cte_entity_brand AS ( -- this gives 1 row
select
    cetcf.entityid as clienttoproductid,
    cfv.clientfeaturevaluecode
from
    base.cliententitytoclientfeature cetcf
    join base.entitytype et on cetcf.entitytypeid = et.entitytypeid
    join base.clientfeaturetoclientfeaturevalue cftcfv on cetcf.clientfeaturetoclientfeaturevalueid = cftcfv.clientfeaturetoclientfeaturevalueid
    join base.clientfeature cf on cftcfv.clientfeatureid = cf.clientfeatureid
    join base.clientfeaturevalue cfv on cfv.clientfeaturevalueid = cftcfv.clientfeaturevalueid
where
    et.entitytypecode = 'CLPROD'
    and cf.clientfeaturecode = 'FCBRL' -- Branding Level
    and cfv.clientfeaturevaluecode = 'FVCLT' -- Client
) , 
cte_entity_facility AS ( -- this gives 1 row
select
    cetcf.entityid as clienttoproductid,
    cf.clientfeaturecode
from
    base.cliententitytoclientfeature cetcf
    join base.entitytype et on cetcf.entitytypeid = et.entitytypeid
    join base.clientfeaturetoclientfeaturevalue cftcfv on cetcf.clientfeaturetoclientfeaturevalueid = cftcfv.clientfeaturetoclientfeaturevalueid
    join base.clientfeature cf on cftcfv.clientfeatureid = cf.clientfeatureid
    join base.clientfeaturevalue cfv on cfv.clientfeaturevalueid = cftcfv.clientfeaturevalueid
where
    et.entitytypecode = 'CLPROD'
    and cf.clientfeaturecode = 'FCMAR' -- Facility Market Targeted
    and cfv.clientfeaturevaluecode = 'FVFAC'
) , 
cte_entity_call AS ( -- this gives 1 row
select
    cetcf.entityid as clienttoproductid,
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
    and cf.clientfeaturecode = 'FCCCP' -- Call Center Phone Numbers
    and cfv.clientfeaturevaluecode = 'FVFAC' -- Facility
), 
cte_entity_direct AS ( -- this gives no rows (also in sql server)
select
    cetcf.entityid as clienttoproductid,
    cf.clientfeaturecode
from
    base.cliententitytoclientfeature cetcf
    join base.entitytype et on cetcf.entitytypeid = et.entitytypeid
    join base.clientfeaturetoclientfeaturevalue cftcfv on cetcf.clientfeaturetoclientfeaturevalueid = cftcfv.clientfeaturetoclientfeaturevalueid
    join base.clientfeature cf on cftcfv.clientfeatureid = cf.clientfeatureid
    join base.clientfeaturevalue cfv on cfv.clientfeaturevalueid = cftcfv.clientfeaturevalueid
where
    et.entitytypecode = 'CLPROD'
    and cf.clientfeaturecode = 'FCDTP' -- Direct To Provider Phone
    and cfv.clientfeaturevaluecode = 'FVPPN'
), 

cte_entity_message_client as ( -- this gives 1 row
    select
        mtme.entityid,
        msg.messagetext as calltoactionmsg
    from
        base.messagetomessagetoentitytopagetoyear mtme
        join base.entitytype et on mtme.entitytypeid = et.entitytypeid
        join base.messagetype mt on mtme.messagetypeid = mt.messagetypeid
        join base.message msg on mtme.messageid = msg.messageid
        join base.messagepage mp on mtme.messagepageid = mp.messagepageid
    where
        et.entitytypecode = 'CLPROD'
        and mt.messagetypecode = 'CLIENTCALLMSG'
        and msg.isactive = true
        and mp.messagepagecode = 'SPONSPHYPRO'
),
cte_entity_message_product AS ( -- this gives 1 row
select
    mte.entityid,
    msg.messagetext as calltoactionmsg
from
    base.messagetomessagetoentitytopagetoyear mte
    join base.entitytype et on mte.entitytypeid = et.entitytypeid
    join base.messagetype mt on mte.messagetypeid = mt.messagetypeid
    join base.message msg on mte.messageid = msg.messageid
    join base.messagepage mp on mte.messagepageid = mp.messagepageid
where
    et.entitytypecode = 'PROD'
    and mt.messagetypecode = 'PRODUCTCALLMSG'
    and msg.isactive = true
    and mp.messagepagecode = 'SPONSPHYPRO'
), 
cte_entity_message_product_group AS ( -- this gives 1 row
select
    a.entityid,
    d.messagetext as calltoactionmsg
from
    base.messagetomessagetoentitytopagetoyear a
    join base.entitytype b on a.entitytypeid = b.entitytypeid
    join base.messagetype c on a.messagetypeid = c.messagetypeid
    join base.message d on a.messageid = d.messageid
    join base.messagepage e on a.messagepageid = e.messagepageid
where
    b.entitytypecode = 'PROGROUP'
    and c.messagetypecode = 'DEFAULTCALLMSG'
    and d.isactive = true
    and e.messagepagecode = 'SPONSPHYPRO'
), 
cte_entity_message_safe AS ( -- this gives 1 row
select
    a.entityid,
    d.messagetext as safeharbormsg
from
    base.messagetomessagetoentitytopagetoyear a
    join base.entitytype b on a.entitytypeid = b.entitytypeid
    join base.messagetype c on a.messagetypeid = c.messagetypeid
    join base.message d on a.messageid = d.messageid
    join base.messagepage e on a.messagepageid = e.messagepageid
where
    b.entitytypecode = 'CLPROD'
    and c.messagetypecode = 'SAFEHARBOR'
    and d.isactive = true
    and e.messagepagecode = 'SPONSPHYPRO'
), 
cte_entity_message_state AS ( -- this gives no rows (also in sql server)
select
    cetcf.entityid as clienttoproductid,
    cf.clientfeaturecode
from
    base.cliententitytoclientfeature cetcf
    join base.entitytype et on cetcf.entitytypeid = et.entitytypeid
    join base.clientfeaturetoclientfeaturevalue cftcfv on cetcf.clientfeaturetoclientfeaturevalueid = cftcfv.clientfeaturetoclientfeaturevalueid
    join base.clientfeature cf on cftcfv.clientfeatureid = cf.clientfeatureid
    join base.clientfeaturevalue cfv on cfv.clientfeaturevalueid = cftcfv.clientfeaturevalueid
where
    et.entitytypecode = 'CLPROD'
    and cf.clientfeaturecode = 'FCSBS' -- State Border for Sponsorship
    and cfv.clientfeaturevaluecode = 'FVYES'
),
cte_practice as (
select
    cper.parentid,
    off.officeid,
    off.officecode,
    off.officename,
    prac.practiceid,
    prac.practicecode,
    prac.practicename,
    cpte.clientproducttoentityid
from
    base.clientproductentityrelationship cper
    join base.relationshiptype rt on cper.relationshiptypeid = rt.relationshiptypeid
    join base.clientproducttoentity cpte on cpte.clientproducttoentityid = cper.childid
    join base.office off on cpte.entityid = off.officeid
    left join base.practice prac on off.practiceid = prac.practiceid
where
    rt.relationshiptypecode = 'PROVTOOFF'
),

cte_clientcode_in as (
select distinct
    cl.clientcode
from
    base.cliententitytoclientfeature cetcf
    join base.entitytype et on cetcf.entitytypeid = et.entitytypeid
    join base.clientfeaturetoclientfeaturevalue cftcfv on cetcf.clientfeaturetoclientfeaturevalueid = cftcfv.clientfeaturetoclientfeaturevalueid
    join base.clientfeature cf on cftcfv.clientfeatureid = cf.clientfeatureid
    join base.clientfeaturevalue cfv on cfv.clientfeaturevalueid = cftcfv.clientfeaturevalueid
    join base.clientfeaturegroup cfg on cf.clientfeaturegroupid = cfg.clientfeaturegroupid
    join base.clienttoproduct ctp on ctp.clienttoproductid = cetcf.entityid
    join base.client cl on cl.clientid = ctp.clientid
    join base.product prod on ctp.productid = prod.productid
    join base.productgroup pg on prod.productgroupid = pg.productgroupid
where
    et.entitytypecode = 'CLPROD'
    and cf.clientfeaturecode = 'FCDOA'
    and cfv.clientfeaturevaluecode = 'FVYES'
    and pg.productgroupcode = 'PDC'
),

cte_pracoffice_update as (
select
    pb.providercode,
    off.officecode,
    prac.practicecode,
    pto.providerofficerank,
    off.officeid,
    off.officename,
    prac.practiceid,
    prac.practicename,
    off.officecode as officecodetemp,
    prac.practicecode as practicecodetemp
from
    cte_provider_batch pb
    join base.providertooffice pto on pb.providerid = pto.providerid 
    join base.office off on pto.officeid = off.officeid
    join base.practice prac on off.practiceid = prac.practiceid
qualify row_number() over (partition by pb.providercode order by pto.providerofficerank asc, off.officecode asc) = 1
),

--------------------- Build Xml Columns -----------------------------
-- PhoneXML
cte_phone_1 as (
    select 
        vw.clienttoproductid,
        ph.phonenumber as ph,
        pht.phonetypecode as phtyp
    from base.providertooffice prto
        join base.office off on off.officeid = prto.officeid
        join base.officetophone opt on opt.officeid = off.officeid
        join base.phone ph on ph.phoneid = opt.phoneid
        join base.phonetype pht on pht.phonetypeid = opt.phonetypeid
        left join base.vwupdcclientdetail vw on vw.designatedproviderphone = ph.phonenumber
    -- where pht.phonetypecode = 'Service'
    where clienttoproductid is not null
    union all
    select 
        cp.clienttoproductid,
        clid.designatedproviderphone as ph,
        clid.phonetypecode as phtyp
    from base.vwupdcclientdetail clid
    join base.clienttoproduct cp on cp.clienttoproductid = clid.clienttoproductid
    join base.product prod on prod.productid = cp.productid
    where clid.phonetypecode in ('PTPSR', 'PTMWC', 'PTMTR') and prod.productcode = 'MAP'
),

cte_phone_xml_1 as (
 select
        clienttoproductid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as phonexml
    from cte_phone_1
    group by clienttoproductid
),

-- CTE for Employed Provider Phones
cte_phone_2 as (
    select
        epd.clienttoproductid,
        epd.employedproviderphone as ph,
        epd.phonetypecode as phtyp
    from base.vwupdcemployedproviderphone epd
    where epd.phonetypecode = 'PTEMP' 
    order by epd.employedproviderphone, epd.phonetypecode
),

cte_phone_xml_2 as (
    select
        clienttoproductid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as phonexml
    from cte_phone_2
    group by clienttoproductid
),

cte_phone_3 as (
    select distinct
        fa.clientproducttoentityid,
        fa.designatedproviderphone as ph,
        fa.phonetypecode as phtyp,
        1 as rankvalue
    from
        base.vwupdcfacilitydetail fa
    where
        fa.phonetypecode in ('PTPSRD','PTFMT','PTFMTM','PTFMTT','PTFDS','PTFMC','PTFSRD','PTFDPPEP','PTFDPPNP','PTFSR','PTFSRM','PTFSRT','PTFSRDTP','PTFMTDTP')
        
    union all

    select distinct
        fa.clientproducttoentityid,
        fa.designatedproviderphone as ph,
        'PTPSR' as phtyp,
        2 as rankvalue
    from
        base.vwupdcfacilitydetail fa
    where
        fa.phonetypecode in ('PTFSR')
    union all

    select distinct
        fa.clientproducttoentityid,
        fa.designatedproviderphone as ph,
        'PTMTR' as phtyp,
        3 as rankvalue
    from
        base.vwupdcfacilitydetail fa
    where
        fa.phonetypecode in ('PTFMT')
    union all
    select
        fa.clientproducttoentityid,
        phone.phonenumber as ph,
        phonetype.phonetypecode as phtyp,
        1 as rankvalue
    from
        base.providertooffice pto
        join base.office office on office.officeid = pto.officeid
        join base.officetophone otp on otp.officeid = office.officeid
        join base.phone phone on otp.phoneid = phone.phoneid
        join base.phonetype phonetype on otp.phonetypeid = phonetype.phonetypeid
        left join base.vwupdcfacilitydetail fa on fa.designatedproviderphone = phone.phonenumber
    where
        phonetype.phonetypecode = 'Service'
    limit 1
        
),

cte_phone_3_rn1 as (
select 
    clientproducttoentityid,
    ph,
    phtyp
from cte_phone_3
qualify row_number() over (partition by phtyp order by rankvalue, ph) = 1
),

cte_phone_xml_3 as (
select
        clientproducttoentityid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as phonexml
    from cte_phone_3_rn1
    group by clientproducttoentityid
),

cte_phone_xml_4 as (
    select    
        clienttoproductid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as phonexml
    from cte_client_to_product_phone
    group by clienttoproductid
),

cte_phone_xml_5 as (
 select    
        providerid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as phonexml
    from cte_provider_office_phones
    group by providerid

),

cte_phone_xml_6 as (
 select    
        providerid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as phonexml
    from cte_facility_phones
    group by providerid

),


-- MobileXML

cte_mobile_1 as (
select distinct
    ep.clienttoproductid,
    ep.employedproviderphone as ph,
    ep.phonetypecode as phtyp
from
    base.vwupdcemployedproviderphone ep
where
    ep.phonetypecode = 'PTEMPM'
order by
    ep.employedproviderphone, ep.phonetypecode
),

cte_mobile_xml_1 as (
select    
        clienttoproductid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as mobilephonexml
    from cte_mobile_1
    group by clienttoproductid
),

cte_mobile_2 as (
select distinct
    fa.clientproducttoentityid,
    fa.designatedproviderphone as ph,
    fa.phonetypecode as phtyp
from
    base.vwupdcfacilitydetail fa
where
    fa.phonetypecode in ('PTFDSM', 'PTFMCM', 'PTFSRDM') -- PDC Designated -- Facility Specific
order by
    fa.designatedproviderphone, fa.phonetypecode
),

cte_mobile_xml_2 as (
select    
        clientproducttoentityid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as mobilephonexml
    from cte_mobile_2
    group by clientproducttoentityid
),

cte_mobile_3 as (
select distinct
    cl.clienttoproductid,
    cl.designatedproviderphone as ph,
    cl.phonetypecode as phtyp
from
    base.vwupdcclientdetail cl
where
    cl.phonetypecode in ('PTDESM', 'PTMWCM', 'PTPSRM') -- PDC Designated
order by
    cl.designatedproviderphone, cl.phonetypecode
),

cte_mobile_xml_3 as (
select    
        clienttoproductid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as mobilephonexml
    from cte_mobile_3
    group by clienttoproductid
),

-- DesktopPhoneXML
cte_desktop_1 as (
select distinct
    ep.clienttoproductid,
    ep.employedproviderphone as ph,
    ep.phonetypecode as phtyp
from
    base.vwupdcemployedproviderphone ep
where
    ep.phonetypecode = 'PTEMPDTP'
order by
    ep.employedproviderphone, ep.phonetypecode
),

cte_desktop_xml_1 as (
select    
        clienttoproductid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as desktopphonexml
    from cte_desktop_1
    group by clienttoproductid
),

cte_desktop_2 as (
select distinct
    fa.clientproducttoentityid,
    fa.designatedproviderphone as ph,
    fa.phonetypecode as phtyp
from
    base.vwupdcfacilitydetail fa
where
    fa.phonetypecode in('PTFDSDTP','PTFMCDTP','PTFSRDDTP') -- pdc designated -- facility specific
order by
    fa.designatedproviderphone, fa.phonetypecode
),

cte_desktop_xml_2 as (
select    
        clientproducttoentityid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as desktopphonexml
    from cte_desktop_2
    group by clientproducttoentityid
),

cte_desktop_3 as (
select distinct
    cl.clienttoproductid,
    cl.designatedproviderphone as ph,
    cl.phonetypecode as phtyp
from
    base.vwupdcclientdetail cl
where
    cl.phonetypecode in('PTDESDTP','PTMWCDTP', 'PTPSRDTP') -- pdc designated
order by
    cl.designatedproviderphone, cl.phonetypecode
),
cte_desktop_xml_3 as (
select    
        clienttoproductid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as desktopphonexml
    from cte_desktop_3
    group by clienttoproductid
),

-- TabletPhoneXML

cte_tablet_1 as (
select distinct
    ep.clienttoproductid,
    ep.employedproviderphone as ph,
    ep.phonetypecode as phtyp
from
    base.vwupdcemployedproviderphone ep
where
    ep.phonetypecode = 'PTEMPT'
order by
    ep.employedproviderphone, ep.phonetypecode
    ),
cte_tablet_xml_1 as (
    select 
    clienttoproductid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as tabletphonexml
    from cte_tablet_1
    group by clienttoproductid
    ),
cte_tablet_2 as (
select distinct
    fa.clientproducttoentityid,
    fa.designatedproviderphone as ph,
    fa.phonetypecode as phtyp
from
    base.vwupdcfacilitydetail fa
where
    fa.phonetypecode in('PTFDST', 'PTFMCT', 'PTFSRDT') -- pdc designated -- facility specific
order by
    fa.designatedproviderphone, fa.phonetypecode
    ),
cte_tablet_xml_2 as (
    select    
        clientproducttoentityid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as tabletphonexml
    from cte_tablet_2
    group by clientproducttoentityid
    ),
cte_tablet_3 as (
select distinct
    cl.clienttoproductid,
    cl.designatedproviderphone as ph,
    cl.phonetypecode as phtyp
from
    base.vwupdcclientdetail cl
where
    cl.phonetypecode in('PTDEST', 'PTMWCT', 'PTPSRT') -- pdc designated
order by
    cl.designatedproviderphone, cl.phonetypecode  
    ),
cte_tablet_xml_3 as (
select 
    clienttoproductid,
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phtyp is not null,'<phTyp>' || phtyp || '</phTyp>','')  || '</phone>','') as tabletphonexml
    from cte_tablet_3
    group by clienttoproductid
    ),

-- URLXML
    
cte_url_1 as (
select distinct
    fa.clientproducttoentityid,
    fa.url as urlval,
    fa.urltypecode as urltyp
from
    base.vwupdcfacilitydetail fa
where
    fa.urltypecode in ('FCFURL', 'FCCIURL') -- hospital profile
),
cte_url_xml_1 as (
select
    clientproducttoentityid,
    listagg( '<url>' || iff(urlval is not null,'<urlval>' || urlval || '</urlval>','') ||
iff(urltyp is not null,'<urltyp>' || urltyp || '</urltyp>','')  || '</url>','') as urlxml
from cte_url_1
group by
    clientproducttoentityid
),
cte_url_2 as (
select distinct
    cl.clienttoproductid,
    cl.url as urlval,
    cl.urltypecode as urltyp
from
    base.vwupdcclientdetail cl
where
    cl.urltypecode = 'FCCLURL' -- client url
),
cte_url_xml_2 as (
select
    clienttoproductid,
    listagg( '<url>' || iff(urlval is not null,'<urlval>' || urlval || '</urlval>','') ||
iff(urltyp is not null,'<urltyp>' || urltyp || '</urltyp>','')  || '</url>','') as urlxml
from cte_url_2
group by
    clienttoproductid
),
cte_url_3 as (
select 
    facilitycode,
    facilityurl as urlval,
    'FCCLURL' AS urlTyp 
from cte_facility_url
),
cte_url_xml_3 as (
select
    facilitycode,
    listagg( '<url>' || iff(urlval is not null,'<urlval>' || urlval || '</urlval>','') ||
iff(urltyp is not null,'<urltyp>' || urltyp || '</urltyp>','')  || '</url>','') as urlxml
from cte_url_3
group by
    facilitycode
),

-- ImageXML

cte_image_1 as (
select distinct
    cl.clienttoproductid,
    cl.imagefilepath as img,
    cl.mediaimagetypecode as imgtyp
from
    base.vwupdcclientdetail cl
where
    cl.mediaimagetypecode = 'FCCLLOGO' -- Client Logo
),
cte_image_xml_1 as (
select
    clienttoproductid,
    listagg( '<url>' || iff(img is not null,'<img>' || img || '</img>','') ||
iff(imgTyp is not null,'<imgTyp>' || imgTyp || '</imgTyp>','')  || '</url>','') as imagexml
from cte_image_1
group by
    clienttoproductid
),
cte_image_2 as (
select distinct
    fa.clientproducttoentityid,
    fa.imagefilepath as img,
    fa.mediaimagetypecode as imgtyp
from
    base.vwupdcfacilitydetail fa
where
    fa.mediaimagetypecode = 'FCFLOGO' -- Hospital Logo
),
cte_image_xml_2 as (
select
    clientproducttoentityid,
    listagg( '<url>' || iff(img is not null,'<img>' || img || '</img>','') ||
iff(imgTyp is not null,'<imgTyp>' || imgTyp || '</imgTyp>','')  || '</url>','') as imagexml
from cte_image_2
group by
    clientproducttoentityid
),
cte_image_3 as (
select distinct
    fa.clientproducttoentityid,
    fa.imagefilepath as img,
    fa.mediaimagetypecode as imgtyp
from
    base.vwupdcfacilitydetail fa
order by
    fa.imagefilepath 
limit 1
),
cte_image_xml_3 as (
select
    clientproducttoentityid,
    listagg( '<url>' || iff(img is not null,'<img>' || img || '</img>','') ||
iff(imgTyp is not null,'<imgTyp>' || imgTyp || '</imgTyp>','')  || '</url>','') as imagexml
from cte_image_3
group by
    clientproducttoentityid
),
cte_image_4 as (
select distinct
    cl.clienttoproductid,
    cl.imagefilepath as img,
    cl.mediaimagetypecode as imgtyp
from
    base.vwupdcclientdetail cl
),
cte_image_xml_4 as (
select
    clienttoproductid,
    listagg( '<url>' || iff(img is not null,'<img>' || img || '</img>','') ||
iff(imgTyp is not null,'<imgTyp>' || imgTyp || '</imgTyp>','')  || '</url>','') as imagexml
from cte_image_4
group by
    clienttoproductid
),

-- case whens for phonexml
cte_case_phone_2 as (
select
    ifnull(ep.EmployedProviderPhone, '')
from
    Base.vwuPDCEmployedProviderPhone ep
    join base.clienttoproduct ctp on ctp.clienttoproductid = ep.ClientToProductID
WHERE
    ep.PhoneTypeCode = 'PTEMP'
),
cte_case_phone_3 as (
select
    top 1 ifnull(DesignatedProviderPhone, '')
from
    Base.vwuPDCFacilityDetail fa
    join cte_temp_facility_pdc tfp on tfp.ClientProductToEntityID = fa.ClientProductToEntityID
WHERE
    fa.PhoneTypeCode in (
        'PTFMT','PTFMTM','PTFMTT','PTFDS','PTFMC','PTFSRD','PTFDPPEP','PTFDPPNP','PTFSR','PTFSRM','PTFSRT','PTFSRDTP','PTFMTDTP'
    )
),
cte_case_phone_4 as (
select
    TOP 1 1
from
    cte_client_to_product_phone cpp
    join base.clienttoproduct ctp on ctp.clienttoproductid = cpp.ClientToProductID
),
cte_case_phone_5 as (
select
    TOP 1 1
from
    cte_provider_office_phones pop
    join base.provider pv on pv.ProviderID = pop.ProviderID
),

----------- Case whens for the xml columns --------------------
-- case whens for mobilephonexml
cte_case_mobile_1 as (
select
    ifnull(ep.EmployedProviderPhone, '')
from
    Base.vwuPDCEmployedProviderPhone ep
    join base.clienttoproduct ctp on ctp.clienttoproductid = ep.ClientToProductID
where
    ep.PhoneTypeCode = 'PTEMPM'
),
-- case whens for desktopphonexml
cte_case_desktop_1 as (
select
    ifnull(ep.EmployedProviderPhone, '')
from
    Base.vwuPDCEmployedProviderPhone ep
    join base.clienttoproduct ctp on ctp.clienttoproductid = ep.ClientToProductID
where
    ep.PhoneTypeCode = 'PTEMPDTP'
),
-- case whens for tabletphonexml
cte_case_tablet_1 as (
select
    ifnull(ep.EmployedProviderPhone, '')
from
    Base.vwuPDCEmployedProviderPhone ep
    join base.clienttoproduct ctp on ctp.clienttoproductid = ep.ClientToProductID
where
    ep.PhoneTypeCode = 'PTEMPT'
),
-- case when for urlxml
cte_case_url_1 as (
select
    TOP 1 URL
from
    Base.vwuPDCFacilityDetail fa
    join cte_temp_facility_pdc tfp on tfp.ClientProductToEntityID = fa.ClientProductToEntityID
WHERE
    fa.URLTypeCode IN ('FCFURL', 'FCCIURL')
),
cte_case_url_2 as (
select
    TOP 1 URL
from
    Base.vwuPDCClientDetail cl
    join cte_entity_brand as eb on eb.ClientToProductID = cl.ClientToProductID 
WHERE
    cl.URLTypeCode = 'FCCLURL'
),
-- case when for imagexml
cte_case_image_1 as (
select
    TOP 1 ImageFilePath
from
    Base.vwuPDCClientDetail cl
    join cte_entity_brand as eb on eb.ClientToProductID = cl.ClientToProductID
WHERE
    cl.MediaImageTypeCode = 'FCCLLOGO'
),
cte_case_image_2 as (
select
    TOP 1 ImageFilePath
from
    Base.vwuPDCFacilityDetail fa
    join cte_temp_facility_pdc tfp on tfp.ClientProductToEntityID = fa.ClientProductToEntityID
WHERE
    fa.MediaImageTypeCode = 'FCFLOGO'
),
cte_case_image_3 as (
select
    TOP 1 ImageFilePath
from
    Base.vwuPDCFacilityDetail fa
    join cte_temp_facility_pdc tfp on tfp.ClientProductToEntityID = fa.ClientProductToEntityID
),
cte_providersponsorship as (select
    distinct 
    pv.providercode,
    pr.productcode,
    pr.producttypecode,
    pr.productdescription,
    pg.productgroupcode,
    pg.productgroupdescription,
    ctp.clienttoproductid,
    cl.clientcode,
    cl.clientname,
    tfp.facilitycode,
    tfp.facilityname,
    -- phonexml,
    case
        when ( pr.ProductCode IN ('PDCDEV', 'PDCSPC') OR ifnull(to_varchar(ed.ClientToProductID), '') <> '' ) THEN p1.phonexml
        when ( cpe.IsEntityEmployed = 1 and (select * from cte_case_phone_2) <> '' ) THEN p2.phonexml
        when ifnull(to_varchar(ec.ClientToProductID), '') <> '' and (select * from cte_case_phone_3) <> '' THEN p3.phonexml
        when length(select * from cte_case_phone_4) > 0 then p4.phonexml
        when length(select * from cte_case_phone_5) > 0 THEN p5.phonexml
        else p6.phonexml
    end as phonexml,
    -- mobilephonexml
    case
        when (pr.ProductCode IN ('PDCDEV', 'PDCSPC') or ifnull(to_varchar(ed.clienttoproductid), '') <> '') then null
        when (cpe.IsEntityEmployed = 1 and (select * from cte_case_mobile_1) <> '' ) then m1.mobilephonexml
        when ifnull(to_varchar(ec.ClientToProductID), '') <> '' then m2.mobilephonexml
        else m3.mobilephonexml
    end as mobilephonexml,
    -- desktopphonexml,
    case
        when (pr.ProductCode IN ('PDCDEV', 'PDCSPC') or ifnull(to_varchar(ed.clienttoproductid), '') <> '') then null
        when (cpe.IsEntityEmployed = 1 and (select * from cte_case_desktop_1) <> '') then d1.desktopphonexml
        when ifnull(to_varchar(ec.ClientToProductID), '') <> '' then d2.desktopphonexml
        else d3.desktopphonexml
    end as desktopphonexml,
    -- tabletphonexml,
    case
        when (pr.ProductCode IN ('PDCDEV', 'PDCSPC') or ifnull(to_varchar(ed.clienttoproductid), '') <> '') then null
        when (cpe.IsEntityEmployed = 1 and (select * from cte_case_tablet_1) <> '' ) then t1.tabletphonexml
        when ifnull(to_varchar(ec.ClientToProductID), '') <> '' then t2.tabletphonexml
        else t3.tabletphonexml
    end as tabletphonexml,
    -- urlxml,
    case
        when (ifnull(to_varchar(eb.ClientToProductID), '') <> '') and (select * from cte_case_url_1) IS NOT NULL THEN u1.urlxml
        when (select * from cte_case_url_2) IS NOT NULL THEN u2.urlxml
        else u3.urlxml
    end as urlxml,
    -- imagexml,
    case
        when (ifnull(to_varchar(eb.ClientToProductID), '') <> '') and  length(select * from cte_case_image_1) > 0 then i1.imagexml
        when length(select * from cte_case_image_2) > 0 then i2.imagexml
        when length(select * from cte_case_image_3) > 0 then i3.imagexml
        else i4.imagexml
    end as imagexml,
    -- qualitymessagexml,
    null as appointmentoptiondescription,
    case
        when ifnull(emc.calltoactionmsg, '') <> '' then emc.calltoactionmsg
        when ifnull(emp.calltoactionmsg, '') <> '' then emp.calltoactionmsg
        else empg.calltoactionmsg
    end as calltoactionmsg,
    ems.safeharbormsg,
    case
        when ifnull(to_varchar(emst.clienttoproductid), '') <> '' then tfp.state
    end as facilitystate,
    case
        when prac.officeid is not null then prac.officeid
        else po.officeid
    end as officeid,
    case
        when prac.officecode is not null then prac.officecode
        else po.officecode
    end as officecode,
    case
        when prac.officename is not null then prac.officename
        else po.officename
    end as officename,
    case
        when prac.practiceid is not null then prac.practiceid
        when po.practiceid is not null then po.practiceid
        else '00000000-0000-0000-0000-000000000000'
    end as practiceid,
    case
        when prac.practicecode is not null then prac.practicecode
        when po.practicecode is not null then po.practicecode
        else 'GENERAL'
    end as practicecode,
    case
        when prac.practicename is not null then prac.practicename
        when po.practicename is not null then po.practicename
        else ''
    end as practicename,
    case
        when clientcode in (
            select
                clientcode
            from
                cte_clientcode_in
        ) then 1
    end as hasoar
from base.clienttoproduct ctp -- a
		join base.client cl on ctp.clientid = cl.clientid  -- b
		join base.product pr on ctp.productid = pr.productid and ifnull(pr.producttypecode, '') <> 'Practice' -- c
		join base.productgroup pg on pr.productgroupid = pg.productgroupid -- and pg.productgroupcode = 'PDC' -- pg
		join base.clientproducttoentity cpe on ctp.clienttoproductid = cpe.clienttoproductid -- d
		join base.entitytype et on cpe.entitytypeid = et.entitytypeid and et.entitytypecode = 'PROV' -- e
		join cte_provider_batch pb on cpe.entityid = pb.providerid  -- pb
		join base.provider pv on cpe.entityid = pv.providerid --f
		left join cte_temp_facility_pdc tfp on cpe.clientproducttoentityid = tfp.parentid --g
        
        left join cte_entity_brand as eb on eb.clienttoproductid = ctp.clienttoproductid -- i 
        left join cte_entity_facility as ef on ef.clienttoproductid = ctp.clienttoproductid -- k
        left join cte_entity_call as ec on ec.clienttoproductid = ctp.clienttoproductid -- l
        left join cte_entity_direct as ed on ed.clienttoproductid = ctp.clienttoproductid --m
        left join cte_entity_message_client as emc on emc.entityid = ctp.clienttoproductid -- r
        left join cte_entity_message_product as emp on emp.entityid = ctp.productid -- rr
        left join cte_entity_message_product_group as empg on empg.entityid = pg.productgroupid -- s
        left join cte_entity_message_safe as ems on ems.entityid = ctp.clienttoproductid -- t
        left join cte_entity_message_state as emst on emst.clienttoproductid = ctp.clienttoproductid -- u
        
        left join cte_practice as prac on prac.parentid = cpe.clientproducttoentityid -- g (in practice insert)
        left join cte_pracoffice_update as po on po.providercode = pv.providercode
        
        -- phonexml
        left join cte_phone_xml_1 p1 on p1.clienttoproductid = ctp.clienttoproductid
        left join cte_phone_xml_2 p2 on p2.clienttoproductid = ctp.clienttoproductid
        left join cte_phone_xml_3 p3 on p3.clientproducttoentityid = tfp.clientproducttoentityid and pr.productcode = 'MAP'
        left join cte_phone_xml_4 p4 on p4.clienttoproductid = ctp.clienttoproductid
        left join cte_phone_xml_5 p5 on p5.providerid = pv.providerid 
        left join cte_phone_xml_6 p6 on p6.providerid = pv.providerid

        -- mobilephonexml
        left join cte_mobile_xml_1 m1 on m1.clienttoproductid = ctp.clienttoproductid
        left join cte_mobile_xml_2 m2 on m2.clientproducttoentityid = tfp.clientproducttoentityid
        left join cte_mobile_xml_3 m3 on m3.clienttoproductid = ctp.clienttoproductid

        -- desktopphonexml
        left join cte_desktop_xml_1 d1 on d1.clienttoproductid = ctp.clienttoproductid
        left join cte_desktop_xml_2 d2 on d2.clientproducttoentityid = tfp.clientproducttoentityid
        left join cte_desktop_xml_3 d3 on d3.clienttoproductid = ctp.clienttoproductid

        -- tabletphonexml
        left join cte_tablet_xml_1 t1 on t1.clienttoproductid = ctp.clienttoproductid
        left join cte_tablet_xml_2 t2 on t2.clientproducttoentityid = tfp.clientproducttoentityid
        left join cte_tablet_xml_3 t3 on t3.clienttoproductid = ctp.clienttoproductid

        -- urlxml
        left join cte_url_xml_1 u1 on u1.clientproducttoentityid = tfp.clientproducttoentityid
        left join cte_url_xml_2 u2 on u2.clienttoproductid = ctp.clienttoproductid
        left join cte_url_xml_3 u3 on u3.facilitycode = tfp.facilitycode

        -- imagexml
        left join cte_image_xml_1 i1 on i1.clienttoproductid = eb.clienttoproductid
        left join cte_image_xml_2 i2 on i2.clientproducttoentityid = tfp.clientproducttoentityid
        left join cte_image_xml_3 i3 on i3.clientproducttoentityid = tfp.clientproducttoentityid
        left join cte_image_xml_4 i4 on i4.clienttoproductid = eb.clienttoproductid and i4.clienttoproductid = ctp.clienttoproductid
where 
    ctp.activeflag = 1)
select
    ps.providercode,
    ps.productcode,
    ps.producttypecode,
    ps.productdescription,
    ps.productgroupcode,
    ps.productgroupdescription,
    ps.clienttoproductid,
    ps.clientcode,
    ps.clientname,
    ps.facilitycode,
    ps.facilityname,
    to_variant(ps.phonexml) as phonexml,
    to_variant(ps.mobilephonexml) as mobilephonexml,
    to_variant(ps.desktopphonexml) as desktopphonexml,
    to_variant(ps.tabletphonexml) as tabletphonexml,
    to_variant(ps.urlxml) as urlxml,
    to_variant(ps.imagexml) as imagexml,
    ps.appointmentoptiondescription,
    ps.calltoactionmsg,
    ps.safeharbormsg,
    ps.facilitystate,
    ps.officeid,
    ps.officecode,
    ps.officename,
    ps.practiceid,
    ps.practicecode,
    ps.practicename,
    ps.hasoar
from cte_providersponsorship ps
 $$;

--- Delete Statement
delete_statement := 'delete from mid.providersponsorship as target
                        using ('|| select_statement ||') AS source
                        where target.providercode = source.providercode;';

--- Insert Statement
insert_statement := '  insert  ( providercode,
                                productcode,
                                productdescription,
                                productgroupcode,
                                productgroupdescription,
                                clienttoproductid,
                                clientcode,
                                clientname,
                                facilitycode,
                                facilityname,
                                phonexml,
                                mobilephonexml,
                                desktopphonexml,
                                tabletphonexml,
                                urlxml,
                                imagexml,
                                appointmentoptiondescription,
                                calltoactionmsg,
                                safeharbormsg,
                                facilitystate,
                                officeid,
                                officecode,
                                officename,
                                practiceid,
                                practicecode,
                                practicename,
                                hasoar)
                                
                      values (  source.providercode,
                                source.productcode,
                                source.productdescription,
                                source.productgroupcode,
                                source.productgroupdescription,
                                source.clienttoproductid,
                                source.clientcode,
                                source.clientname,
                                source.facilitycode,
                                source.facilityname,
                                source.phonexml,
                                source.mobilephonexml,
                                source.desktopphonexml,
                                source.tabletphonexml,
                                source.urlxml,
                                source.imagexml,
                                source.appointmentoptiondescription,
                                source.calltoactionmsg,
                                source.safeharbormsg,
                                source.facilitystate,
                                source.officeid,
                                source.officecode,
                                source.officename,
                                source.practiceid,
                                source.practicecode,
                                source.practicename,
                                source.hasoar
                        
                        )';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.providersponsorship as target using 
                   ('||select_statement||') as source 
                   on source.providercode = target.providercode
                   when not matched then  '||insert_statement;
                   
        
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.ProviderSponsorship;
end if; 
execute immediate delete_statement;
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