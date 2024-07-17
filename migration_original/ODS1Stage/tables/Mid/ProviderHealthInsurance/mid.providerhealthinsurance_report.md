# Mid.ProviderHealthInsurance Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/13).
Percentage of Different Columns: 0.00% (0/13).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 13
- Snowflake: 13
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 38592898
- Snowflake: 35156511
- Rows Margin (%): 8.904195274477702

### 2.3 Nulls per Column
|    | Column_Name                     |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToHealthInsuranceID     |                       0 |                       0 |          0   |
|  1 | ProviderID                      |                       0 |                       0 |          0   |
|  2 | HealthInsurancePlanToPlanTypeID |                       0 |                       0 |          0   |
|  3 | ProductName                     |                       0 |                       0 |          0   |
|  4 | PlanName                        |                       0 |                       0 |          0   |
|  5 | PlanDisplayName                 |                       0 |                       0 |          0   |
|  6 | PayorName                       |                       0 |                       0 |          0   |
|  7 | PlanTypeDescription             |                10181461 |                 9896137 |          2.8 |
|  8 | PlanTypeDisplayDescription      |                10181461 |                 9896137 |          2.8 |
|  9 | Searchable                      |                       0 |                       0 |          0   |
| 10 | PayorCode                       |                 3189788 |                       0 |        100   |
| 11 | HealthInsurancePayorID          |                       0 |                       0 |          0   |
| 12 | PayorProductCount               |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name                     |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToHealthInsuranceID     |                    38592898 |                    35156511 |          8.9 |
|  1 | ProviderID                      |                     2849266 |                     2832636 |          0.6 |
|  2 | HealthInsurancePlanToPlanTypeID |                        6904 |                        6227 |          9.8 |
|  3 | ProductName                     |                        6276 |                        5624 |         10.4 |
|  4 | PlanName                        |                        5223 |                        4585 |         12.2 |
|  5 | PlanDisplayName                 |                        5223 |                        4585 |         12.2 |
|  6 | PayorName                       |                        1383 |                         781 |         43.5 |
|  7 | PlanTypeDescription             |                          58 |                          58 |          0   |
|  8 | PlanTypeDisplayDescription      |                          58 |                          58 |          0   |
|  9 | Searchable                      |                           2 |                           1 |         50   |
| 10 | PayorCode                       |                        1361 |                         781 |         42.6 |
| 11 | HealthInsurancePayorID          |                        1383 |                         781 |         43.5 |
| 12 | PayorProductCount               |                          86 |                          85 |          1.2 |