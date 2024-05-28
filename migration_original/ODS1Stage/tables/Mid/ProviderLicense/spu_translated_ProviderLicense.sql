CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDERLICENSE()
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

select_statement := select_statement || 
                    $$ with CTE_ProviderBatch as (
                select
                    p.providerid
                from
                    $$ || mdm_db || $$.mst.Provider_Profile_Processing as ppp
                    join base.provider as P on p.providercode = ppp.ref_provider_code),
                    
                CTE_ProviderLicense as (
                        select
                            pl.providerid,
                            pl.licensenumber,
                            pl.licenseeffectivedate,
                            pl.licenseterminationdate,
                            st.state,
                            st.statename,
                            pl.licensetype,
                            0 as ActionCode
                        from
                            CTE_ProviderBatch as pb
                            join base.providerlicense as pl on pl.providerid = pb.providerid
                            join base.state as st on st.stateid = pl.stateid
                    ),
                    -- insert Action
                    CTE_Action_1 as (
                        select
                            cte.providerid,
                            1 as ActionCode
                        from
                            CTE_ProviderLicense as cte
                            left join mid.providerlicense as mid on cte.providerid = mid.providerid
                        where
                            mid.providerid is null
                    ),
                    -- update Action
                    CTE_Action_2 as (
                        select
                            cte.providerid,
                            2 as ActionCode
                        from
                            CTE_ProviderLicense as cte
                            join mid.providerlicense as mid on cte.providerid = mid.providerid
                        where
                            MD5(ifnull(cte.licensenumber::varchar, '')) <> MD5(ifnull(mid.licensenumber::varchar, ''))
                            or MD5(ifnull(cte.licenseeffectivedate::varchar, '')) <> MD5(ifnull(mid.licenseeffectivedate::varchar, ''))
                            or MD5(ifnull(cte.licenseterminationdate::varchar, '')) <> MD5(ifnull(mid.licenseterminationdate::varchar, ''))
                            or MD5(ifnull(cte.state::varchar, '')) <> MD5(ifnull(mid.state::varchar, ''))
                            or MD5(ifnull(cte.statename::varchar, '')) <> MD5(ifnull(mid.statename::varchar, ''))
                            or MD5(ifnull(cte.licensetype::varchar, '')) <> MD5(ifnull(mid.licensetype::varchar, ''))
                    )
                    select distinct
                        A0.ProviderID,
                        A0.LicenseNumber,
                        A0.LicenseEffectiveDate,
                        A0.LicenseTerminationDate,
                        A0.State,
                        A0.StateName,
                        A0.LicenseType,
                        ifnull(
                            A1.ActionCode,
                            ifnull(A2.ActionCode, A0.ActionCode)
                        ) as ActionCode
                    from
                        CTE_ProviderLicense as A0
                        left join CTE_Action_1 as A1 on A0.ProviderID = A1.ProviderID
                        left join CTE_Action_2 as A2 on A0.ProviderID = A2.ProviderID
                    where
                        ifnull(
                            A1.ActionCode,
                            ifnull(A2.ActionCode, A0.ActionCode)
                        ) <> 0 $$;

--- update Statement
update_statement := ' update 
                     SET 
                        ProviderID = source.providerid,
                        LicenseNumber = source.licensenumber,
                        LicenseEffectiveDate = source.licenseeffectivedate,
                        LicenseTerminationDate = source.licenseterminationdate,
                        State = source.state,
                        StateName = source.statename,
                        LicenseType = source.licensetype';

--- insert Statement
insert_statement := ' insert  (
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
                   WHEN MATCHED and source.actioncode = 2 then '||update_statement|| '
                   when not matched and source.actioncode = 1 then '||insert_statement;
                   
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