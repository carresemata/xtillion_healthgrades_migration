CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOCLIENTPRODUCTTODISPLAYPARTNER()
RETURNS STRING
LANGUAGE SQL
EXECUTE as CALLER
as
declare
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.providertoclientproducttodisplaypartner depends on :
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.clienttoproduct
--- base.syndicationpartner


---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
merge_statement string;
status string;
    procedure_name varchar(50) default('sp_load_providertoclientproducttodisplaypartner');
    execution_start datetime default getdate();

begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- select Statement
select_statement := $$  select distinct
                        p.providerid,
                        cp.clienttoproductid,
                        sp.syndicationpartnerid,
                        json.customerproduct_SOURCECODE as SourceCode,
                        ifnull(json.customerproduct_LASTUPDATEDATE, sysdate()) as LastUpdateDate
                        
                        from raw.vw_PROVIDER_PROFILE as JSON
                            inner join base.provider as P on p.providercode = json.providercode
                            inner join base.clienttoproduct as cp on cp.clienttoproductcode = json.customerproduct_CUSTOMERPRODUCTCODE
                            inner join base.syndicationpartner as SP on sp.syndicationpartnercode = json.customerproduct_DISPLAYPARTNER
                        
                        where
                            PROVIDER_PROFILE is not null and
                            json.customerproduct_CUSTOMERPRODUCTCODE is not null and
                            json.customerproduct_DISPLAYPARTNER is not null and
                            ClientToProductID is not null and
                            ProviderID is not null
                        
                        qualify dense_rank() over(partition by ProviderID, json.customerproduct_CUSTOMERPRODUCTCODE order by CREATE_DATE desc) = 1 $$;

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


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := 'merge into base.providertoclientproducttodisplaypartner as target
using
('||select_statement||') as source
on source.providerid = target.providerid
and source.clienttoproductid = target.clienttoproductid
and source.syndicationpartnerid = target.syndicationpartnerid
WHEN MATCHED then delete
when not matched then' || insert_statement;

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