CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOLANGUAGE()
RETURNS STRING
LANGUAGE SQL
EXECUTE as CALLER
as
declare
--------------------------------------------------------
--------------- 0. table dependencies -------------------
--------------------------------------------------------

-- base.providertolanguage depends on:
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.language

--------------------------------------------------------
--------------- 1. declaring variables ------------------
--------------------------------------------------------

select_statement string; -- cte and select statement for the merge
insert_statement string; -- insert statement for the merge
merge_statement string; -- merge statement to final table
status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertolanguage');
    execution_start datetime default getdate();


--------------------------------------------------------
--------------- 2.conditionals if any -------------------
--------------------------------------------------------

begin
    -- no conditionals

--------------------------------------------------------
----------------- 3. SQL Statements ---------------------
--------------------------------------------------------

--- select Statement
select_statement := $$ 
select distinct
    p.providerid,
    l.languageid,
    ifnull(json.language_SourceCode, 'Profisee') as SourceCode,
    ifnull(json.language_LastUpdateDate, current_timestamp()) as LastUpdateDate 

from raw.vw_PROVIDER_PROFILE as JSON
    left join base.provider P on json.providercode = p.providercode
    left join base.language L on json.language_LanguageCode = l.languagecode
    
where json.provider_PROFILE is not null
  and json.language_LanguageCode is not null
  and ProviderID is not null
  and LanguageID is not null
  and json.language_LanguageCode != 'LN0000C3A1' -- Discard English
qualify row_number() over (partition by ProviderId, json.language_LanguageCode order by CREATE_DATE desc) = 1
$$;

--- insert Statement
insert_statement := $$  insert 
                            (ProviderToLanguageId, 
                            ProviderId, 
                            LanguageId, 
                            SourceCode, 
                            LastUpdateDate)
                        values 
                            (uuid_string(), 
                            source.providerid, 
                            source.languageid, 
                            source.sourcecode, 
                            source.lastupdatedate)
                        $$;

--------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
--------------------------------------------------------

merge_statement := $$ merge into base.providertolanguage as target
                        using ($$||select_statement||$$) as source
                        on source.providerid = target.providerid 
                        WHEN MATCHED then delete
                        when not matched then $$||insert_statement;

--------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------

execute immediate merge_statement;

--------------------------------------------------------
--------------- 6. status monitoring --------------------
--------------------------------------------------------

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