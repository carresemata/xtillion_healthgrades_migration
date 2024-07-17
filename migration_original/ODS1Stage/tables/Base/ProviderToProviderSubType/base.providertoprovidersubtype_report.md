# Base.ProviderToProviderSubtype Report

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
- SQL Server: 6452848
- Snowflake: 6539058
- Rows Margin (%): 1.3359992363062017

### 2.3 Nulls per Column
|    | Column_Name                   |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToProviderSubTypeID   |                       0 |                       0 |            0 |
|  1 | ProviderID                    |                       0 |                       0 |            0 |
|  2 | ProviderSubTypeID             |                       0 |                       0 |            0 |
|  3 | SourceCode                    |                       0 |                       0 |            0 |
|  4 | ProviderSubTypeRank           |                       0 |                       0 |            0 |
|  5 | ProviderSubTypeRankCalculated |                       0 |                       0 |            0 |
|  6 | InsertedOn                    |                       0 |                       0 |            0 |
|  7 | InsertedBy                    |                       0 |                       0 |            0 |
|  8 | LastUpdateDate                |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name                   |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToProviderSubTypeID   |                     6452848 |                     6539058 |          1.3 |
|  1 | ProviderID                    |                     6452848 |                     6522348 |          1.1 |
|  2 | ProviderSubTypeID             |                           7 |                           4 |         42.9 |
|  3 | SourceCode                    |                           2 |                           1 |         50   |
|  4 | ProviderSubTypeRank           |                           1 |                           1 |          0   |
|  5 | ProviderSubTypeRankCalculated |                           1 |                           1 |          0   |
|  6 | InsertedOn                    |                          10 |                           1 |         90   |
|  7 | InsertedBy                    |                           2 |                           1 |         50   |
|  8 | LastUpdateDate                |                          30 |                           2 |         93.3 |