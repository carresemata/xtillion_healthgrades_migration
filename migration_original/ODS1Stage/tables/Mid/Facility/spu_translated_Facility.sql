CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_FACILITY(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
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
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    select_statement_xml string;
    update_statement_xml string;
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_facility');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement

select_statement := $$ with cte_temp_facility as (
    select f.*
    from base.facility f 
    inner join $$||mdm_db||$$.mst.facility_profile_processing proc on f.facilitycode = proc.ref_facility_code
),
cte_facilityurl as (
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
    from cte_temp_facility f
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
        join cte_temp_facility f on d.entityid = f.facilityid
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

cte_facility as (
select
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
    furl.facilityurl as facilityurl
from
    cte_temp_facility fac
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
    join cte_temp_facility f on d.entityid = f.facilityid
where 
    a.activeflag = 1
    and pg.productgroupcode = 'PDC'
    and ifnull(f.isclosed, 0) = 0
),

cte_facility_update_1 as (
    select
        fac.facilityid,
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
        case when cte_fac.facilityid is null then null else awardsinformation end as awardsinformation,
        case when cte_fac.facilityid is null then null else closedholidaysinformation end as closedholidaysinformation,
        case when cte_fac.facilityid is null then null else communityactivitiesinformation end as communityactivitiesinformation,
        case when cte_fac.facilityid is null then null else communityoutreachprograminformation end as communityoutreachprograminformation,
        case when cte_fac.facilityid is null then null else communitysupportinformation end as communitysupportinformation,
        case when cte_fac.facilityid is null then null else emergencyafterhoursphonenumber end as emergencyafterhoursphonenumber,
        case when cte_fac.facilityid is null then null else facilitydescription end as facilitydescription,
        case when cte_fac.facilityid is null then null else foundationinformation end as foundationinformation,
        case when cte_fac.facilityid is null then null else healthplaninformation end as healthplaninformation,
        ismedicaidaccepted,
        ismedicareaccepted,
        isteaching,
        case when cte_fac.facilityid is null then null else languageinformation end as languageinformation,
        case when cte_fac.facilityid is null then null else medicalservicesinformation end as medicalservicesinformation,
        case when cte_fac.facilityid is null then null else missionstatement end as missionstatement,
        case when cte_fac.facilityid is null then null else officeclosetime end as officeclosetime,
        case when cte_fac.facilityid is null then null else officeopentime end as officeopentime,
        case when cte_fac.facilityid is null then null else onsiteguestservicesinformation end as onsiteguestservicesinformation,
        case when cte_fac.facilityid is null then null else othereducationandtraininginformation end as othereducationandtraininginformation,
        otherservicesinformation,
        ownershiptype,
        case when cte_fac.facilityid is null then null else parkinginstructionsinformation end as parkinginstructionsinformation,
        paymentpolicyinformation,
        case when cte_fac.facilityid is null then null else professionalaffiliationinformation end as professionalaffiliationinformation,
        publictransportationinformation,
        regionalrelationshipinformation,
        case when cte_fac.facilityid is null then null else religiousaffiliationinformation end as religiousaffiliationinformation,
        case when cte_fac.facilityid is null then null else specialprogramsinformation end as specialprogramsinformation,
        case when cte_fac.facilityid is null then null else surroundingareainformation end as surroundingareainformation,
        case when cte_fac.facilityid is null then null else teachingprogramsinformation end as teachingprogramsinformation,
        tollfreephonenumber,
        case when cte_fac.facilityid is null then null else transplantcapabilitiesinformation end as transplantcapabilitiesinformation,
        case when cte_fac.facilityid is null then null else visitinghoursinformation end as visitinghoursinformation,
        case when cte_fac.facilityid is null then null else volunteerinformation end as volunteerinformation,
        case when cte_fac.facilityid is null then null else yearestablished end as yearestablished,
        case when cte_fac.facilityid is null then null else hospitalaffiliationinformation end as hospitalaffiliationinformation,
        case when cte_fac.facilityid is null then null else physiciancallcenterphonenumber end as physiciancallcenterphonenumber,
        overallhospitalstar,
        adulttraumalevel,
        pediatrictraumalevel,
        case when cte_fac.facilityid is null then null else respgmapprama end as respgmapprama,
        case when cte_fac.facilityid is null then null else respgmappraoa end as respgmappraoa,
        case when cte_fac.facilityid is null then null else respgmapprada end as respgmapprada,
        case when cte_fac.facilityid is null then null else miscellaneousinformation end as miscellaneousinformation,
        case when cte_fac.facilityid is null then null else appointmentinformation end as appointmentinformation,
        website,
        case when cte_fac.facilityid is null then null else visitinghoursmonday end as visitinghoursmonday,
        case when cte_fac.facilityid is null then null else visitinghourstuesday end as visitinghourstuesday,
        case when cte_fac.facilityid is null then null else visitinghourswednesday end as visitinghourswednesday,
        case when cte_fac.facilityid is null then null else visitinghoursthursday end as visitinghoursthursday,
        case when cte_fac.facilityid is null then null else visitinghoursfriday end as visitinghoursfriday,
        case when cte_fac.facilityid is null then null else visitinghourssaturday end as visitinghourssaturday,
        case when cte_fac.facilityid is null then null else visitinghourssunday end as visitinghourssunday,
        case when cte_fac.facilityid is null then null else facilityimagepath end as facilityimagepath,
        clienttoproductid,
        clientcode,
        clientname,
        productcode,
        productgroupcode,
        facilityurl
    from
        cte_facility fac
        left join cte_not_in cte_fac on fac.facilityid = cte_fac.facilityid
)
-- select * from cte_facility_update_1;
,
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
        join cte_temp_facility b on a.facilityid = b.facilityid
    group by
        a.facilityid
),
cte_num_hosp as (
            SELECT COUNT (DISTINCT FacilityID) as numhosp
			FROM	ERMART1.Facility_FacilityToRating a
					JOIN ERMART1.Facility_Rating b ON a.RatingID = b.RatingID
			WHERE	b.RatingCategoryId = 2
					AND a.IsMaxYear = 1
					AND a.RatingID = 25
					AND EventCount > 0
),
cte_total_number_hosp as
			(SELECT COUNT (DISTINCT FacilityID) as totalnumhosp
			FROM	ERMART1.Facility_FacilityToRating a
					JOIN ERMART1.Facility_Rating b ON a.RatingID = b.RatingID
			WHERE	b.RatingCategoryId = 2
					AND a.IsMaxYear = 1
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
        f.facilityurl,
        ac.awardcount,
        pc.procedurecount,
        fsc.fivestarprocedurecount,
        pvc.providercount,
        round(DIV0((select numhosp from cte_num_hosp ), (select totalnumhosp from cte_total_number_hosp)) * 100, 1) as foreignobjectleftpercent
    from cte_facility_update_1 as f
        left join cte_award_count as ac on f.legacykey = ac.facilityid
        left join cte_procedure_count as pc on f.legacykey = pc.facilityid
        left join cte_fivestar_count as fsc on f.legacykey = fsc.facilityid
        left join cte_provider_count as pvc on f.facilityid = pvc.facilityid 
) ,

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
    f.facilityurl,
    f.awardcount,
    f.procedurecount,
    f.fivestarprocedurecount,
    f.providercount,
    f.foreignobjectleftpercent
from cte_facility_update_2 as f
    left join base.client as c on c.clientcode = f.clientcode
    left join show.clientcontract as cc on cc.clientid = c.clientid
)

