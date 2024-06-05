# BASE.CLIENT Report

## 1. Sample Validation

Percentage of Identical Columns: 42.86% (3/7).
Percentage of Different Columns: 57.14% (4/7).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name    | Match ID   | SQL Server Value                     | Snowflake Value                      |
|---:|:---------------|:-----------|:-------------------------------------|:-------------------------------------|
|  0 | CLIENTID       | ABGTON     | 54474241-4e4f-0000-0000-000000000000 | 7c1c53cc-50b8-4b61-8e73-293ab991a7ce |
|  1 | LEGACYKEY      | INOVA      | 39343                                | None                                 |
|  2 | SOURCECODE     | ABGTON     | HG Reference                         | ABGTON                               |
|  3 | LASTUPDATEDATE | ABGTON     | 2023-10-11 18:07:36.023              | 2023-10-11 18:07:36.023 -0700        |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 7
- Snowflake: 7
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 697
- Snowflake: 400
- Rows Margin (%): 42.61119081779053

### 2.3 Nulls per Column
|    | Column_Name    |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:---------------|------------------------:|------------------------:|-------------:|
|  0 | ClientID       |                       0 |                       0 |          0   |
|  1 | ClientCode     |                       0 |                       0 |          0   |
|  2 | ClientName     |                       0 |                       0 |          0   |
|  3 | LegacyKey      |                     492 |                     400 |         18.7 |
|  4 | LegacyKeyName  |                     697 |                     400 |         42.6 |
|  5 | SourceCode     |                       2 |                       0 |        100   |
|  6 | LastUpdateDate |                       1 |                       0 |        100   |

### 2.4 Distincts per Column
|    | Column_Name    |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:---------------|----------------------------:|----------------------------:|-------------:|
|  0 | ClientID       |                         697 |                         400 |         42.6 |
|  1 | ClientCode     |                         695 |                         400 |         42.4 |
|  2 | ClientName     |                         639 |                         378 |         40.8 |
|  3 | LegacyKey      |                         205 |                           0 |        100   |
|  4 | LegacyKeyName  |                           0 |                           0 |          0   |
|  5 | SourceCode     |                          13 |                         400 |       2976.9 |
|  6 | LastUpdateDate |                         155 |                          57 |         63.2 |