# BASE.PROVIDEREMAIL Report

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
- SQL Server: 11987
- Snowflake: 12138
- Rows Margin (%): 1.2596980061733545

### 2.3 Nulls per Column
|    | Column_Name     |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:----------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderEmailID |                       0 |                       0 |          0   |
|  1 | ProviderID      |                       0 |                       0 |          0   |
|  2 | EmailAddress    |                       0 |                       0 |          0   |
|  3 | EmailRank       |                       0 |                       0 |          0   |
|  4 | SourceCode      |                       0 |                       0 |          0   |
|  5 | EmailTypeID     |                   11987 |                   12138 |          1.3 |
|  6 | LastUpdateDate  |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name     |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:----------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderEmailID |                       11987 |                       12138 |          1.3 |
|  1 | ProviderID      |                       11987 |                       12138 |          1.3 |
|  2 | EmailAddress    |                       10778 |                       10930 |          1.4 |
|  3 | EmailRank       |                           1 |                           1 |          0   |
|  4 | SourceCode      |                          81 |                          82 |          1.2 |
|  5 | EmailTypeID     |                           0 |                           0 |          0   |
|  6 | LastUpdateDate  |                          22 |                          22 |          0   |