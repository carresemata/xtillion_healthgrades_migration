import json
import re
import os

# Load the JSON file
with open('/Users/carrese/Desktop/output.json') as f:
    data = json.load(f)

# Initialize an empty dictionary to store the results
result = {}


# Iterate over the list of stored procedures
for procedure in data:
    # Get the name of the stored procedure
    stored_procedure = procedure['stored_procedure']

    # Iterate over the findings within each stored procedure
    for finding in procedure['findings']:
        # If the target table is not None
        if '.' in finding['target']:
            # Extract the target table database 
            target_db = finding['target_db_schema']
            # Extract the target table schema, schema is first part of the table name before the dot
            target_schema = finding['target'].split('.')[0]
            # Extract the target table name applying the format_name function, table is second part of the table name after the dot
            target_table = finding['target'].split('.')[1]

            # If the target table is not already in the result dictionary, add it
            if (target_db, target_schema, target_table) not in result:
                result[(target_db, target_schema, target_table)] = []

            # Add the stored procedure to the list of stored procedures for the target table
            result[(target_db, target_schema, target_table)].append(stored_procedure)

# Print the result
#for key, value in result.items():
#   print(f'{key[0]}, {key[1]}, {key[2]} : {value}')

# Save result in csv file with columns database, schema, table, stored_procedures
import csv
with open('spus_update_tables.csv', 'w') as f:
    writer = csv.writer(f)
    writer.writerow(['database', 'schema', 'table', 'stored_procedures'])
    for key, value in result.items():
        # Write the database, schema, table and unique stored procedures to the file
        writer.writerow([key[0], key[1], key[2], ', '.join(set(value))])

# Add the result in the file spu_check_table.txt in the migration/ods1_stage/tables folder (only add when db is ods1_stage)
for key, value in result.items():
    if 'ods1' in key[0].lower():
        # navigate to migration/ods1_stage/tables folder and find folder name with the same name as the table name (key[2])
        # Construct the file path
        file_path = f'/Users/carrese/Desktop/xtillion_healthgrades_migration/migration_original/ODS1Stage/tables/{key[1]}/{key[2]}/spu_check_{key[2]}.txt'

        # Check if the file exists
        if os.path.exists(file_path):
            # Open the file and write the unique list of stored procedures
            with open(file_path, 'w') as f:
                f.write('\n'.join(set(value)))

# Modify the csv created to include the business_logic and lines columns
import pandas as pd
# Each row is a database, schema, table and its stored procedure, we split the stored procedures to have one per row
df = pd.read_csv('spus_update_tables.csv')
df['stored_procedures'] = df['stored_procedures'].str.split(', ')
df = df.explode('stored_procedures')
# Rename the stored_procedures column to spu_updating_table
df = df.rename(columns={'stored_procedures': 'spu_updating_table'})
# Update the database and schema columns to be lowercase
df['database'] = df['database'].str.lower()
df['schema'] = df['schema'].str.lower()
# Order the df by database, schema, table column
df = df.sort_values(by=['database', 'schema', 'table'])
# Keep only rows where database is ods1stage or snowflake
df = df[df['database'].str.lower().str.contains('ods1stage|snowflake')]
# Add two columns: business_logic, lines
df['business_logic'] = ''
df['lines_in_sql_server'] = ''
df.to_excel('business_logic.xlsx', index=False)

# Create csv for migration status
# Remove business_logic and lines columns
df = df.drop(columns=['business_logic', 'lines_in_sql_server'])
# Create new columns: migration_status, translation_status, check_status
df['migration_status'] = ''
df['translation_status'] = ''
df['check_status'] = ''
#Save as an excel
df.to_excel('migration_status.xlsx', index=False)