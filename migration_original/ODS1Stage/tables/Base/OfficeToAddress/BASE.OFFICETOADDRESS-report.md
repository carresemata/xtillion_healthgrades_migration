# BASE.OFFICETOADDRESS Report

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
- SQL Server: 15704512
- Snowflake: 3688859
- Rows Margin (%): 76.51083331974912

### 2.3 Nulls per Column
|    | Column_Name       |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:------------------|------------------------:|------------------------:|-------------:|
|  0 | OfficeToAddressID |                       0 |                       0 |          0   |
|  1 | AddressTypeID     |                   75850 |                       0 |        100   |
|  2 | OfficeID          |                       0 |                       0 |          0   |
|  3 | AddressID         |                       0 |                       1 |        inf   |
|  4 | LegacyKey         |                15704512 |                 3688859 |         76.5 |
|  5 | LegacyKeyName     |                15704512 |                 3688859 |         76.5 |
|  6 | SourceCode        |                       0 |                       0 |          0   |
|  7 | IsDerived         |                       0 |                       0 |          0   |
|  8 | LastUpdateDate    |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name       |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:------------------|----------------------------:|----------------------------:|-------------:|
|  0 | OfficeToAddressID |                    15704512 |                     3688859 |         76.5 |
|  1 | AddressTypeID     |                           1 |                           1 |          0   |
|  2 | OfficeID          |                    15699370 |                     3006675 |         80.8 |
|  3 | AddressID         |                     4100855 |                     1587811 |         61.3 |
|  4 | LegacyKey         |                           0 |                           0 |          0   |
|  5 | LegacyKeyName     |                           0 |                           0 |          0   |
|  6 | SourceCode        |                         163 |                         216 |         32.5 |
|  7 | IsDerived         |                           1 |                           1 |          0   |
|  8 | LastUpdateDate    |                        4313 |                       90032 |       1987.5 |