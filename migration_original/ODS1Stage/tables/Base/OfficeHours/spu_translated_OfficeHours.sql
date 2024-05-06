CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_OFFICEHOURS()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.OfficeHours depends on: 
--- Raw.VW_OFFICE_PROFILE
--- Base.Office
--- Base.DaysOfWeek

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement_1 STRING; -- CTE and Select statement for the Merge
    select_statement_2 STRING; 
    update_statement STRING; -- Update statement for the Merge
    update_clause STRING; -- where condition for update
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    -- no conditionals


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement
select_statement_1 := $$ WITH CTE_Swimlane AS (
SELECT
	O.OfficeID,
	DW.DaysOfWeekId,
	IFNULL(JSON.HOURS_LastUpdateDate, SYSDATE()) AS LastUpdateDate,
	TO_TIME(JSON.HOURS_ClosingTime) AS OfficeHoursClosingTime, 
	TO_TIME(JSON.HOURS_OpeningTime) AS OfficeHoursOpeningTime,  
	case when JSON.HOURS_IsClosed is null and JSON.HOURS_OpeningTime is not null then 0 when JSON.HOURS_IsClosed is null then 1 else JSON.HOURS_IsClosed end as OfficeIsClosed,
	IFNULL(JSON.HOURS_IsOpen24Hours, 0) as OfficeIsOpen24Hours, 
	IFNULL( JSON.HOURS_SourceCode , 'Profisee' ) AS SourceCode, 
	JSON.OfficeCode,
    row_number() over(partition by O.OfficeID, JSON.HOURS_DaysOfWeekCode order by CREATE_DATE desc) AS RowRank 

FROM RAW.VW_OFFICE_PROFILE AS JSON
	LEFT JOIN Base.Office AS O ON O.OfficeCode = JSON.OfficeCode
	LEFT JOIN Base.DaysOfWeek AS DW ON DW.DaysOfWeekCode = 
JSON.HOURS_DaysOfWeekCode
WHERE OFFICE_PROFILE IS NOT NULL ),

CTE_NotExists AS (
select 1
                from CTE_swimlane as s
                inner join Base.Office as O on O.OfficeId = S.OfficeId
                inner join Base.DaysOfWeek as DW on DW.DaysOfWeekID = S.DaysOfWeekId
                inner join Base.OfficeHours as OH on OH.OfficeId = S.OfficeID and OH.DaysOfWeekID = DW.DaysOfWeekID
                where OH.OfficeID = O.OfficeID and OH.DaysOfWeekID = DW.DaysOfWeekID
),

CTE_DeleteOfficeHours AS (
SELECT DISTINCT
	O.OfficeID
FROM CTE_Swimlane AS S
	INNER JOIN Base.Office AS O ON O.OfficeCode = S.OfficeCode 
	INNER JOIN Base.DaysOfWeek AS DW ON DW.DaysOfWeekID = S.DaysOfWeekId
WHERE NOT EXISTS (SELECT * FROM CTE_NotExists)) $$;

select_statement_2 := select_statement_1 || $$ SELECT DISTINCT
	OfficeID, 
	SourceCode, 
	DaysOfWeekID, 
	OfficeHoursOpeningTime, 
	OfficeHoursClosingTime,
	OfficeIsClosed, 
	OfficeIsOpen24Hours, 
	LastUpdateDate
FROM CTE_swimlane
WHERE 
	OfficeID IS NOT NULL AND
	DaysOfWeekID IS NOT NULL AND
	OfficeIsClosed IS NOT NULL AND
	OfficeIsOpen24Hours IS NOT NULL AND
	RowRank = 1  $$;



--- Update Statement
update_statement := ' UPDATE
					SET
	target.SourceCode = source.SourceCode, 
	target.OfficeHoursOpeningTime = source.OfficeHoursOpeningTime, 
	target.OfficeHoursClosingTime = source.OfficeHoursClosingTime, 
	target.OfficeIsClosed = source.OfficeIsClosed, 
	target.OfficeIsOpen24Hours = source.OfficeIsOpen24Hours, 
	target.LastUpdateDate = source.LastUpdateDate';
                            
-- Update Clause
update_clause := $$ target.SourceCode != source.SourceCode
or IFNULL(target.OfficeHoursOpeningTime, '08:00:00.0000000') != IFNULL(source.OfficeHoursOpeningTime, '08:00:00.0000000')
or IFNULL(target.OfficeHoursClosingTime, '17:00:00.0000000') != IFNULL(source.OfficeHoursClosingTime, '17:00:00.0000000')
or IFNULL(target.OfficeIsClosed, 1) != IFNULL(source.OfficeIsClosed, 1)
or IFNULL(target.OfficeIsOpen24Hours, 0) != IFNULL(source.OfficeIsOpen24Hours, 0)
                    $$;                        
        
--- Insert Statement
insert_statement := 'INSERT ( 
    OfficeHoursID, 
	OfficeID, 
	SourceCode, 
	DaysOfWeekID, 
	OfficeHoursOpeningTime, 
	OfficeHoursClosingTime,
	OfficeIsClosed, 
	OfficeIsOpen24Hours, 
	LastUpdateDate)

VALUES (
    UUID_STRING(),
    source.OfficeID, 
	source.SourceCode, 
	source.DaysOfWeekID, 
	source.OfficeHoursOpeningTime, 
	source.OfficeHoursClosingTime,
	source.OfficeIsClosed, 
	source.OfficeIsOpen24Hours, 
	source.LastUpdateDate)';


    
---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := ' MERGE INTO Base.OfficeHours as target USING 
                   ('||select_statement_2 ||') as source 
                   ON source.Officeid = target.officeid
		           WHEN MATCHED AND target.OfficeID IN (' || select_statement_1 || ' SELECT OfficeId FROM CTE_DeleteOfficeHours ) THEN DELETE
                   WHEN MATCHED AND' || update_clause || 'THEN '||update_statement|| '
                   WHEN NOT MATCHED THEN '||insert_statement ;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
EXECUTE IMMEDIATE merge_statement;

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
--------------------------------------------------------- 

status := 'Completed successfully';
    RETURN status;


        
EXCEPTION
    WHEN OTHER THEN
          status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
          RETURN status;


    
END;