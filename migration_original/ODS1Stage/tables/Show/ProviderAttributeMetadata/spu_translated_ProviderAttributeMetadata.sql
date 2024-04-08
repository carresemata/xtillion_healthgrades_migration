CREATE OR REPLACE PROCEDURE ODS1_STAGE.SHOW.SP_LOAD_PROVIDERATTRIBUTEMETADATA() 
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Show.ProviderAttributeMetadata depends on: 
--- Raw.ProviderProfileProcessing
--- Base.Provider
--- Base.MedicalTerm
--- Base.MedicalTermType
--- Base.EntityToMedicalTerm
--- Base.ProviderToAboutMe
--- Base.AboutMe
--- Base.ProviderToOffice
--- Base.OfficeToAddress
--- Base.ProviderToAppointmentAvailability (empty)
--- Base.ProviderAppointmentAvailabilityStatement (empty)
--- Base.ProviderToCertificationSpecialty (empty)
--- Base.ProviderToDegree
--- Base.Provider
--- Base.ProviderToHealthInsurance
--- Base.ProviderToFacility
--- Base.ProviderToLanguage
--- Base.ProviderMalpractice
--- Base.ProviderMedia
--- Base.OfficeToPhone
--- Base.PhoneType
--- Base.Office
--- Base.ProviderImage
--- Base.ProviderToOrganization
--- Base.Practice
--- Base.ProviderSanction
--- Base.ProviderToSpecialty
--- Base.ProviderVideo

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
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
-- If no conditionals:
select_statement := $$
                    WITH CTE_ProviderIdList AS (
    SELECT
        DISTINCT CASE
            WHEN P.ProviderID IS NOT NULL THEN p.ProviderID
            ELSE PDP.ProviderID
        END AS ProviderID,
        PDP.PROVIDER_CODE AS ProviderCode
    FROM
        Raw.ProviderProfileProcessing AS PDP
        JOIN Base.Provider AS P ON PDP.PROVIDER_CODE = P.ProviderCode
    ORDER BY
        (
            CASE
                WHEN P.ProviderID IS NOT NULL THEN p.ProviderID
                ELSE PDP.ProviderID
            END
        )
            ),
            CTE_MedicalTerm AS (
                SELECT
                    mt.MedicalTermID,
                    mtt.MedicalTermTypeCode,
                    mt.RefMedicalTermCode,
                    mt.MedicalTermDescription1
                FROM
                    Base.MedicalTerm AS mt
                    JOIN Base.MedicalTermType AS mtt ON mtt.MedicalTermTypeID = mt.MedicalTermTypeID
                WHERE
                    mtt.MedicalTermTypeCode IN ('Condition', 'Procedure')
                ORDER BY
                    mt.MedicalTermID
            ),
            CTE_ProviderMedical AS (
                SELECT
                    p.ProviderID,
                    emt.EntityID,
                    emt.MedicalTermID,
                    emt.SourceCode,
                    emt.LastUpdateDate,
                    IFNULL(emt.IsPreview, 0) AS IsPreview,
                    emt.NationalRankingA,
                    emt.NationalRankingB,
                    emt.NationalRankingBCalc
                FROM
                    CTE_ProviderIdList AS p
                    JOIN Base.EntityToMedicalTerm AS emt ON emt.EntityID = p.ProviderID
            ),
            CTE_ProviderEntityToMedicalTermList AS (
                SELECT
                    DISTINCT pm.ProviderID,
                    pm.EntityID,
                    pm.MedicalTermID,
                    mt.MedicalTermTypeCode,
                    mt.RefMedicalTermCode,
                    pm.SourceCode,
                    pm.LastUpdateDate,
                    pm.IsPreview,
                    pm.NationalRankingA,
                    pm.NationalRankingB,
                    pm.NationalRankingBCalc
                FROM
                    CTE_ProviderMedical AS pm
                    JOIN CTE_MedicalTerm AS mt ON mt.MedicalTermID = pm.MedicalTermID
                ORDER BY
                    pm.EntityID,
                    pm.MedicalTermID,
                    mt.MedicalTermTypeCode
            ),
            CTE_updates AS (
                --About Me
                SELECT
                    ptam.ProviderID,
                    'AboutMe ' || AboutMeCode AS DataElement,
                    IFNULL(SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(ptam.LastUPDATEdDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderToAboutMe ptam ON pid.ProviderID = ptam.ProviderID
                    JOIN Base.AboutMe am ON ptam.AboutMeID = am.AboutMeID
                GROUP BY
                    ptam.ProviderID,
                    AboutMeCode,
                    SourceCode
                UNION ALL
                    --Provider Address:
                SELECT
                    pto.ProviderID,
                    'Address' AS DataElement,
                    IFNULL(ota.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(ota.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderToOffice PTO ON pid.ProviderID = pto.ProviderID
                    JOIN Base.OfficeToAddress OTA ON ota.OfficeID = pto.OfficeID
                GROUP BY
                    pto.ProviderID,
                    ota.SourceCode
                UNION ALL
                    --Appointment Availability:
                SELECT
                    paa.ProviderID,
                    'Appointment Availability' AS DataElement,
                    IFNULL(paa.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(paa.InsertedOn) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderToAppointmentAvailability paa ON pid.ProviderID = paa.ProviderID
                GROUP BY
                    paa.ProviderID,
                    paa.SourceCode
                UNION ALL
                    --Provider Availability Statement:
                SELECT
                    pas.ProviderID,
                    'Availability Statement' AS DataElement,
                    IFNULL(pas.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(pas.InsertedOn) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderAppointmentAvailabilityStatement pas ON pid.ProviderID = pas.ProviderID
                GROUP BY
                    pas.ProviderID,
                    pas.SourceCode
                UNION ALL
                    --Certifications:
                SELECT
                    ptc.ProviderID,
                    'Certifications' AS DataElement,
                    IFNULL(ptc.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(ptc.InsertedOn) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderToCertificationSpecialty ptc ON pid.ProviderID = ptc.ProviderID
                GROUP BY
                    ptc.ProviderID,
                    ptc.SourceCode
                UNION ALL
                    --Condition:
                SELECT
                    emt.EntityID AS ProviderID,
                    MedicalTermTypeCode AS DataElement,
                    IFNULL(emt.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(emt.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderEntityToMedicalTermList AS emt
                WHERE
                    emt.MedicalTermTypeCode = 'Condition'
                GROUP BY
                    emt.EntityID,
                    emt.MedicalTermTypeCode,
                    emt.SourceCode
                UNION ALL
                    --Degree:
                SELECT
                    ptd.ProviderID,
                    'Degree' AS DataElement,
                    IFNULL(ptd.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(ptd.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderToDegree ptd ON pid.ProviderID = ptd.ProviderID
                GROUP BY
                    ptd.ProviderID,
                    ptd.SourceCode
                UNION ALL
                    --FirstName:
                SELECT
                    a.ProviderID,
                    'FirstName' AS DataElement,
                    IFNULL(a.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(a.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.provider a ON pid.ProviderID = a.ProviderID
                GROUP BY
                    a.ProviderID,
                    a.SourceCode
                UNION ALL
                    --Health Insurance:
                SELECT
                    phi.ProviderID,
                    'Health Insurance' AS DataElement,
                    IFNULL(phi.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(phi.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderToHealthInsurance phi ON pid.ProviderID = phi.ProviderID
                GROUP BY
                    phi.ProviderID,
                    phi.SourceCode
                UNION ALL
                    --Hospital Affiliation
                SELECT
                    ptf.ProviderID,
                    'Hospital Affiliation' AS DataElement,
                    IFNULL(ptf.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(ptf.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderToFacility ptf ON pid.ProviderID = ptf.ProviderID
                GROUP BY
                    ptf.ProviderID,
                    ptf.SourceCode
                UNION ALL
                    --Languages Spoken:
                SELECT
                    pl.ProviderID,
                    'Languages Spoken' AS DataElement,
                    IFNULL(pl.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(pl.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderToLanguage pl ON pid.ProviderID = pl.ProviderID
                GROUP BY
                    pl.ProviderID,
                    pl.SourceCode
                UNION ALL
                    --LastName:
                SELECT
                    a.ProviderID,
                    'LastName' AS DataElement,
                    IFNULL(a.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(a.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.provider a ON pid.ProviderID = a.ProviderID
                GROUP BY
                    a.ProviderID,
                    a.SourceCode
                UNION ALL
                    --Malpractice:
                SELECT
                    pm.ProviderID,
                    'Malpractice' AS DataElement,
                    IFNULL(pm.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(pm.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderMalpractice pm ON pid.ProviderID = pm.ProviderID
                GROUP BY
                    pm.ProviderID,
                    pm.SourceCode
                UNION ALL
                    --Media:
                SELECT
                    pm.ProviderID,
                    'Media' AS DataElement,
                    IFNULL(pm.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(pm.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderMedia pm ON pid.ProviderID = pm.ProviderID
                GROUP BY
                    pm.ProviderID,
                    pm.SourceCode
                UNION ALL
                    --Office:
                SELECT
                    pto.ProviderID,
                    'Office' AS DataElement,
                    IFNULL(pto.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(pto.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderToOffice pto ON pid.ProviderID = pto.ProviderID
                GROUP BY
                    pto.ProviderID,
                    pto.SourceCode
                UNION ALL
                    --Office Fax:
                SELECT
                    pto.ProviderID,
                    'Office Fax' AS DataElement,
                    IFNULL(op.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(op.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderToOffice PTO ON pid.ProviderID = PTO.ProviderID
                    JOIN Base.OfficeToPhone op ON pto.OfficeID = op.OfficeID
                    JOIN Base.PhoneType pt ON pt.PhoneTypeID = op.PhoneTypeID
                WHERE
                    pt.PhoneTypeCode = 'FAX'
                GROUP BY
                    pto.ProviderID,
                    op.SourceCode
                UNION ALL
                    --Office Name:
                SELECT
                    a.ProviderID,
                    'Office Name' AS DataElement,
                    IFNULL(b.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(b.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderToOffice a ON pid.ProviderID = a.ProviderID
                    JOIN Base.Office b ON b.officeID = a.OfficeID
                GROUP BY
                    a.ProviderID,
                    b.SourceCode
                UNION ALL
                    --Photo:
                SELECT
                    pimg.ProviderID,
                    'Photo' AS DataElement,
                    IFNULL(pimg.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(pimg.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderImage pimg ON pid.ProviderID = pimg.ProviderID
                GROUP BY
                    pimg.ProviderID,
                    pimg.SourceCode
                UNION ALL
                    --Positions:
                SELECT
                    po.ProviderID,
                    'Positions' AS DataElement,
                    IFNULL(po.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(po.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderToOrganization po ON pid.ProviderID = po.ProviderID
                WHERE
                    po.PositionEndDate IS NULL
                GROUP BY
                    po.ProviderID,
                    po.SourceCode
                UNION ALL
                    --Practice Name:
                SELECT
                    po.ProviderID,
                    'Practice Name' AS DataElement,
                    IFNULL(a.SourceCode, '') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(a.LastUPDATEDate) AS LastUpdateDate
                FROM
                    Base.Practice a
                    JOIN Base.Office o ON a.practiceid = o.practiceid
                    JOIN Base.ProviderToOffice po ON po.officeid = o.officeid
                    JOIN CTE_ProviderIDList pid ON pid.ProviderID = po.ProviderID
                GROUP BY
                    po.ProviderID,
                    a.SourceCode
                UNION ALL
                    --Procedure:
                SELECT
                    emt.EntityID AS ProviderID,
                    MedicalTermTypeCode AS DataElement,
                    IFNULL(emt.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(emt.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderEntityToMedicalTermList AS emt
                WHERE
                    emt.MedicalTermTypeCode = 'Procedure'
                GROUP BY
                    emt.EntityID,
                    emt.MedicalTermTypeCode,
                    emt.SourceCode
                UNION ALL
                    -- Sanctions:
                SELECT
                    ps.ProviderID,
                    'Sanctions' AS DataElement,
                    IFNULL(ps.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(ps.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderSanction ps ON pid.ProviderID = ps.ProviderID
                GROUP BY
                    ps.ProviderID,
                    ps.SourceCode
                UNION ALL
                    --Specialty:
                SELECT
                    pts.ProviderID,
                    'Specialty' AS DataElement,
                    IFNULL(pts.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(pts.InsertedOn) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderToSpecialty pts ON pid.ProviderID = pts.ProviderID
                GROUP BY
                    pts.ProviderID,
                    pts.SourceCode
                UNION ALL
                    --Video:
                SELECT
                    a.ProviderID,
                    'Video' AS DataElement,
                    IFNULL(a.SourceCode, 'N/A') AS SourceCode,
                    CURRENT_USER() AS UpdatedBy, 
                    MAX(a.LastUPDATEDate) AS LastUpdateDate
                FROM
                    CTE_ProviderIDList pid
                    JOIN Base.ProviderVideo a ON pid.ProviderID = a.ProviderID
                GROUP BY
                    a.ProviderID,
                    a.SourceCode
                ORDER BY
                    DataElement ASC
            ), 
            CTE_UpdateTrackingXML AS (
            SELECT DISTINCT
                    p.ProviderId,
                    p.ProviderCode,
                    CTE_updates.DataElement,
                    p_json_to_xml(
                        ARRAY_AGG(
                            '{ ' || IFF(
                                CTE_updates.DataElement IS NOT NULL,
                                '"elem":' || '"' || CTE_updates.DataElement || '"' || ',',
                                ''
                            ) || IFF(
                                CTE_updates.SourceCode IS NOT NULL,
                                '"src":' || '"' || CTE_updates.SourceCode || '"' || ',',
                                ''
                            ) || IFF(
                                CTE_updates.LastUpdateDate IS NOT NULL,
                                '"upd":' || '"' || CTE_updates.LastUpdateDate || '"',
                                ''
                            ) || ' }'
                        )::varchar,
                        '',
                        ''
                    ) AS UpdateTrackingXML,
                    CTE_updates.UpdatedBy,
                    CTE_updates.LastUpdateDate AS UpdatedOn
                FROM
                    CTE_ProviderIdList AS p
                    JOIN CTE_updates ON CTE_updates.ProviderID = p.ProviderId
                    
                GROUP BY
                    p.ProviderId,
                    p.ProviderCode,
                    CTE_updates.UpdatedBy,
                    CTE_updates.LastUpdateDate,
                    CTE_updates.DataElement
                ORDER BY
                    CTE_updates.DataElement)
            
            SELECT DISTINCT
                p.ProviderId,
                p.ProviderCode,
                TO_VARIANT(p_json_to_xml(
                        array_agg( 
                        '{ '||
            IFF(UpdateTrackingXML IS NOT NULL, '"xml_1":' || '"' || UpdateTrackingXML || '"', '')
            ||' }'
                        )::varchar
                        ,
                        'prov',
                        'de'
                    )) AS UpdateTrackingXML, -- TO_VARIANT()
                u.UpdatedBy,
                MAX(u.LastUpdateDate) AS UpdatedOn
            
            FROM CTE_ProviderIDList AS p
            JOIN CTE_updates AS u ON p.ProviderId = u.Providerid
            JOIN CTE_UpdateTrackingXML AS xml ON p.ProviderId = xml.Providerid
            GROUP BY
                p.ProviderId,
                p.ProviderCode,
                u.UpdatedBy
            ORDER BY
                p.ProviderId,
                p.ProviderCode
            $$;


--- Update Statement
update_statement := ' UPDATE 
                        SET
                            ProviderCode = source.ProviderCode,
                            UpdateTrackingXML = source.UpdateTrackingXML,
                            UpdatedBy = CURRENT_USER(),
                            UpdatedOn = CURRENT_TIMESTAMP()';
                        
--- Insert Statement
insert_statement := ' INSERT (
                            ProviderId,
                            ProviderCode,
                            UpdateTrackingXML,
                            UpdatedBy,
                            UpdatedOn
                        )
                        VALUES (
                            source.ProviderId,
                            source.ProviderCode,
                            source.UpdateTrackingXML,
                            source.Updatedby,
                            source.UpdatedOn
                        );';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Dev.ProviderAttributeMetadata as target USING 
                   ('||select_statement||') as source 
                   ON source.ProviderId = target.ProviderId
                   WHEN MATCHED THEN '||update_statement|| '
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

call sp_load_providerattributemetadata();