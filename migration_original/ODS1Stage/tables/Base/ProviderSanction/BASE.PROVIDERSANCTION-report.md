# BASE.PROVIDERSANCTION Report

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
- SQL Server: 31572
- Snowflake: 31637
- Rows Margin (%): 0.20587862663119222

### 2.3 Nulls per Column
|    | Column_Name               |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderSanctionID        |                       0 |                       0 |          0   |
|  1 | ProviderID                |                       0 |                       0 |          0   |
|  2 | SanctionLicense           |                   31572 |                   31637 |          0.2 |
|  3 | SanctionResidenceState    |                   31572 |                   31637 |          0.2 |
|  4 | SanctionTypeID            |                       0 |                       0 |          0   |
|  5 | SanctionCategoryID        |                       0 |                       0 |          0   |
|  6 | SanctionActionID          |                       0 |                       0 |          0   |
|  7 | SanctionDescription       |                   31572 |                   31637 |          0.2 |
|  8 | SanctionDate              |                       0 |                       0 |          0   |
|  9 | SanctionReinstatementDate |                   31572 |                   31637 |          0.2 |
| 10 | LegacyKey                 |                   31572 |                   31637 |          0.2 |
| 11 | LegacyKeyName             |                   31572 |                   31637 |          0.2 |
| 12 | SourceCode                |                       0 |                       0 |          0   |
| 13 | LastUpdateDate            |                       0 |                       0 |          0   |
| 14 | StateReportingAgencyID    |                       0 |                       0 |          0   |
| 15 | SanctionAccuracyDate      |                   31572 |                   31637 |          0.2 |

### 2.4 Distincts per Column
|    | Column_Name               |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderSanctionID        |                       31572 |                       31637 |          0.2 |
|  1 | ProviderID                |                       11561 |                       11589 |          0.2 |
|  2 | SanctionLicense           |                           0 |                           0 |          0   |
|  3 | SanctionResidenceState    |                           0 |                           0 |          0   |
|  4 | SanctionTypeID            |                           1 |                           1 |          0   |
|  5 | SanctionCategoryID        |                           1 |                           1 |          0   |
|  6 | SanctionActionID          |                         131 |                         131 |          0   |
|  7 | SanctionDescription       |                           0 |                           0 |          0   |
|  8 | SanctionDate              |                        2577 |                        2553 |          0.9 |
|  9 | SanctionReinstatementDate |                           0 |                           0 |          0   |
| 10 | LegacyKey                 |                           0 |                           0 |          0   |
| 11 | LegacyKeyName             |                           0 |                           0 |          0   |
| 12 | SourceCode                |                           1 |                           1 |          0   |
| 13 | LastUpdateDate            |                           2 |                           2 |          0   |
| 14 | StateReportingAgencyID    |                          70 |                          70 |          0   |
| 15 | SanctionAccuracyDate      |                           0 |                           0 |          0   |