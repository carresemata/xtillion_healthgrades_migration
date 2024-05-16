CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_FACILITY() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------

-- mid.facility depends on:
-- base.address
-- base.client
-- base.cliententitytoclientfeature
-- base.clientfeature
-- base.clientfeaturetoclientfeaturevalue
-- base.clientfeaturevalue
-- base.clientproducttoentity
-- base.clienttoproduct
-- base.citystatepostalcode
-- base.facility
-- base.facilitycheckinurl
-- base.facilityimage
-- base.facilitytoaddress
-- base.facilitytofacilitytype
-- base.facilitytype
-- base.mediaimagetype
-- base.product
-- base.productgroup
-- base.providertofacility
-- base.state
-- base.vwupdcclientdetail
-- base.vwupdcfacilitydetail
-- ermart1.facility_award
-- ermart1.facility_facility
-- ermart1.facility_facilityaddressdetail
-- ermart1.facility_facilitytoaward
-- ermart1.facility_facilitytoprocedurerating
-- ermart1.facility_facilitytorating
-- ermart1.facility_facilitytotraumalevel
-- ermart1.facility_facsearchtype
-- ermart1.facility_hospitaldetail
-- ermart1.facility_vwufacilityhgdisplayprocedures
-- show.clientcontract

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_facility');
    execution_start datetime default getdate();
   
---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------   
   
begin
    -- no conditionals


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement

select_statement := $$ with cte_facilityurl as (
    select distinct
        f.facilityid,
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
                        '/urgent-care-directory/',
                        lower(regexp_replace(trim(f.facilityname), '[&/''\:\\~\\;\\|<>™•*?+®!–@{}\\[\\]()ñéí"’ #,\\.]', '-')),
                        '-',
                        lower(f.facilitycode)
                    ),
                    '--',
                    '-'
                )
            when ft.facilitytypecode ='HGPH' then
                regexp_replace(
                    concat(
                        '/pharmacy/',
                        lower(regexp_replace(trim(f.facilityname), '[&/''\:\\~\\;\\|<>™•*?+®!–@{}\\[\\]()ñéí"’ #,\\.]', '-')),
                        '-',
                        lower(f.facilitycode)
                    ),
                    '--',
                    '-'
                )
        end as facilityurl
    from base.facility f
    inner join base.facilitytofacilitytype ftft on ftft.facilityid = f.facilityid
    inner join base.facilitytype ft on ft.facilitytypeid = ftft.facilitytypeid
    left join base.facilitytoaddress fa on fa.facilityid = f.facilityid
    left join base.address a on a.addressid = fa.addressid
    left join base.citystatepostalcode csp on csp.citystatepostalcodeid = a.citystatepostalcodeid
    left join base.state s on s.state = csp.state
    left join ermart1.facility_facility ef on ef.facilityid = f.legacykey
    left join ermart1.facility_hospitaldetail hd on hd.facilityid = ef.facilityid
    where ifnull(f.isclosed, 0) = 0
        and ef.facsearchtypeid in (1, 4, 8, 9)
        and ft.facilitytypecode in ('CHDR', 'ESRD', 'STAC', 'HGUC', 'HGPH')
        and length(facilityurl) > 0
),
-- ii left join
cte_client_product_details as (
    select
        d.clientproducttoentityid,
        a.clienttoproductid,
        b.clientcode,
        b.clientname,
        c.productcode,
        pg.productgroupcode,
        f.facilityid
    from
        base.clienttoproduct a
        join base.client b on a.clientid = b.clientid
        join base.product c on a.productid = c.productid
        join base.productgroup pg on c.productgroupid = pg.productgroupid
        join base.clientproducttoentity d on a.clienttoproductid = d.clienttoproductid
        join base.entitytype e on d.entitytypeid = e.entitytypeid and e.entitytypecode = 'FAC'
        join base.facility f on d.entityid = f.facilityid
    where
        a.activeflag = 1
        and pg.productgroupcode = 'PDC'
        and f.isclosed = 0
),

-- jj
cte_entity as (
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
    and cf.clientfeaturecode = 'FCBRL' -- branding level
    and cfv.clientfeaturevaluecode = 'FVCLT' -- client
),

-- kk
cte_description as (
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
-- old nn
cte_facility_image as (
    select
        d.facilityid,
        coalesce(e.mediarelativepath, '') || case when right(coalesce(e.mediarelativepath, ''), 1) <> '/' then '/' else '' end || d.filename as facilityimagepath
    from
        base.facilityimage d
        join base.mediaimagetype e on e.mediaimagetypeid = d.mediaimagetypeid
    where
        e.mediaimagetypecode = 'FACIMAGE'
),
-- PhoneXML
cte_facility_detail_phone as (
select distinct 
    clientproducttoentityid,
    designatedproviderphone as ph, 
    phonetypecode as phtyp
from base.vwupdcfacilitydetail fa
where fa.phonetypecode in ('PTUFS', 'PTHFS') -- hospital - facility specific
),
cte_facility_detail_phone_xml as (
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
    'phone') as phonexml
from cte_facility_detail_phone
group by
    clientproducttoentityid
),
cte_client_detail_phone as (
select distinct 
    clientproducttoentityid,
    designatedproviderphone as ph, 
    phonetypecode as phtyp
from base.vwupdcclientdetail cl
where cl.phonetypecode = 'PTHOS' -- pdc affiliated hospital
),

cte_client_detail_phone_xml as (
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
    'phone') as phonexml
from cte_client_detail_phone
group by
    clientproducttoentityid
),
-- MobilePhoneXML
cte_facility_detail_mobile as (
    select distinct 
        clientproducttoentityid,
        designatedproviderphone as ph, 
        phonetypecode as phtyp
    from base.vwupdcfacilitydetail fa
    where fa.phonetypecode in ('PTUFSM', 'PTHFSM') -- hospital - facility specific
),
cte_facility_mobile_xml as (
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
    'phone') as mobilephonexml
from cte_facility_detail_mobile
group by
    clientproducttoentityid
),
cte_client_detail_mobile as (
    select distinct 
        clientproducttoentityid,
        cl.designatedproviderphone as ph, 
        phonetypecode as phtyp
    from base.vwupdcclientdetail cl
    where cl.phonetypecode = 'PTHOSM' -- pdc affiliated hospital
),
cte_client_mobile_xml as (
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
    'phone') as mobilephonexml
from cte_client_detail_mobile
group by
    clientproducttoentityid
),
-- DesktopPhoneXML
cte_facility_detail_desktop as (
    select distinct 
        clientproducttoentityid,
        designatedproviderphone as ph, 
        phonetypecode as phtyp
    from base.vwupdcfacilitydetail fa
    where fa.phonetypecode in ('PTUFSDTP', 'PTHFSDTP') -- hospital - facility specific
),
cte_client_detail_desktop as (
    select distinct 
        clientproducttoentityid,
        cl.designatedproviderphone as ph, 
        phonetypecode as phtyp
    from base.vwupdcclientdetail cl
    where cl.phonetypecode = 'PTHOSDTP' -- pdc affiliated hospital
),
cte_facility_desktop_xml as (
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
    'phone') as desktopphonexml
from cte_facility_detail_desktop
group by
    clientproducttoentityid
),
cte_client_desktop_xml as (
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
    'phone') as desktopphonexml
