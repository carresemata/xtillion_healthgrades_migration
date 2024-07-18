CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDERPRACTICEOFFICE(is_full BOOLEAN)
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
    update_statement_2 string;
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providerpracticeoffice');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin
select_statement := $$ 
                with CTE_ProviderBatch as (
                            select p.providerid
                            from $$ || mdm_db || $$.mst.Provider_Profile_Processing as ppp
                            join base.provider as p on ppp.ref_provider_code = p.providercode
                    ),

                -- ***** does return rows because now we only have 'MAIN' and 'FAX' Numbers instead of 'MAIN' and 'Service' *****
                CTE_MainNumbers as (
                    select 
                        o.phonenumber, 
                        otp.officeid, 
                        row_number() over(partition by otp.officeid order by otp.phonerank, otp.lastupdatedate desc, o.lastupdatedate, otp.phoneid) as SequenceId1   
                    from base.officetophone otp
                    join base.phone o on otp.phoneid = o.phoneid
                    where otp.phonetypeid = (select PhoneTypeID from base.phonetype where PhoneTypeCode = 'MAIN') 
                ),
                
                -- ***** returns 0 rows because we don't have 'Service' PhoneTypeCodes in Snowflake MDM (we only have 'MAIN' and 'FAX') *****
                CTE_ServiceNumbers as (
                    select 
                        o.phonenumber, 
                        otp.officeid, 
                        row_number() over(partition by otp.officeid order by otp.phonerank, otp.lastupdatedate desc, o.lastupdatedate, otp.phoneid) as SequenceId1   
                    from base.officetophone otp
                    join base.phone o on otp.phoneid = o.phoneid
                    where otp.phonetypeid = (select PhoneTypeID from base.phonetype where PhoneTypeCode = 'Service')
                ),
                
                
                CTE_FaxNumbers as (
                    select o.phonenumber, pto.officeid, row_number() over(partition by pto.officeid order by pto.phonerank, pto.lastupdatedate desc, o.lastupdatedate, pto.phoneid) as SequenceId1
                    from base.officetophone pto
                    join base.phone o on (pto.phoneid = o.phoneid)
                    where pto.phonetypeid = (select PhoneTypeID from base.phonetype where PhoneTypeCode = 'FAX') 
                ),
                
                CTE_ProviderOfficeRank as (
                    select ProviderID, MIN(ProviderOfficeRank) as ProviderOfficeRank
                    from base.providertooffice
                    where ProviderOfficeRank is not null
                    group by ProviderID
                ),
                
                -- this has 0 rows in SQL server as well
                CTE_PracticeEmails as (
                    select PracticeID, EmailAddress, row_number() over (partition by PracticeID order by LEN(EmailAddress)) as EmailRank
                    from base.practiceemail
                    where EmailAddress is not null
                )
                select 
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
                        cte_mn.phonenumber as FullPhone,
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
                        p.legacykey as LegacyKeyPractice
                    from CTE_ProviderBatch pb 
                        inner join base.providertooffice as pto on pb.providerid = pto.providerid
                        inner join base.office as o on o.officeid = pto.officeid
                        inner join base.officetoaddress as ota on o.officeid = ota.officeid
                        inner join base.address as a on a.addressid = ota.addressid	
                        left join CTE_MainNumbers as cte_mn on cte_mn.officeid = o.officeid and cte_mn.sequenceid1 = 1
                        left join CTE_ServiceNumbers as cte_sn on cte_sn.officeid = o.officeid and cte_sn.sequenceid1 = 1
                        left join CTE_FaxNumbers as cte_fn on cte_fn.officeid = o.officeid and cte_fn.sequenceid1 = 1
                        left join base.citystatepostalcode as cspc on a.citystatepostalcodeid = cspc.citystatepostalcodeid
                        left join base.nation as n on cspc.nationid = n.nationid
                        left join base.practice as p on o.practiceid = p.practiceid
                        left join CTE_ProviderOfficeRank as cte_por on pto.providerid = cte_por.providerid and pto.providerofficerank = cte_por.providerofficerank
                        left join CTE_PracticeEmails cte_pe on cte_pe.practiceid = o.practiceid and cte_pe.emailrank = 1
                    qualify row_number() over(partition by pto.providertoofficeid order by pto.lastupdatedate desc) = 1
                $$;
                        


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------

update_statement := $$ update 
                        SET 
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
                      insert  ( AddressCode,
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
                    on source.providertoofficeid = target.providertoofficeid
                    when matched then $$|| update_statement ||$$
                    when not matched then $$ || insert_statement;

update_statement_2 := $$ UPDATE mid.providerpracticeoffice as target 
                            SET target.physiciancount = source.physiciancount
                            FROM (select PracticeID, COUNT(*) as PhysicianCount
                        					from
                        						(select distinct ProviderID, PracticeID
                        							from mid.ProviderPracticeOffice
                        							where PracticeID is not null
                        						)a	
                        					group by PracticeID	) as source
                            WHERE target.practiceid = source.practiceid $$;                    

                
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.ProviderPracticeOffice;
end if; 
execute immediate merge_statement;
execute immediate update_statement_2;

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

            raise;
end;