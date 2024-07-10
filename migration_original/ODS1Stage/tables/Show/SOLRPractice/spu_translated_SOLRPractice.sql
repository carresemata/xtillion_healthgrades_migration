CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRPRACTICE(is_full BOOLEAN)
RETURNS varchar(16777216)
LANGUAGE SQL
EXECUTE as CALLER
as declare 

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- show.solrpractice depends on: 
--- mdm_team.mst.provider_profile_processing 
--- base.practice
--- base.office
--- base.client
--- base.providertooffice
--- mid.practicesponsorship
--- show.clientcontract
--- mid.practice
--- mid.officespecialty
--- base.officehours
--- base.daysofweek
--- base.citystatepostalcode
--- base.state
--- base.product
--- base.practiceemail
--- base.provider
--- base.clientproducttoentity (base.vwupdcpracticeofficedetail)
--- base.clienttoproduct (base.vwupdcpracticeofficedetail)
--- base.entitytype (base.vwupdcpracticeofficedetail)
--- base.clientproductentitytoimage (base.vwupdcpracticeofficedetail)
--- base.imagetype (base.vwupdcpracticeofficedetail)
--- base.image (base.vwupdcpracticeofficedetail)
--- base.officetoaddress (base.vwupdcpracticeofficedetail)
--- base.address (base.vwupdcpracticeofficedetail)
--- base.clientproductentitytophone (base.vwuclientproductentitytophone)
--- base.phonetype (base.vwuclientproductentitytophone)
--- base.phone (base.vwuclientproductentitytophone)
--- show.solrprovider (show.vwuproviderindex )
--- show.consolidatedproviders (show.vwuproviderindex )
--- show.delayclient (show.vwuproviderindex )

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement_1 string; -- merge statement to final table
    merge_statement_2 string;
    merge_statement_3 string;
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrpractice');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin

