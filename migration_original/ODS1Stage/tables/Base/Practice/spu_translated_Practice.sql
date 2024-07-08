CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PRACTICE(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.practice depends on: 
--- mdm_team.mst.practice_profile_processing 

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_practice');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ select 
                            ifnull(TO_TIMESTAMP_NTZ(PRACTICE_PROFILE:DEMOGRAPHICS[0].UPDATED_DATETIME), current_timestamp()) as LastUpdateDate,
                            TO_VARCHAR(PRACTICE_PROFILE:DEMOGRAPHICS[0].NPI) as NPI,
                            REF_PRACTICE_CODE as practicecode,
                            CASE WHEN TO_VARCHAR(PRACTICE_PROFILE:DEMOGRAPHICS[0].LOGO) = 'None' then null else TO_VARCHAR(PRACTICE_PROFILE:DEMOGRAPHICS[0].LOGO) END as PracticeLogo,
                            CASE WHEN TO_VARCHAR(PRACTICE_PROFILE:DEMOGRAPHICS[0].MEDICAL_DIRECTOR) = 'None' then null else TO_VARCHAR(PRACTICE_PROFILE:DEMOGRAPHICS[0].MEDICAL_DIRECTOR) END as PracticeMedicalDirector,
                            CASE WHEN TO_VARCHAR(PRACTICE_PROFILE:DEMOGRAPHICS[0].PRACTICE_NAME) LIKE '%&amp;%' then REPLACE(TO_VARCHAR(PRACTICE_PROFILE:DEMOGRAPHICS[0].PRACTICE_NAME), '&amp;', '&') else ifnull(TO_VARCHAR(PRACTICE_PROFILE:DEMOGRAPHICS[0].PRACTICE_NAME), '' ) END as PracticeName,
                            ifnull(TO_VARCHAR(PRACTICE_PROFILE:DEMOGRAPHICS[0].DATA_SOURCE_CODE), 'Profisee') as SourceCode,
                            TO_VARCHAR(PRACTICE_PROFILE:DEMOGRAPHICS[0].YEAR_PRACTICE_ESTABLISHED) as YearPracticeEstablished
                        from $$ || mdm_db || $$.mst.practice_profile_processing
                        where 
                            PracticeName is not null and
                            LENGTH(PracticeCode) <= 10 $$;

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
                            utils.generate_uuid(source.practicecode), 
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
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.Practice;
end if; 
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