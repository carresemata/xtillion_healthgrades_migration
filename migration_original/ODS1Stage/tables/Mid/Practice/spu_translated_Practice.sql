CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PRACTICE(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
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
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_practice');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin
--- select Statement
select_statement := $$ with CTE_PracticeBatch as (
                        select distinct 
                        o.practiceid
                        from $$ || mdm_db || $$.mst.Provider_Profile_Processing as PDP 
                            join base.provider as P on p.providercode = pdp.ref_PROVIDER_CODE
                            join base.providertooffice as PTO on pto.providerid = p.providerid
                            join base.office as O on o.officeid = pto.officeid
                        order by o.practiceid
                    ),
                        
                    CTE_Service as ( 
                        select 
                            p.phonenumber, 
                            otp.officeid
                        from  base.officetophone OTP
                            join base.phone P on otp.phoneid = p.phoneid
                            join base.phonetype PT on otp.phonetypeid = pt.phonetypeid 
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
                        select  
                            distinct 
                            pto.providerid, 
                            p.practiceid
                        from base.providertooffice as PTO
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
                    CTE_OfficeCode_1 as ( -- no rows
                            select 
                                o.officecode 
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
                    CTE_OfficeCode_2 as ( -- no rows
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
                    ),
                    cte_union as (
                    select 
                        officecode
                    from CTE_OfficeCode_1   
                        union all
                    select 
                        officecode
                    from CTE_OfficeCode_2
                        union all
                    select 
                        officecode
                    from CTE_OfficeCode_3
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
                            join base.nation N on cspc.nationid = n.nationid
                            join base.state S on s.state = cspc.state
                            left join CTE_Service as  CTE_S on CTE_s.officeid = o.officeid
                            left join CTE_Fax as CTE_F  on CTE_f.officeid = o.officeid
                            left join CTE_PhysicianCount as CTE_PC on CTE_pc.practiceid = p.practiceid
                    )
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
                            p.officeurl
                    from cte_practice as P
                        join cte_union as offices on offices.officecode = p.officecode
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
                   when matched then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.Practice;
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