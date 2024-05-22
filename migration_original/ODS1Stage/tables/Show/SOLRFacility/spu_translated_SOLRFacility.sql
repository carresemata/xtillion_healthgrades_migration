CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRFACILITY() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

-- show.solrfacility depends on:
-- base.address
-- base.award
-- base.awardcategory
-- base.client
-- base.clientfeature
-- base.clientfeaturegroup
-- base.clientfeaturetoclientfeaturevalue
-- base.clientfeaturevalue
-- base.clientproducttoentity
-- base.clienttoproduct
-- base.clienttolanguage
-- base.citystatepostalcode
-- base.daysofweek
-- base.entitytype
-- base.facility
-- base.facilityhours
-- base.facilityimage
-- base.facilitytoaddress
-- base.facilitytocertification
-- base.facilitytolanguage
-- base.facilitytoservice
-- base.language
-- base.mediaimagetype
-- base.medicalterm
-- base.medicaltermtype
-- base.product
-- base.productgroup
-- base.providertofacility
-- base.service
-- base.state
--- Base.CallCenter (base.vwucallcenterdetails)
--- Base.CallCenterType (base.vwucallcenterdetails)
--- Base.ClientProductToCallCenter (base.vwucallcenterdetails)
--- Base.Email (base.vwucallcenterdetails)
--- Base.EmailType (base.vwucallcenterdetails)
--- Base.CallCenterToPhone (base.vwucallcenterdetails)
--- Base.Phone (base.vwucallcenterdetails)
--- Base.PhoneType (base.vwucallcenterdetails)
--- Base.ClientProductImage (base.vwupdcclientdetail)
--- Base.ClientProductEntityToURL (base.vwupdcclientdetail)
--- Base.URLType (base.vwupdcclientdetail)
--- Base.URL (base.vwupdcclientdetail)
--- Base.ClientProductEntityToPhone (base.vwupdcclientdetail)
-- mid.facility
-- show.clientcontract
-- ermart1.facility_awardtomedicalterm
-- ermart1.facility_facility
-- ermart1.facility_facilityaddressdetail
-- ermart1.facility_facilityparentchild
-- ermart1.facility_facilitytoprocedurerating
-- ermart1.facility_facilitytoprocessmeasures
-- ermart1.facility_facilitytorating
-- ermart1.facility_facilitytoservicelinerating
-- ermart1.facility_facilitytosurvey
-- ermart1.facility_facilitytoaward
-- ermart1.facility_facilitytomaternitydetail
-- ermart1.facility_procedure
-- ermart1.facility_procedureratingsnationalaverage
-- ermart1.facility_proceduretoaward
-- ermart1.facility_proceduretoserviceline
-- ermart1.facility_processmeasurescore
-- ermart1.facility_rating
-- ermart1.facility_serviceline
-- ermart1.patientexperience_opeaaveragesbycohortrange
-- ermart1.patientexperience_opeaprovidertocohortrange
-- ermart1.ref_processmeasure
-- hosp_directory.hosp_cohort (ermart1.facility_vwufacilityhgdisplayprocedures)


---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrfacility');
    execution_start datetime default getdate();
   

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement

begin
select_statement :=  $$ with cte_facility_address_detail as (
    select
        f.facilityid,
        case
            when a.suite is not null then concat(a.addressline1, ' ', a.suite)
            else a.addressline1
        end as address,
        null as addresssuite,
        cspc.city,
        cspc.state,
        cspc.postalcode as zipcode,
        a.latitude,
        a.longitude,
        a.timezone
    from
        base.facility f
        join base.facilitytoaddress fa on fa.facilityid = f.facilityid
        join base.address a on a.addressid = fa.addressid
        join base.citystatepostalcode cspc on cspc.citystatepostalcodeid = a.citystatepostalcodeid 
),
cte_parent_child as (
    select
        fpc.facilityidparent,
        fpc.facilityidchild,
        f.name as childfacilityname,
        case
            when fpc.ismaxyear = 1
            and f.isclosed = 0 then 1
            when fpc.ismaxyear = 0
            and f.isclosed = 0 then 0
        end as currentmerge
    from
        ermart1.facility_facilityparentchild fpc
        join ermart1.facility_facility f on fpc.facilityidchild = f.facilityid
),
cte_facility_hours as (
select 
    f.facilityid,
    dow.daysofweekdescription as day,
    dow.sortorder as disporder,
    fh.facilityhoursopeningtime as "start",
    fh.facilityhoursclosingtime as "end",
    fh.facilityisclosed as closed,
    fh.facilityisopen24hours as open24hrs
from 
    base.facility f
join 
    base.facilityhours fh on f.facilityid = fh.facilityid
join 
    base.daysofweek dow on fh.daysofweekid = dow.daysofweekid
),
cte_facility_hours_xml as (
select 
    facilityid,
    utils.p_json_to_xml(array_agg(
             '{ '||
IFF(day IS NOT NULL, '"day":' || '"' || day || '"' || ',', '') ||
IFF(disporder IS NOT NULL, '"disporder":' || '"' || disporder || '"' || ',', '') ||
IFF("start" IS NOT NULL, '"start":' || '"' || "start" || '"' || ',', '') ||
IFF("end" IS NOT NULL, '"end":' || '"' || "end" || '"' || ',', '') ||
IFF(closed IS NOT NULL, '"closed":' || '"' || closed || '"' || ',', '') ||
IFF(open24hrs IS NOT NULL, '"open24hrs":' || '"' || open24hrs || '"', '')
||' }'
        )::varchar, 'hoursL', 'hours') as facilityhoursxml
from cte_facility_hours 
group by facilityid
),
cte_address as (
select distinct 
    fad.facilityid,
    fad.address as ad1,
    fad.city as city,
    fad.state as st,
    fad.zipcode as zip,
    cast(fad.latitude as decimal(9, 6)) as lat,
    cast(fad.longitude as decimal(9, 6)) as lng,
    fad.timezone as tzn
from 
    cte_facility_address_detail fad
),
cte_address_xml as (
select 
    facilityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(ad1 IS NOT NULL, '"ad1":' || '"' || ad1 || '"' || ',', '') ||
IFF(city IS NOT NULL, '"city":' || '"' || city || '"' || ',', '') ||
IFF(st IS NOT NULL, '"st":' || '"' || st || '"' || ',', '') ||
IFF(zip IS NOT NULL, '"zip":' || '"' || zip || '"' || ',', '') ||
IFF(lat IS NOT NULL, '"lat":' || '"' || lat || '"' || ',', '') ||
IFF(lng IS NOT NULL, '"lng":' || '"' || lng || '"' || ',', '') ||
IFF(tzn IS NOT NULL, '"tzn":' || '"' || tzn || '"', '')
||' }'
        )::varchar, 'addrL', 'addr') as addressxml
from cte_address
group by facilityid
),

cte_related_spec as (
select distinct
    awardname,
    awardid,
    medicaltermcode as speccd,
    awardtomedicaltermorder as awtospecsort
from ermart1.facility_awardtomedicalterm
where medicaltermtypecode = 'Specialty'
),
cte_related_spec_xml as (
select 
    awardname,
    awardid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(speccd IS NOT NULL, '"speccd":' || '"' || speccd || '"' || ',', '') ||
IFF(awtospecsort IS NOT NULL, '"awtospecsort":' || '"' || awtospecsort || '"', '')
||' }')::varchar, 'relatedSpecL', 'relatedSpec') as relatedspecl
from cte_related_spec
group by 
    awardname,
    awardid
),
cte_facility_id_child as (
select 
    facilityid
from ermart1.facility_facilitytoaward
where 
    mergeddata = 1 and 
    left(facilityid, 4) = 'HGCH' and specialtycode = 'LAB' or
    left(facilityid, 4) != 'HGCH'
),

cte_child as (
select distinct
    pc.facilityidparent as facilityid,
    f.facilitycode as faccd,
    pc.childfacilityname as facnm
from cte_parent_child as pc
join base.facility as f on pc.facilityidchild = f.legacykey
where pc.facilityidparent in (select facilityid from cte_facility_id_child)
),
cte_child_xml as (
select 
    facilityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(faccd IS NOT NULL, '"faccd":' || '"' || faccd || '"' || ',', '') ||
IFF(facnm IS NOT NULL, '"facnm":' || '"' || facnm || '"', '')
||' }'
        )::varchar, 'childL', 'child') as childl
from cte_child
group by facilityid
),