select_statement := $$ with cte_practice_batch as (
                        select distinct 
                            BasePrac.PracticeID, 
                            BasePrac.PracticeCode
                        from $$ || mdm_db || $$.MST.Provider_Profile_Processing as ppp
                            join Base.Provider as P on p.providercode = ppp.ref_provider_code
                            inner join base.ProviderToOffice PTO on p.ProviderID = PTO.ProviderID
                            inner join base.Office Off on PTO.OfficeID = Off.OfficeID
                            inner join Base.Practice as BasePrac on BasePrac.PracticeID = Off.PracticeID
                        order by BasePrac.PracticeID
                        ),
                        cte_phone as (
                            select
                                p.OfficeID,
                                p.FullPhone as phFull
                            from
                                Mid.Practice as p
                                join cte_practice_batch as pb on p.PracticeID = pb.PracticeID
                            where
                                p.FullPhone is not null
                            group by
                                p.OfficeID,
                                p.FullPhone
                        ) ,
                        cte_fax as (
                            select
                                p.officeid,
                                p.FullFax as faxFull
                            from
                                Mid.Practice as p
                                join cte_practice_batch as pb on p.PracticeID = pb.PracticeID
                            where
                                p.FullFax is not null
                            group by
                                p.officeid,
                                p.FullFax
                        ) 
                        ,
                        cte_specialty as ( -- this is empty because Mid.OfficeSpecialty is empty in sql server
                            select distinct
                                OfficeID,
                                SpecialtyCode as spCd,
                                Specialty as spY,
                                Specialist as spIst,
                                Specialists as spIsts,
                                LegacyKey as lKey
                            from
                                Mid.OfficeSpecialty
                        ),
                        cte_hours as (
                            select distinct
                                p.OfficeID,
                                dow.DaysOfWeekDescription as "day",
                                dow.SortOrder as dispOrder,
                                oh.OfficeHoursOpeningTime as "start",
                                oh.OfficeHoursClosingTime as "end",
                                oh.OfficeIsClosed as "closed",
                                oh.OfficeIsOpen24Hours as "open24Hrs"
                            from
                                Mid.Practice as p
                                join cte_practice_batch as pb on p.PracticeID = pb.PracticeID
                                join Base.OfficeHours as oh on oh.OfficeID = p.OfficeID
                                join Base.DaysOfWeek as dow on dow.DaysOfWeekID = oh.DaysOfWeekID
                        ) ,
                        
                        cte_sponsor_stg as (
                            select distinct
                                ps.PracticeID,
                                mp.OfficeID,
                                bp.producttypecode
                            from
                                Mid.PracticeSponsorship as ps
                                join cte_practice_batch as pb on pb.PracticeID = ps.PracticeID
                                join Mid.Practice as mp on ps.PracticeID = mp.PracticeID
                                join Base.Product as bp on ps.ProductCode = bp.ProductCode
                            where
                                ps.ProductGroupCode = 'PDC'
                                and bp.ProductTypeCode = 'Practice' 
                        ) ,
                        cte_phoneL as (
                            select distinct
                                mp.OfficeID,
                                fa.DesignatedProviderPhone as ph,
                                fa.PhoneTypeCode as phTyp
                            from
                                Base.vwuPDCPracticeOfficeDetail as fa
                                join cte_sponsor_stg as mp on mp.OfficeID = fa.OfficeID
                            where
                                fa.PhoneTypeCode IN ('PTOOS', 'PTOOSM') -- PDC Designated - Office Specific
                        ) 
                        ,
                        
                         cte_phoneL_xml as (
                            select distinct
                                OfficeID,
                                iff(ph is not null,'<ph>' || ph || '</ph>','') ||
                                iff(phTyp is not null,'<phTyp>' || phTyp || '</phTyp>','') as phoneL
                            from
                                cte_phoneL
                            where
                                phTyp = 'PTOOS'
                        )
                        ,
                        
                        cte_mobile_phoneL_xml as (
                            select distinct
                                OfficeID,
                                iff(ph is not null,'<ph>' || ph || '</ph>','') ||
                                iff(phTyp is not null,'<phTyp>' || phTyp || '</phTyp>','') as mobilePhoneL
                            from
                                cte_phoneL
                            where
                                phTyp = 'PTOOSM'
                        ),

                        cte_imageL as (
                            select distinct
                                mp.OfficeID,
                                fa.ImageFilePath as img,
                                fa.ImageTypeCode as imgTyp
                            from
                                Base.vwuPDCPracticeOfficeDetail as fa
                                join cte_sponsor_stg as mp on mp.OfficeID = fa.OfficeID
                            where
                                fa.ImageTypeCode in ('FCOLOGO', 'FCOWALL') -- PDC Designated - Office Specific
                        ) 
                        ,
                        cte_imageL_xml as (
                            select distinct
                                OfficeID,
                                iff(img is not null,'<img>' || img || '</img>','') ||
                                iff(imgTyp is not null,'<imgTyp>' || imgTyp || '</imgTyp>','') as imageL
                            from
                                cte_imageL
                        )
                        ,
                        cte_sponsor as (
                            select
                                s.OfficeID,
                                p.phoneL,
                                mp.mobilePhoneL,
                                i.imageL
                            from
                                cte_sponsor_stg as s
                                left join cte_phoneL_xml as p on s.OfficeID = p.OfficeID
                                left join cte_mobile_phoneL_xml as mp on s.OfficeID = mp.OfficeID
                                left join cte_imageL_xml as i on s.OfficeID = i.OfficeID
                        ) ,
                        cte_practice_sponsorship as (
                            select distinct
                                ps.ProductCode as prCd,
                                ps.ProductGroupCode as prGrCd,
                                ps.ClientCode as spnCd,
                                ps.ClientName as spnNm,
                                ps.PracticeId
                            from
                                Mid.PracticeSponsorship as ps
                                join cte_practice_batch as pb on pb.PracticeID = ps.PracticeID
                            where ProductCode != 'PDCWMDLITE' and ProductCode != 'PDCWRITEMD' -- these are not practice codes
                                
                        ),
                        cte_practice_sponsorship_xml as (
                            select 
                                PracticeID,
                                '<sponsorL>' || listagg( '<sponsor>' || iff(prCd is not null,'<prCd>' || prCd || '</prCd>','') ||
                                iff(prGrCd is not null,'<prGrCd>' || prGrCd || '</prGrCd>','') ||
                                iff(spnCd is not null,'<spnCd>' || spnCd || '</spnCd>','') ||
                                iff(spnNm is not null,'<spnNm>' || spnNm || '</spnNm>','') || '</sponsor>' , '' ) || '</sponsorL>' as SponsorshipXML
                            from
                                cte_practice_sponsorship
                            group by
                                practiceid
                        ) 
                        ,
                        cte_email as ( -- this is empty because base.practiceemail is empty
                            select
                                pe.EmailAddress as pEmail,
                                pe.PracticeID
                            from
                                Base.PracticeEmail pe
                                join cte_practice_batch as pb on pb.PracticeID = pe.PracticeID
                            where
                                pe.EmailAddress is not null
                            group by
                                pe.EmailAddress,
                                pe.PracticeID
                        ) ,
                        cte_email_xml as (
                            select distinct
                                PracticeID,
                                iff(pEmail is not null,'<pEmail>' || pEmail || '</pEmail>','') as PracticeEmailXML
                            from
                                cte_email
                        ),
                        cte_practice_source as (
                            select
                                p.PracticeID,
                                p.OfficeId,
                                p.PracticeCode,
                                p.PracticeName,
                                p.YearPracticeEstablished,
                                p.NPI,
                                p.PracticeWebsite,
                                p.PracticeDescription,
                                p.PracticeLogo,
                                p.PracticeMedicalDirector,
                                p.PracticeSoftware,
                                p.PracticeTIN,
                                p.LegacyKeyPractice,
                                p.PhysicianCount,
                                p.HasDentist
                            from
                                Mid.Practice as p
                                join cte_practice_batch as pb on p.PracticeID = pb.PracticeID
                                join Base.Office as o on p.OfficeID = o.OfficeID
                                join Base.ProviderToOffice as po on o.OfficeID = po.OfficeID
                                -- join Show.vwuProviderIndex as vpi on po.ProviderID = vpi.ProviderID
                             qualify row_number() over(partition by o.practiceid order by o.lastupdatedate desc) = 1
                        ) 
                        ,
                        cte_hours_xml as (
                            select 
                                OfficeID,
                                listagg( '<hours>' || iff("day" is not null,'<day>' || "day" || '</day>','') ||
                                iff(dispOrder is not null,'<dispOrder>' || dispOrder || '</dispOrder>','') ||
                                iff("start" is not null,'<start>' || "start" || '</start>','') ||
                                iff("end" is not null,'<end>' || "end" || '</end>','') ||
                                iff("closed" is not null,'<closed>' || "closed" || '</closed>','') || '</hours>' , '') as hours_xml
                            from
                                cte_hours
                            group by
                                officeid
                        ) 
                        ,
                        cte_phone_xml as (
                            select distinct
                                OfficeID,
                                iff(phFull is not null,'<phFull>' || phFull || '</phFull>','') as phone_xml
                            from
                                cte_phone
                        )
                        ,
                        
                        cte_fax_xml as (
                            select distinct
                                OfficeID,
                                iff(faxFull is not null,'<faxFull>' || faxFull || '</faxFull>','') as fax_xml
                            from
                                cte_fax
                        )
                        ,
                        
                        cte_specialty_xml as (
                            select distinct
                                OfficeID,
                                iff(spCd is not null,'<spCd>' || spCd || '</spCd>','') ||
                                iff(spY is not null,'<spY>' || spY || '</spY>','') ||
                                iff(spIst is not null,'<spIst>' || spIst || '</spIst>','') ||
                                iff(spIsts is not null,'<spIsts>' || spIsts || '</spIsts>','') ||
                                iff(lKey is not null,'<lKey>' || lKey || '</lKey>','') as specialty_xml
                            from
                                cte_specialty
                        )
                        ,
                        
                        cte_sponsor_xml as (
                            select distinct
                                OfficeID,
                                iff(phoneL is not null,'<phoneL>' || phoneL || '</phoneL>','') ||
                                iff(mobilePhoneL is not null,'<mobilePhoneL>' || mobilePhoneL || '</mobilePhoneL>','') ||
                                iff(imageL is not null,'<imageL>' || imageL || '</imageL>','') as sponsor
                            from
                                cte_sponsor
                        )
                        ,
                        cte_office as (
                            select distinct
                                mp.OfficeID,
                                mp.OfficeCode as oID,
                                mp.OfficeName as oNm,
                                mp.OfficeRank as oRank,
                                mp.AddressTypeCode as addTp,
                                mp.AddressLine1 as ad1,
                                mp.AddressLine2 as ad2,
                                mp.AddressLine3 as ad3,
                                mp.AddressLine4 as ad4,
                                mp.City as city,
                                mp.State as st,
                                mp.ZipCode as zip,
                                mp.Latitude as lat,
                                mp.Longitude as lng,
                                mp.HasBillingStaff as isBStf,
                                mp.HasHandicapAccess isHcap,
                                mp.HasLabServicesOnSite as isLab,
                                mp.HasPharmacyOnSite as isPhrm,
                                mp.HasXrayOnSite isXray,
                                mp.IsSurgeryCenter as isSrg,
                                mp.HasSurgeryOnSite hasSrg,
                                mp.AverageDailyPatientVolume as avVol,
                                mp.OfficeCoordinatorName as ocNm,
                                mp.ParkingInformation as prkInf,
                                mp.PaymentPolicy as payPol,
                                h.hours_xml as hours,
                                p.phone_xml as phone,
                                f.fax_xml as fax,
                                s.specialty_xml as specialty,
                                sp.sponsor as sponsor,
                                mp.LegacyKeyOffice as oLegacyID,
                                SUBSTRING(mp.LegacyKeyOffice, 5, 8) as oLegacyID2,
                                mp.OfficeRank as oRank2,
                                mp.OfficeUrl as PracticeURL,
                                replace(mp.GoogleScriptBlock, '&', '&amp;') as GoogleScriptBlock
                            from
                                Mid.Practice mp
                                left join cte_hours_xml h on mp.OfficeID = h.OfficeID
                                left join cte_phone_xml p on mp.OfficeID = p.OfficeID
                                left join cte_fax_xml f on mp.OfficeID = f.OfficeID
                                left join cte_specialty_xml s on mp.OfficeID = s.OfficeID
                                left join cte_sponsor_xml sp on mp.OfficeID = sp.OfficeID
                                join Base.CityStatePostalCode b on mp.CityStatePostalCodeID = b.CityStatePostalCodeID
                                join Base.State c on c.state = b.state
                            order by
                                mp.AddressLine1,
                                mp.State
                        )
                        ,
                        cte_office_xml as (
                            select 
                                OfficeID,
                                '<offL>' || listagg( '<off>' || iff(oID is not null,'<oID>' || oID || '</oID>','') ||
                                iff(onm is not null,'<oNm>' || onm || '</oNm>','') ||
                                iff(oRank is not null,'<oRank>' || oRank || '</oRank>','') ||
                                iff(addTp is not null,'<addTp>' || addTp || '</addTp>','') ||
                                iff(city is not null,'<city>' || city || '</city>','') ||
                                iff(st is not null,'<st>' || st || '</st>','') ||
                                iff(zip is not null,'<zip>' || zip || '</zip>','') ||
                                iff(lat is not null,'<lat>' || lat || '</lat>','') ||
                                iff(lng is not null,'<lng>' || lng || '</lng>','') ||
                                iff(isBStf is not null,'<isBStf>' || isBStf || '</isBStf>','') ||
                                iff(isHcap is not null,'<isHcap>' || isHcap || '</isHcap>','') ||
                                iff(isLab is not null,'<isLab>' || isLab || '</isLab>','') ||
                                iff(isPhrm is not null,'<isPhrm>' || isPhrm || '</isPhrm>','') ||
                                iff(isXray is not null,'<isXray>' || isXray || '</isXray>','') ||
                                iff(isSrg is not null,'<isSrg>' || isSrg || '</isSrg>','') ||
                                iff(hasSrg is not null,'<hasSrg>' || hasSrg || '</hasSrg>','') ||
                                iff(avVol is not null,'<avVol>' || avVol || '</avVol>','') ||
                                iff(ocNm is not null,'<ocNm>' || ocNm || '</ocNm>','') ||
                                iff(prkInf is not null,'<prkInf>' || prkInf || '</prkInf>','') ||
                                iff(payPol is not null,'<payPol>' || payPol || '</payPol>','') ||
                                iff(hours is not null,'<hoursL>' || hours || '</hoursL>','') || 
                                iff(phone is not null,'<phL>' || phone || '</phL>','') ||
                                iff(fax is not null,'<faxL>' || fax || '</faxL>','') ||
                                iff(specialty is not null,'<specialty>' || specialty || '</specialty>','') ||
                                iff(sponsor is not null,'<sponsor>' || sponsor || '</sponsor>','') || -- this is always empty in sql server
                                iff(oLegacyID is not null,'<oLegacyID>' || oLegacyID || '</oLegacyID>','') ||
                                iff(PracticeURL is not null,'<PracticeURL>' || PracticeURL || '</PracticeURL>','') ||
                                iff(GoogleScriptBlock is not null,'<GoogleScriptBlock>' || GoogleScriptBlock || '</GoogleScriptBlock>','') || '</off>' , '') || '</offL>' as OfficeXML
                            from
                                cte_office
                            group by
                                officeid
                        ) 
                        
                        select distinct
                            p.PracticeID,
                            p.PracticeCode,
                            p.PracticeName,
                            p.YearPracticeEstablished,
                            p.NPI,
                            TO_VARIANT(parse_xml(e.PracticeEmailXML)) as PracticeEmailXML, -- this column is empty in sql server
                            p.PracticeWebsite,
                            p.PracticeDescription,
                            p.PracticeLogo,
                            p.PracticeMedicalDirector,
                            p.PracticeSoftware,
                            p.PracticeTIN,
                            TO_VARIANT(parse_xml(o.OfficeXml)) as OfficeXML,
                            CONCAT('HGPPZ', SUBSTRING(REPLACE(p.PRACTICEID,'-',''), 1, 16)) as LegacyKeyPractice,
                            p.PhysicianCount,
                            current_timestamp() as UpdatedDate,
                            CURRENT_USER() as UpdatedSource,
                            p.HasDentist,
                            TO_VARIANT(parse_Xml(s.SponsorshipXML)) as SponsorshipXML
                        from
                            cte_practice_source as p
                            join cte_office_xml as o on p.OfficeID = o.OfficeID
                            left join cte_practice_sponsorship_xml as s on p.PracticeID = s.PracticeID
                            left join cte_email_xml as e on p.PracticeID = e.PracticeID
                    
                    $$;

