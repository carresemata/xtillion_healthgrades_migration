# BASE.PROVIDERIDENTIFICATION Report

## 1. Sample Validation

Percentage of Identical Columns: 75.00% (6/8).
Percentage of Different Columns: 25.00% (2/8).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name              | Match ID   | SQL Server Value                     | Snowflake Value                      |
|---:|:-------------------------|:-----------|:-------------------------------------|:-------------------------------------|
|  0 | PROVIDERIDENTIFICATIONID | MA0129379  | 5f115e35-e700-493e-ab21-b39a6433921c | d1341640-0377-4ca4-b5e0-c25c4b0d5e19 |
|  1 | PROVIDERID               | MA0129379  | 6e6d6671-6542-004e-0000-000000000000 | 61e996bf-ffd8-4263-beff-0c86af1e3a6e |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 8
- Snowflake: 8
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 2129047
- Snowflake: 2225270
- Rows Margin (%): 4.5195338571670804

### 2.3 Nulls per Column
|    | Column_Name              |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderIdentificationID |                       0 |                       0 |          0   |
|  1 | ProviderID               |                       0 |                       0 |          0   |
|  2 | IdentificationTypeID     |                       0 |                       0 |          0   |
|  3 | IdentificationValue      |                       0 |                       0 |          0   |
|  4 | EffectiveDate            |                 2129047 |                 2225270 |          4.5 |
|  5 | ExpirationDate           |                       1 |                       1 |          0   |
|  6 | SourceCode               |                       0 |                       0 |          0   |
|  7 | LastUpdateDate           |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name              |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderIdentificationID |                     2129047 |                     2225270 |          4.5 |
|  1 | ProviderID               |                     1544703 |                     1599717 |          3.6 |
|  2 | IdentificationTypeID     |                           1 |                           1 |          0   |
|  3 | IdentificationValue      |                     2128986 |                     2129119 |          0   |
|  4 | EffectiveDate            |                           0 |                           0 |          0   |
|  5 | ExpirationDate           |                         445 |                         445 |          0   |
|  6 | SourceCode               |                           1 |                           1 |          0   |
|  7 | LastUpdateDate           |                          26 |                          26 |          0   |