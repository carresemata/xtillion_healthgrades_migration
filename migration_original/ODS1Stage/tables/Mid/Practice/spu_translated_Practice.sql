CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PRACTICE(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------

-- mid.practice depends on:
--- mdm_team.mst.provider_profile_processing
--- base.providertoprovidertype
--- base.providertype
--- base.provider
--- base.providertooffice 
--- base.office
--- base.officetoaddress
--- base.addresstype
--- base.address
--- base.citystatepostalcode 
--- base.nation 
--- base.state
--- base.officetophone 
--- base.phone 
--- base.phonetype
--- base.practice
--- base.clientproductentityrelationship
--- base.relationshiptype 
--- base.clientproducttoentity
--- base.entitytype
--- base.clienttoproduct 
--- base.client 
--- base.product
--- base.productgroup 

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_practice');
    execution_start datetime default getdate();

   
---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------   
   
begin
    if (IsProviderDeltaProcessing) then
           select_statement := '
           with CTE_PracticeBatch as (
                select distinct 
                o.practiceid
                from MDM_team.mst.Provider_Profile_Processing as PDP 
                    join base.provider as P on p.providercode = pdp.ref_PROVIDER_CODE
                    join base.providertooffice as PTO on pto.providerid = p.providerid
                    join base.office as O on o.officeid = pto.officeid
                order by o.practiceid), ';
    else
           select_statement := '
           with CTE_PracticeBatch as (
                select PracticeID
                from base.practice
                order by PracticeID ),';
    end if;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := select_statement || 
                    $$
                    CTE_Service as (
                        select 
                            p.phonenumber, 
                            otp.officeid
                        from  base.officetophone OTP
                            join base.phone P on otp.phoneid = p.phoneid
                            join base.phonetype PT on otp.phonetypeid = pt.phonetypeid 
                            and PhoneTypeCode = 'Service'
                    ),
                    
                    CTE_Fax as (
                        select  
                            p.phonenumber, 
                            otp.officeid
                        from  base.officetophone OTP
                            join base.phone P on otp.phoneid = p.phoneid
                            join base.phonetype PT on otp.phonetypeid = pt.phonetypeid 
                            and PhoneTypeCode = 'FAX'
                    ), 
                    CTE_ProviderToPractice as (
                        select  distinct 
                            pto.providerid, 
                            p.practiceid
                        from    base.providertooffice as PTO
                            join base.office as O on o.officeid = pto.officeid
                            join base.practice as P on p.practiceid = o.practiceid
                    ),
                    CTE_PhysicianCount as (
                        select 
                            PracticeID, 
                            COUNT(*) as PhysicianCount
                        from CTE_ProviderToPractice
                        group by PracticeID
                    )
                    ,
                    --build a temp table of practices with at least one dentist at one of their office
                    CTE_PracticesWithDentists as (
                        select 
                            pb.practiceid 
                        from CTE_PracticeBatch as PB 
                            join base.office as O on o.practiceid = pb.practiceid
                            join base.providertooffice as PO on po.officeid = o.officeid
                            join base.providertoprovidertype as PPT on ppt.providerid = po.providerid 
                            join base.providertype as PT on pt.providertypeid = ppt.providertypeid
                        where pt.providertypecode = 'DENT'
                        group by 
                            pb.practiceid
                    )
                    ,
                    CTE_PROVTOOFF as (
                        select 
                            cper.parentid, 
                            o.officeid, 
                            o.officecode, 
                            o.officename, 
                            p.practiceid, 
                            p.practicecode, 
                            p.practicename,
                            cpte.clientproducttoentityid                           
                        from base.clientproductentityrelationship as CPER 
                            join base.relationshiptype RT on cper.relationshiptypeid = rt.relationshiptypeid
                            join base.clientproducttoentity CPTE on cpte.clientproducttoentityid = cper.childid
                            join base.office O on cpte.entityid = o.officeid 
                            join base.practice P on o.practiceid = p.practiceid
                        where  rt.relationshiptypecode = 'PROVTOOFF'   
                    )
                    ,
                    CTE_OfficeCode_1 as (
                            select o.officecode 
                            from base.office as O 
                            where o.officecode IN ( 'OOO5XB5',
                                                    'OOO82BH',
                                                    'Y3GT4X',
                                                    'YBD8MY',
                                                    'YBD8V7',
                                                    'OOJQPVR',
                                                    'OOJQQB2',
                                                    'YCFH2F',
                                                    'YCFHK7',
                                                    'OOO38H7',
                                                    'YBV56C',
                                                    'OOJVW28',
                                                    'OOJQPWJ',
                                                    'OOS4S2S',
                                                    'OOJTJTQ',
                                                    'YBV5LG',
                                                    'OOO8HQ3')
                    )
                    ,
                    CTE_OfficeCode_2 as (
                            select 
                                cte.officecode
                            from   base.clienttoproduct as CTP
                                join base.client as C on ctp.clientid = c.clientid
                                join base.product as P on ctp.productid = p.productid and p.productcode = 'PDCPRAC'
                                join base.productgroup as PG on p.productgroupid = pg.productgroupid 
                                    and pg.productgroupcode = 'PDC'
                                join base.clientproducttoentity as CPTE on ctp.clienttoproductid = cpte.clienttoproductid
                                join base.entitytype as ET on cpte.entitytypeid = et.entitytypeid 
                                    and et.entitytypecode = 'PROV'
                                join base.provider as BP on cpte.entityid = bp.providerid
                                join CTE_PROVTOOFF as CTE on cpte.clientproducttoentityid = cte.parentid
                            where  ctp.activeflag = 1
                    )
                    ,
                    CTE_OfficeCode_3 as (
                            select 
                                o.officecode 
                            from base.clienttoproduct as CTP
                                join base.client as C on ctp.clientid = ctp.clientid
                                join base.product as P on ctp.productid = p.productid 
                                and p.productcode <> 'PDCPRAC'
                                join base.productgroup as PG on p.productgroupid = pg.productgroupid 
                                    and pg.productgroupcode = 'PDC'
                                join base.clientproducttoentity as CPTE on ctp.clienttoproductid = cpte.clienttoproductid
                                join base.entitytype as ET on cpte.entitytypeid = et.entitytypeid 
                                    and et.entitytypecode = 'PROV'
                                join base.provider as BP on cpte.entityid = bp.providerid
                                join base.providertooffice as PTO on pto.providerid = bp.providerid
                                join base.office as O on o.officeid = pto.officeid
                            where  ctp.activeflag = 1
                            group by
                                o.officecode 
                    )
                    ,
                    CTE_Practice as (select  
                    distinct 
                            p.practiceid,
                            p.practicecode,
                            trim(p.practicename) as PracticeName,
                            p.yearpracticeestablished,
                            p.npi, 
                            p.practicewebsite,
                            p.practicedescription,
                            p.practicelogo,
                            p.practicemedicaldirector,
                            p.practicesoftware,
                            p.practicetin,
                            o.officeid,
                            o.officecode,
                            trim(o.officename) as officename,
                            bat.addresstypecode,
                            a.addressline1 || ifnull( ' ' || a.suite,'') as AddressLine1,
                            a.addressline2,
                            a.addressline3,
                            a.addressline4,
                            cspc.city, 
                            cspc.state, 
                            cspc.postalcode as ZipCode,
                            cspc.county,
                            n.nationname as Nation,
                            a.latitude,
                            a.longitude,
                            CTE_s.phonenumber as FullPhone,
                            CTE_f.phonenumber as FullFax,
                            o.hasbillingstaff,
                            o.hashandicapaccess,
                            o.haslabservicesonsite,
                            o.haspharmacyonsite,
                            o.hasxrayonsite,
                            o.issurgerycenter,
                            o.hassurgeryonsite,
                            o.averagedailypatientvolume,
                            CTE_pc.physiciancount,
                            o.officecoordinatorname,
                            o.parkinginformation,
                            o.paymentpolicy,
                            o.legacykey as LegacyKeyOffice,
                            p.legacykey as LegacyKeyPractice,
                            o.officerank,
                            a.citystatepostalcodeid,
                            CASE 
                                WHEN p.practiceid IN (
                                    select CTE_pwd.practiceid 
                                    from CTE_PracticesWithDentists as CTE_PWD
                                ) then 1
                                else 0
                            END as HasDentist, 
                            REGEXP_REPLACE(
                            REGEXP_REPLACE(
                                CONCAT(
                                    '/group-directory/',
                                    lower(cspc.state),
                                    '-',
                                    lower(REPLACE(s.statename, ' ', '-')),
                                    '/',
                                    lower(REGEXP_REPLACE(cspc.city, '[ -&/''\.]', '-', 1, 0)),
                                    '/',
                                    lower(REGEXP_REPLACE(REGEXP_REPLACE(REPLACE(REPLACE(trim(p.practicename),CHAR(UNICODE('\u0060'))), ' ', '-'), '[&/''\:\\~\\;\\|<>™•*?+®!–@{}\\[\\]()ñéí"’ #,\.]', ''), '--', '-')),
                                    '-',
                                    lower(o.officecode)
                                ),
                                '--',
                                '-'
                            ),
                            '\\r|\\n',
                            ''
                        ) as OfficeURL
                        from CTE_PracticeBatch as PB  --When not migrating a batch, this is all offices in base.office. Otherwise it is just the offices for the providers in the batch
                            join base.practice as P on p.practiceid = pb.practiceid
                            join base.office as O on p.practiceid = o.practiceid
                            join base.officetoaddress as OTA on o.officeid = ota.officeid
                            join base.providertooffice PTO on o.officeid = pto.officeid
                            left join base.addresstype as BAT  on bat.addresstypeid = ota.addresstypeid
                            join base.address as A on a.addressid = ota.addressid
                            join base.citystatepostalcode as CSPC on a.citystatepostalcodeid = cspc.citystatepostalcodeid
                            join base.nation N on ifnull(cspc.nationid,'00415355-0000-0000-0000-000000000000') = n.nationid
                            join base.state S on s.state = cspc.state
                            left join CTE_Service as  CTE_S on CTE_s.officeid = o.officeid
                            left join CTE_Fax as CTE_F  on CTE_f.officeid = o.officeid
                            left join CTE_PhysicianCount as CTE_PC on CTE_pc.practiceid = p.practiceid
                    ),
                    CTE_FinalPractice as (
                    select distinct
                            p.practiceid,
                            p.practicecode,
                            p.practicename,
                            p.yearpracticeestablished,
                            p.npi, 
                            p.practicewebsite,
                            p.practicedescription,
                            p.practicelogo,
                            p.practicemedicaldirector,
                            p.practicesoftware,
                            p.practicetin,
                            p.officeid,
                            p.officecode,
                            p.officename,
                            p.addresstypecode,
                            p.addressline1,
                            p.addressline2,
                            p.addressline3,
                            p.addressline4,
                            p.city, 
                            p.state, 
                            p.zipcode,
                            p.county,
                            p.nation,
                            p.latitude,
                            p.longitude,
                            p.fullphone,
                            p.fullfax,
                            p.hasbillingstaff,
                            p.hashandicapaccess,
                            p.haslabservicesonsite,
                            p.haspharmacyonsite,
                            p.hasxrayonsite,
                            p.issurgerycenter,
                            p.hassurgeryonsite,
                            p.averagedailypatientvolume,
                            p.physiciancount,
                            p.officecoordinatorname,
                            p.parkinginformation,
                            p.paymentpolicy,
                            p.legacykeyoffice,
                            p.legacykeypractice,
                            p.officerank,
                            p.citystatepostalcodeid,
                            p.hasdentist, 
                    '''{"@@context": "http://schema.org","@@type" : "MedicalClinic","@@id":"' || p.officeurl || '","name":"' || p.practicename || '","address": {"@@type": "PostalAddress","streetAddress":"' || p.addressline1 || '","addressLocality":"' || p.city || '","addressRegion":"' || p.state || '","postalCode":"' || p.zipcode || '","addressCountry": "US"},"geo": {"@@type":"GeoCoordinates","latitude":"' || to_varchar(p.latitude) || '","longitude":"' || to_varchar(p.longitude) || '"},"telephone":"' || ifnull(p.fullphone,'') || '","potentialAction":{"@@type":"ReserveAction","@@id":"/groupgoogleform/' || p.officecode || '","url":"/groupgoogleform"}}''' as GoogleScriptBlock,
                            p.officeurl,
                            0 as ActionCode -- Action code 0, no changes
                    from cte_practice as P
                    join (
                            select * from CTE_OfficeCode_1
                            union
                            select * from CTE_OfficeCode_2
                            union
                            select * from CTE_OfficeCode_3
                        ) offices on offices.officecode = p.officecode),
                        
                    -- insert Action    
                    CTE_Action_1 as 
                            (select 
                                cte.practiceid,
                                1 as ActionCode
                            from CTE_FinalPractice as cte
                            left join mid.practice as mp on
                                cte.practiceid = mp.practiceid and 
                                cte.practicecode = mp.practicecode
                            where mp.practiceid is null
                            group by cte.practiceid
                            )
                            
                    -- update Action
                    ,
                    CTE_Action_2 as 
                            (select
                                cte.practiceid,
                                2 as ActionCode
                            from CTE_FinalPractice as cte
                            join mid.practice as mp on
                                cte.practiceid = mp.practiceid and 
                                cte.practicecode = mp.practicecode
                            where
                                MD5(ifnull(cte.practicename::varchar,''))<>           MD5(ifnull(mp.practicename::varchar,'')) or
                                MD5(ifnull(cte.yearpracticeestablished::varchar,''))<>MD5(ifnull(mp.yearpracticeestablished::varchar,'')) or
                                MD5(ifnull(cte.npi::varchar,''))<>                    MD5(ifnull(mp.npi::varchar,'')) or
                                MD5(ifnull(cte.practicewebsite::varchar,''))<>        MD5(ifnull(mp.practicewebsite::varchar,'')) or
                                MD5(ifnull(cte.practicedescription::varchar,''))<>    MD5(ifnull(mp.practicedescription::varchar,'')) or
                                MD5(ifnull(cte.practicelogo::varchar,''))<>           MD5(ifnull(mp.practicelogo::varchar,'')) or
                                MD5(ifnull(cte.practicemedicaldirector::varchar,''))<>MD5(ifnull(mp.practicemedicaldirector::varchar,'')) or
                                MD5(ifnull(cte.practicesoftware::varchar,''))<>       MD5(ifnull(mp.practicesoftware::varchar,'')) or
                                MD5(ifnull(cte.practicetin::varchar,''))<>            MD5(ifnull(mp.practicetin::varchar,'')) or
                                MD5(ifnull(cte.officeid::varchar,''))<>               MD5(ifnull(mp.officeid::varchar,'')) or
                                MD5(ifnull(cte.officecode::varchar,''))<>             MD5(ifnull(mp.officecode::varchar,'')) or
                                MD5(ifnull(cte.officename::varchar,''))<>             MD5(ifnull(mp.officename::varchar,'')) or
                                MD5(ifnull(cte.addresstypecode::varchar,''))<>        MD5(ifnull(mp.addresstypecode::varchar,'')) or
                                MD5(ifnull(cte.addressline1::varchar,''))<>           MD5(ifnull(mp.addressline1::varchar,'')) or
                                MD5(ifnull(cte.addressline2::varchar,''))<>           MD5(ifnull(mp.addressline2::varchar,'')) or
                                MD5(ifnull(cte.addressline3::varchar,''))<>           MD5(ifnull(mp.addressline3::varchar,'')) or
                                MD5(ifnull(cte.addressline4::varchar,''))<>           MD5(ifnull(mp.addressline4::varchar,'')) or
                                MD5(ifnull(cte.city::varchar,''))<>                   MD5(ifnull(mp.city::varchar,'')) or
                                MD5(ifnull(cte.state::varchar,''))<>                  MD5(ifnull(mp.state::varchar,'')) or
                                MD5(ifnull(cte.zipcode::varchar,''))<>                MD5(ifnull(mp.zipcode::varchar,'')) or
                                MD5(ifnull(cte.county::varchar,''))<>                 MD5(ifnull(mp.county::varchar,'')) or
                                MD5(ifnull(cte.nation::varchar,''))<>                 MD5(ifnull(mp.nation::varchar,'')) or
                                MD5(ifnull(cte.latitude::varchar,''))<>               MD5(ifnull(mp.latitude::varchar,'')) or
                                MD5(ifnull(cte.longitude::varchar,''))<>              MD5(ifnull(mp.longitude::varchar,'')) or
                                MD5(ifnull(cte.fullphone::varchar,''))<>              MD5(ifnull(mp.fullphone::varchar,'')) or
                                MD5(ifnull(cte.fullfax::varchar,''))<>                MD5(ifnull(mp.fullfax::varchar,'')) or
                                MD5(ifnull(cte.hasbillingstaff::varchar,''))<>        MD5(ifnull(mp.hasbillingstaff::varchar,'')) or
                                MD5(ifnull(cte.hashandicapaccess::varchar,''))<>      MD5(ifnull(mp.hashandicapaccess::varchar,'')) or
                                MD5(ifnull(cte.haslabservicesonsite::varchar,''))<>   MD5(ifnull(mp.haslabservicesonsite::varchar,'')) or
                                MD5(ifnull(cte.haspharmacyonsite::varchar,''))<>      MD5(ifnull(mp.haspharmacyonsite::varchar,'')) or
                                MD5(ifnull(cte.hasxrayonsite::varchar,''))<>          MD5(ifnull(mp.hasxrayonsite::varchar,'')) or
                                MD5(ifnull(cte.issurgerycenter::varchar,''))<>        MD5(ifnull(mp.issurgerycenter::varchar,'')) or
                                MD5(ifnull(cte.hassurgeryonsite::varchar,''))<>       MD5(ifnull(mp.hassurgeryonsite::varchar,'')) or
                                MD5(ifnull(cte.averagedailypatientvolume::varchar,''))<>MD5(ifnull(mp.averagedailypatientvolume::varchar,'')) or
                                MD5(ifnull(cte.physiciancount::varchar,''))<>         MD5(ifnull(mp.physiciancount::varchar,'')) or
                                MD5(ifnull(cte.officecoordinatorname::varchar,''))<>  MD5(ifnull(mp.officecoordinatorname::varchar,'')) or
                                MD5(ifnull(cte.parkinginformation::varchar,''))<>     MD5(ifnull(mp.parkinginformation::varchar,'')) or
                                MD5(ifnull(cte.paymentpolicy::varchar,''))<>          MD5(ifnull(mp.paymentpolicy::varchar,'')) or
                                MD5(ifnull(cte.legacykeyoffice::varchar,''))<>        MD5(ifnull(mp.legacykeyoffice::varchar,'')) or
                                MD5(ifnull(cte.legacykeypractice::varchar,''))<>      MD5(ifnull(mp.legacykeypractice::varchar,'')) or
                                MD5(ifnull(cte.officerank::varchar,''))<>             MD5(ifnull(mp.officerank::varchar,'')) or
                                MD5(ifnull(cte.citystatepostalcodeid::varchar,''))<>  MD5(ifnull(mp.citystatepostalcodeid::varchar,'')) or
                                MD5(ifnull(cte.hasdentist::varchar,''))<>             MD5(ifnull(mp.hasdentist::varchar,'')) or
                                MD5(ifnull(cte.googlescriptblock::varchar,''))<>      MD5(ifnull(mp.googlescriptblock::varchar,'')) or
                                MD5(ifnull(cte.officeurl::varchar,''))<>              MD5(ifnull(mp.officeurl::varchar,''))
                            group by
                                cte.practiceid
                            )
                    select
                        A0.PracticeId,
                        A0.PracticeCode,
                        A0.PracticeName,
                        A0.YearPracticeEstablished,
                        A0.NPI,
                        A0.PracticeWebsite,
                        A0.PracticeDescription,
                        A0.PracticeLogo,
                        A0.PracticeMedicalDirector,
                        A0.PracticeSoftware,
                        A0.PracticeTIN,
                        A0.OfficeID,
                        A0.OfficeCode,
                        A0.officename,
                        A0.AddressTypeCode,
                        A0.AddressLine1,
                        A0.AddressLine2,
                        A0.AddressLine3,
                        A0.AddressLine4,
                        A0.City,
                        A0.State,
                        A0.ZipCode,
                        A0.County,
                        A0.Nation,
                        A0.Latitude,
                        A0.Longitude,
                        A0.FullPhone,
                        A0.FullFax,
                        A0.HasBillingStaff,
                        A0.HasHandicapAccess,
                        A0.HasLabServicesOnSite,
                        A0.HasPharmacyOnSite,
                        A0.HasXrayOnSite,
                        A0.IsSurgeryCenter,
                        A0.HasSurgeryOnSite,
                        A0.AverageDailyPatientVolume,
                        A0.PhysicianCount,
                        A0.OfficeCoordinatorName,
                        A0.ParkingInformation,
                        A0.PaymentPolicy,
                        A0.LegacyKeyOffice,
                        A0.LegacyKeyPractice,
                        A0.OfficeRank,
                        A0.CityStatePostalCodeID,
                        A0.HasDentist,
                        A0.GoogleScriptBlock,
                        A0.OfficeURL,
                        ifnull(A1.ActionCode, ifnull(A2.ActionCode, A0.ActionCode)) as ActionCode
                    from CTE_FinalPractice as A0
                        left join CTE_Action_1 as A1 on A0.PracticeID = A1.PracticeID
                        left join CTE_Action_2 as A2 on A0.PracticeID = A2.PracticeID
                    where
                        ifnull(A1.ActionCode, ifnull(A2.ActionCode, A0.ActionCode)) <> 0
                    $$;

--- update Statement
update_statement := ' update 
                        SET
                            PracticeName = source.practicename,
                            YearPracticeEstablished = source.yearpracticeestablished,
                            NPI = source.npi,
                            PracticeWebsite = source.practicewebsite,
                            PracticeDescription = source.practicedescription,
                            PracticeLogo = source.practicelogo,
                            PracticeMedicalDirector = source.practicemedicaldirector,
                            PracticeSoftware = source.practicesoftware,
                            PracticeTIN = source.practicetin,
                            OfficeID = source.officeid,
                            OfficeCode = source.officecode,
                            officename = source.officename,
                            AddressTypeCode = source.addresstypecode,
                            AddressLine1 = source.addressline1,
                            AddressLine2 = source.addressline2,
                            AddressLine3 = source.addressline3,
                            AddressLine4 = source.addressline4,
                            City = source.city,
                            State = source.state,
                            ZipCode = source.zipcode,
                            County = source.county,
                            Nation = source.nation,
                            Latitude = source.latitude,
                            Longitude = source.longitude,
                            FullPhone = source.fullphone,
                            FullFax = source.fullfax,
                            HasBillingStaff = source.hasbillingstaff,
                            HasHandicapAccess = source.hashandicapaccess,
                            HasLabServicesOnSite = source.haslabservicesonsite,
                            HasPharmacyOnSite = source.haspharmacyonsite,
                            HasXrayOnSite = source.hasxrayonsite,
                            IsSurgeryCenter = source.issurgerycenter,
                            HasSurgeryOnSite = source.hassurgeryonsite,
                            AverageDailyPatientVolume = source.averagedailypatientvolume,
                            PhysicianCount = source.physiciancount,
                            OfficeCoordinatorName = source.officecoordinatorname,
                            ParkingInformation = source.parkinginformation,
                            PaymentPolicy = source.paymentpolicy,
                            LegacyKeyOffice = source.legacykeyoffice,
                            LegacyKeyPractice = source.legacykeypractice,
                            OfficeRank = source.officerank,
                            CityStatePostalCodeID = source.citystatepostalcodeid,
                            HasDentist = source.hasdentist,
                            GoogleScriptBlock = source.googlescriptblock,
                            OfficeURL = source.officeurl';

--- insert Statement
insert_statement := ' insert
                        (PracticeId,
                        PracticeCode,
                        PracticeName,
                        YearPracticeEstablished,
                        NPI,
                        PracticeWebsite,
                        PracticeDescription,
                        PracticeLogo,
                        PracticeMedicalDirector,
                        PracticeSoftware,
                        PracticeTIN,
                        OfficeID,
                        OfficeCode,
                        officename,
                        AddressTypeCode,
                        AddressLine1,
                        AddressLine2,
                        AddressLine3,
                        AddressLine4,
                        City,
                        State,
                        ZipCode,
                        County,
                        Nation,
                        Latitude,
                        Longitude,
                        FullPhone,
                        FullFax,
                        HasBillingStaff,
                        HasHandicapAccess,
                        HasLabServicesOnSite,
                        HasPharmacyOnSite,
                        HasXrayOnSite,
                        IsSurgeryCenter,
                        HasSurgeryOnSite,
                        AverageDailyPatientVolume,
                        PhysicianCount,
                        OfficeCoordinatorName,
                        ParkingInformation,
                        PaymentPolicy,
                        LegacyKeyOffice,
                        LegacyKeyPractice,
                        OfficeRank,
                        CityStatePostalCodeID,
                        HasDentist,
                        GoogleScriptBlock,
                        OfficeURL)
                    values
                        (source.practiceid,
                        source.practicecode,
                        source.practicename,
                        source.yearpracticeestablished,
                        source.npi,
                        source.practicewebsite,
                        source.practicedescription,
                        source.practicelogo,
                        source.practicemedicaldirector,
                        source.practicesoftware,
                        source.practicetin,
                        source.officeid,
                        source.officecode,
                        source.officename,
                        source.addresstypecode,
                        source.addressline1,
                        source.addressline2,
                        source.addressline3,
                        source.addressline4,
                        source.city,
                        source.state,
                        source.zipcode,
                        source.county,
                        source.nation,
                        source.latitude,
                        source.longitude,
                        source.fullphone,
                        source.fullfax,
                        source.hasbillingstaff,
                        source.hashandicapaccess,
                        source.haslabservicesonsite,
                        source.haspharmacyonsite,
                        source.hasxrayonsite,
                        source.issurgerycenter,
                        source.hassurgeryonsite,
                        source.averagedailypatientvolume,
                        source.physiciancount,
                        source.officecoordinatorname,
                        source.parkinginformation,
                        source.paymentpolicy,
                        source.legacykeyoffice,
                        source.legacykeypractice,
                        source.officerank,
                        source.citystatepostalcodeid,
                        source.hasdentist,
                        source.googlescriptblock,
                        source.officeurl);';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.practice as target using 
                   ('||select_statement||') as source 
                   on source.practiceid = target.practiceid and source.officeid = target.officeid
                   WHEN MATCHED and ActionCode = 2 then '||update_statement|| '
                   when not matched and ActionCode = 1 then '||insert_statement;
                   
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 
                    
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