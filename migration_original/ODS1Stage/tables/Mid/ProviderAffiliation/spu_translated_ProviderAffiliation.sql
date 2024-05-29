CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDERAFFILIATION(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- mid.provideraffiliation depends on: 
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.providertoaffiliation
--- base.affiliation
--- base.providerrole

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_provideraffiliation');
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
                from
                    $$ || mdm_db || $$.mst.Provider_Profile_Processing as ppp
                    join base.provider as P on p.providercode = ppp.ref_provider_code),
                    CTE_ProviderAffiliation as (
                            select
                                pta.providertoaffiliationid,
                                pta.providerid,
                                pta.affiliationbegindate,
                                pta.affiliationenddate,
                                pta.affiliationname,
                                aff.affiliationtypecode,
                                aff.affiliationtypedescription,
                                pr.rolecode,
                                pr.roledescription,
                                0 as ActionCode
                            from
                                CTE_ProviderBatch as pb
                                join base.providertoaffiliation as pta on pta.providerid = pb.providerid
                                join base.affiliation as aff on pta.affiliationid = aff.affiliationid
                                join base.providerrole as pr on pta.providerroleid = pr.providerroleid
                        ),
                        -- insert Action
                        CTE_Action_1 as (
                            select
                                cte.providertoaffiliationid,
                                1 as ActionCode
                            from
                                CTE_ProviderAffiliation as cte
                                left join mid.provideraffiliation as mid on cte.providertoaffiliationid = mid.providertoaffiliationid
                            where
                                mid.providertoaffiliationid is null
                        ),
                        -- update Action
                        CTE_Action_2 as (
                            select
                                cte.providertoaffiliationid,
                                2 as ActionCode
                            from
                                CTE_ProviderAffiliation as cte
                                left join mid.provideraffiliation as mid on cte.providertoaffiliationid = mid.providertoaffiliationid
                            where
                                MD5(ifnull(cte.providerid::varchar, '')) <> MD5(ifnull(mid.providerid::varchar, '')) or
                                MD5(ifnull(cte.affiliationbegindate::varchar, '')) <> MD5(ifnull(mid.affiliationbegindate::varchar, ''))  or
                                MD5(ifnull(cte.affiliationenddate::varchar, '')) <> MD5(ifnull(mid.affiliationenddate::varchar, ''))  or
                                MD5(ifnull(cte.affiliationname::varchar, '')) <> MD5(ifnull(mid.affiliationname::varchar, '')) or
                                MD5(ifnull(cte.affiliationtypecode::varchar, '')) <> MD5(ifnull(mid.affiliationtypecode::varchar, '')) or
                                MD5(ifnull(cte.affiliationtypedescription::varchar, '')) <> MD5(ifnull(mid.affiliationtypedescription::varchar, '')) or
                                MD5(ifnull(cte.rolecode::varchar, '')) <> MD5(ifnull(mid.rolecode::varchar, ''))or
                                MD5(ifnull(cte.roledescription::varchar, '')) <> MD5(ifnull(mid.roledescription::varchar, '')) 
                        
                        )
                        select
                            A0.ProviderToAffiliationID,
                            A0.ProviderID,
                            A0.AffiliationBeginDate,
                            A0.AffiliationEndDate,
                            A0.AffiliationName,
                            A0.AffiliationTypeCode,
                            A0.AffiliationTypeDescription,
                            A0.RoleCode,
                            A0.RoleDescription,
                            ifnull(
                                A1.ActionCode,
                                ifnull(A2.ActionCode, A0.ActionCode)
                            ) as ActionCode
                        from
                            CTE_ProviderAffiliation as A0
                            left join CTE_Action_1 as A1 on A0.ProviderToAffiliationID = A1.ProviderToAffiliationID
                            left join CTE_Action_2 as A2 on A0.ProviderToAffiliationID = A2.ProviderToAffiliationID
                        where
                            ifnull(
                                A1.ActionCode,
                                ifnull(A2.ActionCode, A0.ActionCode)
                            ) <> 0 $$;

--- update Statement
update_statement := ' update 
                     SET 
                        ProviderToAffiliationID = source.providertoaffiliationid,
                        ProviderID = source.providerid,
                        AffiliationBeginDate = source.affiliationbegindate,
                        AffiliationEndDate = source.affiliationenddate,
                        AffiliationName = source.affiliationname,
                        AffiliationTypeCode = source.affiliationtypecode,
                        AffiliationTypeDescription = source.affiliationtypedescription,
                        RoleCode = source.rolecode,
                        RoleDescription = source.roledescription';

--- insert Statement
insert_statement := ' insert  (
                            ProviderToAffiliationID,
                            ProviderID,
                            AffiliationBeginDate,
                            AffiliationEndDate,
                            AffiliationName,
                            AffiliationTypeCode,
                            AffiliationTypeDescription,
                            RoleCode,
                            RoleDescription)
                      values (
                            source.providertoaffiliationid,
                            source.providerid,
                            source.affiliationbegindate,
                            source.affiliationenddate,
                            source.affiliationname,
                            source.affiliationtypecode,
                            source.affiliationtypedescription,
                            source.rolecode,
                            source.roledescription)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.provideraffiliation as target using 
                   ('||select_statement||') as source 
                   on source.providertoaffiliationid = target.providertoaffiliationid
                   WHEN MATCHED and source.actioncode = 2 then '||update_statement|| '
                   when not matched and source.actioncode = 1 then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.ProviderAffiliation;
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