CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PRACTICE() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
    
-- base.practice depends on: 
--- mdmm_team.mst.practice_profile_processing (raw.vw_practice_profile)

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_practice');
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
                            ifnull(json.demographics_LastUpdateDate, current_timestamp()) as LastUpdateDate,
                            json.demographics_NPI as NPI,
                            json.practicecode,
                            CASE WHEN json.demographics_Logo = 'None' then null else json.demographics_Logo END as PracticeLogo,
                            CASE WHEN json.demographics_MedicalDirector = 'None' then null else json.demographics_MedicalDirector END as PracticeMedicalDirector,
                            CASE WHEN json.demographics_PracticeName LIKE '%&amp;%' then REPLACE(json.demographics_PracticeName, '&amp;', '&') else ifnull(json.demographics_PracticeName, '' ) END as PracticeName,
                            ifnull(json.demographics_SourceCode, 'Profisee') as SourceCode,
                            json.demographics_YearPracticeEstablished as YearPracticeEstablished
                        from raw.vw_PRACTICE_PROFILE as JSON
                        where 
                            PRACTICE_PROFILE is not null and
                            PracticeCode is not null and
                            PracticeName is not null and
                            LENGTH(PracticeCode) <= 10
                        qualify row_number() over(partition by PracticeCode order by CREATE_DATE desc) = 1$$;

--- update Statement
update_statement := ' update
                        SET
                            LastUpdateDate = source.lastupdatedate,
                            NPI = source.npi,
                            PracticeCode = source.practicecode,
                            PracticeLogo = source.practicelogo,
                            PracticeMedicalDirector = source.practicemedicaldirector,
                            PracticeName = source.practicename,
                            SourceCode = source.sourcecode,
                            YearPracticeEstablished = source.yearpracticeestablished';

--- insert Statement
insert_statement := ' insert 
                            (
                            PracticeID,
                            LastUpdateDate,
                            NPI,
                            PracticeCode,
                            PracticeLogo,
                            PracticeMedicalDirector,
                            PracticeName,
                            SourceCode,
                            YearPracticeEstablished
                            )
                        values
                            (
                            uuid_string(),
                            source.lastupdatedate,
                            source.npi,
                            source.practicecode,
                            source.practicelogo,
                            source.practicemedicaldirector,
                            source.practicename,
                            source.sourcecode,
                            source.yearpracticeestablished
                            )';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.practice as target using 
                   ('||select_statement||') as source 
                   on source.practicecode = target.practicecode
                   WHEN MATCHED then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 
                    
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