import snowflake.connector
import json
import os

snowflake_account = "OPA66287.us-east-1"  # Healthgrades account
snowflake_username = "ASANCHEZ@RVOHEALTH.COM"
snowflake_warehouse = "MDM_XSMALL"
snowflake_db = "ODS1_STAGE_TEAM"
snowflake_role = "APP-SNOWFLAKE-HG-MDM-POWERUSER"
snowflake_schemas = ['BASE', 'MID', 'SHOW']

# Directory to store the DDL files
ddl_directory = 'DDLs'

# Create the main DDL directory if it doesn't exist
if not os.path.exists(ddl_directory):
    os.makedirs(ddl_directory)

# Establish connection
conn = snowflake.connector.connect(
    user=snowflake_username,
    account=snowflake_account,
    authenticator="externalbrowser",
    warehouse=snowflake_warehouse,
    database=snowflake_db,
    role=snowflake_role
)

cur = conn.cursor()

try:
    for schema in snowflake_schemas:
        # Create schema subdirectory if it doesn't exist
        schema_directory = os.path.join(ddl_directory, schema)
        if not os.path.exists(schema_directory):
            os.makedirs(schema_directory)

        # SQL to get list of tables in the schema
        cur.execute(f"SHOW TABLES IN SCHEMA {snowflake_db}.{schema}")
        tables = cur.fetchall()
        print(f"Tables in {schema}: {len(tables)}")
        # Iterate over tables and get CREATE statements
        for table_info in tables:
            table_name = table_info[1]  # Table name is in the second column
            cur.execute(f"SELECT GET_DDL('TABLE', '{schema}.{table_name}')")
            create_statement = cur.fetchone()[0]

            # Write the CREATE statement to a file
            file_path = os.path.join(schema_directory, f"{table_name}.sql")
            with open(file_path, 'w') as f:
                f.write(create_statement)

finally:
    # Close the cursor and connection
    cur.close()
    conn.close()