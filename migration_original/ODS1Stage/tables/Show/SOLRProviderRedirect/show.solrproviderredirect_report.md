# SHOW.SOLRPROVIDERREDIRECT Report

## 1. Sample Validation

Percentage of Identical Columns: 91.43% (32/35).
Percentage of Different Columns: 8.57% (3/35).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name            | Match ID   | SQL Server Value        | Snowflake Value               |
|---:|:-----------------------|:-----------|:------------------------|:------------------------------|
|  0 | SOLRPROVIDERREDIRECTID | 4BJML      | 445149                  | None                          |
|  1 | UPDATEDATE             | 4BJML      | 2020-01-12 13:11:16.397 | 2024-06-28 16:04:36.926 -0700 |
|  2 | UPDATESOURCE           | 4BJML      | dbo                     | CARRESE@RVOHEALTH.COM         |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 35
- Snowflake: 35
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 431259
- Snowflake: 241327
- Rows Margin (%): 44.041283776106695

### 2.3 Nulls per Column
|    | Column_Name            |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-----------------------|------------------------:|------------------------:|-------------:|
|  0 | SOLRProviderRedirectID |                       0 |                  241327 |        inf   |
|  1 | ProviderIDOld          |                  431258 |                  241327 |         44   |
|  2 | ProviderIDNew          |                  431258 |                  241327 |         44   |
|  3 | ProviderCodeOld        |                       0 |                       0 |          0   |
|  4 | ProviderCodeNew        |                       0 |                       0 |          0   |
|  5 | ProviderURLOld         |                       2 |                       1 |         50   |
|  6 | ProviderURLNew         |                  222290 |                  174173 |         21.6 |
|  7 | HGIDOld                |                  294244 |                  104371 |         64.5 |
|  8 | HGIDNew                |                  289985 |                  100113 |         65.5 |
|  9 | HGID8Old               |                  297743 |                  107869 |         63.8 |
| 10 | HGID8New               |                  297734 |                  107860 |         63.8 |
| 11 | LastName               |                      17 |                       0 |        100   |
| 12 | FirstName              |                      20 |                       1 |         95   |
| 13 | MiddleName             |                   86004 |                   52162 |         39.3 |
| 14 | Suffix                 |                  377835 |                  197584 |         47.7 |
| 15 | DisplayName            |                   40510 |                   40486 |          0.1 |
| 16 | Degree                 |                  344408 |                  241327 |         29.9 |
| 17 | Title                  |                  348356 |                  241327 |         30.7 |
| 18 | DegreePriority         |                  431259 |                  241327 |         44   |
| 19 | ProviderTypeID         |                  289112 |                  241327 |         16.5 |
| 20 | ProviderTypeGroup      |                  289099 |                  241327 |         16.5 |
| 21 | CityState              |                  431259 |                  241327 |         44   |
| 22 | SpecialtyCode          |                  431259 |                  241327 |         44   |
| 23 | SpecialtyLegacyKey     |                  431259 |                  241327 |         44   |
| 24 | DeactivationReason     |                       7 |                       7 |          0   |
| 25 | Gender                 |                  389617 |                  241327 |         38.1 |
| 26 | DateOfBirth            |                  379549 |                  241327 |         36.4 |
| 27 | PracticeOfficeXML      |                  324941 |                  241327 |         25.7 |
| 28 | SpecialtyXML           |                  355384 |                  241327 |         32.1 |
| 29 | EducationXML           |                  390268 |                  241327 |         38.2 |
| 30 | ImageXML               |                  431245 |                  241327 |         44   |
| 31 | ExpireCode             |                  431246 |                  241327 |         44   |
| 32 | LastUpdateDate         |                      14 |                       0 |        100   |
| 33 | UpdateDate             |                      14 |                       0 |        100   |
| 34 | UpdateSource           |                      14 |                       0 |        100   |

### 2.4 Distincts per Column
|    | Column_Name            |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-----------------------|----------------------------:|----------------------------:|-------------:|
|  0 | SOLRProviderRedirectID |                      431259 |                           0 |        100   |
|  1 | ProviderIDOld          |                           1 |                           0 |        100   |
|  2 | ProviderIDNew          |                           1 |                           0 |        100   |
|  3 | ProviderCodeOld        |                      431257 |                      241327 |         44   |
|  4 | ProviderCodeNew        |                      430737 |                      240832 |         44.1 |
|  5 | ProviderURLOld         |                      431247 |                      241321 |         44   |
|  6 | ProviderURLNew         |                      208477 |                       66685 |         68   |
|  7 | HGIDOld                |                      136886 |                      136830 |          0   |
|  8 | HGIDNew                |                      140713 |                      140660 |          0   |
|  9 | HGID8Old               |                      133512 |                      133455 |          0   |
| 10 | HGID8New               |                      133389 |                      133326 |          0   |
| 11 | LastName               |                      121905 |                       87807 |         28   |
| 12 | FirstName              |                       38305 |                       30030 |         21.6 |
| 13 | MiddleName             |                       28651 |                       19285 |         32.7 |
| 14 | Suffix                 |                          15 |                          22 |         46.7 |
| 15 | DisplayName            |                      344163 |                      164867 |         52.1 |
| 16 | Degree                 |                         307 |                           0 |        100   |
| 17 | Title                  |                           1 |                           0 |        100   |
| 18 | DegreePriority         |                           0 |                           0 |          0   |
| 19 | ProviderTypeID         |                           6 |                           0 |        100   |
| 20 | ProviderTypeGroup      |                           3 |                           0 |        100   |
| 21 | CityState              |                           0 |                           0 |          0   |
| 22 | SpecialtyCode          |                           0 |                           0 |          0   |
| 23 | SpecialtyLegacyKey     |                           0 |                           0 |          0   |
| 24 | DeactivationReason     |                           4 |                           4 |          0   |
| 25 | Gender                 |                           2 |                           0 |        100   |
| 26 | DateOfBirth            |                       17762 |                           0 |        100   |
| 27 | ExpireCode             |                           2 |                           0 |        100   |
| 28 | LastUpdateDate         |                        1945 |                        1831 |          5.9 |
| 29 | UpdateDate             |                         239 |                           1 |         99.6 |
| 30 | UpdateSource           |                          10 |                           1 |         90   |