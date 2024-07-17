# BASE.PROVIDERTOCERTIFICATIONSPECIALTY Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/18).
Percentage of Different Columns: 0.00% (0/18).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 18
- Snowflake: 18
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 1199564
- Snowflake: 1200199
- Rows Margin (%): 0.05293590004368254

### 2.3 Nulls per Column
|    | Column_Name                        |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToCertificationSpecialtyID |                       0 |                       0 |          0   |
|  1 | ProviderID                         |                       0 |                       0 |          0   |
|  2 | CertificationSpecialtyID           |                       0 |                       0 |          0   |
|  3 | SourceCode                         |                       0 |                       0 |          0   |
|  4 | CertificationBoardID               |                       0 |                       0 |          0   |
|  5 | CertificationAgencyID              |                       0 |                       0 |          0   |
|  6 | CertificationSpecialtyRank         |                 1199564 |                 1200199 |          0.1 |
|  7 | CertificationStatusID              |                       0 |                       0 |          0   |
|  8 | CertificationStatusDate            |                 1199564 |                 1200199 |          0.1 |
|  9 | CertificationEffectiveDate         |                   65358 |                   65532 |          0.3 |
| 10 | CertificationExpirationDate        |                  947236 |                  947333 |          0   |
| 11 | IsSearchable                       |                 1199564 |                 1200199 |          0.1 |
| 12 | InsertedOn                         |                       0 |                       0 |          0   |
| 13 | InsertedBy                         |                       0 |                       0 |          0   |
| 14 | MOCPathwayID                       |                 1199564 |                 1200199 |          0.1 |
| 15 | MOCLevelID                         |                 1199564 |                  432688 |         63.9 |
| 16 | CertificationAgencyVerified        |                 1199562 |                       0 |        100   |
| 17 | LastUpdateDate                     |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name                        |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToCertificationSpecialtyID |                     1199564 |                     1200199 |          0.1 |
|  1 | ProviderID                         |                      897487 |                      897711 |          0   |
|  2 | CertificationSpecialtyID           |                         266 |                         269 |          1.1 |
|  3 | SourceCode                         |                         113 |                         114 |          0.9 |
|  4 | CertificationBoardID               |                          63 |                          62 |          1.6 |
|  5 | CertificationAgencyID              |                          19 |                          18 |          5.3 |
|  6 | CertificationSpecialtyRank         |                           0 |                           0 |          0   |
|  7 | CertificationStatusID              |                           4 |                           4 |          0   |
|  8 | CertificationStatusDate            |                           0 |                           0 |          0   |
|  9 | CertificationEffectiveDate         |                        7146 |                        7171 |          0.3 |
| 10 | CertificationExpirationDate        |                         655 |                         655 |          0   |
| 11 | IsSearchable                       |                           0 |                           0 |          0   |
| 12 | InsertedOn                         |                           2 |                           1 |         50   |
| 13 | InsertedBy                         |                           1 |                           1 |          0   |
| 14 | MOCPathwayID                       |                           0 |                           0 |          0   |
| 15 | MOCLevelID                         |                           0 |                           3 |        inf   |
| 16 | CertificationAgencyVerified        |                           1 |                           1 |          0   |
| 17 | LastUpdateDate                     |                        5735 |                        5698 |          0.6 |