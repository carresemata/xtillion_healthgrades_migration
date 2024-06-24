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
- SQL Server: 6158664
- Snowflake: 6609988
- Rows Margin (%): 7.328277691395406

### 2.3 Nulls per Column
|    | Column_Name            |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderLicenseID      |                       0 |                       0 |          0   |
|  1 | ProviderID             |                       0 |                       0 |          0   |
|  2 | StateID                |                       0 |                       0 |          0   |
|  3 | LicenseNumber          |                       0 |                       0 |          0   |
|  4 | LicenseEffectiveDate   |                 6158664 |                 6609988 |          7.3 |
|  5 | LicenseTerminationDate |                 2480326 |                 2533898 |          2.2 |
|  6 | LegacyKey              |                 6158664 |                 6609988 |          7.3 |
|  7 | LegacyKeyName          |                 6158664 |                 6609988 |          7.3 |
|  8 | SourceCode             |                       0 |                       0 |          0   |
|  9 | LastUpdateDate         |                       0 |                       0 |          0   |
| 10 | LicenseType            |                 2288035 |                 2334765 |          2   |

### 2.4 Distincts per Column
|    | Column_Name            |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderLicenseID      |                     6158664 |                     6609988 |          7.3 |
|  1 | ProviderID             |                     4946845 |                     5054083 |          2.2 |
|  2 | StateID                |                          60 |                          59 |          1.7 |
|  3 | LicenseNumber          |                     4300905 |                     4334484 |          0.8 |
|  4 | LicenseEffectiveDate   |                           0 |                           0 |          0   |
|  5 | LicenseTerminationDate |                        1679 |                        1720 |          2.4 |
|  6 | LegacyKey              |                           0 |                           0 |          0   |
|  7 | LegacyKeyName          |                           0 |                           0 |          0   |
|  8 | SourceCode             |                           5 |                           5 |          0   |
|  9 | LastUpdateDate         |                       48890 |                       46551 |          4.8 |
| 10 | LicenseType            |                          95 |                          96 |          1.1 |