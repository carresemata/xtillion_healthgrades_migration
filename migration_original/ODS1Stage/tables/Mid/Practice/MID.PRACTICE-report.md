# MID.PRACTICE Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/47).
Percentage of Different Columns: 42.55% (20/47).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name           | Match ID   | SQL Server Value                                        | Snowflake Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|---:|:----------------------|:-----------|:--------------------------------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|  0 | PRACTICEID            | UQNC2V     | 434e5155-5632-0000-0000-000000000000                    | 5bc6ff12-a257-4611-be51-b6202b705cfc                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
|  1 | PRACTICECODE          | DVVRIBB631 | DVVRIBB631                                              | 10IWDDPE17                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|  2 | PRACTICENAME          | DVVRIBB631 | Practice                                                | Aspen Dental                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
|  3 | OFFICEID              | UQNC2V     | 4a345258-5038-0000-0000-000000000000                    | c338b833-ff67-4afa-9046-590c08759fc6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
|  4 | OFFICECODE            | DVVRIBB631 | XSJQLQ                                                  | X7R2SF                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
|  5 | OFFICENAME            | UQNC2V     | None                                                    | MISSION REGIONAL MEDICAL CENTER                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|  6 | ADDRESSLINE1          | DVVRIBB631 | 1800 E Florence Blvd                                    | 762 59th St                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|  7 | CITY                  | DVVRIBB631 | Casa Grande                                             | Brooklyn                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
|  8 | STATE                 | DVVRIBB631 | AZ                                                      | NY                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
|  9 | ZIPCODE               | DVVRIBB631 | 85122                                                   | 11220                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 10 | COUNTY                | UQNC2V     | Hidalgo                                                 | None                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| 11 | LATITUDE              | UQNC2V     | 26.1959                                                 | 26.196392                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| 12 | LONGITUDE             | UQNC2V     | -98.31319                                               | -98.314232                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| 13 | FULLPHONE             | DVVRIBB631 | (520) 381-6300                                          | (718) 765-0383                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| 14 | FULLFAX               | UQNC2V     | (903) 389-1606                                          | None                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| 15 | PHYSICIANCOUNT        | DVVRIBB631 | 843                                                     | 20310                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 16 | CITYSTATEPOSTALCODEID | UQNC2V     | bf253e36-2c79-43e0-8e75-2fa738ccf04c                    | 30a35f4a-aa44-4cf1-b884-0eb1059f724b                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| 17 | HASDENTIST            | DVVRIBB631 | 1                                                       | 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| 18 | GOOGLESCRIPTBLOCK     | UQNC2V     | None                                                    | '{"@@context": "http://schema.org","@@type" : "MedicalClinic","@@id":"/group-directory/tx-texas/mission/rio-grande-valley-emergency-phy-xr4j8p","name":"Rio Grande Valley Emergency Phy","address": {"@@type": "PostalAddress","streetAddress":"900 S Bryan Rd","addressLocality":"Mission","addressRegion":"TX","postalCode":"78572","addressCountry": "US"},"geo": {"@@type":"GeoCoordinates","latitude":"26.196392","longitude":"-98.314232"},"telephone":"(956) 580-9000","potentialAction":{"@@type":"ReserveAction","@@id":"/groupgoogleform/XR4J8P","url":"/groupgoogleform"}}' |
| 19 | OFFICEURL             | DVVRIBB631 | /group-directory/az-arizona/casa-grande/practice-xsjqlq | /group-directory/ny-new-york/brooklyn/practice-x7r2sf                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 47
- Snowflake: 47
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 458602
- Snowflake: 454175
- Rows Margin (%): 0.9653250530961487

