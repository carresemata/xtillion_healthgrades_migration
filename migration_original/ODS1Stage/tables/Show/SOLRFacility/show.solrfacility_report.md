# SHOW.SOLRFACILITY Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/96).
Percentage of Different Columns: 0.00% (0/96).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 96
- Snowflake: 96
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
|  2 | LegacyKey8                           |                       0 |                       0 |          0   |
|  3 | FacilityCode                         |                       0 |                       0 |          0   |
|  4 | FacilityName                         |                       0 |                       0 |          0   |
|  5 | FacilityType                         |                       0 |                       0 |          0   |
|  6 | FacilityTypeCode                     |                       0 |                       0 |          0   |
|  7 | FacilitySearchType                   |                       0 |                       0 |          0   |
|  8 | Accreditation                        |                   75953 |                   64343 |         15.3 |
|  9 | AccreditationDescription             |                   75953 |                   64343 |         15.3 |
| 10 | TreatmentSchedules                   |                   79258 |                   66939 |         15.5 |
| 11 | PhoneNumber                          |                       0 |                      63 |        inf   |
| 12 | AdditionalTransportationInformation  |                   79258 |                   68821 |         13.2 |
| 13 | AfterHoursPhoneNumber                |                   79258 |                   68821 |         13.2 |
| 14 | AwardsInformation                    |                   79258 |                   68772 |         13.2 |
| 15 | ClosedHolidaysInformation            |                   79258 |                   68821 |         13.2 |
| 16 | CommunityActivitiesInformation       |                   79258 |                   68732 |         13.3 |
| 17 | CommunityOutreachProgramInformation  |                   79258 |                   68809 |         13.2 |
| 18 | CommunitySupportInformation          |                   79258 |                   68801 |         13.2 |
| 19 | FacilityDescription                  |                   79258 |                   68620 |         13.4 |
| 20 | EmergencyAfterHoursPhoneNumber       |                   79258 |                   68816 |         13.2 |
| 21 | FoundationInformation                |                   79258 |                   68802 |         13.2 |
| 22 | HealthPlanInformation                |                   79258 |                   68796 |         13.2 |
| 23 | IsMedicaidAccepted                   |                       0 |                       0 |          0   |
| 24 | IsMedicareAccepted                   |                       0 |                       0 |          0   |
| 25 | IsTeaching                           |                   79258 |                   65396 |         17.5 |
| 26 | LanguageInformation                  |                   79258 |                   68810 |         13.2 |
| 27 | MedicalServicesInformation           |                   79258 |                   68663 |         13.4 |
| 28 | MissionStatement                     |                   79258 |                   68633 |         13.4 |
| 29 | OfficeCloseTime                      |                   79258 |                   68813 |         13.2 |
| 30 | OfficeOpenTime                       |                   79258 |                   68813 |         13.2 |
| 31 | OnsiteGuestServicesInformation       |                   79258 |                   68807 |         13.2 |
| 32 | OtherEducationAndTrainingInformation |                   79258 |                   68815 |         13.2 |
| 33 | OtherServicesInformation             |                   79258 |                   68821 |         13.2 |
| 34 | OwnershipType                        |                   79257 |                       0 |        100   |
| 35 | ParkingInstructionsInformation       |                   79258 |                   68719 |         13.3 |
| 36 | PaymentPolicyInformation             |                   79258 |                   68821 |         13.2 |
| 37 | ProfessionalAffiliationInformation   |                   79258 |                   68811 |         13.2 |
| 38 | PublicTransportationInformation      |                   79258 |                   68821 |         13.2 |
| 39 | RegionalRelationshipInformation      |                   79258 |                   68817 |         13.2 |
| 40 | ReligiousAffiliationInformation      |                   79258 |                   68813 |         13.2 |
| 41 | SpecialProgramsInformation           |                   79258 |                   68731 |         13.3 |
| 42 | SurroundingAreaInformation           |                   79258 |                   68726 |         13.3 |
| 43 | TeachingProgramsInformation          |                   79258 |                   68792 |         13.2 |
| 44 | TollFreePhoneNumber                  |                   79258 |                   68821 |         13.2 |
| 45 | TransplantCapabilitiesInformation    |                   79258 |                   68819 |         13.2 |
| 46 | VisitingHoursInformation             |                   79258 |                   68752 |         13.3 |
| 47 | VolunteerInformation                 |                   79258 |                   68687 |         13.3 |
| 48 | YearEstablished                      |                   79258 |                   68720 |         13.3 |
| 49 | HospitalAffiliationInformation       |                   79258 |                   68816 |         13.2 |
| 50 | PhysicianCallCenterPhoneNumber       |                   79258 |                   68818 |         13.2 |
| 51 | OverallHospitalStar                  |                   79258 |                   68821 |         13.2 |
| 52 | ClientCode                           |                   78149 |                   67940 |         13.1 |
| 53 | ProductCode                          |                   78149 |                   67940 |         13.1 |
| 54 | AwardCount                           |                   77601 |                   67216 |         13.4 |
| 55 | ProviderCount                        |                   74081 |                   64723 |         12.6 |
| 56 | ProcedureCount                       |                   74664 |                   64311 |         13.9 |
| 57 | FiveStarProcedureCount               |                   76598 |                   67747 |         11.6 |
| 58 | ResidencyProgApproval                |                   79257 |                       0 |        100   |
| 59 | MiscellaneousInformation             |                   79258 |                   68798 |         13.2 |
| 60 | AppointmentInformation               |                   79258 |                   68821 |         13.2 |
| 61 | VisitingHoursMonday                  |                   79258 |                   68774 |         13.2 |
| 62 | VisitingHoursTuesday                 |                   79258 |                   68774 |         13.2 |
| 63 | VisitingHoursWednesday               |                   79258 |                   68775 |         13.2 |
| 64 | VisitingHoursThursday                |                   79258 |                   68774 |         13.2 |
| 65 | VisitingHoursFriday                  |                   79258 |                   68775 |         13.2 |
| 66 | VisitingHoursSaturday                |                   79258 |                   68775 |         13.2 |
| 67 | VisitingHoursSunday                  |                   79258 |                   68775 |         13.2 |
| 68 | FacilityImagePath                    |                   79143 |                   68821 |         13   |
| 69 | WebSite                              |                   79258 |                   67765 |         14.5 |
| 70 | FacilityURL                          |                       0 |                     121 |        inf   |
| 71 | ForeignObjectLeftPercent             |                       0 |                       0 |          0   |
| 72 | AddressXML                           |                       0 |                    4124 |        inf   |
| 73 | AwardXML                             |                   76978 |                   68616 |         10.9 |
| 74 | ServiceLineXML                       |                   74664 |                   67172 |         10   |
| 75 | PatientSatisfactionXML               |                   75312 |                   64880 |         13.9 |
| 76 | TopTenProcedureXML                   |                   79258 |                   68821 |         13.2 |
| 77 | TransplantRatingsXML                 |                   79258 |                   68821 |         13.2 |
| 78 | SponsorshipXML                       |                   78149 |                   68762 |         12   |
| 79 | TraumaLevelXML                       |                   79258 |                   67413 |         14.9 |
| 80 | DistinctionXML                       |                   77870 |                   67452 |         13.4 |
| 81 | PatientCareXML                       |                   79258 |                   68821 |         13.2 |
| 82 | PatientSafetyXML                     |                   74424 |                   64055 |         13.9 |
| 83 | AffiliationXML                       |                   78545 |                   68176 |         13.2 |
| 84 | LeadershipXML                        |                   79258 |                   68719 |         13.3 |
| 85 | AwardAchievementXML                  |                   79109 |                   68689 |         13.2 |
| 86 | UpdatedDate                          |                       0 |                       0 |          0   |
| 87 | UpdatedSource                        |                       0 |                       0 |          0   |
| 88 | PatientSatisfaction                  |                   75312 |                   64880 |         13.9 |
| 89 | IsPDC                                |                       0 |                       0 |          0   |
| 90 | OverallPatientSafety                 |                   79258 |                   68821 |         13.2 |
| 91 | ReadmissionRateXML                   |                   74692 |                   64263 |         14   |
| 92 | TimelyAndEffectiveCareXML            |                   74692 |                   64263 |         14   |
| 93 | FacilityHoursXML                     |                   24226 |                   68821 |        184.1 |
| 94 | LanguageXML                          |                   69946 |                   59532 |         14.9 |
| 95 | ServiceXML                           |                   22195 |                   16925 |         23.7 |

