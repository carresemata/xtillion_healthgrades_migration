import os
import snowflake.connector

def get_root_directory() -> str:
    """
    This function returns the root directory of the project by looking for the README.md file.
    """
    current_dir = os.path.abspath(os.path.dirname(__file__))
    while not os.path.exists(os.path.join(current_dir, "README.md")):
        current_dir = os.path.dirname(current_dir)
    return current_dir

def execute_sql_files(snowflake_cursor, directory) -> None:
    """
    This function goes recursively through the project and executes all the SQL files found.
    """
    count_executed = 0
    for root, _, files in os.walk(directory):
        for file_name in files:
            if file_name.endswith(".sql"):
                file_path = os.path.join(root, file_name)
                with open(file_path, 'r') as file:
                    try:
                        sql_script = file.read()
                        snowflake_cursor.execute(sql_script)
                        count_executed += 1
                        #print(f"Executed SQL script: {file_path}")
                    except snowflake.connector.errors.ProgrammingError as e:
                        print(f"Error executing SQL script {file_path}: {str(e)}")
    print(f"Total SQL commands executed: {count_executed}")


if __name__ == "__main__":

    snowflake_account = "OPA66287.us-east-1"  # HG-01 account
    snowflake_username = "CARRESE@RVOHEALTH.COM"
    snowflake_warehouse = "MDM_XSMALL"
    snowflake_db = "ODS1_STAGE_TEAM"
    snowflake_role = "APP-SNOWFLAKE-HG-MDM-POWERUSER"

    snowflake_connector = snowflake.connector.connect(user=snowflake_username, account=snowflake_account, authenticator="externalbrowser",
                                                        warehouse=snowflake_warehouse, database=snowflake_db, role=snowflake_role)
    snowflake_cursor = snowflake_connector.cursor()

    project_root = get_root_directory()
    execute_sql_files(snowflake_cursor, project_root)