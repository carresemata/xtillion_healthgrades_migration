# MID.PROVIDERCONDITION Report

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
- SQL Server: 74853051
- Snowflake: 93780846
- Rows Margin (%): 25.286604550026958

### 2.3 Nulls per Column
|    | Column_Name               |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToConditionID     |                       0 |                       0 |          0   |
|  1 | ProviderID                |                       0 |                       0 |          0   |
|  2 | ConditionCode             |                       0 |                       0 |          0   |
|  3 | ConditionDescription      |                       0 |                       0 |          0   |
|  4 | ConditionGroupDescription |                74853051 |                93780846 |         25.3 |
|  5 | LegacyKey                 |                72533458 |                90869675 |         25.3 |

### 2.4 Distincts per Column
|    | Column_Name               |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToConditionID     |                    74853051 |                    82977422 |         10.9 |
|  1 | ProviderID                |                     1078743 |                     1114125 |          3.3 |
|  2 | ConditionCode             |                        8909 |                        8911 |          0   |
|  3 | ConditionDescription      |                        8909 |                        8911 |          0   |
|  4 | ConditionGroupDescription |                           0 |                           0 |          0   |
|  5 | LegacyKey                 |                          95 |                          95 |          0   |