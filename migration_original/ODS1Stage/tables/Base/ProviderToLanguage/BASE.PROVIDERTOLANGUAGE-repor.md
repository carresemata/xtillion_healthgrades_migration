# BASE.PROVIDERTOLANGUAGE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/7).
Percentage of Different Columns: 0.00% (0/7).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 7
- Snowflake: 7
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 312997
- Snowflake: 314966
- Rows Margin (%): 0.629079511944204

### 2.3 Nulls per Column
|    | Column_Name          |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:---------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToLanguageID |                       0 |                       0 |          0   |
|  1 | ProviderID           |                       0 |                       0 |          0   |
|  2 | LanguageID           |                       0 |                       0 |          0   |
|  3 | LegacyKey            |                  312997 |                  314966 |          0.6 |
|  4 | LegacyKeyName        |                  312997 |                  314966 |          0.6 |
|  5 | SourceCode           |                       0 |                       0 |          0   |
|  6 | LastUpdateDate       |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name          |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:---------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToLanguageID |                      312997 |                      314966 |          0.6 |
|  1 | ProviderID           |                      254339 |                      255698 |          0.5 |
|  2 | LanguageID           |                         224 |                         224 |          0   |
|  3 | LegacyKey            |                           0 |                           0 |          0   |
|  4 | LegacyKeyName        |                           0 |                           0 |          0   |
|  5 | SourceCode           |                         190 |                         192 |          1.1 |
|  6 | LastUpdateDate       |                        1461 |                        1685 |         15.3 |