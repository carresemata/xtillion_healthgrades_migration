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
- SQL Server: 491464
- Snowflake: 53002
- Rows Margin (%): 89.21548679048719

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
|  8 | DisplayPartnerCode             |                       0 |                   53002 |        inf   |
|  9 | RingToNumberType               |                       0 |                   53002 |        inf   |
| 10 | DisplayPhoneNumber             |                       0 |                       0 |          0   |
| 11 | RingToNumber                   |                       0 |                   53002 |        inf   |
| 12 | TrackingNumber                 |                  412824 |                   53002 |         87.2 |

### 2.4 Distincts per Column
|    | Column_Name                    |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToMAPCustomerProductID |                      491464 |                       53002 |         89.2 |
|  1 | ProviderID                     |                       67393 |                       40830 |         39.4 |
|  2 | OfficeID                       |                       29659 |                       24276 |         18.1 |
|  3 | ClientToProductID              |                          92 |                          87 |          5.4 |
|  4 | HasOAR                         |                           1 |                           1 |          0   |
|  5 | InsertedOn                     |                          37 |                           1 |         97.3 |
|  6 | InsertedBy                     |                           2 |                           1 |         50   |
|  7 | DisplayPartnerCode             |                           4 |                           0 |        100   |
|  8 | RingToNumberType               |                           3 |                           0 |        100   |
|  9 | DisplayPhoneNumber             |                       87258 |                       15710 |         82   |
| 10 | RingToNumber                   |                       18211 |                           0 |        100   |
| 11 | TrackingNumber                 |                       78628 |                           0 |        100   |