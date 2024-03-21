
-- sp_load_solrproviderredirect (validated in snowflake)


-- 1. Update show.solrproviderredirect where the columns are different 
-- 2. Insert into show.solrproviderredirect where the providerid is null
-- 3. Delete from show.solrproviderredirect if the provider is in show.solrprovider
-- 4. DELTA: Insert into show.solrproviderredirect where the providerid is null
-- 5. DELTA: Update show.solrproviderredirect where URLs are null

CREATE OR REPLACE PROCEDURE SHOW.SP_LOAD_SOLRPROVIDERREDIRECT(IsProviderDeltaProcessing BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    AS  

DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- SOLRProviderRedirect depends on: 
--- Base.ProviderRedirect 
--- Base.Provider 
--- Base.ProviderURL 
--- Show.SOLRProvider 
--- Show.SOLRProviderRedirect

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE statement
    merge_condition STRING; -- Merge condition to final table
    update_statement STRING; -- Update statement to final table
    insert_statement STRING; -- Insert statement to final table
    merge_statement STRING; -- Merge statement
    delete_statement STRING; -- Delete statement to final table
    merge_statement_else_1 STRING; -- Insert into statement to final table
    merge_statement_else_2 STRING; -- Merge statement to final table
    status STRING; -- Status monitoring

---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN

    IF (IsProviderDeltaProcessing) THEN
        merge_statement_else_1 := '';
    ELSE
    
        merge_statement_else_1 := 'MERGE INTO Show.SOLRProviderRedirect AS Target
                                    USING (
                                        SELECT
                                            SolrProv.ProviderCode AS ProviderCodeOld,
                                            SolrProv.ProviderCode AS ProviderCodeNew,
                                            SolrProv.ProviderURL AS ProviderURLOld,
                                            SolrProv.ProviderURL AS ProviderURLNew,
                                            SolrProv.LastName,
                                            SolrProv.FirstName,
                                            SolrProv.MiddleName,
                                            SolrProv.Suffix,
                                            SolrProv.FirstName || '' '' || IFF(SolrProv.MiddleName IS NULL, '''', SolrProv.MiddleName || '' '') || SolrProv.LastName || IFF(SolrProv.Suffix IS NULL,'''', '' '' || SolrProv.Suffix) AS DisplayName,
                                            SolrProv.Degree,
                                            SolrProv.Title,
                                            SolrProv.ProviderTypeID,
                                            SolrProv.ProviderTypeGroup,
                                            ''Deactivated'' AS DeactivationReason,
                                            SolrProv.Gender AS GENDer,
                                            SolrProv.DateOfBirth,
                                            SolrProv.PracticeOfficeXML,
                                            SolrProv.SpecialtyXML,
                                            SolrProv.EducationXML,
                                            SolrProv.ImageXML,
                                            CURRENT_TIMESTAMP() AS LastUpdateDate,
                                            CURRENT_TIMESTAMP() AS UpdateDate,
                                            CURRENT_USER() AS UpdateSource
                                        FROM
                                            Show.SOLRProvider SolrProv
                                            LEFT JOIN Base.Provider BaseProv ON BaseProv.ProviderID = SolrProv.ProviderID
                                            LEFT JOIN Show.SOLRProviderRedirect SolrProvRed ON SolrProvRed.ProviderCodeOld = SolrProv.ProviderCode
                                            AND SolrProvRed.ProviderCodeNew = SolrProv.ProviderCode
                                            AND SolrProvRed.DeactivationReason = ''Deactivated''
                                        WHERE
                                            BaseProv.ProviderID IS NULL
                                            AND SolrProvRed.SOLRProviderRedirectID IS NULL
                                    ) AS Source
                                    ON Target.ProviderCodeOld = Source.ProviderCodeOld
                                    WHEN NOT MATCHED THEN 
                                        INSERT (
                                            ProviderCodeOld,
                                            ProviderCodeNew,
                                            ProviderURLOld,
                                            ProviderURLNew,
                                            LastName,
                                            FirstName,
                                            MiddleName,
                                            Suffix,
                                            DisplayName,
                                            Degree,
                                            Title,
                                            ProviderTypeID,
                                            ProviderTypeGroup,
                                            DeactivationReason,
                                            Gender,
                                            DateOfBirth,
                                            PracticeOfficeXML,
                                            SpecialtyXML,
                                            EducationXML,
                                            ImageXML,
                                            LastUpdateDate,
                                            UpdateDate,
                                            UpdateSource
                                        )
                                        VALUES (
                                            Source.ProviderCodeOld,
                                            Source.ProviderCodeNew,
                                            Source.ProviderURLOld,
                                            Source.ProviderURLNew,
                                            Source.LastName,
                                            Source.FirstName,
                                            Source.MiddleName,
                                            Source.Suffix,
                                            Source.DisplayName,
                                            Source.Degree,
                                            Source.Title,
                                            Source.ProviderTypeID,
                                            Source.ProviderTypeGroup,
                                            Source.DeactivationReason,
                                            Source.Gender,
                                            Source.DateOfBirth,
                                            Source.PracticeOfficeXML,
                                            Source.SpecialtyXML,
                                            Source.EducationXML,
                                            Source.ImageXML,
                                            Source.LastUpdateDate,
                                            Source.UpdateDate,
                                            Source.UpdateSource
                                        );';
                                                                
            
                        
     merge_statement_else_2 := 'MERGE INTO Show.SOLRProviderRedirect as SolrProvRed USING (
                                 SELECT
                                    ProvURL.URL,
                                    BaseProv.ProviderCode
                                FROM
                                    Base.ProviderURL as ProvURL
                                    JOIN Base.Provider as BaseProv ON ProvURL.ProviderID = BaseProv.ProviderID
                           ) as url ON SolrProvRed.ProviderCodeOld = url.ProviderCode
                            AND SolrProvRed.ProviderURLOld IS NULL
                            WHEN MATCHED THEN
                        UPDATE
                        SET
                            SolrProvRed.ProviderURLOld = url.URL;';
        
        EXECUTE IMMEDIATE merge_statement_else_1;
        EXECUTE IMMEDIATE merge_statement_else_2;
                                
    END IF;


---------------------------------------------------------
----------------- 3. SQL statements ---------------------
---------------------------------------------------------     

        
select_statement := ' WITH CTE_ProviderNotInSOLR AS (
                        	SELECT	ProviderCodeOld 
                        			,ProviderCodeNew 
                        			,ProviderURLOld 
                        			,ProviderURLNew 
                        			,HGIDOld 
                        			,HGIDNew 
                        			,HGID8Old 
                        			,HGID8New 
                        			,LastName 
                        			,FirstName 
                        			,MiddleName 
                        			,Suffix 
                        			,DisplayName 
                        			,Degree 
                        			,DegreePriority 
                        			,ProviderTypeID 
                        			,CityState
                        			,SpecialtyCode
                        			,SpecialtyLegacyKey
                        			,DeactivationReason
                        			,LastUpdateDate 
                        			,ROW_NUMBER() OVER(PARTITION BY ProviderCodeOld ORDER BY LastUpdateDate DESC) AS SequenceId
                        	FROM	Base.ProviderRedirect
                        	WHERE	ProviderCodeOld NOT IN (SELECT ProviderCode FROM Show.SOLRProvider )
                        )
                        
    
                            SELECT	ProviderCodeOld 
                        			,ProviderCodeNew 
                        			,ProviderURLOld 
                        			,ProviderURLNew 
                        			,HGIDOld 
                        			,HGIDNew 
                        			,HGID8Old 
                        			,HGID8New 
                        			,LastName 
                        			,FirstName 
                        			,MiddleName 
                        			,Suffix 
                        			,DisplayName 
                        			,Degree 
                        			,DegreePriority 
                        			,ProviderTypeID 
                        			,CityState
                        			,SpecialtyCode
                        			,SpecialtyLegacyKey
                        			,DeactivationReason
                        			,LastUpdateDate 
                            FROM CTE_PROVIDERNOTINSOLR
                            WHERE SequenceId = 1
                            ';

