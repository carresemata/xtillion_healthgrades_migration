CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERIDENTIFICATION(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.provideridentification depends on: 
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.identificationtype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_provideridentification');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ select distinct
                            p.providerid,
                            i.identificationtypeid,
                            json.identification_Identifier as IdentificationValue,
                            json.identification_ExpirationDate as ExpirationDate,
                            json.identification_SourceCode as SourceCode,
                            json.identification_LastUpdateDate as LastUpdateDate
                        from
                            raw.vw_PROVIDER_PROFILE as JSON
                            join base.provider as P on p.providercode = json.providercode
                            join base.identificationtype as I on i.identificationtypecode = json.identification_IdentificationTypeCode
                        from
                            raw.vw_PROVIDER_PROFILE as JSON
                            join base.provider as P on p.providercode = json.providercode
                        where
                            PROVIDER_PROFILE is not null and
                            ProviderId is not null and
                            IdentificationTypeID is not null
                            qualify row_number() over(partition by ProviderID order by CREATE_DATE desc) = 1$$;

--- insert Statement
insert_statement := ' insert  
                        (ProviderIdentificationID,
                        ProviderID,
                        IdentificationTypeID,
                        IdentificationValue,
                        ExpirationDate,
                        SourceCode,
                        LastUpdateDate)
                      values 
                        (uuid_string(),
                        source.providerid,
                        source.identificationtypeid,
                        source.identificationvalue,
                        source.expirationdate,
                        source.sourcecode,
                        source.lastupdatedate)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.provideridentification as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid
                   WHEN MATCHED then delete
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderIdentification;
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