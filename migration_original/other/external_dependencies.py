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
     sql_server_cursor = sql_server_connector.cursor()

     queue_file_path = os.path.join(queue_dir, "remaining_tables_queue.txt")
     with open(queue_file_path, 'w') as file:
         for table in external_dependencies:
             file.write(table + '\n') 

     remaining_tables = external_dependencies.copy()

     for table_name in external_dependencies:
         
         db, schema, table = table_name.split('.')
         if db == 'ermart1' or db == 'hosp_directory':
            table_name_snowflake = schema + '_' + table  ### SNOWFLAKE NAMING CONVENTION IS DIFFERENT FROM SQL SERVER FOR ERMART1/HOSP_DIRECTORY
         else: 
            table_name_snowflake = table

         ######### ----------- Now we are ready to upload raw files ----------- #########
         sql_server_rows_query = f"SELECT COUNT(*) FROM [{db}].[{schema}].[{table}]"

         if schema in ('base', 'mid', 'show'):
            snowflake_rows_query = f"SELECT COUNT(*) FROM ODS1_STAGE_TEAM.{schema}.{table_name_snowflake}"
         elif db == 'ods1stage' and schema == 'dbo': #### We moved dbo tables to Base schema
            snowflake_rows_query = f"SELECT COUNT(*) FROM ODS1_STAGE_TEAM.BASE.{table_name_snowflake}"
         else: # for ERMART1 and HOSP_DIRECTORY
            snowflake_rows_query = f"SELECT COUNT(*) FROM ODS1_STAGE_TEAM.{db}.{table_name_snowflake}"
         total_rows_sql_server = pd.read_sql(sql_server_rows_query, sql_server_connector)[''].values[0]
         total_rows_snowflake = pd.read_sql(snowflake_rows_query, snowflake_connector).values[0][0]

         # only transfer data for tables that don't have data in Snowflake currently
         if total_rows_sql_server > 0 and total_rows_snowflake == 0:

             db_query = f"USE {db};"

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
             db_query = sql_server_cursor.execute(db_query)
             total_gb = pd.read_sql(storage_query, sql_server_connector)['TotalSpaceGB'].values[0]

             if total_gb > 1:
                 chunk_storage_size = 1  # in GB
                 num_chunks = math.ceil(total_gb / chunk_storage_size)
                 chunk_row_size = math.ceil(total_rows_sql_server / num_chunks) # in rows
             else: # if the table is less than 1 GB, we don't need to chunk it
                 num_chunks = 1
                 chunk_row_size = total_rows_sql_server

             schema_dir = os.path.join(output_dir, schema)
             if not os.path.exists(schema_dir):
                 os.makedirs(schema_dir) 

             for chunk_num in range(num_chunks):
                 offset = chunk_num * chunk_row_size

                 # this query will return a subset of the source table data according to offset and chunk_row_size
                 query = f"""SELECT * FROM [{db}].[{schema}].[{table}]
                         ORDER BY (SELECT NULL) 
                         OFFSET {offset} ROWS 
                         FETCH NEXT {chunk_row_size} ROWS ONLY"""
                 data = pd.read_sql(query, sql_server_connector)

                 if save_format == 'parquet':  # UUID datatypes can be a bit finicky in pd parquet
                     for col in data.select_dtypes(include=['object']).columns:
                         if data[col].apply(lambda x: isinstance(x, uuid.UUID)).any():
                             data[col] = data[col].astype(str)
                     for col in data.select_dtypes(include=['datetime64']).columns:
                         data[col] = data[col].astype(str) ### just throw varchar

                 file_path = os.path.join(schema_dir, f"{table_name_snowflake.upper()}_chunk{chunk_num + 1}.{save_format}")

                 if save_format == 'csv': data.to_csv(file_path, index=False)
                 elif save_format == 'parquet': data.to_parquet(file_path)

                 # ----------------------------- UPLOAD ---------------------------------
                 try:
                     # We need to setup Snowflake context in a separate query since we can't specify it in the PUT command
                     if db == 'ermart1': schema_query = f"USE SCHEMA ERMART1;"
                     elif db == 'hosp_directory': schema_query = f"USE SCHEMA HOSP_DIRECTORY;"
                     elif db == 'ods1stage' and schema == 'dbo': schema_query = f"USE SCHEMA BASE;"
                     else: schema_query = f"USE SCHEMA {schema};"
                     snowflake_cursor.execute(schema_query)

                     # To avoid duplicates, purge the Table Stage before uploading data
                     purge_query = f"REMOVE @%{table_name_snowflake};"
                     snowflake_cursor.execute(purge_query)

                     # Stage data
                     upload_query = f"PUT file://{file_path} @%{table_name_snowflake}"
                     snowflake_cursor.execute(upload_query)
                 except:
                     pass # we could add a logger here but it will be different in AWS, leave for later

                 # ---------------------- DELETE RAW DATA LOCALLY ------------------------
                 os.remove(file_path) 

                 # ---------------------- TRUNCATE SNOWFLAKE TABLE -----------------------
                 try:
                     truncate_query = f"TRUNCATE TABLE {table_name_snowflake}"
                     snowflake_cursor.execute(truncate_query)
                 except:
                     pass # we could add a logger here but it will be different in AWS, leave for later

                 # -------------------- LOAD DATA FROM STAGE TO TABLE --------------------
                 if save_format == 'parquet':
                     copy_query = f"""COPY INTO {table_name_snowflake}
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
                     copy_query =    f"""COPY INTO {table_name_snowflake}
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

