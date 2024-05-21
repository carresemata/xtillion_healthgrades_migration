CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOOFFICE()
RETURNS STRING
LANGUAGE SQL
EXECUTE as CALLER
as
declare

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.providertooffice depends on:
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.office

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

select_statement string; -- cte and select statement for the merge
insert_statement string; -- insert statement for the merge
merge_statement string; -- merge statement to final table
status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertooffice');
    execution_start datetime default getdate();



begin


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- select Statement
select_statement := $$ select distinct
                            p.providerid,
                            o.officeid, 
                            json.office_OfficeName as OfficeName,
                            json.office_PracticeName as PracticeName, 
                            -- IsPrimaryOffice
                            json.office_OfficeRank as ProviderOfficeRank,
                            ifnull(json.office_SourceCode, 'Profisee') as SourceCode,
                            -- ProviderOfficeRankInferenceCode
                            -- SourceAddressCount
                            ifnull(json.office_LastUpdateDate, sysdate()) as LastUpdateDate
                        
                        from raw.vw_PROVIDER_PROFILE as JSON
                            left join base.provider as P on p.providercode = json.providercode
                            join base.office as O on o.officecode = json.office_OfficeCode
                        where
                            PROVIDER_PROFILE is not null and
                            ProviderID is not null and
                            OfficeID is not null and
                            json.office_OfficeCode is not null
                        qualify row_number() over(partition by ProviderId, json.office_OfficeCode order by CREATE_DATE desc)= 1 $$;

-- insert Statement
insert_statement := $$
    insert (
        ProviderToOfficeID,
        ProviderID,
        OfficeID,
        OfficeName,
        PracticeName,
        --IsPrimaryOffice,
        ProviderOfficeRank,
        SourceCode,
        --ProviderOfficeRankInferenceCode,
        --SourceAddressCount,
        LastUpdateDate
    )
    values
        (uuid_string(),
        source.providerid,
        source.officeid,
        source.officename,
        source.practicename,
        --source.isprimaryoffice,
        source.providerofficerank,
        source.sourcecode,
        --source.providerofficerankinferencecode,
        --source.sourceaddresscount,
        source.lastupdatedate) $$;

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------

merge_statement := ' merge into base.providertooffice as TARGET
                    using (' || select_statement || ') as SOURCE
                    on target.providerid = source.providerid and target.officeid = source.officeid
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