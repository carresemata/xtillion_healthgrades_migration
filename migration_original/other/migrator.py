# This script is a part of the SQL Server to Snowflake migration project. It contains the Migrator class
### DDL Migrator: create scheleton, load data from Sql server to Snowflake, create constraints, translate views...

import os
import re
import uuid
import logging
import math
from tqdm import tqdm
import pandas as pd
import numpy as np
import pymssql
import snowflake.connector
import sqlglot


class Translator(dict):
    def __init__(self, *args, **kwargs):
        super(Translator, self).__init__(*args, **kwargs)
        self.__dict__ = self

class SnowflakeDataTypeMapping(Translator):
    def __init__(self):
        super(SnowflakeDataTypeMapping, self).__init__({
        "BIGINT": "NUMBER",  # Precision and scale not to be specified when using Numeric.
        "BIT": "BOOLEAN",  # Recommended: Use NUMBER if migrating value-to-value to capture the actual BIT value.
        #"BIT": "NUMBER",  # Recommended: Use NUMBER if migrating value-to-value to capture the actual BIT value.
        "DECIMAL": "NUMBER",  # Default precision and scale are (38,0).
        "INT": "NUMBER",  # Precision and scale not to be specified when using Numeric.
        "MONEY": "NUMBER(19,4)",  # Money has a range of 19 digits with a scale of 4 digits.
        "NUMERIC": "NUMBER",  # Default precision and scale are (38,0).
        "SMALLINT": "NUMBER",  # Default precision and scale are (38,0).
        "SMALLMONEY": "NUMBER(10,4)",  # NUMBER with precision of 10 digits and a scale of 4.
        "TINYINT": "NUMBER",  # Default precision and scale are (38,0).
        "FLOAT": "FLOAT",  # Snowflake uses double-precision (64-bit) IEEE 754 floating point numbers.
        "REAL": "FLOAT",  # The ISO synonym for REAL is FLOAT(24).
        # "DATE": "DATE",  # Default in SQL Server is YYYY-MM-DD.
        # "DATETIME2": "TIMESTAMP_NTZ",  # Snowflake: TIMESTAMP with no time zone, precision of up to 9 digits.
        # "DATETIME": "DATETIME",  # SQL Server's datetime, not ANSI compliant, storage size is 8 bytes.
        # "DATETIMEOFFSET": "TIMESTAMP_LTZ",  # Up to 34,7 in precision, scale.
        # "SMALLDATETIME": "DATETIME",  # SmallDateTime is not ANSI compliant, fixed 4 bytes storage space.
        "DATE": "VARCHAR",  # Default in SQL Server is YYYY-MM-DD.
        "DATETIME2": "VARCHAR",  # Snowflake: TIMESTAMP with no time zone, precision of up to 9 digits.
        "DATETIME": "VARCHAR",  # SQL Server's datetime, not ANSI compliant, storage size is 8 bytes.
        "DATETIMEOFFSET": "VARCHAR",  # Up to 34,7 in precision, scale.
        "SMALLDATETIME": "VARCHAR",  # SmallDateTime is not ANSI compliant, fixed 4 bytes storage space.
        "TIME": "TIME",  # SQL Server precision of 7 nanoseconds, Snowflake precision of 9 nanoseconds.
        "CHAR": "VARCHAR",  # Any set of strings shorter than the maximum length is not space-padded.
        "TEXT": "VARCHAR",  # Discontinued in SQL Server, use NVARCHAR, VARCHAR, or VARBINARY instead.
        "VARCHAR": "VARCHAR",  # Any set of strings shorter than the maximum length is not space-padded.
        "NCHAR": "VARCHAR",  # Used on fixed-length-string data.
        "NTEXT": "VARCHAR",  # Discontinued in SQL Server, use NVARCHAR, VARCHAR, or VARBINARY instead.
        "NVARCHAR": "VARCHAR(4000)",  # NVARCHAR's string length can range from 1 to 4000.
        "BINARY": "BINARY",  # Snowfake: maximum length is 8 MB.
        "IMAGE": "VARCHAR",  # ------ Unlikely to appear but TOCHECK!!!!!!!!!! DEFAULT: N/A -------
        "VARBINARY": "BINARY",  # Snowflake: maximum length is 8 MB.
        "UNIQUEIDENTIFIER": "VARCHAR",  # ------ This is what phdata uses in their transpiler. TOCHECK!!!!!!!!!! DEFAULT: N/A -------
        "TIMESTAMP": "VARCHAR", # ------ This is what phdata uses in their transpiler. TOCHECK!!!!!!!!!! Something else might make more sense -------
        "XML": "VARIANT",
        "GEOGRAPHY": "GEOMETRY" # ------ This data type exists in Snowflake but appears to be somewhat different from SQL Server. VARCHAR for now -------
        })


