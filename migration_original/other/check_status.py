import os


def check_tables():
    # Navigate to the tables directory
    os.chdir('/Users/carrese/Desktop/xtillion_healthgrades_migration/migration/ods1_stage/tables')

    # For each schema
    for schema in os.listdir():
        print(f'        SCHEMA: {schema}')
        os.chdir(schema)

        # For each table
        for table in os.listdir():
            os.chdir(table)
            # Check that the table is updated by at least one spu (if spu_check file is not empty)
            if os.path.getsize(f'spu_check_{table}.txt') != 0:
                
                # Check if the spu_translated file is not empty
                if os.path.getsize(f'spu_translated_{table}.sql') != 0:
                    print(f'"{table}": STEP 3 --> translation started.')

                # Check if the spu_original file is empty (not parsed)
                if os.path.getsize(f'spu_original_{table}.sql') == 0:
                    print(f'"{table}": STEP 1 --> parsing not started.')

                # Check if spu_orginial is not empty and spu_translated is empty (not translated)
                if os.path.getsize(f'spu_original_{table}.sql') != 0 and os.path.getsize(f'spu_translated_{table}.sql') == 0:
                    print(f'"{table}": STEP 2 --> parsing started but translation not started.')

            os.chdir('..')

        os.chdir('..')

    # Navigate back to the original directory
    os.chdir('../../../..')

# Call the function
check_tables()