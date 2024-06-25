# MID.PROVIDERSPECIALTYFACILITYSERVICELINERATING Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/7).
Percentage of Different Columns: 100.00% (7/7).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name            | Match ID   | SQL Server Value                     | Snowflake Value                      |
|---:|:-----------------------|:-----------|:-------------------------------------|:-------------------------------------|
|  0 | PROVIDERID             | SLPRS      | 424c4c55-5433-0000-0000-000000000000 | 764a5637-c9c2-4332-8090-ae6d9bcd9ed7 |
|  1 | SERVICELINECODE        | SLPRS      | SLPRS                                | SLNSC                                |
|  2 | SERVICELINESTAR        | SLPRS      | 1                                    | 5                                    |
|  3 | SERVICELINEDESCRIPTION | SLPRS      | Prostate Surgery                     | Neurosciences                        |
|  4 | LEGACYKEY              | SLPRS      | 64                                   | 28                                   |
|  5 | SPECIALTYID            | SLPRS      | 4c4f5255-0000-0000-0000-000000000000 | 5255454e-0000-0000-0000-000000000000 |
|  6 | SPECIALTYCODE          | SLPRS      | UROL                                 | NEUR                                 |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 7
- Snowflake: 7
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 267934
- Snowflake: 20418
- Rows Margin (%): 92.37946658505453

### 2.3 Nulls per Column
|    | Column_Name            |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderID             |                       0 |                       0 |            0 |
|  1 | ServiceLineCode        |                       0 |                       0 |            0 |
|  2 | ServiceLineStar        |                       0 |                       0 |            0 |
|  3 | ServiceLineDescription |                       0 |                       0 |            0 |
|  4 | LegacyKey              |                       0 |                       0 |            0 |
|  5 | SpecialtyID            |                       0 |                       0 |            0 |
|  6 | SpecialtyCode          |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name            |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderID             |                      187671 |                       13792 |         92.7 |
|  1 | ServiceLineCode        |                          15 |                          14 |          6.7 |
|  2 | ServiceLineStar        |                           3 |                           3 |          0   |
|  3 | ServiceLineDescription |                          15 |                          14 |          6.7 |
|  4 | LegacyKey              |                          24 |                          23 |          4.2 |
|  5 | SpecialtyID            |                          24 |                          23 |          4.2 |
|  6 | SpecialtyCode          |                          24 |                          23 |          4.2 |