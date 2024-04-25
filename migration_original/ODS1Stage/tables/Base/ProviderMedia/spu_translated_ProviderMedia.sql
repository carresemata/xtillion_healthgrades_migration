CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERMEDIA()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS  
DECLARE
    
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
-- Base.ProviderMedia depends on the following tables:
--- Raw.VW_PROVIDER_PROFILE
--- Base.Provider
--- Base.MediaType

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

--- Select Statement
select_statement := $$ SELECT
                            P.ProviderId,
                            MT.MediaTypeId,
                            JSON.MEDIA_MEDIADATE AS MediaDate,
                            JSON.MEDIA_MEDIATITLE AS MediaTitle,
                            JSON.MEDIA_MEDIAPUBLISHER AS MediaPublisher,
                            JSON.MEDIA_MEDIASYNOPSIS AS MediaSynopsis,
                            JSON.MEDIA_MEDIALINK AS MediaLink,
                            IFNULL(JSON.MEDIA_SOURCECODE, 'Profisee') AS SourceCode,
                            IFNULL(JSON.MEDIA_LASTUPDATEDATE, CURRENT_TIMESTAMP()) AS LastUpdateDate
                            
                        FROM RAW.VW_PROVIDER_PROFILE AS JSON
                            LEFT JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                            LEFT JOIN Base.MediaType AS MT ON MT.MediaTypeCode = JSON.MEDIA_MEDIATYPECODE
                        WHERE
                            PROVIDER_PROFILE IS NOT NULL AND
                            PROVIDERID IS NOT NULL AND
                            MediaTypeID IS NOT NULL
                        QUALIFY row_number() over(partition by ProviderId, JSON.MEDIA_MEDIATYPECODE,  JSON.MEDIA_MEDIADATE, JSON.MEDIA_MEDIALINK, JSON.MEDIA_MEDIAPUBLISHER, JSON.MEDIA_MEDIASYNOPSIS, JSON.MEDIA_MEDIATITLE order by CREATE_DATE desc) = 1 $$;

--- Insert Statement
insert_statement := '       INSERT  
                                    (ProviderMediaId, 
                                    ProviderID,
                                    MediaTypeID,
                                    MediaDate,
                                    MediaTitle,
                                    MediaPublisher,
                                    MediaSynopsis,
                                    MediaLink,
                                    SourceCode,
                                    LastUpdateDate)         
                             VALUES 
                                    (UUID_STRING(),
                                    source.ProviderID,
                                    source.MediaTypeID,
                                    source.MediaDate,
                                    source.MediaTitle,
                                    source.MediaPublisher,
                                    source.MediaSynopsis,
                                    source.MediaLink,
                                    source.SourceCode,
                                    source.LastUpdateDate)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  

merge_statement := ' MERGE INTO Base.ProviderMedia AS target 
                    USING (' || select_statement || ') AS source
                   ON source.ProviderID = target.ProviderID AND source.MediaTypeID = target.MediaTypeId
                   WHEN MATCHED THEN DELETE
                   WHEN NOT MATCHED THEN '||insert_statement;

---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE merge_statement ;

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