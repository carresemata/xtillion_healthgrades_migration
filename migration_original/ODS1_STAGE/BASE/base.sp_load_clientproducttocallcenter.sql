CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CLIENTPRODUCTTOCALLCENTER(is_full BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

--- base.clientproducttocallcenter depends on:
--- base.clienttoproduct
--- base.product
--- base.client

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_clientproducttocallcenter');
    execution_start datetime default getdate();

   

begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$
                    select
                        cp.clienttoproductid,
                        '36334343-0000-0000-0000-000000000000' as CallCenterID,
                        1 as ActiveFlag,
                        cp.sourcecode,
                        getdate() as LastUpdateDate
                    from
                        base.clienttoproduct as CP
                        join base.product as P on cp.productid = p.productid
                        join base.client as c on c.clientid = cp.clientid
                    where (p.productcode IN ('PDCHSP') or (p.productcode IN ('MAP') and ClientCode IN ('COMO', 'PAGE1SLN')))
                    $$;

--- insert Statement
insert_statement := '
    insert (
        ClientProductToCallCenterID,
        ClientToProductID,
        CallCenterID,
        ActiveFlag,
        SourceCode,
        LastUpdateDate
    )
    values (
        utils.generate_uuid(source.clienttoproductid || source.callcenterid),
        source.clienttoproductid, 
        source.callcenterid, 
        source.activeflag, 
        source.sourcecode, 
        source.lastupdatedate
    )'; 

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.clientproducttocallcenter as target using 
                   ('||select_statement||') as source 
                   on source.clienttoproductid = target.clienttoproductid
                   and source.callcenterid = target.callcenterid
                   when not matched then'||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    delete from base.clientproducttocallcenter
    where callcenterid = '36334343-0000-0000-0000-000000000000';
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

            raise;
end;
