CREATE OR REPLACE PROCEDURE ODS1_STAGE.SHOW.SP_LOAD_SOLRPROVIDER(IsProviderDeltaProcessing BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER 
    AS
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Show.SOLRProvider depends on: 
--- Show.WebFreeze
--- Show.ProviderSourceUpdate
--- Show.SOLRProviderDelta
--- Mid.ProviderPracticeOffice
--- Mid.ProviderEducation
--- Mid.ProviderSponsorship
--- Mid.ProviderSurveyResponse
--- Mid.ProviderMalpractice
--- Mid.ProviderProcedure
--- Mid.Provider
--- Mid.ClientMarket
--- Base.Provider
--- Base.ProviderImage
--- Base.ProviderEmail
--- Base.ProviderType
--- Base.ProviderSanction
--- Base.ProviderSubType
--- Base.ProviderSurveyAggregate
--- Base.ProviderSurveySuppression
--- Base.ProviderToSubStatus
--- Base.ProviderToProviderSubType
--- Base.ProviderAppointmentAvailabilityStatement (DEPRECATED)
--- Base.ProviderSubTypeToDegree
--- Base.ProviderToDegree
--- Base.ProviderToOffice
--- Base.ProviderToSpecialty
--- Base.ProviderLegacyKeys
--- Base.ProviderToAboutMe
--- Base.AboutMe
--- Base.Product
--- Base.MediaSize
--- Base.MediaImageHost
--- Base.MediaContextType
--- Base.SubStatus
--- Base.OfficeToAddress
--- Base.Address
--- Base.CityStatePostalCode
--- Base.GeographicArea
--- Base.DisplayStatus
--- Base.MalpracticeState
--- Base.SanctionAction
--- Base.SanctionActionType
--- Base.SpecialityGroup
--- Base.SpecialtyGroupToSpecialty
--- Base.Client
--- Base.ClientToProduct
--- Base.Specialty






---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------