snowflake_account = "OPA66287.us-east-1"  # HG-01 account
snowflake_username = "OJIMENEZ@RVOHEALTH.COM"
snowflake_warehouse = "MDM_XSMALL"
snowflake_db = "ODS1_STAGE_TEAM"
snowflake_role = "APP-SNOWFLAKE-HG-MDM-POWERUSER"

sql_server_connector = pymssql.connect(server=sql_server, user=sql_server_username, password=sql_server_password)
snowflake_connector = snowflake.connector.connect(user=snowflake_username, account=snowflake_account, authenticator="externalbrowser",
                                                   warehouse=snowflake_warehouse, database=snowflake_db, role=snowflake_role)


external_dependencies = [
    'ermart1.facility.rating',
    'ermart1.facility.awardtomedicalterm',
    'ermart1.facility.facilityaddressdetail',
    'ermart1.facility.facilitytoprocedurerating',
    'ermart1.facility.facilitytorating',
    'ermart1.facility.facility',
    'ermart1.facility.facilitytotraumalevel',
    'ermart1.facility.facilitytoaward',
    'ermart1.facility.facsearchtype',
    'ermart1.facility.facilityparentchild',
    'ermart1.facility.facilitytoservicelinerating',
    'ermart1.facility.facilitytomaternitydetail',
    'ermart1.facility.facilitytosurvey',
    'ermart1.facility.facilitytocertification',
    'ermart1.facility.facilitytoprocessmeasures',
    'ermart1.facility.facilitytoexeclevelteam',
    'ermart1.facility.facilityawardmessage',
    'ermart1.facility.hospitaldetail',
    'ermart1.facility.procedure',
    'ermart1.facility.procedureratingsnationalaverage',
    'ermart1.facility.proceduretoserviceline',
    'ermart1.facility.processmeasurescore',
    'ermart1.facility.proceduretoaward',
    'ermart1.facility.rating',
    'ermart1.facility.statenationalprocedureratingsaverage',
    'ermart1.facility.serviceline',
    'ermart1.ref.processmeasure',
    'ermart1.patientexperience.OPEAprovidertocohortrange',
    'ermart1.patientexperience.OPEAAveragesbycohortrange'
]

