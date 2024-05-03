import os

def original_to_txt():
    base_dirs = ['/Users/carrese/Desktop/xtillion_healthgrades_migration-1/migration_original/ODS1Stage/tables',
                 '/Users/carrese/Desktop/xtillion_healthgrades_migration-1/migration_original/ODS1Stage/views']

    for base_dir in base_dirs:
        for schema in os.listdir(base_dir):
            schema_path = os.path.join(base_dir, schema)
            for table in os.listdir(schema_path):
                table_path = os.path.join(schema_path, table)
                file_path = os.path.join(table_path, f'spu_original_{table}.sql')
                
                # if filepath exists
                if os.path.exists(file_path):
                    # rename the file
                    os.rename(file_path, file_path.replace('.sql', '.txt'))

original_to_txt()