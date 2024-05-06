import os
import shutil

def delete_empty_folders():

    # Define the base directories
    base_dirs = [os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/tables'),
                    os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/views')]

    for base_dir in base_dirs:
        # Navigate to the directory: tables or views folder
        os.chdir(base_dir)

        # For each schema folder
        for schema in os.listdir():
            os.chdir(f'{base_dir}/{schema}')

            # For each table/view folder
            for table in os.listdir():
                os.chdir(f'{base_dir}/{schema}/{table}')
                # Check that the 'translated' file and the original file are empty, if the original file exists and is not empty
                if os.path.getsize(f'spu_translated_{table}.sql') == 0 and os.path.exists(f'spu_original_{table}.sql') and os.path.getsize(f'spu_original_{table}.sql') == 0:
                    # remove the folder
                    shutil.rmtree(os.getcwd())


            # if the schema folder is empty, delete it
            try:
                os.rmdir(f'{base_dir}/{schema}')
            except OSError as e:
                pass

        # # Navigate back to the original directory
        # os.chdir('../../../..')

# Call the function
delete_empty_folders()