cte_award as (
select distinct
    fta.facilityid,
    a.awardcode as awcd,
    ac.awardcategorycode as awtypcd,
    a.awarddisplayname as awnm,
    fta.year as awyr,
    fta.displaydatayear as dispawyr,
    fta.mergeddata as mrgd,
    fta.isbestind as isbest,
    fta.is50bestind as is50best,
    fta.isbestindnonsea as isbestnonsea,
    fta.ismaxyear as ismaxyr,
    fta.ranking as awrnk,
    case when fta.awardid = 11 then 1 else 0 end as isstrnk,
    rsxml.relatedspecl,
    cxml.childl
from ermart1.facility_facilitytoaward as fta -- x
    join base.award as a on a.awardname = fta.awardname -- y
    join base.awardcategory as ac on ac.awardcategoryid = a.awardcategoryid -- w
    left join ermart1.facility_serviceline as fsl on fsl.servicelineid = fta.specialtycode -- z
    join cte_related_spec_xml as rsxml on rsxml.awardid = fta.awardid and rsxml.awardname = fta.awardname
    join cte_child_xml as cxml on cxml.facilityid = fta.facilityid  
),

cte_award_xml as (
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
IFF(is50best IS NOT NULL, '"is50best":' || '"' || is50best || '"' || ',', '') ||
IFF(isbestnonsea IS NOT NULL, '"isbestnonsea":' || '"' || isbestnonsea || '"' || ',', '') ||
IFF(ismaxyr IS NOT NULL, '"ismaxyr":' || '"' || ismaxyr || '"' || ',', '') ||
IFF(awrnk IS NOT NULL, '"awrnk":' || '"' || awrnk || '"' || ',', '') ||
IFF(isstrnk IS NOT NULL, '"isstrnk":' || '"' || isstrnk || '"' || ',', '') ||
IFF(relatedspecl IS NOT NULL, '"":' || '"' || relatedspecl || '"' || ',', '') ||
IFF(childl IS NOT NULL, '"":' || '"' || childl || '"', '')
||' }'
        )::varchar, 'awardL', 'award') as awardxml
from cte_award
group by facilityid
),

cte_medical_serviceline as (
select 
    mt.medicaltermcode as servicelinecode,
    mt.legacykey,
    mt.medicaltermdescription1 as servicelinedescription
from 
    base.medicalterm mt
join 
    base.medicaltermtype mtt on mt.medicaltermtypeid = mtt.medicaltermtypeid
where 
    mtt.medicaltermtypecode = 'SERVICELINE'
),

cte_from_service_line as (
select distinct
    fpr.facilityid,
    fpr.procedureid,
    fpr.ratingsourceid,
    fpr.datayear as proceduredatayear,
    fpr.ismaxyear,
    msl.servicelinecode,
    msl.servicelinedescription,
    msl.legacykey,
    slr.zscore,
    case when fpr.procedureid = 'OB1' then fpr.overallsurvivalstar else slr.survivalstar end as survivalstar,
    case when fpr.procedureid = 'OB1' then fpr.datayear else slr.datayear end as datayear,
    case when fpr.procedureid = 'OB1' then fpr.displaydatayear else slr.displaydatayear end as displaydatayear,
    slr.ratingscorepercent 

from ermart1.facility_facilitytoprocedurerating as fpr -- zz
    join ermart1.facility_vwufacilityhgdisplayprocedures as vw on fpr.procedureid = vw.procedureid and fpr.ratingsourceid = vw.ratingsourceid -- yy
    join ermart1.facility_proceduretoserviceline as psl on psl.procedureid = vw.procedureid -- xx
    join ermart1.facility_serviceline as sl on sl.servicelineid = psl.servicelineid -- ww
    left join ermart1.facility_facilitytoservicelinerating as slr on slr.servicelineid = sl.servicelineid and fpr.facilityid = slr.facilityid and slr.ismaxyear = 1  --vv
    join cte_medical_serviceline as msl on msl.legacykey = 'SL'|| sl.servicelineid   -- qq

where 
    fpr.ismaxyear = 1
),

cte_medterm as (
select 
            mt.medicaltermcode as procedurecode,
            mt.legacykey,
            mt.medicaltermdescription1 as proceduredescription
        from 
            base.medicalterm mt
        join 
            base.medicaltermtype mtt on mt.medicaltermtypeid = mtt.medicaltermtypeid
        where 
            mtt.medicaltermtypecode = 'COHORT'
),

cte_state_avg as (
select distinct
    npra.datayear,
    psl.servicelineid,
    npra.procedureid,
    npra.ratingsource,
    fad.facilityid,
    s.state,
    s.statename as fullstate,
    averagelengthofstay as statelos,
    chargerange as statecost
from ermart1.facility_statenationalprocedureratingsaverage as npra -- z1
    join ermart1.facility_procedure as proc on proc.procedureid = npra.procedureid -- b1
    join ermart1.facility_proceduretoserviceline as psl on psl.procedureid = npra.procedureid -- y1
    join cte_medterm as mt on npra.procedureid = mt.legacykey -- zz1
    join base.state as s on s.state = npra.state -- c1
    join ermart1.facility_facilityaddressdetail as fad on fad.state = s.state -- d1
),

cte_state_avg_xml as (
select 
    datayear,
    servicelineid,
    procedureid,
    ratingsource,
    facilityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(state IS NOT NULL, '"state":' || '"' || state || '"' || ',', '') ||
IFF(fullstate IS NOT NULL, '"fullstate":' || '"' || fullstate || '"' || ',', '') ||
IFF(statelos IS NOT NULL, '"statelos":' || '"' || statelos || '"' || ',', '') ||
IFF(statecost IS NOT NULL, '"statecost":' || '"' || statecost || '"', '')
||' }'
        )::varchar, 'stateAvgL', 'stateAvg') as stateavg
from cte_state_avg
group by 
    datayear,
    servicelineid,
    procedureid,
    ratingsource,
    facilityid
),

cte_rate_trend as (
select distinct
    fpr.facilityid,
    psl.servicelineid,
    fpr.procedureid,
    fpr.ratingsourceid,
    fpr.datayear as ryr,
    fpr.displaydatayear as rdispyr,
    fpr.ismaxyear as ismaxyr,
    case 
        when proc.ratingmethod = 'M'
            then cast((fpr.actualsurvivalpercentage * 100) as varchar(10))
        when proc.ratingmethod = 'C'
            and fpr.procedureid <> 'OB1'
            then cast((fpr.actualsurvivalpercentage * 100) as varchar(10))
    end as actpct,
    case 
        when proc.ratingmethod = 'M'
            then cast((prna.actualsurvivalpercentagenatl * 100) as varchar(10))
        when proc.ratingmethod = 'C'
            then cast((prna.actualsurvivalpercentagenatl * 100) as varchar(10))
    end as actsurnatper
from 
    ermart1.facility_facilitytoprocedurerating fpr -- z1
join 
    ermart1.facility_procedure proc on fpr.procedureid = proc.procedureid -- b1
join 
    ermart1.facility_proceduretoserviceline psl on fpr.procedureid = psl.procedureid --y1
join 
    ermart1.facility_procedureratingsnationalaverage prna on
        fpr.procedureid = prna.procedureid
        and fpr.datayear = prna.datayear -- p1
join cte_medterm mt on prna.procedureid = mt.legacykey  -- zz1

),

cte_rate_trend_xml as (
select 
    facilityid,
    servicelineid,
    procedureid,
    ratingsourceid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(ryr IS NOT NULL, '"ryr":' || '"' || ryr || '"' || ',', '') ||
IFF(rdispyr IS NOT NULL, '"rdispyr":' || '"' || rdispyr || '"' || ',', '') ||
IFF(ismaxyr IS NOT NULL, '"ismaxyr":' || '"' || ismaxyr || '"', '')
||' }'
        )::varchar, 'rateTrendL', 'rateTrend') as ratetrend
from cte_rate_trend
group by 
    facilityid,
    servicelineid,
    procedureid,
    ratingsourceid
),

cte_related_award as (
select distinct
    fta.facilityid,
    pta.procedureid,
    aw.awardcode as awcd,
    awc.awardcategorycode as awtypcd,
    aw.awarddisplayname as awnm,
    fta.year as awyr,
    fta.displaydatayear as dispawyr,
    fta.mergeddata as mrgd,
    fta.isbestind as isbest,
    fta.ismaxyear as ismaxyr
from 
    ermart1.facility_facilitytoaward fta
join 
    base.award aw on fta.awardname = aw.awardname
join 
    base.awardcategory awc on awc.awardcategoryid = aw.awardcategoryid
join 
    ermart1.facility_proceduretoaward pta on pta.specialtycode = fta.specialtycode
),

cte_related_award_xml as (
select 
    facilityid,
    procedureid,
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
        )::varchar, 'relatedAwardL', 'relatedAward') as relatedaward
from cte_related_award
group by 
    facilityid,
    procedureid
),

