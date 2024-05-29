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
select_statement := $$with CTE_geoArea as (
                    select
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
                        END as GeographicAreaValue,
                        0 as ActionCode -- Create a new column ActionCode and set it to 0 (default value: no change)
                    from
                        base.geographicarea GeoArea
                        join base.geographicareatype GeoAreaType on geoarea.geographicareatypeid = geoareatype.geographicareatypeid
                    ),
                    -- insert Action
                    CTE_Action_1 as (
                        select
                            CTE_geoarea.geographicareaid,
                            1 as ActionCode
                        from
                            CTE_geoArea
                            left join mid.geographicarea GeoArea on CTE_geoarea.geographicareaid = geoarea.geographicareaid
                            and CTE_geoarea.geographicareacode = geoarea.geographicareacode
                            and CTE_geoarea.geographicareatypecode = geoarea.geographicareatypecode
                            and CTE_geoarea.geographicareavalue = geoarea.geographicareavalue
                        where
                            geoarea.geographicareaid is null
                    ),
                    -- update Action
                    CTE_Action_2 as (
                        select
                            CTE_geoarea.geographicareaid,
                            2 as ActionCode
                        from
                            CTE_geoArea
                            join mid.geographicarea GeoArea on CTE_geoarea.geographicareaid = geoarea.geographicareaid
                            and CTE_geoarea.geographicareacode = geoarea.geographicareacode
                        where
                            MD5(
                                ifnull(CTE_geoarea.geographicareacode::varchar, '''')
                            ) <> MD5(
                                ifnull(CTE_geoarea.geographicareacode::varchar, '''')
                            )
                            or MD5(
                                ifnull(CTE_geoarea.geographicareavalue::varchar, '''')
                            ) <> MD5(
                                ifnull(CTE_geoarea.geographicareavalue::varchar, '''')
                            )
                    )
                    select
                        A0.GEOGRAPHICAREAID,
                        A0.GEOGRAPHICAREACODE,
                        A0.GEOGRAPHICAREATYPECODE,
                        A0.GeographicAreaValue,
                        ifnull(A1.ActionCode,ifnull(A2.ActionCode, A0.ActionCode)) as ActionCode
                    from
                        CTE_geoArea A0
                        left join CTE_ACTION_1 A1 on A0.GeographicAreaID = A1.GeographicAreaID
                        left join CTE_ACTION_2 A2 on A0.GeographicAreaID = A2.GeographicAreaID
                    where 
                        ifnull(A1.ActionCode,ifnull(A2.ActionCode, A0.ActionCode)) <> 0
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
                   WHEN MATCHED and source.actioncode = 2 then '||update_statement|| '
                   when not matched and source.actioncode = 1 then '||insert_statement;
                   
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

            return status;
end;
