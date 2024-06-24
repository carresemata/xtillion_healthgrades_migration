# BASE.PROVIDERSURVEYSUPPRESSION Report

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
- SQL Server: 3932
- Snowflake: 4684
- Rows Margin (%): 19.12512716174975

### 2.3 Nulls per Column
|    | Column_Name                 |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:----------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderSurveySuppressionID |                       0 |                       0 |            0 |
|  1 | ProviderID                  |                       0 |                       0 |            0 |
|  2 | SurveySuppressionReasonID   |                       0 |                       0 |            0 |
|  3 | SourceCode                  |                       0 |                       0 |            0 |
|  4 | InsertedOn                  |                       0 |                       0 |            0 |
|  5 | InsertedBy                  |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name                 |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:----------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderSurveySuppressionID |                        3932 |                        4684 |         19.1 |
|  1 | ProviderID                  |                        3932 |                        4484 |         14   |
|  2 | SurveySuppressionReasonID   |                           5 |                           6 |         20   |
|  3 | SourceCode                  |                          41 |                          44 |          7.3 |
|  4 | InsertedOn                  |                           1 |                           1 |          0   |
|  5 | InsertedBy                  |                           1 |                           1 |          0   |