cte_procl as (
select distinct
    fpr.facilityid,
    psl.servicelineid,
    fpr.ratingsourceid,
    mt.procedurecode as pcd,
    proc.proceduredescription as pnm,
    proc.ratingmethod as rmth,
    case when fpr.procedureid = 'OB1' then 1 end as mcare,
    fpr.datayear as ryr,
    fpr.displaydatayear as rdispyr,
    fpr.ismaxyear as ismaxyr,
    fpr.overallsurvivalstar as rstr,
    fpr.overallrecovery30star as rstr30,
    fpr.coststar as chgstr,
    case when fpr.coststar = 1 then 'Higher Than Average' when fpr.coststar = 3 then 'Average' when fpr.coststar = 5 then 'Lower Than Average' end as chgstrdisp,
    to_varchar(fpr.actualcostvalue) as cost,
    fpr.lengthofstaystar as losstr,
    case when fpr.lengthofstaystar = 1 then 'Longer Than Average' when fpr.lengthofstaystar = 3 then 'Average' when fpr.lengthofstaystar = 5 then 'Shorter Than Average' end as losstrdisp,
    to_varchar(round(fpr.actuallengthofstayvalue, 1)) as los,
    fpr.volume as vol,
    case 
        when proc.ratingmethod = 'M'
            then cast((fpr.actualsurvivalpercentage * 100) as varchar(10))
        when proc.ratingmethod = 'C'
            and fpr.procedureid <> 'OB1'
            then cast((fpr.actualsurvivalpercentage * 100) as varchar(10))
    end as actpct,
    case 
        when proc.ratingmethod = 'M'
            then cast((fpr.actualrecovery30percentage * 100) as varchar(10))
        when proc.ratingmethod = 'C'
            and fpr.procedureid <> 'OB1'
            then cast((fpr.actualrecovery30percentage * 100) as varchar(10))
    end as actpct30,
    case 
        when proc.ratingmethod = 'M'
            then cast((fpr.predictedsurvivalpercentage * 100) as varchar(10))
        when proc.ratingmethod = 'C'
            and fpr.procedureid <> 'OB1'
            then cast((fpr.predictedsurvivalpercentage * 100) as varchar(10))
    end as prdpct,
    case 
        when proc.ratingmethod = 'M'
            then cast((fpr.predictedrecovery30percentage * 100) as varchar(10))
        when proc.ratingmethod = 'C'
            and fpr.procedureid <> 'OB1'
            then cast((fpr.predictedrecovery30percentage * 100) as varchar(10))
    end as prdpct30,
    case 
        when fpr.procedureid = 'OB1' 
            then fmd.csectionactualpercentage end as csectactpct,
    case 
        when fpr.procedureid = 'OB1'  
            then fmd.csectionnatlpercentage end as csectnatpct,
    case 
        when fpr.procedureid = 'OB1'
            then fmd.csectionvolume end as csectvol,
    case 
        when fpr.procedureid = 'OB1'
            then fmd.vaginalactualpercentage end as vagactpct,
    case 
        when fpr.procedureid = 'OB1'
            then fmd.vaginalnatlpercentage end as vagnatpct,
    case 
        when fpr.procedureid = 'OB1'
            then fmd.vaginalvolume end as vagvol,
    case 
        when fpr.procedureid = 'OB1'
            then fmd.newbornsurvivalstar end as nwbrnstr,
    case 
        when fpr.procedureid = 'OB1'
            then fmd.newbornsurvivalstardescription end as nwbrnstrdesc,
    cast(fpr.weightscore as decimal(18,15)) as zscr,
    case 
        when proc.procedureid = 'OB1'
            then cast((cast(fpr.overallsurvivalstar as float) - cast(fpr.weightscore as float)) as varchar(50))
        when proc.ratingmethod = 'M'
            then cast((cast(fpr.weightstar as float) + cast(fpr.weightscore as float)) as varchar(50))
        when proc.ratingmethod = 'C'
            then cast((cast(fpr.overallsurvivalstar as float) + cast(fpr.weightscore as float)) as varchar(50))
    end as psort,
    case 
        when proc.ratingmethod = 'M'
            then cast((prna.actualsurvivalpercentagenatl * 100) as varchar(10))
        when proc.ratingmethod = 'C'
            then cast((prna.actualsurvivalpercentagenatl * 100) as varchar(10))
    end as actsurnatper,
    case 
        when proc.ratingmethod = 'M'
            then cast((prna.predictedsurvivalpercentagenatl * 100) as varchar(10))
        when proc.ratingmethod = 'C'
            then cast((prna.predictedsurvivalpercentagenatl * 100) as varchar(10))
    end as predsurnatper,
    prna.overallsurvivalstarnatl as ovrallsurnatstr,
    prna.survival30starnatl as surnatstr30,
    prna.avgcasesnatl,
    prna.averagelengthofstay as losnatl,
    prna.chargerange as costnatl,
    saxml.stateavg,
    rtxml.ratetrend,
    raxml.relatedaward,
    fpr.weightstar as wstr,
    fpr.ratingscorepercent as qualpctscr
    
from ermart1.facility_facilitytoprocedurerating as fpr -- z
    join ermart1.facility_procedure as proc on proc.procedureid = fpr.procedureid -- b
    join ermart1.facility_proceduretoserviceline as psl on psl.procedureid = fpr.procedureid -- y
    join ermart1.facility_procedureratingsnationalaverage as prna on prna.procedureid = fpr.procedureid and prna.datayear = fpr.datayear --p
    join cte_medterm as mt on prna.procedureid = mt.legacykey -- zz
    join ermart1.facility_facilitytomaternitydetail as fmd on fmd.facilityid = fpr.facilityid and fmd.datayear = fpr.datayear
    join cte_state_avg_xml as saxml on saxml.datayear = fpr.datayear and saxml.servicelineid = psl.servicelineid and saxml.procedureid = fpr.procedureid and saxml.ratingsource = fpr.ratingsourceid and saxml.facilityid = fpr.facilityid
    join cte_rate_trend_xml as rtxml on rtxml.facilityid = fpr.facilityid and rtxml.servicelineid = psl.servicelineid and rtxml.procedureid = fpr.procedureid and rtxml.ratingsourceid = fpr.ratingsourceid
    join cte_related_award_xml as raxml on raxml.facilityid = fpr.facilityid and raxml.procedureid = psl.procedureid
),

