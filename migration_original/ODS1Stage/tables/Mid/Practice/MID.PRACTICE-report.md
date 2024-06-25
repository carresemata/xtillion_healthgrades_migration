# MID.PRACTICE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/47).
Percentage of Different Columns: 0.00% (0/47).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 47
- Snowflake: 47
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 449428
- Snowflake: 55959
- Rows Margin (%): 87.54883985866479

### 2.3 Nulls per Column
|    | Column_Name               |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------|------------------------:|------------------------:|-------------:|
|  0 | PracticeID                |                       0 |                       0 |          0   |
|  1 | PracticeCode              |                       0 |                       0 |          0   |
|  2 | PracticeName              |                       0 |                       0 |          0   |
|  3 | YearPracticeEstablished   |                  443226 |                   55923 |         87.4 |
|  4 | NPI                       |                  449428 |                   55959 |         87.5 |
|  5 | PracticeWebsite           |                  447799 |                   55959 |         87.5 |
|  6 | PracticeDescription       |                  449428 |                   55959 |         87.5 |
|  7 | PracticeLogo              |                  447021 |                   55956 |         87.5 |
|  8 | PracticeMedicalDirector   |                  445720 |                   55953 |         87.4 |
|  9 | PracticeSoftware          |                  449428 |                   55959 |         87.5 |
| 10 | PracticeTIN               |                  449428 |                   55959 |         87.5 |
| 11 | OfficeID                  |                       0 |                       0 |          0   |
| 12 | OfficeCode                |                       0 |                       0 |          0   |
| 13 | OfficeName                |                  449418 |                    2000 |         99.6 |
| 14 | AddressTypeCode           |                       0 |                       0 |          0   |
| 15 | AddressLine1              |                       0 |                       0 |          0   |
| 16 | AddressLine2              |                  443853 |                   54897 |         87.6 |
| 17 | AddressLine3              |                  449428 |                   55959 |         87.5 |
| 18 | AddressLine4              |                  449428 |                   55959 |         87.5 |
| 19 | City                      |                       0 |                       0 |          0   |
| 20 | State                     |                       0 |                       0 |          0   |
| 21 | ZipCode                   |                       0 |                       0 |          0   |
| 22 | County                    |                   75087 |                   55959 |         25.5 |
| 23 | Nation                    |                       0 |                       0 |          0   |
| 24 | Latitude                  |                       6 |                       0 |        100   |
| 25 | Longitude                 |                       6 |                       0 |        100   |
| 26 | FullPhone                 |                     600 |                   14785 |       2364.2 |
| 27 | FullFax                   |                   94794 |                   28978 |         69.4 |
| 28 | HasBillingStaff           |                  449428 |                   55959 |         87.5 |
| 29 | HasHandicapAccess         |                  449428 |                   55959 |         87.5 |
| 30 | HasLabServicesOnSite      |                  449428 |                   55959 |         87.5 |
| 31 | HasPharmacyOnSite         |                  449428 |                   55959 |         87.5 |
| 32 | HasXrayOnSite             |                  449428 |                   55959 |         87.5 |
| 33 | IsSurgeryCenter           |                  449428 |                   55959 |         87.5 |
| 34 | HasSurgeryOnSite          |                  449428 |                   55959 |         87.5 |
| 35 | AverageDailyPatientVolume |                  449428 |                   55959 |         87.5 |
| 36 | PhysicianCount            |                       0 |                       0 |          0   |
| 37 | OfficeCoordinatorName     |                  449428 |                   55959 |         87.5 |
| 38 | ParkingInformation        |                  449428 |                   55956 |         87.5 |
| 39 | PaymentPolicy             |                  449428 |                   55959 |         87.5 |
| 40 | LegacyKeyOffice           |                  449428 |                   55959 |         87.5 |
| 41 | LegacyKeyPractice         |                  449428 |                   55959 |         87.5 |
| 42 | OfficeRank                |                  449428 |                   55959 |         87.5 |
| 43 | CityStatePostalCodeID     |                       0 |                       0 |          0   |
| 44 | HasDentist                |                       0 |                       0 |          0   |
| 45 | GoogleScriptBlock         |                  400151 |                       0 |        100   |
| 46 | OfficeURL                 |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name               |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | PracticeID                |                      342144 |                       31842 |         90.7 |
|  1 | PracticeCode              |                      342144 |                       31842 |         90.7 |
|  2 | PracticeName              |                      263331 |                       24552 |         90.7 |
|  3 | YearPracticeEstablished   |                          95 |                          18 |         81.1 |
|  4 | NPI                       |                           0 |                           0 |          0   |
|  5 | PracticeWebsite           |                         165 |                           0 |        100   |
|  6 | PracticeDescription       |                           0 |                           0 |          0   |
|  7 | PracticeLogo              |                        2025 |                           3 |         99.9 |
|  8 | PracticeMedicalDirector   |                        3083 |                           5 |         99.8 |
|  9 | PracticeSoftware          |                           0 |                           0 |          0   |
| 10 | PracticeTIN               |                           0 |                           0 |          0   |
| 11 | OfficeID                  |                      449383 |                       55744 |         87.6 |
| 12 | OfficeCode                |                      449383 |                       55744 |         87.6 |
| 13 | OfficeName                |                          10 |                       35301 |     352910   |
| 14 | AddressTypeCode           |                           1 |                           1 |          0   |
| 15 | AddressLine1              |                      321429 |                       41954 |         86.9 |
| 16 | AddressLine2              |                        2123 |                         457 |         78.5 |
| 17 | AddressLine3              |                           0 |                           0 |          0   |
| 18 | AddressLine4              |                           0 |                           0 |          0   |
| 19 | City                      |                        8786 |                        4050 |         53.9 |
| 20 | State                     |                          53 |                          52 |          1.9 |
| 21 | ZipCode                   |                       16341 |                        7764 |         52.5 |
| 22 | County                    |                        1565 |                           0 |        100   |
| 23 | Nation                    |                           1 |                           1 |          0   |
| 24 | Latitude                  |                      240480 |                       32684 |         86.4 |
| 25 | Longitude                 |                      244289 |                       32558 |         86.7 |
| 26 | FullPhone                 |                      335199 |                       31624 |         90.6 |
| 27 | FullFax                   |                      281012 |                       22370 |         92   |
| 28 | HasBillingStaff           |                           0 |                           0 |          0   |
| 29 | HasHandicapAccess         |                           0 |                           0 |          0   |
| 30 | HasLabServicesOnSite      |                           0 |                           0 |          0   |
| 31 | HasPharmacyOnSite         |                           0 |                           0 |          0   |
| 32 | HasXrayOnSite             |                           0 |                           0 |          0   |
| 33 | IsSurgeryCenter           |                           0 |                           0 |          0   |
| 34 | HasSurgeryOnSite          |                           0 |                           0 |          0   |
| 35 | AverageDailyPatientVolume |                           0 |                           0 |          0   |
| 36 | PhysicianCount            |                         692 |                         543 |         21.5 |
| 37 | OfficeCoordinatorName     |                           0 |                           0 |          0   |
| 38 | ParkingInformation        |                           0 |                           3 |        inf   |
| 39 | PaymentPolicy             |                           0 |                           0 |          0   |
| 40 | LegacyKeyOffice           |                           0 |                           0 |          0   |
| 41 | LegacyKeyPractice         |                           0 |                           0 |          0   |
| 42 | OfficeRank                |                           0 |                           0 |          0   |
| 43 | CityStatePostalCodeID     |                       18092 |                        8308 |         54.1 |
| 44 | HasDentist                |                           2 |                           2 |          0   |
| 45 | GoogleScriptBlock         |                       49277 |                       55959 |         13.6 |
| 46 | OfficeURL                 |                      449428 |                       55744 |         87.6 |