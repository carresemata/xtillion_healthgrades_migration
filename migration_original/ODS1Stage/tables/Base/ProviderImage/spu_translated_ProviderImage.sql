CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERIMAGE(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providerimage depends on: 
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.mediaimagehost
--- base.mediaimagetype
--- base.mediasize
--- base.mediareviewlevel
--- base.mediacontexttype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providerimage');
    execution_start datetime default getdate();

    mdm_db string default('mdm_team');

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ 
with Cte_image as (
    SELECT
        p.ref_provider_code as providercode,
        to_varchar(json.value:IDENTIFIER) as Image_Identifier,
        to_varchar(json.value:IMAGE_FILE_NAME) as Image_ImageFileName,
        to_varchar(json.value:MEDIA_IMAGE_TYPE_CODE) as Image_MediaImageTypeCode,
        to_varchar(json.value:MEDIA_REVIEW_LEVEL_CODE) as Image_MediaReviewLevelCode,
        to_varchar(json.value:MEDIA_SIZE_CODE) as Image_MediaSizeCode,
        to_varchar(json.value:MEDIA_IMAGE_HOST_CODE) as Image_MediaImageHostCode,
        to_varchar(json.value:MEDIA_CONTEXT_TYPE_CODE) as Image_MediaContextTypeCode,
        to_varchar(json.value:IMAGE_PATH) as Image_ImagePath,
        to_varchar(json.value:DATA_SOURCE_CODE) as Image_SourceCode,
        to_timestamp_ntz(json.value:UPDATED_DATETIME) as Image_LastUpdateDate
    FROM mdm_team.mst.provider_profile_processing as p
    , lateral flatten(input => p.PROVIDER_PROFILE:IMAGE) as json
)
select distinct
    p.providerid,
    mt.mediaimagetypeid,
    json.image_ImageFileName as FileName,
    ms.mediasizeid,
    mrl.mediareviewlevelid,
    ifnull(json.image_SourceCode, 'Profisee') as SourceCode,
    ifnull(json.image_LastUpdateDate, current_timestamp()) as LastUpdateDate,
    mct.mediacontexttypeid,
    m.mediaimagehostid,
    json.image_Identifier as ExternalIdentifier,
    json.image_ImagePath as ImagePath
from
    Cte_image as JSON
    join base.provider as P on p.providercode = json.providercode
    left join base.mediaimagehost as M on json.image_MediaImageHostCode = m.mediaimagehostcode
    left join base.mediaimagetype as MT on mt.mediaimagetypecode = json.image_MediaImageTypeCode
    left join base.mediasize as MS on ms.mediasizecode = json.image_MediaSizeCode
    left join base.mediareviewlevel as MRL on mrl.mediareviewlevelcode = json.image_MediaReviewLevelCode
    left join base.mediacontexttype as MCT on mct.mediacontexttypecode = json.image_MediaContextTypeCode    

$$;


--- insert Statement
insert_statement := ' insert 
                        (ProviderImageID,
                        ProviderID,
                        MediaImageTypeID,
                        FileName,
                        MediaSizeID,
                        MediaReviewLevelID,
                        SourceCode,
                        LastUpdateDate,
                        MediaContextTypeID,
                        MediaImageHostID,
                        ExternalIdentifier,
                        ImagePath)
                    values
                        (uuid_string(),
                        source.providerid,
                        source.mediaimagetypeid,
                        source.filename,
                        source.mediasizeid,
                        source.mediareviewlevelid,
                        source.sourcecode,
                        source.lastupdatedate,
                        source.mediacontexttypeid,
                        source.mediaimagehostid,
                        source.externalidentifier,
                        source.imagepath)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providerimage as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid
                   WHEN MATCHED then delete
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderImage;
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