# BASE.PROVIDERTODISPLAYSPECIALTY Report

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
- SQL Server: 667434
- Snowflake: 752224
- Rows Margin (%): 12.703877836610062

### 2.3 Nulls per Column
|    | Column_Name                  |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToDisplaySpecialtyID |                       0 |                       0 |            0 |
|  1 | ProviderID                   |                       0 |                       0 |            0 |
|  2 | SpecialtyID                  |                       0 |                       0 |            0 |
|  3 | InsertedOn                   |                       0 |                       0 |            0 |
|  4 | InsertedBy                   |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name                  |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToDisplaySpecialtyID |                      667434 |                      752224 |         12.7 |
|  1 | ProviderID                   |                      667434 |                      752224 |         12.7 |
|  2 | SpecialtyID                  |                          65 |                          67 |          3.1 |
|  3 | InsertedOn                   |                          12 |                           1 |         91.7 |
|  4 | InsertedBy                   |                           1 |                           1 |          0   |