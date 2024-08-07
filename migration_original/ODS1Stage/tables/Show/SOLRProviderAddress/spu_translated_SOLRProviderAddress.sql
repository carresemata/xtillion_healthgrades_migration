CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRPROVIDERADDRESS(is_full BOOLEAN)
RETURNS varchar(16777216)
LANGUAGE SQL
EXECUTE as CALLER
as 

    ---------------------------------------------------------
    --------------- 1. table dependencies -------------------
    ---------------------------------------------------------
    
    -- Show.SOLRProviderAddress depends on: 
    --- Show.SOLRProvider 
    --- Mid.ProviderPracticeOffice
    --- Mid.Provider
    --- Base.ProviderRemoval
    

    ---------------------------------------------------------
    --------------- 2. declaring variables ------------------
    ---------------------------------------------------------
    declare 
    select_statement string; -- ctes
    insert_statement string; -- insert statements
    update_statement string; -- update statements
    delete_statement string; -- delete statements
    merge_statement string; -- merge statement 
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrprovideraddress');
    execution_start datetime default getdate();


    
    ---------------------------------------------------------
    --------------- 3. select statements --------------------
    ---------------------------------------------------------     
    begin
    
    select_statement := '
                with CTE_ProviderID as (
                    select ProviderID
                    from Mid.ProviderPracticeOffice
                    group by
                        ProviderID,
                        City,
                        State
                ),
                
                CTE_MultipleLocations as (
                    select ProviderID
                    from CTE_ProviderID
                    group by ProviderID
                    having COUNT(*) > 1
                ),

                -- this is a workaround for the weird function assigning this column in 
                -- SQL Server which has unsupported subqueries in Snowflake
                CTE_CityStateAlternatives as (
                    SELECT 
                        ProviderID,
                        LISTAGG(CityState, ''; '') WITHIN GROUP (ORDER BY CityState) as CityStateAlternative
                    FROM (
                        SELECT 
                            ProviderID,
                            City || '', '' || State as CityState,
                            ROW_NUMBER() OVER (PARTITION BY ProviderID ORDER BY City, State) as rn
                        FROM Mid.ProviderPracticeOffice
                        GROUP BY ProviderID, City, State
                    )
                    WHERE rn > 1 
                    GROUP BY ProviderID
                ),
                
                CTE_Source as (
                    select
                        distinct ppo.ProviderToOfficeID,
                        p.ProviderID,
                        p.ProviderCode,
                        ppo.AddressLine1,
                        ppo.AddressLine2,
                        ppo.City,
                        ppo.State,
                        ppo.ZipCode,
                        ppo.Latitude,
                        ppo.Longitude,
                        ppo.City || '', '' || ppo.State as CityState,
                        COALESCE(csa.CityStateAlternative, NULL) as CityStateAlternative,
                        ppo.OfficeCode,
                        ppo.IsPrimaryOffice,
                        ppo.FullPhone,
                        ppo.officeId,
                        CASE
                            WHEN ml.ProviderID is not null then 1
                            else 0
                        END as MultipleLocations,
                        TO_GEOGRAPHY(ST_MAKEPOINT(ppo.LONGITUDE, ppo.LATITUDE)) as AddressGeoPoint,
                        row_number() over (order by p.ProviderCode NULLS FIRST) as SequenceId
                    from
                        Mid.Provider p
                        inner join Mid.ProviderPracticeOffice ppo on p.ProviderID = ppo.ProviderID
                        left join CTE_MultipleLocations ml on p.ProviderID = ml.ProviderID
                        left join CTE_CityStateAlternatives csa ON p.ProviderID = csa.ProviderID
                )
                
                select distinct
                    ProviderToOfficeID,
                    ProviderID,
                    ProviderCode,
                    AddressLine1,
                    AddressLine2,
                    City,
                    State,
                    ZipCode,
                    Latitude,
                    Longitude,
                    CityState,
                    CityStateAlternative,
                    OfficeCode,
                    IsPrimaryOffice,
                    FullPhone,
                    AddressGeoPoint
                from CTE_Source
               ';

                     
---------------------------------------------------------
--------------------  4. actions ------------------------
---------------------------------------------------------  

insert_statement := '
                  insert (
                            SOLRProviderAddressID,
                            ProviderToOfficeID,
                            ProviderID,
                            ProviderCode,
                            AddressLine1,
                            AddressLine2,
                            City,
                            State,
                            ZipCode,
                            Latitude,
                            Longitude,
                            CityState,
                            CityStateAlternative,
                            OfficeCode,
                            IsPrimaryOffice,
                            FullPhone,
                            AddressGeoPoint
                            )
                    values (
                            uuid_string(),
                            source.ProviderToOfficeID,
                            source.ProviderID,
                            source.ProviderCode,
                            source.AddressLine1,
                            source.AddressLine2,
                            source.City,
                            source.State,
                            source.ZipCode,
                            source.Latitude,
                            source.Longitude,
                            source.CityState,
                            source.CityStateAlternative,
                            source.OfficeCode,
                            source.IsPrimaryOffice,
                            source.FullPhone,
                            source.AddressGeoPoint
                            ) 
                    ';

update_statement := '
                    update 
                    SET
                      ProviderID = source.ProviderID,
                      ProviderCode = source.ProviderCode,
                      AddressLine1 = source.AddressLine1,
                      AddressLine2 = source.AddressLine2,
                      City = source.City,
                      State = LEFT(source.State, 2),
                      ZipCode = source.ZipCode,
                      Latitude = source.Latitude,
                      Longitude = source.Longitude,
                      CityState = source.CityState,
                      CityStateAlternative = source.CityStateAlternative,
                      OfficeCode = source.OfficeCode,
                      IsPrimaryOffice = source.IsPrimaryOffice,
                      FullPhone = source.FullPhone,
                      RefreshDate = current_timestamp()
                    ';

-- This is the merge statement from logic of show.spuSOLRProviderAddressGenerateFromMid                     
merge_statement := '
                   merge into show.solrprovideraddress as target
                   using ('||select_statement||') as source
                    on target.ProviderID = source.ProviderID
                    and target.ProviderToOfficeID = source.ProviderToOfficeID
                   when matched then '||update_statement||'
                   when not matched then '||insert_statement||'
                   ';

-- This delete comes from hack.spuRemoveSuspecProviders
delete_statement := '
                    delete from show.solrprovideraddress spa
                    using Base.ProviderRemoval pr, Show.SOLRProvider sp
                    where sp.ProviderCode = pr.ProviderCode
                    and sp.ProviderID = spa.ProviderID
                    ';

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Show.SOLRProviderAddress;
end if; 
execute immediate merge_statement;
execute immediate delete_statement; 

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
--------------------------------------------------------- 

status := 'Completed successfully';
    return status;
        
exception
    WHEN other then
          status := 'Failed during execution.' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
          return status;
END
;