cte_procl_xml as (
select 
    facilityid,
    servicelineid,
    ratingsourceid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(pcd IS NOT NULL, '"pcd":' || '"' || pcd || '"' || ',', '') ||
IFF(pnm IS NOT NULL, '"pnm":' || '"' || pnm || '"' || ',', '') ||
IFF(rmth IS NOT NULL, '"rmth":' || '"' || rmth || '"' || ',', '') ||
IFF(mcare IS NOT NULL, '"mcare":' || '"' || mcare || '"' || ',', '') ||
IFF(ryr IS NOT NULL, '"ryr":' || '"' || ryr || '"' || ',', '') ||
IFF(rdispyr IS NOT NULL, '"rdispyr":' || '"' || rdispyr || '"' || ',', '') ||
IFF(ismaxyr IS NOT NULL, '"ismaxyr":' || '"' || ismaxyr || '"' || ',', '') ||
IFF(rstr IS NOT NULL, '"rstr":' || '"' || rstr || '"' || ',', '') ||
IFF(rstr30 IS NOT NULL, '"rstr30":' || '"' || rstr30 || '"' || ',', '') ||
IFF(chgstr IS NOT NULL, '"chgstr":' || '"' || chgstr || '"' || ',', '') ||
IFF(chgstrdisp IS NOT NULL, '"chgstrdisp":' || '"' || chgstrdisp || '"' || ',', '') ||
IFF(cost IS NOT NULL, '"cost":' || '"' || cost || '"' || ',', '') ||
IFF(losstr IS NOT NULL, '"losstr":' || '"' || losstr || '"' || ',', '') ||
IFF(losstrdisp IS NOT NULL, '"losstrdisp":' || '"' || losstrdisp || '"' || ',', '') ||
IFF(los IS NOT NULL, '"los":' || '"' || los || '"' || ',', '') ||
IFF(vol IS NOT NULL, '"vol":' || '"' || vol || '"' || ',', '') ||
IFF(actpct IS NOT NULL, '"actpct":' || '"' || actpct || '"' || ',', '') ||
IFF(actpct30 IS NOT NULL, '"actpct30":' || '"' || actpct30 || '"' || ',', '') ||
IFF(prdpct IS NOT NULL, '"prdpct":' || '"' || prdpct || '"' || ',', '') ||
IFF(prdpct30 IS NOT NULL, '"prdpct30":' || '"' || prdpct30 || '"' || ',', '') ||
IFF(csectactpct IS NOT NULL, '"csectactpct":' || '"' || csectactpct || '"' || ',', '') ||
IFF(csectnatpct IS NOT NULL, '"csectnatpct":' || '"' || csectnatpct || '"' || ',', '') ||
IFF(csectvol IS NOT NULL, '"csectvol":' || '"' || csectvol || '"' || ',', '') ||
IFF(vagactpct IS NOT NULL, '"vagactpct":' || '"' || vagactpct || '"' || ',', '') ||
IFF(vagnatpct IS NOT NULL, '"vagnatpct":' || '"' || vagnatpct || '"' || ',', '') ||
IFF(vagvol IS NOT NULL, '"vagvol":' || '"' || vagvol || '"' || ',', '') ||
IFF(nwbrnstr IS NOT NULL, '"nwbrnstr":' || '"' || nwbrnstr || '"' || ',', '') ||
IFF(nwbrnstrdesc IS NOT NULL, '"nwbrnstrdesc":' || '"' || nwbrnstrdesc || '"' || ',', '') ||
IFF(zscr IS NOT NULL, '"zscr":' || '"' || zscr || '"' || ',', '') ||
IFF(psort IS NOT NULL, '"psort":' || '"' || psort || '"' || ',', '') ||
IFF(actsurnatper IS NOT NULL, '"actsurnatper":' || '"' || actsurnatper || '"' || ',', '') ||
IFF(predsurnatper IS NOT NULL, '"predsurnatper":' || '"' || predsurnatper || '"' || ',', '') ||
IFF(ovrallsurnatstr IS NOT NULL, '"ovrallsurnatstr":' || '"' || ovrallsurnatstr || '"' || ',', '') ||
IFF(surnatstr30 IS NOT NULL, '"surnatstr30":' || '"' || surnatstr30 || '"' || ',', '') ||
IFF(avgcasesnatl IS NOT NULL, '"avgcasesnatl":' || '"' || avgcasesnatl || '"' || ',', '') ||
IFF(losnatl IS NOT NULL, '"losnatl":' || '"' || losnatl || '"' || ',', '') ||
IFF(costnatl IS NOT NULL, '"costnatl":' || '"' || costnatl || '"' || ',', '') ||
IFF(stateavg IS NOT NULL, '"":' || '"' || stateavg || '"' || ',', '') ||
IFF(ratetrend IS NOT NULL, '"":' || '"' || ratetrend || '"' || ',', '') ||
IFF(relatedaward IS NOT NULL, '"":' || '"' || relatedaward || '"' || ',', '') ||
IFF(wstr IS NOT NULL, '"wstr":' || '"' || wstr || '"' || ',', '') ||
IFF(qualpctscr IS NOT NULL, '"qualpctscr":' || '"' || qualpctscr || '"', '')
||' }'
        )::varchar, 'procL', 'proc') as procxml
from cte_procl
group by 
    facilityid,
    servicelineid,
    ratingsourceid

),

cte_rating_sort_value as (
select
    fpr.facilityid,
    fpr.ismaxyear,
    psl.servicelineid,
    fpr.ratingsourceid,
    avg(
        (fpr.overallsurvivalstar * fpr.overallrecovery30star) + 
        (0.5 * fpr.overallsurvivalstar) + 
        (fpr.overallrecovery30star)
    ) + 
    (count(fpr.overallsurvivalstar) + count(fpr.overallrecovery30star)) * 0.25 as ratingsortvalue
from 
    ermart1.facility_facilitytoprocedurerating fpr
join 
    ermart1.facility_procedure proc on fpr.procedureid = proc.procedureid
join 
    ermart1.facility_proceduretoserviceline psl on fpr.procedureid = psl.procedureid
join cte_medterm medterm on psl.procedureid = medterm.legacykey
group by
    facilityid,
    ismaxyear,
    servicelineid,
    ratingsourceid
),

    
cte_service_line as (
select
    sl.facilityid,
    sl.servicelinecode as svccd,
    sl.zscore as svczscore,
    sl.servicelinedescription as svcnm,
    sl.survivalstar as svclnrtg,
    sl.datayear as scyr,
    sl.displaydatayear as svcdispyr,
    sl.ismaxyear as ismaxyr,
    sl.ratingscorepercent as qualpctscr,
    procl.procxml,
    rsv.ratingsortvalue
from cte_from_service_line as sl-- qq
join cte_procl_xml as procl on procl.facilityid = sl.facilityid
    and 'sl' || procl.servicelineid = sl.legacykey
    and procl.ratingsourceid = sl.ratingsourceid
join cte_rating_sort_value as rsv on  rsv.facilityid = sl.facilityid
    and rsv.ismaxyear = sl.ismaxyear
    and 'sl' || rsv.servicelineid = sl.legacykey
    and rsv.ratingsourceid = sl.ratingsourceid
),

cte_service_line_xml as (
select 
    facilityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(svccd IS NOT NULL, '"svccd":' || '"' || svccd || '"' || ',', '') ||
IFF(svczscore IS NOT NULL, '"svczscore":' || '"' || svczscore || '"' || ',', '') ||
IFF(svcnm IS NOT NULL, '"svcnm":' || '"' || svcnm || '"' || ',', '') ||
IFF(svclnrtg IS NOT NULL, '"svclnrtg":' || '"' || svclnrtg || '"' || ',', '') ||
IFF(scyr IS NOT NULL, '"scyr":' || '"' || scyr || '"' || ',', '') ||
IFF(svcdispyr IS NOT NULL, '"svcdispyr":' || '"' || svcdispyr || '"' || ',', '') ||
IFF(ismaxyr IS NOT NULL, '"ismaxyr":' || '"' || ismaxyr || '"' || ',', '') ||
IFF(qualpctscr IS NOT NULL, '"qualpctscr":' || '"' || qualpctscr || '"' || ',', '') ||
IFF(procxml IS NOT NULL, '"":' || '"' || procxml || '"' || ',', '') ||
IFF(ratingsortvalue IS NOT NULL, '"ratingsortvalue":' || '"' || ratingsortvalue || '"', '')
||' }'
        )::varchar, 'svcLnL', 'svcLn') as servicelinexml
from cte_service_line
group by 
    facilityid
),

cte_patient_satisfaction as (
select 
    fs.facilityid,
    fs.questionid as queid,
    fs.questiontextdisplay as quetxt,
    fs.numberofcompletedsurveys as noofsurv,
    fs.surveyresponseratepercent as surresrateperc,
    fs.answerid as ansid,
    fs.answertextdisplay as anstxt,
    fs.answerpercent as ansperc,
    fs.category as cat,
    fs.categorysortid as catsort,
    to_decimal(oa.average) as natavg
from 
    ermart1.facility_facilitytosurvey fs
left join 
    ermart1.patientexperience_opeaprovidertocohortrange op 
on 
    fs.facilityid = op.hgid 
left join 
    ermart1.patientexperience_opeaaveragesbycohortrange oa
on 
    fs.questionid = oa.questionid 
    and op.cohortrange = oa.cohortrange
where 
    fs.surveyid = 1
),

cte_patient_satisfaction_xml as (
select 
    facilityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(queid IS NOT NULL, '"queid":' || '"' || queid || '"' || ',', '') ||
IFF(quetxt IS NOT NULL, '"quetxt":' || '"' || quetxt || '"' || ',', '') ||
IFF(noofsurv IS NOT NULL, '"noofsurv":' || '"' || noofsurv || '"' || ',', '') ||
IFF(surresrateperc IS NOT NULL, '"surresrateperc":' || '"' || surresrateperc || '"' || ',', '') ||
IFF(ansid IS NOT NULL, '"ansid":' || '"' || ansid || '"' || ',', '') ||
IFF(anstxt IS NOT NULL, '"anstxt":' || '"' || anstxt || '"' || ',', '') ||
IFF(ansperc IS NOT NULL, '"ansperc":' || '"' || ansperc || '"' || ',', '') ||
IFF(cat IS NOT NULL, '"cat":' || '"' || cat || '"' || ',', '') ||
IFF(catsort IS NOT NULL, '"catsort":' || '"' || catsort || '"' || ',', '') ||
IFF(natavg IS NOT NULL, '"natavg":' || '"' || natavg || '"', '')
||' }'
        )::varchar, 'satisL', 'satis') as patientsatisfactionxml
from cte_patient_satisfaction
group by 
    facilityid
),

