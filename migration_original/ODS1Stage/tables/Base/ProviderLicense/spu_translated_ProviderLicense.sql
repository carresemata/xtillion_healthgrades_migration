CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERLICENSE("IS_FULL" BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providerlicense depends on: 
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.providermalpractice
--- base.state

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    delete_statement string; -- delete statement 
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default(''sp_load_providerlicense'');
    execution_start datetime default getdate();
    mdm_db string default(''mdm_team'');
   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$  With Cte_license as (
                            SELECT
                                p.ref_provider_code as providercode,
                                to_varchar(json.value:LICENSE_TYPE_CODE) as License_LicenseTypeCode,
                                to_varchar(json.value:LICENSE_STATUS_CODE) as License_LicenseStatusCode,
                                to_varchar(json.value:LICENSE_NUMBER) as License_LicenseNumber,
                                to_varchar(json.value:STATE) as License_State,
                                to_varchar(json.value:LICENSE_TERMINATION_DATE) as License_LicenseTerminationDate,
                                to_varchar(json.value:DATA_SOURCE_CODE) as License_SourceCode,
                                to_timestamp_ntz(json.value:UPDATED_DATETIME) as License_LastUpdateDate
                            FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
                            , lateral flatten(input => p.PROVIDER_PROFILE:LICENSE) as json
                        )

                        select distinct
                            p.providerid,
                            s.stateid, 
                            cte.license_LicenseNumber as LicenseNumber,
                            cte.license_LicenseTerminationDate as LicenseTerminationDate,
                            ifnull(cte.license_SourceCode, ''Profisee'') as SourceCode,
                            ifnull(cte.license_LastUpdateDate, current_timestamp()) as LastUpdateDate,
                            cte.license_LicenseTypeCode as LicenseType
                        from
                            cte_license as cte
                            inner join base.provider as P on p.providercode = cte.providercode
                            inner join base.state as S on cte.license_State = s.state
                        where   
                            ifnull(LicenseTerminationDate, current_timestamp()) >= DATEADD(''DAY'', -90, current_timestamp())
                        	or not (cte.license_LicenseStatusCode != ''A'' and LicenseTerminationDate is null) and
                            LicenseNumber is not null $$;


--- delete Statement
delete_statement := ''delete from base.providerlicense as target
                            using ( select 
                                        pc.providerlicenseid
                                    from $$ || mdm_db || $$.mst.provider_profile_processing as proc
                                        inner join base.provider as pID on pid.providercode = proc.ref_provider_code
                                        inner join base.providerlicense as pc on pc.providerid = pid.providerid
                                        left join base.providermalpractice M on m.providerid = pc.providerid -- before it was on m.providerlicenseid = pc.providerlicenseid
                                    where m.providermalpracticeid is null) as query
                            where target.providerlicenseid = query.providerlicenseid;'';

--- insert Statement
insert_statement := '' insert  
                        (ProviderLicenseID,
                        ProviderID,
                        StateID,
                        LicenseNumber,
                        LicenseTerminationDate,
                        SourceCode,
                        LastUpdateDate,
                        LicenseType)
                      values 
                        (uuid_string(),
                        source.providerid,
                        source.stateid,
                        source.licensenumber,
                        source.licenseterminationdate,
                        source.sourcecode,
                        source.lastupdatedate,
                        source.licensetype)'';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := '' merge into base.providerlicense as target using 
                   (''||select_statement||'') as source 
                   on source.providerid = target.providerid
                   when not matched then ''||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderLicense;
end if; 
-- execute immediate delete_statement ;
execute immediate merge_statement ;

---------------------------------------------------------
--------------- 6. status monitoring --------------------
--------------------------------------------------------- 

status := ''completed successfully'';
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        return status;

        exception
        when other then
            status := ''failed during execution. '' || ''sql error: '' || sqlerrm || '' error code: '' || sqlcode || ''. sql state: '' || sqlstate;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, split_part(regexp_substr(:status, ''error code: ([0-9]+)''), '':'', 2)::integer, trim(split_part(split_part(:status, ''sql error:'', 2), ''error code:'', 1)), split_part(regexp_substr(:status, ''sql state: ([0-9]+)''), '':'', 2)::integer; 

            return status;
end';