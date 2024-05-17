-- spuSOLRGeographicAreaGenerateFromMid
CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRGEOGRAPHICAREA() 
    RETURNS STRING
    LANGUAGE SQL
    as  

declare 

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- show.solrgeographicarea depends on: 
--- show.solrgeographicareadelta
--- mid.geographicarea

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte statement
    update_statement string;
    insert_statement string;
    merge_statement string; -- insert statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrgeographicarea');
    execution_start datetime default getdate();


   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL statements ---------------------
---------------------------------------------------------     

-- select Statement
select_statement := 'with CTE_geoId as (select
    distinct GeographicAreaID
from
    show.solrgeographicareadelta
where
    StartDeltaProcessDate is null
    and EndDeltaProcessDate is null
    and SolrDeltaTypeCode = 1 --insert/updates
    and MidDeltaProcessComplete = 1 ) --this will indicate the Mid TABLEs have been refreshed with the updated data

select
            midgeo.geographicareaid,
            midgeo.geographicareacode,
            midgeo.geographicareatypecode,
            midgeo.geographicareavalue,
            current_timestamp as UpdatedDate,
            CURRENT_USER as UpdatedSource
        from
            mid.geographicarea midGeo
            join CTE_geoId as geoId on geoid.geographicareaid = midgeo.geographicareaid';

-- update Statement
update_statement := 
'update
SET
    solrgeo.geographicareaid = geoarea.geographicareaid,
    solrgeo.geographicareacode = geoarea.geographicareacode,
    solrgeo.geographicareatypecode = geoarea.geographicareatypecode,
    solrgeo.geographicareavalue = geoarea.geographicareavalue,
    solrgeo.updateddate = geoarea.updateddate,
    solrgeo.updatedsource = geoarea.updatedsource';

-- insert Statement 
insert_statement := 
'insert
    (
        GeographicAreaID,
        GeographicAreaCode,
        GeographicAreaTypeCode,
        GeographicAreaValue,
        UpdatedDate,
        UpdatedSource
    )
values
    (
        geoarea.geographicareaid,
        geoarea.geographicareacode,
        geoarea.geographicareatypecode,
        geoarea.geographicareavalue,
        geoarea.updateddate,
        geoarea.updatedsource
    );';
                     
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := 
'merge into show.solrgeographicarea as solrGeo using 
    (' || select_statement || ') as GeoArea 
    on geoarea.geographicareaid = solrgeo.geographicareaid
    WHEN MATCHED then '
        || update_statement ||
    ' when not matched then ' 
        || insert_statement ;

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
