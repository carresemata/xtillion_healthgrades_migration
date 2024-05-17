CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDERSANCTION()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- mid.providersanction depends on: 
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.providersanction
--- base.sanctiontype
--- base.sanctioncategory
--- base.sanctionaction
--- base.statereportingagency
--- base.sanctionactiontype
--- base.state

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providersanction');
    execution_start datetime default getdate();

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin
--- select Statement

select_statement := $$ with CTE_ProviderBatch as (
                select
                    p.providerid
                from
                    MDM_team.mst.Provider_Profile_Processing as ppp
                    join base.provider as P on p.providercode = ppp.ref_provider_code),
                    CTE_ProviderSanction as (
                            select
                                ps.providersanctionid,
                                ps.providerid,
                                ps.sanctiondescription,
                                ps.sanctiondate,
                                ps.sanctionreinstatementdate as ReinstatementDate,
                                st.sanctiontypecode,
                                st.sanctiontypedescription,
                                sra.state,
                                sc.sanctioncategorycode,
                                sc.sanctioncategorydescription,
                                sa.sanctionactioncode,
                                sa.sanctionactiondescription,
                                sat.sanctionactiontypecode,
                                sat.sanctionactiontypedescription,
                                s.statename as StateFull,
                                0 as ActionCode
                            from
                                CTE_ProviderBatch as pb
                                join base.providersanction as ps on ps.providerid = pb.providerid
                                join base.sanctiontype as st on ps.sanctiontypeid = st.sanctiontypeid
                                join base.sanctioncategory as sc on ps.sanctioncategoryid = sc.sanctioncategoryid
                                join base.sanctionaction as sa on ps.sanctionactionid = sa.sanctionactionid
                                join base.statereportingagency as sra on ps.statereportingagencyid = sra.statereportingagencyid
                                left join base.sanctionactiontype as sat on sa.sanctionactiontypeid = sat.sanctionactiontypeid
                                left join base.state as s on sra.state = s.state
                        ),
                        -- insert Action
                        CTE_Action_1 as (
                            select
                                cte.providersanctionid,
                                1 as ActionCode
                            from
                                CTE_ProviderSanction as cte
                                left join mid.providersanction as mid on cte.providersanctionid = mid.providersanctionid
                            where
                                mid.providersanctionid is null
                        ),
                        -- update Action
                        CTE_Action_2 as (
                            select
                                cte.providersanctionid,
                                2 as ActionCode
                            from
                                CTE_ProviderSanction as cte
                                join mid.providersanction as mid on cte.providersanctionid = mid.providersanctionid
                           where 
                                MD5(ifnull(cte.providerid::varchar,'')) <> MD5(ifnull(mid.providerid::varchar,'')) or
                                MD5(ifnull(cte.sanctiondescription::varchar,'')) <> MD5(ifnull(mid.sanctiondescription::varchar,'')) or
                                MD5(ifnull(cte.sanctiondate::varchar,'')) <> MD5(ifnull(mid.sanctiondate::varchar,'')) or
                                MD5(ifnull(cte.reinstatementdate::varchar,'')) <> MD5(ifnull(mid.reinstatementdate::varchar,'')) or
                                MD5(ifnull(cte.sanctiontypecode::varchar,'')) <> MD5(ifnull(mid.sanctiontypecode::varchar,'')) or
                                MD5(ifnull(cte.sanctiontypedescription::varchar,'')) <> MD5(ifnull(mid.sanctiontypedescription::varchar,'')) or
                                MD5(ifnull(cte.sanctioncategorycode::varchar,'')) <> MD5(ifnull(mid.sanctioncategorycode::varchar,'')) or
                                MD5(ifnull(cte.sanctioncategorydescription::varchar,'')) <> MD5(ifnull(mid.sanctioncategorydescription::varchar,'')) or
                                MD5(ifnull(cte.sanctionactioncode::varchar,'')) <> MD5(ifnull(mid.sanctionactioncode::varchar,'')) or
                                MD5(ifnull(cte.sanctionactiondescription::varchar,'')) <> MD5(ifnull(mid.sanctionactiondescription::varchar,'')) or
                                MD5(ifnull(cte.sanctionactiontypecode::varchar,'')) <> MD5(ifnull(mid.sanctionactiontypecode::varchar,'')) or
                                MD5(ifnull(cte.sanctionactiontypedescription::varchar,'')) <> MD5(ifnull(mid.sanctionactiontypedescription::varchar,'')) or
                                MD5(ifnull(cte.statefull::varchar,'')) <> MD5(ifnull(mid.statefull::varchar,'')) 
                        )
                        select
                            distinct A0.ProviderSanctionID,
                            A0.ProviderID,
                            A0.SanctionDescription,
                            A0.SanctionDate,
                            A0.ReinstatementDate,
                            A0.SanctionTypeCode,
                            A0.SanctionTypeDescription,
                            A0.SanctionCategoryCode,
                            A0.SanctionCategoryDescription,
                            A0.SanctionActionCode,
                            A0.SanctionActionDescription,
                            A0.SanctionActionTypeCode,
                            A0.SanctionActionTypeDescription,
                            A0.StateFull,
                            ifnull(
                                A1.ActionCode,
                                ifnull(A2.ActionCode, A0.ActionCode)
                            ) as ActionCode
                        from
                            CTE_ProviderSanction as A0
                            left join CTE_Action_1 as A1 on A0.ProviderSanctionID = A1.ProviderSanctionID
                            left join CTE_Action_2 as A2 on A0.ProviderSanctionID = A2.ProviderSanctionID
                        where
                            ifnull(
                                A1.ActionCode,
                                ifnull(A2.ActionCode, A0.ActionCode)
                            ) <> 0 $$;

--- update Statement
update_statement := ' update 
                     SET 
                        ProviderSanctionID = source.providersanctionid,
                        ProviderID = source.providerid,
                        SanctionDescription = source.sanctiondescription,
                        SanctionDate = source.sanctiondate,
                        ReinstatementDate = source.reinstatementdate,
                        SanctionTypeCode = source.sanctiontypecode,
                        SanctionTypeDescription = source.sanctiontypedescription,
                        SanctionCategoryCode = source.sanctioncategorycode,
                        SanctionCategoryDescription = source.sanctioncategorydescription,
                        SanctionActionCode = source.sanctionactioncode,
                        SanctionActionDescription = source.sanctionactiondescription,
                        SanctionActionTypeCode = source.sanctionactiontypecode,
                        SanctionActionTypeDescription = source.sanctionactiontypedescription,
                        StateFull = source.statefull';

--- insert Statement
insert_statement := ' insert  (
                            ProviderSanctionID,
                            ProviderID,
                            SanctionDescription,
                            SanctionDate,
                            ReinstatementDate,
                            SanctionTypeCode,
                            SanctionTypeDescription,
                            SanctionCategoryCode,
                            SanctionCategoryDescription,
                            SanctionActionCode,
                            SanctionActionDescription,
                            SanctionActionTypeCode,
                            SanctionActionTypeDescription,
                            StateFull)
                      values (
                            source.providersanctionid,
                            source.providerid,
                            source.sanctiondescription,
                            source.sanctiondate,
                            source.reinstatementdate,
                            source.sanctiontypecode,
                            source.sanctiontypedescription,
                            source.sanctioncategorycode,
                            source.sanctioncategorydescription,
                            source.sanctionactioncode,
                            source.sanctionactiondescription,
                            source.sanctionactiontypecode,
                            source.sanctionactiontypedescription,
                            source.statefull)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.providersanction as target using 
                   ('||select_statement||') as source 
                   on source.providersanctionid = target.providersanctionid
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