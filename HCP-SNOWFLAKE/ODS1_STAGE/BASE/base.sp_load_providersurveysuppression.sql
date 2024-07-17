CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERSURVEYSUPPRESSION(is_full BOOLEAN)
RETURNS STRING
LANGUAGE SQL
EXECUTE as CALLER
as
declare

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.providersurveysuppression depends on:
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.surveysuppressionreason

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
update_statement string; 
merge_statement string;
status string;
procedure_name varchar(50) default('sp_load_providersurveysuppression');
execution_start datetime default getdate();
mdm_db string default('mdm_team');

begin


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

--- select Statement
select_statement := $$ with cte_surveysupression as (
                        select
                            TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].PROVIDER_CODE) AS ProviderCode,
                            TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].SURVEY_SUPPRESSION_REASON_CODE) AS Demographics_SurveySuppressionReasonCode,
                            TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].DATA_SOURCE_CODE) AS Demographics_SourceCode,
                            TO_TIMESTAMP_NTZ(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].UPDATED_DATETIME) AS Demographics_LastUpdateDate,
                        from $$ || mdm_db || $$.mst.provider_profile_processing as process
                        where TO_VARCHAR(Process.PROVIDER_PROFILE:DEMOGRAPHICS[0].SURVEY_SUPPRESSION_REASON_CODE) is not null
                        )

                        select
                            p.providerid,
                            ssr.surveysuppressionreasonid,
                            ifnull(json.demographics_SOURCECODE, 'Profisee') as SourceCode
                        from cte_surveysupression as JSON
                            join base.provider as P on p.providercode = json.providercode
                            join base.surveysuppressionreason as SSR on ssr.suppressioncode = json.demographics_SURVEYSUPPRESSIONREASONCODE
                        qualify row_number() over (partition by ProviderId, surveysuppressionreasonid order by json.Demographics_LastUpdateDate desc)= 1 $$;

--- insert Statement
insert_statement := ' insert 
                        (ProviderSurveySuppressionID, 
                        ProviderID, 
                        SurveySuppressionReasonID, 
                        SourceCode)
                      values 
                        (utils.generate_uuid(source.providerid || source.surveysuppressionreasonid),  
                        source.providerid, 
                        source.surveysuppressionreasonid, 
                        source.sourcecode)';

--- update statement
update_statement := ' update
                        set
                            target.SourceCode = source.sourcecode ';                        

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------

merge_statement := ' merge into base.providersurveysuppression as target 
                        using ('||select_statement||') as source
                        on source.providerid = target.providerid and source.surveysuppressionreasonid = target.surveysuppressionreasonid
                        when matched then ' || update_statement || '
                        when not matched then'||insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderSurveySuppression;
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