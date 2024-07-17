import snowflake.connector
import pandas as pd
import json


def drop_unused_tables(snowflake_connector) -> None:
    """
    This function drops unused tables due to one of two reasons:
    1. Tables that fall outside the scope of the Xtillion project and are presumably updated by
    other ODS1Stage stored procedures (i.e., not the main jobs).
    2. Tables that may be empty in both SQL Server and Snowflake ODS1Stage 
    """

    snowflake_cursor = snowflake_connector.cursor()

    # Read the list of dependencies (JSON) that are part of the Xtillion project
    with open("audit_table_dependencies.json") as file:
        xtillion_dependencies = json.load(file)

    unique_keys = list(xtillion_dependencies.keys())
    values = [val for sublist in xtillion_dependencies.values() for val in sublist]
    unique_values = list(set(values))
    xtillion_tables = sorted(unique_keys + unique_values) # sort just for easier reading in print

    all_snowflake_tables_df = pd.read_sql("SHOW TABLES", snowflake_connector)
    all_snowflake_tables_list = [".".join([table_row["schema_name"], table_row["name"]]) for idx, table_row in all_snowflake_tables_df.iterrows()]

    #### We only want to drop Base, Mid, or Show Tables ####
    droppable_schemas = ["BASE", "MID", "SHOW"]

    ctr = 0 
    for full_table_name in all_snowflake_tables_list:
        schema = full_table_name.split(".")[0]
        table = full_table_name.split(".")[1]
        total_rows = pd.read_sql(f"SELECT COUNT(*) FROM {full_table_name}", snowflake_connector).iloc[0, 0]
        if schema in droppable_schemas and full_table_name not in xtillion_tables and total_rows == 0:
            drop_table_command = f"DROP TABLE IF EXISTS {full_table_name} CASCADE"
            try:
                snowflake_cursor.execute(drop_table_command)
                ctr += 1
            except:
                print(f"Error dropping table: {full_table_name}")
    print(f"Total tables dropped: {ctr}")


if __name__ == "__main__":

    snowflake_account = "OPA66287.us-east-1"  # HG-01 account
    snowflake_username = "OJIMENEZ@RVOHEALTH.COM"
    snowflake_warehouse = "MDM_XSMALL"
    snowflake_db = "ODS1_STAGE_TEAM"
    snowflake_role = "APP-SNOWFLAKE-HG-MDM-POWERUSER"

    snowflake_connector = snowflake.connector.connect(user=snowflake_username, account=snowflake_account, authenticator="externalbrowser",
                                                      warehouse=snowflake_warehouse, database=snowflake_db, role=snowflake_role)
    
    drop_unused_tables(snowflake_connector)