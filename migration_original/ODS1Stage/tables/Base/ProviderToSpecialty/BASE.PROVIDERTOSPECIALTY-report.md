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
- SQL Server: 6380705
- Snowflake: 6384379
- Rows Margin (%): 0.05757984423351338

### 2.3 Nulls per Column
|    | Column_Name                           |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToSpecialtyID                 |                       0 |                       0 |          0   |
|  1 | ProviderID                            |                       0 |                       0 |          0   |
|  2 | SpecialtyID                           |                       0 |                       0 |          0   |
|  3 | SourceCode                            |                       0 |                       0 |          0   |
|  4 | SpecialtyRank                         |                 5704505 |                 5705723 |          0   |
|  5 | SpecialtyRankCalculated               |                       0 |                       0 |          0   |
|  6 | IsSearchable                          |                 5830250 |                 5831649 |          0   |
|  7 | IsSearchableCalculated                |                       0 |                       0 |          0   |
|  8 | InsertedOn                            |                       0 |                       0 |          0   |
|  9 | InsertedBy                            |                       0 |                       0 |          0   |
| 10 | SpecialtyGroupID                      |                 6380705 |                 6384379 |          0.1 |
| 11 | SpecialtyIsRedundant                  |                       0 |                       0 |          0   |
| 12 | CampaignCode                          |                 6380705 |                 6384379 |          0.1 |
| 13 | SearchBoostExperience                 |                 5601868 |                 6384379 |         14   |
| 14 | SearchBoostHospitalCohortQuality      |                 6380698 |                 6384379 |          0.1 |
| 15 | SearchBoostHospitalServiceLineQuality |                 6380699 |                 6384379 |          0.1 |
| 16 | LastUpdateDate                        |                       6 |                       0 |        100   |
| 17 | SpecialtyDCPCount                     |                 5644876 |                 5648351 |          0.1 |
| 18 | SpecialtyDCPMinFillThreshold          |                 5644876 |                 5648351 |          0.1 |
| 19 | ProviderSpecialtyDCPCount             |                 5644876 |                 5648351 |          0.1 |
| 20 | ProviderSpecialtyAveragePercentile    |                 5644876 |                 5648351 |          0.1 |
| 21 | MeetsLowThreshold                     |                 5644876 |                 5648351 |          0.1 |
| 22 | ProviderRawSpecialtyScore             |                 5644876 |                 5648351 |          0.1 |
| 23 | ScaledSpecialtyBoost                  |                 5644876 |                 5648351 |          0.1 |

### 2.4 Distincts per Column
|    | Column_Name                           |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToSpecialtyID                 |                     6380705 |                     6384379 |          0.1 |
|  1 | ProviderID                            |                     4960546 |                     4961681 |          0   |
|  2 | SpecialtyID                           |                         952 |                         952 |          0   |
|  3 | SourceCode                            |                         214 |                         215 |          0.5 |
|  4 | SpecialtyRank                         |                          17 |                          18 |          5.9 |
|  5 | SpecialtyRankCalculated               |                         125 |                         125 |          0   |
|  6 | IsSearchable                          |                           2 |                           2 |          0   |
|  7 | IsSearchableCalculated                |                           2 |                           2 |          0   |
|  8 | InsertedOn                            |                           6 |                           1 |         83.3 |
|  9 | InsertedBy                            |                           2 |                           1 |         50   |
| 10 | SpecialtyGroupID                      |                           0 |                           0 |          0   |
| 11 | SpecialtyIsRedundant                  |                           1 |                           1 |          0   |
| 12 | CampaignCode                          |                           0 |                           0 |          0   |
| 13 | SearchBoostExperience                 |                         103 |                           0 |        100   |
| 14 | SearchBoostHospitalCohortQuality      |                           7 |                           0 |        100   |
| 15 | SearchBoostHospitalServiceLineQuality |                           6 |                           0 |        100   |
| 16 | LastUpdateDate                        |                      181932 |                      181995 |          0   |
| 17 | SpecialtyDCPCount                     |                         126 |                         126 |          0   |
| 18 | SpecialtyDCPMinFillThreshold          |                          30 |                          30 |          0   |
| 19 | ProviderSpecialtyDCPCount             |                         311 |                         311 |          0   |
| 20 | ProviderSpecialtyAveragePercentile    |                         100 |                         100 |          0   |
| 21 | MeetsLowThreshold                     |                           1 |                           1 |          0   |
| 22 | ProviderRawSpecialtyScore             |                      107072 |                          12 |        100   |
| 23 | ScaledSpecialtyBoost                  |                      145546 |                           2 |        100   |