# BASE.ADDRESS Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/22).
Percentage of Different Columns: 0.00% (0/22).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 22
- Snowflake: 22
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 10545340
- Snowflake: 1489920
- Rows Margin (%): 85.87129480889189

### 2.3 Nulls per Column
|    | Column_Name           |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:----------------------|------------------------:|------------------------:|-------------:|
|  0 | AddressID             |                       0 |                       0 |          0   |
|  1 | CityStatePostalCodeID |                     669 |                       0 |        100   |
|  2 | NationID              |                  119245 |                       0 |        100   |
|  3 | AddressLine1          |                  204825 |                       0 |        100   |
|  4 | AddressLine2          |                10014252 |                 1449415 |         85.5 |
|  5 | AddressLine3          |                10545340 |                 1489920 |         85.9 |
|  6 | AddressLine4          |                10545340 |                 1489920 |         85.9 |
|  7 | ZIPPlus4              |                10545340 |                 1489920 |         85.9 |
|  8 | Latitude              |                   44973 |                       3 |        100   |
|  9 | Longitude             |                   44973 |                       3 |        100   |
| 10 | Suite                 |                 7419637 |                  752852 |         89.9 |
| 11 | LastUpdateDate        |                  250550 |                       0 |        100   |
| 12 | CASSErrors            |                10545340 |                 1489920 |         85.9 |
| 13 | CASSErrorDetails      |                10545340 |                 1489920 |         85.9 |
| 14 | AddressCleansedInd    |                  140626 |                       0 |        100   |
| 15 | GeocodeInd            |                  140626 |                       0 |        100   |
| 16 | StreetType            |                10545340 |                 1489920 |         85.9 |
| 17 | StreetNumber          |                10545340 |                 1489920 |         85.9 |
| 18 | StreetName            |                10545340 |                 1489920 |         85.9 |
| 19 | AddressCode           |                       0 |                 1489920 |        inf   |
| 20 | TimeZone              |                   65303 |                       0 |        100   |
| 21 | AddressInt            |                       0 |                 1489920 |        inf   |

### 2.4 Distincts per Column
|    | Column_Name           |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | AddressID             |                    10545340 |                     1489920 |         85.9 |
|  1 | CityStatePostalCodeID |                       75016 |                       32053 |         57.3 |
|  2 | NationID              |                           1 |                           1 |          0   |
|  3 | AddressLine1          |                     5687851 |                      855602 |         85   |
|  4 | AddressLine2          |                       63409 |                       14822 |         76.6 |
|  5 | AddressLine3          |                           0 |                           0 |          0   |
|  6 | AddressLine4          |                           0 |                           0 |          0   |
|  7 | ZIPPlus4              |                           0 |                           0 |          0   |
|  8 | Latitude              |                     2212331 |                      833333 |         62.3 |
|  9 | Longitude             |                     2668654 |                      826375 |         69   |
| 10 | Suite                 |                      174088 |                       58824 |         66.2 |
| 11 | LastUpdateDate        |                       40984 |                       43109 |          5.2 |
| 12 | CASSErrors            |                           0 |                           0 |          0   |
| 13 | CASSErrorDetails      |                           0 |                           0 |          0   |
| 14 | AddressCleansedInd    |                           1 |                           1 |          0   |
| 15 | GeocodeInd            |                           1 |                           1 |          0   |
| 16 | StreetType            |                           0 |                           0 |          0   |
| 17 | StreetNumber          |                           0 |                           0 |          0   |
| 18 | StreetName            |                           0 |                           0 |          0   |
| 19 | AddressCode           |                    10545339 |                           0 |        100   |
| 20 | TimeZone              |                          45 |                           9 |         80   |
| 21 | AddressInt            |                    10545340 |                           0 |        100   |