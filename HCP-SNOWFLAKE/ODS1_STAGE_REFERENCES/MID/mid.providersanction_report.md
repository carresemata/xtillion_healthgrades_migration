# MID.PROVIDERSANCTION Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/15).
Percentage of Different Columns: 0.00% (0/15).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 15
- Snowflake: 15
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 31296
- Snowflake: 37133
- Rows Margin (%): 18.65094580777096

### 2.3 Nulls per Column
|    | Column_Name                   |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderSanctionID            |                       0 |                       0 |          0   |
|  1 | ProviderID                    |                       0 |                       0 |          0   |
|  2 | SanctionDescription           |                   31191 |                   37133 |         19.1 |
|  3 | SanctionDate                  |                       0 |                       0 |          0   |
|  4 | ReinstatementDate             |                   31293 |                   37133 |         18.7 |
|  5 | SanctionTypeCode              |                       0 |                       0 |          0   |
|  6 | SanctionTypeDescription       |                       0 |                       0 |          0   |
|  7 | State                         |                       0 |                   37133 |        inf   |
|  8 | SanctionCategoryCode          |                       0 |                       0 |          0   |
|  9 | SanctionCategoryDescription   |                       0 |                       0 |          0   |
| 10 | SanctionActionCode            |                       0 |                       0 |          0   |
| 11 | SanctionActionDescription     |                       0 |                       0 |          0   |
| 12 | SanctionActionTypeCode        |                       0 |                       0 |          0   |
| 13 | SanctionActionTypeDescription |                       0 |                       0 |          0   |
| 14 | StateFull                     |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name                   |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderSanctionID            |                       31296 |                       33469 |          6.9 |
|  1 | ProviderID                    |                       11565 |                       12076 |          4.4 |
|  2 | SanctionDescription           |                         105 |                           0 |        100   |
|  3 | SanctionDate                  |                        2614 |                        2553 |          2.3 |
|  4 | ReinstatementDate             |                           3 |                           0 |        100   |
|  5 | SanctionTypeCode              |                           1 |                           1 |          0   |
|  6 | SanctionTypeDescription       |                           1 |                           1 |          0   |
|  7 | State                         |                          51 |                           0 |        100   |
|  8 | SanctionCategoryCode          |                          34 |                           1 |         97.1 |
|  9 | SanctionCategoryDescription   |                          34 |                           1 |         97.1 |
| 10 | SanctionActionCode            |                         149 |                         131 |         12.1 |
| 11 | SanctionActionDescription     |                         149 |                         131 |         12.1 |
| 12 | SanctionActionTypeCode        |                           2 |                           1 |         50   |
| 13 | SanctionActionTypeDescription |                           2 |                           1 |         50   |
| 14 | StateFull                     |                          51 |                          51 |          0   |