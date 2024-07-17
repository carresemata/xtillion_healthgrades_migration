# Base.ProviderToSubStatus Report

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
- SQL Server: 8804876
- Snowflake: 13266636
- Rows Margin (%): 50.67374032297559

### 2.3 Nulls per Column
|    | Column_Name           |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:----------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToSubStatusID |                       0 |                       0 |          0   |
|  1 | ProviderID            |                       0 |                       0 |          0   |
|  2 | SubStatusID           |                       0 |                       0 |          0   |
|  3 | HierarchyRank         |                       0 |                       0 |          0   |
|  4 | SubStatusValueA       |                 8804876 |                13266636 |         50.7 |
|  5 | LegacyKey             |                 8804876 |                13266636 |         50.7 |
|  6 | LegacyKeyName         |                 8804876 |                13266636 |         50.7 |
|  7 | SourceCode            |                       0 |                       0 |          0   |
|  8 | LastUpdateDate        |                       1 |                       0 |        100   |

### 2.4 Distincts per Column
|    | Column_Name           |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToSubStatusID |                     8804876 |                    13266636 |         50.7 |
|  1 | ProviderID            |                     6452848 |                     6522348 |          1.1 |
|  2 | SubStatusID           |                          29 |                          29 |          0   |
|  3 | HierarchyRank         |                           6 |                           6 |          0   |
|  4 | SubStatusValueA       |                           0 |                           0 |          0   |
|  5 | LegacyKey             |                           0 |                           0 |          0   |
|  6 | LegacyKeyName         |                           0 |                           0 |          0   |
|  7 | SourceCode            |                         185 |                         217 |         17.3 |
|  8 | LastUpdateDate        |                         735 |                         676 |          8   |