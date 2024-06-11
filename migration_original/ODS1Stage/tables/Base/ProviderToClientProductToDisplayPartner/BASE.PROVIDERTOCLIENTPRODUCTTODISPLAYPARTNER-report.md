# Base.ProviderToClientProductToDisplayPartner Report

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
- SQL Server: 19192
- Snowflake: 19128
- Rows Margin (%): 0.3334722801167153

### 2.3 Nulls per Column
|    | Column_Name          |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:---------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderCPDPID       |                       0 |                       0 |            0 |
|  1 | ProviderID           |                       0 |                       0 |            0 |
|  2 | ClientToProductID    |                       0 |                       0 |            0 |
|  3 | SyndicationPartnerID |                       0 |                       0 |            0 |
|  4 | SourceCode           |                       0 |                       0 |            0 |
|  5 | LastUpdateDate       |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name          |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:---------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderCPDPID       |                       19192 |                       19128 |          0.3 |
|  1 | ProviderID           |                       13574 |                       13510 |          0.5 |
|  2 | ClientToProductID    |                           8 |                           8 |          0   |
|  3 | SyndicationPartnerID |                           4 |                           4 |          0   |
|  4 | SourceCode           |                           1 |                          10 |        900   |
|  5 | LastUpdateDate       |                           1 |                          21 |       2000   |