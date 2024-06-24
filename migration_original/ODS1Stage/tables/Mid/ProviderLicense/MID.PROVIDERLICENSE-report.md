# MID.PROVIDERLICENSE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/7).
Percentage of Different Columns: 0.00% (0/7).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 7
- Snowflake: 7
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 6095996
- Snowflake: 6610104
- Rows Margin (%): 8.433535717543121

### 2.3 Nulls per Column
|    | Column_Name            |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderID             |                       0 |                       0 |          0   |
|  1 | LicenseNumber          |                       0 |                       0 |          0   |
|  2 | LicenseEffectiveDate   |                 6095996 |                 6610104 |          8.4 |
|  3 | LicenseTerminationDate |                 2431056 |                 2533898 |          4.2 |
|  4 | State                  |                       0 |                       0 |          0   |
|  5 | StateName              |                       0 |                       0 |          0   |
|  6 | LicenseType            |                 2239703 |                 2334881 |          4.2 |

### 2.4 Distincts per Column
|    | Column_Name            |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderID             |                     4887997 |                     5054083 |          3.4 |
|  1 | LicenseNumber          |                     4256994 |                     4334484 |          1.8 |
|  2 | LicenseEffectiveDate   |                           0 |                           0 |          0   |
|  3 | LicenseTerminationDate |                        1669 |                        1720 |          3.1 |
|  4 | State                  |                          59 |                          59 |          0   |
|  5 | StateName              |                          59 |                          59 |          0   |
|  6 | LicenseType            |                          95 |                          96 |          1.1 |