# BASE.PROVIDER Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/54).
Percentage of Different Columns: 31.48% (17/54).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name                 | Match ID   | SQL Server Value                     | Snowflake Value                      |
|---:|:----------------------------|:-----------|:-------------------------------------|:-------------------------------------|
|  0 | PROVIDERID                  | UPNNTC     | 4e4e5055-4354-0000-0000-000000000000 | 62bcdb82-4a0a-4f5f-b2fd-ab22aeba495e |
|  1 | EDWBASERECORDID             | UPNNTC     | 4e4e5055-4354-0000-0000-000000000000 | None                                 |
|  2 | PROVIDERCODE                | UR7PXC     | UR7PXC                               | URDY63                               |
|  3 | FIRSTNAME                   | UPNNTC     | Michael                              | None                                 |
|  4 | MIDDLENAME                  | UPNNTC     | Glenn                                | None                                 |
|  5 | LASTNAME                    | UPNNTC     | Duncan                               | None                                 |
|  6 | GENDER                      | UPNNTC     | M                                    | None                                 |
|  7 | NPI                         | UPNNTC     | 1548979560                           | None                                 |
|  8 | ACCEPTSNEWPATIENTS          | UPNV8G     | True                                 | None                                 |
|  9 | SOURCECODE                  | UPNNTC     | HMS                                  | Profisee                             |
| 10 | SOURCEID                    | UPNNTC     | 00534d48-0000-0000-0000-000000000000 | None                                 |
| 11 | LASTUPDATEDATE              | UPNNTC     | 2023-02-11 01:26:31.363              | 2024-06-03 15:03:21.149              |
| 12 | SEARCHBOOSTACCESSIBILITY    | UPNNTC     | 0.0                                  | None                                 |
| 13 | FAFBOOSTSANCMALP            | UPNNTC     | 0.0                                  | None                                 |
| 14 | FFESATISFACTIONBOOST        | UPNNTC     | 0.5                                  | None                                 |
| 15 | RELTIOENTITYID              | UPNNTC     | UPNNTC                               | None                                 |
| 16 | SURVIVERESIDENTIALADDRESSES | UPNV8G     | False                                | None                                 |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 54
- Snowflake: 54
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 6452850
- Snowflake: 6522348
- Rows Margin (%): 1.0770124828564123

