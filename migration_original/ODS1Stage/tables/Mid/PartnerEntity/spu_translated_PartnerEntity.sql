CREATE OR REPLACE PROCEDURE ODS1_STAGE.MID.SP_LOAD_PartnerEntity(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Mid.PartnerEntity depends on: 
--- MDM_TEAM.MST.Provider_Profile_Processing
--- Base.PartnerToEntity
--- Base.Partner
--- Base.Provider
--- Base.EntityType
--- Base.Office
--- Base.ProviderToOffice
--- Base.Practice
--- Base.PartnerType
--- Base.ExternalOASPartner

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    truncate_statement STRING; 
    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    IF (IsProviderDeltaProcessing) THEN
           select_statement := '
            WITH CTE_ProviderBatch AS (
                SELECT DISTINCT p.ProviderID, p.ProviderCode
                FROM MDM_TEAM.MST.Provider_Profile_Processing as pdp
                JOIN Base.Provider as p on p.Providercode = pdp.ref_provider_code),
           ';
    ELSE
           truncate_statement := 'TRUNCATE TABLE Mid.PartnerEntity';
           EXECUTE IMMEDIATE truncate_statement;
           
           select_statement := '
           WITH CTE_ProviderBatch AS (
                SELECT DISTINCT p.ProviderID, p.ProviderCode
                FROM Base.PartnerToEntity AS pte
                JOIN Base.Provider as p on pte.PrimaryEntityID = p.ProviderID),
          ';
    END IF;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement

-- If conditionals:
select_statement := select_statement || 
                    $$
                    CTE_PartnerEntity AS (
                                SELECT DISTINCT
                                			pte.PartnerToEntityID, 
                                			pa.PartnerID, 
                                			pa.PartnerCode, 
                                            pa.PartnerDescription, 
                                			pt.PartnerTypeCode, 
                                			pt.PartnerTypeDescription, 
                                			pa.PartnerProductCode,
                                			pa.PartnerProductDescription,
                                			pa.URLPath, 
                                            CASE WHEN OASURL IS NOT NULL THEN OASURL
                                				ELSE 'https://' || pa.URLPath || pte.PartnerPrimaryEntityID || '/availability' END AS FullURL,
                                			pte.PrimaryEntityID, 
                                			pte.PartnerPrimaryEntityID, 
                                			pte.SecondaryEntityID, 
                                			pte.PartnerSecondaryEntityID, 
                                			pte.TertiaryEntityID, 
                                			pte.PartnerTertiaryEntityID, 
                                			p.ProviderCode, 
                                			o.OfficeCode, 
                                			prac.PracticeCode,
                                			eop.ExternalOASPartnerCode,
                                			eop.ExternalOASPartnerDescription,
                                            0 AS ActionCode -- ActionCode 0, for no changes
                                		FROM base.PartnerToEntity pte
                                		JOIN base.Partner pa ON pte.PartnerID = pa.PartnerID
                                		JOIN base.Provider p ON p.ProviderID = pte.PrimaryEntityID
                                		JOIN base.EntityType pet ON pte.PrimaryEntityTypeID = pet.EntityTypeID
                                		JOIN base.Office o ON o.OfficeID = pte.SecondaryEntityID
                                		JOIN base.providertooffice po ON p.ProviderID = po.ProviderID AND o.OfficeID = po.OfficeID
                                		JOIN base.EntityType seet ON pte.PrimaryEntityTypeID = seet.EntityTypeID
                                		LEFT JOIN base.Practice prac ON prac.PracticeID = pte.TertiaryEntityID
                                		LEFT JOIN base.EntityType tet ON pte.TertiaryEntityTypeID = tet.EntityTypeID
                                		JOIN base.PartnerType pt ON pa.PartnerTypeID = pt.PartnerTypeID
                                		JOIN CTE_ProviderBatch pb ON pte.PrimaryEntityID = pb.ProviderID
                                		LEFT JOIN base.ExternalOASPartner eop ON pte.ExternalOASPartnerID = eop.ExternalOASPartnerID
                                		WHERE pt.PartnerTypeCode='API' OR pt.PartnerTypeCode='URL'),
                    
                    -- ActionCode 1: Insert data to final table
                    CTE_Action_1 AS (
                                SELECT 
                                    cte.PartnerToEntityID,
                                    1 AS ActionCode
                                FROM CTE_PartnerEntity AS cte
                                LEFT JOIN Mid.PartnerEntity AS mid 
                                    ON cte.ProviderCode = mid.ProviderCode AND 
                                    cte.PartnerProductCode = mid.PartnerProductCode AND 
                                    cte.PartnerCode = mid.PartnerCode AND 
                                    IFNULL(cte.PracticeCode, 'ZZZ') =  IFNULL(mid.PracticeCode, 'ZZZ') AND 
                                    IFNULL(cte.OfficeCode, 'ZZZ') =  IFNULL(mid.OfficeCode, 'ZZZ')
                                WHERE mid.ProviderCode IS NULL
                    ),
                    
                    -- ActionCode 2: Update existing data to final table
                    CTE_Action_2 AS (
                                SELECT 
                                    cte.PartnerToEntityID,
                                    2 AS ActionCode
                                FROM CTE_PartnerEntity AS cte
                                JOIN Mid.PartnerEntity AS mid 
                                    ON cte.ProviderCode = mid.ProviderCode AND 
                                    cte.PartnerProductCode = mid.PartnerProductCode AND 
                                    cte.PartnerCode = mid.PartnerCode AND 
                                    IFNULL(cte.PracticeCode, 'ZZZ') =  IFNULL(mid.PracticeCode, 'ZZZ') AND 
                                    IFNULL(cte.OfficeCode, 'ZZZ') =  IFNULL(mid.OfficeCode, 'ZZZ')
                                WHERE
                                    MD5(IFNULL(cte.PartnerID::VARCHAR,'''')) <> MD5(IFNULL(mid.PartnerID::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.PartnerCode::VARCHAR,'''')) <> MD5(IFNULL(mid.PartnerCode::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.PartnerDescription::VARCHAR,'''')) <> MD5(IFNULL(mid.PartnerDescription::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.PartnerTypeCode::VARCHAR,'''')) <> MD5(IFNULL(mid.PartnerTypeCode::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.PartnerTypeDescription::VARCHAR,'''')) <> MD5(IFNULL(mid.PartnerTypeDescription::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.PartnerProductCode::VARCHAR,'''')) <> MD5(IFNULL(mid.PartnerProductCode::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.PartnerProductDescription::VARCHAR,'''')) <> MD5(IFNULL(mid.PartnerProductDescription::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.URLPath::VARCHAR,'''')) <> MD5(IFNULL(mid.URLPath::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.FullURL::VARCHAR,'''')) <> MD5(IFNULL(mid.FullURL::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.PrimaryEntityID::VARCHAR,'''')) <> MD5(IFNULL(mid.PrimaryEntityID::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.PartnerPrimaryEntityID::VARCHAR,'''')) <> MD5(IFNULL(mid.PartnerPrimaryEntityID::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.SecondaryEntityID::VARCHAR,'''')) <> MD5(IFNULL(mid.SecondaryEntityID::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.PartnerSecondaryEntityID::VARCHAR,'''')) <> MD5(IFNULL(mid.PartnerSecondaryEntityID::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.TertiaryEntityID::VARCHAR,'''')) <> MD5(IFNULL(mid.TertiaryEntityID::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.PartnerTertiaryEntityID::VARCHAR,'''')) <> MD5(IFNULL(mid.PartnerTertiaryEntityID::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.ProviderCode::VARCHAR,'''')) <> MD5(IFNULL(mid.ProviderCode::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.OfficeCode::VARCHAR,'''')) <> MD5(IFNULL(mid.OfficeCode::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.PracticeCode::VARCHAR,'''')) <> MD5(IFNULL(mid.PracticeCode::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.ExternalOASPartnerCode::VARCHAR,'''')) <> MD5(IFNULL(mid.ExternalOASPartnerCode::VARCHAR,'''')) OR
                                    MD5(IFNULL(cte.ExternalOASPartnerDescription::VARCHAR,'''')) <> MD5(IFNULL(mid.ExternalOASPartnerDescription::VARCHAR,''''))            
                    )
                    
                    SELECT DISTINCT
                        A0.PartnerToEntityID, 
                        A0.PartnerID, 
                        A0.PartnerCode, 
                        A0.PartnerDescription, 
                        A0.PartnerTypeCode, 
                        A0.PartnerTypeDescription, 
                        A0.PartnerProductCode,
                        A0.PartnerProductDescription,
                        A0.URLPath, 
                        A0.FullURL, 
                        A0.PrimaryEntityID, 
                        A0.PartnerPrimaryEntityID, 
                        A0.SecondaryEntityID, 
                        A0.PartnerSecondaryEntityID, 
                        A0.TertiaryEntityID, 
                        A0.PartnerTertiaryEntityID, 
                        A0.ProviderCode, 
                        A0.OfficeCode, 
                        A0.PracticeCode,
                        A0.ExternalOASPartnerCode,
                        A0.ExternalOASPartnerDescription,
                        IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) AS ActionCode 
                    FROM CTE_PartnerEntity AS A0 
                                        LEFT JOIN CTE_Action_1 AS A1 ON A0.PartnerToEntityID = A1.PartnerToEntityID
                                        LEFT JOIN CTE_Action_2 AS A2 ON A0.PartnerToEntityID = A2.PartnerToEntityID
                                        WHERE IFNULL(A1.ActionCode,IFNULL(A2.ActionCode, A0.ActionCode)) <> 0 
                                        $$;

--- Update Statement
update_statement := ' UPDATE 
                        SET
                            PartnerToEntityID = source.PartnerToEntityID,
                            PartnerID = source.PartnerID,
                            PartnerCode = source.PartnerCode,
                            PartnerDescription = source.PartnerDescription,
                            PartnerTypeCode = source.PartnerTypeCode,
                            PartnerTypeDescription = source.PartnerTypeDescription,
                            PartnerProductCode = source.PartnerProductCode,
                            PartnerProductDescription = source.PartnerProductDescription,
                            URLPath = source.URLPath,
                            FullURL = source.FullURL, 
                            PrimaryEntityID = source.PrimaryEntityID, 
                            PartnerPrimaryEntityID = source.PartnerPrimaryEntityID, 
                            SecondaryEntityID = source.SecondaryEntityID, 
                            PartnerSecondaryEntityID = source.PartnerSecondaryEntityID, 
                            TertiaryEntityID = source.TertiaryEntityID, 
                            PartnerTertiaryEntityID = source.PartnerTertiaryEntityID, 
                            ProviderCode = source.ProviderCode, 
                            OfficeCode = source.OfficeCode, 
                            PracticeCode = source.PracticeCode,
                            ExternalOASPartnerCode = source.ExternalOASPartnerCode,
                            ExternalOASPartnerDescription = source.ExternalOASPartnerDescription';

--- Insert Statement
insert_statement := ' INSERT (
                            PartnerToEntityID,
                            PartnerID,
                            PartnerCode,
                            PartnerDescription,
                            PartnerTypeCode,
                            PartnerTypeDescription,
                            PartnerProductCode,
                            PartnerProductDescription,
                            URLPath,
                            FullURL, 
                            PrimaryEntityID, 
                            PartnerPrimaryEntityID, 
                            SecondaryEntityID, 
                            PartnerSecondaryEntityID, 
                            TertiaryEntityID, 
                            PartnerTertiaryEntityID, 
                            ProviderCode, 
                            OfficeCode, 
                            PracticeCode,
                            ExternalOASPartnerCode,
                            ExternalOASPartnerDescription
                        )
                        VALUES (
                            source.PartnerToEntityID,
                            source.PartnerID,
                            source.PartnerCode,
                            source.PartnerDescription,
                            source.PartnerTypeCode,
                            source.PartnerTypeDescription,
                            source.PartnerProductCode,
                            source.PartnerProductDescription,
                            source.URLPath,
                            source.FullURL, 
                            source.PrimaryEntityID, 
                            source.PartnerPrimaryEntityID, 
                            source.SecondaryEntityID, 
                            source.PartnerSecondaryEntityID, 
                            source.TertiaryEntityID, 
                            source.PartnerTertiaryEntityID, 
                            source.ProviderCode, 
                            source.OfficeCode, 
                            source.PracticeCode,
                            source.ExternalOASPartnerCode,
                            source.ExternalOASPartnerDescription
                        )';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Mid.PartnerEntity as target USING 
                   ('||select_statement||') as source 
                   ON source.PartnerToEntityID = target.PartnerToEntityID
                   WHEN MATCHED AND source.ActionCode = 2 THEN '||update_statement|| '
                   WHEN NOT MATCHED AND source.ActionCode = 1 THEN '||insert_statement;
                   
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