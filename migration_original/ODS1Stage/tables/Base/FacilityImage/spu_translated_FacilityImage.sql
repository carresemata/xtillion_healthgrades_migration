CREATE OR REPLACE PROCEDURE ODS1_STAGE.BASE.SP_LOAD_FACILITYIMAGE() -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Base.FacilityImage depends on: 
--- FACILITY_PROFILE_PROCESSING
--- Base.Facility
--- Base.EntityType
--- Base.MediaImageType
--- Base.MediaSize
--- Base.MediaReviewLevel

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
                            SHA1(TO_VARCHAR(Facility.FacilityID) || Entity.EntityTypeCode || Image_TypeCode || Image_FileName) AS FacilityImageID,
                            Facility.FacilityId,
                            JSON.Image_FileName AS FileName,
                            JSON.Image_Path AS ImagePath,
                            MIT.MediaImageTypeId,
                            MS.MediaSizeId,
                            MRL.MediaReviewLevelID,
                            'MergeFacilityImage' AS SourceCode
                            
                        FROM Raw.VW_FACILITY_PROFILE AS JSON
                        LEFT JOIN Base.Facility AS Facility ON JSON.FacilityCode = Facility.FacilityCode 
                        LEFT JOIN Base.EntityType Entity ON Entity.EntityTypeCode = 'FAC'
                        LEFT JOIN Base.MediaImageType AS MIT ON MIT.MediaImageTypeCode = JSON.Image_TypeCode
                        LEFT JOIN Base.MediaSize AS MS ON MS.MediaSizeCode = JSON.Image_SizeCode
                        LEFT JOIN Base.MediaReviewLevel AS MRL ON MRL.MediaReviewLevelCode = JSON.Image_ReviewLevel
                        WHERE 
                            FACILITY_PROFILE IS NOT NULL AND
                            FileName IS NOT NULL AND
                            FacilityID IS NOT NULL
                        QUALIFY ROW_NUMBER() OVER(PARTITION BY Facility.FacilityID, MediaImageTypeID, MediaSizeid ORDER BY CREATE_DATE DESC) = 1 $$;



--- Insert Statement
insert_statement := ' INSERT  
                        (FacilityImageID, 
                        FacilityID, 
                        FileName, 
                        ImagePath, 
                        MediaImageTypeID, 
                        MediaSizeID, 
                        MediaReviewLevelID, 
                        SourceCode, 
                        LastUpdateDate)
                      VALUES 
                        (source.FacilityImageID, 
                        source.FacilityID, 
                        source.FileName, 
                        source.ImagePath, 
                        source.MediaImageTypeID, 
                        source.MediaSizeID, 
                        source.MediaReviewLevelID, 
                        source.SourceCode, 
                        CURRENT_TIMESTAMP())';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Base.FacilityImage as target USING 
                   ('||select_statement||') as source 
                   ON source.Facilityid = target.Facilityid
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