from cte_client_detail_desktop
group by
    clientproducttoentityid
),
-- TabletPhoneXML
cte_facility_detail_tablet as (
    select distinct 
        clientproducttoentityid,
        designatedproviderphone as ph, 
        phonetypecode as phtyp
    from base.vwupdcfacilitydetail fa
    where fa.phonetypecode in ('PTUFST', 'PTHFST') -- hospital - facility specific
),
cte_client_detail_tablet as (
    select distinct 
        clientproducttoentityid,
        cl.designatedproviderphone as ph, 
        phonetypecode as phtyp
    from base.vwupdcclientdetail cl
    where cl.phonetypecode = 'PTHOST' -- pdc affiliated hospital
),
cte_facility_tablet_xml as (
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
    'phone') as tabletphonexml
from cte_facility_detail_tablet
group by
    clientproducttoentityid
),
cte_client_tablet_xml as (
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
    'phone') as tabletphonexml
from cte_client_detail_tablet
group by
    clientproducttoentityid
),
-- URLXml
cte_facility_checkin_url as (
    select 
        facilitycode,
        checkinurl as urlval, 
        'FCFURL' as urltyp
    from base.facilitycheckinurl x
),
cte_facility_detail_url as (
    select distinct 
        clientproducttoentityid,
        url as urlval, 
        urltypecode as urltyp
    from base.vwupdcfacilitydetail fa
    where fa.urltypecode in ('FCFURL', 'FCCIURL') -- hospital profile
),
cte_client_detail_url as (
    select distinct 
        clienttoproductid,
        url as urlval, 
        urltypecode as urltyp
    from base.vwupdcclientdetail cl
    where cl.urltypecode = 'FCCLURL' -- client url
),
cte_facility_url as (
    select 
        facilityid,
        facilityurl as urlval,
        'FCCLURL' as urltyp
    from cte_facilityurl
),

cte_facility_checkin_url_xml as (
select
    facilitycode,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(urlval IS NOT NULL, '"urlval":' || '"' || urlval || '"' || ',', '') ||
IFF(urltyp IS NOT NULL, '"urltyp":' || '"' || urltyp || '"', '')
||' }'
    
    )::varchar
    ,
    '',
    'url') as urlxml
from cte_facility_checkin_url
group by
    facilitycode
),

cte_facility_url_xml as (
select
    clientproducttoentityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(urlval IS NOT NULL, '"urlval":' || '"' || urlval || '"' || ',', '') ||
IFF(urltyp IS NOT NULL, '"urltyp":' || '"' || urltyp || '"', '')
||' }'
    
    )::varchar
    ,
    '',
    'url') as urlxml
from cte_facility_detail_url
group by
    clientproducttoentityid
),
cte_client_url_xml as (
select
    clienttoproductid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(urlval IS NOT NULL, '"urlval":' || '"' || urlval || '"' || ',', '') ||
IFF(urltyp IS NOT NULL, '"urltyp":' || '"' || urltyp || '"', '')
||' }'
    
    )::varchar
    ,
    '',
    'url') as urlxml
from cte_client_detail_url
group by
    clienttoproductid
),
cte_facilityurl_xml as (
select
    facilityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(urlval IS NOT NULL, '"urlval":' || '"' || urlval || '"' || ',', '') ||
IFF(urltyp IS NOT NULL, '"urltyp":' || '"' || urltyp || '"', '')
||' }'
    
    )::varchar
    ,
    '',
    'url') as urlxml
from cte_facility_url
group by
    facilityid
),
-- ImageXML
cte_client_image as (
    select distinct 
        clienttoproductid,
        imagefilepath as img, 
        mediaimagetypecode as imgtyp
    from base.vwupdcclientdetail cl
    where cl.mediaimagetypecode = 'FCCLLOGO' --client logo
),
cte_facility_img as (
    select distinct 
        clientproducttoentityid,
        imagefilepath as img, 
        mediaimagetypecode as imgtyp
    from base.vwupdcfacilitydetail
    where mediaimagetypecode = 'FCFLOGO' -- hospital logo
),
cte_combined_image as (
    select distinct 
        clienttoproductid,
        imagefilepath as img, 
        mediaimagetypecode as imgtyp
    from base.vwupdcclientdetail cl
    where cl.mediaimagetypecode = 'FCCLLOGO' --client logo
    union all
    select distinct 
        clienttoproductid,
        imagefilepath as img, 
        mediaimagetypecode as imgtyp
    from base.vwupdcfacilitydetail cl
    where cl.mediaimagetypecode in ('FCCLLOGO','FACIMAGE','FCFLOGO')
),
cte_client_image_xml as (
select
    clienttoproductid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(img IS NOT NULL, '"img":' || '"' || img || '"' || ',', '') ||
IFF(imgTyp IS NOT NULL, '"imgTyp":' || '"' || imgTyp || '"', '')
||' }'
    
    )::varchar
    ,
    '',
    'url') as imagexml
from cte_client_image
group by
    clienttoproductid
),

cte_facility_image_xml as (
select
    clientproducttoentityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(img IS NOT NULL, '"img":' || '"' || img || '"' || ',', '') ||
IFF(imgTyp IS NOT NULL, '"imgTyp":' || '"' || imgTyp || '"', '')
||' }'
    
    )::varchar
    ,
    '',
    'url') as imagexml
from cte_facility_img
group by
    clientproducttoentityid
),
cte_combined_image_xml as (
select
    clienttoproductid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(img IS NOT NULL, '"img":' || '"' || img || '"' || ',', '') ||
IFF(imgTyp IS NOT NULL, '"imgTyp":' || '"' || imgTyp || '"', '')
||' }'
    
    )::varchar
    ,
    '',
    'url') as imagexml
from cte_combined_image
group by
    clienttoproductid
),

