# BASE.FACILITYTOFACILITYTYPE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/5).
Percentage of Different Columns: 0.00% (0/5).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 5
- Snowflake: 5
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 178215
- Snowflake: 86871
- Rows Margin (%): 51.25494486996044

### 2.3 Nulls per Column
|    | Column_Name              |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------------|------------------------:|------------------------:|-------------:|
|  0 | FacilityToFacilityTypeID |                       0 |                       0 |            0 |
|  1 | FacilityID               |                       0 |                       0 |            0 |
|  2 | FacilityTypeID           |                       0 |                       0 |            0 |
|  3 | SourceCode               |                       0 |                       0 |            0 |
|  4 | LastUpdateDate           |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name              |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | FacilityToFacilityTypeID |                      178215 |                       86871 |         51.3 |
|  1 | FacilityID               |                      178215 |                       86871 |         51.3 |
|  2 | FacilityTypeID           |                          27 |                          17 |         37   |
|  3 | SourceCode               |                           5 |                           1 |         80   |
|  4 | LastUpdateDate           |                         123 |                          70 |         43.1 |