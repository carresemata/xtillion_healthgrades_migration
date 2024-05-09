import os
import re
import json

def table_dependencies():
    table_dependencies = {}
    base_dirs = [os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/tables')]

    for base_dir in base_dirs:
        os.chdir(base_dir)
        for schema in os.listdir():
            os.chdir(schema)
            for table in os.listdir():
                os.chdir(table)
                with open(f'spu_translated_{table}.sql', 'r') as f:
                    content = f.read()
                    match = re.search(r'declare(.*?)end;', content, re.DOTALL|re.IGNORECASE)
                    if match:
                        dependencies_section = re.findall(r'(?:from|join)\s+(.*?)\s', match.group(1), re.IGNORECASE)
                        dependencies = [dep.strip().upper() for dep in dependencies_section if '.' in dep]
                        dependencies = [re.sub(r'[;,\(\)--]', '', dep) for dep in dependencies]
                        dependencies = [dep for dep in dependencies if not dep.startswith('CTE')]
                        table_dependencies[f'{schema}.{table}'.upper()] = dependencies
                    else:
                        table_dependencies[f'{schema}.{table}'.upper()] = []

                os.chdir('..')
            os.chdir('..')
        os.chdir('..')

    # Removing cycles
    for table_name, dependencies in table_dependencies.items():
        table_dependencies[table_name] = [dep for dep in dependencies if dep != table_name]

    # Compare with json
    path = os.path.join(os.path.dirname(os.getcwd()), 'other/table_dependencies.json')
    with open(path, 'r') as f:
        table_dependencies_json = json.load(f)
        for table, deps in table_dependencies.items():
            if table in table_dependencies_json:
                if set(deps) != set(table_dependencies_json[table]):
                    print(f'* {table} has different dependencies')
                    diff = set(deps).symmetric_difference(set(table_dependencies_json[table]))
                    if diff:
                        print(diff)
                print()

table_dependencies()