cte_facility as (
select distinct
    fac.facilityid,
    fac.legacykey,
    fac.facilitycode,
    fac.facilityname,
    ftype.facilitytypedescription as facilitytype,
    ftype.facilitytypecode,
    search.searchtypedescription as facilitysearchtype,
    f.accreditation,
    f.accreditationdescription,
    f.treatmentschedules,
    fad.phonenumber,
    f.additionaltransportationinformation,
    f.afterhoursphonenumber,
    f.awardsinformation,
    f.closedholidaysinformation,
    f.communityactivitiesinformation,
    f.communityoutreachprograminformation,
    f.communitysupportinformation,
    f.emergencyafterhoursphonenumber,
    f.facilitydescription,
    f.foundationinformation,
    f.healthplaninformation,
    f.ismedicaidaccepted,
    f.ismedicareaccepted,
    f.isteaching,
    f.languageinformation,
    f.medicalservicesinformation,
    f.missionstatement,
    f.officeclosetime,
    f.officeopentime,
    f.onsiteguestservicesinformation,
    f.othereducationandtraininginformation,
    f.otherservicesinformation,
    f.ownershiptype,
    f.parkinginstructionsinformation,
    f.paymentpolicyinformation,
    f.professionalaffiliationinformation,
    f.publictransportationinformation,
    f.regionalrelationshipinformation,
    f.religiousaffiliationinformation,
    f.specialprogramsinformation,
    f.surroundingareainformation,
    case when f.facilityid = 'HGSTE6064176190065' then left(f.teachingprogramsinformation, 2997) else f.teachingprogramsinformation end as teachingprogramsinformation,
    f.tollfreephonenumber,
    f.transplantcapabilitiesinformation,
    f.visitinghoursinformation,
    f.volunteerinformation,
    f.yearestablished,
    f.hospitalaffiliationinformation,
    f.physiciancallcenterphonenumber,
    fr.ratingstar as overallhospitalstar,
    traumalevel.adulttraumalevel,
    traumalevel.pediatrictraumalevel,
    case when hos_details.respgmapprama = 'Y' then 'AMA' end as respgmapprama, 
    case when hos_details.respgmappraoa = 'Y' then 'AOA' end as respgmappraoa,
    case when hos_details.respgmapprada = 'Y' then 'ADA' end as respgmapprada,
    f.miscellaneousinformation,
    f.appointmentinformation,
    hos_details.url as website,
    f.visitinghoursmonday,
    f.visitinghourstuesday,
    f.visitinghourswednesday,
    f.visitinghoursthursday,
    f.visitinghoursfriday,
    f.visitinghourssaturday,
    f.visitinghourssunday,
    fac_details.facilityimagepath,
    client_details.clienttoproductid,
    client_details.clientcode,
    client_details.clientname,
    client_details.productcode,
    client_details.productgroupcode,
    -- phonexml
    case when (ifnull(to_varchar(des.ClientToProductID),'') <> '') and exists 
        (select TOP 1 DesignatedProviderPhone 
        from Base.vwuPDCFacilityDetail fa 
        where fa.PhoneTypeCode in ('PTUFS', 'PTHFS') 
            and client_details.ClientProductToEntityID = fa.ClientProductToEntityID) then 
        pfxml.phonexml 
        when (select top 1 1 from Base.vwuPDCClientDetail cl where cl.PhoneTypeCode = 'PTHOS' and client_details.ClientToProductID = cl.ClientToProductID) is not null then 
        pcxml.phonexml end as phonexml,

    -- mobilephonexml
    case when (select top 1 1 from Base.vwuPDCClientDetail cl where cl.PhoneTypeCode = 'PTHOSM' and client_details.ClientToProductID = cl.ClientToProductID) is not null then mcxml.mobilephonexml
    else mfxml.mobilephonexml end as mobilephonexml,
    
    -- desktopphonexml
    case when (select top 1 1 from Base.vwuPDCClientDetail cl where cl.PhoneTypeCode = 'PTHOSDTP' and client_details.ClientToProductID = cl.ClientToProductID) is not null then dcxml.desktopphonexml
    else dfxml.desktopphonexml end as desktopphonexml,
    
    -- tabletphonexml
    case when (select top 1 1 from Base.vwuPDCClientDetail cl where cl.PhoneTypeCode = 'PTHOST' and client_details.ClientToProductID = cl.ClientToProductID) is not null then tcxml.tabletphonexml
    else tfxml.tabletphonexml end as tabletphonexml,
    
    -- urlxml
    case when (select top 1 facilitycode from base.facilitycheckinurl fc where fc.facilitycode = fac.facilitycode) is not null then fcxml.urlxml
        when (ifnull(to_varchar(des.clienttoproductid), '') <> '') 
    and exists (
        select 1 
        from base.vwupdcfacilitydetail fa 
        where length(fa.url) > 0 
            and fa.urltypecode in ('FCFURL', 'FCCIURL') 
            and client_details.clientproducttoentityid = fa.clientproducttoentityid
        limit 1 ) then fxml.urlxml
        when exists (
            select 1
            from base.vwupdcclientdetail cl
            where length(cl.url) > 0
                and cl.urltypecode = 'FCCLURL'
                and client_details.clienttoproductid = cl.clienttoproductid
            limit 1) then cxml.urlxml
        else fuxml.urlxml end as urlxml,
        
    -- imagexml
    case when (ifnull(to_varchar(entity.clienttoproductid), '') <> '' )
        and exists (
            select 1
            from base.vwupdcclientdetail cl
            where cl.mediaimagetypecode = 'FCCLLOGO'
                and client_details.clienttoproductid = cl.clienttoproductid
            limit 1)  then icxml.imagexml
    when exists (
            select 1
            from base.vwupdcfacilitydetail fa
            where fa.mediaimagetypecode = 'FCFLOGO'
                and client_details.clientproducttoentityid = fa.clientproducttoentityid
            limit 1) then ifxml.imagexml
     else icoxml.imagexml end as imagexml,
    
    furl.facilityurl as facilityurl
from
    base.facility fac
    left join cte_facilityurl furl on furl.facilityid = fac.facilityid
    join ermart1.facility_facility f on fac.legacykey = f.facilityid
    join ermart1.facility_facilityaddressdetail fad on f.facilityid = fad.facilityid
    join base.facilitytofacilitytype ft on ft.facilityid = fac.facilityid
    join base.facilitytype ftype on ft.facilitytypeid = ftype.facilitytypeid
    join ermart1.facility_facsearchtype search on f.facsearchtypeid = search.facsearchtypeid
    left join ermart1.facility_facilitytorating fr on f.facilityid = fr.facilityid and fr.ismaxyear = 1 and fr.ratingid = 1
    left join ermart1.facility_facilitytotraumalevel traumalevel on f.facilityid = traumalevel.facilityid
    left join cte_client_product_details client_details on client_details.facilityid = fac.facilityid --ii
    left join cte_entity entity on entity.clienttoproductid = client_details.clienttoproductid -- jj
    left join cte_description des on des.clienttoproductid = client_details.clienttoproductid --kk
    left join ermart1.facility_hospitaldetail hos_details on f.facilityid = hos_details.facilityid
    left join cte_facility_image fac_details on fac_details.facilityid = fac.facilityid --nn
    join cte_facility_detail_phone_xml pfxml on pfxml.clientproducttoentityid = client_details.clientproducttoentityid
    join cte_client_detail_phone_xml pcxml on pcxml.clientproducttoentityid = client_details.clientproducttoentityid
    join cte_facility_mobile_xml mfxml on mfxml.clientproducttoentityid = client_details.clientproducttoentityid
    join cte_client_mobile_xml mcxml on mcxml.clientproducttoentityid = client_details.clientproducttoentityid
    join cte_facility_desktop_xml dfxml on dfxml.clientproducttoentityid = client_details.clientproducttoentityid
    join cte_client_desktop_xml dcxml on dcxml.clientproducttoentityid = client_details.clientproducttoentityid 
    join cte_facility_tablet_xml tfxml on tfxml.clientproducttoentityid = client_details.clientproducttoentityid
    join cte_client_tablet_xml tcxml on tcxml.clientproducttoentityid = client_details.clientproducttoentityid 
    join cte_facility_checkin_url_xml fcxml on fcxml.facilitycode = fac.facilitycode
    join cte_facility_url_xml fxml on fxml.clientproducttoentityid = client_details.clientproducttoentityid
    join cte_client_url_xml cxml on cxml.clienttoproductid = client_details.clienttoproductid
    join cte_facilityurl_xml fuxml on fuxml.facilityid = fac.facilityid
    join cte_client_image_xml icxml on icxml.clienttoproductid = client_details.clienttoproductid
    join cte_facility_image_xml  ifxml on ifxml.clientproducttoentityid = client_details.clientproducttoentityid
    join cte_combined_image_xml icoxml on icoxml.clienttoproductid = client_details.clienttoproductid
where
    ifnull(fac.isclosed, 0) = 0
    and search.facsearchtypeid in (1, 4, 8, 9)
    and ftype.facilitytypecode in ('CHDR', 'ESRD', 'STAC', 'HGUC', 'HGPH')
),

-- UPDATING CTE_FACILITY
cte_not_in as (
select distinct 
    f.facilityid
from 
    base.clienttoproduct a
    join base.client b on a.clientid = b.clientid
    join base.product c on a.productid = c.productid
    join base.productgroup pg on c.productgroupid = pg.productgroupid
    join base.clientproducttoentity d on a.clienttoproductid = d.clienttoproductid
    join base.entitytype e on d.entitytypeid = e.entitytypeid and e.entitytypecode = 'FAC'
    join base.facility f on d.entityid = f.facilityid
where 
    a.activeflag = 1
    and pg.productgroupcode = 'PDC'
    and ifnull(f.isclosed, 0) = 0
),

