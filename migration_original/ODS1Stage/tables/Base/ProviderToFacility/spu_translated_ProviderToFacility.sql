CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOFACILITY(is_full BOOLEAN)
    RETURNS STRING
LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertofacility depends on:
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.facility

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update
    merge_statement string;
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertofacility');
    execution_start datetime default getdate();
    mdm_db string default ('mdm_team');
   
begin


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$
with cte_facility as (
    SELECT
        p.ref_provider_code as providercode,
        to_varchar(json.value:FACILITY_CODE) as Facility_FacilityCode,
        to_varchar(json.value:DATA_SOURCE_CODE) as Facility_SourceCode,
        to_timestamp_ntz(json.value:UPDATED_DATETIME) as Facility_LastUpdateDate,
        to_varchar(json.value:CUSTOMER_PRODUCT) as Facility_CustomerProduct
    FROM $$||mdm_db||$$.mst.provider_profile_processing as p
    , lateral flatten(input => p.PROVIDER_PROFILE:FACILITY) as json
)
select distinct 
    p.providerid,
    f.facilityid,
    ifnull(cte.Facility_SourceCode, 'Profisee') as SourceCode,
    ifnull(cte.Facility_LastUpdateDate, current_timestamp()) as LastUpdateDate
from cte_facility as cte
    inner join base.provider as P on cte.providercode = p.providercode
    inner join base.facility as F on cte.Facility_FacilityCode = f.facilitycode
qualify row_number() over(partition by providerid, facilityid order by Facility_LastUpdateDate desc ) = 1
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

--- update statement                       
update_statement := ' update
                        set
                            target.SourceCode = source.sourcecode,
                            target.LastUpdateDate = source.lastupdatedate';
                            
                        
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providertofacility as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid and source.facilityid = target.facilityid
                   when matched then ' || update_statement || '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToFacility;
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