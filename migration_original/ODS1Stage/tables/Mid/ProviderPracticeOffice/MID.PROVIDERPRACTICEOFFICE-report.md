# MID.PROVIDERPRACTICEOFFICE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/51).
Percentage of Different Columns: 0.00% (0/51).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 51
- Snowflake: 51
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 7542981
- Snowflake: 9373359
- Rows Margin (%): 24.265976541635197

### 2.3 Nulls per Column
|    | Column_Name               |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToOfficeID        |                       0 |                       0 |          0   |
|  1 | ProviderID                |                       0 |                       0 |          0   |
|  2 | PracticeID                |                 5092641 |                 6328123 |         24.3 |
|  3 | PracticeCode              |                 5092641 |                 6328123 |         24.3 |
|  4 | PracticeName              |                       2 |                       0 |        100   |
|  5 | YearPracticeEstablished   |                 7522542 |                 9357590 |         24.4 |
|  6 | PracticeNPI               |                 7542981 |                 9373359 |         24.3 |
|  7 | PracticeEmail             |                 7542981 |                 9373359 |         24.3 |
|  8 | PracticeWebsite           |                 7533276 |                 9373359 |         24.4 |
|  9 | PracticeDescription       |                 7542981 |                 9373359 |         24.3 |
| 10 | PracticeLogo              |                 7537229 |                 9368406 |         24.3 |
| 11 | PracticeMedicalDirector   |                 7533493 |                 9365717 |         24.3 |
| 12 | PracticeSoftware          |                 7542981 |                 9373359 |         24.3 |
| 13 | PracticeTIN               |                 7542981 |                 9373359 |         24.3 |
| 14 | OfficeToAddressID         |                       0 |                       0 |          0   |
| 15 | OfficeID                  |                       0 |                       0 |          0   |
| 16 | OfficeCode                |                       0 |                       0 |          0   |
| 17 | OfficeName                |                       1 |                       0 |        100   |
| 18 | IsPrimaryOffice           |                 1986182 |                 2605286 |         31.2 |
| 19 | ProviderOfficeRank        |                       0 |                       0 |          0   |
| 20 | AddressID                 |                       0 |                       0 |          0   |
| 21 | AddressTypeCode           |                       0 |                       0 |          0   |
| 22 | AddressLine1              |                       0 |                       0 |          0   |
| 23 | AddressLine2              |                 7542981 |                 9373359 |         24.3 |
| 24 | AddressLine3              |                 7542981 |                 9373359 |         24.3 |
| 25 | AddressLine4              |                 7542981 |                 9373359 |         24.3 |
| 26 | City                      |                       0 |                       0 |          0   |
| 27 | State                     |                       0 |                       0 |          0   |
| 28 | ZipCode                   |                       0 |                       0 |          0   |
| 29 | County                    |                 1321455 |                 9373359 |        609.3 |
| 30 | Nation                    |                   75752 |                       0 |        100   |
| 31 | Latitude                  |                     156 |                       0 |        100   |
| 32 | Longitude                 |                     156 |                       0 |        100   |
| 33 | FullPhone                 |                   12696 |                 1844434 |      14427.7 |
| 34 | FullFax                   |                 2108619 |                 3513522 |         66.6 |
| 35 | IsDerived                 |                       0 |                       0 |          0   |
| 36 | HasBillingStaff           |                 7542981 |                 9373359 |         24.3 |
| 37 | HasHandicapAccess         |                 7542981 |                 9373359 |         24.3 |
| 38 | HasLabServicesOnSite      |                 7542981 |                 9373359 |         24.3 |
| 39 | HasPharmacyOnSite         |                 7542981 |                 9373359 |         24.3 |
| 40 | HasXrayOnSite             |                 7542981 |                 9373359 |         24.3 |
| 41 | IsSurgeryCenter           |                 7542981 |                 9373359 |         24.3 |
| 42 | HasSurgeryOnSite          |                 7542981 |                 9373359 |         24.3 |
| 43 | AverageDailyPatientVolume |                 7542981 |                 9373359 |         24.3 |
| 44 | PhysicianCount            |                 5092641 |                 9373359 |         84.1 |
| 45 | OfficeCoordinatorName     |                 7542981 |                 9373359 |         24.3 |
| 46 | ParkingInformation        |                 7542981 |                 9372632 |         24.3 |
| 47 | PaymentPolicy             |                 7542981 |                 9373359 |         24.3 |
| 48 | LegacyKeyOffice           |                 7542981 |                 9373359 |         24.3 |
| 49 | LegacyKeyPractice         |                 7542981 |                 9373359 |         24.3 |
| 50 | AddressCode               |                       0 |                 9373359 |        inf   |