cte_distinction as (
select 
       facilityid, 
       certificationdisplayname as certnm,
       certificationsourcedisplayname as certsrcnm,
       certificationsourcelongname as certsrclgnm,
       certificationstartdate as certstdt,
       certificationenddate as certenddt
from ermart1.facility_facilitytocertification
),
cte_distinction_xml as (
select 
    facilityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(certnm IS NOT NULL, '"certnm":' || '"' || certnm || '"' || ',', '') ||
IFF(certsrcnm IS NOT NULL, '"certsrcnm":' || '"' || certsrcnm || '"' || ',', '') ||
IFF(certsrclgnm IS NOT NULL, '"certsrclgnm":' || '"' || certsrclgnm || '"' || ',', '') ||
IFF(certstdt IS NOT NULL, '"certstdt":' || '"' || certstdt || '"' || ',', '') ||
IFF(certenddt IS NOT NULL, '"certenddt":' || '"' || certenddt || '"', '')
||' }'
        )::varchar, 'distL', 'dist') as distinctionxml
from cte_distinction
group by 
    facilityid
),

cte_readmission_rate as (
    select distinct
        fpm.facilityid,
        pm.conditioncode as condc,
        pm.conditiondisplayname as condnm,
        pm.measurecode as measc,
        pm.measuredisplayname as measnm,
        fpm.scorepercent as scperc,
        fpm.samplevolume as sampvol,
        fpm.comparisonnationalrate as comprnat,
        pms.scorepercent as natscperc,
        pm.conditioncodedisplayorder as condsort,
        pm.measurecodedisplayorder as meassort
    from ermart1.ref_processmeasure pm
    join ermart1.facility_facilitytoprocessmeasures fpm on fpm.conditioncode = pm.conditioncode
        and fpm.measurecode = pm.measurecode
    left join ermart1.facility_processmeasurescore pms on pm.conditioncode = pms.conditioncode
        and pm.measurecode = pms.measurecode
        and pms.state = 'US'
    where pm.conditioncode in ('AMI', 'CHF', 'PNE')
        and pm.measuredisplayname = '30-Day Readmission Rate'
        and pm.iscurrent = 1
        and pm.isdisplayed = 1

),

cte_readmission_rate_xml as (
select 
    facilityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(condc IS NOT NULL, '"condc":' || '"' || condc || '"' || ',', '') ||
IFF(condnm IS NOT NULL, '"condnm":' || '"' || condnm || '"' || ',', '') ||
IFF(measc IS NOT NULL, '"measc":' || '"' || measc || '"' || ',', '') ||
IFF(measnm IS NOT NULL, '"measnm":' || '"' || measnm || '"' || ',', '') ||
IFF(scperc IS NOT NULL, '"scperc":' || '"' || scperc || '"' || ',', '') ||
IFF(sampvol IS NOT NULL, '"sampvol":' || '"' || sampvol || '"' || ',', '') ||
IFF(comprnat IS NOT NULL, '"comprnat":' || '"' || comprnat || '"' || ',', '') ||
IFF(natscperc IS NOT NULL, '"natscperc":' || '"' || natscperc || '"' || ',', '') ||
IFF(condsort IS NOT NULL, '"condsort":' || '"' || condsort || '"' || ',', '') ||
IFF(meassort IS NOT NULL, '"meassort":' || '"' || meassort || '"', '')
||' }'
        )::varchar, 'reAdminL', 'reAdmin') as readmissionratexml
from cte_readmission_rate
group by 
    facilityid
),

cte_effective_care as (
select distinct
        fpm.facilityid,
        pm.conditioncode as condc,
        pm.conditiondisplayname as condnm,
        pm.measurecode as measc,
        pm.measuredisplayname as measnm,
        fpm.scorepercent as scperc,
        fpm.samplevolume as sampvol,
        fad.state,
        st.statename as fullstate,
        pms_state.scorepercent as statescperc,
        pms_nat.scorepercent as natscperc,
        pm.conditioncodedisplayorder as condsort,
        pm.measurecodedisplayorder as meassort
    from ermart1.ref_processmeasure pm
    join ermart1.facility_facilitytoprocessmeasures fpm on fpm.conditioncode = pm.conditioncode
        and fpm.measurecode = pm.measurecode
    left join ermart1.facility_facilityaddressdetail fad on fad.facilityid = fpm.facilityid
    left join ermart1.facility_processmeasurescore pms_state on pm.conditioncode = pms_state.conditioncode
        and pm.measurecode = pms_state.measurecode
        and pms_state.state = fad.state
    left join base.state st on st.state = fad.state
    left join ermart1.facility_processmeasurescore pms_nat on pm.conditioncode = pms_nat.conditioncode
        and pm.measurecode = pms_nat.measurecode
        and pms_nat.state = 'US'
    where pm.conditioncode in ('AMI', 'PNE', 'SIP', 'CAS', 'CHF', 'IMM')
        and pm.measuredisplayname <> '30-Day Readmission Rate'
        and pm.iscurrent = 1
        and pm.isdisplayed = 1
),

cte_effective_care_xml as (
select 
    facilityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(condc IS NOT NULL, '"condc":' || '"' || condc || '"' || ',', '') ||
IFF(condnm IS NOT NULL, '"condnm":' || '"' || condnm || '"' || ',', '') ||
IFF(measc IS NOT NULL, '"measc":' || '"' || measc || '"' || ',', '') ||
IFF(measnm IS NOT NULL, '"measnm":' || '"' || measnm || '"' || ',', '') ||
IFF(scperc IS NOT NULL, '"scperc":' || '"' || scperc || '"' || ',', '') ||
IFF(sampvol IS NOT NULL, '"sampvol":' || '"' || sampvol || '"' || ',', '') ||
IFF(state IS NOT NULL, '"state":' || '"' || state || '"' || ',', '') ||
IFF(fullstate IS NOT NULL, '"fullstate":' || '"' || fullstate || '"' || ',', '') ||
IFF(statescperc IS NOT NULL, '"statescperc":' || '"' || statescperc || '"' || ',', '') ||
IFF(natscperc IS NOT NULL, '"natscperc":' || '"' || natscperc || '"' || ',', '') ||
IFF(condsort IS NOT NULL, '"condsort":' || '"' || condsort || '"' || ',', '') ||
IFF(meassort IS NOT NULL, '"meassort":' || '"' || meassort || '"', '')
||' }'
        )::varchar, 'effCareL', 'effCare') as timelyandeffectivecarexml
from cte_effective_care
group by 
    facilityid
),

cte_patient_safety as (
select 
    fr.facilityid, 
    r.displayratingdescription as ratedesc,
    fr.ratingstar as ratestr,
    eventcount as evtcount
from 
    ermart1.facility_facilitytorating fr
join 
    ermart1.facility_rating r on fr.ratingid = r.ratingid
where 
    r.ratingcategoryid = 2
    and fr.ismaxyear = 1
    and r.ratingid <> 2
),
cte_patient_safety_xml as (
select 
    facilityid,
    utils.p_json_to_xml(array_agg(
'{ '||
IFF(ratedesc IS NOT NULL, '"ratedesc":' || '"' || ratedesc || '"' || ',', '') ||
IFF(ratestr IS NOT NULL, '"ratestr":' || '"' || ratestr || '"' || ',', '') ||
IFF(evtcount IS NOT NULL, '"evtcount":' || '"' || evtcount || '"', '')
||' }'
        )::varchar, 'pSafeL', 'pSafe') as patientsafetyxml
from cte_patient_safety
group by 
    facilityid
),

cte_trauma_level as (
    select 
        facilitycode, 
        adulttraumalevel as adutralev,
        pediatrictraumalevel as pedtralev
    from 
        mid.facility
    where 
        adulttraumalevel is not null or
        pediatrictraumalevel is not null
),
cte_trauma_level_xml as (
    select 
        facilitycode,
        utils.p_json_to_xml(array_agg(
            '{ '||
            IFF(adutralev IS NOT NULL, '"adutralev":' || '"' || adutralev || '"' || ',', '') ||
            IFF(pedtralev IS NOT NULL, '"pedtralev":' || '"' || pedtralev || '"', '')
            ||' }'
            )::varchar, 'traumaL', 'trauma') as traumalevelxml
    from cte_trauma_level
    group by 
        facilitycode
),

cte_affiliation as (
    select 
        fpc.facilityidchild as facilityid,
        fparent.name as nm
    from 
        ermart1.facility_facilityparentchild fpc
    join 
        ermart1.facility_facility fchild on fpc.facilityidchild = fchild.facilityid
    join 
        ermart1.facility_facility fparent on fpc.facilityidparent = fparent.facilityid
    where 
        fpc.ismaxyear = 1
        and fchild.isclosed = 0
        and fparent.isclosed = 0

    union all

    select 
        fpc.facilityidparent as facilityid,
        fchild.name as nm
    from 
        ermart1.facility_facilityparentchild fpc
    join 
        ermart1.facility_facility fparent on fpc.facilityidparent = fparent.facilityid
    join 
        ermart1.facility_facility fchild on fpc.facilityidchild = fchild.facilityid
    where 
        fpc.ismaxyear = 1
        and fparent.isclosed = 0
),
cte_affiliation_xml as (
    select 
        facilityid,
        utils.p_json_to_xml(array_agg(
            '{ '||
            IFF(nm IS NOT NULL, '"nm":' || '"' || nm || '"', '')
            ||' }'
            )::varchar, 'affilL', 'affil') as affiliationxml
    from cte_affiliation
    group by 
        facilityid
),

