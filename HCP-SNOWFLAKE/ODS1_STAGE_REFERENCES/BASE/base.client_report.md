# BASE.CLIENT Report

## 1. Sample Validation

Percentage of Identical Columns: 42.86% (3/7).
Percentage of Different Columns: 57.14% (4/7).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name    | Match ID   | SQL Server Value                     | Snowflake Value                      |
|---:|:---------------|:-----------|:-------------------------------------|:-------------------------------------|
|  0 | CLIENTID       | ELS09      | 875901a4-00a1-ed11-8381-1205831baf5d | a52d7bc2-f342-438e-a8ee-4d1becfb936b |
|  1 | LEGACYKEY      | THSSTA     | 60734                                | None                                 |
|  2 | SOURCECODE     | ELS09      | HGREFERENCE                          | ELS09                                |
|  3 | LASTUPDATEDATE | ELS09      | 2023-10-11 18:07:36.023              | 2023-10-11 18:07:36.023 -0700        |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 7
- Snowflake: 7
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 698
- Snowflake: 400
- Rows Margin (%): 42.693409742120345

### 2.3 Nulls per Column
|    | Column_Name    |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:---------------|------------------------:|------------------------:|-------------:|
|  0 | ClientID       |                       0 |                       0 |          0   |
|  1 | ClientCode     |                       0 |                       0 |          0   |
|  2 | ClientName     |                       0 |                       0 |          0   |
|  3 | LegacyKey      |                     493 |                     400 |         18.9 |
|  4 | LegacyKeyName  |                     698 |                     400 |         42.7 |
|  5 | SourceCode     |                       2 |                       0 |        100   |
|  6 | LastUpdateDate |                       1 |                       0 |        100   |

### 2.4 Distincts per Column
|    | Column_Name    |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:---------------|----------------------------:|----------------------------:|-------------:|
|  0 | ClientID       |                         698 |                         400 |         42.7 |
|  1 | ClientCode     |                         696 |                         400 |         42.5 |
|  2 | ClientName     |                         640 |                         378 |         40.9 |
|  3 | LegacyKey      |                         205 |                           0 |        100   |
|  4 | LegacyKeyName  |                           0 |                           0 |          0   |
|  5 | SourceCode     |                          13 |                         400 |       2976.9 |
|  6 | LastUpdateDate |                         156 |                          57 |         63.5 |