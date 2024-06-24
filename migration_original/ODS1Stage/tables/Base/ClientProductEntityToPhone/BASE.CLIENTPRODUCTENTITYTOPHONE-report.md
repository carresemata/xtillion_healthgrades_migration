# BASE.CLIENTPRODUCTENTITYTOPHONE Report

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
- SQL Server: 83755
- Snowflake: 79475
- Rows Margin (%): 5.110142678049072

### 2.3 Nulls per Column
|    | Column_Name                  |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------------|------------------------:|------------------------:|-------------:|
|  0 | ClientProductEntityToPhoneID |                       0 |                       0 |            0 |
|  1 | ClientProductToEntityID      |                       0 |                       0 |            0 |
|  2 | PhoneTypeID                  |                       0 |                       0 |            0 |
|  3 | PhoneID                      |                       0 |                       0 |            0 |
|  4 | SourceCode                   |                       0 |                       0 |            0 |
|  5 | LastUpdateDate               |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name                  |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ClientProductEntityToPhoneID |                       83755 |                       79475 |          5.1 |
|  1 | ClientProductToEntityID      |                       67358 |                       47218 |         29.9 |
|  2 | PhoneTypeID                  |                          41 |                          39 |          4.9 |
|  3 | PhoneID                      |                       34258 |                       58275 |         70.1 |
|  4 | SourceCode                   |                           2 |                         180 |       8900   |
|  5 | LastUpdateDate               |                         675 |                        2005 |        197   |