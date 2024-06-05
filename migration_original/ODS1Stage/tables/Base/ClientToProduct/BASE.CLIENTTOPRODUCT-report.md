# BASE.CLIENTTOPRODUCT Report

## 1. Sample Validation

Percentage of Identical Columns: 30.00% (3/10).
Percentage of Different Columns: 70.00% (7/10).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name       | Match ID       | SQL Server Value                     | Snowflake Value                      |
|---:|:------------------|:---------------|:-------------------------------------|:-------------------------------------|
|  0 | CLIENTTOPRODUCTID | NWLAKEF-PDCHSP | 5a7a7a69-366b-0055-0000-000000000000 | 13d08882-a651-4992-95c9-1b65af8b7d4a |
|  1 | CLIENTID          | NWLAKEF-PDCHSP | 414c574e-454b-0046-0000-000000000000 | d398c1df-7c60-4e32-8d6e-7619f3389677 |
|  2 | ACTIVEFLAG        | NWLAKEF-PDCHSP | True                                 | False                                |
|  3 | SOURCECODE        | NWLAKEF-PDCHSP | Reltio                               | NWLAKEF                              |
|  4 | LASTUPDATEDATE    | NWLAKEF-PDCHSP | 2020-01-21 03:46:38.207              | 2023-11-03 17:55:05.787              |
|  5 | RELTIOENTITYID    | NWLAKEF-PDCHSP | izzZk6U                              | None                                 |
|  6 | HASOAR            | NWLAKEF-PDCHSP | True                                 | False                                |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 10
- Snowflake: 10
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 580
- Snowflake: 636
- Rows Margin (%): 9.655172413793103

### 2.3 Nulls per Column
|    | Column_Name         |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------|------------------------:|------------------------:|-------------:|
|  0 | ClientToProductID   |                       0 |                       0 |          0   |
|  1 | ClientID            |                       0 |                       0 |          0   |
|  2 | ProductID           |                       0 |                       0 |          0   |
|  3 | ActiveFlag          |                       0 |                       0 |          0   |
|  4 | SourceCode          |                       0 |                       0 |          0   |
|  5 | LastUpdateDate      |                       0 |                       0 |          0   |
|  6 | QueueSize           |                     566 |                     632 |         11.7 |
|  7 | ReltioEntityID      |                      86 |                     636 |        639.5 |
|  8 | ClientToProductCode |                       0 |                       0 |          0   |
|  9 | HasOAR              |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name         |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ClientToProductID   |                         580 |                         636 |          9.7 |
|  1 | ClientID            |                         501 |                         476 |          5   |
|  2 | ProductID           |                          10 |                          10 |          0   |
|  3 | ActiveFlag          |                           2 |                           2 |          0   |
|  4 | SourceCode          |                          96 |                         400 |        316.7 |
|  5 | LastUpdateDate      |                         288 |                          58 |         79.9 |
|  6 | QueueSize           |                          11 |                           4 |         63.6 |
|  7 | ReltioEntityID      |                         494 |                           0 |        100   |
|  8 | ClientToProductCode |                         580 |                         476 |         17.9 |
|  9 | HasOAR              |                           2 |                           1 |         50   |