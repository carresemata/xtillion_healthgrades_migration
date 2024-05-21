CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.Mid.SP_LOAD_PROVIDERPROCEDURE()
RETURNS varchar(16777216)
LANGUAGE SQL
EXECUTE as CALLER
as 

declare
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

--- mid.providerprocedure depends on:
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
    update_statement string;
    merge_statement string; 
    status string;
    procedure_name varchar(50) default('sp_load_providerprocedure');
    execution_start datetime default getdate();

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------  

begin

    select_statement := $$
                        with CTE_ProviderBatch as (
                        select p.providerid
                        from MDM_team.mst.Provider_Profile_Processing as ppp
                            join base.provider as p on ppp.ref_provider_code = p.providercode
                        order by p.providerid
                        ),
                    
                        CTE_ProviderProcedure as (
                            select
                                etmt.entitytomedicaltermid as ProviderToProcedureID,
                                etmt.entityid as ProviderID,
                                mt.medicaltermcode as ProcedureCode,
                                mt.medicaltermdescription1 as ProcedureDescription,
                                mt.medicaltermdescription2 as ProcedureGroupDescription,
                                mt.legacykey,
                                CASE
                                    WHEN mpp.providertoprocedureid is null then 1
                                    else 0
                                END as ActionCode
                            from CTE_ProviderBatch as pb
                            inner join base.entitytomedicalterm as etmt on etmt.entityid = pb.providerid
                            inner join base.medicalterm as mt on mt.medicaltermid = etmt.medicaltermid
                            inner join base.entitytype as et on et.entitytypeid = etmt.entitytypeid
                            inner join base.medicaltermset as mts on mts.medicaltermsetid = mt.medicaltermsetid
                            inner join base.medicaltermtype as mtt on mtt.medicaltermtypeid = mt.medicaltermtypeid
                            left join mid.providerprocedure as mpp on etmt.entitytomedicaltermid = mpp.providertoprocedureid
                        )
                        
                        select
                            pp.providertoprocedureid,
                            pp.providerid,
                            pp.procedurecode,
                            pp.proceduredescription,
                            pp.proceduregroupdescription,
                            pp.legacykey,
                            pp.actioncode
                        from CTE_ProviderProcedure pp)
                        $$;
      

      ---------------------------------------------------------
      --------- 4. actions (inserts and updates) --------------
      ---------------------------------------------------------

      update_statement := $$
                         update SET 
                            target.legacykey = source.legacykey,
                            target.procedurecode = source.procedurecode,
                            target.proceduredescription = source.proceduredescription,
                            target.proceduregroupdescription = source.proceduregroupdescription,
                            target.providerid = source.providerid
                          $$;

      
      insert_statement := $$
                         insert
                         ( 
                         LegacyKey,
                         ProcedureCode,
                         ProcedureDescription,
                         ProcedureGroupDescription,
                         ProviderID,
                         ProviderToProcedureID
                         )
                         values 
                         (
                         source.legacykey,
                         source.procedurecode,
                         source.proceduredescription,
                         source.proceduregroupdescription,
                         source.providerid,
                         source.providertoprocedureid
                         )
                         $$;


     merge_statement := $$
                        merge into mid.providerprocedure as target
                        using $$ || select_statement || $$ as source
                        on source.providertoprocedureid = target.providertoprocedureid
                        WHEN MATCHED and MD5(ifnull(CAST(target.legacykey as varchar), '')) <> MD5(ifnull(CAST(source.legacykey as varchar), '')) or 
                                        MD5(ifnull(CAST(target.procedurecode as varchar), '')) <> MD5(ifnull(CAST(source.procedurecode as varchar), '')) or 
                                        MD5(ifnull(CAST(target.proceduredescription as varchar), '')) <> MD5(ifnull(CAST(source.proceduredescription as varchar), '')) or 
                                        MD5(ifnull(CAST(target.proceduregroupdescription as varchar), '')) <> MD5(ifnull(CAST(source.proceduregroupdescription as varchar), '')) or 
                                        MD5(ifnull(CAST(target.providerid as varchar), '')) <> MD5(ifnull(CAST(source.providerid as varchar), '')) 
                                        then $$ || update_statement || $$
                        WHEN MATCHED and source.providertoprocedureid = target.providertoprocedureid and target.providertoprocedureid is null then delete
                        when not matched then $$ || insert_statement;
        

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