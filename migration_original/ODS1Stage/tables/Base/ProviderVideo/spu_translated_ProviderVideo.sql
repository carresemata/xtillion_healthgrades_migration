CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERVIDEO()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
DECLARE

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.ProviderVideo depends on:
--- Raw.VW_PROVIDER_PROFILE
--- Base.Provider
--- Base.MediaVideoHost
--- Base.MediaReviewLevel
--- Base.MediaContextType

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
-- No conditionals

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

-- Select Statement
select_statement := $$ SELECT 
                            P.ProviderId, 
                            JSON.VIDEO_SRCIDENTIFIER AS ExternalIdentifier,
                            MH.MediaVideoHostId,
                            MR.MediaReviewLevelId,
                            IFNULL(JSON.Video_SourceCode, 'Profisee') AS SourceCode,
                            IFNULL(JSON.Video_LastUpdateDate, SYSDATE()) AS LastUpdateDate,
                            MC.MediaContextTypeId
                        
                        FROM RAW.VW_PROVIDER_PROFILE AS JSON
                            LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                            LEFT JOIN Base.MediaVideoHost AS MH ON MH.MediaVideohostCode = JSON.VIDEO_REFMEDIAVIDEOHOSTCODE
                            LEFT JOIN Base.MediaReviewLevel AS MR ON JSON.VIDEO_REFMEDIAREVIEWLEVELCODE = MR.MediaReviewLevelCode
                            LEFT JOIN Base.MediaContextType AS MC ON JSON.VIDEO_REFMEDIACONTEXTTYPECODE = MC.MediaContextTypeCode
                        WHERE PROVIDER_PROFILE IS NOT NULL
                            AND PROVIDERID IS NOT NULL
                            AND JSON.VIDEO_SRCIDENTIFIER IS NOT NULL
                            AND MEDIAVIDEOHOSTID IS NOT NULL
                            AND MEDIAREVIEWLEVELID IS NOT NULL
                            AND MEDIACONTEXTTYPEID IS NOT NULL
                        QUALIFY row_number() over(partition by ProviderId, JSON.VIDEO_REFMEDIACONTEXTTYPECODE, JSON.VIDEO_REFMEDIAVIDEOHOSTCODE order by CREATE_DATE desc) = 1 $$;

-- Insert Statement
insert_statement := 'INSERT 
                        (PROVIDERVIDEOID, 
                        PROVIDERID, 
                        EXTERNALIDENTIFIER, 
                        MEDIAVIDEOHOSTID, 
                        MEDIAREVIEWLEVELID, 
                        SOURCECODE, 
                        LASTUPDATEDATE, 
                        MEDIACONTEXTTYPEID)
                    VALUES 
                        (UUID_STRING(), 
                        source.PROVIDERID, 
                        source.EXTERNALIDENTIFIER, 
                        source.MEDIAVIDEOHOSTID, 
                        source.MEDIAREVIEWLEVELID, 
                        source.SOURCECODE, 
                        source.LASTUPDATEDATE, 
                        source.MEDIACONTEXTTYPEID)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------

merge_statement := 'MERGE INTO Base.PROVIDERVIDEO AS TARGET
USING ('||select_statement||') AS SOURCE
ON TARGET.PROVIDERID = SOURCE.PROVIDERID
WHEN MATCHED THEN DELETE
WHEN NOT MATCHED THEN ' || insert_statement;

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