cte_pdc_facilities as (
    select distinct 
        f.legacykey as facilityid
    from 
        base.clienttoproduct ctp
    join 
        base.client cl on ctp.clientid = cl.clientid
    join 
        base.product p on ctp.productid = p.productid
    join 
        base.productgroup pg on p.productgroupid = pg.productgroupid
    join 
        base.clientproducttoentity cpte on ctp.clienttoproductid = cpte.clienttoproductid
    join 
        base.entitytype et on cpte.entitytypeid = et.entitytypeid
        and et.entitytypecode = 'FAC'
    join 
        base.facility f on cpte.entityid = f.facilityid
    where 
        ctp.activeflag = 1
        and pg.productgroupcode = 'PDC'
        and f.isclosed = 0
),
cte_leadership as (
    select 
        flet.facilityid,
        flet.execteamname as leadnm,
        flet.title,
        flet.bio,
        flet.execteamimage as img,
        flet.execemail as email
    from 
        ermart1.facility_facilitytoexeclevelteam flet
    join 
        cte_pdc_facilities pf on flet.facilityid = pf.facilityid
),
cte_leadership_xml as (
    select 
        facilityid,
        utils.p_json_to_xml(array_agg(
            '{ '||
            IFF(leadnm IS NOT NULL, '"leadnm":' || '"' || leadnm || '"' || ',', '') ||
            IFF(title IS NOT NULL, '"title":' || '"' || title || '"' || ',', '') ||
            IFF(bio IS NOT NULL, '"bio":' || '"' || bio || '"' || ',', '') ||
            IFF(img IS NOT NULL, '"img":' || '"' || img || '"' || ',', '') ||
            IFF(email IS NOT NULL, '"email":' || '"' || email || '"', '')
            ||' }'
            )::varchar, 'leaderL', 'leader') as leadershipxml
    from cte_leadership
    group by 
        facilityid
),

cte_pdc_facilities_award as (
    select distinct 
        f.legacykey as facilityid
    from 
        base.clienttoproduct ctp
    join 
        base.client c on ctp.clientid = c.clientid
    join 
        base.product p on ctp.productid = p.productid
    join 
        base.productgroup pg on p.productgroupid = pg.productgroupid
    join 
        base.clientproducttoentity cpte on ctp.clienttoproductid = cpte.clienttoproductid
    join 
        base.entitytype et on cpte.entitytypeid = et.entitytypeid
        and et.entitytypecode = 'fac'
    join 
        base.facility f on cpte.entityid = f.facilityid
    where 
        ctp.activeflag = 1
        and pg.productgroupcode = 'pdc'
        and f.isclosed = 0
),
cte_award_achievement as (
    select 
        fam.facilityid,
        fam.awardname as awnm,
        fam.standardmessage as standmsg,
        fam.displaylabel as dispyr,
        fam.priorityrank as pri,
        fam.imagename as imgpath
    from 
        ermart1.facility_facilityawardmessage fam
    join 
        cte_pdc_facilities_award pfa on fam.facilityid = pfa.facilityid
),
cte_award_achievement_xml as (
    select 
        facilityid,
        utils.p_json_to_xml(array_agg(
            '{ '||
            IFF(awnm IS NOT NULL, '"awnm":' || '"' || awnm || '"' || ',', '') ||
            IFF(standmsg IS NOT NULL, '"standmsg":' || '"' || standmsg || '"' || ',', '') ||
            IFF(dispyr IS NOT NULL, '"dispyr":' || '"' || dispyr || '"' || ',', '') ||
            IFF(pri IS NOT NULL, '"pri":' || '"' || pri || '"' || ',', '') ||
            IFF(imgpath IS NOT NULL, '"imgpath":' || '"' || imgpath || '"', '')
            ||' }'
            )::varchar, 'awardMsgL', 'awardMsg') as awardachievementxml
    from cte_award_achievement
    group by 
        facilityid
),
cte_survey as (
    select 
        facilityid, 
        answerpercent as patientsatisfaction
    from 
        ermart1.facility_facilitytosurvey
    where 
        surveyid = 1
        and questionid = 10
),

cte_facility_language as (
    select 
        fl.facilityid, 
        l.languagename as langnm,
        l.languagecode as langcd
    from 
        base.facilitytolanguage fl
    inner join 
        base.language l on fl.languageid = l.languageid
),
cte_language_xml as (
    select 
        facilityid,
        utils.p_json_to_xml(array_agg(
            '{ '||
            IFF(langnm IS NOT NULL, '"langnm":' || '"' || langnm || '"' || ',', '') ||
            IFF(langcd IS NOT NULL, '"langcd":' || '"' || langcd || '"', '')
            ||' }'
            )::varchar, 'langL', 'lang') as languagexml
    from cte_facility_language
    group by 
        facilityid
),

cte_facility_service as (
    select 
        fs.facilityid, 
        s.servicename as servnm,
        s.servicecode as servcd
    from 
        base.facilitytoservice fs
    inner join 
        base.service s on fs.serviceid = s.serviceid
),
cte_service_xml as (
    select 
        facilityid,
        utils.p_json_to_xml(array_agg(
            '{ '||
            IFF(servnm IS NOT NULL, '"servnm":' || '"' || servnm || '"' || ',', '') ||
            IFF(servcd IS NOT NULL, '"servcd":' || '"' || servcd || '"', '')
            ||' }'
            )::varchar, 'servL', 'serv') as servicexml
    from cte_facility_service
    group by 
        facilityid
),

-- sponsorshipxml

cte_spnfeat as (
    select distinct
        a.entityid as clienttoproductid,
        cf.clientfeaturecode as featcd,
        cf.clientfeaturedescription as featdesc,
        cfv.clientfeaturevaluecode as featvalcd,
        cfv.clientfeaturevaluedescription as featvaldesc
    from 
        base.cliententitytoclientfeature a
    join 
        base.entitytype et on a.entitytypeid = et.entitytypeid
    join 
        base.clientfeaturetoclientfeaturevalue ccf on a.clientfeaturetoclientfeaturevalueid = ccf.clientfeaturetoclientfeaturevalueid
    join 
        base.clientfeature cf on ccf.clientfeatureid = cf.clientfeatureid
    join 
        base.clientfeaturevalue cfv on ccf.clientfeaturevalueid = cfv.clientfeaturevalueid
    join 
        base.clientfeaturegroup cfg on cf.clientfeaturegroupid = cfg.clientfeaturegroupid
    where 
        et.entitytypecode = 'CLPROD'
),

cte_spnfeat_xml as (
    select 
        clienttoproductid,
        utils.p_json_to_xml(array_agg(
            '{ '||
            IFF(featcd IS NOT NULL, '"featCd":' || '"' || featcd || '"' || ',', '') ||
            IFF(featdesc IS NOT NULL, '"featDesc":' || '"' || featdesc || '"' || ',', '') ||
            IFF(featvalcd IS NOT NULL, '"featValCd":' || '"' || featvalcd || '"' || ',', '') ||
            IFF(featvaldesc IS NOT NULL, '"featValDesc":' || '"' || featvaldesc || '"', '')
            ||' }'
            )::varchar, '', 'spnFeat') as spnfeatl
    from cte_spnfeat
    group by clienttoproductid
),

cte_spn as (
select distinct
    f.facilitycode,
    f.clientcode as spncd,
    f.clientname as spnnm,
    spn.spnfeatl
from mid.facility as f
join cte_spnfeat_xml as spn on spn.clienttoproductid = f.clienttoproductid
where f.clientcode is not null
),

cte_spn_xml as (
 select 
        facilitycode,
        utils.p_json_to_xml(array_agg(
'{ '||
IFF(spncd IS NOT NULL, '"spncd":' || '"' || spncd || '"' || ',', '') ||
IFF(spnnm IS NOT NULL, '"spnnm":' || '"' || spnnm || '"' || ',', '') ||
IFF(spnfeatl IS NOT NULL, '"spnfeatl":' || '"' || spnfeatl || '"', '')
||' }'
            )::varchar, '', 'spn') as spn
    from cte_spn
    group by facilitycode
),

