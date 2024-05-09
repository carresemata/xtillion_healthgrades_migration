CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERIMAGE() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
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
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providerimage');
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
                            raw.vw_PROVIDER_PROFILE as JSON
                            left join base.provider as P on p.providercode = json.providercode
                            left join base.mediaimagehost as M on json.image_MediaImageHostCode = m.mediaimagehostcode
                            left join base.mediaimagetype as MT on mt.mediaimagetypecode = json.image_MediaImageTypeCode
                            left join base.mediasize as MS on ms.mediasizecode = json.image_MediaSizeCode
                            left join base.mediareviewlevel as MRL on mrl.mediareviewlevelcode = json.image_MediaReviewLevelCode
                            left join base.mediacontexttype as MCT on mct.mediacontexttypecode = json.image_MediaContextTypeCode    
                        where
                            PROVIDER_PROFILE is not null
                            and Image_ImageFileName is not null
                            and ProviderID is not null 
                        qualify row_number() over( partition by ProviderID, Image_MediaImageTypeCode, Image_MediaSizeCode, Image_MediaContextTypeCode, Image_MediaImageHostCode order by CREATE_DATE desc) = 1$$;


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
