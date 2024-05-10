import pyodbc
import snowflake.connector
from tabulate import tabulate

# Configuration for SQL Server
sql_server_conn_str = 'DRIVER={ODBC Driver 17 for SQL Server};SERVER=your_server;DATABASE=your_db;UID=your_user;PWD=your_password'

# Configuration for Snowflake
snowflake_conn_info = {
    'user': 'your_user',
    'password': 'your_password',
    'account': 'your_account',
    'warehouse': 'your_warehouse',
    'database': 'your_db',
    'schema': 'your_schema'
}

def fetch_tables(conn):
    cursor = conn.cursor()
    query = """
    SHOW TABLES IN DATABASE {db} LIKE '%'
    """.format(db=snowflake_conn_info['database'])
    cursor.execute(query)
    tables = cursor.fetchall()
    cursor.close()
    return [table[1] for table in tables if table[2] in ['Base', 'Mid', 'Show']]

def generate_query(table_name, column_data, db_type):
    numerical_cols = [col for col, dtype in column_data.items() if dtype in ['int', 'float', 'decimal']]
    categorical_cols = [col for col, dtype in column_data.items() if dtype == 'varchar']

    common_num_cat_cols = numerical_cols + categorical_cols

    if db_type == 'sql_server':
        num_cat_query = f"""
        SELECT
            COUNT(*) AS row_count,
            {', '.join(f'COUNT({col}) - COUNT(NULLIF({col}, NULL)) AS null_{col}' for col in common_num_cat_cols)},
            {', '.join(f'AVG({col}) AS avg_{col}, SUM({col}) AS sum_{col}, MIN({col}) AS min_{col}, MAX({col}) AS max_{col}, STDEV({col}) AS std_{col}' for col in numerical_cols)},
            {', '.join(f'COUNT(DISTINCT {col}) AS distinct_{col}' for col in categorical_cols)},
            {', '.join(f'(SELECT TOP 1 {col} FROM {table_name} GROUP BY {col} ORDER BY COUNT(*) DESC) AS mode_{col}' for col in categorical_cols)}
        FROM
            {table_name};
        """
    elif db_type == 'snowflake':
        num_cat_query = f"""
        SELECT
            COUNT(*) AS row_count,
            {', '.join(f'COUNT({col}) - COUNT_IF({col} IS NOT NULL) AS null_{col}' for col in common_num_cat_cols)},
            {', '.join(f'AVG({col}) AS avg_{col}, SUM({col}) AS sum_{col}, MIN({col}) AS min_{col}, MAX({col}) AS max_{col}, APPROXIMATE_STDDEV({col}) AS std_{col}' for col in numerical_cols)},
            {', '.join(f'COUNT(DISTINCT {col}) AS distinct_{col}' for col in categorical_cols)},
            {', '.join(f'(SELECT {col} FROM {table_name} GROUP BY {col} ORDER BY COUNT(*) DESC LIMIT 1) AS mode_{col}' for col in categorical_cols)}
        FROM
            {table_name};
        """
    return num_cat_query

def fetch_metadata(conn, table_name):
    cursor = conn.cursor()
    cursor.execute(f"SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{table_name}'")
    column_data = {row[0]: row[1] for row in cursor.fetchall()}
    cursor.close()
    return column_data

def fetch_data(conn, query):
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()
    cursor.close()
    return result

def main():
    # Connect to Snowflake
    snowflake_conn = snowflake.connector.connect(**snowflake_conn_info)
    
    # Fetch the list of tables from Snowflake
    tables_to_validate = fetch_tables(snowflake_conn)

    # Connect to SQL Server
    sql_server_conn = pyodbc.connect(sql_server_conn_str)
    
    # Report data
    report = []

    for table in tables to_validate:
        print(f"Validating table: {table}")
        
        # Fetch column metadata from SQL Server (assuming schema is similar in Snowflake)
        column_data = fetch_metadata(sql_server_conn, table)

        # Generate queries
        query = generate_query(table, column_data, 'sql_server' if 'ODBC Driver' in sql_server_conn_str else 'snowflake')

        # Execute and fetch data
        ss_data = fetch_data(sql_server_conn, query)
        sf_data = fetch_data(snowflake_conn, query