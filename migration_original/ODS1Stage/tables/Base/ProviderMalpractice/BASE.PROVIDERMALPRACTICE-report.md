# BASE.PROVIDERMALPRACTICE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/19).
Percentage of Different Columns: 0.00% (0/19).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 19
- Snowflake: 19
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 5872
- Snowflake: 6745
- Rows Margin (%): 14.86716621253406

### 2.3 Nulls per Column
|    | Column_Name            |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderMalpracticeID  |                       0 |                       0 |          0   |
|  1 | ProviderID             |                       0 |                       0 |          0   |
|  2 | ProviderLicenseID      |                    5872 |                    6745 |         14.9 |
|  3 | MalpracticeClaimTypeID |                       0 |                       0 |          0   |
|  4 | ClaimNumber            |                    5872 |                    6745 |         14.9 |
|  5 | ClaimDate              |                     442 |                     652 |         47.5 |
|  6 | ClaimYear              |                    5430 |                    6093 |         12.2 |
|  7 | ClaimAmount            |                       0 |                       0 |          0   |
|  8 | ClaimState             |                       0 |                       0 |          0   |
|  9 | MalpracticeClaimRange  |                    3807 |                    4393 |         15.4 |
| 10 | Complaint              |                    5872 |                    6745 |         14.9 |
| 11 | IncidentDate           |                    5872 |                    6745 |         14.9 |
| 12 | ClosedDate             |                    5872 |                    6745 |         14.9 |
| 13 | ReportDate             |                    5872 |                    6745 |         14.9 |
| 14 | LegacyKey              |                    5872 |                    6745 |         14.9 |
| 15 | LegacyKeyName          |                    5872 |                    6745 |         14.9 |
| 16 | SourceCode             |                       0 |                       0 |          0   |
| 17 | LicenseNumber          |                       2 |                       2 |          0   |
| 18 | LastUpdateDate         |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name            |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderMalpracticeID  |                        5872 |                        6745 |         14.9 |
|  1 | ProviderID             |                        5309 |                        5564 |          4.8 |
|  2 | ProviderLicenseID      |                           0 |                           0 |          0   |
|  3 | MalpracticeClaimTypeID |                           1 |                           1 |          0   |
|  4 | ClaimNumber            |                           0 |                           0 |          0   |
|  5 | ClaimDate              |                        1125 |                        1127 |          0.2 |
|  6 | ClaimYear              |                           4 |                           4 |          0   |
|  7 | ClaimAmount            |                         444 |                         443 |          0.2 |
|  8 | ClaimState             |                          16 |                          16 |          0   |
|  9 | MalpracticeClaimRange  |                           4 |                           4 |          0   |
| 10 | Complaint              |                           0 |                           0 |          0   |
| 11 | IncidentDate           |                           0 |                           0 |          0   |
| 12 | ClosedDate             |                           0 |                           0 |          0   |
| 13 | ReportDate             |                           0 |                           0 |          0   |
| 14 | LegacyKey              |                           0 |                           0 |          0   |
| 15 | LegacyKeyName          |                           0 |                           0 |          0   |
| 16 | SourceCode             |                           1 |                           1 |          0   |
| 17 | LicenseNumber          |                        5405 |                        5421 |          0.3 |
| 18 | LastUpdateDate         |                           1 |                           1 |          0   |