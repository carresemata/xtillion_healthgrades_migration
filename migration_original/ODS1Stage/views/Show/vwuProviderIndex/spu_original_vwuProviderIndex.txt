SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [Show].[vwuProviderIndex] 
as 
 
/*-------------------------------------------------------------------- 
View                    : Show.vwuProviderIndex 
 
Description        : View to show Provider Solr Index data 
 
CreatedBy          : John Tran 
CreatedOn         : October 2011 
 
Server                 : ???? 
 
Modified By:    Barbara Gunion 
Modified On:    6/6/2013 
Change:                             Added HealthInsuranceXML_v2 to view. 
 
Modified By:    Erik Shaw 
Modified On:    7/9/2013 
Change:                             Removed hasAddressXML = 1, hasSpecialtyXML = 1, ExpireCode is null from Where clause 
                Added DisplayStatusCode not in ('S', 'I') to Where clause 
                Added column DisplayStatusCode 
                                                          Added column SubStatusCode 

Modified By:    Eugene Atha
Modified On:    8/5/2019
Change:                             Added column OfficeCodes 
                                                          Added column HospitalCodes 

Testing                :   
select top 100 * from Show.vwuProviderIndex 
 
select providerid, sponsorcode, OASXML from Show.vwuProviderIndex 
WHERE ProviderId in ('6C313951-6776-0037-0000-000000000000','37523078-3930-0030-0000-000000000000')
 
 
---------------------------------------------------------------------*/ 
               
