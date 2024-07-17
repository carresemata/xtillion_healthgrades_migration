# Base.Partner Report

## 1. Sample Validation

Percentage of Identical Columns: 77.78% (7/9).
Percentage of Different Columns: 22.22% (2/9).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name    | Match ID   | SQL Server Value                     | Snowflake Value                      |
|---:|:---------------|:-----------|:-------------------------------------|:-------------------------------------|
|  0 | PARTNERID      | ATH        | 00485441-0000-0000-0000-000000000000 | e99d6656-758f-4107-85bd-060b109400e6 |
|  1 | LASTUPDATEDATE | ATH        | NaT                                  | 2023-10-11 18:07:36.023              |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 9
- Snowflake: 9
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 121
- Snowflake: 114
- Rows Margin (%): 5.785123966942149

### 2.3 Nulls per Column
|    | Column_Name               |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------|------------------------:|------------------------:|-------------:|
|  0 | PartnerID                 |                       0 |                       0 |          0   |
|  1 | PartnerCode               |                       0 |                       0 |          0   |
|  2 | PartnerDescription        |                       0 |                       0 |          0   |
|  3 | PartnerTypeID             |                       0 |                       0 |          0   |
|  4 | URLPath                   |                     120 |                     113 |          5.8 |
|  5 | SourceCode                |                     121 |                     114 |          5.8 |
|  6 | LastUpdateDate            |                      40 |                       0 |        100   |
|  7 | PartnerProductCode        |                       0 |                       0 |          0   |
|  8 | PartnerProductDescription |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name               |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | PartnerID                 |                         121 |                         113 |          6.6 |
|  1 | PartnerCode               |                         121 |                         113 |          6.6 |
|  2 | PartnerDescription        |                         117 |                         109 |          6.8 |
|  3 | PartnerTypeID             |                           2 |                           2 |          0   |
|  4 | URLPath                   |                           1 |                           1 |          0   |
|  5 | SourceCode                |                           0 |                           0 |          0   |
|  6 | LastUpdateDate            |                          74 |                           9 |         87.8 |
|  7 | PartnerProductCode        |                           5 |                           3 |         40   |
|  8 | PartnerProductDescription |                           6 |                           3 |         50   |