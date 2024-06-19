# Base.ProviderToProviderType Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/9).
Percentage of Different Columns: 0.00% (0/9).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 9
- Snowflake: 9
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 6527422
- Snowflake: 6596810
- Rows Margin (%): 1.0630230434005952

### 2.3 Nulls per Column
|    | Column_Name                |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:---------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToProviderTypeID   |                       0 |                       0 |            0 |
|  1 | ProviderID                 |                       0 |                       0 |            0 |
|  2 | ProviderTypeID             |                       0 |                       0 |            0 |
|  3 | SourceCode                 |                       0 |                       0 |            0 |
|  4 | ProviderTypeRank           |                       0 |                       0 |            0 |
|  5 | ProviderTypeRankCalculated |                       0 |                       0 |            0 |
|  6 | InsertedOn                 |                       0 |                       0 |            0 |
|  7 | InsertedBy                 |                       0 |                       0 |            0 |
|  8 | LastUpdateDate             |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name                |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:---------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToProviderTypeID   |                     6527422 |                     6596810 |          1.1 |
|  1 | ProviderID                 |                     6452850 |                     6522348 |          1.1 |
|  2 | ProviderTypeID             |                           4 |                           4 |          0   |
|  3 | SourceCode                 |                           1 |                         215 |      21400   |
|  4 | ProviderTypeRank           |                           3 |                           3 |          0   |
|  5 | ProviderTypeRankCalculated |                           1 |                           1 |          0   |
|  6 | InsertedOn                 |                          11 |                           1 |         90.9 |
|  7 | InsertedBy                 |                           2 |                           1 |         50   |
|  8 | LastUpdateDate             |                          11 |                         151 |       1272.7 |