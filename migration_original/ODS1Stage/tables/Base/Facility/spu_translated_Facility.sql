CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_FACILITY(is_full BOOLEAN)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

--- base.facility depends on:   
--- mdm_team.mst.facility_profile_processing 

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_facility');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$  select
                            ifnull(TO_VARCHAR(FACILITY_PROFILE:DEMOGRAPHICS[0].FACILITY_CODE), ref_facility_code) as Facilitycode,
                            replace(TO_VARCHAR(FACILITY_PROFILE:DEMOGRAPHICS[0].FACILITY_NAME) , '&amp;' , '&') as FacilityName,
                            ifnull(TO_VARCHAR(FACILITY_PROFILE:DEMOGRAPHICS[0].DATA_SOURCE_CODE), 'Profisee') as sourcecode,
                            ifnull(TO_TIMESTAMP_NTZ(FACILITY_PROFILE:DEMOGRAPHICS[0].UPDATED_DATETIME), current_timestamp()) as lastupdatedate,
                            TO_VARCHAR(FACILITY_PROFILE:DEMOGRAPHICS[0].LEGACY_KEY) AS LegacyKey,
                            TO_BOOLEAN(FACILITY_PROFILE:DEMOGRAPHICS[0].IS_CLOSED) AS IsClosed
                        from $$ || mdm_db || $$.mst.facility_profile_processing
                        where 
                            length(facilitycode) <= 10  $$;

--- update Statement
update_statement := '
update
SET
    facilityname = source.facilityname,
    sourcecode = source.sourcecode,
    legacykey = source.legacykey,
    lastupdatedate = source.lastupdatedate,
    isclosed = source.isclosed';

--- insert Statement
insert_statement := ' insert
    (
        FacilityID, 
        FacilityCode,
        FacilityName, 
        SourceCode, 
        LastUpdateDate, 
        LegacyKey, 
        IsClosed
    )
values
    (
        utils.generate_uuid(source.FacilityCode), -- done
        source.FacilityCode,
        source.FacilityName, 
        source.SourceCode, 
        source.LastUpdateDate, 
        source.LegacyKey, 
        source.IsClosed
    )';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.facility as target using 
                   ('||select_statement||') as source 
                   on source.facilitycode = target.facilitycode
                   WHEN MATCHED then '||update_statement||'
                   when not matched then'||insert_statement;
                   
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 

if (is_full) then
    truncate table base.facility;
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