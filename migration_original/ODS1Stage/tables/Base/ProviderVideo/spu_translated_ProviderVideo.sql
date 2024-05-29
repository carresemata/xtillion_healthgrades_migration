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
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
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



begin
-- No conditionals

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- select Statement
select_statement := $$ select 
                            p.providerid, 
                            json.video_SRCIDENTIFIER as ExternalIdentifier,
                            mh.mediavideohostid,
                            mr.mediareviewlevelid,
                            ifnull(json.video_SourceCode, 'Profisee') as SourceCode,
                            ifnull(json.video_LastUpdateDate, sysdate()) as LastUpdateDate,
                            mc.mediacontexttypeid
                        
                        from raw.vw_PROVIDER_PROFILE as JSON
                            left join base.provider as P on p.providercode = json.providercode
                            left join base.mediavideohost as MH on mh.mediavideohostcode = json.video_REFMEDIAVIDEOHOSTCODE
                            left join base.mediareviewlevel as MR on json.video_REFMEDIAREVIEWLEVELCODE = mr.mediareviewlevelcode
                            left join base.mediacontexttype as MC on json.video_REFMEDIACONTEXTTYPECODE = mc.mediacontexttypecode
                        where PROVIDER_PROFILE is not null
                            and PROVIDERID is not null
                            and json.video_SRCIDENTIFIER is not null
                            and MEDIAVIDEOHOSTID is not null
                            and MEDIAREVIEWLEVELID is not null
                            and MEDIACONTEXTTYPEID is not null
                        qualify row_number() over(partition by ProviderId, json.video_REFMEDIACONTEXTTYPECODE, json.video_REFMEDIAVIDEOHOSTCODE order by CREATE_DATE desc) = 1 $$;

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