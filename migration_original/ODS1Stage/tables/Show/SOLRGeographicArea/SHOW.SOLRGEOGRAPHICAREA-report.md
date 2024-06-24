# SHOW.SOLRGEOGRAPHICAREA Report

## 1. Sample Validation

Percentage of Identical Columns: 66.67% (4/6).
Percentage of Different Columns: 33.33% (2/6).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name   | Match ID                             | SQL Server Value        | Snowflake Value               |
|---:|:--------------|:-------------------------------------|:------------------------|:------------------------------|
|  0 | UPDATEDDATE   | 32463352-0032-0000-0000-000000000000 | 2024-06-24 01:23:07.910 | 2024-06-24 07:49:28.329 -0700 |
|  1 | UPDATEDSOURCE | 32463352-0032-0000-0000-000000000000 | dbo                     | OJIMENEZ@RVOHEALTH.COM        |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 6
- Snowflake: 6
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 81914
- Snowflake: 81914
- Rows Margin (%): 0.0

### 2.3 Nulls per Column
|    | Column_Name            |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------|------------------------:|------------------------:|-------------:|
|  0 | GeographicAreaID       |                       0 |                       0 |            0 |
|  1 | GeographicAreaCode     |                       0 |                       0 |            0 |
|  2 | GeographicAreaTypeCode |                       0 |                       0 |            0 |
|  3 | GeographicAreaValue    |                       0 |                       0 |            0 |
|  4 | UpdatedDate            |                       0 |                       0 |            0 |
|  5 | UpdatedSource          |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name            |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | GeographicAreaID       |                       81914 |                       81914 |            0 |
|  1 | GeographicAreaCode     |                       81914 |                       81914 |            0 |
|  2 | GeographicAreaTypeCode |                           3 |                           3 |            0 |
|  3 | GeographicAreaValue    |                       81914 |                       81914 |            0 |
|  4 | UpdatedDate            |                           1 |                           1 |            0 |
|  5 | UpdatedSource          |                           1 |                           1 |            0 |