cte_facility_update_1 as (
    select
        facilityid,
        legacykey,
        facilitycode,
        facilityname,
        facilitytype,
        facilitytypecode,
        facilitysearchtype,
        accreditation,
        accreditationdescription,
        treatmentschedules,
        phonenumber,
        additionaltransportationinformation,
        afterhoursphonenumber,
        case when facilityid not in (select facilityid from cte_not_in) then null else awardsinformation end as awardsinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else closedholidaysinformation end as closedholidaysinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else communityactivitiesinformation end as communityactivitiesinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else communityoutreachprograminformation end as communityoutreachprograminformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else communitysupportinformation end as communitysupportinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else emergencyafterhoursphonenumber end as emergencyafterhoursphonenumber,
        case when facilityid not in (select facilityid from cte_not_in) then null else facilitydescription end as facilitydescription,
        case when facilityid not in (select facilityid from cte_not_in) then null else foundationinformation end as foundationinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else healthplaninformation end as healthplaninformation,
        ismedicaidaccepted,
        ismedicareaccepted,
        isteaching,
        case when facilityid not in (select facilityid from cte_not_in) then null else languageinformation end as languageinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else medicalservicesinformation end as medicalservicesinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else missionstatement end as missionstatement,
        case when facilityid not in (select facilityid from cte_not_in) then null else officeclosetime end as officeclosetime,
        case when facilityid not in (select facilityid from cte_not_in) then null else officeopentime end as officeopentime,
        case when facilityid not in (select facilityid from cte_not_in) then null else onsiteguestservicesinformation end as onsiteguestservicesinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else othereducationandtraininginformation end as othereducationandtraininginformation,
        otherservicesinformation,
        ownershiptype,
        case when facilityid not in (select facilityid from cte_not_in) then null else parkinginstructionsinformation end as parkinginstructionsinformation,
        paymentpolicyinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else professionalaffiliationinformation end as professionalaffiliationinformation,
        publictransportationinformation,
        regionalrelationshipinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else religiousaffiliationinformation end as religiousaffiliationinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else specialprogramsinformation end as specialprogramsinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else surroundingareainformation end as surroundingareainformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else teachingprogramsinformation end as teachingprogramsinformation,
        tollfreephonenumber,
        case when facilityid not in (select facilityid from cte_not_in) then null else transplantcapabilitiesinformation end as transplantcapabilitiesinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else visitinghoursinformation end as visitinghoursinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else volunteerinformation end as volunteerinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else yearestablished end as yearestablished,
        case when facilityid not in (select facilityid from cte_not_in) then null else hospitalaffiliationinformation end as hospitalaffiliationinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else physiciancallcenterphonenumber end as physiciancallcenterphonenumber,
        overallhospitalstar,
        adulttraumalevel,
        pediatrictraumalevel,
        case when facilityid not in (select facilityid from cte_not_in) then null else respgmapprama end as respgmapprama,
        case when facilityid not in (select facilityid from cte_not_in) then null else respgmappraoa end as respgmappraoa,
        case when facilityid not in (select facilityid from cte_not_in) then null else respgmapprada end as respgmapprada,
        case when facilityid not in (select facilityid from cte_not_in) then null else miscellaneousinformation end as miscellaneousinformation,
        case when facilityid not in (select facilityid from cte_not_in) then null else appointmentinformation end as appointmentinformation,
        website,
        case when facilityid not in (select facilityid from cte_not_in) then null else visitinghoursmonday end as visitinghoursmonday,
        case when facilityid not in (select facilityid from cte_not_in) then null else visitinghourstuesday end as visitinghourstuesday,
        case when facilityid not in (select facilityid from cte_not_in) then null else visitinghourswednesday end as visitinghourswednesday,
        case when facilityid not in (select facilityid from cte_not_in) then null else visitinghoursthursday end as visitinghoursthursday,
        case when facilityid not in (select facilityid from cte_not_in) then null else visitinghoursfriday end as visitinghoursfriday,
        case when facilityid not in (select facilityid from cte_not_in) then null else visitinghourssaturday end as visitinghourssaturday,
        case when facilityid not in (select facilityid from cte_not_in) then null else visitinghourssunday end as visitinghourssunday,
        case when facilityid not in (select facilityid from cte_not_in) then null else facilityimagepath end as facilityimagepath,
        clienttoproductid,
        clientcode,
        clientname,
        productcode,
        productgroupcode,
        phonexml,
        mobilephonexml,
        desktopphonexml,
        tabletphonexml,
        urlxml,
        imagexml,
        facilityurl
    from
        cte_facility
),
-- Count updates
cte_award_count as (
select
    fta.facilityid,
    count(*) as awardcount
from
    ermart1.facility_facilitytoaward fta
    join ermart1.facility_award fa on fta.awardid = fa.awardid and fta.awardname = fa.awardname
where
    fta.ismaxyear = 1
group by
    fta.facilityid
),
cte_procedure_count as (
select
    a.facilityid,
    count(*) as procedurecount
from
    ermart1.facility_facilitytoprocedurerating a
    join ermart1.facility_vwufacilityhgdisplayprocedures b on (a.procedureid = b.procedureid and a.ratingsourceid = b.ratingsourceid)
where
    a.ismaxyear = 1
group by
    a.facilityid
),
cte_fivestar_count as (
select
    a.facilityid,
    count(*) as fivestarprocedurecount
from
    ermart1.facility_facilitytoprocedurerating a
    join ermart1.facility_vwufacilityhgdisplayprocedures b on (a.procedureid = b.procedureid and a.ratingsourceid = b.ratingsourceid)
where
    a.ismaxyear = 1
    and a.overallsurvivalstar = 5
    and a.overallrecovery30star = 5
group by
    a.facilityid
),
cte_provider_count as (
select
    a.facilityid,
    count(a.providerid) as providercount
from
    base.providertofacility a
    join base.facility b on a.facilityid = b.facilityid
group by
    a.facilityid
),
cte_facility_update_2 as (
select
    f.facilityid,
    f.legacykey,
    f.facilitycode,
    f.facilityname,
    f.facilitytype,
    f.facilitytypecode,
    f.facilitysearchtype,
    f.accreditation,
    f.accreditationdescription,
    f.treatmentschedules,
    f.phonenumber,
    f.additionaltransportationinformation,
    f.afterhoursphonenumber,
    f.awardsinformation,
    f.closedholidaysinformation,
    f.communityactivitiesinformation,
    f.communityoutreachprograminformation,
    f.communitysupportinformation,
    f.emergencyafterhoursphonenumber,
    f.facilitydescription,
    f.foundationinformation,
    f.healthplaninformation,
    f.ismedicaidaccepted,
    f.ismedicareaccepted,
    f.isteaching,
    f.languageinformation,
    f.medicalservicesinformation,
    f.missionstatement,
    f.officeclosetime,
    f.officeopentime,
    f.onsiteguestservicesinformation,
    f.othereducationandtraininginformation,
    f.otherservicesinformation,
    f.ownershiptype,
    f.parkinginstructionsinformation,
    f.paymentpolicyinformation,
    f.professionalaffiliationinformation,
    f.publictransportationinformation,
    f.regionalrelationshipinformation,
    f.religiousaffiliationinformation,
    f.specialprogramsinformation,
    f.surroundingareainformation,
    f.teachingprogramsinformation,
    f.tollfreephonenumber,
    f.transplantcapabilitiesinformation,
    f.visitinghoursinformation,
    f.volunteerinformation,
    f.yearestablished,
    f.hospitalaffiliationinformation,
    f.physiciancallcenterphonenumber,
    f.overallhospitalstar,
    f.adulttraumalevel,
    f.pediatrictraumalevel,
    f.respgmapprama,
    f.respgmappraoa,
    f.respgmapprada,
    f.miscellaneousinformation,
    f.appointmentinformation,
    f.website,
    f.visitinghoursmonday,
    f.visitinghourstuesday,
    f.visitinghourswednesday,
    f.visitinghoursthursday,
    f.visitinghoursfriday,
    f.visitinghourssaturday,
    f.visitinghourssunday,
    f.facilityimagepath,
    f.clienttoproductid,
    f.clientcode,
    f.clientname,
    f.productcode,
    f.productgroupcode,
    f.phonexml,
    f.mobilephonexml,
    f.desktopphonexml,
    f.tabletphonexml,
    f.urlxml,
    f.imagexml,
    f.facilityurl,
    ac.awardcount,
    pc.procedurecount,
    fsc.fivestarprocedurecount,
    pvc.providercount
from cte_facility_update_1 as f
    join cte_award_count as ac on f.legacykey = ac.facilityid
    join cte_procedure_count as pc on f.legacykey = pc.facilityid
    join cte_fivestar_count as fsc on f.legacykey = fsc.facilityid
    join cte_provider_count as pvc on f.facilityid = pvc.facilityid ),

