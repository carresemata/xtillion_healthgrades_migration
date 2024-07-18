# Script to go over all procs in ODS1_STAGE and change a part of the proc with a regex


import os
import re

def raise_exception():
    base_dir = '/Users/carrese/Desktop/xtillion_healthgrades_migration-1/migration_original/ODS1_STAGE'
    for schema in ['BASE', 'MID', 'SHOW', 'UTILS']:
        schema_path = os.path.join(base_dir, schema)
        for table in os.listdir(schema_path):
            table_path = os.path.join(schema_path, table)

            if os.path.isfile(table_path):
                with open(table_path, 'r') as file:
                    content = file.read()

                # Regular expression to find `::integer;` and the following `return status;`
                pattern = r'(::integer;.*?return\s+status;)'
                matches = re.finditer(pattern, content, re.DOTALL)

                # Replace only the `return status;` that comes after `::integer;`
                for match in matches:
                    updated_text = match.group(1).replace('return status;', 'raise;')
                    content = content.replace(match.group(1), updated_text)

                with open(table_path, 'w') as file:
                    file.write(content)

raise_exception()
