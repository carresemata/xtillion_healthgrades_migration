# BASE.PROVIDERTOAPPOINTMENTAVAILABILITY Report

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
- SQL Server: 250888
- Snowflake: 259227
- Rows Margin (%): 3.323793884123593

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
|  0 | ProviderToAppointmentAvailabilityID |                      250888 |                      259227 |          3.3 |
|  1 | ProviderID                          |                      114149 |                      118041 |          3.4 |
|  2 | AppointmentAvailabilityID           |                           4 |                           4 |          0   |
|  3 | SourceCode                          |                         152 |                         152 |          0   |
|  4 | InsertedBy                          |                           1 |                           1 |          0   |
|  5 | InsertedOn                          |                           2 |                           1 |         50   |
|  6 | LastUpdatedDate                     |                          35 |                          35 |          0   |