# MID.PROVIDERRECOGNITION Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/6).
Percentage of Different Columns: 0.00% (0/6).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 6
- Snowflake: 6
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 940364
- Snowflake: 916046
- Rows Margin (%): 2.5860198816628452

### 2.3 Nulls per Column
|    | Column_Name            |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderID             |                       0 |                       0 |          0   |
|  1 | RecognitionCode        |                       0 |                       0 |          0   |
|  2 | RecognitionDisplayName |                       0 |                       0 |          0   |
|  3 | ServiceLine            |                  940364 |                  916046 |          2.6 |
|  4 | FacilityCode           |                  940364 |                  916046 |          2.6 |
|  5 | FacilityName           |                  940364 |                  916046 |          2.6 |

### 2.4 Distincts per Column
|    | Column_Name            |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderID             |                      883386 |                      916046 |          3.7 |
|  1 | RecognitionCode        |                           1 |                           1 |          0   |
|  2 | RecognitionDisplayName |                           1 |                           1 |          0   |
|  3 | ServiceLine            |                           0 |                           0 |          0   |
|  4 | FacilityCode           |                           0 |                           0 |          0   |
|  5 | FacilityName           |                           0 |                           0 |          0   |