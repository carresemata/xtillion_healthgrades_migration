# BASE.FACILITY Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/12).
Percentage of Different Columns: 50.00% (6/12).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name    | Match ID   | SQL Server Value                     | Snowflake Value                          |
|---:|:---------------|:-----------|:-------------------------------------|:-----------------------------------------|
|  0 | FACILITYID     | HG7768     | 37374748-3836-0000-0000-000000000000 | 5ac5f0cc-475e-4533-9c1c-cbd75d461f44     |
|  1 | FACILITYCODE   | HG7770     | HG7770                               | HG7776                                   |
|  2 | FACILITYNAME   | HG7768     | Optum - Airport Plaza                | Novant Health Surgical Partners Biltmore |
|  3 | LEGACYKEY      | HG7768     | HGST7EB017D9HG7768                   | HGSTDB9067D0HG7768                       |
|  4 | LASTUPDATEDATE | HG7768     | 2024-05-27 14:04:49.187              | 2024-04-04 14:50:20.120 -0700            |
|  5 | RELTIOENTITYID | HG7768     | HG7768                               | None                                     |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 12
- Snowflake: 12
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 179007
- Snowflake: 86871
- Rows Margin (%): 51.47061288106052

### 2.3 Nulls per Column
|    | Column_Name             |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:------------------------|------------------------:|------------------------:|-------------:|
|  0 | FacilityID              |                       0 |                       0 |          0   |
|  1 | FacilityCode            |                       0 |                       0 |          0   |
|  2 | FacilityName            |                       0 |                       0 |          0   |
|  3 | IsClosed                |                       2 |                       0 |        100   |
|  4 | LegacyKey               |                     482 |                     474 |          1.7 |
|  5 | LegacyKeyName           |                  179007 |                   86871 |         51.5 |
|  6 | SourceCode              |                       0 |                       0 |          0   |
|  7 | LastUpdateDate          |                       0 |                       0 |          0   |
|  8 | ReltioEntityID          |                  174437 |                   86871 |         50.2 |
|  9 | IsDuplicate             |                  119108 |                       0 |        100   |
| 10 | FacilityCodeDuplicate   |                  178993 |                   86871 |         51.5 |
| 11 | FacilityAccreditationID |                  179007 |                   86871 |         51.5 |

### 2.4 Distincts per Column
|    | Column_Name             |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | FacilityID              |                      179007 |                       86871 |         51.5 |
|  1 | FacilityCode            |                      179007 |                       86871 |         51.5 |
|  2 | FacilityName            |                      153596 |                       80144 |         47.8 |
|  3 | IsClosed                |                           2 |                           2 |          0   |
|  4 | LegacyKey               |                      178523 |                       86397 |         51.6 |
|  5 | LegacyKeyName           |                           0 |                           0 |          0   |
|  6 | SourceCode              |                           2 |                           1 |         50   |
|  7 | LastUpdateDate          |                          15 |                          89 |        493.3 |
|  8 | ReltioEntityID          |                        4563 |                           0 |        100   |
|  9 | IsDuplicate             |                           1 |                           1 |          0   |
| 10 | FacilityCodeDuplicate   |                          14 |                           0 |        100   |
| 11 | FacilityAccreditationID |                           0 |                           0 |          0   |