# BASE.PROVIDERTOORGANIZATION Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/11).
Percentage of Different Columns: 0.00% (0/11).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 11
- Snowflake: 11
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 0
- Snowflake: 16334
- Rows Margin (%): 0.0

### 2.3 Nulls per Column
|    | Column_Name              |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------------|------------------------:|------------------------:|-------------:|
|  0 | SourceCode               |                       0 |                       0 |            0 |
|  1 | ProviderToOrganizationID |                       0 |                       0 |            0 |
|  2 | ProviderID               |                       0 |                       0 |            0 |
|  3 | OrganizationID           |                       0 |                   16334 |          inf |
|  4 | PositionID               |                       0 |                   16334 |          inf |
|  5 | PositionStartDate        |                       0 |                   16334 |          inf |
|  6 | PositionEndDate          |                       0 |                   16334 |          inf |
|  7 | PositionRank             |                       0 |                   13899 |          inf |
|  8 | LastUpdateDate           |                       0 |                       0 |            0 |
|  9 | InsertedOn               |                       0 |                       0 |            0 |
| 10 | InsertedBy               |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name              |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | SourceCode               |                           0 |                          97 |          inf |
|  1 | ProviderToOrganizationID |                           0 |                       16334 |          inf |
|  2 | ProviderID               |                           0 |                        6833 |          inf |
|  3 | OrganizationID           |                           0 |                           0 |            0 |
|  4 | PositionID               |                           0 |                           0 |            0 |
|  5 | PositionStartDate        |                           0 |                           0 |            0 |
|  6 | PositionEndDate          |                           0 |                           0 |            0 |
|  7 | PositionRank             |                           0 |                          11 |          inf |
|  8 | LastUpdateDate           |                           0 |                           1 |          inf |
|  9 | InsertedOn               |                           0 |                           1 |          inf |
| 10 | InsertedBy               |                           0 |                           1 |          inf |