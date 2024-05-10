CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_MARKET()
RETURNS STRING
LANGUAGE SQL EXECUTE
as CALLER
as declare 

---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
--- base.market depends on:
-- base.geographicarea
-- base.marketmaster (empty in sql server?)
-- base.source
-- dbo.requestedmarketlocationsmissingfromods2 (external schema)

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
merge_statement string;
status string;
    procedure_name varchar(50) default('sp_load_market');
    execution_start datetime default getdate();


---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------   

begin
-- no conditionals

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

select_statement := $$                 
                    select distinct
                        mkm.marketguid as MarketID,
                        mkm.geographicareaguid as GeographicAreaID,
                        mkm.lineofserviceguid as LineOfServiceID,
                        mkm.marketcode,
                        mkm.legacyclientmarketid as LegacyKey,
                        'ClientMarketID' as LegacyKeyName,
                        s.sourcecode,
                        mkm.lastupdatedate
                    from base.marketmaster as mkm
                        inner join base.geographicarea ga on mkm.geographicareaguid = ga.geographicareaid
                        inner join dbo.requestedmarketlocationsmissingfromods2 missing on ga.geographicareavalue1 = missing.geographicareavalue1
                            and ifnull(ga.geographicareavalue2,'') = ifnull(missing.geographicareavalue2, '')
                        left join base.market bm on mkm.marketguid = bm.marketid
                        left join base.source s on mkm.system_SRC_GUID = s.sourceid
                    where mkm.enddate > DATEADD(day, -180, CURRENT_DATE()) or mkm.enddate is null
                        and bm.marketid is null
                    $$;


insert_statement := $$ 
                    insert
                        (
                        MarketID, 
                        GeographicAreaID, 
                        LineOfServiceID, 
                        MarketCode, 
                        LegacyKey, 
                        LegacyKeyName, 
                        SourceCode,
                        LastUpdateDate
                        )
                     values 
                        (
                        source.marketid, 
                        source.geographicareaid, 
                        source.lineofserviceid, 
                        source.marketcode, 
                        source.legacykey, 
                        source.legacykeyname, 
                        source.sourcecode,
                        source.lastupdatedate
                        )
                     $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := $$ merge into base.market as target 
                    using ($$||select_statement||$$) as source 
                   on source.marketid = target.marketid
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