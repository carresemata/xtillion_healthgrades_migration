# BASE.PROVIDERTOMAPCUSTOMERPRODUCT Report

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
- SQL Server: 487136
- Snowflake: 51472
- Rows Margin (%): 89.43375156013926

### 2.3 Nulls per Column
|    | Column_Name                    |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToMAPCustomerProductID |                       0 |                       0 |          0   |
|  1 | ProviderID                     |                       0 |                       0 |          0   |
|  2 | OfficeID                       |                       0 |                       0 |          0   |
|  3 | ClientToProductID              |                       0 |                       0 |          0   |
|  4 | PhoneXML                       |                       0 |                       0 |          0   |
|  5 | HasOAR                         |                       0 |                       0 |          0   |
|  6 | InsertedOn                     |                       0 |                       0 |          0   |
|  7 | InsertedBy                     |                       0 |                       0 |          0   |
|  8 | DisplayPartnerCode             |                       0 |                   51472 |        inf   |
|  9 | RingToNumberType               |                       0 |                   51472 |        inf   |
| 10 | DisplayPhoneNumber             |                       0 |                       0 |          0   |
| 11 | RingToNumber                   |                       0 |                   51472 |        inf   |
| 12 | TrackingNumber                 |                  408502 |                   51472 |         87.4 |

### 2.4 Distincts per Column
|    | Column_Name                    |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToMAPCustomerProductID |                      487136 |                       51472 |         89.4 |
|  1 | ProviderID                     |                       67432 |                       39651 |         41.2 |
|  2 | OfficeID                       |                       29659 |                       24276 |         18.1 |
|  3 | ClientToProductID              |                          92 |                          87 |          5.4 |
|  4 | HasOAR                         |                           1 |                           1 |          0   |
|  5 | InsertedOn                     |                          43 |                           1 |         97.7 |
|  6 | InsertedBy                     |                           2 |                           1 |         50   |
|  7 | DisplayPartnerCode             |                           4 |                           0 |        100   |
|  8 | RingToNumberType               |                           3 |                           0 |        100   |
|  9 | DisplayPhoneNumber             |                       87247 |                       15710 |         82   |
| 10 | RingToNumber                   |                       18200 |                           0 |        100   |
| 11 | TrackingNumber                 |                       78622 |                           0 |        100   |