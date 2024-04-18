CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_PROVIDERIMAGE() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.ProviderImage depends on: 
--- Raw.PROVIDER_PROFILE_PROCESSING
--- Base.Provider
--- Base.MediaImageHost

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
select_statement := $$ SELECT DISTINCT
                            P.ProviderID,
                            IFNULL(JSON.Image_MediaImageTypeCode, 'PHYSPHOT') AS MediaImageTypeID,
                            JSON.Image_ImageFileName AS FileName,
                            JSON.Image_MediaSizeCode AS MediaSizeID,
                            JSON.Image_MediaReviewLevelCode AS MediaReviewLevelID,
                            IFNULL(JSON.Image_SourceCode, 'Profisee') AS SourceCode,
                            IFNULL(JSON.Image_LastUpdateDate, CURRENT_TIMESTAMP()) AS LastUpdateDate,
                            JSON.Image_MediaContextTypeCode AS MediaContextTypeID,
                            M.MediaImageHostID,
                            JSON.Image_Identifier AS ExternalIdentifier,
                            JSON.Image_ImagePath AS ImagePath
                        FROM
                            Raw.VW_PROVIDER_PROFILE AS JSON
                            JOIN Base.Provider AS P ON P.ProviderCode = JSON.ProviderCode
                            JOIN Base.MediaImageHost AS M ON JSON.Image_MediaImageHostCode = M.MediaImageHostCode
                        WHERE
                            PROVIDER_PROFILE IS NOT NULL
                            AND Image_ImageFileName IS NOT NULL
                            AND ProviderID IS NOT NULL 
                        QUALIFY ROW_NUMBER() OVER( PARTITION BY ProviderID, Image_MediaImageTypeCode, Image_MediaSizeCode, Image_MediaContextTypeCode, Image_MediaImageHostCode ORDER BY CREATE_DATE DESC) = 1$$;


--- Insert Statement
insert_statement := ' INSERT 
                        (ProviderImageID,
                        ProviderID,
                        MediaImageTypeID,
                        FileName,
                        MediaSizeID,
                        MediaReviewLevelID,
                        SourceCode,
                        LastUpdateDate,
                        MediaContextTypeID,
                        MediaImageHostID,
                        ExternalIdentifier,
                        ImagePath)
                    VALUES
                        (UUID_STRING(),
                        source.ProviderID,
                        source.MediaImageTypeID,
                        source.FileName,
                        source.MediaSizeID,
                        source.MediaReviewLevelID,
                        source.SourceCode,
                        source.LastUpdateDate,
                        source.MediaContextTypeID,
                        source.MediaImageHostID,
                        source.ExternalIdentifier,
                        source.ImagePath)';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.ProviderImage as target USING 
                   ('||select_statement||') as source 
                   ON source.Providerid = target.Providerid
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