cte_facility_update_3 as (
select
    f.facilityid,
    f.legacykey,
    f.facilitycode,
    f.facilityname,
    f.facilitytype,
    f.facilitytypecode,
    f.facilitysearchtype,
    f.accreditation,
    f.accreditationdescription,
    f.treatmentschedules,
    f.phonenumber,
    f.additionaltransportationinformation,
    f.afterhoursphonenumber,
    f.awardsinformation,
    f.closedholidaysinformation,
    f.communityactivitiesinformation,
    f.communityoutreachprograminformation,
    f.communitysupportinformation,
    f.emergencyafterhoursphonenumber,
    f.facilitydescription,
    f.foundationinformation,
    f.healthplaninformation,
    f.ismedicaidaccepted,
    f.ismedicareaccepted,
    f.isteaching,
    f.languageinformation,
    f.medicalservicesinformation,
    f.missionstatement,
    f.officeclosetime,
    f.officeopentime,
    f.onsiteguestservicesinformation,
    f.othereducationandtraininginformation,
    f.otherservicesinformation,
    f.ownershiptype,
    f.parkinginstructionsinformation,
    f.paymentpolicyinformation,
    f.professionalaffiliationinformation,
    f.publictransportationinformation,
    f.regionalrelationshipinformation,
    f.religiousaffiliationinformation,
    f.specialprogramsinformation,
    f.surroundingareainformation,
    f.teachingprogramsinformation,
    f.tollfreephonenumber,
    f.transplantcapabilitiesinformation,
    f.visitinghoursinformation,
    f.volunteerinformation,
    f.yearestablished,
    f.hospitalaffiliationinformation,
    f.physiciancallcenterphonenumber,
    f.overallhospitalstar,
    f.adulttraumalevel,
    f.pediatrictraumalevel,
    f.respgmapprama,
    f.respgmappraoa,
    f.respgmapprada,
    f.miscellaneousinformation,
    f.appointmentinformation,
    f.website,
    f.visitinghoursmonday,
    f.visitinghourstuesday,
    f.visitinghourswednesday,
    f.visitinghoursthursday,
    f.visitinghoursfriday,
    f.visitinghourssaturday,
    f.visitinghourssunday,
    f.facilityimagepath,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.clienttoproductid end as clienttoproductid,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.clientcode end as clientcode,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.clientname end as clientname,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.productcode end as productcode,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.productgroupcode end as productgroupcode,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.phonexml end as phonexml,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.mobilephonexml end as mobilephonexml,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.desktopphonexml end as desktopphonexml,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.tabletphonexml end as tabletphonexml,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.urlxml end as urlxml,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.imagexml end as imagexml,
    f.facilityurl,
    f.awardcount,
    f.procedurecount,
    f.fivestarprocedurecount,
    f.providercount,
    0 as actioncode
from cte_facility_update_2 as f
    join base.client as c on c.clientcode = f.clientcode
    join show.clientcontract as cc on cc.clientid = c.clientid
)
,

-- insert action
cte_action_1 as (
    select 
        cte.facilityid,
        1 as actioncode
    from cte_facility_update_3 as cte
    left join mid.facility as mid
    on cte.facilityid = mid.facilityid and cte.facilitycode = mid.facilitycode 
    where mid.facilityid is null
),

