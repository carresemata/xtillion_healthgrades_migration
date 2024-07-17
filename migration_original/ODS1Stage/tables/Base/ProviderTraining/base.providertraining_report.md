# Base.ProviderTraining Report

## 1. Sample Validation

Percentage of Identical Columns: 50.00% (3/6).
Percentage of Different Columns: 50.00% (3/6).

The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.

|    | Column Name        | Match ID                                                                | SQL Server Value                     | Snowflake Value                      |
|---:|:-------------------|:------------------------------------------------------------------------|:-------------------------------------|:-------------------------------------|
|  0 | PROVIDERTRAININGID | https://www.outcarehealth.org/provider/listing/jenna-stack-lcmhca-lcasa | 4c7a1fe6-965d-497f-a373-535246db28a8 | 5dfb7591-79b0-48dd-9a81-2134288e0786 |
|  1 | PROVIDERID         | https://www.outcarehealth.org/provider/listing/jenna-stack-lcmhca-lcasa | 42395762-4149-0070-0000-000000000000 | 34ece493-8af3-4abd-aaa7-722094856745 |
|  2 | LASTUPDATEDATE     | https://www.outcarehealth.org/provider/listing/jenna-stack-lcmhca-lcasa | 2023-03-03 21:15:32.813              | 2023-03-03 21:15:32.813 -0800        |

## 2. Aggregate Validation

### 2.1 Total Columns
- SQL Server: 6
- Snowflake: 6
- Columns Margin (%): 0.0

### 2.2 Total Rows
- SQL Server: 4357
- Snowflake: 4376
- Rows Margin (%): 0.4360798714711958

### 2.3 Nulls per Column
|    | Column_Name        |   Total_Nulls_SQLServer |   Total_Nulls_Snowflake |   Margin (%) |
|---:|:-------------------|------------------------:|------------------------:|-------------:|
|  0 | ProviderTrainingID |                       0 |                       0 |            0 |
|  1 | ProviderID         |                       0 |                       0 |            0 |
|  2 | TrainingID         |                       0 |                       0 |            0 |
|  3 | TrainingLink       |                       0 |                       0 |            0 |
|  4 | SourceCode         |                       0 |                       0 |            0 |
|  5 | LastUpdateDate     |                       0 |                       0 |            0 |

### 2.4 Distincts per Column
|    | Column_Name        |   Total_Distincts_SQLServer |   Total_Distincts_Snowflake |   Margin (%) |
|---:|:-------------------|----------------------------:|----------------------------:|-------------:|
|  0 | ProviderTrainingID |                        4357 |                        4376 |          0.4 |
|  1 | ProviderID         |                        4357 |                        4376 |          0.4 |
|  2 | TrainingID         |                           2 |                           2 |          0   |
|  3 | TrainingLink       |                        4357 |                        4376 |          0.4 |
|  4 | SourceCode         |                           1 |                           1 |          0   |
|  5 | LastUpdateDate     |                          17 |                          17 |          0   |