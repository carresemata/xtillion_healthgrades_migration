CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOCLIENTPRODUCTTODISPLAYPARTNER(is_full BOOLEAN)
RETURNS STRING
LANGUAGE SQL
EXECUTE as CALLER
as
declare
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.providertoclientproducttodisplaypartner depends on :
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.clienttoproduct
--- base.syndicationpartner

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
update_statement string;
merge_statement string;
status string;
    procedure_name varchar(50) default('sp_load_providertoclientproducttodisplaypartner');
    execution_start datetime default getdate();
mdm_db string default('mdm_team');

begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- select Statement
select_statement := $$  
                    with cte_customerproduct as (
                        select
                            p.ref_provider_code as providercode,
                            to_varchar(json.value:CUSTOMER_PRODUCT_CODE) as customerproduct_CustomerProductCode,
                            to_varchar(partner.value:DISPLAY_PARTNER_CODE) as customerproduct_DisplayPartner,
                            to_varchar(json.value:DATA_SOURCE_CODE) as customerproduct_SourceCode,
                            to_timestamp_ntz(json.value:UPDATED_DATETIME) as customerproduct_LastUpdateDate
                        from $$||mdm_db||$$.mst.provider_profile_processing as p,
                        lateral flatten(input => p.PROVIDER_PROFILE:CUSTOMER_PRODUCT) as json,
                        lateral flatten(input => json.value:DISPLAY_PARTNER) as partner
                        
                    )
                    
                    select
                        p.providerid,
                        cp.clienttoproductid,
                        sp.syndicationpartnerid,
                        json.customerproduct_SourceCode as SourceCode,
                        ifnull(json.customerproduct_LastUpdateDate, current_timestamp()) as LastUpdateDate
                    from cte_customerproduct as json
                    inner join base.provider as p on p.providercode = json.providercode
                    inner join base.clienttoproduct as cp on cp.clienttoproductcode = json.customerproduct_CustomerProductCode
                    inner join base.syndicationpartner as sp on sp.syndicationpartnercode = json.customerproduct_DisplayPartner
                    qualify dense_rank() over (partition by ProviderId order by json.customerproduct_LastUpdateDate desc) = 1
                    $$;

-- insert Statement
insert_statement := ' insert (
                        ProviderCPDPID,
                        ProviderID,
                        ClientToProductID,
                        SyndicationPartnerId,
                        SourceCode,
                        LastUpdateDate)
                     values (
                        uuid_string(),
                        source.providerid,
                        source.clienttoproductid,
                        source.syndicationpartnerid,
                        source.sourcecode,
                        source.lastupdatedate)';

--- update statement
update_statement := ' update
                      set
                        target.sourceCode = source.sourcecode,
                        target.lastupdatedate = source.lastupdatedate';                        



---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := 'merge into base.providertoclientproducttodisplaypartner as target
                    using ('||select_statement||') as source
                    on source.providerid = target.providerid
                        and source.clienttoproductid = target.clienttoproductid
                        and source.syndicationpartnerid = target.syndicationpartnerid
                    when matched then '||update_statement||'
                    when not matched then '|| insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToClientProductToDisplayPartner;
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

            return status;
end;
