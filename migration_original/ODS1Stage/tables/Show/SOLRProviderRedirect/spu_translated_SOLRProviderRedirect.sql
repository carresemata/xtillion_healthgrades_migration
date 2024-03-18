
-- sp_get_solrproviderredirect (validated in snowflake)
CREATE OR REPLACE PROCEDURE ODS1_STAGE.SHOW.SP_GET_SOLRPROVIDERREDIRECT()
RETURNS TABLE (
        ProviderCodeOld VARCHAR,
        ProviderCodeNew VARCHAR,
        ProviderURLOld VARCHAR,
        ProviderURLNew VARCHAR,
        HGIDOld VARCHAR,
        HGIDNew VARCHAR,
        HGID8Old VARCHAR,
        HGID8New VARCHAR,
        LastName VARCHAR,
        FirstName VARCHAR,
        MiddleName VARCHAR,
        Suffix VARCHAR,
        DisplayName VARCHAR,
        Degree VARCHAR,
        DegreePriority INTEGER,
        ProviderTypeID STRING,
        CityState VARCHAR,
        SpecialtyCode VARCHAR,
        SpecialtyLegacyKey VARCHAR,
        DeactivationReason VARCHAR,
        LastUpdateDate TIMESTAMP
)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'DECLARE
  select_statement VARCHAR;
  res RESULTSET;
BEGIN
    select_statement := ''
                     WITH CTE_ProviderNotInSOLR AS (
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
                        ),
                        
                        CTE_ProviderRedirect AS (
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
                            WHERE SequenceId = 1)
                            SELECT * FROM CTE_ProviderRedirect'';

    res := (EXECUTE IMMEDIATE :select_statement);
    RETURN TABLE(res);
END
'


--- sp_load_solrproviderredirect 

-- 1. Update show.solrproviderredirect where the columns are different 
-- 2. Insert into show.solrproviderredirect where the providerid is null
-- 3. Delete from show.solrproviderredirect if the provider is in show.solrprovider
-- 4. DELTA: Insert into show.solrproviderredirect where the providerid is null
-- 5. DELTA: Update show.solrproviderredirect where URLs are null

--- We can do the updates 1 and 2 in this merge statement
MERGE INTO Show.SOLRProviderRedirect as S
USING (SELECT * FROM ###### Insert here the table result from sp_get_solrproviderredirect #######) as T
ON T.ProviderCodeOld = S.ProviderCodeOld
WHEN MATCHED AND (
    T.ProviderCodeOld != S.ProviderCodeOld 
    OR T.ProviderCodeNew != S.ProviderCodeNew 
    OR T.ProviderURLOld != S.ProviderURLOld 
    OR T.ProviderURLNew != S.ProviderURLNew 
    OR T.HGIDOld != S.HGIDOld 
    OR T.HGIDNew != S.HGIDNew 
    OR T.HGID8Old != S.HGID8Old 
    OR T.HGID8New != S.HGID8New 
    OR T.LastName != S.LastName 
    OR T.FirstName != S.FirstName 
    OR T.MiddleName != S.MiddleName 
    OR T.Suffix != S.Suffix 
    OR T.DisplayName != S.DisplayName 
    OR T.Degree != S.Degree 
    OR T.DegreePriority != S.DegreePriority 
    OR T.ProviderTypeID != S.ProviderTypeID 
    OR T.CityState != S.CityState 
    OR T.SpecialtyCode != S.SpecialtyCode 
    OR T.SpecialtyLegacyKey != S.SpecialtyLegacyKey 
    OR T.DeactivationReason != S.DeactivationReason 
    OR T.LastUpdateDate != S.LastUpdateDate
)
THEN UPDATE SET 
    ProviderCodeOld = T.ProviderCodeOld, 
    ProviderCodeNew = T.ProviderCodeNew, 
    ProviderURLOld = T.ProviderURLOld, 
    ProviderURLNew = T.ProviderURLNew, 
    HGIDOld = T.HGIDOld, 
    HGIDNew = T.HGIDNew, 
    HGID8Old = T.HGID8Old, 
    HGID8New = T.HGID8New, 
    LastName = T.LastName, 
    FirstName = T.FirstName, 
    MiddleName = T.MiddleName, 
    Suffix = T.Suffix, 
    DisplayName = T.DisplayName, 
    Degree = T.Degree, 
    DegreePriority = T.DegreePriority, 
    ProviderTypeID = T.ProviderTypeID, 
    CityState = T.CityState, 
    SpecialtyCode = T.SpecialtyCode, 
    SpecialtyLegacyKey = T.SpecialtyLegacyKey, 
    DeactivationReason = T.DeactivationReason, 
    LastUpdateDate = T.LastUpdateDate,
    UpdateDate = CURRENT_TIMESTAMP(),
    UpdateSource = CURRENT_USER()
WHEN NOT MATCHED THEN INSERT(
    ProviderCodeOld, ProviderCodeNew, ProviderURLOld, ProviderURLNew, HGIDOld, HGIDNew, HGID8Old, HGID8New, LastName, FirstName, MiddleName, Suffix, DisplayName, Degree, DegreePriority, ProviderTypeID, CityState, SpecialtyCode, SpecialtyLegacyKey, DeactivationReason, LastUpdateDate, UpdateDate, UpdateSource
) VALUES (
    T.ProviderCodeOld, T.ProviderCodeNew, T.ProviderURLOld, T.ProviderURLNew, T.HGIDOld, T.HGIDNew, T.HGID8Old, T.HGID8New, T.LastName, T.FirstName, T.MiddleName, T.Suffix, T.DisplayName, T.Degree, T.DegreePriority, T.ProviderTypeID, T.CityState, T.SpecialtyCode, T.SpecialtyLegacyKey, T.DeactivationReason, T.LastUpdateDate, CURRENT_TIMESTAMP(), CURRENT_USER()
);