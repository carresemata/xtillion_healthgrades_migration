CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CLIENT(is_full BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

--- base.client depends on:   
--- mdm_team.mst.customer_product_profile_processing (base.vw_swimlane_base_client)

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_client');
    execution_start datetime default getdate();

begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ select
                            distinct
                            swimlane.clientcode,
                            case when swimlane.customername is null then swimlane.clientcode else swimlane.customername end as ClientName,
                            ifnull(swimlane.lastupdatedate, current_timestamp()) as LastUpdateDate,
                            ifnull(swimlane.sourcecode, 'Profisee') as SourceCode
                        from
                            base.vw_swimlane_base_client as swimlane
                        qualify row_number() over (partition by swimlane.clientcode order by swimlane.lastupdatedate desc) = 1
                        $$;

--- update Statement
update_statement := 'update
                        SET
                            ClientName = source.clientname,
                            sourcecode = source.sourcecode,
                            LastUpdateDate = source.lastupdatedate';

--- insert Statement
insert_statement := ' insert
    (
        ClientID,
        ClientCode,
        ClientName,
        SourceCode,
        LastUpdateDate
    )
values
    (
        utils.generate_uuid(source.clientcode), 
        source.clientcode,
        source.clientname,
        source.sourcecode,
        source.lastupdatedate
    )';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.client as target using 
                   ('||select_statement||') as source 
                   on source.clientcode = target.clientcode
                   when matched then '||update_statement||'
                   when not matched then'||insert_statement;
                   
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 

if (is_full) then
    truncate table base.client;
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