CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_GEOGRAPHICAREA(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  

declare
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- mid.geographicarea depends on: 
--- base.geographicarea
--- base.geographicareatype


---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
 
    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_geographicarea');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ select
                            GEOGRAPHICAREAID,
                            GEOGRAPHICAREACODE,
                            GEOGRAPHICAREATYPECODE,
                            CASE
                                WHEN geoareatype.geographicareatypecode = 'CITYST' then CONCAT(
                                    geoarea.geographicareavalue1,
                                    ',',
                                    geoarea.geographicareavalue2
                                )
                                else geoarea.geographicareavalue1
                            END as GeographicAreaValue
                        from
                            base.geographicarea GeoArea
                            join base.geographicareatype GeoAreaType on geoarea.geographicareatypeid = geoareatype.geographicareatypeid
                    $$;

--- update Statement
update_statement := ' update 
                        SET
                            GEOGRAPHICAREAID = source.geographicareaid , 
                            GEOGRAPHICAREACODE = source.geographicareacode , 
                            GEOGRAPHICAREATYPECODE = source.geographicareatypecode , 
                            GEOGRAPHICAREAVALUE = source.geographicareavalue ';

--- insert Statement
insert_statement := ' insert
                            (   GEOGRAPHICAREAID,
                                GEOGRAPHICAREACODE,
                                GEOGRAPHICAREATYPECODE,
                                GEOGRAPHICAREAVALUE)
                       values
                            (   source.geographicareaid,
                                source.geographicareacode,
                                source.geographicareatypecode,
                                source.geographicareavalue);';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.geographicarea as target using 
                   ('||select_statement||') as source 
                   on source.geographicareaid = target.geographicareaid and source.geographicareacode = target.geographicareacode
                   when matched then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.GeographicArea;
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