### 2.4 Distincts per Column
|    | Column_Name               |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToOfficeID        |                     7542981 |                     7917430 |          5   |
|  1 | ProviderID                |                     5556815 |                     5681540 |          2.2 |
|  2 | PracticeID                |                      388224 |                      268385 |         30.9 |
|  3 | PracticeCode              |                      388224 |                      268385 |         30.9 |
|  4 | PracticeName              |                      264981 |                      267872 |          1.1 |
|  5 | YearPracticeEstablished   |                          96 |                          84 |         12.5 |
|  6 | PracticeNPI               |                           0 |                           0 |          0   |
|  7 | PracticeEmail             |                           0 |                           0 |          0   |
|  8 | PracticeWebsite           |                         162 |                           0 |        100   |
|  9 | PracticeDescription       |                           0 |                           0 |          0   |
| 10 | PracticeLogo              |                        1589 |                         883 |         44.4 |
| 11 | PracticeMedicalDirector   |                        2434 |                        1384 |         43.1 |
| 12 | PracticeSoftware          |                           0 |                           0 |          0   |
| 13 | PracticeTIN               |                           0 |                           0 |          0   |
| 14 | OfficeToAddressID         |                     2965715 |                     3300248 |         11.3 |
| 15 | OfficeID                  |                     2964664 |                     2961900 |          0.1 |
| 16 | OfficeCode                |                     2964664 |                     2961798 |          0.1 |
| 17 | OfficeName                |                      806052 |                      859551 |          6.6 |
| 18 | IsPrimaryOffice           |                           1 |                           1 |          0   |
| 19 | ProviderOfficeRank        |                         154 |                         154 |          0   |
| 20 | AddressID                 |                     1476957 |                     1515770 |          2.6 |
| 21 | AddressTypeCode           |                           1 |                           1 |          0   |
| 22 | AddressLine1              |                     1415225 |                      835197 |         41   |
| 23 | AddressLine2              |                           0 |                           0 |          0   |
| 24 | AddressLine3              |                           0 |                           0 |          0   |
| 25 | AddressLine4              |                           0 |                           0 |          0   |
| 26 | City                      |                       14999 |                       14969 |          0.2 |
| 27 | State                     |                          56 |                          56 |          0   |
| 28 | ZipCode                   |                       27067 |                       27007 |          0.2 |
| 29 | County                    |                        1815 |                           0 |        100   |
| 30 | Nation                    |                           1 |                           1 |          0   |
| 31 | Latitude                  |                      907131 |                          49 |        100   |
| 32 | Longitude                 |                      968281 |                          99 |        100   |
| 33 | FullPhone                 |                     2036259 |                     2028346 |          0.4 |
| 34 | FullFax                   |                      962266 |                      954167 |          0.8 |
| 35 | IsDerived                 |                           1 |                           1 |          0   |
| 36 | HasBillingStaff           |                           0 |                           0 |          0   |
| 37 | HasHandicapAccess         |                           0 |                           0 |          0   |
| 38 | HasLabServicesOnSite      |                           0 |                           0 |          0   |
| 39 | HasPharmacyOnSite         |                           0 |                           0 |          0   |
| 40 | HasXrayOnSite             |                           0 |                           0 |          0   |
| 41 | IsSurgeryCenter           |                           0 |                           0 |          0   |
| 42 | HasSurgeryOnSite          |                           0 |                           0 |          0   |
| 43 | AverageDailyPatientVolume |                           0 |                           0 |          0   |
| 44 | PhysicianCount            |                         690 |                           0 |        100   |
| 45 | OfficeCoordinatorName     |                           0 |                           0 |          0   |
| 46 | ParkingInformation        |                           0 |                         190 |        inf   |
| 47 | PaymentPolicy             |                           0 |                           0 |          0   |
| 48 | LegacyKeyOffice           |                           0 |                           0 |          0   |
| 49 | LegacyKeyPractice         |                           0 |                           0 |          0   |
| 50 | AddressCode               |                     1476957 |                           0 |        100   |