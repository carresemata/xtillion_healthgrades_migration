# BASE.PROVIDERTOOFFICE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/16).
Percentage of Different Columns: 0.00% (0/16).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 16
- Snowflake: 16
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 7532552
- Snowflake: 7570026
- Rows Margin (%): 0.4974940763767711

### 2.3 Nulls per Column
|    | Column_Name                     |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToOfficeID              |                       0 |                       0 |          0   |
|  1 | ProviderID                      |                       0 |                       0 |          0   |
|  2 | OfficeID                        |                       0 |                       0 |          0   |
|  3 | IsPrimaryOffice                 |                 7532552 |                 7570026 |          0.5 |
|  4 | ProviderOfficeRank              |                       0 |                       0 |          0   |
|  5 | LegacyKey                       |                 7532552 |                 7570026 |          0.5 |
|  6 | LegacyKeyName                   |                 7532552 |                 7570026 |          0.5 |
|  7 | SourceCode                      |                       0 |                       0 |          0   |
|  8 | IsDerived                       |                       0 |                       0 |          0   |
|  9 | ProviderOfficeRankInferenceCode |                 7532552 |                 7570026 |          0.5 |
| 10 | SourceAddressCount              |                 7532552 |                 7570026 |          0.5 |
| 11 | LastUpdateDate                  |                       0 |                       0 |          0   |
| 12 | MergeWithAll                    |                 7532552 |                 7570026 |          0.5 |
| 13 | CampaignCode                    |                 7532552 |                 7570026 |          0.5 |
| 14 | OfficeName                      |                       5 |                       0 |        100   |
| 15 | PracticeName                    |                       7 |                       0 |        100   |

### 2.4 Distincts per Column
|    | Column_Name                     |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToOfficeID              |                     7532552 |                     7570026 |          0.5 |
|  1 | ProviderID                      |                     5552586 |                     5587458 |          0.6 |
|  2 | OfficeID                        |                     2951839 |                     2961935 |          0.3 |
|  3 | IsPrimaryOffice                 |                           0 |                           0 |          0   |
|  4 | ProviderOfficeRank              |                         154 |                         154 |          0   |
|  5 | LegacyKey                       |                           0 |                           0 |          0   |
|  6 | LegacyKeyName                   |                           0 |                           0 |          0   |
|  7 | SourceCode                      |                         215 |                         214 |          0.5 |
|  8 | IsDerived                       |                           1 |                           1 |          0   |
|  9 | ProviderOfficeRankInferenceCode |                           0 |                           0 |          0   |
| 10 | SourceAddressCount              |                           0 |                           0 |          0   |
| 11 | LastUpdateDate                  |                      174405 |                      174134 |          0.2 |
| 12 | MergeWithAll                    |                           0 |                           0 |          0   |
| 13 | CampaignCode                    |                           0 |                           0 |          0   |
| 14 | OfficeName                      |                      799570 |                      822078 |          2.8 |
| 15 | PracticeName                    |                      262836 |                      267235 |          1.7 |