select distinct
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
    facilityurl,
    awardcount,
    procedurecount,
    fivestarprocedurecount,
    providercount,
    foreignobjectleftpercent
from cte_facility_update_3 
qualify row_number() over(partition by facilityid order by facilityid desc) = 1
 $$;


 select_statement_xml := $$ 

with cte_temp_facility as (
    select f.*
    from base.facility f 
    inner join $$||mdm_db||$$.mst.facility_profile_processing proc on f.facilitycode = proc.ref_facility_code
),


cte_facilityurl as (
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
    from cte_temp_facility f
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
        join cte_temp_facility f on d.entityid = f.facilityid
    where
        a.activeflag = 1
        and pg.productgroupcode = 'PDC'
        and f.isclosed = 0
),

--------------- PhoneXML -------------------
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
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
    iff(phTyp is not null,'<phTyp>' || phTyp || '</phTyp>','')  || '</phone>','') as phonexml
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
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
    iff(phTyp is not null,'<phTyp>' || phTyp || '</phTyp>','')  || '</phone>','') as phonexml
    from cte_client_detail_phone
    group by
        clientproducttoentityid
),
----------------- MobilePhoneXML -----------------------
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
        listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
    iff(phTyp is not null,'<phTyp>' || phTyp || '</phTyp>','')  || '</phone>','') as mobilephonexml
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
    listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phTyp is not null,'<phTyp>' || phTyp || '</phTyp>','')  || '</phone>','') as mobilephonexml
