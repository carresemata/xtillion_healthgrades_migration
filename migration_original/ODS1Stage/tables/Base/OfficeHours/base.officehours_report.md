# BASE.OFFICEHOURS Report

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
- SQL Server: 5378927
- Snowflake: 408481
- Rows Margin (%): 92.40590177185895

### 2.3 Nulls per Column
|    | Column_Name            |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------|------------------------:|------------------------:|-------------:|
|  0 | OfficeHoursID          |                       0 |                       0 |            0 |
|  1 | OfficeID               |                       0 |                       0 |            0 |
|  2 | SourceCode             |                       0 |                       0 |            0 |
|  3 | DaysOfWeekID           |                       0 |                       0 |            0 |
|  4 | OfficeHoursOpeningTime |                 1015586 |                       0 |          100 |
|  5 | OfficeHoursClosingTime |                 1016591 |                       0 |          100 |
|  6 | OfficeIsClosed         |                       0 |                       0 |            0 |
|  7 | OfficeIsOpen24Hours    |                       0 |                       0 |            0 |
|  8 | LastUpdateDate         |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name            |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | OfficeHoursID          |                     5378927 |                      408481 |         92.4 |
|  1 | OfficeID               |                     1012197 |                       75894 |         92.5 |
|  2 | SourceCode             |                          91 |                          80 |         12.1 |
|  3 | DaysOfWeekID           |                          14 |                          14 |          0   |
|  4 | OfficeHoursOpeningTime |                          81 |                          80 |          1.2 |
|  5 | OfficeHoursClosingTime |                          86 |                          86 |          0   |
|  6 | OfficeIsClosed         |                           2 |                           2 |          0   |
|  7 | OfficeIsOpen24Hours    |                           2 |                           2 |          0   |
|  8 | LastUpdateDate         |                       32094 |                       21024 |         34.5 |