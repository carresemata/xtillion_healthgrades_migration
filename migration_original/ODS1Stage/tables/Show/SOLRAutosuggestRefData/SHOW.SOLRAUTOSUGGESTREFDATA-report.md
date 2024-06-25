# SHOW.SOLRAUTOSUGGESTREFDATA Report

## 1. Sample Validation

Percentage of Identical Columns: 60.00% (6/10).
Percentage of Different Columns: 40.00% (4/10).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name              | Match ID   | SQL Server Value                                                                                                                                                                                                                  | Snowflake Value                               |
|---:|:-------------------------|:-----------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------|
|  0 | SOLRAUTOSUGGESTREFDATAID | HPR0007C68 | d064cbba-0833-ef11-ba8d-0ed0be738343                                                                                                                                                                                              | 0e71264c-3c2d-4d74-a47c-664bb88bc05f          |
|  1 | UPDATEDDATE              | HPR0007C68 | 2024-06-25 09:36:46.763                                                                                                                                                                                                           | 2024-06-25 08:40:43.409 -0700                 |
|  2 | UPDATEDSOURCE            | HPR0007C68 | dbo                                                                                                                                                                                                                               | OJIMENEZ@RVOHEALTH.COM                        |
|  3 | RELATIONSHIPXML          | HPR0007C68 | <insuranceL><insurance><payorCd>HPY0000768</payorCd><payorNm>Anthem</payorNm><planCd>HPL0006D69</planCd><planNm>Pathway X (Small Grp)-CT</planNm><planTpCd>HPT0000407</planTpCd><planTpNm>PPO</planTpNm></insurance></insuranceL> | <insuranceL>                                  |
|    |                          |            |                                                                                                                                                                                                                                   |   <insurance>                                 |
|    |                          |            |                                                                                                                                                                                                                                   |     <payorCd>HPY0000768</payorCd>             |
|    |                          |            |                                                                                                                                                                                                                                   |     <payorNm>Anthem</payorNm>                 |
|    |                          |            |                                                                                                                                                                                                                                   |     <planCd>HPL0006D69</planCd>               |
|    |                          |            |                                                                                                                                                                                                                                   |     <planNm>Pathway X (Small Grp)-CT</planNm> |
|    |                          |            |                                                                                                                                                                                                                                   |     <planTpCd>HPT0000407</planTpCd>           |
|    |                          |            |                                                                                                                                                                                                                                   |     <planTpNm>PPO</planTpNm>                  |
|    |                          |            |                                                                                                                                                                                                                                   |   </insurance>                                |
|    |                          |            |                                                                                                                                                                                                                                   | </insuranceL>                                 |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 10
- Snowflake: 10
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 36370
- Snowflake: 36320
- Rows Margin (%): 0.13747594171020072

### 2.3 Nulls per Column
|    | Column_Name              |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------------|------------------------:|------------------------:|-------------:|
|  0 | SOLRAutosuggestRefDataID |                       0 |                       0 |          0   |
|  1 | Code                     |                       0 |                       0 |          0   |
|  2 | Description              |                   15990 |                   15969 |          0.1 |
|  3 | Definition               |                   36016 |                   35999 |          0   |
|  4 | Rank                     |                   35402 |                   35352 |          0.1 |
|  5 | TermID                   |                       0 |                       0 |          0   |
|  6 | AutoType                 |                       0 |                       0 |          0   |
|  7 | UpdatedDate              |                       0 |                       0 |          0   |
|  8 | UpdatedSource            |                       0 |                       0 |          0   |
|  9 | RelationshipXML          |                   18725 |                   18680 |          0.2 |

### 2.4 Distincts per Column
|    | Column_Name              |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | SOLRAutosuggestRefDataID |                       36370 |                       36320 |          0.1 |
|  1 | Code                     |                       36322 |                       36266 |          0.2 |
|  2 | Description              |                       17299 |                       17290 |          0.1 |
|  3 | Definition               |                          10 |                           9 |         10   |
|  4 | Rank                     |                         235 |                         235 |          0   |
|  5 | TermID                   |                       36325 |                       36274 |          0.1 |
|  6 | AutoType                 |                          27 |                          27 |          0   |
|  7 | UpdatedDate              |                           1 |                           2 |        100   |
|  8 | UpdatedSource            |                           1 |                           1 |          0   |