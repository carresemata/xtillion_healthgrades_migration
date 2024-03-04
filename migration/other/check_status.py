import os
import pandas as pd

def check_table_status():
    # Initialize empty DataFrame
    df_output = pd.DataFrame(columns=['Schema', 'Table', 'SPU_Original_Is_Empty', 'Translation_Is_Empty'])

    # Navigate to the tables directory in ODS1STAGE
    os.chdir('migration/ods1stage/tables')

    # For each schema
    for schema in os.listdir():
        os.chdir(schema)

        # For each table
        for table in os.listdir():
            os.chdir(table)

            # Check if the spu_original file is empty
            spu_original_is_empty = os.path.getsize(f'spu_original_{table}.sql') == 0

            # Check if the translation is done (indicated by the presence of 3 files)
            translation_done = len(os.listdir()) == 3

            # Append the row to the DataFrame
            df_output = df_output.append({
                'Schema': schema,
                'Table': table,
                'SPU_Original_Is_Empty': spu_original_is_empty,
                'Translation_Exists': translation_done
            }, ignore_index=True)

            os.chdir('..')

        os.chdir('..')

    # Navigate back to the original directory
    os.chdir('../../../..')

    # Return the DataFrame
    return df_output

# Call the function and assign the resulting DataFrame to a variable
df_status = check_table_status()

# Print the DataFrame
print(df_status)