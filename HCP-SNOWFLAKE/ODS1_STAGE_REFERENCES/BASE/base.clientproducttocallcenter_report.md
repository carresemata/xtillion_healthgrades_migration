# Base.ClientProductToCallCenter Report

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
- SQL Server: 174
- Snowflake: 157
- Rows Margin (%): 9.770114942528735

### 2.3 Nulls per Column
|    | Column_Name                 |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:----------------------------|------------------------:|------------------------:|-------------:|
|  0 | ClientProductToCallCenterID |                       0 |                       0 |            0 |
|  1 | ClientToProductID           |                       0 |                       0 |            0 |
|  2 | CallCenterID                |                       0 |                       0 |            0 |
|  3 | ActiveFlag                  |                       0 |                       0 |            0 |
|  4 | SourceCode                  |                       0 |                       0 |            0 |
|  5 | LastUpdateDate              |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name                 |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:----------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ClientProductToCallCenterID |                         174 |                         157 |          9.8 |
|  1 | ClientToProductID           |                         173 |                         157 |          9.2 |
|  2 | CallCenterID                |                          34 |                          34 |          0   |
|  3 | ActiveFlag                  |                           2 |                           1 |         50   |
|  4 | SourceCode                  |                           3 |                         111 |       3600   |
|  5 | LastUpdateDate              |                         123 |                          40 |         67.5 |