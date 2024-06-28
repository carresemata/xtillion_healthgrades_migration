# BASE.CLIENTPRODUCTTOENTITY Report

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
- SQL Server: 628297
- Snowflake: 168822
- Rows Margin (%): 73.13022344528144

### 2.3 Nulls per Column
|    | Column_Name             |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:------------------------|------------------------:|------------------------:|-------------:|
|  0 | ClientProductToEntityID |                       0 |                       0 |            0 |
|  1 | ClientToProductID       |                       0 |                       0 |            0 |
|  2 | EntityTypeID            |                       0 |                       0 |            0 |
|  3 | EntityID                |                       0 |                       0 |            0 |
|  4 | IsEntityEmployed        |                  263626 |                       0 |          100 |
|  5 | SourceCode              |                     514 |                       0 |          100 |
|  6 | LastUpdateDate          |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name             |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ClientProductToEntityID |                      628297 |                      168822 |         73.1 |
|  1 | ClientToProductID       |                         581 |                         476 |         18.1 |
|  2 | EntityTypeID            |                           5 |                           5 |          0   |
|  3 | EntityID                |                      578190 |                      168335 |         70.9 |
|  4 | IsEntityEmployed        |                           2 |                           1 |         50   |
|  5 | SourceCode              |                         185 |                         407 |        120   |
|  6 | LastUpdateDate          |                        3605 |                        5043 |         39.9 |