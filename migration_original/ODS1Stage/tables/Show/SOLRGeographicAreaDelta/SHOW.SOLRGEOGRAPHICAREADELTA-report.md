# SHOW.SOLRGEOGRAPHICAREADELTA Report

## 1. Sample Validation

Percentage of Identical Columns: 77.78% (7/9).
Percentage of Different Columns: 22.22% (2/9).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name               | Match ID                             | SQL Server Value                     | Snowflake Value                      |
|---:|:--------------------------|:-------------------------------------|:-------------------------------------|:-------------------------------------|
|  0 | SOLRGEOGRAPHICAREADELTAID | 32463352-0032-0000-0000-000000000000 | 5ea493c1-8286-49da-996f-a36982988d27 | 67a7ca37-e613-44f8-ae3e-8b31063bb46c |
|  1 | LOADDATE                  | 32463352-0032-0000-0000-000000000000 | 2024-06-24 01:23:07.077              | 2024-06-24 07:38:37.086 -0700        |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 9
- Snowflake: 9
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 81914
- Snowflake: 81914
- Rows Margin (%): 0.0

### 2.3 Nulls per Column
|    | Column_Name               |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------|------------------------:|------------------------:|-------------:|
|  0 | SOLRGeographicAreaDeltaID |                       0 |                       0 |            0 |
|  1 | GeographicAreaID          |                       0 |                       0 |            0 |
|  2 | SolrDeltaTypeCode         |                       0 |                       0 |            0 |
|  3 | StartDeltaProcessDate     |                   81914 |                   81914 |            0 |
|  4 | EndDeltaProcessDate       |                   81914 |                   81914 |            0 |
|  5 | MidDeltaProcessComplete   |                       0 |                       0 |            0 |
|  6 | LoadDate                  |                       0 |                       0 |            0 |
|  7 | StartMoveDate             |                   81914 |                   81914 |            0 |
|  8 | EndMoveDate               |                   81914 |                   81914 |            0 |

### 2.4 Distincts per Column
|    | Column_Name               |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | SOLRGeographicAreaDeltaID |                       81914 |                       81914 |            0 |
|  1 | GeographicAreaID          |                       81914 |                       81914 |            0 |
|  2 | SolrDeltaTypeCode         |                           1 |                           1 |            0 |
|  3 | StartDeltaProcessDate     |                           0 |                           0 |            0 |
|  4 | EndDeltaProcessDate       |                           0 |                           0 |            0 |
|  5 | MidDeltaProcessComplete   |                           1 |                           1 |            0 |
|  6 | LoadDate                  |                           1 |                           1 |            0 |
|  7 | StartMoveDate             |                           0 |                           0 |            0 |
|  8 | EndMoveDate               |                           0 |                           0 |            0 |