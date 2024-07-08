CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_IMAGE(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.image depends on:
--- mdm_team.mst.facility_profile_processing 
--- base.facility
--- base.clienttoproduct

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the insert
    insert_statement string; -- insert statement 
    update_statement string; -- update
    merge_statement string;
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_image');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
begin
  
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement

-- if conditionals:
select_statement := $$ WITH CTE_CustomerProduct AS (
                                SELECT
                                    p.ref_facility_code AS facilitycode,
                                    TO_VARCHAR(json.value: CUSTOMER_PRODUCT_CODE) AS CustomerProduct_CustomerProductCode,
                                    TO_VARCHAR(json.value: FEATURE_FCFLOGO) AS CustomerProduct_FeatureFcfLogo,
                                    TO_VARCHAR(json.value: DATA_SOURCE_CODE) AS CustomerProduct_SourceCode,
                                    TO_TIMESTAMP_NTZ(json.value: UPDATED_DATETIME) AS CustomerProduct_LastUpdateDate
                                FROM $$ || mdm_db || $$.mst.facility_profile_processing AS p,
                                     LATERAL FLATTEN(input => p.FACILITY_PROFILE:CUSTOMER_PRODUCT) AS json
                                where CustomerProduct_FeatureFcfLogo is not null
                            ),
                            cte_image_1 as (select
                                customerproduct_FeatureFCFLOGO as ImageFilePath,
                                customerproduct_sourcecode as sourcecode,
                                CustomerProduct_LastUpdateDate as lastupdatedate
                            from cte_customerproduct as json
                                join base.facility as f on f.facilitycode = json.facilitycode
                                join base.clienttoproduct as cp on cp.clienttoproductcode = json.CustomerProduct_CustomerProductCode
                            qualify row_number() over(partition by ImageFilePath order by CustomerProduct_LastUpdateDate desc) = 1),
                            
                            CTE_Image AS (
                                SELECT
                                    p.ref_facility_code AS facilitycode,
                                    TO_VARCHAR(json.value: S3_PREFIX) AS Image_Path,
                                    TO_VARCHAR(json.value: FACILITY_IMAGE_FILE_NAME) AS Image_FileName,
                                    TO_VARCHAR(json.value: MEDIA_IMAGE_TYPE_CODE) AS Image_TypeCode,
                                    TO_VARCHAR(json.value: DATA_SOURCE_CODE) AS Image_SourceCode,
                                    TO_TIMESTAMP_NTZ(json.value: UPDATED_DATETIME) AS Image_LastUpdateDate
                                FROM mdm_Team.mst.facility_profile AS p,
                                     LATERAL FLATTEN(input => p.FACILITY_PROFILE:IMAGE) AS json
                                where TO_VARCHAR(json.value: S3_PREFIX) is not null
                                    and TO_VARCHAR(json.value: FACILITY_IMAGE_FILE_NAME) is not null
                            ),
                            cte_image_2 as (select distinct
                                '/' || image_path|| '/'||image_filename as imagefilepath,
                                image_sourcecode as sourcecode,
                                image_lastupdatedate as lastupdatedate
                            from cte_image
                            qualify row_number() over(partition by ImageFilePath order by LastUpdateDate desc) = 1),
                            cte_union as (
                                select
                                    imagefilepath,
                                    sourcecode,
                                    lastupdatedate
                                from cte_image_1
                                union all
                                select 
                                    imagefilepath,
                                    sourcecode,
                                    lastupdatedate
                                from cte_image_2
                            )
                            select distinct
                                imagefilepath,
                                sourcecode,
                                lastupdatedate
                            from cte_union $$;

update_statement := ' update
                        set
                            target.sourcecode = source.sourcecode,
                            target.lastupdatedate = source.lastupdatedate';

insert_statement := ' insert
                        (ImageId,
                        ImageFilePath,
                        sourcecode,
                        LastUpdateDate)
                      values
                        (utils.generate_uuid(source.imagefilepath), -- done
                        source.imagefilepath,
                        source.sourcecode,
                        source.lastupdatedate)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement:= ' merge into base.image as target using 
                   ('||select_statement||') as source 
                   on source.imagefilepath = target.imagefilepath 
                   when matched then ' || update_statement || '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.Image;
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