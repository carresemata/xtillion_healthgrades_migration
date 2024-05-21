-- Show_spuSOLRLineOfServiceGenerateFromMid
CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRLINEOFSERVICE() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  

declare 

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- show.solrlineofservice depends on: 
--- mid.lineofservice
--- show.solrlineofservicedelta  

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte statement
    update_statement string;
    insert_statement string;
    merge_statement string; -- insert statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrlineofservice');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL statements ---------------------
---------------------------------------------------------     

-- select Statement
select_statement :=
'with cte_id as (
            select
                distinct LineOfServiceID
            from
                show.solrlineofservicedelta
            where
                StartDeltaProcessDate is null
                and EndDeltaProcessDate is null
                and SolrDeltaTypeCode = 1 --insert/updates
                and MidDeltaProcessComplete = 1
)
select
        midline.lineofserviceid,
        midline.lineofservicecode,
        midline.lineofservicetypecode,
        midline.lineofservicedescription,
        midline.legacykey,
        midline.legacykeyname,
        current_timestamp as UpdatedDate,
        CURRENT_USER as UpdatedSource
    from
        mid.lineofservice midLine
    join
        cte_id on midline.lineofserviceid = cte_id.lineofserviceid'; --this will indicate the Mid tables have been refreshed with the updated data

-- update statement
update_statement :=
'update
SET
    solrline.lineofserviceid = lineservice.lineofserviceid,
    solrline.lineofservicecode = lineservice.lineofservicecode,
    solrline.lineofservicetypecode = lineservice.lineofservicetypecode,
    solrline.lineofservicedescription = lineservice.lineofservicedescription,
    solrline.legacykey = lineservice.legacykey,
    solrline.legacykeyname = lineservice.legacykeyname,
    solrline.updateddate = lineservice.updateddate,
    solrline.updatedsource = lineservice.updatedsource ';
 
-- insert Statement
insert_statement :=
'insert
    (
        LineOfServiceID,
        LineOfServiceCode,
        LineOfServiceTypeCode,
        LineOfServiceDescription,
        LegacyKey,
        LegacyKeyName,
        UpdatedDate,
        UpdatedSource
    )
values
    (
        lineservice.lineofserviceid,
        lineservice.lineofservicecode,
        lineservice.lineofservicetypecode,
        lineservice.lineofservicedescription,
        lineservice.legacykey,
        lineservice.legacykeyname,
        lineservice.updateddate,
        lineservice.updatedsource
    );';
                     
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  
 
-- Merge Statement
merge_statement := 'merge into show.solrlineofservice as solrLine using 
                        (' || select_statement || ') as LineService 
                        on lineservice.lineofserviceid = solrline.lineofserviceid and solrline.lineofservicecode = lineservice.lineofservicecode
                        WHEN MATCHED then '
                            || update_statement ||
                        'when not matched then '
                            || insert_statement ;

---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 
                    
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