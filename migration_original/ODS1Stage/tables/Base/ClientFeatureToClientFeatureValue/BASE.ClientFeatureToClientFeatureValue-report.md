# Base.ClientFeatureToClientFeatureValue Report

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
- SQL Server: 5451
- Snowflake: 5838
- Rows Margin (%): 7.099614749587231

### 2.3 Nulls per Column
|    | Column_Name                         |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:------------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ClientFeatureToClientFeatureValueID |                       0 |                       0 |            0 |
|  1 | ClientFeatureID                     |                       0 |                       0 |            0 |
|  2 | ClientFeatureValueID                |                       0 |                       0 |            0 |
|  3 | SourceCode                          |                       0 |                       0 |            0 |
|  4 | LastUpdateDate                      |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name                         |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:------------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ClientFeatureToClientFeatureValueID |                        5451 |                        5838 |          7.1 |
|  1 | ClientFeatureID                     |                          48 |                          19 |         60.4 |
|  2 | ClientFeatureValueID                |                          47 |                          20 |         57.4 |
|  3 | SourceCode                          |                           3 |                           1 |         66.7 |
|  4 | LastUpdateDate                      |                         129 |                           1 |         99.2 |