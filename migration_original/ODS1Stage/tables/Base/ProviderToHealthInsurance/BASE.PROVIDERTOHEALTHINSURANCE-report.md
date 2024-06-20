# BASE.PROVIDERTOHEALTHINSURANCE Report

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
- SQL Server: 37554463
- Snowflake: 38565202
- Rows Margin (%): 2.6913951612089355

### 2.3 Nulls per Column
|    | Column_Name                     |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToHealthInsuranceID     |                       0 |                       0 |          0   |
|  1 | ProviderID                      |                       0 |                       0 |          0   |
|  2 | HealthInsurancePlanToPlanTypeID |                       0 |                       0 |          0   |
|  3 | LegacyKey                       |                37554463 |                38565202 |          2.7 |
|  4 | LegacyKeyName                   |                37554463 |                38565202 |          2.7 |
|  5 | SourceCode                      |                       0 |                       0 |          0   |
|  6 | LastUpdateDate                  |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name                     |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToHealthInsuranceID     |                    37554463 |                    38565202 |          2.7 |
|  1 | ProviderID                      |                     2793320 |                     2850495 |          2   |
|  2 | HealthInsurancePlanToPlanTypeID |                        6809 |                        6845 |          0.5 |
|  3 | LegacyKey                       |                           0 |                           0 |          0   |
|  4 | LegacyKeyName                   |                           0 |                           0 |          0   |
|  5 | SourceCode                      |                         214 |                         213 |          0.5 |
|  6 | LastUpdateDate                  |                        3578 |                        3868 |          8.1 |