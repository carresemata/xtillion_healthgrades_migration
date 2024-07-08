CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDER(is_full BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.provider depends on: 
--- mdm_team.mst.provider_profile_processing 
--- base.source

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement_1 string; -- cte and select statement for the merge
    update_statement_1 string; -- update statement for the merge
    update_clause_1 string; -- where condition for update
    insert_statement_1 string; -- insert statement for the merge
    merge_statement_1 string; -- merge statement to final table

    update_statement_2 string; -- update statement for the merge
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_provider');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement_1 := $$ select
                            -- ReltioEntityId
                            -- EDWBaseRecordID
                            json.ref_provider_code as providercode,
                            to_varchar(json.PROVIDER_PROFILE:DEMOGRAPHICS[0]:FIRST_NAME) as FirstName,
                            to_varchar(json.PROVIDER_PROFILE:DEMOGRAPHICS[0]:MIDDLE_NAME) as MiddleName,
                            to_varchar(json.PROVIDER_PROFILE:DEMOGRAPHICS[0]:LAST_NAME) as LastName,
                            to_varchar(json.PROVIDER_PROFILE:DEMOGRAPHICS[0]:SUFFIX_CODE) as Suffix,
                            to_varchar(json.PROVIDER_PROFILE:DEMOGRAPHICS[0]:GENDER_CODE) as Gender,
                            CASE
                                WHEN to_varchar(json.PROVIDER_PROFILE:DEMOGRAPHICS[0]:NPI) = json.ref_provider_code then null
                                else to_varchar(json.PROVIDER_PROFILE:DEMOGRAPHICS[0]:NPI)
                            END as NPI,
                            TO_DATE(json.PROVIDER_PROFILE:DEMOGRAPHICS[0]:DATE_OF_BIRTH) as DateOfBirth,
                            to_varchar(json.PROVIDER_PROFILE:DEMOGRAPHICS[0]:ACCEPTS_NEW_PATIENTS) as AcceptsNewPatients,
                            -- HasElectronicMedicalRecords,
                            -- HasElectronicPrescription,
                            ifnull(json.PROVIDER_PROFILE:DEMOGRAPHICS[0]:DATA_SOURCE_CODE, 'Profisee') as SourceCode,
                            s.sourceid,
                            ifnull(json.PROVIDER_PROFILE:DEMOGRAPHICS[0]:LAST_UPDATE_DATE, sysdate()) as LastUpdateDate,
                            -- PatientVolume
                            -- IsInClinicalPractice
                            -- PatientCountIsFew
                            -- IsPCPCalculated
                            -- ProfessionalInterest
                            to_varchar(json.PROVIDER_PROFILE:DEMOGRAPHICS[0]:SURVIVE_RESIDENTIAL_ADDRESSES) as SurviveResidentialAddresses,
                            to_varchar(json.PROVIDER_PROFILE:DEMOGRAPHICS[0]:IS_PATIENT_FAVORITE) as IsPatientFavorite
                        from
                            $$ || mdm_db || $$.mst.provider_profile_processing as JSON
                            left join ((select distinct(sourcecode), sourceid from base.source where lastupdatedate != 'NaT')) as S on s.sourcecode = to_varchar(json.PROVIDER_PROFILE:DEMOGRAPHICS[0]:DATA_SOURCE_CODE) $$;



--- update Statement
update_statement_1 := ' update 
                            SET
                            target.firstname = source.firstname,
                            target.middlename = source.middlename,
                            target.lastname = source.lastname,
                            target.suffix = source.suffix,
                            target.gender = source.gender,
                            target.npi = source.npi,
                            target.dateofbirth = source.dateofbirth,
                            target.acceptsnewpatients = source.acceptsnewpatients,
                            target.sourcecode = source.sourcecode,
                            target.sourceid = source.sourceid,
                            target.lastupdatedate = source.lastupdatedate,
                            target.surviveresidentialaddresses = source.surviveresidentialaddresses,
                            target.ispatientfavorite = source.ispatientfavorite';
                            
-- update Clause
update_clause_1 := $$ ifnull(target.providercode, '') != ifnull(source.providercode, '')
        or ifnull(target.firstname, '') != ifnull(source.firstname, '')
        or ifnull(target.middlename, '') != ifnull(source.middlename, '')
        or ifnull(target.lastname, '') != ifnull(source.lastname, '')
        or ifnull(target.suffix, '') != ifnull(source.suffix, '')
        or ifnull(target.gender, '') != ifnull(source.gender, '')
        or ifnull(target.npi, '') != ifnull(source.npi, '')
        or ifnull(target.dateofbirth, '1900-01-01') != ifnull(source.dateofbirth,'1900-01-01')
        or ifnull(target.acceptsnewpatients, 0) != ifnull(source.acceptsnewpatients, 0)
        or ifnull(target.sourcecode, '') != ifnull(source.sourcecode, '')
        or ifnull(target.sourceid, '00000000-0000-0000-0000-000000000000') != ifnull(source.sourceid,'00000000-0000-0000-0000-000000000000')
        or ifnull(target.lastupdatedate, '1900-01-01') != ifnull(source.lastupdatedate, '1900-01-01')
        or ifnull(target.surviveresidentialaddresses, 0) != ifnull(source.surviveresidentialaddresses, 0)
        or ifnull(target.ispatientfavorite, 0) != ifnull(source.ispatientfavorite, 0) $$;                        
        
--- insert Statement
insert_statement_1 := ' insert  
                            (ProviderID,
                            ProviderCode,
                            FirstName,
                            MiddleName,
                            LastName,
                            Suffix,
                            Gender,
                            NPI,
                            DateOfBirth,
                            AcceptsNewPatients,
                            SourceCode,
                            SourceID,
                            LastUpdateDate,
                            SurviveResidentialAddresses,
                            IsPatientFavorite)
                      values 
                          ( utils.generate_uuid(source.providercode), 
                            source.providercode,
                            source.firstname,
                            source.middlename,
                            source.lastname,
                            source.suffix,
                            source.gender,
                            source.npi,
                            source.dateofbirth,
                            source.acceptsnewpatients,
                            source.sourcecode,
                            source.sourceid,
                            source.lastupdatedate,
                            source.surviveresidentialaddresses,
                            source.ispatientfavorite)';

-- update Statement

update_statement_2 := $$ update base.provider as target
       SET target.carephilosophy = source.provideraboutmetext
         from (select 
                    json.ref_provider_code as providercode,
                    to_varchar(aboutme.VALUE:ABOUT_ME_CODE) as AboutMeCode,
                    to_varchar(aboutme.VALUE:ABOUT_ME_TEXT) as ProviderAboutMeText
                from $$ || mdm_db || $$.mst.provider_profile_processing as JSON
                    , lateral flatten (input => json.PROVIDER_PROFILE:ABOUT_ME) ABOUTME
                    where AboutMeCode = 'CarePhilosophy') as source
         where target.providercode = source.providercode
    $$;
    
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement_1 := ' merge into base.provider as target using 
                   ('||select_statement_1||') as source 
                   on source.providercode = target.providercode
                   WHEN MATCHED and' || update_clause_1 || 'then '||update_statement_1|| '
                   when not matched then '||insert_statement_1;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.Provider;
end if; 
execute immediate merge_statement_1 ;
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

            return status;
end;