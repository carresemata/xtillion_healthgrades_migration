CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRPRACTICEDELTA(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- show.solrpracticedelta depends on:
--- mdm_team.mst.provider_profile_processing
--- base.practice
--- base.providertooffice
--- base.office
--- base.provider

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement_1 string;
    insert_statement_1 string;
    update_statement_1 string;
    merge_statement_1 string; -- merge statement to final table
    merge_statement_2 string;
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrpracticedelta');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     
begin   

select_statement_1 := $$ select distinct
                            pr.practiceid,
                            spd.solrdeltatypecode, 
                            spd.middeltaprocesscomplete, 
                            spd.startdeltaprocessdate,
                            spd.enddeltaprocessdate,
                            spd.startmovedate,
                            spd.endmovedate
                        from	$$ || mdm_db || $$.mst.Provider_Profile_Processing as ppp
                                join base.provider as P on p.providercode = ppp.ref_provider_code
                                join	base.providertooffice po on p.providerid = po.providerid
                                join	base.office o on po.officeid = o.officeid
                                join	base.practice pr on o.practiceid = pr.practiceid		
                                left join	show.solrpracticedelta spd on pr.practiceid = spd.practiceid $$;

 update_statement_1 := ' update 
                            SET
                            target.enddeltaprocessdate = null,
                            target.startmovedate = null,
                            target.endmovedate = null ' ; 
                            
insert_statement_1 := 'insert ( PracticeID,
                                SolrDeltaTypeCode,
                                StartDeltaProcessDate,
                                MidDeltaProcessComplete
                                )
                                values (
                                source.practiceid,
                                source.solrdeltatypecode,
                                source.startdeltaprocessdate,
                                source.middeltaprocesscomplete
                                );';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement_1 := 'merge into show.solrpracticedelta as target using 
                       (' || select_statement_1 || ') as source 
                        on source.practiceid = target.practiceid
                        when matched then ' || update_statement_1 || '
                        when not matched 
                            and source.startdeltaprocessdate is not null and source.enddeltaprocessdate is null and source.practiceid is null then 
                            '|| insert_statement_1 ;
                                            

merge_statement_2 := 'merge into show.solrpracticedelta as target using 
                   (select distinct
                        PracticeId,
                        StartDeltaProcessDate,
                        EndDeltaProcessDate
                   from show.solrpracticedelta
                   where 
                        StartDeltaProcessDate is not null and EndDeltaProcessDate is null) as source 
                   on source.practiceid = target.practiceid
                   when matched then
                        update SET target.enddeltaprocessdate  = current_timestamp()';
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Show.SOLRPracticeDelta;
end if; 
execute immediate merge_statement_1;
        execute immediate merge_statement_2;


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