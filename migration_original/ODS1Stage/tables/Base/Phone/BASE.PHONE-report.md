# BASE.PHONE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/8).
Percentage of Different Columns: 0.00% (0/8).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 8
- Snowflake: 8
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 6641830
- Snowflake: 3299415
- Rows Margin (%): 50.323705966578494

### 2.3 Nulls per Column
|    | Column_Name    |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:---------------|------------------------:|------------------------:|-------------:|
|  0 | PhoneID        |                       0 |                       0 |          0   |
|  1 | AreaCode       |                 6641830 |                 3299415 |         50.3 |
|  2 | PhoneNumber    |                       1 |                      14 |       1300   |
|  3 | Extension      |                 6641830 |                 3299415 |         50.3 |
|  4 | LegacyKey      |                 6641830 |                 3299415 |         50.3 |
|  5 | LegacyKeyName  |                 6641830 |                 3299415 |         50.3 |
|  6 | SourceCode     |                 4839082 |                       0 |        100   |
|  7 | LastUpdateDate |                       7 |                       0 |        100   |

### 2.4 Distincts per Column
|    | Column_Name    |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:---------------|----------------------------:|----------------------------:|-------------:|
|  0 | PhoneID        |                     6641830 |                     3299415 |         50.3 |
|  1 | AreaCode       |                           0 |                           0 |          0   |
|  2 | PhoneNumber    |                     6549123 |                     2944529 |         55   |
|  3 | Extension      |                           0 |                           0 |          0   |
|  4 | LegacyKey      |                           0 |                           0 |          0   |
|  5 | LegacyKeyName  |                           0 |                           0 |          0   |
|  6 | SourceCode     |                         122 |                         212 |         73.8 |
|  7 | LastUpdateDate |                       86473 |                      115348 |         33.4 |