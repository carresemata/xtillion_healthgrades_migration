# BASE.CLIENTTOPRODUCT Report

## 1. Sample Validation

Percentage of Identical Columns: 30.00% (3/10).
Percentage of Different Columns: 70.00% (7/10).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name       | Match ID          | SQL Server Value                     | Snowflake Value                      |
|---:|:------------------|:------------------|:-------------------------------------|:-------------------------------------|
|  0 | CLIENTTOPRODUCTID | IUHGSH-PDCHSP     | 6d614e71-695a-0074-0000-000000000000 | 4e331a87-9cf6-4491-bd34-48134c6636d9 |
|  1 | CLIENTID          | IUHGSH-PDCHSP     | 47485549-4853-0000-0000-000000000000 | 00a7cef1-d1cf-424b-863c-4d8c410cc408 |
|  2 | ACTIVEFLAG        | TRL01-PDCWMDLITE  | True                                 | False                                |
|  3 | SOURCECODE        | IUHGSH-PDCHSP     | Reltio                               | IUHGSH                               |
|  4 | LASTUPDATEDATE    | IUHGSH-PDCHSP     | 2020-01-21 03:46:38.207              | 2023-10-11 18:07:36.023              |
|  5 | RELTIOENTITYID    | IUHGSH-PDCHSP     | qNamZit                              | None                                 |
|  6 | HASOAR            | EHGSELF-PDCPRACT2 | True                                 | False                                |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 10
- Snowflake: 10
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 580
- Snowflake: 476
- Rows Margin (%): 17.93103448275862

### 2.3 Nulls per Column
|    | Column_Name         |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------|------------------------:|------------------------:|-------------:|
|  0 | ClientToProductID   |                       0 |                       0 |          0   |
|  1 | ClientID            |                       0 |                       0 |          0   |
|  2 | ProductID           |                       0 |                       0 |          0   |
|  3 | ActiveFlag          |                       0 |                       0 |          0   |
|  4 | SourceCode          |                       0 |                       0 |          0   |
|  5 | LastUpdateDate      |                       0 |                       0 |          0   |
|  6 | QueueSize           |                     566 |                     472 |         16.6 |
|  7 | ReltioEntityID      |                      86 |                     476 |        453.5 |
|  8 | ClientToProductCode |                       0 |                       0 |          0   |
|  9 | HasOAR              |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name         |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ClientToProductID   |                         580 |                         476 |         17.9 |
|  1 | ClientID            |                         501 |                         400 |         20.2 |
|  2 | ProductID           |                          10 |                          10 |          0   |
|  3 | ActiveFlag          |                           2 |                           2 |          0   |
|  4 | SourceCode          |                          96 |                         400 |        316.7 |
|  5 | LastUpdateDate      |                         288 |                          58 |         79.9 |
|  6 | QueueSize           |                          11 |                           4 |         63.6 |
|  7 | ReltioEntityID      |                         494 |                           0 |        100   |
|  8 | ClientToProductCode |                         580 |                         476 |         17.9 |
|  9 | HasOAR              |                           2 |                           1 |         50   |