--- update Statement
update_statement := 'update
                        SET
                            target.PracticeCode = source.PracticeCode,
                            target.PracticeName = source.PracticeName,
                            target.YearPracticeEstablished = source.YearPracticeEstablished,
                            target.NPI = source.NPI,
                            target.PracticeEmailXML = source.PracticeEmailXML,
                            target.PracticeWebsite = source.PracticeWebsite,
                            target.PracticeDescription = source.PracticeDescription,
                            target.PracticeLogo = source.PracticeLogo,
                            target.PracticeMedicalDirector = source.PracticeMedicalDirector,
                            target.PracticeSoftware = source.PracticeSoftware,
                            target.PracticeTIN = source.PracticeTIN,
                            target.LegacyKeyPractice = source.LegacyKeyPractice,
                            target.PhysicianCount = source.PhysicianCount,
                            target.HasDentist = source.HasDentist,
                            target.OfficeXML = source.OfficeXML,
                            target.SponsorshipXML = source.SponsorshipXML,
                            target.UpdatedDate = source.UpdatedDate,
                            target.UpdatedSource = source.UpdatedSource';

--- insert Statement
insert_statement := 'insert
                            (PracticeID,
                            PracticeCode,
                            PracticeName,
                            YearPracticeEstablished,
                            NPI,
                            PracticeEmailXML,
                            PracticeWebsite,
                            PracticeDescription,
                            PracticeLogo,
                            PracticeMedicalDirector,
                            PracticeSoftware,
                            PracticeTIN,
                            LegacyKeyPractice,
                            PhysicianCount,
                            HasDentist,
                            OfficeXML,
                            SponsorshipXML,
                            UpdatedDate,
                            UpdatedSource)
                    values
                            (source.PracticeID,
                            source.PracticeCode,
                            source.PracticeName,
                            source.YearPracticeEstablished,
                            source.NPI,
                            source.PracticeEmailXML,
                            source.PracticeWebsite,
                            source.PracticeDescription,
                            source.PracticeLogo,
                            source.PracticeMedicalDirector,
                            source.PracticeSoftware,
                            source.PracticeTIN,
                            source.LegacyKeyPractice,
                            source.PhysicianCount,
                            source.HasDentist,
                            source.OfficeXML,
                            source.SponsorshipXML,
                            source.UpdatedDate,
                            source.UpdatedSource);';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement_1 := ' merge into Show.SOLRPractice as target using 
                   ('||select_statement||') as source 
                   on source.PracticeID = target.PracticeID
                   when matched then '||update_statement|| '
                   when not matched then '||insert_statement;

                 
