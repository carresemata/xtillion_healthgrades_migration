import pandas as pd
import json

# Your json data
with open('/Users/carrese/Desktop/formatted_output.json') as f:
    json_data = json.load(f)

# Initialize empty lists to collect data for the dataframe
databases = []
schemas = []
tables = []
stored_procedures = []
table_dependencies = []

# Iterate over the json data
for database in json_data:
    for table_info in json_data[database]:
        # Split the database information into database, schema, and table
        db_schema_table = database.lower().split('.')
        
        if len(db_schema_table) == 3:
            db, schema, table = db_schema_table
        elif len(db_schema_table) == 2:
            db = None  # or 'unknown' or any default value
            schema, table = db_schema_table
            
        databases.append(db)
        schemas.append(schema)
        tables.append(table)
        
        # Extract stored procedures
        sp_list = list(set([table_info["stored_procedure"].replace("_", ".").lower() for table_info in json_data[database]]))
        stored_procedures.append(sp_list)
        
        # Extract table dependencies
        dependencies_list = list(set([source["source_table"].lower() for table_info in json_data[database] for source in table_info["sources"]]))
        table_dependencies.append(dependencies_list)

# Now create the dataframe
df = pd.DataFrame({
    'database': databases,
    'schema': schemas,
    'table': tables,
    'status': ['']*len(databases), # empty status column
    'stored procedures': stored_procedures,
    'table dependencies': table_dependencies,
    'external table dependencies': ['']*len(databases) # empty external table dependencies column
})

# Filter df where db is snowflake or ods1stage only
df = df[df['database'].isin(['snowflake', 'ods1stage'])]

# Each row is a unique table so drop duplicates
df = df.drop_duplicates(subset=['database', 'schema', 'table']).reset_index(drop=True)

# Sort the dataframe by database, schema, and table
df = df.sort_values(['database', 'schema', 'table']).reset_index(drop=True)



# Save df as excel file in 2 sheets depending on schema name, if schema in: show, mid, base, raw or etl then save in sheet1 else in sheet2
with pd.ExcelWriter('/Users/carrese/Desktop/status_repo.xlsx') as writer:
    for schema in ['show', 'mid', 'base', 'raw', 'etl']:
        df_schema = df[df['schema'].str.lower() == schema]
        df_schema.to_excel(writer, sheet_name=schema, index=False)
    
    df_others = df[~df['schema'].str.lower().isin(['show', 'mid', 'base', 'raw', 'etl'])]
    df_others.to_excel(writer, sheet_name='others', index=False)

