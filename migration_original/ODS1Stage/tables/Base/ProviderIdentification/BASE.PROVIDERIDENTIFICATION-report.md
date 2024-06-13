# Base.ProviderIdentification Report

## 1. Sample Validation

Percentage of Identical Columns: 75.00% (6/8).
Percentage of Different Columns: 25.00% (2/8).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name              | Match ID   | SQL Server Value                     | Snowflake Value                      |
|---:|:-------------------------|:-----------|:-------------------------------------|:-------------------------------------|
|  0 | PROVIDERIDENTIFICATIONID | AS7030125  | aa499084-e13d-4242-b8ee-aa5426a58228 | 717ce292-2a05-400c-a055-5dc99bf34f42 |
|  1 | PROVIDERID               | AS7030125  | 5a433272-426f-006e-0000-000000000000 | 3fc0a654-7dbf-4621-8683-7e487f4491e4 |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 8
- Snowflake: 8
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 2129047
- Snowflake: 2129180
- Rows Margin (%): 0.006246926441736608

### 2.3 Nulls per Column
|    | Column_Name              |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderIdentificationID |                       0 |                       0 |            0 |
|  1 | ProviderID               |                       0 |                       0 |            0 |
|  2 | IdentificationTypeID     |                       0 |                       0 |            0 |
|  3 | IdentificationValue      |                       0 |                       0 |            0 |
|  4 | EffectiveDate            |                 2129047 |                 2129180 |            0 |
|  5 | ExpirationDate           |                       1 |                       1 |            0 |
|  6 | SourceCode               |                       0 |                       0 |            0 |
|  7 | LastUpdateDate           |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name              |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderIdentificationID |                     2129047 |                     2129180 |            0 |
|  1 | ProviderID               |                     1544703 |                     1544826 |            0 |
|  2 | IdentificationTypeID     |                           1 |                           1 |            0 |
|  3 | IdentificationValue      |                     2128986 |                     2129119 |            0 |
|  4 | EffectiveDate            |                           0 |                           0 |            0 |
|  5 | ExpirationDate           |                         445 |                         445 |            0 |
|  6 | SourceCode               |                           1 |                           1 |            0 |
|  7 | LastUpdateDate           |                          26 |                          26 |            0 |