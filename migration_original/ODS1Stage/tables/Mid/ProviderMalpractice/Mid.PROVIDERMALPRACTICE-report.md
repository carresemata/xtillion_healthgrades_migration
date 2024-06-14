# Mid.ProviderMalpractice Report

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
- SQL Server: 5916
- Snowflake: 5937
- Rows Margin (%): 0.35496957403651114

### 2.3 Nulls per Column
|    | Column_Name                     |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderMalpracticeID           |                       0 |                       0 |          0   |
|  1 | ProviderID                      |                       0 |                       0 |          0   |
|  2 | MalpracticeClaimTypeCode        |                       0 |                       0 |          0   |
|  3 | MalpracticeClaimTypeDescription |                       0 |                       0 |          0   |
|  4 | ClaimNumber                     |                    5916 |                    5937 |          0.4 |
|  5 | ClaimDate                       |                     442 |                     442 |          0   |
|  6 | ClaimAmount                     |                       1 |                       0 |        100   |
|  7 | Complaint                       |                    5916 |                    5937 |          0.4 |
|  8 | IncidentDate                    |                    5916 |                    5937 |          0.4 |
|  9 | ClosedDate                      |                    5916 |                    5937 |          0.4 |
| 10 | ClaimState                      |                       0 |                       0 |          0   |
| 11 | ClaimStateFull                  |                       0 |                       0 |          0   |
| 12 | LicenseNumber                   |                       0 |                       0 |          0   |
| 13 | ClaimYear                       |                    5474 |                    5495 |          0.4 |
| 14 | ReportDate                      |                    5916 |                    5937 |          0.4 |

### 2.4 Distincts per Column
|    | Column_Name                     |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderMalpracticeID           |                        5916 |                        5937 |          0.4 |
|  1 | ProviderID                      |                        5345 |                        5363 |          0.3 |
|  2 | MalpracticeClaimTypeCode        |                           1 |                           1 |          0   |
|  3 | MalpracticeClaimTypeDescription |                           1 |                           1 |          0   |
|  4 | ClaimNumber                     |                           0 |                           0 |          0   |
|  5 | ClaimDate                       |                        1131 |                        1133 |          0.2 |
|  6 | ClaimAmount                     |                         447 |                         445 |          0.4 |
|  7 | Complaint                       |                           0 |                           0 |          0   |
|  8 | IncidentDate                    |                           0 |                           0 |          0   |
|  9 | ClosedDate                      |                           0 |                           0 |          0   |
| 10 | ClaimState                      |                          15 |                          15 |          0   |
| 11 | ClaimStateFull                  |                          15 |                          15 |          0   |
| 12 | LicenseNumber                   |                        5445 |                        5464 |          0.3 |
| 13 | ClaimYear                       |                           4 |                           4 |          0   |
| 14 | ReportDate                      |                           0 |                           0 |          0   |