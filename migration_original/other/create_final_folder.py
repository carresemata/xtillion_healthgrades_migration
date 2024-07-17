# This script is used to create the final folder for hcp Github.

import os
import shutil

# Path to the folder containing the tables
def create_final_folder():
    base_dir = os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/tables')
    # Make a new folder called ods1_stage
    os.makedirs('ODS1_STAGE', exist_ok=True)
    os.chdir('ODS1_STAGE')
    for schema in os.listdir(base_dir):
        schema_path = os.path.join(base_dir, schema)
        # Make folder for each schema in ods1_stage
        os.makedirs(schema.upper(), exist_ok=True)
        os.chdir(schema)
        for table in os.listdir(schema_path):
            table_path = os.path.join(schema_path, table)
            file_path = os.path.join(table_path, f'spu_translated_{table}.sql')
            # Copy the file to the new folder and rename it to schema.sp_load_table.sql and set the schema to lowercase
            shutil.copy(file_path, os.path.join(os.getcwd(), f'{schema.lower()}.sp_load_{table.lower()}.sql'))
        os.chdir('..')  # Go back to the parent directory before moving to the next schema
    os.chdir('..')  # Go back to the initial directory

    # Create a folder for the references
    os.makedirs('ODS1_STAGE_REFERENCES', exist_ok=True)
    os.chdir('ODS1_STAGE_REFERENCES')
    for schema in os.listdir(base_dir):
        schema_path = os.path.join(base_dir, schema)
        os.makedirs(schema.upper(), exist_ok=True)
        os.chdir(schema)
        for table in os.listdir(schema_path):
            table_path = os.path.join(schema_path, table)
            file_path1 = os.path.join(table_path, f'spu_check_{table}.txt')
            file_path2 = os.path.join(table_path, f'spu_original_{table}.txt')
            file_path3 = os.path.join(table_path, f'{schema.upper()}.{table.upper()}-report.md') or os.path.join(table_path, f'{schema.upper()}.{table.upper()}-report (1).md')
            shutil.copy(file_path1, os.path.join(os.getcwd(), f'{schema.lower()}.{table.lower()}_sp_original.txt'))
            shutil.copy(file_path2, os.path.join(os.getcwd(), f'{schema.lower()}.{table.lower()}_sp_original_code.txt'))
            if os.path.exists(file_path3):
                shutil.copy(file_path3, os.path.join(os.getcwd(), f'{schema.lower()}.{table.lower()}_report.md'))
        os.chdir('..')
    os.chdir('..')

create_final_folder()