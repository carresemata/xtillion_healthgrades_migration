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
- SQL Server: 5980
- Snowflake: 5972
- Rows Margin (%): 0.13377926421404682

### 2.3 Nulls per Column
|    | Column_Name            |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderMalpracticeID  |                       0 |                       0 |          0   |
|  1 | ProviderID             |                       0 |                       0 |          0   |
|  2 | ProviderLicenseID      |                    5980 |                    5972 |          0.1 |
|  3 | MalpracticeClaimTypeID |                       0 |                       0 |          0   |
|  4 | ClaimNumber            |                    5980 |                    5972 |          0.1 |
|  5 | ClaimDate              |                     442 |                     442 |          0   |
|  6 | ClaimYear              |                    5538 |                    5530 |          0.1 |
|  7 | ClaimAmount            |                       0 |                       0 |          0   |
|  8 | ClaimState             |                       0 |                       0 |          0   |
|  9 | MalpracticeClaimRange  |                    3877 |                    3874 |          0.1 |
| 10 | Complaint              |                    5980 |                    5972 |          0.1 |
| 11 | IncidentDate           |                    5980 |                    5972 |          0.1 |
| 12 | ClosedDate             |                    5980 |                    5972 |          0.1 |
| 13 | ReportDate             |                    5980 |                    5972 |          0.1 |
| 14 | LegacyKey              |                    5980 |                    5972 |          0.1 |
| 15 | LegacyKeyName          |                    5980 |                    5972 |          0.1 |
| 16 | SourceCode             |                       0 |                       0 |          0   |
| 17 | LicenseNumber          |                       3 |                       3 |          0   |
| 18 | LastUpdateDate         |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name            |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderMalpracticeID  |                        5980 |                        5972 |          0.1 |
|  1 | ProviderID             |                        5399 |                        5394 |          0.1 |
|  2 | ProviderLicenseID      |                           0 |                           0 |          0   |
|  3 | MalpracticeClaimTypeID |                           1 |                           1 |          0   |
|  4 | ClaimNumber            |                           0 |                           0 |          0   |
|  5 | ClaimDate              |                        1138 |                        1137 |          0.1 |
|  6 | ClaimYear              |                           4 |                           4 |          0   |
|  7 | ClaimAmount            |                         446 |                         445 |          0.2 |
|  8 | ClaimState             |                          16 |                          16 |          0   |
|  9 | MalpracticeClaimRange  |                           4 |                           4 |          0   |
| 10 | Complaint              |                           0 |                           0 |          0   |
| 11 | IncidentDate           |                           0 |                           0 |          0   |
| 12 | ClosedDate             |                           0 |                           0 |          0   |
| 13 | ReportDate             |                           0 |                           0 |          0   |
| 14 | LegacyKey              |                           0 |                           0 |          0   |
| 15 | LegacyKeyName          |                           0 |                           0 |          0   |
| 16 | SourceCode             |                           1 |                           1 |          0   |
| 17 | LicenseNumber          |                        5499 |                        5494 |          0.1 |
| 18 | LastUpdateDate         |                           1 |                           1 |          0   |