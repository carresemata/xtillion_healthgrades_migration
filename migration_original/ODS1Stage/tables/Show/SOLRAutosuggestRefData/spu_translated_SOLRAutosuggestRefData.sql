CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRAutosuggestRefData()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 
DECLARE 

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

--- Show.SOLRAutosuggestRefData depends on:
-- Base.Gender
-- Base.Suffix
-- Base.ProviderType
-- Base.SubStatus
-- Base.IdentificationType
-- Base.Position
-- Base.Language
-- Base.AboutMe
-- Base.AppointmentAvailability
-- Base.HGProcedureGroup
-- Base.SpecialtyGroup
-- Base.CertificationBoard
-- Base.CertificationAgency
-- Base.CertificationStatus
-- Base.SurveySuppressionReason2
-- Base.LocationType
-- Base.Nation
-- Base.LicenseType
-- Base.HealthInsurancePlan
-- Base.ClientToProduct
-- Base.Client
-- Base.Product
-- Base.ProductGroup
-- Base.EducationInstitutionType
-- Base.HealthInsurancePlanToPlanType
-- Base.HealthInsurancePlanType
-- Base.HealthInsurancePayor
-- Base.CertificationAgencyToBoardToSpecialty
-- Base.CertificationSpecialty
-- Base.DisplayStatus
-- Base.PopularSearchTerm (from DBO schema)

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

create_temp_statement STRING;

select_statement_union STRING;
-- These are the xml selects
select_statement_payor STRING;
select_statement_product STRING;
select_statement_certspec STRING;
select_statement_dispstatus STRING;
    procedure_name varchar(50) default('sp_load_SOLRAutosuggestRefData');
    execution_start DATETIME default getdate();


insert_statement_union STRING; 
-- These are the xml inserts
insert_statement_payor STRING; 
insert_statement_product STRING;
insert_statement_certspec STRING;
insert_statement_dispstatus STRING;

-- Main statements from the temp table
select_statement STRING; -- Select statement for the Merge
insert_statement STRING; -- Insert statement for the Merge
update_statement STRING; -- Update statement for the Merge
merge_statement STRING; -- Merge statement to final table
status STRING; -- Status monitoring
BEGIN

---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------  

create_temp_statement := $$
                         CREATE OR REPLACE TEMPORARY TABLE SHOW.TEMPAutosuggestRefData AS
                         SELECT Code, Description, Definition, Rank, TermID, AutoType, RelationshipXML, UpdatedDate, UpdatedSource
                         FROM SHOW.SOLRAutosuggestRefData
                         LIMIT 0;
                         $$;

