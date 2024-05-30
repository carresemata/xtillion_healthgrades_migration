CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_LINEOFSERVICE(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- mid.lineofservice depends on:
--- base.lineofservice
--- base.lineofservicetype
--- base.specialtygroup

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_lineofservice');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------   

--- select Statement
select_statement := $$ 
                    with CTE_LineofService as (
                    select
                        baseline.lineofserviceid,
                        baseline.lineofservicecode,
                        basetype.lineofservicetypecode,
                        baseline.lineofservicedescription,
                        basespec.legacykey,
                        basespec.specialtygroupdescription as LegacyKeyName,
                        0 as ActionCode
                    from
                        base.lineofservice BaseLine
                        join base.lineofservicetype BaseType on baseline.lineofservicetypeid = basetype.lineofservicetypeid
                        join base.specialtygroup BaseSpec on baseline.lineofservicecode = basespec.specialtygroupcode
                ),
                --- insert Action
                CTE_Action_1 as (
                    select
                        CTE_lineofservice.lineofserviceid,
                        1 as ActionCode
                    from
                        CTE_LineOfService
                        left join mid.lineofservice MidLine on midline.lineofserviceid = CTE_lineofservice.lineofserviceid
                        and midline.lineofservicecode = CTE_lineofservice.lineofservicecode
                        and midline.lineofservicetypecode = CTE_lineofservice.lineofservicetypecode
                    where
                        CTE_lineofservice.lineofserviceid is null
                ),
                -- update Action
                CTE_Action_2 as (
                    select
                        CTE_lineofservice.lineofserviceid,
                        2 as ActionCode
                    from
                        CTE_LineOfService
                        join mid.lineofservice MidLine on midline.lineofserviceid = CTE_lineofservice.lineofserviceid
                        and midline.lineofservicecode = CTE_lineofservice.lineofservicecode
                        and midline.lineofservicetypecode = CTE_lineofservice.lineofservicetypecode
                    where
                        MD5(
                            ifnull(
                                CTE_lineofservice.lineofservicedescription::varchar,
                                ''''''''
                            )
                        ) <> MD5(
                            ifnull(
                                CTE_lineofservice.lineofservicedescription::varchar,
                                ''''''''
                            )
                        )
                        or MD5(
                            ifnull(CTE_lineofservice.legacykey::varchar, '''''''')
                        ) <> MD5(
                            ifnull(CTE_lineofservice.legacykey::varchar, '''''''')
                        )
                        or MD5(
                            ifnull(
                                CTE_lineofservice.legacykeyname::varchar,
                                ''''''''
                            )
                        ) <> MD5(
                            ifnull(
                                CTE_lineofservice.legacykeyname::varchar,
                                ''''''''
                            )
                        )
                )
                select
                    A0.LineOfServiceID,
                    A0.LineOfServiceCode,
                    A0.LineOfServiceTypeCode,
                    A0.LineOfServiceDescription,
                    A0.LegacyKey,
                    A0.LegacyKeyName,
                    ifnull(A1.ActionCode,ifnull(A2.ActionCode, A0.ActionCode)) as ActionCode
                from
                    CTE_LineOfService A0
                    left join CTE_ACTION_1 A1 on A0.LineOfServiceID = A1.LineOfServiceID
                    left join CTE_ACTION_2 A2 on A0.LineOfServiceID = A2.LineOfServiceID
                where
                    ifnull(A1.ActionCode,ifnull(A2.ActionCode, A0.ActionCode)) <> 0
                    $$;


--- update Statement
update_statement := 'update 
                     SET 
                        LINEOFSERVICEID = source.lineofserviceid, 
                        LINEOFSERVICECODE = source.lineofservicecode, 
                        LINEOFSERVICETYPECODE = source.lineofservicetypecode, 
                        LINEOFSERVICEDESCRIPTION = source.lineofservicedescription, 
                        LEGACYKEY = source.legacykey, 
                        LEGACYKEYNAME = source.legacykeyname';

--- insert Statement
insert_statement := ' insert  
                        (LINEOFSERVICEID,
                        LINEOFSERVICECODE, 
                        LINEOFSERVICETYPECODE, 
                        LINEOFSERVICEDESCRIPTION, 
                        LEGACYKEY, 
                        LEGACYKEYNAME)
                      values 
                        (source.lineofserviceid,
                        source.lineofservicecode, 
                        source.lineofservicetypecode, 
                        source.lineofservicedescription, 
                        source.legacykey, 
                        source.legacykeyname)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.lineofservice as target using 
                   ('||select_statement||') as source 
                   on source.lineofserviceid = target.lineofserviceid
                   WHEN MATCHED and ActionCode = 2 then '||update_statement|| '
                   when not matched and ActionCode = 1 then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.LineOfService;
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