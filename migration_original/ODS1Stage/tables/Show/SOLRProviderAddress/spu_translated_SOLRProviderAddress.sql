-- sp_load_solrprovideraddress

CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.Show.SP_LOAD_SOLRPROVIDERADDRESS()
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
    merge_statement string; -- merge statement combining everything
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
                        CONCAT(ppo.City, '''', '''', ppo.State) as CityState,
                        CAST(null as varchar(1000)) as CityStateAlternative,
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
                )
                
                select
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
                            s.ProviderToOfficeID,
                            s.ProviderID,
                            s.ProviderCode,
                            s.AddressLine1,
                            s.AddressLine2,
                            s.City,
                            s.State,
                            s.ZipCode,
                            s.Latitude,
                            s.Longitude,
                            s.CityState,
                            s.CityStateAlternative,
                            s.OfficeCode,
                            s.IsPrimaryOffice,
                            s.FullPhone,
                            s.AddressGeoPoint
                            ) 
                    ';

update_statement := '
                    update 
                    SET
                      ProviderID = s.ProviderID,
                      ProviderCode = s.ProviderCode,
                      AddressLine1 = s.AddressLine1,
                      AddressLine2 = s.AddressLine2,
                      City = s.City,
                      State = LEFT(s.State, 2),
                      ZipCode = s.ZipCode,
                      Latitude = s.Latitude,
                      Longitude = s.Longitude,
                      CityState = s.CityState,
                      CityStateAlternative = s.CityStateAlternative,
                      OfficeCode = s.OfficeCode,
                      IsPrimaryOffice = s.IsPrimaryOffice,
                      FullPhone = s.FullPhone,
                      RefreshDate = current_timestamp()
                    ';

-- This is the merge statement from logic of show.spuSOLRProviderAddressGenerateFromMid                     
merge_statement := '
                   merge into DEV.SOLRProviderAddress using 
                   ('||select_statement||') as s 
                   on DEV.SOLRPROVIDERADDRESS.ProviderToOfficeID = s.ProviderToOfficeID
                   WHEN MATCHED then '||update_statement||'
                   when not matched then '||insert_statement||'
                   ';

-- This delete comes from hack.spuRemoveSuspecProviders
delete_statement := '
                    delete from DEV.SOLRProviderAddress spa
                    using Base.ProviderRemoval pr, Show.SOLRProvider sp
                    where sp.ProviderCode = pr.ProviderCode
                    and sp.ProviderID = spa.ProviderID
                    ';

---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
execute immediate delete_statement; 
execute immediate merge_statement;

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