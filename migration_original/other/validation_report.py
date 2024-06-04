import pymssql
import snowflake.connector
import pandas as pd
import numpy as np
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import Paragraph
from reportlab.lib import colors

class Validator: 
    pass

class SnowflakeTableValidator(Validator):
    def __init__(self, sql_server_connector, snowflake_connector):
        self.sql_server_connector = sql_server_connector
        self.snowflake_connector = snowflake_connector

    def sample_validation(self, table_name_sql_server, table_name_snowflake, match_ids, sample_size):
        """
        This function validates a table in SQL Server and Snowflake by comparing qualitatively actual data in the tables.
        It returns a list of the columns that are identical and a dictionary of tuples with a sample to illustrate
        the differences between the two tables. This will help debug any issues that arise during the migration.
        NOTE: match_id is a pseudo primary key that is used to match the rows between the two tables. It must be 
        unique, otherwise the comparison will not work.
        """
        # ----------------- Snowflake -----------------
        snowflake_query = f"SELECT * FROM {table_name_snowflake} LIMIT {sample_size}"
        df_snowflake = pd.read_sql(snowflake_query, self.snowflake_connector)
        df_snowflake.columns = df_snowflake.columns.str.upper()
        df_snowflake = df_snowflake.astype(str)

        snowflake_ids = {}
        for match_id in match_ids:
            snowflake_ids[match_id] = [str(i) for i in df_snowflake[match_id.upper()].tolist()]

        # ----------------- SQL Server -----------------
        sql_server_sub_dfs = []
        for i in range(len(snowflake_ids[match_ids[0]])):  # Assuming all lists have the same length
            sql_server_query = f"SELECT * FROM {table_name_sql_server} WHERE "
            key_value_pairs = [f"{key} = '{values[i]}'" for key, values in snowflake_ids.items()]
            and_conditions = " AND ".join(key_value_pairs)
            final_query = sql_server_query + and_conditions
            sql_server_sub_df = pd.read_sql(final_query, self.sql_server_connector)
            sql_server_sub_dfs.append(sql_server_sub_df)

        df_sql_server = pd.concat(sql_server_sub_dfs, ignore_index=True)
        df_sql_server = df_sql_server.astype(str)
        df_sql_server.columns = df_sql_server.columns.str.upper()

        # ----------------- Compare -----------------
        identical_cols = []
        different_cols = []

        for col in df_sql_server.columns:
            if df_sql_server[col].equals(df_snowflake[col]):
                identical_cols.append(col)
            else:
                different_cols.append(col)

        different_cols_df = pd.DataFrame(columns=["Column Name", "Match ID", "SQL Server Value", "Snowflake Value"])
        for col in different_cols:
            found_difference = False
            for index, (val_sql_server, val_snowflake) in enumerate(zip(df_sql_server[col], df_snowflake[col])):
                if val_sql_server != val_snowflake:
                    val_id = df_sql_server[match_ids[0].upper()].iloc[index]
                    diff_row = {"Column Name": col, f"Match ID": val_id, "SQL Server Value": val_sql_server, "Snowflake Value": val_snowflake}
                    different_cols_df = pd.concat([different_cols_df, pd.DataFrame(diff_row, index=[0])], ignore_index=True)                    
                    found_difference = True
                    break

            if found_difference:
                continue

        return identical_cols, different_cols_df
    

    def aggregate_validation(self, table_name_sql_server, table_name_snowflake):
        """
        This function validates a table in SQL Server and Snowflake by comparing quantitatively the number of columns,
        number of rows, total number of nulls per column, and number of unique values in each column. 
        """
        schema = table_name_sql_server.split(".")[0]
        name = table_name_sql_server.split(".")[1]

        snowflake_schema = table_name_snowflake.split(".")[0]
        snowflake_name = table_name_snowflake.split(".")[1]

        ##################### Validation Metric 1: Total Columns #################
        query_total_cols_sql_server = f"SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS \
                            WHERE TABLE_SCHEMA = '{schema}' AND TABLE_NAME = '{name}'" 
        query_total_cols_snowflake = f"SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS \
                            WHERE TABLE_SCHEMA = '{snowflake_schema.upper()}' AND TABLE_NAME = '{snowflake_name.upper()}'"
        
        total_cols_sql_server = pd.read_sql(query_total_cols_sql_server, self.sql_server_connector).iloc[0, 0]
        total_cols_snowflake = pd.read_sql(query_total_cols_snowflake, self.snowflake_connector).iloc[0, 0]

        ##################### Validation Metric 2: Total Rows ####################
        query_total_rows_sql_server = f"SELECT COUNT(*) FROM {table_name_sql_server}"
        query_total_rows_snowflake = f"SELECT COUNT(*) FROM {table_name_snowflake}"
        total_rows_sql_server = pd.read_sql(query_total_rows_sql_server, self.sql_server_connector).iloc[0, 0]
        total_rows_snowflake = pd.read_sql(query_total_rows_snowflake, self.snowflake_connector).iloc[0, 0]
        
        ############### Validation Metric 3: Total Nulls per Column ###############
        col_names_query = f"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '{schema}' AND TABLE_NAME = '{name}'"
        col_names = pd.read_sql(col_names_query, self.sql_server_connector)["COLUMN_NAME"].tolist()
        nulls_df = pd.DataFrame(columns=['Column_Name','Total_Nulls_SQLServer','Total_Nulls_Snowflake'])
        for col_name in col_names:
            query_nulls = f"SELECT COUNT(*) FROM {table_name_sql_server} WHERE {col_name} IS NULL"
            total_nulls_sql_server = pd.read_sql(query_nulls, self.sql_server_connector).iloc[0, 0]
            total_nulls_snowflake = pd.read_sql(query_nulls, self.snowflake_connector).iloc[0, 0]

            new_row = {'Column_Name': col_name,
                   'Total_Nulls_Snowflake': total_nulls_snowflake,
                   'Total_Nulls_SQLServer': total_nulls_sql_server}
        
            nulls_df = pd.concat([nulls_df, pd.DataFrame([new_row])], ignore_index=True)
            

        nulls_df["Total_Nulls_SQLServer"] = nulls_df["Total_Nulls_SQLServer"].astype(int)
        nulls_df["Total_Nulls_Snowflake"] = nulls_df["Total_Nulls_Snowflake"].astype(int)

        # Calculate the margin of error
        nulls_df['Margin (%)'] = np.where(
            (nulls_df['Total_Nulls_SQLServer'] == 0) & (nulls_df['Total_Nulls_Snowflake'] == 0),
            0,
            np.abs((nulls_df['Total_Nulls_SQLServer'] - nulls_df['Total_Nulls_Snowflake']) / nulls_df['Total_Nulls_SQLServer']) * 100
        )

        nulls_df['Margin (%)'] = nulls_df['Margin (%)'].round(1)

        ############### Validation Metric 4: Total Distincts per Column ###############
        distincts_df = pd.DataFrame(columns=['Column_Name','Total_Distincts_SQLServer','Total_Distincts_Snowflake'])
        for col_name in col_names:
            # some columns like geography may give errors with count distinct
            try:
                query_distincts_sql_server = f"SELECT COUNT(DISTINCT {col_name}) FROM {table_name_sql_server}"
                query_ditincts_snowflake = f"SELECT COUNT(DISTINCT {col_name}) FROM {table_name_snowflake}"
                total_distincts_sql_server = pd.read_sql(query_distincts_sql_server, self.sql_server_connector).iloc[0, 0]
                total_distincts_snowflake = pd.read_sql(query_ditincts_snowflake, self.snowflake_connector).iloc[0, 0]
                # distincts_df['Column_Name'] = col_name
                # distincts_df['Total_Distincts_Snowflake']= total_distincts_snowflake
                # distincts_df['Total_Distincts_SQLServer']= total_distincts_sql_server

                new_row = {'Column_Name': col_name,
                   'Total_Distincts_Snowflake': total_distincts_snowflake,
                   'Total_Distincts_SQLServer': total_distincts_sql_server}
        
                distincts_df = pd.concat([distincts_df, pd.DataFrame([new_row])], ignore_index=True)

                # distincts_df = distincts_df.concat({"Column_Name": col_name, 
                #                                     "Total_Distincts_SQLServer": total_distincts_sql_server,
                #                                     "Total_Distincts_Snowflake": total_distincts_snowflake}, ignore_index=True)
            except:
                pass

        distincts_df["Total_Distincts_SQLServer"] = distincts_df["Total_Distincts_SQLServer"].astype(int)
        distincts_df["Total_Distincts_Snowflake"] = distincts_df["Total_Distincts_Snowflake"].astype(int)

        # Calculate the margin of error
        distincts_df['Margin (%)'] = np.where(
            (distincts_df['Total_Distincts_SQLServer'] == 0) & (distincts_df['Total_Distincts_Snowflake'] == 0),
            0,
            np.abs((distincts_df['Total_Distincts_SQLServer'] - distincts_df['Total_Distincts_Snowflake']) / distincts_df['Total_Distincts_SQLServer']) * 100
        )

        distincts_df['Margin (%)'] = distincts_df['Margin (%)'].round(1)

        return total_cols_sql_server, total_cols_snowflake, total_rows_sql_server, total_rows_snowflake, nulls_df, distincts_df
    
    def generate_report_markdown(self, table_name_sql_server, table_name_snowflake, match_ids, sample_size) -> str:
        """
        This function generates a Markdown report with the results of the sample and aggregate validations.
        """
        identical_cols, different_cols_df = self.sample_validation(table_name_sql_server, table_name_snowflake, match_ids, sample_size)
        total_cols_sql_server, total_cols_snowflake, total_rows_sql_server, total_rows_snowflake, nulls_df, distincts_df = self.aggregate_validation(table_name_sql_server, table_name_snowflake)
        ## Some postprocessing to make outputs dfs for report
        identical_count = len(identical_cols)
        different_count = len(different_cols_df)
        identical_percentage = (identical_count / total_cols_sql_server) * 100
        different_percentage = (different_count / total_cols_sql_server) * 100
        report = f"# {table_name_sql_server} Report\n\n"
        ## 1. Sample Validation ##
        report += "## 1. Sample Validation\n\n"
        report += f"Percentage of Identical Columns: {identical_percentage:.2f}% ({identical_count}/{total_cols_sql_server}).\n"
        report += f"Percentage of Different Columns: {different_percentage:.2f}% ({different_count}/{total_cols_sql_server}).\n\n"
        report += "The example below shows a sample row where values are not identical. Important to remember that fields like IDs are never expected to match. Long outputs are truncated since they will be hard to visualize.\n\n"
        report += different_cols_df.to_markdown() + "\n\n"
        ## 2. Aggregate Validation ##
        report += "## 2. Aggregate Validation\n\n"
        ### 2.1 Total Columns ###
        report += "### 2.1 Total Columns\n"
        report += f"- SQL Server: {total_cols_sql_server}\n"
        report += f"- Snowflake: {total_cols_snowflake}\n"
        cols_margin = np.where((total_cols_sql_server == 0) & (total_cols_snowflake == 0), 0,
                        (np.abs(total_cols_sql_server - total_cols_snowflake) / total_cols_sql_server) * 100)
        report += f"- Columns Margin (%): {cols_margin}\n\n"
        ### 2.2 Total Rows ###
        report += "### 2.2 Total Rows\n"
        report += f"- SQL Server: {total_rows_sql_server}\n"
        report += f"- Snowflake: {total_rows_snowflake}\n"
        rows_margin = np.where((total_rows_sql_server == 0) & (total_rows_sql_server == 0), 0,
                        (np.abs(total_rows_sql_server - total_rows_snowflake) / total_rows_sql_server) * 100)
        report += f"- Rows Margin (%): {rows_margin}\n\n"
        ### 2.3 Total Nulls per Column ###
        report += "### 2.3 Nulls per Column\n"
        report += nulls_df.to_markdown() + "\n\n"
        ### 2.4 Total Distincts per Column ###
        report += "### 2.4 Distincts per Column\n"
        report += distincts_df.to_markdown()
        output_file = f"{table_name_snowflake}-report.md"
        with open(output_file, "w") as file:
            file.write(report)
        print(f"Markdown report generated successfully for {table_name_snowflake}!")
        return report

