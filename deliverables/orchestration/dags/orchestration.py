
# Import necessary modules
from datetime import datetime
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
import json
import snowflake.connector

# Define default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 5, 10),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
}

# Define the DAG
dag = DAG(
    'dag_hg_demo',
    default_args=default_args,
    description='A simple DAG with complex dependencies',
    schedule_interval='@daily',
)

# Define a function to call a stored procedure in Snowflake
def call_stored_procedure(table_name):

    # Define the query to call the stored procedure
    query = f"CALL ODS1_STAGE.{table_name}()"

    # Define Snowflake connection parameters
    snowflake_account = "jab25078.us-east-1"  # HG-Ungoverned
    snowflake_username = "ASANCHEZ@RVOHEALTH.COM"
    snowflake_warehouse = "XITTILLION_M"
    snowflake_db = "ODS1_STAGE"
    snowflake_role = "APP-SNOWFLAKE-UNGOVERNED-XTILLION"

    # Connect to Snowflake
    snowflake_connector = snowflake.connector.connect(
        user=snowflake_username, 
        account=snowflake_account, 
        authenticator="externalbrowser",
        warehouse=snowflake_warehouse, 
        database=snowflake_db, 
        role=snowflake_role
        )
    
    # Execute the query
    snowflake_connector.cursor().execute(query)

    # Close the connection
    snowflake_connector.close()

# Define a function to create tasks in the DAG
def create_tasks(dag):

    # Load the dependencies from a JSON file
    with open('dags/data/traced_dependencies.json') as file:
        data = json.load(file)
    tasks = {}

    # First, instantiate all tasks
    for table in data.keys():
        task_id = f'{table}'
        task = PythonOperator(
            task_id=task_id,
            python_callable=call_stored_procedure,
            op_kwargs={'table_name': table},
            dag=dag
        )
        tasks[table] = task

    # Then, set up the dependencies
    for table, dependencies in data.items():
        for dependency in dependencies:
            if dependency in tasks:
                tasks[dependency] >> tasks[table]

# Create tasks in the DAG
create_tasks(dag)
