import json
import re
import os

# Load the JSON file
with open('/Users/carrese/Desktop/output.json') as f:
    data = json.load(f)

# Initialize an empty dictionary to store the results
result = {}

# Function to change name to snake case
def format_name(name):
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

# Iterate over the list of stored procedures
for procedure in data:
    # Get the name of the stored procedure
    stored_procedure = procedure['stored_procedure']

    # Iterate over the findings within each stored procedure
    for finding in procedure['findings']:
        # If the target table is not None
        if '.' in finding['target']:
            # Extract the target table database applying the format_name function
            target_db = format_name(finding['target_db_schema'])
            # Extract the target table schema applying the format_name function, schema is first part of the table name before the dot
            target_schema = format_name(finding['target'].split('.')[0])
            # Extract the target table name applying the format_name function, table is second part of the table name after the dot
            target_table = format_name(finding['target'].split('.')[1])

            # If the target table is not already in the result dictionary, add it
            if (target_db, target_schema, target_table) not in result:
                result[(target_db, target_schema, target_table)] = []

            # Add the stored procedure to the list of stored procedures for the target table
            result[(target_db, target_schema, target_table)].append(stored_procedure)

# Print the result
# for key, value in result.items():
#   print(f'{key[0]}, {key[1]}, {key[2]} : {value}')

# Save result in csv file with columns database, schema, table, stored_procedures
import csv
with open('spus_update_tables.csv', 'w') as f:
    writer = csv.writer(f)
    writer.writerow(['database', 'schema', 'table', 'stored_procedures'])
    for key, value in result.items():
        writer.writerow([key[0], key[1], key[2], value])

# Add the result in the file spu_check_table.txt in the migration/ods1_stage/tables folder (only add when db is ods1_stage)
for key, value in result.items():
    if 'ods1' in key[0] :
        # navigate to migration/ods1_stage/tables folder and find folder name with the same name as the table name (key[2])
        # Construct the file path
        file_path = f'/Users/carrese/Desktop/xtillion_healthgrades_migration/migration/ods1_stage/tables/{key[1]}/{key[2]}/spu_check_{key[2]}.txt'

        # Check if the file exists
        if os.path.exists(file_path):
            # Open the file and write the unique list of stored procedures
            with open(file_path, 'w') as f:
                f.write('\n'.join(set(value)))