# BASE.PROVIDERURL Report

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
- SQL Server: 6452910
- Snowflake: 6625923
- Rows Margin (%): 2.681162452288967

### 2.3 Nulls per Column
|    | Column_Name    |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:---------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderURLID  |                       0 |                       0 |            0 |
|  1 | ProviderID     |                       0 |                       0 |            0 |
|  2 | URL            |                       0 |                       0 |            0 |
|  3 | SourceCode     |                       0 |                       0 |            0 |
|  4 | LastUpdateDate |                       0 |                       0 |            0 |
|  5 | ProviderCode   |                 6452910 |                       0 |          100 |

### 2.4 Distincts per Column
|    | Column_Name    |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:---------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderURLID  |                     6452910 |                     6625923 |          2.7 |
|  1 | ProviderID     |                     6452910 |                     6625923 |          2.7 |
|  2 | URL            |                     6452910 |                     6522350 |          1.1 |
|  3 | SourceCode     |                          34 |                         214 |        529.4 |
|  4 | LastUpdateDate |                       33390 |                         151 |         99.5 |
|  5 | ProviderCode   |                           0 |                     6522348 |        inf   |