select  
             SOLRProviderID 
            ,p.ProviderID as ProviderID 
            ,p.ProviderCode as ProviderCode 
            ,ProviderLegacyKey as ProviderLegacyKey 
            ,FirstName as FirstName 
            ,LastName as LastName 
            ,MiddleName as MiddleName 
            ,left(MiddleName,1) as MiddleInitial 
            ,Suffix as Suffix 
            ,Degree as Degree 
            ,Title as Title 
            ,isnull(FirstName,'')+' '+case when MiddleName is null then '' else left(isnull(MiddleName,''),1)+'. 'end+isnull(LastName,'')+case when Suffix is not null then ' '+isnull(Suffix,'') else '' end as FirstMiddleInitialLastName 
                                           ,(isnull(Title,'')+case when Title is null then '' else ' ' end+isnull(FirstName,'')+' '+isnull(LastName,'')+case when Suffix is not null then ' '+isnull(Suffix,'') else '' end+case when Degree is not null then ', '+Degree else '' end)         as DisplayName              
                                           ,case  
                        when Title is not null then Title +' '+isnull(LastName,'')  
                        else isnull(FirstName,'')+' '+isnull(LastName,'') 
            end  
            +case  
                        when Suffix is not null then ' '+isnull(Suffix,'')  
                        else ''  
             end as DisplayLastName 
            ,case  
                        when Title is not null then Title +' '+isnull(LastName,'')   
                        else isnull(FirstName,'')+' '+isnull(LastName,'')  
             end  
             +case  
                        when Suffix is not null then ' '+isnull(Suffix,'') 
                        else ''  
              end 
            +case  
                        when right(LastName,1) = 's' then +'''' 
                        else +'''s' 
              end as DisplayLastNamePossessive 
            ,Gender as Gender 
            ,(convert(int, convert(varchar, getdate(), 112)) - convert(int, convert(varchar, DateOfBirth, 112)))/10000 as Age 
            ,DateOfBirth 
            ,YearsSinceMedicalSchoolGraduation as YearsSinceMedicalSchoolGraduation 
            ,p.ProviderTypeGroup as ProviderTypeGroup 
            ,PatientExperienceSurveyOverallCount as PatientExperienceSurveyOverallCount 
            ,cast( round( PatientExperienceSurveyOverallScore * 2, 0 ) / 2 as decimal( 5, 2 ) ) as PatientExperienceSurveyOverallScore 
            ,DisplayPatientExperienceSurveyOverallScore as DisplayPatientExperienceSurveyOverallScore     
            ,HasDisplayImage as HasDisplayImage 
            ,DisplayImage as DisplayImage 
            ,ProviderURL 
            ,AcceptsNewPatients as AcceptsNewPatients 
            ,CarePhilosophy as CarePhilosophy 
            ,YearlySearchVolume as YearlySearchVolume 
            ,null as ClientID--NULL's AS PLACE HOLDERS 
            ,null as ClientType--NULL's AS PLACE HOLDERS 
            ,null as ProfileType--NULL's AS PLACE HOLDERS 
            ,RecognitionXML as RecognitionXML 
            ,SpecialtyXML as SpecialtyXML 
            ,AddressXML as AddressXML 
            ,PracticeOfficeXML as PracticeOfficeXML 
            ,CityStateAll as CityStateAll 
            ,LicenseXML as LicenseXML 
            ,p.ConditionXML as ConditionXML 
            ,p.ProcedureXML as ProcedureXML 
            ,EducationXML as EducationXML 
            ,FacilityXML as FacilityXML 
            ,SurveyXML as SurveyXML 
            ,SurveyResponse as SurveyResponse 
            ,SurveyResponseDate as SurveyResponseDate 
            ,SuppressSurvey as SuppressSurvey 
            ,MediaXML as MediaXML 
            ,MalpracticeXML as MalpracticeXML 
            ,SanctionXML as SanctionXML 
            ,BoardActionXML as BoardActionXML 
            ,LanguageXML as LanguageXML 
            ,HealthInsuranceXML as HealthInsuranceXML 
            ,HealthInsuranceXML_v2 as HealthInsuranceXML_v2 
            ,CASE WHEN DC.ClientCode IS NOT NULL THEN NULL ELSE SponsorshipXML END as SponsorshipXML 
            ,CASE WHEN DC.ClientCode IS NOT NULL THEN NULL ELSE SearchSponsorshipXML END as SearchSponsorshipXML 
            ,case when SponsorCode = 'xxx' then null else OASXML end as OASXML 
            ,ProviderSpecialtyFacility5StarXML as ProviderSpecialtyFacility5StarXML 
            ,HasAddressXML as HasAddressXML 
            ,HasSpecialtyXML as HasSpecialtyXML 
            ,HasPhilosophy as HasPhilosophy 
            ,HasMediaXML as HasMediaXML 
            ,HasProcedureXML as HasProcedureXML 
            ,HasConditionXML as HasConditionXML 
            ,HasMalpracticeXML as HasMalpracticeXML 
            ,HasSanctionXML as HasSanctionXML  
            ,HasBoardActionXML as HasBoardActionXML  
            ,HasProviderSpecialtyFacility5StarXML as HasProviderSpecialtyFacility5StarXML 
            ,CASE WHEN DC.ClientCode IS NOT NULL THEN NULL ELSE ProductGroupCode END as ProductGroupCode 
            --,SponsorCode as SponsorCode 
            ,CASE WHEN DC.ClientCode IS NOT NULL THEN NULL ELSE SponsorCode END as SponsorCode 
            ,FacilityCode as FacilityCode 
            ,CASE WHEN DC.ClientCode IS NOT NULL THEN NULL ELSE ProductCode END as ProductCode 
            ,VideoXML as VideoXML 
            --,ImageXML as ImageXML 
            ,case 
                                                          when isnull(HasDisplayImage,0) = 0 
                                                          then 
                                                                        case  
                                                                                      when Gender = 'M' then '<imgL> 
                                                                                                                                                                               <img> 
                                                                                                                                                                                            <imgC>small</imgC> 
                                                                                                                                                                                            <imgU>/img/silhouettes/silhouette-male_w60h80_v1.jpg</imgU> 
                                                                                                                                                                                            <imgA>small image</imgA> 
                                                                                                                                                                                            <imgW>60</imgW> 
                                                                                                                                                                                            <imgH>80</imgH> 
                                                                                                                                                                               </img> 
                                                                                                                                                                               <img> 
                                                                                                                                                                                            <imgC>medium</imgC> 
                                                                                                                                                                                            <imgU>/img/silhouettes/silhouette-male_w90h120_v1.jpg</imgU> 
                                                                                                                                                                                            <imgA>medium image</imgA> 
                                                                                                                                                                                            <imgW>90</imgW> 
                                                                                                                                                                                            <imgH>120</imgH> 
                                                                                                                                                                               </img> 
                                                                                                                                                                               <img> 
                                                                                                                                                                                            <imgC>large</imgC> 
                                                                                                                                                                                            <imgU>/img/silhouettes/silhouette-male_w120h160_v1.jpg</imgU> 
                                                                                                                                                                                            <imgA>large image</imgA> 
                                                                                                                                                                                            <imgW>120</imgW> 
                                                                                                                                                                                            <imgH>160</imgH> 
                                                                                                                                                                               </img> 
                                                                                                                                                                             </imgL>' 
                                                                                      when Gender = 'F' then '<imgL> 
                                                                                                                                                                               <img> 
                                                                                                                                                                                            <imgC>small</imgC> 
                                                                                                                                                                                            <imgU>/img/silhouettes/silhouette-female_w60h80_v1.jpg</imgU> 
                                                                                                                                                                                            <imgA>small image</imgA> 
                                                                                                                                                                                            <imgW>60</imgW> 
                                                                                                                                                                                            <imgH>80</imgH> 
                                                                                                                                                                               </img> 
                                                                                                                                                                               <img> 
                                                                                                                                                                                            <imgC>medium</imgC> 
                                                                                                                                                                                            <imgU>/img/silhouettes/silhouette-female_w90h120_v1.jpg</imgU> 
                                                                                                                                                                                            <imgA>medium image</imgA> 
                                                                                                                                                                                            <imgW>90</imgW> 
                                                                                                                                                                                            <imgH>120</imgH> 
                                                                                                                                                                               </img> 
                                                                                                                                                                              <img> 
                                                                                                                                                                                            <imgC>large</imgC> 
                                                                                                                                                                                            <imgU>/img/silhouettes/silhouette-female_w120h160_v1.jpg</imgU> 
                                                                                                                                                                                            <imgA>large image</imgA> 
                                                                                                                                                                                            <imgW>120</imgW> 
                                                                                                                                                                                            <imgH>160</imgH> 
                                                                                                                                                                               </img> 
                                                                                                                                                                             </imgL>' 
                                                                                      else '<imgL> 
                                                                                                                     <img> 
                                                                                                                                 <imgC>small</imgC> 
                                                                                                                                 <imgU>/img/silhouettes/silhouette-unknown_w60h80_v1.jpg</imgU> 
                                                                                                                                 <imgA>small image</imgA> 
                                                                                                                                 <imgW>60</imgW> 
                                                                                                                                 <imgH>80</imgH> 
                                                                                                                     </img> 
                                                                                                                     <img> 
                                                                                                                                 <imgC>medium</imgC> 
                                                                                                                                 <imgU>/img/silhouettes/silhouette-unknown_w90h120_v1.jpg</imgU> 
                                                                                                                                 <imgA>medium image</imgA> 
                                                                                                                                 <imgW>90</imgW> 
                                                                                                                                 <imgH>120</imgH> 
                                                                                                                     </img> 
                                                                                                                     <img> 
                                                                                                                                 <imgC>large</imgC> 
                                                                                                                                 <imgU>/img/silhouettes/silhouette-unknown_w120h160_v1.jpg</imgU> 
                                                                                                                                 <imgA>large image</imgA> 
                                                                                                                                 <imgW>120</imgW> 
                                                                                                                                 <imgH>160</imgH> 
                                                                                                                     </img> 
                                                                                                                   </imgL>' 
                                                                                      end 
                                                          else ImageXML 
                                            end as ImageXML 
            ,AdXML as AdXML 
            ,IsActive as IsActive 
            ,ExpireCode as ExpireCode 
            ,UpdatedDate as UpdatedDate 
            ,UpdatedSource as UpdatedSource 
            ,HasProfessionalOrganizationXML as HasProfessionalOrganizationXML 
            ,ProfessionalOrganizationXML as ProfessionalOrganizationXML 
            ,ProviderProfileViewOneYear as ProviderProfileViewOneYear 
            ,ProviderBiography as ProviderBiography 
            ,PatientExperienceSurveyOverallStarValue as PatientExperienceSurveyOverallStarValue 
            ,PracticingSpecialtyXML as PracticingSpecialtyXML 
            ,HasPracticingSpecialtyXML as HasPracticingSpecialtyXML 
            ,CertificationXML as CertificationXML 
            ,HasCertificationXML as HasCertificationXML 
            ,DisplayStatusCode 
            ,SubStatusCode 
                                           ,SubStatusDescription 
            ,case  
                                                          when Degree in ('MD','DO','PhD','PsyD','DDS','DMD','OD','DC','DPM') then 1 
                                                          else 0 
                                            end IsPremiumDegree, 
             case  
                                                          when Degree in ('MD','DO','PhD','PsyD','DDS','DMD','OD','DC','DPM') then '0.40' 
                                                          when Degree = 'PA' then '0.20' 
                                                          else '0' 
                                            end as DegreeBoost, 
             case  
                                                          when HasCertificationXML = 1 then '0.25' 
                                                          else '0' 
                                            end as CertificationBoost,                                         
             case  
                                                          when HasMalpracticeXML = 1 then '0' 
                                                          when HasMalpracticeState = 0 then '0'  
                                                          else '0.1' 
                                            end as MalpracticeBoost,                       
             case  
                                                          when HasSanctionXML = 1 then '0' 
                                                          else '0.4' 
                                            end as SanctionBoost, 
             case  
                                                          when HasBoardActionXML = 1 then '0' 
                                                          else '0.4' 
                                            end as BoardActionBoost,                                                                                   
                                           HasMalpracticeState,  
                                           ProcedureHierarchyXML, 
                                           ConditionHierarchyXML, 
                                           NPI, 
                                           ProcMappedXML, 
                                           CondMappedXML, 
                                           PracSpecHeirXML, 
                                           AboutMeXML, 
                                           HasAboutMeXML, 
                                           case 
                                                          when cp.ProviderID is null then 0  
                                                          else 1 
                                           end as IsConsolidated, 
                                           PatientVolume, 
                                           case 
                                                          when (ProcedureCount+ConditionCount) >= 5 then 0.5 
                                                          when ((ProcedureCount+ConditionCount) > 0 and (ProcedureCount+ConditionCount) < 5) then 0.2 
                                                          else 0 
                                           end as DCPCountBoost, 
                                           ProcedureCount, 
                                           ConditionCount, 
                                           AvailabilityXML, 
                                           VideoXML2, 
                                           AvailabilityStatement,                                                                                                          
                                           --CASE  
                                           --            WHEN ISNULL(pa.ProviderCode, '') = '' THEN 0 
                                           --            ELSE 1 
                                           --END    AS ShowComment, 
                                           1 as ShowComment, 
                                           HasOAR, 
                                           NatlAdvertisingXML, 
                                           APIXML as APIXML, 
                                           DIHGroupNumber, 
                                           null as   UPIN, 
                                           null as SSN4, 
                                           null as ABMSUID, 
                                           null as SurveySuppressionReason, 
                                           null as DEAXML, 
                                           null as HasDEAXML, 
                                           null as EmailAddressXML, 
                                           null as HasEmailAddressXML, 
                                           null as DegreeXML, 
                                           p.ClientCertificationXML, 
                                           HasSurveyXML, 
                                           HasGoogleOAS,
                                           HasVideoXML2,
                                           HasAboutMe,
                                           ( (cast(isnull(HasVideoXML2,0) as int)*0.1) + (cast(isnull(HasPhilosophy,0) as int)*0.2) + (cast(isnull(HasAboutMe,0) as int)*0.3) + (cast(isnull(HasDisplayImage,0) as int)*0.4) ) as CompatibilityBoost ,
                                           ConversionPathXML,
                                           SearchBoostSatisfaction,
                                           SearchBoostAccessibility,
                                           IsPCPCalculated as IsPCP,
                                           FAFBoostSatisfaction,
                                           FAFBoostSancMalp,
                                           FFDisplaySpecialty,
                                           p.FFPESBoost,
                                           p.FFMalMultiHQ,
                                           p.FFMalMulti,
                                           (SELECT STUFF((SELECT N'|' + OfficeId FROM (SELECT T2.loc.value('.', 'nvarchar(20)') AS 'OfficeId' FROM Show.SOLRProvider p2 WITH(NOLOCK) CROSS APPLY p2.PracticeOfficeXML.nodes('/poffL/poff/offL/off/oID') AS T2(loc) WHERE p2.SOLRProviderID = p.SOLRProviderID) SubQuery FOR XML PATH(''), TYPE).value('text()[1]', 'nvarchar(max)'), 1, 1, N'')) AS 'OfficeCodes',
                                           (SELECT STUFF((SELECT N'|' + FacilityId FROM (SELECT T2.loc.value('.', 'nvarchar(30)') AS 'FacilityId' FROM Show.SOLRProvider p2 WITH(NOLOCK) CROSS APPLY p2.FacilityXML.nodes('/facL/fac/fLegacyId') AS T2(loc) WHERE p2.SOLRProviderID = p.SOLRProviderID) SubQuery FOR XML PATH(''), TYPE).value('text()[1]', 'nvarchar(max)'), 1, 1, N'')) AS 'HospitalCodes'
				,ClinicalFocusXML, ClinicalFocusDCPXML
				,SyndicationXML
				,TeleHealthXML
				,CASE WHEN P.ProviderId IN (SELECT ProviderId FROM Base.NoIndexNoFollow) THEN 1 ELSE 0 END as NoIndexNoFollow
				,CASE WHEN P.ProviderId IN (SELECT ProviderId FROM Base.NoIndexNoFollowSC) THEN 1 ELSE 0 END as NoIndexNoFollowSC
				,ISNULL(SourceUpdateDateTime,P.UpdatedDate) AS SourceUpdateDateTime
				,ISNULL(SourceUpdate, 'Vendor Data') AS SourceUpdate
				,DateOfFirstLoad
				,ProviderSubTypeCode
				,TrainingXML 
				,LastUpdateDateXML
        ,SmartReferralXML
        ,p.SmartReferralClientCode
        ,p.IsBoardActionEligible
from     Show.SOLRProvider p 
left join Show.ConsolidatedProviders cp on p.ProviderID = cp.ProviderID 
left join Show.DelayClient dc on dc.ClientCode = P.SponsorCode and GoLiveDate > CAST(GETDATE() AS DATE) and P.ProviderCode NOT IN ('y9tbn8z')
where   p.DisplayStatusCode not in ('S', 'I', 'H') 
                             and  p.PracticingSpecialtyXML IS NOT NULL
                             and P.PracticeOfficeXML IS NOT NULL
GO
