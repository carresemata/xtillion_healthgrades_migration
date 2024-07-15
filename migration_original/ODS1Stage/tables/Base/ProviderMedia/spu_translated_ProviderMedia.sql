CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERMEDIA(is_full BOOLEAN)
RETURNS STRING
LANGUAGE SQL
EXECUTE as CALLER
as  
declare
    
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.providermedia depends on the following tables:
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.mediatype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    delete_statement string;
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providermedia');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ with Cte_media as (
SELECT
    p.ref_provider_code as providercode,
    to_varchar(json.value:MEDIA_TYPE_CODE) as Media_MediaTypeCode,
    to_varchar(json.value:MEDIA_DATE) as Media_MediaDate,
    to_varchar(json.value:MEDIA_TITLE) as Media_MediaTitle,
    to_varchar(json.value:MEDIA_PUBLISHER) as Media_MediaPublisher,
    to_varchar(json.value:MEDIA_SYNOPSIS) as Media_MediaSynopsis,
    to_varchar(json.value:MEDIA_LINK) as Media_MediaLink,
    to_varchar(json.value:DATA_SOURCE_CODE) as Media_SourceCode,
    to_timestamp_ntz(json.value:UPDATED_DATETIME) as Media_LastUpdateDate
FROM $$||mdm_db||$$.mst.provider_profile_processing as p
, lateral flatten(input => p.PROVIDER_PROFILE:MEDIA) as json
)
select
    p.providerid,
    mt.mediatypeid,
    json.media_MEDIADATE as MediaDate,
    json.media_MEDIATITLE as MediaTitle,
    json.media_MEDIAPUBLISHER as MediaPublisher,
    json.media_MEDIASYNOPSIS as MediaSynopsis,
    json.media_MEDIALINK as MediaLink,
    ifnull(json.media_SOURCECODE, 'Profisee') as SourceCode,
    ifnull(json.media_LASTUPDATEDATE, current_timestamp()) as LastUpdateDate
from cte_media as JSON
    join base.provider as P on p.providercode = json.providercode
    join base.mediatype as MT on mt.mediatypecode = json.media_MEDIATYPECODE 
qualify row_number() over(partition by ProviderID, media_mediatypecode, media_mediadate, media_MediaLink, media_MediaPublisher, media_MediaSynopsis, media_MediaTitle order by json.media_lastupdatedate desc) = 1 $$;

--- insert Statement
insert_statement := '       insert  
                                    (ProviderMediaId, 
                                    ProviderID,
                                    MediaTypeID,
                                    MediaDate,
                                    MediaTitle,
                                    MediaPublisher,
                                    MediaSynopsis,
                                    MediaLink,
                                    SourceCode,
                                    LastUpdateDate)         
                             values 
                                    (uuid_string(), 
                                    source.providerid,
                                    source.mediatypeid,
                                    source.mediadate,
                                    source.mediatitle,
                                    source.mediapublisher,
                                    source.mediasynopsis,
                                    source.medialink,
                                    source.sourcecode,
                                    source.lastupdatedate)';
        
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  
-- Remove the providers and insert them again to avoid duplicate records
delete_statement := 'delete from base.providermedia as target
                        using ('|| select_statement ||') AS source
                        where target.providerid = source.providerid;';

merge_statement := 'merge into base.providermedia as target 
                    using (' || select_statement || ') as source
                   on source.providerid = target.providerid 
                   when not matched then '||insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderMedia;
end if; 
execute immediate delete_statement ;
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