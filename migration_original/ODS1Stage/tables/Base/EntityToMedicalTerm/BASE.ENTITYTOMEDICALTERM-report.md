# base.entitytomedicalterm Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/35).
Percentage of Different Columns: 0.00% (0/35).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 35
- Snowflake: 35
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 98414094
- Snowflake: 98264434
- Rows Margin (%): 0.15207171444366493

### 2.3 Nulls per Column
|    | Column_Name                                   |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:----------------------------------------------|------------------------:|------------------------:|-------------:|
|  0 | EntityToMedicalTermID                         |                       0 |                       0 |          0   |
|  1 | EntityID                                      |                       0 |                       0 |          0   |
|  2 | MedicalTermID                                 |                       0 |                       0 |          0   |
|  3 | EntityTypeID                                  |                       0 |                       0 |          0   |
|  4 | MedicalTermRank                               |                98414094 |                98264434 |          0.2 |
|  5 | LegacyKey                                     |                98414094 |                98264434 |          0.2 |
|  6 | LegacyKeyName                                 |                98414094 |                98264434 |          0.2 |
|  7 | SourceCode                                    |                       0 |                       0 |          0   |
|  8 | Searchable                                    |                98414094 |                98264434 |          0.2 |
|  9 | LastUpdateDate                                |                       0 |                       0 |          0   |
| 10 | NationalRankingA                              |                70663513 |                70155728 |          0.7 |
| 11 | PatientCount                                  |                88180263 |                87933089 |          0.3 |
| 12 | DecileRank                                    |                98414094 |                98264434 |          0.2 |
| 13 | PatientCountIsFew                             |                71611301 |                70155635 |          2   |
| 14 | NationalRankingB                              |                70663419 |                70155635 |          0.7 |
| 15 | SourceSearch                                  |                       0 |                       0 |          0   |
| 16 | IsPreview                                     |                97601338 |                98264434 |          0.7 |
| 17 | NationalRankingBCalc                          |                71736928 |                98264434 |         37   |
| 18 | SearchBoostExperience                         |                71736928 |                98264434 |         37   |
| 19 | SearchBoostHospitalCohortQuality              |                96053058 |                98264434 |          2.3 |
| 20 | SearchBoostHospitalServiceLineQuality         |                96208866 |                98264434 |          2.1 |
| 21 | FriendsAndFamilyDCPQualityFacility            |                94751187 |                98264434 |          3.7 |
| 22 | FriendsAndFamilyDCPQualityZScore              |                94751187 |                98264434 |          3.7 |
| 23 | FriendsAndFamilyDCPQualityCode                |                94751187 |                98264434 |          3.7 |
| 24 | FriendsAndFamilyDCPQualityRatingPercent       |                94751187 |                98264434 |          3.7 |
| 25 | FriendsAndFamilyDCPExperienceRatingPercent    |                71737395 |                98264434 |         37   |
| 26 | FriendsAndFamilyDCPQualityFacilityList        |                94751187 |                98264434 |          3.7 |
| 27 | FriendsAndFamilyDCPQualityFacilityScoreList   |                94814928 |                98264434 |          3.6 |
| 28 | FriendsAndFamilyDCPQualityFacRatingPerList    |                94751187 |                98264434 |          3.7 |
| 29 | FFExpBoost                                    |                70663421 |                98264434 |         39.1 |
| 30 | FFQualityFaciltyWeightList                    |                94751187 |                98264434 |          3.7 |
| 31 | FFHQualityWinWeight                           |                94751187 |                98264434 |          3.7 |
| 32 | FriendsAndFamilyDCPQualityFacilityListLatLong |                94751187 |                98264434 |          3.7 |
| 33 | IsScreeningDefaultCalculation                 |                98414094 |                98264434 |          0.2 |
| 34 | TreatmentLevelID                              |                98414094 |                98264434 |          0.2 |

### 2.4 Distincts per Column
|    | Column_Name                                   |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:----------------------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | EntityToMedicalTermID                         |                    98414094 |                    98264434 |          0.2 |
|  1 | EntityID                                      |                     1098672 |                     1111869 |          1.2 |
|  2 | MedicalTermID                                 |                       13206 |                       13211 |          0   |
|  3 | EntityTypeID                                  |                           1 |                           1 |          0   |
|  4 | MedicalTermRank                               |                           0 |                           0 |          0   |
|  5 | LegacyKey                                     |                           0 |                           0 |          0   |
|  6 | LegacyKeyName                                 |                           0 |                           0 |          0   |
|  7 | SourceCode                                    |                         224 |                         212 |          5.4 |
|  8 | Searchable                                    |                           0 |                           0 |          0   |
|  9 | LastUpdateDate                                |                      258895 |                      336551 |         30   |
| 10 | NationalRankingA                              |                           4 |                           4 |          0   |
| 11 | PatientCount                                  |                        4218 |                        4218 |          0   |
| 12 | DecileRank                                    |                           0 |                           0 |          0   |
| 13 | PatientCountIsFew                             |                           2 |                           2 |          0   |
| 14 | NationalRankingB                              |                         100 |                         100 |          0   |
| 15 | SourceSearch                                  |                           1 |                           1 |          0   |
| 16 | IsPreview                                     |                           1 |                           0 |        100   |
| 17 | NationalRankingBCalc                          |                         100 |                           0 |        100   |
| 18 | SearchBoostExperience                         |                         100 |                           0 |        100   |
| 19 | SearchBoostHospitalCohortQuality              |                        2903 |                           0 |        100   |
| 20 | SearchBoostHospitalServiceLineQuality         |                        3026 |                           0 |        100   |
| 21 | FriendsAndFamilyDCPQualityFacility            |                        3908 |                           0 |        100   |
| 22 | FriendsAndFamilyDCPQualityZScore              |                        1932 |                           0 |        100   |
| 23 | FriendsAndFamilyDCPQualityCode                |                          50 |                           0 |        100   |
| 24 | FriendsAndFamilyDCPQualityRatingPercent       |                        8814 |                           0 |        100   |
| 25 | FriendsAndFamilyDCPExperienceRatingPercent    |                        3100 |                           0 |        100   |
| 26 | FriendsAndFamilyDCPQualityFacilityList        |                       92392 |                           0 |        100   |
| 27 | FriendsAndFamilyDCPQualityFacilityScoreList   |                      185953 |                           0 |        100   |
| 28 | FriendsAndFamilyDCPQualityFacRatingPerList    |                      197127 |                           0 |        100   |
| 29 | FFExpBoost                                    |                           7 |                           0 |        100   |
| 30 | FFQualityFaciltyWeightList                    |                        3853 |                           0 |        100   |
| 31 | FFHQualityWinWeight                           |                           6 |                           0 |        100   |
| 32 | FriendsAndFamilyDCPQualityFacilityListLatLong |                       92441 |                           0 |        100   |
| 33 | IsScreeningDefaultCalculation                 |                           0 |                           0 |          0   |
| 34 | TreatmentLevelID                              |                           0 |                           0 |          0   |