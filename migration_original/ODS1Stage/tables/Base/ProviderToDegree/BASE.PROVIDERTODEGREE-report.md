# BASE.PROVIDERTODEGREE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/8).
Percentage of Different Columns: 0.00% (0/8).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 8
- Snowflake: 8
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 4630703
- Snowflake: 4680728
- Rows Margin (%): 1.0802895370314183

### 2.3 Nulls per Column
|    | Column_Name        |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToDegreeID |                       0 |                       0 |          0   |
|  1 | ProviderID         |                       0 |                       0 |          0   |
|  2 | DegreeID           |                       0 |                       0 |          0   |
|  3 | DegreePriority     |                 4279760 |                 4329486 |          1.2 |
|  4 | LegacyKey          |                 4630703 |                 4680728 |          1.1 |
|  5 | LegacyKeyName      |                 4630703 |                 4680728 |          1.1 |
|  6 | SourceCode         |                       0 |                       0 |          0   |
|  7 | LastUpdateDate     |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name        |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToDegreeID |                     4630703 |                     4680728 |          1.1 |
|  1 | ProviderID         |                     4305997 |                     4356625 |          1.2 |
|  2 | DegreeID           |                         683 |                         675 |          1.2 |
|  3 | DegreePriority     |                         564 |                         558 |          1.1 |
|  4 | LegacyKey          |                           0 |                           0 |          0   |
|  5 | LegacyKeyName      |                           0 |                           0 |          0   |
|  6 | SourceCode         |                         210 |                         211 |          0.5 |
|  7 | LastUpdateDate     |                      224563 |                      225655 |          0.5 |