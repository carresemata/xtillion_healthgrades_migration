CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERLSWITHSPONSORSHIPISSUES()
RETURNS varchar(16777216)
LANGUAGE SQL
EXECUTE as CALLER
as 

declare
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
--- base.providerswithsponsorshipissues depends on:
-- mid.providersponsorship
-- mid.provider

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
update_statement string;
merge_statement string;
status string;
    procedure_name varchar(50) default('sp_load_providerswithsponsorshipissues');
    execution_start datetime default getdate();


begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

select_statement := $$
                    with CTE_ProviderWithMultipleSponsorships as (
                        select ProviderCode
                        from mid.providersponsorship
                        where ProductCode <> 'LID'
                        group by ProviderCode
                        having COUNT(distinct ClientCode) > 1
                    ),
                    
                    CTE_ProviderWithNullOfficeCode as (
                        select distinct ProviderCode
                        from mid.providersponsorship
                        where ProductCode = 'PDCPRAC' and OfficeCode is null
                    ),
                    
                    CTE_ProviderWithNullPhoneXML as (
                        select distinct ps.providercode
                        from mid.providersponsorship ps
                        join mid.provider p on p.providercode = ps.providercode
                        where ps.productcode IN ('PDCHSP', 'PDCPRAC') and ps.phonexml is null
                    ),
                    
                    CTE_ProviderWithNullFacilityCode as (
                        select distinct ps.providercode
                        from mid.providersponsorship ps
                        join mid.provider p on p.providercode = ps.providercode
                        where ps.productcode = 'PDCHSP' and ps.facilitycode is null
                    ),
                    
                    CTE_AllIssues as (
                        select ProviderCode, 'Non-LID Provider has more than one sponsorship record in ODS1stage.mid.ProviderSponsorship' as IssueDescription
                        from CTE_ProviderWithMultipleSponsorships
                        union all
                        select ProviderCode, 'PDCPRAC Provider has a null OfficeCode in ODS1stage.mid.ProviderSponsorship'
                        from CTE_ProviderWithNullOfficeCode 
                        union all
                        select ProviderCode, 'PDCHSP/PDCPRAC Provider has a null PhoneXML in ODS1stage.mid.ProviderSponsorship'
                        from CTE_ProviderWithNullPhoneXML
                        union all
                        select ProviderCode, 'PDCHSP Provider has a null FacilityCode in ODS1stage.mid.ProviderSponsorship'
                        from CTE_ProviderWithNullFacilityCode
                    )
                    
                    select ProviderCode, IssueDescription
                    from CTE_AllIssues
                    $$;

insert_statement := $$ 
                    insert
                        (
                        ProviderCode, 
                        IssueDescription
                        )
                     values 
                        (
                        source.providercode,
                        source.issuedescription
                        )
                     $$;

update_statement := $$
                    update SET target.issuedescription= source.issuedescription
                    $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement := $$ merge into base.providerswithsponsorshipissues as target 
                    using ($$||select_statement||$$) as source 
                    on source.providercode = target.providercode
                    WHEN MATCHED then $$||update_statement||$$
                    when not matched then $$ ||insert_statement;

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