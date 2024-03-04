import os
import pandas as pd

# Load the CSV file: df with the database, schema and table names for ods1stage
df = pd.read_csv('tables_ods1_stage.csv')

# Get the unique database names
databases = df['database_name'].unique().tolist()

# Get the unique schema names from the CSV file
schemas = df['schema_name'].unique().tolist()

# Define a dictionary to store schemas and their tables
tables = {}

# For each schema, get its associated tables
for schema in schemas:
    tables[schema] = df[df['schema_name'] == schema]['table_name'].unique().tolist()

# Create the main directory
os.makedirs('migration', exist_ok=True)
os.chdir('migration')

# Loop over the database, schemas, tables and create a directory for each one and two files (SQL and TXT)
for database in databases:
    os.makedirs(database, exist_ok=True)
    os.chdir(database)

    # OPTIONAL: Create a directory called tables to store all the tables for the current database
    os.makedirs('tables', exist_ok=True)
    os.chdir('tables')

    # Loop over the schemas for the current database and create a directory for each one
    for schema in schemas:
        os.makedirs(schema, exist_ok=True)
        os.chdir(schema)


        # Loop over tables for the current schema and create a directory for each one
        for table in tables[schema]:
            os.makedirs(table, exist_ok=True)
            os.chdir(table)

            # Create SQL and TXT files for each table
            open(f'spu_original_{table}.sql', 'a').close()
            open(f'spu_translated_{table}.sql', 'a').close()
            open(f'spu_check_{table}.txt', 'a').close()

            os.chdir('..')

        os.chdir('..')

    os.chdir('..')