from cte_client_detail_mobile
group by
    clientproducttoentityid
),
--------------- DesktopPhoneXML ----------------------
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
    listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phTyp is not null,'<phTyp>' || phTyp || '</phTyp>','')  || '</phone>','') as desktopphonexml
from cte_facility_detail_desktop
group by
    clientproducttoentityid
),
cte_client_desktop_xml as (
select
    clientproducttoentityid,
    listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phTyp is not null,'<phTyp>' || phTyp || '</phTyp>','')  || '</phone>','') as desktopphonexml
from cte_client_detail_desktop
group by
    clientproducttoentityid
),
------------- TabletPhoneXML -----------------
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
    listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phTyp is not null,'<phTyp>' || phTyp || '</phTyp>','')  || '</phone>','') as tabletphonexml
from cte_facility_detail_tablet
group by
    clientproducttoentityid
),
cte_client_tablet_xml as (
select
    clientproducttoentityid,
    listagg( '<phone>' || iff(ph is not null,'<ph>' || ph || '</ph>','') ||
iff(phTyp is not null,'<phTyp>' || phTyp || '</phTyp>','')  || '</phone>','') as tabletphonexml
from cte_client_detail_tablet
group by
    clientproducttoentityid
),
--------------------- URLXml ------------------------
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
    listagg( '<url>' || iff(urlval is not null,'<urlval>' || urlval || '</urlval>','') ||
iff(urltyp is not null,'<urltyp>' || urltyp || '</urltyp>','')  || '</url>','') as urlxml
from cte_facility_checkin_url
group by
    facilitycode
),

cte_facility_url_xml as (
select
    clientproducttoentityid,
    listagg( '<url>' || iff(urlval is not null,'<urlval>' || urlval || '</urlval>','') ||
iff(urltyp is not null,'<urltyp>' || urltyp || '</urltyp>','')  || '</url>','') as urlxml
from cte_facility_detail_url
group by
    clientproducttoentityid
),
cte_client_url_xml as (
select
    clienttoproductid,
    listagg( '<url>' || iff(urlval is not null,'<urlval>' || urlval || '</urlval>','') ||
iff(urltyp is not null,'<urltyp>' || urltyp || '</urltyp>','')  || '</url>','') as urlxml
from cte_client_detail_url
group by
    clienttoproductid
),
cte_facilityurl_xml as (
select
    facilityid,
    listagg( '<url>' || iff(urlval is not null,'<urlval>' || urlval || '</urlval>','') ||
iff(urltyp is not null,'<urltyp>' || urltyp || '</urltyp>','')  || '</url>','') as urlxml
from cte_facility_url
group by
    facilityid
),
------------------ ImageXML ----------------------
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
    listagg( '<url>' || iff(img is not null,'<img>' || img || '</img>','') ||
iff(imgTyp is not null,'<imgTyp>' || imgTyp || '</imgTyp>','')  || '</url>','') as imagexml
from cte_client_image
group by
    clienttoproductid
),

