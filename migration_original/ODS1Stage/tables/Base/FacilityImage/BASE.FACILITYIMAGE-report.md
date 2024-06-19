# BASE.FACILITYIMAGE Report

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
- SQL Server: 488
- Snowflake: 356
- Rows Margin (%): 27.049180327868854

### 2.3 Nulls per Column
|    | Column_Name        |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------|------------------------:|------------------------:|-------------:|
|  0 | FacilityImageID    |                       0 |                       0 |            0 |
|  1 | FacilityID         |                       0 |                       0 |            0 |
|  2 | FileName           |                       0 |                       0 |            0 |
|  3 | MediaImageTypeID   |                       0 |                       0 |            0 |
|  4 | MediaSizeID        |                       0 |                       0 |            0 |
|  5 | MediaReviewLevelID |                       0 |                       0 |            0 |
|  6 | FacilityImage      |                     488 |                     356 |           27 |
|  7 | SourceCode         |                       0 |                       0 |            0 |
|  8 | LastUpdateDate     |                       0 |                       0 |            0 |
|  9 | ImagePath          |                       2 |                       2 |            0 |

### 2.4 Distincts per Column
|    | Column_Name        |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------|----------------------------:|----------------------------:|-------------:|
|  0 | FacilityImageID    |                         488 |                         356 |         27   |
|  1 | FacilityID         |                         488 |                         355 |         27.3 |
|  2 | FileName           |                         479 |                         349 |         27.1 |
|  3 | MediaImageTypeID   |                           2 |                           1 |         50   |
|  4 | MediaSizeID        |                           1 |                           1 |          0   |
|  5 | MediaReviewLevelID |                           1 |                           1 |          0   |
|  6 | SourceCode         |                           4 |                          38 |        850   |
|  7 | LastUpdateDate     |                           5 |                          59 |       1080   |
|  8 | ImagePath          |                           2 |                           1 |         50   |