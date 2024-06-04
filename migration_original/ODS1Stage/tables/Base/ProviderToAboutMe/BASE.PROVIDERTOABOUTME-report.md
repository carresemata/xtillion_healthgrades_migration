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
- SQL Server: 457554
- Snowflake: 466716
- Rows Margin (%): 2.0023866035484335

### 2.3 Nulls per Column
|    | Column_Name              |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToAboutMeID      |                       0 |                       0 |            0 |
|  1 | ProviderID               |                       0 |                       0 |            0 |
|  2 | SourceCode               |                       0 |                       0 |            0 |
|  3 | AboutMeID                |                       0 |                       0 |            0 |
|  4 | CustomAboutMeDescription |                  457554 |                  466716 |            2 |
|  5 | ProviderAboutMeText      |                       0 |                       0 |            0 |
|  6 | CustomDisplayOrder       |                  457554 |                       0 |          100 |
|  7 | InsertedBy               |                       0 |                       0 |            0 |
|  8 | InsertedOn               |                       0 |                       0 |            0 |
|  9 | LastUpdatedDate          |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name              |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToAboutMeID      |                      457554 |                      466716 |          2   |
|  1 | ProviderID               |                      282729 |                      289661 |          2.5 |
|  2 | SourceCode               |                         199 |                         199 |          0   |
|  3 | AboutMeID                |                           5 |                           5 |          0   |
|  4 | CustomAboutMeDescription |                           0 |                           0 |          0   |
|  5 | ProviderAboutMeText      |                      392874 |                      401254 |          2.1 |
|  6 | CustomDisplayOrder       |                           0 |                           5 |        inf   |
|  7 | InsertedBy               |                           2 |                           1 |         50   |
|  8 | InsertedOn               |                          44 |                           1 |         97.7 |
|  9 | LastUpdatedDate          |                        4482 |                        4991 |         11.4 |