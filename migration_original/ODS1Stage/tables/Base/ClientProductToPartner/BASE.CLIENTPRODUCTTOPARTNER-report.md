# BASE.CLIENTPRODUCTTOPARTNER Report

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
- SQL Server: 189
- Snowflake: 112
- Rows Margin (%): 40.74074074074074

### 2.3 Nulls per Column
|    | Column_Name              |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------------|------------------------:|------------------------:|-------------:|
|  0 | ClientProductToPartnerID |                       0 |                       0 |            0 |
|  1 | ClientToProductID        |                       0 |                       0 |            0 |
|  2 | PartnerID                |                       8 |                       0 |          100 |
|  3 | SourceCode               |                       0 |                       0 |            0 |
|  4 | LastUpdateDate           |                       0 |                       0 |            0 |
|  5 | LastUpdateUser           |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name              |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ClientProductToPartnerID |                         189 |                         112 |         40.7 |
|  1 | ClientToProductID        |                         168 |                         112 |         33.3 |
|  2 | PartnerID                |                         102 |                          85 |         16.7 |
|  3 | SourceCode               |                           2 |                          85 |       4150   |
|  4 | LastUpdateDate           |                         104 |                           9 |         91.3 |
|  5 | LastUpdateUser           |                          16 |                           1 |         93.8 |