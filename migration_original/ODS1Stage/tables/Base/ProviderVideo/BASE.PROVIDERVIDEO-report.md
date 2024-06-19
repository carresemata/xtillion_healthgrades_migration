# BASE.PROVIDERVIDEO Report

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
- SQL Server: 27803
- Snowflake: 27710
- Rows Margin (%): 0.3344962773801388

### 2.3 Nulls per Column
|    | Column_Name         |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderVideoID     |                       0 |                       0 |          0   |
|  1 | ProviderID          |                       0 |                       0 |          0   |
|  2 | ExternalIdentifier  |                       0 |                       0 |          0   |
|  3 | MediaVideoHostID    |                       0 |                       0 |          0   |
|  4 | MediaReviewLevelID  |                       0 |                       0 |          0   |
|  5 | VideoXML            |                   27803 |                   27710 |          0.3 |
|  6 | VideoThumbnailImage |                   27803 |                   27710 |          0.3 |
|  7 | SourceCode          |                       0 |                       0 |          0   |
|  8 | LastUpdateDate      |                       0 |                       0 |          0   |
|  9 | MediaContextTypeID  |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name        |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderVideoID    |                       27803 |                       27710 |          0.3 |
|  1 | ProviderID         |                       27803 |                       27710 |          0.3 |
|  2 | ExternalIdentifier |                       24277 |                       24184 |          0.4 |
|  3 | MediaVideoHostID   |                           2 |                           2 |          0   |
|  4 | MediaReviewLevelID |                           1 |                           1 |          0   |
|  5 | SourceCode         |                          60 |                          60 |          0   |
|  6 | LastUpdateDate     |                         819 |                         804 |          1.8 |
|  7 | MediaContextTypeID |                           5 |                           5 |          0   |