### 2.3 Nulls per Column
|    | Column_Name                              |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |      Margin (%) |
|---:|:-----------------------------------------|------------------------:|------------------------:|----------------:|
|  0 | ProviderID                               |                       0 |                       0 |     0           |
|  1 | EDWBaseRecordID                          |                       0 |                 6522348 |   inf           |
|  2 | ProviderCode                             |                       0 |                       0 |     0           |
|  3 | ProviderTypeID                           |                 6452850 |                 6522348 |     1.1         |
|  4 | FirstName                                |                      55 |                 6522348 |     1.18587e+07 |
|  5 | MiddleName                               |                 1991796 |                 6522348 |   227.5         |
|  6 | LastName                                 |                      54 |                 6522348 |     1.20783e+07 |
|  7 | CarePhilosophy                           |                 6219684 |                 6522348 |     4.9         |
|  8 | ProfessionalInterest                     |                 6452850 |                 6522348 |     1.1         |
|  9 | Suffix                                   |                 6333730 |                 6522348 |     3           |
| 10 | Gender                                   |                   95422 |                 6522348 |  6735.3         |
| 11 | NPI                                      |                   35785 |                 6522348 | 18126.5         |
| 12 | AMAID                                    |                 6452850 |                 6522348 |     1.1         |
| 13 | UPIN                                     |                 5598520 |                 6522348 |    16.5         |
| 14 | ABMSUID                                  |                 5656496 |                 6522348 |    15.3         |
| 15 | MedicareID                               |                 6452850 |                 6522348 |     1.1         |
| 16 | DEANumber                                |                 6452850 |                 6522348 |     1.1         |
| 17 | TaxIDNumber                              |                 6452850 |                 6522348 |     1.1         |
| 18 | DateOfBirth                              |                 6198591 |                 6522348 |     5.2         |
| 19 | PlaceOfBirth                             |                 6452850 |                 6522348 |     1.1         |
| 20 | AcceptsNewPatients                       |                 5417361 |                 6522348 |    20.4         |
| 21 | HasElectronicMedicalRecords              |                 6452850 |                 6522348 |     1.1         |
| 22 | HasElectronicPrescription                |                 6452850 |                 6522348 |     1.1         |
| 23 | SourceCode                               |                       0 |                       0 |     0           |
| 24 | SourceID                                 |                       0 |                 6522348 |   inf           |
| 25 | ChangedOn                                |                 6452850 |                 6522348 |     1.1         |
| 26 | ChangedBy                                |                 6452850 |                 6522348 |     1.1         |
| 27 | CreatedOn                                |                 6452850 |                 6522348 |     1.1         |
| 28 | CreatedBy                                |                 6452850 |                 6522348 |     1.1         |
| 29 | LegacyKey                                |                 6452850 |                 6522348 |     1.1         |
| 30 | LegacyKeyName                            |                 6452850 |                 6522348 |     1.1         |
| 31 | ProviderLastUpdateDateOverall            |                 6452850 |                 6522348 |     1.1         |
| 32 | ProviderLastUpdateDateOverallSource      |                 6452850 |                 6522348 |     1.1         |
| 33 | ProviderLastUpdateDateOverallSourceTable |                 6452850 |                 6522348 |     1.1         |
| 34 | ProviderLastUpdateDateOverallSourceCode  |                 6452850 |                 6522348 |     1.1         |
| 35 | LastUpdateDate                           |                   69894 |                       0 |   100           |
| 36 | SSN4                                     |                 6452850 |                 6522348 |     1.1         |
| 37 | ColumnSource                             |                 6452850 |                 6522348 |     1.1         |
| 38 | PatientVolume                            |                 6452850 |                 6522348 |     1.1         |
| 39 | IsInClinicalPractice                     |                 6452850 |                 6522348 |     1.1         |
| 40 | PatientCountIsFew                        |                 6452850 |                 6522348 |     1.1         |
| 41 | CampaignCode                             |                 6452850 |                 6522348 |     1.1         |
| 42 | SearchBoostSatisfaction                  |                 5242851 |                 6522348 |    24.4         |
| 43 | SearchBoostAccessibility                 |                       0 |                 6522348 |   inf           |
| 44 | IsPCPCalculated                          |                       0 |                       0 |     0           |
| 45 | FAFBoostSatisfaction                     |                 5242851 |                 6522348 |    24.4         |
| 46 | FAFBoostSancMalp                         |                       0 |                 6522348 |   inf           |
| 47 | FFESatisfactionBoost                     |                       0 |                 6522348 |   inf           |
| 48 | FFMalMultiHQ                             |                 6452850 |                 6522348 |     1.1         |
| 49 | FFMalMulti                               |                 6452850 |                 6522348 |     1.1         |
| 50 | ReltioEntityID                           |                       0 |                 6522348 |   inf           |
| 51 | SurviveResidentialAddresses              |                 6025883 |                 6522348 |     8.2         |
| 52 | IsPatientFavorite                        |                 6438687 |                 6522348 |     1.3         |
| 53 | SmartReferralClientID                    |                 6451351 |                 6522348 |     1.1         |

