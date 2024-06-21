CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDERLICENSE(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- mid.providerlicense depends on: 
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.providerlicense
--- base.state

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providerlicense');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin
--- select Statement

select_statement := 
                    $$ 
                    with CTE_ProviderBatch as (
                        select p.providerid
                        from $$||mdm_db||$$.mst.Provider_Profile_Processing as ppp
                        join base.provider as P on p.providercode = ppp.ref_provider_code
                    )
        
                    select distinct
                        pl.providerid,
                        pl.licensenumber,
                        pl.licenseeffectivedate,
                        pl.licenseterminationdate,
                        st.state,
                        st.statename,
                        pl.licensetype
                    from CTE_ProviderBatch as pb
                    join base.providerlicense as pl on pl.providerid = pb.providerid
                    join base.state as st on st.stateid = pl.stateid
                    $$;

--- update Statement
update_statement := ' update 
                      set 
                        ProviderID = source.providerid,
                        LicenseNumber = source.licensenumber,
                        LicenseEffectiveDate = source.licenseeffectivedate,
                        LicenseTerminationDate = source.licenseterminationdate,
                        State = source.state,
                        StateName = source.statename,
                        LicenseType = source.licensetype';

--- insert Statement
insert_statement := ' insert (
                            ProviderID,
                            LicenseNumber,
                            LicenseEffectiveDate,
                            LicenseTerminationDate,
                            State,
                            StateName,
                            LicenseType)
                      values (
                            source.providerid,
                            source.licensenumber,
                            source.licenseeffectivedate,
                            source.licenseterminationdate,
                            source.state,
                            source.statename,
                            source.licensetype)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.providerlicense as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid and source.licensenumber = target.licensenumber and source.licensetype = target.licensetype
                   when matched then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.ProviderLicense;
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