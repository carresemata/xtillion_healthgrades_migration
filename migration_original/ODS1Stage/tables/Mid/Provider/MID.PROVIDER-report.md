# MID.PROVIDER Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/31).
Percentage of Different Columns: 0.00% (0/31).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 31
- Snowflake: 31
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 6452915
- Snowflake: 6625923
- Rows Margin (%): 2.681082890445636

### 2.3 Nulls per Column
|    | Column_Name                              |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderID                               |                       0 |                       0 |          0   |
|  1 | ProviderCode                             |                       0 |                       0 |          0   |
|  2 | LegacyKey                                |                 6452915 |                 6625923 |          2.7 |
|  3 | ProviderTypeID                           |                       0 |                       0 |          0   |
|  4 | FirstName                                |                       2 |                       0 |        100   |
|  5 | MiddleName                               |                 1991639 |                 2088045 |          4.8 |
|  6 | LastName                                 |                       1 |                       0 |        100   |
|  7 | Suffix                                   |                 6334119 |                 6503167 |          2.7 |
|  8 | Gender                                   |                   88540 |                   18730 |         78.8 |
|  9 | NPI                                      |                   35732 |                   35729 |          0   |
| 10 | AMAID                                    |                 6452915 |                 6625923 |          2.7 |
| 11 | UPIN                                     |                 5598585 |                 6625923 |         18.3 |
| 12 | MedicareID                               |                 6452915 |                 6625923 |          2.7 |
| 13 | DEANumber                                |                 6452915 |                 6625923 |          2.7 |
| 14 | TaxIDNumber                              |                 6452915 |                 6625923 |          2.7 |
| 15 | DateOfBirth                              |                 4412041 |                 4531060 |          2.7 |
| 16 | PlaceOfBirth                             |                 6452915 |                 6625923 |          2.7 |
| 17 | CarePhilosophy                           |                 6215836 |                 6396962 |          2.9 |
| 18 | ProfessionalInterest                     |                 6452915 |                 6625923 |          2.7 |
| 19 | HasElectronicMedicalRecords              |                 6452915 |                 6625923 |          2.7 |
| 20 | HasElectronicPrescription                |                 6452915 |                 6625923 |          2.7 |
| 21 | AcceptsNewPatients                       |                 5411960 |                 5555124 |          2.6 |
| 22 | DegreeAbbreviation                       |                 2136554 |                 2180852 |          2.1 |
| 23 | Title                                    |                 4406206 |                 5709463 |         29.6 |
| 24 | ProviderLastUpdateDateOverall            |                   69840 |                       0 |        100   |
| 25 | ProviderLastUpdateDateOverallSourceTable |                   69840 |                       0 |        100   |
| 26 | ProviderURL                              |                       0 |                       2 |        inf   |
| 27 | ExpireCode                               |                 6452915 |                 6625923 |          2.7 |
| 28 | SearchBoostSatisfaction                  |                 5242274 |                 6625923 |         26.4 |
| 29 | SearchBoostAccessibility                 |                       0 |                 6625923 |        inf   |
| 30 | FFDisplaySpecialty                       |                 5785580 |                 6625923 |         14.5 |

### 2.4 Distincts per Column
|    | Column_Name                              |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderID                               |                     6452915 |                     6625923 |          2.7 |
|  1 | ProviderCode                             |                     6452915 |                     6522348 |          1.1 |
|  2 | LegacyKey                                |                           0 |                           0 |          0   |
|  3 | ProviderTypeID                           |                           4 |                           4 |          0   |
|  4 | FirstName                                |                      292283 |                      300452 |          2.8 |
|  5 | MiddleName                               |                      245807 |                      249525 |          1.5 |
|  6 | LastName                                 |                      807085 |                      820800 |          1.7 |
|  7 | Suffix                                   |                          13 |                          13 |          0   |
|  8 | Gender                                   |                           2 |                           2 |          0   |
|  9 | NPI                                      |                     6417175 |                     6486618 |          1.1 |
| 10 | AMAID                                    |                           0 |                           0 |          0   |
| 11 | UPIN                                     |                      853773 |                           0 |        100   |
| 12 | MedicareID                               |                           0 |                           0 |          0   |
| 13 | DEANumber                                |                           0 |                           0 |          0   |
| 14 | TaxIDNumber                              |                           0 |                           0 |          0   |
| 15 | DateOfBirth                              |                       26372 |                       26369 |          0   |
| 16 | PlaceOfBirth                             |                           0 |                           0 |          0   |
| 17 | CarePhilosophy                           |                      171875 |                      164829 |          4.1 |
| 18 | ProfessionalInterest                     |                           0 |                           0 |          0   |
| 19 | HasElectronicMedicalRecords              |                           0 |                           0 |          0   |
| 20 | HasElectronicPrescription                |                           0 |                           0 |          0   |
| 21 | AcceptsNewPatients                       |                           2 |                           2 |          0   |
| 22 | DegreeAbbreviation                       |                         678 |                         678 |          0   |
| 23 | Title                                    |                           1 |                           1 |          0   |
| 24 | ProviderLastUpdateDateOverall            |                        7652 |                           1 |        100   |
| 25 | ProviderLastUpdateDateOverallSourceTable |                        3976 |                           1 |        100   |
| 26 | ProviderURL                              |                     6452915 |                     6522472 |          1.1 |
| 27 | ExpireCode                               |                           0 |                           0 |          0   |
| 28 | SearchBoostSatisfaction                  |                         108 |                           0 |        100   |
| 29 | SearchBoostAccessibility                 |                          68 |                           0 |        100   |
| 30 | FFDisplaySpecialty                       |                          65 |                           0 |        100   |