import os
import pymssql
import snowflake.connector
import pandas as pd
import math
import uuid
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime


def load_external_dependencies(sql_server_connector, snowflake_connector, external_dependencies, save_format, output_dir, queue_dir) -> None:
    """
    This function loads external dependencies from SQL Server to Snowflake. It does so in the following steps:
    1. Purge the Snowflake Table Stage to avoid duplicates (i.e., REMOVE command)
    2. Upload raw files to Snowflake Stage (i.e., PUT command)
    3. Delete raw files locally
    4. Truncate Snowflake Table (i.e., TRUNCATE TABLE command)
    5. Load data from Snowflake Stage to Table (i.e., COPY INTO command)
    6. Update the queue file with remaining tables
    """
    snowflake_cursor = snowflake_connector.cursor()

    queue_file_path = os.path.join(queue_dir, "remaining_tables_queue.txt")
    with open(queue_file_path, 'w') as file:
        for table in external_dependencies:
            file.write(table + '\n') 

    remaining_tables = external_dependencies.copy()

    for table_name in external_dependencies:

        ######### ----------- To avoid duplicates, purge the Table Stage before uploading data ----------- #########
        schema, table = table_name.split('.')
        table_name_snowflake = schema + '_' + table  ### SNOWFLAKE NAMING CONVENTION IS DIFFERENT FROM SQL SERVER
        purge_query = f"REMOVE @%{table_name_snowflake};"
        snowflake_cursor.execute(purge_query)

        ######### ----------- Now we are ready to upload raw files ----------- #########
        rows_query = f"SELECT COUNT(*) FROM [{schema}].[{table}]"
        total_rows = pd.read_sql(rows_query, sql_server_connector)[''].values[0]

        if total_rows > 0:
            storage_query = f"""
                            SELECT 
                                t.NAME AS TableName,
                                s.Name AS SchemaName,
                                p.rows AS RowCounts,
                                CAST(SUM(a.total_pages) * 8 / 1024.0 / 1024.0 AS DECIMAL(18,2)) AS TotalSpaceGB,
                                CAST(SUM(a.used_pages) * 8 / 1024.0 / 1024.0 AS DECIMAL(18,2)) AS UsedSpaceGB,
                                CAST((SUM(a.total_pages) - SUM(a.used_pages)) * 8 / 1024.0 / 1024.0 AS DECIMAL(18,2)) AS UnusedSpaceGB
                            FROM sys.tables t
                            INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
                            INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
                            INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
                            LEFT OUTER JOIN sys.schemas s ON t.schema_id = s.schema_id
                            WHERE t.NAME = '{table}' AND s.Name = '{schema}'
                            GROUP BY t.Name, s.Name, p.Rows;
                            """
            
            # This query returns the total space in GB for the table. We should be careful with this
            # to prevent memory issues. Data is divided into ~1 GB chunks which pandas can handle reasonably well 
            total_gb = pd.read_sql(storage_query, sql_server_connector)['TotalSpaceGB'].values[0]

            if total_gb > 1:
                chunk_storage_size = 1  # in GB
                num_chunks = math.ceil(total_gb / chunk_storage_size)
                chunk_row_size = math.ceil(total_rows / num_chunks) # in rows
            else: # if the table is less than 1 GB, we don't need to chunk it
                num_chunks = 1
                chunk_row_size = total_rows

            schema_dir = os.path.join(output_dir, schema)
            if not os.path.exists(schema_dir):
                os.makedirs(schema_dir) 

            for chunk_num in range(num_chunks):
                offset = chunk_num * chunk_row_size
                
                # this query will return a subset of the source table data according to offset and chunk_row_size
                query = f"""SELECT * FROM [{schema}].[{table}]
                        ORDER BY (SELECT NULL) 
                        OFFSET {offset} ROWS 
                        FETCH NEXT {chunk_row_size} ROWS ONLY"""
                data = pd.read_sql(query, sql_server_connector)

                if save_format == 'parquet':  # UUID datatypes can be a bit finicky in pd parquet
                    for col in data.select_dtypes(include=['object']).columns:
                        if data[col].apply(lambda x: isinstance(x, uuid.UUID)).any():
                            data[col] = data[col].astype(str)
                    for col in data.select_dtypes(include=['datetime64']).columns:
                        data[col] = data[col].astype('datetime64[ms]')

                file_path = os.path.join(schema_dir, f"{table_name_snowflake.upper()}_chunk{chunk_num + 1}.{save_format}")

                if save_format == 'csv': data.to_csv(file_path, index=False)
                elif save_format == 'parquet':
                    data.to_parquet(file_path, engine='pyarrow', coerce_timestamps='ms', allow_truncated_timestamps=True)

                # ----------------------------- UPLOAD ---------------------------------
                try:
                    upload_query = f"PUT file://{file_path} @%{table_name_snowflake}"
                    snowflake_cursor.execute(upload_query)
                except:
                    pass # we could add a logger here but it will be different in AWS, leave for later

                # ---------------------- DELETE RAW DATA LOCALLY ------------------------
                os.remove(file_path) 

                # ---------------------- TRUNCATE SNOWFLAKE TABLE -----------------------
                try:
                    truncate_query = f"TRUNCATE TABLE {snowflake_connector.database}.{snowflake_connector.schema}.{table_name_snowflake}"
                    snowflake_cursor.execute(truncate_query)
                except:
                    pass # we could add a logger here but it will be different in AWS, leave for later

                # -------------------- LOAD DATA FROM STAGE TO TABLE --------------------
                if save_format == 'parquet':
                    copy_query = f"""COPY INTO {snowflake_connector.database}.{snowflake_connector.schema}.{table_name_snowflake}
                                    FROM @%{table_name_snowflake}
                                    FILE_FORMAT = (
                                        TYPE=PARQUET,
                                        REPLACE_INVALID_CHARACTERS=TRUE,
                                        BINARY_AS_TEXT=FALSE
                                    )
                                    MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE
                                    ON_ERROR=ABORT_STATEMENT
                                    PURGE=FALSE
                                    """
                elif save_format == 'csv':
                    copy_query =    f"""COPY INTO {snowflake_connector.database}.{snowflake_connector.schema}.{table_name_snowflake}
                                    FROM @%{table_name_snowflake}
                                    FILE_FORMAT = (
                                        TYPE=CSV,
                                        SKIP_HEADER=1,
                                        FIELD_DELIMITER=',',
                                        TRIM_SPACE=FALSE,
                                        FIELD_OPTIONALLY_ENCLOSED_BY=NONE,
                                        REPLACE_INVALID_CHARACTERS=TRUE,
                                        DATE_FORMAT=AUTO,
                                        TIME_FORMAT=AUTO,
                                        TIMESTAMP_FORMAT='YYYY-MM-DD HH24:MI:SS.FF'
                                    )
                                    ON_ERROR=ABORT_STATEMENT
                                    PURGE=FALSE
                                    """
                try:
                    snowflake_cursor.execute(copy_query)
                except:
                    pass # we could add a logger here but it will be different in AWS, leave for later
                    
            remaining_tables.remove(table_name)  # data successfully uploaded to Snowflake, remove from queue

            # update the queue file with remaining tables
            with open(queue_file_path, 'w') as file:
                for table in remaining_tables:
                    file.write(table + '\n')

    sql_server_connector.close()
    snowflake_connector.close()

    return None