select_statement_union :=   $$
                            SELECT Code, Description, Definition, Rank, TermID, AutoType
                            FROM
                                (
                                SELECT 
                                    GenderCode AS Code,
                                    GenderDescription AS Description, 
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    GenderID AS TermID,
                                    'GENDER' AS AutoType
                                FROM Base.Gender
                                
                                UNION
                                
                                SELECT
                                    SuffixAbbreviation AS Code,
                                    NULL AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    SuffixID AS TermID,
                                    'SUFFIX' AS AutoType
                                FROM Base.Suffix
                                
                                UNION
                                
                                SELECT
                                    ProviderTypeCode AS Code,
                                    ProviderTypeDescription AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    ProviderTypeID AS TermID,
                                    'PROVIDERTYPE' AS AutoType
                                FROM Base.ProviderType
                                
                                UNION
                                
                                SELECT
                                    SubStatusCode AS Code,
                                    SubStatusDescription AS Description,
                                    NULL AS Definition,
                                    SubStatusRank AS Rank,
                                    SubStatusID AS TermID,
                                    'SUBSTATUS' AS AutoType
                                FROM Base.SubStatus
                            
                                UNION
                                
                                SELECT
                                    IdentificationTypeCode AS Code,
                                    IdentificationTypeDescription AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    IdentificationTypeID AS TermID,
                                    'IDENTIFICATIONTYPE' AS AutoType
                                FROM Base.IdentificationType
                                
                                UNION 
                                
                                SELECT
                                    PositionCode AS Code,
                                    PositionDescription AS Description,
                                    NULL AS Definition,
                                    refRank AS Rank,
                                    PositionID AS TermID,
                                    'POSITION' AS AutoType
                                FROM Base.Position
                                
                                UNION
                                
                                SELECT
                                    LanguageCode AS Code,
                                    LanguageName AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    LanguageID AS TermID,
                                    'LANGUAGE' AS AutoType
                                FROM Base.Language
                                
                                UNION
                                
                                SELECT
                                    AboutMeCode AS Code,
                                    AboutMeDescription AS Description,
                                    NULL AS Definition,
                                    DisplayOrder AS Rank,
                                    AboutMeID AS TermID,
                                    'ABOUTME' AS AutoType
                                FROM Base.AboutMe
                                
                                UNION
                                
                                SELECT
                                    AppointmentAvailabilityCode AS Code,
                                    AppointmentAvailabilityDescription AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    AppointmentAvailabilityID AS TermID,
                                    'APPOINTMEMT' AS AutoType
                                FROM Base.AppointmentAvailability
                                
                                UNION
                                
                                SELECT
                                    HGProcedureGroupCode AS Code,
                                    HGProcedureGroupDisplayDescription AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    HGProcedureGroupID AS TermID,
                                    'PROCGROUP' AS AutoType
                                FROM Base.HGProcedureGroup
                                WHERE IsActive = 1
                            
                                UNION
                                
                                SELECT
                                    SpecialtyGroupCode AS Code,
                                    SpecialtyGroupDescription AS Description,
                                    NULL AS Definition,
                                    Rank AS Rank,
                                    SpecialtyGroupID AS TermID,
                                    'SPECGROUP' AS AutoType
                                FROM Base.SpecialtyGroup
                                
                                UNION
                                
                                SELECT
                                    CertificationBoardCode AS Code,
                                    CertificationBoardDescription AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    CertificationBoardID AS TermID,
                                    'CERTBOARD' AS AutoType
                                FROM Base.CertificationBoard
                                
                                UNION
                                
                                SELECT
                                    CertificationAgencyCode AS Code,
                                    CertificationAgencyDescription AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    CertificationAgencyID AS TermID,
                                    'CERTAGENCY' AS AutoType
                                FROM Base.CertificationAgency
                                
                                UNION
                                
                                SELECT
                                    CertificationStatusCode AS Code,
                                    CertificationStatusDescription AS Description,
                                    NULL AS Definition,
                                    Rank AS Rank,
                                    CertificationStatusID AS TermID,
                                    'CERTSTATUS' AS AutoType
                                FROM Base.CertificationStatus
                                
                                UNION
                                
                                SELECT
                                    SuppressionReasonCode AS Code,
                                    SuppressionReasonDescription AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    SurveySuppressionReasonID AS TermID,
                                    'SURVEYSUPPRESSREASON' AS AutoType
                                FROM Base.SurveySuppressionReason2
                                
                                UNION
                                
                                SELECT
                                    LocationTypeCode AS Code,
                                    LocationTypeDescription AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    LocationTypeID AS TermID,
                                    'LOCATIONTYPE' AS AutoType
                                FROM Base.LocationType
                                
                                UNION
                                
                                SELECT
                                    NationCode AS Code,
                                    NationName AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    NationID AS TermID,
                                    'NATION' AS AutoType
                                FROM Base.Nation
                                
                                UNION
                                
                                SELECT
                                    LicenseTypeCode AS Code,
                                    LicenseTypeDescription AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    LicenseTypeID AS TermID,
                                    'LICENSETYPE' AS AutoType
                                FROM Base.LicenseType
                                
                                UNION
                                
                                SELECT 
                                    PlanCode AS Code,
                                    PLanDisplayName AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    HealthInsurancePlanID AS TermID,
                                    'INSURANCEPLAN' AS AutoType
                                FROM Base.HealthInsurancePlan
                                
                                UNION
                                
                                SELECT
                                    c.ClientCode AS Code,
                                    c.ClientName AS Description,
                                    p.ProductCode AS Definition,
                                    NULL AS Rank,
                                    c.ClientID AS TermID,
                                    'CLIENT' AS AutoType
                                FROM Base.ClientToProduct cp
                                JOIN Base.Client c ON cp.ClientID = c.ClientID
                                JOIN Base.Product p ON cp.ProductID = p.ProductID
                                JOIN Base.ProductGroup pg ON p.ProductGroupID = pg.ProductGroupID
                                WHERE cp.ActiveFlag = 1
                            
                                UNION
                                
                                SELECT
                                    EducationInstitutionTypeCode AS Code,
                                    EducationInstitutionTypeCode AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    EducationInstitutionTypeID AS TermID,
                                    'EDUCATIONTYPE' AS AutoType
                                FROM Base.EducationInstitutionType
                                
                                UNION
                                
                                SELECT
                                    'DOCSPECLABEL' AS Code,
                                    'Specialties' AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    UUID_STRING() AS TermID,
                                    'SPECLABEL' AS AutoType
                                
                                UNION
                                
                                SELECT
                                    'ALTSPECLABEL' AS Code,
                                    'Specialties' AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    UUID_STRING() AS TermID,
                                    'SPECLABEL' AS AutoType
                                
                                UNION
                                
                                SELECT
                                    'DENTSPECLABEL' AS Code,
                                    'Practice Areas' AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    UUID_STRING() AS TermID,
                                    'SPECLABEL' AS AutoType
                                
                                UNION
                                
                                SELECT
                                    'DOCPRACSPECLABEL' AS Code,
                                    'Practicing Specialties' AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    UUID_STRING() AS TermID,
                                    'SPECLABEL' AS AutoType
                                
                                UNION
                                
                                SELECT
                                    'ALTPRACSPECLABEL' AS Code,
                                    'Practicing Specialties' AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    UUID_STRING() AS TermID,
                                    'SPECLABEL' AS AutoType
                                
                                UNION
                                
                                SELECT
                                    'DENTPRACSPECLABEL' AS Code,
                                    'Practice Areas' AS Description,
                                    NULL AS Definition,
                                    NULL AS Rank,
                                    UUID_STRING() AS TermID,
                                    'SPECLABEL' AS AutoType
                                
                                UNION
                            
                                -- * THIS IS THE TABLE THAT CAME FROM DBO SCHEMA * --
                                SELECT
                                    TermCode AS Code,
                                    TermDescription AS Description,
                                    TermType AS Definition,
                                    Rank AS Rank,
                                    PopularSearchTermID AS TermID,
                                    'POPULARSEARCHTERM' AS AutoType
                                FROM Base.PopularSearchTerm
                            
                                ) a;

                            $$;

