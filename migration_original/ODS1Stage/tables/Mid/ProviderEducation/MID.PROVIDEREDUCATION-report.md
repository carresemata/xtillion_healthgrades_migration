# Mid.ProviderEducation Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/11).
Percentage of Different Columns: 0.00% (0/11).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 11
- Snowflake: 11
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 1900247
- Snowflake: 1885879
- Rows Margin (%): 0.7561122317256651

### 2.3 Nulls per Column
|    | Column_Name                         |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:------------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToEducationInstitutionID    |                       0 |                       0 |          0   |
|  1 | ProviderID                          |                       0 |                       0 |          0   |
|  2 | EducationInstitutionName            |                       0 |                       0 |          0   |
|  3 | EducationInstitutionTypeCode        |                       0 |                       0 |          0   |
|  4 | EducationInstitutionTypeDescription |                       0 |                       0 |          0   |
|  5 | GraduationYear                      |                  397511 |                  392691 |          1.2 |
|  6 | PositionHeld                        |                 1900247 |                 1885879 |          0.8 |
|  7 | DegreeAbbreviation                  |                 1900247 |                 1885879 |          0.8 |
|  8 | City                                |                 1900247 |                 1885879 |          0.8 |
|  9 | State                               |                 1900247 |                 1885879 |          0.8 |
| 10 | NationName                          |                 1900247 |                 1885879 |          0.8 |

### 2.4 Distincts per Column
|    | Column_Name                         |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:------------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToEducationInstitutionID    |                     1900247 |                     1885879 |          0.8 |
|  1 | ProviderID                          |                     1141341 |                     1137859 |          0.3 |
|  2 | EducationInstitutionName            |                      204732 |                      204651 |          0   |
|  3 | EducationInstitutionTypeCode        |                           7 |                           8 |         14.3 |
|  4 | EducationInstitutionTypeDescription |                           7 |                           8 |         14.3 |
|  5 | GraduationYear                      |                         133 |                         133 |          0   |
|  6 | PositionHeld                        |                           0 |                           0 |          0   |
|  7 | DegreeAbbreviation                  |                           0 |                           0 |          0   |
|  8 | City                                |                           0 |                           0 |          0   |
|  9 | State                               |                           0 |                           0 |          0   |
| 10 | NationName                          |                           0 |                           0 |          0   |