-- update action
cte_action_2 as (
   select 
        cte.facilityid,
        1 as actioncode
    from cte_facility_update_3 as cte
    left join mid.facility as mid
    on cte.facilityid = mid.facilityid and cte.facilitycode = mid.facilitycode 
    where
        md5(ifnull(cte.legacykey::varchar, '')) <> md5(ifnull(mid.legacykey::varchar, '')) or 
        md5(ifnull(cte.facilityname::varchar, '')) <> md5(ifnull(mid.facilityname::varchar, '')) or 
        md5(ifnull(cte.facilitytype::varchar, '')) <> md5(ifnull(mid.facilitytype::varchar, '')) or 
        md5(ifnull(cte.facilitytypecode::varchar, '')) <> md5(ifnull(mid.facilitytypecode::varchar, '')) or 
        md5(ifnull(cte.facilitysearchtype::varchar, '')) <> md5(ifnull(mid.facilitysearchtype::varchar, '')) or 
        md5(ifnull(cte.accreditation::varchar, '')) <> md5(ifnull(mid.accreditation::varchar, '')) or 
        md5(ifnull(cte.accreditationdescription::varchar, '')) <> md5(ifnull(mid.accreditationdescription::varchar, '')) or 
        md5(ifnull(cte.treatmentschedules::varchar, '')) <> md5(ifnull(mid.treatmentschedules::varchar, '')) or 
        md5(ifnull(cte.phonenumber::varchar, '')) <> md5(ifnull(mid.phonenumber::varchar, '')) or 
        md5(ifnull(cte.additionaltransportationinformation::varchar, '')) <> md5(ifnull(mid.additionaltransportationinformation::varchar, '')) or 
        md5(ifnull(cte.afterhoursphonenumber::varchar, '')) <> md5(ifnull(mid.afterhoursphonenumber::varchar, '')) or 
        md5(ifnull(cte.awardsinformation::varchar, '')) <> md5(ifnull(mid.awardsinformation::varchar, '')) or 
        md5(ifnull(cte.closedholidaysinformation::varchar, '')) <> md5(ifnull(mid.closedholidaysinformation::varchar, '')) or 
        md5(ifnull(cte.communityactivitiesinformation::varchar, '')) <> md5(ifnull(mid.communityactivitiesinformation::varchar, '')) or 
        md5(ifnull(cte.communityoutreachprograminformation::varchar, '')) <> md5(ifnull(mid.communityoutreachprograminformation::varchar, '')) or 
        md5(ifnull(cte.communitysupportinformation::varchar, '')) <> md5(ifnull(mid.communitysupportinformation::varchar, '')) or 
        md5(ifnull(cte.emergencyafterhoursphonenumber::varchar, '')) <> md5(ifnull(mid.emergencyafterhoursphonenumber::varchar, '')) or 
        md5(ifnull(cte.facilitydescription::varchar, '')) <> md5(ifnull(mid.facilitydescription::varchar, '')) or 
        md5(ifnull(cte.foundationinformation::varchar, '')) <> md5(ifnull(mid.foundationinformation::varchar, '')) or 
        md5(ifnull(cte.healthplaninformation::varchar, '')) <> md5(ifnull(mid.healthplaninformation::varchar, '')) or 
        md5(ifnull(cte.ismedicaidaccepted::varchar, '')) <> md5(ifnull(mid.ismedicaidaccepted::varchar, '')) or 
        md5(ifnull(cte.ismedicareaccepted::varchar, '')) <> md5(ifnull(mid.ismedicareaccepted::varchar, '')) or 
        md5(ifnull(cte.isteaching::varchar, '')) <> md5(ifnull(mid.isteaching::varchar, '')) or 
        md5(ifnull(cte.languageinformation::varchar, '')) <> md5(ifnull(mid.languageinformation::varchar, '')) or 
        md5(ifnull(cte.medicalservicesinformation::varchar, '')) <> md5(ifnull(mid.medicalservicesinformation::varchar, '')) or 
        md5(ifnull(cte.missionstatement::varchar, '')) <> md5(ifnull(mid.missionstatement::varchar, '')) or 
        md5(ifnull(cte.officeclosetime::varchar, '')) <> md5(ifnull(mid.officeclosetime::varchar, '')) or 
        md5(ifnull(cte.officeopentime::varchar, '')) <> md5(ifnull(mid.officeopentime::varchar, '')) or 
        md5(ifnull(cte.onsiteguestservicesinformation::varchar, '')) <> md5(ifnull(mid.onsiteguestservicesinformation::varchar, '')) or 
        md5(ifnull(cte.othereducationandtraininginformation::varchar, '')) <> md5(ifnull(mid.othereducationandtraininginformation::varchar, '')) or 
        md5(ifnull(cte.otherservicesinformation::varchar, '')) <> md5(ifnull(mid.otherservicesinformation::varchar, '')) or 
        md5(ifnull(cte.ownershiptype::varchar, '')) <> md5(ifnull(mid.ownershiptype::varchar, '')) or 
        md5(ifnull(cte.parkinginstructionsinformation::varchar, '')) <> md5(ifnull(mid.parkinginstructionsinformation::varchar, '')) or 
        md5(ifnull(cte.paymentpolicyinformation::varchar, '')) <> md5(ifnull(mid.paymentpolicyinformation::varchar, '')) or 
        md5(ifnull(cte.professionalaffiliationinformation::varchar, '')) <> md5(ifnull(mid.professionalaffiliationinformation::varchar, '')) or 
        md5(ifnull(cte.publictransportationinformation::varchar, '')) <> md5(ifnull(mid.publictransportationinformation::varchar, '')) or 
        md5(ifnull(cte.regionalrelationshipinformation::varchar, '')) <> md5(ifnull(mid.regionalrelationshipinformation::varchar, '')) or 
        md5(ifnull(cte.religiousaffiliationinformation::varchar, '')) <> md5(ifnull(mid.religiousaffiliationinformation::varchar, '')) or 
        md5(ifnull(cte.specialprogramsinformation::varchar, '')) <> md5(ifnull(mid.specialprogramsinformation::varchar, '')) or 
        md5(ifnull(cte.surroundingareainformation::varchar, '')) <> md5(ifnull(mid.surroundingareainformation::varchar, '')) or 
        md5(ifnull(cte.teachingprogramsinformation::varchar, '')) <> md5(ifnull(mid.teachingprogramsinformation::varchar, '')) or 
        md5(ifnull(cte.tollfreephonenumber::varchar, '')) <> md5(ifnull(mid.tollfreephonenumber::varchar, '')) or 
        md5(ifnull(cte.transplantcapabilitiesinformation::varchar, '')) <> md5(ifnull(mid.transplantcapabilitiesinformation::varchar, '')) or 
        md5(ifnull(cte.visitinghoursinformation::varchar, '')) <> md5(ifnull(mid.visitinghoursinformation::varchar, '')) or 
        md5(ifnull(cte.volunteerinformation::varchar, '')) <> md5(ifnull(mid.volunteerinformation::varchar, '')) or 
        md5(ifnull(cte.yearestablished::varchar, '')) <> md5(ifnull(mid.yearestablished::varchar, '')) or 
        md5(ifnull(cte.hospitalaffiliationinformation::varchar, '')) <> md5(ifnull(mid.hospitalaffiliationinformation::varchar, '')) or 
        md5(ifnull(cte.physiciancallcenterphonenumber::varchar, '')) <> md5(ifnull(mid.physiciancallcenterphonenumber::varchar, '')) or 
        md5(ifnull(cte.overallhospitalstar::varchar, '')) <> md5(ifnull(mid.overallhospitalstar::varchar, '')) or 
        md5(ifnull(cte.adulttraumalevel::varchar, '')) <> md5(ifnull(mid.adulttraumalevel::varchar, '')) or 
        md5(ifnull(cte.pediatrictraumalevel::varchar, '')) <> md5(ifnull(mid.pediatrictraumalevel::varchar, '')) or 
        md5(ifnull(cte.respgmapprama::varchar, '')) <> md5(ifnull(mid.respgmapprama::varchar, '')) or 
        md5(ifnull(cte.respgmappraoa::varchar, '')) <> md5(ifnull(mid.respgmappraoa::varchar, '')) or 
        md5(ifnull(cte.respgmapprada::varchar, '')) <> md5(ifnull(mid.respgmapprada::varchar, '')) or 
        md5(ifnull(cte.miscellaneousinformation::varchar, '')) <> md5(ifnull(mid.miscellaneousinformation::varchar, '')) or 
        md5(ifnull(cte.appointmentinformation::varchar, '')) <> md5(ifnull(mid.appointmentinformation::varchar, '')) or 
        md5(ifnull(cte.website::varchar, '')) <> md5(ifnull(mid.website::varchar, '')) or 
        md5(ifnull(cte.visitinghoursmonday::varchar, '')) <> md5(ifnull(mid.visitinghoursmonday::varchar, '')) or 
        md5(ifnull(cte.visitinghourstuesday::varchar, '')) <> md5(ifnull(mid.visitinghourstuesday::varchar, '')) or 
        md5(ifnull(cte.visitinghourswednesday::varchar, '')) <> md5(ifnull(mid.visitinghourswednesday::varchar, '')) or 
        md5(ifnull(cte.visitinghoursthursday::varchar, '')) <> md5(ifnull(mid.visitinghoursthursday::varchar, '')) or 
        md5(ifnull(cte.visitinghoursfriday::varchar, '')) <> md5(ifnull(mid.visitinghoursfriday::varchar, '')) or 
        md5(ifnull(cte.visitinghourssaturday::varchar, '')) <> md5(ifnull(mid.visitinghourssaturday::varchar, '')) or 
        md5(ifnull(cte.visitinghourssunday::varchar, '')) <> md5(ifnull(mid.visitinghourssunday::varchar, '')) or 
        md5(ifnull(cte.facilityimagepath::varchar, '')) <> md5(ifnull(mid.facilityimagepath::varchar, '')) or 
        md5(ifnull(cte.clienttoproductid::varchar, '')) <> md5(ifnull(mid.clienttoproductid::varchar, '')) or 
        md5(ifnull(cte.clientcode::varchar, '')) <> md5(ifnull(mid.clientcode::varchar, '')) or 
        md5(ifnull(cte.clientname::varchar, '')) <> md5(ifnull(mid.clientname::varchar, '')) or 
        md5(ifnull(cte.productcode::varchar, '')) <> md5(ifnull(mid.productcode::varchar, '')) or 
        md5(ifnull(cte.productgroupcode::varchar, '')) <> md5(ifnull(mid.productgroupcode::varchar, '')) or 
        md5(ifnull(cte.phonexml::varchar, '')) <> md5(ifnull(mid.phonexml::varchar, '')) or 
        md5(ifnull(cte.mobilephonexml::varchar, '')) <> md5(ifnull(mid.mobilephonexml::varchar, '')) or 
        md5(ifnull(cte.desktopphonexml::varchar, '')) <> md5(ifnull(mid.desktopphonexml::varchar, '')) or 
        md5(ifnull(cte.tabletphonexml::varchar, '')) <> md5(ifnull(mid.tabletphonexml::varchar, '')) or 
        md5(ifnull(cte.urlxml::varchar, '')) <> md5(ifnull(mid.urlxml::varchar, '')) or 
        md5(ifnull(cte.imagexml::varchar, '')) <> md5(ifnull(mid.imagexml::varchar, '')) or 
        md5(ifnull(cte.facilityurl::varchar, '')) <> md5(ifnull(mid.facilityurl::varchar, '')) or 
        md5(ifnull(cte.awardcount::varchar, '')) <> md5(ifnull(mid.awardcount::varchar, '')) or 
        md5(ifnull(cte.procedurecount::varchar, '')) <> md5(ifnull(mid.procedurecount::varchar, '')) or 
        md5(ifnull(cte.fivestarprocedurecount::varchar, '')) <> md5(ifnull(mid.fivestarprocedurecount::varchar, '')) or 
        md5(ifnull(cte.providercount::varchar, '')) <> md5(ifnull(mid.providercount::varchar, ''))
)

