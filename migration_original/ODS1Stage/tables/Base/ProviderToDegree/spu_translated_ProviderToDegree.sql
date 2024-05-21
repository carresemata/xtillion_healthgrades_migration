CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTODEGREE()
RETURNS STRING
LANGUAGE SQL EXECUTE
as CALLER
as declare 

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.providertodegree depends on:
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.degree

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
merge_statement string;
status string;
    procedure_name varchar(50) default('sp_load_providertodegree');
    execution_start datetime default getdate();



begin


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

select_statement := $$                 
                    select 
                        uuid_string() as ProviderToDegreeID,
                        p.providerid,
                        json.degree_DegreeCode as DegreeID,
                        json.degree_DegreeRank as DegreePriority,
                        ifnull(json.degree_SourceCode, 'Profisee') as SourceCode,
                        ifnull(json.degree_LastUpdateDate, sysdate()) as LastUpdateDate
                    from raw.vw_PROVIDER_PROFILE as JSON
                    left join base.provider p on p.providercode = json.providercode
                    left join base.degree d on d.degreeabbreviation = json.degree_DegreeCode
                    where json.provider_PROFILE is not null 
                    qualify row_number() over (partition by ProviderId, json.degree_DegreeCode order by json.create_Date desc) = 1
                    $$;


insert_statement := $$ 
                     insert  
                       (   
                        ProviderToDegreeID,
                        ProviderId,
                        DegreeId, 
                        DegreePriority,
                        SourceCode,
                        LastUpdateDate
                        )
                      values 
                        (   
                        source.providertodegreeid,
                        source.providerid,
                        source.degreeid,
                        source.degreepriority,
                        source.sourcecode,
                        source.lastupdatedate
                        )
                     $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := $$ merge into base.providertodegree as target 
                    using ($$||select_statement||$$) as source 
                   on source.providerid = target.providerid
                   when not matched then $$ ||insert_statement;

---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 

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