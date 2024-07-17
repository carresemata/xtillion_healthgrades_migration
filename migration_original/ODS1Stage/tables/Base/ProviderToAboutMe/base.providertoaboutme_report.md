# BASE.PROVIDERTOABOUTME Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/10).
Percentage of Different Columns: 0.00% (0/10).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 10
- Snowflake: 10
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 470449
- Snowflake: 482585
- Rows Margin (%): 2.5796632578664216

### 2.3 Nulls per Column
|    | Column_Name              |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToAboutMeID      |                       0 |                       0 |          0   |
|  1 | ProviderID               |                       0 |                       0 |          0   |
|  2 | SourceCode               |                       0 |                       0 |          0   |
|  3 | AboutMeID                |                       0 |                       0 |          0   |
|  4 | CustomAboutMeDescription |                  470449 |                  482585 |          2.6 |
|  5 | ProviderAboutMeText      |                       0 |                       0 |          0   |
|  6 | CustomDisplayOrder       |                  470449 |                       0 |        100   |
|  7 | InsertedBy               |                       0 |                       0 |          0   |
|  8 | InsertedOn               |                       0 |                       0 |          0   |
|  9 | LastUpdatedDate          |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name              |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToAboutMeID      |                      470449 |                      482585 |          2.6 |
|  1 | ProviderID               |                      291938 |                      299693 |          2.7 |
|  2 | SourceCode               |                         201 |                         199 |          1   |
|  3 | AboutMeID                |                           5 |                           5 |          0   |
|  4 | CustomAboutMeDescription |                           0 |                           0 |          0   |
|  5 | ProviderAboutMeText      |                      404484 |                      401253 |          0.8 |
|  6 | CustomDisplayOrder       |                           0 |                           5 |        inf   |
|  7 | InsertedBy               |                           2 |                           1 |         50   |
|  8 | InsertedOn               |                           4 |                           1 |         75   |
|  9 | LastUpdatedDate          |                        5298 |                        4991 |          5.8 |