select distinct
    a0.facilityid,
    a0.legacykey,
    a0.facilitycode,
    a0.facilityname,
    a0.facilitytype,
    a0.facilitytypecode,
    a0.facilitysearchtype,
    a0.accreditation,
    a0.accreditationdescription,
    a0.treatmentschedules,
    a0.phonenumber,
    a0.additionaltransportationinformation,
    a0.afterhoursphonenumber,
    a0.awardsinformation,
    a0.closedholidaysinformation,
    a0.communityactivitiesinformation,
    a0.communityoutreachprograminformation,
    a0.communitysupportinformation,
    a0.emergencyafterhoursphonenumber,
    a0.facilitydescription,
    a0.foundationinformation,
    a0.healthplaninformation,
    a0.ismedicaidaccepted,
    a0.ismedicareaccepted,
    a0.isteaching,
    a0.languageinformation,
    a0.medicalservicesinformation,
    a0.missionstatement,
    a0.officeclosetime,
    a0.officeopentime,
    a0.onsiteguestservicesinformation,
    a0.othereducationandtraininginformation,
    a0.otherservicesinformation,
    a0.ownershiptype,
    a0.parkinginstructionsinformation,
    a0.paymentpolicyinformation,
    a0.professionalaffiliationinformation,
    a0.publictransportationinformation,
    a0.regionalrelationshipinformation,
    a0.religiousaffiliationinformation,
    a0.specialprogramsinformation,
    a0.surroundingareainformation,
    a0.teachingprogramsinformation,
    a0.tollfreephonenumber,
    a0.transplantcapabilitiesinformation,
    a0.visitinghoursinformation,
    a0.volunteerinformation,
    a0.yearestablished,
    a0.hospitalaffiliationinformation,
    a0.physiciancallcenterphonenumber,
    a0.overallhospitalstar,
    a0.adulttraumalevel,
    a0.pediatrictraumalevel,
    a0.respgmapprama,
    a0.respgmappraoa,
    a0.respgmapprada,
    a0.miscellaneousinformation,
    a0.appointmentinformation,
    a0.website,
    a0.visitinghoursmonday,
    a0.visitinghourstuesday,
    a0.visitinghourswednesday,
    a0.visitinghoursthursday,
    a0.visitinghoursfriday,
    a0.visitinghourssaturday,
    a0.visitinghourssunday,
    a0.facilityimagepath,
    a0.clienttoproductid,
    a0.clientcode,
    a0.clientname,
    a0.productcode,
    a0.productgroupcode,
    to_variant(a0.phonexml) as phonexml,
    to_variant(a0.mobilephonexml) as mobilephonexml,
    to_variant(a0.desktopphonexml) as desktopphonexml,
    to_variant(a0.tabletphonexml) as tabletphonexml,
    to_variant(a0.urlxml) as urlxml,
    to_variant(a0.imagexml) as imagexml,
    a0.facilityurl,
    a0.awardcount,
    a0.procedurecount,
    a0.fivestarprocedurecount,
    a0.providercount,
    ifnull(a1.actioncode, ifnull(a2.actioncode, a0.actioncode)) as ActionCode 
from cte_facility_update_3 as a0 
left join cte_action_1 as a1 on a0.facilityid = a1.facilityid
left join cte_action_2 as a2 on a0.facilityid = a2.facilityid
where ifnull(a1.actioncode, ifnull(a2.actioncode, a0.actioncode)) <> 0 $$;

--- Update Statement
update_statement := ' update 
                     set
                        target.facilityid = source.facilityid,
                        target.legacykey = source.legacykey,
                        target.facilitycode = source.facilitycode,
                        target.facilityname = source.facilityname,
                        target.facilitytype = source.facilitytype,
                        target.facilitytypecode = source.facilitytypecode,
                        target.facilitysearchtype = source.facilitysearchtype,
                        target.accreditation = source.accreditation,
                        target.accreditationdescription = source.accreditationdescription,
                        target.treatmentschedules = source.treatmentschedules,
                        target.phonenumber = source.phonenumber,
                        target.additionaltransportationinformation = source.additionaltransportationinformation,
                        target.afterhoursphonenumber = source.afterhoursphonenumber,
                        target.awardsinformation = source.awardsinformation,
                        target.closedholidaysinformation = source.closedholidaysinformation,
                        target.communityactivitiesinformation = source.communityactivitiesinformation,
                        target.communityoutreachprograminformation = source.communityoutreachprograminformation,
                        target.communitysupportinformation = source.communitysupportinformation,
                        target.emergencyafterhoursphonenumber = source.emergencyafterhoursphonenumber,
                        target.facilitydescription = source.facilitydescription,
                        target.foundationinformation = source.foundationinformation,
                        target.healthplaninformation = source.healthplaninformation,
                        target.ismedicaidaccepted = source.ismedicaidaccepted,
                        target.ismedicareaccepted = source.ismedicareaccepted,
                        target.isteaching = source.isteaching,
                        target.languageinformation = source.languageinformation,
                        target.medicalservicesinformation = source.medicalservicesinformation,
                        target.missionstatement = source.missionstatement,
                        target.officeclosetime = source.officeclosetime,
                        target.officeopentime = source.officeopentime,
                        target.onsiteguestservicesinformation = source.onsiteguestservicesinformation,
                        target.othereducationandtraininginformation = source.othereducationandtraininginformation,
                        target.otherservicesinformation = source.otherservicesinformation,
                        target.ownershiptype = source.ownershiptype,
                        target.parkinginstructionsinformation = source.parkinginstructionsinformation,
                        target.paymentpolicyinformation = source.paymentpolicyinformation,
                        target.professionalaffiliationinformation = source.professionalaffiliationinformation,
                        target.publictransportationinformation = source.publictransportationinformation,
                        target.regionalrelationshipinformation = source.regionalrelationshipinformation,
                        target.religiousaffiliationinformation = source.religiousaffiliationinformation,
                        target.specialprogramsinformation = source.specialprogramsinformation,
                        target.surroundingareainformation = source.surroundingareainformation,
                        target.teachingprogramsinformation = source.teachingprogramsinformation,
                        target.tollfreephonenumber = source.tollfreephonenumber,
                        target.transplantcapabilitiesinformation = source.transplantcapabilitiesinformation,
                        target.visitinghoursinformation = source.visitinghoursinformation,
                        target.volunteerinformation = source.volunteerinformation,
                        target.yearestablished = source.yearestablished,
                        target.hospitalaffiliationinformation = source.hospitalaffiliationinformation,
                        target.physiciancallcenterphonenumber = source.physiciancallcenterphonenumber,
                        target.overallhospitalstar = source.overallhospitalstar,
                        target.adulttraumalevel = source.adulttraumalevel,
                        target.pediatrictraumalevel = source.pediatrictraumalevel,
                        target.respgmapprama = source.respgmapprama,
                        target.respgmappraoa = source.respgmappraoa,
                        target.respgmapprada = source.respgmapprada,
                        target.miscellaneousinformation = source.miscellaneousinformation,
                        target.appointmentinformation = source.appointmentinformation,
                        target.website = source.website,
                        target.visitinghoursmonday = source.visitinghoursmonday,
                        target.visitinghourstuesday = source.visitinghourstuesday,
                        target.visitinghourswednesday = source.visitinghourswednesday,
                        target.visitinghoursthursday = source.visitinghoursthursday,
                        target.visitinghoursfriday = source.visitinghoursfriday,
                        target.visitinghourssaturday = source.visitinghourssaturday,
                        target.visitinghourssunday = source.visitinghourssunday,
                        target.facilityimagepath = source.facilityimagepath,
                        target.clienttoproductid = source.clienttoproductid,
                        target.clientcode = source.clientcode,
                        target.clientname = source.clientname,
                        target.productcode = source.productcode,
                        target.productgroupcode = source.productgroupcode,
                        target.phonexml = source.phonexml,
                        target.mobilephonexml = source.mobilephonexml,
                        target.desktopphonexml = source.desktopphonexml,
                        target.tabletphonexml = source.tabletphonexml,
                        target.urlxml = source.urlxml,
                        target.imagexml = source.imagexml,
                        target.facilityurl = source.facilityurl,
                        target.awardcount = source.awardcount,
                        target.procedurecount = source.procedurecount,
                        target.fivestarprocedurecount = source.fivestarprocedurecount,
                        target.providercount = source.providercount ';

