CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRPROVIDER(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER 
    as
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- show.solrprovider depends on: 
--- mdm_team.mst.provider_profile_processing
--- show.webfreeze
--- show.solrprovider_freeze (empty)
--- show.providersourceupdate
--- show.solrproviderdelta
--- mid.providerpracticeoffice
--- mid.providereducation
--- mid.providersponsorship
--- mid.providersurveyresponse
--- mid.providermalpractice
--- mid.providerprocedure
--- mid.provider
--- mid.clientmarket
--- base.provider
--- base.providerimage
--- base.provideremail
--- base.providertype
--- base.providersanction
--- base.providersubtype
--- base.providersurveyaggregate
--- base.providersurveysuppression
--- base.providertosubstatus
--- base.providertoprovidersubtype
--- base.providerappointmentavailabilitystatement (deprecated)
--- base.providersubtypetodegree
--- base.providertodegree
--- base.providertooffice
--- base.providertospecialty
--- base.providerlegacykeys
--- base.providertoaboutme
--- base.aboutme
--- base.product
--- base.mediasize
--- base.mediaimagehost
--- base.mediacontexttype
--- base.substatus
--- base.officetoaddress
--- base.address
--- base.citystatepostalcode
--- base.geographicarea
--- base.displaystatus
--- base.malpracticestate
--- base.sanctionaction
--- base.sanctionactiontype
--- base.specialtygrouptospecialty
--- base.client
--- base.clienttoproduct
--- base.specialty

--- XML LOAD
-- Base.OfficeHours
-- Base.DaysOfWeek
-- Base.State
-- Base.Award
-- Base.AwardCategory
-- Base.ProviderTypeToMedicalTerm
-- Base.ProviderToProviderType
-- Base.EntityType
-- Base.MedicalTerm
-- Base.MedicalTermType
-- Base.CohortToProcedure
-- Base.TempSpecialtyToServiceLineGhetto
-- Base.CertificationSpecialty
-- Base.ProviderToCertificationSpecialty
-- Base.CertificationAgency
-- Base.CertificationBoard
-- Base.CertificationStatus
-- Base.MOCLevel
-- Base.MOCPathway
-- Base.Language
-- Base.ClientEntityToClientFeature
-- Base.ClientFeatureToClientFeatureValue
-- Base.ClientFeature
-- Base.ClientFeatureValue
-- Base.ClientFeatureGroup
-- Base.ClinicalFocusDCP
-- Base.ProviderToClinicalFocus
-- Base.ClinicalFocus
-- Base.ClinicalFocusToSpecialty
-- Base.ProviderTraining
-- Base.Training
-- Base.ProviderLastUpdateDate
-- Base.Provider
-- Base.ProviderToClientToOASPartner
-- Base.OASPartner
-- Base.EntityToMedicalTerm
-- Base.SpecialtyToProcedureMedical
-- Base.SanctionType
-- Base.SanctionCategory
-- Base.StateReportingAgency
-- Base.ProviderIdentification
-- Base.IdentificationType
-- Base.Degree
-- Base.ProviderToTelehealthMethod
-- Base.TelehealthMethod
-- Base.TelehealthMethodType
-- Base.ProviderToClientProductToDisplayPartner
-- Base.SyndicationPartner
-- Base.HealthInsurancePlanToPlanType
-- Base.HealthInsurancePlan
-- Base.HealthInsurancePlanType
-- Base.HealthInsurancePayor
-- Base.HealthInsurancePayorOrganization
-- Base.ProviderMedia
-- Base.MediaType
-- ERMART1.Facility_ServiceLine
-- ERMART1.Facility_FacilityToAward
-- ERMART1.Facility_FacilityToProcedureRating
-- ERMART1.Facility_vwuFacilityHGDisplayProcedures
-- ERMART1.Facility_ProcedureToServiceLine
-- ERMART1.Facility_Procedure
-- Mid.Practice
-- Mid.SurveyQuestionRangeMapping
-- Mid.ProviderHealthInsurance
-- Mid.PartnerEntity
-- Mid.ProviderRecognition
-- Show.SOLRProviderSurveyQuestionAndAnswer
--- Base.ClientProductImage (Base.vwuPDCClientDetail)
--- Base.MediaImageType (Base.vwuPDCClientDetail)
--- Base.ClientProductEntityToURL (Base.vwuPDCClientDetail)
--- Base.URLType (Base.vwuPDCClientDetail)
--- Base.URL (Base.vwuPDCClientDetail)
--- Base.ClientProductToEntity (Base.vwuPDCClientDetail)
--- BASE.CLIENTPRODUCTENTITYTOPHONE (Base.vwuPDCClientDetail)
--- BASE.PHONETYPE (Base.vwuPDCClientDetail)
--- BASE.PHONE (Base.vwuPDCClientDetail)
--- Base.CallCenter (Base.vwuCallCenterDetails)
--- Base.CallCenterType (Base.vwuCallCenterDetails)
--- Base.ClientProductToCallCenter (Base.vwuCallCenterDetails)
--- Base.CallCenterToEmail (Base.vwuCallCenterDetails)
--- Base.Email (Base.vwuCallCenterDetails)
--- Base.EmailType (Base.vwuCallCenterDetails)
--- Base.CallCenterToPhone (Base.vwuCallCenterDetails)


---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement_1 string; -- cte and select statement for the merge
    insert_statement_1 string; -- insert statement for the merge
    merge_statement_1 string; -- merge statement to final table
    select_statement_2 string;
    insert_statement_2 string;
    update_statement_2 string;
    merge_statement_2 string;
    update_statement_3 string;
    update_statement_4 string;
    update_statement_5 string;
    update_statement_6 string;
    update_statement_7 string;
    update_statement_8 string;
    update_statement_9 string;
    update_statement_10 string;
    update_statement_11 string;
    update_statement_12 string;
    update_statement_13 string;
    update_statement_14 string;
    update_statement_15 string;
    update_statement_16 string;
    update_statement_17 string;
    update_statement_18 string;
    update_statement_19 string;
    update_statement_20 string;
    temp_table_statement_1 string;
    update_statement_temp_1 string;
    update_statement_21 string;
    update_statement_22 string;
    if_condition string;
    update_statement_23 string;
    update_statement_24 string;
    -------------- xml load ----------------
    select_statement_xml_load_1 string;
    update_statement_xml_load_1 string;
    select_statement_xml_load_2 string;
    update_statement_xml_load_2 string;
    select_statement_xml_load_3 string;
    update_statement_xml_load_3 string;
    
    select_statement_facility string;
    update_statement_facility string;
    select_statement_condition_hierarchy string;
    update_statement_condition_hierarchy string;
    select_statement_cond_mapped string;
    update_statement_cond_mapped string;

    select_statement_sponsorship string;
    update_statement_xml_load_4 string;

    
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrprovider');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');

---------------------------------------------------------
----------------- 3. sql statements ---------------------
---------------------------------------------------------     
begin


------------ Step 2: Generate from Mid --------------

--- select Statement 
select_statement_2 :=  $$ with cte_batch_process as (
                            	select distinct
                    					p.providerid,
                                        p.providercode
                    			from base.provider as p 
                    			where p.npi is not null
                    			union 
                    			select distinct
                    					p.providerid,
                                        p.providercode
                    			from $$ || mdm_db || $$.mst.provider_profile_processing as ppp 
                    			inner join base.provider as p on p.providercode = ppp.ref_PROVIDER_CODE
                    			where p.npi is not null
                                
                        ), cte_provider_image as (
                                select
                                    *
                                from
                                    (
                                        select
                                            a.providerid,
                                            a.filename as ImageFilePath,
                                            'http://d306gt4zvs7g2s.cloudfront.net/img/prov/' || SUBSTRING(a.filename, 1, 1) || '/' || SUBSTRING(a.filename, 2, 1) || '/' || SUBSTRING(a.filename, 3, 1) || '/' || a.filename as imFull,
                                            row_number() over(
                                                partition by a.providerid
                                                order by
                                                    a.providerid
                                            ) as RN1
                                        from
                                            base.providerimage a
                                            inner join base.mediasize ms on a.mediasizeid = ms.mediasizeid
                                        where
                                            ms.mediasizename = 'Medium'
                                    )
                                where
                                    RN1 <= 1
                            ) 
                        ,
                            cte_care_philosophy as (
                                select
                                    *
                                from
                                    (
                                        select
                                            ProviderID,
                                            pam.provideraboutmetext,
                                            row_number() over(
                                                partition by ProviderId
                                                order by
                                                    pam.lastupdateddate desc
                                            ) as RN1
                                        from
                                            base.aboutme am
                                            inner join base.providertoaboutme pam on am.aboutmeid = pam.aboutmeid
                                            and am.aboutmecode = 'CarePhilosophy'
                                    )
                                where
                                    RN1 <= 1
                            ) 
                        ,
                            cte_city_state_greater_1 as (
                                select
                                    ProviderID --652,813
                                from
                                    mid.providerpracticeoffice
                                group by
                                    ProviderID
                                having
                                    COUNT(distinct CONCAT(City, State)) > 1
                            ),
                            cte_city_state_concat as (
                                select
                                    providerID,
                                    LISTAGG(city || ', ' || state, '|') as CityState
                                from
                                    mid.providerpracticeoffice
                                group by
                                    providerID
                            ),
                            cte_city_state_multiple as (
                                select
                                    CTE_batch.providerid,
                                    CTE_csc.citystate as CityStateAll
                                from
                                    cte_batch_process as CTE_BATCH
                                    join cte_city_state_greater_1 b on CTE_batch.providerid = b.providerid
                                    left join cte_city_state_concat as CTE_CSC on CTE_batch.providerid = CTE_csc.providerid
                            ),
                            cte_city_state_equal_1 as (
                                select
                                    ProviderID --652,813
                                from
                                    mid.providerpracticeoffice
                                group by
                                    ProviderID
                                having
                                    COUNT(distinct CONCAT(City, State)) = 1
                            ),
                            cte_city_state_single as (
                                select
                                    mppo.providerid,
                                    trim(City) || ', ' || State as CityStateAll
                                from
                                    mid.providerpracticeoffice as MPPO
                                    join cte_city_state_equal_1 as CTE_CSE1 on mppo.providerid = CTE_CSE1.providerid
                            ),
                            cte_city_state_all as (
                                select
                                    CTE_bp.providerid,
                                    CASE
                                        WHEN CTE_csm.providerid is null then CTE_css.citystateall
                                        else CTE_csm.citystateall
                                    END as CityStateAll
                                from
                                    cte_batch_process as CTE_BP
                                    left join cte_city_state_single as CTE_CSS on CTE_css.providerid = CTE_bp.providerid
                                    left join cte_city_state_multiple as CTE_CSM on CTE_csm.providerid = CTE_bp.providerid
                            ),
                            cte_email as (
                                select
                                    *
                                from
                                    (
                                        select
                                            ProviderID,
                                            EmailAddress,
                                            row_number() over(
                                                partition by ProviderId
                                                order by
                                                    LastUpdateDate desc
                                            ) as RN1
                                        from
                                            base.provideremail
                                    )
                                where
                                    RN1 <= 1
                            ) 
                        ,
                            cte_provider_type_group as (
                                select
                                    *
                                from
                                    (
                                        select
                                            ProviderTypeID,
                                            trim(x.providertypecode) as ProviderTypeCode,
                                            row_number() over(
                                                partition by ProviderTypeID
                                                order by
                                                    x.lastupdatedate desc
                                            ) as RN1
                                        from
                                            base.providertype X
                                    )
                                where
                                    RN1 <= 1
                            ),
                            cte_media_school_nation as (
                                select
                                    *
                                from
                                    (
                                        select
                                            mpe.providerid,
                                            mpe.nationname,
                                            row_number() over(
                                                partition by mpe.providerid
                                                order by
                                                    mpe.nationname desc,
                                                    mpe.graduationyear desc
                                            ) as RN1
                                        from
                                            mid.providereducation as MPE
                                            inner join cte_batch_process as CTE_BP on CTE_bp.providerid = mpe.providerid
                                    )
                                where
                                    RN1 <= 1
                            ) 
                        ,
                            cte_years_since_medical_school_graduation as (
                                select
                                    *
                                from
                                    (
                                        select
                                            mpe.providerid,
                                            EXTRACT(
                                                YEAR
                                                from
                                                    CURRENT_DATE
                                            ) - CASE
                                                WHEN TRY_TO_NUMBER(GraduationYear) is null then null
                                                else TRY_TO_NUMBER(GraduationYear)
                                            END as YearsSinceMedicalSchoolGraduation,
                                            row_number() over (
                                                partition by mpe.providerid
                                                order by
                                                    mpe.nationname desc,
                                                    mpe.graduationyear desc
                                            ) as RN1
                                        from
                                            mid.providereducation MPE
                                            inner join cte_batch_process CTE_BP on CTE_bp.providerid = mpe.providerid
                                    )
                                where
                                    RN1 <= 1
                            ) 
                        ,
                            cte_patient_experience_survey_overall_score as (
                                select
                                    *
                                from
                                    (
                                        select
                                            bpsa.providercode,
                                            (ProviderAverageScore / 5) * 100 as PatientExperienceSurveyOverallScore,
                                            row_number() over(
                                                partition by bpsa.providerid
                                                order by
                                                    bpsa.updatedon desc
                                            ) as RN1
                                        from
                                            base.providersurveyaggregate as BPSA
                                            -- originally was like this but the IDs in BPSA are from SQL Server, join on ProviderCode
                                            -- inner join cte_batch_process CTE_BP on CTE_bp.providerid = bpsa.providerid
                                            inner join cte_batch_process CTE_BP on CTE_bp.providercode = bpsa.providercode
                                        where
                                            QuestionID = 231
                                    )
                                where
                                    RN1 <= 1
                            ),
                            cte_patient_experience_survey_overall_star_value as (
                                select
                                    *
                                from
                                    (
                                        select
                                            bpsa.providercode,
                                            bpsa.provideraveragescore,
                                            row_number() over(
                                                partition by bpsa.providerid
                                                order by
                                                    bpsa.updatedon desc
                                            ) as RN1
                                        from
                                            base.providersurveyaggregate as BPSA
                                            -- originally was like this but the IDs in BPSA are from SQL Server, join on ProviderCode
                                            -- inner join cte_batch_process CTE_BP on CTE_bp.providerid = bpsa.providerid
                                            inner join cte_batch_process CTE_BP on CTE_bp.providercode = bpsa.providercode
                                        where
                                            QuestionID = 231
                                    )
                                where
                                    rn1 <= 1
                            ),
                            cte_patient_experience_survey_overall_count as (
                                select
                                    *
                                from
                                    (
                                        select
                                            bpsa.providercode,
                                            bpsa.questioncount,
                                            row_number() over(
                                                partition by bpsa.providerid
                                                order by
                                                    bpsa.updatedon desc
                                            ) as RN1
                                        from
                                            base.providersurveyaggregate as BPSA
                                            -- originally was like this but the IDs in BPSA are from SQL Server, join on ProviderCode
                                            -- inner join cte_batch_process CTE_BP on CTE_bp.providerid = bpsa.providerid
                                            inner join cte_batch_process CTE_BP on CTE_bp.providercode = bpsa.providercode
                                        where
                                            QuestionID = 231
                                    )
                                where
                                    RN1 <= 1
                            ),
                            cte_display_status_code_sub as (
                                select
                                    bptss.providerid,
                                    bds.displaystatuscode,
                                    bptss.hierarchyrank,
                                    ss.substatusrank
                                from
                                    base.providertosubstatus as BPTSS
                                    inner join cte_batch_process as CTE_BP on CTE_bp.providerid = bptss.providerid
                                    inner join base.substatus as SS on ss.substatusid = bptss.substatusid
                                    inner join base.displaystatus as BDS on bds.displaystatusid = ss.displaystatusid
                                where
                                    bptss.hierarchyrank = 1
                                union
                                select
                                    ProviderId,
                                    'A' as DisplayStatusCode,
                                    2147483647 as HierarchyRank,
                                    2147483647 as SubStatusRank
                                from
                                    base.provider
                            ),
                            cte_display_status_code as (
                                select
                                    *
                                from(
                                        select
                                            ProviderId,
                                            DisplayStatusCode,
                                            HierarchyRank,
                                            SubStatusRank,
                                            row_number() over(
                                                partition by ProviderId
                                                order by
                                                    HierarchyRank,
                                                    SubStatusRank
                                            ) as RN1
                                        from
                                            cte_display_status_code_sub
                                    )
                                where
                                    RN1 <= 1
                            ),
                            cte_sub_status_code_sub as (
                                select
                                    bpss.providerid,
                                    ss.substatuscode,
                                    bpss.hierarchyrank,
                                    ss.substatusrank
                                from
                                    base.providertosubstatus as BPSS
                                    inner join cte_batch_process as CTE_BP on CTE_bp.providerid = bpss.providerid
                                    inner join base.substatus as SS on ss.substatusid = bpss.substatusid
                                    inner join base.displaystatus as BDS on bds.displaystatusid = ss.displaystatusid
                                where
                                    bpss.hierarchyrank = 1
                                union
                                select
                                    ProviderId,
                                    'K' as SubStatusCode,
                                    2147483647 as HierarchyRank,
                                    2147483647 as SubStatusRank
                                from
                                    base.provider
                            ),
                            cte_sub_status_code as (
                                select
                                    *
                                from
                                    (
                                        select
                                            ProviderId,
                                            SubStatusCode,
                                            HierarchyRank,
                                            SubStatusRank,
                                            row_number() over(
                                                partition by ProviderId
                                                order by
                                                    HierarchyRank,
                                                    SubStatusRank
                                            ) as RN1
                                        from
                                            cte_sub_status_code_sub
                                    )
                                where
                                    RN1 <= 1
                            ),
                            cte_product_group_code as (
                                select
                                    *
                                from
                                    (
                                        select
                                            p.providerid,
                                            ProductGroupCode,
                                            row_number() over(
                                                partition by p.providerid
                                                order by
                                                    ProductGroupCode desc
                                            ) as RN1
                                        from
                                            mid.providersponsorship as MPS
                                            inner join base.provider as P on p.providercode = mps.providercode
                                            inner join cte_batch_process as CTE_BP on CTE_bp.providerid = p.providerid
                                        where
                                            ProductGroupCode = 'PDC'
                                    )
                                where
                                    RN1 <= 1
                            ) 
                        ,
                            cte_product_code as (
                                select
                                    *
                                from
                                    (
                                        select
                                            p.providerid,
                                            ProductCode,
                                            row_number() over(
                                                partition by p.providerid
                                                order by
                                                    ProductGroupCode desc
                                            ) as RN1
                                        from
                                            mid.providersponsorship as MPS
                                            inner join base.provider as P on p.providercode = mps.providercode
                                            inner join cte_batch_process as CTE_BP on CTE_bp.providerid = p.providerid
                                        where
                                            ProductGroupCode = 'PDC'
                                    )
                                where
                                    RN1 <= 1
                            ) 
                        ,
                            cte_sponsor_code as (
                                select
                                    *
                                from
                                    (
                                        select
                                            p.providerid,
                                            ClientCode as SponsorCode,
                                            row_number() over(
                                                partition by p.providerid
                                                order by
                                                    ProductGroupCode desc
                                            ) as RN1
                                        from
                                            mid.providersponsorship as MPS
                                            inner join base.provider as P on p.providercode = mps.providercode
                                            inner join cte_batch_process as CTE_BP on CTE_bp.providerid = p.providerid
                                        where
                                            ProductGroupCode = 'PDC'
                                    )
                                where
                                    RN1 <= 1
                            ) 
                        ,
                            cte_pipe_separated_facility as (
                                select
                                    p.providerid,
                                    listagg(mps.providercode, '|') as codes
                                from
                                    mid.providersponsorship as MPS
                                    inner join base.provider as P on p.providercode = mps.providercode
                                    inner join cte_batch_process as CTE_BP on CTE_bp.providerid = p.providerid
                                where
                                    ProductGroupCode = 'PDC'
                                group by
                                    p.providerid
                            ) 
                        ,
                            cte_facility_code as (
                                select
                                    p.providerid,
                                    CTE_psf.codes as Facility,
                                    row_number() over(
                                        partition by p.providerid
                                        order by
                                            ProductGroupCode desc
                                    ) as RN1
                                from
                                    mid.providersponsorship as MPS
                                    inner join base.provider as P on p.providercode = mps.providercode
                                    inner join cte_batch_process as CTE_BP on CTE_bp.providerid = p.providerid
                                    inner join cte_pipe_separated_facility as CTE_PSF on CTE_psf.providerid = p.providerid
                                where
                                    ProductGroupCode = 'PDC'
                            ) 
                        ,
                            cte_about_me as (
                                select
                                    pam.providerid,
                                    ProviderAboutMeText,
                                    row_number() over(
                                        partition by CTE_bp.providerid
                                        order by
                                            pam.lastupdateddate desc
                                    ) as RN1
                                from
                                    base.aboutme as AM
                                    inner join base.providertoaboutme as PAM on am.aboutmeid = pam.aboutmeid
                                    and am.aboutmecode = 'ResponseToPes'
                                    inner join cte_batch_process as CTE_BP on CTE_bp.providerid = pam.providerid
                            ) 
                        ,
                            cte_survey_response_date as (
                                select
                                    pam.providerid,
                                    SurveyResponseDate,
                                    row_number() over(
                                        partition by CTE_bp.providerid
                                        order by
                                            pam.surveyresponsedate desc
                                    ) as RN1
                                from
                                    mid.providersurveyresponse as PAM
                                    inner join CTE_BATCH_PROCESS as CTE_BP on CTE_bp.providerid = pam.providerid
                            ) 
                        ,
                            cte_has_malpractice_state_sub as (
                                select
                                    ProviderId,
                                    CASE
                                        WHEN exists (
                                            select
                                                1
                                            from
                                                mid.providerpracticeoffice ppo
                                                join base.malpracticestate mps on ppo.state = mps.state
                                                and ifnull(mps.active, 1) = 1
                                            where
                                                p.providerid = ppo.providerid
                                        ) then 1
                                        WHEN exists (
                                            select
                                                1
                                            from
                                                mid.providermalpractice pm
                                            where
                                                p.providerid = pm.providerid
                                        ) then 1
                                        else 0
                                    END HasMalpracticeState
                                from
                                    cte_batch_process P
                            ) 
                        ,
                            cte_has_malpractice_state as (
                                select
                                    *
                                from
                                    (
                                        select
                                            ProviderId,
                                            HasMalpracticeState,
                                            row_number() over(
                                                partition by ProviderID
                                                order by
                                                    HasMalpracticeState desc
                                            ) as RN1
                                        from
                                            cte_has_malpractice_state_sub
                                    )
                                where
                                    RN1 <= 1
                            ) 
                        ,
                            cte_procedure_count as (
                                select
                                    mpp.providerid,
                                    COUNT(ProcedureCode) as ProcedureCount
                                from
                                    mid.providerprocedure as MPP
                                    inner join cte_batch_process as CTE_BP on CTE_bp.providerid = mpp.providerid
                                group by
                                    mpp.providerid
                            ) 
                        ,
                            cte_condition_count as (
                                select
                                    mpp.providerid,
                                    COUNT(ProcedureCode) as ConditionCount
                                from
                                    mid.providerprocedure as MPP
                                    inner join cte_batch_process as CTE_BP on CTE_bp.providerid = mpp.providerid
                                group by
                                    mpp.providerid
                            ) 
                        ,
                            cte_condition_code as (
                                select
                                    mpp.providerid,
                                    COUNT(ProcedureCode) as ConditionCount
                                from
                                    mid.providerprocedure as MPP
                                    inner join cte_batch_process as CTE_BP on CTE_bp.providerid = mpp.providerid
                                group by
                                    mpp.providerid
                            ) 
                        ,
                            --THIS CTE RETURNS EMPTY, I VALIDATED IN SQL SERVER IT ALSO RETURNS EMPTY
                            cte_oar as (
                                select
                                    distinct CTE_bp.providerid,
                                    HasOar
                                from
                                    mid.providersponsorship as MPS
                                    inner join base.product as BP on mps.productcode = bp.productcode
                                    inner join base.provider as P on p.providercode = mps.providercode
                                    inner join cte_batch_process as CTE_BP on CTE_bp.providerid = p.providerid
                                    and(
                                        bp.producttypecode = 'PRACTICE'
                                        or mps.clientcode IN ('OCHSNR', 'PRVHEW')
                                    )
                            ) 
                        ,
                            cte_availability_statement as (
                                select
                                    bpaas.providerid,
                                    AppointmentAvailabilityStatement,
                                    row_number() over(
                                        partition by bpaas.providerid
                                        order by
                                            LastUpdatedDate desc
                                    ) as RN1
                                from
                                    base.providerappointmentavailabilitystatement as BPAAS
                                    inner join cte_batch_process as CTE_BP on CTE_bp.providerid = bpaas.providerid
                            ) 
                        ,
                            cte_has_about_me as (
                                select
                                    distinct CTE_bp.providerid,
                                    1 as HasAboutMe
                                from
                                    base.aboutme as BAM
                                    inner join base.providertoaboutme as PAM on pam.aboutmeid = bam.aboutmeid
                                    inner join cte_batch_process as CTE_BP on CTE_bp.providerid = pam.providerid
                                where
                                    bam.aboutmecode = 'About'
                            ) 
                        ,
                            cte_provider_sub_type as (
                                select
                                    *
                                from
                                    (
                                        select
                                            bptpst.providerid,
                                            bpst.providersubtypecode,
                                            row_number() over(
                                                partition by bptpst.providerid
                                                order by
                                                    bpst.providersubtyperank ASC,
                                                    bptpst.lastupdatedate desc
                                            ) as RN1
                                        from
                                            base.providertoprovidersubtype as BPTPST
                                            inner join base.providersubtype as BPST on bptpst.providersubtypeid = bpst.providersubtypeid
                                            inner join cte_batch_process as CTE_BP on CTE_bp.providerid = bptpst.providerid
                                    )
                                where
                                    RN1 <= 1
                            ) 
                        ,
                            cte_provider_is_board_eligible as (
                                select
                                    ps.providerid
                                from
                                    base.providersanction as ps
                                    join base.sanctionaction as sa on sa.sanctionactionid = ps.sanctionactionid
                                    join base.sanctionactiontype as sat on sat.sanctionactiontypeid = sa.sanctionactiontypeid
                                    join cte_batch_process as bp on ps.providerid = bp.providerid
                                where
                                    sat.sanctionactiontypecode = 'B'
                                union
                                    --using Only Provider SubType (DOC and NDOC)
                                select
                                    ptpst.providerid
                                from
                                    base.providersubtype as pst
                                    join base.providertoprovidersubtype as ptpst on ptpst.providersubtypeid = pst.providersubtypeid
                                    join cte_batch_process as bp on ptpst.providerid = bp.providerid
                                where
                                    pst.isboardactioneligible = 1
                                union
                                    --using Provider SubType To Degree (MDEX Plus Degrees)
                                select
                                    ptpst.providerid
                                from
                                    base.providersubtypetodegree as psttd
                                    join base.providertoprovidersubtype as ptpst on psttd.providersubtypeid = ptpst.providersubtypeid
                                    join base.providertodegree as ptd on ptd.providerid = ptpst.providerid
                                    and psttd.degreeid = ptd.degreeid
                                    join cte_batch_process as bp on ptpst.providerid = bp.providerid
                                where
                                    psttd.isboardactioneligible = 1
                                union
                                    --using Specialty Group (GMPA)
                                select
                                    ps.providerid
                                from
                                    base.specialtygroup as sg
                                    join base.specialtygrouptospecialty as sgts on sgts.specialtygroupid = sg.specialtygroupid
                                    join base.providertospecialty as ps on ps.specialtyid = sgts.specialtyid
                                    join cte_batch_process as bp on ps.providerid = bp.providerid
                                where
                                    sg.isboardactioneligible = 1
                            ) 
                        ,
                            cte_pss as (
                                select
                                    a.providerid,
                                    a.substatusvaluea
                                from
                                    base.providertosubstatus as a
                                    join base.substatus as b on b.substatusid = a.substatusid
                                    and b.substatuscode = 'U'
                            ) 
                        ,
                            cte_prov_updates_sub as (
                                select
                                    distinct p.providerid,
                                    p.providercode,
                                    p.providertypeid,
                                    p.firstname,
                                    p.middlename,
                                    p.lastname,
                                    p.suffix,
                                    p.gender,
                                    p.npi,
                                    p.amaid,
                                    p.upin,
                                    p.medicareid,
                                    p.deanumber,
                                    p.taxidnumber,
                                    p.dateofbirth,
                                    p.placeofbirth,
                                    CTE_cp.providerid as CarePhilosophy,
                                    p.professionalinterest,
                                    p.acceptsnewpatients,
                                    p.haselectronicmedicalrecords,
                                    p.haselectronicprescription,
                                    p.legacykey,
                                    p.degreeabbreviation as Degree,
                                    p.title,
                                    p.providerurl,
                                    p.expirecode,
                                    pss.substatusvaluea,
                                    CTE_csa.citystateall as CityStateAll,
                                    CTE_e.emailaddress as PrimaryEmailAddress,
                                    trim(CTE_ptg.providertypecode) as ProviderTypeGroup,
                                    CTE_msn.nationname as MedicalSchoolNation,
                                    CTE_ysmsg.yearssincemedicalschoolgraduation as YearsSinceMedicalSchoolGraduation,
                                    CASE
                                        WHEN exists(
                                            select
                                                ProviderId
                                            from
                                                cte_provider_image as a
                                            where
                                                a.providerid = p.providerid
                                        ) then 1
                                        else 0
                                    END as HasDisplayImage,
                                    CTE_pi.imagefilepath as Image,
                                    CTE_pi.imfull as imFull,
                                    null as ProviderProfileViewOneYear,
                                    null as YearlySearchVolume,
                                    CTE_pesos.patientexperiencesurveyoverallscore as PatientExperienceSurveyOverallScore,
                                    CTE_pesosv.provideraveragescore as PatientExperienceSurveyOverallStarValue,
                                    CTE_pesoc.questioncount as PatientExperienceSurveyOverallCount,
                                    null as ProviderBiography,
                                    CTE_dsc.displaystatuscode as DisplayStatusCode,
                                    CTE_ssc.substatuscode as SubStatusCode,
                                    CTE_pgc.productgroupcode as ProductGroupCode,
                                    CTE_sc.sponsorcode as SponsorCode,
                                    CTE_pc.productcode as ProductCode,
                                    CTE_fc.facility as FacilityCode,
                                    CTE_am.provideraboutmetext as SurveyResponse,
                                    CTE_srd.surveyresponsedate as SurveyResponseDate,
                                    CTE_hms.hasmalpracticestate as HasMalpracticeState,
                                    CTE_pcount.procedurecount as ProcedureCount,
                                    CTE_cc.conditioncount as ConditionCount,
                                    null as PatientVolume,
                                    -- CTE_as.appointmentavailabilitystatement as AvailabilityStatement,
                                    p.providerlastupdatedateoverall as UpdatedDate,
                                    null as UpdatedSource,
                                    CTE_o.hasoar as HasOar,
                                    null as IsMMPUser,
                                    CTE_ham.hasaboutme as HasAboutMe,
                                    pb.searchboostsatisfaction,
                                    pb.searchboostaccessibility,
                                    pb.ispcpcalculated,
                                    pb.fafboostsatisfaction,
                                    pb.fafboostsancmalp,
                                    p.ffdisplayspecialty,
                                    pb.ffesatisfactionboost as FFPESBoost,
                                    pb.ffmalmultihq,
                                    pb.ffmalmulti,
                                    CTE_pst.providersubtypecode as ProviderSubTypeCode
                                from
                                    mid.provider as p
                                    inner join base.provider as pb on pb.providerid = p.providerid -- inner join #BatchInsertUpdateProcess
                                    -- as batch on batch.providerid = p.providerid
                                    inner join cte_batch_process as CTE_BP on CTE_bp.providerid = p.providerid
                                    left join cte_city_state_multiple e on p.providerid = e.providerid
                                    left join cte_pss as pss on pss.providerid = p.providerid
                                    left join cte_care_philosophy as CTE_CP on CTE_cp.providerid = p.providerid
                                    left join cte_city_state_all as CTE_CSA on CTE_csa.providerid = p.providerid
                                    left join cte_email as CTE_E on CTE_e.providerid = p.providerid
                                    left join cte_provider_type_group as CTE_PTG on CTE_ptg.providertypeid = p.providertypeid
                                    left join cte_media_school_nation as CTE_MSN on CTE_msn.providerid = p.providerid
                                    left join cte_years_since_medical_school_graduation as CTE_YSMSG on CTE_ysmsg.providerid = p.providerid
                                    left join cte_provider_image as CTE_PI on CTE_pi.providerid = p.providerid
                                    -- originally was like this but these IDs in BPSA are from SQL Server, join on ProviderCode
                                    -- left join cte_patient_experience_survey_overall_score as CTE_PESOS on CTE_pesos.providerid = p.providerid
                                    left join cte_patient_experience_survey_overall_score as CTE_PESOS on CTE_pesos.providercode = p.providercode
                                    -- left join cte_patient_experience_survey_overall_star_value as CTE_PESOSV on CTE_pesosv.providerid = p.providerid
                                    left join cte_patient_experience_survey_overall_star_value as CTE_PESOSV on CTE_pesosv.providercode = p.providercode
                                    -- left join cte_patient_experience_survey_overall_count as CTE_PESOC on CTE_pesoc.providerid = p.providerid
                                    left join cte_patient_experience_survey_overall_count as CTE_PESOC on CTE_pesoc.providercode = p.providercode
                                    left join cte_display_status_code as CTE_DSC on CTE_dsc.providerid = p.providerid
                                    left join cte_sub_status_code as CTE_SSC on CTE_ssc.providerid = p.providerid
                                    left join cte_product_group_code as CTE_PGC on CTE_pgc.providerid = p.providerid
                                    left join cte_sponsor_code as CTE_SC on CTE_sc.providerid = p.providerid
                                    left join cte_product_code as CTE_PC on CTE_pc.providerid = p.providerid
                                    left join cte_facility_code as CTE_FC on CTE_fc.providerid = p.providerid
                                    left join cte_about_me as CTE_AM on CTE_am.providerid = p.providerid
                                    left join cte_survey_response_date as CTE_SRD on CTE_srd.providerid = p.providerid
                                    left join cte_has_malpractice_state as CTE_HMS on CTE_hms.providerid = p.providerid
                                    left join cte_procedure_count as CTE_PCOUNT on CTE_pcount.providerid = p.providerid
                                    left join cte_condition_count as CTE_CC on CTE_cc.providerid = p.providerid
                                    left join cte_availability_statement as CTE_AS on CTE_as.providerid = p.providerid
                                    left join cte_oar as CTE_O on CTE_o.providerid = p.providerid
                                    left join cte_has_about_me as CTE_HAM on CTE_ham.providerid = p.providerid
                                    left join cte_provider_sub_type as CTE_PST on CTE_pst.providerid = p.providerid
                            ),
                            cte_prov_updates as (
                                select
                                    CTE_pus.providerid,
                                    ProviderCode,
                                    LegacyKey as ProviderLegacyKey,
                                    ProviderTypeID,
                                    ProviderTypeGroup,
                                    FirstName,
                                    MiddleName,
                                    LastName,
                                    Suffix,
                                    upper(Degree) as Degree,
                                    upper(Gender) as Gender,
                                    NPI,
                                    AMAID,
                                    UPIN,
                                    MedicareID,
                                    DEANumber,
                                    TaxIDNumber,
                                    DateOfBirth,
                                    PlaceOfBirth,
                                    CarePhilosophy,
                                    ProfessionalInterest,
                                    PrimaryEmailAddress,
                                    /*City,St*/
                                    MedicalSchoolNation,
                                    YearsSinceMedicalSchoolGraduation,
                                    HasDisplayImage,
                                    imFull as DisplayImage,
                                    HasElectronicMedicalRecords,
                                    HasElectronicPrescription,
                                    AcceptsNewPatients,
                                    YearlySearchVolume,
                                    ProviderProfileViewOneYear,
                                    PatientExperienceSurveyOverallScore,
                                    PatientExperienceSurveyOverallStarValue,
                                    PatientExperienceSurveyOverallCount,
                                    ProviderBiography,
                                    ProviderURL,
                                    CTE_pus.displaystatuscode,
                                    CTE_pus.substatuscode,
                                    CASE
                                        WHEN SubStatusCode = 'U' then SubStatusValueA
                                        else null
                                    END as DuplicateProviderCode,
                                    ProductGroupCode,
                                    SponsorCode,
                                    ProductCode,
                                    FacilityCode,
                                    SurveyResponse,
                                    SurveyResponseDate,
                                    HasMalpracticeState,
                                    ProcedureCount,
                                    ConditionCount,
                                    null as IsActive,
                                    UpdatedDate,
                                    UpdatedSource,
                                    Title,
                                    CityStateAll,
                                    CASE
                                        WHEN PatientExperienceSurveyOverallScore >= 75 then 1
                                        else 0
                                    END as DisplayPatientExperienceSurveyOverallScore,
                                    CTE_ds.deactivationreason as DeactivationReason,
                                    PatientVolume,
                                    -- AvailabilityStatement,
                                    HasOAR,
                                    IsMMPUser,
                                    HasAboutMe,
                                    SearchBoostSatisfaction,
                                    SearchBoostAccessibility,
                                    IsPCPCalculated,
                                    FAFBoostSatisfaction,
                                    FAFBoostSancMalp,
                                    FFDisplaySpecialty,
                                    FFPESBoost,
                                    FFMalMultiHQ,
                                    FFMalMulti,
                                    ProviderSubTypeCode
                                from
                                    cte_prov_updates_sub as CTE_PUS
                                    left join base.displaystatus as CTE_DS on CTE_ds.displaystatuscode = CTE_pus.displaystatuscode -- join #BatchInsertUpdateProcess b on b.providerid = py.providerid
                            ),
                            cte_display_image as (
                                select
                                    pu.providerid,
                                    '/img/prov/' || lower(SUBSTRING(bp.providercode, 1, 1)) || '/' || lower(SUBSTRING(bp.providercode, 2, 1)) || '/' || lower(SUBSTRING(bp.providercode, 3, 1)) || '/' || lower(bp.providercode) || '_w' || CAST(ms.width as varchar(10)) || 'h' || CAST(ms.height as varchar(10)) || '_v' || bpi.externalidentifier || '.jpg' as DisplayImage
                                from
                                    base.providerimage as bpi
                                    inner join base.provider as bp on bp.providerid = bpi.providerid
                                    inner join cte_prov_updates as PU on pu.providerid = bp.providerid
                                    inner join base.mediaimagehost as mih on mih.mediaimagehostid = bpi.mediaimagehostid
                                    inner join base.mediacontexttype as mct on mct.mediacontexttypeid = bpi.mediacontexttypeid
                                    CROSS join base.mediasize as ms
                                where
                                    mih.mediaimagehostcode = 'BRIGHTSPOT'
                                    and ms.mediasizecode IN ('MEDIUM')
                                    and pu.displayimage is null
                                    and pu.hasdisplayimage = 1
                            ) 
                            select
                                CTE_pu.providerid,
                                ProviderCode,
                                ProviderLegacyKey,
                                ProviderTypeID,
                                ProviderTypeGroup,
                                FirstName,
                                MiddleName,
                                LastName,
                                Suffix,
                                Degree,
                                Gender,
                                NPI,
                                AMAID,
                                UPIN,
                                MedicareID,
                                DEANumber,
                                TaxIDNumber,
                                DateOfBirth,
                                PlaceOfBirth,
                                CarePhilosophy,
                                ProfessionalInterest,
                                PrimaryEmailAddress,
                                MedicalSchoolNation,
                                YearsSinceMedicalSchoolGraduation,
                                ----------------------------------
                                CASE
                                    WHEN CTE_pu.displayimage is null
                                    and CTE_pu.hasdisplayimage = 1 then CTE_di.displayimage
                                    else CTE_pu.displayimage
                                END as DisplayImage,
                                ----------------------------------
                                HasDisplayImage,
                                HasElectronicMedicalRecords,
                                HasElectronicPrescription,
                                AcceptsNewPatients,
                                YearlySearchVolume,
                                ProviderProfileViewOneYear,
                                PatientExperienceSurveyOverallScore,
                                PatientExperienceSurveyOverallStarValue,
                                PatientExperienceSurveyOverallCount,
                                ProviderBiography,
                                ProviderURL,
                                DisplayStatusCode,
                                SubStatusCode,
                                DuplicateProviderCode,
                                ProductGroupCode,
                                SponsorCode,
                                ProductCode,
                                FacilityCode,
                                SurveyResponse,
                                SurveyResponseDate,
                                HasMalpracticeState,
                                ProcedureCount,
                                ConditionCount,
                                IsActive,
                                UpdatedDate,
                                UpdatedSource,
                                Title,
                                CityStateAll,
                                DisplayPatientExperienceSurveyOverallScore,
                                DeactivationReason,
                                PatientVolume,
                                -- AvailabilityStatement,
                                HasOAR,
                                IsMMPUser,
                                HasAboutMe,
                                SearchBoostSatisfaction,
                                SearchBoostAccessibility,
                                IsPCPCalculated,
                                FAFBoostSatisfaction,
                                FAFBoostSancMalp,
                                FFDisplaySpecialty,
                                FFPESBoost,
                                FFMalMultiHQ,
                                FFMalMulti,
                                ProviderSubTypeCode
                            from
                                cte_prov_updates as CTE_PU
                                left join cte_display_image as CTE_DI on CTE_di.providerid = CTE_pu.providerid $$;

--- update Statement
update_statement_2 := ' update
                        SET
                            target.providercode = source.providercode,
                            target.providertypeid = source.providertypeid,
                            target.providertypegroup = source.providertypegroup,
                            target.firstname = source.firstname,
                            target.middlename = source.middlename,
                            target.lastname = source.lastname,
                            target.suffix = source.suffix,
                            target.degree = source.degree,
                            target.gender = source.gender,
                            target.npi = source.npi,
                            target.amaid = source.amaid,
                            target.upin = source.upin,
                            target.medicareid = source.medicareid,
                            target.deanumber = source.deanumber,
                            target.taxidnumber = source.taxidnumber,
                            target.dateofbirth = source.dateofbirth,
                            target.placeofbirth = source.placeofbirth,
                            target.carephilosophy = source.carephilosophy,
                            target.professionalinterest = source.professionalinterest,
                            target.primaryemailaddress = source.primaryemailaddress,
                            target.medicalschoolnation = source.medicalschoolnation,
                            target.yearssincemedicalschoolgraduation = source.yearssincemedicalschoolgraduation,
                            target.hasdisplayimage = source.hasdisplayimage,
                            target.haselectronicmedicalrecords = source.haselectronicmedicalrecords,
                            target.haselectronicprescription = source.haselectronicprescription,
                            target.acceptsnewpatients = source.acceptsnewpatients,
                            target.yearlysearchvolume = source.yearlysearchvolume,
                            target.providerprofileviewoneyear = source.providerprofileviewoneyear,
                            target.patientexperiencesurveyoverallscore = source.patientexperiencesurveyoverallscore,
                            target.patientexperiencesurveyoverallstarvalue = source.patientexperiencesurveyoverallstarvalue,
                            target.patientexperiencesurveyoverallcount = source.patientexperiencesurveyoverallcount,
                            target.providerbiography = source.providerbiography,
                            target.providerurl = source.providerurl,
                            target.productgroupcode = source.productgroupcode,
                            target.sponsorcode = source.sponsorcode,
                            target.productcode = source.productcode,
                            target.facilitycode = source.facilitycode,
                            target.providerlegacykey = source.providerlegacykey,
                            target.displayimage = source.displayimage,
                            target.surveyresponse = source.surveyresponse,
                            target.surveyresponsedate = source.surveyresponsedate,
                            target.updateddate = source.updateddate,
                            target.isactive = source.isactive,
                            target.updatedsource = source.updatedsource,
                            target.title = source.title,
                            target.citystateall = source.citystateall,
                            target.displaypatientexperiencesurveyoverallscore = source.displaypatientexperiencesurveyoverallscore,
                            target.displaystatuscode = source.displaystatuscode,
                            target.substatuscode = source.substatuscode,
                            target.deactivationreason = source.deactivationreason,
                            target.duplicateprovidercode = source.duplicateprovidercode,
                            target.patientvolume = source.patientvolume,
                            target.hasmalpracticestate = source.hasmalpracticestate,
                            target.procedurecount = source.procedurecount,
                            target.conditioncount = source.conditioncount,
                            -- target.availabilitystatement = source.availabilitystatement,
                            target.hasoar = source.hasoar,
                            target.ismmpuser = source.ismmpuser,
                            target.hasaboutme = source.hasaboutme,
                            target.searchboostsatisfaction = source.searchboostsatisfaction,
                            target.searchboostaccessibility = source.searchboostaccessibility,
                            target.ispcpcalculated = source.ispcpcalculated,
                            target.fafboostsatisfaction = source.fafboostsatisfaction,
                            target.fafboostsancmalp = source.fafboostsancmalp,
                            target.ffdisplayspecialty = source.ffdisplayspecialty,
                            target.ffpesboost = source.ffpesboost,
                            target.ffmalmultihq = source.ffmalmultihq,
                            target.ffmalmulti = source.ffmalmulti,
                            target.providersubtypecode = source.providersubtypecode';

--- insert Statement
insert_statement_2 := ' insert
                            (
                                ProviderID,
                                ProviderCode,
                                ProviderTypeID,
                                ProviderTypeGroup,
                                FirstName,
                                MiddleName,
                                LastName,
                                Suffix,
                                Degree,
                                Gender,
                                NPI,
                                AMAID,
                                UPIN,
                                MedicareID,
                                DEANumber,
                                TaxIDNumber,
                                DateOfBirth,
                                PlaceOfBirth,
                                CarePhilosophy,
                                ProfessionalInterest,
                                PrimaryEmailAddress,
                                MedicalSchoolNation,
                                YearsSinceMedicalSchoolGraduation,
                                HasDisplayImage,
                                HasElectronicMedicalRecords,
                                HasElectronicPrescription,
                                AcceptsNewPatients,
                                YearlySearchVolume,
                                ProviderProfileViewOneYear,
                                PatientExperienceSurveyOverallScore,
                                PatientExperienceSurveyOverallStarValue,
                                PatientExperienceSurveyOverallCount,
                                ProviderBiography,
                                ProviderURL,
                                ProductGroupCode,
                                SponsorCode,
                                ProductCode,
                                FacilityCode,
                                ProviderLegacyKey,
                                DisplayImage,
                                SurveyResponse,
                                SurveyResponseDate,
                                IsActive,
                                UpdatedDate,
                                UpdatedSource,
                                Title,
                                CityStateAll,
                                DisplayPatientExperienceSurveyOverallScore,
                                DisplayStatusCode,
                                SubStatusCode,
                                DuplicateProviderCode,
                                DeactivationReason,
                                PatientVolume,
                                HasMalpracticeState,
                                ProcedureCount,
                                ConditionCount,
                                -- AvailabilityStatement,
                                HasOar,
                                IsMMPUser,
                                HasAboutMe,
                                SearchBoostSatisfaction,
                                SearchBoostAccessibility,
                                isPCPCalculated,
                                FAFBoostSatisfaction,
                                FAFBoostSancMalp,
                                FFDisplaySpecialty,
                                FFPESBoost,
                                FFMalMultiHQ,
                                FFMalMulti,
                                ProviderSubTypeCode
                            )
                        values(
                                source.providerid,
                                source.providercode,
                                source.providertypeid,
                                source.providertypegroup,
                                source.firstname,
                                source.middlename,
                                source.lastname,
                                source.suffix,
                                source.degree,
                                source.gender,
                                source.npi,
                                source.amaid,
                                source.upin,
                                source.medicareid,
                                source.deanumber,
                                source.taxidnumber,
                                source.dateofbirth,
                                source.placeofbirth,
                                source.carephilosophy,
                                source.professionalinterest,
                                source.primaryemailaddress,
                                source.medicalschoolnation,
                                source.yearssincemedicalschoolgraduation,
                                source.hasdisplayimage,
                                source.haselectronicmedicalrecords,
                                source.haselectronicprescription,
                                source.acceptsnewpatients,
                                source.yearlysearchvolume,
                                source.providerprofileviewoneyear,
                                source.patientexperiencesurveyoverallscore,
                                source.patientexperiencesurveyoverallstarvalue,
                                source.patientexperiencesurveyoverallcount,
                                source.providerbiography,
                                source.providerurl,
                                source.productgroupcode,
                                source.sponsorcode,
                                source.productcode,
                                source.facilitycode,
                                source.providerlegacykey,
                                source.displayimage,
                                source.surveyresponse,
                                source.surveyresponsedate,
                                source.isactive,
                                source.updateddate,
                                source.updatedsource,
                                source.title,
                                source.citystateall,
                                source.displaypatientexperiencesurveyoverallscore,
                                source.displaystatuscode,
                                source.substatuscode,
                                source.duplicateprovidercode,
                                source.deactivationreason,
                                source.patientvolume,
                                source.hasmalpracticestate,
                                source.procedurecount,
                                source.conditioncount,
                                -- source.availabilitystatement,
                                source.hasoar,
                                source.ismmpuser,
                                source.hasaboutme,
                                source.searchboostsatisfaction,
                                source.searchboostaccessibility,
                                source.ispcpcalculated,
                                source.fafboostsatisfaction,
                                source.fafboostsancmalp,
                                source.ffdisplayspecialty,
                                source.ffpesboost,
                                source.ffmalmultihq,
                                source.ffmalmulti,
                                source.providersubtypecode
                            );';

-- fast
update_statement_3 := $$ update show.solrprovider target
                            SET target.providerlegacykey = src.legacykey
                            from base.providerlegacykeys as src 
                            where target.providerid = src.providerid; 
                        $$;

-- this delete doesn't seem to be doing anything
update_statement_4 := $$ delete from show.solrprovider
                        where SOLRPRoviderID IN (
                            select SOLRPRoviderID
                            from (
                                select SOLRPRoviderID, ProviderId
                                from (
                                    select SOLRPRoviderID, ProviderId, ProviderCode, 
                                    row_number() over(partition by ProviderCode order by CASE WHEN sponsorshipXML is not null then 1 else 9 END desc, DisplayStatusCode, ProviderTypeGroup desc, SOLRPRoviderID) as SequenceId
                                    from show.solrprovider
                                ) X
                                where SequenceId > 1
                            )
                        ); 
                        $$;


-- fast + we can merge this with update_statement 3 on providerid instead of code. does update rows
update_statement_5 := $$ update show.solrprovider target
                            SET DateOfFirstLoad = src.lastupdatedate
                            from  base.provider src 
                            where src.providercode = target.providercode; 
                        $$;

-- fast 
update_statement_6 := $$ update show.solrprovider target
                            SET 
                                target.sourceupdate = src.sourcename, 
                                target.sourceupdatedatetime = src.lastupdatedatetime
                            from show.providersourceupdate src 
                            where src.providerid = target.providerid; 
                        $$;


-- ~3 seconds
update_statement_7 := $$ update show.solrprovider target
                            SET AcceptsNewPatients = 1
                            from mid.provider src 
                            where src.providerid = target.providerid
                            and src.acceptsnewpatients = 1 and ifnull(target.acceptsnewpatients, 0) = 0; 
                        $$;

update_statement_8 := $$ update show.solrprovider target
                            SET SuppressSurvey = CASE WHEN src.providerid is not null then 1 else 0 END
                            from (
                                select distinct ProviderId
                                from base.providersurveysuppression
                            ) src 
                            where src.providerid = target.providerid; 
                        $$;


-- ~4s but does update rows even in full
update_statement_9 := $$  update show.solrprovider target
                            SET IsBoardActionEligible = CASE WHEN x.providerid is not null then 1 else 0 END
                            from (
                                select ps.providerid
                                from base.providersanction as ps
                                join base.sanctionaction as sa on sa.sanctionactionid = ps.sanctionactionid
                                join base.sanctionactiontype as sat on sat.sanctionactiontypeid = sa.sanctionactiontypeid
                                where sat.sanctionactiontypecode = 'B'
                                union
                                select ptpst.providerid
                                from base.providersubtype as pst
                                join base.providertoprovidersubtype as ptpst on ptpst.providersubtypeid = pst.providersubtypeid
                                where pst.isboardactioneligible = 1
                                union
                                select ptpst.providerid
                                from base.providersubtypetodegree as psttd
                                join base.providertoprovidersubtype as ptpst on psttd.providersubtypeid = ptpst.providersubtypeid
                                join base.providertodegree as ptd on ptd.providerid = ptpst.providerid and psttd.degreeid = ptd.degreeid
                                where psttd.isboardactioneligible = 1
                                union
                                select ps.providerid
                                from base.specialtygroup as sg
                                join base.specialtygrouptospecialty as sgts on sgts.specialtygroupid = sg.specialtygroupid
                                join base.providertospecialty as ps on ps.specialtyid = sgts.specialtyid
                                where sg.isboardactioneligible = 1
                            ) X 
                            where x.providerid = target.providerid; 
                        $$;


--------- Step 3: Client Certification XML ------------


-- the CTE for the XML generation returns 0 rows so this updates 0 rows
update_statement_10 := $$   update
                                show.solrprovider target
                            SET
                                ClientCertificationXML = parse_xml(CTE_ccx.certs)
                            from
                                (
                                    with cte_client_providers as (
                                        select
                                            distinct s.providercode,
                                            s.providerid,
                                            s.solrproviderid,
                                            pc.sourcecode
                                        from
                                            show.solrprovider as s
                                            join base.providercertification as pc on pc.providercode = s.providercode
                                    ) -- select* from cte_client_providers;
                            ,
                                    cte_cSpcL as (
                                        select
                                            pc.providercode,
                                            listagg( '<cspc>' || iff(pc.cspcd is not null,'<cspcd>' || pc.cspcd || '</cspcd>','') ||
iff(pc.cspy is not null,'<cspy>' || pc.cspy || '</cspy>','') ||
iff(pc.cacd is not null,'<cacd>' || pc.cacd || '</cacd>','') ||
iff(pc.cad is not null,'<cad>' || pc.cad || '</cad>','') ||
iff(pc.cbcd is not null,'<cbcd>' || pc.cbcd || '</cbcd>','') ||
iff(pc.cbd is not null,'<cbd>' || pc.cbd || '</cbd>','') ||
iff(pc.cscd is not null,'<cscd>' || pc.cscd || '</cscd>','') ||
iff(pc.csd is not null,'<csd>' || pc.csd || '</csd>','')  || '</cspc>','') as cSpcL
                                        from
                                            base.providercertification as pc
                                        where
                                            (
                                                pc.cspcd is not null
                                                or pc.cspy is not null
                                                or pc.cacd is not null
                                                or pc.cad is not null
                                                or pc.cbcd is not null
                                                or pc.cbd is not null
                                                or pc.cscd is not null
                                                or pc.csd is not null
                                            )
                                        group by
                                            pc.providercode
                                    ),
                                    cte_SpnL as (
                                        select
                                            cp.solrproviderid,
                                            cp.providercode,
                                            '<cspnl>' || listagg( '<cspn>' || iff(SUBSTRING(cp.sourcecode, 3, 50) is not null,'<spncd>' || SUBSTRING(cp.sourcecode, 3, 50) || '</spncd>','') ||
iff(cte_cspcl.cspcl is not null,'<cspcl>' || cte_cspcl.cspcl || '</cspcl>','')  || '</cspn>','') || '</cspnl>' as certs
                                        from
                                            cte_client_providers as cp
                                            left join CTE_cSpcL on CTE_cspcl.providercode = cp.providercode -- where cp.solrproviderid=prv.solrproviderid
                                        group by
                                            cp.solrproviderid,
                                            cp.providercode
                                    ),
                                    cte_certs as (
                                        select
                                            distinct prv.solrproviderid,
                                            prv.providercode,
                                            certs
                                        from
                                            cte_client_providers as prv
                                            left join cte_SpnL on cte_spnl.solrproviderid = prv.solrproviderid
                                            and cte_spnl.providercode = prv.providercode
                                    )
                                    ,
                                    cte_client_certs_xml as (
                                        select
                                            SOLRProviderID,
                                            CASE
                                                WHEN REGEXP_COUNT(certs, '<cSpnL><cSpn><spnCd>.*<cspc>', 1, 'i') > 0 then cte_certs.certs
                                            END as certs,
                                            REGEXP_COUNT(certs, '<cSpnL><cSpn><spnCd>.*<cspc>', 1, 'i') as CertsCount,
                                            row_number() over (
                                                partition by SOLRProviderID
                                                order by
                                                    REGEXP_COUNT(certs, '<cSpnL><cSpn><spnCd>.*<cspc>', 1, 'i') desc
                                            ) as DedupeRank
                                            
                                        from
                                            cte_certs
                                    )
                                    select * from cte_client_certs_xml
                                ) as CTE_CCX 
                                where CTE_ccx.solrproviderid = target.solrproviderid
                            and
                                CTE_ccx.deduperank = 1; $$;


-- this updates 0 rows 
update_statement_11 := $$ update show.solrprovider
                            SET DateOfBirth = null
                            where EXTRACT(YEAR from DateOfBirth) = 1900;$$;

--------- Step 4: spuSuppressSurveyFlag

-- fast but 0 rows
update_statement_12 := $$   update
                                show.solrprovider target
                            SET
                                SuppressSurvey = 1
                            from
                                base.providertospecialty as a
                                join base.specialty as b on b.specialtyid = a.specialtyid
                                join base.specialtygrouptospecialty c on c.specialtyid = a.specialtyid
                                join base.specialtygroup d on d.specialtygroupid = c.specialtygroupid
                            where target.providerid = a.providerid
                            and
                                d.specialtygroupcode IN ('NPHR', 'PNPH')
                                and ifnull(target.suppresssurvey, 0) = 0;$$;

-- fast but 0 rows
update_statement_13 := $$   update
                                show.solrprovider target
                            SET
                                SuppressSurvey = 0
                            from
                                show.solrproviderdelta src 
                            where src.providerid = target.providerid
                            and
                                target.suppresssurvey = 1;$$;
                                
-- fast but 0 rows
update_statement_14 := $$   update
                                show.solrprovider target
                            SET
                                SuppressSurvey = 1
                            from show.solrproviderdelta b , base.providersurveysuppression ps 
                            where
                            b.providerid = target.providerid and target.providerid = ps.providerid;$$;

-- fast but 0 rows
update_statement_15 := $$   update
                                show.solrprovider target
                            SET
                                SuppressSurvey = 1
                            from
                                show.solrproviderdelta b 
                                join (
                                    select
                                        distinct p.providerid
                                    from
                                        base.provider p
                                        join show.solrproviderdelta b on b.providerid = p.providerid
                                        join base.providertosubstatus ap on p.providerid = ap.providerid
                                        join base.substatus ss on ap.substatusid = ss.substatusid
                                    where
                                        ss.substatuscode IN ('B', 'L')
                                        and ap.hierarchyrank = 1
                                ) x 
                                where x.providerid = target.providerid
                                and b.providerid = target.providerid;$$;

-- updates 0 rows
update_statement_16 := $$   update
                                show.solrprovider target
                            SET
                                SuppressSurvey = 0 --select SuppressSurvey, *
                            from
                                mid.providersponsorship ps,
                                base.providertospecialty a 
                                join base.specialty b on b.specialtyid = a.specialtyid
                                join base.specialtygrouptospecialty c on c.specialtyid = a.specialtyid
                                join base.specialtygroup d on d.specialtygroupid = c.specialtygroupid
                            where
                                d.specialtygroupcode IN ('NPHR', 'PNPH')
                                and ps.clientcode <> 'Fresen'
                                and ps.providercode = target.providercode
                                and target.providerid = a.providerid
                                and target.suppresssurvey = 1; $$;
--------------------- 

-- deletes 0 rows
update_statement_17 := $$ 
                        delete from show.solrprovider
                        where ProviderCode IN (
                            select pr.providercode
                            from base.providerremoval pr
                            where show.solrprovider.ProviderCode = pr.providercode
                        ); 
                        $$;

-- updates 0 rows but only because we have 0 rows in delta for now
update_statement_18 :=  $$ 
                        update show.solrprovider
                        SET AcceptsNewPatients = 0
                        where ProviderID IN (
                            select b.providerid
                            from show.solrproviderdelta b
                            where show.solrprovider.ProviderID = b.providerid
                            and SubStatusCode IN ('C', 'Y', 'A')
                            and AcceptsNewPatients != 0
                        );
                        $$;

update_statement_19 := $$ 
                        merge into show.solrprovider as P using (
                            select ss.substatuscode, ds.displaystatuscode
                            from base.substatus as SS
                            join base.displaystatus as DS on ds.displaystatusid = ss.displaystatusid
                        ) as sub on p.substatuscode = sub.substatuscode
                        when matched and p.displaystatuscode != sub.displaystatuscode and p.displaystatuscode = 'H' then
                        update SET p.displaystatuscode = sub.displaystatuscode; 
                        $$;

-- We have somehow lost these Providers in the pipeline (they are in Base.Provider but not Show.SOLRProvider) 
update_statement_20 := $$ 
                        update show.solrprovider 
                        SET APIXML = TO_VARIANT(REPLACE(CAST(APIXML as varchar(16777216)), '</apiL>', '
                        <api>
                        <clientCd>OASTEST</clientCd>
                        <camCd>OASTEST_005</camCd>
                        </api>
                        </apiL>'))
                        where ProviderCode IN ('G92WN', 'yj754', 'XYLGDMH', '2p2v2', '2CJGY', 'XCWYN', 'E5B5Z', 'YJLPH')
                        and CAST(APIXML as varchar(16777216)) not LIKE '%OASTEST_005%'; 
                        $$;

------ Client Market Refresh

temp_table_statement_1 := $$ 
                          CREATE or REPLACE TEMPORARY TABLE temp_provider as (
                                select
                                    p.providerid,
                                    p.providerid as EDWBaseRecordID,
                                    0 as IsInClientMarket
                                from
                                    $$ || mdm_db || $$.mst.provider_profile_processing as ppp
                                    join base.provider as p on p.providercode = ppp.ref_PROVIDER_CODE
                          );
                          $$;



-- this thing is painfully slow, this is where it starts to break (possibly syntax errors)
update_statement_temp_1 := 'update
                                temp_provider target
                            set
                                IsInClientMarket = 1
                            from
                                base.providertooffice pto 
                                join base.officetoaddress ota on pto.officeid = ota.officeid
                                join base.address a on ota.addressid = a.addressid
                                join base.citystatepostalcode csz on a.citystatepostalcodeid = csz.citystatepostalcodeid
                                join base.geographicarea geo on (
                                    csz.city = geo.geographicareavalue1
                                    and csz.state = geo.geographicareavalue2
                                )
                                join mid.clientmarket cm on geo.geographicareacode = cm.geographicareacode,
                                base.providertospecialty pts  
                                join base.specialtygrouptospecialty sgs on pts.specialtyid = sgs.specialtyid,
                                base.specialtygroup sg
                            where
                                pts.issearchable = 1
                                and target.providerid = pto.providerid
                                and target.providerid = pts.providerid
                                and sgs.specialtygroupid = sg.specialtygroupid
                                and cm.lineofservicecode = sg.specialtygroupcode;';

                                
----------- update_statement_temp_1 (changed a few things). This is painfully slow,
--- for a full refresh in a medium wh the select takes ~6 min to run and 
--- for a sample delta of 10k providers it takes *40-50* seconds
update_statement_temp_1 := '
                            update temp_provider target
                            set IsInClientMarket = 1
                            from (
                                select pto.providerid
                                from base.providertooffice pto 
                                    join base.officetoaddress ota on pto.officeid = ota.officeid
                                    join base.address a on ota.addressid = a.addressid
                                    join base.citystatepostalcode csz on a.citystatepostalcodeid = csz.citystatepostalcodeid
                                    join base.geographicarea geo on (
                                        csz.city = geo.geographicareavalue1
                                        and csz.state = geo.geographicareavalue2
                                    )
                                    join mid.clientmarket cm on geo.geographicareacode = cm.geographicareacode
                                    join show.solrprovider p on pto.providerid = p.providerid
                                    join base.providertospecialty pts on pts.providerid = p.providerid
                                    join base.specialtygrouptospecialty sgs on pts.specialtyid = sgs.specialtyid
                                    join base.specialtygroup sg on sg.specialtygroupid = sgs.specialtygroupid
                                where
                                    pts.issearchable = 1
                                    and p.providerid = pto.providerid
                                    and p.providerid = pts.providerid
                                    and sgs.specialtygroupid = sg.specialtygroupid
                                    and cm.lineofservicecode = sg.specialtygroupcode
                            ) as source
                            where target.providerid = source.providerid;';

-- I deleted a duplicate update statement here that was a copy of update_statement_temp_1                              

-- one of the were conditions was causing the update to not do anything, changed it
update_statement_21 := 'update show.solrprovider target
                        set IsInClientMarket = temp.IsInClientMarket
                        from temp_provider temp
                        where temp.ProviderID = target.providerid;';


-- this updates 0 rows but this col comes straight from base.provider, don't worry for now
update_statement_22 := 'update show.solrprovider target
                        set AcceptsNewPatients =  1
                        from base.provider P 
                        where ifnull(target.acceptsnewpatients,0) != p.acceptsnewpatients
                            and p.providerid = target.providerid';


if_condition := $$ select
                        COUNT(1)
                    from
                        show.solrprovider P
                        left join (
                            select
                                distinct *
                            from(
                                    select
                                        ProviderId,
                                        ProviderCode,
                                        SponsorCode,
                                        get(
                                            xmlget(
                                                xmlget(
                                                    xmlget(
                                                        xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                        'dispL'
                                                    ),
                                                    'disp'
                                                ),
                                                'Type'
                                            ),
                                            '$'
                                        ) as DisplayType,
                                        get(
                                            xmlget(
                                                xmlget(
                                                    xmlget(
                                                        xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                        'dispL'
                                                    ),
                                                    'disp'
                                                ),
                                                'cd'
                                            ),
                                            '$'
                                        ) as PracticeCode,
                                        get(
                                            xmlget(
                                                xmlget(
                                                    xmlget(
                                                        xmlget(
                                                            xmlget(
                                                                xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                                'dispL'
                                                            ),
                                                            'disp'
                                                        ),
                                                        'offL'
                                                    ),
                                                    'off'
                                                ),
                                                'cd'
                                            ),
                                            '$'
                                        ) as OfficeCode,
                                        get(
                                            xmlget(
                                                xmlget(
                                                    xmlget(
                                                        xmlget(
                                                            xmlget(
                                                                xmlget(
                                                                    xmlget(
                                                                        xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                                        'dispL'
                                                                    ),
                                                                    'disp'
                                                                ),
                                                                'offL'
                                                            ),
                                                            'off'
                                                        ),
                                                        'phoneL'
                                                    ),
                                                    'phone'
                                                ),
                                                'ph'
                                            ),
                                            '$'
                                        ) as PhoneNumber,
                                        get(
                                            xmlget(
                                                xmlget(
                                                    xmlget(
                                                        xmlget(
                                                            xmlget(
                                                                xmlget(
                                                                    xmlget(
                                                                        xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                                        'dispL'
                                                                    ),
                                                                    'disp'
                                                                ),
                                                                'offL'
                                                            ),
                                                            'off'
                                                        ),
                                                        'phoneL'
                                                    ),
                                                    'phone'
                                                ),
                                                'phTyp'
                                            ),
                                            '$'
                                        ) as PhoneType,
                                    from
                                        show.solrprovider,
                                    where
                                        ProductCode = 'MAP'
                                )
                        ) X on x.providerid = p.providerid
                    where
                        ProductCode = 'MAP'
                        and PracticeOfficeXML is not null
                        and(
                            x.providerid is null
                            or LEN(PhoneNumber) = 0
                        )
                        and p.displaystatuscode != 'H'
                        and SponsorshipXML is not null 
                $$;


-- fast, but updates 0 rows in full
update_statement_23 := $$   update
                                show.solrprovider
                            SET
                                SponsorshipXML = null,
                                SearchSponsorshipXML = null
                            from
                                show.solrprovider as P
                                left join (
                                    select
                                        distinct *
                                    from(
                                            select
                                                ProviderId,
                                                ProviderCode,
                                                SponsorCode,
                                                get(
                                                    xmlget(
                                                        xmlget(
                                                            xmlget(
                                                                xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                                'dispL'
                                                            ),
                                                            'disp'
                                                        ),
                                                        'Type'
                                                    ),
                                                    '$'
                                                ) as DisplayType,
                                                get(
                                                    xmlget(
                                                        xmlget(
                                                            xmlget(
                                                                xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                                'dispL'
                                                            ),
                                                            'disp'
                                                        ),
                                                        'cd'
                                                    ),
                                                    '$'
                                                ) as PracticeCode,
                                                get(
                                                    xmlget(
                                                        xmlget(
                                                            xmlget(
                                                                xmlget(
                                                                    xmlget(
                                                                        xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                                        'dispL'
                                                                    ),
                                                                    'disp'
                                                                ),
                                                                'offL'
                                                            ),
                                                            'off'
                                                        ),
                                                        'cd'
                                                    ),
                                                    '$'
                                                ) as OfficeCode,
                                                get(
                                                    xmlget(
                                                        xmlget(
                                                            xmlget(
                                                                xmlget(
                                                                    xmlget(
                                                                        xmlget(
                                                                            xmlget(
                                                                                xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                                                'dispL'
                                                                            ),
                                                                            'disp'
                                                                        ),
                                                                        'offL'
                                                                    ),
                                                                    'off'
                                                                ),
                                                                'phoneL'
                                                            ),
                                                            'phone'
                                                        ),
                                                        'ph'
                                                    ),
                                                    '$'
                                                ) as PhoneNumber,
                                                get(
                                                    xmlget(
                                                        xmlget(
                                                            xmlget(
                                                                xmlget(
                                                                    xmlget(
                                                                        xmlget(
                                                                            xmlget(
                                                                                xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                                                'dispL'
                                                                            ),
                                                                            'disp'
                                                                        ),
                                                                        'offL'
                                                                    ),
                                                                    'off'
                                                                ),
                                                                'phoneL'
                                                            ),
                                                            'phone'
                                                        ),
                                                        'phTyp'
                                                    ),
                                                    '$'
                                                ) as PhoneType,
                                            from
                                                show.solrprovider,
                                            where
                                                ProductCode = 'MAP'
                                        )
                                ) as x on x.providerid = p.providerid
                            where
                                p.productcode = 'MAP'
                                and p.practiceofficexml is not null
                                and(
                                    x.providerid is null
                                    or LEN(PhoneNumber) = 0
                                )
                                and p.displaystatuscode != 'H'
                                and p.sponsorshipxml is not null; $$;
                                
-- fast, updates 0 rows
update_statement_24 :=  $$
                        update show.solrprovider 
                		SET DisplayStatusCode = 'A'
                		where DisplayStatusCode = 'H' and SubStatusCode = '1'
                        $$;

-----------------------------------------------------------------
--------------------------- XML LOAD ----------------------------
-----------------------------------------------------------------

select_statement_xml_load_1 := $$ 
------------------------AvailabilityXML------------------------

with cte_appointment_availability as (
    SELECT DISTINCT
        poaa.ProviderID,
        aa.AppointmentAvailabilityCode AS aptCd,
        aa.AppointmentAvailabilityDescription AS aptD
    FROM
        Base.ProviderToAppointmentAvailability poaa
        JOIN Base.AppointmentAvailability aa ON aa.AppointmentAvailabilityID = poaa.AppointmentAvailabilityID
),
cte_availability_xml as (
    SELECT
        ProviderID,
        '<aptL>' || listagg( '<apt>' || iff(aptCd is not null,'<aptCd>' || aptCd || '</aptCd>','') ||
        iff(aptD is not null,'<aptD>' || aptD || '</aptD>','') || '</apt>' , '') || '</aptL>' AS XMLValue
    FROM
        cte_appointment_availability
    GROUP BY
        ProviderID
),

-----------------------ProcedureHierarchyXML--------------------
CTE_ProviderProceduresq AS (
    SELECT
        a.ProviderID,
        a.ProcedureCode,
        0 AS IsMapped
    FROM
        Mid.ProviderProcedure a
        INNER JOIN Show.SolrProvider pr ON a.ProviderID = pr.ProviderId
    UNION ALL
    SELECT
        a.ProviderID,
        mt.MedicalTermCode AS ProcedureCode,
        1 AS IsMapped
    FROM
        Base.ProviderToSpecialty a
        INNER JOIN Base.Specialty b ON b.SpecialtyID = a.SpecialtyID
        INNER JOIN Base.SpecialtyToProcedureMedical spm ON b.SpecialtyID = spm.SpecialtyID
        INNER JOIN Base.MedicalTerm mt ON mt.MedicalTermID = spm.ProcedureMedicalID
        INNER JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID
            AND mtt.MedicalTermTypeCode = 'Procedure'
        INNER JOIN Show.SolrProvider pr ON a.ProviderID = pr.ProviderId
    WHERE
        a.SpecialtyIsRedundant = 0
        AND a.IsSearchableCalculated = 1
),

CTE_ProviderProcedureXMLLoads AS (
    SELECT
        ProviderID,
        ProcedureCode,
        IsMapped
    FROM
        CTE_ProviderProceduresq
),
cte_procedure_hierarchy as (
    SELECT DISTINCT
        pp.ProviderID,
        dcp.MedicalInt AS prC,
        dcp.parentHier AS pHier,
        dcp.childHier AS cHier,
        dcp.parentSelfHier AS pSelfHier,
        dcp.parentByTwosHier AS pTwoHier,
        dcp.parentSelfByTwosHier AS pSelfTwoHier,
        dcp.ParentNameCodesAlpha AS pNmCdAlpha,
        dcp.ParentNameCodesInitials AS pNmCdInitial,
        pp.IsMapped AS isMap
    FROM
        CTE_ProviderProcedureXMLLoads pp -- temp schema before
        JOIN base.DCPHierarchy dcp ON dcp.MedicalInt = pp.ProcedureCode AND dcp.medicaltype = 'Procedure' -- dbo schema before
),

cte_procedure_hierarchy_xml as (
    SELECT
        ProviderID,
        '<prHierL>' || listagg('<prHier>'|| iff(prC is not null,'<prC>' || prC || '</prC>','') ||
        iff(pHier is not null,'<pHier>' || pHier || '</pHier>','') ||
        iff(cHier is not null,'<cHier>' || cHier || '</cHier>','') ||
        iff(pSelfHier is not null,'<pSelfHier>' || pSelfHier || '</pSelfHier>','') ||
        iff(pTwoHier is not null,'<pTwoHier>' || pTwoHier || '</pTwoHier>','') ||
        iff(pSelfTwoHier is not null,'<pSelfTwoHier>' || pSelfTwoHier || '</pSelfTwoHier>','') ||
        iff(pNmCdAlpha is not null,'<pNmCdAlpha>' || pNmCdAlpha || '</pNmCdAlpha>','') ||
        iff(pNmCdInitial is not null,'<pNmCdInitial>' || pNmCdInitial || '</pNmCdInitial>','') ||
        iff(isMap is not null,'<isMap>' || isMap || '</isMap>','') || '</prHier>' , '' ) || '</prHierL>'
 AS XMLValue
    FROM
        cte_procedure_hierarchy
    GROUP BY
        ProviderID
),


--------------------------ProcMappedXML--------------------------

cte_proc_mapped as (
    SELECT DISTINCT
        sp.ProviderID,
        mt.MedicalTermCode AS prC,
        s.SpecialtyCode || '/' || mt.MedicalTermDescription1 || '|' || mt.MedicalTermCode AS prcN
    FROM
        Base.SpecialtyToProcedureMedical stpm
        JOIN Base.MedicalTerm mt ON mt.MedicalTermID = stpm.ProcedureMedicalID
        JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID AND mtt.MedicalTermTypeCode = 'Procedure'
        JOIN Base.Specialty s ON stpm.SpecialtyID = s.SpecialtyID
        JOIN Base.ProviderToSpecialty pts ON pts.SpecialtyID = stpm.SpecialtyID
        JOIN Show.SolrProvider as sp on sp.providerid = pts.providerid
    WHERE 
        pts.SpecialtyIsRedundant = 0
        AND pts.IsSearchableCalculated = 1
),

cte_proc_mapped_xml as (
    SELECT
        ProviderID,
        '<prL>' || listagg( '<pr>' || iff(prC is not null,'<prC>' || prC || '</prC>','') ||
        iff(prcN is not null,'<prcN>' || prcN || '</prcN>','') || '</pr>' , '') || '</prL>'  AS XMLValue
    FROM
        cte_proc_mapped
    GROUP BY
        ProviderID
),

--------------------------PracSpecHeirXML--------------------------

-- Define the CTE for extracting and transforming specialty data
cte_specialty_hierarchy as (
    SELECT
        p.providerid,
        spec.SpecialtyCode AS spCd,
        spec.SpecialtyCode || '/' || TRIM(spec.SpecialtyDescription) || '|' || spec.specialtycode AS prSpHeirBar
    FROM
        Base.SpecialtyGroup sgr
        JOIN Base.SpecialtyGroupToSpecialty sgs ON sgr.SpecialtyGroupID = sgs.SpecialtyGroupID
        JOIN Base.Specialty spec ON spec.SpecialtyID = sgs.SpecialtyID AND sgr.SpecialtyGroupDescription = spec.SpecialtyDescription
        JOIN base.providertospecialty as p on p.specialtyid = spec.specialtyid 
),

cte_prac_spec_hier_xml as (
    SELECT
        providerid,
        '<prSpHeirL>' || listagg('<prSpHeir>' || iff(spCd is not null,'<spCd>' || spCd || '</spCd>','') ||
iff(prSpHeirBar is not null,'<prSpHeirBar>' || prSpHeirBar || '</prSpHeirBar>','') || '</prSpHeir>', '') || '</prSpHeirL>' as xmlvalue
    FROM
        cte_specialty_hierarchy
    GROUP BY
        providerid
),

--------------------------OASXML--------------------------	
cte_oas_partner AS (
    SELECT DISTINCT 
        ProviderId, 
        P.OASPartnerCode
    FROM Base.ProviderToClientToOASPartner O 
        INNER JOIN Base.OASPartner P ON P.OASPartnerId = O.OASPartnerId
),
cte_TempPartnerEntity AS (
    SELECT DISTINCT 
        pte.primaryentityid as providerid,
        pte.PartnerCode,
        pte.PartnerDescription,
        pte.PartnerTypeCode,
        pte.PartnerPrimaryEntityID,
        pte.OfficeCode,
        pte.PartnerSecondaryEntityID,
        pte.PartnerTertiaryEntityID,
        pte.FullURL,
        pte.PrimaryEntityID,
        pte.PartnerId,
        O.OASPartnerCode,
        pte.ExternalOASPartnerDescription
    FROM mid.PartnerEntity pte
    INNER JOIN Show.SolrProvider P ON P.ProviderId = pte.PrimaryEntityID
    LEFT JOIN cte_oas_partner O ON O.ProviderId = P.ProviderID
),

Cte_Oas as (
    SELECT DISTINCT 
        pte.PrimaryEntityId AS Providerid,
        pte.OASPartnerCode,
        pte.PartnerCode AS partCd,
        pte.PartnerDescription AS partDesc,
        pte.PartnerTypeCode AS partTyCd,
        pte.PartnerPrimaryEntityID AS partProvId,
        pte.OfficeCode AS offCd,
        pte.PartnerSecondaryEntityID AS partOffId,
        pte.PartnerTertiaryEntityID AS partPracId,
        pte.FullURL,
        pte.ExternalOASPartnerDescription AS ExternalOASPartner
        -- configL (always empty)
    FROM
        cte_TempPartnerEntity pte 
),

Cte_Oas_xml as (
    SELECT
        ProviderID, 
        replace('<oasL>' || listagg('<oas>' || 
        iff(OASPartnerCode is not null,'<OASPartnerCode>' || OASPartnerCode || '</OASPartnerCode>','') ||
        iff(partCd is not null,'<partCd>' || partCd || '</partCd>','') ||
        iff(partDesc is not null,'<partDesc>' || partDesc || '</partDesc>','') ||
        iff(partTyCd is not null,'<partTyCd>' || partTyCd || '</partTyCd>','') ||
        iff(partProvId is not null,'<partProvId>' || partProvId || '</partProvId>','') ||
        iff(offCd is not null,'<offCd>' || offCd || '</offCd>','') ||
        iff(partOffId is not null,'<partOffId>' || partOffId || '</partOffId>','') ||
        iff(partPracId is not null,'<partPracId>' || partPracId || '</partPracId>','') ||
        iff(FullURL is not null,'<FullURL>' || FullURL || '</FullURL>','') ||
        iff(ExternalOASPartner is not null,'<ExternalOASPartner>' || ExternalOASPartner || '</ExternalOASPartner>','') || 
        '</oas>', '') || '</oasL>', '&', '&amp;') AS XMLValue
    FROM
        cte_oas
    GROUP BY
        ProviderID 
),

------------------------DEAXML------------------------

cte_dea_identification as (
    SELECT DISTINCT
        ppi.ProviderID,
        ppi.IdentificationValue AS deaN,
        ppi.EffectiveDate AS deaEfDt,
        ppi.ExpirationDate AS deaExDt
    FROM
        Base.ProviderIdentification ppi
        JOIN Base.IdentificationType it ON it.IdentificationTypeID = ppi.IdentificationTypeID
    WHERE 
        it.IdentificationTypeCode = 'DEA'
),

cte_dea_xml as (
    SELECT
        ProviderID,
        '<deaL>' || listagg('<dea>' || 
        iff(deaN is not null,'<deaN>' || deaN || '</deaN>','') ||
        iff(deaEfDt is not null,'<deaEfDt>' || deaEfDt || '</deaEfDt>','') ||
        iff(deaExDt is not null,'<deaExDt>' || deaExDt || '</deaExDt>','') || 
        '</dea>', '') || '</deaL>'
 AS XMLValue
    FROM
        cte_dea_identification
    GROUP BY
        ProviderID
),

------------------------EmailAddressXML------------------------

cte_provider_email as (
    SELECT DISTINCT
        ProviderID,
        EmailAddress AS eAdd,
        EmailRank AS eRank
    FROM
        Base.ProviderEmail 
),

cte_email_address_xml as (
    SELECT
        ProviderID,
        '<eaL>' || listagg('<ea>' || 
        iff(eAdd is not null,'<eAdd>' || eAdd || '</eAdd>','') ||
        iff(eRank is not null,'<eRank>' || eRank || '</eRank>','') || 
        '</ea>', '') || '</eaL>' 
 AS XMLValue
    FROM
        cte_provider_email
    GROUP BY
        ProviderID
),

------------------------DegreeXML------------------------

cte_degree as (
    SELECT DISTINCT
        ptd.ProviderID,
        d.DegreeAbbreviation AS degA,
        d.DegreeDescription AS degD,
        ptd.DegreePriority AS rank,
        TO_DATE(ptd.LastUpdateDate) AS updDte
    FROM
        Base.Degree d
        JOIN Base.ProviderToDegree ptd ON d.DegreeID = ptd.DegreeID
),

cte_degree_xml as (
    SELECT
        ProviderID,
        '<degL>' || listagg('<deg>' || 
        iff(degA is not null,'<degA>' || degA || '</degA>','') ||
        iff(degD is not null,'<degD>' || degD || '</degD>','') ||
        iff(rank is not null,'<rank>' || rank || '</rank>','') ||
        iff(TO_CHAR(updDte, 'YYYY-MM-DD') is not null,'<updDte>' || TO_CHAR(updDte, 'YYYY-MM-DD') || '</updDte>','') || 
        '</deg>', '') || '</degL>'
 AS XMLValue
    FROM
        cte_degree
    GROUP BY
        ProviderID
),

------------------------SurveyXML------------------------

cte_survey as (
    SELECT DISTINCT
        dP.ProviderID,
        sqa.SurveyQuestion AS qstn,
        sqa.SurveyQuestionGroupDescription AS qGrp,
        psqrm.SurveyAnswer AS ansId,
        ps.QuestionID AS qId,
        ps.QuestionSort AS qSrt,
        0 AS qDSrt, -- Originally ps.QuestionDisplaySort
        ps.ProviderAverageScore AS pScr,
        ps.QuestionCount AS qCnt,
        ps.NationalAverageScore AS nScr,
        (ps.ProviderAverageScore / 5) * 100 AS pScrPct,
        ROUND((((ps.ProviderAverageScore / 5) * 100) / 5), 0) * 5 AS pScrPctRnd,
        (ps.NationalAverageScore / 5) * 100 AS nScrPct,
        ROUND((((ps.NationalAverageScore / 5) * 100) / 5), 0) * 5 AS nScrPctRnd,
        ps.PositiveResponse AS nPosScr,
        ps.NegativeResponse AS nNegScr,
        psqrm.SurveyAnswerText AS range,
        nsqrm.SurveyAnswerText || ' National Average' AS nRange,
        IFF(psqrm.SurveyScore < nsqrm.SurveyScore AND psqrm.SurveyQuestionCode = '226', 'longer than national average',
            IFF(psqrm.SurveyScore > nsqrm.SurveyScore AND psqrm.SurveyQuestionCode = '226', 'shorter than national average',
                IFF(psqrm.SurveyScore = nsqrm.SurveyScore AND psqrm.SurveyQuestionCode = '226', 'same as national average',
                    IFF(psqrm.SurveyScore < nsqrm.SurveyScore, 'below national average',
                        IFF(psqrm.SurveyScore > nsqrm.SurveyScore, 'above national average',
                            IFF(psqrm.SurveyScore = nsqrm.SurveyScore, 'same as national average',
                                IFF(ps.ProviderAverageScore < ps.NationalAverageScore, 'below national average',
                                    IFF(ps.ProviderAverageScore > ps.NationalAverageScore, 'above national average',
                                        IFF(ps.ProviderAverageScore = ps.NationalAverageScore, 'same as national average', '')
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ) AS nScrCompr
    FROM
        Base.ProviderSurveyAggregate ps
        INNER JOIN base.Provider dP ON dP.ProviderCode = ps.ProviderCode
        INNER JOIN Show.SOLRProviderSurveyQuestionAndAnswer sqa ON ps.QuestionID = sqa.SurveyQuestionCode AND sqa.SurveyTempletVersion IS NULL
        LEFT JOIN Mid.SurveyQuestionRangeMapping psqrm ON ps.QuestionID = psqrm.SurveyQuestionCode AND ROUND(ps.ProviderAverageScore,0) = psqrm.SurveyScore
        LEFT JOIN Mid.SurveyQuestionRangeMapping nsqrm ON ps.QuestionID = nsqrm.SurveyQuestionCode AND ROUND(ps.NationalAverageScore,0) = nsqrm.SurveyScore
),

cte_survey_xml as (
    SELECT
        ProviderID,
        '<svyL>' || listagg('<svy>' || 
        iff(qstn is not null,'<qstn>' || qstn || '</qstn>','') ||
        iff(qGrp is not null,'<qGrp>' || qGrp || '</qGrp>','') ||
        iff(ansId is not null,'<ansId>' || ansId || '</ansId>','') ||
        iff(qId is not null,'<qId>' || qId || '</qId>','') ||
        iff(qSrt is not null,'<qSrt>' || qSrt || '</qSrt>','') ||
        iff(pScr is not null,'<pScr>' || pScr || '</pScr>','') ||
        iff(qCnt is not null,'<qCnt>' || qCnt || '</qCnt>','') ||
        iff(nScr is not null,'<nScr>' || nScr || '</nScr>','') ||
        iff(pScrPct is not null,'<pScrPct>' || pScrPct || '</pScrPct>','') ||
        iff(pScrPctRnd is not null,'<pScrPctRnd>' || pScrPctRnd || '</pScrPctRnd>','') ||
        iff(nScrPct is not null,'<nScrPct>' || nScrPct || '</nScrPct>','') ||
        iff(nScrPctRnd is not null,'<nScrPctRnd>' || nScrPctRnd || '</nScrPctRnd>','') ||
        iff(nPosScr is not null,'<nPosScr>' || nPosScr || '</nPosScr>','') ||
        iff(nNegScr is not null,'<nNegScr>' || nNegScr || '</nNegScr>','') ||
        iff(range is not null,'<range>' || range || '</range>','') ||
        iff(nRange is not null,'<nRange>' || nRange || '</nRange>','') ||
        iff(nScrCompr is not null,'<nScrCompr>' || nScrCompr || '</nScrCompr>','') || 
        '</svy>', '') || '</svyL>'
 AS XMLValue
    FROM
        cte_survey
    GROUP BY
        ProviderID
),

------------------------ClinicalFocusDCPXML------------------------

Cte_medical_procedure as (
    select distinct 
    m.entityid as providerid,
    m.medicaltermid 
from base.entitytomedicalterm m 
    qualify row_number() over(partition by entityid order by m.lastupdatedate desc ) = 1
),

cte_clinical as 
    (select 
        c.medicaltermid,
        c.refMedicalTermCode AS MTCode,
        c.NationalRankingB AS NRankB,
        c.ClinicalFocusShortDescription as ClFdesc
    from base.ClinicalFocusDCP as c
    qualify row_number() over(partition by medicaltermid order by providerid) = 1
),
cte_mtcode as (
select distinct
    m.providerid,
    c.MTCode,
    c.NRankB,
    c.ClFdesc
from cte_clinical c 
    join cte_medical_procedure m on c.medicaltermid = m.medicaltermid
),
cte_mtcode_xml as (
    SELECT
        providerid,
        listagg('<MTCode>' || 
        iff(MTCode is not null,'<MTCode>' || MTCode || '</MTCode>','') ||
        iff(NRankB is not null,'<NRankB>' || NRankB || '</NRankB>','') || 
        '</MTCode>', '') 
 AS XMLValue
    FROM
        cte_mtcode
    GROUP BY
        providerid
) ,

cte_clinical_focus_dcp as (
    SELECT
        c.providerid,
        C.CLFdesc,
        cte.xmlvalue as mtcode
    FROM
        cte_mtcode as C
        JOIN cte_mtcode_xml cte ON cte.providerid = C.providerid
) ,

cte_clinical_focus_dcp_xml as (
    SELECT
        providerid,
        '<CLFdescL>' || listagg('<CLFdesc>' || 
        iff(CLFdesc is not null,'<CLFdesc>' || CLFdesc || '</CLFdesc>','') || 
        iff(mtcode is not null, '<MTCodeL>' || mtcode || '</MTCodeL>' , '') ||
        '</CLFdesc>', '') || '</CLFdescL>'
 AS XMLValue
    FROM
        cte_clinical_focus_dcp
    GROUP BY
        providerid
),

------------------------CLinicalFocusXML------------------------

cte_from_clinical_focus as (
SELECT DISTINCT 
    C.ProviderID, 
    dCF.ClinicalFocusId, 
    dCF.ClinicalFocusDescription
FROM Base.ProviderToClinicalFocus C
    INNER JOIN	Base.ClinicalFocus dCF ON dCF.ClinicalFocusID = C.ClinicalFocusID
),

cte_specialty_codes as (
    SELECT
        cfs.ClinicalFocusID,
        '|' || s.SpecialtyCode AS SpecialtyCode
    FROM
        Base.ClinicalFocusToSpecialty cfs
        INNER JOIN Base.Specialty s ON s.SpecialtyID = cfs.SpecialtyID
),

cte_concatenated_specialty_codes as (
    SELECT
        ClinicalFocusID,
        LISTAGG(SpecialtyCode, '') WITHIN GROUP (ORDER BY SpecialtyCode) AS CLFSpecId
    FROM
        cte_specialty_codes
    GROUP BY
        ClinicalFocusID
),

cte_specialty_codes_xml as (
    SELECT
        ClinicalFocusID,
        listagg(iff(CLFSpecId is not null,'<CLFSpecId>' || CLFSpecId || '</CLFSpecId>',''), '' )
 AS XMLValue
    FROM
        cte_concatenated_specialty_codes
    GROUP BY
        ClinicalFocusId
),

cte_mtcode2 as (
    SELECT
        ProviderId,
        ProviderDCPCount AS PDCP,
        CAST(AverageBPercentile AS INT) AS AvgP,
        ProviderDCPFillPercent AS CFProvFill,
        IsProviderDCPCountOverLowThreshold AS DCPThresh,
        ClinicalFocusScore AS CFScore,
        ProviderClinicalFocusRank AS CFRank
    FROM
        Base.ProviderToClinicalFocus 
),

cte_mtcode_xml as (
    SELECT
        ProviderId,
        '<MTCodeL>' || listagg('<MTCode>' || 
        iff(PDCP is not null,'<pdcp>' || PDCP || '</pdcp>','') ||
        iff(avgp is not null,'<avgp>' || avgp || '</avgp>','') ||
        iff(CFProvFill is not null,'<cfprovfill>' || CFProvFill || '</cfprovfill>','') ||
        iff(DCPThresh is not null,'<dcpthresh>' || DCPThresh || '</dcpthresh>','') ||
        iff(CFScore is not null,'<cfscore>' || CFScore || '</cfscore>','') ||
        iff(CFRank is not null,'<cfrank>' || CFRank || '</cfrank>','') || 
        '</MTCode>', '') || '</MTCodeL>'
 AS XMLValue
    FROM
        cte_mtcode2
    GROUP BY
        ProviderId
),

cte_clinical_focus as (
SELECT		
    C.ProviderId,
    C.ClinicalFocusId AS CLFId,
	C.ClinicalFocusDescription AS CLFDesc,
    code.xmlvalue as clfspecid,
    mt.xmlvalue as mtcode
FROM Cte_from_clinical_focus as c
    JOIN cte_specialty_codes_xml as code on code.clinicalfocusid = c.clinicalfocusid
    JOIN cte_mtcode_xml as mt on mt.providerid = c.providerid
),

cte_clinical_focus_xml as (
SELECT
        providerid,
        '<CLFIdL>' || listagg('<CLF>' || 
        iff(clfId is not null,'<clfId>' || clfId || '</clfId>','') ||
        iff(clfDesc is not null,'<clfDesc>' || clfDesc || '</clfDesc>','') ||
        iff(clfspecid is not null,'<clfspecid>' || clfspecid || '</clfspecid>','') || 
        '</CLF>', '') || '</CLFIdL>'
 AS XMLValue
    FROM
        cte_clinical_focus
    GROUP BY
        providerid
) ,

------------------------TrainingXML------------------------

cte_training as (
    SELECT
        trn.ProviderID,
        t.TrainingCode AS trCd,
        t.TrainingDescription AS trD,
        trn.TrainingLink AS trUrl
    FROM
        Base.ProviderTraining trn
        INNER JOIN Base.Training t ON trn.TrainingID = t.TrainingID
    WHERE
        t.IsActive = 1
),

cte_training_xml as (
    SELECT
        ProviderID,
        '<trL>' || listagg('<tr>' || 
        iff(trCd is not null,'<trCd>' || trCd || '</trCd>','') ||
        iff(trD is not null,'<trD>' || trD || '</trD>','') ||
        iff(trUrl is not null,'<trUrl>' || trUrl || '</trUrl>','') || 
        '</tr>', '') || '</trL>' 
 AS XMLValue
    FROM
        cte_training
    GROUP BY
        ProviderID
),

------------------------LastUpdateDateXML------------------------
cte_last_update_date_xml as (
SELECT
    p.ProviderId,
    lu.LastUpdateDatePayload as XMLValue
FROM Show.SolrProvider as p
    JOIN Base.ProviderLastUpdateDate as lu on p.providerid = lu.providerid
),

------------------------SmartReferralXML------------------------

CTE_ClientImages AS (
SELECT DISTINCT 
    fd.ClientToProductID, 
    fd.ImageFilePath as Logo
FROM Base.vwuPDCClientDetail fd 
WHERE fd.ImageFilePath IS NOT NULL
),

CTE_Smart_Referral AS (
SELECT 	   
    p.ProviderID, 
    c.ClientCode as srCli, 
    ci.Logo as srLogo
FROM Show.SolrProvider as p   
    INNER JOIN Base.Provider p2 ON p2.ProviderID = p.ProviderID
    INNER JOIN Base.Client c ON c.ClientID = p2.SmartReferralClientID -- this is empty now in base.provider as it does not come in the new json, so this join will return empty for now
    INNER JOIN Base.ClientToProduct cp  ON cp.ClientID = c.ClientID
    LEFT JOIN  CTE_ClientImages ci ON ci.ClientToProductID = cp.ClientToProductID
QUALIFY ROW_NUMBER() OVER (PARTITION BY p.ProviderID ORDER BY CASE WHEN ci.logo IS NOT NULL THEN 0 ELSE 1 END) = 1
),

cte_smart_referral_xml as (
    SELECT
        ProviderID,
        '<srL>' || listagg('<sr>' || 
        iff(srCli is not null,'<srCli>' || srCli || '</srCli>','') ||
        iff(srLogo is not null,'<srLogo>' || srLogo || '</srLogo>','') || 
        '</sr>', '') || '</srL>'
 AS XMLValue
    FROM
        cte_smart_referral
    GROUP BY
        ProviderID
)


SELECT
    p.providerid,
    to_variant(parse_xml( avail.xmlvalue)) as availabilityxml,
    to_variant(parse_xml (proch.xmlvalue)) as procedurehierarchyxml,
    to_variant( parse_xml(procm.xmlvalue)) as procmappedxml,
    to_variant( parse_xml(pspec.xmlvalue)) as pracspecheirxml,
    to_variant( parse_xml(oas.xmlvalue)) as oasxml,
    to_variant( parse_xml(dea.xmlvalue)) as deaxml,
    to_variant( parse_xml(emad.xmlvalue)) as emailaddressxml,
    to_variant( parse_xml(degree.xmlvalue)) as degreexml,
    to_variant( parse_xml(survey.xmlvalue)) as surveyxml,
    to_variant( parse_xml(cfdcp.xmlvalue)) as clinicalfocusdcpxml, 
    to_variant( parse_xml(cfoc.xmlvalue)) as clinicalfocusxml,
    to_variant( parse_xml(train.xmlvalue)) as trainingxml,
    to_variant( parse_xml(ldate.xmlvalue)) as lastupdatedatexml,
    smref.srcli as smartreferralclientcode,
    to_variant( parse_xml(smart.xmlvalue)) as smartreferralxml,
    CASE WHEN survey.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasSurveyXML,
    CASE WHEN dea.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasDEAXML,
    CASE WHEN emad.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasEmailAddressXML
FROM Show.SolrProvider as P
    LEFT JOIN cte_availability_xml AS avail ON avail.providerid = p.providerid
    LEFT JOIN cte_procedure_hierarchy_xml  AS proch ON proch.providerid = p.providerid
    LEFT JOIN cte_proc_mapped_xml AS procm ON procm.providerid = p.providerid
    LEFT JOIN cte_prac_spec_hier_xml AS pspec ON pspec.providerid = p.providerid
    LEFT JOIN cte_oas_xml  AS oas ON oas.providerid = p.providerid -- really fast
    LEFT JOIN cte_dea_xml AS dea ON dea.providerid = p.providerid -- fast
    LEFT JOIN cte_email_address_xml AS emad ON emad.providerid = p.providerid --fast
    LEFT JOIN cte_degree_xml  AS degree ON degree.providerid = p.providerid --fast
    LEFT JOIN cte_survey_xml  AS survey ON survey.providerid = p.providerid
    LEFT JOIN cte_clinical_focus_dcp_xml AS cfdcp ON cfdcp.providerid = p.providerid
    LEFT JOIN cte_clinical_focus_xml  AS cfoc ON cfoc.providerid = p.providerid
    LEFT JOIN cte_training_xml  AS train ON train.providerid = p.providerid --fast
    LEFT JOIN cte_last_update_date_xml AS ldate ON ldate.providerid = p.providerid
    LEFT JOIN CTE_Smart_Referral  AS smref ON smref.providerid = p.providerid
    LEFT JOIN cte_smart_referral_xml  AS smart ON smart.providerid = p.providerid $$;


select_statement_xml_load_2 := 
$$ 

WITH CTE_Provider_Batch AS (
    SELECT ProviderID
    FROM mdm_team.mst.provider_profile_processing ppp
    INNER JOIN base.provider bp ON ppp.ref_provider_code = bp.providercode
),

------------------------ProviderProcedureXMLLoads------------------------
CTE_ProviderProceduresq AS (
    SELECT
        a.ProviderID,
        a.ProcedureCode,
        0 AS IsMapped
    FROM
        Mid.ProviderProcedure a
        INNER JOIN CTE_Provider_Batch pr ON a.ProviderID = pr.ProviderId
    UNION ALL
    SELECT
        a.ProviderID,
        mt.MedicalTermCode AS ProcedureCode,
        1 AS IsMapped
    FROM
        Base.ProviderToSpecialty a
        INNER JOIN Base.Specialty b ON b.SpecialtyID = a.SpecialtyID
        INNER JOIN Base.SpecialtyToProcedureMedical spm ON b.SpecialtyID = spm.SpecialtyID
        INNER JOIN Base.MedicalTerm mt ON mt.MedicalTermID = spm.ProcedureMedicalID
        INNER JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID
            AND mtt.MedicalTermTypeCode = 'Procedure'
        INNER JOIN CTE_Provider_Batch pr ON a.ProviderID = pr.ProviderId
    WHERE
        a.SpecialtyIsRedundant = 0
        AND a.IsSearchableCalculated = 1
),

CTE_ProviderProcedureXMLLoads AS (
    SELECT
        ProviderID,
        ProcedureCode,
        IsMapped
    FROM
        CTE_ProviderProceduresq
),
------------------------ProviderConditionXMLLoads------------------------
CTE_ProviderConditionsq AS (
    SELECT
        a.ProviderID,
        a.ConditionCode,
        0 AS IsMapped
    FROM
        Mid.ProviderCondition a
        INNER JOIN CTE_Provider_Batch pr ON a.ProviderID = pr.ProviderId
    UNION ALL
    SELECT
        a.ProviderID,
        mt.MedicalTermCode AS ConditionCode,
        1 AS IsMapped
    FROM
        Base.ProviderToSpecialty a
        INNER JOIN Base.Specialty b ON b.SpecialtyID = a.SpecialtyID
        INNER JOIN Base.SpecialtyToCondition spm ON b.SpecialtyID = spm.SpecialtyID
        INNER JOIN Base.MedicalTerm mt ON mt.MedicalTermID = spm.ConditionID
        INNER JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID
            AND mtt.MedicalTermTypeCode = 'Condition'
        INNER JOIN CTE_Provider_Batch pr ON a.ProviderID = pr.ProviderId
    WHERE
        a.SpecialtyIsRedundant = 0
        AND a.IsSearchableCalculated = 1
),

CTE_ProviderConditionXMLLoads AS (
    SELECT
        ProviderID,
        ConditionCode,
        IsMapped
    FROM
        CTE_ProviderConditionsq
),

-----------------------------TeleHealthXML-----------------------------
---- validated: ~700k XMLs in SQL Server and here (not null)
CTE_Services AS (
    SELECT DISTINCT 
        PTM.ProviderId,
        MT.MethodTypeCode AS type,
        M.TelehealthMethod AS method,
        M.ServiceName AS servicename
    FROM Base.ProviderToTelehealthMethod PTM
    INNER JOIN Base.TelehealthMethod M ON M.TelehealthMethodId = PTM.TelehealthMethodId
    INNER JOIN Base.TelehealthMethodType MT ON MT.TelehealthMethodTypeId = M.TelehealthMethodTypeId
    WHERE MT.MethodTypeCode IN ('URL', 'PHONE')
),

CTE_ServicesXML AS (
    SELECT 
        ProviderId,
        LISTAGG(
            '<service>' ||
            '<type>' || type || '</type>' ||
            '<method>' || method || '</method>' ||
            '<servicename>' || servicename || '</servicename>' ||
            '</service>'
        ) AS service_xml
    FROM CTE_Services
    GROUP BY ProviderId
),

CTE_TelehealthXML AS (
    SELECT 
        T.ProviderId,
        CASE 
            WHEN P.ProviderId IS NOT NULL THEN
                to_variant(parse_xml('<Telehealth>' ||
                '<hasTelehealth>true</hasTelehealth>' ||
                '<_serviceL>' ||
                '<serviceL>' || COALESCE(S.service_xml, '') || '</serviceL>' ||
                '</_serviceL>' ||
                '</Telehealth>'))
            ELSE NULL
        END AS XMLValue
    FROM CTE_Provider_Batch T
    INNER JOIN (SELECT DISTINCT ProviderId FROM Base.ProviderToTelehealthMethod) P 
        ON P.ProviderId = T.ProviderId
    LEFT JOIN CTE_ServicesXML S ON S.ProviderId = T.ProviderId
),

------------------------ProviderTypeXML------------------------
---- validated: all ~6.5M providers should have this xml 
CTE_ProviderType AS (
    SELECT
        bptpt.ProviderID,
        bpt.ProviderTypeCode AS ptCd,
        bpt.ProviderTypeDescription AS ptD,
        bptpt.ProviderTypeRank AS ptRank
    FROM
        Base.ProviderToProviderType bptpt
        INNER JOIN Base.ProviderType bpt ON bptpt.ProviderTypeID = bpt.ProviderTypeID
    WHERE
        ProviderTypeRank = CASE
            WHEN ProviderTypeCode = 'ALT' THEN 1
            ELSE ProviderTypeRank
        END
    ORDER BY
        IFNULL(bptpt.ProviderTypeRank, 2147483647)
),

CTE_ProviderTypeXML AS (
    SELECT
        T.ProviderID,
        to_variant(parse_xml('<ptL>' || 
        LISTAGG(
            '<pt>' ||
            IFF(cte_pt.ptCd IS NOT NULL, '<ptCd>' || cte_pt.ptCd || '</ptCd>', '') ||
            IFF(cte_pt.ptD IS NOT NULL, '<ptD>' || cte_pt.ptD || '</ptD>', '') ||
            IFF(cte_pt.ptRank IS NOT NULL, '<ptRank>' || cte_pt.ptRank || '</ptRank>', '') ||
            '</pt>'
        ) ||
        '</ptL>')) AS XMLValue
    FROM
        CTE_Provider_Batch T
        LEFT JOIN CTE_ProviderType cte_pt ON cte_pt.ProviderId = T.ProviderID
    GROUP BY
        T.ProviderID
),

------------------------PracticeOfficeXML------------------------
---- validated: ~5.7M providers have this xml in both sides
CTE_PracticeOfficeHoursBase AS (
    SELECT
        dow.DaysOfWeekDescription AS _day,
        dow.SortOrder AS dispOrder,
        CAST(oh.OfficeHoursOpeningTime AS VARCHAR) AS _start,
        CAST(oh.OfficeHoursClosingTime AS VARCHAR) AS _end,
        oh.OfficeIsClosed AS closed,
        oh.OfficeIsOpen24Hours AS open24Hrs,
        ppo.ProviderId,
        ppo.OfficeID
    FROM
        Mid.ProviderPracticeOffice ppo
        INNER JOIN base.OfficeHours oh ON oh.OfficeID = ppo.OfficeID
        INNER JOIN base.DaysOfWeek dow ON dow.DaysOfWeekID = oh.DaysOfWeekID
        INNER JOIN CTE_Provider_Batch p ON ppo.ProviderID = p.ProviderID
    ORDER BY
        dow.SortOrder
),
CTE_PracticeOfficephFullBase AS (
    SELECT
        DISTINCT ppo.FullPhone AS phFull,
        ppo.ProviderId,
        ppo.OfficeID
    FROM
        Mid.ProviderPracticeOffice ppo
        INNER JOIN CTE_Provider_Batch p ON ppo.ProviderID = p.ProviderID
),
CTE_PracticeOfficefaxFullBase AS (
    SELECT
        DISTINCT ppo.FullFax AS faxFull,
        ppo.ProviderId,
        ppo.OfficeID
    FROM
        Mid.ProviderPracticeOffice ppo
        INNER JOIN CTE_Provider_Batch p ON ppo.ProviderID = p.ProviderID
),
CTE_PracticeOfficeBase AS (
    SELECT
        ppo.OfficeID AS oGUID,
        ppo.OfficeCode AS oID,
        ppo.OfficeName AS oNm,
        ppo.IsPrimaryOffice AS prmryO,
        ppo.ProviderOfficeRank AS oRank,
        ppo.AddressTypeCode AS addTp,
        ppo.AddressCode AS addCd,
        ppo.AddressLine1 AS ad1,
        ppo.AddressLine2 AS ad2,
        ppo.AddressLine3 AS ad3,
        ppo.AddressLine4 AS ad4,
        ppo.City AS city,
        ppo.State AS st,
        ppo.ZipCode AS zip,
        ppo.Latitude AS lat,
        ppo.Longitude AS lng,
        a.TimeZone AS tzn,
        ppo.HasBillingStaff AS isBStf,
        ppo.HasHandicapAccess isHcap,
        ppo.HasLabServicesOnSite isLab,
        ppo.HasPharmacyOnSite AS isPhrm,
        ppo.HasXrayOnSite isXray,
        ppo.IsSurgeryCenter AS isSrg,
        ppo.HasSurgeryOnSite hasSrg,
        ppo.AverageDailyPatientVolume AS avVol,
        ppo.OfficeCoordinatorName AS ocNm,
        ppo.ParkingInformation AS prkInf,
        ppo.PaymentPolicy AS payPol,
        a.AddressLine1 AS ast,
        a.Suite AS ste,
        ppo.LegacyKeyOffice AS oLegacyID,
        REPLACE(
            '/group-directory/' || LOWER(cspc.State) || '-' || LOWER(REPLACE(s.StateName, ' ', '-')) || '/' || LOWER(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                REPLACE(
                                    REPLACE(REPLACE(cspc.City, ' - ', ' '), '&', '-'),
                                    ' ',
                                    '-'
                                ),
                                '/',
                                '-'
                            ),
                            '''',
                            ''
                        ),
                        '.',
                        ''
                    ),
                    '--',
                    '-'
                )
            ) || '/' || LOWER(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                REPLACE(
                                    REPLACE(
                                        REPLACE(
                                            REPLACE(
                                                REPLACE(
                                                    REPLACE(
                                                        REPLACE(
                                                            REPLACE(
                                                                REPLACE(
                                                                    REPLACE(
                                                                        REPLACE(
                                                                            REPLACE(
                                                                                REPLACE(
                                                                                    REPLACE(
                                                                                        REPLACE(
                                                                                            REPLACE(
                                                                                                REPLACE(
                                                                                                    REPLACE(
                                                                                                        REPLACE(
                                                                                                            REPLACE(
                                                                                                                REPLACE(
                                                                                                                    REPLACE(
                                                                                                                        REPLACE(
                                                                                                                            REPLACE(
                                                                                                                                REPLACE(
                                                                                                                                    REPLACE(
                                                                                                                                        REPLACE(
                                                                                                                                            REPLACE(
                                                                                                                                                REPLACE(
                                                                                                                                                    REPLACE(
                                                                                                                                                        REPLACE(
                                                                                                                                                            REPLACE(
                                                                                                                                                                REPLACE(
                                                                                                                                                                    REPLACE(
                                                                                                                                                                        REPLACE(LTRIM(RTRIM(pr.PracticeName)), ' - ', ' '),
                                                                                                                                                                        '&',
                                                                                                                                                                        '-'
                                                                                                                                                                    ),
                                                                                                                                                                    ' ',
                                                                                                                                                                    '-'
                                                                                                                                                                ),
                                                                                                                                                                '/',
                                                                                                                                                                '-'
                                                                                                                                                            ),
                                                                                                                                                            '\\\\',
                                                                                                                                                            '-'
                                                                                                                                                        ),
                                                                                                                                                        '''',
                                                                                                                                                        ''
                                                                                                                                                    ),
                                                                                                                                                    ':',
                                                                                                                                                    ''
                                                                                                                                                ),
                                                                                                                                                '~',
                                                                                                                                                ''
                                                                                                                                            ),
                                                                                                                                            ';',
                                                                                                                                            ''
                                                                                                                                        ),
                                                                                                                                        '|',
                                                                                                                                        ''
                                                                                                                                    ),
                                                                                                                                    '<',
                                                                                                                                    ''
                                                                                                                                ),
                                                                                                                                '>',
                                                                                                                                ''
                                                                                                                            ),
                                                                                                                            '?',
                                                                                                                            ''
                                                                                                                        ),
                                                                                                                        '?',
                                                                                                                        ''
                                                                                                                    ),
                                                                                                                    '*',
                                                                                                                    ''
                                                                                                                ),
                                                                                                                '?',
                                                                                                                ''
                                                                                                            ),
                                                                                                            '+',
                                                                                                            ''
                                                                                                        ),
                                                                                                        '?',
                                                                                                        ''
                                                                                                    ),
                                                                                                    '!',
                                                                                                    ''
                                                                                                ),
                                                                                                '?',
                                                                                                ''
                                                                                            ),
                                                                                            '@',
                                                                                            ''
                                                                                        ),
                                                                                        '{',
                                                                                        ''
                                                                                    ),
                                                                                    '}',
                                                                                    ''
                                                                                ),
                                                                                '[',
                                                                                ''
                                                                            ),
                                                                            ']',
                                                                            ''
                                                                        ),
                                                                        '(',
                                                                        ''
                                                                    ),
                                                                    ')',
                                                                    ''
                                                                ),
                                                                '?',
                                                                'n'
                                                            ),
                                                            '?',
                                                            'a'
                                                        ),
                                                        '?',
                                                        'i'
                                                    ),
                                                    '"',
                                                    ''
                                                ),
                                                '?',
                                                ''
                                            ),
                                            ' ',
                                            ''
                                        ),
                                        '`',
                                        ''
                                    ),
                                    ',',
                                    ''
                                ),
                                '#',
                                ''
                            ),
                            '.',
                            ''
                        ),
                        '---',
                        '-'
                    ),
                    '--',
                    '-'
                )
            ) || '-' || LOWER(pr.OfficeCode),
            '--',
            '-'
        ) AS pracUrl,
        ppo.PracticeID,
        ppo.ProviderID
    FROM
        Mid.ProviderPracticeOffice ppo
        LEFT JOIN Mid.Practice pr ON ppo.OfficeID = pr.OfficeID
        AND ppo.PracticeID = pr.PracticeID
        LEFT JOIN Base.CityStatePostalCode cspc ON pr.CityStatePostalCodeID = cspc.CityStatePostalCodeID
        LEFT JOIN Base.State s ON s.state = cspc.state
        INNER JOIN Base.Address a ON ppo.AddressID = a.AddressID
        INNER JOIN CTE_Provider_Batch p ON ppo.ProviderID = p.ProviderID
    WHERE
        ppo.Latitude <> 0
        AND ppo.Longitude <> 0
    GROUP BY
        ppo.ProviderID,
        ppo.PracticeID,
        ppo.OfficeCode,
        ppo.OfficeName,
        ppo.IsPrimaryOffice,
        ppo.ProviderOfficeRank,
        ppo.AddressTypeCode,
        ppo.AddressCode,
        ppo.AddressLine1,
        ppo.AddressLine2,
        ppo.AddressLine3,
        ppo.AddressLine4,
        ppo.City,
        ppo.State,
        ppo.ZipCode,
        ppo.Latitude,
        ppo.Longitude,
        a.TimeZone,
        ppo.HasBillingStaff,
        ppo.HasHandicapAccess,
        ppo.HasLabServicesOnSite,
        ppo.HasPharmacyOnSite,
        ppo.HasXrayOnSite,
        ppo.IsSurgeryCenter,
        ppo.HasSurgeryOnSite,
        ppo.AverageDailyPatientVolume,
        ppo.OfficeCoordinatorName,
        ppo.ParkingInformation,
        ppo.PaymentPolicy,
        ppo.LegacyKeyOffice,
        ppo.OfficeID,
        s.StateName,
        cspc.State,
        cspc.City,
        pr.PracticeName,
        pr.LegacyKeyOffice,
        pr.OfficeCode,
        a.AddressLine1,
        a.Suite
    ORDER BY
        ppo.ProviderOfficeRank
),
CTE_ProviderPracticeOffice AS (
    SELECT
        p.ProviderID,
        ppo.PracticeID AS prGUID,
        ppo.PracticeCode AS prID,
        ppo.PracticeName AS prNm,
        ppo.YearPracticeEstablished AS yrEst,
        ppo.PracticeNPI AS prNpi,
        ppo.PracticeWebsite AS prUrl,
        ppo.PracticeDescription AS prD,
        ppo.PracticeLogo AS prLgo,
        ppo.PracticeMedicalDirector AS medDir,
        ppo.PracticeSoftware AS prSft,
        ppo.PracticeTIN AS prTin,
        ppo.LegacyKeyPractice AS pLegacyID,
        ppo.PhysicianCount AS pProvCnt,
    FROM
        Mid.ProviderPracticeOffice AS ppo
        INNER JOIN Base.Provider p ON p.ProviderId = ppo.ProviderId
        LEFT JOIN Mid.ProviderSponsorship ps ON p.ProviderCode = ps.ProviderCode
        AND ppo.PracticeCode = ps.PracticeCode
        AND ps.ProductCode IN (
            SELECT
                ProductCode
            FROM
                Base.Product
            WHERE
                ProductTypeCode = 'PRACTICE'
        )
    WHERE
        ppo.Latitude <> 0
        AND ppo.Longitude <> 0
        AND CAST(ppo.Latitude AS VARCHAR) <> '0.000000'
        AND CAST(ppo.Longitude AS VARCHAR) <> '0.000000'
),
CTE_PracticeOfficeBaseXML AS (
    SELECT
        cte_pob.ProviderID,
        '<offL>' || 
        LISTAGG(
            '<off>' ||
            IFF(cte_pob.oGUID IS NOT NULL, '<oGUID>' || cte_pob.oGUID || '</oGUID>', '') ||
            IFF(cte_pob.oID IS NOT NULL, '<oID>' || cte_pob.oID || '</oID>', '') ||
            IFF(cte_pob.oNm IS NOT NULL, '<oNm>' || cte_pob.oNm || '</oNm>', '') ||
            IFF(cte_pob.prmryO IS NOT NULL, '<prmryO>' || cte_pob.prmryO || '</prmryO>', '') ||
            IFF(cte_pob.oRank IS NOT NULL, '<oRank>' || cte_pob.oRank || '</oRank>', '') ||
            IFF(cte_pob.addTp IS NOT NULL, '<addTp>' || cte_pob.addTp || '</addTp>', '') ||
            IFF(cte_pob.addCd IS NOT NULL, '<addCd>' || cte_pob.addCd || '</addCd>', '') ||
            IFF(cte_pob.ad1 IS NOT NULL, '<ad1>' || cte_pob.ad1 || '</ad1>', '') ||
            IFF(cte_pob.ad2 IS NOT NULL, '<ad2>' || cte_pob.ad2 || '</ad2>', '') ||
            IFF(cte_pob.ad3 IS NOT NULL, '<ad3>' || cte_pob.ad3 || '</ad3>', '') ||
            IFF(cte_pob.ad4 IS NOT NULL, '<ad4>' || cte_pob.ad4 || '</ad4>', '') ||
            IFF(cte_pob.city IS NOT NULL, '<city>' || cte_pob.city || '</city>', '') ||
            IFF(cte_pob.st IS NOT NULL, '<st>' || cte_pob.st || '</st>', '') ||
            IFF(cte_pob.zip IS NOT NULL, '<zip>' || cte_pob.zip || '</zip>', '') ||
            IFF(cte_pob.lat IS NOT NULL, '<lat>' || cte_pob.lat || '</lat>', '') ||
            IFF(cte_pob.lng IS NOT NULL, '<lng>' || cte_pob.lng || '</lng>', '') ||
            IFF(cte_pob.tzn IS NOT NULL, '<tzn>' || cte_pob.tzn || '</tzn>', '') ||
            IFF(cte_pob.isBStf IS NOT NULL, '<isBStf>' || cte_pob.isBStf || '</isBStf>', '') ||
            IFF(cte_pob.isHcap IS NOT NULL, '<isHcap>' || cte_pob.isHcap || '</isHcap>', '') ||
            IFF(cte_pob.isLab IS NOT NULL, '<isLab>' || cte_pob.isLab || '</isLab>', '') ||
            IFF(cte_pob.isPhrm IS NOT NULL, '<isPhrm>' || cte_pob.isPhrm || '</isPhrm>', '') ||
            IFF(cte_pob.isXray IS NOT NULL, '<isXray>' || cte_pob.isXray || '</isXray>', '') ||
            IFF(cte_pob.isSrg IS NOT NULL, '<isSrg>' || cte_pob.isSrg || '</isSrg>', '') ||
            IFF(cte_pob.hasSrg IS NOT NULL, '<hasSrg>' || cte_pob.hasSrg || '</hasSrg>', '') ||
            IFF(cte_pob.avVol IS NOT NULL, '<avVol>' || cte_pob.avVol || '</avVol>', '') ||
            IFF(cte_pob.ocNm IS NOT NULL, '<ocNm>' || cte_pob.ocNm || '</ocNm>', '') ||
            IFF(cte_pob.prkInf IS NOT NULL, '<prkInf>' || cte_pob.prkInf || '</prkInf>', '') ||
            IFF(cte_pob.payPol IS NOT NULL, '<payPol>' || cte_pob.payPol || '</payPol>', '') ||
            IFF(cte_pob.ast IS NOT NULL, '<ast>' || cte_pob.ast || '</ast>', '') ||
            IFF(cte_pob.ste IS NOT NULL, '<ste>' || cte_pob.ste || '</ste>', '') ||
            '</off>'
        ) ||
        '</offL>' AS XMLValue
    FROM
        CTE_PracticeOfficeBase cte_pob
    GROUP BY
        cte_pob.ProviderID
),

CTE_PracticeOfficeHoursBaseXML AS (
    SELECT
        cte_pohb.ProviderID,
        '<hoursL>' || 
        LISTAGG(
            '<hours>' ||
            IFF(cte_pohb._day IS NOT NULL, '<day>' || cte_pohb._day || '</day>', '') ||
            IFF(cte_pohb.dispOrder IS NOT NULL, '<dispOrder>' || cte_pohb.dispOrder || '</dispOrder>', '') ||
            IFF(cte_pohb._start IS NOT NULL, '<start>' || cte_pohb._start || '</start>', '') ||
            IFF(cte_pohb._end IS NOT NULL, '<end>' || cte_pohb._end || '</end>', '') ||
            IFF(cte_pohb.closed IS NOT NULL, '<closed>' || cte_pohb.closed || '</closed>', '') ||
            IFF(cte_pohb.open24Hrs IS NOT NULL, '<open24Hrs>' || cte_pohb.open24Hrs || '</open24Hrs>', '') ||
            '</hours>'
        ) ||
        '</hoursL>' AS XMLValue
    FROM
        CTE_PracticeOfficeHoursBase cte_pohb
    GROUP BY
        cte_pohb.ProviderID
),

CTE_PracticeOfficephFullBaseXML AS (
    SELECT
        cte_pophfb.ProviderID,
        '<phL>' || 
        LISTAGG(
            '<ph>' ||
            IFF(cte_pophfb.phFull IS NOT NULL, '<phFull>' || cte_pophfb.phFull || '</phFull>', '') ||
            '</ph>'
        ) ||
        '</phL>' AS XMLValue
    FROM
        CTE_PracticeOfficephFullBase cte_pophfb
    GROUP BY
        cte_pophfb.ProviderID
),

CTE_PracticeOfficefaxFullBaseXML AS (
    SELECT
        cte_poffb.ProviderID,
        '<faxL>' || 
        LISTAGG(
            '<fax>' ||
            IFF(cte_poffb.faxFull IS NOT NULL, '<faxFull>' || cte_poffb.faxFull || '</faxFull>', '') ||
            '</fax>'
        ) ||
        '</faxL>' AS XMLValue
    FROM
        CTE_PracticeOfficefaxFullBase cte_poffb
    GROUP BY
        cte_poffb.ProviderID
),

CTE_PracticeUrlXML AS (
    SELECT
        cte_pob.ProviderID,
        LISTAGG(
            '<pracUrl>' ||
            IFF(cte_pob.pracUrl IS NOT NULL, cte_pob.pracUrl, '') ||
            '</pracUrl>'
        ) AS XMLValue
    FROM
        CTE_PracticeOfficeBase cte_pob
    GROUP BY
        cte_pob.ProviderID
),

CTE_ProviderPracticeOfficeXML AS (
    SELECT
        cte_ppo.ProviderID,
        LISTAGG(
            '<practice>' ||
            IFF(cte_ppo.prGUID IS NOT NULL, '<prGUID>' || cte_ppo.prGUID || '</prGUID>', '') ||
            IFF(cte_ppo.prID IS NOT NULL, '<prID>' || cte_ppo.prID || '</prID>', '') ||
            IFF(cte_ppo.prNm IS NOT NULL, '<prNm>' || cte_ppo.prNm || '</prNm>', '') ||
            IFF(cte_ppo.yrEst IS NOT NULL, '<yrEst>' || cte_ppo.yrEst || '</yrEst>', '') ||
            IFF(cte_ppo.prNpi IS NOT NULL, '<prNpi>' || cte_ppo.prNpi || '</prNpi>', '') ||
            IFF(cte_ppo.prUrl IS NOT NULL, '<prUrl>' || REPLACE(cte_ppo.prUrl, '&', '&amp;') || '</prUrl>', '') ||
            IFF(cte_ppo.prD IS NOT NULL, '<prD>' || cte_ppo.prD || '</prD>', '') ||
            IFF(cte_ppo.prLgo IS NOT NULL, '<prLgo>' || cte_ppo.prLgo || '</prLgo>', '') ||
            IFF(cte_ppo.medDir IS NOT NULL, '<medDir>' || cte_ppo.medDir || '</medDir>', '') ||
            IFF(cte_ppo.prSft IS NOT NULL, '<prSft>' || cte_ppo.prSft || '</prSft>', '') ||
            IFF(cte_ppo.prTin IS NOT NULL, '<prTin>' || cte_ppo.prTin || '</prTin>', '') ||
            IFF(cte_ppo.pLegacyID IS NOT NULL, '<pLegacyID>' || cte_ppo.pLegacyID || '</pLegacyID>', '') ||
            '</practice>'
        ) AS XMLValue
    FROM
        CTE_ProviderPracticeOffice cte_ppo
    GROUP BY
        cte_ppo.ProviderID
),

CTE_PracticeOfficeXML AS (
    SELECT
        pob.ProviderID,
        to_variant(parse_xml('<poffL><poff>' || 
        COALESCE(REPLACE(ppo.XMLValue, '&', '/amp'), '') || 
        '<offL><off>' || 
        COALESCE(REPLACE(pohb.XMLValue, '&', '/amp'), '') || 
        COALESCE(REPLACE(pofb.XMLValue, '&', '/amp'), '') || 
        COALESCE(REPLACE(poffb.XMLValue, '&', '/amp'), '') || 
        COALESCE(REPLACE(purl.XMLValue, '&', '/amp'), '') || 
        '</off></offL></poff></poffL>'))
        AS XMLValue
    FROM
        CTE_PracticeOfficeBaseXML pob
        LEFT JOIN CTE_PracticeOfficeHoursBaseXML pohb ON pob.ProviderID = pohb.ProviderID
        LEFT JOIN CTE_PracticeOfficephFullBaseXML pofb ON pob.ProviderId = pofb.ProviderID
        LEFT JOIN CTE_PracticeOfficefaxFullBaseXML poffb ON pob.ProviderId = poffb.ProviderID
        LEFT JOIN CTE_PracticeUrlXML purl ON pob.ProviderId = purl.ProviderID
        LEFT JOIN CTE_ProviderPracticeOfficeXML ppo ON pob.ProviderId = ppo.ProviderID
),

------------------------AddressXML------------------------
---- validated: ~5.6M providers have this xml in both sides
CTE_Address AS (
    SELECT
        x.ProviderID,
        x.OfficeID,
        x.AddressCode AS addCd,
        x.AddressLine1 AS ad1,
        x.AddressLine2 AS ad2,
        x.AddressLine3 AS ad3,
        x.AddressLine4 AS ad4,
        x.City AS city,
        x.State AS st,
        x.ZipCode AS zip,
        x.Latitude AS lat,
        x.Longitude AS lng,
        ba.TimeZone AS tzn,
        x.AddressTypeCode AS addTp,
        x.OfficeCode AS offCd,
        x.OfficeID AS oGUID,
        x.ProviderOfficeRank AS oRank,
        z.FullPhone AS phFull
    FROM
        Mid.ProviderPracticeOffice AS x
        JOIN Base.Address ba ON ba.AddressID = x.AddressID
        LEFT JOIN Mid.ProviderPracticeOffice z ON x.ProviderID = z.ProviderID AND x.OfficeID = z.OfficeID
),

CTE_AddressXML AS (
    SELECT
        s.ProviderId,
        TO_VARIANT(PARSE_XML(
            '<addrL>' || 
            LISTAGG(DISTINCT
                '<addr>' ||
                IFF(addCd IS NOT NULL, '<addCd>' || REPLACE(addCd, '&', '/amp') || '</addCd>', '') ||
                IFF(ad1 IS NOT NULL, '<ad1>' || REPLACE(ad1, '&', '/amp') || '</ad1>', '') ||
                IFF(ad2 IS NOT NULL, '<ad2>' || REPLACE(ad2, '&', '/amp') || '</ad2>', '') ||
                IFF(ad3 IS NOT NULL, '<ad3>' || REPLACE(ad3, '&', '/amp') || '</ad3>', '') ||
                IFF(ad4 IS NOT NULL, '<ad4>' || REPLACE(ad4, '&', '/amp') || '</ad4>', '') ||
                IFF(city IS NOT NULL, '<city>' || REPLACE(city, '&', '/amp') || '</city>', '') ||
                IFF(st IS NOT NULL, '<st>' || REPLACE(st, '&', '/amp') || '</st>', '') ||
                IFF(zip IS NOT NULL, '<zip>' || REPLACE(zip, '&', '/amp') || '</zip>', '') ||
                IFF(lat IS NOT NULL, '<lat>' || REPLACE(lat, '&', '/amp') || '</lat>', '') ||
                IFF(lng IS NOT NULL, '<lng>' || REPLACE(lng, '&', '/amp') || '</lng>', '') ||
                IFF(tzn IS NOT NULL, '<tzn>' || REPLACE(tzn, '&', '/amp') || '</tzn>', '') ||
                IFF(addTp IS NOT NULL, '<addTp>' || REPLACE(addTp, '&', '/amp') || '</addTp>', '') ||
                IFF(offCd IS NOT NULL, '<offCd>' || REPLACE(offCd, '&', '/amp') || '</offCd>', '') ||
                IFF(oGUID IS NOT NULL, '<oGUID>' || REPLACE(oGUID, '&', '/amp') || '</oGUID>', '') ||
                IFF(oRank IS NOT NULL, '<oRank>' || REPLACE(oRank, '&', '/amp') || '</oRank>', '') ||
                '<phL>' ||
                (SELECT LISTAGG(DISTINCT '<phFull>' || REPLACE(phFull, '&', '/amp') || '</phFull>', '')
                 FROM CTE_Address cte
                 WHERE cte.ProviderID = a.ProviderID AND cte.oGUID = a.oGUID) ||
                '</phL>' ||
                '</addr>'
            , '') ||
            '</addrL>'
        )) AS XMLValue
    FROM CTE_Provider_Batch s
    INNER JOIN CTE_Address a ON s.ProviderId = a.ProviderID
    GROUP BY s.ProviderId
),

------------------------SpecialtyXML------------------------
---- validated: ~5M providers have this xml in both sides
CTE_Y AS (
    SELECT
        p.ProviderID,
        d.SpecialtyGroupCode,
        a.SpecialtyRankCalculated,
        c.SpecialtyGroupRank,
        d.SpecialtyGroupDescription,
        d.SpecialistGroupDescription,
        d.SpecialistsGroupDescription,
        a.IsSearchableCalculated,
        a.SearchBoostExperience,
        a.SearchBoostHospitalCohortQuality,
        a.SearchBoostHospitalServiceLineQuality,
        d.LegacyKey,
        ROW_NUMBER() OVER (
            PARTITION BY d.SpecialtyGroupCode
            ORDER BY
                c.SpecialtyGroupRank,
                CASE
                    WHEN a.IsSearchableCalculated = 1 THEN 0
                    ELSE 1
                END,
                a.SpecialtyRankCalculated
        ) AS SpecialtyGroupCodeRank,
        a.SpecialtyID
    FROM
        Base.ProviderToSpecialty AS a
        INNER JOIN Base.SpecialtyGroupToSpecialty AS c ON c.SpecialtyID = a.SpecialtyID
        INNER JOIN Base.SpecialtyGroup AS d ON d.SpecialtyGroupID = c.SpecialtyGroupID
        INNER JOIN CTE_Provider_Batch p ON a.ProviderID = p.ProviderID
),

CTE_X AS (
    SELECT
        ProviderID,
        SpecialtyGroupCode,
        SpecialtyRankCalculated,
        SpecialtyGroupRank,
        SpecialtyGroupDescription,
        SpecialistGroupDescription,
        SpecialistsGroupDescription,
        IsSearchableCalculated,
        SearchBoostExperience,
        SearchBoostHospitalCohortQuality,
        SearchBoostHospitalServiceLineQuality,
        LegacyKey,
        ROW_NUMBER() OVER (
            ORDER BY
                SpecialtyRankCalculated,
                SpecialtyGroupRank
        ) AS spRank,
        SpecialtyID
    FROM
        CTE_Y
    WHERE
        SpecialtyGroupCodeRank = 1
),
--- left join
CTE_W AS (
    SELECT
        e.MedicalTermCode,
        RTRIM(LTRIM(h.ProviderTypeCode)) AS ProviderTypeCode
    FROM
        Base.MedicalTerm AS e
        INNER JOIN Base.ProviderTypeToMedicalTerm g ON g.MedicalTermID = e.MedicalTermID
        INNER JOIN Base.ProviderType h ON h.ProviderTypeID = g.ProviderTypeID
),
CTE_Specialty AS (
    SELECT
        s.ProviderID,
        cte_y.SpecialtyGroupCode AS spCd,
        cte_y.SpecialtyRankCalculated AS spRank,
        cte_y.SpecialtyGroupDescription AS spY,
        cte_y.SpecialistGroupDescription AS spIst,
        cte_y.SpecialistsGroupDescription AS spIsts,
        cte_y.IsSearchableCalculated AS srch,
        cte_y.SearchBoostExperience as boostExp,
        CASE
            WHEN cte_y.SearchBoostHospitalCohortQuality IS NOT NULL THEN cte_y.SearchBoostHospitalCohortQuality
            ELSE cte_y.SearchBoostHospitalServiceLineQuality
        END AS boostQual,
        CASE
            WHEN spRank = 1 THEN 1
            ELSE 0
        END AS prm,
        CASE
            WHEN cte_w.ProviderTypeCode IS NULL THEN 'ALT'
            ELSE cte_w.ProviderTypeCode
        END AS prvTypCd,
        (
            SELECT
                DISTINCT z.ServiceLineCode
        ) AS svcCd,
        cte_y.LegacyKey
    FROM
        CTE_Provider_Batch s
        INNER JOIN CTE_y ON s.ProviderID = cte_y.ProviderID
        LEFT JOIN CTE_w ON cte_w.MedicalTermCode = cte_y.SpecialtyGroupCode
        LEFT JOIN Base.TempSpecialtyToServiceLineGhetto z ON z.SpecialtyCode = cte_y.SpecialtyGroupCode
),

CTE_ServiceCodes AS (
    SELECT
        ProviderID,
        spCd,
        LISTAGG(
            IFF(svcCd IS NOT NULL, '<svcLn><svcCd>' || REPLACE(svcCd, '&', '/amp') || '</svcCd></svcLn>', '')
        , '') AS svcLnXML
    FROM CTE_Specialty
    GROUP BY ProviderID, spCd
),

CTE_SpecialtyXML AS (
    SELECT
        cte_s.ProviderID,
        TO_VARIANT(PARSE_XML(
            '<spcL>' ||
            LISTAGG(
                '<spc>' ||
                IFF(cte_s.spCd IS NOT NULL, '<spCd>' || REPLACE(cte_s.spCd, '&', '/amp') || '</spCd>', '') ||
                IFF(cte_s.spRank IS NOT NULL, '<spRank>' || cte_s.spRank || '</spRank>', '') ||
                IFF(cte_s.spY IS NOT NULL, '<spY>' || REPLACE(cte_s.spY, '&', '/amp') || '</spY>', '') ||
                IFF(cte_s.spIst IS NOT NULL, '<spIst>' || REPLACE(cte_s.spIst, '&', '/amp') || '</spIst>', '') ||
                IFF(cte_s.spIsts IS NOT NULL, '<spIsts>' || REPLACE(cte_s.spIsts, '&', '/amp') || '</spIsts>', '') ||
                IFF(cte_s.srch IS NOT NULL, '<srch>' || cte_s.srch || '</srch>', '') ||
                IFF(cte_s.boostQual IS NOT NULL, '<boostQual>' || cte_s.boostQual || '</boostQual>', '') ||
                IFF(cte_s.prm IS NOT NULL, '<prm>' || cte_s.prm || '</prm>', '') ||
                IFF(cte_s.prvTypCd IS NOT NULL, '<prvTypCd>' || REPLACE(cte_s.prvTypCd, '&', '/amp') || '</prvTypCd>', '') ||
                '<svcLnL>' || COALESCE(sc.svcLnXML, '') || '</svcLnL>' ||
                IFF(cte_s.LegacyKey IS NOT NULL, '<lKey>' || REPLACE(cte_s.LegacyKey, '&', '/amp') || '</lKey>', '') ||
                '</spc>'
            , '') ||
            '</spcL>'
        )) AS XMLValue
    FROM CTE_Specialty cte_s
    LEFT JOIN CTE_ServiceCodes sc ON cte_s.ProviderID = sc.ProviderID AND cte_s.spCd = sc.spCd
    GROUP BY cte_s.ProviderID
),

------------------------PracticingSpecialtyXML------------------------
--- validated: all providers have this xml in Snowflake

CTE_HGChoice AS (
    SELECT 
        P.ProviderID, 
        Sp.SpecialtyID, 
        Sp.SpecialtyCode
    FROM Show.SOLRProvider P
    INNER JOIN Base.ProviderToSpecialty PS ON PS.ProviderID = P.ProviderID
    INNER JOIN Base.Specialty Sp ON Sp.SpecialtyID = PS.SpecialtyID
    WHERE P.ProviderTypeGroup = 'DOC'
    -- at the end the aggregate counts for XMLs look good, but in the future we should check this 'A' or 'H' where condition
    -- since counts appear somewhat inverted compared to SQL Server
    AND P.DisplayStatusCode = 'A'
    AND Sp.SpecialtyCode IN ('PS780','PS962','PS863','PS324','PS534','PS574','PS645','PS127','PS548','PS1081')
    AND P.ProviderID NOT IN (SELECT ProviderID FROM Base.ProviderToSubStatus WHERE SubStatusID IN (SELECT SubStatusID FROM Base.SubStatus WHERE SubStatusCode IN ('B', 'L', 'L5')))
    AND P.ProviderID NOT IN (SELECT ProviderID FROM Base.NoIndexNoFollow)
    AND P.AcceptsNewPatients != 0
    AND (COALESCE(P.PatientExperienceSurveyOverallCount,0) >= 10 AND COALESCE(P.PatientExperienceSurveyOverallScore,0) >= 70)
    AND NOT EXISTS (SELECT 1 FROM Base.ProviderMalpractice pm WHERE pm.ProviderID = P.ProviderID)
    AND NOT EXISTS (SELECT 1 FROM Base.ProviderSanction psa WHERE psa.ProviderID = P.ProviderId) 
),

CTE_SpecialtyScoreWithBoost AS (
    SELECT
        lPtS.ProviderId,
        lPtS.SpecialtyID,
        CAST(SpecialtyScoreWithBoost AS NUMERIC(7, 5)) AS SpecialtyScoreWithBoost,
        CASE WHEN H.ProviderID IS NOT NULL THEN 1 ELSE 0 END AS hgChoice
    FROM
        Show.SOLRProvider P
        INNER JOIN Base.ProviderToSpecialty lPtS ON lPtS.ProviderID = P.ProviderID
        INNER JOIN Base.ProviderToSpecialtyExperienceScore SEC ON SEC.ProviderId = lPtS.ProviderID
            AND SEC.EligibleSpecialtyid = lPtS.Specialtyid
        LEFT JOIN CTE_HGChoice H ON H.ProviderID = lPtS.ProviderID
            AND H.SpecialtyID = lPtS.SpecialtyID
),

CTE_MapSpc AS (
    SELECT 
        c1.SpecialtyGroupID,
        PARSE_XML(
            '<mapSpc>' ||
            LISTAGG(
                '<mapPracSpcCd>' || UTILS.CLEAN_XML(a1.SpecialtyCode) || '</mapPracSpcCd>' ||
                '<mapPracSpcDesc>' || UTILS.CLEAN_XML(a1.SpecialtyDescription) || '</mapPracSpcDesc>' ||
                '<SpecialtyGroupRank>' || c1.SpecialtyGroupRank || '</SpecialtyGroupRank>'
            , '') WITHIN GROUP (ORDER BY c1.SpecialtyGroupRank) ||
            '</mapSpc>'
        ) AS mapSpc
    FROM Base.Specialty a1
    JOIN Base.SpecialtyGroupToSpecialty c1 ON a1.SpecialtyID = c1.SpecialtyID
        AND c1.SpecialtyIsRedundant = 1
    GROUP BY c1.SpecialtyGroupID
),

CTE_SpecialtyGroupInfo AS (
    SELECT
        c.SpecialtyID,
        d.SpecialtyGroupCode AS spGCd,
        d.SpecialtyGroupDescription AS spGY,
        ROW_NUMBER() OVER (PARTITION BY c.SpecialtyID ORDER BY c.SpecialtyGroupRank) AS spGRank,
        d.LegacyKey AS glKey,
        m.mapSpc
    FROM Base.SpecialtyGroupToSpecialty c
    JOIN Base.SpecialtyGroup d ON d.SpecialtyGroupID = c.SpecialtyGroupID
    LEFT JOIN CTE_MapSpc m ON m.SpecialtyGroupID = c.SpecialtyGroupID
),

CTE_PracticingSpecialty AS (
    SELECT
        a.ProviderID,
        b.SpecialtyCode AS spCd,
        ROW_NUMBER() OVER (PARTITION BY a.ProviderID ORDER BY a.SpecialtyRankCalculated) AS spRank,
        b.SpecialtyDescription AS spY,
        b.SpecialistDescription AS spIst,
        b.SpecialistsDescription AS spIsts,
        a.IsSearchableCalculated AS srch,
        SEC.hgChoice,
        a.SearchBoostExperience AS boostExp,
        CASE
            WHEN a.SearchBoostHospitalCohortQuality IS NOT NULL THEN a.SearchBoostHospitalCohortQuality
            ELSE a.SearchBoostHospitalServiceLineQuality
        END AS boostQual,
        sgi.spGCd,
        sgi.spGY,
        sgi.spGRank,
        sgi.glKey,
        sgi.mapSpc AS spcGL,
        b.LegacyKey AS lKey
    FROM Base.ProviderToSpecialty a
    INNER JOIN Base.Specialty b ON b.SpecialtyID = a.SpecialtyID
    LEFT JOIN Base.ProviderToProviderType e ON e.ProviderID = a.ProviderID AND e.ProviderTypeRank = 1
    LEFT JOIN Base.ProviderTypeToSpecialty f ON f.ProviderTypeID = e.ProviderTypeID AND f.SpecialtyID = a.SpecialtyID
    LEFT JOIN CTE_SpecialtyScoreWithBoost SEC ON SEC.Specialtyid = a.Specialtyid AND SEC.ProviderId = a.ProviderID
    LEFT JOIN CTE_SpecialtyGroupInfo sgi ON sgi.SpecialtyID = b.SpecialtyID
    WHERE a.SpecialtyIsRedundant = 0 AND a.IsSearchableCalculated = 1
),

CTE_PracticingSpecialtyXML AS (
    SELECT
        s.ProviderId,
        TRY_CAST(PARSE_XML(
            '<spcL>' ||
            LISTAGG(
                '<spc>' ||
                '<spCd>' || COALESCE(ps.spCd, '') || '</spCd>' ||
                '<spRank>' || COALESCE(TO_CHAR(ps.spRank), '') || '</spRank>' ||
                '<spY>' || COALESCE(UTILS.CLEAN_XML(ps.spY), '') || '</spY>' ||
                '<spIst>' || COALESCE(UTILS.CLEAN_XML(ps.spIst), '') || '</spIst>' ||
                '<spIsts>' || COALESCE(UTILS.CLEAN_XML(ps.spIsts), '') || '</spIsts>' ||
                '<srch>' || COALESCE(TO_CHAR(ps.srch), '') || '</srch>' ||
                '<hgChoice>' || COALESCE(TO_CHAR(ps.hgChoice), '') || '</hgChoice>' ||
                '<boostExp>' || COALESCE(TO_CHAR(ps.boostExp), '') || '</boostExp>' ||
                '<boostQual>' || COALESCE(TO_CHAR(ps.boostQual), '') || '</boostQual>' ||
                '<spcGL>' || COALESCE(TO_CHAR(ps.spcGL), '') || '</spcGL>' ||
                '<lkey>' || COALESCE(UTILS.CLEAN_XML(ps.lKey), '') || '</lkey>' ||
                '</spc>'
            , '') ||
            '</spcL>'
        ) AS VARIANT) AS XMLValue
    FROM Base.Provider s
    LEFT JOIN CTE_PracticingSpecialty ps ON s.ProviderID = ps.ProviderID
    GROUP BY s.ProviderId
),


---------------------------CertificationXML--------------------------
---- validated: ~900k providers have this xml in both sides
CTE_Certification AS (
    SELECT
        DISTINCT cs.CertificationSpecialtyCode AS cSpCd,
        ptcs.CertificationSpecialtyRank AS cSpRank,
        cs.CertificationSpecialtyDescription AS cSpY,
        ptcs.IsSearchable AS cSrch,
        ca.CertificationAgencyCode AS caCd,
        ca.CertificationAgencyDescription AS caD,
        cb.CertificationBoardCode AS cbCd,
        cb.CertificationBoardDescription AS cbD,
        cst.CertificationStatusCode AS csCd,
        cst.CertificationStatusDescription AS csD,
        mocl.MOCType AS mTyp,
        mocl.MOCLevelCode AS mLvC,
        mocl.MOCLevelDescription AS mLvD,
        mocp.MOCPathwayNumber AS mPwNo,
        mocp.MOCPathwaycode AS mPwCd,
        mocp.MOCPathwayName AS mPwNm,
        mocp.MOCPathwayBoardMessage AS mPwMsg,
        ptcs.CertificationStatusDate AS csDt,
        CASE
            WHEN ptcs.CertificationEffectiveDate IS NOT NULL
            AND ca.CertificationAgencyCode = 'ABMS' THEN NULL
            ELSE ptcs.CertificationEffectiveDate
        END AS ceffDt,
        CASE
            WHEN ptcs.CertificationExpirationDate IS NOT NULL THEN NULL
            ELSE ptcs.CertificationExpirationDate
        END AS ceExDt,
        IFNULL(ptcs.CertificationSpecialtyRank, 2147483647) AS TempDistinctSort1,
        cs.CertificationSpecialtyCode AS TempDistinctSort2,
        p.ProviderId,
        CASE
            WHEN ptcs.CertificationAgencyVerified = 1 THEN ca.CertificationAgencyCode
            ELSE 'SELF'
        END AS caVeri
    FROM
        Base.ProviderToCertificationSpecialty AS ptcs
        INNER JOIN CTE_Provider_Batch p ON p.ProviderID = ptcs.ProviderID
        INNER JOIN Base.CertificationSpecialty AS cs ON cs.CertificationSpecialtyID = ptcs.CertificationSpecialtyID
        INNER JOIN Base.CertificationAgency AS ca ON ca.CertificationAgencyID = ptcs.CertificationAgencyID
        INNER JOIN Base.CertificationBoard AS cb ON cb.CertificationBoardID = ptcs.CertificationBoardID
        INNER JOIN Base.CertificationStatus AS cst ON cst.CertificationStatusID = ptcs.CertificationStatusID
        LEFT JOIN Base.MOCLevel mocl ON ptcs.MOCLevelID = mocl.MOCLevelID
        LEFT JOIN Base.MOCPathway mocp ON ptcs.MOCPathwayID = mocp.MOCPathwayID
    WHERE
        cst.IndicatesNotCertified = 0
),

CTE_CertificationXML AS (
    SELECT
        cte_c.ProviderID,
        TO_VARIANT(PARSE_XML(
            '<cScL>' ||
            LISTAGG(
                '<cSc>' ||
                NULLIF(CONCAT(
                    IFF(cte_c.cSpCd IS NOT NULL, '<cSpCd>' || cte_c.cSpCd || '</cSpCd>', ''),
                    IFF(cte_c.cSpRank IS NOT NULL, '<cSpRank>' || cte_c.cSpRank || '</cSpRank>', ''),
                    IFF(cte_c.cSpY IS NOT NULL, '<cSpY>' || cte_c.cSpY || '</cSpY>', ''),
                    IFF(cte_c.cSrch IS NOT NULL, '<cSrch>' || cte_c.cSrch || '</cSrch>', ''),
                    IFF(cte_c.caCd IS NOT NULL, '<caCd>' || cte_c.caCd || '</caCd>', ''),
                    IFF(cte_c.caD IS NOT NULL, '<caD>' || cte_c.caD || '</caD>', ''),
                    IFF(cte_c.cbCd IS NOT NULL, '<cbCd>' || cte_c.cbCd || '</cbCd>', ''),
                    IFF(cte_c.cbD IS NOT NULL, '<cbD>' || cte_c.cbD || '</cbD>', ''),
                    IFF(cte_c.csCd IS NOT NULL, '<csCd>' || cte_c.csCd || '</csCd>', ''),
                    IFF(cte_c.csD IS NOT NULL, '<csD>' || cte_c.csD || '</csD>', ''),
                    IFF(cte_c.mTyp IS NOT NULL, '<mTyp>' || cte_c.mTyp || '</mTyp>', ''),
                    IFF(cte_c.mLvC IS NOT NULL, '<mLvC>' || cte_c.mLvC || '</mLvC>', ''),
                    IFF(cte_c.mLvD IS NOT NULL, '<mLvD>' || cte_c.mLvD || '</mLvD>', ''),
                    IFF(cte_c.mPwNo IS NOT NULL, '<mPwNo>' || cte_c.mPwNo || '</mPwNo>', ''),
                    IFF(cte_c.mPwCd IS NOT NULL, '<mPwCd>' || cte_c.mPwCd || '</mPwCd>', ''),
                    IFF(cte_c.mPwNm IS NOT NULL, '<mPwNm>' || cte_c.mPwNm || '</mPwNm>', ''),
                    IFF(cte_c.mPwMsg IS NOT NULL, '<mPwMsg>' || cte_c.mPwMsg || '</mPwMsg>', ''),
                    IFF(cte_c.csDt IS NOT NULL, '<csDt>' || cte_c.csDt || '</csDt>', ''),
                    IFF(cte_c.ceffDt IS NOT NULL, '<ceffDt>' || cte_c.ceffDt || '</ceffDt>', ''),
                    IFF(cte_c.ceExDt IS NOT NULL, '<ceExDt>' || cte_c.ceExDt || '</ceExDt>', ''),
                    IFF(cte_c.caVeri IS NOT NULL, '<caVeri>' || cte_c.caVeri || '</caVeri>', '')
                ), '') ||
                '</cSc>'
            , '') ||
            '</cScL>'
        )) AS XMLValue
    FROM CTE_Certification cte_c
    GROUP BY  cte_c.ProviderID
),

---------------------------EducationXML--------------------------
--- Validated: ~1.2M rows on both sides

CTE_EducationInstitutions AS (
    SELECT
        z.ProviderID,
        z.EducationInstitutionTypeCode,
        UTILS.CLEAN_XML(z.EducationInstitutionName) AS edNm,
        CASE
            WHEN TRY_CAST(z.GraduationYear AS INT) = 0 THEN NULL
            ELSE TRY_CAST(z.GraduationYear AS INT)
        END AS yr,
        UTILS.CLEAN_XML(z.PositionHeld) AS posH,
        UTILS.CLEAN_XML(z.DegreeAbbreviation) AS deg,
        UTILS.CLEAN_XML(z.City) AS city,
        UTILS.CLEAN_XML(z.State) AS st,
        UTILS.CLEAN_XML(z.NationName) AS natn
    FROM Mid.ProviderEducation z
),

CTE_InstitutionXML AS (
    SELECT
        ProviderID,
        EducationInstitutionTypeCode,
        LISTAGG(
            '<inst>' ||
            IFF(edNm IS NOT NULL, '<edNm>' || edNm || '</edNm>', '') ||
            IFF(yr IS NOT NULL, '<yr>' || yr || '</yr>', '') ||
            IFF(posH IS NOT NULL, '<posH>' || posH || '</posH>', '') ||
            IFF(deg IS NOT NULL, '<deg>' || deg || '</deg>', '') ||
            IFF(city IS NOT NULL, '<city>' || city || '</city>', '') ||
            IFF(st IS NOT NULL, '<st>' || st || '</st>', '') ||
            IFF(natn IS NOT NULL, '<natn>' || natn || '</natn>', '') ||
            '</inst>'
        , '') AS InstXML
    FROM CTE_EducationInstitutions
    GROUP BY ProviderID, EducationInstitutionTypeCode
),

CTE_EducationTypeXML AS (
    SELECT
        a.ProviderID,
        LISTAGG(
            '<edu>' ||
            '<edTypC>' || UTILS.CLEAN_XML(a.EducationInstitutionTypeCode) || '</edTypC>' ||
            i.InstXML ||
            '</edu>'
        , '') AS EduXML
    FROM
        Mid.ProviderEducation a
    JOIN CTE_InstitutionXML i ON a.ProviderID = i.ProviderID AND a.EducationInstitutionTypeCode = i.EducationInstitutionTypeCode
    GROUP BY a.ProviderID
),

CTE_EducationXML AS (
    SELECT
        s.ProviderId,
        CASE 
            WHEN COALESCE(e.EduXML, '') = '' THEN NULL
            ELSE TRY_CAST(PARSE_XML('<eduL>' || e.EduXML || '</eduL>') AS VARIANT)
        END AS XMLValue
    FROM CTE_Provider_Batch s
    LEFT JOIN CTE_EducationTypeXML e ON s.ProviderId = e.ProviderID
),

------------------------ProfessionalOrganizationXML------------------------
--- Validated: 0 non-null rows on both sides (which is why I commented it out)
-- CTE_ProfessionalOrganization AS (
--     SELECT
--         pto.ProviderID,
--         pto.OrganizationID,
--         o.OrganizationCode AS porgCd,
--         o.OrganizationDescription AS porgNm,
--         o.refDefinition AS porgDesc,
--         p.PositionCode AS porgPositCd,
--         p.PositionDescription AS porgPositNm,
--         pto.PositionRank AS posRk,
--         pto.PositionStartDate AS posSt,
--         pto.PositionEndDate AS posEnd
--     FROM
--         Base.ProviderToOrganization AS pto
--         INNER JOIN Base.Organization AS o ON o.OrganizationID = pto.OrganizationID
--         INNER JOIN Base.Position AS p ON p.PositionID = pto.PositionID
-- ),

-- CTE_OrganizationImage AS (
--     SELECT
--         otip.OrganizationID,
--         ip.ImagePathText AS porgImgU,
--         ip.ImageWidth AS porgImgW,
--         ip.ImageHeight AS porgImgH
--     FROM
--         Base.OrganizationToImagePath AS otip
--         INNER JOIN Base.ImagePath AS ip ON ip.ImagePathID = otip.ImagePathID
-- ),

-- CTE_ProfessionalOrganizationXML AS (
--     SELECT
--         cte_po.ProviderID,
--         TRY_CAST(PARSE_XML(
--             '<porgL>' ||
--             LISTAGG(
--                 '<porg>' ||
--                 IFF(cte_po.porgCd IS NOT NULL, '<porgCd>' || cte_po.porgCd || '</porgCd>', '') ||
--                 IFF(cte_po.porgNm IS NOT NULL, '<porgNm>' || cte_po.porgNm || '</porgNm>', '') ||
--                 IFF(cte_po.porgDesc IS NOT NULL, '<porgDesc>' || cte_po.porgDesc || '</porgDesc>', '') ||
--                 IFF(cte_po.porgPositCd IS NOT NULL, '<porgPositCd>' || cte_po.porgPositCd || '</porgPositCd>', '') ||
--                 IFF(cte_po.porgPositNm IS NOT NULL, '<porgPositNm>' || cte_po.porgPositNm || '</porgPositNm>', '') ||
--                 IFF(cte_po.posRk IS NOT NULL, '<posRk>' || cte_po.posRk || '</posRk>', '') ||
--                 IFF(cte_po.posSt IS NOT NULL, '<posSt>' || cte_po.posSt || '</posSt>', '') ||
--                 IFF(cte_po.posEnd IS NOT NULL, '<posEnd>' || cte_po.posEnd || '</posEnd>', '') ||
--                 '<imgL>' ||
--                 IFF(cte_oi.porgImgU IS NOT NULL, '<porgImg><porgImgU>' || cte_oi.porgImgU || '</porgImgU>', '') ||
--                 IFF(cte_oi.porgImgW IS NOT NULL, '<porgImgW>' || cte_oi.porgImgW || '</porgImgW>', '') ||
--                 IFF(cte_oi.porgImgH IS NOT NULL, '<porgImgH>' || cte_oi.porgImgH || '</porgImgH>', '') ||
--                 IFF(cte_oi.porgImgU IS NOT NULL, '</porgImg>', '') ||
--                 '</imgL>' ||
--                 '</porg>'
--             , '') WITHIN GROUP (ORDER BY cte_po.posRk, cte_po.porgNm) ||
--             '</porgL>'
--         ) AS VARIANT) AS XMLValue
--     FROM
--         CTE_ProfessionalOrganization cte_po
--         LEFT JOIN CTE_OrganizationImage cte_oi ON cte_oi.OrganizationID = cte_po.OrganizationID
--     GROUP BY
--         cte_po.ProviderID
-- ),

------------------------LicenseXML------------------------
--- Validated: ~5M non-null rows on both sides
CTE_ProviderLicense AS (
    SELECT
        DISTINCT pl.ProviderID,
        UTILS.CLEAN_XML(pl.State) AS licStAbr,
        UTILS.CLEAN_XML(pl.StateName) AS licSt,
        UTILS.CLEAN_XML(pl.LicenseType) AS licTp,
        UTILS.CLEAN_XML(pl.LicenseNumber) AS licNr,
        pl.LicenseEffectiveDate AS licEfDt,
        pl.LicenseTerminationDate AS licTeDt
    FROM
        Mid.ProviderLicense AS pl
),

CTE_LicenseXML AS (
    SELECT
        cte_pl.ProviderID,
        TRY_CAST(PARSE_XML(
            '<licL>' ||
            LISTAGG(
                '<lic>' ||
                IFF(cte_pl.licStAbr IS NOT NULL, '<licStAbr>' || cte_pl.licStAbr || '</licStAbr>', '') ||
                IFF(cte_pl.licSt IS NOT NULL, '<licSt>' || cte_pl.licSt || '</licSt>', '') ||
                IFF(cte_pl.licTp IS NOT NULL, '<licTp>' || cte_pl.licTp || '</licTp>', '') ||
                IFF(cte_pl.licNr IS NOT NULL, '<licNr>' || cte_pl.licNr || '</licNr>', '') ||
                IFF(cte_pl.licEfDt IS NOT NULL, '<licEfDt>' || cte_pl.licEfDt || '</licEfDt>', '') ||
                IFF(cte_pl.licTeDt IS NOT NULL, '<licTeDt>' || cte_pl.licTeDt || '</licTeDt>', '') ||
                '</lic>'
            , '') ||
            '</licL>'
        ) AS VARIANT) AS XMLValue
    FROM CTE_ProviderLicense cte_pl
    GROUP BY cte_pl.ProviderID
),

------------------------LanguageXML------------------------
--- Validated: ~260k non-null rows on both sides
CTE_Language AS (
    SELECT
        DISTINCT pl.ProviderID,
        UTILS.CLEAN_XML(pl.LanguageName) AS langNm,
        UTILS.CLEAN_XML(l.LanguageCode) AS langCd
    FROM Mid.ProviderLanguage AS pl
    INNER JOIN Base.Language l ON pl.LanguageName = l.LanguageName
),

CTE_LanguageXML AS (
    SELECT
        cte_l.ProviderID,
        TRY_CAST(PARSE_XML(
            '<langL>' ||
            LISTAGG(
                '<lang>' ||
                IFF(cte_l.langNm IS NOT NULL, '<langNm>' || cte_l.langNm || '</langNm>', '') ||
                IFF(cte_l.langCd IS NOT NULL, '<langCd>' || cte_l.langCd || '</langCd>', '') ||
                '</lang>'
            , '') ||
            '</langL>'
        ) AS VARIANT) AS XMLValue
    FROM CTE_Language cte_l
    GROUP BY cte_l.ProviderID
),

------------------------MalpracticeXML------------------------
--- Validated: ~5k non-null rows on both sides
CTE_Malpractice AS (
    SELECT
        mp.ProviderID,
        mp.MalpracticeClaimTypeCode AS malC,
        mp.MalpracticeClaimTypeDescription AS malD,
        mp.ClaimNumber AS clNum,
        mp.ClaimDate AS clDt,
        mp.ClaimYear AS clYr,
        mp.ClaimAmount AS clAmt,
        mp.Complaint AS cmplt,
        mp.IncidentDate AS inDt,
        mp.ClosedDate AS endDt,
        mp.ClaimState AS malSt,
        mp.ClaimStateFull AS malStFl,
        mp.LicenseNumber AS LicNum,
        mp.ReportDate AS reDt
    FROM Mid.ProviderMalpractice mp
    INNER JOIN Base.MalpracticeState ms ON mp.ClaimState = ms.State
        AND IFNULL(ms.Active, 1) = 1
),

CTE_MalpracticeXML AS (
    SELECT
        cte_mp.ProviderID,
        TRY_CAST(PARSE_XML(
            '<malL>' ||
            LISTAGG(
                '<mal>' ||
                IFF(cte_mp.malC IS NOT NULL, '<malC>' || cte_mp.malC || '</malC>', '') ||
                IFF(cte_mp.malD IS NOT NULL, '<malD>' || cte_mp.malD || '</malD>', '') ||
                IFF(cte_mp.clNum IS NOT NULL, '<clNum>' || cte_mp.clNum || '</clNum>', '') ||
                IFF(cte_mp.clDt IS NOT NULL, '<clDt>' || cte_mp.clDt || '</clDt>', '') ||
                IFF(cte_mp.clYr IS NOT NULL, '<clYr>' || cte_mp.clYr || '</clYr>', '') ||
                IFF(cte_mp.clAmt IS NOT NULL, '<clAmt>' || cte_mp.clAmt || '</clAmt>', '') ||
                IFF(cte_mp.cmplt IS NOT NULL, '<cmplt>' || cte_mp.cmplt || '</cmplt>', '') ||
                IFF(cte_mp.inDt IS NOT NULL, '<inDt>' || cte_mp.inDt || '</inDt>', '') ||
                IFF(cte_mp.endDt IS NOT NULL, '<endDt>' || cte_mp.endDt || '</endDt>', '') ||
                IFF(cte_mp.malSt IS NOT NULL, '<malSt>' || cte_mp.malSt || '</malSt>', '') ||
                IFF(cte_mp.malStFl IS NOT NULL, '<malStFl>' || cte_mp.malStFl || '</malStFl>', '') ||
                IFF(cte_mp.LicNum IS NOT NULL, '<LicNum>' || cte_mp.LicNum || '</LicNum>', '') ||
                IFF(cte_mp.reDt IS NOT NULL, '<reDt>' || cte_mp.reDt || '</reDt>', '') ||
                '</mal>'
            , '') ||
            '</malL>'
        ) AS VARIANT) AS XMLValue
    FROM CTE_Malpractice cte_mp
    GROUP BY cte_mp.ProviderID
),

------------------------SanctionXML------------------------
-- this one is funky: all nulls in SQL Server but we have ~12k rows? Interesting
CTE_ProviderSanction AS (
    SELECT
        ps.ProviderID,
        CASE
            WHEN ps.SanctionDescription LIKE 'hgpy%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%www.%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%HTTP%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%://%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%.gov%' THEN 'Please reference the following Document'
            ELSE ps.SanctionDescription
        END AS sancD,
        ps.SanctionDate AS sDt,
        ps.ReinstatementDate AS reinDt,
        ps.SanctionTypeCode AS sTyp,
        ps.SanctionTypeDescription AS sTypD,
        ps.State AS lSt,
        ps.SanctionCategoryCode AS sCat,
        ps.SanctionCategoryDescription AS sCatD,
        ps.SanctionActionCode AS sActC,
        ps.SanctionActionDescription AS sActD,
        CASE
            WHEN ps.SanctionDescription LIKE 'hgpy%' THEN 'https://www.healthgrades.com/media/english/pdf/sanctions/' || LTRIM(RTRIM(ps.SanctionDescription)) || '.pdf'
            WHEN ps.SanctionDescription LIKE '%www.%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            WHEN ps.SanctionDescription LIKE '%HTTP%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            WHEN ps.SanctionDescription LIKE '%://%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            WHEN ps.SanctionDescription LIKE '%.gov%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            ELSE ''
        END AS pdfUrl,
        ps.StateFull AS lStFl
    FROM Mid.ProviderSanction AS ps
),

CTE_SanctionXML AS (
    SELECT
        cte_ps.ProviderID,
        TRY_CAST(PARSE_XML(
            '<sancL>' ||
            LISTAGG(
                '<sanc>' ||
                IFF(cte_ps.sancD IS NOT NULL, '<sancD>' || cte_ps.sancD || '</sancD>', '') ||
                IFF(cte_ps.sDt IS NOT NULL, '<sDt>' || cte_ps.sDt || '</sDt>', '') ||
                IFF(cte_ps.reinDt IS NOT NULL, '<reinDt>' || cte_ps.reinDt || '</reinDt>', '') ||
                IFF(cte_ps.sTyp IS NOT NULL, '<sTyp>' || cte_ps.sTyp || '</sTyp>', '') ||
                IFF(cte_ps.sTypD IS NOT NULL, '<sTypD>' || cte_ps.sTypD || '</sTypD>', '') ||
                IFF(cte_ps.lSt IS NOT NULL, '<lSt>' || cte_ps.lSt || '</lSt>', '') ||
                IFF(cte_ps.sCat IS NOT NULL, '<sCat>' || cte_ps.sCat || '</sCat>', '') ||
                IFF(cte_ps.sCatD IS NOT NULL, '<sCatD>' || cte_ps.sCatD || '</sCatD>', '') ||
                IFF(cte_ps.sActC IS NOT NULL, '<sActC>' || cte_ps.sActC || '</sActC>', '') ||
                IFF(cte_ps.sActD IS NOT NULL, '<sActD>' || cte_ps.sActD || '</sActD>', '') ||
                IFF(cte_ps.pdfUrl IS NOT NULL, '<pdfUrl>' || cte_ps.pdfUrl || '</pdfUrl>', '') ||
                IFF(cte_ps.lStFl IS NOT NULL, '<lStFl>' || cte_ps.lStFl || '</lStFl>', '') ||
                '</sanc>'
            , '') ||
            '</sancL>'
        ) AS VARIANT) AS XMLValue
    FROM CTE_ProviderSanction cte_ps
    GROUP BY cte_ps.ProviderID
),

------------------------BoardActionXML------------------------
--- Validated: ~12k non-null rows on both sides
CTE_BoardAction AS (
    SELECT
        ps.ProviderID,
        CASE
            WHEN ps.SanctionDescription LIKE 'hgpy%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%www.%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%HTTP%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%://%' THEN 'Please reference the following Document'
            WHEN ps.SanctionDescription LIKE '%.gov%' THEN 'Please reference the following Document'
            ELSE ps.SanctionDescription
        END AS sancD,
        ps.SanctionDate AS sDt,
        ps.SanctionReinstatementDate AS reinDt,
        st.SanctionTypeCode AS sTyp,
        st.SanctionTypeDescription AS sTypD,
        sra.State AS lSt,
        sc.SanctionCategoryCode AS sCat,
        sc.SanctionCategoryDescription AS sCatD,
        sa.SanctionActionCode AS sActC,
        sa.SanctionActionDescription AS sActD,
        CASE
            WHEN ps.SanctionDescription LIKE 'hgpy%' THEN 'https://www.healthgrades.com/media/english/pdf/sanctions/' || LTRIM(RTRIM(ps.SanctionDescription)) || '.pdf'
            WHEN ps.SanctionDescription LIKE '%www.%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            WHEN ps.SanctionDescription LIKE '%HTTP%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            WHEN ps.SanctionDescription LIKE '%://%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            WHEN ps.SanctionDescription LIKE '%.gov%' THEN LTRIM(RTRIM(ps.SanctionDescription))
            ELSE ''
        END AS pdfUrl,
        s.StateName AS lStFl,
        sra.StateReportingAgencyCode AS sBrdCd,
        sra.StateReportingAgencyDescription AS sBrdNm,
        sra.StateReportingAgencyURL AS sBrdUrl,
        ps.SanctionDate AS sAccDt
    FROM
        Base.ProviderSanction AS ps
        INNER JOIN Base.SanctionType st ON ps.SanctionTypeID = st.SanctionTypeID
        INNER JOIN Base.SanctionCategory sc ON ps.SanctionCategoryID = sc.SanctionCategoryID
        INNER JOIN Base.SanctionAction sa ON ps.SanctionActionID = sa.SanctionActionID
        INNER JOIN Base.StateReportingAgency sra ON ps.StateReportingAgencyID = sra.StateReportingAgencyID
        INNER JOIN Base.SanctionActionType sat ON sa.SanctionActionTypeID = sat.SanctionActionTypeID
        LEFT JOIN Base.State s ON sra.State = s.State
),

CTE_BoardActionXML AS (
    SELECT
        cte_ba.ProviderID,
        TRY_CAST(PARSE_XML(
            '<sancL>' ||
            LISTAGG(
                '<sanc>' ||
                IFF(cte_ba.sancD IS NOT NULL, '<sancD>' || UTILS.CLEAN_XML(cte_ba.sancD) || '</sancD>', '') ||
                IFF(cte_ba.sDt IS NOT NULL, '<sDt>' || cte_ba.sDt || '</sDt>', '') ||
                IFF(cte_ba.reinDt IS NOT NULL, '<reinDt>' || cte_ba.reinDt || '</reinDt>', '') ||
                IFF(cte_ba.sTyp IS NOT NULL, '<sTyp>' || UTILS.CLEAN_XML(cte_ba.sTyp) || '</sTyp>', '') ||
                IFF(cte_ba.sTypD IS NOT NULL, '<sTypD>' || UTILS.CLEAN_XML(cte_ba.sTypD) || '</sTypD>', '') ||
                IFF(cte_ba.lSt IS NOT NULL, '<lSt>' || UTILS.CLEAN_XML(cte_ba.lSt) || '</lSt>', '') ||
                IFF(cte_ba.sCat IS NOT NULL, '<sCat>' || UTILS.CLEAN_XML(cte_ba.sCat) || '</sCat>', '') ||
                IFF(cte_ba.sCatD IS NOT NULL, '<sCatD>' || UTILS.CLEAN_XML(cte_ba.sCatD) || '</sCatD>', '') ||
                IFF(cte_ba.sActC IS NOT NULL, '<sActC>' || UTILS.CLEAN_XML(cte_ba.sActC) || '</sActC>', '') ||
                IFF(cte_ba.sActD IS NOT NULL, '<sActD>' || UTILS.CLEAN_XML(cte_ba.sActD) || '</sActD>', '') ||
                IFF(cte_ba.pdfUrl IS NOT NULL, '<pdfUrl>' || UTILS.CLEAN_XML(cte_ba.pdfUrl) || '</pdfUrl>', '') ||
                IFF(cte_ba.lStFl IS NOT NULL, '<lStFl>' || UTILS.CLEAN_XML(cte_ba.lStFl) || '</lStFl>', '') ||
                IFF(cte_ba.sBrdCd IS NOT NULL, '<sBrdCd>' || UTILS.CLEAN_XML(cte_ba.sBrdCd) || '</sBrdCd>', '') ||
                IFF(cte_ba.sBrdNm IS NOT NULL, '<sBrdNm>' || UTILS.CLEAN_XML(cte_ba.sBrdNm) || '</sBrdNm>', '') ||
                IFF(cte_ba.sBrdUrl IS NOT NULL, '<sBrdUrl>' || UTILS.CLEAN_XML(cte_ba.sBrdUrl) || '</sBrdUrl>', '') ||
                IFF(cte_ba.sAccDt IS NOT NULL, '<sAccDt>' || cte_ba.sAccDt || '</sAccDt>', '') ||
                '</sanc>'
            , '') ||
            '</sancL>'
        ) AS VARIANT) AS XMLValue
    FROM
        CTE_BoardAction cte_ba
    GROUP BY
        cte_ba.ProviderID
),

------------------------NatlAdvertisingXML------------------------
-- Not validated due to 0 rows: explanations below in individual CTEs
-- this CTE gives 340 rows in SQL Server, but 20 in Snowflake...
-- CTE_AdFeatures AS (
--     SELECT
--         a.EntityID,
--         LISTAGG(
--             '<adFeat>' ||
--             '<featCd>' || ClientFeatureCode || '</featCd>' ||
--             '<featDesc>' || d.ClientFeatureDescription || '</featDesc>' ||
--             '<featValCd>' || e.ClientFeatureValueCode || '</featValCd>' ||
--             '<featValDesc>' || e.ClientFeatureValueDescription || '</featValDesc>' ||
--             '</adFeat>'
--         , '') AS adFeatXML
--     FROM
--         Base.ClientEntityToClientFeature a
--         JOIN Base.EntityType b ON a.EntityTypeID = b.EntityTypeID
--         JOIN Base.ClientFeatureToClientFeatureValue c ON a.ClientFeatureToClientFeatureValueID = c.ClientFeatureToClientFeatureValueID
--         JOIN Base.ClientFeature d ON c.ClientFeatureID = d.ClientFeatureID
--         JOIN Base.ClientFeatureValue e ON e.ClientFeatureValueID = c.ClientFeatureValueID
--         JOIN Base.ClientFeatureGroup f ON d.ClientFeatureGroupID = f.ClientFeatureGroupID
--     WHERE b.EntityTypeCode = 'CLPROD'
--     GROUP BY a.EntityID
-- ),

-- -- Now this CTE has 0 rows, which is what causes all the XMLs to be NULLs. But I don't see
-- -- where is the error, I'm simply doing a left join to deal with the original subquery 
-- -- which is unsupported in Snowflake.
-- CTE_Ads AS (
--     SELECT
--         u.ProviderCode,
--         u.ProductCode,
--         u.ProductGroupCode,
--         u.AppointmentOptionDescription,
--         '<ad>' ||
--         '<adCd>' || u.ClientCode || '</adCd>' ||
--         '<adNm>' || u.ClientName || '</adNm>' ||
--         '<caToActMsg>' || u.CallToActionMsg || '</caToActMsg>' ||
--         '<safHarMsg>' || u.SafeHarborMsg || '</safHarMsg>' ||
--         '<adFeatL>' || COALESCE(cte_af.adFeatXML, '') || '</adFeatL>' ||
--         '</ad>' AS adXML
--     FROM Mid.ProviderSponsorship u
--     LEFT JOIN CTE_AdFeatures cte_af ON u.ClientToProductID = cte_af.EntityID
--     WHERE u.ProductGroupCode = 'LID'
-- ),

-- CTE_NatlAdvertising AS (
--     SELECT
--         p.ProviderID,
--         '<natladv>' ||
--         '<prCd>' || a.ProductCode || '</prCd>' ||
--         '<prGrCd>' || a.ProductGroupCode || '</prGrCd>' ||
--         '<adL>' || LISTAGG(a.adXML, '') || '</adL>' ||
--         '<aptOptDesc>' || MAX(a.AppointmentOptionDescription) || '</aptOptDesc>' ||
--         '</natladv>' AS natladvXML
--     FROM
--         CTE_Ads a
--     JOIN Base.Provider p on a.ProviderCode = p.ProviderCode
--     GROUP BY
--         p.ProviderID,
--         a.ProductCode,
--         a.ProductGroupCode
-- ),

-- CTE_NatlAdvertisingXML AS (
--     SELECT
--         p.ProviderId,
--         TRY_CAST(PARSE_XML(
--             '<natladvL>' ||
--             COALESCE(LISTAGG(na.natladvXML, ''), '') ||
--             '</natladvL>'
--         ) AS VARIANT) AS XMLValue
--     FROM CTE_Provider_Batch p
--     LEFT JOIN CTE_NatlAdvertising na ON p.ProviderID = na.ProviderID
--     GROUP BY
--         p.ProviderId
-- )
CTE_AdFeatures AS (
    SELECT
        a.EntityID AS ClientToProductID,
        LISTAGG(
            '<adFeat>' ||
            '<featCd>' || UTILS.CLEAN_XML(ClientFeatureCode) || '</featCd>' ||
            '<featDesc>' || UTILS.CLEAN_XML(d.ClientFeatureDescription) || '</featDesc>' ||
            '<featValCd>' || UTILS.CLEAN_XML(e.ClientFeatureValueCode) || '</featValCd>' ||
            '<featValDesc>' || UTILS.CLEAN_XML(e.ClientFeatureValueDescription) || '</featValDesc>' ||
            '</adFeat>'
        , '') AS adFeatXML
    FROM
        Base.ClientEntityToClientFeature a
        JOIN Base.EntityType b ON a.EntityTypeID = b.EntityTypeID
        JOIN Base.ClientFeatureToClientFeatureValue c ON a.ClientFeatureToClientFeatureValueID = c.ClientFeatureToClientFeatureValueID
        JOIN Base.ClientFeature d ON c.ClientFeatureID = d.ClientFeatureID
        JOIN Base.ClientFeatureValue e ON e.ClientFeatureValueID = c.ClientFeatureValueID
        JOIN Base.ClientFeatureGroup f ON d.ClientFeatureGroupID = f.ClientFeatureGroupID
    WHERE
        b.EntityTypeCode = 'CLPROD'
    GROUP BY
        a.EntityID
),

CTE_Ads AS (
    SELECT
        u.ProviderCode,
        u.ProductCode,
        u.ProductGroupCode,
        LISTAGG(
            '<ad>' ||
            '<adCd>' || UTILS.CLEAN_XML(u.ClientCode) || '</adCd>' ||
            '<adNm>' || UTILS.CLEAN_XML(u.ClientName) || '</adNm>' ||
            '<caToActMsg>' || UTILS.CLEAN_XML(u.CallToActionMsg) || '</caToActMsg>' ||
            '<safHarMsg>' || UTILS.CLEAN_XML(u.SafeHarborMsg) || '</safHarMsg>' ||
            '<adFeatL>' || COALESCE(af.adFeatXML, '') || '</adFeatL>' ||
            '</ad>'
        , '') AS adXML
    FROM
        Mid.ProviderSponsorship u
        LEFT JOIN CTE_AdFeatures af ON u.ClientToProductID = af.ClientToProductID
    -- In SQL Server we have 2 distinct ProductGroupCodes: 'LID' and 'PDC' in Mid.ProviderSponsorship. HOWEVER,
    -- in Snowflake we only have 'PDC' values.
    -- WHERE u.ProductGroupCode = 'LID'
       WHERE u.ProductGroupCode = 'PDC'
    GROUP BY
        u.ProviderCode,
        u.ProductCode,
        u.ProductGroupCode
),

CTE_NationalAdvertising AS (
    SELECT
        a.ProviderCode,
        LISTAGG(
            '<natladv>' ||
            '<prCd>' || UTILS.CLEAN_XML(a.ProductCode) || '</prCd>' ||
            '<prGrCd>' || UTILS.CLEAN_XML(a.ProductGroupCode) || '</prGrCd>' ||
            '<adL>' || COALESCE(ca.adXML, '') || '</adL>' ||
            '<aptOptDesc>' || UTILS.CLEAN_XML(a.AppointmentOptionDescription) || '</aptOptDesc>' ||
            '</natladv>'
        , '') AS natladvXML
    FROM
        Mid.ProviderSponsorship a
        LEFT JOIN CTE_Ads ca ON a.ProviderCode = ca.ProviderCode
            AND a.ProductCode = ca.ProductCode
            AND a.ProductGroupCode = ca.ProductGroupCode
    WHERE
        a.ProductGroupCode = 'LID'
    GROUP BY
        a.ProviderCode
),

CTE_NatlAdvertisingXML AS (
    SELECT
        p.ProviderId,
        TRY_CAST(PARSE_XML(
            '<natladvL>' ||
            COALESCE(na.natladvXML, '') ||
            '</natladvL>'
        ) AS VARIANT) AS XMLValue
    FROM
        Show.SOLRProvider s
        INNER JOIN mid.Provider p ON s.ProviderID = p.ProviderID
        LEFT JOIN CTE_NationalAdvertising na ON p.ProviderCode = na.ProviderCode
),

------------------------SyndicationXML------------------------
-- for the full this CTE gave me 4k rows in Snowflake compared to 
-- 600k in SQL Server, which most definitely propagates to having a lot 
-- less SyndicationXML non-NULLs. For example, we are joining with Base.ClientProductToEntity
-- which has +70% less rows in Snowflake, so things like this are obviously propagated.

CTE_FacilityPhones AS (
    SELECT
        tp.ProviderId,
        f.FacilityCode,
        cptedp.PhoneNumber AS Phone,
        cpte.ClientToProductID,
        mps.ClientCode,
        mps.ProductCode,
        mps.ProductGroupCode,
        cptedp.DisplayPartnerCode AS SyndicationPartnerCode,
        pt.PhoneTypeCode
    FROM
        CTE_Provider_Batch tp
        INNER JOIN Base.Provider p ON p.ProviderID = tp.ProviderID
        INNER JOIN Mid.ProviderSponsorship mps ON mps.ProviderCode = p.ProviderCode
        INNER JOIN Base.ProviderToFacility ptf ON ptf.ProviderID = p.ProviderID
        INNER JOIN Base.Facility f ON f.FacilityID = ptf.FacilityID
        INNER JOIN Base.ClientProductToEntity cpte ON cpte.EntityID = f.FacilityID
        INNER JOIN Base.ClientProductEntityToDisplayPartnerPhone cptedp ON cptedp.ClientProductToEntityID = cpte.ClientProductToEntityID
        INNER JOIN Base.PhoneType pt ON pt.PhoneTypeID = cptedp.PhoneTypeID
    WHERE
        mps.ProductGroupCode <> 'LID'
        AND mps.ProductCode IN (
            SELECT
                ProductCode
            FROM
                Base.Product
            WHERE
                ProductTypeCode != 'PRACTICE'
        )
        AND mps.ProductCode IN ('PDCHSP', 'MAP')
),

CTE_ClientPhones AS (
    SELECT
        DISTINCT tp.ProviderID,
        ctp.ClientToProductID,
        cptedp.DisplayPartnerCode AS SyndicationPartnerCode,
        cptedp.PhoneNumber,
        pt.PhoneTypeCode,
        mps.ClientCode,
        mps.ProductCode,
        mps.ProductGroupCode
    FROM
        CTE_Provider_Batch tp
        INNER JOIN Base.Provider p ON p.ProviderID = tp.ProviderID
        INNER JOIN Mid.ProviderSponsorship mps ON mps.ProviderCode = p.ProviderCode
        INNER JOIN Base.ClientProductToEntity CPE ON cpe.EntityID = p.ProviderID
        INNER JOIN Base.ClientToProduct ctp ON ctp.ClientToProductID = cpe.ClientToProductID
        INNER JOIN Base.ClientProductToEntity cpte ON cpte.EntityID = ctp.ClientToProductID
        INNER JOIN Base.ClientProductEntityToDisplayPartnerPhone cptedp ON cptedp.ClientProductToEntityID = cpte.ClientProductToEntityID
        INNER JOIN Base.PhoneType pt ON pt.PhoneTypeID = cptedp.PhoneTypeID
    WHERE
        mps.ProductGroupCode <> 'LID'
        AND mps.ProductCode IN (
            SELECT
                ProductCode
            FROM
                Base.Product
            WHERE
                ProductTypeCode != 'PRACTICE'
        )
        AND mps.ProductCode in ('PDCHSP', 'MAP')
),
CTE_SyndicationPDCHSP AS (
    SELECT
        ProviderID,
        ClientToProductID,
        ClientCode,
        ProductCode,
        ProductGroupCode,
        SyndicationPartnerCode
    FROM
        CTE_FacilityPhones
    UNION
    SELECT
        ProviderID,
        ClientToProductID,
        ClientCode,
        ProductCode,
        ProductGroupCode,
        SyndicationPartnerCode
    FROM
        CTE_ClientPhones
),
CTE_SP AS (
    SELECT
        SP.ProviderID,
        SP.SyndicationPartnerCode AS syndSpnCd
    FROM
        CTE_SyndicationPDCHSP SP
    WHERE
        SP.ProductCode = 'PDCHSP'
    GROUP BY
        SP.ProviderID,
        SP.SyndicationPartnerCode,
        SP.CLientToProductId
),
CTE_SP2 AS (
    SELECT
        SP2.ProviderID,
        SP2.ClientCode AS spn,
        SP2.ProductCode AS prCd,
        SP2.ProductGroupCode AS prGrCd
    FROM
        CTE_SyndicationPDCHSP SP2
        INNER JOIN CTE_SyndicationPDCHSP SP ON SP2.ProviderID = SP.ProviderID
    WHERE
        SP2.ProviderID = SP.ProviderID
        AND SP2.ClientToProductID = SP.ClientToProductID
        AND SP2.SyndicationPartnerCode = SP.SyndicationPartnerCode
        AND SP2.ProductCode = 'PDCHSP'
    GROUP BY
        SP2.ClientCode,
        SP2.ProductCode,
        SP2.ProductGroupCode,
        SP2.ProviderID,
        SP2.ClientToProductID,
        SP2.SyndicationPartnerCode
),
CTE_FP AS (
    SELECT
        FP.ProviderID,
        FP.FacilityCode AS fCd,
    FROM
        CTE_FacilityPhones FP
        INNER JOIN CTE_SyndicationPDCHSP SP2 ON SP2.ProviderID = FP.ProviderID
    WHERE
        FP.ClientToProductID = SP2.ClientToProductID
        AND FP.SyndicationPartnerCode = SP2.SyndicationPartnerCode
        AND FP.ProductCode = 'PDCHSP'
    GROUP BY
        FP.ClientToProductID,
        FP.ProviderID,
        FP.FacilityCode
),
CTE_FP2 AS (
    SELECT
        DISTINCT FP2.ProviderID,
        FP.FacilityCode AS fCd,
        FP2.Phone AS ph,
        FP2.PhoneTypeCode AS phTyp
    FROM
        CTE_FacilityPhones FP2
        INNER JOIN CTE_SyndicationPDCHSP SP2 ON FP2.ProviderID = SP2.ProviderID
        INNER JOIN CTE_FacilityPhones FP ON FP2.FacilityCode = FP.FacilityCode
    WHERE
        FP2.ClientToProductID = SP2.ClientToProductID
        AND FP2.SyndicationPartnerCode = SP2.SyndicationPartnerCode
        AND FP2.ProductCode = 'PDCHSP'
    GROUP BY
        fCd,
        FP2.ClientToProductID,
        FP2.ProviderID,
        FP2.FacilityCode,
        FP2.Phone,
        FP2.PhoneTypeCode
),
CTE_CP AS (
    SELECT
        DISTINCT cp.ProviderID,
        cp.PhoneNumber AS ph,
        cp.PhoneTypeCode AS phTyp
    FROM
        CTE_ClientPhones CP
        INNER JOIN CTE_SyndicationPDCHSP SP2 ON cp.ClientToProductID = sp2.ClientToProductID
    WHERE
        cp.SyndicationPartnerCode = sp2.SyndicationPartnerCode
        AND cp.ProductCode = 'PDCHSP'
),
CTE_SyndicationXML AS (
    SELECT
        cte_s.ProviderID,
        TRY_CAST(PARSE_XML(
            '<syndL>' ||
            IFF(cte_sp.syndSpnCd IS NOT NULL, '<syndSpnCd>' || cte_sp.syndSpnCd || '</syndSpnCd>', '') ||
            '<spnL>' ||
            LISTAGG(
                '<spn>' ||
                IFF(cte_sp2.spn IS NOT NULL, '<spnCd>' || cte_sp2.spn || '</spnCd>', '') ||
                IFF(cte_sp2.prCd IS NOT NULL, '<prCd>' || cte_sp2.prCd || '</prCd>', '') ||
                IFF(cte_sp2.prGrCd IS NOT NULL, '<prGrCd>' || cte_sp2.prGrCd || '</prGrCd>', '') ||
                '</spn>'
            , '') ||
            '</spnL>' ||
            '<fphL>' ||
            LISTAGG(
                '<fph>' ||
                IFF(cte_fp2.fCd IS NOT NULL, '<fCd>' || cte_fp2.fCd || '</fCd>', '') ||
                IFF(cte_fp2.ph IS NOT NULL, '<ph>' || cte_fp2.ph || '</ph>', '') ||
                IFF(cte_fp2.phTyp IS NOT NULL, '<phTyp>' || cte_fp2.phTyp || '</phTyp>', '') ||
                '</fph>'
            , '') ||
            '</fphL>' ||
            '<cphL>' ||
            LISTAGG(
                '<cph>' ||
                IFF(cte_cp.ph IS NOT NULL, '<ph>' || cte_cp.ph || '</ph>', '') ||
                IFF(cte_cp.phTyp IS NOT NULL, '<phTyp>' || cte_cp.phTyp || '</phTyp>', '') ||
                '</cph>'
            , '') ||
            '</cphL>' ||
            '</syndL>'
        ) AS VARIANT) AS XMLValue
    FROM
        CTE_SyndicationPDCHSP cte_s
        LEFT JOIN CTE_SP ON cte_s.ProviderID = cte_sp.ProviderID
        LEFT JOIN CTE_SP2 ON cte_s.ProviderID = cte_sp2.ProviderID
        LEFT JOIN CTE_FP ON cte_s.ProviderID = cte_fp.ProviderID
        LEFT JOIN CTE_FP2 ON cte_s.ProviderID = cte_fp2.ProviderID
        LEFT JOIN CTE_CP ON cte_s.ProviderID = cte_cp.ProviderID
    WHERE
        cte_s.ProductCode = 'PDCHSP'
    GROUP BY
        cte_s.ProviderID,
        cte_sp.syndSpnCd
)

SELECT DISTINCT
    p.providerid,
    p.providercode, 
    tele.xmlvalue AS telehealthxml,
    ptype.xmlvalue AS providertypexml,
    poffice.xmlvalue AS practiceofficexml,
    addr.xmlvalue AS addressxml,
    spec.xmlvalue AS specialtyxml,
    pract_spec.xmlvalue AS practicingspecialtyxml,
    cert.xmlvalue AS certificationxml,
    edu.xmlvalue AS educationxml,
    -- org.xmlvalue AS professionalorganizationxml,
    licensexml.xmlvalue AS licensexml,
    lang.xmlvalue AS languagexml,
    mal.xmlvalue AS malpracticexml,
    sanctionxml.xmlvalue AS sanctionxml,
    baction.xmlvalue AS boardactionxml,
    adxml.xmlvalue AS natladvertisingxml,
    synd.xmlvalue AS syndicationxml,
    CASE WHEN poffice.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasAddressXML,
    CASE WHEN spec.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasSpecialtyXML,
    CASE WHEN pract_spec.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasPracticingSpecialtyXML,
    CASE WHEN cert.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasCertificationXML,
    CASE WHEN mal.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasMalpracticeXML,
    CASE WHEN sanctionxml.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasSanctionXML,
    CASE WHEN baction.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasBoardActionXML,
    -- CASE WHEN org.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasProfessionalOrganizationXML
FROM Show.SolrProvider as P
    LEFT JOIN CTE_TelehealthXML AS tele ON tele.providerid = p.providerid -- 1
    LEFT JOIN CTE_ProviderTypeXML AS ptype ON ptype.providerid = p.providerid -- 2
    LEFT JOIN CTE_PracticeOfficeXML AS poffice ON poffice.providerid = p.providerid -- 3
    LEFT JOIN CTE_AddressXML AS addr ON addr.providerid = p.providerid -- 4
    LEFT JOIN CTE_SpecialtyXML AS spec ON spec.providerid = p.providerid -- 5
    LEFT JOIN CTE_PracticingSpecialtyXML AS pract_spec ON pract_spec.providerid = p.providerid -- 6
    LEFT JOIN CTE_CertificationXML AS cert ON cert.providerid = p.providerid -- 7
    LEFT JOIN CTE_EducationXML AS edu ON edu.providerid = p.providerid -- 8
    -- LEFT JOIN CTE_ProfessionalOrganizationXML AS org ON org.providerid = p.providerid -- 9 (ignore, empty in SQL Server)
    LEFT JOIN CTE_LicenseXML AS licensexml ON licensexml.providerid = p.providerid -- 10
    LEFT JOIN CTE_LanguageXML AS lang ON lang.providerid = p.providerid -- 11
    LEFT JOIN CTE_MalpracticeXML AS mal ON mal.providerid = p.providerid -- 12
    LEFT JOIN CTE_SanctionXML AS sanctionxml ON sanctionxml.providerid = p.providerid -- 13
    LEFT JOIN CTE_BoardActionXML AS baction ON baction.providerid = p.providerid -- 14
    LEFT JOIN CTE_NatlAdvertisingXML AS adxml ON adxml.providerid = p.providerid -- 15
    LEFT JOIN CTE_SyndicationXML AS synd ON synd.providerid = p.providerid -- 16
$$;

select_statement_xml_load_3 := 
$$
------------------------ProcedureXML------------------------

with cte_prov_Proc AS (
    SELECT 
        etmt.EntityID, 
        mt.MedicalTermCode AS prC, 
        mt.MedicalTermDescription1 AS prD, 
        NULL AS prGD, 
        NULL AS lKey,
        etmt.NationalRankingA AS nrkA, 
        etmt.NationalRankingB AS nrkB, 
        etmt.SearchBoostExperience AS boostExp,
        etmt.FriendsAndFamilyDCPExperienceRatingPercent AS ffExpPscr,
        IFF(etmt.SearchBoostHospitalCohortQuality IS NOT NULL, etmt.SearchBoostHospitalCohortQuality, etmt.SearchBoostHospitalServiceLineQuality) AS boostQual,
        etmt.FriendsAndFamilyDCPQualityFacility AS ffQFac, 
        etmt.FriendsAndFamilyDCPQualityFacilityList AS ffQFacLst, 
        etmt.FriendsAndFamilyDCPQualityFacilityListLatLong AS ffQFacLatLongList,
        etmt.FriendsAndFamilyDCPQualityFacRatingPerList AS ffQFacScrLst,
        etmt.FriendsAndFamilyDCPQualityFacilityScoreList AS ffQFacHQList,
        etmt.FriendsAndFamilyDCPQualityZScore AS ffQZscr,
        etmt.FriendsAndFamilyDCPQualityRatingPercent AS ffQPscr, 
        etmt.FriendsAndFamilyDCPQualityCode AS ffQCd,
        CASE 
            WHEN etmt.FriendsAndFamilyDCPQualityCode IS NOT NULL AND rcp.CohortCode IS NOT NULL THEN 1
            WHEN etmt.FriendsAndFamilyDCPQualityCode IS NULL THEN NULL 
            ELSE 0 
        END AS IsCohort, 
        etmt.PatientCount AS vol,
        etmt.SourceSearch AS sSrch, 
        mt.VolumeIsCredible AS vCred, 
        mt.RefMedicalTermCode AS prRC, 
        mt.WebArticleURL AS aUrl,
        etmt.PatientCountIsFew, 
        etmt.MedicalTermID, 
        etmt.FFExpBoost, 
        etmt.FFQualityFaciltyWeightList AS FFHQualityWList, 
        etmt.FFHQualityWinWeight AS FFHQualityWinW
    FROM 
        Base.EntityToMedicalTerm etmt
        JOIN Show.solrProvider tprov ON etmt.EntityID = tprov.ProviderID
        JOIN Base.MedicalTerm mt ON etmt.MedicalTermID = mt.MedicalTermID
        JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID
        LEFT JOIN (
            SELECT DISTINCT CohortCode, ProcedureMedicalCode
            FROM Base.CohortToProcedure
        ) rcp ON rcp.CohortCode = etmt.FriendsAndFamilyDCPQualityCode AND rcp.ProcedureMedicalCode = mt.RefMedicalTermCode
    WHERE 
        mtt.MedicalTermTypeCode = 'Procedure' 
        AND COALESCE(etmt.IsPreview, 0) = 0
),

cte_prov_perf AS (
    SELECT 
        p.ProviderID, 
        emt.MedicalTermID, 
        MAX(to_decimal(stpm.Perform)) AS Perform
    FROM Base.ProviderToSpecialty pts
    JOIN cte_prov_Proc emt ON pts.ProviderID = emt.EntityID
    JOIN Base.SpecialtyToProcedureMedical stpm ON stpm.SpecialtyID = pts.SpecialtyID AND stpm.ProcedureMedicalID = emt.MedicalTermID
    JOIN Show.SolrProvider as p on p.providerid = pts.providerid
    WHERE 
        emt.PatientCountIsFew IS NOT NULL OR 
        emt.vol IS NOT NULL
    GROUP BY 
        p.ProviderID, 
        emt.MedicalTermID
),

cte_procedure as (
    SELECT 
        pp.providerid,
        p.prC, 
        p.prD, 
        p.prGD, 
        p.lKey,
        p.nrkA,
        p.nrkB, 
        p.boostExp, 
        p.ffExpPscr, 
        p.boostQual, 
        p.ffQFac,
        p.ffQFacLst, 
        p.ffQFacScrLst, 
        p.ffQFacHQList, 
        p.ffQFacLatLongList, 
        p.ffQZscr, 
        p.ffQPscr, 
        p.ffQCd, 
        p.IsCohort, 
        p.vol, 
        p.sSrch, 
        p.vCred, 
        p.prRC, 
        p.aUrl, 
        IFF(pp.ProviderID IS NULL, 1, pp.Perform) AS perform,
        p.FFExpBoost, 
        p.FFHQualityWList, 
        p.FFHQualityWinW
    FROM 
        cte_prov_Proc p
    LEFT JOIN 
        cte_prov_Perf pp ON pp.ProviderID = p.EntityID AND pp.MedicalTermID = p.MedicalTermID
    WHERE 
        providerid is not null
),

cte_procedure_xml as (
    SELECT
        ProviderID, 
        '<prcL>' || listagg( '<prc>' || iff(prC is not null,'<prC>' || prC || '</prC>','') ||
        iff(prD is not null,'<prD>' || prD || '</prD>','') ||
        iff(prGD is not null,'<prGD>' || prGD || '</prGD>','') ||
        iff(lKey is not null,'<lKey>' || lKey || '</lKey>','') ||
        iff(nrkA is not null,'<nrkA>' || nrkA || '</nrkA>','') ||
        iff(nrkB is not null,'<nrkB>' || nrkB || '</nrkB>','') ||
        iff(boostExp is not null,'<boostExp>' || boostExp || '</boostExp>','') ||
        iff(ffExpPscr is not null,'<ffExpPscr>' || ffExpPscr || '</ffExpPscr>','') ||
        iff(boostQual is not null,'<boostQual>' || boostQual || '</boostQual>','') ||
        iff(ffQFac is not null,'<ffQFac>' || ffQFac || '</ffQFac>','') ||
        iff(ffQFacLst is not null,'<ffQFacLst>' || ffQFacLst || '</ffQFacLst>','') ||
        iff(ffQFacScrLst is not null,'<ffQFacScrLst>' || ffQFacScrLst || '</ffQFacScrLst>','') ||
        iff(ffQFacHQList is not null,'<ffQFacHQList>' || ffQFacHQList || '</ffQFacHQList>','') ||
        iff(ffQFacLatLongList is not null,'<ffQFacLatLongList>' || ffQFacLatLongList || '</ffQFacLatLongList>','') ||
        iff(ffQZscr is not null,'<ffQZscr>' || ffQZscr || '</ffQZscr>','') ||
        iff(ffQPscr is not null,'<ffQPscr>' || ffQPscr || '</ffQPscr>','') ||
        iff(ffQCd is not null,'<ffQCd>' || ffQCd || '</ffQCd>','') ||
        iff(IsCohort is not null,'<IsCohort>' || IsCohort || '</IsCohort>','') ||
        iff(vol is not null,'<vol>' || vol || '</vol>','') ||
        iff(sSrch is not null,'<sSrch>' || sSrch || '</sSrch>','') ||
        iff(vCred is not null,'<vCred>' || vCred || '</vCred>','') ||
        iff(prRC is not null,'<prRC>' || prRC || '</prRC>','') ||
        iff(aurl is not null,'<aurl>' || aurl || '</aurl>','') ||
        iff(perform is not null,'<perform>' || perform || '</perform>','') ||
        iff(FFExpBoost is not null,'<FFExpBoost>' || FFExpBoost || '</FFExpBoost>','') ||
        iff(FFHQualityWList is not null,'<FFHQualityWList>' || FFHQualityWList || '</FFHQualityWList>','') ||
        iff(FFHQualityWinW is not null,'<FFHQualityWinW>' || FFHQualityWinW || '</FFHQualityWinW>','') || '</prc>' , '') || '</prcL>'
 AS XMLValue
    FROM
        cte_procedure
    GROUP BY
        ProviderID
),
                
------------------------ConditionXML------------------------

 Cte_prov_Cond AS (
    SELECT 
        ent.EntityID, 
        mt.MedicalTermCode AS condC,
        mt.MedicalTermDescription1 AS conD,
        NULL AS conGD,
        NULL AS lKey,
        ent.NationalRankingA AS nrkA,
        ent.NationalRankingB AS nrkB,
        ent.SearchBoostExperience AS boostExp,
        ent.FriendsAndFamilyDCPExperienceRatingPercent AS ffExpPscr,
        IFF(ent.SearchBoostHospitalCohortQuality IS NOT NULL, ent.SearchBoostHospitalCohortQuality, ent.SearchBoostHospitalServiceLineQuality) AS boostQual,
        ent.FriendsAndFamilyDCPQualityFacility AS ffQFac,
        ent.FriendsAndFamilyDCPQualityFacilityList AS ffQFacLst, 
        ent.FriendsAndFamilyDCPQualityFacilityListLatLong AS ffQFacLatLongList,
        ent.FriendsAndFamilyDCPQualityFacRatingPerList AS ffQFacScrLst,
        ent.FriendsAndFamilyDCPQualityFacilityScoreList AS ffQFacHQList,
        ent.FriendsAndFamilyDCPQualityZScore AS ffQZscr,
        ent.FriendsAndFamilyDCPQualityRatingPercent AS ffQPscr,
        ent.FriendsAndFamilyDCPQualityCode AS ffQCd,
        IFF(ent.FriendsAndFamilyDCPQualityCode IS NOT NULL AND rcc.CohortCode IS NOT NULL, 1, IFF(ent.FriendsAndFamilyDCPQualityCode IS NULL, NULL, 0)) AS IsCohort,
        ent.PatientCount AS vol,
        ent.SourceSearch AS sSrch,
        mt.VolumeIsCredible AS vCred,
        mt.RefMedicalTermCode AS conRC,
        mt.WebArticleURL AS aUrl,
        ent.PatientCountIsFew, 
        ent.MedicalTermID, 
        ent.FFExpBoost, 
        ent.FFQualityFaciltyWeightList AS FFHQualityWList, 
        ent.FFHQualityWinWeight AS FFHQualityWinW
    FROM
        Base.EntityToMedicalTerm ent
        JOIN Base.MedicalTerm mt ON ent.MedicalTermID = mt.MedicalTermID
        JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID
        LEFT JOIN (
            SELECT DISTINCT CohortCode, ConditionCode 
            FROM Base.CohortToCondition
        ) rcc ON rcc.CohortCode = ent.FriendsAndFamilyDCPQualityCode 
            AND rcc.ConditionCode = mt.RefMedicalTermCode
    WHERE
        mtt.MedicalTermTypeCode = 'Condition'
        AND IFF(ent.IsPreview IS NULL, 0, ent.IsPreview) = 0
),

Cte_prov_Treat AS (
    SELECT 
        pts.ProviderID, 
        emt.MedicalTermID, 
        MAX(CAST(stpm.Treat AS INT)) AS Treat
    FROM 
        Base.ProviderToSpecialty pts
    JOIN 
        cte_prov_Cond emt ON pts.ProviderID = emt.EntityID
    JOIN 
        Base.SpecialtyToCondition stpm ON stpm.SpecialtyID = pts.SpecialtyID AND stpm.ConditionID = emt.MedicalTermID
    WHERE 
        emt.PatientCountIsFew IS NOT NULL OR emt.vol IS NOT NULL
    GROUP BY 
        pts.ProviderID, 
        emt.MedicalTermID
),

cte_condition as (
    SELECT DISTINCT
        cond.EntityID as ProviderID,
        cond.condC, 
        cond.conD, 
        cond.conGD, 
        cond.lKey, 
        cond.nrkA, 
        cond.nrkB, 
        cond.boostExp, 
        cond.ffExpPscr, 
        cond.boostQual, 
        cond.ffQFac, 
        cond.ffQFacLst,
        cond.ffQFacScrLst, 
        cond.ffQFacHQList, 
        cond.ffQFacLatLongList, 
        cond.ffQZscr, 
        cond.ffQPscr, 
        cond.ffQCd, 
        cond.IsCohort, 
        cond.vol, 
        cond.sSrch, 
        cond.vCred, 
        cond.conRC,
        cond.aUrl, 
        IFF(treat.ProviderID IS NULL, 1, treat.Treat) AS treat,
        cond.FFExpBoost, 
        cond.FFHQualityWList, 
        cond.FFHQualityWinW
    FROM
        show.solrprovider p 
        JOIN cte_prov_Cond cond on p.providerid = cond.entityid
        LEFT JOIN cte_prov_Treat treat ON treat.ProviderID = cond.EntityID AND treat.MedicalTermID = cond.MedicalTermID
),

cte_condition_xml as (
    SELECT
        ProviderID,
        '<cndL>' || listagg( '<cnd>' || iff(condc is not null,'<condc>' || condc || '</condc>','') ||
        iff(conD is not null,'<conD>' || conD || '</conD>','') ||
        iff(conGD is not null,'<conGD>' || conGD || '</conGD>','') ||
        iff(lKey is not null,'<lKey>' || lKey || '</lKey>','') ||
        iff(nrkA is not null,'<nrkA>' || nrkA || '</nrkA>','') ||
        iff(nrkB is not null,'<nrkB>' || nrkB || '</nrkB>','') ||
        iff(boostExp is not null,'<boostExp>' || boostExp || '</boostExp>','') ||
        iff(ffExpPscr is not null,'<ffExpPscr>' || ffExpPscr || '</ffExpPscr>','') ||
        iff(boostQual is not null,'<boostQual>' || boostQual || '</boostQual>','') ||
        iff(ffQFac is not null,'<ffQFac>' || ffQFac || '</ffQFac>','') ||
        iff(ffQFacLst is not null,'<ffQFacLst>' || ffQFacLst || '</ffQFacLst>','') ||
        iff(ffQFacScrLst is not null,'<ffQFacScrLst>' || ffQFacScrLst || '</ffQFacScrLst>','') ||
        iff(ffQFacHQList is not null,'<ffQFacHQList>' || ffQFacHQList || '</ffQFacHQList>','') ||
        iff(ffQFacLatLongList is not null,'<ffQFacLatLongList>' || ffQFacLatLongList || '</ffQFacLatLongList>','') ||
        iff(ffQZscr is not null,'<ffQZscr>' || ffQZscr || '</ffQZscr>','') ||
        iff(ffQPscr is not null,'<ffQPscr>' || ffQPscr || '</ffQPscr>','') ||
        iff(ffQCd is not null,'<ffQCd>' || ffQCd || '</ffQCd>','') ||
        iff(IsCohort is not null,'<IsCohort>' || IsCohort || '</IsCohort>','') ||
        iff(vol is not null,'<vol>' || vol || '</vol>','') ||
        iff(sSrch is not null,'<sSrch>' || sSrch || '</sSrch>','') ||
        iff(vCred is not null,'<vCred>' || vCred || '</vCred>','') ||
        iff(conRC is not null,'<conRC>' || conRC || '</conRC>','') ||
        iff(aUrl is not null,'<aUrl>' || aUrl || '</aUrl>','') ||
        iff(treat is not null,'<treat>' || treat || '</treat>','') ||
        iff(FFExpBoost is not null,'<FFExpBoost>' || FFExpBoost || '</FFExpBoost>','') ||
        iff(FFHQualityWList is not null,'<FFHQualityWList>' || FFHQualityWList || '</FFHQualityWList>','') ||
        iff(FFHQualityWinW is not null,'<FFHQualityWinW>' || FFHQualityWinW || '</FFHQualityWinW>','')  || '</cnd>' ,'') || '</cndL>'
         AS XMLValue
    FROM
        cte_condition
    GROUP BY
        ProviderID
) ,

------------------------HealthInsuranceXML_v2------------------------

CTE_Health_Insurance_Product AS (
    SELECT
        P.ProviderID,
        PH.PayorName,
        replace(replace(PH.ProductName, '\'', ''), '&', '&amp;') AS prodNm,
        PHtPT.ProductCode AS prodCd,
        H.PlanCode AS plCd,
        PT.PlanTypeCode AS plTpCd,
        1 AS srch
    FROM
        Mid.ProviderHealthInsurance PH
        INNER JOIN Base.HealthInsurancePlanToPlanType PHtPT ON PHtPT.HealthInsurancePlanToPlanTypeID = PH.HealthInsurancePlanToPlanTypeID
        INNER JOIN Base.HealthInsurancePlan H ON PHtPT.HealthInsurancePlanID = H.HealthInsurancePlanID
        INNER JOIN Base.HealthInsurancePlanType PT ON PHtPT.HealthInsurancePlanTypeID = PT.HealthInsurancePlanTypeID
        INNER JOIN Show.SolrProvider P ON P.ProviderID = PH.ProviderID
),

CTE_Health_Insurance_Plan AS (
    SELECT DISTINCT
        P.ProviderID,
        PH.PayorName,
        replace(replace(PH.ProductName, '\'', ''), '&', '&amp;') AS prodNm,
        PH.HealthInsurancePlanToPlanTypeID AS prodNmID,
        PH.Searchable AS srch,
        replace(PH.PlanDisplayName,'&', '&amp;' ) AS plNm,
        PH.PlanTypeDisplayDescription AS plTp,
    FROM
        Mid.ProviderHealthInsurance PH
    JOIN
        Show.SolrProvider P ON P.ProviderID = PH.ProviderID

),

CTE_Health_Insurance_Base AS (
    SELECT DISTINCT
        replace(replace(ph.PayorName, '\'', ''), '&', '&amp;' ) as payorname,
        po.PayorOrganizationName,
        ph.Searchable,
        ph.HealthInsurancePayorID,
        ph.PayorCode,
        ph.PayorProductCount,
        hpo.InsurancePayorCode,
        P.ProviderID
    FROM
        Mid.ProviderHealthInsurance ph
    JOIN
        (SELECT DISTINCT HealthInsurancePayorID, PayorCode, InsurancePayorCode, HealthInsurancePayorOrganizationID 
         FROM Base.HealthInsurancePayor) hpo ON ph.PayorCode = hpo.PayorCode
    JOIN
        Show.SolrProvider P ON P.ProviderID = ph.ProviderID
    LEFT JOIN
        Base.HealthInsurancePayorOrganization po ON po.HealthInsurancePayorOrganizationID = hpo.HealthInsurancePayorOrganizationID
),

cte_plan_xml as (
    SELECT
        ProviderID,
        payorname,
        listagg( '<plan>' || iff(prodNm is not null,'<prodNm>' || prodNm || '</prodNm>','') ||
        iff(prodNmID is not null,'<prodNmID>' || prodNmID || '</prodNmID>','') ||
        iff(srch is not null,'<srch>' || srch || '</srch>','') ||
        iff(plNm is not null,'<plNm>' || plNm || '</plNm>','') ||
        iff(plTp is not null,'<plTp>' || plTp || '</plTp>','') || '</plan>' ,'') 
 AS XMLValue
    FROM
        cte_health_insurance_plan
    GROUP BY
        ProviderID,
        payorname
)
,


cte_product_xml as (
    SELECT
        ProviderID,
        payorname,
        listagg( '<product>' || iff(prodNm is not null,'<prodNm>' || prodNm || '</prodNm>','') ||
        iff(prodCd is not null,'<prodCd>' || prodCd || '</prodCd>','') ||
        iff(plCd is not null,'<plCd>' || plCd || '</plCd>','') ||
        iff(plTpCd is not null,'<plTpCd>' || plTpCd || '</plTpCd>','') ||
        iff(srch is not null,'<srch>' || srch || '</srch>','') || '</product>' ,'')
         AS XMLValue
    FROM
        Cte_Health_Insurance_Product
    GROUP BY
        ProviderID,
        payorname
),

CTE_Health_Insurnace_v2 as (
    SELECT DISTINCT
        p.ProviderID,
        replace(hi.PayorName, '&', '&amp;') AS paNm,
        hi.PayorOrganizationName AS paOrgNm,
        hi.Searchable AS srch,
        hi.HealthInsurancePayorID AS paGUID,
        hi.PayorCode AS paCd,
        hi.PayorProductCount AS plCount,
        hi.InsurancePayorCode AS paNewCd,
        --- it is computationally more expensive to do the join so we use this function instead
        to_varchar(SELECT LISTAGG(cte.xmlvalue, '') WITHIN GROUP (ORDER BY cte.xmlvalue) 
        FROM cte_plan_xml cte 
        WHERE cte.providerid = p.providerid and cte.payorname = hi.payorname) as pll,
        to_varchar(SELECT LISTAGG(cte.xmlvalue, '') WITHIN GROUP (ORDER BY cte.xmlvalue) 
        FROM cte_product_xml cte 
        WHERE cte.providerid = p.providerid and cte.payorname = hi.payorname) as prl
    
    FROM
        Show.solrprovider as p 
        JOIN cte_health_insurance_base hi on p.providerid = hi.providerid
    WHERE
        hi.HealthInsurancePayorID IS NOT NULL
)
,

CTE_Health_Insurnace_v2_xml as (
    SELECT
        ProviderID,
        '<paL>' || 
        listagg('<pa>' || iff(paNm is not null,'<paNm>' || paNm || '</paNm>','') ||
        iff(paOrgNm is not null,'<paOrgNm>' || paOrgNm || '</paOrgNm>','') ||
        iff(srch is not null,'<srch>' || srch || '</srch>','') ||
        iff(paGUID is not null,'<paGUID>' || paGUID || '</paGUID>','') ||
        iff(paCd is not null,'<paCd>' || paCd || '</paCd>','') ||
        iff(plCount is not null,'<plCount>' || plCount || '</plCount>','') ||
        iff(paNewCd is not null,'<paNewCd>' || paNewCd || '</paNewCd>','') ||
        iff(pll is not null,'<plL>' || pll || '</plL>','') ||
        iff(prl is not null,'<prL>' || prl || '</prL>','') || '</pa>' , '') || '</paL>'
        AS XMLValue
    FROM
        CTE_Health_Insurnace_v2
    GROUP BY
        ProviderID
),


-----------------HealthInsuranceXML------------------------

cte_provider_health_insurance as (
    SELECT DISTINCT
        p.ProviderID,
        h.PayorName AS paNm,
        h.Searchable AS srch,
        h.PayorCode AS paCd
    FROM
        Mid.ProviderHealthInsurance h
        JOIN Show.solrprovider as p on p.providerid = h.providerid
),

cte_health_insurance_xml as (
    SELECT
        ProviderID,
        '<paL>' || listagg( '<pa>' || iff(paNm is not null,'<paNm>' || paNm || '</paNm>','') ||
        iff(srch is not null,'<srch>' || srch || '</srch>','') ||
        iff(paCd is not null,'<paCd>' || paCd || '</paCd>','') || '</pa>' , '') || '</paL>'
 AS XMLValue
    FROM
        cte_provider_health_insurance
    GROUP BY
        ProviderID
),

------------------------MediaXML------------------------
Cte_Media as (
    SELECT
        DISTINCT pm.providerid,
        pm.MediaDate AS mDt,
        utils.clean_xml(pm.MediaTitle) AS mTit,
        utils.clean_xml(pm.MediaPublisher) AS mPub,
        utils.clean_xml(pm.MediaSynopsis) AS mSyn,
        utils.clean_xml(pm.MediaLink) AS mLink,
        mt.MediaTypeCode AS mC,
        mt.MediaTypeDescription AS mD
    FROM
        Base.ProviderMedia pm
        JOIN Base.MediaType mt ON pm.MediaTypeID = mt.MediaTypeID
),
cte_Media_XML as (
    SELECT
        ProviderID,
        '<medL>' || listagg( '<med>' || iff(mdt is not null,'<mdt>' || mdt || '</mdt>','') ||
        iff(mTit is not null,'<mTit>' || mTit || '</mTit>','') ||
        iff(mPub is not null,'<mPub>' || mPub || '</mPub>','') ||
        iff(mSyn is not null,'<mSyn>' || mSyn || '</mSyn>','') ||
        iff(mLink is not null,'<mLink>' || mLink || '</mLink>','') ||
        iff(mC is not null,'<mC>' || mC || '</mC>','') ||
        iff(mD is not null,'<mD>' || mD || '</mD>','') || '</med>' , '') || '</medL>'
         AS XMLValue
    FROM
        CTE_Media
    GROUP BY
        ProviderID
) ,
------------------------RecognitionXML------------------------

cte_recogsl as (
SELECT DISTINCT
    Providerid,
    ServiceLine AS recogSl
FROM   
    Mid.ProviderRecognition
),

cte_recogsl_xml as (
SELECT distinct
        ProviderID,
        iff(recogsl is not null,'<recogSl>' || recogsl || '</recogSl>','') AS XMLValue
    FROM
        cte_recogsl
),

cte_recogdl as (
SELECT DISTINCT
    pr.providerid,
    pr.FacilityName AS recogHosp,
	pr.FacilityCode as recogHospID,
    xml.xmlvalue as recogsll
FROM Mid.ProviderRecognition pr
JOIN cte_recogsl_xml as xml on xml.providerid = pr.providerid
),

cte_recogdl_xml as (
SELECT
        ProviderID,
        listagg( '<recogD>' || iff(recogHosp is not null,'<recogHosp>' || recogHosp || '</recogHosp>','') ||
        iff(recogHospID is not null,'<recogHospID>' || recogHospID || '</recogHospID>','') ||
        iff(recogsll is not null,'<recogSlL>' || recogsll || '</recogSlL>','') 
        || '</recogD>' , '')
 AS XMLValue
    FROM
        cte_recogdl
    GROUP BY
        ProviderID
),

cte_recognition as (
SELECT DISTINCT
    pr.providerid,
    pr.RecognitionCode AS recogCd,
	pr.RecognitionDisplayName AS recogDName,
	xml.xmlvalue as recogdl
FROM  Mid.ProviderRecognition pr
JOIN cte_recogdl_xml as xml on xml.providerid = pr.providerid
ORDER BY pr.RecognitionCode
),

cte_recognition_xml as (
SELECT
        ProviderID,
        '<recogL>' || listagg( '<recog>' || 
        iff(recogCd is not null,'<recogcd>' || recogCd || '</recogcd>','') ||
        iff(recogDName is not null,'<recogDName>' || recogDName || '</recogDName>','') ||
        iff(recogdl is not null,'<recogDL>' || recogdl || '</recogDL>','') 
        || '</recog>' , '') || '</recogL>'
 AS XMLValue
FROM
    cte_recognition
GROUP BY
    ProviderID
) ,

------------------------ProviderSpecialtyFacility5StarXML------------------------

cte_spec as (
SELECT DISTINCT
    ProviderId,
    LegacyKey AS lKey,
    SpecialtyCode AS spCd 
FROM Mid.ProviderSpecialtyFacilityServiceLineRating 
),
cte_spec_xml as (
SELECT
        ProviderID,
        listagg(iff(lkey is not null,'<lkey>' || lkey || '</lkey>','') ||
        iff(spcd is not null,'<spcd>' || spcd || '</spcd>',''), '') 
 AS XMLValue
FROM
    cte_spec
GROUP BY
    ProviderID
),

cte_provider_speciality_facility_5star as (
SELECT DISTINCT
    pr.providerid,
    pr.ServiceLineCode AS svcCd,
    pr.ServiceLineDescription AS svcNm,
    xml.xmlvalue as spec
 FROM   Mid.ProviderSpecialtyFacilityServiceLineRating pr
 JOIN cte_spec_xml as xml on xml.providerid = pr.providerid
 WHERE  pr.ServiceLineStar = 5
),

cte_provider_speciality_facility_5star_xml as (
SELECT
        ProviderID,
        '<provFiveStar>' || listagg( '<svcLn>' || iff(svcCd is not null,'<svcCd>' || svcCd || '</svcCd>','') ||
        iff(svcNm is not null,'<svcNm>' || svcNm || '</svcNm>','') ||
        iff(spec is not null,'<spec>' || spec || '</spec>','') || '</svcLn>' , '' ) || '</provFiveStar>'
 AS XMLValue
FROM
    cte_provider_speciality_facility_5star
GROUP BY
    ProviderID
),

------------------------VideoXML------------------------

cte_video_xml as (
SELECT DISTINCT
    pv.providerid,
    CONCAT('<video>
            <vidL>
            <flash>
                <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"      codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,115,0"      id="i_051bb5a507614c37917aad1705f5dd93"      width="450"      height="392">
                <param name="movie" value="http://applications.fliqz.com/',  utils.clean_xml(pv.ExternalIdentifier) , '.swf"/>
                <param name="allowfullscreen" value="true" />
                <param name="menu" value="false" />
                <param name="bgcolor" value="#ffffff"/>
                <param name="wmode" value="window"/>
                <param name="allowscriptaccess" value="always"/>
                <param name="flashvars" value=" file=', utils.clean_xml(pv.ExternalIdentifier) , '"/>
                <embed name="i_f3fa611a238b4b14a65e4985373ead58"  src="http://applications.fliqz.com/', utils.clean_xml(pv.ExternalIdentifier) , '.swf" flashvars="file=',  utils.clean_xml(pv.ExternalIdentifier) , '"                 width="450"                 height="392"                 pluginspage="http://www.macromedia.com/go/getflashplayer"                 allowfullscreen="true"                 menu="false"                 bgcolor="#ffffff"                 wmode="window"                 allowscriptaccess="always"                 type="application/x-shockwave-flash"/>
                </object>
            </flash>
            </vidL>
        </video>') as xmlvalue
FROM Base.ProviderVideo AS pv 
JOIN Base.MediaContextType mc ON mc.MediaContextTypeID = pv.MediaContextTypeID
JOIN Base.MediaVideoHost mh ON mh.MediaVideoHostID = pv.MediaVideoHostID AND mh.MediaVideoHostCode = 'FLIQZ' 
) ,

------------------------VideoXML2------------------------
cte_video_xml2 as (
SELECT DISTINCT
    pv.providerid,
    CONCAT('<vidL>
                <vid>
                    <vidHostCd>', mh.MediaVideoHostCode, '</vidHostCd>
                    <vidContCd>', mc.MediaContextTypeCode, '</vidContCd>
                    <vidSrc>/video/',lower(utils.clean_xml(pv.ExternalIdentifier)), '</vidSrc>
                </vid>     
            </vidL>') as xmlvalue
FROM Base.ProviderVideo AS pv 
JOIN Base.MediaContextType mc ON mc.MediaContextTypeID = pv.MediaContextTypeID
JOIN Base.MediaVideoHost mh ON mh.MediaVideoHostID = pv.MediaVideoHostID AND mh.MediaVideoHostCode = 'BRIGHTSPOT' 
) ,

------------------------ImageXML------------------------

CTE_From_Temp_UpdateDate AS (
    SELECT 
        PI.Providerid,
        CASE WHEN LEFT(ExternalIdentifier, 1) = 'v'
            THEN RIGHT(ExternalIdentifier, LENGTH(ExternalIdentifier) - 1)
            ELSE ExternalIdentifier
        END AS ExternalIdentifier,
        ImagePath,
        Filename,
        MIN(LastUpdateDate) AS LastUpdateDate,
        MediaContextTypeID,
        MediaImageHostID
    FROM Base.ProviderImage PI
    INNER JOIN Show.SolrProvider P ON P.ProviderID = PI.ProviderID
    WHERE ImagePath IS NOT NULL
    GROUP BY 
    PI.ProviderId, 
    ExternalIdentifier, 
    ImagePath, 
    Filename,
    MediaContextTypeID,
    MediaImageHostID
),

CTE_Temp_Update_Date AS (
    SELECT
        ProviderId,
        IFNULL(ExternalIdentifier, CASE WHEN POSITION('v_' IN REVERSE(FileName)) > 0
            THEN REPLACE(SUBSTRING(FileName, LENGTH(FileName) - POSITION('v_' IN REVERSE(FileName)) + 2, LENGTH(FileName)), '.jpg', '')
            ELSE ''
        END) AS ExternalIdentifier,
        CASE WHEN LEFT(TRIM(ImagePath), 1) = '/' THEN '' ELSE '/' END || ImagePath || CASE WHEN RIGHT(TRIM(ImagePath), 1) = '/' THEN '' ELSE '/' END AS ImagePath,
        IFF(IS_INTEGER(TRY_CAST(IFNULL(ExternalIdentifier, CASE WHEN POSITION('v_' IN REVERSE(FileName)) > 0 THEN
            REPLACE(SUBSTRING(FileName, LENGTH(FileName) - POSITION('v_' IN REVERSE(FileName)) + 2, LENGTH(FileName)), '.jpg', '')
            ELSE '0'
        END) AS INT)) = 1, 1, 0) AS IsLegacy,
        MediaContextTypeID,
        MediaImageHostID,
        ExternalIdentifier AS OriginalExternalIdentifier,
        ImagePath AS OriginalImagePath,
        LastUpdateDate
    FROM CTE_From_Temp_UpdateDate
),

CTE_Temp_Provider_Image AS (
SELECT
    cte.ProviderId,
    ImagePath || CASE WHEN cte.IsLegacy = 1 THEN UPPER(P.ProviderCode) ELSE LOWER(P.ProviderCode) END || '_' || 'w60h80' || '_v' || ExternalIdentifier || '.jpg' AS imgU,
    'small' AS imgC,
    60 AS imgW,
    80 AS imgH,
    'image' AS imgA
FROM
    cte_temp_update_date cte
INNER JOIN
    Base.Provider P ON P.ProviderId = cte.ProviderID

UNION ALL

SELECT
    cte.ProviderId,
    ImagePath || CASE WHEN cte.IsLegacy = 1 THEN UPPER(P.ProviderCode) ELSE LOWER(P.ProviderCode) END || '_' || 'w90h120' || '_v' || ExternalIdentifier || '.jpg' AS imgU,
    'medium' AS imgC,
    90 AS imgW,
    120 AS imgH,
    'image' AS imgA
FROM
    cte_temp_update_date cte
INNER JOIN
    Base.Provider P ON P.ProviderId = cte.ProviderID
WHERE
    LENGTH(ExternalIdentifier) > 0

UNION ALL

SELECT
    cte.ProviderId,
    ImagePath || CASE WHEN cte.IsLegacy = 1 THEN UPPER(P.ProviderCode) ELSE LOWER(P.ProviderCode) END || '_' || 'w120h160' || '_v' || ExternalIdentifier || '.jpg' AS imgU,
    'large' AS imgC,
    120 AS imgW,
    160 AS imgH,
    'image' AS imgA
FROM
    cte_temp_update_date cte
INNER JOIN
    Base.Provider P ON P.ProviderId = cte.ProviderID
WHERE
    LENGTH(ExternalIdentifier) > 0

UNION ALL

SELECT
    cte.ProviderId,
    ImagePath || CASE WHEN cte.IsLegacy = 1 THEN UPPER(P.ProviderCode) ELSE LOWER(P.ProviderCode) END || '_' || 'w90h120.jpg' AS imgU,
    'medium' AS imgC,
    90 AS imgW,
    120 AS imgH,
    'image' AS imgA
FROM
    cte_temp_update_date cte
INNER JOIN
    Base.Provider P ON P.ProviderId = cte.ProviderID
WHERE
    cte.IsLegacy = 1
    AND LENGTH(ExternalIdentifier) = 0
),

CTE_Image_XML AS (
    SELECT
        ProviderId,
        '<imgL>' || listagg( '<img>' || iff(imgC is not null,'<imgC>' || imgC || '</imgC>','') ||
        iff(imgU is not null,'<imgU>' || imgU || '</imgU>','') ||
        iff(imgA is not null,'<imgA>' || imgA || '</imgA>','') ||
        iff(imgW is not null,'<imgW>' || imgW || '</imgW>','') ||
        iff(imgH is not null,'<imgH>' || imgH || '</imgH>','') || '</img>' , '') || '</imgL>'
 AS XMLValue
    FROM
        CTE_Temp_Provider_Image
    GROUP BY
        ProviderId
),

------------------------AboutMeXML------------------------

cte_aboutme as (
    SELECT DISTINCT
        pam.ProviderID,
        am.AboutMeCode AS type,
        utils.clean_xml(CASE WHEN am.DescriptionEdit = 1 AND IFNULL(pam.CustomAboutMeDescription, '') <> ''
            THEN pam.CustomAboutMeDescription
            ELSE IFNULL(am.AboutMeDescription, '')
        END ) as title,
        am.DisplayOrder AS sort,
        -- pam.ProviderAboutMeText AS text,
        utils.clean_xml(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REPLACE(REPLACE(trim(REGEXP_REPLACE(pam.ProviderAboutMeText, '\\x00|\\x01|\\x02|\\x03|\\x04|\\x05|\\x06|\\x07|\\x08|\\x0B|\\x0C|\\x0E|\\x0F|\\x10|\\x11|\\x12|\\x13|\\x14|\\x15|\\x16|\\x17|\\x18|\\x19|\\x1A|\\x1B|\\x1C|\\x1D|\\x1E|\\x1F|\\&amp', '', 1, 0, 'e')),CHAR(UNICODE('\\u0060'))), ''), '[&/''''\\:\\\\~\\\\;\\\\|<>™•*?+®!–@{}\\\\[\\\\]()ñéí"’ #,\\.]', ''), '--', '-'), '\'', ''), '\"' , ''), CHAR(UNICODE('\\u0060')), ''), '{', ''), '}', '')) as text,
        IFNULL(TO_DATE(pam.LastUpdatedDate), TO_DATE(pam.InsertedOn)) AS updDte
    FROM
        Base.AboutMe am
        JOIN Base.ProviderToAboutMe pam ON am.AboutMeID = pam.AboutMeID
),

cte_aboutme_xml as (
    SELECT
        ProviderID,
        '<aboutMeL>' || listagg( '<section>' || iff(type is not null,'<type>' || type || '</type>','') ||
        iff(title is not null,'<title>' || title || '</title>','') ||
        iff(sort is not null,'<sort>' || sort || '</sort>','') ||
        iff(text is not null,'<text>' || text || '</text>','') ||
        iff(updDte is not null,'<updDte>' || updDte || '</updDte>','') || '</section>', '') || '</aboutMeL>'
 AS XMLValue
    FROM
        cte_aboutme
    GROUP BY
        ProviderID
) 
SELECT
    p.providerid,
    to_variant(parse_xml(proc.xmlvalue)) as procedurexml,
    to_variant(parse_xml(cond.xmlvalue)) as conditionxml,
    to_variant(parse_xml(hivw.xmlvalue)) as healthinsurancexml_v2,
    to_variant(parse_xml(hins.xmlvalue)) as healthinsurancexml,
    to_variant(parse_xml(media.xmlvalue)) as mediaxml,
    to_variant(parse_xml(rec.xmlvalue)) as recognitionxml,
    to_variant(parse_xml(fstar.xmlvalue)) as ProviderSpecialtyFacility5StarXML,
    to_variant(parse_xml(video.xmlvalue)) as VideoXML,
    to_variant(parse_xml(video2.xmlvalue)) as videoxml2,
    to_variant(parse_xml(image.xmlvalue)) as imagexml,
    case when image.xmlvalue is not null then 1 else 0 end as hasdisplayimage,
    to_variant(parse_xml(aboutme.xmlvalue)) as aboutmexml,
    CASE WHEN media.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasMediaXML,
    CASE WHEN aboutme.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasAboutMeXML,
    CASE WHEN video2.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasVideoXML2,
    CASE WHEN fstar.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasProviderSpecialtyFacility5StarXML,
    CASE WHEN proc.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasProcedureXML,
    CASE WHEN cond.xmlvalue IS NULL THEN 0 ELSE 1 END AS HasConditionXML
FROM Show.SolrProvider as P
    LEFT JOIN cte_procedure_xml as proc on proc.providerid = p.providerid
    LEFT JOIN Cte_condition_xml as  cond on cond.providerid = p.providerid
    LEFT JOIN CTE_Health_Insurnace_v2_xml as hivw on hivw.providerid = p.providerid -- bottleneck
    LEFT JOIN cte_health_insurance_xml AS hins ON hins.providerid = p.providerid
    LEFT JOIN cte_media_xml AS media ON media.providerid = p.providerid 
    LEFT JOIN cte_recognition_xml AS rec ON rec.providerid = p.providerid
    LEFT JOIN cte_provider_speciality_facility_5star_xml AS fstar ON fstar.providerid = p.providerid
    LEFT JOIN cte_video_xml AS video ON video.providerid = p.providerid
    LEFT JOIN cte_video_xml2 AS video2 ON   video2.providerid = p.providerid
    LEFT JOIN cte_image_xml AS image ON image.providerid = p.providerid
    LEFT JOIN cte_aboutme_xml AS aboutme ON aboutme.providerid = p.providerid
$$;


update_statement_xml_load_1 := $$ update show.solrprovider as target
                                    set target.availabilityxml = source.availabilityxml,
                                        target.procedurehierarchyxml = source.procedurehierarchyxml,
                                        target.procmappedxml = source.procmappedxml,
                                        target.pracspecheirxml = source.pracspecheirxml,
                                        target.oasxml = source.oasxml,
                                        target.deaxml = source.deaxml,
                                        target.emailaddressxml = source.emailaddressxml,
                                        target.degreexml = source.degreexml,
                                        target.surveyxml = source.surveyxml,
                                        target.clinicalfocusdcpxml = source.clinicalfocusdcpxml,
                                        target.clinicalfocusxml = source.clinicalfocusxml,
                                        target.trainingxml = source.trainingxml,
                                        target.lastupdatedatexml = source.lastupdatedatexml,
                                        target.smartreferralclientcode = source.smartreferralclientcode,
                                        target.smartreferralxml = source.smartreferralxml,
                                        target.HasSurveyXML = source.HasSurveyXML,
                                        target.HasDEAXML = source.HasDEAXML,
                                        target.HasEmailAddressXML = source.HasEmailAddressXML
                                    from ($$ || select_statement_xml_load_1 || $$) as source
                                        where target.providerid = source.providerid $$;

update_statement_xml_load_2 := $$ update show.solrprovider as target
                                    set target.telehealthxml = source.telehealthxml,
                                        target.providertypexml = source.providertypexml,
                                        target.practiceofficexml = source.practiceofficexml,
                                        target.addressxml = source.addressxml,
                                        target.specialtyxml = source.specialtyxml,
                                        target.practicingspecialtyxml = source.practicingspecialtyxml,
                                        target.certificationxml = source.certificationxml,
                                        target.educationxml = source.educationxml,
                                        -- target.professionalorganizationxml = source.professionalorganizationxml,
                                        target.licensexml = source.licensexml,
                                        target.languagexml = source.languagexml,
                                        target.malpracticexml = source.malpracticexml,
                                        target.sanctionxml = source.sanctionxml,
                                        target.boardactionxml = source.boardactionxml,
                                        target.natladvertisingxml = source.natladvertisingxml,
                                        target.syndicationxml = source.syndicationxml,
                                        target.HasAddressXML = source.HasAddressXML,
                                        target.HasSpecialtyXML = source.HasSpecialtyXML,
                                        target.HasPracticingSpecialtyXML = source.HasPracticingSpecialtyXML,
                                        target.HasCertificationXML = source.HasCertificationXML,
                                        target.HasMalpracticeXML = source.HasMalpracticeXML,
                                        target.HasSanctionXML = source.HasSanctionXML,
                                        target.HasBoardActionXML = source.HasBoardActionXML
                                    from ($$ || select_statement_xml_load_2 || $$) as source
                                        where target.providerid = source.providerid $$;

update_statement_xml_load_3 :=
                                $$ update show.solrprovider as target
                                    set
                                        target.procedurexml = source.procedurexml,
                                        target.conditionxml = source.conditionxml,
                                        target.healthinsurancexml_v2 = source.healthinsurancexml_v2,
                                        target.healthinsurancexml = source.healthinsurancexml,
                                        target.mediaxml = source.mediaxml,
                                        target.recognitionxml = source.recognitionxml,
                                        target.ProviderSpecialtyFacility5StarXML = source.ProviderSpecialtyFacility5StarXML,
                                        target.VideoXML = source.VideoXML,
                                        target.videoxml2 = source.videoxml2,
                                        target.imagexml = source.imagexml,
                                        target.hasdisplayimage = source.hasdisplayimage,
                                        target.aboutmexml = source.aboutmexml,
                                        target.HasMediaXML = source.HasMediaXML,
                                        target.HasVideoXML2 = source.HasVideoXML2,
                                        target.HasProviderSpecialtyFacility5StarXML = source.HasProviderSpecialtyFacility5StarXML,
                                        target.HasProcedureXML = source.HasProcedureXML,
                                        target.HasConditionXML = source.HasConditionXML,
                                        target.HasAboutMeXML = source.HasAboutMeXML
                                    from ($$ || select_statement_xml_load_3 || $$) as source
                                       where target.providerid = source.providerid $$;
                                                                        
--------------------------ConditionHierarchyXML--------------------------
-- this takes long 
select_statement_condition_hierarchy := $$ with CTE_ProviderConditionsq AS (
    SELECT 
        a.ProviderID,
        a.ConditionCode,
        0 AS IsMapped
    FROM
        Mid.ProviderCondition a
        INNER JOIN Show.SolrProvider pr ON a.ProviderID = pr.ProviderId
    UNION ALL
    SELECT 
        a.ProviderID,
        mt.MedicalTermCode AS ConditionCode,
        1 AS IsMapped
    FROM
        Base.ProviderToSpecialty a
        INNER JOIN Base.Specialty b ON b.SpecialtyID = a.SpecialtyID
        INNER JOIN Base.SpecialtyToCondition spm ON b.SpecialtyID = spm.SpecialtyID
        INNER JOIN Base.MedicalTerm mt ON mt.MedicalTermID = spm.ConditionID
        INNER JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID
            AND mtt.MedicalTermTypeCode = 'Condition'
        INNER JOIN Show.SolrProvider pr ON a.ProviderID = pr.ProviderId
    WHERE
        a.SpecialtyIsRedundant = 0
        AND a.IsSearchableCalculated = 1
),

CTE_ProviderConditionXMLLoads AS (
    SELECT distinct
        ProviderID,
        ConditionCode,
        IsMapped
    FROM
        CTE_ProviderConditionsq
),
cte_condition_hierarchy as (
    SELECT
        DISTINCT 
        pp.ProviderID,
        dcp.MedicalInt AS condC,
        dcp.parentHier AS pHier,
        dcp.childHier AS cHier,
        dcp.parentSelfHier AS pSelfHier,
        dcp.parentByTwosHier AS pTwoHier,
        dcp.parentSelfByTwosHier AS pSelfTwoHier,
        dcp.ParentNameCodesAlpha AS pNmCdAlpha,
        dcp.ParentNameCodesInitials AS pNmCdInitial,
        pp.IsMapped AS isMap
    FROM
        CTE_ProviderConditionXMLLoads pp -- temp schema before
        INNER JOIN base.DCPHierarchy dcp ON dcp.MedicalInt = pp.ConditionCode AND dcp.medicaltype = 'Condition' -- dbo schema before
),

cte_condition_hierarchy_xml as (
    SELECT
        ProviderID,
        '<condHierL>' || listagg( '<condHier>' || iff(condC is not null,'<condC>' || condC || '</condC>','') ||
        iff(pHier is not null,'<pHier>' || pHier || '</pHier>','') ||
        iff(cHier is not null,'<cHier>' || cHier || '</cHier>','') ||
        iff(pSelfHier is not null,'<pSelfHier>' || pSelfHier || '</pSelfHier>','') ||
        iff(pTwoHier is not null,'<pTwoHier>' || pTwoHier || '</pTwoHier>','') ||
        iff(pSelfTwoHier is not null,'<pSelfTwoHier>' || pSelfTwoHier || '</pSelfTwoHier>','') ||
        iff(pNmCdAlpha is not null,'<pNmCdAlpha>' || pNmCdAlpha || '</pNmCdAlpha>','') ||
        iff(pNmCdInitial is not null,'<pNmCdInitial>' || pNmCdInitial || '</pNmCdInitial>','') ||
        iff(isMap is not null,'<isMap>' || isMap || '</isMap>','') || '</condHier>' , '') || '</condHierL>'
 AS XMLValue
    FROM
        cte_condition_hierarchy
    GROUP BY
        ProviderID
) 
SELECT
    ProviderID,
    to_variant(parse_xml(XMLValue)) as ConditionHierarchyXML
FROM
    cte_condition_hierarchy_xml $$;

update_statement_condition_hierarchy := $$ update show.solrprovider as target
                                            set target.ConditionHierarchyXML = source.ConditionHierarchyXML
                                            from ( $$ || select_statement_condition_hierarchy || $$ ) as source
                                            where target.ProviderID = source.ProviderID $$;

--------------------------CondMappedXML--------------------------
select_statement_cond_mapped := $$ with cte_cond_mapped as (
    SELECT DISTINCT
        sp.ProviderId,
        mt.MedicalTermCode AS cndC,
        s.SpecialtyCode || '/' || mt.MedicalTermDescription1 || '|' || mt.MedicalTermCode AS cndN,
    FROM
        Base.SpecialtyToCondition stc
        JOIN Base.MedicalTerm mt ON mt.MedicalTermID = stc.ConditionID
        JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID AND mtt.MedicalTermTypeCode = 'Condition'
        JOIN Base.Specialty s ON stc.SpecialtyID = s.SpecialtyID
        JOIN Base.ProviderToSpecialty pts ON pts.SpecialtyID = stc.SpecialtyID AND pts.SpecialtyIsRedundant = 0 AND pts.IsSearchableCalculated = 1
        JOIN Show.SolrProvider as sp on sp.providerid = pts.providerid
),

cte_cond_mapped_xml as (
    SELECT
        ProviderId,
        '<cndL>' || listagg('<cnd>' || iff(cndC is not null,'<cndC>' || cndC || '</cndC>','') ||
        iff(cndN is not null,'<cndN>' || cndN || '</cndN>','') || '</cnd>', '') || '</cndL>'
 AS XMLValue
    FROM
        cte_cond_mapped
    GROUP BY
        ProviderId
) 
select 
    providerid,
    to_variant(parse_xml(xmlvalue)) as condmappedxml
from cte_cond_mapped_xml $$;

update_statement_cond_mapped := $$ update show.solrprovider as target
                                    set target.CondMappedXML = source.condmappedxml
                                    from ( $$ || select_statement_cond_mapped ||  $$ ) as source
                                    where target.ProviderID = source.ProviderID $$;

------------------------FacilityXML------------------------
select_statement_facility := $$ WITH CTE_ProviderProceduresq AS (
    SELECT
        a.ProviderID,
        a.ProcedureCode,
        0 AS IsMapped
    FROM
        Mid.ProviderProcedure a
        INNER JOIN Show.SolrProvider pr ON a.ProviderID = pr.ProviderId
    UNION ALL
    SELECT
        a.ProviderID,
        mt.MedicalTermCode AS ProcedureCode,
        1 AS IsMapped
    FROM
        Base.ProviderToSpecialty a
        INNER JOIN Base.Specialty b ON b.SpecialtyID = a.SpecialtyID
        INNER JOIN Base.SpecialtyToProcedureMedical spm ON b.SpecialtyID = spm.SpecialtyID
        INNER JOIN Base.MedicalTerm mt ON mt.MedicalTermID = spm.ProcedureMedicalID
        INNER JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID
            AND mtt.MedicalTermTypeCode = 'Procedure'
        INNER JOIN Show.SolrProvider pr ON a.ProviderID = pr.ProviderId
    WHERE
        a.SpecialtyIsRedundant = 0
        AND a.IsSearchableCalculated = 1
),

CTE_ProviderProcedureXMLLoads AS (
    SELECT
        ProviderID,
        ProcedureCode,
        IsMapped
    FROM
        CTE_ProviderProceduresq
),

CTE_ProviderConditionsq AS (
    SELECT 
        a.ProviderID,
        a.ConditionCode,
        0 AS IsMapped
    FROM
        Mid.ProviderCondition a
        INNER JOIN Show.SolrProvider pr ON a.ProviderID = pr.ProviderId
    UNION ALL
    SELECT 
        a.ProviderID,
        mt.MedicalTermCode AS ConditionCode,
        1 AS IsMapped
    FROM
        Base.ProviderToSpecialty a
        INNER JOIN Base.Specialty b ON b.SpecialtyID = a.SpecialtyID
        INNER JOIN Base.SpecialtyToCondition spm ON b.SpecialtyID = spm.SpecialtyID
        INNER JOIN Base.MedicalTerm mt ON mt.MedicalTermID = spm.ConditionID
        INNER JOIN Base.MedicalTermType mtt ON mt.MedicalTermTypeID = mtt.MedicalTermTypeID
            AND mtt.MedicalTermTypeCode = 'Condition'
        INNER JOIN Show.SolrProvider pr ON a.ProviderID = pr.ProviderId
    WHERE
        a.SpecialtyIsRedundant = 0
        AND a.IsSearchableCalculated = 1
),

CTE_ProviderConditionXMLLoads AS (
    SELECT distinct
        ProviderID,
        ConditionCode,
        IsMapped
    FROM
        CTE_ProviderConditionsq
),
cte_related_spec AS (
    SELECT
        DISTINCT 
        ats.awardcode AS awardid,
        s.SpecialtyCode || '|' AS SpecialtyCode
    FROM
        Base.AwardToSpecialty ats
        JOIN Base.Specialty s ON ats.SpecialtyCode = s.SpecialtyCode
        JOIN Base.ProviderToSpecialty pts ON pts.SpecialtyID = s.SpecialtyID
    WHERE
        pts.SpecialtyIsRedundant = 0
        AND pts.IsSearchableCalculated = 1
),

cte_related_spec_xml AS (
    SELECT
        awardid,
        listagg(iff(SpecialtyCode is not null, SpecialtyCode ,'')) AS XMLValue
    FROM
        cte_related_spec
    GROUP BY
        awardId
),
cte_related_parent_spec AS (
    SELECT distinct
        ats.AwardCode AS Awardid,
        s.SpecialtyCode || ':' || psp.PracticingSpecialtyCode || '|' AS SpecialtyCode
    FROM
        Base.AwardToSpecialty ats
        JOIN Base.Specialty s ON ats.SpecialtyCode = s.SpecialtyCode
        JOIN Base.ProviderToSpecialty pts ON pts.SpecialtyID = s.SpecialtyID
        JOIN Base.SpecialtyGroupToSpecialty sgtos ON s.SpecialtyID = sgtos.SpecialtyID
        JOIN Base.SpecialtyGroup sg ON sg.SpecialtyGroupID = sgtos.SpecialtyGroupID
        JOIN Show.vwuPracticingSpecialtyToGroupSpecialtyPrimary psp ON sg.SpecialtyGroupCode = psp.RolledUpSpecialtyCode
    WHERE
        pts.SpecialtyIsRedundant = 0
        AND s.IsPediatricAdolescent = 0
        AND pts.IsSearchableCalculated = 1
        AND psp.PracticingSpecialtyCode <> s.SpecialtyCode
),

cte_related_parent_spec_xml AS (
    SELECT
        awardid,
        listagg(iff(SpecialtyCode is not null, SpecialtyCode ,'')) AS XMLValue
    FROM
        cte_related_parent_spec
    GROUP BY
        awardid
),

cte_related_child_spec AS (
    SELECT distinct
        ats.awardcode AS awardid,
        j.SpecialtyCode || ':' || s.SpecialtyCode || '|' AS SpecialtyCode
    FROM
        Base.AwardToSpecialty ats
        JOIN Base.Specialty j ON ats.SpecialtyCode = j.SpecialtyCode
        JOIN Base.ProviderToSpecialty pts ON pts.SpecialtyID = j.SpecialtyID
        JOIN Show.vwuPracticingSpecialtyToGroupSpecialtyPrimary psp ON j.SpecialtyCode = psp.PracticingSpecialtyCode
        JOIN Base.SpecialtyGroup sg ON psp.RolledUpSpecialtyCode = sg.SpecialtyGroupCode
        JOIN Base.SpecialtyGroupToSpecialty sgtos ON sg.SpecialtyGroupID = sgtos.SpecialtyGroupID
        JOIN Base.Specialty s ON s.SpecialtyID = sgtos.SpecialtyID
    WHERE
        pts.SpecialtyIsRedundant = 0
        AND s.IsPediatricAdolescent = 0
        AND j.IsPediatricAdolescent = 0
        AND pts.IsSearchableCalculated = 1
        AND j.SpecialtyCode <> s.SpecialtyCode
),

cte_related_child_spec_xml AS ( 
    SELECT
        awardid,
        listagg(iff(SpecialtyCode is not null, SpecialtyCode ,'')) AS XMLValue
    FROM
        cte_related_child_spec
    GROUP BY
        awardid
) ,

cte_related_proc AS (
    SELECT DISTINCT
        atp.awardcode AS awardid,
        pp.ProcedureCode || '|' AS ProcedureCode
    FROM
        Base.AwardToProcedure atp
        JOIN Base.MedicalTerm mt ON atp.ProcedureMedicalID = mt.MedicalTermID
        JOIN CTE_ProviderProcedureXMLLoads pp ON mt.MedicalTermCode = pp.ProcedureCode
),

cte_related_proc_xml AS (
    SELECT
        awardid,
        listagg(iff(ProcedureCode is not null, ProcedureCode ,'')) AS XMLValue
    FROM
        cte_related_proc
    GROUP BY
        awardid
),

cte_related_cond AS (
    SELECT DISTINCT
        atc.awardcode AS awardid,
        pc.ConditionCode || '|' as conditioncode
    FROM
        Base.AwardToCondition atc
        JOIN Base.MedicalTerm mt ON atc.ConditionID = mt.MedicalTermID
        JOIN CTE_ProviderConditionXMLLoads pc ON mt.MedicalTermCode = pc.ConditionCode
),

cte_related_cond_xml AS (
    SELECT
        awardid,
        listagg(iff(ConditionCode is not null, ConditionCode ,'')) AS XMLValue
    FROM
        cte_related_cond
    GROUP BY
        awardid
),

cte_award AS (
SELECT distinct
    x.facilityid,
    y.AwardCode AS awCd, 
    w.AwardCategoryCode AS awTypCd,
    y.AwardDisplayName AS awNm, 
    x.DisplayDataYear AS dispAwYr,
    x.IsBestInd AS isBest,
    x.IsMaxYear AS isMaxYr,
    rspec.xmlvalue as relatedspec,
    rpar.xmlvalue as relatedparentspec,
    rchild.xmlvalue as relatedchildspec,
    rproc.xmlvalue as relatedproc,
    rcond.xmlvalue as relatedcond
FROM ERMART1.Facility_FacilityToAward x
    JOIN Base.Award y ON  x.AwardName = y.AwardName
    JOIN Base.AwardCategory w ON w.AwardCategoryID = y.AwardCategoryID
    LEFT JOIN ERMART1.Facility_ServiceLine z ON x.SpecialtyCode = z.ServiceLineID
    JOIN Cte_Related_spec_xml as rspec on rspec.awardid = x.awardid 
    JOIN Cte_Related_parent_Spec_xml as rpar on rpar.awardid = x.awardid
    JOIN cte_related_child_spec_xml as rchild on rchild.awardid = x.awardid
    JOIN Cte_related_proc_xml as rproc on rproc.awardid = x.awardid
    JOIN Cte_related_cond_xml as rcond on rcond.awardid = x.awardid
WHERE	
    x.IsMaxYear = 1
),

cte_award_xml AS (
 SELECT
        facilityid,
        '<awardL>' || listagg('<award>' || 
        iff(awCd is not null,'<awcd>' || awCd || '</awcd>','') ||
        iff(awTypCd is not null,'<awtypcd>' || awTypCd || '</awtypcd>','') ||
        iff(awNm is not null,'<awnm>' || awNm || '</awnm>','') ||
        iff(dispAwYr is not null,'<dispawyr>' || dispAwYr || '</dispawyr>','') ||
        iff(isBest is not null,'<isbest>' || isBest || '</isbest>','') ||
        iff(isMaxYr is not null,'<ismaxyr>' || isMaxYr || '</ismaxyr>','') ||
        iff(relatedspec is not null,'<relatedspec>' || relatedspec || '</relatedspec>','') ||
        iff(relatedparentspec is not null,'<relatedparentspec>' || relatedparentspec || '</relatedparentspec>','') ||
        iff(relatedchildspec is not null,'<relatedchildspec>' || relatedchildspec || '</relatedchildspec>','') ||
        iff(relatedproc is not null,'<relatedproc>' || relatedproc || '</relatedproc>','') ||
        iff(relatedcond is not null,'<relatedcond>' || relatedcond || '</relatedcond>','') || 
        '</award>', '') || '</awardL>'
 AS XMLValue
    FROM
        cte_award
    GROUP BY
        facilityid
) ,

cte_related_spec2 as (
    SELECT DISTINCT
        i.CohortCode as procedureid,
        j.SpecialtyCode || '|' as specialtycode
    FROM
        Base.CohortToSpecialty i
        JOIN Base.Specialty j ON i.SpecialtyCode = j.SpecialtyCode
        JOIN Base.ProviderToSpecialty k ON k.SpecialtyID = j.SpecialtyID
    WHERE
        k.SpecialtyIsRedundant = 0
        AND k.IsSearchableCalculated = 1
),

cte_related_spec_xml2 as (
    SELECT
        procedureid,
        listagg(iff(SpecialtyCode is not null, SpecialtyCode ,'')) AS XMLValue
    FROM
        cte_related_spec2
    GROUP BY
        procedureid
),

cte_related_parent_spec2 as (
    SELECT distinct
        i.cohortcode as procedureid,
        j.SpecialtyCode || ':' || d1.PracticingSpecialtyCode || '|' AS SpecialtyCode
    FROM
        Base.CohortToSpecialty i
        JOIN Base.Specialty j ON i.SpecialtyCode = j.SpecialtyCode
        JOIN Base.ProviderToSpecialty k ON k.SpecialtyID = j.SpecialtyID
        JOIN Base.SpecialtyGroupToSpecialty c1 ON j.SpecialtyID = c1.SpecialtyID
        JOIN Base.SpecialtyGroup a1 ON a1.SpecialtyGroupID = c1.SpecialtyGroupID
        JOIN Show.vwuPracticingSpecialtyToGroupSpecialtyPrimary d1 ON a1.SpecialtyGroupCode = d1.RolledUpSpecialtyCode
    WHERE
        j.IsPediatricAdolescent = 0
        AND k.SpecialtyIsRedundant = 0
        AND k.IsSearchableCalculated = 1
        AND d1.PracticingSpecialtyCode <> j.SpecialtyCode
),

cte_related_parent_spec_xml2 as (
    SELECT
        procedureid,
        listagg(iff(SpecialtyCode is not null, SpecialtyCode ,'')) AS XMLValue
    FROM
        cte_related_parent_spec2
    GROUP BY
        procedureid
),


cte_related_child_spec2 as (
    SELECT distinct
        i.CohortCode as procedureid,
        j.SpecialtyCode || ':' || s.SpecialtyCode || '|' AS SpecialtyCode
    FROM
        Base.CohortToSpecialty i
        JOIN Base.Specialty j ON i.SpecialtyCode = j.SpecialtyCode
        JOIN Base.ProviderToSpecialty k ON k.SpecialtyID = j.SpecialtyID
        JOIN Show.vwuPracticingSpecialtyToGroupSpecialtyPrimary d1 ON j.SpecialtyCode = d1.PracticingSpecialtyCode
        JOIN Base.SpecialtyGroup a1 ON d1.RolledUpSpecialtyCode = a1.SpecialtyGroupCode
        JOIN Base.SpecialtyGroupToSpecialty c1 ON a1.SpecialtyGroupID = c1.SpecialtyGroupID
        JOIN Base.Specialty s ON s.SpecialtyID = c1.SpecialtyID
    WHERE
        j.IsPediatricAdolescent = 0
        AND s.IsPediatricAdolescent = 0
        AND k.SpecialtyIsRedundant = 0
        AND k.IsSearchableCalculated = 1
        AND j.SpecialtyCode <> s.SpecialtyCode
),

cte_related_child_spec_xml2 as (
    SELECT
        procedureid,
        listagg(iff(SpecialtyCode is not null, SpecialtyCode ,'')) AS XMLValue
    FROM
        cte_related_child_spec2
    GROUP BY
        procedureid
),


cte_related_proc2 as (
    SELECT DISTINCT
        g.CohortCode as procedureid,
        h.ProcedureCode || '|' as procedurecode
    FROM
        Base.CohortToProcedure g
        JOIN Base.MedicalTerm i ON g.ProcedureMedicalID = i.MedicalTermID
        JOIN CTE_ProviderProcedureXMLLoads h ON i.MedicalTermCode = h.ProcedureCode
) ,

cte_related_proc_xml2 as (
    SELECT
        procedureid,
        listagg(iff(ProcedureCode is not null, ProcedureCode ,'')) AS XMLValue
    FROM
        cte_related_proc2
    GROUP BY
        procedureid
),

cte_related_cond2 AS (
    SELECT DISTINCT
        atc.cohortcode as procedureid,
        pc.ConditionCode || '|' as conditioncode
    FROM
        Base.CohortToCondition atc
        JOIN Base.MedicalTerm mt ON atc.ConditionID = mt.MedicalTermID
        JOIN CTE_ProviderConditionXMLLoads pc ON mt.MedicalTermCode = pc.ConditionCode
),

cte_related_cond_xml2 AS (
    SELECT
        procedureid,
        listagg(iff(ConditionCode is not null, ConditionCode ,'')) AS XMLValue
    FROM
        cte_related_cond2
    GROUP BY
        procedureid
),
cte_ratings AS (
    SELECT DISTINCT 
        fpr.facilityid,
        proc.ProcedureID AS pCd, 
        proc.ProcedureDescription AS pNm, 
        'SL' || sl.ServiceLineID AS svcCd,
        sl.ServiceLineDescription AS svcNm,
        proc.RatingMethod AS rMth, 
        CASE 
            WHEN fpr.ProcedureID = 'OB1' THEN 1
        END AS mcare,
        fpr.DataYear AS rYr, 
        fpr.DisplayDataYear AS rDispYr,
        fpr.OverallSurvivalStar AS rStr, 
        fpr.OverallRecovery30Star AS rStr30,
        rspec.xmlvalue AS relatedspec,
        rpar.xmlvalue AS relatedparentspec,
        rchild.xmlvalue AS relatedchildspec,
        rproc.xmlvalue AS relatedproc,
        rcond.xmlvalue AS relatedcond
    FROM	
        ERMART1.Facility_FacilityToProcedureRating fpr
        JOIN ERMART1.Facility_vwuFacilityHGDisplayProcedures vfdp ON fpr.ProcedureID = vfdp.ProcedureID AND fpr.RatingSourceID = vfdp.RatingSourceID
        JOIN ERMART1.Facility_Procedure proc ON fpr.ProcedureID = proc.ProcedureID
        JOIN ERMART1.Facility_ProcedureToServiceLine ptsl ON fpr.ProcedureID = ptsl.ProcedureID
        JOIN ERMART1.Facility_ServiceLine sl ON ptsl.ServiceLineID = sl.ServiceLineID
        JOIN Cte_Related_spec_xml2 AS rspec ON rspec.procedureid = proc.procedureid
        JOIN Cte_Related_parent_Spec_xml2 AS rpar ON rpar.procedureid = proc.procedureid
        JOIN cte_related_child_spec_xml2 AS rchild ON rchild.procedureid = proc.procedureid
        JOIN Cte_related_proc_xml2 AS rproc ON rproc.procedureid = proc.procedureid
        JOIN Cte_related_cond_xml2 AS rcond ON rcond.procedureid = proc.procedureid
    WHERE	
        fpr.IsMaxYear = 1
),

cte_ratings_xml as (
    SELECT
        facilityid,
        '<procL>' || listagg('<proc>' || 
        iff(pcd is not null,'<pcd>' || pcd || '</pcd>','') ||
        iff(pnm is not null,'<pnm>' || pnm || '</pnm>','') ||
        iff(svccd is not null,'<svccd>' || svccd || '</svccd>','') ||
        iff(svcnm is not null,'<svcnm>' || svcnm || '</svcnm>','') ||
        iff(rmth is not null,'<rmth>' || rmth || '</rmth>','') ||
        iff(mcare is not null,'<mcare>' || mcare || '</mcare>','') ||
        iff(ryr is not null,'<ryr>' || ryr || '</ryr>','') ||
        iff(rdispyr is not null,'<rdispyr>' || rdispyr || '</rdispyr>','') ||
        iff(rstr is not null,'<rstr>' || rstr || '</rstr>','') ||
        iff(relatedspec is not null,'<relatedspec>' || relatedspec || '</relatedspec>','') ||
        iff(relatedparentspec is not null,'<relatedparentspec>' || relatedparentspec || '</relatedparentspec>','') ||
        iff(relatedchildspec is not null,'<relatedchildspec>' || relatedchildspec || '</relatedchildspec>','') ||
        iff(relatedproc is not null,'<relatedproc>' || relatedproc || '</relatedproc>','') ||
        iff(relatedcond is not null,'<relatedcond>' || relatedcond || '</relatedcond>','') || 
        '</proc>', '') || '</procL>'
 AS XMLValue
    FROM
        cte_ratings
    GROUP BY
        facilityid
) 
,

cte_facility AS (
SELECT distinct
    pf.ProviderId,
    pf.FacilityCode AS fID,
    pf.LegacyKey AS fLegacyId,
    pf.FacilityName AS fNm,
    pf.ImageFilePath AS fLogo,
    pf.HasAward AS awrd,
    to_variant(pf.AddressXML) AS addrL,
    to_variant(pf.PDCPhoneXML) AS pdcPhoneL,
    pf.FacilityURL AS fUrl,
    pf.FacilityType AS fType,
    pf.FacilityTypeCode AS fTypeCd,
    pf.FacilitySearchType AS fSearchTyp,
    pf.FiveStarProcedureCount AS fiveStrCnt,
    to_variant(f.ImageXML) AS imageL,
    f.AwardCount AS awCnt,
    f.MedicalServicesInformation AS medSvc,
    fs.AnswerPercent AS patientSatis,
    NULL AS topProcL,
    CASE 
        WHEN ps.ProductGroupCode = 'PDC' THEN '1'
        ELSE '0'
    END AS isPDC,
    pf.qualityScore,
    f.MissionStatement AS misson,
    to_variant(aw.xmlvalue) as awardxml,
    to_variant(rat.xmlvalue) as ratingsxml 
FROM Mid.ProviderFacility AS pf
    JOIN Mid.Facility f ON pf.FacilityID = f.FacilityID
    JOIN Mid.Provider p ON p.ProviderID = pf.ProviderID
    LEFT JOIN Mid.ProviderSponsorship ps ON p.ProviderCode = ps.ProviderCode AND f.FacilityCode = ps.FacilityCode
    JOIN Cte_award_xml as aw on aw.facilityid = pf.legacykey
    JOIN Cte_ratings_xml as rat on rat.facilityid = pf.legacykey
    left join ERMART1.Facility_FacilityToSurvey fs on fs.FacilityID = f.LegacyKey and fs.SurveyID = 1 AND fs.QuestionID = 10
) ,

Cte_Facility_XML AS (
SELECT
        providerid,
        '<facL>' || listagg('<fac>' || 
        iff(fId is not null,'<fId>' || fId || '</fId>','') ||
        iff(fLegacyId is not null,'<fLegacyId>' || fLegacyId || '</fLegacyId>','') ||
        iff(fNm is not null,'<fNm>' || fNm || '</fNm>','') ||
        iff(fLogo is not null,'<fLogo>' || fLogo || '</fLogo>','') ||
        iff(awrd is not null,'<awrd>' || awrd || '</awrd>','') ||
        iff(addrL is not null,'<addrL>' || addrL || '</addrL>','') ||
        iff(pdcPhoneL is not null,'<pdcPhoneL>' || pdcPhoneL || '</pdcPhoneL>','') ||
        iff(fUrl is not null,'<fUrl>' || fUrl || '</fUrl>','') ||
        iff(fType is not null,'<fType>' || fType || '</fType>','') ||
        iff(fTypeCd is not null,'<fTypeCd>' || fTypeCd || '</fTypeCd>','') ||
        iff(fSearchTyp is not null,'<fSearchTyp>' || fSearchTyp || '</fSearchTyp>','') ||
        iff(fiveStrCnt is not null,'<fiveStrCnt>' || fiveStrCnt || '</fiveStrCnt>','') ||
        iff(imageL is not null,'<imageL>' || imageL || '</imageL>','') ||
        iff(awCnt is not null,'<awCnt>' || awCnt || '</awCnt>','') ||
        iff(medSvc is not null,'<medSvc>' || medSvc || '</medSvc>','') ||
        iff(patientSatis is not null,'<patientSatis>' || patientSatis || '</patientSatis>','') ||
        iff(topProcL is not null,'<topProcL>' || topProcL || '</topProcL>','') ||
        iff(isPDC is not null,'<isPDC>' || isPDC || '</isPDC>','') ||
        iff(qualityScore is not null,'<qualityScore>' || qualityScore || '</qualityScore>','') ||
        iff(misson is not null,'<misson>' || replace(replace(misson, '<', ''), '>', '') || '</misson>','') ||
        iff(awardxml is not null,'<awardxml>' || awardxml || '</awardxml>','') ||
        iff(ratingsxml is not null,'<ratingsxml>' || ratingsxml || '</ratingsxml>','') || 
        '</fac>', '') || '</facL>' 
 AS XMLValue
    FROM
        cte_facility
    GROUP BY
        providerid
) 
select 
    providerid,
    to_variant(parse_xml(xmlvalue)) as facilityxml
from cte_facility_xml $$;

update_statement_facility := $$ update show.solrprovider as target
                        set target.FacilityXML = source.facilityxml
                        from ( $$ || select_statement_facility || $$ ) as source
                        where target.ProviderID = source.ProviderID $$;

                        select_statement_sponsorship := $$ 
WITH CTE_Temp_Provider AS (
    SELECT
        ProviderID
    FROM
        mdm_team.mst.provider_profile ppp
        JOIN base.provider bp ON ppp.ref_provider_code = bp.providercode
),
CTE_ProviderToClientToProduct AS (
    SELECT
        DISTINCT dPv.ProviderId,
        lCP.ClientToProductID
    FROM
        Base.ClientProductToEntity lCPE
        INNER JOIN Base.EntityType dE ON dE.EntityTypeId = lCPE.EntityTypeID
        INNER JOIN Base.ClientToProduct lCP ON lCP.ClientToProductID = lCPE.ClientToProductID
        INNER JOIN Base.Client dC ON lCP.ClientID = dC.ClientID
        INNER JOIN Base.Product dP ON dP.ProductId = lCP.ProductID
        INNER JOIN Base.Provider dPv ON dPv.ProviderID = lCPE.EntityID
        INNER JOIN CTE_Temp_Provider P ON P.ProviderId = dPv.ProviderId
),
CTE_ProviderPracticeOfficeSponsorship AS (
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.PracticeCode,
        a.OfficeCode,
        a.PracticeName,
        a.OfficeName,
        a.OfficeID,
        a.PracticeID,
        a.PhoneXML,
        a.ImageXML,
        a.MobilePhoneXML,
        a.TabletPhoneXML,
        a.DesktopPhoneXML,
        a.URLXML,
        CASE
            WHEN LEN(CAST(a.PhoneXML AS VARCHAR)) - LEN(
                REPLACE(CAST(a.PhoneXML AS VARCHAR), '<phTyp>', '123456')
            ) > 1 THEN 1
            ELSE 0
        END AS compositePhone
    FROM
        (
            SELECT
                a.ProviderCode,
                a.ProductCode,
                a.ProductDescription,
                a.ProductGroupCode,
                a.ProductGroupDescription,
                a.ClientToProductID,
                a.ClientCode,
                a.ClientName,
                a.HasOAR,
                a.QualityMessageXML,
                a.AppointmentOptionDescription,
                a.CallToActionMsg,
                a.SafeHarborMsg,
                a.PracticeCode,
                a.OfficeCode,
                a.PracticeName,
                a.OfficeName,
                a.OfficeID,
                a.PracticeID,
                a.PhoneXML,
                a.ImageXML,
                a.MobilePhoneXML,
                a.TabletPhoneXML,
                a.DesktopPhoneXML,
                a.URLXML,
                ROW_NUMBER() OVER (
                    PARTITION BY A.ProviderCode,
                    A.ProductCode,
                    A.ClientCode,
                    A.OfficeCode
                    ORDER BY
                        CASE
                            WHEN PhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN URLXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN ImageXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN MobilePhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN TabletPhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN DesktopPhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END
                ) AS RN1
            FROM
                CTE_Temp_Provider AS p
                INNER JOIN Base.Provider AS p2 ON p2.ProviderID = p.ProviderID
                INNER JOIN Mid.ProviderSponsorship AS a ON a.ProviderCode = p2.ProviderCode
                INNER JOIN Base.Product PD ON PD.ProductCode = A.ProductCode
            WHERE
                ProductGroupCode != 'LID'
                AND PD.ProductTypeCode = 'PRACTICE'
        ) A
    WHERE
        RN1 = 1
),
CTE_ProviderPracticeOfficeSponsorshipMAP AS (
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.PracticeCode,
        a.OfficeCode,
        a.PracticeName,
        a.OfficeName,
        a.OfficeID,
        a.PracticeID,
        a.PhoneXML,
        a.ImageXML,
        a.MobilePhoneXML,
        a.TabletPhoneXML,
        a.DesktopPhoneXML,
        a.URLXML,
        CASE
            WHEN LEN(CAST(a.PhoneXML AS VARCHAR)) - LEN(
                REPLACE(CAST(a.PhoneXML AS VARCHAR), '<phTyp>', '123456')
            ) > 1 THEN 1
            ELSE 0
        END AS compositePhone
    FROM
        (
            SELECT
                p2.ProviderCode,
                PD.ProductCode,
                PD.ProductDescription,
                PRG.ProductGroupCode,
                PRG.ProductGroupDescription,
                a.ClientToProductID,
                C.ClientCode,
                C.ClientName,
                a.HasOAR,
                PS.QualityMessageXML,
                PS.AppointmentOptionDescription,
                PS.CallToActionMsg,
                PS.SafeHarborMsg,
                PC.PracticeCode,
                O.OfficeCode,
                PC.PracticeName,
                O.OfficeName,
                a.OfficeID,
                PC.PracticeID,
                a.PhoneXML,
                IFNULL(PS.ImageXML, PSc.ImageXML) AS ImageXML,
                PS.MobilePhoneXML,
                PS.TabletPhoneXML,
                PS.DesktopPhoneXML,
                PS.URLXML,
                ROW_NUMBER() OVER (
                    PARTITION BY P2.ProviderCode,
                    PD.ProductCode,
                    C.ClientCode,
                    O.OfficeCode
                    ORDER BY
                        CASE
                            WHEN PC.PracticeCode IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN a.PhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN PS.URLXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN PS.ImageXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN PS.MobilePhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN PS.TabletPhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END,
                        CASE
                            WHEN PS.DesktopPhoneXML IS NOT NULL THEN 0
                            ELSE 1
                        END
                ) AS RN1
            FROM
                CTE_Temp_Provider AS p
                INNER JOIN Base.Provider AS p2 ON p2.ProviderID = p.ProviderID
                INNER JOIN base.ProviderToMAPCustomerProduct AS a ON a.ProviderID = p2.ProviderID
                AND IFNULL(a.DisplayPartnerCode, 'HG.COM') = 'HG.COM'
                INNER JOIN CTE_ProviderToClientToProduct PCP ON PCP.ProviderId = a.ProviderId
                AND PCP.ClientToProductID = A.ClientToProductID
                INNER JOIN Base.Office O ON O.OfficeId = A.OfficeID
                LEFT JOIN base.Practice PC ON PC.PracticeID = O.PracticeID
                INNER JOIN Base.ClientToProduct AS cp ON cp.ClientToProductID = A.ClientToProductID
                INNER JOIN Base.Client AS c ON c.ClientID = cp.ClientID
                INNER JOIN Base.Product AS pd ON pd.ProductID = cp.ProductID
                INNER JOIN Base.ProductGroup AS prg ON prg.ProductGroupID = pd.ProductGroupID
                LEFT JOIN Mid.ProviderSponsorship AS PS ON PS.ProviderCode = p2.ProviderCode
                AND PS.OfficeCode = O.OfficeCode
                LEFT JOIN Mid.ProviderSponsorship AS PSc ON PSc.ProviderCode = p2.ProviderCode
            WHERE p2.ProviderCode IN (SELECT DISTINCT ProviderCode FROM Mid.ProviderSponsorship)
        ) A
    WHERE
        RN1 = 1
),
CTE_Url AS (
    SELECT
        fa.FacilityCode,
        FacilityURL AS urlVal,
        'FCURL' AS urlTyp,
        '<url>' || urlVal || urlTyp || '</url>' AS XML
    FROM
        Show.SOLRFacility fa
        LEFT JOIN Mid.ProviderSponsorship AS a ON a.FacilityCode = fa.FacilityCode
    ORDER BY
        FacilityURL
),
CTE_A AS (
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.FacilityCode,
        a.FacilityName,
        a.FacilityState,
        a.PhoneXML,
        a.ImageXML,
        a.MobilePhoneXML,
        a.TabletPhoneXML,
        a.DesktopPhoneXML,
        CASE
            WHEN a.URLXML IS NOT NULL THEN a.URLXML
            ELSE CTE_Url.XML
        END AS URLXML
    FROM
        CTE_Temp_Provider AS p
        INNER JOIN Base.Provider AS p2 ON p2.ProviderID = p.ProviderID
        INNER JOIN Mid.ProviderSponsorship AS a ON a.ProviderCode = p2.ProviderCode
        INNER JOIN Base.Product PD ON PD.ProductCode = A.ProductCode
        LEFT JOIN CTE_Url ON CTE_Url.FacilityCode = a.FacilityCode
    WHERE
        ProductGroupCode != 'LID'
        AND (
            a.FacilityCode IS NOT NULL
            OR a.ProductCode IN ('PDCWMDLITE', 'PDCWRITEMD')
        )
        AND (
            PD.ProductCode IN ('MAP')
            OR PD.ProductTypeCode = 'Hospital'
        )
),
CTE_ProviderFacilitySponsorship AS (
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.FacilityCode,
        a.FacilityName,
        a.FacilityState,
        a.PhoneXML,
        a.ImageXML,
        a.MobilePhoneXML,
        a.TabletPhoneXML,
        a.DesktopPhoneXML,
        URLXML,
        0 AS compositePhone
    FROM
        CTE_A a
),
CTE_ProviderClientDisplayPartner AS (
    SELECT
        p2.ProviderCode,
        c.ClientCode,
        sp.SyndicationPartnerCode AS DisplayPartnerCode
    FROM
        CTE_Temp_Provider AS p
        INNER JOIN Base.Provider AS p2 ON p2.ProviderID = p.ProviderID
        INNER JOIN Base.ProviderToClientProductToDisplayPartner AS pc ON pc.ProviderID = p2.ProviderID
        INNER JOIN Base.ClientToProduct AS cp ON cp.ClientToProductID = pc.ClientToProductID
        INNER JOIN Base.Client AS c ON c.ClientID = cp.ClientID
        INNER JOIN Base.Product AS prod ON prod.ProductID = cp.ProductID
        INNER JOIN Base.SyndicationPartner AS sp ON sp.SyndicationPartnerId = pc.SyndicationPartnerID
        INNER JOIN Mid.ProviderSponsorship AS mps ON mps.ProviderCode = p2.ProviderCode
        AND mps.ClientCode = c.ClientCode
        AND mps.ProductCode = prod.ProductCode
    WHERE
        prod.ProductCode IN ('PDCWRITEMD', 'PDCWMDLITE')
    ORDER BY
        p2.ProviderCode,
        c.ClientCode,
        sp.SyndicationPartnerCode
),
CTE_CompositePhonesX AS (
    SELECT
        s.ProviderCode,
        GET(XMLGET(TO_VARIANT(s.PHONEXML), 'phone'), '$') AS PhoneType,
        GET(
            XMLGET(TO_VARIANT(s.DESKTOPPHONEXML), 'phone'),
            '$'
        ) AS DesktopPhoneType,
        GET(
            XMLGET(TO_VARIANT(s.MOBILEPHONEXML), 'phone'),
            '$'
        ) AS MobilePhoneType,
        GET(
            XMLGET(TO_VARIANT(s.TABLETPHONEXML), 'phone'),
            '$'
        ) AS TabletPhoneType
    FROM
        CTE_ProviderFacilitySponsorship S
),
CTE_CompositePhones AS (
    SELECT
        ProviderCode
    FROM
        CTE_CompositePhonesX
    WHERE
        PhoneType IN (
            SELECT
                PhoneTypeCode
            FROM
                Base.PhoneType
            WHERE
                PhoneTypeDescription LIKE '%PSR%'
                OR PhoneTypeDescription LIKE '%Market Targeted%'
        )
        OR DesktopPhoneType IN (
            SELECT
                PhoneTypeCode
            FROM
                Base.PhoneType
            WHERE
                PhoneTypeDescription LIKE '%PSR%'
                OR PhoneTypeDescription LIKE '%Market Targeted%'
        )
        OR MobilePhoneType IN (
            SELECT
                PhoneTypeCode
            FROM
                Base.PhoneType
            WHERE
                PhoneTypeDescription LIKE '%PSR%'
                OR PhoneTypeDescription LIKE '%Market Targeted%'
        )
        OR TabletPhoneType IN (
            SELECT
                PhoneTypeCode
            FROM
                Base.PhoneType
            WHERE
                PhoneTypeDescription LIKE '%PSR%'
                OR PhoneTypeDescription LIKE '%Market Targeted%'
        )
),
CTE_ProviderSponsorship_sq1 AS (
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.compositePhone
    FROM
        CTE_ProviderPracticeOfficeSponsorship A
    UNION ALL
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.compositePhone
    FROM
        CTE_ProviderPracticeOfficeSponsorshipMAP A
    UNION ALL
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        a.compositePhone
    FROM
        CTE_ProviderFacilitySponsorship A
),
CTE_ProviderSponsorship_sq2 AS (
    SELECT
        x.ProviderCode,
        x.ProductCode,
        x.ProductDescription,
        x.ProductGroupCode,
        x.ProductGroupDescription,
        x.ClientToProductID,
        x.ClientCode,
        x.ClientName,
        x.HasOAR,
        x.QualityMessageXML,
        x.AppointmentOptionDescription,
        x.CallToActionMsg,
        x.SafeHarborMsg,
        x.compositePhone,
        CASE
            WHEN HasOAR IS NOT NULL THEN 0
            WHEN QualityMessageXML IS NOT NULL THEN 0
            WHEN AppointmentOptionDescription IS NOT NULL THEN 0
            WHEN CallToActionMsg IS NOT NULL THEN 0
            WHEN SafeHarborMsg IS NOT NULL THEN 0
            ELSE x.RN1
        END as rn1
        FROM(
        SELECT
            a.ProviderCode,
            a.ProductCode,
            a.ProductDescription,
            a.ProductGroupCode,
            a.ProductGroupDescription,
            a.ClientToProductID,
            a.ClientCode,
            a.ClientName,
            a.HasOAR,
            a.QualityMessageXML,
            a.AppointmentOptionDescription,
            a.CallToActionMsg,
            a.SafeHarborMsg,
            a.compositePhone,
            ROW_NUMBER() OVER(
                PARTITION BY 
                a.ProviderCode,
                a.ProductCode,
                a.ClientCode
                ORDER BY
                    a.compositePhone desc
            ) RN1
        FROM
            CTE_ProviderSponsorship_sq1 a
        ) x
),
CTE_ProviderSponsorship AS (
    SELECT
        a.ProviderCode,
        a.ProductCode,
        a.ProductDescription,
        a.ProductGroupCode,
        a.ProductGroupDescription,
        a.ClientToProductID,
        a.ClientCode,
        a.ClientName,
        a.HasOAR,
        a.QualityMessageXML,
        a.AppointmentOptionDescription,
        a.CallToActionMsg,
        a.SafeHarborMsg,
        CASE
            WHEN (
                SELECT COUNT(*)
                FROM CTE_CompositePhones cp
                WHERE cp.ProviderCode = a.ProviderCode
            ) > 1 THEN 1
            ELSE 0
        END AS compositePhone
    FROM CTE_ProviderSponsorship_sq2 a
    WHERE RN1 = 1
),

CTE_ClientFeatureCode AS (
    SELECT 
         ClientFeatureCode AS featCd,
         d.ClientFeatureDescription AS featDesc,
         e.ClientFeatureValueCode AS featValCd,
         e.ClientFeatureValueDescription AS featValDesc,
         a.EntityID, 
         CP.ClientToProductCode
    FROM Base.ClientEntityToClientFeature a
    INNER JOIN Base.ClientToProduct CP on CP.ClientToProductID = a.EntityID
    INNER JOIN Base.Product P ON P.ProductId = CP.ProductID
    INNER JOIN Base.EntityType b ON a.EntityTypeID = b.EntityTypeID
    INNER JOIN Base.ClientFeatureToClientFeatureValue c ON a.ClientFeatureToClientFeatureValueID = c.ClientFeatureToClientFeatureValueID
    INNER JOIN Base.ClientFeature d ON c.ClientFeatureID = d.ClientFeatureID
    INNER JOIN Base.ClientFeatureValue e ON e.ClientFeatureValueID = c.ClientFeatureValueID
    INNER JOIN Base.ClientFeatureGroup f ON d.ClientFeatureGroupID = f.ClientFeatureGroupID
    WHERE b.EntityTypeCode = 'CLPROD'
        AND CASE WHEN ClientFeatureValueCode = 'FVNO' AND ClientFeatureCode IN ('FCOOMT','FCOOPSR', 'FCDOA') THEN 'REMOVE'                 ELSE 'KEEP' END = 'KEEP'
                AND NOT(
                    ClientFeatureCode = 'FCBFN'
                    AND a.EntityID IN (
                        SELECT ClientToProductID
                        FROM Base.ClientToProduct lCP
                        INNER JOIN Base.Client dC ON lCP.ClientID = dC.ClientID
                        WHERE ClientCode IN      ('HCACKS','HCACVA','HCAEFD','HCAFRFT','HCAGC','HCAHL1','HCALEW','HCAMT','HCAMW','HCANFD','HCAPASO','HCARES','HCASAM','HCASATL','HCATRI','HCAWFD','HCAWNV','STDAVD')
                    )
                )
),

CTE_spnFeatXML AS (
    SELECT
        cte_cfc.EntityID,
            listagg(
                '<spnFeat>' ||
                IFF(cte_cfc.featCd IS NOT NULL, '<featCd>' || cte_cfc.featCd || '</featCd>', '') ||
                IFF(cte_cfc.featDesc IS NOT NULL, '<featDesc>' || cte_cfc.featDesc || '</featDesc>', '') ||
                IFF(cte_cfc.featValCd IS NOT NULL, '<featValCd>' || cte_cfc.featValCd || '</featValCd>', '') ||
                IFF(cte_cfc.featValDesc IS NOT NULL, '<featValDesc>' || cte_cfc.featValDesc || '</featValDesc>', '')
                || '</spnFeat>'
            ) AS XMLValue
    FROM CTE_ClientFeatureCode cte_cfc
    GROUP BY cte_cfc.EntityID
),

CTE_spnFeat AS (
    SELECT 
       P.ProviderCode,
       MS.ClientCode AS spnCd,
       MS.ClientName AS spnNm,
       MS.CallToActionMsg AS caToActMsg,
       MS.SafeHarborMsg AS safHarMsg,
       MS.ProductDescription AS spnD,
       CAST(NULL AS BOOLEAN) AS isOarX,
       CTE_spnFeatXML.XMLValue AS XMLValue
    FROM CTE_ProviderSponsorship MS
    INNER JOIN Base.Provider P ON P.ProviderCode = MS.ProviderCode
    INNER JOIN CTE_Temp_Provider A ON A.Providerid = P.ProviderID
    INNER JOIN CTE_spnFeatXML ON MS.ClientToProductID = cte_spnfeatXML.EntityID
    GROUP BY P.ProviderCode,ClientCode,ClientName,ClientToProductID,
             CallToActionMsg,SafeHarborMsg,ProductDescription,XMLValue
),

CTE_clCtrFeatXML AS (
    SELECT
       a.EntityID,
            listagg(
                '<clCtrFeat>' ||
                IFF(ClientFeatureCode IS NOT NULL, '<featCd>' || ClientFeatureCode || '</featCd>', '') ||
                IFF(d.ClientFeatureDescription IS NOT NULL, '<featDesc>' || d.ClientFeatureDescription || '</featDesc>', '') ||
                IFF(e.ClientFeatureValueCode IS NOT NULL, '<featValCd>' || e.ClientFeatureValueCode || '</featValCd>', '') ||
                IFF(e.ClientFeatureValueDescription IS NOT NULL, '<featValDesc>' || e.ClientFeatureValueDescription || '</featValDesc>', '')
                || '</clCtrFeat>') AS XMLValue
    FROM Base.ClientEntityToClientFeature a
    INNER JOIN Base.EntityType b ON a.EntityTypeID = b.EntityTypeID
    INNER JOIN Base.ClientFeatureToClientFeatureValue c ON a.ClientFeatureToClientFeatureValueID = c.ClientFeatureToClientFeatureValueID
    INNER JOIN Base.ClientFeature d ON c.ClientFeatureID = d.ClientFeatureID
    INNER JOIN Base.ClientFeatureValue e ON e.ClientFeatureValueID = c.ClientFeatureValueID
    INNER JOIN Base.ClientFeatureGroup f ON d.ClientFeatureGroupID = f.ClientFeatureGroupID
    WHERE f.ClientFeatureGroupCode = 'FGOAR' AND b.EntityTypeCode = 'CLCTR'
    GROUP BY EntityID, ClientFeatureCode, d.ClientFeatureDescription, 
            e.ClientFeatureValueCode, e.ClientFeatureValueDescription
),

CTE_clCtrL AS (
    SELECT		
        CallCenterCode AS clCtrCd,
        CallCenterName AS clCtrNm,
        ReplyDays AS aptCoffDay,
        ApptCutOffTime AS aptCoffHr,
        EmailAddress AS eml,
        FaxNumber AS fxNo,
        CTE_clCtrFeatXML.XMLValue AS XMLValue,
        ccd.ClientToProductID
    FROM Base.vwuCallCenterDetails ccd
    LEFT JOIN CTE_clCtrFeatXML ON ccd.CallCenterID = CTE_clCtrFeatXML.EntityID
    GROUP BY CallCenterCode,CallCenterName,ReplyDays,ApptCutOffTime,
             EmailAddress,FaxNumber,CallCenterID,ccd.ClientToProductID, XMLValue
),

CTE_OfficeXML AS (
    SELECT
        PPOx.ProviderCode,
        PPOx.OfficeCode,
            listagg(
                '<off>' ||
                IFF(OfficeCode IS NOT NULL, '<offCd>' || OfficeCode || '</offCd>', '') ||
                IFF(OfficeNAme IS NOT NULL, '<offNm>' || OfficeNAme || '</offNm>', '') ||
                IFF(PhoneXML IS NOT NULL, '<phoneL>' || PhoneXML || '</phoneL>', '') ||
                IFF(MobilePhoneXML IS NOT NULL, '<mobilePhoneL>' || MobilePhoneXML || '</mobilePhoneL>', '') ||
                IFF(URLXML IS NOT NULL, '<urlL>' || URLXML || '</urlL>', '') ||
                IFF(ImageXML IS NOT NULL, '<imageL>' || ImageXML || '</imageL>', '') ||
                IFF(TabletPhoneXML IS NOT NULL, '<tabletPhoneL>' || TabletPhoneXML || '</tabletPhoneL>', '') ||
                IFF(DesktopPhoneXML IS NOT NULL, '<desktopPhoneL>' || DesktopPhoneXML || '</desktopPhoneL>', '')
                || '</off>'
        ) AS XMLValue
    FROM CTE_ProviderPracticeOfficeSponsorship PPOx
    GROUP BY PPOx.ProviderCode, PPOx.OfficeCode, OfficeCode, OfficeNAme,
             PhoneXML, MobilePhoneXML, URLXML, ImageXML, TabletPhoneXML, DesktopPhoneXML
),

CTE_PracticePDCPRAC AS (
    SELECT
        PPO.PracticeCode AS pracCd,
        PPO.PracticeName AS pracName,
        CTE_OfficeXML.XMLValue AS offL,
        PPO.ProviderCode
    FROM CTE_ProviderPracticeOfficeSponsorship PPO
    INNER JOIN CTE_OfficeXML ON PPO.ProviderCode = CTE_OfficeXML.ProviderCode AND PPO.OfficeCode = CTE_OfficeXML.OfficeCode
    INNER JOIN Base.Provider P ON P.ProviderCode = PPO.ProviderCode
    INNER JOIN CTE_Temp_Provider Pt ON Pt.ProviderID = P.ProviderID
    WHERE PPO.ProviderCode = p.ProviderCode
    GROUP BY PPO.PracticeCode, PPO.PracticeName, PPO.ProviderCode, PPO.OfficeCode, CTE_OfficeXML.XMLValue
),

CTE_OfficeXMLMAP AS (
    SELECT
        PPO.ProviderCode,
        PPO.OfficeCode,
            listagg(
                '<off>' ||
                IFF(PPO.OfficeCode IS NOT NULL, '<cd>' || PPO.OfficeCode || '</cd>', '') ||
                IFF(PPO.OfficeName IS NOT NULL, '<nm>' || PPO.OfficeName || '</nm>', '') ||
                IFF(PPO.PhoneXML IS NOT NULL, '<phoneL>' || PPO.PhoneXML || '</phoneL>', '') ||
                IFF(PPO.MobilePhoneXML IS NOT NULL, '<mobilePhoneL>' || PPO.MobilePhoneXML || '</mobilePhoneL>', '') ||
                IFF(PPO.URLXML IS NOT NULL, '<urlL>' || PPO.URLXML || '</urlL>', '') ||
                IFF(PPO.TabletPhoneXML IS NOT NULL, '<tabletPhoneL>' || PPO.TabletPhoneXML || '</tabletPhoneL>', '') ||
                IFF(PPO.DesktopPhoneXML IS NOT NULL, '<desktopPhoneL>' || PPO.DesktopPhoneXML || '</desktopPhoneL>', '')
                || '</off>'
        ) AS XMLValue
    FROM CTE_ProviderPracticeOfficeSponsorshipMAP PPO
    GROUP BY PPO.ProviderCode, PPO.OfficeCode, PPO.OfficeName, PPO.PhoneXML, 
             PPO.MobilePhoneXML, PPO.URLXML, PPO.TabletPhoneXML, PPO.DesktopPhoneXML
),

CTE_MAPX AS (
    SELECT DISTINCT
        ProviderCode,
        PracticeCode,
        PracticeName,
        OfficeCode,
        OfficeName,
        CAST(PhoneXML AS VARCHAR()) AS PhoneXML,
        CAST(MobilePhoneXML AS VARCHAR()) AS MobilePhoneXML,
        CAST(URLXML AS VARCHAR()) AS URLXML,
        CAST(ImageXML AS VARCHAR()) AS ImageXML,
        CAST(TabletPhoneXML AS VARCHAR()) AS TabletPhoneXML,
        CAST(DesktopPhoneXML AS VARCHAR()) AS DesktopPhoneXML
    FROM CTE_ProviderPracticeOfficeSponsorshipMAP
),

CTE_PracticeMAP AS (
    SELECT
        'Practice' AS Type,
        X.PracticeCode AS cd,
        X.PracticeName AS nm,
        CAST(NULL AS OBJECT) AS st,
        CAST(NULL AS OBJECT) AS phoneL,
        CAST(NULL AS OBJECT) AS mobilePhoneL,
        CAST(NULL AS OBJECT) AS urlL,
        X.ImageXML AS imageL,
        CAST(NULL AS OBJECT) AS quaMsgL,
        CAST(NULL AS OBJECT) AS tabletPhoneL,
        CAST(NULL AS OBJECT) AS desktopPhoneL,
        X.ProviderCode,
        CTE_OfficeXMLMAP.XMLValue AS offL
    FROM CTE_MAPX AS X
    INNER JOIN CTE_OfficeXMLMAP ON X.ProviderCode = CTE_OfficeXMLMAP.ProviderCode AND X.OfficeCode = CTE_OfficeXMLMAP.OfficeCode
    INNER JOIN Base.Provider P ON P.ProviderCode = X.ProviderCode
    INNER JOIN CTE_Temp_Provider Pt ON Pt.ProviderID = P.ProviderID
),

CTE_FacilityMAP AS (
    SELECT
      'facility' AS Type,
      X.FacilityCode AS cd,
      X.FacilityName AS nm,
      X.FacilityState AS st,
      X.PhoneXML AS phoneL,
      X.MobilePhoneXML AS mobilePhoneL,
      X.URLXML AS urlL,
      X.ImageXML AS imageL,
      X.QualityMessageXML AS quaMsgL,
      X.TabletPhoneXML AS tabletPhoneL,
      X.DesktopPhoneXML AS desktopPhoneL,
      CAST(NULL AS OBJECT ) AS offL,
      P.ProviderCode
    FROM
      (
        SELECT
          ProviderCode,
          FacilityCode,
          FacilityName,
          FacilityState,
          PhoneXML,
          MobilePhoneXML,
          URLXML,
          ImageXML,
          QualityMessageXML,
          TabletPhoneXML,
          DesktopPhoneXML
        FROM
          (
            SELECT
              ProviderCode,
              FacilityCode,
              FacilityName,
              FacilityState,
              PhoneXML,
              MobilePhoneXML,
              URLXML,
              ImageXML,
              QualityMessageXML,
              TabletPhoneXML,
              DesktopPhoneXML,
              ROW_NUMBER() OVER (
                PARTITION BY ProviderCode,
                FacilityCode
                ORDER BY
                  FacilityName
              ) AS RN1
            FROM
              CTE_ProviderFacilitySponsorship
          ) X
        WHERE
          RN1 = 1
      ) X
      INNER JOIN Base.Provider P ON P.ProviderCode = X.ProviderCode
      INNER JOIN CTE_Temp_Provider Pt ON Pt.ProviderID = P.ProviderID
    WHERE
      X.FacilityCode IS NOT NULL
),

CTE_ClientLevelBranded AS (
    SELECT DISTINCT 
        t2.EntityID AS ClientToProductID, 
        t2.ClientToProductCode, 
        t2.featValDesc AS PhoneLevel
    FROM CTE_ClientFeatureCode AS t1
    INNER JOIN CTE_ClientFeatureCode AS t2 ON t2.EntityID = t1.EntityID
    WHERE t1.featDesc = 'Branding Level' AND t1.featValCd = 'FVCLT' AND t2.featCd = 'FCCCP' 
    ORDER BY t2.ClientToProductCode
), 

CTE_ProviderFacilitySponsorship_ClientLevelBranded AS (
    SELECT
        p.ProviderCode,
        p.ClientCode,
        p.ClientName,
        NULL AS FacilityState,
        p.PhoneXML,
        p.MobilePhoneXML,
        NULL AS URLXML,
        p.ImageXML,
        NULL AS QualityMessageXML,
        p.TabletPhoneXML,
        p.DesktopPhoneXML,
        c.PhoneLevel,
        ROW_NUMBER() OVER (PARTITION BY p.ProviderCode ORDER BY p.ClientCode) AS RN1
    FROM
        CTE_ProviderFacilitySponsorship p
        INNER JOIN CTE_ClientLevelBranded c ON c.ClientToProductID = p.ClientToProductID
),

CTE_ProviderSponsorship_ClientLevelBranded AS (
    SELECT
        m.ProviderCode,
        m.ClientCode,
        m.ClientName,
        NULL AS FacilityState,
        CAST(NULL AS VARCHAR()) AS PhoneXML,
        CAST(NULL AS VARCHAR()) AS MobilePhoneXML,
        NULL AS URLXML,
        CAST(NULL AS VARCHAR()) AS ImageXML,
        NULL AS QualityMessageXML,
        CAST(NULL AS VARCHAR()) AS TabletPhoneXML,
        CAST(NULL AS VARCHAR()) AS DesktopPhoneXML,
        c.PhoneLevel,
        ROW_NUMBER() OVER (PARTITION BY m.ProviderCode ORDER BY m.ClientCode) AS RN2
    FROM
        Mid.ProviderSponsorship m
        INNER JOIN CTE_ClientLevelBranded c ON c.ClientToProductID = m.ClientToProductID
    WHERE
        NOT EXISTS (SELECT 1 FROM CTE_ProviderFacilitySponsorship t WHERE t.ClientToProductID = c.ClientToProductID
                    AND t.ProviderCode = m.ProviderCode) AND m.ProductGroupCode != 'LID' AND m.FacilityCode IS NULL
),

CTE_ClientType AS (
    SELECT
        'client' AS Type,
        X.ClientCode AS cd,
        X.ClientName AS nm,
        CAST(NULL AS VARCHAR()) AS st,
        CASE WHEN X.PhoneLevel = 'Client' THEN X.PhoneXML ELSE NULL END AS phoneL,
        CASE WHEN X.PhoneLevel = 'Client' THEN X.MobilePhoneXML ELSE NULL END AS mobilePhoneL,
        CAST(NULL AS VARCHAR()) AS urlL,
        X.ImageXML AS imageL,
        CAST(NULL AS VARCHAR()) AS quaMsgL,
        CASE WHEN X.PhoneLevel = 'Client' THEN X.TabletPhoneXML ELSE NULL END AS tabletPhoneL,
        CASE WHEN X.PhoneLevel = 'Client' THEN X.DesktopPhoneXML ELSE NULL END AS desktopPhoneL,
        CAST(NULL AS VARCHAR()) AS offL,
        P.ProviderCode,
        X.ClientCode
    FROM
        (
            SELECT
                a.ProviderCode,
                a.ClientCode,
                a.ClientName,
                a.FacilityState,
                a.PhoneXML,
                a.MobilePhoneXML,
                a.URLXML,
                a.ImageXML,
                a.QualityMessageXML,
                a.TabletPhoneXML,
                a.DesktopPhoneXML,
                a.RN1,
                a.PhoneLevel
            FROM
                (
                    SELECT 
                    PROVIDERCODE,
                    CLIENTCODE,
                    CLIENTNAME,
                    FACILITYSTATE,
                    to_varchar(PHONEXML) as PHONEXML,
                    to_varchar(MOBILEPHONEXML) as MOBILEPHONEXML,
                    to_varchar(URLXML) as URLXML,
                    to_varchar(IMAGEXML) as IMAGEXML,
                    to_varchar(QUALITYMESSAGEXML) as QUALITYMESSAGEXML,
                    to_varchar(TABLETPHONEXML) as TABLETPHONEXML,
                    to_varchar(DESKTOPPHONEXML) as DESKTOPPHONEXML,
                    PHONELEVEL,
                    RN1 
                    FROM CTE_ProviderFacilitySponsorship_ClientLevelBranded WHERE RN1 = 1
                    UNION ALL
                    SELECT PROVIDERCODE,
                    CLIENTCODE,
                    CLIENTNAME,
                    FACILITYSTATE,
                    to_varchar(PHONEXML) as PHONEXML,
                    to_varchar(MOBILEPHONEXML) as MOBILEPHONEXML,
                    to_varchar(URLXML) as URLXML,
                    to_varchar(IMAGEXML) as IMAGEXML,
                    to_varchar(QUALITYMESSAGEXML) as QUALITYMESSAGEXML,
                    to_varchar(TABLETPHONEXML) as TABLETPHONEXML,
                    to_varchar(DESKTOPPHONEXML) as DESKTOPPHONEXML,
                    PHONELEVEL,
                    RN2  FROM CTE_ProviderSponsorship_ClientLevelBranded WHERE RN2 = 1
                ) a
        ) X
        INNER JOIN Base.Provider P ON P.ProviderCode = X.ProviderCode
        INNER JOIN CTE_Temp_Provider Pt ON Pt.ProviderID = P.ProviderID
),

CTE_ProviderFacilitySponsorshipFinal AS (
    SELECT	
        v.ProviderCode,
        NULL AS Type,
        NULL AS nm,
        v.FacilityCode AS facCd,
        v.FacilityName AS facNm,
        v.FacilityState AS facSt,
        to_varchar(v.PhoneXML) AS phoneL,
        to_varchar(v.MobilePhoneXML) AS mobilePhoneL,
        to_varchar(v.URLXML) AS urlL,
        to_varchar(v.ImageXML) AS imageL,
        to_varchar(v.QualityMessageXML) AS quaMsgL,
        to_varchar(v.TabletPhoneXML) AS tabletPhoneL,
        to_varchar(v.DesktopPhoneXML) AS desktopPhoneL
    FROM CTE_ProviderFacilitySponsorship v
    INNER JOIN CTE_ProviderSponsorship a ON v.ProviderCode = a.ProviderCode AND v.ClientCode = a.ClientCode
    UNION ALL
    SELECT	
        v.ProviderCode,
        v.Type AS Type,
        v.nm AS nm, 
        NULL AS facCd, 
        NULL AS facNm, 
        NULL AS facSt, 
        to_varchar(v.phoneL) AS phoneL, 
        to_varchar(v.mobilePhoneL) AS mobilePhoneL,
        to_varchar(v.urlL) AS urlL,
        to_varchar(v.imageL) AS imageL, 
        to_varchar(v.quaMsgL) AS quaMsgL, 
        to_varchar(v.tabletPhoneL) AS tabletPhoneL, 
        to_varchar(v.desktopPhoneL) AS desktopPhoneL
    FROM CTE_ClientType v
    INNER JOIN CTE_ProviderSponsorship a ON v.ProviderCode = a.ProviderCode AND v.cd = a.ClientCode
),

CTE_PracticeMapFacilityMapClientType AS (
    SELECT
        ProviderCode,
        Type,
        cd,
        nm,
        CAST(st AS VARCHAR()) AS st,
        CAST(phoneL AS VARCHAR()) AS phoneL,
        CAST(mobilePhoneL AS VARCHAR()) AS mobilePhoneL,
        CAST(urlL AS VARCHAR()) AS urlL,
        CAST(imageL AS VARCHAR()) AS imageL,
        CAST(quaMsgL AS VARCHAR()) AS quaMsgL,
        CAST(tabletPhoneL AS VARCHAR()) AS tabletPhoneL,
        CAST(desktopPhoneL AS VARCHAR()) AS desktopPhoneL,
        CAST(offL AS VARCHAR()) AS offL
    FROM CTE_PracticeMAP
    UNION ALL
    SELECT
        ProviderCode,
        Type,
        cd,
        nm,
        CAST(st AS VARCHAR()) AS st,
        CAST(phoneL AS VARCHAR()) AS phoneL,
        CAST(mobilePhoneL AS VARCHAR()) AS mobilePhoneL,
        CAST(urlL AS VARCHAR()) AS urlL,
        CAST(imageL AS VARCHAR()) AS imageL,
        CAST(quaMsgL AS VARCHAR()) AS quaMsgL,
        CAST(tabletPhoneL AS VARCHAR()) AS tabletPhoneL,
        CAST(desktopPhoneL AS VARCHAR()) AS desktopPhoneL,
        CAST(offL AS VARCHAR()) AS offL
    FROM CTE_FacilityMAP
    UNION ALL
    SELECT
        ProviderCode,
        Type,
        NULL AS cd,
        nm,
        CAST(st AS VARCHAR()) AS st,
        CAST(phoneL AS VARCHAR()) AS phoneL,
        CAST(mobilePhoneL AS VARCHAR()) AS mobilePhoneL,
        CAST(urlL AS VARCHAR()) AS urlL,
        CAST(imageL AS VARCHAR()) AS imageL,
        CAST(quaMsgL AS VARCHAR()) AS quaMsgL,
        CAST(tabletPhoneL AS VARCHAR()) AS tabletPhoneL,
        CAST(desktopPhoneL AS VARCHAR()) AS desktopPhoneL,
        CAST(offL AS VARCHAR()) AS offL
    FROM CTE_ClientType
),

CTE_spnFeatXML AS (
    SELECT
        s.ProviderID,
        XMLValue AS spnFeatL,
            listagg(
                '<spn>' ||
                IFF(spnCd IS NOT NULL, '<spnCd>' || spnCd || '</spnCd>', '') ||
                IFF(spnNm IS NOT NULL, '<spnNm>' || spnNm || '</spnNm>', '') ||
                IFF(caToActMsg IS NOT NULL, '<caToActMsg>' || caToActMsg || '</caToActMsg>', '') ||
                IFF(safHarMsg IS NOT NULL, '<safHarMsg>' || safHarMsg || '</safHarMsg>', '') ||
                IFF(spnD IS NOT NULL, '<spnD>' || spnD || '</spnD>', '') ||
                IFF(isOarX IS NOT NULL, '<isOarX>' || isOarX || '</isOarX>', '') ||
                IFF(spnFeatL IS NOT NULL, '<spnFeatL>' || spnFeatL || '</spnFeatL>', '')
                || '</spn>'
        ) AS XMLValue
    FROM CTE_spnFeat
    INNER JOIN Show.SOLRProvider s ON s.ProviderCode = cte_spnFeat.ProviderCode
    GROUP BY s.ProviderID, spnFeatL
),

CTE_PCDPXML AS (
    SELECT
        s.ProviderID,
        '<dpcL>' ||
            listagg(
                IFF(DisplayPartnerCode IS NOT NULL, '<dpcd>' || DisplayPartnerCode || '</dpcd>', '')
        ) || '</dpcL>' AS XMLValue
    FROM CTE_ProviderClientDisplayPartner cte_pcdp
    INNER JOIN Show.SOLRProvider s ON s.ProviderCode = cte_pcdp.ProviderCode
    GROUP BY s.ProviderID
),

CTE_clCtrLXML AS (
    SELECT
        s.ProviderID,
        XMLValue AS clCtrFeatL,
            listagg(
                '<clCtrL>' ||
                IFF(clCtrCd IS NOT NULL, '<clCtrCd>' ||  clCtrCd || '</clCtrCd>', '') ||
                IFF(clCtrNm IS NOT NULL, '<clCtrNm>' || clCtrNm || '</clCtrNm>', '') ||
                IFF(aptCoffDay IS NOT NULL, '<aptCoffDay>' || aptCoffDay || '</aptCoffDay>', '') ||
                IFF(aptCoffHr IS NOT NULL, '<aptCoffHr>' || aptCoffHr || '</aptCoffHr>', '') ||
                IFF(eml IS NOT NULL, '<eml>' || eml || '</eml>', '') ||
                IFF(fxNo IS NOT NULL, '<fxNo>' || fxNo || '</fxNo>', '') ||
                IFF(clCtrFeatL IS NOT NULL, '<clCtrFeatL>' || clCtrFeatL || '</clCtrFeatL>', '')
                || '</clCtrL>'

        ) AS XMLValue
    FROM CTE_clCtrL
    LEFT JOIN CTE_ProviderSponsorship ps ON ps.ClientToProductID = CTE_clCtrL.ClientToProductID
    INNER JOIN Show.SOLRProvider s ON ps.ProviderCode = s.ProviderCode
    GROUP BY s.ProviderID, clCtrFeatL
),

CTE_PracticePDCPRACXML AS (
    SELECT
        s.ProviderID,
        '<dispL>' ||
            listagg(
                '<disp>' ||
                IFF(pracCd IS NOT NULL, '<pracCd>' || pracCd || '</pracCd>', '') ||
                IFF(pracName IS NOT NULL, '<pracName>' || pracName || '</pracName>', '') ||
                IFF(offL IS NOT NULL, '<offL>' || offL || '</offL>', '')
                || '</disp>') || 
        '</dispL>' AS XMLValue
    FROM CTE_PracticePDCPRAC cte_pdcprac
    INNER JOIN Show.SOLRProvider s ON s.ProviderCode = cte_pdcprac.ProviderCode
    GROUP BY ProviderID
),

CTE_PracticeMAPXML AS (
    SELECT
        s.ProviderID,
        '<dispL>' ||
            listagg(
                '<disp>' ||
                IFF(Type IS NOT NULL, '<Type>' || Type || '</Type>', '') ||
                IFF(cd IS NOT NULL, '<cd>' || cd || '</cd>', '') ||
                IFF(nm IS NOT NULL, '<nm>' || nm || '</nm>', '') ||
                IFF(st IS NOT NULL, '<st>' || st || '</st>', '') ||
                IFF(phoneL IS NOT NULL, '<phoneL>' || phoneL || '</phoneL>', '') ||
                IFF(mobilePhoneL IS NOT NULL, '<mobilePhoneL>' || mobilePhoneL || '</mobilePhoneL>', '') ||
                IFF(urlL IS NOT NULL, '<urlL>' || urlL || '</urlL>', '') ||
                IFF(imageL IS NOT NULL, '<imageL>' || imageL || '</imageL>', '') ||
                IFF(quaMsgL IS NOT NULL, '<quaMsgL>' || quaMsgL || '</quaMsgL>', '') ||
                IFF(tabletPhoneL IS NOT NULL, '<tabletPhoneL>' || tabletPhoneL || '</tabletPhoneL>', '') ||
                IFF(desktopPhoneL IS NOT NULL, '<desktopPhoneL>' || desktopPhoneL || '</desktopPhoneL>', '') ||
                IFF(offL IS NOT NULL, '<offL>' || offL || '</offL>', '')
                || '</disp>'
            ) || '</dispL>'
         AS XMLValue
    FROM CTE_PracticeMapFacilityMapClientType cte_pmfmct
    INNER JOIN Show.SOLRProvider s ON s.ProviderCode = cte_pmfmct.ProviderCode
    GROUP BY s.ProviderID
),

CTE_ProviderFacilitySponsorshipXML AS (
    SELECT
        s.ProviderID,
        '<dispL>' ||
            listagg(
                '<disp>' ||
                IFF(Type IS NOT NULL, '<Type>' || Type || '</Type>', '') ||
                IFF(nm IS NOT NULL, '<nm>' || nm || '</nm>', '') ||
                IFF(facCd IS NOT NULL, '<facCd>' || facCd || '</facCd>', '') ||
                IFF(facNm IS NOT NULL, '<facNm>' || facNm || '</facNm>', '') ||
                IFF(facSt IS NOT NULL, '<facSt>' || facSt || '</facSt>', '') ||
                IFF(phoneL IS NOT NULL, '<phoneL>' || phoneL || '</phoneL>', '') ||
                IFF(mobilePhoneL IS NOT NULL, '<mobilePhoneL>' || mobilePhoneL || '</mobilePhoneL>', '') ||
                IFF(urlL IS NOT NULL, '<urlL>' || urlL || '</urlL>', '') ||
                IFF(imageL IS NOT NULL, '<imageL>' || imageL || '</imageL>', '') ||
                IFF(quaMsgL IS NOT NULL, '<quaMsgL>' || quaMsgL || '</quaMsgL>', '') ||
                IFF(tabletPhoneL IS NOT NULL, '<tabletPhoneL>' || tabletPhoneL || '</tabletPhoneL>', '') ||
                IFF(desktopPhoneL IS NOT NULL, '<desktopPhoneL>' || desktopPhoneL || '</desktopPhoneL>', '')
                || '</disp>'
            ) || '</dispL>'AS XMLValue
    FROM CTE_ProviderFacilitySponsorshipFinal cte_pfs
    INNER JOIN Show.SOLRProvider s ON s.ProviderCode = cte_pfs.ProviderCode
    GROUP BY s.ProviderID
),

CTE_SponsorshipXML AS (
    SELECT
        s.ProviderID,
        a.providercode,
        '<sponsorL>' || '<sponsor>' ||
            listagg(
                IFF(a.ProductCode IS NOT NULL, '<prCd>' || a.ProductCode || '</prCd>', '') ||
                IFF(a.ProductGroupCode IS NOT NULL, '<prGrCd>' || a.ProductGroupCode || '</prGrCd>', '') ||
                IFF(a.compositePhone IS NOT NULL, '<compositePhone>' || a.compositePhone || '</compositePhone>', '')
            ) ||
        ifnull(spn.XMLValue,'') ||
        ifnull(pcdp.XMLValue,'') ||
        ifnull(clCtrL.XMLValue,'') ||
        CASE
            WHEN a.ProductCode IN (SELECT ProductCode FROM Base.Product WHERE ProductTypeCode = 'PRACTICE') THEN pdcprac.XMLValue
            WHEN a.ProductCode IN (SELECT ProductCode FROM Base.Product WHERE ProductTypeCode = 'MAP') THEN map.XMLValue
            ELSE pfs.XMLValue
        END ||
        '</sponsor>' || '</sponsorL>' AS XMLValue,
        a.AppointmentOptionDescription AS aptOptDesc
    FROM
        CTE_ProviderSponsorship a
        INNER JOIN mid.provider s ON a.ProviderCode = s.ProviderCode
        LEFT JOIN CTE_spnFeatXML spn ON s.ProviderID = spn.EntityID 
        LEFT JOIN CTE_PCDPXML pcdp ON s.ProviderID = pcdp.ProviderID 
        LEFT JOIN CTE_clCtrLXML clCtrL ON s.ProviderID = clCtrL.ProviderID
        LEFT JOIN CTE_PracticePDCPRACXML pdcprac ON s.ProviderID = pdcprac.ProviderID
        LEFT JOIN CTE_PracticeMAPXML map ON s.ProviderID = map.ProviderID
        LEFT JOIN CTE_ProviderFacilitySponsorshipXML pfs ON s.ProviderID = pfs.ProviderID
        GROUP BY s.ProviderID, pcdp.XMLValue, clCtrL.XMLValue, pdcprac.XMLValue, spn.XMLValue,
                 map.XMLValue, pfs.XMLValue, a.ProductCode, a.ProductGroupCode, 
                 a.compositePhone, a.ProviderCode, a.AppointmentOptionDescription, 
                 a.ClientToProductID, a.ClientCode
),
------------------------------------------------SponsorshipXML------------------------------------------------

------------------------------------------------SearchSponsorshipXML------------------------------------------------
Cte_Search_Spn_feat AS (
    SELECT DISTINCT
        ClientFeatureCode AS featCd,
        cf.ClientFeatureDescription AS featDesc,
        cfv.ClientFeatureValueCode AS featValCd,
        cfv.ClientFeatureValueDescription AS featValDesc,
        ce.EntityID,
        ctp.ClientToProductCode
    FROM Base.ClientEntityToClientFeature ce
    INNER JOIN Base.ClientToProduct ctp ON ctp.ClientToProductID = ce.EntityID
    INNER JOIN Base.Product p ON p.ProductId = ctp.ProductID
    INNER JOIN Base.EntityType et ON ce.EntityTypeID = et.EntityTypeID
    INNER JOIN Base.ClientFeatureToClientFeatureValue cfcfv ON ce.ClientFeatureToClientFeatureValueID = cfcfv.ClientFeatureToClientFeatureValueID
    INNER JOIN Base.ClientFeature cf ON cfcfv.ClientFeatureID = cf.ClientFeatureID
    INNER JOIN Base.ClientFeatureValue cfv ON cfv.ClientFeatureValueID = cfcfv.ClientFeatureValueID
    INNER JOIN Base.ClientFeatureGroup cfg ON cf.ClientFeatureGroupID = cfg.ClientFeatureGroupID
    WHERE et.EntityTypeCode = 'CLPROD'
    AND ClientFeatureCode IN ('FCRAB', 'FCBRL')
    AND cfv.ClientFeatureValueCode IN ('FVPSR', 'FVCLT')
    AND CASE WHEN cfv.ClientFeatureValueCode = 'FVNO' AND ClientFeatureCode IN ('FCOOMT', 'FCOOPSR', 'FCDOA') THEN 'REMOVE' ELSE 'KEEP' END = 'KEEP'
)
-- select * from Cte_Search_Spn_feat;
,

Cte_spn_feat AS (
 SELECT
        DISTINCT 
        entityid as clienttoproductid,
        featCd,
        featDesc,
        featValCd,
        featValDesc
    FROM
        cte_Search_spn_Feat
)
-- select * from cte_spn_feat;
,

Cte_spn_feat_xml as (
 SELECT
        clienttoproductid,
            listagg(
                '<spnFeat>' ||
                IFF(featCd IS NOT NULL, '<featCd>' || featCd || '</featCd>', '') ||
                IFF(featDesc IS NOT NULL, '<featDesc>' || featDesc || '</featDesc>', '') ||
                IFF(featValCd IS NOT NULL, '<featValCd>' || featValCd || '</featValCd>', '') ||
                IFF(featValDesc IS NOT NULL, '<featValDesc>' || featValDesc || '</featValDesc>', '')
                || '</spnFeat>'
        ) AS XMLValue
    FROM
        cte_spn_feat
    GROUP BY
        clienttoproductid
)
-- select * from Cte_spn_feat_xml;
,

Cte_search_spn as (
    SELECT DISTINCT	
        P.ProviderCode,
        MS.ClientCode,
        MS.ClientCode AS spnCd,
        MS.ClientName AS spnNm,
        MS.SafeHarborMsg AS safHarMsg,
        spn.xmlvalue AS spnFeatL
    FROM		Mid.ProviderSponsorship MS
    INNER JOIN	Base.Provider P ON P.ProviderCode = MS.ProviderCode
    INNER JOIN	Show.SolrProvider A ON A.Providerid = P.ProviderID
    INNER JOIN  Cte_spn_feat_xml spn ON spn.clienttoproductid = Ms.Clienttoproductid
    WHERE		MS.ProductGroupCode <> 'LID'
)
-- select * from Cte_search_spn;
,

cte_office_pdc_prac as (
    SELECT DISTINCT
        ProviderCode,
        OfficeCode,
        OfficeCode AS offCd,
        OfficeName AS offNm,
        PhoneXML AS phoneL,
        MobilePhoneXML AS mobilePhoneL,
        URLXML AS urlL,
        ImageXML AS imageL,
        TabletPhoneXML AS tabletPhoneL,
        DesktopPhoneXML AS desktopPhoneL
    FROM
        Cte_ProviderPracticeOfficeSponsorship 
)
-- select * from cte_office_pdc_prac;
,

cte_office_pdc_prac_xml as (
    SELECT
        ProviderCode,
        OfficeCode,
            listagg(
                '<off>' ||
                IFF(offCd IS NOT NULL, '<offCd>' || offCd || '</offCd>', '') ||
                IFF(offNm IS NOT NULL, '<offNm>' || offNm || '</offNm>', '') ||
                IFF(phoneL IS NOT NULL, '<phoneL>' || phoneL || '</phoneL>', '') ||  -- Assuming phoneL and others are already well-formatted JSON
                IFF(mobilePhoneL IS NOT NULL, '<mobilePhoneL>' || mobilePhoneL || '</mobilePhoneL>', '') ||
                IFF(urlL IS NOT NULL, '<urlL>' || urlL || '</urlL>', '') ||
                IFF(imageL IS NOT NULL, '<imageL>' || imageL || '</imageL>', '') ||
                IFF(tabletPhoneL IS NOT NULL, '<tabletPhoneL>' || tabletPhoneL || '</tabletPhoneL>', '') ||
                IFF(desktopPhoneL IS NOT NULL, '<desktopPhoneL>' || desktopPhoneL || '</desktopPhoneL>', '')
                || ' </off>'
        ) AS XMLValue
    FROM
        cte_office_pdc_prac
    GROUP BY
        ProviderCode,
        OfficeCode
)
-- select * from cte_office_pdc_prac_xml;
,

Cte_search_practice_pdc_prac as (
        SELECT DISTINCT		
            PPO.PracticeCode AS pracCd,
            PPO.PracticeName AS pracName,
            off.xmlvalue AS offl,
            PPO.ProviderCode
		FROM Cte_ProviderPracticeOfficeSponsorship PPO
		INNER JOIN	Base.Provider P ON P.ProviderCode = PPO.ProviderCode
		INNER JOIN	Show.SolrProvider Pt ON Pt.ProviderID = P.ProviderID
        INNER JOIN cte_office_pdc_prac_xml off ON off.providercode = ppo.providercode and off.officecode = ppo.officecode
)
-- select * from Cte_search_practice_pdc_prac;
,

cte_providerclientdisplaypartner2 as (
    SELECT
        dis.providercode,
        dis.clientcode,
        case when dis.displaypartnercode is null then 'HG' else dis.displaypartnercode end as displaypartnercode
    FROM cte_providerclientdisplaypartner as dis
    JOIN cte_providersponsorship as spo on dis.providercode = spo.providercode
    WHERE spo.productcode in ('MAP', 'PDCHSP')
)
-- select * from cte_providerclientdisplaypartner2;
,

-- Define the CTE for Search Spn data
cte_spn_search as (
    SELECT DISTINCT
        providercode,
        clientcode,
        spnCd,
        spnNm,
        safHarMsg,
        spnFeatL
    FROM
        Cte_search_spn 
)
-- select * from cte_spn_search;
,

cte_spn_search_xml as (
    SELECT
        providercode,
        clientcode,
            listagg(
                '<spn>' ||
                IFF(spnCd IS NOT NULL, '<spnCd>' || spnCd || '</spnCd>', '') ||
                IFF(spnNm IS NOT NULL, '<spnNm>' || spnNm || '</spnNm>', '') ||
                IFF(safHarMsg IS NOT NULL, '<safHarMsg>' || safHarMsg || '</safHarMsg>', '') ||
                IFF(spnFeatL IS NOT NULL, '<spnFeatL>' || spnFeatL || '</spnFeatL>', '')
                || '</spn>'
        ) AS XMLValue
    FROM
        cte_spn_search
    GROUP BY
        providercode,
        clientcode
)
-- select * from cte_spn_search_xml;
,

cte_dpc_search as (
    SELECT DISTINCT
        ProviderCode,
        ClientCode,
        DisplayPartnerCode as dpcd
    FROM
        cte_providerclientdisplaypartner2 
)
-- select * from cte_dpc_search;
,

cte_dpc_search_xml as (
    SELECT
        ProviderCode,
        ClientCode,
            '<dpcL>' || listagg(
                IFF(dpcd IS NOT NULL, '<dpcd>' || dpcd || '</dpcd>', '')
            ) ||
            '</dpcL>'
         AS XMLValue
    FROM
        cte_dpc_search
    GROUP BY
        ProviderCode,
        ClientCode
)
-- select * from cte_dpc_search_xml;
,

cte_disp1_search as (
    SELECT
        ProviderCode,  
        pracCd,
        pracName,
        offL
    FROM
        Cte_search_practice_pdc_prac  
),

cte_disp1_search_xml as (
    SELECT
        ProviderCode,
        '<dispL>' ||
            listagg(
                '<disp>' ||
                IFF(pracCd IS NOT NULL, '<pracCd>' || pracCd || '</pracCd>', '') ||
                IFF(pracName IS NOT NULL, '<pracName>' || pracName || '</pracName>', '') ||
                IFF(offL IS NOT NULL, '<offL>' || offL || '</offL>', '')
                || '<disp>'
            ) || '</dispL>' AS XMLValue
    FROM
        cte_disp1_search
    GROUP BY
        ProviderCode
)
-- select * from cte_disp1_search_xml;
,

cte_disp2_search as (
    SELECT 
        ProviderCode,
        Type,
        cd,
        nm,
        to_varchar(st) as st,
        to_varchar(phoneL) as phonel,
        to_varchar(mobilePhoneL) as mobilephonel,
        to_varchar(urlL) as urll,
        NULL as imageL,
        to_varchar(quaMsgL) as quamsgl,
        to_varchar(tabletPhoneL) as tabletphonel,
        to_varchar(desktopPhoneL) as desktopphonel,
        to_varchar(offL) as offL
    FROM cte_practicemap 
    UNION ALL
    SELECT 
        ProviderCode,
        Type,
        cd,
        nm,
        to_varchar(st),
        to_varchar(phoneL),
        to_varchar(mobilePhoneL),
        to_varchar(urlL),
        to_varchar(imageL),
        to_varchar(quaMsgL),
        to_varchar(tabletPhoneL),
        to_varchar(desktopPhoneL),
        to_varchar(offL)
    FROM cte_facilitymap 
    UNION ALL
    SELECT 
        ProviderCode,
        Type,
        cd,
        nm,
        to_varchar(st),
        to_varchar(phoneL),
        to_varchar(mobilePhoneL),
        to_varchar(urlL),
        to_varchar(imageL),
        to_varchar(quaMsgL),
        to_varchar(tabletPhoneL),
        to_varchar(desktopPhoneL),
        to_varchar(offL)
    FROM cte_clienttype 
)
-- select * from cte_disp2_search;
,

cte_disp2_search_xml as (
    SELECT
        ProviderCode,
                '<dispL>'||            
                listagg(
                '<disp>' ||
                IFF(Type IS NOT NULL, '<Type>' || Type || '</Type>', '') ||
                IFF(cd IS NOT NULL, '<cd>' || cd || '</cd>', '') ||
                IFF(nm IS NOT NULL, '<nm>' || nm || '</nm>', '') ||
                IFF(st IS NOT NULL, '<st>' || st || '</st>', '') ||
                IFF(phoneL IS NOT NULL, '<phoneL>' || phoneL || '</phoneL>', '') ||
                IFF(mobilePhoneL IS NOT NULL, '<mobilePhoneL>' || mobilePhoneL || '</mobilePhoneL>', '') ||
                IFF(urlL IS NOT NULL, '<urlL>' || urlL || '</urlL>', '') ||
                IFF(imageL IS NOT NULL, '<imageL>' || imageL || '</imageL>', '') ||
                IFF(quaMsgL IS NOT NULL, '<quaMsgL>' || quaMsgL || '</quaMsgL>', '') ||
                IFF(tabletPhoneL IS NOT NULL, '<tabletPhoneL>' || tabletPhoneL || '</tabletPhoneL>', '') ||
                IFF(desktopPhoneL IS NOT NULL, '<desktopPhoneL>' || desktopPhoneL || '</desktopPhoneL>', '') ||
                IFF(offL IS NOT NULL, '<offL>' || offL || '</offL>', '')
                || '</disp>'
            ) || '</dispL>' AS XMLValue
    FROM
        cte_disp2_search
    GROUP BY
        ProviderCode
)
-- select * from cte_disp2_search_xml;
,

cte_disp3_search as (
    SELECT
        providercode,
        clientcode,
        null AS Type,
        null AS nm,
        FacilityCode AS facCd,
        FacilityName AS facNm,
        FacilityState AS facSt,
        to_varchar(PhoneXML) AS phoneL,
        to_varchar(MobilePhoneXML) AS mobilePhoneL,
        to_varchar(URLXML) AS urlL,
        to_varchar(ImageXML) AS imageL,
        to_varchar(QualityMessageXML) AS quaMsgL,
        to_varchar(TabletPhoneXML) AS tabletPhoneL,
        to_varchar(DesktopPhoneXML) AS desktopPhoneL
    FROM
        CTE_ProviderFacilitySponsorship 
    WHERE
        ProductGroupCode <> 'LID'
    UNION
    SELECT
        ProviderCode,
        ClientCode,
        Type,
        nm,
        null AS facCd,
        null AS facNm,
        null AS facSt,
        to_varchar(phoneL),
        to_varchar(mobilePhoneL),
        to_varchar(urlL),
        to_varchar(imageL),
        to_varchar(quaMsgL),
        to_varchar(tabletPhoneL),
        to_varchar(desktopPhoneL)
    FROM
        Cte_ClientType 
)
-- select * from cte_disp3_search;
,

cte_disp3_search_xml as (
    SELECT
        providercode,
        clientcode,
                '<dispL>' ||
                listagg(
                '<disp>' ||
                IFF(Type IS NOT NULL, '<Type>' || Type || '</Type>', '') ||
                IFF(nm IS NOT NULL, '<nm>' || nm || '</nm>', '') ||
                IFF(facCd IS NOT NULL, '<facCd>' || facCd || '</facCd>', '') ||
                IFF(facNm IS NOT NULL, '<facNm>' || facNm || '</facNm>', '') ||
                IFF(facSt IS NOT NULL, '<facSt>' || facSt || '</facSt>', '') ||
                IFF(phoneL IS NOT NULL, '<phoneL>' || phoneL || '</phoneL>', '') ||  -- Assuming XML columns are already properly formatted JSON strings
                IFF(mobilePhoneL IS NOT NULL, '<mobilePhoneL>' || mobilePhoneL || '</mobilePhoneL>', '') ||
                IFF(urlL IS NOT NULL, '<urlL>' || urlL || '</urlL>', '') ||
                IFF(imageL IS NOT NULL, '<imageL>' || imageL || '</imageL>', '') ||
                IFF(quaMsgL IS NOT NULL, '<quaMsgL>' || quaMsgL || '</quaMsgL>', '') ||
                IFF(tabletPhoneL IS NOT NULL, '<tabletPhoneL>' || tabletPhoneL || '</tabletPhoneL>', '') ||
                IFF(desktopPhoneL IS NOT NULL, '<desktopPhoneL>' || desktopPhoneL || '</desktopPhoneL>', '') ||
                '</disp>'
            )|| '</dispL>' AS XMLValue
    FROM
        cte_disp3_search
    GROUP BY
        providercode,
        clientcode
)
-- select * from cte_disp3_search_xml;
,


cte_search_sponsorship as (
    SELECT DISTINCT
        ps.providercode,
        ps.productcode as prcd,
        ps.productgroupcode as prgrcd,
        ps.compositePhone,
        CASE WHEN (SELECT COUNT(1) FROM cte_ProviderFacilitySponsorship as pfs JOIN mid.provider as p WHERE pfs.FacilityCode IS NOT NULL AND pfs.ProviderCode = p.ProviderCode) > 0 THEN 0 ELSE 1 END AS mtOfficeType,
        spn.xmlvalue as spn,
        dpc.xmlvalue as dpcl,
        CASE WHEN ps.ProductCode IN (select ProductCode FROM Base.Product WHERE ProductTypeCode = 'PRACTICE') THEN disp1.xmlvalue 
        WHEN ps.ProductCode IN (SELECT ProductCode FROM Base.Product WHERE ProductTypeCode = 'MAP') THEN disp2.xmlvalue
        ELSE disp3.xmlvalue end as displ,
        ps.appointmentoptiondescription as aptoptdesc
    FROM cte_providersponsorship ps
    LEFT JOIN cte_spn_search_xml spn on spn.providercode = ps.providercode and spn.clientcode = ps.clientcode
    LEFT JOIN cte_dpc_search_xml dpc on dpc.providercode = ps.providercode and dpc.clientcode = ps.clientcode
    LEFT JOIN cte_disp1_search_xml disp1 on disp1.providercode = ps.providercode
    LEFT JOIN cte_disp2_search_xml disp2 on disp2.providercode = ps.providercode
    LEFT JOIN cte_disp3_search_xml disp3 on disp3.providercode = ps.providercode and disp3.clientcode = ps.clientcode
    WHERE 
        ps.productgroupcode != 'LID'
),

cte_search_sponsorship_xml as (
SELECT
        s.ProviderCode, 
        '<sponsorL>' ||
            listagg(
             '<sponsor>'||
            IFF(prcd IS NOT NULL, '<prcd>' || prcd || '</prcd>', '') ||
            IFF(prgrcd IS NOT NULL, '<prgrcd>' || prgrcd || '</prgrcd>', '') ||
            IFF(compositePhone IS NOT NULL, '<compositePhone>' || compositePhone || '</compositePhone>', '') ||
            IFF(mtOfficeType IS NOT NULL, '<mtOfficeType>' || mtOfficeType || '</mtOfficeType>', '') ||
            IFF(spn IS NOT NULL, '<spn>' || spn || '</spn>', '') ||
            IFF(dpcl IS NOT NULL, '<dpcl>' || dpcl || '</dpcl>', '') ||
            IFF(displ IS NOT NULL, '<displ>' || displ || '</displ>', '') ||
            IFF(aptoptdesc IS NOT NULL, '<aptoptdesc>' || aptoptdesc || '</aptoptdesc>', '')
            ||'</sponsor>'   
                ) || '</sponsorL>' AS XMLValue
    FROM
        cte_search_sponsorship a
        INNER JOIN mid.provider s ON a.ProviderCode = s.ProviderCode
    GROUP BY
        s.ProviderCode
)

select 
distinct
    p.providerid ,
    to_variant(parse_xml(sponsrxml.xmlvalue)) as sponsorshipxml,
    to_variant(parse_xml(searchxml.xmlvalue)) as searchsponsorshipxml
from show.solrprovider p
    left join CTE_SponsorshipXML sponsrxml on p.providercode = sponsrxml.providercode
    left join cte_search_sponsorship_xml searchxml on p.providercode = searchxml.providercode
where sponsrxml.xmlvalue is not null or searchxml.xmlvalue is not null
$$;

update_statement_xml_load_4 := $$
    update show.solrprovider as target
        set 
        target.sponsorshipxml = source.sponsorshipxml,
        target.searchsponsorshipxml = source.searchsponsorshipxml 
        from ($$ || select_statement_sponsorship || $$) as source
        where target.providerid = source.providerid
$$;


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement_2 := ' merge into show.solrprovider as target using 
                   ('||select_statement_2 ||') as source 
                   on source.providerid = target.providerid
                   WHEN MATCHED then '||update_statement_2 || '
                   when not matched then '||insert_statement_2 ;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Show.SOLRProvider;
end if; 
execute immediate merge_statement_2;
execute immediate update_statement_3;
execute immediate update_statement_4;
execute immediate update_statement_5;
execute immediate update_statement_6;
execute immediate update_statement_7;
execute immediate update_statement_8;
execute immediate update_statement_9;
execute immediate update_statement_10; 
execute immediate update_statement_11;
if ((select count(*) from base.client c join base.clienttoproduct ctp on c.clientid = ctp.clientid where c.clientcode = 'fresen') > 1) then
    execute immediate update_statement_12;
end if;
execute immediate update_statement_13;
execute immediate update_statement_14;
execute immediate update_statement_15;
execute immediate update_statement_16;
execute immediate update_statement_17;
execute immediate update_statement_18;
execute immediate update_statement_19;
execute immediate update_statement_20;
execute immediate temp_table_statement_1;
execute immediate update_statement_temp_1;
execute immediate update_statement_21;
execute immediate update_statement_22;
execute immediate if_condition;
if ((select
    count(1)
from
    show.solrprovider p
    left join (
        select
            distinct *
        from(
                select
                    providerid,
                    providercode,
                    sponsorcode,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                    'displ'
                                ),
                                'disp'
                            ),
                            'type'
                        ),
                        '$'
                    ) as displaytype,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                    'displ'
                                ),
                                'disp'
                            ),
                            'cd'
                        ),
                        '$'
                    ) as practicecode,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(
                                        xmlget(
                                            xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                            'displ'
                                        ),
                                        'disp'
                                    ),
                                    'offl'
                                ),
                                'off'
                            ),
                            'cd'
                        ),
                        '$'
                    ) as officecode,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(
                                        xmlget(
                                            xmlget(
                                                xmlget(
                                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                    'displ'
                                                ),
                                                'disp'
                                            ),
                                            'offl'
                                        ),
                                        'off'
                                    ),
                                    'phonel'
                                ),
                                'phone'
                            ),
                            'ph'
                        ),
                        '$'
                    ) as phonenumber,
                    get(
                        xmlget(
                            xmlget(
                                xmlget(
                                    xmlget(
                                        xmlget(
                                            xmlget(
                                                xmlget(
                                                    xmlget(parse_xml(sponsorshipxml), 'sponsor'),
                                                    'displ'
                                                ),
                                                'disp'
                                            ),
                                            'offl'
                                        ),
                                        'off'
                                    ),
                                    'phonel'
                                ),
                                'phone'
                            ),
                            'phtyp'
                        ),
                        '$'
                    ) as phonetype,
                from
                    show.solrprovider,
                where
                    productcode = 'map'
            )
    ) x on x.providerid = p.providerid
where
    productcode = 'map'
    and practiceofficexml is not null
    and(
        x.providerid is null
        or len(phonenumber) = 0
    )
    and p.displaystatuscode != 'h'
    and sponsorshipxml is not null)< 20 ) then 
    execute immediate update_statement_23;
end if;
execute immediate update_statement_24;

--------------------- XMLLOAD --------------------------

execute immediate update_statement_xml_load_1;
execute immediate update_statement_xml_load_2;
execute immediate update_statement_xml_load_3;
execute immediate update_statement_xml_load_4;
execute immediate update_statement_condition_hierarchy;
execute immediate update_statement_cond_mapped;
execute immediate update_statement_facility;

---------------------------------------------------------
--------------- 6. status monitoring --------------------
--------------------------------------------------------- 

status := 'completed successfully';
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        return status;

        exception
        when other then
            status := 'failed during execution. ' || 'sql error: ' || sqlerrm || ' error code: ' || sqlcode || ' sql state: ' || sqlstate;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, split_part(regexp_substr(:status, 'error code: ([0-9]+)'), ':', 2)::integer, trim(split_part(split_part(:status, 'sql error:', 2), 'error code:', 1)), split_part(regexp_substr(:status, 'sql state: ([0-9]+)'), ':', 2)::integer; 

            return status;

end;