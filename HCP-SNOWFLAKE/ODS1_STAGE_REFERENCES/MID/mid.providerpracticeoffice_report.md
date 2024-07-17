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
- SQL Server: 7706638
- Snowflake: 7569840
- Rows Margin (%): 1.7750671563916718

### 2.3 Nulls per Column
|    | Column_Name               |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToOfficeID        |                       0 |                       0 |          0   |
|  1 | ProviderID                |                       0 |                       0 |          0   |
|  2 | PracticeID                |                 5338884 |                 5319706 |          0.4 |
|  3 | PracticeCode              |                 5338884 |                 5319706 |          0.4 |
|  4 | PracticeName              |                       2 |                       0 |        100   |
|  5 | YearPracticeEstablished   |                 7686964 |                 7556971 |          1.7 |
|  6 | PracticeNPI               |                 7706638 |                 7569840 |          1.8 |
|  7 | PracticeEmail             |                 7706638 |                 7569840 |          1.8 |
|  8 | PracticeWebsite           |                 7694386 |                 7569840 |          1.6 |
|  9 | PracticeDescription       |                 7706638 |                 7569840 |          1.8 |
| 10 | PracticeLogo              |                 7698432 |                 7565786 |          1.7 |
| 11 | PracticeMedicalDirector   |                 7693843 |                 7563273 |          1.7 |
| 12 | PracticeSoftware          |                 7706638 |                 7569840 |          1.8 |
| 13 | PracticeTIN               |                 7706638 |                 7569840 |          1.8 |
| 14 | OfficeToAddressID         |                       0 |                       0 |          0   |
| 15 | OfficeID                  |                       0 |                       0 |          0   |
| 16 | OfficeCode                |                       0 |                       0 |          0   |
| 17 | OfficeName                |                       1 |                       0 |        100   |
| 18 | IsPrimaryOffice           |                 2100190 |                 1982565 |          5.6 |
| 19 | ProviderOfficeRank        |                       0 |                       0 |          0   |
| 20 | AddressID                 |                       0 |                       0 |          0   |
| 21 | AddressTypeCode           |                       0 |                       0 |          0   |
| 22 | AddressLine1              |                       0 |                       0 |          0   |
| 23 | AddressLine2              |                 7706638 |                 7569840 |          1.8 |
| 24 | AddressLine3              |                 7706638 |                 7569840 |          1.8 |
| 25 | AddressLine4              |                 7706638 |                 7569840 |          1.8 |
| 26 | City                      |                       0 |                       0 |          0   |
| 27 | State                     |                       0 |                       0 |          0   |
| 28 | ZipCode                   |                       0 |                       0 |          0   |
| 29 | County                    |                 1350219 |                 7569840 |        460.6 |
| 30 | Nation                    |                   76207 |                       0 |        100   |
| 31 | Latitude                  |                     174 |                       0 |        100   |
| 32 | Longitude                 |                     174 |                       0 |        100   |
| 33 | FullPhone                 |                   10493 |                 1388253 |      13130.3 |
| 34 | FullFax                   |                 2048116 |                 2907092 |         41.9 |
| 35 | IsDerived                 |                       0 |                       0 |          0   |
| 36 | HasBillingStaff           |                 7706638 |                 7569840 |          1.8 |
| 37 | HasHandicapAccess         |                 7706638 |                 7569840 |          1.8 |
| 38 | HasLabServicesOnSite      |                 7706638 |                 7569840 |          1.8 |
| 39 | HasPharmacyOnSite         |                 7706638 |                 7569840 |          1.8 |
| 40 | HasXrayOnSite             |                 7706638 |                 7569840 |          1.8 |
| 41 | IsSurgeryCenter           |                 7706638 |                 7569840 |          1.8 |
| 42 | HasSurgeryOnSite          |                 7706638 |                 7569840 |          1.8 |
| 43 | AverageDailyPatientVolume |                 7706638 |                 7569840 |          1.8 |
| 44 | PhysicianCount            |                 5338884 |                 5319706 |          0.4 |
| 45 | OfficeCoordinatorName     |                 7706638 |                 7569840 |          1.8 |
| 46 | ParkingInformation        |                 7706638 |                 7569144 |          1.8 |
| 47 | PaymentPolicy             |                 7706638 |                 7569840 |          1.8 |
| 48 | LegacyKeyOffice           |                 7706638 |                 7569840 |          1.8 |
| 49 | LegacyKeyPractice         |                 7706638 |                 7569840 |          1.8 |
| 50 | AddressCode               |                       0 |                 7569840 |        inf   |

