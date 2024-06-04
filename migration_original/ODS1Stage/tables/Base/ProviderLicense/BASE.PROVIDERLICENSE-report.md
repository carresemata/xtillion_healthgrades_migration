# BASE.PROVIDERLICENSE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/11).
Percentage of Different Columns: 0.00% (0/11).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 11
- Snowflake: 11
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 6479927
- Snowflake: 6191567
- Rows Margin (%): 4.450050131737595

### 2.3 Nulls per Column
|    | Column_Name            |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderLicenseID      |                       0 |                       0 |          0   |
|  1 | ProviderID             |                       0 |                       0 |          0   |
|  2 | StateID                |                       0 |                       0 |          0   |
|  3 | LicenseNumber          |                       0 |                       0 |          0   |
|  4 | LicenseEffectiveDate   |                 6479927 |                 6191567 |          4.5 |
|  5 | LicenseTerminationDate |                 2702738 |                 2359218 |         12.7 |
|  6 | LegacyKey              |                 6479927 |                 6191567 |          4.5 |
|  7 | LegacyKeyName          |                 6479927 |                 6191567 |          4.5 |
|  8 | SourceCode             |                       0 |                       0 |          0   |
|  9 | LastUpdateDate         |                       0 |                       0 |          0   |
| 10 | LicenseType            |                 2546075 |                 2167194 |         14.9 |

### 2.4 Distincts per Column
|    | Column_Name            |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderLicenseID      |                     6479927 |                     6191567 |          4.5 |
|  1 | ProviderID             |                     4883172 |                     4950406 |          1.4 |
|  2 | StateID                |                          60 |                          59 |          1.7 |
|  3 | LicenseNumber          |                     4364003 |                     4307008 |          1.3 |
|  4 | LicenseEffectiveDate   |                           0 |                           0 |          0   |
|  5 | LicenseTerminationDate |                        1749 |                        1720 |          1.7 |
|  6 | LegacyKey              |                           0 |                           0 |          0   |
|  7 | LegacyKeyName          |                           0 |                           0 |          0   |
|  8 | SourceCode             |                          28 |                           5 |         82.1 |
|  9 | LastUpdateDate         |                       58194 |                       43016 |         26.1 |
| 10 | LicenseType            |                          95 |                          96 |          1.1 |