CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_IMAGE() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.image depends on:
--- mdm_team.mst.facility_profile_processing (raw.vw_facility_profile)
--- base.facility
--- base.clienttoproduct

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the insert
    insert_statement string; -- insert statement 
    merge_statement string;
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_image');
    execution_start datetime default getdate();

    
   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement

-- if conditionals:
select_statement := $$ with CTE_Swimlane as (select 
                                uuid_string() as URLId,
                                f.facilityid,
                                jsonfacility.facilitycode,
                                ctc.clienttoproductcode,
                                'FCCIURL' as URLTypeCode,
                                jsonfacility.customerproduct_FEATUREFCCLURL as URL,
                                sysdate() as LastUpdateDate,
                                jsonfacility.customerproduct_FEATUREFCFLOGO as FeatureFCFLogo
                            from raw.vw_FACILITY_PROFILE as JSONFacility
                                join base.facility as F on f.facilitycode = jsonfacility.facilitycode
                                join base.clienttoproduct as CTC on ctc.clienttoproductcode = jsonfacility.customerproduct_CUSTOMERPRODUCTCODE
                                
                            where 
                                jsonfacility.facility_PROFILE is not null and
                                jsonfacility.facilitycode is not null and
                                jsonfacility.customerproduct_FEATUREFCCLURL is not null
                            qualify row_number() over(partition by f.facilityid order by jsonfacility.create_DATE desc) = 1),
                            CTE_TempImage as (select distinct
                                FacilityID, 
                                FacilityCode, 
                                ClientToProductCode, 
                                'FCFLOGO' as ImageTypeCode, 
                                'LOGO' as ImageSize, 
                                FeatureFCFLOGO as ImageFilePath 
                            from CTE_Swimlane
                            where FeatureFCFLOGO is not null)
                            select
                                uuid_string() as ImageID,
                                ImageFilePath,
                                sysdate() as LastUpdateDate
                            from CTE_TempImage  $$;


insert_statement := ' insert
                        (ImageId,
                        ImageFilePath,
                        LastUpdateDate)
                      values
                        (source.imageid,
                        source.imagefilepath,
                        source.lastupdatedate)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement:= ' merge into dev.image as target using 
                   ('||select_statement||') as source 
                   on source.imageid = target.imageid 
                   when not matched then '||insert_statement;
                   
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