### 2.3 Nulls per Column
|    | Column_Name               |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------|------------------------:|------------------------:|-------------:|
|  0 | PracticeID                |                       0 |                       0 |          0   |
|  1 | PracticeCode              |                       0 |                       0 |          0   |
|  2 | PracticeName              |                       0 |                       0 |          0   |
|  3 | YearPracticeEstablished   |                  452402 |                  450521 |          0.4 |
|  4 | NPI                       |                  458602 |                  454175 |          1   |
|  5 | PracticeWebsite           |                  455840 |                  454175 |          0.4 |
|  6 | PracticeDescription       |                  458602 |                  454175 |          1   |
|  7 | PracticeLogo              |                  456201 |                  453099 |          0.7 |
|  8 | PracticeMedicalDirector   |                  454902 |                  452475 |          0.5 |
|  9 | PracticeSoftware          |                  458602 |                  454175 |          1   |
| 10 | PracticeTIN               |                  458602 |                  454175 |          1   |
| 11 | OfficeID                  |                       0 |                       0 |          0   |
| 12 | OfficeCode                |                       0 |                       0 |          0   |
| 13 | OfficeName                |                  458591 |                   78851 |         82.8 |
| 14 | AddressTypeCode           |                       0 |                       0 |          0   |
| 15 | AddressLine1              |                       0 |                       0 |          0   |
| 16 | AddressLine2              |                  452792 |                  441802 |          2.4 |
| 17 | AddressLine3              |                  458602 |                  454175 |          1   |
| 18 | AddressLine4              |                  458602 |                  454175 |          1   |
| 19 | City                      |                       0 |                       0 |          0   |
| 20 | State                     |                       0 |                       0 |          0   |
| 21 | ZipCode                   |                       0 |                       0 |          0   |
| 22 | County                    |                   76640 |                  454175 |        492.6 |
| 23 | Nation                    |                       0 |                       0 |          0   |
| 24 | Latitude                  |                       6 |                       0 |        100   |
| 25 | Longitude                 |                       6 |                       0 |        100   |
| 26 | FullPhone                 |                     611 |                  110930 |      18055.5 |
| 27 | FullFax                   |                  100344 |                  243366 |        142.5 |
| 28 | HasBillingStaff           |                  458602 |                  454175 |          1   |
| 29 | HasHandicapAccess         |                  458602 |                  454175 |          1   |
| 30 | HasLabServicesOnSite      |                  458602 |                  454175 |          1   |
| 31 | HasPharmacyOnSite         |                  458602 |                  454175 |          1   |
| 32 | HasXrayOnSite             |                  458602 |                  454175 |          1   |
| 33 | IsSurgeryCenter           |                  458602 |                  454175 |          1   |
| 34 | HasSurgeryOnSite          |                  458602 |                  454175 |          1   |
| 35 | AverageDailyPatientVolume |                  458602 |                  454175 |          1   |
| 36 | PhysicianCount            |                       0 |                       0 |          0   |
| 37 | OfficeCoordinatorName     |                  458602 |                  454175 |          1   |
| 38 | ParkingInformation        |                  458602 |                  453959 |          1   |
| 39 | PaymentPolicy             |                  458602 |                  454175 |          1   |
| 40 | LegacyKeyOffice           |                  458602 |                  454175 |          1   |
| 41 | LegacyKeyPractice         |                  458602 |                  454175 |          1   |
| 42 | OfficeRank                |                  458602 |                  454175 |          1   |
| 43 | CityStatePostalCodeID     |                       0 |                       0 |          0   |
| 44 | HasDentist                |                       0 |                       0 |          0   |
| 45 | GoogleScriptBlock         |                  407309 |                       0 |        100   |
| 46 | OfficeURL                 |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name               |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |    Margin (%) |
|---:|:--------------------------|----------------------------:|----------------------------:|--------------:|
|  0 | PracticeID                |                      344442 |                      268384 |  22.1         |
|  1 | PracticeCode              |                      344442 |                      268384 |  22.1         |
|  2 | PracticeName              |                      263912 |                      205604 |  22.1         |
|  3 | YearPracticeEstablished   |                          95 |                          84 |  11.6         |
|  4 | NPI                       |                           0 |                           0 |   0           |
|  5 | PracticeWebsite           |                         170 |                           0 | 100           |
|  6 | PracticeDescription       |                           0 |                           0 |   0           |
|  7 | PracticeLogo              |                        2022 |                         883 |  56.3         |
|  8 | PracticeMedicalDirector   |                        3078 |                        1384 |  55           |
|  9 | PracticeSoftware          |                           0 |                           0 |   0           |
| 10 | PracticeTIN               |                           0 |                           0 |   0           |
| 11 | OfficeID                  |                      457474 |                      454175 |   0.7         |
| 12 | OfficeCode                |                      457474 |                      454175 |   0.7         |
| 13 | OfficeName                |                          11 |                      239230 |   2.17472e+06 |
| 14 | AddressTypeCode           |                           1 |                           1 |   0           |
| 15 | AddressLine1              |                      324380 |                      295170 |   9           |
| 16 | AddressLine2              |                        2171 |                        4338 |  99.8         |
| 17 | AddressLine3              |                           0 |                           0 |   0           |
| 18 | AddressLine4              |                           0 |                           0 |   0           |
| 19 | City                      |                        8804 |                        8567 |   2.7         |
| 20 | State                     |                          53 |                          53 |   0           |
| 21 | ZipCode                   |                       16373 |                       15824 |   3.4         |
| 22 | County                    |                        1567 |                           0 | 100           |
| 23 | Nation                    |                           1 |                           1 |   0           |
| 24 | Latitude                  |                      242565 |                      196066 |  19.2         |
| 25 | Longitude                 |                      246455 |                      194435 |  21.1         |
| 26 | FullPhone                 |                      338007 |                      305752 |   9.5         |
| 27 | FullFax                   |                      282089 |                      186706 |  33.8         |
| 28 | HasBillingStaff           |                           0 |                           0 |   0           |
| 29 | HasHandicapAccess         |                           0 |                           0 |   0           |
| 30 | HasLabServicesOnSite      |                           0 |                           0 |   0           |
| 31 | HasPharmacyOnSite         |                           0 |                           0 |   0           |
| 32 | HasXrayOnSite             |                           0 |                           0 |   0           |
| 33 | IsSurgeryCenter           |                           0 |                           0 |   0           |
| 34 | HasSurgeryOnSite          |                           0 |                           0 |   0           |
| 35 | AverageDailyPatientVolume |                           0 |                           0 |   0           |
| 36 | PhysicianCount            |                         702 |                         689 |   1.9         |
| 37 | OfficeCoordinatorName     |                           0 |                           0 |   0           |
| 38 | ParkingInformation        |                           0 |                         165 | inf           |
| 39 | PaymentPolicy             |                           0 |                           0 |   0           |
| 40 | LegacyKeyOffice           |                           0 |                           0 |   0           |
| 41 | LegacyKeyPractice         |                           0 |                           0 |   0           |
| 42 | OfficeRank                |                           0 |                           0 |   0           |
| 43 | CityStatePostalCodeID     |                       18128 |                       17613 |   2.8         |
| 44 | HasDentist                |                           2 |                           2 |   0           |
| 45 | GoogleScriptBlock         |                       51228 |                      454175 | 786.6         |
| 46 | OfficeURL                 |                      457842 |                      454175 |   0.8         |