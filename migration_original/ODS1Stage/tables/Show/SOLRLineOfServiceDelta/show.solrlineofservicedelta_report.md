# SHOW.SOLRLINEOFSERVICEDELTA Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/9).
Percentage of Different Columns: 0.00% (0/9).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 9
- Snowflake: 9
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 267
- Snowflake: 267
- Rows Margin (%): 0.0

### 2.3 Nulls per Column
|    | Column_Name              |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------------|------------------------:|------------------------:|-------------:|
|  0 | SOLRLineOfServiceDeltaID |                       0 |                       0 |            0 |
|  1 | LineOfServiceID          |                       0 |                       0 |            0 |
|  2 | SolrDeltaTypeCode        |                       0 |                       0 |            0 |
|  3 | StartDeltaProcessDate    |                     267 |                     267 |            0 |
|  4 | EndDeltaProcessDate      |                     267 |                     267 |            0 |
|  5 | MidDeltaProcessComplete  |                       0 |                       0 |            0 |
|  6 | LoadDate                 |                       0 |                       0 |            0 |
|  7 | StartMoveDate            |                     267 |                     267 |            0 |
|  8 | EndMoveDate              |                     267 |                     267 |            0 |

### 2.4 Distincts per Column
|    | Column_Name              |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | SOLRLineOfServiceDeltaID |                         267 |                         267 |            0 |
|  1 | LineOfServiceID          |                         267 |                         267 |            0 |
|  2 | SolrDeltaTypeCode        |                           1 |                           1 |            0 |
|  3 | StartDeltaProcessDate    |                           0 |                           0 |            0 |
|  4 | EndDeltaProcessDate      |                           0 |                           0 |            0 |
|  5 | MidDeltaProcessComplete  |                           1 |                           1 |            0 |
|  6 | LoadDate                 |                           1 |                           1 |            0 |
|  7 | StartMoveDate            |                           0 |                           0 |            0 |
|  8 | EndMoveDate              |                           0 |                           0 |            0 |