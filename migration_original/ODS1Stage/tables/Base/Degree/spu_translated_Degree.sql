CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_DEGREE(is_full BOOLEAN)
RETURNS STRING
LANGUAGE SQL EXECUTE
as CALLER
as declare 

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.degree depends on:
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
merge_statement string;
status string;
    procedure_name varchar(50) default('sp_load_degree');
    execution_start datetime default getdate();



begin


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

select_statement := $$
                    with CTE_degrees as (
                        select distinct json.degree_DegreeCode as DegreeCode
                        from raw.vw_PROVIDER_PROFILE as JSON
                        where not exists (
                            select d.degreeabbreviation
                            from base.degree as d
                            where d.degreeabbreviation = json.degree_DegreeCode
                        ) and DegreeCode is not null
                    )
                    
                    select 
                        uuid_string() as DegreeID,
                        cte_d.degreecode as DegreeAbbreviation,
                        cte_d.degreecode as DegreeDescription, -- weird but what the original proc does
                        (select MAX(refRank) from base.degree) + row_number() over (order by cte_d.degreecode) as refRank
                    from CTE_degrees as cte_d
                    order by cte_d.degreecode
                    $$;


insert_statement := $$ 
                     insert  
                       (   
                        DegreeID,
                        DegreeAbbreviation,
                        DegreeDescription,
                        refRank
                        )
                      values 
                        (   
                        source.degreeid,
                        source.degreeabbreviation,
                        source.degreedescription,
                        source.refrank
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