select_statement_payor := $$

                          WITH cte_base AS (
                            SELECT DISTINCT d.InsurancePayorCode, e.HealthInsurancePlanID, c.ProductName
                            FROM Base.HealthInsurancePlanToPlanType c 
                            JOIN Base.HealthInsurancePlan e ON e.HealthInsurancePlanID=c.HealthInsurancePlanID
                            JOIN Base.HealthInsurancePlanType f ON f.HealthInsurancePlanTypeID=c.HealthInsurancePlanTypeID
                            JOIN Base.HealthInsurancePayor d ON d.HealthInsurancePayorID=e.HealthInsurancePayorID
                          ),
                        
                         cte_rel AS (
                            SELECT
                              pay.InsurancePayorCode AS InsurancePayorCode,
                              ipr.InsuranceProductCode AS productCd,
                              ipr.HealthInsurancePlanToPlanTypeID AS productId,
                              ipl.PlanCode AS planCd,
                              ipl.PlanName AS planNm,
                              ipt.PlanTypeCode AS planTpCd,
                              ipt.PlanTypeDescription AS planTpNm,
                              b.ProductName  AS pktdokPlNm
                            FROM Base.HealthInsurancePlanToPlanType ipr 
                              JOIN Base.HealthInsurancePlan ipl ON ipr.HealthInsurancePlanID = ipl.HealthInsurancePlanID
                              JOIN Base.HealthInsurancePlanType ipt ON ipr.HealthInsurancePlanTypeID = ipt.HealthInsurancePlanTypeID
                              JOIN Base.HealthInsurancePayor pay ON pay.HealthInsurancePayorID = ipl.HealthInsurancePayorID
                              LEFT JOIN cte_base b ON b.InsurancePayorCode = pay.InsurancePayorCode AND b.HealthInsurancePlanID = ipr.HealthInsurancePlanID 
                          ),
                        
                          cte_rel_xml AS (
                              SELECT 
                                InsurancePayorCode,
                                TO_VARIANT(utils.p_json_to_xml(
                                    ARRAY_AGG(
                                    REPLACE(
                                    '{ '||
                                    IFF(cte_rel.productCd IS NOT NULL, '"productCd":' || '"' || cte_rel.productCd || '"' || ',', '') ||
                                    IFF(cte_rel.productId IS NOT NULL, '"productId":' || '"' || cte_rel.productId || '"' || ',', '') ||
                                    IFF(cte_rel.planCd IS NOT NULL, '"planCd":' || '"' || cte_rel.planCd || '"' || ',', '') ||
                                    IFF(cte_rel.planNm IS NOT NULL, '"planNm":' || '"' || replace(cte_rel.planNm,'\"','') || '"' || ',', '') || -- 
                                    IFF(cte_rel.planTpCd IS NOT NULL, '"planTpCd":' || '"' || cte_rel.planTpCd || '"' || ',', '') ||
                                    IFF(cte_rel.planTpNm IS NOT NULL, '"planTpNm":' || '"' || cte_rel.planTpNm || '"' || ',', '') ||
                                    IFF(cte_rel.pktdokPlNm IS NOT NULL, '"pktdokPlNm":' || '"' || replace(cte_rel.pktdokPlNm,'\"','') || '"', '') --
                                    ||' }'
                                    ,'\'','\\\'')
                                    )::VARCHAR,
                                    'insuranceL',
                                    'insurance'
                                )) AS RelationshipXML
                                FROM cte_rel
                                GROUP BY InsurancePayorCode
                            )
                        
                            SELECT 
                                ip.InsurancePayorCode AS Code, -- col 1
                                ip.PayorName AS Description, -- col 2
                                NULL AS Definition, -- col 3
                                NULL AS Rank, -- col 4
                                ip.HealthInsurancePayorID AS TermID, -- col 5
                                'INSURANCEPAYOR' AS AutoType, -- col 6 
                                r.RelationshipXML AS RelationshipXML
                            FROM Base.HealthInsurancePayor ip
                            LEFT JOIN cte_rel_xml r ON r.InsurancePayorCode = ip.InsurancePayorCode;
                          $$;

