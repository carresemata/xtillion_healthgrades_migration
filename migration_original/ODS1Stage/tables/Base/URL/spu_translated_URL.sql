CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_URL(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  

declare 

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.url depends on:
--- mdm_team.mst.facility_profile_processing 
--- base.facility
--- base.clienttoproduct

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
merge_statement string;
status string;
procedure_name varchar(50) default('sp_load_url');
execution_start datetime default getdate();
mdm_db string default('mdm_team');


begin


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- select Statement
select_statement := $$   with Cte_customer_product as (
                            SELECT
                                p.ref_facility_code as facilitycode,
                                to_varchar(json.value:CUSTOMER_PRODUCT_CODE) as CustomerProduct_CustomerProductCode,
                                to_varchar(json.value:FEATURE_FCCLURL) as CustomerProduct_FeatureFcclUrl,
                                to_timestamp_ntz(json.value:UPDATED_DATETIME) as CustomerProduct_LastUpdateDate
                            FROM $$ || mdm_db || $$.mst.facility_profile_processing as p
                            , lateral flatten(input => p.FACILITY_PROFILE:CUSTOMER_PRODUCT) as json
                            where 
                                CustomerProduct_FeatureFcclUrl is not null
                        )
                        
                        select distinct
                                json.CustomerProduct_FeatureFcclUrl as URL,
                                ifnull(json.CustomerProduct_LastUpdateDate, current_timestamp()) as LastUpdateDate
                            from cte_customer_product as json
                                join base.facility as F on f.facilitycode = json.facilitycode
                                join base.clienttoproduct as CTC on ctc.clienttoproductcode = json.CustomerProduct_CustomerProductCode  $$;

insert_statement := ' insert
                       (URLid,
                        URL,
                        LastUpdateDate)
                    values
                        (utils.generate_uuid(source.url), -- done
                        source.url,
                        source.lastupdatedate)';


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------


merge_statement := ' merge into base.url as target 
                    using ('||select_statement||') as source
                    on source.url = target.url
                    when not matched then '||insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.URL;
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