static_tables = [
    'ods1stage.base.aboutme',
    'ods1stage.base.addresstype',
    'ods1stage.base.affiliation',
    'ods1stage.base.appointmentavailability',
    'ods1stage.base.award',
    'ods1stage.base.awardcategory',
    'ods1stage.base.callcenter',
    'ods1stage.base.callcentertoemail',
    'ods1stage.base.callcentertophone',
    'ods1stage.base.callcentertype',
    'ods1stage.base.certificationagency',
    'ods1stage.base.certificationboard',
    'ods1stage.base.certificationspecialty',
    'ods1stage.base.certificationstatus',
    'ods1stage.base.clientfeature',
    'ods1stage.base.clientfeaturegroup',
    'ods1stage.base.clientfeaturevalue',
    'ods1stage.base.clientproductentitytoimage',
    'ods1stage.base.clientproductentitytourl',
    'ods1stage.base.clientproductimage',
    'ods1stage.base.clinicalfocus',
    'ods1stage.base.daysofweek',
    'ods1stage.base.displayspecialtyrule',
    'ods1stage.base.displayspecialtyruletocertificationspecialty',
    'ods1stage.base.displayspecialtyruletoclinicalfocus',
    'ods1stage.base.displayspecialtyruletospecialty',
    'ods1stage.base.displaystatus',
    'ods1stage.base.educationinstitution',
    'ods1stage.base.educationinstitutiontype',
    'ods1stage.base.email',
    'ods1stage.base.emailtype',
    'ods1stage.base.entitytype',
    'ods1stage.base.externaloaspartner',
    'ods1stage.base.facilitycheckinurl',
    'ods1stage.base.facilitytolanguage',
    'ods1stage.base.facilitytoservice',
    'ods1stage.base.facilitytype',
    'ods1stage.base.geographicarea',
    'ods1stage.base.geographicareatype',
    'ods1stage.base.healthinsurancepayor',
    'ods1stage.base.healthinsuranceplan',
    'ods1stage.base.healthinsuranceplantoplantype',
    'ods1stage.base.healthinsuranceplantype',
    'ods1stage.base.identificationtype',
    'ods1stage.base.imagetype',
    'ods1stage.base.language',
    'ods1stage.base.lineofservice',
    'ods1stage.base.lineofservicetype',
    'ods1stage.base.malpracticeclaimtype',
    'ods1stage.base.malpracticestate',
    'ods1stage.base.mediacontexttype',
    'ods1stage.base.mediaimagehost',
    'ods1stage.base.mediaimagetype',
    'ods1stage.base.mediareviewlevel',
    'ods1stage.base.mediasize',
    'ods1stage.base.mediatype',
    'ods1stage.base.mediavideohost',
    'ods1stage.base.medicalterm',
    'ods1stage.base.medicaltermset',
    'ods1stage.base.medicaltermtype',
    'ods1stage.base.message',
    'ods1stage.base.messagepage',
    'ods1stage.base.messagetomessagetoentitytopagetoyear',
    'ods1stage.base.messagetype',
    'ods1stage.base.moclevel',
    'ods1stage.base.mocpathway',
    'ods1stage.base.nation',
    'ods1stage.base.partnertype',
    'ods1stage.base.phonetype',
    'ods1stage.base.practiceemail',
    'ods1stage.base.product',
    'ods1stage.base.productgroup',
    'ods1stage.base.providerappointmentavailabilitystatement',
    # 'ods1stage.base.providercertification',
    'ods1stage.base.providerlegacykeys',
    'ods1stage.base.providerredirect',
    'ods1stage.base.providerremoval',
    'ods1stage.base.providerrole',
    'ods1stage.base.providersubtype',
    'ods1stage.base.providersubtypetodegree',
    'ods1stage.dbo.providersurveyaggregate',
    'ods1stage.base.providerswithsponsorshipissues',
    'ods1stage.base.providertoaffiliation',
    'ods1stage.base.providertoorganization',
    'ods1stage.base.providertype',
    'ods1stage.base.relationshiptype',
    'ods1stage.base.sanctionaction',
    'ods1stage.base.sanctionactiontype',
    'ods1stage.base.sanctioncategory',
    'ods1stage.base.sanctiontype',
    'ods1stage.base.service',
    'ods1stage.base.source',
    'ods1stage.base.specialty',
    'ods1stage.base.specialtygroup',
    'ods1stage.base.specialtygrouptospecialty',
    'ods1stage.base.specialtytocondition',
    'ods1stage.base.specialtytoproceduremedical',
    'ods1stage.base.state',
    'ods1stage.base.statereportingagency',
    'ods1stage.base.substatus',
    'ods1stage.base.surveysuppressionreason',
    'ods1stage.base.syndicationpartner',
    'ods1stage.base.telehealthmethodtype',
    'ods1stage.base.training',
    'ods1stage.base.treatmentlevel',
    'ods1stage.base.urltype',
    'ods1stage.mid.clientmarket',
    'ods1stage.mid.providersurveyresponse',
    'ods1stage.show.clientcontract',
    'ods1stage.show.consolidatedproviders',
    'ods1stage.show.delayclient',
    'ods1stage.show.providersourceupdate',
    'ods1stage.show.webfreeze'
]

all_tables = external_dependencies + static_tables

save_format = "parquet"

queue_dir = "queue"
output_dir = "data"
if not os.path.exists(queue_dir): os.makedirs(queue_dir)
if not os.path.exists(output_dir): os.makedirs(output_dir)

######## ---------------- This is just an example of how it will look like in Airflow ---------------- ########

default_args = {
    'owner': 'Healthgrades MDM Team',
    'depends_on_past': False,
    'start_date': datetime(2022, 3, 10),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
}

args = (sql_server_connector, snowflake_connector, all_tables, save_format, output_dir, queue_dir)

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