cte_clctr_featl as (
    select 
        cecf.entityid as callcenterid,
        cf.clientfeaturecode as featcd,
        cf.clientfeaturedescription as featdesc,
        cfv.clientfeaturevaluecode as featvalcd,
        cfv.clientfeaturevaluedescription as featvaldesc
    from 
        base.cliententitytoclientfeature cecf
    join 
        base.entitytype et on cecf.entitytypeid = et.entitytypeid
    join 
        base.clientfeaturetoclientfeaturevalue cfcfv on cecf.clientfeaturetoclientfeaturevalueid = cfcfv.clientfeaturetoclientfeaturevalueid
    join 
        base.clientfeature cf on cfcfv.clientfeatureid = cf.clientfeatureid
    join 
        base.clientfeaturevalue cfv on cfcfv.clientfeaturevalueid = cfv.clientfeaturevalueid
    join 
        base.clientfeaturegroup cfg on cf.clientfeaturegroupid = cfg.clientfeaturegroupid
    where 
        cfg.clientfeaturegroupcode = 'FGOAR'
        and et.entitytypecode = 'CLCTR'
),

cte_clctr_featl_xml as (
    select 
        callcenterid,
        utils.p_json_to_xml(array_agg(
            '{ '||
            IFF(featcd IS NOT NULL, '"featCd":' || '"' || featcd || '"' || ',', '') ||
            IFF(featdesc IS NOT NULL, '"featDesc":' || '"' || featdesc || '"' || ',', '') ||
            IFF(featvalcd IS NOT NULL, '"featValCd":' || '"' || featvalcd || '"' || ',', '') ||
            IFF(featvaldesc IS NOT NULL, '"featValDesc":' || '"' || featvaldesc || '"', '')
            ||' }'
            )::varchar, '', 'clCtrFeat') as clctrfeatl
    from cte_clctr_featl
    group by callcenterid
),

cte_clctr as (
    select distinct
        ccd.clienttoproductid,
        ccd.callcentercode as clctrcd,
        ccd.callcentername as clctrnm,
        ccd.replydays as aptcoffday,
        ccd.apptcutofftime as aptcoffhr,
        ccd.emailaddress as eml,
        ccd.faxnumber as fxno,
        clctr.clctrfeatl
    from 
        base.vwucallcenterdetails ccd
    join 
        cte_clctr_featl_xml clctr on clctr.callcenterid = ccd.callcenterid
),

cte_clctr_xml as (
    select 
        clienttoproductid,
        utils.p_json_to_xml(array_agg(
            '{ '||
            IFF(clctrcd IS NOT NULL, '"clCtrCd":' || '"' || clctrcd || '"' || ',', '') ||
            IFF(clctrnm IS NOT NULL, '"clCtrNm":' || '"' || clctrnm || '"' || ',', '') ||
            IFF(aptcoffday IS NOT NULL, '"aptCoffDay":' || '"' || aptcoffday || '"' || ',', '') ||
            IFF(aptcoffhr IS NOT NULL, '"aptCoffHr":' || '"' || aptcoffhr || '"' || ',', '') ||
            IFF(eml IS NOT NULL, '"eml":' || '"' || eml || '"' || ',', '') ||
            IFF(fxno IS NOT NULL, '"fxNo":' || '"' || fxno || '"' || ',', '') ||
            IFF(clctrfeatl IS NOT NULL, '"clctrfeatl":' || '"' || clctrfeatl || '"', '')
||' }'
            )::varchar, '', 'clCtrL') as clctrl
    from cte_clctr
    group by
        clienttoproductid
),

cte_display as (
    select 
        facilitycode,
        phonexml as phonel,
        mobilephonexml as mobilephonel,
        urlxml as urll,
        imagexml as imagel,
        tabletphonexml as tabletphonel,
        desktopphonexml as desktopphonel
    from 
        mid.facility 
    where 
        phonexml is not null
        or urlxml is not null
        or imagexml is not null
        or tabletphonexml is not null
        or desktopphonexml is not null
),

cte_displ_xml as (
    select 
        facilitycode,
        utils.p_json_to_xml(array_agg(
            '{ '||
            IFF(phonel IS NOT NULL, '"phoneL":' || '"' || phonel || '"' || ',', '') ||
            IFF(mobilephonel IS NOT NULL, '"mobilePhoneL":' || '"' || mobilephonel || '"' || ',', '') ||
            IFF(urll IS NOT NULL, '"urlL":' || '"' || urll || '"' || ',', '') ||
            IFF(imagel IS NOT NULL, '"imageL":' || '"' || imagel || '"' || ',', '') ||
            IFF(tabletphonel IS NOT NULL, '"tabletPhoneL":' || '"' || tabletphonel || '"' || ',', '') ||
            IFF(desktopphonel IS NOT NULL, '"desktopPhoneL":' || '"' || desktopphonel || '"', '')
            ||' }'
            )::varchar, 'dispL', 'disp') as displ
    from cte_display
    group by facilitycode
),


cte_sponsorship as (
select distinct
    f.facilitycode,
    f.productcode as prcd,
    f.productgroupcode as prgrcd,
    spn.spn,
    cl.clctrl,
    di.displ
from mid.facility as f
    join cte_spn_xml as spn on spn.facilitycode = f.facilitycode
    join cte_clctr_xml as cl on cl.clienttoproductid = f.clienttoproductid
    join cte_displ_xml as di on di.facilitycode = f.facilitycode
where f.clienttoproductid is not null
),

cte_sponsorship_xml as (
    select 
        facilitycode,
        utils.p_json_to_xml(array_agg(
'{ '||
IFF(prgrcd IS NOT NULL, '"prgrcd":' || '"' || prgrcd || '"' || ',', '') ||
IFF(spn IS NOT NULL, '"":' || '"' || spn || '"' || ',', '') ||
IFF(clctrl IS NOT NULL, '"":' || '"' || clctrl || '"' || ',', '') ||
IFF(displ IS NOT NULL, '"":' || '"' || displ || '"', '')
||' }'
            )::varchar, 'sponsorL', 'sponsor') as sponsorshipxml
    from cte_sponsorship
    group by 
        facilitycode
),



