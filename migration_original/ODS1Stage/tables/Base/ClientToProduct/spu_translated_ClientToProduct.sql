CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CLIENTTOPRODUCT(is_full BOOLEAN)
RETURNS STRING
LANGUAGE SQL
EXECUTE as CALLER
as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
--- base.clienttoproduct depends on:
-- mdm_team.mst.customer_product_profile_processing (base.vw_swimlane_base_client)
-- base.client
-- base.product

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

select_statement string;
insert_statement string; 
merge_statement string;
status string; -- status monitoring
procedure_name varchar(50) default('sp_load_clienttoproduct');
execution_start datetime default getdate();


begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------   
select_statement := $$
                    select
                        s.customerproductcode as ClientToProductCode,
                        c.clientid,
                        p.productid,
                        ifnull(s.activeflag, true) as ActiveFlag,
                        ifnull(s.sourcecode, 'Profisee') as SourceCode,
                        ifnull(s.lastupdatedate, sysdate()) as LastUpdateDate,
                        s.queuesize,
                        -- s.reltioentityid
                    from base.vw_swimlane_base_client s
                    inner join base.client c on c.clientcode = s.clientcode 
                    inner join base.product p on p.productcode = s.productcode
                    where
                        s.customerproductcode is not null
                    $$;


insert_statement := $$ 
                    insert  
                        (ClientToProductID,
                         ClientToProductCode,
                         ClientID, 
                         ProductID, 
                         ActiveFlag, 
                         SourceCode, 
                         LastUpdateDate, 
                         QueueSize
                         )
                    values 
                        (uuid_string(),
                        source.clienttoproductcode,
                        source.clientid,
                        source.productid,
                        source.activeflag,
                        source.sourcecode,
                        source.lastupdatedate,
                        source.queuesize
                        )
                    $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := $$ merge into base.clienttoproduct as target using 
                   ($$||select_statement||$$) as source 
                   on source.clienttoproductcode = target.clienttoproductcode
                   when not matched then $$||insert_statement;

    
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ClientToProduct;
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