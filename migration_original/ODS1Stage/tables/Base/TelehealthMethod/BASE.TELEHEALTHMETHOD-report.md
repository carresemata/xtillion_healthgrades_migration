# Base.TelehealthMethod Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/6).
Percentage of Different Columns: 0.00% (0/6).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 6
- Snowflake: 6
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 11545
- Snowflake: 7732
- Rows Margin (%): 33.02728453876137

### 2.3 Nulls per Column
|    | Column_Name            |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------|------------------------:|------------------------:|-------------:|
|  0 | TelehealthMethodId     |                       0 |                       0 |          0   |
|  1 | TelehealthMethodTypeId |                       0 |                       0 |          0   |
|  2 | TelehealthMethod       |                       0 |                       0 |          0   |
|  3 | ServiceName            |                    9378 |                    7723 |         17.6 |
|  4 | SourceCode             |                       0 |                       0 |          0   |
|  5 | LastUpdatedDate        |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name            |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | TelehealthMethodId     |                       11545 |                        7732 |         33   |
|  1 | TelehealthMethodTypeId |                           3 |                           3 |          0   |
|  2 | TelehealthMethod       |                       11509 |                        5112 |         55.6 |
|  3 | ServiceName            |                         656 |                           9 |         98.6 |
|  4 | SourceCode             |                          12 |                         200 |       1566.7 |
|  5 | LastUpdatedDate        |                        4735 |                        1571 |         66.8 |