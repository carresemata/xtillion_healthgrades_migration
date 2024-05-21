# Create a function to format the table dependencies to lowercase
import os
import re

def remove_conditionals():
    base_dir = os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/tables')
    for schema in os.listdir(base_dir):
            schema_path = os.path.join(base_dir, schema)
            for table in os.listdir(schema_path):
                table_path = os.path.join(schema_path, table)
                file_path = os.path.join(table_path, f'spu_translated_{table}.sql') 

    # testing with a single file
    # file_path = os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/tables/Base/Office/spu_translated_Office.sql')
    # Open the file and read its content
                with open(file_path, 'r') as f:
                    content = f.read()

                # 1. Change the section numbers
                content = re.sub(r'0\. table dependencies', '1. table dependencies', content, flags=re.IGNORECASE)
                content = re.sub(r'1\. declaring variables', '2. declaring variables', content, flags=re.IGNORECASE)
                content = re.sub(r'-- no conditionals', '', content)

                # 2. Remove the '2. conditionals' section including the decorative lines around it
                # pattern = r'--+2\.conditionals.*?[\s\S]*?--+'
                # content = re.sub(pattern, '', content, flags=re.DOTALL | re.IGNORECASE)

                # Write the updated content back to the file
                with open(file_path, 'w') as f:
                    f.write(content)

                # Read the contents of the file into a list of lines
                with open(file_path, 'r') as f:
                    lines = f.readlines()
                
                # Find the index of the line containing '2. conditionals'
                target_line_index = None
                for i, line in enumerate(lines):
                    if '2.conditionals' in line.lower():  # Check for '2. conditionals' in a case-insensitive manner
                        target_line_index = i
                        break
                
                # If the line was found, remove it along with the line above and below it
                if target_line_index is not None:
                    # Make sure not to go out of bounds when removing lines
                    start_index = max(0, target_line_index - 1)  # Prevent negative index
                    end_index = min(len(lines), target_line_index + 2)  # Prevent index out of bounds
                    del lines[start_index:end_index]
                
                # Write the modified lines back to the file
                with open(file_path, 'w') as f:
                    f.writelines(lines)

remove_conditionals()
