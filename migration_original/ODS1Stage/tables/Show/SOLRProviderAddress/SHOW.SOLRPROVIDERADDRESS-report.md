# SHOW.SOLRPROVIDERADDRESS Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/18).
Percentage of Different Columns: 0.00% (0/18).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 18
- Snowflake: 18
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 7706388
- Snowflake: 7727967
- Rows Margin (%): 0.2800144503495023

### 2.3 Nulls per Column
|    | Column_Name           |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:----------------------|------------------------:|------------------------:|-------------:|
|  0 | SOLRProviderAddressID |                       0 |                       0 |          0   |
|  1 | ProviderToOfficeID    |                       0 |                       0 |          0   |
|  2 | ProviderID            |                       0 |                       0 |          0   |
|  3 | ProviderCode          |                       0 |                       0 |          0   |
|  4 | AddressLine1          |                       0 |                       0 |          0   |
|  5 | AddressLine2          |                 7706388 |                 7727967 |          0.3 |
|  6 | City                  |                       0 |                       0 |          0   |
|  7 | State                 |                       0 |                       0 |          0   |
|  8 | ZipCode               |                       0 |                       0 |          0   |
|  9 | Latitude              |                     174 |                       0 |        100   |
| 10 | Longitude             |                     174 |                       0 |        100   |
| 11 | CityState             |                       0 |                       0 |          0   |
| 12 | CityStateAlternative  |                 5066644 |                 5181517 |          2.3 |
| 13 | RefreshDate           |                       0 |                       0 |          0   |
| 14 | OfficeCode            |                       0 |                       0 |          0   |
| 15 | IsPrimaryOffice       |                 2100010 |                 2046396 |          2.6 |
| 16 | FullPhone             |                   10493 |                 1438232 |      13606.6 |
| 17 | AddressGeoPoint       |                     174 |                       0 |        100   |

### 2.4 Distincts per Column
|    | Column_Name           |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | SOLRProviderAddressID |                     7706388 |                     7727967 |          0.3 |
|  1 | ProviderToOfficeID    |                     7706388 |                     7727930 |          0.3 |
|  2 | ProviderID            |                     5606395 |                     5681540 |          1.3 |
|  3 | ProviderCode          |                     5606395 |                     5587275 |          0.3 |
|  4 | AddressLine1          |                     1427407 |                      835197 |         41.5 |
|  5 | AddressLine2          |                           0 |                           0 |          0   |
|  6 | City                  |                       15052 |                       14969 |          0.6 |
|  7 | State                 |                          56 |                          56 |          0   |
|  8 | ZipCode               |                       27216 |                       27007 |          0.8 |
|  9 | Latitude              |                      917205 |                          49 |        100   |
| 10 | Longitude             |                      980439 |                          99 |        100   |
| 11 | CityState             |                       22263 |                       22061 |          0.9 |
| 12 | CityStateAlternative  |                      421178 |                      133737 |         68.2 |
| 13 | RefreshDate           |                         958 |                           1 |         99.9 |
| 14 | OfficeCode            |                     2985322 |                     2961798 |          0.8 |
| 15 | IsPrimaryOffice       |                           1 |                           1 |          0   |
| 16 | FullPhone             |                     2049511 |                     2028350 |          1   |