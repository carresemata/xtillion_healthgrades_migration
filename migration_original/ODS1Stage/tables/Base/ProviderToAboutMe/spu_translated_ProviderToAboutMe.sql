CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOABOUTME()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertoaboutme depends on: 
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.aboutme

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertoaboutme');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ select
                        p.providerid,
                        ifnull(json.aboutme_Sourcecode, 'Profisee') as SourceCode,
                        a.aboutmeid,
                        json.aboutme_AboutMeText as ProviderAboutMeText,
                        a.displayorder as CustomDisplayOrder,
                        ifnull(json.aboutme_LastUpdateDate, current_timestamp()) as LastUpdateDate
                    from raw.vw_PROVIDER_PROFILE as JSON
                          left join base.provider P on json.providercode = p.providercode
                          left join base.aboutme A on json.aboutme_AboutMeCode = a.aboutmecode
                    where 
                        json.provider_PROFILE is not null and
                        ProviderId is not null and
                        AboutMeId is not null and
                        AboutMe_AboutMeText is not null
                    qualify row_number() over (partition by ProviderId, AboutMe_AboutMeCode order by CREATE_DATE desc) = 1 $$ ;



--- insert Statement
insert_statement := ' insert  
                        (ProviderToAboutMeID,
                        ProviderID,
                        SourceCode,
                        AboutMeID,
                        ProviderAboutMeText,
                        CustomDisplayOrder,
                        LastUpdatedDate)
                      values 
                        (uuid_string(),
                        source.providerid,
                        source.sourcecode,
                        source.aboutmeid,
                        source.provideraboutmetext,
                        source.customdisplayorder,
                        source.lastupdatedate)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providertoaboutme as target using 
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