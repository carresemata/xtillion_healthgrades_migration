import os
import re
import json

def table_dependencies():
    table_dependencies = {}
    base_dirs = [os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/tables')]
    prefixes = ['base.', 'mid.', 'show.', 'hosp_directory.', 'ermart1.']

    # Load view dependencies
    view_dependencies_path = os.path.join(os.path.dirname(os.getcwd()), 'other/views_dependencies.json')
    with open(view_dependencies_path, 'r') as f:
        view_dependencies = json.load(f)
    
    # test for one table Show.SolrProvider only
    for base_dir in base_dirs:
        os.chdir(base_dir)
        for schema in os.listdir():
            os.chdir(schema)
            for table in os.listdir():
                os.chdir(table)
                with open(f'spu_translated_{table}.sql', 'r') as f:
                    content = f.read()
                    match = re.search(r'statements(.*?)actions', content.lower(), re.DOTALL | re.IGNORECASE)
                    if match:
                        dependencies_section = match.group(1)
                        dependencies = []
                        for prefix in prefixes:
                            dependencies.extend(re.findall(r'\b' + re.escape(prefix) + r'\w*\b', dependencies_section))

                        # Convert dependencies to upper case and ensure they are unique
                        dependencies = list(set(dep.upper() for dep in dependencies))

                        # Exclude the table itself from its dependencies
                        table_key = f'{schema}.{table}'.upper()
                        dependencies = [dep for dep in dependencies if dep != table_key]
                        dependencies = [dep for dep in dependencies if 'TEMP' not in dep]

                        # Substitute view dependencies with actual tables
                        expanded_dependencies = []
                        for dep in dependencies:
                            if 'VW' in dep and dep in view_dependencies:
                                expanded_dependencies.extend(view_dependencies[dep])
                            else:
                                expanded_dependencies.append(dep)

                        table_dependencies[table_key] = list(set(expanded_dependencies))
                    else:
                        table_dependencies[f'{schema}.{table}'.upper()] = []

                os.chdir('..')
            os.chdir('..')
        os.chdir('..')

    # Save to audit_dependencies.json
    audit_dependencies_path = os.path.join(os.path.dirname(os.getcwd()), 'other/audit_table_dependencies.json')
    with open(audit_dependencies_path, 'w') as audit_file:
        json.dump(table_dependencies, audit_file, indent=4)

    # Create sp_dependencies.json where the empty dependencies are removed
    sp_dependencies = {table: deps for table, deps in table_dependencies.items() if deps}
    # remove all items that are not in keys
    sp_dependencies = {table: [dep for dep in deps if dep in sp_dependencies.keys()] for table, deps in sp_dependencies.items()}
    # I want to modify the table names to be schema.SP_LOAD_{table}, first split the table name by '.' and then join the parts
    sp_dependencies = {f'{table.split(".")[0]}.SP_LOAD_{table.split(".")[1]}' : [f'{dep.split(".")[0]}.SP_LOAD_{dep.split(".")[1]}' for dep in deps] for table, deps in sp_dependencies.items() }
    audit_sp_path = os.path.join(os.path.dirname(os.getcwd()), 'other/audit_sp_dependencies.json')
    # Save to audit_sp_dependencies.json in audit_dependencies_path location
    with open(audit_sp_path, 'w') as audit_file:
        json.dump(sp_dependencies, audit_file, indent=4)

    # Find static tables which are those in dependencies but not in keys
    # for each table in dependencies, check if it is in keys
    # if not, add it to static_tables
    static_tables = []
    for table, deps in table_dependencies.items():
        for dep in deps:
            if dep not in table_dependencies.keys():
                static_tables.append(dep)
    # order the static tables
    static_tables = sorted(list(set(static_tables)))
    # save to static_tables.txt
    static_tables_path = os.path.join(os.path.dirname(os.getcwd()), 'other/static_tables.txt')
    # remove the file if it exists and create a new one
    if os.path.exists(static_tables_path):
        os.remove(static_tables_path)
    with open(static_tables_path, 'w') as f:
        for table in static_tables:
            f.write(f'{table}\n')


table_dependencies()

    # Compare with json
    # path = os.path.join(os.path.dirname(os.getcwd()), 'other/table_dependencies.json')
    # with open(path, 'r') as f:
    #     table_dependencies_json = json.load(f)
    #     for table, deps in table_dependencies.items():
    #         if table in table_dependencies_json:
    #             json_deps = [dep for dep in table_dependencies_json[table] if not dep.startswith('MDM_TEAM')]
    #             if set(deps) != set(json_deps):
    #                 print(f'* {table} has different dependencies')
    #                 diff = set(deps).symmetric_difference(set(json_deps))
    #                 if diff:
    #                     print(diff)
    #             print()

