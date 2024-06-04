# BASE.CITYSTATEPOSTALCODE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/14).
Percentage of Different Columns: 0.00% (0/14).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 14
- Snowflake: 14
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 90298
- Snowflake: 32074
- Rows Margin (%): 64.47983344038629

### 2.3 Nulls per Column
|    | Column_Name           |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:----------------------|------------------------:|------------------------:|-------------:|
|  0 | CityStatePostalCodeID |                       0 |                       0 |          0   |
|  1 | City                  |                       0 |                       0 |          0   |
|  2 | State                 |                       0 |                       0 |          0   |
|  3 | PostalCode            |                       0 |                       0 |          0   |
|  4 | URLCity               |                   28249 |                   32074 |         13.5 |
|  5 | County                |                   43936 |                   32074 |         27   |
|  6 | PopulationClass       |                   35553 |                   32074 |          9.8 |
|  7 | CentroidLatitude      |                   32200 |                   31917 |          0.9 |
|  8 | CentroidLongitude     |                   32202 |                   31917 |          0.9 |
|  9 | IsCityAlias           |                   33236 |                   32074 |          3.5 |
| 10 | CityType              |                   33236 |                   32074 |          3.5 |
| 11 | NationID              |                   27911 |                   31914 |         14.3 |
| 12 | LastUpdateDate        |                   15389 |                       0 |        100   |
| 13 | IsDerivedData         |                   31950 |                   32074 |          0.4 |

### 2.4 Distincts per Column
|    | Column_Name           |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | CityStatePostalCodeID |                       90298 |                       32074 |         64.5 |
|  1 | City                  |                       33209 |                       15074 |         54.6 |
|  2 | State                 |                        1149 |                          57 |         95   |
|  3 | PostalCode            |                       44660 |                       27104 |         39.3 |
|  4 | URLCity               |                       24960 |                           0 |        100   |
|  5 | County                |                        1948 |                           0 |        100   |
|  6 | PopulationClass       |                           3 |                           0 |        100   |
|  7 | CentroidLatitude      |                       45943 |                         156 |         99.7 |
|  8 | CentroidLongitude     |                       46096 |                         156 |         99.7 |
|  9 | IsCityAlias           |                           2 |                           0 |        100   |
| 10 | CityType              |                           8 |                           0 |        100   |
| 11 | NationID              |                           1 |                           1 |          0   |
| 12 | LastUpdateDate        |                        1262 |                           2 |         99.8 |
| 13 | IsDerivedData         |                           2 |                           0 |        100   |