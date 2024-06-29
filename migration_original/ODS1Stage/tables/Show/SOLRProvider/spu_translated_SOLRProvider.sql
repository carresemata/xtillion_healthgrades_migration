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
    select_statement_facility string;
    update_statement_facility string;
    select_statement_condition_hierarchy string;
    update_statement_condition_hierarchy string;
    select_statement_cond_mapped string;
    update_statement_cond_mapped string;
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
                                -- select top 1000
                    					p.providerid
                    			from base.provider as p 
                    			where 	p.npi is not null
                    			union 
                    			select distinct
                                -- select top 1000
                    					p.providerid
                    			from    $$ || mdm_db || $$.mst.provider_profile_processing as ppp 
                    			inner join base.provider as p on p.providercode = ppp.ref_PROVIDER_CODE
                    			where 	p.npi is not null
                                
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
                                            bpsa.providerid,
                                            (ProviderAverageScore / 5) * 100 as PatientExperienceSurveyOverallScore,
                                            row_number() over(
                                                partition by bpsa.providerid
                                                order by
                                                    bpsa.updatedon desc
                                            ) as RN1
                                        from
                                            base.providersurveyaggregate as BPSA
                                            inner join cte_batch_process CTE_BP on CTE_bp.providerid = bpsa.providerid
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
                                            bpsa.providerid,
                                            bpsa.provideraveragescore,
                                            row_number() over(
                                                partition by bpsa.providerid
                                                order by
                                                    bpsa.updatedon desc
                                            ) as RN1
                                        from
                                            base.providersurveyaggregate as BPSA
                                            inner join cte_batch_process CTE_BP on CTE_bp.providerid = bpsa.providerid
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
                                            bpsa.providerid,
                                            bpsa.questioncount,
                                            row_number() over(
                                                partition by bpsa.providerid
                                                order by
                                                    bpsa.updatedon desc
                                            ) as RN1
                                        from
                                            base.providersurveyaggregate as BPSA
                                            inner join cte_batch_process CTE_BP on CTE_bp.providerid = bpsa.providerid
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
                                    left join cte_patient_experience_survey_overall_score as CTE_PESOS on CTE_pesos.providerid = p.providerid
                                    left join cte_patient_experience_survey_overall_star_value as CTE_PESOSV on CTE_pesosv.providerid = p.providerid
                                    left join cte_patient_experience_survey_overall_count as CTE_PESOC on CTE_pesoc.providerid = p.providerid
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
) ,

------------------------ClinicalFocusDCPXML------------------------

cte_mtcode as (
    SELECT
        ProviderId,
        refMedicalTermCode AS MTCode,
        NationalRankingB AS NRankB,
        ClinicalFocusShortDescription
    FROM
        Base.ClinicalFocusDCP 
),

cte_mtcode_xml as (
    SELECT
        ProviderId,
       '<MTCodeL>' || listagg('<MTCode>' || 
        iff(MTCode is not null,'<MTCode>' || MTCode || '</MTCode>','') ||
        iff(NRankB is not null,'<NRankB>' || NRankB || '</NRankB>','') || 
        '</MTCode>', '') || '</MTCodeL>'
 AS XMLValue
    FROM
        cte_mtcode
    GROUP BY
        ProviderId
),

cte_clinical_focus_dcp as (
    SELECT
        C.providerid,
        C.ClinicalFocusShortDescription AS CLFdesc,
        cte.xmlvalue
    FROM
        Base.ClinicalFocusDCP C
        JOIN cte_mtcode_xml cte ON cte.providerid = C.providerid
),

cte_clinical_focus_dcp_xml as (
    SELECT
        providerid,
        '<CLFdescL>' || listagg('<CLFdesc>' || 
        iff(CLFdesc is not null,'<CLFdesc>' || CLFdesc || '</CLFdesc>','') || 
        '</CLFdesc>', '') || '</CLFdescL>'
 AS XMLValue
    FROM
        cte_clinical_focus_dcp
    GROUP BY
        providerid
) ,

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
select_statement_facility := $$ with CTE_ProviderProceduresq AS (
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
),

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
    pf.AddressXML AS addrL,
    pf.PDCPhoneXML AS pdcPhoneL,
    pf.FacilityURL AS fUrl,
    pf.FacilityType AS fType,
    pf.FacilityTypeCode AS fTypeCd,
    pf.FacilitySearchType AS fSearchTyp,
    pf.FiveStarProcedureCount AS fiveStrCnt,
    f.ImageXML AS imageL,
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
    aw.xmlvalue as awardxml,
    rat.xmlvalue as ratingsxml 
FROM Mid.ProviderFacility AS pf
    JOIN Mid.Facility f ON pf.FacilityID = f.FacilityID
    JOIN Mid.Provider p ON p.ProviderID = pf.ProviderID
    LEFT JOIN Mid.ProviderSponsorship ps ON p.ProviderCode = ps.ProviderCode AND f.FacilityCode = ps.FacilityCode
    JOIN Cte_award_xml as aw on aw.facilityid = pf.legacykey
    JOIN Cte_ratings_xml as rat on rat.facilityid = pf.legacykey
    left join ERMART1.Facility_FacilityToSurvey fs on fs.FacilityID = f.LegacyKey and fs.SurveyID = 1 AND fs.QuestionID = 10
),

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

---------------------  XMLLOAD --------------------------

execute immediate update_statement_xml_load_1;
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
