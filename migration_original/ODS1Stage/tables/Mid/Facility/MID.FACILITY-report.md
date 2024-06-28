# MID.FACILITY Report

## 1. Sample Validation

Percentage of Identical Columns: 84.52% (71/84).
Percentage of Different Columns: 15.48% (13/84).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name              | Match ID   | SQL Server Value                                                                                     | Snowflake Value                                                                                        |
|---:|:-------------------------|:-----------|:-----------------------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------|
|  0 | FACILITYID               | UC4511     | 35344355-3131-0000-0000-000000000000                                                                 | d9571b38-beb3-4a57-bf97-d67988a10e78                                                                   |
|  1 | FACILITYNAME             | PBM3TW     | CVS Pharmacy #10736                                                                                  | CVS PHARMACY 10736                                                                                     |
|  2 | ISMEDICAIDACCEPTED       | PDF45T     | Y                                                                                                    | N                                                                                                      |
|  3 | ISMEDICAREACCEPTED       | PDF45T     | Y                                                                                                    | N                                                                                                      |
|  4 | OWNERSHIPTYPE            | UC4511     | None                                                                                                 | N/A                                                                                                    |
|  5 | CLIENTTOPRODUCTID        | UC3254     | 58464f31-4c44-4f47-0000-000000000000                                                                 | 4c34e16d-5799-451a-9b7c-b3c4fdc1c397                                                                   |
|  6 | FOREIGNOBJECTLEFTPERCENT | UC4511     | 12.8                                                                                                 | None                                                                                                   |
|  7 | PHONEXML                 | UC3254     | <phone><ph>(972) 674-8922</ph><phTyp>PTHFS</phTyp></phone>                                           | None                                                                                                   |
|  8 | URLXML                   | UC4511     | <url><urlVal>/urgent-care-directory/aurora-urgent-care-uc4511</urlVal><urlTyp>FCCLURL</urlTyp></url> | "<url><urlval>/urgent-care-directory/aurora-urgent-care-uc4511</urlval><urltyp>FCCLURL</urltyp></url>" |
|  9 | IMAGEXML                 | UC3254     | <image><img>/img/client/logo/HCAUC_PDC_w180h65.png</img><imgTyp>FCCLLOGO</imgTyp></image>            | None                                                                                                   |
| 10 | FACILITYIMAGEPATH        | UC3254     | /img/facility/image/UC3254_PDC_w700h400.png                                                          | None                                                                                                   |
| 11 | TABLETPHONEXML           | UC3254     | <phone><ph>(972) 674-8922</ph><phTyp>PTHFST</phTyp></phone>                                          | "<phone><ph>(972) 674-8922</ph><phTyp>PTHFST</phTyp></phone>"                                          |
| 12 | DESKTOPPHONEXML          | UC3254     | <phone><ph>(972) 674-8922</ph><phTyp>PTHFSDTP</phTyp></phone>                                        | "<phone><ph>(972) 674-8922</ph><phTyp>PTHFSDTP</phTyp></phone>"                                        |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 84
- Snowflake: 84
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 79258
- Snowflake: 68821
- Rows Margin (%): 13.168386787453631