cte_facility_image_xml as (
select
    clientproducttoentityid,
    listagg( '<url>' || iff(img is not null,'<img>' || img || '</img>','') ||
iff(imgTyp is not null,'<imgTyp>' || imgTyp || '</imgTyp>','')  || '</url>','') as imagexml
from cte_facility_img
group by
    clientproducttoentityid
),
cte_combined_image_xml as (
select
    clienttoproductid,
    listagg( '<url>' || iff(img is not null,'<img>' || img || '</img>','') ||
iff(imgTyp is not null,'<imgTyp>' || imgTyp || '</imgTyp>','')  || '</url>','') as imagexml
from cte_combined_image
group by
    clienttoproductid
),
cte_url_xml as(
select * from (
select
    fac.facilityid,
    -- urlxml
    case 
        when (select count(*) from base.facilitycheckinurl fc where fc.facilitycode = fac.facilitycode) > 0 
        then fcxml.urlxml
        when (ifnull(to_varchar(des.clienttoproductid), '') <> '') 
            and (select COUNT(*) from base.vwupdcfacilitydetail fa where length(fa.url) > 0 and fa.urltypecode in ('FCFURL', 'FCCIURL') and client_details.clientproducttoentityid = fa.clientproducttoentityid ) > 0
        then fxml.urlxml
        when (select COUNT(*) from base.vwupdcclientdetail cl where length(cl.url) > 0 and cl.urltypecode = 'FCCLURL' and client_details.clienttoproductid = cl.clienttoproductid) > 0 
        then cxml.urlxml
        else fuxml.urlxml end as urlxml
    from mid.facility fac
    left join cte_client_product_details client_details on client_details.facilityid = fac.facilityid 
    left join cte_description des on des.clienttoproductid = client_details.clienttoproductid
    left join cte_facility_checkin_url_xml fcxml on fcxml.facilitycode = fac.facilitycode
    left join cte_facility_url_xml fxml on fxml.clientproducttoentityid = client_details.clientproducttoentityid
    left join cte_client_url_xml cxml on cxml.clienttoproductid = client_details.clienttoproductid
    left join cte_facilityurl_xml fuxml on fuxml.facilityid = fac.facilityid
    )
    where urlxml is not null
),
    
