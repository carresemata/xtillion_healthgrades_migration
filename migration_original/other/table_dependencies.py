import os
import re
import json

def table_dependencies():
    # Define a dictionary to store the tables and their dependencies
    table_dependencies = {}

    # Define the base directories
    base_dirs = ['/Users/carrese/Desktop/xtillion_healthgrades_migration-1/migration_original/ODS1Stage/tables', 
                 '/Users/carrese/Desktop/xtillion_healthgrades_migration-1/migration_original/ODS1Stage/views'
                ]

    for base_dir in base_dirs:
        # Navigate to the directory
        os.chdir(base_dir)

        # For each schema
        for schema in os.listdir():
            os.chdir(schema)

            # For each table/view
            for table in os.listdir():
                os.chdir(table)
                # Check that the 'translated' file is not empty
                if os.path.getsize(f'spu_translated_{table}.sql') != 0:
                    with open(f'spu_translated_{table}.sql', 'r') as f:
                        content = f.read()
                        # Check if the section exists
                        match = re.search(r'0. Table dependencies(.*?)1.', content, re.DOTALL)
                        if match:
                            dependencies_section = match.group(1)
                            # Remove unwanted characters and split into lines
                            dependencies_section = dependencies_section.replace('---', '').replace('--', '').split(' ')
                            # Keep only the lines that have a '.' inside (Ex: schema.table)
                            dependencies = [dep.strip() for dep in dependencies_section if '.' in dep]
                            # Set all the dependencies to uppercase
                            dependencies = [dep.upper() for dep in dependencies]
                            # Assume the first item is the table name and the rest are the dependencies
                            table_name, *dependencies = dependencies
                            # Store the dependencies in the dictionary
                            table_dependencies[table_name] = dependencies

                os.chdir('..')

            os.chdir('..')


    # Check if there is a table inside the list of dependencies that is not in the items of the dictionary
    origin_tables = {} # Dictionary to store the tables with no dependencies
    for table_name, source_tables in table_dependencies.items():
        for source_table in source_tables:
            if source_table not in table_dependencies.keys():
                # Add source_table to dictionary
                origin_tables[source_table] = []
    
    # Add the origin_tables to the table_dependencies dictionary
    table_dependencies.update(origin_tables)

    # Order the table dependencies json by table_name
    table_dependencies = dict(sorted(table_dependencies.items()))

    
    # Print the table dependencies
    # print(json.dumps(table_dependencies, indent=4))
    # print(table_dependencies)

    # Navigate back to the original directory
    os.chdir('/Users/carrese/Desktop/xtillion_healthgrades_migration-1/migration_original/other')

    # Write the table dependencies to a JSON file
    with open('table_dependencies.json', 'w') as f:
        json.dump(table_dependencies, f, indent=4)




# Call the function
table_dependencies()