merge_condition := '  cteFinal.ProviderCodeOld != SolrProvRed.ProviderCodeOld
                OR cteFinal.ProviderCodeNew != SolrProvRed.ProviderCodeNew
                OR cteFinal.ProviderURLOld != SolrProvRed.ProviderURLOld
                OR cteFinal.ProviderURLNew != SolrProvRed.ProviderURLNew
                OR cteFinal.HGIDOld != SolrProvRed.HGIDOld
                OR cteFinal.HGIDNew != SolrProvRed.HGIDNew
                OR cteFinal.HGID8Old != SolrProvRed.HGID8Old
                OR cteFinal.HGID8New != SolrProvRed.HGID8New
                OR cteFinal.LastName != SolrProvRed.LastName
                OR cteFinal.FirstName != SolrProvRed.FirstName
                OR cteFinal.MiddleName != SolrProvRed.MiddleName
                OR cteFinal.Suffix != SolrProvRed.Suffix
                OR cteFinal.DisplayName != SolrProvRed.DisplayName
                OR cteFinal.Degree != SolrProvRed.Degree
                OR cteFinal.DegreePriority != SolrProvRed.DegreePriority
                OR cteFinal.ProviderTypeID != SolrProvRed.ProviderTypeID
                OR cteFinal.CityState != SolrProvRed.CityState
                OR cteFinal.SpecialtyCode != SolrProvRed.SpecialtyCode
                OR cteFinal.SpecialtyLegacyKey != SolrProvRed.SpecialtyLegacyKey
                OR cteFinal.DeactivationReason != SolrProvRed.DeactivationReason
                OR cteFinal.LastUpdateDate != SolrProvRed.LastUpdateDate';

