# BASE.CLIENTPRODUCTENTITYTODISPLAYPARTNERPHONE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/7).
Percentage of Different Columns: 0.00% (0/7).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 7
- Snowflake: 7
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 2299
- Snowflake: 507
- Rows Margin (%): 77.9469334493258

### 2.3 Nulls per Column
|    | Column_Name                                |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ClientProductEntityToDisplayPartnerPhoneID |                       0 |                       0 |            0 |
|  1 | ClientProductToEntityID                    |                       0 |                       0 |            0 |
|  2 | DisplayPartnerCode                         |                       0 |                       0 |            0 |
|  3 | PhoneTypeID                                |                       0 |                       0 |            0 |
|  4 | PhoneNumber                                |                       0 |                       0 |            0 |
|  5 | SourceCode                                 |                       0 |                       0 |            0 |
|  6 | LastUpdateDate                             |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name                                |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ClientProductEntityToDisplayPartnerPhoneID |                        2299 |                         507 |         77.9 |
|  1 | ClientProductToEntityID                    |                         146 |                          34 |         76.7 |
|  2 | DisplayPartnerCode                         |                           1 |                           1 |          0   |
|  3 | PhoneTypeID                                |                          32 |                          32 |          0   |
|  4 | PhoneNumber                                |                         146 |                          34 |         76.7 |
|  5 | SourceCode                                 |                           1 |                           9 |        800   |
|  6 | LastUpdateDate                             |                          11 |                          10 |          9.1 |