CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRPROVIDERDELTA()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  

declare 

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- show.solrproviderdelta depends on: 
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.providerswithsponsorshipissues (empty)

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    merge_statement_1 string;
    merge_statement_2 string;
    select_statement_3 string;
    insert_statement_3 string;
    merge_statement_3 string;
    update_statement string;
    status string;
    procedure_name varchar(50) default('sp_load_solrproviderdelta');
    execution_start datetime default getdate();


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------  

begin

select_statement_3 := 'with CTE_union as (
                                    select
                                        distinct p.providerid,
                                        1 as SolrDeltaTypeCode,
                                        current_timestamp() as StartDeltaProcessDate,
                                        1 as MidDeltaProcessComplete
                                    from
                                        MDM_team.mst.Provider_Profile_Processing as PPP
                                        inner join base.provider as P on p.providercode = ppp.ref_Provider_Code
                                        left join show.solrproviderdelta as SOLRProvDelta on solrprovdelta.providerid = p.providerid
                                        left join base.providerswithsponsorshipissues as ProvIssue on provissue.providercode = p.providercode
                                    where
                                        solrprovdelta.providerid is null
                                        and provissue.providercode is null
                                ),
                                CTE_final as (
                                    select
                                        cteunion.providerid,
                                        cteunion.solrdeltatypecode,
                                        current_timestamp() as StartDeltaProcessDate,
                                        cteunion.middeltaprocesscomplete,
                                        row_number() over (
                                            partition by cteunion.providerid
                                            order by
                                                cteunion.solrdeltatypecode
                                        ) as RN1
                                    from
                                        cte_union as cteUnion
                                        left join show.solrproviderdelta as SOLRProvDelta on solrprovdelta.providerid = cteunion.providerid
                                    where
                                        solrprovdelta.solrproviderdeltaid is null
                                )
                                select
                                    ProviderID,
                                    SolrDeltaTypeCode,
                                    StartDeltaProcessDate,
                                    MidDeltaProcessComplete
                                from
                                    CTE_final
                                where
                                    RN1 = 1 ';
                            
insert_statement_3 := ' insert (
                                        ProviderID,
                                        SolrDeltaTypeCode,
                                        StartDeltaProcessDate,
                                        MidDeltaProcessComplete
                                    )
                                    values (
                                        source.providerid,
                                        source.solrdeltatypecode,
                                        source.startdeltaprocessdate,
                                        source.middeltaprocesscomplete
                                    )';

--- update Statement
update_statement := ' update show.solrproviderdelta 
                        SET ENDDeltaProcessDate = current_timestamp()
                        where StartDeltaProcessDate is not null
                        and ENDDeltaProcessDate is null;';


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement_1 := 'merge into show.solrproviderdelta as target using
                                    (select	
                                        p.providerid, 
                                        1 as SolrDeltaTypeCode, 
                                        current_timestamp() as StartDeltaProcessDate
                            		from	MDM_team.mst.Provider_Profile_Processing as PPP
                                    inner join base.provider as P on p.providercode = ppp.ref_Provider_Code
                            		where	ProviderId not IN (select ProviderId from show.solrproviderdelta)) as source
                                        on source.providerid = target.providerid
                                        when not matched then
                                            insert (
                                                ProviderId, 
                                                SolrDeltaTypeCode, 
                                                StartDeltaProcessDate
                                            )
                                            values (
                                                source.providerid, 
                                                source.solrdeltatypecode, 
                                                source.startdeltaprocessdate
                                            );';

merge_statement_2 :=  'merge into show.solrproviderdelta as target using 
                                    (select 
                                        p.providerid
                                    from 
                                        MDM_team.mst.Provider_Profile_Processing as PPP
                                    inner join base.provider as P on p.providercode = ppp.ref_Provider_Code    
                                    inner join show.solrproviderdelta SOLRProvDelta
                                    on p.providerid = solrprovdelta.providerid) as source
                                    on source.providerid = target.providerid
                                    WHEN MATCHED then 
                                        update SET
                                        target.enddeltaprocessdate = null,
                                        target.startmovedate = null,
                                        target.endmovedate = null;';

         
                            
merge_statement_3 := ' merge into show.solrproviderdelta as target
                                    using (' || select_statement_if_3 || ') as source
                                    on target.providerid = source.providerid
                                    when not matched then ' || insert_statement_if_3;


                   
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 

    execute immediate merge_statement_1;
    execute immediate merge_statement_2;
    execute immediate merge_statement_3;
    execute immediate update_statement ;

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