CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.Mid.SP_LOAD_PROVIDER(IsProviderDeltaProcessing BOOLEAN)
RETURNS varchar(16777216)
LANGUAGE SQL
EXECUTE as CALLER
as 

declare
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------

--- mid.provider depends on:
-- mdm_team.mst.provider_profile_processing
-- base.provider
-- base.providertodegree
-- base.degree
-- base.providertoprovidertype
-- base.providertype
-- base.providertoprovidersubtype
-- base.providersubtype
-- base.providertodisplayspecialty
-- base.specialty

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------


create_temp string; 
insert_temp string; -- delta logic of insert to temporary table
join_temp_delta string;

-- updates to temporary version of mid.provider
update_temp_1 string;
update_temp_2 string;
update_temp_3 string;
update_temp_4 string;
update_temp_5 string;
update_temp_6 string;

-- changes to mid.provider from temp version
update_statement string;
insert_statement string;
select_statement string; 
merge_statement string;

status string;
    procedure_name varchar(50) default('sp_load_provider');
    execution_start datetime default getdate();



---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------  

begin
         create_temp := $$
                        CREATE or REPLACE TEMPORARY TABLE mid.tempprovider as
                        select * from  mid.provider LIMIT 0;
                        $$;
                        
         insert_temp := $$ 
                      insert INTO mid.tempprovider (
                          ProviderID,
                          ProviderCode,
                          ProviderTypeID,
                          FirstName,
                          MiddleName,
                          LastName,
                          CarePhilosophy,
                          ProfessionalInterest,
                          Suffix,
                          Gender,
                          NPI,
                          AMAID,
                          UPIN,
                          MedicareID,
                          DEANumber,
                          TaxIDNumber,
                          DateOfBirth,
                          PlaceOfBirth,
                          AcceptsNewPatients,
                          HasElectronicMedicalRecords,
                          HasElectronicPrescription,
                          LegacyKey,
                          ProviderLastUpdateDateOverall,
                          ProviderLastUpdateDateOverallSourceTable,
                          SearchBoostSatisfaction,
                          SearchBoostAccessibility
                      )
                      select
                        p.providerid,
                        p.providercode,
                        p.providertypeid,
                        p.firstname,
                        p.middlename,
                        p.lastname,
                        p.carephilosophy,
                        p.professionalinterest,
                        p.suffix,
                        p.gender,
                        p.npi,
                        p.amaid,
                        p.upin,
                        p.medicareid,
                        p.deanumber,
                        p.taxidnumber,
                        p.dateofbirth,
                        p.placeofbirth,
                        p.acceptsnewpatients,
                        p.haselectronicmedicalrecords,
                        p.haselectronicprescription,
                        p.legacykey,
                        ifnull(p.providerlastupdatedateoverall, p.lastupdatedate),
                        ifnull(p.providerlastupdatedateoverallsourcetable, p.lastupdatedate),
                        p.searchboostsatisfaction,
                        p.searchboostaccessibility
                       from (select * from base.provider) as p
                   $$;
                   
      if (IsProviderDeltaProcessing) then
        join_temp_delta := $$ inner join MDM_team.mst.Provider_Profile_Processing as ppp on p.providercode = ppp.ref_provider_code $$;
        insert_temp := insert_temp || join_temp_delta;
      else
        insert_temp := insert_temp;
      end if;

      ---------------------------------------------------------
      ----------------- 3. SQL Statements ---------------------
      ---------------------------------------------------------  
      select_statement := $$
                          (select * from mid.tempprovider)
                          $$;

      ---------------------------------------------------------
      --------- 4. actions (inserts and updates) --------------
      ---------------------------------------------------------

      update_temp_1 := $$ 
                      update mid.tempprovider p
                      SET p.degreeabbreviation = s.degreeabbreviation
                      from
                        (
                          select
                            ptd.providerid,
                            d.degreeabbreviation,
                            row_number() over (
                              partition by ptd.providerid
                              order by
                                ptd.degreepriority ASC NULLS FIRST,
                                ptd.lastupdatedate desc NULLS LAST,
                                d.degreeabbreviation NULLS FIRST
                            ) as recID
                          from  base.providertodegree ptd
                          inner join base.degree d on ptd.degreeid = d.degreeid
                        ) s
                      where p.providerid = s.providerid and recID = 1;
                       $$;

      update_temp_2 := $$
                      update mid.tempprovider p
                      SET p.providertypeid = ptpt.providertypeid
                      from base.providertoprovidertype ptpt
                      where p.providerid = ptpt.providerid and ptpt.providertyperank = 1;
                       $$;

      update_temp_3 := $$
                      update mid.tempprovider p
                      SET p.providertypeid =(select ProviderTypeID from base.providertype where ProviderTypeCode = 'ALT') 
                      where p.providertypeid is null;
                       $$;

      update_temp_4 := $$
                      update mid.tempprovider p 
                      SET p.title = 'Dr.'
                      from base.providertoprovidersubtype ptpst, base.providersubtype pst
                      where p.providerid = ptpst.providerid and ptpst.providersubtypeid = pst.providersubtypeid 
                            and pst.isdoctor = 1 and ifnull(Title, '') != 'Dr.';
                       $$;


      update_temp_5 := $$
                        update mid.tempprovider p 
                        SET p.providerurl = 
                          CASE
                            WHEN pt.providertypecode = 'ALT' then REPLACE(REPLACE(
                                '/' || 'providers/' || ifnull(lower(p.firstname), '') || '-' || ifnull(lower(p.lastname), '') || '-' || ifnull(lower(p.providercode),''),
                                '''', ''), ' ', '-')
                            WHEN pt.providertypecode = 'DOC' then REPLACE(REPLACE(
                                '/' || 'physician/dr-' || ifnull(lower(p.firstname), '') || '-' || ifnull(lower(p.lastname), '') || '-' || ifnull(lower(p.providercode), ''),
                                '''', ''), ' ', '-')
                            WHEN pt.providertypecode = 'DENT' then REPLACE(REPLACE(
                                '/' || 'dentist/dr-' || ifnull(lower(p.firstname), '') || '-' || ifnull(lower(p.lastname), '') || '-' || ifnull(lower(p.providercode), ''),'''', ''), ' ', '-')
                            else REPLACE(REPLACE('/' || 'providers/' || ifnull(lower(p.firstname), '') || '-' || ifnull(lower(p.lastname), '') || '-' || ifnull(lower(p.providercode), ''),
                                '''', ''), ' ', '-')
                          END
                        from base.providertoprovidertype ptpt, base.providertype pt
                        where p.providerid = ptpt.providerid and ptpt.providertyperank = 1 and ptpt.providertypeid = pt.providertypeid;
                       $$;

      update_temp_6 := $$
                      update mid.tempprovider p
                      SET p.ffdisplayspecialty = s.specialtycode
                      from base.providertodisplayspecialty ptds, base.specialty s
                      where ptds.providerid = p.providerid and s.specialtyid = ptds.specialtyid;
                       $$;


      update_statement := $$ 
                        update SET
                            target.acceptsnewpatients = source.acceptsnewpatients,
                            target.amaid = source.amaid,
                            target.carephilosophy = source.carephilosophy,
                            target.dateofbirth = source.dateofbirth,
                            target.deanumber = source.deanumber,
                            target.degreeabbreviation = source.degreeabbreviation,
                            target.expirecode = source.expirecode,
                            target.ffdisplayspecialty = source.ffdisplayspecialty,
                            target.firstname = source.firstname,
                            target.gender = source.gender,
                            target.haselectronicmedicalrecords = source.haselectronicmedicalrecords,
                            target.haselectronicprescription = source.haselectronicprescription,
                            target.lastname = source.lastname,
                            target.legacykey = source.legacykey,
                            target.medicareid = source.medicareid,
                            target.middlename = source.middlename,
                            target.npi = source.npi,
                            target.placeofbirth = source.placeofbirth,
                            target.professionalinterest = source.professionalinterest,
                            target.providercode = source.providercode,
                            target.providerlastupdatedateoverall = source.providerlastupdatedateoverall,
                            target.providerlastupdatedateoverallsourcetable = source.providerlastupdatedateoverallsourcetable,
                            target.providertypeid = source.providertypeid,
                            target.providerurl = source.providerurl,
                            target.searchboostaccessibility = source.searchboostaccessibility,
                            target.searchboostsatisfaction = source.searchboostsatisfaction,
                            target.suffix = source.suffix,
                            target.taxidnumber = source.taxidnumber,
                            target.title = source.title,
                            target.upin = source.upin
                          $$;

        insert_statement := $$
                            insert (
                                      AcceptsNewPatients,
                                      AMAID,
                                      CarePhilosophy,
                                      DateOfBirth,
                                      DEANumber,
                                      DegreeAbbreviation,
                                      ExpireCode,
                                      FFDisplaySpecialty,
                                      FirstName,
                                      Gender,
                                      HasElectronicMedicalRecords,
                                      HasElectronicPrescription,
                                      LastName,
                                      LegacyKey,
                                      MedicareID,
                                      MiddleName,
                                      NPI,
                                      PlaceOfBirth,
                                      ProfessionalInterest,
                                      ProviderCode,
                                      ProviderID,
                                      ProviderLastUpdateDateOverall,
                                      ProviderLastUpdateDateOverallSourceTable,
                                      ProviderTypeID,
                                      ProviderURL,
                                      SearchBoostAccessibility,
                                      SearchBoostSatisfaction,
                                      Suffix,
                                      TaxIDNumber,
                                      Title,
                                      UPIN
                                 )
                          values (	
                                source.acceptsnewpatients,
                                source.amaid,
                                source.carephilosophy,
                                source.dateofbirth,
                                source.deanumber,
                                source.degreeabbreviation,
                                source.expirecode,
                                source.ffdisplayspecialty,
                                source.firstname,
                                source.gender,
                                source.haselectronicmedicalrecords,
                                source.haselectronicprescription,
                                source.lastname,
                                source.legacykey,
                                source.medicareid,
                                source.middlename,
                                source.npi,
                                source.placeofbirth,
                                source.professionalinterest,
                                source.providercode,
                                source.providerid,
                                source.providerlastupdatedateoverall,
                                source.providerlastupdatedateoverallsourcetable,
                                source.providertypeid,
                                source.providerurl,
                                source.searchboostaccessibility,
                                source.searchboostsatisfaction,
                                source.suffix,
                                source.taxidnumber,
                                source.title,
                                source.upin
                                )
                            $$;
                     

      merge_statement := $$
                        merge into mid.provider as target 
                        using $$|| select_statement ||$$ as source	
                        on source.providerid = target.providerid
                        WHEN MATCHED and MD5(ifnull(CAST(target.acceptsnewpatients as varchar), '')) <> MD5(ifnull(CAST(source.acceptsnewpatients as varchar), '')) or 
                                        MD5(ifnull(CAST(target.amaid as varchar), '')) <> MD5(ifnull(CAST(source.amaid as varchar), '')) or 
                                        MD5(ifnull(CAST(target.carephilosophy as varchar), '')) <> MD5(ifnull(CAST(source.carephilosophy as varchar), '')) or 
                                        MD5(ifnull(CAST(target.dateofbirth as varchar), '')) <> MD5(ifnull(CAST(source.dateofbirth as varchar), '')) or 
                                        MD5(ifnull(CAST(target.deanumber as varchar), '')) <> MD5(ifnull(CAST(source.deanumber as varchar), '')) or 
                                        MD5(ifnull(CAST(target.degreeabbreviation as varchar), '')) <> MD5(ifnull(CAST(source.degreeabbreviation as varchar), '')) or 
                                        MD5(ifnull(CAST(target.expirecode as varchar), '')) <> MD5(ifnull(CAST(source.expirecode as varchar), '')) or 
                                        MD5(ifnull(CAST(target.ffdisplayspecialty as varchar), '')) <> MD5(ifnull(CAST(source.ffdisplayspecialty as varchar), '')) or 
                                        MD5(ifnull(CAST(target.firstname as varchar), '')) <> MD5(ifnull(CAST(source.firstname as varchar), '')) or 
                                        MD5(ifnull(CAST(target.gender as varchar), '')) <> MD5(ifnull(CAST(source.gender as varchar), '')) or 
                                        MD5(ifnull(CAST(target.haselectronicmedicalrecords as varchar), '')) <> MD5(ifnull(CAST(source.haselectronicmedicalrecords as varchar), '')) or 
                                        MD5(ifnull(CAST(target.haselectronicprescription as varchar), '')) <> MD5(ifnull(CAST(source.haselectronicprescription as varchar), '')) or 
                                        MD5(ifnull(CAST(target.lastname as varchar), '')) <> MD5(ifnull(CAST(source.lastname as varchar), '')) or 
                                        MD5(ifnull(CAST(target.legacykey as varchar), '')) <> MD5(ifnull(CAST(source.legacykey as varchar), '')) or 
                                        MD5(ifnull(CAST(target.medicareid as varchar), '')) <> MD5(ifnull(CAST(source.medicareid as varchar), '')) or 
                                        MD5(ifnull(CAST(target.middlename as varchar), '')) <> MD5(ifnull(CAST(source.middlename as varchar), '')) or 
                                        MD5(ifnull(CAST(target.npi as varchar), '')) <> MD5(ifnull(CAST(source.npi as varchar), '')) or 
                                        MD5(ifnull(CAST(target.placeofbirth as varchar), '')) <> MD5(ifnull(CAST(source.placeofbirth as varchar), '')) or 
                                        MD5(ifnull(CAST(target.professionalinterest as varchar), '')) <> MD5(ifnull(CAST(source.professionalinterest as varchar), '')) or 
                                        MD5(ifnull(CAST(target.providercode as varchar), '')) <> MD5(ifnull(CAST(source.providercode as varchar), '')) or 
                                        MD5(ifnull(CAST(target.providerlastupdatedateoverall as varchar), '')) <> MD5(ifnull(CAST(source.providerlastupdatedateoverall as varchar), '')) or 
                                        MD5(ifnull(CAST(target.providerlastupdatedateoverallsourcetable as varchar), '')) <> MD5(ifnull(CAST(source.providerlastupdatedateoverallsourcetable as varchar), '')) or 
                                        MD5(ifnull(CAST(target.providertypeid as varchar), '')) <> MD5(ifnull(CAST(source.providertypeid as varchar), '')) or 
                                        MD5(ifnull(CAST(target.providerurl as varchar), '')) <> MD5(ifnull(CAST(source.providerurl as varchar), '')) or 
                                        MD5(ifnull(CAST(target.searchboostaccessibility as varchar), '')) <> MD5(ifnull(CAST(source.searchboostaccessibility as varchar), '')) or 
                                        MD5(ifnull(CAST(target.searchboostsatisfaction as varchar), '')) <> MD5(ifnull(CAST(source.searchboostsatisfaction as varchar), '')) or 
                                        MD5(ifnull(CAST(target.suffix as varchar), '')) <> MD5(ifnull(CAST(source.suffix as varchar), '')) or 
                                        MD5(ifnull(CAST(target.taxidnumber as varchar), '')) <> MD5(ifnull(CAST(source.taxidnumber as varchar), '')) or 
                                        MD5(ifnull(CAST(target.title as varchar), '')) <> MD5(ifnull(CAST(source.title as varchar), '')) or 
                                        MD5(ifnull(CAST(target.upin as varchar), '')) <> MD5(ifnull(CAST(source.upin as varchar), '')) then $$ || update_statement || $$ 
                        when not matched then $$ || insert_statement;

     ---------------------------------------------------------
     ------------------- 5. execution ------------------------
     --------------------------------------------------------- 
     execute immediate create_temp;        
     execute immediate insert_temp;

     -- updates to temporary version of mid.provider
     execute immediate update_temp_1;
     execute immediate update_temp_2;
     execute immediate update_temp_3;
     execute immediate update_temp_4;
     execute immediate update_temp_5;
     execute immediate update_temp_6;
     
     -- merge to final mid.prover table
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