cte_solr_facility as (
    select distinct
        fac.facilityid,
        fac.legacykey,
        substr(fac.legacykey, 5, 8) as legacykey8,
        fac.facilitycode,
        case
            when fac.facilitytypecode = 'HGPH'
            and position(
                concat(' ', fad.city, ', ', fad.state, ' '),
                concat(trim(fac.facilityname), ' ')
            ) = 0 then concat(
                trim(fac.facilityname),
                ' in ',
                fad.city,
                ', ',
                fad.state
            )
            else trim(fac.facilityname)
        end as facilityname,
        fac.facilitytype,
        fac.facilitytypecode,
        fac.facilitysearchtype,
        fac.accreditation,
        fac.accreditationdescription,
        fac.treatmentschedules,
        fac.phonenumber,
        fac.additionaltransportationinformation,
        fac.afterhoursphonenumber,
        fac.closedholidaysinformation,
        fac.communityactivitiesinformation,
        fac.communityoutreachprograminformation,
        fac.communitysupportinformation,
        fac.facilitydescription,
        fac.emergencyafterhoursphonenumber,
        fac.foundationinformation,
        fac.healthplaninformation,
        fac.ismedicaidaccepted,
        fac.ismedicareaccepted,
        fac.isteaching,
        fac.languageinformation,
        fac.medicalservicesinformation,
        fac.missionstatement,
        fac.officeclosetime,
        fac.officeopentime,
        fhxml.facilityhoursxml,
        fac.onsiteguestservicesinformation,
        fac.othereducationandtraininginformation,
        fac.otherservicesinformation,
        fac.ownershiptype,
        fac.parkinginstructionsinformation,
        fac.paymentpolicyinformation,
        fac.professionalaffiliationinformation,
        fac.publictransportationinformation,
        fac.regionalrelationshipinformation,
        fac.religiousaffiliationinformation,
        fac.specialprogramsinformation,
        fac.surroundingareainformation,
        fac.teachingprogramsinformation,
        fac.tollfreephonenumber,
        fac.transplantcapabilitiesinformation,
        fac.visitinghoursinformation,
        fac.volunteerinformation,
        fac.yearestablished,
        fac.hospitalaffiliationinformation,
        fac.physiciancallcenterphonenumber,
        fac.overallhospitalstar,
        fac.clientcode,
        fac.productcode,
        fac.providercount,
        fac.awardsinformation,
        fac.awardcount,
        fac.procedurecount,
        fac.fivestarprocedurecount,
        replace(
                trim(ifnull(fac.respgmapprama, '')) || 
                trim(ifnull(fac.respgmappraoa, '')) || 
                trim(ifnull(fac.respgmapprada, '')), 
                'AA', 
                'A, A'
            ) as residencyprogapproval,
        fac.miscellaneousinformation,
        fac.appointmentinformation,
        fac.visitinghoursmonday,
        fac.visitinghourstuesday,
        fac.visitinghourswednesday,
        fac.visitinghoursthursday,
        fac.visitinghoursfriday,
        fac.visitinghourssaturday,
        fac.visitinghourssunday,
        fac.website,
        fac.foreignobjectleftpercent,
        axml.addressxml,
        awxml.awardxml,
        slxml.servicelinexml,
        psxml.patientsatisfactionxml,
        null as toptenprocedurexml,
        dxml.distinctionxml,
        null as patientcarexml,
        rxml.readmissionratexml,
        ecxml.timelyandeffectivecarexml,
        psfxml.patientsafetyxml,
        tlxml.traumalevelxml,
        spxml.sponsorshipxml,
        afxml.affiliationxml,
        lxml.leadershipxml,
        aaxml.awardachievementxml,
        fac.facilityurl,
        fac.facilityimagepath,
        sur.patientsatisfaction,
        case when fac.productgroupcode = 'PDC' then '1' else '0' end as ispdc,
        null as overallpatientsafety,
        getdate() as updateddate,
        current_user() as updatedsource,
        laxml.languagexml,
        sxml.servicexml
    from
        mid.facility as fac
        join cte_facility_address_detail as fad on fad.facilityid = fac.facilityid
        join cte_facility_hours_xml as fhxml on fhxml.facilityid = fac.facilityid
        join cte_address_xml as axml on axml.facilityid = fac.facilityid
        join cte_award_xml as awxml on awxml.facilityid = fac.facilityid
        join cte_service_line_xml as slxml on slxml.facilityid = fac.legacykey
        join cte_patient_satisfaction_xml as psxml on psxml.facilityid = fac.legacykey
        join cte_distinction_xml as dxml on dxml.facilityid = fac.legacykey
        join cte_readmission_rate_xml as rxml on rxml.facilityid = fac.legacykey
        join cte_effective_care_xml as ecxml on ecxml.facilityid = fac.legacykey
        join cte_patient_safety_xml as psfxml on psfxml.facilityid = fac.legacykey
        join cte_trauma_level_xml as tlxml on tlxml.facilitycode = fac.facilitycode
        join cte_sponsorship_xml as spxml on spxml.facilitycode = fac.facilitycode
        join cte_affiliation_xml as afxml on afxml.facilityid = fac.legacykey
        join cte_leadership_xml as lxml on lxml.facilityid = fac.legacykey
        join cte_award_achievement_xml as aaxml on aaxml.facilityid = fac.legacykey
        join cte_survey as sur on sur.facilityid = fac.legacykey
        join cte_language_xml as laxml on laxml.facilityid = fac.facilityid
        join cte_service_xml as sxml on sxml.facilityid = fac.facilityid
)
select 
    facilityid,
    legacykey,
    facilitycode,
    facilitytype,
    facilitytypecode,
    facilitysearchtype,
    accreditation,
    accreditationdescription,
    treatmentschedules,
    phonenumber,
    additionaltransportationinformation,
    afterhoursphonenumber,
    closedholidaysinformation,
    communityactivitiesinformation,
    communityoutreachprograminformation,
    communitysupportinformation,
    facilitydescription,
    emergencyafterhoursphonenumber,
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
    to_variant(facilityhoursxml) as facilityhoursxml,
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
    clientcode,
    productcode,
    providercount,
    awardsinformation,
    awardcount,
    procedurecount,
    fivestarprocedurecount,
    residencyprogapproval,
    miscellaneousinformation,
    appointmentinformation,
    visitinghoursmonday,
    visitinghourstuesday,
    visitinghourswednesday,
    visitinghoursthursday,
    visitinghoursfriday,
    visitinghourssaturday,
    visitinghourssunday,
    website,
    foreignobjectleftpercent,
    to_variant(addressxml) as addressxml,
    to_variant(awardxml) as awardxml,
    to_variant(servicelinexml) as servicelinexml,
    to_variant(patientsatisfactionxml) as patientsatisfactionxml,
    to_variant(toptenprocedurexml) as toptenprocedurexml,
    to_variant(distinctionxml) as distinctionxml,
    to_variant(patientcarexml) as patientcarexml,
    to_variant(readmissionratexml) as readmissionratexml,
    to_variant(timelyandeffectivecarexml) as timelyandeffectivecarexml,
    to_variant(patientsafetyxml) as patientsafetyxml,
    to_variant(traumalevelxml) as traumalevelxml,
    to_variant(sponsorshipxml) as sponsorshipxml,
    to_variant(affiliationxml) as affiliationxml,
    to_variant(leadershipxml) as leadershipxml,
    to_variant(awardachievementxml) as awardachievementxml,
    facilityurl,
    facilityimagepath,
    patientsatisfaction,
    ispdc,
    overallpatientsafety,
    updateddate,
    updatedsource,
    to_variant(languagexml) as languagexml,
    to_variant(servicexml) as servicexml
from cte_solr_facility $$;


--- Insert Statement
insert_statement := '  insert  ( facilityid,
                                legacykey,
                                facilitycode,
                                facilitytype,
                                facilitytypecode,
                                facilitysearchtype,
                                accreditation,
                                accreditationdescription,
                                treatmentschedules,
                                phonenumber,
                                additionaltransportationinformation,
                                afterhoursphonenumber,
                                closedholidaysinformation,
                                communityactivitiesinformation,
                                communityoutreachprograminformation,
                                communitysupportinformation,
                                facilitydescription,
                                emergencyafterhoursphonenumber,
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
                                facilityhoursxml,
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
                                clientcode,
                                productcode,
                                providercount,
                                awardsinformation,
                                awardcount,
                                procedurecount,
                                fivestarprocedurecount,
                                residencyprogapproval,
                                miscellaneousinformation,
                                appointmentinformation,
                                visitinghoursmonday,
                                visitinghourstuesday,
                                visitinghourswednesday,
                                visitinghoursthursday,
                                visitinghoursfriday,
                                visitinghourssaturday,
                                visitinghourssunday,
                                website,
                                foreignobjectleftpercent,
                                addressxml,
                                awardxml,
                                servicelinexml,
                                patientsatisfactionxml,
                                toptenprocedurexml,
                                distinctionxml,
                                patientcarexml,
                                readmissionratexml,
                                timelyandeffectivecarexml,
                                patientsafetyxml,
                                traumalevelxml,
                                sponsorshipxml,
                                affiliationxml,
                                leadershipxml,
                                awardachievementxml,
                                facilityurl,
                                facilityimagepath,
                                patientsatisfaction,
                                ispdc,
                                overallpatientsafety,
                                updateddate,
                                updatedsource,
                                languagexml,
                                servicexml)
                                
                      values (  source.facilityid,
                                source.legacykey,
                                source.facilitycode,
                                source.facilitytype,
                                source.facilitytypecode,
                                source.facilitysearchtype,
                                source.accreditation,
                                source.accreditationdescription,
                                source.treatmentschedules,
                                source.phonenumber,
                                source.additionaltransportationinformation,
                                source.afterhoursphonenumber,
                                source.closedholidaysinformation,
                                source.communityactivitiesinformation,
                                source.communityoutreachprograminformation,
                                source.communitysupportinformation,
                                source.facilitydescription,
                                source.emergencyafterhoursphonenumber,
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
                                source.facilityhoursxml,
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
                                source.clientcode,
                                source.productcode,
                                source.providercount,
                                source.awardsinformation,
                                source.awardcount,
                                source.procedurecount,
                                source.fivestarprocedurecount,
                                source.residencyprogapproval,
                                source.miscellaneousinformation,
                                source.appointmentinformation,
                                source.visitinghoursmonday,
                                source.visitinghourstuesday,
                                source.visitinghourswednesday,
                                source.visitinghoursthursday,
                                source.visitinghoursfriday,
                                source.visitinghourssaturday,
                                source.visitinghourssunday,
                                source.website,
                                source.foreignobjectleftpercent,
                                source.addressxml,
                                source.awardxml,
                                source.servicelinexml,
                                source.patientsatisfactionxml,
                                source.toptenprocedurexml,
                                source.distinctionxml,
                                source.patientcarexml,
                                source.readmissionratexml,
                                source.timelyandeffectivecarexml,
                                source.patientsafetyxml,
                                source.traumalevelxml,
                                source.sponsorshipxml,
                                source.affiliationxml,
                                source.leadershipxml,
                                source.awardachievementxml,
                                source.facilityurl,
                                source.facilityimagepath,
                                source.patientsatisfaction,
                                source.ispdc,
                                source.overallpatientsafety,
                                source.updateddate,
                                source.updatedsource,
                                source.languagexml,
                                source.servicexml )';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into show.solrfacility as target using 
                   ('||select_statement||') as source 
                   on source.facilityid = target.facilityid and source.facilitycode = target.facilitycode
                   when not matched then  '||insert_statement;
                   
        
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