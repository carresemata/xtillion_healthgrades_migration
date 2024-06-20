# MID.PARTNERENTITY Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/21).
Percentage of Different Columns: 0.00% (0/21).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 21
- Snowflake: 21
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 41364
- Snowflake: 19988
- Rows Margin (%): 51.677787448022436

### 2.3 Nulls per Column
|    | Column_Name                   |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:------------------------------|------------------------:|------------------------:|-------------:|
|  0 | PartnerToEntityID             |                       0 |                       0 |          0   |
|  1 | PartnerID                     |                       0 |                       0 |          0   |
|  2 | PartnerCode                   |                       0 |                       0 |          0   |
|  3 | PartnerDescription            |                       0 |                       0 |          0   |
|  4 | PartnerTypeCode               |                       0 |                       0 |          0   |
|  5 | PartnerTypeDescription        |                       0 |                       0 |          0   |
|  6 | PartnerProductCode            |                       0 |                       0 |          0   |
|  7 | PartnerProductDescription     |                       0 |                       0 |          0   |
|  8 | URLPath                       |                   39244 |                   18856 |         52   |
|  9 | FullURL                       |                    1344 |                       0 |        100   |
| 10 | PrimaryEntityID               |                       0 |                       0 |          0   |
| 11 | PartnerPrimaryEntityID        |                       0 |                   19988 |        inf   |
| 12 | SecondaryEntityID             |                       0 |                       0 |          0   |
| 13 | PartnerSecondaryEntityID      |                       0 |                       0 |          0   |
| 14 | TertiaryEntityID              |                   41362 |                   19988 |         51.7 |
| 15 | PartnerTertiaryEntityID       |                   41362 |                   19988 |         51.7 |
| 16 | ProviderCode                  |                       0 |                       0 |          0   |
| 17 | OfficeCode                    |                   20148 |                       0 |        100   |
| 18 | PracticeCode                  |                   41362 |                   19988 |         51.7 |
| 19 | ExternalOASPartnerCode        |                   41358 |                   19988 |         51.7 |
| 20 | ExternalOASPartnerDescription |                   41358 |                   19988 |         51.7 |

### 2.4 Distincts per Column
|    | Column_Name                   |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | PartnerToEntityID             |                       21216 |                       19957 |          5.9 |
|  1 | PartnerID                     |                          64 |                          50 |         21.9 |
|  2 | PartnerCode                   |                          64 |                          50 |         21.9 |
|  3 | PartnerDescription            |                          63 |                          50 |         20.6 |
|  4 | PartnerTypeCode               |                           2 |                           1 |         50   |
|  5 | PartnerTypeDescription        |                           2 |                           1 |         50   |
|  6 | PartnerProductCode            |                           2 |                           2 |          0   |
|  7 | PartnerProductDescription     |                           2 |                           2 |          0   |
|  8 | URLPath                       |                           1 |                           1 |          0   |
|  9 | FullURL                       |                       14288 |                       14165 |          0.9 |
| 10 | PrimaryEntityID               |                       17241 |                       16330 |          5.3 |
| 11 | PartnerPrimaryEntityID        |                       17241 |                           0 |        100   |
| 12 | SecondaryEntityID             |                        7660 |                        7208 |          5.9 |
| 13 | PartnerSecondaryEntityID      |                        8110 |                        7208 |         11.1 |
| 14 | TertiaryEntityID              |                           2 |                           0 |        100   |
| 15 | PartnerTertiaryEntityID       |                           2 |                           0 |        100   |
| 16 | ProviderCode                  |                       17241 |                       16043 |          6.9 |
| 17 | OfficeCode                    |                        7660 |                        7207 |          5.9 |
| 18 | PracticeCode                  |                           2 |                           0 |        100   |
| 19 | ExternalOASPartnerCode        |                           1 |                           0 |        100   |
| 20 | ExternalOASPartnerDescription |                           1 |                           0 |        100   |