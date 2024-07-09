# MID.PRACTICESPONSORSHIP Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/9).
Percentage of Different Columns: 77.78% (7/9).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name        | Match ID   | SQL Server Value                     | Snowflake Value                      |
|---:|:-------------------|:-----------|:-------------------------------------|:-------------------------------------|
|  0 | PRACTICEID         | PE50897    | 30354550-3938-0037-0000-000000000000 | 05669f2a-ccfb-4655-9ddc-ac62b11392c8 |
|  1 | PRACTICECODE       | 1AXEF6TX23 | 1AXEF6TX23                           | PPP6R5C                              |
|  2 | PRODUCTCODE        | 1AXEF6TX23 | MAP                                  | PDCWMDLITE                           |
|  3 | PRODUCTDESCRIPTION | 1AXEF6TX23 | Market Activation Program            | WriteMD Lite                         |
|  4 | CLIENTTOPRODUCTID  | PE50897    | 36584931-5449-5839-0000-000000000000 | 911c0ac9-bedf-40fa-bb4c-c61a7cb2d503 |
|  5 | CLIENTCODE         | 1AXEF6TX23 | OAK                                  | TEZ02NW                              |
|  6 | CLIENTNAME         | 1AXEF6TX23 | Oak Street Health                    | TEZ02NW                              |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 9
- Snowflake: 9
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 44400
- Snowflake: 31842
- Rows Margin (%): 28.283783783783782

### 2.3 Nulls per Column
|    | Column_Name             |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:------------------------|------------------------:|------------------------:|-------------:|
|  0 | PracticeID              |                       0 |                       0 |            0 |
|  1 | PracticeCode            |                       0 |                       0 |            0 |
|  2 | ProductCode             |                       0 |                       0 |            0 |
|  3 | ProductDescription      |                       0 |                       0 |            0 |
|  4 | ProductGroupCode        |                       0 |                       0 |            0 |
|  5 | ProductGroupDescription |                       0 |                       0 |            0 |
|  6 | ClientToProductID       |                       0 |                       0 |            0 |
|  7 | ClientCode              |                       0 |                       0 |            0 |
|  8 | ClientName              |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name             |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | PracticeID              |                       44400 |                       31842 |         28.3 |
|  1 | PracticeCode            |                       44400 |                       31842 |         28.3 |
|  2 | ProductCode             |                           4 |                           4 |          0   |
|  3 | ProductDescription      |                           4 |                           4 |          0   |
|  4 | ProductGroupCode        |                           1 |                           1 |          0   |
|  5 | ProductGroupDescription |                           1 |                           1 |          0   |
|  6 | ClientToProductID       |                          98 |                         135 |         37.8 |
|  7 | ClientCode              |                          98 |                         135 |         37.8 |
|  8 | ClientName              |                          98 |                         135 |         37.8 |