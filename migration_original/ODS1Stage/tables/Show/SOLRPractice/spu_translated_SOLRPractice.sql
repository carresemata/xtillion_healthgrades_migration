CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRPRACTICE()
RETURNS varchar(16777216)
LANGUAGE SQL
EXECUTE as CALLER
as 'declare 

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
    merge_statement_4 string;
    status string; -- status monitoring
    procedure_name varchar(50) default(''sp_load_solrpractice'');
    execution_start datetime default getdate();

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin
--- select Statement

select_statement := $$ with cte_practice_batch as (
                    select distinct 
                        BasePrac.PracticeID, 
                        BasePrac.PracticeCode
                    from MDM_TEAM.MST.Provider_Profile_Processing as ppp
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
                        ),
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
                        cte_specialty as (
                            select
                                OfficeID,
                                SpecialtyCode as spCd,
                                Specialty as spY,
                                Specialist as spIst,
                                Specialists as spIsts,
                                LegacyKey as lKey
                            from
                                Mid.OfficeSpecialty
                            group by
                                OfficeID,
                                SpecialtyCode,
                                Specialty,
                                Specialist,
                                Specialists,
                                LegacyKey
                        ),
                        cte_hours as (
                            select
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
                            group by
                                p.OfficeID,
                                dow.DaysOfWeekDescription,
                                dow.SortOrder,
                                oh.OfficeHoursOpeningTime,
                                oh.OfficeHoursClosingTime,
                                oh.OfficeIsClosed,
                                oh.OfficeIsOpen24Hours
                        ),
                        cte_sponsor_stg as (
                            select
                                ps.PracticeID,
                                mp.OfficeID,
                            from
                                Mid.PracticeSponsorship as ps
                                join cte_practice_batch as pb on pb.PracticeID = ps.PracticeID
                                join Mid.Practice as mp on ps.PracticeID = mp.PracticeID
                                join Base.Product as bp on ps.ProductCode = bp.ProductCode
                            where
                                ps.ProductGroupCode = ''PDC''
                                and bp.ProductTypeCode = ''Practice''
                            group by
                                ps.PracticeID,
                                mp.officeid
                        ),
                        cte_phoneL as (
                            select
                                mp.OfficeID,
                                fa.DesignatedProviderPhone as ph,
                                fa.PhoneTypeCode as phTyp
                            from
                                Base.vwuPDCPracticeOfficeDetail as fa
                                join cte_sponsor_stg as mp on mp.OfficeID = fa.OfficeID
                            where
                                fa.PhoneTypeCode IN (''PTOOS'', ''PTOOSM'') -- PDC Designated - Office Specific
                            group by
                                mp.OfficeID,
                                fa.DesignatedProviderPhone,
                                fa.PhoneTypeCode
                        ),
                        
                         cte_phoneL_xml as (
                            select
                                OfficeID,
                                utils.p_json_to_xml(
                                    array_agg(
                        ''{ '' ||
                        iff(ph is not null, ''"ph":'' || ''"'' || ph || ''"'' || '','', '''') ||
                        iff(phTyp is not null, ''"phTyp":'' || ''"'' || phTyp || ''"'', '''')
                        ||'' }''
                                    )::varchar,
                                    '''',
                                    ''phone''
                                ) as phoneL
                            from
                                cte_phoneL
                            where
                                phTyp = ''PTOOS''
                            group by
                                OfficeID
                        )
                        ,
                        
                        cte_mobile_phoneL_xml as (
                            select
                                OfficeID,
                                utils.p_json_to_xml(
                                    array_agg(
                                        ''{ '' ||
                                        iff(ph is not null, ''"ph":'' || ''"'' || ph || ''"'' || '','', '''') ||
                                        iff(phTyp is not null, ''"phTyp":'' || ''"'' || phTyp || ''"'', '''')
                                        ||'' }''
                                    )::varchar,
                                    '''',
                                    ''mobilePhone''
                                ) as mobilePhoneL
                            from
                                cte_phoneL
                            where
                                phTyp = ''PTOOSM''
                            group by
                                OfficeID
                        ),
                        cte_imageL as (
                            select
                                mp.OfficeID,
                                fa.ImageFilePath as img,
                                fa.ImageTypeCode as imgTyp
                            from
                                Base.vwuPDCPracticeOfficeDetail as fa
                                join cte_sponsor_stg as mp on mp.OfficeID = fa.OfficeID
                            where
                                fa.ImageTypeCode in (''FCOLOGO'', ''FCOWALL'') -- PDC Designated - Office Specific
                            group by
                                mp.OfficeID,
                                fa.ImageFilePath,
                                fa.ImageTypeCode
                        ),
                        cte_imageL_xml as (
                            select
                                OfficeID,
                                utils.p_json_to_xml(
                                    array_agg(
                                        ''{ '' ||
                                        iff(img is not null, ''"img":'' || ''"'' || img || ''"'' || '','', '''') ||
                                        iff(imgTyp is not null, ''"imgTyp":'' || ''"'' || imgTyp || ''"'', '''')
                                        ||'' }''
                                    )::varchar,
                                    '''',
                                    ''image''
                                ) as imageL
                            from
                                cte_imageL
                            group by
                                OfficeID
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
                        ),
                        cte_practice_sponsorship as (
                            select
                                ps.ProductCode as prCd,
                                ps.ProductGroupCode as prGrCd,
                                ps.ClientCode as spnCd,
                                ps.ClientName as spnNm,
                                ps.PracticeId
                            from
                                Mid.PracticeSponsorship as ps
                                join cte_practice_batch as pb on pb.PracticeID = ps.PracticeID
                        ),
                        cte_practice_sponsorship_xml as (
                            select
                                PracticeID,
                                utils.p_json_to_xml(
                                    array_agg(
                                        ''{ '' ||
                                        iff(prCd is not null, ''"prCd":'' || ''"'' || prCd || ''"'' || '','', '''') ||
                                        iff(prGrCd is not null, ''"prGrCd":'' || ''"'' || prGrCd || ''"'' || '','', '''') ||
                                        iff(spnCd is not null, ''"spnCd":'' || ''"'' || spnCd || ''"'' || '','', '''') ||
                                        iff(spnNm is not null, ''"spnNm":'' || ''"'' || spnNm || ''"'', '''')
                                        ||'' }''
                                    )::varchar
                                    ,
                                    ''sponsorL'',
                                    ''sponsor''
                                ) as SponsorshipXML
                            from
                                cte_practice_sponsorship
                            group by
                                PracticeID
                        )
                        ,
                        cte_email as (
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
                        ),
                        cte_email_xml as (
                            select
                                PracticeID,
                                utils.p_json_to_xml(
                                    array_agg(
                                        ''{ '' ||
                                        iff(pEmail is not null, ''"pEmail":'' || ''"'' || pEmail || ''"'', '''')
                                        ||'' }''
                                    )::varchar,
                                    ''pEmailL'',
                                    ''''
                                ) as PracticeEmailXML
                            from
                                cte_email
                            group by
                                PracticeID
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
                                join Show.vwuProviderIndex as vpi on po.ProviderID = vpi.ProviderID
                        )
                        ,
                        cte_hours_xml as (
                            select
                                OfficeID,
                                utils.p_json_to_xml(
                                    array_agg(
                                        ''{ '' ||
                                        iff("day" is not null, ''"day":'' || ''"'' || "day" || ''"'' || '','', '''') ||
                                        iff(dispOrder is not null, ''"dispOrder":'' || ''"'' || dispOrder || ''"'' || '','', '''') ||
                                        iff("start" is not null, ''"start":'' || ''"'' || "start" || ''"'' || '','', '''') ||
                                        iff("end" is not null, ''"end":'' || ''"'' || "end" || ''"'' || '','', '''') ||
                                        iff("closed" is not null, ''"closed":'' || ''"'' || "closed" || ''"'' || '','', '''') ||
                                        iff("open24Hrs" is not null, ''"open24Hrs":'' || ''"'' || "open24Hrs" || ''"'', '''')
                                        ||'' }''
                                    )::varchar
                                    ,
                                    ''hoursL'',
                                    ''hours''
                                ) as hours_xml
                            from
                                cte_hours
                            group by
                                OfficeID
                        )
                        ,
                        cte_phone_xml as (
                            select
                                OfficeID,
                                utils.p_json_to_xml(
                                    array_agg(
                                        ''{ '' ||
                                        iff(phFull is not null, ''"phFull":'' || ''"'' || phFull || ''"'', '''')
                                        ||'' }''
                                    )::varchar,
                                    ''phL'',
                                    ''''
                                ) as phone_xml
                            from
                                cte_phone
                            group by
                                OfficeID
                        )
                        ,
                        
                        cte_fax_xml as (
                            select
                                OfficeID,
                                utils.p_json_to_xml(
                                    array_agg(
                                        ''{ '' ||
                                        iff(faxFull is not null, ''"faxFull":'' || ''"'' || faxFull || ''"'', '''')
                                        ||'' }''
                                    )::varchar,
                                    ''faxL'',
                                    ''''
                                ) as fax_xml
                            from
                                cte_fax
                            group by
                                OfficeID
                        )
                        ,
                        
                        cte_specialty_xml as (
                            select
                                OfficeID,
                                utils.p_json_to_xml(
                                    array_agg(
                                        ''{ '' ||
                                        iff(spCd is not null, ''"spCd":'' || ''"'' || spCd || ''"'' || '','', '''') ||
                                        iff(spY is not null, ''"spY":'' || ''"'' || spY || ''"'' || '','', '''') ||
                                        iff(spIst is not null, ''"spIst":'' || ''"'' || spIst || ''"'' || '','', '''') ||
                                        iff(spIsts is not null, ''"spIsts":'' || ''"'' || spIsts || ''"'' || '','', '''') ||
                                        iff(lKey is not null, ''"lKey":'' || ''"'' || lKey || ''"'', '''')
                                        ||'' }''
                                    )::varchar,
                                    ''spcL'',
                                    ''spc''
                                ) as specialty_xml
                            from
                                cte_specialty
                            group by
                                OfficeID
                        )
                        ,
                        
                        cte_sponsor_xml as (
                            select
                                OfficeID,
                                utils.p_json_to_xml(
                                    array_agg(
                                        ''{ '' ||
                                        iff(phoneL is not null, ''"phoneL":'' || ''"'' || phoneL || ''"'' || '','', '''') ||
                                        iff(mobilePhoneL is not null, ''"mobilePhoneL":'' || ''"'' || mobilePhoneL || ''"'' || '','', '''') ||
                                        iff(imageL is not null, ''"imageL":'' || ''"'' || imageL || ''"'', '''')
                                        ||'' }''
                                    )::varchar,
                                    ''dispL'',
                                    ''disp''
                                ) as sponsor
                            from
                                cte_sponsor
                            group by
                                OfficeID
                        )
                        ,
                        cte_office as (
                            select
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
                                mp.GoogleScriptBlock as GoogleScriptBlock
                            from
                                Mid.Practice mp
                                left join cte_hours_xml h on mp.OfficeID = h.OfficeID
                                left join cte_phone_xml p on mp.OfficeID = p.OfficeID
                                left join cte_fax_xml f on mp.OfficeID = f.OfficeID
                                left join cte_specialty_xml s on mp.OfficeID = s.OfficeID
                                left join cte_sponsor_xml sp on mp.OfficeID = sp.OfficeID
                                join Base.CityStatePostalCode b on mp.CityStatePostalCodeID = b.CityStatePostalCodeID
                                join Base.State c on c.state = b.state
                            group by
                                mp.OfficeID,
                                mp.OfficeCode,
                                OfficeName,
                                mp.OfficeRank,
                                mp.AddressTypeCode,
                                mp.AddressLine1,
                                mp.AddressLine2,
                                mp.AddressLine3,
                                mp.AddressLine4,
                                mp.City,
                                mp.State,
                                mp.ZipCode,
                                mp.Latitude,
                                mp.Longitude,
                                mp.HasBillingStaff,
                                mp.HasHandicapAccess,
                                mp.HasLabServicesOnSite,
                                mp.HasPharmacyOnSite,
                                mp.HasXrayOnSite,
                                mp.IsSurgeryCenter,
                                mp.HasSurgeryOnSite,
                                mp.AverageDailyPatientVolume,
                                mp.OfficeCoordinatorName,
                                mp.ParkingInformation,
                                mp.PaymentPolicy,
                                h.hours_xml,
                                p.phone_xml,
                                f.fax_xml,
                                s.specialty_xml,
                                sp.sponsor,
                                mp.LegacyKeyOffice,
                                mp.OfficeID,
                                c.StateName,
                                b.State,
                                b.City,
                                mp.PracticeName,
                                mp.OfficeUrl,
                                GoogleScriptBlock
                            order by
                                mp.AddressLine1,
                                mp.State
                        )
                        ,
                        cte_office_xml as (
                            select
                                OfficeID,
                                utils.p_json_to_xml(
                                    array_agg(
                                        REPLACE(
                                        ''{ ''||
                                            iff(oID is not null, ''"oID":'' || ''"'' || oID || ''"'' || '','', '''') ||
                                            iff(oNm is not null, ''"oNm":'' || ''"'' || replace(onm,''"'','''') || ''"'' || '','', '''') ||
                                            iff(oRank is not null, ''"oRank":'' || ''"'' || oRank || ''"'' || '','', '''') ||
                                            iff(addTp is not null, ''"addTp":'' || ''"'' || addTp || ''"'' || '','', '''') ||
                                            iff(ad1 is not null, ''"ad1":'' || ''"'' || ad1 || ''"'' || '','', '''') ||
                                            iff(ad2 is not null, ''"ad2":'' || ''"'' || ad2 || ''"'' || '','', '''') ||
                                            iff(ad3 is not null, ''"ad3":'' || ''"'' || ad3 || ''"'' || '','', '''') ||
                                            iff(ad4 is not null, ''"ad4":'' || ''"'' || ad4 || ''"'' || '','', '''') ||
                                            iff(city is not null, ''"city":'' || ''"'' || city || ''"'' || '','', '''') ||
                                            iff(st is not null, ''"st":'' || ''"'' || st || ''"'' || '','', '''') ||
                                            iff(zip is not null, ''"zip":'' || ''"'' || zip || ''"'' || '','', '''') ||
                                            iff(lat is not null, ''"lat":'' || ''"'' || lat || ''"'' || '','', '''') ||
                                            iff(lng is not null, ''"lng":'' || ''"'' || lng || ''"'' || '','', '''') ||
                                            iff(isBStf is not null, ''"isBStf":'' || ''"'' || isBStf || ''"'' || '','', '''') ||
                                            iff(isHcap is not null, ''"isHcap":'' || ''"'' || isHcap || ''"'' || '','', '''') ||
                                            iff(isLab is not null, ''"isLab":'' || ''"'' || isLab || ''"'' || '','', '''') ||
                                            iff(isPhrm is not null, ''"isPhrm":'' || ''"'' || isPhrm || ''"'' || '','', '''') ||
                                            iff(isXray is not null, ''"isXray":'' || ''"'' || isXray || ''"'' || '','', '''') ||
                                            iff(isSrg is not null, ''"isSrg":'' || ''"'' || isSrg || ''"'' || '','', '''') ||
                                            iff(hasSrg is not null, ''"hasSrg":'' || ''"'' || hasSrg || ''"'' || '','', '''') ||
                                            iff(avVol is not null, ''"avVol":'' || ''"'' || avVol || ''"'' || '','', '''') ||
                                            iff(ocNm is not null, ''"ocNm":'' || ''"'' || ocNm || ''"'' || '','', '''') ||
                                            iff(prkInf is not null, ''"prkInf":'' || ''"'' || prkInf || ''"'' || '','', '''') ||
                                            iff(payPol is not null, ''"payPol":'' || ''"'' || payPol || ''"'' || '','', '''') ||
                                            iff(hours is not null, ''"hours":'' || ''"'' || hours || ''"'' || '','', '''') ||
                                            iff(phone is not null, ''"phone":'' || ''"'' || phone || ''"'' || '','', '''') ||
                                            iff(fax is not null, ''"fax":'' || ''"'' || fax || ''"'' || '','', '''') ||
                                            iff(specialty is not null, ''"specialty":'' || ''"'' || specialty || ''"'' || '','', '''') ||
                                            iff(sponsor is not null, ''"sponsor":'' || ''"'' || sponsor || ''"'' || '','', '''') ||
                                            iff(oLegacyID is not null, ''"oLegacyID":'' || ''"'' || oLegacyID || ''"'' || '','', '''') ||
                                            iff(oLegacyID2 is not null, ''"oLegacyID2":'' || ''"'' || oLegacyID2 || ''"'' || '','', '''') ||
                                            iff(oRank2 is not null, ''"oRank2":'' || ''"'' || oRank2 || ''"'' || '','', '''') ||
                                            iff(PracticeURL is not null, ''"PracticeURL":'' || ''"'' || PracticeURL || ''"'' || '','', '''') ||
                                            iff(GoogleScriptBlock is not null, ''"GoogleScriptBlock":'' || ''"'' || GoogleScriptBlock || ''"'', '''')
                                            ||'' }''
                                    ,''\\'''',''\\\\\\'''')
                                    )::varchar
                                    ,
                                    '''',
                                    ''''
                                 ) as OfficeXML
                            from
                                cte_office
                            group by
                                OfficeID
                        )
                        
                        select
                            p.PracticeID,
                            p.PracticeCode,
                            p.PracticeName,
                            p.YearPracticeEstablished,
                            p.NPI,
                            TO_VARIANT(e.PracticeEmailXML) as PracticeEmailXML,
                            p.PracticeWebsite,
                            p.PracticeDescription,
                            p.PracticeLogo,
                            p.PracticeMedicalDirector,
                            p.PracticeSoftware,
                            p.PracticeTIN,
                            TO_VARIANT(
                                utils.p_json_to_xml(
                                    array_agg(
                                        REPLACE(
                                            ''{ ''||
                                            iff(OfficeXML is not null, ''"xml_1":'' || ''"'' || OfficeXML || ''"'', '''')
                                            ||'' }''
                                            ,''\\'''',''\\\\\\'''')
                                            )::varchar
                                            , 
                                            ''offL'', 
                                            ''off'')) 
                                            as OfficeXML,
                            p.LegacyKeyPractice,
                            p.PhysicianCount,
                            current_timestamp() as UpdatedDate,
                            CURRENT_USER() as UpdatedSource,
                            p.HasDentist,
                            TO_VARIANT(s.SponsorshipXML) as SponsorshipXML
                        from
                            cte_practice_source as p
                            left join cte_office_xml as o on p.OfficeID = o.OfficeID
                            left join cte_practice_sponsorship_xml as s on p.PracticeID = s.PracticeID
                            left join cte_email_xml as e on p.PracticeID = e.PracticeID
                        where officexml is not null
                        group by
                            p.PracticeID,
                            p.PracticeCode,
                            p.PracticeName,
                            p.YearPracticeEstablished,
                            p.NPI,
                            TO_VARIANT(e.PracticeEmailXML),
                            p.PracticeWebsite,
                            p.PracticeDescription,
                            p.PracticeLogo,
                            p.PracticeMedicalDirector,
                            p.PracticeSoftware,
                            p.PracticeTIN,
                            p.LegacyKeyPractice,
                            p.PhysicianCount,
                            p.HasDentist,
                            TO_VARIANT(s.SponsorshipXML) 
                    
                    $$;

--- update Statement
update_statement := ''update
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
                            target.UpdatedSource = source.UpdatedSource'';

--- insert Statement
insert_statement := ''insert
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
                            source.UpdatedSource);'';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement_1 := '' merge into Show.SOLRPractice as target using 
                   (''||select_statement||'') as source 
                   on source.PracticeID = target.PracticeID
                   WHEN MATCHED then ''||update_statement|| ''
                   when not matched then ''||insert_statement;

                 
-- -- Nullify the SPONSORSHIPXML column for practices with client contracts set to start in the future
merge_statement_2 := ''merge into Show.SOLRPractice as target 
                    using (
                        select SP.PRACTICEID
                        from SHOW.SOLRPRACTICE SP
                        join MID.PRACTICESPONSORSHIP PS on PS.PRACTICEID = SP.PRACTICEID
                        join BASE.CLIENT C on PS.CLIENTCODE = C.CLIENTCODE
                        join SHOW.CLIENTCONTRACT CC on C.CLIENTID = CC.CLIENTID
                        where CC.CONTRACTSTARTDATE > current_timestamp()
                    ) as source 
                    on source.PRACTICEID = target.PRACTICEID
                    WHEN MATCHED then 
                        update SET SPONSORSHIPXML = null'';

-- -- Nullify the SPONSORSHIPXML column for practices with client contracts set to end in the past
merge_statement_3 := ''merge into Show.SOLRPRACTICE as target 
                        using (select 
                                PRACTICEID, 
                                CONCAT(''''HGPPZ'''', SUBSTRING(REPLACE(PRACTICEID,''''-'''',''''''''), 1, 16)) as NEWLEGACYKEYPRACTICE
                            from SHOW.SOLRPRACTICE
                            where NEWLEGACYKEYPRACTICE is null
                        ) as source 
                        on source.PRACTICEID = target.PRACTICEID
                        WHEN MATCHED then 
                            update SET LEGACYKEYPRACTICE = source.NEWLEGACYKEYPRACTICE'';

-- -- Remove practices with no providers and where PracticeName = Practice
merge_statement_4 := ''merge into Show.solrpractice as target 
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
                    WHEN MATCHED then delete '';


---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
execute immediate merge_statement_1 ;
execute immediate merge_statement_2 ;
execute immediate merge_statement_3 ;
execute immediate merge_statement_4 ;

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
--------------------------------------------------------- 

status := ''Completed successfully'';
    return status;


        
exception
    WHEN other then
          status := ''Failed during execution. '' || ''SQL Error: '' || SQLERRM || '' Error code: '' || SQLCODE || ''. SQL State: '' || SQLSTATE;
          return status;


    
END';