cte_facility_xml as 
(select 
    fac.facilityid,
    client_details.clientcode,
        -- phonexml
    case 
        when (ifnull(to_varchar(des.ClientToProductID),'') <> '') 
            and  (select count(*) from Base.vwuPDCFacilityDetail fa where fa.PhoneTypeCode in ('PTUFS', 'PTHFS') and client_details.ClientProductToEntityID = fa.ClientProductToEntityID) > 0 
        then pfxml.phonexml 
        when (select count(*) from Base.vwuPDCClientDetail cl where cl.PhoneTypeCode = 'PTHOS' and client_details.ClientToProductID = cl.ClientToProductID) > 0 
        then pcxml.phonexml end as phonexml,
    -- -- mobilephonexml
    case 
        when (select count(*) from Base.vwuPDCClientDetail cl where cl.PhoneTypeCode = 'PTHOSM' and client_details.ClientToProductID = cl.ClientToProductID ) > 0 
        then mcxml.mobilephonexml
        else mfxml.mobilephonexml end as mobilephonexml,
    -- -- desktopphonexml
    case 
        when (select count(*) from Base.vwuPDCClientDetail cl where cl.PhoneTypeCode = 'PTHOSDTP' and client_details.ClientToProductID = cl.ClientToProductID) > 0 
        then dcxml.desktopphonexml
        else dfxml.desktopphonexml end as desktopphonexml,
    -- -- tabletphonexml
    case 
        when (select count(*) from Base.vwuPDCClientDetail cl where cl.PhoneTypeCode = 'PTHOST' and client_details.ClientToProductID = cl.ClientToProductID) > 0 
        then tcxml.tabletphonexml
        else tfxml.tabletphonexml end as tabletphonexml,
    -- urlxml
    cte_url.urlxml,
    -- -- imagexml
    case 
    when (ifnull(to_varchar(entity.clienttoproductid), '') <> '' )
        and  (select count(*) from base.vwupdcclientdetail cl where cl.mediaimagetypecode = 'FCCLLOGO' and client_details.clienttoproductid = cl.clienttoproductid) > 0  
    then icxml.imagexml
    when (select count(*) from base.vwupdcfacilitydetail fa where fa.mediaimagetypecode = 'FCFLOGO' and client_details.clientproducttoentityid = fa.clientproducttoentityid) > 0 
    then ifxml.imagexml
    else icoxml.imagexml end as imagexml
from
    mid.facility fac
    left join cte_client_product_details client_details on client_details.facilityid = fac.facilityid 
    left join cte_description des on des.clienttoproductid = client_details.clienttoproductid
    left join cte_entity entity on entity.clienttoproductid = client_details.clienttoproductid
    left join cte_facility_detail_phone_xml pfxml on pfxml.clientproducttoentityid = client_details.clientproducttoentityid
    left join cte_client_detail_phone_xml pcxml on pcxml.clientproducttoentityid = client_details.clientproducttoentityid
    left join cte_facility_mobile_xml mfxml on mfxml.clientproducttoentityid = client_details.clientproducttoentityid
    left join cte_client_mobile_xml mcxml on mcxml.clientproducttoentityid = client_details.clientproducttoentityid
    left join cte_facility_desktop_xml dfxml on dfxml.clientproducttoentityid = client_details.clientproducttoentityid
    left join cte_client_desktop_xml dcxml on dcxml.clientproducttoentityid = client_details.clientproducttoentityid 
    left join cte_facility_tablet_xml tfxml on tfxml.clientproducttoentityid = client_details.clientproducttoentityid
    left join cte_client_tablet_xml tcxml on tcxml.clientproducttoentityid = client_details.clientproducttoentityid
    left join cte_url_xml as cte_url on cte_url.facilityid = fac.facilityid
    left join cte_client_image_xml icxml on icxml.clienttoproductid = client_details.clienttoproductid
    left join cte_facility_image_xml  ifxml on ifxml.clientproducttoentityid = client_details.clientproducttoentityid
    left join cte_combined_image_xml icoxml on icoxml.clienttoproductid = client_details.clienttoproductid
),
cte_fac_contract as (
select
    f.facilityid,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.phonexml end as phonexml,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.mobilephonexml end as mobilephonexml,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.desktopphonexml end as desktopphonexml,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.tabletphonexml end as tabletphonexml,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.urlxml end as urlxml,
    case when (cc.contractenddate <= getdate() or cc.contractstartdate >= getdate()) then null else f.imagexml end as imagexml
from cte_facility_xml as f
    left join base.client as c on c.clientcode = f.clientcode
    left join show.clientcontract as cc on cc.clientid = c.clientid
)
select
    facilityid,
    to_variant(phonexml) as phonexml,
    to_variant(mobilephonexml) as mobilephonexml,
    to_variant(desktopphonexml) as desktopphonexml,
    to_variant(tabletphonexml) as tabletphonexml,
    to_variant(urlxml) as urlxml,
    to_variant(imagexml) as imagexml
from cte_fac_contract $$;

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
                        target.facilityurl = source.facilityurl,
                        target.awardcount = source.awardcount,
                        target.procedurecount = source.procedurecount,
                        target.fivestarprocedurecount = source.fivestarprocedurecount,
                        target.providercount = source.providercount,
                        target.foreignobjectleftpercent = source.foreignobjectleftpercent';
                        
--- Update Xml
update_statement_xml := $$ update mid.facility as target
                                set target.phonexml = source.phonexml,
                                    target.mobilephonexml = source.mobilephonexml,
                                    target.desktopphonexml = source.desktopphonexml,
                                    target.tabletphonexml = source.tabletphonexml,
                                    target.urlxml = source.urlxml,
                                    target.imagexml = source.imagexml
                                from ( $$ || select_statement_xml || $$ ) as source 
                                    where target.facilityid = source.facilityid $$;
                        
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
                                facilityurl,
                                awardcount,
                                procedurecount,
                                fivestarprocedurecount,
                                providercount,
                                foreignobjectleftpercent)
                                
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
                                source.facilityurl,
                                source.awardcount,
                                source.procedurecount,
                                source.fivestarprocedurecount,
                                source.providercount,
                                source.foreignobjectleftpercent
                        )';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.facility as target using 
                   ('||select_statement||') as source 
                   on source.facilitycode = target.facilitycode
                   when matched  then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
        
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.Facility;
end if; 
execute immediate merge_statement;
execute immediate update_statement_xml;

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
