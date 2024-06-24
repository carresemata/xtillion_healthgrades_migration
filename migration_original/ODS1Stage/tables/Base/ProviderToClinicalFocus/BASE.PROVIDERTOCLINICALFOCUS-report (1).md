# BASE.PROVIDERTOCLINICALFOCUS Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/14).
Percentage of Different Columns: 0.00% (0/14).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 14
- Snowflake: 14
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 395828
- Snowflake: 410962
- Rows Margin (%): 3.823377830774983

### 2.3 Nulls per Column
|    | Column_Name                        |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToClinicalFocusID          |                       0 |                       0 |            0 |
|  1 | ProviderID                         |                       0 |                       0 |            0 |
|  2 | ClinicalFocusID                    |                       0 |                       0 |            0 |
|  3 | InsertedOn                         |                       0 |                       0 |            0 |
|  4 | InsertedBy                         |                       0 |                       0 |            0 |
|  5 | ClinicalFocusDCPCount              |                       0 |                       0 |            0 |
|  6 | ClinicalFocusMinBucketsCalculated  |                       0 |                       0 |            0 |
|  7 | ProviderDCPCount                   |                       0 |                       0 |            0 |
|  8 | AverageBPercentile                 |                       0 |                       0 |            0 |
|  9 | ProviderDCPFillPercent             |                       0 |                       0 |            0 |
| 10 | IsProviderDCPCountOverLowThreshold |                       0 |                       0 |            0 |
| 11 | ClinicalFocusScore                 |                       0 |                       0 |            0 |
| 12 | ProviderClinicalFocusRank          |                       0 |                       0 |            0 |
| 13 | SourceCode                         |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name                        |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToClinicalFocusID          |                      395828 |                      410962 |          3.8 |
|  1 | ProviderID                         |                      167961 |                      174292 |          3.8 |
|  2 | ClinicalFocusID                    |                          94 |                          94 |          0   |
|  3 | InsertedOn                         |                           7 |                           7 |          0   |
|  4 | InsertedBy                         |                           1 |                           1 |          0   |
|  5 | ClinicalFocusDCPCount              |                          40 |                          40 |          0   |
|  6 | ClinicalFocusMinBucketsCalculated  |                          15 |                          15 |          0   |
|  7 | ProviderDCPCount                   |                          73 |                          73 |          0   |
|  8 | AverageBPercentile                 |                       18573 |                       18573 |          0   |
|  9 | ProviderDCPFillPercent             |                         316 |                         316 |          0   |
| 10 | IsProviderDCPCountOverLowThreshold |                           1 |                           1 |          0   |
| 11 | ClinicalFocusScore                 |                        6642 |                        6642 |          0   |
| 12 | ProviderClinicalFocusRank          |                          10 |                          10 |          0   |
| 13 | SourceCode                         |                           1 |                           1 |          0   |