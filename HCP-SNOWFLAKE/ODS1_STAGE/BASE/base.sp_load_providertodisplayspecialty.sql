CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTODISPLAYSPECIALTY(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertodisplayspecialty depends on:
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.providertospecialty
--- base.displayspecialtyrule
--- base.providertoclinicalfocus
--- base.displayspecialtyruletoclinicalfocus

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the insert
    insert_statement string; -- insert statement 
    merge_statement string; -- merge
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertodisplayspecialty');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
    
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin
--- select Statement

select_statement := $$ with CTE_ProviderBatch as (
                                select 
                                    p.providerid
                                from $$ || mdm_db || $$.mst.Provider_Profile_Processing as ppp
                                    join base.provider as p on ppp.ref_provider_code = p.providercode
                            ),
                            
                            CTE_ProviderDisplay as (
                              select distinct 
                                c.displayspecialtyruleid, 
                                a.providerid,
                                a.specialtyid
                              from base.providertospecialty a
                                  join CTE_ProviderBatch b on b.providerid = a.providerid
                                  join base.displayspecialtyrule c on c.specialtyid = a.specialtyid
                              where a.issearchablecalculated = 1 
                            ),
                            
                            CTE_ProviderCF as (
                                select distinct
                                    cf.providerid,
                                    discf.displayspecialtyruleid
                                from base.providertoclinicalfocus as CF
                                    join CTE_ProviderDisplay as CTE on cte.providerid = cf.providerid
                                    join base.displayspecialtyruletoclinicalfocus as DisCF on discf.displayspecialtyruleid = cte.displayspecialtyruleid
                            ),
                            CTE_ProviderPrimarySpec as (
                                select
                                    provspec.providerid,
                                    specrule.displayspecialtyruleid
                                from base.providertospecialty as ProvSpec
                                    join CTE_ProviderDisplay as CTE on cte.providerid = provspec.providerid
                                    join base.displayspecialtyrule as SpecRule on specrule.displayspecialtyruleid = cte.displayspecialtyruleid
                            ) 
                            select distinct
                                provds.providerid,
                                specrule.specialtyid
                            from CTE_ProviderDisplay as ProvDS
                                join base.displayspecialtyrule as SpecRule on specrule.displayspecialtyruleid = provds.displayspecialtyruleid
                                left join CTE_ProviderCF as ProvCF on provcf.providerid = provds.providerid and provcf.displayspecialtyruleid = specrule.displayspecialtyruleid
                                left join CTE_ProviderPrimarySpec as ProvPrimSpec on provprimspec.providerid = provds.providerid and provprimspec.displayspecialtyruleid = specrule.displayspecialtyruleid 
                             qualify row_number() over (partition by provds.providerid order by specrule.displayspecialtyrulerank, case when specrule.isprimaryrequired = 1 and provprimspec.providerid is not null then 1 else 2 end, specrule.displayspecialtyruletiebreaker) = 1   $$;


-- insert statement
insert_statement := 'insert 
                        (providertodisplayspecialtyid,
                        providerid,
                        specialtyid)
                     values
                        (utils.generate_uuid(source.providerid || source.specialtyid), 
                        source.providerid,
                        source.specialtyid)';
                        
-- no need for update as only ids are inserted

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := ' merge into base.providertodisplayspecialty as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid and source.specialtyid = target.specialtyid 
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToDisplaySpecialty;
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