class SnowflakeFunctionMapping(Translator):
    def __init__(self):
        super(SnowflakeFunctionMapping, self).__init__({ 
        "user_name()" : "CURRENT_USER()",
        "suser_name()" : "CURRENT_USER()",
        "original_login()" : "CURRENT_USER()",
        "sysdatetime()" : "CURRENT_TIMESTAMP()", 
        "getdate()" : "CURRENT_TIMESTAMP()",
        "getutcdate()" : "SYSDATE()", 
        "sysutcdatetime()" : "SYSDATE()",
        "newsequentialid()": "UUID_STRING()", # I thought maybe autoincrement here but doc suggest no difference between this and newid()
        "newid()" : "UUID_STRING()"
        })


# This is just in case later on if we want to define a Migrator class and have different types of migrators
# for now I'm putting all the logic inside the SnowflakeMigrator class.
class Migrator: 
    pass

class SnowflakeMigrator(Migrator):
    def __init__(self, sql_server_connector, snowflake_connector):
        self.sql_server_connector = sql_server_connector
        self.sql_server_cursor = self.sql_server_connector.cursor(as_dict=True)
        self.snowflake_connector = snowflake_connector
        self.snowflake_cursor = self.snowflake_connector.cursor()
        self.sql_server_to_snowflake_mapping = SnowflakeDataTypeMapping()
        self.sql_server_to_snowflake_fn_mapping = SnowflakeFunctionMapping()
        self.mapped_data_types = self.map_data_types()
        self.save_format = 'parquet'  
        self.all_schema_names = []
        self.all_table_names = []
        self.all_views_names = []
        self.convert_to_snake_case = False # this is bad practice but what client wants

    def get_sql_server_db_skeleton(self) -> pd.DataFrame:
        """
        This functions return a skeleton of the TABLES in the db where each row represents a column in a table.
        The columns of the df are: TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE. 
        NOTE: We are not considering views for now.
        """
        query = """SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, COLUMN_DEFAULT,
                          CHARACTER_MAXIMUM_LENGTH, DATETIME_PRECISION
                    FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_SCHEMA NOT IN ('sys')
                    AND TABLE_NAME NOT IN (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS)"""
        df = pd.read_sql(query, self.sql_server_connector)
        df = df.rename(columns={'TABLE_SCHEMA': 'DB_SCHEMA'}) # schemas are db level objects, table_schema feels weird
        df['TABLE_FULL_NAME'] = df['DB_SCHEMA'] + '.' + df['TABLE_NAME']
        self.all_schema_names = df['DB_SCHEMA'].unique().tolist()
        self.all_table_names = df['TABLE_FULL_NAME'].unique().tolist()

        return df
    
    def get_sql_server_db_views_skeleton(self) -> pd.DataFrame:
        """
        This functions return a skeleton of the VIEWS in the db where each row represents a column in a table.
        The columns of the df are: TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE. 
        """
        views_query = """SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE
                        FROM INFORMATION_SCHEMA.COLUMNS
                        WHERE TABLE_SCHEMA NOT IN ('sys')
                        AND TABLE_NAME IN (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS)"""
        views_df = pd.read_sql(views_query, self.sql_server_connector)
        # schemas are db level objects, table_schema feels weird
        views_df = views_df.rename(columns={'TABLE_SCHEMA': 'DB_SCHEMA', 'TABLE_NAME': 'VIEW_NAME', 'TABLE_FULL_NAME': 'VIEW_FULL_NAME'})
        views_df['VIEW_FULL_NAME'] = views_df['DB_SCHEMA'] + '.' + views_df['VIEW_NAME']
        self.all_views_names = views_df['VIEW_FULL_NAME'].unique().tolist()

        return views_df

    def get_sql_server_db_datatypes(self) -> list:
        """
        This function returns a list of unique datatypes in the connected SQL Server database.
        """
        return [elem.upper() for elem in set(self.get_sql_server_db_skeleton()['DATA_TYPE'].values)]

    def map_data_types(self) -> pd.DataFrame:
        """
        This function maps the SQL Server datatypes to Snowflake datatypes using DataTypeMapping class.
        """
        df = self.get_sql_server_db_skeleton().copy()
        df['DATA_TYPE'] = df['DATA_TYPE'].str.upper()
        df['DATA_TYPE'] = df['DATA_TYPE'].map(self.sql_server_to_snowflake_mapping)
        return df

    def get_missing_datatypes(self) -> list:
        """
        This function returns a list of datatypes that are in the SQL Server database but not in the dictionary mapping.
        """
        handbook_datatypes = list(self.sql_server_to_snowflake_mapping.keys())
        missing_datatypes = [datatype for datatype in self.get_sql_server_db_datatypes() if datatype not in handbook_datatypes]
        return missing_datatypes
    
    def format_to_snake_case(self, name) -> str:
        """
        This functions adjusts the table name to snake case format.
        """
        s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
        return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

    def test_missing_datatypes(self) -> None:
        """
        This unit test checks if there are any missing datatypes in the dictionary mapping that are in the SQL Server database.
        """
        missing_datatypes = self.get_missing_datatypes()
        if not missing_datatypes:
            print("Unit test passed: All datatypes are in the mapping!")
        else:
            print(f"Missing datatypes: {missing_datatypes} in the dictionary mapping")

    def test_mapping(self) -> None:
        """
        This unit test checks if the datatypes after mapping are all valid in Snowflake.
        """
        mapped_df_datatypes = set(self.map_data_types()['DATA_TYPE'].values)
        if all(datatype in self.sql_server_to_snowflake_mapping.values() for datatype in mapped_df_datatypes):
            print("Unit test passed: All datatypes are valid in Snowflake! Workflow is ready for migration.")
        else:
            print(f"Some datatypes in {mapped_df_datatypes} are not valid Snowflake datatypes")

    def get_create_schema_commands(self) -> list:
        """
        This function returns a list of CREATE SCHEMA commands for the migration in Snowflake.
        """
        create_schema_query_list = []
        for db_schema, _ in self.mapped_data_types.groupby(['DB_SCHEMA']):
            schema_name = self.format_to_snake_case(db_schema) if self.convert_to_snake_case else db_schema
            schema_query = f"CREATE SCHEMA IF NOT EXISTS {schema_name};"
            create_schema_query_list.append(schema_query)
        return create_schema_query_list

    def get_create_table_commands(self) -> list:
        """
        This function returns a list of CREATE TABLE commands for the migration in Snowflake. The query
        contains information about the default value of the column if it exists.
        """
        create_table_query_list = []
        for (db_schema, table_name), group in self.mapped_data_types.groupby(['DB_SCHEMA', 'TABLE_NAME']):
            table_name = self.format_to_snake_case(table_name) if self.convert_to_snake_case else table_name
            schema_name = self.format_to_snake_case(db_schema) if self.convert_to_snake_case else db_schema 
            #table_schema_query = f"CREATE TABLE IF NOT EXISTS {schema_name}.{table_name} (\n" 
            table_schema_query = f"CREATE OR REPLACE TABLE {schema_name}.{table_name} (\n" 
            columns = []
            for _, row in group.iterrows():
                column_name = row['COLUMN_NAME']
                column_name = self.format_to_snake_case(column_name) if self.convert_to_snake_case else column_name
                data_type = row['DATA_TYPE']
                # for some reason you can have a VARCHAR with more length in SQL Server than Snowflake? TOCHECK
                if data_type == 'VARCHAR' and row['CHARACTER_MAXIMUM_LENGTH'] > 0 and row['CHARACTER_MAXIMUM_LENGTH'] < 16777216: 
                    data_type = f"{data_type}({int(row['CHARACTER_MAXIMUM_LENGTH'])})"
                #elif data_type == 'TIMESTAMP_NTZ' or data_type == 'TIMESTAMP_LTZ':
                elif data_type == 'TIMESTAMP_NTZ' or data_type == 'TIMESTAMP_LTZ' or data_type == 'DATETIME':
                    data_type = f"{data_type}({int(row['DATETIME_PRECISION'])})"

                default_value = row['COLUMN_DEFAULT']
                if default_value:
                    default_value = default_value[1:-1] if default_value.startswith('(') and default_value.endswith(')') else default_value
                    snowflake_default_value = self.sql_server_to_snowflake_fn_mapping.get(default_value, default_value)  # Keep original value if not found

                    # if it's an integer unique identifier (right now in the dict this is not included)
                    if snowflake_default_value == 'autoincrement start 1 increment 1 order':
                        columns.append(f"    {column_name} {data_type} {snowflake_default_value}")
                    # some Snowflake datetime functions expect certain precision, cast
                    elif snowflake_default_value == 'SYSDATE()' or snowflake_default_value == 'CURRENT_TIMESTAMP()':
                        columns.append(f"    {column_name} {data_type} DEFAULT CAST({snowflake_default_value} AS {data_type})")
                    # if it's a boolean data type
                    elif data_type == 'BOOLEAN':
                        columns.append(f"    {column_name} {data_type} DEFAULT TO_BOOLEAN{row['COLUMN_DEFAULT']}")
                    # usual default values from a function  
                    else:
                        columns.append(f"    {column_name} {data_type} DEFAULT {snowflake_default_value}")
                else: # if it doesn't have default value
                    columns.append(f"    {column_name} {data_type}")

            table_schema_query += ",\n".join(columns) + "\n);"
            create_table_query_list.append(table_schema_query)
        return create_table_query_list
    

    def get_null_constraint_commands(self) -> list:
        """
        This function returns a list of ALTER TABLE statements to add NOT NULL constraints in Snowflake.
        Function was written separately to keep the code clean and modular but can be incorporated 
        into CREATE OR REPLACE TABLE statement later on if desired.
        """
        query = """SELECT 
                    c.TABLE_SCHEMA,
                    c.TABLE_NAME,
                    c.COLUMN_NAME,
                    c.DATA_TYPE,
                    CASE WHEN c.IS_NULLABLE = 'NO' THEN 'NOT NULL' ELSE '' END AS NULL_CONSTRAINT
                    FROM INFORMATION_SCHEMA.COLUMNS c
                    WHERE c.TABLE_SCHEMA NOT IN ('sys')
                        AND c.TABLE_NAME NOT IN (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS)
                        AND c.IS_NULLABLE = 'NO';"""
        
        df = pd.read_sql(query, self.sql_server_connector)
        df = df.rename(columns={'TABLE_SCHEMA': 'DB_SCHEMA'})
        df['TABLE_FULL_NAME'] = df['DB_SCHEMA'] + '.' + df['TABLE_NAME']

        alter_null_constraint_query_list = []
        for _, row in df.iterrows():
            null_constraint = row['NULL_CONSTRAINT']
            alter_statement = f"ALTER TABLE {row['TABLE_FULL_NAME']} MODIFY COLUMN {row['COLUMN_NAME']} {null_constraint};"
            alter_null_constraint_query_list.append(alter_statement)
    
        return alter_null_constraint_query_list
    
    def get_pk_constraint_commands(self) -> list:
        """
        This function returns a list of ALTER TABLE statements to add PRIMARY KEY constraints in Snowflake.
        The function groups primary keys by table name and adds them to a single ALTER TABLE statement for each table.
        Only the first constraint name is selected for each table.
        """
        query = """
                WITH CTE_PrimaryKeys AS (
                    SELECT 
                        c.TABLE_SCHEMA,
                        c.TABLE_NAME,
                        STRING_AGG(COALESCE(k.CONSTRAINT_NAME, ''), ',') AS Constraint_Names,
                        STRING_AGG(c.COLUMN_NAME, ',') AS Column_Names
                    FROM INFORMATION_SCHEMA.COLUMNS c
                    LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE k 
                        ON c.TABLE_SCHEMA = k.TABLE_SCHEMA 
                        AND c.TABLE_NAME = k.TABLE_NAME 
                        AND c.COLUMN_NAME = k.COLUMN_NAME
                    WHERE c.TABLE_SCHEMA NOT IN ('sys')
                    AND c.TABLE_NAME NOT IN (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS)
                    AND k.CONSTRAINT_NAME IN (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'PRIMARY KEY')
                    GROUP BY c.TABLE_SCHEMA, c.TABLE_NAME
                )
                SELECT TABLE_SCHEMA, TABLE_NAME, Constraint_Names, Column_Names
                FROM CTE_PrimaryKeys
                """

        df = pd.read_sql(query, self.sql_server_connector)

        alter_pk_constraint_query_list = []
        for _, row in df.iterrows():
            constraint_names = [name.strip() for name in row['Constraint_Names'].split(',') if name.strip()]
            first_constraint_name = constraint_names[0] if constraint_names else ''
            column_names = ', '.join([name.strip() for name in row['Column_Names'].split(',') if name.strip()])
            alter_statement = f"ALTER TABLE {row['TABLE_SCHEMA']}.{row['TABLE_NAME']} ADD CONSTRAINT {first_constraint_name} PRIMARY KEY ({column_names});"
            alter_pk_constraint_query_list.append(alter_statement)

        return alter_pk_constraint_query_list
    

    def get_fk_constraint_commands(self) -> list:
                
        """
        This function returns a list of ALTER TABLE statements to add PRIMARY KEY constraints in Snowflake.
        Function was written separately to keep the code clean and modular but can be incorporated 
        into CREATE OR REPLACE TABLE statement later on if desired. 

        NOTE: Of course, this must be run after the primary key constraints have been created.  
        """  
        query = """
                WITH CTE_PrimaryKey AS (
                    SELECT 
                        c.TABLE_SCHEMA,
                        c.TABLE_NAME,
                        c.COLUMN_NAME,
                        COALESCE(k.CONSTRAINT_NAME, '') AS Constraint_Name
                    FROM INFORMATION_SCHEMA.COLUMNS c
                    LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE k 
                        ON c.TABLE_SCHEMA = k.TABLE_SCHEMA 
                        AND c.TABLE_NAME = k.TABLE_NAME 
                        AND c.COLUMN_NAME = k.COLUMN_NAME
                    LEFT JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS r
                        ON k.CONSTRAINT_NAME = r.CONSTRAINT_NAME
                    LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE f
                        ON r.UNIQUE_CONSTRAINT_NAME = f.CONSTRAINT_NAME
                    WHERE c.TABLE_SCHEMA NOT IN ('sys')
                    AND c.TABLE_NAME NOT IN (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS)
                ),

                CTE_ForeignKey AS (
                    SELECT 
                        t.name AS 'TABLE_NAME_REF',
                        fk.name AS 'FK_CONSTRAINT_NAME_REF',
                        rc.name AS 'FK_COLUMN_NAME',
                        rt.name AS 'REFERENCED_TABLE_NAME',
                        s.name AS 'REFERENCED_SCHEMA_NAME'
                    FROM sys.foreign_keys AS fk
                    INNER JOIN sys.tables AS t ON fk.parent_object_id = t.object_id
                    INNER JOIN sys.foreign_key_columns AS fkc ON fkc.constraint_object_id = fk.object_id
                    INNER JOIN sys.tables AS rt ON fk.referenced_object_id = rt.object_id
                    INNER JOIN sys.columns AS rc ON rc.object_id = fkc.referenced_object_id AND rc.column_id = fkc.referenced_column_id
                    INNER JOIN sys.schemas AS s ON s.schema_id = rt.schema_id
                )

                SELECT cte_pk.TABLE_SCHEMA, cte_pk.TABLE_NAME, cte_pk.COLUMN_NAME, cte_pk.CONSTRAINT_NAME, cte_fk.REFERENCED_SCHEMA_NAME, cte_fk.REFERENCED_TABLE_NAME
                FROM CTE_PrimaryKey cte_pk
                JOIN CTE_ForeignKey cte_fk ON cte_pk.Constraint_Name = cte_fk.FK_CONSTRAINT_NAME_REF;
                """

        df = pd.read_sql(query, self.sql_server_connector)

        alter_fk_constraint_query_list = []
        for _, row in df.iterrows():
            constraint_name = row['CONSTRAINT_NAME']     
            alter_statement = f"ALTER TABLE {row['TABLE_SCHEMA']}.{row['TABLE_NAME']} ADD CONSTRAINT {constraint_name} FOREIGN KEY ({row['COLUMN_NAME']}) REFERENCES {row['REFERENCED_SCHEMA_NAME']}.{row['REFERENCED_TABLE_NAME']};"
            alter_fk_constraint_query_list.append(alter_statement)
        
        return alter_fk_constraint_query_list
    
    def get_create_views_commands(self) -> list:
        """
        This function returns a list of CREATE VIEW commands for the migration in Snowflake.
        The view definitions are transpiled from T-SQL to Snowflake SQL using sqlglot.
        This method has some extra logic to clean up the view definition and execute the queries 
        since for views we are parsing the files directly. 

        NOTE: IN DEV. Some minor parsing issues may occur when transpiling some views. 
        """
        create_view_query_list = []
        failed_view_query_list = []
        views_df = self.get_sql_server_db_views_skeleton()

        for (db_schema, table_name), group in views_df.groupby(['DB_SCHEMA', 'VIEW_NAME']):
            schema_name = self.format_to_snake_case(db_schema) if self.convert_to_snake_case else db_schema
            view_name = self.format_to_snake_case(table_name) if self.convert_to_snake_case else table_name
            
            cursor = self.sql_server_connector.cursor()
            cursor.execute(f"SELECT OBJECT_DEFINITION(OBJECT_ID('[{schema_name}].[{view_name}]')) AS ViewDefinition")
            view_definition = cursor.fetchone()[0]

            # Transpile T-SQL view definition to Snowflake SQL using sqlglot
            try:
                translated_view_definition = sqlglot.transpile(view_definition, read='tsql', write='snowflake')
                
                # remove double quotations to prevent issues in Snowflake view creation
                schema_name_no_quotes = schema_name.replace('"', '')
                for i in range(len(translated_view_definition)):
                    translated_view_definition[i] = translated_view_definition[i].replace(f'"{schema_name_no_quotes}".', f'{schema_name_no_quotes}.')
                    translated_view_definition[i] = translated_view_definition[i].replace(f'"{view_name}"', f'{view_name}')
                    for schema_table in self.all_table_names:
                        table_wo_schema = schema_table.split('.')[-1]
                        translated_view_definition[i] = translated_view_definition[i].replace(f'"{table_wo_schema}"', f'{table_wo_schema}')

                create_view_query_list.extend(translated_view_definition)
            except:
                failed_view_query_list.append(translated_view_definition)
                continue

        return create_view_query_list, failed_view_query_list

    def execute_create_commands(self, object) -> None:
        """
        This function executes the CREATE commands in Snowflake for specified object.
        Currently supports: Schemas, Tables, Views, Null Constraints, PK Constraints, FK Constraints.
        """
        if object == 'Schemas': query_list = self.get_create_schema_commands()
        elif object == 'Tables': query_list = self.get_create_table_commands()
        elif object == 'Views': query_list = self.get_create_views_commands()   
        elif object == 'Null Constraints': query_list = self.get_null_constraint_commands()
        elif object == 'PK Constraints': query_list = self.get_pk_constraint_commands()
        elif object == 'FK Constraints': query_list = self.get_fk_constraint_commands()
        else: print("Invalid object. Please choose from: Schemas, Tables, Views, Null Constraints, PK Constraints, FK Constraints")

        for query in tqdm(query_list, desc=f"Creating {object}"):
            try:
                #self.snowflake_cursor.execute_async(query) # async execution
                self.snowflake_cursor.execute(query)
            except Exception as e:
                logging.error(f"Error executing {object} creation query: {query}. Exception: {e}")

    def initialize_table_queue_file(self):
        """
        This function initializes the table queue file with all table names. The reason is that we want to keep track of
        tables that have not been migrated yet. We will remove each table from the queue as we migrate it. Due to VPN issues
        we may have to run the migration in chunks and this file will help us keep track of remaining tables.
        """

        queue_dir = "queue"
        if not os.path.exists(queue_dir):
            os.makedirs(queue_dir)

        tables = self.all_table_names

        # Only add to queue tables that don't have data in Snowflake yet
        tables_without_data = []
        for table in tables:
            rows_query = f"SELECT COUNT(*) FROM {table}"
            total_rows = pd.read_sql(rows_query, self.snowflake_connector).values[0][0]
            if total_rows == 0:
                tables_without_data.append(table)

        queue_file_path = os.path.join(queue_dir, "remaining_tables_queue.txt")
        with open(queue_file_path, 'w') as file:
            for table in tables_without_data:
                file.write(table + '\n')

    def download_and_upload_data(self, output_dir="./data") -> None:
        """
        This function downloads data from SQL Server and uploads it to Snowflake (i.e., PUT command to Table Stage).
        NOTE: we are also chunking the table data to prevent memory issues in Pandas. After processing it we are also deleting 
        each file from disk since we are working with hundreds GBs of data in some tables.
        """
        queue_dir = "queue"
        queue_file_path = os.path.join(queue_dir, "remaining_tables_queue.txt")  # This is where the queue file is saved

        if not os.path.exists(output_dir):  # This is where the data files itself will be saved
            os.makedirs(output_dir)

        queued_tables = []
        with open(queue_file_path, 'r') as file:
            queued_tables = file.read().splitlines()

        remaining_tables = queued_tables.copy()

        for table_name in tqdm(queued_tables, desc='Tables Progress'):
            print(f"-----------{table_name}-----------")
            schema, table = table_name.split('.')
            rows_query = f"SELECT COUNT(*) FROM {table_name}"
            total_rows = pd.read_sql(rows_query, self.sql_server_connector)[''].values[0]

            if total_rows > 0:

                storage_query = f"""SELECT 
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
                total_gb = pd.read_sql(storage_query, self.sql_server_connector)['TotalSpaceGB'].values[0]

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

                for chunk_num in tqdm(range(num_chunks), desc=f'Chunks Progress for {table_name}'):
                    offset = chunk_num * chunk_row_size

                    # this query will return a subset of the source table data according to offset and chunk_row_size
                    query = f"""SELECT * FROM {table_name} 
                            ORDER BY (SELECT NULL) 
                            OFFSET {offset} ROWS 
                            FETCH NEXT {chunk_row_size} ROWS ONLY"""
                    data = pd.read_sql(query, self.sql_server_connector)

                    if self.save_format == 'parquet':  # UUID datatypes can be a bit finicky in parquet
                        for col in data.select_dtypes(include=['object']).columns:
                            if data[col].apply(lambda x: isinstance(x, uuid.UUID)).any():
                                data[col] = data[col].astype(str)
                        for col in data.select_dtypes(include=['datetime64']).columns:
                            data[col] = data[col].astype('datetime64[ms]')

                    formatted_table_name = self.format_to_snake_case(table) if self.convert_to_snake_case else table
                    file_path = os.path.join(schema_dir, f"{formatted_table_name.upper()}_chunk{chunk_num + 1}.{self.save_format}")

                    if self.save_format == 'csv':
                        data.to_csv(file_path, index=False)
                    elif self.save_format == 'parquet':
                        #data.to_parquet(file_path)
                        data.to_parquet(file_path, engine='pyarrow', coerce_timestamps='ms', allow_truncated_timestamps=True)

                    print(f"Data for {table_name} (Chunk {chunk_num + 1}/{num_chunks}) downloaded and saved as {self.save_format.upper()} successfully.")

                    # -------------------------------- UPLOAD --------------------------------
                    try:
                        self.snowflake_cursor.execute(f"USE SCHEMA {schema}")
                        upload_query = f"PUT file://{file_path} @%{formatted_table_name}"
                        self.snowflake_cursor.execute(upload_query)
                        print(f"Uploaded {file_path} to its Snowflake Table Stage")
                        logging.info(f"Uploaded {file_path} to its Snowflake Table Stage")
                    except Exception as e:
                        print(f"Error uploading {file_path} to its Snowflake Table Stage. Exception: {e}")
                        logging.error(f"Error uploading {file_path} to its Snowflake Table Stage. Exception: {e}")

                    # -------------------------------- DELETE --------------------------------
                    os.remove(file_path)
                    print(f"Local file {file_path} deleted successfully.")   
                
                remaining_tables.remove(table_name)  # Data successfully uploaded to Snowflake, remove from queue

                # Update the queue file with remaining tables
                with open(queue_file_path, 'w') as file:
                    for table in remaining_tables:
                        file.write(table + '\n')

    
    def load_stage_data(self) -> None:
        """
        This function loads data from Table Stages to their respective tables in Snowflake.
        NOTE: We are looking for schemas and tables in *SNOWFLAKE* since creation of some tables may have failed
        due to naming convention differences and we want to load data to the tables that were successfully created.
        """
        db_name = self.snowflake_connector.database
        schemas_query = f"SHOW SCHEMAS IN {db_name}"
        schemas_result = self.snowflake_cursor.execute(schemas_query).fetchall() # this query returns a few things 

        for schema_info in tqdm(schemas_result, desc='Schemas Progress'):
            schema_name = schema_info[1] # schema name is 2nd element
            use_schema_query = f"USE SCHEMA {db_name}.{schema_name}"
            self.snowflake_cursor.execute(use_schema_query)

            # loop over each table in the schema
            tables_query = f"SHOW TABLES"
            tables_result = self.snowflake_cursor.execute(tables_query).fetchall()

            for table_info in tqdm(tables_result, desc='Tables Progress'):
                table_name = table_info[1]
                list_query = f"LIST @%{table_name};"
                list_result = self.snowflake_cursor.execute(list_query).fetchall()
                total_rows = pd.read_sql(f"SELECT COUNT(*) FROM {table_name}", self.snowflake_connector).values[0][0]

                # -------------------- LOAD DATA FROM STAGE TO TABLE --------------------

                if len(list_result) > 0 and total_rows == 0: # only load if there are files in the table stage and if table has not been loaded before
                    if self.save_format == 'parquet':
                        copy_query = f"""COPY INTO {db_name}.{schema_name}.{table_name}
                                        FROM @%{table_name}
                                        FILE_FORMAT = (
                                            TYPE=PARQUET,
                                            REPLACE_INVALID_CHARACTERS=TRUE,
                                            BINARY_AS_TEXT=FALSE
                                        )
                                        MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE
                                        ON_ERROR=ABORT_STATEMENT
                                        PURGE=FALSE
                                        """
                    elif self.save_format == 'csv':
                        copy_query =    f"""COPY INTO {db_name}.{schema_name}.{table_name}
                                        FROM @%{table_name}
                                        FILE_FORMAT = (
                                            TYPE=CSV,
                                            SKIP_HEADER=1,
                                            FIELD_DELIMITER=',',
                                            TRIM_SPACE=FALSE,
                                            FIELD_OPTIONALLY_ENCLOSED_BY=NONE,
                                            REPLACE_INVALID_CHARACTERS=TRUE,
                                            DATE_FORMAT=AUTO,
                                            TIME_FORMAT=AUTO,
                                            TIMESTAMP_FORMAT=AUTO
                                        )
                                        ON_ERROR=ABORT_STATEMENT
                                        PURGE=FALSE
                                        """
                    try:
                        self.snowflake_cursor.execute(copy_query)
                        print(f"Data loaded to table {table_name} from its Table Stage in schema {schema_name} successfully.")
                        logging.info(f"Data loaded table {table_name} from its Table Stage in schema {schema_name} successfully.")
                    except Exception as e:
                        print(f"Error loading data to table {table_name} in schema {schema_name}. Exception: {e}")
                        logging.error(f"Error loading data to table {table_name} in schema {schema_name}. Exception: {e}")

    def purge_all_table_stage_files(self) -> None:
        """
        This function purges files from the Snowflake Table Stages. Just for being careful in the loading we set up
        PURGE=FALSE in load_stage_data but we can call this method once we're sure we don't need the files anymore. 
        """
        db_name = self.snowflake_connector.database
        schemas_query = f"SHOW SCHEMAS IN {db_name}"
        schemas_result = self.snowflake_cursor.execute(schemas_query).fetchall()

        for schema_info in tqdm(schemas_result, desc='Schemas Progress'):
            schema_name = schema_info[1]
            use_schema_query = f"USE SCHEMA {db_name}.{schema_name}"
            self.snowflake_cursor.execute(use_schema_query)

            tables_query = f"SHOW TABLES"
            tables_result = self.snowflake_cursor.execute(tables_query).fetchall()

            for table_info in tqdm(tables_result, desc='Tables Progress'):
                table_name = table_info[1]
                list_query = f"LIST @%{table_name};"
                list_result = self.snowflake_cursor.execute(list_query).fetchall()

                if len(list_result) > 0:  # if there are files in the table stage
                    purge_query = f"REMOVE @%{table_name};"
                    try:
                        self.snowflake_cursor.execute(purge_query)
                        print(f"Table stage files from {table_name} succesfully purged.")
                        logging.info(f"Table stage files from {table_name} succesfully purged.")
                    except Exception as e:
                        print(f"Error purging table stage of {table_name} Exception: {e}")
                        logging.error(f"Error purging table stage of {table_name} Exception: {e}")
    
    
    def execute_migration(self) -> None:
        """
        Method to wrap up core migration steps:
        1. Create schema skeleton in Snowflake
        2. Create table skeleton in Snowflake
        3. Download data as parquet/csv files, Upload to Snowflake Table Stage
        4. Load data from Snowflake Table Stage to respective Snowflake tables

        NOTE: This is the end goal but due to VPN issues it's unlikely that we will be able to run this in one go.
        Which is why we have the queue file to keep track of remaining tables and I ran methods separately in a notebook.
        """

        ## This block transfers table skeletons from SQL Server to Snowflake
        self.test_missing_datatypes()
        self.test_mapping()
        self.execute_create_commands('Schemas')
        self.execute_create_commands('Tables')
        self.execute_create_commands('Views')
        self.execute_create_commands('Null Constraints')
        self.execute_create_commands('PK Constraints')
        self.execute_create_commands('FK Constraints')

        ##  This blocks transfers table **DATA** from SQL Server to Snowflake
        ## Uncomment if data transfer is desired
        self.initialize_table_queue_file()
        self.download_and_upload_data()
        self.load_stage_data()


# --------------------------------------------- Example Usage --------------------------------------------- # 
if __name__ == "__main__":
    sql_server = "hgTestmdmdb01.sql.hgw-test.aws.healthgrades.zone"
    sql_server_username = "XT-OJimenez"
    sql_server_password = ""
    sql_server_db = "ODS1Stage"

    snowflake_account = "OPA66287.us-east-1" # Healthgrades account
    snowflake_username = "OJIMENEZ@RVOHEALTH.COM"
    snowflake_warehouse = "MDM_XSMALL"
    snowflake_db = "ODS1_STAGE_TEAM"
    snowflake_role = "APP-SNOWFLAKE-HG-MDM-POWERUSER" 

    # outside of Migrator class since at some point different authenticators might be used (e.g., future projects)
    sql_server_connector = pymssql.connect(server=sql_server, user=sql_server_username, password=sql_server_password, database=sql_server_db)
    snowflake_connector = snowflake.connector.connect(user=snowflake_username, account=snowflake_account, authenticator="externalbrowser",
                                                    warehouse=snowflake_warehouse, database=snowflake_db, role=snowflake_role)

    snowflake_migrator = SnowflakeMigrator(sql_server_connector, snowflake_connector)

    snowflake_migrator.execute_create_commands(object='Schemas')
