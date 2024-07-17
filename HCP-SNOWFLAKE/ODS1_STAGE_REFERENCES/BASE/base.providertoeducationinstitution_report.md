# Base.ProviderToEducationInstitution Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/13).
Percentage of Different Columns: 0.00% (0/13).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 13
- Snowflake: 13
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 1895582
- Snowflake: 1885879
- Rows Margin (%): 0.5118744533341211

### 2.3 Nulls per Column
|    | Column_Name                      |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:---------------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderToEducationInstitutionID |                       0 |                       0 |          0   |
|  1 | ProviderRecordID                 |                 1895582 |                 1885879 |          0.5 |
|  2 | ProviderID                       |                       0 |                       0 |          0   |
|  3 | EducationInstitutionID           |                       0 |                       0 |          0   |
|  4 | EducationInstitutionTypeID       |                       0 |                       0 |          0   |
|  5 | DegreeID                         |                 1895582 |                 1885879 |          0.5 |
|  6 | GraduationYear                   |                  396680 |                  392691 |          1   |
|  7 | EducationYearsCount              |                 1895582 |                 1885879 |          0.5 |
|  8 | PositionHeld                     |                 1895582 |                 1885879 |          0.5 |
|  9 | LegacyKey                        |                 1895582 |                 1885879 |          0.5 |
| 10 | LegacyKeyName                    |                 1895582 |                 1885879 |          0.5 |
| 11 | SourceCode                       |                       0 |                       0 |          0   |
| 12 | LastUpdateDate                   |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name                      |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:---------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderToEducationInstitutionID |                     1895582 |                     1885879 |          0.5 |
|  1 | ProviderRecordID                 |                           0 |                           0 |          0   |
|  2 | ProviderID                       |                     1138479 |                     1137859 |          0.1 |
|  3 | EducationInstitutionID           |                      219498 |                      220137 |          0.3 |
|  4 | EducationInstitutionTypeID       |                           7 |                           8 |         14.3 |
|  5 | DegreeID                         |                           0 |                           0 |          0   |
|  6 | GraduationYear                   |                         133 |                         133 |          0   |
|  7 | EducationYearsCount              |                           0 |                           0 |          0   |
|  8 | PositionHeld                     |                           0 |                           0 |          0   |
|  9 | LegacyKey                        |                           0 |                           0 |          0   |
| 10 | LegacyKeyName                    |                           0 |                           0 |          0   |
| 11 | SourceCode                       |                         202 |                         201 |          0.5 |
| 12 | LastUpdateDate                   |                        3994 |                        3796 |          5   |