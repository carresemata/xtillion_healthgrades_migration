CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDERPRACTICEOFFICE()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

-- mid.providerpracticeoffice depends on:
-- mdm_team.mst.provider_profile_processing
-- base.officetoaddress
-- base.practice
-- base.officetophone
-- base.provider
-- base.phone
-- base.nation
-- base.address
-- base.phonetype
-- base.practiceemail
-- base.office
-- base.providertooffice
-- base.citystatepostalcode

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- main update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providerpracticeoffice');
    execution_start datetime default getdate();

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin
select_statement := $$ with CTE_ProviderBatch as (
                            select p.providerid
                            from MDM_team.mst.Provider_Profile_Processing as ppp
                            join base.provider as p on ppp.ref_provider_code = p.providercode),
            CTE_ServiceNumbers as (
                select o.phonenumber, pto.officeid, row_number() over(partition by pto.officeid order by pto.phonerank, pto.lastupdatedate desc, 
                       o.lastupdatedate, pto.phoneid) as SequenceId1   
                from base.officetophone pto
                join base.phone o on (pto.phoneid = o.phoneid)
                where pto.phonetypeid = (select PhoneTypeID from base.phonetype where PhoneTypeCode = 'Service') 
            ),
            
            CTE_FaxNumbers as (
                select o.phonenumber, pto.officeid, row_number() over(partition by pto.officeid order by pto.phonerank, pto.lastupdatedate desc,                      o.lastupdatedate, pto.phoneid) as SequenceId1
                from base.officetophone pto
                join base.phone o on (pto.phoneid = o.phoneid)
                where pto.phonetypeid = (select PhoneTypeID from base.phonetype where PhoneTypeCode = 'Fax') 
            ),
            
            CTE_ProviderOfficeRank as (
                select ProviderID, MIN(ProviderOfficeRank) as ProviderOfficeRank
                from base.providertooffice
                where ProviderOfficeRank is not null
                group by ProviderID
            ),
            
            CTE_PracticeEmails as (
                select PracticeID, EmailAddress, row_number() over (partition by PracticeID order by LEN(EmailAddress)) as EmailRank
                from base.practiceemail
                where EmailAddress is not null
            ),
            
            CTE_ProviderPracticeOffice as (
                select distinct 
                    pto.providertoofficeid, 
                    pto.providerid,  
                    p.practiceid, 
                    p.practicecode, 
                    CASE 
                        WHEN pto.practicename is not null then pto.practicename 
                        else p.practicename 
                    END as PracticeName,
                    p.yearpracticeestablished, 
                    p.npi as PracticeNPI, 
                    cte_pe.emailaddress as PracticeEmail,
                    p.practicewebsite, 
                    p.practicedescription, 
                    p.practicelogo, 
                    p.practicemedicaldirector, 
                    p.practicesoftware, 
                    p.practicetin, 
                    ota.officetoaddressid, 
                    o.officeid, 
                    o.officecode, 
                    CASE 
                        WHEN pto.officename is not null then pto.officename 
                        else o.officename 
                    END as OfficeName, 
                    CASE
                        WHEN cte_por.providerid is not null then 1
                        else null 
                    END as IsPrimaryOffice, 
                    pto.providerofficerank, 
                    a.addressid, 
                    a.addresscode, 
                    'Office' as AddressTypeCode, 
                    a.addressline1 as AddressLine1, 
                    null as AddressLine2, 
                    a.addressline3, 
                    a.addressline4,
                    cspc.city, 
                    cspc.state, 
                    cspc.postalcode as ZipCode, 
                    cspc.county, 
                    n.nationname as Nation, 
                    a.latitude, 
                    a.longitude,
                    cte_sn.phonenumber as FullPhone,
                    cte_fn.phonenumber as FullFax,
                    ota.isderived, 
                    o.hasbillingstaff,
                    o.hashandicapaccess, 
                    o.haslabservicesonsite, 
                    o.haspharmacyonsite, 
                    o.hasxrayonsite, 
                    o.issurgerycenter, 
                    o.hassurgeryonsite, 
                    o.averagedailypatientvolume, 
                    null as PhysicianCount, 
                    o.officecoordinatorname, 
                    o.parkinginformation, 
                    o.paymentpolicy,
                    o.legacykey as LegacyKeyOffice, 
                    p.legacykey as LegacyKeyPractice,
                    0 as ActionCode
                from CTE_ProviderBatch pb 
                inner join base.providertooffice as pto on pb.providerid = pto.providerid
                inner join base.office as o on o.officeid = pto.officeid
                inner join base.officetoaddress as ota on o.officeid = ota.officeid
                inner join base.address as a on a.addressid = ota.addressid	
                left join CTE_ServiceNumbers as cte_sn on cte_sn.officeid = o.officeid and cte_sn.sequenceid1 = 1
                left join CTE_FaxNumbers as cte_fn on cte_fn.officeid = o.officeid and cte_fn.sequenceid1 = 1
                left join base.citystatepostalcode as cspc on a.citystatepostalcodeid = cspc.citystatepostalcodeid
                left join base.nation as n on cspc.nationid = n.nationid
                left join base.practice as p on o.practiceid = p.practiceid
                left join CTE_ProviderOfficeRank as cte_por on pto.providerid = cte_por.providerid and pto.providerofficerank = cte_por.providerofficerank
                left join CTE_PracticeEmails cte_pe on cte_pe.practiceid = o.practiceid and cte_pe.emailrank = 1
            ),
            
            -- insert Action
            CTE_Action_1 as (
                    select 
                        cte.providerid,
                        cte.officeid,
                        cte.fullphone,
                        cte.fullfax,
                        1 as ActionCode
                    from CTE_ProviderPracticeOffice as cte
                    left join mid.providerpracticeoffice as mid 
                        on (cte.providerid = mid.providerid and cte.officeid = mid.officeid
                        and ifnull(cte.fullphone, '') = ifnull(mid.fullphone, '')
                        and ifnull(cte.fullfax, '') = ifnull(mid.fullfax, ''))
                    where mid.providertoofficeid is null
            ),
            
            -- update Action
            CTE_Action_2 as (
                    select 
                        cte.providerid,
                        cte.officeid,
                        cte.fullphone,
                        cte.fullfax,
                        2 as ActionCode
                    from CTE_ProviderPracticeOffice as cte
                    inner join mid.providerpracticeoffice as mid 
                        on (cte.providerid = mid.providerid and cte.officeid = mid.officeid
                        and ifnull(cte.fullphone, '') = ifnull(mid.fullphone, '')
                        and ifnull(cte.fullfax, '') = ifnull(mid.fullfax, ''))
                    where 
                        MD5(ifnull(cte.addresscode::varchar,'''')) <> MD5(ifnull(mid.addresscode::varchar,'''')) or 
                        MD5(ifnull(cte.addressid::varchar,'''')) <> MD5(ifnull(mid.addressid::varchar,'''')) or
                        MD5(ifnull(cte.addressline1::varchar,'''')) <> MD5(ifnull(mid.addressline1::varchar,'''')) or
                        MD5(ifnull(cte.addressline2::varchar,'''')) <> MD5(ifnull(mid.addressline2::varchar,'''')) or
                        MD5(ifnull(cte.addressline3::varchar,'''')) <> MD5(ifnull(mid.addressline3::varchar,'''')) or
                        MD5(ifnull(cte.addressline4::varchar,'''')) <> MD5(ifnull(mid.addressline4::varchar,'''')) or
                        MD5(ifnull(cte.addresstypecode::varchar,'''')) <> MD5(ifnull(mid.addresstypecode::varchar,'''')) or
                        MD5(ifnull(cte.averagedailypatientvolume::varchar,'''')) <> MD5(ifnull(mid.averagedailypatientvolume::varchar,'''')) or
                        MD5(ifnull(cte.city::varchar,'''')) <> MD5(ifnull(mid.city::varchar,'''')) or
                        MD5(ifnull(cte.county::varchar,'''')) <> MD5(ifnull(mid.county::varchar,'''')) or
                        MD5(ifnull(cte.fullfax::varchar,'''')) <> MD5(ifnull(mid.fullfax::varchar,'''')) or
                        MD5(ifnull(cte.fullphone::varchar,'''')) <> MD5(ifnull(mid.fullphone::varchar,'''')) or
                        MD5(ifnull(cte.hasbillingstaff::varchar,'''')) <> MD5(ifnull(mid.hasbillingstaff::varchar,'''')) or
                        MD5(ifnull(cte.hashandicapaccess::varchar,'''')) <> MD5(ifnull(mid.hashandicapaccess::varchar,'''')) or
                        MD5(ifnull(cte.haslabservicesonsite::varchar,'''')) <> MD5(ifnull(mid.haslabservicesonsite::varchar,'''')) or
                        MD5(ifnull(cte.haspharmacyonsite::varchar,'''')) <> MD5(ifnull(mid.haspharmacyonsite::varchar,'''')) or
                        MD5(ifnull(cte.hassurgeryonsite::varchar,'''')) <> MD5(ifnull(mid.hassurgeryonsite::varchar,'''')) or
                        MD5(ifnull(cte.hasxrayonsite::varchar,'''')) <> MD5(ifnull(mid.hasxrayonsite::varchar,'''')) or
                        MD5(ifnull(cte.isderived::varchar,'''')) <> MD5(ifnull(mid.isderived::varchar,'''')) or
                        MD5(ifnull(cte.isprimaryoffice::varchar,'''')) <> MD5(ifnull(mid.isprimaryoffice::varchar,'''')) or
                        MD5(ifnull(cte.issurgerycenter::varchar,'''')) <> MD5(ifnull(mid.issurgerycenter::varchar,'''')) or
                        MD5(ifnull(cte.latitude::varchar,'''')) <> MD5(ifnull(mid.latitude::varchar,'''')) or
                        MD5(ifnull(cte.legacykeyoffice::varchar,'''')) <> MD5(ifnull(mid.legacykeyoffice::varchar,'''')) or
                        MD5(ifnull(cte.legacykeypractice::varchar,'''')) <> MD5(ifnull(mid.legacykeypractice::varchar,'''')) or
                        MD5(ifnull(cte.longitude::varchar,'''')) <> MD5(ifnull(mid.longitude::varchar,'''')) or
                        MD5(ifnull(cte.nation::varchar,'''')) <> MD5(ifnull(mid.nation::varchar,'''')) or
                        MD5(ifnull(cte.officecode::varchar,'''')) <> MD5(ifnull(mid.officecode::varchar,'''')) or
                        MD5(ifnull(cte.officecoordinatorname::varchar,'''')) <> MD5(ifnull(mid.officecoordinatorname::varchar,'''')) or
                        MD5(ifnull(cte.officeid::varchar,'''')) <> MD5(ifnull(mid.officeid::varchar,'''')) or
                        MD5(ifnull(cte.officename::varchar,'''')) <> MD5(ifnull(mid.officename::varchar,'''')) or
                        MD5(ifnull(cte.officetoaddressid::varchar,'''')) <> MD5(ifnull(mid.officetoaddressid::varchar,'''')) or
                        MD5(ifnull(cte.parkinginformation::varchar,'''')) <> MD5(ifnull(mid.parkinginformation::varchar,'''')) or
                        MD5(ifnull(cte.paymentpolicy::varchar,'''')) <> MD5(ifnull(mid.paymentpolicy::varchar,'''')) or
                        MD5(ifnull(cte.physiciancount::varchar,'''')) <> MD5(ifnull(mid.physiciancount::varchar,'''')) or
                        MD5(ifnull(cte.practicecode::varchar,'''')) <> MD5(ifnull(mid.practicecode::varchar,'''')) or
                        MD5(ifnull(cte.practicedescription::varchar,'''')) <> MD5(ifnull(mid.practicedescription::varchar,'''')) or
                        MD5(ifnull(cte.practiceemail::varchar,'''')) <> MD5(ifnull(mid.practiceemail::varchar,'''')) or
                        MD5(ifnull(cte.practiceid::varchar,'''')) <> MD5(ifnull(mid.practiceid::varchar,'''')) or
                        MD5(ifnull(cte.practicelogo::varchar,'''')) <> MD5(ifnull(mid.practicelogo::varchar,'''')) or
                        MD5(ifnull(cte.practicemedicaldirector::varchar,'''')) <> MD5(ifnull(mid.practicemedicaldirector::varchar,'''')) or
                        MD5(ifnull(cte.practicename::varchar,'''')) <> MD5(ifnull(mid.practicename::varchar,'''')) or
                        MD5(ifnull(cte.practicenpi::varchar,'''')) <> MD5(ifnull(mid.practicenpi::varchar,'''')) or
                        MD5(ifnull(cte.practicesoftware::varchar,'''')) <> MD5(ifnull(mid.practicesoftware::varchar,'''')) or
                        MD5(ifnull(cte.practicetin::varchar,'''')) <> MD5(ifnull(mid.practicetin::varchar,'''')) or
                        MD5(ifnull(cte.practicewebsite::varchar,'''')) <> MD5(ifnull(mid.practicewebsite::varchar,'''')) or
                        MD5(ifnull(cte.providerid::varchar,'''')) <> MD5(ifnull(mid.providerid::varchar,'''')) or
                        MD5(ifnull(cte.providerofficerank::varchar,'''')) <> MD5(ifnull(mid.providerofficerank::varchar,'''')) or
                        MD5(ifnull(cte.providertoofficeid::varchar,'''')) <> MD5(ifnull(mid.providertoofficeid::varchar,'''')) or
                        MD5(ifnull(cte.state::varchar,'''')) <> MD5(ifnull(mid.state::varchar,'''')) or
                        MD5(ifnull(cte.yearpracticeestablished::varchar,'''')) <> MD5(ifnull(mid.yearpracticeestablished::varchar,'''')) or
                        MD5(ifnull(cte.zipcode::varchar,'''')) <> MD5(ifnull(mid.zipcode::varchar,''''))
            )
            
            select distinct
                A0.AddressCode,
                A0.AddressID,
                A0.AddressLine1,
                A0.AddressLine2,
                A0.AddressLine3,
                A0.AddressLine4,
                A0.AddressTypeCode,
                A0.AverageDailyPatientVolume,
                A0.City,
                A0.County,
                A0.FullFax,
                A0.FullPhone,
                A0.HasBillingStaff,
                A0.HasHandicapAccess,
                A0.HasLabServicesOnSite,
                A0.HasPharmacyOnSite,
                A0.HasSurgeryOnSite,
                A0.HasXrayOnSite,
                A0.IsDerived,
                A0.IsPrimaryOffice,
                A0.IsSurgeryCenter,
                A0.Latitude,
                A0.LegacyKeyOffice,
                A0.LegacyKeyPractice,
                A0.Longitude,
                A0.Nation,
                A0.OfficeCode,
                A0.OfficeCoordinatorName,
                A0.OfficeID,
                A0.OfficeName,
                A0.OfficeToAddressID,
                A0.ParkingInformation,
                A0.PaymentPolicy,
                A0.PhysicianCount,
                A0.PracticeCode,
                A0.PracticeDescription,
                A0.PracticeEmail,
                A0.PracticeID,
                A0.PracticeLogo,
                A0.PracticeMedicalDirector,
                A0.PracticeName,
                A0.PracticeNPI,
                A0.PracticeSoftware,
                A0.PracticeTIN,
                A0.PracticeWebsite,
                A0.ProviderID,
                A0.ProviderOfficeRank,
                A0.ProviderToOfficeID,
                A0.State,
                A0.YearPracticeEstablished,
                A0.ZipCode,
                ifnull(A1.ActionCode,ifnull(A2.ActionCode, A0.ActionCode)) as ActionCode  
            from CTE_ProviderPracticeOffice as A0
            left join CTE_Action_1 as A1 on A0.ProviderID = A1.ProviderID and A0.OfficeID = A1.OfficeID
            left join CTE_Action_2 as A2 on A0.ProviderID = A2.ProviderID and A0.OfficeID = A2.OfficeID
            where ifnull(A1.ActionCode,ifnull(A2.ActionCode, A0.ActionCode)) <> 0
            $$;
                        


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------

update_statement := $$
                     update SET 
                        target.addresscode = source.addresscode,
                        target.addressid = source.addressid,
                        target.addressline1 = source.addressline1,
                        target.addressline2 = source.addressline2,
                        target.addressline3 = source.addressline3,
                        target.addressline4 = source.addressline4,
                        target.addresstypecode = source.addresstypecode,
                        target.averagedailypatientvolume = source.averagedailypatientvolume,
                        target.city = CASE 
                                        WHEN source.city || ', ' || source.state LIKE '%,,%' then LEFT(source.city, LENGTH(source.city) - 1)
                                        else source.city
                                      END,
                        target.county = source.county,
                        target.fullfax = source.fullfax,
                        target.fullphone = source.fullphone,
                        target.hasbillingstaff = source.hasbillingstaff,
                        target.hashandicapaccess = source.hashandicapaccess,
                        target.haslabservicesonsite = source.haslabservicesonsite,
                        target.haspharmacyonsite = source.haspharmacyonsite,
                        target.hassurgeryonsite = source.hassurgeryonsite,
                        target.hasxrayonsite = source.hasxrayonsite,
                        target.isderived = source.isderived,
                        target.isprimaryoffice = source.isprimaryoffice,
                        target.issurgerycenter = source.issurgerycenter,
                        target.latitude = source.latitude,
                        target.legacykeyoffice = source.legacykeyoffice,
                        target.legacykeypractice = source.legacykeypractice,
                        target.longitude = source.longitude,
                        target.nation = source.nation,
                        target.officecode = source.officecode,
                        target.officecoordinatorname = source.officecoordinatorname,
                        target.officeid = source.officeid,
                        target.officename = utils.fnuremovespecialhexadecimalcharacters(source.officename),
                        target.officetoaddressid = source.officetoaddressid,
                        target.parkinginformation = source.parkinginformation,
                        target.paymentpolicy = source.paymentpolicy,
                        target.physiciancount = source.physiciancount,
                        target.practicecode = source.practicecode,
                        target.practicedescription = source.practicedescription,
                        target.practiceemail = source.practiceemail,
                        target.practiceid = source.practiceid,
                        target.practicelogo = source.practicelogo,
                        target.practicemedicaldirector = source.practicemedicaldirector,
                        target.practicename = source.practicename,
                        target.practicenpi = source.practicenpi,
                        target.practicesoftware = source.practicesoftware,
                        target.practicetin = source.practicetin,
                        target.practicewebsite = source.practicewebsite,
                        target.providerid = source.providerid,
                        target.providerofficerank = source.providerofficerank,
                        target.providertoofficeid = source.providertoofficeid,
                        target.state = source.state,
                        target.yearpracticeestablished = source.yearpracticeestablished,
                        target.zipcode = source.zipcode
                      $$;


--- insert Statement
insert_statement :=   $$
                      insert  (
                                AddressCode,
                                AddressID,
                                AddressLine1,
                                AddressLine2,
                                AddressLine3,
                                AddressLine4,
                                AddressTypeCode,
                                AverageDailyPatientVolume,
                                City,
                                County,
                                FullFax,
                                FullPhone,
                                HasBillingStaff,
                                HasHandicapAccess,
                                HasLabServicesOnSite,
                                HasPharmacyOnSite,
                                HasSurgeryOnSite,
                                HasXrayOnSite,
                                IsDerived,
                                IsPrimaryOffice,
                                IsSurgeryCenter,
                                Latitude,
                                LegacyKeyOffice,
                                LegacyKeyPractice,
                                Longitude,
                                Nation,
                                OfficeCode,
                                OfficeCoordinatorName,
                                OfficeID,
                                OfficeName,
                                OfficeToAddressID,
                                ParkingInformation,
                                PaymentPolicy,
                                PhysicianCount,
                                PracticeCode,
                                PracticeDescription,
                                PracticeEmail,
                                PracticeID,
                                PracticeLogo,
                                PracticeMedicalDirector,
                                PracticeName,
                                PracticeNPI,
                                PracticeSoftware,
                                PracticeTIN,
                                PracticeWebsite,
                                ProviderID,
                                ProviderOfficeRank,
                                ProviderToOfficeID,
                                State,
                                YearPracticeEstablished,
                                ZipCode
                               )
                      values  (
                                source.addresscode,
                                source.addressid,
                                source.addressline1,
                                source.addressline2,
                                source.addressline3,
                                source.addressline4,
                                source.addresstypecode,
                                source.averagedailypatientvolume,
                                source.city,
                                source.county,
                                source.fullfax,
                                source.fullphone,
                                source.hasbillingstaff,
                                source.hashandicapaccess,
                                source.haslabservicesonsite,
                                source.haspharmacyonsite,
                                source.hassurgeryonsite,
                                source.hasxrayonsite,
                                source.isderived,
                                source.isprimaryoffice,
                                source.issurgerycenter,
                                source.latitude,
                                source.legacykeyoffice,
                                source.legacykeypractice,
                                source.longitude,
                                source.nation,
                                source.officecode,
                                source.officecoordinatorname,
                                source.officeid,
                                source.officename,
                                source.officetoaddressid,
                                source.parkinginformation,
                                source.paymentpolicy,
                                source.physiciancount,
                                source.practicecode,
                                source.practicedescription,
                                source.practiceemail,
                                source.practiceid,
                                source.practicelogo,
                                source.practicemedicaldirector,
                                source.practicename,
                                source.practicenpi,
                                source.practicesoftware,
                                source.practicetin,
                                source.practicewebsite,
                                source.providerid,
                                source.providerofficerank,
                                source.providertoofficeid,
                                source.state,
                                source.yearpracticeestablished,
                                source.zipcode
                               )
                       $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement :=  $$
                    merge into mid.providerpracticeoffice as target using ($$|| select_statement ||$$) as source 
                    on source.providerid = target.providerid
                    WHEN MATCHED and source.actioncode = 2 then $$|| update_statement ||$$
                    when not matched and source.actioncode = 1 then $$ || insert_statement;

                
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
