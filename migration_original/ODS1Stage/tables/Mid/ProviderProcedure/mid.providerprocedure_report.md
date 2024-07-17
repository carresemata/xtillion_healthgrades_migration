# MID.PROVIDERPROCEDURE Report

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
- SQL Server: 23383638
- Snowflake: 29304517
- Rows Margin (%): 25.320606656671647

### 2.3 Nulls per Column
|    | Column_Name               |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToProcedureID     |                       0 |                       0 |          0   |
|  1 | ProviderID                |                       0 |                       0 |          0   |
|  2 | ProcedureCode             |                       0 |                       0 |          0   |
|  3 | ProcedureDescription      |                       0 |                       0 |          0   |
|  4 | ProcedureGroupDescription |                23372022 |                29289793 |         25.3 |
|  5 | LegacyKey                 |                23383638 |                29304517 |         25.3 |

### 2.4 Distincts per Column
|    | Column_Name               |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToProcedureID     |                    23383638 |                    25924553 |         10.9 |
|  1 | ProviderID                |                     1030927 |                     1066474 |          3.4 |
|  2 | ProcedureCode             |                        4300 |                        4300 |          0   |
|  3 | ProcedureDescription      |                        4300 |                        4300 |          0   |
|  4 | ProcedureGroupDescription |                           1 |                           1 |          0   |
|  5 | LegacyKey                 |                           0 |                           0 |          0   |