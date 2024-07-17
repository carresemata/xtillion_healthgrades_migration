# MID.PROVIDERLANGUAGE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/2).
Percentage of Different Columns: 0.00% (0/2).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 2
- Snowflake: 2
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 645230
- Snowflake: 681352
- Rows Margin (%): 5.598313779582474

### 2.3 Nulls per Column
|    | Column_Name   |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderID    |                       0 |                       0 |            0 |
|  1 | LanguageName  |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name   |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderID    |                      514241 |                      525072 |          2.1 |
|  1 | LanguageName  |                         256 |                         224 |         12.5 |