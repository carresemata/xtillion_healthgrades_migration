CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOSPECIALTY()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertospecialty depends on: 
--- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
--- base.provider
--- base.specialty

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertospecialty');
    execution_start datetime default getdate();

   
   
begin
    


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ select distinct
                            p.providerid,
                            s.specialtyid,
                            ifnull(json.specialty_SourceCode, 'Profisee') as SourceCode,
                            ifnull(json.specialty_LastUpdatedate, current_timestamp()) as LastUpdateDate,
                            json.specialty_SpecialtyRank as SpecialtyRank,
                            ifnull(json.specialty_SpecialtyRankCalculated, 2147483647) as SpecialtyRankCalculated,
                            json.specialty_IsSearchable as IsSearchable,
                            ifnull(json.specialty_IsSearchableCalculated, 1) as IsSearchableCalculated,
                            ifnull(json.specialty_IsSpecialtyRedundant, 0) as SpecialtyIsRedundant,
                            json.specialty_SpecialtyDCPCount as SpecialtyDCPCount,
                            json.specialty_SpecialtyDCPMinFillThreshold as SpecialtyDCPMinFillThreshold,
                            json.specialty_ProviderSpecialtyDCPCount as ProviderSpecialtyDCPCount,
                            json.specialty_ProviderSpecialtyAveragePercentile as ProviderSpecialtyAveragePercentile,
                            json.specialty_IsMeetsLowThreshold as MeetsLowThreshold,
                            json.specialty_ProviderRawSpecialtyScore as ProviderRawSpecialtyScore,
                            json.specialty_ScaledSpecialtyBoost as ScaledSpecialtyBoost,
                        from raw.vw_PROVIDER_PROFILE as JSON
                             left join base.provider as P on p.providercode = json.providercode
                             left join base.specialty as S on s.specialtycode = json.specialty_SpecialtyCode
                        where
                             PROVIDER_PROFILE is not null
                             and SpecialtyID is not null
                             and ProviderID is not null 
                        qualify row_number() over( partition by ProviderID, Specialty_SpecialtyCode order by Specialty_SpecialtyRankCalculated, CREATE_DATE desc) = 1 $$;



--- insert Statement
insert_statement := ' insert  
                        (ProviderToSpecialtyID,
                        ProviderID,
                        SpecialtyID,
                        SourceCode,
                        LastUpdateDate,
                        SpecialtyRank,
                        SpecialtyRankCalculated,
                        IsSearchable,
                        IsSearchableCalculated,
                        SpecialtyIsRedundant,
                        SpecialtyDCPCount,
                        SpecialtyDCPMinFillThreshold,
                        ProviderSpecialtyDCPCount,
                        ProviderSpecialtyAveragePercentile,
                        MeetsLowThreshold,
                        ProviderRawSpecialtyScore,
                        ScaledSpecialtyBoost)
                      values 
                        (uuid_string(),
                        source.providerid,
                        source.specialtyid,
                        source.sourcecode,
                        source.lastupdatedate,
                        source.specialtyrank,
                        source.specialtyrankcalculated,
                        source.issearchable,
                        source.issearchablecalculated,
                        source.specialtyisredundant,
                        source.specialtydcpcount,
                        source.specialtydcpminfillthreshold,
                        source.providerspecialtydcpcount,
                        source.providerspecialtyaveragepercentile,
                        source.meetslowthreshold,
                        source.providerrawspecialtyscore,
                        source.scaledspecialtyboost)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.providertospecialty as target using 
                   ('||select_statement||') as source 
                   on source.providerid = target.providerid
                   WHEN MATCHED then delete
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 
                    
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