-- -- Nullify the SPONSORSHIPXML column for practices with client contracts set to start in the future
merge_statement_2 := 'merge into Show.SOLRPractice as target 
                    using (
                        select SP.PRACTICEID
                        from SHOW.SOLRPRACTICE SP
                        join MID.PRACTICESPONSORSHIP PS on PS.PRACTICEID = SP.PRACTICEID
                        join BASE.CLIENT C on PS.CLIENTCODE = C.CLIENTCODE
                        join SHOW.CLIENTCONTRACT CC on C.CLIENTID = CC.CLIENTID
                        where CC.CONTRACTSTARTDATE > current_timestamp()
                    ) as source 
                    on source.PRACTICEID = target.PRACTICEID
                    when matched then 
                        update SET SPONSORSHIPXML = null';

-- -- Remove practices with no providers and where PracticeName = Practice
merge_statement_3 := 'merge into Show.solrpractice as target 
                    using ( select solrPrac.PracticeID 
                                                from Show.solrpractice solrPrac
                                                left join 
                                                ( select BasePrac.PracticeID 
                                                    from Base.providertooffice as BaseProvOff  
                                                    join Base.office as BaseOff on BaseOff.OfficeID = BaseProvOff.OfficeID 
                                                    join Base.practice as BasePrac on BasePrac.PracticeID = BaseOff.PracticeID 
                                                    join Show.solrprovider solrProv on BaseProvOff.ProviderID = solrProv.ProviderID 
                                                    group by BasePrac.PracticeID   
                                                ) subQuery on solrPrac.PracticeID = subQuery.PracticeID 
                                                where subQuery.PracticeID is null) as source
                    on target.PracticeID = source.PracticeID
                    WHEN MATCHED then delete ';


---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Show.SOLRPractice;
end if; 
execute immediate merge_statement_1 ;
execute immediate merge_statement_2 ;
execute immediate merge_statement_3 ;

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
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