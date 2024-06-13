CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PROVIDERHEALTHINSURANCE(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- mid.providerhealthinsurance depends on: 
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.providertohealthinsurance
--- base.healthinsuranceplantoplantype
--- base.healthinsuranceplan
--- base.healthinsurancepayor
--- base.healthinsuranceplantype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    update_condition string;
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providerhealthinsurance');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin
--- select Statement

select_statement := $$  
                    with CTE_ProviderBatch as (
                        select
                            p.providerid
                        from
                            mdm_team.mst.Provider_Profile_Processing as ppp
                        join base.provider as P on p.providercode = ppp.ref_provider_code
                    ),
                    CTE_PayorProductCount as (
                        select
                            hipay.payorcode,
                            COUNT(*) as PayorProductCount
                        from
                            base.healthinsuranceplantoplantype as hipt
                            join base.healthinsuranceplan as hip on hipt.healthinsuranceplanid = hip.healthinsuranceplanid
                            right join base.healthinsurancepayor as hipay on hip.healthinsurancepayorid = hipay.healthinsurancepayorid
                        where
                            hipay.payorname != hipt.productname
                        group by
                            hipay.payorcode
                    )
                    select distinct
                        pthi.providertohealthinsuranceid,
                        pthi.providerid,
                        hipt.healthinsuranceplantoplantypeid,
                        hipt.productname,
                        hip.planname,
                        hip.plandisplayname,
                        hipay.payorname,
                        hiptd.plantypedescription,
                        hiptd.plantypedisplaydescription,
                        CASE
                            WHEN hipay.payorname IN (
                                'Name of Insurance Unknown',
                                'Accepts most insurance',
                                'Accepts most major Health Plans. Please contact our office for details.'
                            ) then 0
                            else 1
                        END as Searchable,
                        hipay.payorcode,
                        hipay.healthinsurancepayorid,
                        pc.payorproductcount,
                    from
                        CTE_ProviderBatch as pb
                        join base.providertohealthinsurance as pthi on pthi.providerid = pb.providerid
                        join base.healthinsuranceplantoplantype as hipt on pthi.healthinsuranceplantoplantypeid = hipt.healthinsuranceplantoplantypeid
                        join base.healthinsuranceplan as hip on hipt.healthinsuranceplanid = hip.healthinsuranceplanid
                        join base.healthinsurancepayor as hipay on hip.healthinsurancepayorid = hipay.healthinsurancepayorid
                        join base.healthinsuranceplantype as hiptd on hipt.healthinsuranceplantypeid = hiptd.healthinsuranceplantypeid
                        join CTE_PayorProductCount as pc on pc.payorcode = hipay.payorcode
                    $$;

--- update Statement
update_statement := ' update
                        SET
                            target.healthinsurancepayorid = source.healthinsurancepayorid,
                            target.healthinsuranceplantoplantypeid = source.healthinsuranceplantoplantypeid,
                            target.payorcode = source.payorcode,
                            target.payorname = source.payorname,
                            target.plandisplayname = source.plandisplayname,
                            target.planname = source.planname,
                            target.plantypedescription = source.plantypedescription,
                            target.plantypedisplaydescription = source.plantypedisplaydescription,
                            target.productname = source.productname,
                            target.providerid = source.providerid,
                            target.searchable = source.searchable';

--- update Condition
update_condition := 'target.healthinsurancepayorid != source.healthinsurancepayorid
                            or target.healthinsuranceplantoplantypeid != source.healthinsuranceplantoplantypeid
                            or target.payorcode != source.payorcode
                            or target.payorname != source.payorname
                            or target.plandisplayname != source.plandisplayname
                            or target.planname != source.planname
                            or target.plantypedescription != source.plantypedescription
                            or target.plantypedisplaydescription != source.plantypedisplaydescription
                            or target.productname != source.productname
                            or target.providerid != source.providerid
                            or target.searchable != source.searchable';

--- insert Statement
insert_statement := ' insert
                        (   HealthInsurancePayorID,
                            HealthInsurancePlanToPlanTypeID,
                            PayorCode,
                            PayorName,
                            PayorProductCount,
                            PlanDisplayName,
                            PlanName,
                            PlanTypeDescription,
                            PlanTypeDisplayDescription,
                            ProductName,
                            ProviderID,
                            ProviderToHealthInsuranceID,
                            Searchable
                        )
                    values
                        (
                            source.healthinsurancepayorid,
                            source.healthinsuranceplantoplantypeid,
                            source.payorcode,
                            source.payorname,
                            source.payorproductcount,
                            source.plandisplayname,
                            source.planname,
                            source.plantypedescription,
                            source.plantypedisplaydescription,
                            source.productname,
                            source.providerid,
                            source.providertohealthinsuranceid,
                            source.searchable
                        );';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.providerhealthinsurance as target using 
                   ('||select_statement||') as source 
                   on target.providertohealthinsuranceid = source.providertohealthinsuranceid
                   WHEN MATCHED and ('||update_condition||') then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.ProviderHealthInsurance;
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