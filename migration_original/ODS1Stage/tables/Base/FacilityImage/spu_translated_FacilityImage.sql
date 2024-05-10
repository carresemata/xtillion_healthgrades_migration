CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_FACILITYIMAGE() -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
    
-- base.facilityimage depends on: 
--- mdm_team.mst.facility_profile_processing (raw.vw_facility_profile)
--- base.facility
--- base.entitytype
--- base.mediaimagetype
--- base.mediasize
--- base.mediareviewlevel

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_facilityimage');
    execution_start datetime default getdate();

   
---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------   
   
begin
    -- no conditionals


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ select distinct
                            SHA1(to_varchar(facility.facilityid) || entity.entitytypecode || Image_TypeCode || Image_FileName) as FacilityImageID,
                            facility.facilityid,
                            json.image_FileName as FileName,
                            json.image_Path as ImagePath,
                            mit.mediaimagetypeid,
                            ms.mediasizeid,
                            mrl.mediareviewlevelid,
                            'MergeFacilityImage' as SourceCode
                            
                        from raw.vw_FACILITY_PROFILE as JSON
                        left join base.facility as Facility on json.facilitycode = facility.facilitycode 
                        left join base.entitytype Entity on entity.entitytypecode = 'FAC'
                        left join base.mediaimagetype as MIT on mit.mediaimagetypecode = json.image_TypeCode
                        left join base.mediasize as MS on ms.mediasizecode = json.image_SizeCode
                        left join base.mediareviewlevel as MRL on mrl.mediareviewlevelcode = json.image_ReviewLevel
                        where 
                            FACILITY_PROFILE is not null and
                            FileName is not null and
                            FacilityID is not null
                        qualify row_number() over(partition by facility.facilityid, MediaImageTypeID, MediaSizeid order by CREATE_DATE desc) = 1 $$;



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
                        (source.facilityimageid, 
                        source.facilityid, 
                        source.filename, 
                        source.imagepath, 
                        source.mediaimagetypeid, 
                        source.mediasizeid, 
                        source.mediareviewlevelid, 
                        source.sourcecode, 
                        current_timestamp())';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.facilityimage as target using 
                   ('||select_statement||') as source 
                   on source.facilityid = target.facilityid
                   WHEN MATCHED then delete
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