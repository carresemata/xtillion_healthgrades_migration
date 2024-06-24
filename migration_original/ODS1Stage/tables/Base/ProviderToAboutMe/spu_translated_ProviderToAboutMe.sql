CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOABOUTME(is_full BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertoaboutme depends on: 
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.aboutme

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertoaboutme');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
   
begin
    

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ WITH Cte_about_me as (
                        SELECT
                            p.ref_provider_code as providercode,
                            to_varchar(json.value:ABOUT_ME_CODE ) as  aboutme_aboutmecode,
                            to_varchar(json.value:ABOUT_ME_TEXT ) as  aboutme_aboutmetext,
                            to_varchar(json.value:DATA_SOURCE_CODE ) as aboutme_sourcecode,
                            to_varchar(json.value:UPDATED_DATETIME ) as aboutme_lastupdatedate
                        FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
                            , lateral flatten (input => p.PROVIDER_PROFILE:ABOUT_ME ) as json
                    )
                    select
                        p.providerid,
                        ifnull(aboutme_sourcecode, 'Profisee') as SourceCode,
                        a.aboutmeid,
                        aboutme_aboutmetext as ProviderAboutMeText,
                        a.displayorder as CustomDisplayOrder,
                        ifnull(aboutme_lastupdatedate, current_timestamp()) as LastUpdateDate
                    from cte_about_me as JSON
                          inner join base.provider P on json.providercode = p.providercode
                          inner join base.aboutme A on aboutme_aboutmecode = a.aboutmecode
                    qualify row_number() over(partition by providerid, aboutmeid order by aboutme_lastupdatedate desc) = 1 $$;



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

--- update statement
update_statement := ' 
    update
    set
        target.SourceCode = source.sourcecode,
        target.ProviderAboutMeText = source.provideraboutmetext,
        target.CustomDisplayOrder = source.customdisplayorder,
        target.LastUpdatedDate = source.lastupdatedate
';
                        
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providertoaboutme as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid and source.aboutmeid = target.aboutmeid
                   when matched then ' || update_statement || '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToAboutMe;
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