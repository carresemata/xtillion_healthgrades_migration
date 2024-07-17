# BASE.PROVIDER Report

## 1. Sample Validation

Percentage of Identical Columns: 75.93% (41/54).
Percentage of Different Columns: 24.07% (13/54).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name              | Match ID   | SQL Server Value                     | Snowflake Value                      |
|---:|:-------------------------|:-----------|:-------------------------------------|:-------------------------------------|
|  0 | PROVIDERID               | 1ZMV11PP62 | 564d5a31-3131-5050-0000-000000000000 | 8f8de674-be92-4cf7-8dae-af3a3c47d424 |
|  1 | EDWBASERECORDID          | 1ZMV11PP62 | 564d5a31-3131-5050-0000-000000000000 | None                                 |
|  2 | UPIN                     | 22B39      | F98317                               | None                                 |
|  3 | ABMSUID                  | 22B39      | 00216751                             | None                                 |
|  4 | DATEOFBIRTH              | 1ZMV11PP62 | NaT                                  | None                                 |
|  5 | SOURCEID                 | 22B39      | 54535543-4d4f-5245-5345-525649434500 | None                                 |
|  6 | LASTUPDATEDATE           | 1ZMV11PP62 | 2022-12-09 22:05:03.277              | 2024-06-19 16:02:14.660              |
|  7 | SEARCHBOOSTSATISFACTION  | 1ZMV11PP62 | nan                                  | None                                 |
|  8 | SEARCHBOOSTACCESSIBILITY | 1ZMV11PP62 | 0.0                                  | None                                 |
|  9 | FAFBOOSTSATISFACTION     | 1ZMV11PP62 | nan                                  | None                                 |
| 10 | FAFBOOSTSANCMALP         | 1ZMV11PP62 | 0.0                                  | None                                 |
| 11 | FFESATISFACTIONBOOST     | 1ZMV11PP62 | 0.5                                  | None                                 |
| 12 | RELTIOENTITYID           | 1ZMV11PP62 | 1ZMV11PP                             | None                                 |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 54
- Snowflake: 54
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 6452907
- Snowflake: 6625923
- Rows Margin (%): 2.6812101894541485

### 2.3 Nulls per Column
|    | Column_Name                              |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderID                               |                       0 |                       0 |          0   |
|  1 | EDWBaseRecordID                          |                       0 |                 6625923 |        inf   |
|  2 | ProviderCode                             |                       0 |                       0 |          0   |
|  3 | ProviderTypeID                           |                 6452907 |                 6625923 |          2.7 |
|  4 | FirstName                                |                       2 |                       0 |        100   |
|  5 | MiddleName                               |                 1991633 |                 2088045 |          4.8 |
|  6 | LastName                                 |                       1 |                       0 |        100   |
|  7 | CarePhilosophy                           |                 6215828 |                 6396962 |          2.9 |
|  8 | ProfessionalInterest                     |                 6452907 |                 6625923 |          2.7 |
|  9 | Suffix                                   |                 6334111 |                 6503167 |          2.7 |
| 10 | Gender                                   |                   88373 |                   18730 |         78.8 |
| 11 | NPI                                      |                   35732 |                   35729 |          0   |
| 12 | AMAID                                    |                 6452907 |                 6625923 |          2.7 |
| 13 | UPIN                                     |                 5598577 |                 6625923 |         18.4 |
| 14 | ABMSUID                                  |                 5656553 |                 6625923 |         17.1 |
| 15 | MedicareID                               |                 6452907 |                 6625923 |          2.7 |
| 16 | DEANumber                                |                 6452907 |                 6625923 |          2.7 |
| 17 | TaxIDNumber                              |                 6452907 |                 6625923 |          2.7 |
| 18 | DateOfBirth                              |                 4412039 |                 4531060 |          2.7 |
| 19 | PlaceOfBirth                             |                 6452907 |                 6625923 |          2.7 |
| 20 | AcceptsNewPatients                       |                 5411954 |                 5555124 |          2.6 |
| 21 | HasElectronicMedicalRecords              |                 6452907 |                 6625923 |          2.7 |
| 22 | HasElectronicPrescription                |                 6452907 |                 6625923 |          2.7 |
| 23 | SourceCode                               |                       0 |                       0 |          0   |
| 24 | SourceID                                 |                       0 |                 1279870 |        inf   |
| 25 | ChangedOn                                |                 6452907 |                 6625923 |          2.7 |
| 26 | ChangedBy                                |                 6452907 |                 6625923 |          2.7 |
| 27 | CreatedOn                                |                 6452907 |                 6625923 |          2.7 |
| 28 | CreatedBy                                |                 6452907 |                 6625923 |          2.7 |
| 29 | LegacyKey                                |                 6452907 |                 6625923 |          2.7 |
| 30 | LegacyKeyName                            |                 6452907 |                 6625923 |          2.7 |
| 31 | ProviderLastUpdateDateOverall            |                 6452907 |                 6625923 |          2.7 |
| 32 | ProviderLastUpdateDateOverallSource      |                 6452907 |                 6625923 |          2.7 |
| 33 | ProviderLastUpdateDateOverallSourceTable |                 6452907 |                 6625923 |          2.7 |
| 34 | ProviderLastUpdateDateOverallSourceCode  |                 6452907 |                 6625923 |          2.7 |
| 35 | LastUpdateDate                           |                   69840 |                       0 |        100   |
| 36 | SSN4                                     |                 6452907 |                 6625923 |          2.7 |
| 37 | ColumnSource                             |                 6452907 |                 6625923 |          2.7 |
| 38 | PatientVolume                            |                 6452907 |                 6625923 |          2.7 |
| 39 | IsInClinicalPractice                     |                 6452907 |                 6625923 |          2.7 |
| 40 | PatientCountIsFew                        |                 6452907 |                 6625923 |          2.7 |
| 41 | CampaignCode                             |                 6452907 |                 6625923 |          2.7 |
| 42 | SearchBoostSatisfaction                  |                 5242266 |                 6625923 |         26.4 |
| 43 | SearchBoostAccessibility                 |                       0 |                 6625923 |        inf   |
| 44 | IsPCPCalculated                          |                       0 |                       0 |          0   |
| 45 | FAFBoostSatisfaction                     |                 5242266 |                 6625923 |         26.4 |
| 46 | FAFBoostSancMalp                         |                       0 |                 6625923 |        inf   |
| 47 | FFESatisfactionBoost                     |                       0 |                 6625923 |        inf   |
| 48 | FFMalMultiHQ                             |                 6452907 |                 6625923 |          2.7 |
| 49 | FFMalMulti                               |                 6452907 |                 6625923 |          2.7 |
| 50 | ReltioEntityID                           |                       0 |                 6625923 |        inf   |
| 51 | SurviveResidentialAddresses              |                 6287760 |                 6462561 |          2.8 |
| 52 | IsPatientFavorite                        |                 6424975 |                 6625923 |          3.1 |
| 53 | SmartReferralClientID                    |                 6451748 |                 6625923 |          2.7 |