### 2.4 Distincts per Column
|    | Column_Name               |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToOfficeID        |                     7706638 |                     7569840 |          1.8 |
|  1 | ProviderID                |                     5606465 |                     5587275 |          0.3 |
|  2 | PracticeID                |                      342585 |                      268385 |         21.7 |
|  3 | PracticeCode              |                      342585 |                      268385 |         21.7 |
|  4 | PracticeName              |                      166002 |                      267426 |         61.1 |
|  5 | YearPracticeEstablished   |                          95 |                          84 |         11.6 |
|  6 | PracticeNPI               |                           0 |                           0 |          0   |
|  7 | PracticeEmail             |                           0 |                           0 |          0   |
|  8 | PracticeWebsite           |                         169 |                           0 |        100   |
|  9 | PracticeDescription       |                           0 |                           0 |          0   |
| 10 | PracticeLogo              |                        2019 |                         883 |         56.3 |
| 11 | PracticeMedicalDirector   |                        3072 |                        1384 |         54.9 |
| 12 | PracticeSoftware          |                           0 |                           0 |          0   |
| 13 | PracticeTIN               |                           0 |                           0 |          0   |
| 14 | OfficeToAddressID         |                     3138168 |                     2961798 |          5.6 |
| 15 | OfficeID                  |                     2985450 |                     2961798 |          0.8 |
| 16 | OfficeCode                |                     2985450 |                     2961798 |          0.8 |
| 17 | OfficeName                |                      722400 |                      839043 |         16.1 |
| 18 | IsPrimaryOffice           |                           1 |                           1 |          0   |
| 19 | ProviderOfficeRank        |                         154 |                         154 |          0   |
| 20 | AddressID                 |                     1484862 |                     1506240 |          1.4 |
| 21 | AddressTypeCode           |                           1 |                           1 |          0   |
| 22 | AddressLine1              |                     1427459 |                      835197 |         41.5 |
| 23 | AddressLine2              |                           0 |                           0 |          0   |
| 24 | AddressLine3              |                           0 |                           0 |          0   |
| 25 | AddressLine4              |                           0 |                           0 |          0   |
| 26 | City                      |                       15052 |                       14969 |          0.6 |
| 27 | State                     |                          56 |                          56 |          0   |
| 28 | ZipCode                   |                       27216 |                       27007 |          0.8 |
| 29 | County                    |                        1817 |                           0 |        100   |
| 30 | Nation                    |                           1 |                           1 |          0   |
| 31 | Latitude                  |                      917225 |                      816607 |         11   |
| 32 | Longitude                 |                      980467 |                      809954 |         17.4 |
| 33 | FullPhone                 |                     2049598 |                     2028459 |          1   |
| 34 | FullFax                   |                      998425 |                      954260 |          4.4 |
| 35 | IsDerived                 |                           1 |                           1 |          0   |
| 36 | HasBillingStaff           |                           0 |                           0 |          0   |
| 37 | HasHandicapAccess         |                           0 |                           0 |          0   |
| 38 | HasLabServicesOnSite      |                           0 |                           0 |          0   |
| 39 | HasPharmacyOnSite         |                           0 |                           0 |          0   |
| 40 | HasXrayOnSite             |                           0 |                           0 |          0   |
| 41 | IsSurgeryCenter           |                           0 |                           0 |          0   |
| 42 | HasSurgeryOnSite          |                           0 |                           0 |          0   |
| 43 | AverageDailyPatientVolume |                           0 |                           0 |          0   |
| 44 | PhysicianCount            |                         697 |                         681 |          2.3 |
| 45 | OfficeCoordinatorName     |                           0 |                           0 |          0   |
| 46 | ParkingInformation        |                           0 |                         190 |        inf   |
| 47 | PaymentPolicy             |                           0 |                           0 |          0   |
| 48 | LegacyKeyOffice           |                           0 |                           0 |          0   |
| 49 | LegacyKeyPractice         |                           0 |                           0 |          0   |
| 50 | AddressCode               |                     1484862 |                           0 |        100   |