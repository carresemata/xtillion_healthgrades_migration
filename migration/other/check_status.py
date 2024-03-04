import os


def check_tables():
    # Navigate to the tables directory
    os.chdir('/Users/carrese/Documents/GitHub/xtillion_healthgrades_migration/migration/ods1_stage/tables')

    # For each schema
    for schema in os.listdir():
        print(f'        SCHEMA: {schema}')
        os.chdir(schema)

        # For each table
        for table in os.listdir():
            os.chdir(table)

            # Check the number of files in the table directory
            if len(os.listdir()) == 3:
                print(f'"{table}" has started the spu translation.')

            # Check if the spu_original file is empty
            if os.path.getsize(f'spu_original_{table}.sql') == 0:
                print(f'"{table}" has not parsed original spus.')

            os.chdir('..')

        os.chdir('..')

    # Navigate back to the original directory
    os.chdir('../../../..')

# Call the function
check_tables()