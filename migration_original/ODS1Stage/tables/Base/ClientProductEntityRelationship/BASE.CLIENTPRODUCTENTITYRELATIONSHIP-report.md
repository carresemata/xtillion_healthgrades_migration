# BASE.CLIENTPRODUCTENTITYRELATIONSHIP Report

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
- SQL Server: 64148
- Snowflake: 119607
- Rows Margin (%): 86.45476086549854

### 2.3 Nulls per Column
|    | Column_Name                       |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:----------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ClientProductEntityRelationshipID |                       0 |                       0 |            0 |
|  1 | RelationshipTypeID                |                       0 |                       0 |            0 |
|  2 | ParentID                          |                       0 |                       0 |            0 |
|  3 | ChildID                           |                       0 |                       0 |            0 |
|  4 | SourceCode                        |                       0 |                       0 |            0 |
|  5 | LastUpdateDate                    |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name                       |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:----------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ClientProductEntityRelationshipID |                       64148 |                      119607 |         86.5 |
|  1 | RelationshipTypeID                |                           2 |                           2 |          0   |
|  2 | ParentID                          |                       48524 |                       76199 |         57   |
|  3 | ChildID                           |                        3366 |                       58889 |       1649.5 |
|  4 | SourceCode                        |                         133 |                         141 |          6   |
|  5 | LastUpdateDate                    |                        1281 |                         647 |         49.5 |