update_statement := 'UPDATE
                        SET
                            ProviderCodeOld = cteFinal.ProviderCodeOld,
                            ProviderCodeNew = cteFinal.ProviderCodeNew,
                            ProviderURLOld = cteFinal.ProviderURLOld,
                            ProviderURLNew = cteFinal.ProviderURLNew,
                            HGIDOld = cteFinal.HGIDOld,
                            HGIDNew = cteFinal.HGIDNew,
                            HGID8Old = cteFinal.HGID8Old,
                            HGID8New = cteFinal.HGID8New,
                            LastName = cteFinal.LastName,
                            FirstName = cteFinal.FirstName,
                            MiddleName = cteFinal.MiddleName,
                            Suffix = cteFinal.Suffix,
                            DisplayName = cteFinal.DisplayName,
                            Degree = cteFinal.Degree,
                            DegreePriority = cteFinal.DegreePriority,
                            ProviderTypeID = cteFinal.ProviderTypeID,
                            CityState = cteFinal.CityState,
                            SpecialtyCode = cteFinal.SpecialtyCode,
                            SpecialtyLegacyKey = cteFinal.SpecialtyLegacyKey,
                            DeactivationReason = cteFinal.DeactivationReason,
                            LastUpdateDate = cteFinal.LastUpdateDate,
                            UpdateDate = CURRENT_TIMESTAMP(),
                            UpdateSource = CURRENT_USER()';

 insert_statement := 'INSERT(
                        ProviderCodeOld,
                        ProviderCodeNew,
                        ProviderURLOld,
                        ProviderURLNew,
                        HGIDOld,
                        HGIDNew,
                        HGID8Old,
                        HGID8New,
                        LastName,
                        FirstName,
                        MiddleName,
                        Suffix,
                        DisplayName,
                        Degree,
                        DegreePriority,
                        ProviderTypeID,
                        CityState,
                        SpecialtyCode,
                        SpecialtyLegacyKey,
                        DeactivationReason,
                        LastUpdateDate,
                        UpdateDate,
                        UpdateSource
                    )
                    VALUES
                    (cteFinal.ProviderCodeOld,
                        cteFinal.ProviderCodeNew,
                        cteFinal.ProviderURLOld,
                        cteFinal.ProviderURLNew,
                        cteFinal.HGIDOld,
                        cteFinal.HGIDNew,
                        cteFinal.HGID8Old,
                        cteFinal.HGID8New,
                        cteFinal.LastName,
                        cteFinal.FirstName,
                        cteFinal.MiddleName,
                        cteFinal.Suffix,
                        cteFinal.DisplayName,
                        cteFinal.Degree,
                        cteFinal.DegreePriority,
                        cteFinal.ProviderTypeID,
                        cteFinal.CityState,
                        cteFinal.SpecialtyCode,
                        cteFinal.SpecialtyLegacyKey,
                        cteFinal.DeactivationReason,
                        cteFinal.LastUpdateDate,
                        CURRENT_TIMESTAMP(),
                        CURRENT_USER() );';
                
---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  
                     

merge_statement := 'MERGE INTO Show.SOLRProviderRedirect as SolrProvRed
                        USING ('  || select_statement || ') as cteFinal 
                        ON cteFinal.ProviderCodeOld = SolrProvRed.ProviderCodeOld
                        WHEN MATCHED AND (' || merge_condition ||') THEN '
                            || update_statement ||
                        'WHEN NOT MATCHED THEN '
                            || insert_statement;

                         
delete_statement := 'DELETE FROM
                Show.SOLRProviderRedirect
            WHERE
                ProviderCodeOld IN (
                    SELECT
                        ProviderCode
                    FROM
                        Show.SOLRProvider);';

                    
                        

---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

--EXECUTE IMMEDIATE merge_statement_else_1; (executed in section 2. Conditionals)
--EXECUTE IMMEDIATE merge_statement_else_2; (executed in section 2. Conditionals) 
EXECUTE IMMEDIATE merge_statement;
EXECUTE IMMEDIATE delete_statement;

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
