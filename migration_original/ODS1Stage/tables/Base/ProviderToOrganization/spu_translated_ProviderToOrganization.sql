CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOORGANIZATION(is_full BOOLEAN)
RETURNS STRING
LANGUAGE SQL EXECUTE
as CALLER
as declare 

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.providertoorganization depends on:
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
merge_statement string;
status string;
    procedure_name varchar(50) default('sp_load_providertoorganization');
    execution_start datetime default getdate();



begin


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

select_statement := $$
                    select
                        ifnull(json.organization_SourceCode, 'Profisee') as SourceCode,
                        uuid_string() as ProviderToOrganizationID,
                        p.providerid as ProviderID,
                        -- OrganizationID,
                        -- PositionID,
                        -- PositionStartDate,
                        -- PositionEndDate,
                        json.organization_PositionRank as PositionRank,
                        sysdate() as LastUpdateDate,
                        CURRENT_USER() as InsertedBy
                    from raw.vw_PROVIDER_PROFILE as JSON
                    left join base.provider as p on p.providercode = json.providercode
                    where p.providerid is not null
                    $$;


insert_statement := $$ 
                     insert  
                       (   
                        SourceCode,
                        ProviderToOrganizationID,
                        ProviderID,
                        -- OrganizationID,
                        -- PositionID,
                        -- PositionStartDate,
                        -- PositionEndDate,
                        PositionRank,
                        LastUpdateDate,
                        InsertedBy
                        )
                      values 
                        (   
                        source.sourcecode,
                        source.providertoorganizationid,
                        source.providerid,
                        -- source.organizationid,
                        -- source.positionid,
                        -- source.positionstartdate,
                        -- source.positionenddate,
                        source.positionrank,
                        source.lastupdatedate,
                        source.insertedby
                        )
                     $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := $$ merge into base.providertoorganization as target 
                    using ($$||select_statement||$$) as source 
                   on source.providerid = target.providerid
                   WHEN MATCHED then delete
                   when not matched then $$ ||insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToOrganization;
end if; 
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