import os
import re

def add_monitoring_logs():
    base_dir = os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/tables')
    for schema in os.listdir(base_dir):
            schema_path = os.path.join(base_dir, schema)
            for table in os.listdir(schema_path):
                table_path = os.path.join(schema_path, table)
                file_path = os.path.join(table_path, f'spu_translated_{table}.sql')   
    
    #testing file_path
    # table = 'Address'
    # file_path = os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/tables/Base/Address/spu_translated_Address.sql')
                with open(file_path, 'r') as f:
                    content = f.read()
                        
                    content_updated = False

                    # STEP 1: Add the monitoring logs
                    match = re.search(r"status := 'Completed successfully';(.*?)END;", content, re.DOTALL | re.IGNORECASE)
                    if match: 
                        monitoring_logs = f"""
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        RETURN status;

        EXCEPTION
        WHEN OTHER THEN
            status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, SPLIT_PART(REGEXP_SUBSTR(:status, 'Error code: ([0-9]+)'), ':', 2)::INTEGER, TRIM(SPLIT_PART(SPLIT_PART(:status, 'SQL Error:', 2), 'Error code:', 1)), SPLIT_PART(REGEXP_SUBSTR(:status, 'SQL State: ([0-9]+)'), ':', 2)::INTEGER; 

            RETURN status;
"""
                        content = content.replace(match.group(1), monitoring_logs)
                        content_updated = True
                                    
                    # STEP 2: Add the new variables for the monitoring logs
                    match = re.search(r"status STRING;.*", content)
                    if match:
                        new_vars = f"""
    procedure_name varchar(50) default('sp_load_{table}');
    execution_start DATETIME default getdate();
"""
                        # Find the position where to insert new variables
                        insert_pos = match.end()
                        # Insert new variables into the content
                        content = content[:insert_pos] + new_vars + content[insert_pos:]
                        content_updated = True

                    #  where you see ODS1_STAGE, replace it with ODS1_STAGE_TEAM
                    # match = re.search(r"ODS1_STAGE", content)
                    # if match:
                    #     content = content.replace('ODS1_STAGE', 'ODS1_STAGE_TEAM')
                    #     content_updated = True

                    # Write the new content to the file
                    if content_updated:
                        with open(file_path, 'w') as f:
                            f.write(content)

add_monitoring_logs()

