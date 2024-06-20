# BASE.PARTNERTOENTITY Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/15).
Percentage of Different Columns: 0.00% (0/15).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 15
- Snowflake: 15
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 21229
- Snowflake: 19957
- Rows Margin (%): 5.991803664798153

### 2.3 Nulls per Column
|    | Column_Name              |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------------|------------------------:|------------------------:|-------------:|
|  0 | PartnerToEntityID        |                       0 |                       0 |            0 |
|  1 | PartnerID                |                       0 |                       0 |            0 |
|  2 | PrimaryEntityID          |                       0 |                       0 |            0 |
|  3 | PrimaryEntityTypeID      |                       0 |                       0 |            0 |
|  4 | PartnerPrimaryEntityID   |                       0 |                   19957 |          inf |
|  5 | SecondaryEntityID        |                       0 |                       0 |            0 |
|  6 | SecondaryEntityTypeID    |                       0 |                       0 |            0 |
|  7 | PartnerSecondaryEntityID |                       0 |                       0 |            0 |
|  8 | TertiaryEntityID         |                   21227 |                   19957 |            6 |
|  9 | TertiaryEntityTypeID     |                   21227 |                   19957 |            6 |
| 10 | PartnerTertiaryEntityID  |                   21227 |                   19957 |            6 |
| 11 | SourceCode               |                   21229 |                   19957 |            6 |
| 12 | LastUpdateDate           |                       0 |                       0 |            0 |
| 13 | OASURL                   |                    1209 |                       0 |          100 |
| 14 | ExternalOASPartnerID     |                   21226 |                   19957 |            6 |

### 2.4 Distincts per Column
|    | Column_Name              |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | PartnerToEntityID        |                       21229 |                       19957 |          6   |
|  1 | PartnerID                |                          64 |                          50 |         21.9 |
|  2 | PrimaryEntityID          |                       17253 |                       16330 |          5.3 |
|  3 | PrimaryEntityTypeID      |                           1 |                           1 |          0   |
|  4 | PartnerPrimaryEntityID   |                       17253 |                           0 |        100   |
|  5 | SecondaryEntityID        |                        7660 |                        7208 |          5.9 |
|  6 | SecondaryEntityTypeID    |                           1 |                           1 |          0   |
|  7 | PartnerSecondaryEntityID |                        8113 |                        7208 |         11.2 |
|  8 | TertiaryEntityID         |                           2 |                           0 |        100   |
|  9 | TertiaryEntityTypeID     |                           1 |                           0 |        100   |
| 10 | PartnerTertiaryEntityID  |                           2 |                           0 |        100   |
| 11 | SourceCode               |                           0 |                           0 |          0   |
| 12 | LastUpdateDate           |                          19 |                           1 |         94.7 |
| 13 | OASURL                   |                       14293 |                       14165 |          0.9 |
| 14 | ExternalOASPartnerID     |                           1 |                           0 |        100   |