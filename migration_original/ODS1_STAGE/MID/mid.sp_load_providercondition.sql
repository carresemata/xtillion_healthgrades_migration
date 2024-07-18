CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.Mid.SP_LOAD_PROVIDERCONDITION(is_full BOOLEAN)
RETURNS varchar(16777216)
LANGUAGE SQL
EXECUTE as CALLER
as 

declare
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

-- mid.providercondition depends on:
-- mdm_team.mst.provider_profile_processing
-- base.provider
-- base.entitytomedicalterm
-- base.medicalterm
-- base.entitytype
-- base.medicaltermset
-- base.medicaltermtype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
  
  select_statement string; 
  insert_statement string;
  merge_statement string; 
  status string;
  procedure_name varchar(50) default('sp_load_providercondition');
  execution_start datetime default getdate();
  mdm_db string default('mdm_team');

---------------------------------------------------------
----------------- 3. sql statements ---------------------
---------------------------------------------------------  

begin
        select_statement := $$
                            (with CTE_ProviderBatch as (
                                select
                                    p.providerid
                                from
                                    $$||mdm_db||$$.mst.Provider_Profile_Processing as ppp
                                join base.provider as P on p.providercode = ppp.ref_provider_code
                            ),
                            
                            CTE_ProviderCondition as (
                                select
                                    etmt.entitytomedicaltermid as ProviderToConditionID,
                                    etmt.entityid as ProviderID,
                                    mt.medicaltermcode as ConditionCode,
                                    mt.medicaltermdescription1 as ConditionDescription,
                                    mt.medicaltermdescription2 as ConditionGroupDescription,
                                    mt.legacykey
                                from CTE_ProviderBatch as pb
                                inner join base.entitytomedicalterm as etmt on etmt.entityid = pb.providerid 
                                inner join base.medicalterm as mt on mt.medicaltermid = etmt.medicaltermid
                                inner join base.entitytype as et on et.entitytypeid = etmt.entitytypeid
                                inner join base.medicaltermset as mts on mts.medicaltermsetid = mt.medicaltermsetid
                                inner join base.medicaltermtype as mtt on mtt.medicaltermtypeid = mt.medicaltermtypeid
                                left join mid.providercondition as mpc on etmt.entitytomedicaltermid = mpc.providertoconditionid
                                where mts.medicaltermsetcode = 'HGProvider' and mtt.medicaltermtypecode = 'Condition'
                                 and (MD5(ifnull(CAST(mt.medicaltermcode as varchar), '')) <> MD5(ifnull(CAST(mpc.conditioncode as varchar), '')) or 
                                      MD5(ifnull(CAST(mt.medicaltermdescription1 as varchar), '')) <> MD5(ifnull(CAST(mpc.conditiondescription as varchar), '')) or 
                                      MD5(ifnull(CAST(mt.medicaltermdescription2 as varchar), '')) <> MD5(ifnull(CAST(mpc.conditiongroupdescription as varchar), '')) or 
                                      MD5(ifnull(CAST(mt.legacykey as varchar), '')) <> MD5(ifnull(CAST(mpc.legacykey as varchar), '')) or 
                                      MD5(ifnull(CAST(etmt.entityid as varchar), '')) <> MD5(ifnull(CAST(mpc.providerid as varchar), '')))
                             ) 
                             
                             select
                              pc.conditioncode,
                              pc.conditiondescription,
                              pc.conditiongroupdescription,
                              pc.legacykey,
                              pc.providerid,
                              pc.providertoconditionid
                             from CTE_ProviderCondition pc)
                            $$;

              insert_statement := $$
                         insert 
                          ( 
                          ConditionCode,
                          ConditionDescription,
                          ConditionGroupDescription,
                          LegacyKey,
                          ProviderID,
                          ProviderToConditionID
                          )
                         values 
                          (
                          source.conditioncode,
                          source.conditiondescription,
                          source.conditiongroupdescription,
                          source.legacykey,
                          source.providerid,
                          source.providertoconditionid
                          )
                          $$;    

      ---------------------------------------------------------
      --------- 4. actions (inserts and updates) --------------
      ---------------------------------------------------------

      merge_statement := $$
                        merge into mid.providercondition as target 
                        using $$ || select_statement || $$ as source	
                        on source.providertoconditionid = target.providertoconditionid
                        WHEN MATCHED and target.providertoconditionid = source.providertoconditionid
                                     and source.providerid = target.providerid 
                                     and source.providertoconditionid is null then delete
                        when not matched then $$ || insert_statement;

    ---------------------------------------------------------
    ------------------- 5. execution ------------------------
    --------------------------------------------------------- 
    
    if (is_full) then
        truncate table mid.providercondition;
    end if; 
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

            raise;
end;