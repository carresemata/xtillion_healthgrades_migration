# BASE.PROVIDERTOTELEHEALTHMETHOD Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/5).
Percentage of Different Columns: 0.00% (0/5).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 5
- Snowflake: 5
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 692175
- Snowflake: 704452
- Rows Margin (%): 1.7736844006212302

### 2.3 Nulls per Column
|    | Column_Name                  |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToTelehealthMethodId |                       0 |                       0 |            0 |
|  1 | ProviderId                   |                       0 |                       0 |            0 |
|  2 | TelehealthMethodId           |                       0 |                       0 |            0 |
|  3 | SourceCode                   |                       0 |                       0 |            0 |
|  4 | LastUpdatedDate              |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name                  |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToTelehealthMethodId |                      692175 |                      704452 |          1.8 |
|  1 | ProviderId                   |                      688723 |                      704452 |          2.3 |
|  2 | TelehealthMethodId           |                        5089 |                        2972 |         41.6 |
|  3 | SourceCode                   |                         202 |                         200 |          1   |
|  4 | LastUpdatedDate              |                        1638 |                        1503 |          8.2 |