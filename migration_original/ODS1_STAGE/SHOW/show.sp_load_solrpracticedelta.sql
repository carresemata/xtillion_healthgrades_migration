CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRPRACTICEDELTA(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- show.solrpracticedelta depends on:
--- mdm_team.mst.practice_profile_processing
--- show.solrpractice

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string;
    insert_statement string;
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrpracticedelta');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     
begin   

-- Get all the ids that are processed and get to solr table
select_statement := $$ with cte_practice_id as (
                        select 
                            distinct
                            p.practiceid
                        from $$ || mdm_db || $$.mst.Practice_Profile_Processing as ppp
                            join show.solrpractice as P on p.practicecode = ppp.ref_practice_code)
                       select
                            uuid_string() as solrpracticedeltaid,
                            p.practiceid,
                            '1' as solrdeltatypecode,
                            null as startdeltaprocessdate,
                            current_timestamp() as enddeltaprocessdate,
                            '1' as middeltaprocesscomplete
                       from cte_practice_id as p
                        $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

insert_statement := 'insert overwrite into show.solrpracticedelta 
                       (solrpracticedeltaid, practiceid, solrdeltatypecode, startdeltaprocessdate, enddeltaprocessdate, middeltaprocesscomplete)
                        select 
                                solrpracticedeltaid,
                                practiceid,
                                solrdeltatypecode,
                                current_timestamp() as startdeltaprocessdate,
                                enddeltaprocessdate,
                                middeltaprocesscomplete
                        from (' || select_statement || ') as source';
                                            
                   
---------------------------------------------------------
-------------------  5. execution -----------------------
---------------------------------------------------------

if (is_full) then
    truncate table Show.SOLRPracticeDelta;
else
    execute immediate insert_statement;
end if; 


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

            raise;
end;