CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTODISPLAYSPECIALTY()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertodisplayspecialty depends on:
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.providertospecialty
--- base.displayspecialtyrule
--- base.displayspecialtyruletospecialty
--- base.providertocertificationspecialty
--- base.displayspecialtyruletocertificationspecialty
--- base.providertoclinicalfocus
--- base.displayspecialtyruletoclinicalfocus

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

    delete_statement string;
    select_statement string; -- cte and select statement for the insert
    insert_statement string; -- insert statement 
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertodisplayspecialty');
    execution_start datetime default getdate();

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin
--- select Statement

select_statement := $$ with CTE_ProviderBatch as (
                select p.providerid
                from MDM_team.mst.Provider_Profile_Processing as ppp
                join base.provider as p on ppp.ref_provider_code = p.providercode
            ),
            CTE_ProviderBatch as (
                                select ProviderId
                                from base.provider),
                                
                            CTE_NotExists as (
                              select 1
                              from base.providertospecialty pts
                              left join base.displayspecialtyrule as dsr on pts.specialtyid = dsr.specialtyid
                              left join base.provider as P on p.providerid = pts.providerid
                              left join base.displayspecialtyruletospecialty dsrs
                                on dsrs.displayspecialtyruleid = dsr.displayspecialtyruleid
                                and dsrs.specialtyid = pts.specialtyid
                              where pts.providerid = p.providerid
                                and pts.issearchablecalculated = 1
                                and dsrs.specialtyid is null
                            ),
                            CTE_ProviderDisplay as (
                              select distinct c.displayspecialtyruleid, a.providerid
                              from base.providertospecialty a
                              join CTE_ProviderBatch b on b.providerid = a.providerid
                              join base.displayspecialtyrule c on c.specialtyid = a.specialtyid
                              where a.issearchablecalculated = 1 and
                                    not exists (select * from CTE_NotExists)
                            ),
                            CTE_ProviderCerts as (
                                select distinct
                                    cert.providerid,
                                    dis.displayspecialtyruleid
                                from base.providertocertificationspecialty as Cert
                                join CTE_ProviderDisplay as CTE on cert.providerid = cte.providerid
                                join base.displayspecialtyruletocertificationspecialty as Dis on dis.displayspecialtyruleid = cte.displayspecialtyruleid
                            ),
                            CTE_ProviderCF as (
                                select distinct
                                    cf.providerid,
                                    discf.displayspecialtyruleid
                                from base.providertoclinicalfocus as CF
                                join CTE_ProviderDisplay as CTE on cte.providerid = cf.providerid
                                join base.displayspecialtyruletoclinicalfocus as DisCF on discf.displayspecialtyruleid = cte.displayspecialtyruleid
                            ),
                            CTE_ProviderPrimarySpec as (
                                select
                                    provspec.providerid,
                                    specrule.displayspecialtyruleid
                                from base.providertospecialty as ProvSpec
                                join CTE_ProviderDisplay as CTE on cte.providerid = provspec.providerid
                                join base.displayspecialtyrule as SpecRule on specrule.displayspecialtyruleid = cte.displayspecialtyruleid
                            )
                            select distinct
                                provds.providerid,
                                specrule.specialtyid
                            from CTE_ProviderDisplay as ProvDS
                                join base.displayspecialtyrule as SpecRule on specrule.displayspecialtyruleid = provds.providerid
                                left join CTE_ProviderCerts as ProvCert on provcert.providerid = provds.providerid and provcert.displayspecialtyruleid = specrule.displayspecialtyruleid
                                left join CTE_ProviderCF as ProvCF on provcf.providerid = provds.providerid and provcf.displayspecialtyruleid = specrule.displayspecialtyruleid
                                left join CTE_ProviderPrimarySpec as ProvPrimSpec on provprimspec.providerid = provds.providerid and provprimspec.displayspecialtyruleid = specrule.displayspecialtyruleid 
                            
                            where (((((specrule.iscertificationspecialtyrequired = 1 and provcert.providerid is not null) or (specrule.iscertificationspecialtyrequired = 0))
                            			or ((specrule.isclinicalfocurequired = 1 and provcf.providerid is not null) or (specrule.isclinicalfocurequired = 0)))) 
                            			and specrule.displayspecialtyrulecondition = 'and')
                            			or (((((specrule.iscertificationspecialtyrequired = 1 and provcert.providerid is not null) or (specrule.iscertificationspecialtyrequired = 0))
                            			or ((specrule.isclinicalfocurequired = 1 and provcf.providerid is not null) or (specrule.isclinicalfocurequired = 0)))) 
                            			and specrule.displayspecialtyrulecondition = 'or')  
                             qualify row_number() over (partition by provds.providerid order by specrule.displayspecialtyrulerank, case when specrule.isprimaryrequired = 1 and provprimspec.providerid is not null then 1 else 2 end, specrule.displayspecialtyruletiebreaker) = 1    $$;



---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

delete_statement := 'delete from base.providertodisplayspecialty 
                                    where ProviderID IN 
                                        (select p.providerid
                                        from MDM_team.mst.Provider_Profile_Processing as ppp
                                        join base.provider as p on ppp.ref_provider_code = p.providercode)';

insert_statement := ' insert INTO base.providertodisplayspecialty 
                        (ProviderID,
                        SpecialtyId) ' ||select_statement;
                   
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 

    execute immediate delete_statement;
    execute immediate insert_statement ;

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