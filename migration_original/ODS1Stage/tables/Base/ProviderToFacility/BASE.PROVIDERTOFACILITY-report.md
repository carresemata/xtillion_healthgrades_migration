# BASE.PROVIDERTOFACILITY Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/10).
Percentage of Different Columns: 0.00% (0/10).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 10
- Snowflake: 10
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 1461798
- Snowflake: 1486099
- Rows Margin (%): 1.662404791906953

### 2.3 Nulls per Column
|    | Column_Name          |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:---------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToFacilityID |                       0 |                       0 |          0   |
|  1 | ProviderID           |                       0 |                       0 |          0   |
|  2 | FacilityID           |                       0 |                       0 |          0   |
|  3 | ProviderRoleID       |                 1461798 |                 1486099 |          1.7 |
|  4 | LegacyKey            |                 1461798 |                 1486099 |          1.7 |
|  5 | LegacyKeyName        |                 1461798 |                 1486099 |          1.7 |
|  6 | HonorRollTypeID      |                 1461798 |                 1486099 |          1.7 |
|  7 | SourceCode           |                       0 |                       0 |          0   |
|  8 | LastUpdateDate       |                       0 |                       0 |          0   |
|  9 | CampaignCode         |                 1461798 |                 1486099 |          1.7 |

### 2.4 Distincts per Column
|    | Column_Name          |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:---------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToFacilityID |                     1461798 |                     1486099 |          1.7 |
|  1 | ProviderID           |                      842990 |                      852698 |          1.2 |
|  2 | FacilityID           |                        5748 |                        5784 |          0.6 |
|  3 | ProviderRoleID       |                           0 |                           0 |          0   |
|  4 | LegacyKey            |                           0 |                           0 |          0   |
|  5 | LegacyKeyName        |                           0 |                           0 |          0   |
|  6 | HonorRollTypeID      |                           0 |                           0 |          0   |
|  7 | SourceCode           |                         193 |                         190 |          1.6 |
|  8 | LastUpdateDate       |                        3112 |                        3376 |          8.5 |
|  9 | CampaignCode         |                           0 |                           0 |          0   |