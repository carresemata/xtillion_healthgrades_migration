CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_PROVIDERTOSPECIALTY(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- base.providertospecialty depends on: 
--- mdm_team.mst.provider_profile_processing 
--- base.provider
--- base.specialty

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    update_statement string; -- update
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_providertospecialty');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
   
begin
    
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
select_statement := $$ with Cte_specialty as (
    SELECT
        p.ref_provider_code as providercode,
        to_varchar(json.value:SPECIALTY_CODE) as Specialty_SpecialtyCode,
        to_varchar(json.value:SPECIALTY_RANK) as Specialty_SpecialtyRank,
        to_varchar(json.value:SPECIALTY_RANK_CALCULATED) as Specialty_SpecialtyRankCalculated,
        to_boolean(json.value:IS_SEARCHABLE) as Specialty_IsSearchable,
        to_boolean(json.value:IS_SEARCHABLE_CALCULATED) as Specialty_IsSearchableCalculated,
        to_varchar(json.value:SPECIALTY_DCP_COUNT) as Specialty_SpecialtyDcpCount,
        to_boolean(json.value:IS_SPECIALTY_REDUNDANT) as Specialty_IsSpecialtyRedundant,
        to_varchar(json.value:SPECIALTY_DCP_MIN_FILL_THRESHOLD) as Specialty_SpecialtyDcpMinFillThreshold,
        to_varchar(json.value:PROVIDER_SPECIALTY_DCP_COUNT) as Specialty_ProviderSpecialtyDcpCount,
        to_varchar(json.value:PROVIDER_SPECIALTY_AVERAGE_PERCENTILE) as Specialty_ProviderSpecialtyAveragePercentile,
        to_boolean(json.value:IS_MEETS_LOW_THRESHOLD) as Specialty_IsMeetsLowThreshold,
        to_varchar(json.value:PROVIDER_RAW_SPECIALTY_SCORE) as Specialty_ProviderRawSpecialtyScore,
        to_varchar(json.value:SCALED_SPECIALTY_BOOST) as Specialty_ScaledSpecialtyBoost,
        to_varchar(json.value:DATA_SOURCE_CODE) as Specialty_SourceCode,
        to_timestamp_ntz(json.value:UPDATED_DATETIME) as Specialty_LastUpdateDate
    FROM $$||mdm_db||$$.mst.provider_profile_processing as p
    , lateral flatten(input => p.PROVIDER_PROFILE:SPECIALTY) as json
)
select distinct
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
from Cte_specialty as JSON
    join base.provider as P on p.providercode = json.providercode
    join base.specialty as S on s.specialtycode = json.specialty_SpecialtyCode 
qualify row_number() over(partition by providerid, specialtyid order by specialty_LastUpdatedate desc) = 1
 $$;


--- update statement
update_statement := ' update
    set
        target.SourceCode = source.SourceCode,
        target.LastUpdateDate = source.LastUpdateDate,
        target.SpecialtyRank = source.SpecialtyRank,
        target.SpecialtyRankCalculated = source.SpecialtyRankCalculated,
        target.IsSearchable = source.IsSearchable,
        target.IsSearchableCalculated = source.IsSearchableCalculated,
        target.SpecialtyIsRedundant = source.SpecialtyIsRedundant,
        target.SpecialtyDCPCount = source.SpecialtyDCPCount,
        target.SpecialtyDCPMinFillThreshold = source.SpecialtyDCPMinFillThreshold,
        target.ProviderSpecialtyDCPCount = source.ProviderSpecialtyDCPCount,
        target.ProviderSpecialtyAveragePercentile = source.ProviderSpecialtyAveragePercentile,
        target.MeetsLowThreshold = source.MeetsLowThreshold,
        target.ProviderRawSpecialtyScore = source.ProviderRawSpecialtyScore,
        target.ScaledSpecialtyBoost = source.ScaledSpecialtyBoost';

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
                   on source.providerid = target.providerid and source.specialtyid = target.specialtyid
                   when matched then '|| update_statement ||'
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ProviderToSpecialty;
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