### 2.3 Nulls per Column
|    | Column_Name                          |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------------------------|------------------------:|------------------------:|-------------:|
|  0 | FacilityID                           |                       0 |                       0 |          0   |
|  1 | LegacyKey                            |                       0 |                       0 |          0   |
|  2 | FacilityCode                         |                       0 |                       0 |          0   |
|  3 | FacilityName                         |                       0 |                       0 |          0   |
|  4 | FacilityType                         |                       0 |                       0 |          0   |
|  5 | FacilityTypeCode                     |                       0 |                       0 |          0   |
|  6 | FacilitySearchType                   |                       0 |                       0 |          0   |
|  7 | Accreditation                        |                   75953 |                   64343 |         15.3 |
|  8 | AccreditationDescription             |                   75953 |                   64343 |         15.3 |
|  9 | PhoneNumber                          |                       0 |                      63 |        inf   |
| 10 | AdditionalTransportationInformation  |                   79258 |                   68821 |         13.2 |
| 11 | AfterHoursPhoneNumber                |                   79258 |                   68821 |         13.2 |
| 12 | AwardsInformation                    |                   79258 |                   68772 |         13.2 |
| 13 | ClosedHolidaysInformation            |                   79258 |                   68821 |         13.2 |
| 14 | CommunityActivitiesInformation       |                   79258 |                   68732 |         13.3 |
| 15 | CommunityOutreachProgramInformation  |                   79258 |                   68809 |         13.2 |
| 16 | CommunitySupportInformation          |                   79258 |                   68801 |         13.2 |
| 17 | FacilityDescription                  |                   79258 |                   68620 |         13.4 |
| 18 | EmergencyAfterHoursPhoneNumber       |                   79258 |                   68816 |         13.2 |
| 19 | FoundationInformation                |                   79258 |                   68802 |         13.2 |
| 20 | HealthPlanInformation                |                   79258 |                   68796 |         13.2 |
| 21 | IsMedicaidAccepted                   |                       0 |                       0 |          0   |
| 22 | IsMedicareAccepted                   |                       0 |                       0 |          0   |
| 23 | IsTeaching                           |                   79258 |                   65396 |         17.5 |
| 24 | LanguageInformation                  |                   79258 |                   68810 |         13.2 |
| 25 | MedicalServicesInformation           |                   79258 |                   68663 |         13.4 |
| 26 | MissionStatement                     |                   79258 |                   68633 |         13.4 |
| 27 | OfficeCloseTime                      |                   79258 |                   68813 |         13.2 |
| 28 | OfficeOpenTime                       |                   79258 |                   68813 |         13.2 |
| 29 | OnsiteGuestServicesInformation       |                   79258 |                   68807 |         13.2 |
| 30 | OtherEducationAndTrainingInformation |                   79258 |                   68815 |         13.2 |
| 31 | OtherServicesInformation             |                   79258 |                   68821 |         13.2 |
| 32 | OwnershipType                        |                   79257 |                       0 |        100   |
| 33 | ParkingInstructionsInformation       |                   79258 |                   68719 |         13.3 |
| 34 | PaymentPolicyInformation             |                   79258 |                   68821 |         13.2 |
| 35 | ProfessionalAffiliationInformation   |                   79258 |                   68811 |         13.2 |
| 36 | PublicTransportationInformation      |                   79258 |                   68821 |         13.2 |
| 37 | RegionalRelationshipInformation      |                   79258 |                   68817 |         13.2 |
| 38 | ReligiousAffiliationInformation      |                   79258 |                   68813 |         13.2 |
| 39 | SpecialProgramsInformation           |                   79258 |                   68731 |         13.3 |
| 40 | SurroundingAreaInformation           |                   79258 |                   68726 |         13.3 |
| 41 | TeachingProgramsInformation          |                   79258 |                   68792 |         13.2 |
| 42 | TollFreePhoneNumber                  |                   79258 |                   68821 |         13.2 |
| 43 | TransplantCapabilitiesInformation    |                   79258 |                   68819 |         13.2 |
| 44 | VisitingHoursInformation             |                   79258 |                   68752 |         13.3 |
| 45 | VolunteerInformation                 |                   79258 |                   68687 |         13.3 |
| 46 | YearEstablished                      |                   79258 |                   68720 |         13.3 |
| 47 | HospitalAffiliationInformation       |                   79258 |                   68816 |         13.2 |
| 48 | PhysicianCallCenterPhoneNumber       |                   79258 |                   68818 |         13.2 |
| 49 | OverallHospitalStar                  |                   79258 |                   68821 |         13.2 |
| 50 | AdultTraumaLevel                     |                   79258 |                   67449 |         14.9 |
| 51 | PediatricTraumaLevel                 |                   79258 |                   68724 |         13.3 |
| 52 | TreatmentSchedules                   |                   79258 |                   66939 |         15.5 |
| 53 | ClientToProductID                    |                   78149 |                   67940 |         13.1 |
| 54 | ClientCode                           |                   78149 |                   67940 |         13.1 |
| 55 | ClientName                           |                   78149 |                   67940 |         13.1 |
| 56 | ProductCode                          |                   78149 |                   67940 |         13.1 |
| 57 | ProductGroupCode                     |                   78149 |                   67940 |         13.1 |
| 58 | ResPgmApprAma                        |                   79258 |                   68821 |         13.2 |
| 59 | ResPgmApprAoa                        |                   79258 |                   68821 |         13.2 |
| 60 | ResPgmApprAda                        |                   79258 |                   68821 |         13.2 |
| 61 | AwardCount                           |                   77601 |                   67216 |         13.4 |
| 62 | ProcedureCount                       |                   74664 |                   68821 |          7.8 |
| 63 | MiscellaneousInformation             |                   79258 |                   68798 |         13.2 |
| 64 | AppointmentInformation               |                   79258 |                   68821 |         13.2 |
| 65 | FiveStarProcedureCount               |                   76598 |                   68821 |         10.2 |
| 66 | ProviderCount                        |                   74083 |                   64723 |         12.6 |
| 67 | FacilityURL                          |                       0 |                     121 |        inf   |
| 68 | VisitingHoursMonday                  |                   79258 |                   68774 |         13.2 |
| 69 | VisitingHoursTuesday                 |                   79258 |                   68774 |         13.2 |
| 70 | VisitingHoursWednesday               |                   79258 |                   68775 |         13.2 |
| 71 | VisitingHoursThursday                |                   79258 |                   68774 |         13.2 |
| 72 | VisitingHoursFriday                  |                   79258 |                   68775 |         13.2 |
| 73 | VisitingHoursSaturday                |                   79258 |                   68775 |         13.2 |
| 74 | VisitingHoursSunday                  |                   79258 |                   68775 |         13.2 |
| 75 | ForeignObjectLeftPercent             |                       0 |                   68821 |        inf   |
| 76 | WebSite                              |                   79258 |                   67765 |         14.5 |
| 77 | PhoneXML                             |                   78710 |                   68816 |         12.6 |
| 78 | UrlXML                               |                       0 |                     121 |        inf   |
| 79 | ImageXML                             |                   78181 |                   68384 |         12.5 |
| 80 | FacilityImagePath                    |                   79143 |                   68821 |         13   |
| 81 | MobilePhoneXML                       |                   79258 |                   68821 |         13.2 |
| 82 | TabletPhoneXML                       |                   78765 |                   68475 |         13.1 |
| 83 | DesktopPhoneXML                      |                   78765 |                   68475 |         13.1 |

