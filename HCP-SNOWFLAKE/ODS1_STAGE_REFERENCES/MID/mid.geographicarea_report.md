# MID.GEOGRAPHICAREA Report

## 1. Sample Validation

Percentage of Identical Columns: 100.00% (4/4).
Percentage of Different Columns: 0.00% (0/4).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 4
- Snowflake: 4
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 81914
- Snowflake: 81914
- Rows Margin (%): 0.0

### 2.3 Nulls per Column
|    | Column_Name            |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------|------------------------:|------------------------:|-------------:|
|  0 | GeographicAreaID       |                       0 |                       0 |            0 |
|  1 | GeographicAreaCode     |                       0 |                       0 |            0 |
|  2 | GeographicAreaTypeCode |                       0 |                       0 |            0 |
|  3 | GeographicAreaValue    |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name            |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | GeographicAreaID       |                       81914 |                       81914 |            0 |
|  1 | GeographicAreaCode     |                       81914 |                       81914 |            0 |
|  2 | GeographicAreaTypeCode |                           3 |                           3 |            0 |
|  3 | GeographicAreaValue    |                       81914 |                       81914 |            0 |