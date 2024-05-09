CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRPRACTICEDELTA(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
    
-- show.solrpracticedelta depends on:
--- mdm_team.mst.provider_profile_processing
--- base.practice
--- base.providertooffice
--- base.office
--- base.provider

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    truncate_statement string;
    merge_statement_1 string; -- merge statement to final table
    merge_statement_2 string;
    merge_statement_3 string;
    merge_statement_4 string;
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrpracticedelta');
    execution_start datetime default getdate();

   
---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------   
begin
--- conditionals are executed in the execution section


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     
merge_statement_1 := 'merge into show.solrpracticedelta as target using 
                                           (select distinct
                                                pr.practiceid,
                                                spd.solrdeltatypecode, 
                                                spd.middeltaprocesscomplete, 
                                                spd.startdeltaprocessdate,
                                                spd.enddeltaprocessdate,
                                                spd.startmovedate,
                                                spd.endmovedate
                                            from	MDM_team.mst.Provider_Profile_Processing as ppp
                                                    join base.provider as P on p.providercode = ppp.ref_provider_code
                                            		join	base.providertooffice po on p.providerid = po.providerid
                                            		join	base.office o on po.officeid = o.officeid
                                            		join	base.practice pr on o.practiceid = pr.practiceid		
                                            		left join	show.solrpracticedelta spd on pr.practiceid = spd.practiceid) as source 
                                           
                                on source.practiceid = target.practiceid
                                WHEN MATCHED then 
                                            update 
                                                SET
                                                target.enddeltaprocessdate = null,
                                				target.startmovedate = null,
                                				target.endmovedate = null
                                when not matched and source.startdeltaprocessdate is not null and source.enddeltaprocessdate is null and source.practiceid is null then 
                                            insert (
                                            PracticeID,
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
                                
        truncate_statement := 'truncate TABLE show.solrpracticedelta';
        merge_statement_2 := $$merge into show.solrpracticedelta as target using 
                                   (select distinct
                                        pr.practiceid,
                                        '1' as SolrDeltaTypeCode,
                                        current_timestamp() as StartDeltaProcessDate,
                                        '1' as MidDeltaProcessComplete
                                    from
                                        base.practice pr
                                        left join show.solrpracticedelta spd on pr.practiceid = spd.practiceid
                                    where
                                        spd.practiceid is null) as source 
                                   on source.practiceid = target.practiceid
                                   when not matched then 
                                    insert (
                                    PracticeID,
                                    SolrDeltaTypeCode,
                                    StartDeltaProcessDate,
                                    MidDeltaProcessComplete
                                    )
                                    values (
                                    source.practiceid,
                                    source.solrdeltatypecode,
                                    source.startdeltaprocessdate,
                                    source.middeltaprocesscomplete
                                    );$$;

        merge_statement_3 := $$
                            merge into show.solrpracticedelta as target using 
                                (select distinct
                                    o.practiceid,
                                    '1' as SolrDeltaTypeCode,
                                    current_timestamp() as StartDeltaProcessDate,
                                    '1' as MidDeltaProcessComplete
                                from
                                    MDM_team.mst.Provider_Profile_Processing as ppp
                                    inner join base.provider as P on p.providercode = ppp.ref_provider_code
                                    inner join base.providertooffice as pto on p.providerid = pto.providerid
                                    inner join base.office as o on pto.officeid = o.officeid
                                where
                                    o.practiceid not in (
                                        select
                                            practiceid
                                        from
                                            show.solrpracticedelta
                                    )) as source
                                on source.practiceid = target.practiceid
                                when not matched then 
                                insert (
                                PracticeID,
                                SolrDeltaTypeCode,
                                StartDeltaProcessDate,
                                MidDeltaProcessComplete
                                )
                                values (
                                source.practiceid,
                                source.solrdeltatypecode,
                                source.startdeltaprocessdate,
                                source.middeltaprocesscomplete
                                );$$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

-- Merge statement ran regardless of the parameter value
merge_statement_4 := 'merge into show.solrpracticedelta as target using 
                   (select distinct
                        PracticeId,
                        StartDeltaProcessDate,
                        EndDeltaProcessDate
                   from show.solrpracticedelta
                   where StartDeltaProcessDate is not null and EndDeltaProcessDate is null) as source 
                   on source.practiceid = target.practiceid
                   WHEN MATCHED then
                    update
                    SET 
                        target.enddeltaprocessdate  = current_timestamp()';
                   
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 

if (isproviderdeltaprocessing) then
        execute immediate merge_statement_1;
else
        execute immediate truncate_statement;
        execute immediate merge_statement_2;
        execute immediate merge_statement_3;
end if;
execute immediate merge_statement_4 ;

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