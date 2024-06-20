# BASE.providertoappointmentavailability Report

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
- SQL Server: 249409
- Snowflake: 250888
- Rows Margin (%): 0.5930018563885024

### 2.3 Nulls per Column
|    | Column_Name                         |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:------------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToAppointmentAvailabilityID |                       0 |                       0 |            0 |
|  1 | ProviderID                          |                       0 |                       0 |            0 |
|  2 | AppointmentAvailabilityID           |                       0 |                       0 |            0 |
|  3 | SourceCode                          |                       0 |                       0 |            0 |
|  4 | InsertedBy                          |                       0 |                       0 |            0 |
|  5 | InsertedOn                          |                       0 |                       0 |            0 |
|  6 | LastUpdatedDate                     |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name                         |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:------------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToAppointmentAvailabilityID |                      249409 |                      250888 |          0.6 |
|  1 | ProviderID                          |                      113494 |                      114149 |          0.6 |
|  2 | AppointmentAvailabilityID           |                           4 |                           4 |          0   |
|  3 | SourceCode                          |                         153 |                         152 |          0.7 |
|  4 | InsertedBy                          |                           1 |                           1 |          0   |
|  5 | InsertedOn                          |                          34 |                           1 |         97.1 |
|  6 | LastUpdatedDate                     |                          45 |                          35 |         22.2 |