select_statement_product := $$
                            WITH cte_rel AS (
                            SELECT
                              ip.HealthInsurancePlanToPlanTypeID,
                              ipa.InsurancePayorCode AS payorCd,
                              ipa.PayorName AS payorNm,
                              ipl.PlanCode AS planCd,
                              ipl.PlanName AS planNm,
                              ipt.PlanTypeCode AS planTpCd,
                              ipt.PlanTypeDescription AS planTpNm,
                            FROM Base.HealthInsurancePayor ipa 
                                 INNER JOIN Base.HealthInsurancePlan ipl ON ipa.HealthInsurancePayorID = ipl.HealthInsurancePayorID
                                 INNER JOIN Base.HealthInsurancePlanToPlanType ip ON ip.HealthInsurancePlanID = ipl.HealthInsurancePlanID 
                                 INNER JOIN Base.HealthInsurancePlanType ipt ON ip.HealthInsurancePlanTypeID = ipt.HealthInsurancePlanTypeID
                            ),
                        
                            cte_rel_xml AS (
                              SELECT 
                                HealthInsurancePlanToPlanTypeID,
                                TO_VARIANT(utils.p_json_to_xml(
                                    ARRAY_AGG(
                                    REPLACE(
                                    '{ '||
                                    IFF(cte_rel.payorCd IS NOT NULL, '"payorCd":' || '"' || cte_rel.payorCd || '"' || ',', '') ||
                                    IFF(cte_rel.payorNm IS NOT NULL, '"payorNm":' || '"' || cte_rel.payorNm || '"' || ',', '') ||
                                    IFF(cte_rel.planCd IS NOT NULL, '"planCd":' || '"' || cte_rel.planCd || '"' || ',', '') ||
                                    IFF(cte_rel.planNm IS NOT NULL, '"planNm":' || '"' || replace(cte_rel.planNm,'\"','') || '"' || ',', '') || 
                                    IFF(cte_rel.planTpCd IS NOT NULL, '"planTpCd":' || '"' || cte_rel.planTpCd || '"' || ',', '') ||
                                    IFF(cte_rel.planTpNm IS NOT NULL, '"planTpNm":' || '"' || cte_rel.planTpNm || '"' || ',', '') 
                                    ||' }'
                                    ,'\'','\\\'')
                                    )::VARCHAR,
                                    'insuranceL',
                                    'insurance'
                                )) AS RelationshipXML
                                FROM cte_rel
                                GROUP BY HealthInsurancePlanToPlanTypeID
                             )
                        
                            SELECT 
                                ipr.InsuranceProductCode AS Code, -- col 1
                                NULL AS Description, -- col 2
                                NULL AS Definition, -- col 3
                                NULL AS Rank, -- col 4
                                ipr.HealthInsurancePlanToPlanTypeID AS TermID, -- col 5
                                'INSURANCEPRODUCT' AS AutoType, -- col 6 
                                r.RelationshipXML AS RelationshipXML
                            FROM Base.HealthInsurancePlanToPlanType ipr 
                            LEFT JOIN cte_rel_xml r ON r.HealthInsurancePlanToPlanTypeID = ipr.HealthInsurancePlanToPlanTypeID;
    
                            $$;

