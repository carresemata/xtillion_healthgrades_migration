CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRPROVIDERDELTA(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  

declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- show.solrproviderdelta depends on: 
--- mdm_team.mst.provider_profile_processing
--- mid.provider

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string;
    insert_statement string;
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrproviderdelta');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     
begin   

-- Get all the ids that are processed and get to solr table
select_statement := $$ with cte_provider_id as (
                        select 
                            distinct
                            p.providerid
                        from $$ || mdm_db || $$.mst.Provider_Profile_Processing as ppp
                            join mid.provider as P on p.providercode = ppp.ref_provider_code)
                       select
                            uuid_string() as solrproviderdeltaid,
                            p.providerid,
                            '1' as solrdeltatypecode,
                            null as startdeltaprocessdate,
                            current_timestamp() as enddeltaprocessdate,
                            '1' as middeltaprocesscomplete
                       from cte_provider_id as p
                        $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

insert_statement := 'insert overwrite into show.solrproviderdelta 
                       (solrproviderdeltaid, providerid, solrdeltatypecode, startdeltaprocessdate, enddeltaprocessdate, middeltaprocesscomplete)
                        select 
                                solrproviderdeltaid,
                                providerid,
                                solrdeltatypecode,
                                current_timestamp() as startdeltaprocessdate,
                                enddeltaprocessdate,
                                middeltaprocesscomplete
                        from (' || select_statement || ') as source';
                                            
                   
---------------------------------------------------------
-------------------  5. execution -----------------------
---------------------------------------------------------

if (is_full) then
    truncate table Show.SOLRProviderDelta;
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