if __name__ == "__main__":
    sql_server = "hgTestmdmdb01.sql.hgw-test.aws.healthgrades.zone"
    sql_server_username = "XT-ASanchez"
    sql_server_password = "mysqlpassword"
    sql_server_db = "ODS1Stage"

    snowflake_account = "OPA66287.us-east-1"  # HG-01 account
    snowflake_username = "ASANCHEZ@RVOHEALTH.COM"
    snowflake_warehouse = "MDM_XSMALL"
    snowflake_db = "ODS1_STAGE_TEAM"
    snowflake_role = "APP-SNOWFLAKE-HG-MDM-POWERUSER"

    # outside of Migrator class since at some point different authenticators might be used (e.g., future projects)
    sql_server_connector = pymssql.connect(server=sql_server, user=sql_server_username, password=sql_server_password, database=sql_server_db)
    snowflake_connector = snowflake.connector.connect(user=snowflake_username, account=snowflake_account, authenticator="externalbrowser",
                                                    warehouse=snowflake_warehouse, database=snowflake_db, role=snowflake_role, arrow_number_to_decimal=True)

    ############################### Example Usage ###############################
    table_name_sql_server = "BASE.CITYSTATEPOSTALCODE"  
    table_name_snowflake = "BASE.CITYSTATEPOSTALCODE"  # in case it's a different schema or has different naming convention 
    match_ids = ["CITYSTATEPOSTALCODEID"] # we should remember to never use IDs since we are creating them in runtime
    sample_size = 10 # rows for sample validation
    snowflake_validator = SnowflakeTableValidator(sql_server_connector, snowflake_connector)
    snowflake_validator.generate_report_markdown(table_name_sql_server, table_name_snowflake, match_ids, sample_size)
