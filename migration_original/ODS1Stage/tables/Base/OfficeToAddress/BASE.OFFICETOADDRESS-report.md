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
- SQL Server: 15697401
- Snowflake: 3006559
- Rows Margin (%): 80.846772022961

### 2.3 Nulls per Column
|    | Column_Name       |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:------------------|------------------------:|------------------------:|-------------:|
|  0 | OfficeToAddressID |                       0 |                       0 |          0   |
|  1 | AddressTypeID     |                   75850 |                       0 |        100   |
|  2 | OfficeID          |                       0 |                       0 |          0   |
|  3 | AddressID         |                       0 |                       1 |        inf   |
|  4 | LegacyKey         |                15697401 |                 3006559 |         80.8 |
|  5 | LegacyKeyName     |                15697401 |                 3006559 |         80.8 |
|  6 | SourceCode        |                       0 |                       0 |          0   |
|  7 | IsDerived         |                       0 |                       0 |          0   |
|  8 | LastUpdateDate    |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name       |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:------------------|----------------------------:|----------------------------:|-------------:|
|  0 | OfficeToAddressID |                    15697401 |                     3006559 |         80.8 |
|  1 | AddressTypeID     |                           1 |                           1 |          0   |
|  2 | OfficeID          |                    15692259 |                     3006557 |         80.8 |
|  3 | AddressID         |                     4095530 |                     1473814 |         64   |
|  4 | LegacyKey         |                           0 |                           0 |          0   |
|  5 | LegacyKeyName     |                           0 |                           0 |          0   |
|  6 | SourceCode        |                         163 |                         216 |         32.5 |
|  7 | IsDerived         |                           1 |                           1 |          0   |
|  8 | LastUpdateDate    |                        4304 |                       90029 |       1991.8 |