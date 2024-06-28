# MID.PROVIDERFACILITY Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/22).
Percentage of Different Columns: 0.00% (0/22).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 22
- Snowflake: 22
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 1449366
- Snowflake: 115462
- Rows Margin (%): 92.03362021739161

### 2.3 Nulls per Column
|    | Column_Name            |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToFacilityID   |                       0 |                       0 |          0   |
|  1 | ProviderID             |                       0 |                       0 |          0   |
|  2 | FacilityID             |                       0 |                       0 |          0   |
|  3 | FacilityCode           |                       0 |                       0 |          0   |
|  4 | FacilityName           |                       0 |                       0 |          0   |
|  5 | IsClosed               |                       0 |                       0 |          0   |
|  6 | ImageFilePath          |                 1449366 |                  115462 |         92   |
|  7 | RoleCode               |                 1449366 |                  115462 |         92   |
|  8 | RoleDescription        |                 1449366 |                  115462 |         92   |
|  9 | LegacyKey              |                       0 |                       0 |          0   |
| 10 | FiveStarXML            |                  395260 |                   41970 |         89.4 |
| 11 | HasAward               |                  597518 |                   60524 |         89.9 |
| 12 | ServiceLineAward       |                  688177 |                   67034 |         90.3 |
| 13 | AddressXML             |                       0 |                       0 |          0   |
| 14 | AwardXML               |                  404999 |                   43538 |         89.2 |
| 15 | PDCPhoneXML            |                 1314066 |                  115462 |         91.2 |
| 16 | FacilityURL            |                       0 |                       2 |        inf   |
| 17 | FacilityType           |                       0 |                       0 |          0   |
| 18 | FacilityTypeCode       |                       0 |                       0 |          0   |
| 19 | FacilitySearchType     |                       0 |                       0 |          0   |
| 20 | FiveStarProcedureCount |                  282392 |                  115462 |         59.1 |
| 21 | QualityScore           |                 1449366 |                  115462 |         92   |

### 2.4 Distincts per Column
|    | Column_Name            |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToFacilityID   |                     1449366 |                      115462 |         92   |
|  1 | ProviderID             |                      849671 |                       60866 |         92.8 |
|  2 | FacilityID             |                        5341 |                        4098 |         23.3 |
|  3 | FacilityCode           |                        5341 |                        4098 |         23.3 |
|  4 | FacilityName           |                        5173 |                        3984 |         23   |
|  5 | IsClosed               |                           2 |                           1 |         50   |
|  6 | ImageFilePath          |                           0 |                           0 |          0   |
|  7 | RoleCode               |                           0 |                           0 |          0   |
|  8 | RoleDescription        |                           0 |                           0 |          0   |
|  9 | LegacyKey              |                        5340 |                        4098 |         23.3 |
| 10 | HasAward               |                           1 |                           1 |          0   |
| 11 | FacilityURL            |                        5340 |                        4097 |         23.3 |
| 12 | FacilityType           |                           4 |                           4 |          0   |
| 13 | FacilityTypeCode       |                           4 |                           4 |          0   |
| 14 | FacilitySearchType     |                           3 |                           3 |          0   |
| 15 | FiveStarProcedureCount |                          36 |                           0 |        100   |
| 16 | QualityScore           |                           0 |                           0 |          0   |