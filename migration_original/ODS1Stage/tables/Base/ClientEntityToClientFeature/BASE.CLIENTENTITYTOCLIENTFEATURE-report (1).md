# base.cliententitytoclientfeature Report

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
- SQL Server: 3492
- Snowflake: 49
- Rows Margin (%): 98.59679266895762

### 2.3 Nulls per Column
|    | Column_Name                         |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:------------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ClientEntityToClientFeatureID       |                       0 |                       0 |            0 |
|  1 | EntityTypeID                        |                       0 |                       0 |            0 |
|  2 | ClientFeatureID                     |                       0 |                       0 |            0 |
|  3 | ClientFeatureToClientFeatureValueID |                       0 |                       0 |            0 |
|  4 | EntityID                            |                       1 |                       0 |          100 |
|  5 | SourceCode                          |                       0 |                       0 |            0 |
|  6 | LastUpdateDate                      |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name                         |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:------------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ClientEntityToClientFeatureID       |                        3492 |                          49 |         98.6 |
|  1 | EntityTypeID                        |                           2 |                           1 |         50   |
|  2 | ClientFeatureID                     |                          35 |                          19 |         45.7 |
|  3 | ClientFeatureToClientFeatureValueID |                          67 |                          41 |         38.8 |
|  4 | EntityID                            |                         385 |                          21 |         94.5 |
|  5 | SourceCode                          |                          28 |                          20 |         28.6 |
|  6 | LastUpdateDate                      |                         116 |                          11 |         90.5 |