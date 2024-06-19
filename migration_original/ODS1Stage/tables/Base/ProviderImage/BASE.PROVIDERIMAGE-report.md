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
- SQL Server: 1587134
- Snowflake: 1012364
- Rows Margin (%): 36.214333509331915

### 2.3 Nulls per Column
|    | Column_Name        |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderImageID    |                       0 |                       0 |          0   |
|  1 | ProviderID         |                       0 |                       0 |          0   |
|  2 | MediaImageTypeID   |                       0 |                       0 |          0   |
|  3 | FileName           |                       0 |                 1012364 |        inf   |
|  4 | MediaSizeID        |                   15095 |                   15127 |          0.2 |
|  5 | MediaReviewLevelID |                  189570 |                  191852 |          1.2 |
|  6 | ProviderImage      |                 1587134 |                 1012364 |         36.2 |
|  7 | SourceCode         |                       0 |                       0 |          0   |
|  8 | LastUpdateDate     |                       0 |                       0 |          0   |
|  9 | MediaContextTypeID |                       0 |                       0 |          0   |
| 10 | MediaImageHostID   |                       0 |                  639729 |        inf   |
| 11 | ExternalIdentifier |                  829237 |                  639729 |         22.9 |
| 12 | ImagePath          |                      12 |                      12 |          0   |

### 2.4 Distincts per Column
|    | Column_Name        |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderImageID    |                     1587134 |                     1012364 |         36.2 |
|  1 | ProviderID         |                      377920 |                      375893 |          0.5 |
|  2 | MediaImageTypeID   |                           1 |                           1 |          0   |
|  3 | FileName           |                     1534981 |                           0 |        100   |
|  4 | MediaSizeID        |                           6 |                           6 |          0   |
|  5 | MediaReviewLevelID |                           1 |                           1 |          0   |
|  6 | SourceCode         |                         159 |                         158 |          0.6 |
|  7 | LastUpdateDate     |                        3506 |                        3360 |          4.2 |
|  8 | MediaContextTypeID |                           2 |                           2 |          0   |
|  9 | MediaImageHostID   |                           2 |                           1 |         50   |
| 10 | ExternalIdentifier |                      206937 |                      181898 |         12.1 |
| 11 | ImagePath          |                       12555 |                       18207 |         45   |