### 2.4 Distincts per Column
|    | Column_Name                          |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | FacilityID                           |                       79258 |                       68821 |         13.2 |
|  1 | LegacyKey                            |                       78958 |                       68821 |         12.8 |
|  2 | LegacyKey8                           |                       78938 |                       68801 |         12.8 |
|  3 | FacilityCode                         |                       79258 |                       68821 |         13.2 |
|  4 | FacilityName                         |                       76617 |                       67683 |         11.7 |
|  5 | FacilityType                         |                           5 |                           5 |          0   |
|  6 | FacilityTypeCode                     |                           5 |                           5 |          0   |
|  7 | FacilitySearchType                   |                           4 |                           4 |          0   |
|  8 | Accreditation                        |                           3 |                           4 |         33.3 |
|  9 | AccreditationDescription             |                           3 |                           4 |         33.3 |
| 10 | TreatmentSchedules                   |                           0 |                          12 |        inf   |
| 11 | PhoneNumber                          |                       76725 |                       67833 |         11.6 |
| 12 | AdditionalTransportationInformation  |                           0 |                           0 |          0   |
| 13 | AfterHoursPhoneNumber                |                           0 |                           0 |          0   |
| 14 | AwardsInformation                    |                           0 |                          49 |        inf   |
| 15 | ClosedHolidaysInformation            |                           0 |                           0 |          0   |
| 16 | CommunityActivitiesInformation       |                           0 |                          88 |        inf   |
| 17 | CommunityOutreachProgramInformation  |                           0 |                          12 |        inf   |
| 18 | CommunitySupportInformation          |                           0 |                          20 |        inf   |
| 19 | FacilityDescription                  |                           0 |                         198 |        inf   |
| 20 | EmergencyAfterHoursPhoneNumber       |                           0 |                           5 |        inf   |
| 21 | FoundationInformation                |                           0 |                          19 |        inf   |
| 22 | HealthPlanInformation                |                           0 |                          18 |        inf   |
| 23 | IsMedicaidAccepted                   |                           2 |                           2 |          0   |
| 24 | IsMedicareAccepted                   |                           2 |                           2 |          0   |
| 25 | IsTeaching                           |                           0 |                           1 |        inf   |
| 26 | LanguageInformation                  |                           0 |                          10 |        inf   |
| 27 | MedicalServicesInformation           |                           0 |                         158 |        inf   |
| 28 | MissionStatement                     |                           0 |                         161 |        inf   |
| 29 | OfficeCloseTime                      |                           0 |                           7 |        inf   |
| 30 | OfficeOpenTime                       |                           0 |                           6 |        inf   |
| 31 | OnsiteGuestServicesInformation       |                           0 |                          14 |        inf   |
| 32 | OtherEducationAndTrainingInformation |                           0 |                           6 |        inf   |
| 33 | OtherServicesInformation             |                           0 |                           0 |          0   |
| 34 | OwnershipType                        |                           1 |                           5 |        400   |
| 35 | ParkingInstructionsInformation       |                           0 |                          83 |        inf   |
| 36 | PaymentPolicyInformation             |                           0 |                           0 |          0   |
| 37 | ProfessionalAffiliationInformation   |                           0 |                           9 |        inf   |
| 38 | PublicTransportationInformation      |                           0 |                           0 |          0   |
| 39 | RegionalRelationshipInformation      |                           0 |                           4 |        inf   |
| 40 | ReligiousAffiliationInformation      |                           0 |                           7 |        inf   |
| 41 | SpecialProgramsInformation           |                           0 |                          89 |        inf   |
| 42 | SurroundingAreaInformation           |                           0 |                          95 |        inf   |
| 43 | TeachingProgramsInformation          |                           0 |                          28 |        inf   |
| 44 | TollFreePhoneNumber                  |                           0 |                           0 |          0   |
| 45 | TransplantCapabilitiesInformation    |                           0 |                           2 |        inf   |
| 46 | VisitingHoursInformation             |                           0 |                          64 |        inf   |
| 47 | VolunteerInformation                 |                           0 |                         134 |        inf   |
| 48 | YearEstablished                      |                           0 |                          68 |        inf   |
| 49 | HospitalAffiliationInformation       |                           0 |                           5 |        inf   |
| 50 | PhysicianCallCenterPhoneNumber       |                           0 |                           3 |        inf   |
| 51 | OverallHospitalStar                  |                           0 |                           0 |          0   |
| 52 | ClientCode                           |                         123 |                         103 |         16.3 |
| 53 | ProductCode                          |                           3 |                           3 |          0   |
| 54 | AwardCount                           |                          21 |                          21 |          0   |
| 55 | ProviderCount                        |                        1066 |                         150 |         85.9 |
| 56 | ProcedureCount                       |                          40 |                          40 |          0   |
| 57 | FiveStarProcedureCount               |                          36 |                          14 |         61.1 |
| 58 | ResidencyProgApproval                |                           1 |                           1 |          0   |
| 59 | MiscellaneousInformation             |                           0 |                          23 |        inf   |
| 60 | AppointmentInformation               |                           0 |                           0 |          0   |
| 61 | VisitingHoursMonday                  |                           0 |                          24 |        inf   |
| 62 | VisitingHoursTuesday                 |                           0 |                          24 |        inf   |
| 63 | VisitingHoursWednesday               |                           0 |                          24 |        inf   |
| 64 | VisitingHoursThursday                |                           0 |                          24 |        inf   |
| 65 | VisitingHoursFriday                  |                           0 |                          24 |        inf   |
| 66 | VisitingHoursSaturday                |                           0 |                          24 |        inf   |
| 67 | VisitingHoursSunday                  |                           0 |                          23 |        inf   |
| 68 | FacilityImagePath                    |                         115 |                           0 |        100   |
| 69 | WebSite                              |                           0 |                         918 |        inf   |
| 70 | FacilityURL                          |                       78961 |                       68700 |         13   |
| 71 | ForeignObjectLeftPercent             |                           2 |                           1 |         50   |
| 72 | UpdatedDate                          |                           2 |                           1 |         50   |
| 73 | UpdatedSource                        |                           1 |                           1 |          0   |
| 74 | PatientSatisfaction                  |                          70 |                          70 |          0   |
| 75 | IsPDC                                |                           2 |                           2 |          0   |
| 76 | OverallPatientSafety                 |                           0 |                           0 |          0   |