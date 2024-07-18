CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRGEOGRAPHICAREADELTA(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  

declare 

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- show.solrgeographicareadelta depends on: 
--- mid.geographicarea

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrgeographicareadelta');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := '   select distinct
                            ga.geographicareaid,
                            1 as SolrDeltaTypeCode,
                            1 as MidDeltaProcessComplete
                        from 
                            mid.geographicarea ga
                            left join show.solrgeographicareadelta gad on ga.geographicareaid = gad.geographicareaid
                        where
                            gad.geographicareaid is null';


--- insert Statement
insert_statement := ' insert (
                        GeographicAreaID, 
                        SolrDeltaTypeCode, 
                        MidDeltaProcessComplete)
                      values (
                        source.geographicareaid, 
                        source.solrdeltatypecode, 
                        source.middeltaprocesscomplete);';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into show.solrgeographicareadelta as target using 
                   ('||select_statement||') as source 
                   on target.geographicareaid = source.geographicareaid 
                   when not matched then ' ||insert_statement ;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Show.SOLRGeographicAreaDelta;
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

            raise;
end;