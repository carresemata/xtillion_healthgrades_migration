import os
import re
import json

def table_dependencies():
    # Define a dictionary to store the tables and their dependencies
    table_dependencies = {}

    # Define the base directories
    
    base_dirs = [os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/tables')]
                    # os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/views')]

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
                        match = re.search(r'1. table dependencies(.*?)2. ', content, re.DOTALL | re.IGNORECASE)
                        if match:
                            dependencies_section = match.group(1)
                            # Remove words inside brackets
                            dependencies_section = re.sub(r'\(.*?\)', '', dependencies_section)
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

    # ------ CHECK: UPDATE VIEWS DEPENDENCIES
    # Update the table_dependencies dictionary, when a table depends on a view change the view by the view dependencies
    # for table_name, source_tables in table_dependencies.items():
    #     for view in source_tables:
    #         if 'VW' in view:
    #             # Get the dependencies of the view
    #             view_dependencies = table_dependencies[view]
    #             # Remove the view from the source_tables
    #             source_tables.remove(view)
    #             # Add the view dependencies to the source_tables
    #             source_tables.extend(view_dependencies)
    #             #print table_name affected
    #             print(f'TABLE: {table_name}')
    #             print(f'VIEW: {view}')
    #             # print view dependencies each in a new line and with --- in the beginning
    #             view_dependencies = [f'--- {dep} ({view})' for dep in view_dependencies]
    #             print('\n'.join(view_dependencies))
    #             print('\n')

    # ------ CHECK: ADD ORIGIN TABLES
    # Check if there is a table inside the list of dependencies that is not in the items of the dictionary
    origin_tables = {} # Dictionary to store the tables with no dependencies
    for table_name, source_tables in table_dependencies.items():
        for source_table in source_tables:
            if source_table not in table_dependencies.keys() and 'VW' not in source_table : # remove views
                # Add source_table to dictionary
                origin_tables[source_table] = []
    
    # Add the origin_tables to the table_dependencies dictionary
    table_dependencies.update(origin_tables)

    # Order the table dependencies json by table_name
    table_dependencies = dict(sorted(table_dependencies.items()))

    # ------ CHECK: REMOVE CYCLES
    # Find the tables that are at the same time the source and the target of a dependency and print the table name
    for table_name, source_tables in table_dependencies.items():
        if table_name in source_tables:
            # remove the table_name from the source_tables
            source_tables.remove(table_name)
            # print(table_name)
    
    # ------ CHECK: REMOVE REPEATED ITEMS
    # Detect if a list of table dependencies has a repeated item
    # for table_name, table_dependencies in table_dependencies.items():
    #     if len(table_dependencies) != len(set(table_dependencies)):
    #         print(table_name)
    
    
    os.chdir('..')
    # Navigate back to the original directory to write the JSON file
    os.chdir(os.path.join(os.path.dirname(os.getcwd()), 'other'))

    # Write the table dependencies to a JSON file
    with open('table_dependencies.json', 'w') as f:
        json.dump(table_dependencies, f, indent=4)

    # Create sp_dependencies.json where the empty dependencies are removed
    sp_dependencies = {table: deps for table, deps in table_dependencies.items() if deps}
    # remove all items that are not in keys
    sp_dependencies = {table: [dep for dep in deps if dep in sp_dependencies.keys()] for table, deps in sp_dependencies.items()}
    # I want to modify the table names to be schema.SP_LOAD_{table}, first split the table name by '.' and then join the parts
    sp_dependencies = {f'{table.split(".")[0]}.SP_LOAD_{table.split(".")[1]}' : [f'{dep.split(".")[0]}.SP_LOAD_{dep.split(".")[1]}' for dep in deps] for table, deps in sp_dependencies.items() }
    with open('sp_dependencies.json', 'w') as f:
        json.dump(sp_dependencies, f, indent=4)



# Call the function
table_dependencies()