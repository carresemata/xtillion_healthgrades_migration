# Create a function to format the table dependencies to lowercase
import os
import re

def format_table_dependencies():
    base_dir = os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/tables')
    for schema in os.listdir(base_dir):
            schema_path = os.path.join(base_dir, schema)
            for table in os.listdir(schema_path):
                table_path = os.path.join(schema_path, table)
                file_path = os.path.join(table_path, f'spu_translated_{table}.sql') 

    # testing with a single file
    # file_path = os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/tables/Base/Address/spu_translated_Address.sql')
                with open(file_path, 'r') as f:
                    content = f.read()

                # Define the keywords
                keywords = ['FROM', 'JOIN', 'LEFT JOIN', 'RIGHT JOIN', 'INNER JOIN', 'SELECT', 'WHERE', 'AND', 'OR', 
                            'ON', 'GROUP BY', 'ORDER BY', 'HAVING', 'UNION', 'UNION ALL', 'AS', 'CURRENT_TIMESTAMP', 
                            'UUID_STRING', 'SYSDATE', 'INSERT', 'VALUES', 'NULL', 'UPDATE', 'CURRENT_USER'
                            'SET', 'DELETE', 'TRUNCATE', 'IF', 'END IF', 'ELSE', 'THEN', 'NULLIF', 'IFNULL', 'DISTINCT', 
                            'QUALIFY', 'ROW_NUMBER', 'OVER', 'PARTITION',  'BY' , 'DESC', 'WHEN NOT MATCHED', 'REPLACE'
                            'WHEN MATCHED', 'USING', 'MERGE INTO', 'IFF', 'TRIM', 'UPPER', 'LOWER', 'IS', 'ARRAY_AGG', 'VARCHAR', 'TO_VARIANT'
                            'SQL Statements', 'Actions', 'Inserts', 'Updates', 'JSON', 'WITH', 'NOT', 'EXISTS', 'EXECUTE IMMEDIATE']

                # 1. For each keyword, replace its occurrence with the lowercase version in the content
                for keyword in keywords:
                    content = re.sub(rf'\b{keyword}\b', keyword.lower(), content, flags=re.IGNORECASE)

                # 2. Replace anything with a dot (.) to lowercase
                content = re.sub(r'(\b\w+\.\w+\b)', lambda x: x.group().lower(), content)

                # 3. Change the section from DECLARE to BEGIN; to lowercase
                content = re.sub(r'(DECLARE.*?BEGIN)', lambda x: x.group().lower(), content, flags=re.DOTALL | re.IGNORECASE)

                # 3. Change everything from 5. to END; to lowercase
                content = re.sub(r"(5\..*END;)", lambda x: x.group().lower(), content, flags=re.DOTALL | re.IGNORECASE)
                
                # Write the updated content to the file
                with open(file_path, 'w') as f:
                    f.write(content)


format_table_dependencies()
