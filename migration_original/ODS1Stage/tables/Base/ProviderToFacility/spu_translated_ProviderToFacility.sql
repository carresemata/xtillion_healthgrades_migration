CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOFACILITY()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertofacility depends on:
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.facility

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string;
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertofacility');
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
select_statement := $$
select distinct 
    p.providerid,
    f.facilityid,
    ifnull(json.facility_SourceCode, 'Profisee') as SourceCode,
    ifnull(json.facility_LastUpdateDate, current_timestamp()) as LastUpdateDate
from raw.vw_PROVIDER_PROFILE as JSON
    left join base.provider as P on json.providercode = p.providercode
    left join base.facility as F on json.facility_FacilityCode = f.facilitycode
where json.provider_PROFILE is not null
  and json.facility_FacilityCode is not null
  and ProviderID is not null
  and FacilityID is not null
qualify row_number() over (partition by ProviderId, Facility_FacilityCode order by CREATE_DATE desc) = 1
$$;

--- insert Statement
insert_statement := ' insert 
                        (ProviderToFacilityId, 
                        ProviderId, 
                        FacilityId, 
                        --ProviderRoleId, 
                        --HonorRollTypeId, 
                        SourceCode, 
                        LastUpdateDate)
                    values 
                        (uuid_string(), 
                        source.providerid, 
                        source.facilityid, 
                        --source.providerroleid, 
                        --source.honorrolltypeid, 
                        source.sourcecode, 
                        source.lastupdatedate)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providertofacility as target using 
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