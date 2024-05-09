CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERREDIRECT()
RETURNS varchar(16777216)
LANGUAGE SQL
EXECUTE as CALLER
as 

declare
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
-- base.providerredirect depends on:
--- mid.provider 

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------
select_statement string;
update_statement string;
merge_statement string;
status string;
    procedure_name varchar(50) default('sp_load_providerredirect');
    execution_start datetime default getdate();


---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------   

begin
-- no conditionals

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

select_statement := $$
                    select p.providercode, p.providerurl
                    from mid.provider p
                    inner join base.providerredirect pr on p.providercode = pr.providercodenew
                    where pr.providerurlnew is not null
                        and p.providerurl != pr.providerurlnew
                        and pr.deactivationreason not IN ('Deactivated', 'HomePageRedirect')
                    $$;

update_statement := $$ 
                    update SET ProviderURLNew = source.providerurl
                    $$;


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := $$ merge into base.providerredirect as target 
                    using ($$||select_statement||$$) as source 
                    on source.providercode = target.providercodenew
                    WHEN MATCHED then $$ ||update_statement
                    $$;


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