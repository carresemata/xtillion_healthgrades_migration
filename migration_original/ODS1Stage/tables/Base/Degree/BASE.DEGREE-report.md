# BASE.DEGREE Report

## 1. Sample Validation

Percentage of Identical Columns: 55.56% (5/9).
Percentage of Different Columns: 44.44% (4/9).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name       | Match ID   | SQL Server Value                         | Snowflake Value                      |
|---:|:------------------|:-----------|:-----------------------------------------|:-------------------------------------|
|  0 | DEGREEID          | MSCC       | 4343534d-0000-0000-0000-000000000000     | fc116184-7925-47ec-bc94-afcfce9c5dcf |
|  1 | DEGREEDESCRIPTION | MSCC       | Master of Science in Clinical Counseling | None                                 |
|  2 | LASTUPDATEDATE    | MSCC       | 2018-03-30 10:01:05.797                  | 2023-04-29 00:23:59.100              |
|  3 | REFRANK           | MSCC       | 713                                      | 491                                  |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 9
- Snowflake: 9
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 695
- Snowflake: 683
- Rows Margin (%): 1.7266187050359711

### 2.3 Nulls per Column
|    | Column_Name        |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------|------------------------:|------------------------:|-------------:|
|  0 | DegreeID           |                       0 |                       0 |          0   |
|  1 | DegreeAbbreviation |                       0 |                       0 |          0   |
|  2 | DegreeName         |                     686 |                     683 |          0.4 |
|  3 | DegreeDescription  |                       0 |                     683 |        inf   |
|  4 | LegacyKey          |                     695 |                     683 |          1.7 |
|  5 | LegacyKeyName      |                     695 |                     683 |          1.7 |
|  6 | SourceCode         |                     695 |                     683 |          1.7 |
|  7 | LastUpdateDate     |                       3 |                       0 |        100   |
|  8 | refRank            |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name        |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------|----------------------------:|----------------------------:|-------------:|
|  0 | DegreeID           |                         695 |                         683 |          1.7 |
|  1 | DegreeAbbreviation |                         695 |                         683 |          1.7 |
|  2 | DegreeName         |                           9 |                           0 |        100   |
|  3 | DegreeDescription  |                         664 |                           0 |        100   |
|  4 | LegacyKey          |                           0 |                           0 |          0   |
|  5 | LegacyKeyName      |                           0 |                           0 |          0   |
|  6 | SourceCode         |                           0 |                           0 |          0   |
|  7 | LastUpdateDate     |                          35 |                         183 |        422.9 |
|  8 | refRank            |                         695 |                         683 |          1.7 |