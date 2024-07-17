# SHOW.SOLRTREATMENTENTRYLEVEL Report

## 1. Sample Validation

Percentage of Identical Columns: 100.00% (5/5).
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
- SQL Server: 22489
- Snowflake: 22489
- Rows Margin (%): 0.0

### 2.3 Nulls per Column
|    | Column_Name               |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------|------------------------:|------------------------:|-------------:|
|  0 | DCPCode                   |                       0 |                       0 |            0 |
|  1 | TreatmentLevelDescription |                       0 |                       0 |            0 |
|  2 | SpecialtyCode             |                       0 |                       0 |            0 |
|  3 | SpecialtyDescription      |                       0 |                       0 |            0 |
|  4 | ForMarketViewLoad         |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name               |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | DCPCode                   |                        2905 |                        2905 |            0 |
|  1 | TreatmentLevelDescription |                           7 |                           7 |            0 |
|  2 | SpecialtyCode             |                         313 |                         313 |            0 |
|  3 | SpecialtyDescription      |                         313 |                         313 |            0 |
|  4 | ForMarketViewLoad         |                           2 |                           2 |            0 |