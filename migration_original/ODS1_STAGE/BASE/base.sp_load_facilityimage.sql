CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_FACILITYIMAGE(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.facilityimage depends on: 
--- mdm_team.mst.facility_profile_processing 
--- base.facility
--- base.mediaimagetype
--- base.mediasize
--- base.mediareviewlevel

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_facilityimage');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
   
begin
    

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ with Cte_image as (
                            SELECT
                                p.ref_facility_code as facilitycode,
                                to_varchar(json.value:S3_PREFIX) as Image_Path, 
                                to_varchar(json.value:FACILITY_IMAGE_FILE_NAME) as Image_FileName,
                                to_varchar(json.value:MEDIA_IMAGE_TYPE_CODE) as Image_TypeCode,
                                to_varchar(json.value:MEDIA_SIZE_CODE) as Image_SizeCode,
                                to_varchar(json.value:MEDIA_REVIEW_LEVEL_CODE) as Image_ReviewLevel,
                                to_varchar(json.value:DATA_SOURCE_CODE) as Image_SourceCode,
                                to_timestamp_ntz(json.value:UPDATED_DATETIME) as Image_LastUpdateDate
                            FROM $$ || mdm_db || $$.mst.facility_profile_processing as p
                            , lateral flatten(input => p.FACILITY_PROFILE:IMAGE) as json
                            where
                                image_filename is not null
                        )
                        
                        select distinct
                            facility.facilityid,
                            json.image_FileName as FileName,
                            json.image_Path as ImagePath,
                            mit.mediaimagetypeid,
                            ms.mediasizeid,
                            mrl.mediareviewlevelid,
                            json.Image_SourceCode as SourceCode,
                            ifnull(json.Image_LastUpdateDate, current_timestamp() ) as LastUpdateDate
                        from cte_image as JSON
                            join base.facility as Facility on json.facilitycode = facility.facilitycode 
                            left join base.mediaimagetype as MIT on mit.mediaimagetypecode = json.image_TypeCode
                            left join base.mediasize as MS on ms.mediasizecode = json.image_SizeCode
                            left join base.mediareviewlevel as MRL on mrl.mediareviewlevelcode = json.image_ReviewLevel 
                        qualify row_number() over(partition by facilityid, mediaimagetypeid, mediasizeid, mediareviewlevelid order by json.Image_LastUpdateDate desc) = 1 $$;
                    


--- insert Statement
insert_statement := ' insert  
                        (FacilityImageID, 
                        FacilityID, 
                        FileName, 
                        ImagePath, 
                        MediaImageTypeID, 
                        MediaSizeID, 
                        MediaReviewLevelID, 
                        SourceCode, 
                        LastUpdateDate)
                      values 
                        (utils.generate_uuid(source.facilityid || source.mediaimagetypeid || source.mediasizeid || source.mediareviewlevelid), 
                        source.facilityid, 
                        source.filename, 
                        source.imagepath, 
                        source.mediaimagetypeid, 
                        source.mediasizeid, 
                        source.mediareviewlevelid, 
                        source.sourcecode, 
                        source.lastupdatedate)';

--- update statement
update_statement := ' update
                        set
                            target.FileName = source.filename,
                            target.ImagePath = source.imagepath,
                            target.SourceCode = source.sourcecode,
                            target.LastUpdateDate = source.lastupdatedate
                    ';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.facilityimage as target using 
                   ('||select_statement||') as source 
                   on source.facilityid = target.facilityid and source.mediaimagetypeid = target.mediaimagetypeid and source.mediasizeid = target.mediasizeid and source.mediareviewlevelid = target.mediareviewlevelid
                   when matched then ' || update_statement || '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.FacilityImage;
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

            raise;
end;