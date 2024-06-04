CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDEREMAIL("IS_FULL" BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.provideremail depends on: 
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default(''sp_load_provideremail'');
    execution_start datetime default getdate();
    mdm_db string default(''mdm_team'');
   
   
begin
    

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ with Cte_email as (
                            SELECT
                                p.ref_provider_code as providercode,
                                to_varchar(json.value:EMAIL) as Email_Email,
                                to_varchar(json.value:EMAIL_RANK) as Email_EmailRank,
                                to_varchar(json.value:DATA_SOURCE_CODE) as Email_SourceCode,
                                to_timestamp_ntz(json.value:UPDATED_DATETIME) as Email_LastUpdateDate
                            FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
                            , lateral flatten(input => p.PROVIDER_PROFILE:EMAIL) as json
                        )
                        select distinct
                            p.providerid,
                            cte.email_Email as EmailAddress,
                            ifnull(cte.email_EmailRank, 999) as EmailRank,
                            ifnull(cte.email_SourceCode, ''Profisee'') as SourceCode,
                            -- EmailTypeID
                            ifnull(cte.email_LastUpdateDate, current_timestamp()) as LastUpdateDate
                        from
                            cte_email as cte
                            join base.provider as P on p.providercode = cte.providercode $$;




--- insert Statement
insert_statement := '' insert  
                        (   ProviderEmailID,
                            ProviderID,
                            EmailAddress,
                            EmailRank,
                            SourceCode,
                            --EmailTypeID,
                            LastUpdateDate)
                      values 
                        (   uuid_string(),
                            source.providerid,
                            source.emailaddress,
                            source.emailrank,
                            source.sourcecode,
                            --EmailTypeID,
                            source.lastupdatedate)'';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := '' merge into base.provideremail as target using 
                   (''||select_statement||'') as source 
                   on source.providerid = target.providerid
                   WHEN MATCHED then delete
                   when not matched then ''||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderEmail;
end if; 
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