### 2.4 Distincts per Column
|    | Column_Name                          |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | FacilityID                           |                       79258 |                       68821 |         13.2 |
|  1 | LegacyKey                            |                       78958 |                       68821 |         12.8 |
|  2 | FacilityCode                         |                       79258 |                       68821 |         13.2 |
|  3 | FacilityName                         |                       73795 |                       64928 |         12   |
|  4 | FacilityType                         |                           5 |                           5 |          0   |
|  5 | FacilityTypeCode                     |                           5 |                           5 |          0   |
|  6 | FacilitySearchType                   |                           4 |                           4 |          0   |
|  7 | Accreditation                        |                           3 |                           4 |         33.3 |
|  8 | AccreditationDescription             |                           3 |                           4 |         33.3 |
|  9 | PhoneNumber                          |                       76725 |                       67833 |         11.6 |
| 10 | AdditionalTransportationInformation  |                           0 |                           0 |          0   |
| 11 | AfterHoursPhoneNumber                |                           0 |                           0 |          0   |
| 12 | AwardsInformation                    |                           0 |                          49 |        inf   |
| 13 | ClosedHolidaysInformation            |                           0 |                           0 |          0   |
| 14 | CommunityActivitiesInformation       |                           0 |                          88 |        inf   |
| 15 | CommunityOutreachProgramInformation  |                           0 |                          12 |        inf   |
| 16 | CommunitySupportInformation          |                           0 |                          20 |        inf   |
| 17 | FacilityDescription                  |                           0 |                         198 |        inf   |
| 18 | EmergencyAfterHoursPhoneNumber       |                           0 |                           5 |        inf   |
| 19 | FoundationInformation                |                           0 |                          19 |        inf   |
| 20 | HealthPlanInformation                |                           0 |                          18 |        inf   |
| 21 | IsMedicaidAccepted                   |                           2 |                           2 |          0   |
| 22 | IsMedicareAccepted                   |                           2 |                           2 |          0   |
| 23 | IsTeaching                           |                           0 |                           1 |        inf   |
| 24 | LanguageInformation                  |                           0 |                          10 |        inf   |
| 25 | MedicalServicesInformation           |                           0 |                         158 |        inf   |
| 26 | MissionStatement                     |                           0 |                         161 |        inf   |
| 27 | OfficeCloseTime                      |                           0 |                           7 |        inf   |
| 28 | OfficeOpenTime                       |                           0 |                           6 |        inf   |
| 29 | OnsiteGuestServicesInformation       |                           0 |                          14 |        inf   |
| 30 | OtherEducationAndTrainingInformation |                           0 |                           6 |        inf   |
| 31 | OtherServicesInformation             |                           0 |                           0 |          0   |
| 32 | OwnershipType                        |                           1 |                           5 |        400   |
| 33 | ParkingInstructionsInformation       |                           0 |                          83 |        inf   |
| 34 | PaymentPolicyInformation             |                           0 |                           0 |          0   |
| 35 | ProfessionalAffiliationInformation   |                           0 |                           9 |        inf   |
| 36 | PublicTransportationInformation      |                           0 |                           0 |          0   |
| 37 | RegionalRelationshipInformation      |                           0 |                           4 |        inf   |
| 38 | ReligiousAffiliationInformation      |                           0 |                           7 |        inf   |
| 39 | SpecialProgramsInformation           |                           0 |                          89 |        inf   |
| 40 | SurroundingAreaInformation           |                           0 |                          95 |        inf   |
| 41 | TeachingProgramsInformation          |                           0 |                          28 |        inf   |
| 42 | TollFreePhoneNumber                  |                           0 |                           0 |          0   |
| 43 | TransplantCapabilitiesInformation    |                           0 |                           2 |        inf   |
| 44 | VisitingHoursInformation             |                           0 |                          64 |        inf   |
| 45 | VolunteerInformation                 |                           0 |                         134 |        inf   |
| 46 | YearEstablished                      |                           0 |                          68 |        inf   |
| 47 | HospitalAffiliationInformation       |                           0 |                           5 |        inf   |
| 48 | PhysicianCallCenterPhoneNumber       |                           0 |                           3 |        inf   |
| 49 | OverallHospitalStar                  |                           0 |                           0 |          0   |
| 50 | AdultTraumaLevel                     |                           0 |                           8 |        inf   |
| 51 | PediatricTraumaLevel                 |                           0 |                           5 |        inf   |
| 52 | TreatmentSchedules                   |                           0 |                          12 |        inf   |
| 53 | ClientToProductID                    |                         123 |                         103 |         16.3 |
| 54 | ClientCode                           |                         123 |                         103 |         16.3 |
| 55 | ClientName                           |                         124 |                         103 |         16.9 |
| 56 | ProductCode                          |                           3 |                           3 |          0   |
| 57 | ProductGroupCode                     |                           1 |                           1 |          0   |
| 58 | ResPgmApprAma                        |                           0 |                           0 |          0   |
| 59 | ResPgmApprAoa                        |                           0 |                           0 |          0   |
| 60 | ResPgmApprAda                        |                           0 |                           0 |          0   |
| 61 | AwardCount                           |                          21 |                          21 |          0   |
| 62 | ProcedureCount                       |                          40 |                           0 |        100   |
| 63 | MiscellaneousInformation             |                           0 |                          23 |        inf   |
| 64 | AppointmentInformation               |                           0 |                           0 |          0   |
| 65 | FiveStarProcedureCount               |                          36 |                           0 |        100   |
| 66 | ProviderCount                        |                        1047 |                         150 |         85.7 |
| 67 | FacilityURL                          |                       78961 |                       68700 |         13   |
| 68 | VisitingHoursMonday                  |                           0 |                          24 |        inf   |
| 69 | VisitingHoursTuesday                 |                           0 |                          24 |        inf   |
| 70 | VisitingHoursWednesday               |                           0 |                          24 |        inf   |
| 71 | VisitingHoursThursday                |                           0 |                          24 |        inf   |
| 72 | VisitingHoursFriday                  |                           0 |                          24 |        inf   |
| 73 | VisitingHoursSaturday                |                           0 |                          24 |        inf   |
| 74 | VisitingHoursSunday                  |                           0 |                          23 |        inf   |
| 75 | ForeignObjectLeftPercent             |                           2 |                           0 |        100   |
| 76 | WebSite                              |                           0 |                         918 |        inf   |
| 77 | FacilityImagePath                    |                         115 |                           0 |        100   |