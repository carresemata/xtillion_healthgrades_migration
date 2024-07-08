CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_OFFICEHOURS(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.officehours depends on: 
--- mdm_team.mst.office_profile_processing (raw.vw_office_profile)
--- base.office
--- base.daysofweek

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement_1 string; -- cte and select statement for the merge
    select_statement_2 string; 
    update_statement string; -- update statement for the merge
    update_clause string; -- where condition for update
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_officehours');
    execution_start datetime default getdate();

   
begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement_1 := $$ WITH CTE_Hours AS (
    SELECT
        p.ref_office_code AS officecode,
        TO_VARCHAR(json.value: DAYS_OF_WEEK_CODE) AS Hours_DaysOfWeekCode,
        TO_VARCHAR(json.value: OPENING_TIME) AS Hours_OpeningTime,
        TO_VARCHAR(json.value: CLOSING_TIME) AS Hours_ClosingTime,
        TO_BOOLEAN(json.value: IS_CLOSED) AS Hours_IsClosed,
        TO_BOOLEAN(json.value: IS_OPEN_24_HOURS) AS Hours_IsOpen24Hours,
        TO_VARCHAR(json.value: DATA_SOURCE_CODE) AS Hours_SourceCode,
        TO_TIMESTAMP_NTZ(json.value: UPDATED_DATETIME) AS Hours_LastUpdateDate
    FROM mdm_team.mst.office_profile_processing AS p,
         LATERAL FLATTEN(input => p.OFFICE_PROFILE:HOURS) AS json
    where TO_VARCHAR(json.value: DAYS_OF_WEEK_CODE) is not null
),
cte_swimlane as (
    select
        o.officeid,
        dw.daysofweekid,
        ifnull(json.hours_LastUpdateDate, sysdate()) as LastUpdateDate,
        case when json.hours_ClosingTime = 'None' or json.hours_ClosingTime is null then '00:00' else json.hours_ClosingTime end as OfficeHoursClosingTime, 
    	case when json.hours_OpeningTime = 'None' or json.hours_OpeningTime is null then '00:00' else json.hours_OpeningTime end as OfficeHoursOpeningTime,  
    	case when json.hours_IsClosed is null and json.hours_OpeningTime is not null then 0 when json.hours_IsClosed is null then 1 else json.hours_IsClosed end as OfficeIsClosed,
    	ifnull(json.hours_IsOpen24Hours, FALSE) as OfficeIsOpen24Hours, 
    	ifnull( json.hours_SourceCode , 'Profisee' ) as SourceCode, 
    	json.officecode,
        row_number() over(partition by o.officeid, dw.daysofweekid order by hours_LastUpdateDate desc) as RowRank 
    from cte_hours as json
        join base.office as o on o.officecode = json.officecode
        join base.daysofweek as DW on dw.daysofweekcode = json.hours_DaysOfWeekCode
),

CTE_NotExists as (
select 1
                from CTE_swimlane as s
                inner join base.office as O on o.officeid = s.officeid
                inner join base.daysofweek as DW on dw.daysofweekid = s.daysofweekid
                inner join base.officehours as OH on oh.officeid = s.officeid and oh.daysofweekid = dw.daysofweekid
                where oh.officeid = o.officeid and oh.daysofweekid = dw.daysofweekid
),

CTE_DeleteOfficeHours as (
select distinct
	o.officeid
from CTE_Swimlane as S
	inner join base.office as O on o.officecode = s.officecode 
	inner join base.daysofweek as DW on dw.daysofweekid = s.daysofweekid
where not exists (select * from CTE_NotExists)) $$;

select_statement_2 := select_statement_1 || $$ 
select distinct
	OfficeID, 
	SourceCode, 
	DaysOfWeekID, 
	OfficeHoursOpeningTime, 
	OfficeHoursClosingTime,
	OfficeIsClosed, 
	OfficeIsOpen24Hours, 
	LastUpdateDate
from CTE_swimlane
where 
	RowRank = 1   $$;



--- update Statement
update_statement := ' update
					   SET
                    	target.sourcecode = source.sourcecode, 
                    	target.officehoursopeningtime = source.officehoursopeningtime, 
                    	target.officehoursclosingtime = source.officehoursclosingtime, 
                    	target.officeisclosed = source.officeisclosed, 
                    	target.officeisopen24Hours = source.officeisopen24Hours, 
                    	target.lastupdatedate = source.lastupdatedate';
                            
-- update Clause
update_clause := $$ target.sourcecode != source.sourcecode
or ifnull(target.officehoursopeningtime, '08:00:00.0000000') != ifnull(source.officehoursopeningtime, '08:00:00.0000000')
or ifnull(target.officehoursclosingtime, '17:00:00.0000000') != ifnull(source.officehoursclosingtime, '17:00:00.0000000')
or ifnull(target.officeisclosed, 1) != ifnull(source.officeisclosed, 1)
or ifnull(target.officeisopen24Hours, 0) != ifnull(source.officeisopen24Hours, 0) $$;                        
        
--- insert Statement
insert_statement := 'insert ( 
    OfficeHoursID, 
	OfficeID, 
	SourceCode, 
	DaysOfWeekID, 
	OfficeHoursOpeningTime, 
	OfficeHoursClosingTime,
	OfficeIsClosed, 
	OfficeIsOpen24Hours, 
	LastUpdateDate)

values (
    utils.generate_uuid(source.officeid || source.daysofweekid), -- done
    source.officeid, 
	source.sourcecode, 
	source.daysofweekid, 
	source.officehoursopeningtime, 
	source.officehoursclosingtime,
	source.officeisclosed, 
	source.officeisopen24Hours, 
	source.lastupdatedate)';


    
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := ' merge into base.officehours as target using 
                   ('||select_statement_2 ||') as source 
                   on source.officeid = target.officeid and source.daysofweekid = target.daysofweekid
		           WHEN MATCHED and target.officeid IN (' || select_statement_1 || ' select OfficeId from CTE_DeleteOfficeHours ) then delete
                   WHEN MATCHED and' || update_clause || 'then '||update_statement|| '
                   when not matched then '||insert_statement ;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.OfficeHours;
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