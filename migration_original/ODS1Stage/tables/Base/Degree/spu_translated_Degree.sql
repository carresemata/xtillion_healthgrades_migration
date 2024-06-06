CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_DEGREE(is_full BOOLEAN)
RETURNS STRING
LANGUAGE SQL EXECUTE
as CALLER
as declare 

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.degree depends on:
--- mdm_team.mst.provider_profile_processing 

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
merge_statement string;
status string;
procedure_name varchar(50) default('sp_load_degree');
execution_start datetime default getdate();
mdm_db string default('mdm_team');


begin


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

select_statement := $$
                    with Cte_degree as (
                        select
                            distinct
                            to_varchar(json.value:DEGREE_CODE) as DegreeCode,
                            MAX(to_varchar(json.value:UPDATED_DATETIME)) as LastUpdateDate
                        from $$ || mdm_db || $$.mst.provider_profile_processing as p
                        , lateral flatten(input => p.PROVIDER_PROFILE:DEGREE) as json
                        group by 
                            to_varchar(json.value:DEGREE_CODE)
                    )
                    select 
                        uuid_string() as DegreeID,
                        cte_d.degreecode as DegreeAbbreviation,
                        (select ifnull(MAX(refRank), 0) from base.degree) + row_number() over (order by cte_d.degreecode) as refRank,
                        cte_d.LastUpdateDate
                    from CTE_degree as cte_d
                    order by cte_d.degreecode
                    $$;


insert_statement := $$ 
                     insert  
                       (   
                        DegreeID,
                        DegreeAbbreviation,
                        refRank,
                        LastUpdateDate
                        )
                      values 
                        (   
                        source.degreeid,
                        source.degreeabbreviation,
                        source.refrank,
                        source.lastupdatedate
                        )
                     $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := $$ merge into base.degree as target 
                    using ($$||select_statement||$$) as source 
                   on source.degreeid = target.degreeid
                   when not matched then $$ ||insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.Degree;
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
