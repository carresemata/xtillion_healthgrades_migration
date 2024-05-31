# Base.Practice Report

## 1. Sample Validation

Percentage of Identical Columns: 80.00% (16/20).
Percentage of Different Columns: 20.00% (4/20).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name    | Match ID   | SQL Server Value                     | Snowflake Value                      |
|---:|:---------------|:-----------|:-------------------------------------|:-------------------------------------|
|  0 | PRACTICEID     | UQC6TG     | 36435155-4754-0000-0000-000000000000 | af0b21a7-6b6c-42f8-9156-74efb0af27e0 |
|  1 | SOURCECODE     | UQC6TG     | Profisee                             | HGMD                                 |
|  2 | LASTUPDATEDATE | UQC6TG     | 2023-03-30 22:28:19.300              | 2015-10-19 11:38:17.000 -0700        |
|  3 | RELTIOENTITYID | UQC6TG     | 000242E5B6                           | None                                 |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 20
- Snowflake: 20
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 1580007
- Snowflake: 367946
- Rows Margin (%): 76.71238165400534

### 2.3 Nulls per Column
|    | Column_Name                     |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:--------------------------------|------------------------:|------------------------:|-------------:|
|  0 | PracticeID                      |                       0 |                       0 |          0   |
|  1 | PracticeCode                    |                       0 |                       0 |          0   |
|  2 | PracticeName                    |                       0 |                       0 |          0   |
|  3 | PracticeWebsite                 |                 1579584 |                  367946 |         76.7 |
|  4 | PracticeDescription             |                 1579526 |                  367946 |         76.7 |
|  5 | PracticeLogo                    |                 1569239 |                  366160 |         76.7 |
|  6 | PracticeMedicalDirector         |                 1561989 |                  365267 |         76.6 |
|  7 | PracticeSoftware                |                 1580007 |                  367946 |         76.7 |
|  8 | PracticeTIN                     |                 1580007 |                  367946 |         76.7 |
|  9 | LegacyKey                       |                 1580007 |                  367946 |         76.7 |
| 10 | LegacyKeyName                   |                 1580007 |                  367946 |         76.7 |
| 11 | SourceCode                      |                  973842 |                       0 |        100   |
| 12 | NPI                             |                 1576745 |                  367946 |         76.7 |
| 13 | YearPracticeEstablished         |                 1511892 |                  363291 |         76   |
| 14 | LastUpdateDate                  |                  973907 |                       0 |        100   |
| 15 | LastUpdateDateOverall           |                 1580006 |                  367946 |         76.7 |
| 16 | LastUpdateRuleTargetCodeOverall |                 1580007 |                  367946 |         76.7 |
| 17 | LastUpdateSourceCodeOverall     |                 1580007 |                  367946 |         76.7 |
| 18 | PracticeEmail                   |                 1580007 |                  367946 |         76.7 |
| 19 | ReltioEntityID                  |                       0 |                  367946 |        inf   |

### 2.4 Distincts per Column
|    | Column_Name                     |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:--------------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | PracticeID                      |                     1580007 |                      367946 |         76.7 |
|  1 | PracticeCode                    |                     1580007 |                      367946 |         76.7 |
|  2 | PracticeName                    |                      582560 |                      249918 |         57.1 |
|  3 | PracticeWebsite                 |                         220 |                           0 |        100   |
|  4 | PracticeDescription             |                         361 |                           0 |        100   |
|  5 | PracticeLogo                    |                        7300 |                        1564 |         78.6 |
|  6 | PracticeMedicalDirector         |                       12228 |                        2389 |         80.5 |
|  7 | PracticeSoftware                |                           0 |                           0 |          0   |
|  8 | PracticeTIN                     |                           0 |                           0 |          0   |
|  9 | LegacyKey                       |                           0 |                           0 |          0   |
| 10 | LegacyKeyName                   |                           0 |                           0 |          0   |
| 11 | SourceCode                      |                         185 |                         204 |         10.3 |
| 12 | NPI                             |                           2 |                           0 |        100   |
| 13 | YearPracticeEstablished         |                         133 |                          87 |         34.6 |
| 14 | LastUpdateDate                  |                        8744 |                      103796 |       1087.1 |
| 15 | LastUpdateDateOverall           |                           1 |                           0 |        100   |
| 16 | LastUpdateRuleTargetCodeOverall |                           0 |                           0 |          0   |
| 17 | LastUpdateSourceCodeOverall     |                           0 |                           0 |          0   |
| 18 | PracticeEmail                   |                           0 |                           0 |          0   |
| 19 | ReltioEntityID                  |                     1577160 |                           0 |        100   |