### 2.4 Distincts per Column
|    | Column_Name                              |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderID                               |                     6452907 |                     6625923 |          2.7 |
|  1 | EDWBaseRecordID                          |                     6452907 |                           0 |        100   |
|  2 | ProviderCode                             |                     6452907 |                     6522348 |          1.1 |
|  3 | ProviderTypeID                           |                           0 |                           0 |          0   |
|  4 | FirstName                                |                      292280 |                      300452 |          2.8 |
|  5 | MiddleName                               |                      245808 |                      249525 |          1.5 |
|  6 | LastName                                 |                      807082 |                      820800 |          1.7 |
|  7 | CarePhilosophy                           |                      171873 |                      164829 |          4.1 |
|  8 | ProfessionalInterest                     |                           0 |                           0 |          0   |
|  9 | Suffix                                   |                          13 |                          13 |          0   |
| 10 | Gender                                   |                           2 |                           2 |          0   |
| 11 | NPI                                      |                     6417167 |                     6486618 |          1.1 |
| 12 | AMAID                                    |                           0 |                           0 |          0   |
| 13 | UPIN                                     |                      853773 |                           0 |        100   |
| 14 | ABMSUID                                  |                      795798 |                           0 |        100   |
| 15 | MedicareID                               |                           0 |                           0 |          0   |
| 16 | DEANumber                                |                           0 |                           0 |          0   |
| 17 | TaxIDNumber                              |                           0 |                           0 |          0   |
| 18 | DateOfBirth                              |                       26372 |                       26369 |          0   |
| 19 | PlaceOfBirth                             |                           0 |                           0 |          0   |
| 20 | AcceptsNewPatients                       |                           2 |                           2 |          0   |
| 21 | HasElectronicMedicalRecords              |                           0 |                           0 |          0   |
| 22 | HasElectronicPrescription                |                           0 |                           0 |          0   |
| 23 | SourceCode                               |                         204 |                         202 |          1   |
| 24 | SourceID                                 |                         205 |                           4 |         98   |
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
| 35 | LastUpdateDate                           |                        7649 |                           1 |        100   |
| 36 | SSN4                                     |                           0 |                           0 |          0   |
| 37 | PatientVolume                            |                           0 |                           0 |          0   |
| 38 | IsInClinicalPractice                     |                           0 |                           0 |          0   |
| 39 | PatientCountIsFew                        |                           0 |                           0 |          0   |
| 40 | CampaignCode                             |                           0 |                           0 |          0   |
| 41 | SearchBoostSatisfaction                  |                         108 |                           0 |        100   |
| 42 | SearchBoostAccessibility                 |                          68 |                           0 |        100   |
| 43 | IsPCPCalculated                          |                           2 |                           1 |         50   |
| 44 | FAFBoostSatisfaction                     |                          86 |                           0 |        100   |
| 45 | FAFBoostSancMalp                         |                           2 |                           0 |        100   |
| 46 | FFESatisfactionBoost                     |                          11 |                           0 |        100   |
| 47 | FFMalMultiHQ                             |                           0 |                           0 |          0   |
| 48 | FFMalMulti                               |                           0 |                           0 |          0   |
| 49 | ReltioEntityID                           |                     6452874 |                           0 |        100   |
| 50 | SurviveResidentialAddresses              |                           2 |                           2 |          0   |
| 51 | IsPatientFavorite                        |                           2 |                           0 |        100   |
| 52 | SmartReferralClientID                    |                           2 |                           0 |        100   |