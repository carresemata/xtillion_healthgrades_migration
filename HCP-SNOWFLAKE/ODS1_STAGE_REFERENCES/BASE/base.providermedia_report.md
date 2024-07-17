# BASE.PROVIDERMEDIA Report

## 1. Sample Validation

Percentage of Identical Columns: 0.00% (0/12).
Percentage of Different Columns: 0.00% (0/12).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

| Column Name   | Match ID   | SQL Server Value   | Snowflake Value   |
|---------------|------------|--------------------|-------------------|

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 12
- Snowflake: 12
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 239234
- Snowflake: 56984
- Rows Margin (%): 76.18064321960925

### 2.3 Nulls per Column
|    | Column_Name     |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:----------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderMediaID |                       0 |                       0 |          0   |
|  1 | ProviderID      |                       0 |                       0 |          0   |
|  2 | MediaTypeID     |                       0 |                       0 |          0   |
|  3 | MediaDate       |                    8450 |                    9115 |          7.9 |
|  4 | MediaTitle      |                     434 |                     454 |          4.6 |
|  5 | MediaPublisher  |                   38377 |                   41909 |          9.2 |
|  6 | MediaSynopsis   |                  232234 |                   49427 |         78.7 |
|  7 | MediaLink       |                   55550 |                   49169 |         11.5 |
|  8 | LegacyKey       |                  239234 |                   56984 |         76.2 |
|  9 | LegacyKeyName   |                  239234 |                   56984 |         76.2 |
| 10 | SourceCode      |                       0 |                       0 |          0   |
| 11 | LastUpdateDate  |                       0 |                       0 |          0   |

### 2.4 Distincts per Column
|    | Column_Name     |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:----------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderMediaID |                      239234 |                       56984 |         76.2 |
|  1 | ProviderID      |                       43154 |                       16273 |         62.3 |
|  2 | MediaTypeID     |                           7 |                           7 |          0   |
|  3 | MediaDate       |                       11729 |                        5862 |         50   |
|  4 | MediaTitle      |                      170858 |                       46354 |         72.9 |
|  5 | MediaPublisher  |                       14637 |                       10057 |         31.3 |
|  6 | MediaSynopsis   |                        6786 |                        7117 |          4.9 |
|  7 | MediaLink       |                      126295 |                        6872 |         94.6 |
|  8 | LegacyKey       |                           0 |                           0 |          0   |
|  9 | LegacyKeyName   |                           0 |                           0 |          0   |
| 10 | SourceCode      |                         124 |                         123 |          0.8 |
| 11 | LastUpdateDate  |                          25 |                          24 |          4   |