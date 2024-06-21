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
- SQL Server: 12137
- Snowflake: 12761
- Rows Margin (%): 5.14130345225344

### 2.3 Nulls per Column
|    | Column_Name     |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:----------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderEmailID |                       0 |                       0 |            0 |
|  1 | ProviderID      |                       0 |                       0 |            0 |
|  2 | EmailAddress    |                       0 |                       0 |            0 |
|  3 | EmailRank       |                       0 |                       0 |            0 |
|  4 | SourceCode      |                       0 |                       0 |            0 |
|  5 | EmailTypeID     |                   12137 |                       0 |          100 |
|  6 | LastUpdateDate  |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name     |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:----------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderEmailID |                       12137 |                       12761 |          5.1 |
|  1 | ProviderID      |                       12137 |                       12761 |          5.1 |
|  2 | EmailAddress    |                       10925 |                       10930 |          0   |
|  3 | EmailRank       |                           1 |                           1 |          0   |
|  4 | SourceCode      |                          82 |                          82 |          0   |
|  5 | EmailTypeID     |                           0 |                           1 |        inf   |
|  6 | LastUpdateDate  |                          22 |                          22 |          0   |