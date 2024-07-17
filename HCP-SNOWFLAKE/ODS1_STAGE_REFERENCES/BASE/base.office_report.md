# BASE.OFFICE Report

## 1. Sample Validation

Percentage of Identical Columns: 82.14% (23/28).
Percentage of Different Columns: 17.86% (5/28).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name    | Match ID   | SQL Server Value                     | Snowflake Value                         |
|---:|:---------------|:-----------|:-------------------------------------|:----------------------------------------|
|  0 | OFFICEID       | XCYYB9     | 59594358-3942-0000-0000-000000000000 | 23eebaf6-54b5-4f08-98d5-bf83fa0e9809    |
|  1 | OFFICENAME     | XCYYB9     | None                                 | TRUMAN MEDICAL CENTER BEHAVIORAL HEALTH |
|  2 | SOURCECODE     | XCYYB9     | Profisee                             | HMS                                     |
|  3 | LASTUPDATEDATE | XCYYB9     | 2024-06-14 04:56:10.197              | 2024-05-02 04:00:01.150                 |
|  4 | RELTIOENTITYID | XCYYB9     | XCYYB9                               | None                                    |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 28
- Snowflake: 28
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 15705451
- Snowflake: 3006709
- Rows Margin (%): 80.85563413619894

### 2.3 Nulls per Column
|    | Column_Name               |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------|------------------------:|------------------------:|-------------:|
|  0 | OfficeID                  |                       0 |                       0 |          0   |
|  1 | OfficeCode                |                       0 |                       0 |          0   |
|  2 | PracticeID                |                11229482 |                 2545491 |         77.3 |
|  3 | HasBillingStaff           |                15705451 |                 3006709 |         80.9 |
|  4 | HasHandicapAccess         |                15705451 |                 3006709 |         80.9 |
|  5 | HasLabServicesOnSite      |                15705451 |                 3006709 |         80.9 |
|  6 | HasPharmacyOnSite         |                15705451 |                 3006709 |         80.9 |
|  7 | HasXrayOnSite             |                15705451 |                 3006709 |         80.9 |
|  8 | IsSurgeryCenter           |                15705451 |                 3006709 |         80.9 |
|  9 | HasSurgeryOnSite          |                15705451 |                 3006709 |         80.9 |
| 10 | AverageDailyPatientVolume |                15705451 |                 3006709 |         80.9 |
| 11 | PhysicianCount            |                15705451 |                 3006709 |         80.9 |
| 12 | OfficeCoordinatorName     |                15705451 |                 3006709 |         80.9 |
| 13 | ParkingInformation        |                15702345 |                 3006444 |         80.9 |
| 14 | PaymentPolicy             |                15705451 |                 3006709 |         80.9 |
| 15 | OfficeName                |                 8371950 |                 1257755 |         85   |
| 16 | LegacyKey                 |                15705451 |                 3006709 |         80.9 |
| 17 | LegacyKeyName             |                15705451 |                 3006709 |         80.9 |
| 18 | SourceCode                |                       0 |                       0 |          0   |
| 19 | OfficeRank                |                15667245 |                 3006709 |         80.8 |
| 20 | IsDerived                 |                       0 |                       0 |          0   |
| 21 | NPI                       |                15705451 |                 3006709 |         80.9 |
| 22 | HasChildPlayground        |                15705451 |                 3006709 |         80.9 |
| 23 | LastUpdateDate            |                       0 |                       0 |          0   |
| 24 | OfficeDescription         |                15705451 |                 3006709 |         80.9 |
| 25 | OfficeWebsite             |                15705451 |                 3006709 |         80.9 |
| 26 | OfficeEmail               |                15705451 |                 3006709 |         80.9 |
| 27 | ReltioEntityID            |                       0 |                 3006709 |        inf   |

### 2.4 Distincts per Column
|    | Column_Name               |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | OfficeID                  |                    15705451 |                     3006709 |         80.9 |
|  1 | OfficeCode                |                    15705451 |                     3006709 |         80.9 |
|  2 | PracticeID                |                      897958 |                      268878 |         70.1 |
|  3 | HasBillingStaff           |                           0 |                           0 |          0   |
|  4 | HasHandicapAccess         |                           0 |                           0 |          0   |
|  5 | HasLabServicesOnSite      |                           0 |                           0 |          0   |
|  6 | HasPharmacyOnSite         |                           0 |                           0 |          0   |
|  7 | HasXrayOnSite             |                           0 |                           0 |          0   |
|  8 | IsSurgeryCenter           |                           0 |                           0 |          0   |
|  9 | HasSurgeryOnSite          |                           0 |                           0 |          0   |
| 10 | AverageDailyPatientVolume |                           0 |                           0 |          0   |
| 11 | PhysicianCount            |                           0 |                           0 |          0   |
| 12 | OfficeCoordinatorName     |                           0 |                           0 |          0   |
| 13 | ParkingInformation        |                         638 |                         197 |         69.1 |
| 14 | PaymentPolicy             |                           0 |                           0 |          0   |
| 15 | OfficeName                |                      957279 |                      727220 |         24   |
| 16 | LegacyKey                 |                           0 |                           0 |          0   |
| 17 | LegacyKeyName             |                           0 |                           0 |          0   |
| 18 | SourceCode                |                         232 |                         216 |          6.9 |
| 19 | OfficeRank                |                          21 |                           0 |        100   |
| 20 | IsDerived                 |                           1 |                           1 |          0   |
| 21 | NPI                       |                           0 |                           0 |          0   |
| 22 | HasChildPlayground        |                           0 |                           0 |          0   |
| 23 | LastUpdateDate            |                        6837 |                       90033 |       1216.8 |
| 24 | OfficeDescription         |                           0 |                           0 |          0   |
| 25 | OfficeWebsite             |                           0 |                           0 |          0   |
| 26 | OfficeEmail               |                           0 |                           0 |          0   |
| 27 | ReltioEntityID            |                    15705451 |                           0 |        100   |