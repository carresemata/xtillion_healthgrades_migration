# BASE.CLIENT Report

## 1. Sample Validation

Percentage of Identical Columns: 57.14% (4/7).
Percentage of Different Columns: 42.86% (3/7).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name    | Match ID   | SQL Server Value                     | Snowflake Value                      |
|---:|:---------------|:-----------|:-------------------------------------|:-------------------------------------|
|  0 | CLIENTID       | EHGSELF    | 53474845-4c45-0046-0000-000000000000 | d7ce7acc-d140-439f-b8ef-68bdf3b9551b |
|  1 | SOURCECODE     | EHGSELF    | HG Reference                         | EHGSELF                              |
|  2 | LASTUPDATEDATE | EHGSELF    | 2023-10-11 18:07:36.023              | 2023-10-11 18:07:36.023 -0700        |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 7
- Snowflake: 7
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 696
- Snowflake: 476
- Rows Margin (%): 31.60919540229885

### 2.3 Nulls per Column
|    | Column_Name    |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:---------------|------------------------:|------------------------:|-------------:|
|  0 | ClientID       |                       0 |                       0 |          0   |
|  1 | ClientCode     |                       0 |                       0 |          0   |
|  2 | ClientName     |                       0 |                       0 |          0   |
|  3 | LegacyKey      |                     491 |                     476 |          3.1 |
|  4 | LegacyKeyName  |                     696 |                     476 |         31.6 |
|  5 | SourceCode     |                       2 |                       0 |        100   |
|  6 | LastUpdateDate |                       1 |                       0 |        100   |

### 2.4 Distincts per Column
|    | Column_Name    |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:---------------|----------------------------:|----------------------------:|-------------:|
|  0 | ClientID       |                         696 |                         476 |         31.6 |
|  1 | ClientCode     |                         694 |                         400 |         42.4 |
|  2 | ClientName     |                         638 |                         378 |         40.8 |
|  3 | LegacyKey      |                         205 |                           0 |        100   |
|  4 | LegacyKeyName  |                           0 |                           0 |          0   |
|  5 | SourceCode     |                          13 |                         400 |       2976.9 |
|  6 | LastUpdateDate |                         150 |                          58 |         61.3 |