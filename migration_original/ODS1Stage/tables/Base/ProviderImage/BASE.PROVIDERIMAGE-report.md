# BASE.PROVIDERIMAGE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/13).
Percentage of Different Columns: 0.00% (0/13).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 13
- Snowflake: 13
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 1587266
- Snowflake: 1046772
- Rows Margin (%): 34.05188544327164

### 2.3 Nulls per Column
|    | Column_Name        |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderImageID    |                       0 |                       0 |          0   |
|  1 | ProviderID         |                       0 |                       0 |          0   |
|  2 | MediaImageTypeID   |                       0 |                       0 |          0   |
|  3 | FileName           |                       0 |                       0 |          0   |
|  4 | MediaSizeID        |                   15099 |                   15746 |          4.3 |
|  5 | MediaReviewLevelID |                  189768 |                  197601 |          4.1 |
|  6 | ProviderImage      |                 1587266 |                 1046772 |         34.1 |
|  7 | SourceCode         |                       0 |                       0 |          0   |
|  8 | LastUpdateDate     |                       0 |                       0 |          0   |
|  9 | MediaContextTypeID |                       0 |                       0 |          0   |
| 10 | MediaImageHostID   |                       0 |                       0 |          0   |
| 11 | ExternalIdentifier |                  829236 |                  662865 |         20.1 |
| 12 | ImagePath          |                      12 |                      12 |          0   |

### 2.4 Distincts per Column
|    | Column_Name        |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderImageID    |                     1587266 |                     1046772 |         34.1 |
|  1 | ProviderID         |                      377930 |                      389154 |          3   |
|  2 | MediaImageTypeID   |                           1 |                           1 |          0   |
|  3 | FileName           |                     1535041 |                     1012363 |         34   |
|  4 | MediaSizeID        |                           6 |                           6 |          0   |
|  5 | MediaReviewLevelID |                           1 |                           1 |          0   |
|  6 | SourceCode         |                         159 |                         158 |          0.6 |
|  7 | LastUpdateDate     |                        3505 |                        3360 |          4.1 |
|  8 | MediaContextTypeID |                           2 |                           2 |          0   |
|  9 | MediaImageHostID   |                           2 |                           2 |          0   |
| 10 | ExternalIdentifier |                      207007 |                      181898 |         12.1 |
| 11 | ImagePath          |                       12558 |                       18207 |         45   |