CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_URL()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  

declare 

---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
-- base.url depends on:
--- mdm_team.mst.facility_profile_processing (raw.vw_facility_profile)
--- mdm_team.mst.customer_product_profile_processing (raw.vw_customer_product_profile)
--- base.facility
--- base.clienttoproduct

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
merge_statement string;
status string;
    procedure_name varchar(50) default('sp_load_url');
    execution_start datetime default getdate();


---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------  

begin
-- no conditionals

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- select Statement
select_statement := $$  with CTE_swimlane as (select 
                                uuid_string() as URLId,
                                f.facilityid,
                                jsonfacility.facilitycode,
                                ctc.clienttoproductcode,
                                'FCCIURL' as URLTypeCode,
                                jsoncustomer.feature_FeatureFCCLURL as URL,
                                sysdate() as LastUpdateDate
                            from raw.vw_FACILITY_PROFILE as JSONFacility
                                join base.facility as F on f.facilitycode = jsonfacility.facilitycode
                                join base.clienttoproduct as CTC on ctc.clienttoproductcode = jsonfacility.customerproduct_CUSTOMERPRODUCTCODE
                                left join raw.vw_CUSTOMER_PRODUCT_PROFILE as JSONCustomer on jsoncustomer.customerproductcode = jsonfacility.customerproduct_CUSTOMERPRODUCTCODE
                            where 
                                jsonfacility.facility_PROFILE is not null and
                                jsonfacility.facilitycode is not null and
                                jsoncustomer.feature_FeatureFCCLURL is not null
                            qualify row_number() over(partition by f.facilityid order by jsonfacility.create_DATE desc) = 1)
                            select 
                                URLid,
                                URL,
                                LastUpdateDate
                            from CTE_Swimlane  $$;

insert_statement := ' insert
                       (URLid,
                        URL,
                        LastUpdateDate)
                    values
                        (source.urlid,
                        source.url,
                        source.lastupdatedate)';


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------


merge_statement := ' merge into base.url as target 
using ('||select_statement||') as source
on source.urlid = target.urlid 
when not matched then '||insert_statement;

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