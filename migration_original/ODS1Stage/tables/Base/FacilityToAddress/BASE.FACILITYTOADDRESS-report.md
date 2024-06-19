# BASE.FACILITYTOADDRESS Report

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
- SQL Server: 178995
- Snowflake: 80840
- Rows Margin (%): 54.836727282885

### 2.3 Nulls per Column
|    | Column_Name         |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------|------------------------:|------------------------:|-------------:|
|  0 | FacilityToAddressID |                       0 |                       0 |            0 |
|  1 | FacilityID          |                       0 |                       0 |            0 |
|  2 | AddressID           |                       0 |                       0 |            0 |
|  3 | AddressTypeID       |                       0 |                       0 |            0 |
|  4 | SourceCode          |                       0 |                       0 |            0 |
|  5 | LastUpdateDate      |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name         |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------|----------------------------:|----------------------------:|-------------:|
|  0 | FacilityToAddressID |                      178995 |                       80840 |         54.8 |
|  1 | FacilityID          |                      178995 |                       80840 |         54.8 |
|  2 | AddressID           |                      146964 |                       77093 |         47.5 |
|  3 | AddressTypeID       |                           1 |                           1 |          0   |
|  4 | SourceCode          |                           4 |                           1 |         75   |
|  5 | LastUpdateDate      |                          16 |                          87 |        443.8 |