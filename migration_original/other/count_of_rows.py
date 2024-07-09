
import json
import snowflake.connector

# Snowflake credentials
snowflake_account = "OPA66287.us-east-1"  # HG-01 account
snowflake_username = "ASANCHEZ@RVOHEALTH.COM"
snowflake_warehouse = "MDM_XSMALL"
snowflake_db = "ODS1_STAGE_TEAM"
snowflake_role = "APP-SNOWFLAKE-HG-MDM-POWERUSER"

# Establish connection
snowflake_connector = snowflake.connector.connect(user=snowflake_username, account=snowflake_account, authenticator="externalbrowser",
                                                    warehouse=snowflake_warehouse, database=snowflake_db, role=snowflake_role, arrow_number_to_decimal=True)

# Cursor to execute SQL queries
cur = snowflake_connector.cursor()

schemas =['BASE','MID','SHOW']
all_schemas_table_counts = {}

try:
    for schema in schemas:
            # SQL to get list of tables in the schema
            cur.execute(f"SHOW TABLES IN SCHEMA {snowflake_db}.{schema}")
            tables = cur.fetchall()

            # Dictionary to hold table row counts
            table_row_counts = {}

            # Iterate over tables and count rows
            for table_info in tables:
                table_name = table_info[1]  # Table name is in the second column
                cur.execute(f"SELECT COUNT(*) FROM {schema}.{table_name}")
                row_count = cur.fetchone()[0]
                table_row_counts[table_name] = row_count

            # Print the row counts
            all_schemas_table_counts[schema] = table_row_counts


finally:
    # Close the cursor and connection
    cur.close()

with open('table_row_counts.json', 'w') as f:
    json.dump(all_schemas_table_counts, f, indent=4)