CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERLICENSE(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providerlicense depends on: 
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
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
    procedure_name varchar(50) default('sp_load_providerlicense');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ select distinct
                            p.providerid,
                            s.stateid, 
                            json.license_LicenseNumber as LicenseNumber,
                            json.license_LicenseTerminationDate as LicenseTerminationDate,
                            ifnull(json.license_SourceCode, 'Profisee') as SourceCode,
                            ifnull(json.license_LastUpdateDate, current_timestamp()) as LastUpdateDate,
                            json.license_LicenseTypeCode as LicenseType
                        from
                            raw.vw_PROVIDER_PROFILE as JSON
                            left join base.provider as P on p.providercode = json.providercode
                            left join base.state as S on json.license_State = s.state
                        where   
                            PROVIDER_PROFILE is not null and
                            ifnull(LicenseTerminationDate, current_timestamp()) >= DATEADD('DAY', -90, current_timestamp())
                        	or not (json.license_LicenseStatusCode != 'A' and LicenseTerminationDate is null) and
                            ProviderID is not null and
                            LicenseNumber is not null and
                            StateID is not null
                        qualify row_number() over(partition by ProviderID, StateID, LicenseNumber, LicenseType  order by CREATE_DATE desc) = 1 $$;


--- delete Statement
delete_statement := 'delete from base.providerlicense
                        where ProviderLicenseID IN (
                            select pc.providerlicenseid
                            from raw.vw_PROVIDER_PROFILE as p
                            inner join base.provider as pID on pid.providercode = p.providercode
                            inner join base.providerlicense as pc on pc.providerid = pid.providerid
                            left join base.providermalpractice M on m.providerid = pc.providerid -- before it was on m.providerlicenseid = pc.providerlicenseid
                            where m.providermalpracticeid is null
                        );';

--- insert Statement
insert_statement := ' insert  
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
                        source.licensetype)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providerlicense as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderLicense;
end if; 
execute immediate delete_statement ;
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