# BASE.PROVIDERTOSPECIALTY Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/24).
Percentage of Different Columns: 0.00% (0/24).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 24
- Snowflake: 24
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 6382026
- Snowflake: 6503798
- Rows Margin (%): 1.9080461282984431

### 2.3 Nulls per Column
|    | Column_Name                           |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToSpecialtyID                 |                       0 |                       0 |          0   |
|  1 | ProviderID                            |                       0 |                       0 |          0   |
|  2 | SpecialtyID                           |                       0 |                       0 |          0   |
|  3 | SourceCode                            |                       0 |                       0 |          0   |
|  4 | SpecialtyRank                         |                 5702928 |                 5811081 |          1.9 |
|  5 | SpecialtyRankCalculated               |                       0 |                       0 |          0   |
|  6 | IsSearchable                          |                 5831290 |                 5936767 |          1.8 |
|  7 | IsSearchableCalculated                |                       0 |                       0 |          0   |
|  8 | InsertedOn                            |                       0 |                       0 |          0   |
|  9 | InsertedBy                            |                       0 |                       0 |          0   |
| 10 | SpecialtyGroupID                      |                 6382026 |                 6503798 |          1.9 |
| 11 | SpecialtyIsRedundant                  |                       0 |                       0 |          0   |
| 12 | CampaignCode                          |                 6382026 |                 6503798 |          1.9 |
| 13 | SearchBoostExperience                 |                 5603865 |                 6503798 |         16.1 |
| 14 | SearchBoostHospitalCohortQuality      |                 5516652 |                 6503798 |         17.9 |
| 15 | SearchBoostHospitalServiceLineQuality |                 5548113 |                 6503798 |         17.2 |
| 16 | LastUpdateDate                        |                       6 |                       0 |        100   |
| 17 | SpecialtyDCPCount                     |                 5646727 |                 5740409 |          1.7 |
| 18 | SpecialtyDCPMinFillThreshold          |                 5646727 |                 5740409 |          1.7 |
| 19 | ProviderSpecialtyDCPCount             |                 5646727 |                 5740409 |          1.7 |
| 20 | ProviderSpecialtyAveragePercentile    |                 5646727 |                 5740409 |          1.7 |
| 21 | MeetsLowThreshold                     |                 5646727 |                 5740409 |          1.7 |
| 22 | ProviderRawSpecialtyScore             |                 5646727 |                 5740409 |          1.7 |
| 23 | ScaledSpecialtyBoost                  |                 5646727 |                 5740409 |          1.7 |

### 2.4 Distincts per Column
|    | Column_Name                           |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToSpecialtyID                 |                     6382026 |                     6503798 |          1.9 |
|  1 | ProviderID                            |                     4960763 |                     5056022 |          1.9 |
|  2 | SpecialtyID                           |                         952 |                         952 |          0   |
|  3 | SourceCode                            |                         215 |                         213 |          0.9 |
|  4 | SpecialtyRank                         |                          18 |                          17 |          5.6 |
|  5 | SpecialtyRankCalculated               |                         125 |                         125 |          0   |
|  6 | IsSearchable                          |                           2 |                           2 |          0   |
|  7 | IsSearchableCalculated                |                           2 |                           2 |          0   |
|  8 | InsertedOn                            |                          21 |                           1 |         95.2 |
|  9 | InsertedBy                            |                           2 |                           1 |         50   |
| 10 | SpecialtyGroupID                      |                           0 |                           0 |          0   |
| 11 | SpecialtyIsRedundant                  |                           1 |                           1 |          0   |
| 12 | CampaignCode                          |                           0 |                           0 |          0   |
| 13 | SearchBoostExperience                 |                         103 |                           0 |        100   |
| 14 | SearchBoostHospitalCohortQuality      |                        2949 |                           0 |        100   |
| 15 | SearchBoostHospitalServiceLineQuality |                        4102 |                           0 |        100   |
| 16 | LastUpdateDate                        |                      181730 |                      181641 |          0   |
| 17 | SpecialtyDCPCount                     |                         126 |                         126 |          0   |
| 18 | SpecialtyDCPMinFillThreshold          |                          30 |                          30 |          0   |
| 19 | ProviderSpecialtyDCPCount             |                         311 |                         311 |          0   |
| 20 | ProviderSpecialtyAveragePercentile    |                         100 |                         100 |          0   |
| 21 | MeetsLowThreshold                     |                           1 |                           1 |          0   |
| 22 | ProviderRawSpecialtyScore             |                      106987 |                          12 |        100   |
| 23 | ScaledSpecialtyBoost                  |                      145346 |                           2 |        100   |