### 2.4 Distincts per Column
|    | Column_Name                              |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderID                               |                     6452850 |                     6522348 |          1.1 |
|  1 | EDWBaseRecordID                          |                     6452850 |                           0 |        100   |
|  2 | ProviderCode                             |                     6452850 |                     6522348 |          1.1 |
|  3 | ProviderTypeID                           |                           0 |                           0 |          0   |
|  4 | FirstName                                |                      292330 |                           0 |        100   |
|  5 | MiddleName                               |                      245783 |                           0 |        100   |
|  6 | LastName                                 |                      806828 |                           0 |        100   |
|  7 | CarePhilosophy                           |                      169278 |                           0 |        100   |
|  8 | ProfessionalInterest                     |                           0 |                           0 |          0   |
|  9 | Suffix                                   |                          13 |                           0 |        100   |
| 10 | Gender                                   |                           2 |                           0 |        100   |
| 11 | NPI                                      |                     6417064 |                           0 |        100   |
| 12 | AMAID                                    |                           0 |                           0 |          0   |
| 13 | UPIN                                     |                      853773 |                           0 |        100   |
| 14 | ABMSUID                                  |                      795798 |                           0 |        100   |
| 15 | MedicareID                               |                           0 |                           0 |          0   |
| 16 | DEANumber                                |                           0 |                           0 |          0   |
| 17 | TaxIDNumber                              |                           0 |                           0 |          0   |
| 18 | DateOfBirth                              |                       20913 |                           0 |        100   |
| 19 | PlaceOfBirth                             |                           0 |                           0 |          0   |
| 20 | AcceptsNewPatients                       |                           2 |                           0 |        100   |
| 21 | HasElectronicMedicalRecords              |                           0 |                           0 |          0   |
| 22 | HasElectronicPrescription                |                           0 |                           0 |          0   |
| 23 | SourceCode                               |                         204 |                           1 |         99.5 |
| 24 | SourceID                                 |                         204 |                           0 |        100   |
| 25 | ChangedOn                                |                           0 |                           0 |          0   |
| 26 | ChangedBy                                |                           0 |                           0 |          0   |
| 27 | CreatedOn                                |                           0 |                           0 |          0   |
| 28 | CreatedBy                                |                           0 |                           0 |          0   |
| 29 | LegacyKey                                |                           0 |                           0 |          0   |
| 30 | LegacyKeyName                            |                           0 |                           0 |          0   |
| 31 | ProviderLastUpdateDateOverall            |                           0 |                           0 |          0   |
| 32 | ProviderLastUpdateDateOverallSource      |                           0 |                           0 |          0   |
| 33 | ProviderLastUpdateDateOverallSourceTable |                           0 |                           0 |          0   |
| 34 | ProviderLastUpdateDateOverallSourceCode  |                           0 |                           0 |          0   |
| 35 | LastUpdateDate                           |                        8533 |                           1 |        100   |
| 36 | SSN4                                     |                           0 |                           0 |          0   |
| 37 | PatientVolume                            |                           0 |                           0 |          0   |
| 38 | IsInClinicalPractice                     |                           0 |                           0 |          0   |
| 39 | PatientCountIsFew                        |                           0 |                           0 |          0   |
| 40 | CampaignCode                             |                           0 |                           0 |          0   |
| 41 | SearchBoostSatisfaction                  |                         108 |                           0 |        100   |
| 42 | SearchBoostAccessibility                 |                          63 |                           0 |        100   |
| 43 | IsPCPCalculated                          |                           2 |                           1 |         50   |
| 44 | FAFBoostSatisfaction                     |                          86 |                           0 |        100   |
| 45 | FAFBoostSancMalp                         |                           2 |                           0 |        100   |
| 46 | FFESatisfactionBoost                     |                          11 |                           0 |        100   |
| 47 | FFMalMultiHQ                             |                           0 |                           0 |          0   |
| 48 | FFMalMulti                               |                           0 |                           0 |          0   |
| 49 | ReltioEntityID                           |                     6452817 |                           0 |        100   |
| 50 | SurviveResidentialAddresses              |                           2 |                           0 |        100   |
| 51 | IsPatientFavorite                        |                           2 |                           0 |        100   |
| 52 | SmartReferralClientID                    |                           3 |                           0 |        100   |