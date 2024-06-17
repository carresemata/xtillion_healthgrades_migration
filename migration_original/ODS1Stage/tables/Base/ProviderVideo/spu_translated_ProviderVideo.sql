CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERVIDEO(is_full BOOLEAN)
RETURNS STRING
LANGUAGE SQL
EXECUTE as CALLER
as
declare

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

-- base.providervideo depends on:
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.mediavideohost
--- base.mediareviewlevel
--- base.mediacontexttype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

select_statement string; -- cte and select statement for the merge
insert_statement string; -- insert statement for the merge
merge_statement string; -- merge statement to final table
status string; -- status monitoring
procedure_name varchar(50) default('sp_load_providervideo');
execution_start datetime default getdate();
mdm_db string default('mdm_team');



begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- select Statement
select_statement := $$ with Cte_video as (
    SELECT
        p.ref_provider_code as providercode,
        to_varchar(json.value:IDENTIFIER) as Video_SrcIdentifier,
        to_varchar(json.value:MEDIA_VIDEO_HOST_CODE) as Video_RefMediaVideoHostCode,
        to_varchar(json.value:MEDIA_REVIEW_LEVEL_CODE) as Video_RefMediaReviewLevelCode,
        to_varchar(json.value:MEDIA_CONTEXT_TYPE_CODE) as Video_RefMediaContextTypeCode,
        to_varchar(json.value:DATA_SOURCE_CODE) as Video_SourceCode,
        to_timestamp_ntz(json.value:UPDATED_DATETIME) as Video_LastUpdateDate
    FROM $$||mdm_db||$$.mst.provider_profile_processing as p
    , lateral flatten(input => p.PROVIDER_PROFILE:VIDEO) as json
)
select 
    p.providerid, 
    json.video_SRCIDENTIFIER as ExternalIdentifier,
    mh.mediavideohostid,
    mr.mediareviewlevelid,
    ifnull(json.video_SourceCode, 'Profisee') as SourceCode,
    ifnull(json.video_LastUpdateDate, sysdate()) as LastUpdateDate,
    mc.mediacontexttypeid
from Cte_video as JSON
     join base.provider as P on p.providercode = json.providercode
     join base.mediavideohost as MH on mh.mediavideohostcode = json.video_REFMEDIAVIDEOHOSTCODE
     join base.mediareviewlevel as MR on json.video_REFMEDIAREVIEWLEVELCODE = mr.mediareviewlevelcode
     join base.mediacontexttype as MC on json.video_REFMEDIACONTEXTTYPECODE = mc.mediacontexttypecode
$$;

-- insert Statement
insert_statement := 'insert 
                        (PROVIDERVIDEOID, 
                        PROVIDERID, 
                        EXTERNALIDENTIFIER, 
                        MEDIAVIDEOHOSTID, 
                        MEDIAREVIEWLEVELID, 
                        SOURCECODE, 
                        LASTUPDATEDATE, 
                        MEDIACONTEXTTYPEID)
                    values 
                        (uuid_string(), 
                        source.providerid, 
                        source.externalidentifier, 
                        source.mediavideohostid, 
                        source.mediareviewlevelid, 
                        source.sourcecode, 
                        source.lastupdatedate, 
                        source.mediacontexttypeid)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------

merge_statement := 'merge into base.providervideo as TARGET
using ('||select_statement||') as SOURCE
on target.providerid = source.providerid
WHEN MATCHED then delete
when not matched then ' || insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderVideo;
end if; 
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