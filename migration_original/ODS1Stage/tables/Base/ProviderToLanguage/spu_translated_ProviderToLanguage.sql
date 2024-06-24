CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOLANGUAGE(is_full BOOLEAN)
RETURNS STRING
LANGUAGE SQL
EXECUTE as CALLER
as
declare
--------------------------------------------------------
--------------- 1. table dependencies -------------------
--------------------------------------------------------

-- base.providertolanguage depends on:
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.language

--------------------------------------------------------
--------------- 2. declaring variables ------------------
--------------------------------------------------------

select_statement string; -- cte and select statement for the merge
insert_statement string; -- insert statement for the merge
update_statement string; -- update
merge_statement string; -- merge statement to final table
status string; -- status monitoring
procedure_name varchar(50) default('sp_load_providertolanguage');
execution_start datetime default getdate();
mdm_db string default ('mdm_team');

begin
    

--------------------------------------------------------
----------------- 3. SQL Statements ---------------------
--------------------------------------------------------

--- select Statement
select_statement := $$ 
with Cte_language as (
    SELECT
        p.ref_provider_code as providercode,
        to_varchar(json.value:LANGUAGE_CODE) as Language_LanguageCode,
        to_varchar(json.value:DATA_SOURCE_CODE) as Language_SourceCode,
        to_timestamp_ntz(json.value:UPDATED_DATETIME) as Language_LastUpdateDate
    FROM $$||mdm_db||$$.mst.provider_profile_processing as p, 
        lateral flatten(input => p.PROVIDER_PROFILE:LANGUAGE) as json
    where to_varchar(json.value:LANGUAGE_CODE) != 'LN0000C3A1' -- Discard English
)
select distinct
    p.providerid,
    l.languageid,
    ifnull(cte.language_SourceCode, 'Profisee') as SourceCode,
    ifnull(cte.language_LastUpdateDate, current_timestamp()) as LastUpdateDate 
from cte_language as cte
    join base.provider P on cte.providercode = p.providercode
    join base.language L on cte.language_LanguageCode = l.languagecode
qualify row_number() over(partition by providerid, languageid order by language_LastUpdateDate desc) = 1
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

--- update statement
update_statement := $$ update
                        set
                            target.SourceCode = source.sourcecode,
                            target.LastUpdateDate = source.lastupdatedate
                    $$;
                        
--------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
--------------------------------------------------------

merge_statement := $$ merge into base.providertolanguage as target
                        using ($$||select_statement||$$) as source
                        on source.providerid = target.providerid and target.LanguageId = source.languageid
                        when matched then $$ || update_statement || $$
                        when not matched then $$||insert_statement;

--------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToLanguage;
end if; 
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