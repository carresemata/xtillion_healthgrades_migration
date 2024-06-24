# BASE.PHONE Report

## 1. Sample Validation

Percentage of Identical Columns: 62.50% (5/8).
Percentage of Different Columns: 37.50% (3/8).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name    | Match ID       | SQL Server Value                     | Snowflake Value                      |
|---:|:---------------|:---------------|:-------------------------------------|:-------------------------------------|
|  0 | PHONEID        | (701) 477-5656 | 31303728-2029-3734-372d-353635360000 | 86cc302a-9272-4f71-a5ad-7452fdc4039a |
|  1 | SOURCECODE     | (701) 477-5656 | None                                 | HMS                                  |
|  2 | LASTUPDATEDATE | (701) 477-5656 | 2015-05-29 12:43:25.103              | 2022-12-10 00:10:15.753              |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 8
- Snowflake: 8
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 6641862
- Snowflake: 2946804
- Rows Margin (%): 55.632863194086234

### 2.3 Nulls per Column
|    | Column_Name    |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:---------------|------------------------:|------------------------:|-------------:|
|  0 | PhoneID        |                       0 |                       0 |          0   |
|  1 | AreaCode       |                 6641862 |                 2946804 |         55.6 |
|  2 | PhoneNumber    |                       1 |                       1 |          0   |
|  3 | Extension      |                 6641862 |                 2946804 |         55.6 |
|  4 | LegacyKey      |                 6641862 |                 2946804 |         55.6 |
|  5 | LegacyKeyName  |                 6641862 |                 2946804 |         55.6 |
|  6 | SourceCode     |                 4839082 |                       0 |        100   |
|  7 | LastUpdateDate |                       7 |                       0 |        100   |

### 2.4 Distincts per Column
|    | Column_Name    |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:---------------|----------------------------:|----------------------------:|-------------:|
|  0 | PhoneID        |                     6641862 |                     2946804 |         55.6 |
|  1 | AreaCode       |                           0 |                           0 |          0   |
|  2 | PhoneNumber    |                     6549155 |                     2946803 |         55   |
|  3 | Extension      |                           0 |                           0 |          0   |
|  4 | LegacyKey      |                           0 |                           0 |          0   |
|  5 | LegacyKeyName  |                           0 |                           0 |          0   |
|  6 | SourceCode     |                         122 |                         221 |         81.1 |
|  7 | LastUpdateDate |                       86482 |                       88881 |          2.8 |