--- Insert Statement
insert_statement := ' insert  ( facilityid,
                                legacykey,
                                facilitycode,
                                facilityname,
                                facilitytype,
                                facilitytypecode,
                                facilitysearchtype,
                                accreditation,
                                accreditationdescription,
                                treatmentschedules,
                                phonenumber,
                                additionaltransportationinformation,
                                afterhoursphonenumber,
                                awardsinformation,
                                closedholidaysinformation,
                                communityactivitiesinformation,
                                communityoutreachprograminformation,
                                communitysupportinformation,
                                emergencyafterhoursphonenumber,
                                facilitydescription,
                                foundationinformation,
                                healthplaninformation,
                                ismedicaidaccepted,
                                ismedicareaccepted,
                                isteaching,
                                languageinformation,
                                medicalservicesinformation,
                                missionstatement,
                                officeclosetime,
                                officeopentime,
                                onsiteguestservicesinformation,
                                othereducationandtraininginformation,
                                otherservicesinformation,
                                ownershiptype,
                                parkinginstructionsinformation,
                                paymentpolicyinformation,
                                professionalaffiliationinformation,
                                publictransportationinformation,
                                regionalrelationshipinformation,
                                religiousaffiliationinformation,
                                specialprogramsinformation,
                                surroundingareainformation,
                                teachingprogramsinformation,
                                tollfreephonenumber,
                                transplantcapabilitiesinformation,
                                visitinghoursinformation,
                                volunteerinformation,
                                yearestablished,
                                hospitalaffiliationinformation,
                                physiciancallcenterphonenumber,
                                overallhospitalstar,
                                adulttraumalevel,
                                pediatrictraumalevel,
                                respgmapprama,
                                respgmappraoa,
                                respgmapprada,
                                miscellaneousinformation,
                                appointmentinformation,
                                website,
                                visitinghoursmonday,
                                visitinghourstuesday,
                                visitinghourswednesday,
                                visitinghoursthursday,
                                visitinghoursfriday,
                                visitinghourssaturday,
                                visitinghourssunday,
                                facilityimagepath,
                                clienttoproductid,
                                clientcode,
                                clientname,
                                productcode,
                                productgroupcode,
                                phonexml,
                                mobilephonexml,
                                desktopphonexml,
                                tabletphonexml,
                                urlxml,
                                imagexml,
                                facilityurl,
                                awardcount,
                                procedurecount,
                                fivestarprocedurecount,
                                providercount )
                                
                      values (  source.facilityid,
                                source.legacykey,
                                source.facilitycode,
                                source.facilityname,
                                source.facilitytype,
                                source.facilitytypecode,
                                source.facilitysearchtype,
                                source.accreditation,
                                source.accreditationdescription,
                                source.treatmentschedules,
                                source.phonenumber,
                                source.additionaltransportationinformation,
                                source.afterhoursphonenumber,
                                source.awardsinformation,
                                source.closedholidaysinformation,
                                source.communityactivitiesinformation,
                                source.communityoutreachprograminformation,
                                source.communitysupportinformation,
                                source.emergencyafterhoursphonenumber,
                                source.facilitydescription,
                                source.foundationinformation,
                                source.healthplaninformation,
                                source.ismedicaidaccepted,
                                source.ismedicareaccepted,
                                source.isteaching,
                                source.languageinformation,
                                source.medicalservicesinformation,
                                source.missionstatement,
                                source.officeclosetime,
                                source.officeopentime,
                                source.onsiteguestservicesinformation,
                                source.othereducationandtraininginformation,
                                source.otherservicesinformation,
                                source.ownershiptype,
                                source.parkinginstructionsinformation,
                                source.paymentpolicyinformation,
                                source.professionalaffiliationinformation,
                                source.publictransportationinformation,
                                source.regionalrelationshipinformation,
                                source.religiousaffiliationinformation,
                                source.specialprogramsinformation,
                                source.surroundingareainformation,
                                source.teachingprogramsinformation,
                                source.tollfreephonenumber,
                                source.transplantcapabilitiesinformation,
                                source.visitinghoursinformation,
                                source.volunteerinformation,
                                source.yearestablished,
                                source.hospitalaffiliationinformation,
                                source.physiciancallcenterphonenumber,
                                source.overallhospitalstar,
                                source.adulttraumalevel,
                                source.pediatrictraumalevel,
                                source.respgmapprama,
                                source.respgmappraoa,
                                source.respgmapprada,
                                source.miscellaneousinformation,
                                source.appointmentinformation,
                                source.website,
                                source.visitinghoursmonday,
                                source.visitinghourstuesday,
                                source.visitinghourswednesday,
                                source.visitinghoursthursday,
                                source.visitinghoursfriday,
                                source.visitinghourssaturday,
                                source.visitinghourssunday,
                                source.facilityimagepath,
                                source.clienttoproductid,
                                source.clientcode,
                                source.clientname,
                                source.productcode,
                                source.productgroupcode,
                                source.phonexml,
                                source.mobilephonexml,
                                source.desktopphonexml,
                                source.tabletphonexml,
                                source.urlxml,
                                source.imagexml,
                                source.facilityurl,
                                source.awardcount,
                                source.procedurecount,
                                source.fivestarprocedurecount,
                                source.providercount
                        
                        )';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.facility as target using 
                   ('||select_statement||') as source 
                   on source.facilityid = target.facilityid and source.facilitycode = target.facilitycode
                   when matched and source.actioncode = 2 then '||update_statement|| '
                   when not matched and source.actioncode = 1 then '||insert_statement;
                   
        
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 
                    
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