### ----------------------------------- MAIN ----------------------------------- ###


sql_server = "hgTestmdmdb01.sql.hgw-test.aws.healthgrades.zone"
sql_server_username = "XT-OJimenez"
sql_server_password = ""
sql_server_db = "ERMart1"

snowflake_account = "OPA66287.us-east-1"  # HG-01 account
snowflake_username = "OJIMENEZ@RVOHEALTH.COM"
snowflake_warehouse = "MDM_XSMALL"
snowflake_db = "ODS1_STAGE_TEAM"
snowflake_schema = "ERMART1"
snowflake_role = "APP-SNOWFLAKE-HG-MDM-POWERUSER"

sql_server_connector = pymssql.connect(server=sql_server, user=sql_server_username, password=sql_server_password, database=sql_server_db)
snowflake_connector = snowflake.connector.connect(user=snowflake_username, account=snowflake_account, authenticator="externalbrowser",
                                                warehouse=snowflake_warehouse, database=snowflake_db, schema=snowflake_schema, role=snowflake_role)


external_dependencies = [
    'facility.award', 
    'facility.awardtomedicalterm', 
    'facility.facilityaddressdetail',
    'facility.facilitytoprocedurerating',
    'facility.facilitytorating',
    'facility.facility',
    'facility.facilitytotraumalevel',
    'facility.facilitytoaward',
    'facility.facsearchtype',
    'facility.facilityparentchild',
    'facility.facilitytoservicelinerating',
    'facility.facilitytomaternitydetail',
    'facility.facilitytosurvey',
    'facility.facilitytocertification',
    'facility.facilitytoprocessmeasures',
    'facility.facilitytoexeclevelteam',
    'facility.facilityawardmessage',
    'facility.hospitaldetail',
    'facility.procedure',
    'facility.procedureratingsnationalaverage',
    'facility.proceduretoserviceline',
    'facility.processmeasurescore',
    'facility.proceduretoaward',                    
    'facility.rating',
    'facility.statenationalprocedureratingsaverage',
    'facility.serviceline',
    'ref.processmeasure',
    'patientexperience.OPEAprovidertocohortrange',
    'patientexperience.OPEAAveragesbycohortrange'
]

save_format = "parquet"

queue_dir = "queue"
output_dir = "data"
if not os.path.exists(queue_dir): os.makedirs(queue_dir)
if not os.path.exists(output_dir): os.makedirs(output_dir)

######## ---------------- This is just an example of how it will look like in Airflow ---------------- ########
# Currently Airflow is unable to recognize my local file system, but the function runs fine in a local environment.
# In any case, this will change a lot when we move to AWS, so we shouldn't worry about this for now.

default_args = {
    'owner': 'Healthgrades MDM Team',
    'depends_on_past': False,
    'start_date': datetime(2022, 3, 10),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
}

args = (sql_server_connector, snowflake_connector, external_dependencies, save_format, output_dir, queue_dir)

dag = DAG(
    'external_dependencies',
    default_args=default_args,
    description='DAG to connect external dependencies from SQL Server to ODS1_Stage in Snowflake',
    schedule_interval='@daily'
)

ods1_external_dependencies = PythonOperator(
    task_id='external_dependencies',
    python_callable=load_external_dependencies,
    dag=dag,
    op_args=args
)

ods1_external_dependencies