select_statement_certspec := $$

                            WITH cte_rel AS (
                                SELECT
                                DISTINCT RTRIM(b.CertificationAgencyCode) AS caCd, 
                                         b.CertificationAgencyDescription AS caD, 
                                         RTRIM(c.CertificationBoardCode) AS cbCd, 
                                         c.CertificationBoardDescription AS cbD,
                                         a.CertificationSpecialtyID as CertificationSpecialtyID
                                FROM Base.CertificationAgencyToBoardToSpecialty a
                                JOIN Base.CertificationAgency b ON a.CertificationagencyID = b.CertificationAgencyID
                                JOIN Base.CertificationBoard c ON a.CertificationBoardID = c.CertificationBoardID
                            ),
                        
                            cte_rel_xml AS (
                              SELECT 
                                CertificationSpecialtyID,
                                TO_VARIANT(utils.p_json_to_xml(
                                    ARRAY_AGG(
                                    REPLACE(
                                    '{ '||
                                    IFF(cte_rel.caCD IS NOT NULL, '"caD":' || '"' || cte_rel.caCD || '"' || ',', '') ||
                                    IFF(cte_rel.caD IS NOT NULL, '"caD":' || '"' || cte_rel.caD || '"' || ',', '') ||
                                    IFF(cte_rel.cbCd IS NOT NULL, '"cbCd":' || '"' || cte_rel.cbCd || '"' || ',', '') ||
                                    IFF(cte_rel.cbD IS NOT NULL, '"cbD":' || '"' || replace(cte_rel.cbD,'\"','') || '"' || ',', '') 
                                    ||' }'
                                    ,'\'','\\\'')
                                    )::VARCHAR,
                                    'certL',
                                    'cert'
                                )) AS RelationshipXML
                                FROM cte_rel
                                GROUP BY CertificationSpecialtyID
                             )
                        
                            SELECT 
                                CertificationSpecialtyCode AS Code, -- col 1
                                CertificationSpecialtyDescription AS Description, -- col 2
                                NULL AS Definition, -- col 3
                                NULL AS Rank, -- col 4
                                s.CertificationSpecialtyID AS TermID, -- col 5
                                'CERTIFICATIONSPEC' AS AutoType, -- col 6 
                                r.RelationshipXML AS RelationshipXML
                            FROM Base.CertificationSpecialty s 
                            LEFT JOIN cte_rel_xml r ON r.CertificationSpecialtyID = s.CertificationSpecialtyID;
                            $$;

select_statement_dispstatus := $$
                    
                            WITH cte_rel AS (
                                SELECT SubStatusCode AS SubStatusCode, 
                                       SubStatusDescription AS SubStatusDesc,
                                       b.DisplayStatusCode AS DisplayStatusCode
                                FROM Base.SubStatus a
                                JOIN Base.DisplayStatus b ON b.DisplayStatusID = a.DisplayStatusID
                            ),
                        
                            cte_rel_xml AS (
                              SELECT 
                                DisplayStatusCode,
                                TO_VARIANT(utils.p_json_to_xml(
                                    ARRAY_AGG(
                                    REPLACE(
                                    '{ '||
                                    IFF(cte_rel.SubStatusCode IS NOT NULL, '"SubStatusCode":' || '"' || cte_rel.SubStatusCode || '"' || ',', '') ||
                                    IFF(cte_rel.SubStatusDesc IS NOT NULL, '"SubStatusDesc":' || '"' || cte_rel.SubStatusDesc || '"' || ',', '')
                                    ||' }'
                                    ,'\'','\\\'')
                                    )::VARCHAR,
                                    'subStatusL',
                                    'subStatus'
                                )) AS RelationshipXML
                                FROM cte_rel
                                GROUP BY DisplayStatusCode
                             )
                        
                            SELECT 
                                ds.DisplayStatusCode AS Code, -- col 1
                                DisplayStatusDescription AS Description, -- col 2
                                NULL AS Definition, -- col 3
                                DisplayStatusRank AS Rank, -- col 4
                                DisplayStatusID AS TermID, -- col 5
                                'DISPLAYSTATUS' AS AutoType, -- col 6 
                                r.RelationshipXML AS RelationshipXML
                            FROM Base.DisplayStatus ds 
                            LEFT JOIN cte_rel_xml r ON r.DisplayStatusCode = ds.DisplayStatusCode;
    
                            $$;
        
                        
