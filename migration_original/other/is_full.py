import os
import re

def is_full():
    base_dir = os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/tables')
    for schema in os.listdir(base_dir):
                schema_path = os.path.join(base_dir, schema)
                for table in os.listdir(schema_path):
                    table_path = os.path.join(schema_path, table)
                    file_path = os.path.join(table_path, f'spu_translated_{table}.sql') 

    #testing file_path
    # table = 'Address'
    # schema = 'Base'
    # file_path = os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/tables/Base/Address/spu_translated_Address.sql')
                    with open(file_path, 'r') as f:
                        content = f.read()

                        # Match the proc name CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.SCHEMA.SP_LOAD_TABLE()
                        proc_name = f'.SP_LOAD_{table.upper()}()'
                        # Check if the proc name is in the content ignore case
                        if proc_name in content:
                            # modify the content
                            content = content.replace(proc_name, f'.SP_LOAD_{table.upper()}(is_full BOOLEAN)')
                            content_updated = True
                        # Match 
                        match = re.search(r"""5. execution -+\n-+[\n, ]*execute""", content, re.DOTALL | re.IGNORECASE)
                        if match:
                              # define the new content
                                new_content = f""" 5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table {schema}.{table};
end if; 
execute"""
                                # replace the content
                                content = re.sub(match.group(0), new_content, content)
                                content_updated = True
                                # write the new content to the file
                                if content_updated:
                                    with open(file_path, 'w') as f:
                                        f.write(content)

is_full()
