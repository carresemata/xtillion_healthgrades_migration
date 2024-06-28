import re 
import os

def extract_p_json_to_xml_calls(sql):
    calls = []
    func_name = "utils.p_json_to_xml"
    start_pos = 0

    while start_pos < len(sql):
        # Find the start of the function call
        start_pos = sql.find(func_name, start_pos)
        if start_pos == -1:
            break

        # Find the opening parenthesis
        start_paren = sql.find('(', start_pos)
        if start_paren == -1:
            break

        # Use a stack to find the matching closing parenthesis
        stack = []
        end_pos = start_paren
        while end_pos < len(sql):
            if sql[end_pos] == '(':
                stack.append('(')
            elif sql[end_pos] == ')':
                stack.pop()
                if not stack:
                    break
            end_pos += 1

        if stack:
            raise ValueError("Unmatched parentheses in SQL")

        # Extract the full function call including the signature
        call_content = sql[start_pos:end_pos+1]
        calls.append(call_content)

        # Move the start position forward
        start_pos = end_pos + 1
    return calls

def replace_json_calls_with_placeholder(sql_procedure):
    calls = extract_p_json_to_xml_calls(sql_procedure)
    for call in calls:
        temp = call.replace('replace(', '')
        pattern = r'"([a-z,A-Z]+)":[^a-zA-Z]*([a-zA-Z\._]+)|varchar[^\']*\'([a-zA-Z]*)\'[^\']*\'([a-zA-Z]*)\''
        matches = re.findall(pattern, temp)
        new_string = write_xml(matches)
        sql_procedure = sql_procedure.replace(call, new_string)
    return sql_procedure

def write_xml (matches):
    new_string = ''
    for match in matches:
        if match[0] != '' and match[1] != '':
            new_string += f'iff({match[1]} is not null,\'<{match[0]}>\' || {match[1]} || \'</{match[0]}>\',\'\') ||\n'
        elif match[3] != '' or match[2] != '':
            last_occurrence = new_string.rfind('||')
            new_string = new_string[:last_occurrence]
            if match[3] != '':
                new_string = f'listagg( \'<{match[3]}>\' || {new_string} || \'</{match[3]}>\',\'\')'
            else:
                new_string = f'listagg( {new_string} ,\'\')'
            if match[2] != '':
                new_string = f'\'<{match[2]}>\' || {new_string} || \'</{match[2]}\''
    return new_string


if __name__ == "__main__":
    # Get a list of all files in the directory that contain "translated" in their name
    test = '''
         utils.p_json_to_xml(
             ARRAY_AGG(
                 '{ ' ||
                 IFF(SpecialtyCode IS NOT NULL, '"spc":' || '"' || SpecialtyCode || '"', '')
                 || ' }'
             )::VARCHAR,
             '',
             ''
         )

'''


    print(write_xml([test]))
    # directory = 'ODS1Stage/tables/'
    # schemas = os.listdir(directory)

    # # Loop over the files
    # for schema in schemas:
    #     # Open the file
    #     tabes_directory = os.path.join(directory, schema)
    #     tables = os.listdir(tabes_directory)
    #     for table in tables:
    #         table_path = os.path.join(tabes_directory, table)
    #         files = os.listdir(table_path)
    #         for file in files:
    #             if 'translated' in file:
    #                 file_path = os.path.join(table_path, file)
    #                 new_content = None
    #                 with open(file_path, 'r') as f:
    #                     sql_procedure = f.read()
    #                     if "p_json_to_xml" in sql_procedure.lower():
    #                         new_content = replace_json_calls_with_placeholder(sql_procedure)
    #                 if new_content:
    #                     with open(file_path, 'w') as f:
    #                         f.write(new_content)

    # replace_json_calls_with_placeholder(sql_procedure)