insert_statement_union := $$
                          INSERT INTO SHOW.TEMPAutosuggestRefData (Code, Description, Definition, Rank, TermID, AutoType) 
                          $$
                          || select_statement_union;

insert_statement_payor := $$
                          INSERT INTO SHOW.TEMPAutosuggestRefData (Code, Description, Definition, Rank, TermID, AutoType, RelationshipXML) 
                          $$
                          || select_statement_payor;

insert_statement_product := $$
                          INSERT INTO SHOW.TEMPAutosuggestRefData (Code, Description, Definition, Rank, TermID, AutoType, RelationshipXML) 
                          $$
                          || select_statement_product;

insert_statement_certspec := $$
                          INSERT INTO SHOW.TEMPAutosuggestRefData (Code, Description, Definition, Rank, TermID, AutoType, RelationshipXML) 
                          $$
                          || select_statement_certspec;

insert_statement_dispstatus := $$
                          INSERT INTO SHOW.TEMPAutosuggestRefData (Code, Description, Definition, Rank, TermID, AutoType, RelationshipXML) 
                          $$
                          || select_statement_dispstatus;


insert_statement :=     $$
                        INSERT (
                                   Code,
                                   Description,
                                   Definition,
                                   Rank,
                                   TermID,
                                   AutoType,
                                   RelationshipXML,
                                   UpdatedDate,
                                   UpdatedSource
                                 )
                          VALUES (	
                                   source.Code,
                                   source.Description,
                                   source.Definition,
                                   source.Rank,
                                   source.TermID,
                                   source.AutoType,
                                   source.RelationshipXML,
                                   CURRENT_TIMESTAMP(),
                                   CURRENT_USER()
                                )
                        $$;

update_statement :=     $$
                        UPDATE SET target.Code = source.Code,
                                     target.Description = source.Description,
                                     target.Definition = source.Definition,
                                     target.Rank = source.Rank,
                                     target.TermID = source.TermID,
                                     target.AutoType = source.AutoType,
                                     target.RelationshipXML = source.RelationshipXML,
                                     target.UpdatedDate = CURRENT_TIMESTAMP(),
                                     target.UpdatedSource = CURRENT_USER()
                        $$;

merge_statement :=      $$
                        MERGE INTO SHOW.SOLRAutosuggestRefData AS target 
                        USING (
                              SELECT Code, Description, Definition, Rank, TermID, AutoType, RelationshipXML, UpdatedDate, UpdatedSource
                              FROM SHOW.TEMPAUTOSUGGESTREFDATA
                              ) AS source
                        ON source.TermID = target.TermID
                        WHEN MATCHED AND source.Code = target.Code AND source.Description = target.Description
                            AND source.Definition = target.Definition AND source.Rank = target.Rank 
                            AND source.AutoType = target.AutoType THEN $$ || update_statement || $$ 
                        WHEN NOT MATCHED THEN $$ || insert_statement;


---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 

EXECUTE IMMEDIATE create_temp_statement; 
-- inserting xmls to temp table
EXECUTE IMMEDIATE insert_statement_union; 
EXECUTE IMMEDIATE insert_statement_payor;
EXECUTE IMMEDIATE insert_statement_product;
EXECUTE IMMEDIATE insert_statement_certspec;
EXECUTE IMMEDIATE insert_statement_dispstatus;
-- final merge from temp
EXECUTE IMMEDIATE merge_statement;
                          
---------------------------------------------------------
--------------- 6. Status monitoring --------------------
--------------------------------------------------------- 

status := 'Completed successfully';
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        RETURN status;

        EXCEPTION
        WHEN OTHER THEN
            status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, SPLIT_PART(REGEXP_SUBSTR(:status, 'Error code: ([0-9]+)'), ':', 2)::INTEGER, TRIM(SPLIT_PART(SPLIT_PART(:status, 'SQL Error:', 2), 'Error code:', 1)), SPLIT_PART(REGEXP_SUBSTR(:status, 'SQL State: ([0-9]+)'), ':', 2)::INTEGER; 

            RETURN status;
END;