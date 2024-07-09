CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTRAINING(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertraining depends on: 
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.training

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertraining');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
  -- select Statement
  select_statement := $$
                        with cte_training as (
                            select
                                p.ref_provider_code as providercode,
                                to_varchar(json.value:TRAINING_CODE) as training_TrainingCode,
                                to_varchar(json.value:TRAINING_LINK) as training_TrainingLink,
                                to_varchar(json.value:DATA_SOURCE_CODE) as training_SourceCode,
                                to_timestamp_ntz(json.value:UPDATED_DATETIME) as training_LastUpdateDate
                            from $$||mdm_db||$$.mst.provider_profile_processing as p,
                            lateral flatten(input => p.PROVIDER_PROFILE:TRAINING) as json
                            qualify row_number() over (partition by providercode, training_TrainingCode order by training_LastUpdateDate desc) = 1
                        )
                        
                        select distinct
                            p.providerid,
                            t.trainingid,
                            json.training_TrainingLink as TrainingLink,
                            ifnull(json.training_SourceCode, 'Profisee') as SourceCode,
                            ifnull(json.training_LastUpdateDate, current_timestamp()) as LastUpdateDate
                        from cte_training as json
                        join base.provider as p on p.providercode = json.providercode
                        join base.training as t on t.trainingcode = json.training_TrainingCode
                     $$;




--- insert Statement
insert_statement := ' insert 
                        (ProviderTrainingId,
                          ProviderId, 
                          TrainingId,
                          TrainingLink,
                          SourceCode,
                          LastUpdateDate
                        )
                        values (
                          utils.generate_uuid(source.providerid || source.trainingid), 
                          source.providerid,
                          source.trainingid,
                          source.traininglink,
                          source.sourcecode,
                          source.lastupdatedate)';

update_statement := 'update set
                        target.TrainingLink = source.TrainingLink,
                        target.SourceCode = source.SourceCode,
                        target.LastUpdateDate = source.LastUpdateDate';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providertraining as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid and source.trainingid = target.trainingid
                   when matched then '||update_statement||'
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderTraining;
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