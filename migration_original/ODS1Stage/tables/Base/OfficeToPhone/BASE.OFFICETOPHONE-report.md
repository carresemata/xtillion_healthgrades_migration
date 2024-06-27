# BASE.OFFICETOPHONE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/11).
Percentage of Different Columns: 0.00% (0/11).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 11
- Snowflake: 11
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 18974933
- Snowflake: 4610336
- Rows Margin (%): 75.70301829260741

### 2.3 Nulls per Column
|    | Column_Name     |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:----------------|------------------------:|------------------------:|-------------:|
|  0 | OfficeToPhoneID |                       0 |                       0 |          0   |
|  1 | PhoneTypeID     |                       0 |                       0 |          0   |
|  2 | PhoneID         |                       0 |                       0 |          0   |
|  3 | OfficeID        |                       0 |                       0 |          0   |
|  4 | LegacyKey       |                18974933 |                 4610336 |         75.7 |
|  5 | LegacyKeyName   |                18974933 |                 4610336 |         75.7 |
|  6 | SourceCode      |                       0 |                       0 |          0   |
|  7 | IsDerived       |                       0 |                       0 |          0   |
|  8 | LastUpdateDate  |                       0 |                       0 |          0   |
|  9 | PhoneRank       |                       0 |                       0 |          0   |
| 10 | IsSearchable    |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name     |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:----------------|----------------------------:|----------------------------:|-------------:|
|  0 | OfficeToPhoneID |                    18974933 |                     4610336 |         75.7 |
|  1 | PhoneTypeID     |                           2 |                           2 |          0   |
|  2 | PhoneID         |                     3632915 |                     3298857 |          9.2 |
|  3 | OfficeID        |                    13485748 |                     2995724 |         77.8 |
|  4 | LegacyKey       |                           0 |                           0 |          0   |
|  5 | LegacyKeyName   |                           0 |                           0 |          0   |
|  6 | SourceCode      |                         148 |                         212 |         43.2 |
|  7 | IsDerived       |                           1 |                           1 |          0   |
|  8 | LastUpdateDate  |                      133612 |                      143947 |          7.7 |
|  9 | PhoneRank       |                           1 |                           1 |          0   |
| 10 | IsSearchable    |                           1 |                           1 |          0   |