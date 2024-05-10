CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERSURVEYSUPPRESSION()
RETURNS STRING
LANGUAGE SQL
EXECUTE as CALLER
as
declare

---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
-- base.providersurveysuppression depends on:
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.surveysuppressionreason

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
merge_statement string;
status string;
    procedure_name varchar(50) default('sp_load_providersurveysuppression');
    execution_start datetime default getdate();


---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------  

begin
-- no conditionals

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

--- select Statement
select_statement := $$ select
                            p.providerid,
                            ssr.surveysuppressionreasonid,
                            ifnull(json.demographics_SOURCECODE, 'Profisee') as SourceCode
                        from raw.vw_PROVIDER_PROFILE as JSON
                            left join base.provider as P on p.providercode = json.providercode
                            left join base.surveysuppressionreason as SSR on ssr.suppressioncode = json.demographics_SURVEYSUPPRESSIONREASONCODE
                        where
                            json.provider_PROFILE is not null and
                            p.providerid is not null and
                            SurveySuppressionReasonID is not null and
                            json.demographics_SURVEYSUPPRESSIONREASONCODE is not null
                        qualify dense_rank() over (partition by ProviderId order by CREATE_DATE desc)= 1 $$;

--- insert Statement
insert_statement := ' insert 
                        (ProviderSurveySuppressionID, 
                        ProviderID, 
                        SurveySuppressionReasonID, 
                        SourceCode)
                      values 
                        (uuid_string(), 
                        source.providerid, 
                        source.surveysuppressionreasonid, 
                        source.sourcecode)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------

merge_statement := ' merge into base.providersurveysuppression as target 
using ('||select_statement||') as source
on source.providerid = target.providerid and source.surveysuppressionreasonid = target.surveysuppressionreasonid
WHEN MATCHED then delete 
when not matched then'||insert_statement;

---------------------------------------------------------
------------------- 5. execution ------------------------
---------------------------------------------------------
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