var data = [
    {
        "entity_name": "spubasetableloads",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuOptInClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "MAPProvisioinedLines",
                "schema_name": "CallTracking",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatusArchive",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "etl",
                "database_name": "ODS1STAGE",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "ETL",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuInsertDeltas",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeCustomerProduct",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeCustomerProductImage",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeFacilityAddress",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeFacilityCustomerProduct",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeFacilityHours",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeFacilityImage",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeFacilityToFacilityType",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeOffice",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeOfficeAddress",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeOfficeHours",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeOfficePhone",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeOfficeSyndication",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergePractice",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergePracticeCustomerProduct",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergePracticeOfficeCustomerProduct",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProvider",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderAboutMe",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderAppointmentAvailability",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderAppointmentAvailabilityStatement",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderBridgeCalcsAndRanks",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderCertificationSpecialty",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderClinicalFocus",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderCondition",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderCustomerProduct",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderCustomerProductDisplayPartner",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderDegree",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderEducationInstitution",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderEmail",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderFacility",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderFacilityCustomerProduct",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderHealthInsurance",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderIdentification",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderIdentifier",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderImage",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderLanguage",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderLastUpdateDate",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderLicense",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderMalpractice",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderMAPCustomerProduct",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderMedia",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderOASCustomerProduct",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderOffice",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderOfficeCustomerProduct",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderOrganization",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderProcedure",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderProviderSubType",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderProviderType",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderSanction",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderSpecialty",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderSubStatus",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderSurveySuppression",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderTelehealth",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderTraining",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderURL",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderVideo",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderDeltaLoads",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuRenameDeltaTablesForProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuRenameTablesForCompletion",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuRenameTablesForProcessing",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductImage",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityImage",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeHours",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderImage",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLicense",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAboutMe",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToCertificationSpecialty",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToDegree",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToEducationInstitution",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToHealthInsurance",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToLanguage",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderType",
                "schema_name": "fastpass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSubStatus",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToTelehealth",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderVideo",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RemoveFacilityFromClient",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RemoveProviderFromClient",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuDeDuplicateOffices",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuDeleteClientProductEntityRelationship",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuDeleteFromMDM",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuDeleteProviderFacilityDesignations",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeAddress",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeEntityToMedicalTerm",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeOffice",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeOfficeToAddress",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeOfficeToHours",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeOfficeToPhone",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergePractice",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProvider",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderLicense",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderToAboutMe",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderToCertificationSpecialty",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderToDegree",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderToEducationInstitution",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderToFacility",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderToHealthInsurance",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderToLanguage",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderToOffice",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderToProviderType",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderToSpecialty",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderToStatus",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderToTelehealth",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuPreProcess",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderSourceUpdate",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductImage",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityImage",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeHours",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderImage",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLicense",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAboutMe",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToCertificationSpecialty",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToDegree",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToEducationInstitution",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToHealthInsurance",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToLanguage",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderType",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSubStatus",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToTelehealth",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderVideo",
                "schema_name": "FastPassArchive",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MissingTrackingLines",
                "schema_name": "Hack",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuCustomerProductReplace",
                "schema_name": "Hack",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuClientProductActiveFlag",
                "schema_name": "ODSFix",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuOfficeDuplicateSuiteAddress",
                "schema_name": "ODSFix",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderOfficeRank",
                "schema_name": "ODSFix",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "CustomerProductProfile",
                "schema_name": "Raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfile",
                "schema_name": "Raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfile",
                "schema_name": "Raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessing",
                "schema_name": "Raw",
                "database_name": "Snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "PracticeProfile",
                "schema_name": "Raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfile",
                "schema_name": "Raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "BlockMDMProviderList",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientDataArchive",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientDataArchive",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuClientProductEntityRelationship",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuClientProductEntityRelationship",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuClientProductToEntity",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuClientProductToEntity",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeEntityToMedicalTerm",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeOfficePractice",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProvider",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderEducationInstitution",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderLanguage",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuOfficeToPhone",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuPreProcessing",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderToAboutMe",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderToDegree",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderToFacility",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderToOffice",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderToProviderType",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderToSpecialty",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderToStatus",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderToTelehealth",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "WebFreeze",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "MAPProvisioinedLines",
        "schema_name": "CallTracking",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderOfficeSyndication",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToMAPCustomerProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveNonNumerical",
                "schema_name": "dbo",
                "database_name": "ODS1STAGE",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "CallCapCampaign",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "ETL",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "value",
                "schema_name": "phone",
                "database_name": "a",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "BlockMDMProviderList",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuInsertDeltas",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "provider",
                "schema_name": "base",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeCustomerProduct",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientEntityToClientFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureToClientFeatureValue",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureValue",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToPartner",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Partner",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PartnerType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "CustomerProductProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "CustomerProductProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeCustomerProductImage",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaImageType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaReviewLevel",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaSize",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "etl",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CustomerProductProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "CustomerProductProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeFacilityAddress",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeFacilityCustomerProduct",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityToImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityToURL",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Image",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MarketShareToClientProductEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "URL",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeFacilityHours",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityHours",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeFacilityImage",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaImageType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaReviewLevel",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaSize",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "ETL",
                "database_name": "ODS1STAGE",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "etl",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityImage",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeFacilityToFacilityType",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityToFacilityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeOffice",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "DaysOfWeek",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeHours",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveNonAlphaNumerical",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "ETL",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeOfficeAddress",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuMergeCityStatePostalCode",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeOfficeHours",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "DaysOfWeek",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeHours",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeOfficePhone",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeOfficeSyndication",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeSyndication",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergePractice",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PracticeProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "PracticeProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergePracticeCustomerProduct",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MarketShareToClientProductEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RelationshipType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "PracticeProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "PracticeProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergePracticeOfficeCustomerProduct",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RelationshipType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProvider",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveNonAlphaNumerical",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "ETL",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderAboutMe",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAboutMe",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderAppointmentAvailability",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAppointmentAvailability",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderAppointmentAvailabilityStatement",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderAppointmentAvailabilityStatement",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderBridgeCalcsAndRanks",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "AboutMe",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "AppointmentAvailability",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CallCenter",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientEntityToClientFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureToClientFeatureValue",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureValue",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToCallCenter",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CohortToCondition",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CohortToProcedure",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ConditionToConditionVolumeMapping",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ExperienceBoostWeight",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MalpracticeClaimType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Partner",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PartnerToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PartnerType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcedureToProcedureVolumeMapping",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderAppointmentAvailabilityStatement",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderEmail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMedia",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSanction",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAboutMe",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAppointmentAvailability",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToCertificationSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToDegree",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacilitytoMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToHealthInsurance",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToLanguage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOrganization",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderVideo",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "QualityBoostWeight",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SatisfactionBoostWeight",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ServiceLineToCondition",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ServiceLineToProcedure",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Source",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyToCondition",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyToProcedureMedical",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "TreatmentLevel",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderSurveyAggregate",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Facility",
                "database_name": "ERMart1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToProcedureRating",
                "schema_name": "Facility",
                "database_name": "ERMart1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToServiceLineRating",
                "schema_name": "Facility",
                "database_name": "ERMart1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcedureToServiceLine",
                "schema_name": "Facility",
                "database_name": "ERMart1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessing",
                "schema_name": "raw",
                "database_name": "Snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "Snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderAttributeMetadata",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuRebuildIndexes",
                "schema_name": "util",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderCertificationSpecialty",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "CertificationAgency",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationBoard",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToCertificationSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderClinicalFocus",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ClinicalFocus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToClinicalFocus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderCondition",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderCustomerProduct",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ClientEntityOpt",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "provider",
                "schema_name": "base",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToCustomerToProductToFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RelationshipType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderCustomerProductDisplayPartner",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToClientProductToDisplayPartner",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SyndicationPartner",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderDegree",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Degree",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToDegree",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderEducationInstitution",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "EducationInstitution",
                "schema_name": "base",
                "database_name": "ods1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EducationInstitution",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EducationInstitutionType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EducationInstitutionType",
                "schema_name": "base",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToEducationInstitution",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToEducationInstitution",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuTRIM",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderToEducationInstitution",
                "schema_name": "fastpass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderEmail",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderEmail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderFacility",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderFacilityCustomerProduct",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RelationshipType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderHealthInsurance",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "HealthInsurancePlanToPlanType",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToHealthInsurance",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderIdentification",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderIdentification",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderIdentifier",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderImage",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "MediaImageHost",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "etl",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderImage",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderLanguage",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Language",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToLanguage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToLanguage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderToLanguage",
                "schema_name": "fastpass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderLastUpdateDate",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderAppointmentAvailabilityStatement",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderEmail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderIdentification",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLastUpdateDate",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLicense",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMedia",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAboutMe",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAppointmentAvailability",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToCertificationSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToDegree",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToEducationInstitution",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToHealthInsurance",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToLanguage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOrganization",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderSubType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSubStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToTelehealthMethod",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderTraining",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderVideo",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderLicense",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLicense",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLicense",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLicense",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderMalpractice",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "sp_send_dbmail",
                "schema_name": "",
                "database_name": "msdb",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "sp_send_dbmail",
                "schema_name": "",
                "database_name": "msdb",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "MalpracticeClaimType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MalpracticeClaimType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MalpracticeState",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLicense",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuTrim",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Malpractice",
                "schema_name": "rawfile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderMAPCustomerProduct",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "DestinationPhoneNumberType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToMAPCustomerProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SyndicationPartner",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderMedia",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMedia",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderOASCustomerProduct",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Partner",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PartnerToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderOffice",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderOfficeCustomerProduct",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RelationshipType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderOrganization",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Organization",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Position",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOrganization",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderProcedure",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderProviderSubType",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSubType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderSubType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderProviderType",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderSanction",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "sp_send_dbmail",
                "schema_name": "",
                "database_name": "msdb",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSanction",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSanction",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SanctionAction",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SanctionCategory",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SanctionType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuTrim",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Sanctions",
                "schema_name": "rawfile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderSpecialty",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderSubStatus",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSubStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SubStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderSurveySuppression",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSurveySuppression",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SurveySuppressionReason",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderTelehealth",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToTelehealthMethod",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "TelehealthMethod",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "TelehealthMethodType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderTraining",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderTraining",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderURL",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderURL",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderVideo",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderVideo",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderVideo",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "etl",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderVideo",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderDeltaLoads",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "etl",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "ETL",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "Snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuRenameDeltaTablesForProcessing",
        "schema_name": "etl",
        "database_name": "Snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuRenameTablesForCompletion",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuRenameTablesForProcessing",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "CustomerProductProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "CustomerProductProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PracticeProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "PracticeProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuDeDuplicateOffices",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "ETL",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "fastpass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeProviderToOffice",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuDeleteClientProductEntityRelationship",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "base",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityToImage",
                "schema_name": "base",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityToPhone",
                "schema_name": "base",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityToURL",
                "schema_name": "base",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MarketShareToClientProductEntity",
                "schema_name": "base",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "ETL",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDesignationPriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RemoveFacilityFromClient",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RemoveProviderFromClient",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "Standardized",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Standardized",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuDeleteFromMDM",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CustomerProductProfileProcessing",
                "schema_name": "Raw",
                "database_name": "Snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfileProcessing",
                "schema_name": "Raw",
                "database_name": "Snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessing",
                "schema_name": "Raw",
                "database_name": "Snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessingDeDup",
                "schema_name": "Raw",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PracticeProfileProcessing",
                "schema_name": "Raw",
                "database_name": "Snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "PracticeProfileProcessingDeDup",
                "schema_name": "Raw",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfile",
                "schema_name": "Raw",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "Raw",
                "database_name": "Snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDedup",
                "schema_name": "Raw",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "BlockMDMProviderList",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuDeleteProviderFacilityDesignations",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RelationshipType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeAddress",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveNonAlphabetical",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "fnuTRIM",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Address",
                "schema_name": "map",
                "database_name": "ProfiseePreStaging",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "NewAddress",
                "schema_name": "temp",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "NewCSPC",
                "schema_name": "temp",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeEntityToMedicalTerm",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "rawfile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeOffice",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "DaysOfWeek",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeHours",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveNonAlphaNumerical",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "ETL",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeOfficeToAddress",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeOfficeToHours",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "DaysOfWeek",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeHours",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeHours",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeOfficeToPhone",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveNonNumerical",
                "schema_name": "dbo",
                "database_name": "ODS1STAGE",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergePractice",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PracticeProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "PracticeProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProvider",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveNonAlphaNumerical",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "ETL",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderLicense",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLicense",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLicense",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLicense",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderToAboutMe",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "AboutMe",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAboutMe",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAboutMe",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderToCertificationSpecialty",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "CertificationAgency",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationBoard",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToCertificationSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToCertificationSpecialty",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderToDegree",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Degree",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToDegree",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToDegree",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderToEducationInstitution",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "EducationInstitution",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EducationInstitutionType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToEducationInstitution",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuTRIM",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToEducationInstitution",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderToFacility",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderToHealthInsurance",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "HealthInsurancePlanToPlanType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToHealthInsurance",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToHealthInsurance",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderToLanguage",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Language",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToLanguage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToLanguage",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderToOffice",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderToProviderType",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderType",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderToSpecialty",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderToStatus",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSubStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SubStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSubStatus",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderToTelehealth",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToTelehealthMethod",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "TelehealthMethod",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "TelehealthMethodType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToTelehealth",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuPreProcess",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "fastpass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "fastpass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "fastpass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderSourceUpdate",
        "schema_name": "FastPass",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductImage",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityImage",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeHours",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderImage",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLicense",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAboutMe",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToCertificationSpecialty",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToDegree",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToEducationInstitution",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToHealthInsurance",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToLanguage",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSubStatus",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToTelehealth",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderVideo",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSourceUpdate",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "MissingTrackingLines",
        "schema_name": "Hack",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToMAPCustomerProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuCustomerProductReplace",
        "schema_name": "Hack",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityProfileProcessing",
                "schema_name": "Raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessing",
                "schema_name": "Raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "PracticeProfileProcessing",
                "schema_name": "Raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "Raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuClientProductActiveFlag",
        "schema_name": "ODSFix",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "sp_send_dbmail",
                "schema_name": "",
                "database_name": "msdb",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatusArchive",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuOfficeDuplicateSuiteAddress",
        "schema_name": "ODSFix",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "provider",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderOfficeRank",
        "schema_name": "ODSFix",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuClientProductEntityRelationship",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RelationshipType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "rawfile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "Standardized",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuClientProductToEntity",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Standardized",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeEntityToMedicalTerm",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "rawfile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeOfficePractice",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveNonAlphaNumerical",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveNonAlphaNumerical",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "fnuTRIM",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "fnuTRIM",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeOffice",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergeOfficeToAddress",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMergePractice",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "SourceData",
                "schema_name": "HMS",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProvider",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveNonAlphaNumerical",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "ETL",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDelta",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderEducationInstitution",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "EducationInstitution",
                "schema_name": "base",
                "database_name": "ods1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EducationInstitution",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EducationInstitutionType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EducationInstitutionType",
                "schema_name": "base",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToEducationInstitution",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToEducationInstitution",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuTRIM",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderToEducationInstitution",
                "schema_name": "fastpass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeProviderLanguage",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Language",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToLanguage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToLanguage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderToLanguage",
                "schema_name": "fastpass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProfiseeToReltioOutputComparison",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuOfficeToPhone",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveNonNumerical",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveNonNumerical",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Fastpass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Fastpass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SourceData",
                "schema_name": "HMS",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "rawfile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuPreProcessing",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "sp_send_dbmail",
                "schema_name": "",
                "database_name": "msdb",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveNonNumerical",
                "schema_name": "dbo",
                "database_name": "ODS1STAGE",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConfigSourcePriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDesignationPriority",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RemoveProviderFromClient",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "RawFile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityData",
                "schema_name": "ref",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderToAboutMe",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAboutMe",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "rawfile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderToDegree",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Degree",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToDegree",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderToDegree",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "rawfile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderToFacility",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityToFacilityType",
                "schema_name": "Base",
                "database_name": "ODs1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuTrim",
                "schema_name": "dbo",
                "database_name": "snowflake",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "FastPass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "rawfile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderToOffice",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Providertooffice",
                "schema_name": "Fastpass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Providertooffice",
                "schema_name": "Fastpass",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SourceData",
                "schema_name": "HMS",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "rawfile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderToProviderType",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderType",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "rawfile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderToSpecialty",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "rawfile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderToStatus",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SubStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSubStatus",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "rawfile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderToTelehealth",
        "schema_name": "RawFile",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderToTelehealth",
                "schema_name": "FastPass",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientData",
                "schema_name": "rawfile",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuGetErrorInfo",
        "schema_name": "util",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMergeCityStatePostalCode",
        "schema_name": "etl",
        "database_name": "snowflake",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessing",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "OfficeProfileProcessingDeDup",
                "schema_name": "raw",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "snowflake",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spumidproviderentityrefresh",
        "schema_name": "etl",
        "database_name": "ods1stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "DisplayStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuBackfillProviderToFacilityHack",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuCalculateIsSearchableGeneralSuppression",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuCalculateProviderDisplaySpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuCallCenterIntCodeHack",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuDefaultPDCCallCenterRelationship",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderSponsorshipAndOASCleanup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSetBatchStatusForPDCDeltas",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "SubStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuProcessStatusInsert",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuCheckFinalResults",
                "schema_name": "etl",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuDeleteOrphanedProviders",
                "schema_name": "etl",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMidNonProviderEntityRefresh",
                "schema_name": "ETL",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuPopulateProviderToAuditIDFromProfisee",
                "schema_name": "etl",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "BJCAndOthersDesignateFacilities",
                "schema_name": "hack",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuCarePhilosophyFix",
                "schema_name": "Hack",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuCleanUpDuplicateIncorrectFacilityToFacilityType",
                "schema_name": "Hack",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuDeleteNullFacilityCodes",
                "schema_name": "Hack",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMAPFreeze",
                "schema_name": "hack",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuRemoveBadURLS",
                "schema_name": "Hack",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuRemoveSuspecProviders",
                "schema_name": "HACK",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRPractice",
                "schema_name": "HACK",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuTheBeginHack",
                "schema_name": "hack",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuTheGreatMidShowODS1StageEDPHackSet",
                "schema_name": "Hack",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "URLTableMatchToFacilityURL",
                "schema_name": "Hack",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderPracticeOffice",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuInsertRequestedMarketLocationsMissingFromODS2",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuOfficeSpecialtyRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuPartnerEntityRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuPracticeRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuPracticeSponsorshipRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderAffiliationRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderConditionRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderEducationRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderFacilityRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderHealthInsuranceRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderLanguageRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderLicenseRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderMalpracticeRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderMetricSummaryRefreshHack",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderPracticeOfficeRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderProcedureRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderRecognitionRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderSanctionRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderSpecialtyFacilityServiceLineRatingRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderSpecialtyRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderSponsorshipRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSuppressSurveyFlag",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "solrpractice",
                "schema_name": "show",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderAddress",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderDelta_PoweredByHealthgrades",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuApplyProviderStatusBusinessRules",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuMidProviderHACKCall",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRPRacticeDeltaRefresh",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRPracticeGenerateFromMid",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRProviderAddressGenerateFromMid",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRProviderDeltaRefresh",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRProviderGenerateFromMid",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRProviderGenerateFromMid_XMLLoad",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRProviderRedirect",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRTreatmentEntryLevel",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuUpdateSOLRProviderClientCertificationXml",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuGetErrorInfo",
                "schema_name": "util",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderDelta",
                "schema_name": "xfr",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuBackfillProviderToFacilityHack",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RelationshipType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuCalculateIsSearchableGeneralSuppression",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "CertificationSpecialty",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "IsSearchableSuppressGeneralSuppressionRule",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "providertocertificationspecialty",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuPrintNVarcharMax",
                "schema_name": "util",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuCalculateProviderDisplaySpecialty",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "DisplaySpecialtyRule",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "DisplaySpecialtyRuleToCertificationSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "DisplaySpecialtyRuleToClinicalFocus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "DisplaySpecialtyRuleToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToCertificationSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToClinicalFocus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToDisplaySpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuPrintNVarcharMax",
                "schema_name": "util",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuCallCenterIntCodeHack",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "CallCenter",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuDefaultPDCCallCenterRelationship",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "callcenter",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "client",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToCallCenter",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "clienttoproduct",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "product",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderSponsorshipAndOASCleanup",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "sp_send_dbmail",
                "schema_name": "",
                "database_name": "msdb",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientEntityOpt",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OptInClientProductToEntity",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PartnerToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProductGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "provider",
                "schema_name": "base",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSanction",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSanctionsMalPractice",
                "schema_name": "EMailAlerts",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PartnerEntity",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSponsorship",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientEntityOpt",
                "schema_name": "xfr",
                "database_name": "Transit",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "PartnerToEntity",
                "schema_name": "xfr",
                "database_name": "Transit",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "xfr",
                "database_name": "Transit",
                "type": null,
                "type_desc": null,
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSetBatchStatusForPDCDeltas",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuCheckFinalResults",
        "schema_name": "etl",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ClientToProductProvider",
                "schema_name": "Checks",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PracticeCounts",
                "schema_name": "Checks",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProductProviderCounts",
                "schema_name": "Checks",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProductProviderCountsOAS",
                "schema_name": "Checks",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProductProviderCountsSurvey",
                "schema_name": "Checks",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "sp_send_dbmail",
                "schema_name": "dbo",
                "database_name": "msdb",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "sp_start_job",
                "schema_name": "dbo",
                "database_name": "msdb",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "query",
                "schema_name": "Loc",
                "database_name": "ot",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "query",
                "schema_name": "Loc",
                "database_name": "T3",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderSponsorship",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "DelayClient",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRPractice",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRPracticeGenerateFromMid",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "vwuProviderIndex",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "CustomersToIgnoreForTesting",
                "schema_name": "util",
                "database_name": "ProfiseeAux",
                "type": null,
                "type_desc": null,
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuDeleteOrphanedProviders",
        "schema_name": "etl",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "provider",
                "schema_name": "base",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "tmstProvider",
                "schema_name": "data",
                "database_name": "ProfiseeKube",
                "type": null,
                "type_desc": null,
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMidNonProviderEntityRefresh",
        "schema_name": "ETL",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuProcessStatusInsert",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuMidFacilityEntityRefresh",
                "schema_name": "etl",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRPractice",
                "schema_name": "HACK",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "GeographicArea",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "LineOfService",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuGeographicAreaRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuLineOfServiceRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderIsInClientMarketRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRPRacticeDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRAutosuggestRefData",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRGeographicAreaDeltaRefresh",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRGeographicAreaGenerateFromMid",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRLineOfServiceDeltaRefresh",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRLineOfServiceGenerateFromMid",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRPRacticeDeltaRefresh",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRPracticeGenerateFromMid",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRPRacticeDelta",
                "schema_name": "xfr",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuPopulateProviderToAuditIDFromProfisee",
        "schema_name": "etl",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAuditID",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "tmstProvider",
                "schema_name": "data",
                "database_name": "ProfiseeKube",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "tmstProviderToAuditID",
                "schema_name": "data",
                "database_name": "ProfiseeKube",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SurvivorshipLastRun",
                "schema_name": "util",
                "database_name": "ProfiseeAux",
                "type": null,
                "type_desc": null,
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "BJCAndOthersDesignateFacilities",
        "schema_name": "hack",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "facility",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "provider",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuCarePhilosophyFix",
        "schema_name": "Hack",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "AboutMe",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAboutMe",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuDeleteNullFacilityCodes",
        "schema_name": "Hack",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProviderSponsorship",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMAPFreeze",
        "schema_name": "hack",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderPriorityLoad",
                "schema_name": "etl",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider_Freeze",
                "schema_name": "SHow",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "WebFreeze",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuRemoveBadURLS",
        "schema_name": "Hack",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ClientMarket",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSponsorship",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuRemoveSuspecProviders",
        "schema_name": "HACK",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProviderRemoval",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderAddress",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRPractice",
        "schema_name": "HACK",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PracticeSponsorship",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientContract",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRPractice",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRPracticeDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuTheGreatMidShowODS1StageEDPHackSet",
        "schema_name": "Hack",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProviderSponsorship",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "URLTableMatchToFacilityURL",
        "schema_name": "Hack",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ClientProductEntityToURL",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "URL",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "URLType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRFacility",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuInsertRequestedMarketLocationsMissingFromODS2",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "GeographicArea",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Market",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MarketMaster",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Source",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RequestedMarketLocationsMissingFromODS2",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuOfficeSpecialtyRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeSpecialty",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuPartnerEntityRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "sp_send_dbmail",
                "schema_name": "",
                "database_name": "msdb",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderOfficeOASMissing",
                "schema_name": "Alerts",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToPartner",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Partner",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Partner",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PartnerToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PartnerType",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "providertooffice",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PartnerEntity",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuPracticeRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "AddressType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Nation",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProductGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderType",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderType",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RelationshipType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuPracticeSponsorshipRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProductGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "WriteMDLite",
                "schema_name": "hack",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "PracticeSponsorship",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSponsorship",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderAffiliationRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Affiliation",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderRole",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAffiliation",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderAffiliation",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderConditionRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermSet",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderCondition",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderEducationRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Degree",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EducationInstitution",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EducationInstitutionType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Nation",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToEducationInstitution",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderEducation",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderFacilityRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Award",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "AwardCategory",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientEntityToClientFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureToClientFeatureValue",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureValue",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaImageType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaSize",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProductGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderRole",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "TempSpecialtyToServiceLineGhetto",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuPDCClientDetail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "vwuPDCFacilityDetail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "vwuProviderSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityAddressDetail",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityParentChild",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToAward",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToProcedureRating",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToServiceLineRating",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Procedure",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcedureToServiceLine",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ServiceLine",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "vwuFacilityHGDisplayProcedures",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderFacility",
                "schema_name": "mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderFacility",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderFacility_MJR",
                "schema_name": "mid",
                "database_name": "ods1STAGE",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSponsorship",
                "schema_name": "mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderHealthInsuranceRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "HealthInsurancePayor",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "HealthInsurancePlan",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "HealthInsurancePlanToPlanType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "HealthInsurancePlanType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToHealthInsurance",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderHealthInsurance",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderLanguageRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Language",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToLanguage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLanguage",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderLicenseRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLicense",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLicense",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderMalpracticeRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "MalpracticeClaimType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MalpracticeState",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderMetricSummaryRefreshHack",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMetricSummary",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMetricSummary",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderPracticeOfficeRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Nation",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PracticeEmail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveSpecialHexadecimalCharacters",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderPracticeOffice",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderProcedureRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermSet",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProcedure",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderRecognitionRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Award",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuProviderRecognition",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderRecognition",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Degree",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderRedirect",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSubType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToDegree",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToDisplaySpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderSubType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderURL",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderSanctionRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSanction",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SanctionAction",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SanctionActionType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SanctionCategory",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SanctionType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "StateReportingAgency",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSanction",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderSpecialtyFacilityServiceLineRatingRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroupToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "TempSpecialtyToServiceLineGhetto",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityTOProcedureRating",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToServiceLineRating",
                "schema_name": "Facility",
                "database_name": "ERMart1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcedureToServiceLine",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ServiceLine",
                "schema_name": "Facility",
                "database_name": "ERMart1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderSpecialtyFacilityServiceLineRating",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderSpecialtyRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "CertificationBoardToCertificationCategory",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationCategory",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTermToCertificationBoard",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermSet",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderTypeToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuSpecialtyToServiceLine",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationBoard",
                "schema_name": "Legacy",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationStatus",
                "schema_name": "Legacy",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSpecialty",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderSponsorshipRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "BASE",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Award",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientEntityToClientFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureToClientFeatureValue",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureValue",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityRelationship",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "clientproductentitytophone",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityToAddress",
                "schema_name": "BASE",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityToFacilityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Message",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MessagePage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MessageToMessageToEntityToPageToYear",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MessageType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProductGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProvidersWithSponsorshipIssues",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOfficeToCustomerToProductToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "RelationshipType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroupToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuPDCClientDetail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "vwuPDCEmployedProviderPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "vwuPDCFacilityDetail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "vwuPDCPracticeOfficeDetail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "vwuSpecialtyToServiceLine",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "MultipleSponsorshipTracking",
                "schema_name": "client",
                "database_name": "OperationalMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "master_directory",
                "schema_name": "dbo",
                "database_name": "hosp_directory",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "QualityMessageForODS",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "HospitalDetail",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "WriteMDLite",
                "schema_name": "hack",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSponsorship",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuRecordPostRulesEngineDataIssues",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSuppressSurveyFlag",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSurveySuppression",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSubStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroupToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SubStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSponsorship",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuApplyProviderStatusBusinessRules",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRPRacticeDeltaRefresh",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRPractice",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRPracticeDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRPRacticeDelta",
                "schema_name": "xfr",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRPracticeGenerateFromMid",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "DaysOfWeek",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeHours",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PracticeEmail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuPDCPracticeOfficeDetail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeSpecialty",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PracticeSponsorship",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRPractice",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRPractice",
                "schema_name": "show",
                "database_name": "ods1stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuPracticeIndex",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "vwuProviderIndex",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRProviderAddressGenerateFromMid",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "GetPipeSeparatedCityStateAlternative",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderPracticeOffice",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderAddress",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRProviderDeltaRefresh",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProvidersWithSponsorshipIssues",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderURL",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderAddress",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderDelta_PoweredByHealthgrades",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderRedirect",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRProviderGenerateFromMid",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "AboutMe",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "DisplayStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MalpracticeState",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaContextType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaImageHost",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaSize",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderAppointmentAvailabilityStatement",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderEmail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLegacyKeys",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSubType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSurveySuppression",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAboutMe",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderSubType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSubStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SubStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "GetPipeSeparatedCityState",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "GetPipeSeparatedPDCFacility",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSurveyAggregate",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuMAPFreeze",
                "schema_name": "hack",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderEducation",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderPracticeOffice",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProcedure",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSponsorship",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSurveyResponse",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSourceUpdate",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuRebuildIndexes",
                "schema_name": "util",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderDelta",
                "schema_name": "xfr",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRProviderGenerateFromMid_XMLLoad",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "AboutMe",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "AppointmentAvailability",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Award",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "AwardCategory",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "AwardToCondition",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "AwardToProcedure",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "AwardToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationAgency",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationBoard",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientEntityToClientFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureToClientFeatureValue",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureValue",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityToDisplayPartnerPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClinicalFocus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClinicalFocusDCP",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClinicalFocusProviderData",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClinicalFocusToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CohortToCondition",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CohortToProcedure",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CohortToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "DaysOfWeek",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Degree",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "HealthInsurancePayor",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "HealthInsurancePayorOrganization",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "HealthInsurancePlan",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "HealthInsurancePlanToPlanType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "HealthInsurancePlanType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "IdentificationType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ImagePath",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Language",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MalpracticeState",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaContextType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaImageType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaReviewLevel",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaSize",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaVideoHost",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MOCLevel",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MOCPathway",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "NoIndexNoFollow",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "NTileType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OASPartner",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeHours",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Organization",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OrganizationToImagePath",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Position",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PrescriptionNTile",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProductGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderEmail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderIdentification",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLastUpdateDate",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMedia",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSanction",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSpecialtyZScore",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAboutMe",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToAppointmentAvailability",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToCertificationSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToClientProductToDisplayPartner",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToClientToOASPartner",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToClinicalFocus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToConditionAdTargeting",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToDegree",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToMAPCustomerProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOrganization",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToPrescriptionNTile",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProcedureMedicalAdTargeting",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSubStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToTelehealthMethod",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderTraining",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderTypeToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderTypeToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderVideo",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroupToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyToCondition",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyToProcedureMedical",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuProviderSpecialtyZScore",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SubStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SyndicationPartner",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "TelehealthMethod",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "TelehealthMethodType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Training",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuCallCenterDetails",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "vwuSpecialtyToServiceLine",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "trefSpecialty",
                "schema_name": "data",
                "database_name": "ProfiseeKube",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "DCPHierarchy",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuRemoveSpecialHexadecimalCharacters",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "OASAppointmentType",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OASDistribution",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PartnerToOASDistribution",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PartnerToOASDistributionToOASAppointmentMessage",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PBHClient",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PBHClientCampaign",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PBHProvider",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "pbhprovidercampaign",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderSurveyAggregate",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuProcessStatusInsert",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuStatusLogInsert",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "temp_OfficeCodeDuplicate",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "value",
                "schema_name": "Destination",
                "database_name": "ODS1Stage",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "ETL",
                "database_name": "SnowFlake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityToAward",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToProcedureRating",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToSurvey",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Procedure",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcedureToServiceLine",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ServiceLine",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "vwuFacilityHGDisplayProcedures",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "value",
                "schema_name": "FootD",
                "database_name": "ODS1Stage",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "value",
                "schema_name": "FootM",
                "database_name": "ODS1Stage",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "value",
                "schema_name": "FootS",
                "database_name": "ODS1Stage",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "value",
                "schema_name": "FootT",
                "database_name": "ODS1Stage",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PartnerEntity",
                "schema_name": "mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderCondition",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderEducation",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderFacility",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderHealthInsurance",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLanguage",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderLicense",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderPracticeOffice",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProcedure",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderRecognition",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSanction",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSpecialtyFacilityServiceLineRating",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSponsorship",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SurveyQuestionRangeMapping",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientContract",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRFacility",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderSurveyQuestionAndAnswer",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuPracticingSpecialtyToGroupSpecialtyPrimary",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "ProviderConditionXMLLoads",
                "schema_name": "temp",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderProcedureXMLLoads",
                "schema_name": "temp",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "fnuGenerateMediaContextXML",
                "schema_name": "util",
                "database_name": "ODS1Stage",
                "type": "FN",
                "type_desc": "SQL_SCALAR_FUNCTION",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaSurvey",
                "schema_name": "xfr",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderXMLData",
                "schema_name": "xml",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRProviderRedirect",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProviderRedirect",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderRedirect",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderRedirect",
                "schema_name": "SHow",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRTreatmentEntryLevel",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyToCondition",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyToProcedureMedical",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "TreatmentLevel",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRTreatmentEntryLevel",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuUpdateSOLRProviderClientCertificationXml",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "value",
                "schema_name": "certs",
                "database_name": "client",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProviderCertification",
                "schema_name": "scdghcorp",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderDelta_PoweredByHealthgrades",
                "schema_name": "show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuGetErrorInfo",
        "schema_name": "util",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuPrintNVarcharMax",
        "schema_name": "util",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "RuleExecutionPrintLog",
                "schema_name": "re",
                "database_name": "ODS1Stage",
                "type": null,
                "type_desc": null,
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "vwuProviderIndex",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "V ",
        "type_desc": "VIEW",
        "list_of_references": [
            {
                "entity_name": "NoIndexNoFollow",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "NoIndexNoFollowSC",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "value",
                "schema_name": "loc",
                "database_name": "T2",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ConsolidatedProviders",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "DelayClient",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "tmpSOLRProvider",
                "schema_name": "soquin",
                "database_name": "ODS1Stage",
                "type": null,
                "type_desc": null,
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuMidFacilityEntityRefresh",
        "schema_name": "etl",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProcessStatus",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "spuProcessStatusInsert",
                "schema_name": "dbo",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuFacilityRefresh",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRFacility",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRFacilityDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "spuSOLRFacilityGenerateFromMid",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "P ",
                "type_desc": "SQL_STORED_PROCEDURE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuGeographicAreaRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "GeographicArea",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "GeographicAreaType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "GeographicArea",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuLineOfServiceRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "LineOfService",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "LineOfServiceType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "LineOfService",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderIsInClientMarketRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "GeographicArea",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToOffice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroupToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "etl",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientMarket",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "DeltaProcessingStatusType",
                "schema_name": "ref",
                "database_name": "Snowflake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProvider",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRAutosuggestRefData",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "AboutMe",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "AppointmentAvailability",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationAgency",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationAgencyToBoardToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationBoard",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationStatus",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "DisplayStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EducationInstitutionType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Gender",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "HealthInsurancePayor",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "HealthInsurancePlan",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "HealthInsurancePlan",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "HealthInsurancePlanToPlanType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "HealthInsurancePlanType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "HGProcedureGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "IdentificationType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Language",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "LicenseType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "LocationType",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Nation",
                "schema_name": "Base",
                "database_name": "ODS1STAGE",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Position",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProductGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SubStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Suffix",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SurveySuppressionReason2",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PopularSearchTerm",
                "schema_name": "dbo",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRAutosuggestRefData",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRGeographicAreaDeltaRefresh",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "GeographicArea",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRGeographicAreaDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRGeographicAreaGenerateFromMid",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "GeographicArea",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRGeographicArea",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRGeographicAreaDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRLineOfServiceDeltaRefresh",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "LineOfService",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRLineOfServiceDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRLineOfServiceGenerateFromMid",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "LineOfService",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRLineOfService",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRLineOfServiceDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "vwuPDCClientDetail",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "V ",
        "type_desc": "VIEW",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityToURL",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaImageType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "URL",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "URLType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuClientProductEntityToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "vwuPDCFacilityDetail",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "V ",
        "type_desc": "VIEW",
        "list_of_references": [
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityToURL",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaImageType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "URL",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "URLType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuClientProductEntityToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "vwuProviderSpecialty",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "V ",
        "type_desc": "VIEW",
        "list_of_references": [
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermSet",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderTypeToMedicalTerm",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuProviderToSpecialty",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "vwuProviderRecognition",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "V ",
        "type_desc": "VIEW",
        "list_of_references": [
            {
                "entity_name": "Award",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Award",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationBoardToCertificationCategory",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationStatus",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityToMedicalTermToCertificationBoard",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderMalpractice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSanction",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSanction",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToCertificationSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SanctionAction",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SanctionAction",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CertificationStatus",
                "schema_name": "Legacy",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "vwuSpecialtyToServiceLine",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "V ",
        "type_desc": "VIEW",
        "list_of_references": [
            {
                "entity_name": "TempSpecialtyToServiceLineGhetto",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "vwuPDCEmployedProviderPhone",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "V ",
        "type_desc": "VIEW",
        "list_of_references": [
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuClientProductEntityToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "vwuPDCPracticeOfficeDetail",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "V ",
        "type_desc": "VIEW",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductEntityToImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Image",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ImageType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Office",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "OfficeToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Practice",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuClientProductEntityToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuRecordPostRulesEngineDataIssues",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "ProvidersWithSponsorshipIssues",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSponsorship",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "vwuPracticeIndex",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "V ",
        "type_desc": "VIEW",
        "list_of_references": [
            {
                "entity_name": "SOLRPractice",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuProviderSpecialtyZScore",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "CohortToCondition",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CohortToProcedure",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderSpecialtyZScore",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacilityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyToCondition",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyToProcedureMedical",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "TreatmentLevel",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderDeltaProcessing",
                "schema_name": "ETL",
                "database_name": "SnowFlake",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Procedure",
                "schema_name": "Facility",
                "database_name": "ERMart1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "SOLRFacility",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRProviderDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "value",
                "schema_name": "XmlCol",
                "database_name": "x",
                "type": null,
                "type_desc": null,
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "vwuCallCenterDetails",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "V ",
        "type_desc": "VIEW",
        "list_of_references": [
            {
                "entity_name": "CallCenter",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CallCenterToEmail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CallCenterToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CallCenterType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToCallCenter",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Email",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EmailType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "vwuPracticingSpecialtyToGroupSpecialtyPrimary",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "V ",
        "type_desc": "VIEW",
        "list_of_references": [
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroupToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRSpecialty",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuFacilityRefresh",
        "schema_name": "Mid",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "BASE",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientEntityToClientFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureToClientFeatureValue",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureValue",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityCheckInURL",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityImage",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityToAddress",
                "schema_name": "BASE",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityToFacilityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaImageType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MediaSize",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProductGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToFacility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "State",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuPDCClientDetail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "vwuPDCFacilityDetail",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "Award",
                "schema_name": "Facility",
                "database_name": "ERMart1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityAddressDetail",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToAward",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToProcedureRating",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToRating",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToTraumaLevel",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacSearchType",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "HospitalDetail",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Rating",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "vwuFacilityHGDisplayProcedures",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "HCATrackingPhoneHack",
                "schema_name": "HACK",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "facility_MJR",
                "schema_name": "mid",
                "database_name": "ods1STAGE",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientContract",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "spuSOLRFacilityGenerateFromMid",
        "schema_name": "Show",
        "database_name": "ODS1Stage",
        "type": "P ",
        "type_desc": "SQL_STORED_PROCEDURE",
        "list_of_references": [
            {
                "entity_name": "Address",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Award",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "AwardCategory",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "CityStatePostalCode",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Client",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientEntityToClientFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeature",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureToClientFeatureValue",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientFeatureValue",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientProductToEntity",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ClientToProduct",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "DaysOfWeek",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Base",
                "database_name": "ODS1STAGE",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "facilityHours",
                "schema_name": "base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "FacilityToAddress",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Product",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProductGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "STATE",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "vwuCallCenterDetails",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "V ",
                "type_desc": "VIEW",
                "keyword": ""
            },
            {
                "entity_name": "AwardToMedicalTerm",
                "schema_name": "Facility",
                "database_name": "ERMart1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityAddressDetail",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityAwardMessage",
                "schema_name": "Facility",
                "database_name": "ERMart1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityParentChild",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToAward",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToCertification",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToExecLevelTeam",
                "schema_name": "Facility",
                "database_name": "ERMart1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToMaternityDetail",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToOrganTransplantRatings",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToProcedureRating",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToProcessMeasures",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToRating",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToServiceLineRating",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "FacilityToSurvey",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Procedure",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcedureRatingsNationalAverage",
                "schema_name": "Facility",
                "database_name": "ERMart1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcedureToAward",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcedureToServiceLine",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ProcessMeasureScore",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Rating",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "ServiceLine",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "StateNationalProcedureRatingsAverage",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "StateNationalSurveyScore",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "vwuFacilityHGDisplayProcedures",
                "schema_name": "Facility",
                "database_name": "ERMART1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "Facility",
                "schema_name": "Mid",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProcessMeasure",
                "schema_name": "ref",
                "database_name": "ERMart1",
                "type": null,
                "type_desc": null,
                "keyword": ""
            },
            {
                "entity_name": "SOLRFacility",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "solrfacility",
                "schema_name": "show",
                "database_name": "ods1STAGE",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "solrfacility_MJR",
                "schema_name": "show",
                "database_name": "ods1STAGE",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SOLRFacilityDelta",
                "schema_name": "Show",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "vwuClientProductEntityToPhone",
        "schema_name": "Base",
        "database_name": "ODS1Stage",
        "type": "V ",
        "type_desc": "VIEW",
        "list_of_references": [
            {
                "entity_name": "ClientProductEntityToPhone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Phone",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "PhoneType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            }
        ]
    },
    {
        "entity_name": "vwuProviderToSpecialty",
        "schema_name": "base",
        "database_name": "ODS1Stage",
        "type": "V ",
        "type_desc": "VIEW",
        "list_of_references": [
            {
                "entity_name": "EntityToMedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "EntityType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTerm",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "MedicalTermType",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Provider",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "Specialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroup",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroupToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroupToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroupToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroupToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroupToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "SpecialtyGroupToSpecialty",
                "schema_name": "Base",
                "database_name": "ODS1Stage",
                "type": "U ",
                "type_desc": "USER_TABLE",
                "keyword": ""
            },
            {
                "entity_name": "ProviderCampaignTracking",
                "schema_name": "log",
                "database_name": "DBMetrics",
                "type": null,
                "type_desc": null,
                "keyword": ""
            }
        ]
    }
];