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
- SQL Server: 600369
- Snowflake: 349303
- Rows Margin (%): 41.81861488517895

### 2.3 Nulls per Column
|    | Column_Name             |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:------------------------|------------------------:|------------------------:|-------------:|
|  0 | ClientProductToEntityID |                       0 |                       0 |          0   |
|  1 | ClientToProductID       |                       0 |                       0 |          0   |
|  2 | EntityTypeID            |                       0 |                       0 |          0   |
|  3 | EntityID                |                       0 |                       0 |          0   |
|  4 | IsEntityEmployed        |                  263626 |                       0 |        100   |
|  5 | SourceCode              |                     512 |                  349303 |      68123.2 |
|  6 | LastUpdateDate          |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name             |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ClientProductToEntityID |                      600369 |                      349303 |         41.8 |
|  1 | ClientToProductID       |                         579 |                         476 |         17.8 |
|  2 | EntityTypeID            |                           5 |                           4 |         20   |
|  3 | EntityID                |                      550047 |                      133883 |         75.7 |
|  4 | IsEntityEmployed        |                           2 |                           1 |         50   |
|  5 | SourceCode              |                         183 |                           0 |        100   |
|  6 | LastUpdateDate          |                        3637 |                         707 |         80.6 |