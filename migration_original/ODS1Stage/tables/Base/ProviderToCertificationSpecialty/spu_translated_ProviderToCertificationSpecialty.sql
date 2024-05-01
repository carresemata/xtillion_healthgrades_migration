CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERTOCERTIFICATIONSPECIALTY()
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderToCertificationSpecialty depends on: 
--- Raw.VW_PROVIDER_PROFILE
--- Base.Provider
--- Base.CertificationBoard
--- Base.CertificationSpecialty
--- Base.CertificationAgency
--- Base.CertificationStatus
--- Base.MocLevel
--- Base.MocPathway

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    -- no conditionals


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- Select Statement
select_statement := $$  SELECT DISTINCT
                            P.ProviderId,
                            CS.CertificationSpecialtyID,
                            IFNULL(JSON.CERTIFICATIONSPECIALTY_SOURCECODE, 'Profisee') AS SourceCode,
                            IFNULL(JSON.CERTIFICATIONSPECIALTY_LASTUPDATEDATE, SYSDATE()) AS LastUpdateDate,
                            CB.CertificationBoardID, 
                            CA.CertificationAgencyID,
                            --CertificationSpecialtyRank
                            CST.CertificationStatusID,
                            -- CertificationStatusDate, 
                            JSON.CERTIFICATIONSPECIALTY_CERTIFICATIONEFFECTIVEDATE AS CertificationEffectiveDate, 
                            JSON.CERTIFICATIONSPECIALTY_CERTIFICATIONEXPIRATIONDATE AS CertificationExpirationDate, 
                            -- IsSearchable, 
                            -- CertificationAgencyVerified, 
                            MP.MOCPathwayID, 
                            ML.MOCLevelID
                        FROM Raw.VW_PROVIDER_PROFILE AS JSON
                            INNER JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                            INNER JOIN Base.CertificationSpecialty AS CS ON CS.CertificationSpecialtyCode = JSON.CERTIFICATIONSPECIALTY_CERTIFICATIONSPECIALTYCODE
                            INNER JOIN Base.CertificationBoard AS CB ON CB.CertificationBoardCode = JSON.CERTIFICATIONSPECIALTY_CERTIFICATIONBOARDCODE
                            INNER JOIN Base.CertificationAgency AS CA ON CA.CertificationAgencyCode = JSON.CERTIFICATIONSPECIALTY_CERTIFICATIONAGENCYCODE
                            INNER JOIN Base.CertificationStatus AS CST ON CST.CertificationStatusCode = JSON.CERTIFICATIONSPECIALTY_CERTIFICATIONSTATUSCODE
                            INNER JOIN Base.MOCPathway AS MP ON MP.MOCPathwayCode = JSON.CERTIFICATIONSPECIALTY_MOCPATHWAYCODE
                            INNER JOIN Base.MOCLevel AS ML ON ML.MOCLevelCode = JSON.CERTIFICATIONSPECIALTY_MOCLEVELCODE
                        WHERE
                            PROVIDER_PROFILE IS NOT NULL AND
                            PROVIDERID IS NOT NULL AND
                            CERTIFICATIONSPECIALTYID IS NOT NULL AND
                            CERTIFICATIONBOARDID IS NOT NULL AND
                            CERTIFICATIONAGENCYID IS NOT NULL 
                        QUALIFY row_number() over(partition by PROVIDERID, JSON.CERTIFICATIONSPECIALTY_CERTIFICATIONAGENCYCODE, JSON.CERTIFICATIONSPECIALTY_CERTIFICATIONBOARDCODE, JSON.CERTIFICATIONSPECIALTY_CERTIFICATIONSPECIALTYCODE order by JSON.CERTIFICATIONSPECIALTY_CERTIFICATIONEFFECTIVEDATE desc, JSON.CERTIFICATIONSPECIALTY_CERTIFICATIONEXPIRATIONDATE desc, case when JSON.CERTIFICATIONSPECIALTY_CERTIFICATIONSTATUSCODE = 'C' then 1 else 9 end, CREATE_DATE desc) = 1 $$;

-- Insert Statement
insert_statement := ' INSERT (
                        ProviderToCertificationSpecialtyID, 
                        ProviderID, 
                        CertificationSpecialtyID, 
                        SourceCode, 
                        LastUpdateDate, 
                        CertificationBoardID, 
                        CertificationAgencyID, 
                        --CertificationSpecialtyRank, 
                        CertificationStatusID, 
                        --CertificationStatusDate, 
                        CertificationEffectiveDate, 
                        CertificationExpirationDate, 
                        --IsSearchable, 
                        --CertificationAgencyVerified, 
                        MOCPathwayID, 
                        MOCLevelID)
                     VALUES (
                       UUID_STRING(),
                       source.ProviderID, 
                       source.CertificationSpecialtyID, 
                       source.SourceCode, 
                       source.LastUpdateDate, 
                       source.CertificationBoardID, 
                       source.CertificationAgencyID, 
                       --source.CertificationSpecialtyRank, 
                       source.CertificationStatusID, 
                       --source.CertificationStatusDate, 
                       source.CertificationEffectiveDate, 
                       source.CertificationExpirationDate, 
                       --source.IsSearchable, 
                       --source.CertificationAgencyVerified, 
                       source.MOCPathwayID, 
                       source.MOCLevelID )';


---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := 'MERGE INTO Base.ProviderToCertificationSpecialty AS target
USING ('||select_statement||') AS source
ON  source.ProviderID = target.ProviderID AND
    source.CertificationSpecialtyID = target.CertificationSpecialtyID AND
    source.CertificationBoardID = target.CertificationBoardID AND
    source.CertificationAgencyID = target.CertificationAgencyID AND
    source.CertificationStatusID = target.CertificationStatusID
WHEN MATCHED THEN DELETE
WHEN NOT MATCHED THEN' || insert_statement;

---------------------------------------------------------
------------------- 5. Execution ------------------------
---------------------------------------------------------
EXECUTE IMMEDIATE merge_statement;

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
---------------------------------------------------------
status := 'Completed successfully';
RETURN status;

EXCEPTION
WHEN OTHER THEN
status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
RETURN status;

END;