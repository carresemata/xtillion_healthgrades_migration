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
--- mdm_team.mst.provider_profile_processing
--- base.provider
--- base.identificationtype

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_provideridentification');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

begin
    

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ 
                    with cte_identification as (
                        select
                            p.ref_provider_code as providercode,
                            to_varchar(json.value:IDENTIFICATION_TYPE_CODE) as identification_IdentificationTypeCode,
                            to_varchar(json.value:IDENTIFIER) as identification_Identifier,
                            to_varchar(json.value:EXPIRATION_DATE) as identification_ExpirationDate,
                            to_varchar(json.value:DATA_SOURCE_CODE) as identification_SourceCode,
                            to_timestamp_ntz(json.value:UPDATED_DATETIME) as identification_LastUpdateDate
                        from $$|| mdm_db ||$$.mst.provider_profile_processing as p,
                        lateral flatten(input => p.PROVIDER_PROFILE:IDENTIFICATION) as json
                    )
                    
                    select 
                        p.providerid,
                        i.identificationtypeid,
                        json.identification_Identifier as IdentificationValue,
                        json.identification_ExpirationDate as ExpirationDate,
                        json.identification_SourceCode as SourceCode,
                        json.identification_LastUpdateDate as LastUpdateDate
                    from cte_identification as json
                    join base.provider as p on p.providercode = json.providercode
                    join base.identificationtype as i on i.identificationtypecode = json.identification_IdentificationTypeCode
                    qualify row_number() over(partition by providerid, identificationtypeid, identificationvalue order by json.identification_LastUpdateDate desc ) = 1 $$;

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

--- update statement
update_statement := ' update
                        set
                            target.ExpirationDate = source.expirationdate,
                            target.SourceCode = source.sourcecode,
                            target.LastUpdateDate = source.lastupdatedate';
        
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.provideridentification as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid and source.identificationtypeid = target.identificationtypeid and target.identificationvalue = source.identificationvalue
                   when matched then ' || update_statement || '
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
