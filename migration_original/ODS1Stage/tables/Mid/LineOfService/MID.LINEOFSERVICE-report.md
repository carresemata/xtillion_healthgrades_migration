# MID.LINEOFSERVICE Report

## 1. Sample Validation

Percentage of Identical Columns: 100.00% (6/6).
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
- SQL Server: 267
- Snowflake: 267
- Rows Margin (%): 0.0

### 2.3 Nulls per Column
|    | Column_Name              |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------------|------------------------:|------------------------:|-------------:|
|  0 | LineOfServiceID          |                       0 |                       0 |            0 |
|  1 | LineOfServiceCode        |                       0 |                       0 |            0 |
|  2 | LineOfServiceTypeCode    |                       0 |                       0 |            0 |
|  3 | LineOfServiceDescription |                       0 |                       0 |            0 |
|  4 | LegacyKey                |                       0 |                       0 |            0 |
|  5 | LegacyKeyName            |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name              |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | LineOfServiceID          |                         267 |                         267 |            0 |
|  1 | LineOfServiceCode        |                         267 |                         267 |            0 |
|  2 | LineOfServiceTypeCode    |                           1 |                           1 |            0 |
|  3 | LineOfServiceDescription |                         267 |                         267 |            0 |
|  4 | LegacyKey                |                         267 |                         267 |            0 |
|  5 | LegacyKeyName            |                         267 |                         267 |            0 |