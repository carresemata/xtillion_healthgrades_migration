# BASE.IMAGE Report

## 1. Sample Validation

Percentage of Identical Columns: 62.50% (5/8).
Percentage of Different Columns: 37.50% (3/8).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name    | Match ID                                  | SQL Server Value                     | Snowflake Value                      |
|---:|:---------------|:------------------------------------------|:-------------------------------------|:-------------------------------------|
|  0 | IMAGEID        | /img/facility/logo/175EEC_PDC_w180h65.png | 49030e4c-2569-a776-55e6-04dd592bc9d2 | 963138af-e3a5-47c1-b8bc-c8edbee51528 |
|  1 | SOURCECODE     | /img/facility/logo/175EEC_PDC_w180h65.png | None                                 | RSHUMC                               |
|  2 | LASTUPDATEDATE | /img/facility/logo/175EEC_PDC_w180h65.png | 2022-05-22 05:22:08.910              | 2022-08-02 20:59:09.717              |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 8
- Snowflake: 8
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 672
- Snowflake: 372
- Rows Margin (%): 44.642857142857146

### 2.3 Nulls per Column
|    | Column_Name    |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:---------------|------------------------:|------------------------:|-------------:|
|  0 | ImageID        |                       0 |                       0 |          0   |
|  1 | ImageFilePath  |                       0 |                       0 |          0   |
|  2 | Image          |                     672 |                     372 |         44.6 |
|  3 | ImageText      |                     672 |                     372 |         44.6 |
|  4 | LegacyKey      |                     672 |                     372 |         44.6 |
|  5 | LegacyKeyName  |                     672 |                     372 |         44.6 |
|  6 | SourceCode     |                     672 |                       0 |        100   |
|  7 | LastUpdateDate |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name    |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:---------------|----------------------------:|----------------------------:|-------------:|
|  0 | ImageID        |                         672 |                         372 |         44.6 |
|  1 | ImageFilePath  |                         672 |                         350 |         47.9 |
|  2 | Image          |                           0 |                           0 |          0   |
|  3 | ImageText      |                           0 |                           0 |          0   |
|  4 | LegacyKey      |                           0 |                           0 |          0   |
|  5 | LegacyKeyName  |                           0 |                           0 |          0   |
|  6 | SourceCode     |                           0 |                          39 |        inf   |
|  7 | LastUpdateDate |                           3 |                          61 |       1933.3 |