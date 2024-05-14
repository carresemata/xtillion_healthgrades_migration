CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.Mid.SP_LOAD_PROVIDERLANGUAGE(IsProviderDeltaProcessing BOOLEAN)
RETURNS varchar(16777216)
LANGUAGE SQL
EXECUTE as CALLER
as 

declare
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------

-- mid.providerlanguage depends on:
-- mdm_team.mst.provider_profile_processing
-- base.provider
-- base.providertolanguage 
-- base.language 

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    source_table string;
    select_statement string; 
    insert_statement string;
    merge_statement string; 
    status string;
    procedure_name varchar(50) default('sp_load_providerlanguage');
    execution_start datetime default getdate();


---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------  
begin

    if (IsProviderDeltaProcessing) then
           select_statement := '
          with CTE_ProviderBatch as (
                select
                    p.providerid
                from
                    mdm_team.mst.Provider_Profile_Processing as ppp
                    join base.provider as P on p.providercode = ppp.ref_provider_code),';
    else
           select_statement := '
           with CTE_ProviderBatch as (
                select
                    p.providerid
                from
                    base.provider as p
                order by
                    p.providerid),';
            
    end if;

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------  

    select_statement := $$
                       CTE_ProviderLanguage as (
                        select ptl.providerid, l.languagename,
                               CASE WHEN mpl.providerid is null then 1 else 0 END as ActionCode
                        from CTE_ProviderBatch pb
                        join base.providertolanguage as ptl on ptl.providerid = pb.providerid
                        join base.language as l on l.languageid = ptl.languageid
                        left join mid.providerlanguage mpl on ptl.providerid = mpl.providerid and l.languagename = mpl.languagename
                        )
                        
                        select 
                            pl.providerid,
                            pl.languagename,
                            pl.actioncode
                        from CTE_ProviderLanguage pl
                        $$;
      

      ---------------------------------------------------------
      --------- 4. actions (inserts and updates) --------------
      ---------------------------------------------------------
      insert_statement := $$
                         insert
                          ( 
                          ProviderID,
                          LanguageName
                          )
                         values 
                          (
                          source.providerid,
                          source.languagename
                          )
                          $$;


     merge_statement := $$
                        merge into mid.providerlanguage as target
                        using $$ || select_statement || $$ as source
                        on source.providerid = target.providerid
                        WHEN MATCHED and source.providerid = target.providerid 
                                     and source.languagename = target.languagename
                                     and source.providerid is null then delete
                        when not matched and source.actioncode = 1 then $$ || insert_statement;
        

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